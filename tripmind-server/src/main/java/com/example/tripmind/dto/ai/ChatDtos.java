package com.example.tripmind.dto.ai;

import java.util.List;

public class ChatDtos {

    public static class Msg {
        public String role;
        public String content;
    }

    public static class ChatRequest {
        public List<Msg> messages;
        public String model;
    }

    public static class AgentReply {
        public String resp;
        public String ui;
    }
}
