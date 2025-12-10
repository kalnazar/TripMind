"use client";

import { useEffect, useState } from "react";
import { getItineraries } from "@/lib/itinerariesClient";
import Link from "next/link";
import { MapPin, Calendar, Users, ArrowRight, Loader } from "lucide-react";

type Itinerary = {
  id: string;
  title: string;
  description?: string;
  tripPlan?: {
    destination?: string;
    origin?: string;
    duration_days?: number;
    group_size?: string;
    interests?: string[];
  };
  createdAt?: string;
};

export default function MyItineraries() {
  const [itineraries, setItineraries] = useState<Itinerary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      try {
        const data = await getItineraries();
        setItineraries(Array.isArray(data) ? data : []);
      } catch (e: any) {
        setError(e?.message || "Failed to load itineraries");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 flex flex-col items-center justify-center">
        <Loader className="h-8 w-8 animate-spin mb-4 text-primary" />
        <p>Loading your itineraries…</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-red-800">
          <p className="font-medium">Error loading itineraries</p>
          <p className="text-sm mt-2">{error}</p>
        </div>
      </div>
    );
  }

  if (itineraries.length === 0) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 flex flex-col items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-2">No Itineraries Yet</h1>
          <p className="text-muted-foreground mb-6">
            Create your first trip to get started!
          </p>
          <Link
            href="/create-new-trip"
            className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90"
          >
            Create New Trip <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-10">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">My Itineraries</h1>
        <p className="text-muted-foreground">
          {itineraries.length} saved itinerary
          {itineraries.length !== 1 ? "ies" : ""}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {itineraries.map((it) => (
          <Link
            key={it.id}
            href={`/my-itineraries/${it.id}`}
            className="group rounded-xl border overflow-hidden hover:shadow-lg transition-all hover:border-primary/50 bg-white"
          >
            {/* Header image placeholder */}
            <div className="relative h-40 bg-gradient-to-br from-indigo-100 to-purple-100 flex items-center justify-center overflow-hidden">
              <div className="text-4xl opacity-20">✈️</div>
            </div>

            {/* Content */}
            <div className="p-4">
              <h3 className="font-semibold text-lg mb-2 line-clamp-2 group-hover:text-primary transition">
                {it.title}
              </h3>

              {it.description && (
                <p className="text-sm text-muted-foreground mb-3 line-clamp-1">
                  {it.description}
                </p>
              )}

              <div className="space-y-2 text-sm text-muted-foreground">
                {it.tripPlan?.destination && (
                  <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4 flex-shrink-0" />
                    <span>
                      {it.tripPlan.origin ? `${it.tripPlan.origin} → ` : ""}
                      {it.tripPlan.destination}
                    </span>
                  </div>
                )}

                {it.tripPlan?.duration_days && (
                  <div className="flex items-center gap-2">
                    <Calendar className="h-4 w-4 flex-shrink-0" />
                    <span>{it.tripPlan.duration_days} days</span>
                  </div>
                )}

                {it.tripPlan?.group_size && (
                  <div className="flex items-center gap-2">
                    <Users className="h-4 w-4 flex-shrink-0" />
                    <span>{it.tripPlan.group_size}</span>
                  </div>
                )}

                {it.tripPlan?.interests && it.tripPlan.interests.length > 0 && (
                  <div className="flex flex-wrap gap-1 mt-3">
                    {it.tripPlan.interests.map((tag, i) => (
                      <span
                        key={i}
                        className="bg-muted px-2 py-1 rounded-full text-xs"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                )}
              </div>

              <div className="mt-4 flex items-center justify-between">
                <span className="text-xs text-muted-foreground">
                  {it.createdAt
                    ? new Date(it.createdAt).toLocaleDateString()
                    : "Saved"}
                </span>
                <ArrowRight className="h-4 w-4 text-primary opacity-0 group-hover:opacity-100 transition" />
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
