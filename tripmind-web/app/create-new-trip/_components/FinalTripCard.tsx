"use client";

import { Loader2, Globe2, Lock } from "lucide-react";
import { Button } from "@/components/ui/button";

export default function FinalTripCard({
  summary,
  ready,
  building,
  onView,
}: {
  summary?: string;
  ready: boolean;
  building?: boolean;
  onView: () => void;
}) {
  return (
    <div className="mt-3 space-y-3">
      {summary && (
        <div className="text-sm leading-6 bg-muted px-4 py-3 rounded-xl">
          {summary}
        </div>
      )}

      <div className="rounded-2xl border bg-white shadow-sm p-5">
        <div className="flex flex-col items-center text-center gap-2">
          <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center">
            <Globe2 className="h-5 w-5" />
          </div>
          <div className="text-lg font-semibold">
            ✨ Planning your dream trip…
          </div>
          <div className="text-sm text-muted-foreground">
            Gathering best destinations, activities, and travel details for you.
          </div>

          <Button className="mt-3" size="sm" onClick={onView} disabled={!ready}>
            {!ready ? (
              <span className="inline-flex items-center gap-2">
                <Loader2
                  className={`h-4 w-4 ${building ? "animate-spin" : ""}`}
                />
                {building ? "Building…" : "Preparing…"}
              </span>
            ) : (
              "View Trip"
            )}
          </Button>

          {!ready && (
            <div className="mt-2 text-xs text-muted-foreground inline-flex items-center gap-1">
              <Lock className="h-3.5 w-3.5" />
              Button unlocks when the itinerary is ready
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
