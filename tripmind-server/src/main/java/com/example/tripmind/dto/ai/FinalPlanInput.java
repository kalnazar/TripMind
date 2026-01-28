package com.example.tripmind.dto.ai;

import java.util.List;

public class FinalPlanInput {
    public String source;
    public String destination;
    public String groupSize;       // Solo | Couple | Family | Friends
    public String budget;          // Low | Medium | High
    public Integer tripDurationDays;
    public List<String> interests; // may be empty
    public String specialReq;      // nullable
}
