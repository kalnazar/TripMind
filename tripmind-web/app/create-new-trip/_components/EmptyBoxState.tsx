"use client";

import { Button } from "@/components/ui/button";
import { Gem, Globe2, Kayak, Plane, MapPin, Sun } from "lucide-react";
import React from "react";

type EmptyBoxStateProps = {
  onSuggestionClick: (text: string) => void;
};

const suggestions = [
  { title: "Create a new trip", icon: <Globe2 className="h-4 w-4" /> },
  { title: "Inspire me where to go", icon: <Plane className="h-4 w-4" /> },
  { title: "Discover hidden gems", icon: <Gem className="h-4 w-4" /> },
  { title: "Adventure destination", icon: <Kayak className="h-4 w-4" /> },
  { title: "Weekend getaway", icon: <MapPin className="h-4 w-4" /> },
  { title: "Sunny beaches", icon: <Sun className="h-4 w-4" /> },
];

const EmptyBoxState = ({ onSuggestionClick }: EmptyBoxStateProps) => {
  return (
    <div className="flex flex-col items-center justify-center h-full text-center px-4">
      <h2 className="font-semibold text-2xl">
        Welcome to <span className="text-primary font-bold">TripMind</span>
      </h2>
      <p className="text-gray-500 mt-2 max-w-md">
        Let AI help you plan your perfect trip. Start by typing or pick a
        suggestion below.
      </p>

      <div className="mt-6 flex flex-wrap justify-center gap-2">
        {suggestions.map((s, i) => (
          <Button
            key={i}
            variant="outline"
            size="sm"
            className="rounded-full flex items-center gap-2"
            onClick={() => onSuggestionClick(s.title)}
          >
            {s.icon}
            {s.title}
          </Button>
        ))}
      </div>
    </div>
  );
};

export default EmptyBoxState;
