"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/app/providers/AuthProvider";
import { useRouter } from "next/navigation";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

type Booking = {
  id: number;
  status: "PENDING" | "ACCEPTED" | "REJECTED";
  requestedStart?: string;
  requestedTimeZone?: string;
  durationHours?: number;
  expertName?: string;
  expertAvatarUrl?: string;
};

const normalizeTimeZone = (timeZone?: string) => {
  if (!timeZone) {
    return "UTC";
  }
  const trimmed = timeZone.trim();
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: trimmed }).format(new Date());
    return trimmed;
  } catch {
    // fall through to offset parsing
  }

  const match = trimmed.match(/^(UTC|GMT)([+-])(\d{1,2})(?::?(\d{2}))?$/i);
  if (match) {
    const hours = parseInt(match[3], 10);
    const minutes = match[4] ? parseInt(match[4], 10) : 0;
    if (minutes !== 0 || Number.isNaN(hours)) {
      return "UTC";
    }
    const reversed = match[2] === "+" ? "-" : "+";
    return `Etc/GMT${reversed}${hours}`;
  }

  return "UTC";
};

export default function ExpertBookingsHistory() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      router.push("/login?next=/my-expert-bookings");
      return;
    }
    if (!user) return;

    const load = async () => {
      setIsLoading(true);
      const res = await fetch("/api/expert-bookings", { cache: "no-store" });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        setError(data?.message || "Failed to load bookings");
        setIsLoading(false);
        return;
      }
      const data = await res.json();
      setBookings(Array.isArray(data) ? data : []);
      setIsLoading(false);
    };

    load();
  }, [user, loading]);

  return (
    <div className="max-w-5xl mx-auto px-6 py-12">
      <h1 className="text-3xl font-bold mb-4">Expert Booking History</h1>
      <p className="text-gray-600 mb-8">
        Track your booking requests and see whether experts accepted them.
      </p>

      {isLoading ? (
        <div className="text-gray-500">Loading bookings…</div>
      ) : error ? (
        <div className="text-red-500">{error}</div>
      ) : bookings.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-xl p-6 text-gray-600">
          No expert bookings yet.
        </div>
      ) : (
        <div className="space-y-4">
          {bookings.map((booking) => (
            <Card key={booking.id} className="border border-gray-200">
              <CardContent className="py-6 flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                <div className="flex items-center gap-4">
                  <Avatar className="h-12 w-12 ring-2 ring-primary/10">
                    <AvatarImage
                      src={booking.expertAvatarUrl || ""}
                      alt={booking.expertName || "Expert"}
                    />
                    <AvatarFallback className="bg-primary/10 text-primary font-semibold">
                      {(booking.expertName || "EX")
                        .split(" ")
                        .map((part) => part[0])
                        .slice(0, 2)
                        .join("")
                        .toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p className="font-semibold text-gray-900">
                      {booking.expertName || "Expert"}
                    </p>
                  {booking.requestedStart && (
                    <p className="text-sm text-gray-500">
                      {new Date(booking.requestedStart).toLocaleString("en-US", {
                        timeZone: normalizeTimeZone(booking.requestedTimeZone),
                        dateStyle: "medium",
                        timeStyle: "short",
                      })}
                      {booking.durationHours ? ` (${booking.durationHours}h)` : ""}
                    </p>
                  )}
                  </div>
                </div>
                <span
                  className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${
                    booking.status === "ACCEPTED"
                      ? "bg-green-100 text-green-700"
                      : booking.status === "REJECTED"
                      ? "bg-red-100 text-red-700"
                      : "bg-yellow-100 text-yellow-700"
                  }`}
                >
                  {booking.status}
                </span>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
