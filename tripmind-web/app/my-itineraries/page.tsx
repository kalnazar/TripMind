"use client";

import { useEffect, useState } from "react";
import {
  getItineraries,
  getItinerary,
  deleteItinerary,
} from "@/lib/itinerariesClient";
import Link from "next/link";
import { MapPin, Calendar, Users, ArrowRight, Loader } from "lucide-react";
import { useToast } from "@/app/providers/ToastProvider";

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
  const [previewImages, setPreviewImages] = useState<
    Record<string, string | null>
  >({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { toast } = useToast();

  const getHotelImageUrl = (hotel: any) => {
    const url =
      (Array.isArray(hotel?.images) ? hotel.images[0] : null) ??
      hotel?.hotel_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  };

  const getActivityImageUrl = (activity: any) => {
    const url =
      (Array.isArray(activity?.images) ? activity.images[0] : null) ??
      activity?.place_image_url ??
      null;
    return typeof url === "string" && url.trim() ? url : null;
  };

  const getPreviewImage = (tp: any) => {
    if (!tp) return null;
    const firstDay = Array.isArray(tp.itinerary) ? tp.itinerary[0] : null;
    const firstDayImage = (firstDay?.activities ?? [])
      .map((a: any) => getActivityImageUrl(a))
      .find((url: string | null) => !!url);
    if (firstDayImage) return firstDayImage;

    const hotelImage = (tp.hotels ?? [])
      .map((h: any) => getHotelImageUrl(h))
      .find((url: string | null) => !!url);
    if (hotelImage) return hotelImage;

    for (const day of tp.itinerary ?? []) {
      const activityImage = (day.activities ?? [])
        .map((a: any) => getActivityImageUrl(a))
        .find((url: string | null) => !!url);
      if (activityImage) return activityImage;
    }
    return null;
  };

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

  useEffect(() => {
    if (itineraries.length === 0) return;
    let cancelled = false;
    async function loadPreviews() {
      const entries = await Promise.all(
        itineraries.map(async (it) => {
          try {
            const detail = await getItinerary(it.id);
            const tp =
              detail?.itineraryData ?? detail?.tripPlan ?? detail ?? null;
            return [it.id, getPreviewImage(tp)] as const;
          } catch {
            return [it.id, null] as const;
          }
        })
      );
      if (!cancelled) {
        setPreviewImages(Object.fromEntries(entries));
      }
    }
    loadPreviews();
    return () => {
      cancelled = true;
    };
  }, [itineraries]);

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
          <div key={it.id} className="relative group">
            <Link
              href={`/my-itineraries/${it.id}`}
              className="block rounded-xl border overflow-hidden hover:shadow-lg transition-all hover:border-primary/50 bg-white"
            >
              {/* Header image placeholder */}
              {previewImages[it.id] ? (
                <div className="relative h-40 bg-gradient-to-br from-indigo-100 to-purple-100 overflow-hidden">
                  <img
                    src={previewImages[it.id] as string}
                    alt={it.title}
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = "none";
                    }}
                  />
                </div>
              ) : (
                <div className="relative h-40 bg-gradient-to-br from-indigo-100 to-purple-100 flex items-center justify-center overflow-hidden">
                  <div className="text-4xl opacity-20">✈️</div>
                </div>
              )}

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

                  {it.tripPlan?.interests &&
                    it.tripPlan.interests.length > 0 && (
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

            <button
              className="absolute top-3 right-3 rounded-full bg-white/90 border text-xs px-2.5 py-1 text-red-600 hover:text-red-700 hover:border-red-200 shadow-sm"
              onClick={async (e) => {
                e.preventDefault();
                e.stopPropagation();
                if (
                  !window.confirm(
                    "Delete this itinerary? This action cannot be undone."
                  )
                )
                  return;
                try {
                  await deleteItinerary(it.id);
                  setItineraries((prev) =>
                    prev.filter((item) => item.id !== it.id)
                  );
                  setPreviewImages((prev) => {
                    const next = { ...prev };
                    delete next[it.id];
                    return next;
                  });
                  toast({
                    title: "Itinerary deleted",
                    variant: "success",
                  });
                } catch (err: any) {
                  toast({
                    title: "Delete failed",
                    description: err?.message || "Could not delete itinerary",
                    variant: "error",
                  });
                }
              }}
            >
              Delete
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
