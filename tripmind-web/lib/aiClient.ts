export type FinalPlanInput = {
  source?: string;
  destination?: string;
  groupSize?: "Solo" | "Couple" | "Family" | "Friends";
  budget?: "Low" | "Medium" | "High";
  tripDurationDays?: number;
  interests?: string[];
  specialReq?: string | null;
};

export async function buildItinerary(payload: FinalPlanInput) {
  const res = await fetch("/api/ai/itinerary", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error(`Itinerary ${res.status}`);
  return res.json();
}
