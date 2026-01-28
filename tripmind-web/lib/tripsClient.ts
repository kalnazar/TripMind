export type SaveTripPayload = {
  title?: string;
  origin: string;
  destination: string;
  durationDays: number;
  budget: string;
  groupSize: string;
  interests?: string[];
  specialReq?: string | null;
  plan: any;
};

export async function saveTrip(payload: SaveTripPayload) {
  const res = await fetch("/api/trips", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`Save trip failed: ${res.status} ${t}`);
  }
  return res.json() as Promise<{ id: string }>;
}
