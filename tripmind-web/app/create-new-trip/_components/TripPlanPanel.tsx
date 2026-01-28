"use client";

import React, { memo, useMemo, useState } from "react";
import { MapPin, Bed, Calendar, DollarSign, Users } from "lucide-react";
import { saveItinerary } from "@/lib/itinerariesClient";
import { useToast } from "@/app/providers/ToastProvider";

export type TripPlan = any;

function TripPlanPanelInner({ plan }: { plan: TripPlan | null }) {
  const tp = useMemo(() => (plan ? plan.trip_plan ?? plan : null), [plan]);
  const [expandedDays, setExpandedDays] = useState<Record<number, boolean>>({});
  const [savingItinerary, setSavingItinerary] = useState(false);
  const { toast } = useToast();

  function toggleDay(n: number) {
    setExpandedDays((prev) => ({ ...prev, [n]: !prev[n] }));
  }

  async function handleSaveItinerary() {
    if (!tp) return;
    setSavingItinerary(true);
    try {
      await saveItinerary({
        title: `${tp.destination} - ${tp.duration_days} days`,
        itineraryData: tp, // Backend expects 'itineraryData' not 'tripPlan'
      });
      toast({
        title: "Itinerary saved",
        description: "You can find it in My Itineraries.",
        variant: "success",
      });
    } catch (e: any) {
      toast({
        title: "Save failed",
        description: e?.message || "Failed to save itinerary",
        variant: "error",
      });
    } finally {
      setSavingItinerary(false);
    }
  }

  return (
    <div className="h-[80vh] flex flex-col border rounded-2xl shadow-sm bg-white">
      {/* Header with subtle visual */}
      <div className="px-6 py-4 sticky top-0 bg-gradient-to-r from-indigo-50 to-white z-10 border-b rounded-t-2xl">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-indigo-300 to-indigo-500 flex items-center justify-center text-white font-semibold shadow">
              {tp?.destination ? tp.destination[0] : "T"}
            </div>
            <div>
              <h2 className="text-xl font-semibold">
                {tp?.destination ?? "Your Trip"}
              </h2>
              <div className="text-sm text-muted-foreground">
                Day-by-day itinerary
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              className="px-3 py-1 rounded-md text-sm border hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed"
              onClick={handleSaveItinerary}
              disabled={!tp || savingItinerary}
            >
              {savingItinerary ? "Saving…" : "Save"}
            </button>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {!tp ? (
          <div className="text-sm text-muted-foreground">
            Your itinerary will appear here once ready.
          </div>
        ) : (
          <>
            <Summary tp={tp} />
            <Itinerary
              itinerary={tp.itinerary ?? []}
              expandedDays={expandedDays}
              onToggleDay={toggleDay}
            />
            <Hotels hotels={tp.hotels ?? []} />
          </>
        )}
      </div>
    </div>
  );
}

export default memo(TripPlanPanelInner);

/* --- subcomponents --- */

function Summary({ tp }: { tp: any }) {
  const { origin, destination, duration_days, budget, group_size, interests } =
    tp;

  return (
    <>
      <div className="flex items-center justify-between">
        <span className="text-sm px-2 py-1 rounded-full bg-muted">
          {interests?.length ? interests.join(" • ") : "General"}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-3 text-sm">
        <div className="flex items-center gap-2">
          <MapPin className="h-4 w-4" />
          <span className="font-medium">{origin}</span>
          <span className="text-muted-foreground">→</span>
          <span className="font-medium">{destination}</span>
        </div>
        <div className="flex items-center gap-2">
          <Calendar className="h-4 w-4" />
          <span>{duration_days} days</span>
        </div>
        <div className="flex items-center gap-2">
          <Users className="h-4 w-4" />
          <span>{group_size}</span>
        </div>
        <div className="flex items-center gap-2">
          <DollarSign className="h-4 w-4" />
          <span>{budget}</span>
        </div>
      </div>
    </>
  );
}

function Hotels({ hotels }: { hotels: any[] }) {
  if (!hotels?.length) return null;
  const getHotelImageUrl = (hotel: any) => {
    const url =
      (Array.isArray(hotel?.images) ? hotel.images[0] : null) ??
      hotel?.hotel_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  };
  return (
    <div>
      <div className="font-medium mb-3 flex items-center gap-2">
        <Bed className="h-4 w-4" />
        Stays ({hotels.length})
      </div>
      <div className="space-y-3">
        {hotels.slice(0, 4).map((h, idx) => (
          <div
            key={idx}
            className="rounded-xl border overflow-hidden hover:shadow-md transition-shadow bg-white"
          >
            {/* Image gallery */}
            {getHotelImageUrl(h) && (
              <div className="relative h-56 bg-gradient-to-br from-muted to-muted/70 overflow-hidden">
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

            {/* Content */}
            <div className="p-3">
              <div className="font-medium text-sm mb-1">{h.hotel_name}</div>
              {h.hotel_address && (
                <div className="text-muted-foreground text-xs mb-2">
                  {h.hotel_address}
                </div>
              )}
              <div className="flex flex-wrap gap-2 text-xs text-muted-foreground">
                {h.price_per_night && (
                  <span className="bg-muted/50 px-2 py-1 rounded">
                    {h.price_per_night}
                  </span>
                )}
                {typeof h.rating === "number" && (
                  <span className="bg-muted/50 px-2 py-1 rounded">
                    ★ {h.rating}
                  </span>
                )}
                {h.hotel_type && (
                  <span className="bg-muted/50 px-2 py-1 rounded">
                    {h.hotel_type}
                  </span>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function Itinerary({
  itinerary,
  expandedDays,
  onToggleDay,
}: {
  itinerary: any[];
  expandedDays?: Record<number, boolean>;
  onToggleDay?: (n: number) => void;
}) {
  const getActivityImageUrl = (activity: any) => {
    const url =
      (Array.isArray(activity?.images) ? activity.images[0] : null) ??
      activity?.place_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  };
  return (
    <div>
      <div className="font-medium mb-2">Day-by-day itinerary</div>
      <div className="space-y-4">
        {itinerary.map((day) => {
          const isOpen = expandedDays?.[day.day] ?? true;
          return (
            <div key={day.day} className="rounded-xl border p-4">
              <div className="flex items-start justify-between">
                <div className="font-semibold">Day {day.day}</div>
                <div className="flex items-center gap-2">
                  {day.best_time_to_visit_day && (
                    <div className="text-xs px-2 py-1 rounded-full bg-muted">
                      {day.best_time_to_visit_day}
                    </div>
                  )}
                  <button
                    type="button"
                    onClick={() => onToggleDay && onToggleDay(day.day)}
                    className="text-sm text-muted-foreground ml-2"
                  >
                    {isOpen ? "Collapse" : "Expand"}
                  </button>
                </div>
              </div>

              {isOpen && (
                <>
                  {day.day_plan && (
                    <div className="text-sm mt-1 text-muted-foreground">
                      {day.day_plan}
                    </div>
                  )}

                  <div className="mt-3 space-y-3">
                    {(day.activities ?? []).map((a: any, i: number) => (
                      <div
                        key={i}
                        className="rounded-lg border overflow-hidden hover:shadow-sm transition-shadow bg-white"
                      >
                        {/* Activity image */}
                        {getActivityImageUrl(a) && (
                          <div className="relative h-44 bg-gradient-to-br from-muted to-muted/70 overflow-hidden">
                            <img
                              src={getActivityImageUrl(a) as string}
                              alt={a.place_name}
                              className="w-full h-full object-cover"
                              onError={(e) => {
                                (e.target as HTMLImageElement).style.display =
                                  "none";
                              }}
                            />
                          </div>
                        )}

                        {/* Activity details */}
                        <div className="p-3 space-y-1">
                          <div className="font-medium text-sm">
                            {a.place_name}
                          </div>
                          {a.place_address && (
                            <div className="text-muted-foreground text-xs">
                              {a.place_address}
                            </div>
                          )}
                          {a.place_details && (
                            <div className="text-muted-foreground text-xs line-clamp-2">
                              {a.place_details}
                            </div>
                          )}
                          <div className="flex flex-wrap gap-2 text-xs text-muted-foreground pt-1">
                            {a.ticket_pricing && (
                              <span className="bg-muted/50 px-2 py-0.5 rounded">
                                {a.ticket_pricing}
                              </span>
                            )}
                            {a.time_travel_each_location && (
                              <span className="bg-muted/50 px-2 py-0.5 rounded">
                                {a.time_travel_each_location}
                              </span>
                            )}
                            {a.best_time_to_visit && (
                              <span className="bg-muted/50 px-2 py-0.5 rounded">
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

        {itinerary.length === 0 && (
          <div className="text-sm text-muted-foreground">
            No activities found.
          </div>
        )}
      </div>
    </div>
  );
}
