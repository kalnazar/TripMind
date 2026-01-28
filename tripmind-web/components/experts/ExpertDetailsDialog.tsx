"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import { X } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

export interface ExpertDetails {
  id: number;
  name: string;
  avatarUrl?: string | null;
  bio?: string | null;
  location?: string | null;
  languages?: string | null;
  experienceYears?: number | null;
  pricePerHour?: number | null;
  timeZone?: string | null;
  countryCode?: string | null;
}

interface ExpertDetailsDialogProps {
  isOpen: boolean;
  onClose: () => void;
  expert: ExpertDetails | null;
  onBook: (date: string, time: string) => void;
  bookingState: "idle" | "loading" | "success" | "error";
  bookingError?: string | null;
}

export function ExpertDetailsDialog({
  isOpen,
  onClose,
  expert,
  onBook,
  bookingState,
  bookingError,
}: ExpertDetailsDialogProps) {
  if (!expert) return null;
  const [date, setDate] = useState("");
  const [time, setTime] = useState("08:00");
  const timeOptions = ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"];
  const flag =
    expert.countryCode && expert.countryCode.length === 2
      ? String.fromCodePoint(
          ...expert.countryCode
            .toUpperCase()
            .split("")
            .map((c) => 127397 + c.charCodeAt(0))
        )
      : null;

  useEffect(() => {
    if (isOpen) {
      setDate("");
      setTime("08:00");
    }
  }, [isOpen, expert?.id]);

  const initials =
    expert.name
      ?.split(" ")
      .map((part) => part[0])
      .slice(0, 2)
      .join("")
      .toUpperCase() || "EX";

  const timezoneMissing = !expert.timeZone;

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => {
            if (e.key === "Escape") {
              onClose();
            }
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) {
              onClose();
            }
          }}
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-md p-4"
        >
          <motion.div
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.95, opacity: 0 }}
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            className="relative w-full max-w-lg"
          >
            <Card className="bg-background p-6 shadow-lg">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-4">
                  <Avatar className="h-14 w-14 ring-2 ring-primary/10">
                    <AvatarImage
                      src={expert.avatarUrl || ""}
                      alt={expert.name}
                    />
                    <AvatarFallback className="bg-primary/10 text-primary font-semibold">
                      {initials}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <h2 className="text-2xl font-bold flex items-center gap-2">
                      {expert.name}
                      {flag && <span className="text-lg">{flag}</span>}
                    </h2>
                    {expert.location && (
                      <p className="text-sm text-muted-foreground">
                        {expert.location}
                      </p>
                    )}
                  </div>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={onClose}
                  className="h-8 w-8"
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>

              <div className="space-y-3 text-sm text-gray-600">
                {expert.languages && (
                  <p>
                    <span className="text-gray-500">Languages:</span>{" "}
                    {expert.languages}
                  </p>
                )}
                {expert.countryCode && (
                  <p>
                    <span className="text-gray-500">Country:</span>{" "}
                    {expert.countryCode.toUpperCase()} {flag ? ` ${flag}` : ""}
                  </p>
                )}
                {expert.timeZone && (
                  <p>
                    <span className="text-gray-500">Time zone:</span>{" "}
                    {expert.timeZone}
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
                    <span className="text-gray-500">Price per hour:</span>{" "}
                    ${" "}{expert.pricePerHour}
                  </p>
                )}
                {expert.bio && (
                  <p className="text-gray-500">{expert.bio}</p>
                )}
              </div>

              <div className="mt-4 space-y-2 text-sm">
                <p className="text-gray-500">
                  Choose a date and time (4-hour slots, expert time zone).
                </p>
                <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                  <input
                    type="date"
                    className="w-full rounded-md border border-gray-200 px-3 py-2"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                  />
                  <select
                    className="w-full rounded-md border border-gray-200 px-3 py-2"
                    value={time}
                    onChange={(e) => setTime(e.target.value)}
                  >
                    {timeOptions.map((slot) => (
                      <option key={slot} value={slot}>
                        {slot}
                      </option>
                    ))}
                  </select>
                </div>
                {timezoneMissing && (
                  <p className="text-xs text-red-500">
                    This expert has no time zone set yet.
                  </p>
                )}
              </div>

              {bookingState === "success" ? (
                <div className="mt-6 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">
                  Booking request sent. The expert will review it soon.
                </div>
              ) : bookingState === "error" ? (
                <div className="mt-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                  {bookingError || "Booking failed. Please try again."}
                </div>
              ) : null}

              <div className="mt-6 flex justify-end">
                <Button
                  onClick={() => onBook(date, time)}
                  disabled={
                    bookingState === "loading" ||
                    !date ||
                    !time ||
                    timezoneMissing
                  }
                  className="bg-primary text-white hover:bg-primary/90"
                >
                  {bookingState === "loading" ? "Booking..." : "Book Expert"}
                </Button>
              </div>
            </Card>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
