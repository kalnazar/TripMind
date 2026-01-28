export type SaveItineraryPayload = {
  title: string;
  tripId?: string;
  itineraryData: any; // Map<String, Object> in backend
};

export async function saveItinerary(payload: SaveItineraryPayload) {
  const res = await fetch("/api/itineraries", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`Save itinerary failed: ${res.status} ${t}`);
  }
  return res.json() as Promise<{ id: string }>;
}

export async function getItineraries() {
  const res = await fetch("/api/itineraries", {
    method: "GET",
    credentials: "include",
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`Fetch itineraries failed: ${res.status} ${t}`);
  }
  return res.json() as Promise<any[]>;
}

export async function getItinerary(id: string) {
  const res = await fetch(`/api/itineraries/${id}`, {
    method: "GET",
    credentials: "include",
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`Fetch itinerary failed: ${res.status} ${t}`);
  }
  return res.json();
}

export async function getItinerariesByTrip(tripId: string) {
  const res = await fetch(`/api/itineraries/trip/${tripId}`, {
    method: "GET",
    credentials: "include",
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`Fetch trip itineraries failed: ${res.status} ${t}`);
  }
  return res.json() as Promise<any[]>;
}

export async function deleteItinerary(id: string) {
  const res = await fetch(`/api/itineraries/${id}`, {
    method: "DELETE",
    credentials: "include",
  });
  if (!res.ok && res.status !== 204) {
    const t = await res.text();
    throw new Error(`Delete itinerary failed: ${res.status} ${t}`);
  }
}
