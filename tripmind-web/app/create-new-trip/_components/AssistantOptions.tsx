"use client";

import { useMemo, useState } from "react";
import { Check, Circle } from "lucide-react";
import { Button } from "@/components/ui/button";
import type { UiOption } from "./useTripAi";

type Props = {
  options: UiOption[];
  multi?: boolean;
  hint?: string;
  loading?: boolean;
  onPick: (value: string | string[]) => void;
};

type NormalizedOption = {
  label: string;
  value: string;
  emoji?: string;
  subtitle?: string;
};

function normalize(opt: UiOption): NormalizedOption {
  return typeof opt === "string" ? { label: opt, value: opt } : opt;
}

export default function AssistantOptions({
  options,
  multi,
  hint,
  loading,
  onPick,
}: Props) {
  const normalized: NormalizedOption[] = useMemo(
    () => options.map(normalize),
    [options]
  );
  const [selected, setSelected] = useState<string[]>([]);

  function toggle(val: string) {
    if (!multi) {
      onPick(val);
      return;
    }
    setSelected((prev) =>
      prev.includes(val) ? prev.filter((v) => v !== val) : [...prev, val]
    );
  }

  return (
    <div className="mt-2">
      {hint && <p className="text-sm text-muted-foreground mb-2">{hint}</p>}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        {normalized.map((o, idx) => {
          const isActive = selected.includes(o.value);
          return (
            <button
              key={`${o.value}-${idx}`}
              type="button"
              disabled={loading}
              onClick={() => toggle(o.value)}
              className={`flex items-center gap-3 rounded-2xl border p-3 text-left transition ${
                isActive ? "border-primary/60 bg-primary/5" : "hover:bg-muted"
              }`}
            >
              <div className="shrink-0">
                {isActive ? (
                  <Check className="h-5 w-5" />
                ) : (
                  <Circle className="h-5 w-5" />
                )}
              </div>
              <div className="flex-1">
                <div className="font-medium">
                  {o.emoji && <span className="mr-2">{o.emoji}</span>}
                  {o.label}
                </div>
                {o.subtitle && (
                  <div className="text-xs text-muted-foreground">
                    {o.subtitle}
                  </div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {multi && (
        <div className="mt-3 flex justify-end">
          <Button
            size="sm"
            disabled={loading || selected.length === 0}
            onClick={() => onPick(selected)}
          >
            Confirm selection
          </Button>
        </div>
      )}
    </div>
  );
}
