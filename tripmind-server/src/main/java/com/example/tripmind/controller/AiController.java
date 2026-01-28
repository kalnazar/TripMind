package com.example.tripmind.controller;

import com.example.tripmind.dto.ai.ChatDtos.AgentReply;
import com.example.tripmind.dto.ai.ChatDtos.ChatRequest;
import com.example.tripmind.dto.ai.FinalPlanInput;
import com.example.tripmind.service.AiService;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    @PostMapping("/ai")
    public ResponseEntity<AgentReply> chat(@RequestBody ChatRequest request) {
        return ResponseEntity.ok(aiService.chat(request));
    }

    @PostMapping("/ai/itinerary")
    public ResponseEntity<JsonNode> buildItinerary(@RequestBody FinalPlanInput input) {
        return ResponseEntity.ok(aiService.buildItinerary(input));
    }
}
