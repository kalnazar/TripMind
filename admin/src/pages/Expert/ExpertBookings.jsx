import React, { useContext, useEffect } from "react";
import { ExpertContext } from "../../context/ExpertContext";

const normalizeTimeZone = (timeZone) => {
  if (!timeZone) {
    return "UTC";
  }
  const trimmed = String(timeZone).trim();
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
    if (Number.isNaN(hours) || minutes !== 0) {
      return "UTC";
    }
    const reversed = match[2] === "+" ? "-" : "+";
    return `Etc/GMT${reversed}${hours}`;
  }

  return "UTC";
};

const ExpertBookings = () => {
  const { eToken, bookings, getBookings, updateBookingStatus } =
    useContext(ExpertContext);

  useEffect(() => {
    if (eToken) {
      getBookings();
    }
  }, [eToken]);

  return (
    <div className="m-5 w-full">
      <div className="flex flex-col gap-1">
        <h1 className="text-lg font-medium">Booking Requests</h1>
        <p className="text-sm text-gray-500">
          Review and respond to user requests.
        </p>
      </div>

      {bookings.length === 0 ? (
        <div className="mt-6 tm-card p-6 text-sm text-gray-600">
          No booking requests yet.
        </div>
      ) : (
        <div className="mt-6 space-y-4">
          {bookings.map((booking) => (
            <div
              key={booking.id}
              className="tm-card p-5 flex flex-col gap-4 md:flex-row md:items-center md:justify-between"
            >
              <div>
                <p className="text-gray-900 font-medium">{booking.userName}</p>
                <p className="text-sm text-gray-500">{booking.userEmail}</p>
                {booking.requestedStart && (
                  <p className="text-xs text-gray-500 mt-1">
                    Requested:{" "}
                    {new Date(booking.requestedStart).toLocaleString("en-US", {
                      timeZone: normalizeTimeZone(booking.requestedTimeZone),
                      dateStyle: "medium",
                      timeStyle: "short",
                    })}
                    {booking.durationHours
                      ? ` (${booking.durationHours}h)`
                      : ""}
                    {booking.requestedTimeZone
                      ? ` • ${booking.requestedTimeZone}`
                      : ""}
                  </p>
                )}
                <p className="text-xs text-gray-400 mt-1">
                  Status: {booking.status}
                </p>
              </div>

              <div className="flex items-center gap-3">
                <button
                  className="px-4 py-2 rounded-full text-sm bg-green-600 text-white disabled:opacity-50"
                  disabled={booking.status !== "PENDING"}
                  onClick={() =>
                    updateBookingStatus(booking.id, "ACCEPTED").catch(() => {})
                  }
                >
                  Accept
                </button>
                <button
                  className="px-4 py-2 rounded-full text-sm bg-red-500 text-white disabled:opacity-50"
                  disabled={booking.status !== "PENDING"}
                  onClick={() =>
                    updateBookingStatus(booking.id, "REJECTED").catch(() => {})
                  }
                >
                  Reject
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ExpertBookings;
