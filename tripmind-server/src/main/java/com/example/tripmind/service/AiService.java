package com.example.tripmind.service;

import com.example.tripmind.dto.ai.ChatDtos.AgentReply;
import com.example.tripmind.dto.ai.ChatDtos.ChatRequest;
import com.example.tripmind.dto.ai.FinalPlanInput;
import com.example.tripmind.exception.BadRequestException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.*;

@Service
public class AiService {

    private final RestClient restClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${grok.api.key}")
    private String groqKey;

    public AiService(RestClient.Builder restClientBuilder) {
        this.restClient = restClientBuilder.build();
    }

    private static final String GROQ_MODEL = "llama-3.3-70b-versatile";
    private static final String GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";

    private static final String PROMPT = """
      You are TripMind’s Trip Planner Agent. Your job is to plan a trip by asking exactly one relevant question at a time and updating the conversation state. Always wait for the user’s reply before asking the next question.
               
      Field order (collect in this order):
      1) source – Starting location (city/country)
      2) destination – Destination (city/country)
      3) groupSize – One of: Solo | Couple | Family | Friends
      4) budget – One of: Low | Medium | High
      5) tripDurationDays – Integer number of days (not dates)
      6) interests – Zero or more from: Adventure | Sightseeing | Cultural | Food | Nightlife | Relaxation
      7) specialReq – Free-text special requirements (optional)
               
      Rules:
      - Ask only one question per turn, and only about the next missing field in the sequence.
      - If an answer is unclear/invalid, ask a short clarifying question for that field.
      - Be concise, friendly, and conversational.
      - Never jump ahead or ask irrelevant questions.
      - When EVERYTHING above has been collected, produce a final confirmation message and STOP asking questions.
               
      UI hint:
      With every response, set `ui` to tell the frontend which widget to render next:
      `"ui": "source" | "destination" | "groupSize" | "budget" | "tripDuration" | "interests" | "specialReq" | "final"`
               
      Definition of `ui: "final"`:
      - Means all required fields are present and validated.
      - Respond with ONE short confirmation sentence summarizing the trip (source → destination, groupSize, budget, tripDurationDays, and interests if any).
      - Do NOT ask another question.
      - Do NOT include options in this turn.
      - Example final turn:
        {
          "resp": "Thanks for the details! I’ll prepare a 4-day, medium-budget trip from Almaty to Paris for a couple with a focus on food and culture.",
          "ui": "final"
        }
               
      Output format (strict):
      Respond only with a single JSON object (no prose). Use this shape EVERY turn:
      {
        "resp": "Text response to user",
        "ui": "source|destination|groupSize|budget|tripDuration|interests|specialReq|final"
      }
    """;

    private static final String FINAL_PROMPT = """
      You are TripMind’s itinerary builder. Generate a complete trip plan strictly as valid JSON.

      You will receive a JSON input with the user's selections:
      {
        "source": "string",
        "destination": "string",
        "groupSize": "Solo|Couple|Family|Friends",
        "budget": "Low|Medium|High",
        "tripDurationDays": number,
        "interests": [ "Adventure" | "Sightseeing" | "Cultural" | "Food" | "Nightlife" | "Relaxation" ],
        "specialReq": "string|null"
      }

      Requirements:
      - Output ONLY JSON (no markdown fences, no prose).
      - Use the schema below.
      - Include 4–8 hotel options fitting the destination and budget if possible.
      - Build a day-by-day itinerary covering the entire tripDurationDays.
      - For each activity, include succinct practical details (address/coords; pricing if relevant; typical visit time).
      - Keep times/durations realistic. Use ISO-like numeric values for coords (not strings).
      - If you are unsure about pricing, use a short human-readable estimate (e.g., "$10–15") rather than "unknown".

      Output schema:
      {
        "trip_plan": {
          "origin": "string",
          "destination": "string",
          "duration_days": number,
          "budget": "Low|Medium|High",
          "group_size": "Solo|Couple|Family|Friends",
          "interests": [ "string" ],
          "special_requirements": "string|null",

          "hotels": [
            {
              "hotel_name": "string",
              "hotel_address": "string",
              "price_per_night": "string",
              "hotel_image_url": "string",
              "geo_coordinates": { "latitude": number, "longitude": number },
              "rating": number,
              "description": "string"
            }
          ],

          "itinerary": [
            {
              "day": number,
              "day_plan": "string",
              "best_time_to_visit_day": "string",
              "activities": [
                {
                  "place_name": "string",
                  "place_details": "string",
                  "place_image_url": "string",
                  "geo_coordinates": { "latitude": number, "longitude": number },
                  "place_address": "string",
                  "ticket_pricing": "string",
                  "time_travel_each_location": "string",
                  "best_time_to_visit": "string"
                }
              ]
            }
          ]
        }
      }
    """;


    /** CHAT AGENT **/
    public AgentReply chat(ChatRequest request) {
        try {
            StringBuilder conversation = new StringBuilder();
            if (request.messages != null && !request.messages.isEmpty()) {
                for (var message : request.messages) {
                    conversation.append(message.role)
                            .append(": ")
                            .append(message.content != null ? message.content : "")
                            .append("\n");
                }
            } else {
                conversation.append("user: Hi\n");
            }

            Map<String, Object> requestBody = Map.of(
                    "model", GROQ_MODEL,
                    "messages", List.of(
                            Map.of("role", "system", "content", PROMPT),
                            Map.of("role", "user", "content", conversation.toString())
                    ),
                    "temperature", 0.2,
                    "max_tokens", 512
            );

            String rawResponse = callGroq(requestBody);
            String jsonResponse = extractBalancedJson(rawResponse);

            return objectMapper.readValue(jsonResponse, AgentReply.class);

        } catch (Exception e) {
            AgentReply errorReply = new AgentReply();
            errorReply.resp = "AI service error. Please try again.";
            errorReply.ui = "source";
            return errorReply;
        }
    }

    /** FINAL ITINERARY **/
    public JsonNode buildItinerary(FinalPlanInput input) {
        try {
            String userState = objectMapper.writeValueAsString(input);

            Map<String, Object> requestBody = Map.of(
                    "model", GROQ_MODEL,
                    "messages", List.of(
                            Map.of("role", "system", "content", FINAL_PROMPT),
                            Map.of("role", "user", "content", userState)
                    ),
                    "temperature", 0.25,
                    "max_tokens", 8000
            );

            String rawResponse = callGroq(requestBody);
            String jsonResponse = extractBalancedJson(rawResponse);

            return objectMapper.readTree(jsonResponse);

        } catch (Exception e) {
            throw new BadRequestException("Failed to build itinerary: " + e.getMessage());
        }
    }


    /** =============== GROQ CALL =============== **/
    private String callGroq(Map<String, Object> requestBody) {
        ResponseEntity<String> response = restClient.post()
                .uri(GROQ_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + groqKey)
                .body(requestBody)
                .retrieve()
                .toEntity(String.class);

        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            throw new BadRequestException("Groq API error: " + response.getStatusCode());
        }

        try {
            JsonNode root = objectMapper.readTree(response.getBody());
            String content = root.path("choices").path(0).path("message").path("content").asText();
            return content.trim();
        } catch (Exception e) {
            throw new BadRequestException("Failed to parse Groq response: " + e.getMessage());
        }
    }

    /** Extract balanced JSON from raw response **/
    private String extractBalancedJson(String raw) {
        if (raw == null || raw.isBlank()) {
            return "{}";
        }

        String text = raw.trim()
                .replace("```json", "")
                .replace("```", "")
                .trim();

        int objectStart = text.indexOf('{');
        int arrayStart = text.indexOf('[');

        if (text.startsWith("```")) {
            text = text.replaceFirst("```json", "```");
            int newlineIndex = text.indexOf('\n');
            if (newlineIndex > 0) {
                text = text.substring(newlineIndex + 1).trim();
            }
            if (text.endsWith("```")) {
                text = text.substring(0, text.length() - 3).trim();
            }
        }

        int startIndex = -1;
        char openChar = 0;
        char closeChar = 0;

        if (objectStart >= 0 && (arrayStart < 0 || objectStart < arrayStart)) {
            startIndex = objectStart;
            openChar = '{';
            closeChar = '}';
        } else if (arrayStart >= 0) {
            startIndex = arrayStart;
            openChar = '[';
            closeChar = ']';
        }

        if (startIndex < 0) {
            return text;
        }

        int depth = 0;
        boolean inString = false;
        boolean escaped = false;

        for (int i = startIndex; i < text.length(); i++) {
            char currentChar = text.charAt(i);
            if (inString) {
                if (escaped) {
                    escaped = false;
                } else if (currentChar == '\\') {
                    escaped = true;
                } else if (currentChar == '"') {
                    inString = false;
                }
            } else {
                if (currentChar == '"') {
                    inString = true;
                } else if (currentChar == openChar) {
                    depth++;
                } else if (currentChar == closeChar) {
                    depth--;
                    if (depth == 0) {
                        return text.substring(startIndex, i + 1).trim();
                    }
                }
            }
        }

        StringBuilder repaired = new StringBuilder(text.substring(startIndex).trim());
        while (depth-- > 0) {
            repaired.append(closeChar);
        }
        return repaired.toString();
    }
}