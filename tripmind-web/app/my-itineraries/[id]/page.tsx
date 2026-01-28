"use client";

import { useEffect, useState } from "react";
import { getItinerary } from "@/lib/itinerariesClient";
import Link from "next/link";
import {
  MapPin,
  Calendar,
  DollarSign,
  Users,
  ArrowLeft,
  Loader,
  Bed,
} from "lucide-react";
import { useParams } from "next/navigation";

export default function ItineraryDetail() {
  const params = useParams();
  const id = params.id as string;

  const [itinerary, setItinerary] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedDays, setExpandedDays] = useState<Record<number, boolean>>({});

  useEffect(() => {
    if (!id) return;
    async function load() {
      try {
        const data = await getItinerary(id);
        console.log("[Detail Page] Loaded itinerary:", data);
        setItinerary(data);
      } catch (e: any) {
        console.error("[Detail Page] Error:", e);
        setError(e?.message || "Failed to load itinerary");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id]);

  function toggleDay(n: number) {
    setExpandedDays((prev) => ({ ...prev, [n]: !prev[n] }));
  }

  function getHotelImageUrl(hotel: any) {
    const url =
      (Array.isArray(hotel?.images) ? hotel.images[0] : null) ??
      hotel?.hotel_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  }

  function getActivityImageUrl(activity: any) {
    const url =
      (Array.isArray(activity?.images) ? activity.images[0] : null) ??
      activity?.place_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  }

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 flex flex-col items-center justify-center">
        <Loader className="h-8 w-8 animate-spin mb-4 text-primary" />
        <p>Loading itinerary…</p>
      </div>
    );
  }

  if (error || !itinerary) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <Link
          href="/my-itineraries"
          className="inline-flex items-center gap-2 text-primary mb-6 hover:underline"
        >
          <ArrowLeft className="h-4 w-4" /> Back to Itineraries
        </Link>
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-red-800">
          <p className="font-medium">Error loading itinerary</p>
          <p className="text-sm mt-2">{error || "Itinerary not found"}</p>
        </div>
      </div>
    );
  }

  const tp = itinerary.itineraryData ?? itinerary.tripPlan ?? itinerary;

  console.log("[TP Data]", {
    hasHotels: !!tp.hotels,
    hotelsCount: tp.hotels?.length,
    hasItinerary: !!tp.itinerary,
    itineraryCount: tp.itinerary?.length,
    hasDestination: !!tp.destination,
    destination: tp.destination,
    fullData: tp,
  });

  // Debug: Show raw data if nothing renders
  if (!tp || (!tp.hotels && !tp.itinerary && !tp.destination)) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-10">
        <Link
          href="/my-itineraries"
          className="inline-flex items-center gap-2 text-primary mb-6 hover:underline"
        >
          <ArrowLeft className="h-4 w-4" /> Back to Itineraries
        </Link>
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
          <p className="font-medium mb-2">Debug: No trip plan data</p>
          <pre className="text-xs bg-white p-4 rounded overflow-auto max-h-96">
            {JSON.stringify(itinerary, null, 2)}
          </pre>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-10">
      <Link
        href="/my-itineraries"
        className="inline-flex items-center gap-2 text-primary mb-6 hover:underline"
      >
        <ArrowLeft className="h-4 w-4" /> Back to Itineraries
      </Link>

      {/* Header */}
      <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-xl p-8 mb-8 border">
        <div className="flex items-start gap-6">
          <div className="text-5xl opacity-40">✈️</div>
          <div className="flex-1">
            <h1 className="text-3xl font-bold mb-4">{itinerary.title}</h1>
            {itinerary.description && (
              <p className="text-muted-foreground mb-6">
                {itinerary.description}
              </p>
            )}

            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {tp.destination && (
                <div className="flex flex-col">
                  <div className="text-xs text-muted-foreground mb-1">
                    Destination
                  </div>
                  <div className="font-semibold flex items-center gap-2">
                    <MapPin className="h-4 w-4" /> {tp.destination}
                  </div>
                </div>
              )}
              {tp.duration_days && (
                <div className="flex flex-col">
                  <div className="text-xs text-muted-foreground mb-1">
                    Duration
                  </div>
                  <div className="font-semibold flex items-center gap-2">
                    <Calendar className="h-4 w-4" /> {tp.duration_days} days
                  </div>
                </div>
              )}
              {tp.group_size && (
                <div className="flex flex-col">
                  <div className="text-xs text-muted-foreground mb-1">
                    Group
                  </div>
                  <div className="font-semibold flex items-center gap-2">
                    <Users className="h-4 w-4" /> {tp.group_size}
                  </div>
                </div>
              )}
              {tp.budget && (
                <div className="flex flex-col">
                  <div className="text-xs text-muted-foreground mb-1">
                    Budget
                  </div>
                  <div className="font-semibold flex items-center gap-2">
                    <DollarSign className="h-4 w-4" /> {tp.budget}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Activities by day */}
      {tp.itinerary && tp.itinerary.length > 0 && (
        <div>
          <h2 className="text-2xl font-bold mb-6">Day-by-Day Plan</h2>
          <div className="space-y-4">
            {tp.itinerary.map((day: any) => {
              const isOpen = expandedDays[day.day] ?? true;
              return (
                <div
                  key={day.day}
                  className="rounded-xl border p-6 bg-white hover:shadow-sm transition-shadow"
                >
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold">Day {day.day}</h3>
                    <div className="flex items-center gap-4">
                      {day.best_time_to_visit_day && (
                        <span className="text-xs px-3 py-1 rounded-full bg-muted">
                          {day.best_time_to_visit_day}
                        </span>
                      )}
                      <button
                        type="button"
                        onClick={() => toggleDay(day.day)}
                        className="text-sm text-primary hover:underline"
                      >
                        {isOpen ? "Hide" : "Show"}
                      </button>
                    </div>
                  </div>

                  {isOpen && (
                    <>
                      {day.day_plan && (
                        <p className="text-muted-foreground mb-4">
                          {day.day_plan}
                        </p>
                      )}

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {(day.activities ?? []).map((a: any, i: number) => (
                          <div
                            key={i}
                            className="rounded-lg border overflow-hidden hover:shadow-sm transition-shadow bg-gradient-to-br from-white to-gray-50"
                          >
                            {getActivityImageUrl(a) && (
                              <div className="relative h-32 bg-gradient-to-br from-muted to-muted/70 overflow-hidden">
                                <img
                                  src={getActivityImageUrl(a) as string}
                                  alt={a.place_name}
                                  className="w-full h-full object-cover"
                                  onError={(e) => {
                                    (
                                      e.target as HTMLImageElement
                                    ).style.display = "none";
                                  }}
                                />
                              </div>
                            )}
                            <div className="p-3">
                              <h4 className="font-semibold mb-1">
                                {a.place_name}
                              </h4>
                              {a.place_address && (
                                <p className="text-xs text-muted-foreground mb-2">
                                  {a.place_address}
                                </p>
                              )}
                              {a.place_details && (
                                <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                                  {a.place_details}
                                </p>
                              )}
                              <div className="flex flex-wrap gap-1">
                                {a.ticket_pricing && (
                                  <span className="text-xs bg-muted/50 px-2 py-0.5 rounded">
                                    {a.ticket_pricing}
                                  </span>
                                )}
                                {a.time_travel_each_location && (
                                  <span className="text-xs bg-muted/50 px-2 py-0.5 rounded">
                                    {a.time_travel_each_location}
                                  </span>
                                )}
                                {a.best_time_to_visit && (
                                  <span className="text-xs bg-muted/50 px-2 py-0.5 rounded">
                                    {a.best_time_to_visit}
                                  </span>
                                )}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Hotels */}
      {tp.hotels && tp.hotels.length > 0 && (
        <div className="mt-8">
          <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
            <Bed className="h-6 w-6" /> Accommodations
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {tp.hotels.map((h: any, idx: number) => (
              <div
                key={idx}
                className="rounded-xl border overflow-hidden hover:shadow-md transition-shadow bg-white"
              >
                {getHotelImageUrl(h) && (
                  <div className="relative h-48 bg-gradient-to-br from-muted to-muted/70 overflow-hidden">
                    <img
                      src={getHotelImageUrl(h) as string}
                      alt={h.hotel_name}
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        (e.target as HTMLImageElement).style.display = "none";
                      }}
                    />
                  </div>
                )}
                <div className="p-4">
                  <h3 className="font-semibold text-lg mb-2">{h.hotel_name}</h3>
                  {h.hotel_address && (
                    <p className="text-sm text-muted-foreground mb-3">
                      {h.hotel_address}
                    </p>
                  )}
                  <div className="flex flex-wrap gap-2">
                    {h.price_per_night && (
                      <span className="bg-muted px-3 py-1 rounded-full text-sm">
                        {h.price_per_night}
                      </span>
                    )}
                    {typeof h.rating === "number" && (
                      <span className="bg-muted px-3 py-1 rounded-full text-sm">
                        ★ {h.rating}
                      </span>
                    )}
                    {h.hotel_type && (
                      <span className="bg-muted px-3 py-1 rounded-full text-sm">
                        {h.hotel_type}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
