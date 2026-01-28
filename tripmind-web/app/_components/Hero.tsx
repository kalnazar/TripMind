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

      <div className="mx-auto max-w-4xl px-4 md:px-8">
        <div className="flex flex-col justify-center items-center text-center">
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

            <div className="mt-4 flex flex-wrap gap-2 justify-center">
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
      </div>
    </section>
  );
}
