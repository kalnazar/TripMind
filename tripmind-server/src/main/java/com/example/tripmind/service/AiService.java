package com.example.tripmind.service;

import com.example.tripmind.dto.ai.ChatDtos.AgentReply;
import com.example.tripmind.dto.ai.ChatDtos.ChatRequest;
import com.example.tripmind.dto.ai.FinalPlanInput;
import com.example.tripmind.exception.BadRequestException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.*;

@Service
public class AiService {

    private static final Logger log = LoggerFactory.getLogger(AiService.class);

    private final RestClient restClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${grok.api.key}")
    private String groqKey;

    public AiService(RestClient.Builder restClientBuilder) {
        this.restClient = restClientBuilder.build();
    }

    private static final String GROQ_MODEL = "llama-3.3-70b-versatile";
    private static final String GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";

    private static final Set<String> HOTEL_INSTANCE_OF = Set.of(
            "Q27686",   // hotel
            "Q675196",  // hostel
            "Q875157",  // resort
            "Q217175",  // inn
            "Q24127145" // boutique hotel
    );

    private static final Set<String> ATTRACTION_INSTANCE_OF = Set.of(
            "Q41176",   // building
            "Q23413",   // castle
            "Q16560",   // palace
            "Q33506",   // museum
            "Q16970",   // church
            "Q2977",    // cathedral
            "Q163577",  // basilica
            "Q12280",   // bridge
            "Q4989906", // monument
            "Q22698",   // park
            "Q174782",  // square
            "Q11032",   // zoo
            "Q811979"   // historical landmark
    );

    private static final Set<String> DISALLOWED_INSTANCE_OF = Set.of(
            "Q5" // human
    );

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
      - IMPORTANT: For images, set hotel_image_url and place_image_url to null (do NOT invent URLs). Backend will enrich.

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
              "hotel_image_url": null,
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
                  "place_image_url": null,
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
            log.warn("Chat agent failed", e);
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

            JsonNode root = objectMapper.readTree(jsonResponse);

            // ✅ DO NOT swallow silently — log the reason (otherwise you always get null and no clue why)
            try {
                enrichPlanImages(root);
            } catch (Exception e) {
                log.warn("Image enrichment failed (keeping plan without images)", e);
            }

            return root;

        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg == null || msg.isBlank()) {
                msg = e.getClass().getSimpleName();
            }
            throw new BadRequestException("Failed to build itinerary: " + msg);
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

    /** ================= IMAGE ENRICHMENT ================= **/

    private void enrichPlanImages(JsonNode root) {
        JsonNode tripPlan = root.path("trip_plan");
        if (!tripPlan.isObject()) return;

        String destination = tripPlan.path("destination").asText("");

        // In-request cache so the same lookup isn't repeated N times
        Map<String, String> imageCache = new HashMap<>();
        Set<String> usedImages = new HashSet<>();

        // Hotels
        JsonNode hotels = tripPlan.path("hotels");
        if (hotels.isArray()) {
            for (JsonNode hotel : hotels) {
                if (!hotel.isObject()) continue;

                ObjectNode hotelNode = (ObjectNode) hotel;
                String currentUrl = hotelNode.path("hotel_image_url").asText("");

                if (shouldReplaceImageUrl(currentUrl)) {
                    String name = hotelNode.path("hotel_name").asText("");
                    String imageUrl = resolveWikidataImage(name, destination, imageCache, usedImages, true);

                    if (imageUrl != null && !imageUrl.isBlank()) {
                        hotelNode.put("hotel_image_url", imageUrl);
                    } else {
                        hotelNode.putNull("hotel_image_url");
                        log.debug("Image miss (hotel): name='{}', destination='{}'", name, destination);
                    }
                }
            }
        }

        // Activities
        JsonNode itinerary = tripPlan.path("itinerary");
        if (itinerary.isArray()) {
            for (JsonNode day : itinerary) {
                JsonNode activities = day.path("activities");
                if (!activities.isArray()) continue;

                for (JsonNode activity : activities) {
                    if (!activity.isObject()) continue;

                    ObjectNode activityNode = (ObjectNode) activity;
                    String currentUrl = activityNode.path("place_image_url").asText("");

                    if (shouldReplaceImageUrl(currentUrl)) {
                        String name = activityNode.path("place_name").asText("");
                        String imageUrl = resolveWikidataImage(name, destination, imageCache, usedImages, false);

                        if (imageUrl != null && !imageUrl.isBlank()) {
                            activityNode.put("place_image_url", imageUrl);
                        } else {
                            activityNode.putNull("place_image_url");
                            log.debug("Image miss (activity): name='{}', destination='{}'", name, destination);
                        }
                    }
                }
            }
        }
    }

    private boolean shouldReplaceImageUrl(String url) {
        if (url == null) return true;
        String normalized = url.trim().toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) return true;
        if (!normalized.startsWith("http")) return true;
        if (normalized.contains("example.com") || normalized.contains("placeholder")) return true;
        return !isLikelyImageUrl(normalized);
    }

    private boolean isLikelyImageUrl(String url) {
        if (url.contains("upload.wikimedia.org/")
                || url.contains("commons.wikimedia.org/wiki/special:filepath/")) {
            return true;
        }
        return url.matches(".*\\.(png|jpe?g|gif|webp|bmp|tiff)(\\?.*)?$");
    }

    private String resolveWikidataImage(
            String placeName,
            String destination,
            Map<String, String> cache,
            Set<String> usedImages,
            boolean isHotel
    ) {
        String name = placeName != null ? placeName.trim() : "";
        String dest = destination != null ? destination.trim() : "";

        String primaryQuery = name;
        String secondaryQuery = buildPlaceQuery(name, dest);

        if (primaryQuery.isBlank() && secondaryQuery.isBlank()) return null;

        String cacheKey = primaryQuery + "||" + secondaryQuery + "||" + isHotel;
        if (cache.containsKey(cacheKey)) return cache.get(cacheKey);

        List<WikidataEntity> entities = new ArrayList<>();
        if (!primaryQuery.isBlank()) entities.addAll(searchWikidata(primaryQuery, 8));
        if (!secondaryQuery.isBlank() && !secondaryQuery.equals(primaryQuery)) {
            entities.addAll(searchWikidata(secondaryQuery, 8));
        }

        log.debug("Wikidata search: primary='{}', secondary='{}', results={}",
                primaryQuery, secondaryQuery, entities.size());

        String imageUrl = pickBestWikidataImage(entities, name, dest, isHotel, usedImages);

        // fallback: try destination alone (sometimes helps for famous sights)
        if ((imageUrl == null || imageUrl.isBlank()) && !dest.isBlank()) {
            List<WikidataEntity> destEntities = searchWikidata(dest, 8);
            log.debug("Wikidata fallback search: destination='{}', results={}", dest, destEntities.size());
            imageUrl = pickBestWikidataImage(destEntities, name, dest, isHotel, usedImages);
        }

        // fallback: Wikipedia pageimages
        if (imageUrl == null || imageUrl.isBlank()) {
            imageUrl = resolveWikipediaImage(name, dest, usedImages, isHotel);
        }

        if (imageUrl != null && !imageUrl.isBlank()) usedImages.add(imageUrl);

        cache.put(cacheKey, imageUrl);
        return imageUrl;
    }

    private String buildPlaceQuery(String placeName, String destination) {
        String name = placeName != null ? placeName.trim() : "";
        String dest = destination != null ? destination.trim() : "";
        if (name.isBlank()) return dest;
        if (dest.isBlank()) return name;

        // slightly more specific than "name dest"
        return name + ", " + dest;
    }

    /** ---------- Wikidata ---------- */

    private List<WikidataEntity> searchWikidata(String query, int limit) {
        if (query == null || query.isBlank()) return Collections.emptyList();
        try {
            String uri = UriComponentsBuilder.fromHttpUrl("https://www.wikidata.org/w/api.php")
                    .queryParam("action", "wbsearchentities")
                    .queryParam("format", "json")
                    .queryParam("language", "en")
                    .queryParam("limit", limit)
                    .queryParam("search", query)
                    .build()
                    .toUriString();

            ResponseEntity<String> response = restClient.get()
                    .uri(uri)
                    .header("User-Agent", "TripMind/1.0 (image-enrichment)")
                    .retrieve()
                    .toEntity(String.class);

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                log.debug("Wikidata search failed: status={}, query='{}'", response.getStatusCode(), query);
                return Collections.emptyList();
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode search = root.path("search");
            if (!search.isArray()) return Collections.emptyList();

            List<WikidataEntity> results = new ArrayList<>();
            for (JsonNode item : search) {
                String id = item.path("id").asText("");
                String label = item.path("label").asText("");
                String description = item.path("description").asText("");
                if (!id.isBlank()) {
                    results.add(new WikidataEntity(id, label, description, null, List.of()));
                }
            }
            return results;
        } catch (Exception e) {
            log.debug("Wikidata search exception: query='{}', err={}", query, e.toString());
            return Collections.emptyList();
        }
    }

    private String pickBestWikidataImage(
            List<WikidataEntity> entities,
            String name,
            String destination,
            boolean isHotel,
            Set<String> usedImages
    ) {
        if (entities == null || entities.isEmpty()) return null;

        List<String> ids = new ArrayList<>();
        for (WikidataEntity entity : entities) {
            if (entity.id() != null && !entity.id().isBlank()) ids.add(entity.id());
        }
        if (ids.isEmpty()) return null;

        Map<String, WikidataEntity> details = fetchWikidataDetails(ids);
        if (details.isEmpty()) return null;

        String normalizedName = normalizeText(name);
        String normalizedDestination = normalizeText(destination);

        WikidataEntity best = null;
        int bestScore = Integer.MIN_VALUE;

        for (WikidataEntity entity : details.values()) {
            if (entity.imageFile() == null || entity.imageFile().isBlank()) continue;

            String imageUrl = buildCommonsUrl(entity.imageFile());
            if (imageUrl == null || imageUrl.isBlank()) continue;
            if (usedImages.contains(imageUrl)) continue;

            int score = scoreWikidataEntity(entity, normalizedName, normalizedDestination, isHotel);

            if (score > bestScore) {
                bestScore = score;
                best = entity;
            }
        }

        if (best == null) return null;

        log.debug("Wikidata best pick: label='{}', score={}, image='{}'",
                best.label(), bestScore, best.imageFile());

        return buildCommonsUrl(best.imageFile());
    }

    private Map<String, WikidataEntity> fetchWikidataDetails(List<String> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyMap();
        try {
            // reduce payload, but keep claims for P18 and P31
            String uri = UriComponentsBuilder.fromHttpUrl("https://www.wikidata.org/w/api.php")
                    .queryParam("action", "wbgetentities")
                    .queryParam("format", "json")
                    .queryParam("ids", String.join("|", ids))
                    .queryParam("props", "labels|descriptions|claims")
                    .build()
                    .toUriString();

            ResponseEntity<String> response = restClient.get()
                    .uri(uri)
                    .header("User-Agent", "TripMind/1.0 (image-enrichment)")
                    .retrieve()
                    .toEntity(String.class);

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                log.debug("Wikidata details failed: status={}, ids={}", response.getStatusCode(), ids.size());
                return Collections.emptyMap();
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode entities = root.path("entities");
            if (!entities.isObject()) return Collections.emptyMap();

            Map<String, WikidataEntity> result = new HashMap<>();
            Iterator<Map.Entry<String, JsonNode>> fields = entities.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> entry = fields.next();
                String id = entry.getKey();
                JsonNode entity = entry.getValue();

                String label = entity.path("labels").path("en").path("value").asText("");
                String description = entity.path("descriptions").path("en").path("value").asText("");

                String imageFile = extractFirstStringClaim(entity.path("claims").path("P18"));
                List<String> instanceOf = extractInstanceOf(entity.path("claims").path("P31"));

                result.put(id, new WikidataEntity(id, label, description, imageFile, instanceOf));
            }
            return result;
        } catch (Exception e) {
            log.debug("Wikidata details exception: {}", e.toString());
            return Collections.emptyMap();
        }
    }

    /** ---------- Wikipedia ---------- */

    private String resolveWikipediaImage(String placeName,
                                         String destination,
                                         Set<String> usedImages,
                                         boolean isHotel) {
        String name = placeName != null ? placeName.trim() : "";
        String dest = destination != null ? destination.trim() : "";

        String query = buildPlaceQuery(name, dest);
        if (query.isBlank()) query = dest;
        if (query.isBlank()) return null;

        List<ImageCandidate> candidates = new ArrayList<>();

        // try exact title first (redirects enabled)
        if (!name.isBlank()) candidates.addAll(fetchWikipediaImagesByTitle(name));

        // then search generator
        candidates.addAll(fetchWikipediaImages(query, 10));
        if (!name.isBlank()) candidates.addAll(fetchWikipediaImages(name, 8));

        log.debug("Wikipedia candidates: query='{}', name='{}', count={}", query, name, candidates.size());

        return pickBestWikipediaImage(candidates, name, dest, isHotel, usedImages);
    }

    private List<ImageCandidate> fetchWikipediaImagesByTitle(String title) {
        if (title == null || title.isBlank()) return Collections.emptyList();
        try {
            String uri = UriComponentsBuilder.fromHttpUrl("https://en.wikipedia.org/w/api.php")
                    .queryParam("action", "query")
                    .queryParam("format", "json")
                    .queryParam("redirects", 1)
                    .queryParam("titles", title)
                    .queryParam("prop", "pageimages")
                    .queryParam("piprop", "original|thumbnail")
                    .queryParam("pithumbsize", 1200)
                    .build()
                    .toUriString();

            ResponseEntity<String> response = restClient.get()
                    .uri(uri)
                    .header("User-Agent", "TripMind/1.0 (image-enrichment)")
                    .retrieve()
                    .toEntity(String.class);

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                log.debug("Wikipedia title query failed: status={}, title='{}'", response.getStatusCode(), title);
                return Collections.emptyList();
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode pages = root.path("query").path("pages");
            if (!pages.isObject()) return Collections.emptyList();

            List<ImageCandidate> candidates = new ArrayList<>();
            Iterator<JsonNode> values = pages.elements();
            while (values.hasNext()) {
                JsonNode page = values.next();
                String pageTitle = page.path("title").asText("");
                String source = extractWikipediaImageSource(page);
                if (source != null && !source.isBlank()) {
                    candidates.add(new ImageCandidate(pageTitle, source));
                }
            }
            return candidates;
        } catch (Exception e) {
            log.debug("Wikipedia byTitle exception: title='{}', err={}", title, e.toString());
            return Collections.emptyList();
        }
    }

    private List<ImageCandidate> fetchWikipediaImages(String query, int limit) {
        if (query == null || query.isBlank()) return Collections.emptyList();
        try {
            String uri = UriComponentsBuilder.fromHttpUrl("https://en.wikipedia.org/w/api.php")
                    .queryParam("action", "query")
                    .queryParam("format", "json")
                    .queryParam("generator", "search")
                    .queryParam("gsrsearch", query)
                    .queryParam("gsrlimit", limit)
                    .queryParam("prop", "pageimages")
                    .queryParam("piprop", "original|thumbnail")
                    .queryParam("pithumbsize", 1200)
                    .queryParam("pilimit", limit)
                    .build()
                    .toUriString();

            ResponseEntity<String> response = restClient.get()
                    .uri(uri)
                    .header("User-Agent", "TripMind/1.0 (image-enrichment)")
                    .retrieve()
                    .toEntity(String.class);

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                log.debug("Wikipedia search failed: status={}, query='{}'", response.getStatusCode(), query);
                return Collections.emptyList();
            }

            JsonNode root = objectMapper.readTree(response.getBody());
            JsonNode pages = root.path("query").path("pages");
            if (!pages.isObject()) return Collections.emptyList();

            List<ImageCandidate> candidates = new ArrayList<>();
            Iterator<JsonNode> values = pages.elements();
            while (values.hasNext()) {
                JsonNode page = values.next();
                String title = page.path("title").asText("");
                String source = extractWikipediaImageSource(page);
                if (source != null && !source.isBlank()) {
                    candidates.add(new ImageCandidate(title, source));
                }
            }
            return candidates;
        } catch (Exception e) {
            log.debug("Wikipedia search exception: query='{}', err={}", query, e.toString());
            return Collections.emptyList();
        }
    }

    private String extractWikipediaImageSource(JsonNode page) {
        JsonNode original = page.path("original");
        if (original.isObject()) {
            String source = original.path("source").asText("");
            if (!source.isBlank()) return source;
        }
        JsonNode thumbnail = page.path("thumbnail");
        if (thumbnail.isObject()) {
            String source = thumbnail.path("source").asText("");
            if (!source.isBlank()) return source;
        }
        return null;
    }

    private String pickBestWikipediaImage(List<ImageCandidate> candidates,
                                          String name,
                                          String destination,
                                          boolean isHotel,
                                          Set<String> usedImages) {
        if (candidates == null || candidates.isEmpty()) return null;

        String normalizedName = normalizeText(name);
        String normalizedDestination = normalizeText(destination);

        ImageCandidate best = null;
        int bestScore = Integer.MIN_VALUE;

        for (ImageCandidate candidate : candidates) {
            String url = candidate.url();
            if (url == null || url.isBlank()) continue;
            if (usedImages.contains(url)) continue;

            int score = scoreWikipediaTitle(candidate.title(), normalizedName, normalizedDestination, isHotel);
            if (score > bestScore) {
                bestScore = score;
                best = candidate;
            }
        }

        if (best != null) {
            log.debug("Wikipedia best pick: title='{}', score={}, url='{}'",
                    best.title(), bestScore, best.url());
        }
        return best != null ? best.url() : null;
    }

    private int scoreWikipediaTitle(String title,
                                    String normalizedName,
                                    String normalizedDestination,
                                    boolean isHotel) {
        String normalizedTitle = normalizeText(title);
        int score = 0;

        if (!normalizedName.isBlank() && normalizedTitle.contains(normalizedName)) score += 20;
        if (!normalizedDestination.isBlank() && normalizedTitle.contains(normalizedDestination)) score += 6;

        if (isHotel && normalizedTitle.contains("hotel")) score += 6;

        if (!normalizedName.isBlank()) {
            for (String token : normalizedName.split(" ")) {
                if (token.length() < 3) continue;
                if (normalizedTitle.contains(token)) score += 2;
            }
        }
        return score;
    }

    private String extractFirstStringClaim(JsonNode claims) {
        if (!claims.isArray() || claims.isEmpty()) return null;
        JsonNode value = claims.get(0).path("mainsnak").path("datavalue").path("value");
        return value.isTextual() ? value.asText() : null;
    }

    private List<String> extractInstanceOf(JsonNode claims) {
        if (!claims.isArray()) return List.of();
        List<String> ids = new ArrayList<>();
        for (JsonNode claim : claims) {
            JsonNode value = claim.path("mainsnak").path("datavalue").path("value");
            String id = value.path("id").asText("");
            if (!id.isBlank()) ids.add(id);
        }
        return ids;
    }

    private int scoreWikidataEntity(WikidataEntity entity,
                                    String normalizedName,
                                    String normalizedDestination,
                                    boolean isHotel) {
        String title = normalizeText(entity.label());
        String description = normalizeText(entity.description());
        int score = 0;

        if (!normalizedName.isBlank() && title.contains(normalizedName)) score += 25;
        if (!normalizedDestination.isBlank() && title.contains(normalizedDestination)) score += 6;

        if (!normalizedName.isBlank()) {
            for (String token : normalizedName.split(" ")) {
                if (token.length() < 3) continue;
                if (title.contains(token)) score += 2;
            }
        }

        if (isHotel) {
            if (containsAny(entity.instanceOf(), HOTEL_INSTANCE_OF)) score += 18;
            if (description.contains("hotel") || description.contains("resort")) score += 10;
        } else {
            if (containsAny(entity.instanceOf(), ATTRACTION_INSTANCE_OF)) score += 10;
        }

        if (containsAny(entity.instanceOf(), DISALLOWED_INSTANCE_OF)) score -= 50;

        return score;
    }

    private boolean containsAny(List<String> values, Set<String> allowed) {
        if (values == null || values.isEmpty()) return false;
        for (String value : values) {
            if (allowed.contains(value)) return true;
        }
        return false;
    }

    private String buildCommonsUrl(String imageFile) {
        if (imageFile == null || imageFile.isBlank()) return null;

        String cleaned = imageFile.trim();
        if (cleaned.startsWith("File:")) cleaned = cleaned.substring(5);
        cleaned = cleaned.replace(' ', '_');

        // Important: let UriComponentsBuilder do encoding
        return UriComponentsBuilder
                .fromHttpUrl("https://commons.wikimedia.org/wiki/Special:FilePath/")
                .path(cleaned)
                .queryParam("width", 1200)
                .build()
                .toUriString();
    }

    private String normalizeText(String value) {
        if (value == null) return "";
        return value.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private record WikidataEntity(String id,
                                  String label,
                                  String description,
                                  String imageFile,
                                  List<String> instanceOf) {}

    private record ImageCandidate(String title, String url) {}
}
