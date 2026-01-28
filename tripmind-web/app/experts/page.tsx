"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useAuth } from "@/app/providers/AuthProvider";
import { useToast } from "@/app/providers/ToastProvider";
import {
  ExpertDetailsDialog,
  ExpertDetails,
} from "@/components/experts/ExpertDetailsDialog";

export default function ExpertsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const { toast } = useToast();
  const [experts, setExperts] = useState<ExpertDetails[]>([]);
  const [selected, setSelected] = useState<ExpertDetails | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [bookingState, setBookingState] = useState<
    "idle" | "loading" | "success" | "error"
  >("idle");
  const [bookingError, setBookingError] = useState<string | null>(null);
  const [countryFilter, setCountryFilter] = useState("ALL");

  useEffect(() => {
    const loadExperts = async () => {
      const res = await fetch("/api/experts", { cache: "no-store" });
      if (!res.ok) return;
      const data = await res.json();
      setExperts(Array.isArray(data) ? data : []);
    };
    loadExperts();
  }, []);

  const regionNames = useMemo(() => {
    if (typeof Intl === "undefined" || !("DisplayNames" in Intl)) return null;
    const DisplayNames = (Intl as unknown as { DisplayNames: any }).DisplayNames;
    return new DisplayNames(["en"], { type: "region" });
  }, []);

  const countries = useMemo(() => {
    const unique = new Set(
      experts
        .map((expert) => expert.countryCode?.toUpperCase())
        .filter((code): code is string => Boolean(code))
    );
    return Array.from(unique).sort();
  }, [experts]);

  const filteredExperts = useMemo(() => {
    if (countryFilter === "ALL") return experts;
    return experts.filter(
      (expert) =>
        expert.countryCode?.toUpperCase() === countryFilter.toUpperCase()
    );
  }, [experts, countryFilter]);

  const toFlag = (code?: string | null) => {
    if (!code || code.length !== 2) return "";
    return String.fromCodePoint(
      ...code
        .toUpperCase()
        .split("")
        .map((c) => 127397 + c.charCodeAt(0))
    );
  };

  const openDialog = (expert: ExpertDetails) => {
    setSelected(expert);
    setDialogOpen(true);
    setBookingState("idle");
    setBookingError(null);
  };

  const closeDialog = () => {
    setDialogOpen(false);
    setSelected(null);
    setBookingState("idle");
    setBookingError(null);
  };

  const handleBook = async (date: string, time: string) => {
    if (loading) return;
    if (!user) {
      router.push("/login?next=/experts");
      return;
    }

    if (!selected) return;
    setBookingState("loading");
    setBookingError(null);

    const res = await fetch("/api/expert-bookings", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ expertId: selected.id, date, time }),
    });

    if (!res.ok) {
      const data = await res.json().catch(() => ({}));
      setBookingState("error");
      setBookingError(data?.message || data?.error || "Unable to book expert");
      toast({
        title: "Booking failed",
        description: data?.message || data?.error || "Unable to book expert",
        variant: "error",
      });
      return;
    }

    setBookingState("success");
    toast({
      title: "Booking request sent",
      description: "The expert will review your request soon.",
      variant: "success",
    });
  };

  return (
    <div className="max-w-7xl mx-auto px-6 py-16">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4">Meet TripMind Experts</h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          Choose a travel expert based on your destination, language, and style.
        </p>
      </div>

      {experts.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-xl p-8 text-center text-gray-600">
          No experts are visible yet. Check back soon.
        </div>
      ) : (
        <>
          <div className="mb-6 flex flex-wrap items-center gap-3">
            <label className="text-sm text-gray-500">Filter by country:</label>
            <select
              className="rounded-md border border-gray-200 px-3 py-2 text-sm"
              value={countryFilter}
              onChange={(e) => setCountryFilter(e.target.value)}
            >
              <option value="ALL">All countries</option>
              {countries.map((code) => (
                <option key={code} value={code}>
                  {toFlag(code)} {regionNames?.of(code) || code}
                </option>
              ))}
            </select>
          </div>

          {filteredExperts.length === 0 ? (
            <div className="bg-white border border-gray-200 rounded-xl p-6 text-gray-600">
              No experts available for the selected country.
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
              {filteredExperts.map((expert) => (
                <Card key={expert.id} className="border border-gray-200">
                  <CardContent className="pt-6 flex flex-col gap-4">
                    <div className="flex items-center gap-4">
                      <Avatar className="h-12 w-12 ring-2 ring-primary/10">
                        <AvatarImage
                          src={expert.avatarUrl || ""}
                          alt={expert.name}
                        />
                        <AvatarFallback className="bg-primary/10 text-primary font-semibold">
                          {expert.name
                            ?.split(" ")
                            .map((part) => part[0])
                            .slice(0, 2)
                            .join("")
                            .toUpperCase() || "EX"}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <h2 className="text-xl font-semibold text-gray-900">
                          {expert.name}{" "}
                          {expert.countryCode && (
                            <span className="text-base">
                              {toFlag(expert.countryCode)}
                            </span>
                          )}
                        </h2>
                        {expert.location && (
                          <p className="text-sm text-gray-500">
                            {expert.location}
                          </p>
                        )}
                      </div>
                    </div>

                    <div className="text-sm text-gray-600 space-y-1">
                      {expert.languages && (
                        <p>
                          <span className="text-gray-500">Languages:</span>{" "}
                          {expert.languages}
                        </p>
                      )}
                      {expert.experienceYears != null && (
                        <p>
                          <span className="text-gray-500">Experience:</span>{" "}
                          {expert.experienceYears} years
                        </p>
                      )}
                      {expert.pricePerHour != null && (
                        <p>
                          <span className="text-gray-500">Price:</span> ${" "}
                          {expert.pricePerHour}/hour
                        </p>
                      )}
                    </div>

                    <Button
                      onClick={() => openDialog(expert)}
                      className="w-full bg-primary text-white hover:bg-primary/90"
                    >
                      View details
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </>
      )}

      <ExpertDetailsDialog
        isOpen={dialogOpen}
        onClose={closeDialog}
        expert={selected}
        onBook={handleBook}
        bookingState={bookingState}
        bookingError={bookingError}
      />
    </div>
  );
}
