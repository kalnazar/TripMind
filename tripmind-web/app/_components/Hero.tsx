"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/app/providers/AuthProvider";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Gem,
  Globe2,
  Kayak,
  Plane,
  Send,
  MapPin,
  CalendarRange,
  Sparkles,
} from "lucide-react";

const suggestions = [
  { title: "Create a new trip", icon: <Globe2 className="h-4 w-4" /> },
  { title: "Inspire me where to go", icon: <Plane className="h-4 w-4" /> },
  { title: "Discover hidden gems", icon: <Gem className="h-4 w-4" /> },
  { title: "Adventure destination", icon: <Kayak className="h-4 w-4" /> },
];

export default function Hero() {
  const { user } = useAuth();
  const router = useRouter();
  const [prompt, setPrompt] = useState("");

  function goNext() {
    if (user) router.push("/create-new-trip");
    else router.push("/login?next=/create-new-trip");
  }

  return (
    <section className="relative pt-10 md:pt-16">
      <div className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute -top-24 -left-24 h-72 w-72 rounded-full bg-primary/10 blur-3xl" />
        <div className="absolute -bottom-20 -right-24 h-80 w-80 rounded-full bg-indigo-300/10 blur-3xl" />
      </div>

      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-10 px-4 md:grid-cols-2 md:gap-12 md:px-8">
        <div className="flex flex-col justify-center">
          <div className="mb-4">
            <Badge variant="secondary" className="gap-2">
              <Sparkles className="h-3.5 w-3.5" />
              AI Trip Builder
            </Badge>
          </div>

          <h1 className="text-3xl font-bold leading-tight sm:text-4xl md:text-5xl">
            Plan smarter. Travel further. Meet{" "}
            <span className="text-primary">TripMind</span>.
          </h1>

          <p className="mt-3 text-base text-muted-foreground sm:text-lg">
            Describe your dream escape and let AI craft the perfect itinerary
            with routes, stays, and hidden gems.
          </p>

          <div className="mt-6 rounded-2xl border bg-background/60 p-4 shadow-sm backdrop-blur">
            <div className="relative">
              <Textarea
                className="min-h-[120px] resize-none border-0 bg-transparent px-0 focus-visible:ring-0"
                placeholder="7-day foodie trip to Osaka with street markets and day trips"
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
              />
              <Button
                onClick={goNext}
                size="icon"
                className="absolute bottom-2 right-2"
                aria-label="Build trip"
              >
                <Send className="h-4 w-4" />
              </Button>
            </div>

            <div className="mt-4 flex flex-wrap gap-2">
              {suggestions.map((s, i) => (
                <Button
                  key={i}
                  variant="outline"
                  size="sm"
                  className="rounded-full"
                  onClick={() => {
                    setPrompt(s.title);
                    goNext();
                  }}
                >
                  <span className="mr-2">{s.icon}</span>
                  {s.title}
                </Button>
              ))}
            </div>
          </div>

          <div className="mt-6 grid grid-cols-1 gap-3 text-sm sm:grid-cols-3">
            <div className="flex items-center gap-2 rounded-xl border bg-muted/30 px-3 py-2">
              <MapPin className="h-4 w-4 text-primary" />
              Personalized routes
            </div>
            <div className="flex items-center gap-2 rounded-xl border bg-muted/30 px-3 py-2">
              <CalendarRange className="h-4 w-4 text-primary" />
              Length-based planning
            </div>
            <div className="flex items-center gap-2 rounded-xl border bg-muted/30 px-3 py-2">
              <Gem className="h-4 w-4 text-primary" />
              Local hidden spots
            </div>
          </div>
        </div>

        <div className="relative">
          <div className="sticky top-24">
            <div className="overflow-hidden rounded-3xl border shadow-sm">
              <div className="bg-gradient-to-br from-primary/10 via-transparent to-indigo-400/10 p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs uppercase tracking-wide text-muted-foreground">
                      Quick start
                    </p>
                    <h3 className="mt-1 text-xl font-semibold">Build a trip</h3>
                  </div>
                  <Button onClick={goNext} size="sm">
                    Get started
                  </Button>
                </div>

                <div className="mt-5 grid gap-3">
                  <div className="rounded-2xl border bg-background p-4">
                    <div className="mb-1 text-sm font-medium">Destination</div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <MapPin className="h-4 w-4 text-primary" />
                      Choose cities and vibe
                    </div>
                  </div>

                  <div className="rounded-2xl border bg-background p-4">
                    <div className="mb-1 text-sm font-medium">Days</div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <CalendarRange className="h-4 w-4 text-primary" />
                      Select trip length
                    </div>
                  </div>

                  <div className="rounded-2xl border bg-background p-4">
                    <div className="mb-1 text-sm font-medium">Style</div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Gem className="h-4 w-4 text-primary" />
                      Luxe, budget, hidden gems
                    </div>
                  </div>
                </div>

                <div className="mt-6 rounded-2xl border bg-background p-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">
                        Next step
                      </p>
                      <p className="text-sm">Generate itinerary</p>
                    </div>
                    <Button onClick={goNext} size="sm" variant="secondary">
                      Continue
                    </Button>
                  </div>
                </div>
              </div>
            </div>

            <div
              aria-hidden
              className="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-primary/20 blur-2xl"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
