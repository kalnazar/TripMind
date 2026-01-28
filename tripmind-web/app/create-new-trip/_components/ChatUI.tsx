"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { Send } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import AssistantOptions from "./AssistantOptions";
import EmptyBoxState from "./EmptyBoxState";
import { useTripAi } from "./useTripAi";
import type { UiOption } from "./useTripAi";
import FinalTripCard from "./FinalTripCard";
import { buildItinerary } from "@/lib/aiClient";

/* ---------- Types ---------- */
export type TripPlan = any; // keep loose for now; TripPlanPanel can type-narrow
export type FinalPlanInput = {
  source?: string;
  destination?: string;
  groupSize?: "Solo" | "Couple" | "Family" | "Friends";
  budget?: "Low" | "Medium" | "High";
  tripDurationDays?: number;
  interests?: string[];
  specialReq?: string | null;
};

type Props = {
  onPlanReady?: (plan: TripPlan) => void;
};

/* ---------- Fallback option chips when model doesn’t send options ---------- */
function fallbackForUi(ui?: string): UiOption[] | undefined {
  switch (ui) {
    case "groupSize":
      return [
        { label: "Solo", value: "Solo", emoji: "🧍", subtitle: "Just me" },
        { label: "Couple", value: "Couple", emoji: "💞", subtitle: "2 people" },
        {
          label: "Family",
          value: "Family",
          emoji: "👨‍👩‍👧‍👦",
          subtitle: "With family",
        },
        {
          label: "Friends",
          value: "Friends",
          emoji: "🧑‍🤝‍🧑",
          subtitle: "Group trip",
        },
      ];
    case "budget":
      return [
        {
          label: "Low",
          value: "Low",
          emoji: "💵",
          subtitle: "Budget friendly",
        },
        {
          label: "Medium",
          value: "Medium",
          emoji: "💳",
          subtitle: "Balanced spend",
        },
        {
          label: "High",
          value: "High",
          emoji: "💎",
          subtitle: "Premium comfort",
        },
      ];
    case "interests":
      return [
        { label: "Adventure", value: "Adventure", emoji: "🧗" },
        { label: "Sightseeing", value: "Sightseeing", emoji: "🗺️" },
        { label: "Cultural", value: "Cultural", emoji: "🏛️" },
        { label: "Food", value: "Food", emoji: "🍽️" },
        { label: "Nightlife", value: "Nightlife", emoji: "🎉" },
        { label: "Relaxation", value: "Relaxation", emoji: "🌿" },
      ];
    default:
      return undefined;
  }
}

export default function Chatbox({ onPlanReady }: Props) {
  /* ---- chat state ---- */
  const { messages, reply, loading, send, pick, appendMessage } = useTripAi([]);
  const [input, setInput] = useState("");
  const [awaitingSpecialReq, setAwaitingSpecialReq] = useState(false);

  /* ---- snapshot of final inputs (for itinerary payload) ---- */
  const [finalInput, setFinalInput] = useState<FinalPlanInput>({
    interests: [],
  });

  /* ---- itinerary build state (from API) ---- */
  const [planBuilding, setPlanBuilding] = useState(false);
  const [planError, setPlanError] = useState<string | null>(null);
  const [planCached, setPlanCached] = useState<TripPlan | null>(null);

  const listRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  /* ---- auto-scroll ---- */
  useEffect(() => {
    listRef.current?.scrollTo({
      top: listRef.current.scrollHeight,
      behavior: "smooth",
    });
  }, [messages, loading]);

  /* ---- last assistant field asked ---- */
  const lastAssistantField = useMemo(() => {
    for (let i = messages.length - 1; i >= 0; i--) {
      const m = messages[i] as any;
      if (m.role === "assistant")
        return (m.meta?.ui as string | undefined) ?? undefined;
    }
    return undefined;
  }, [messages]);

  /* ---- send text + capture answers into finalInput ---- */
  async function onSend() {
    const text = input.trim();
    if (!text) return;

    if (awaitingSpecialReq) {
      appendMessage({ role: "user", content: text });
      setFinalInput((prev) => ({
        ...prev,
        specialReq: /^(no|none|nothing|n\/a)$/i.test(text) ? null : text,
      }));
      setInput("");
      setAwaitingSpecialReq(false);
      sawFinalRef.current = true;
      requestItinerary();
      return;
    }

    if (lastAssistantField) {
      setFinalInput((prev) => {
        const next = { ...prev };
        switch (lastAssistantField) {
          case "source":
            next.source = text;
            break;
          case "destination":
            next.destination = text;
            break;
          case "tripDuration":
            {
              const n = parseInt(text.replace(/\D+/g, ""), 10);
              if (!Number.isNaN(n)) next.tripDurationDays = n;
            }
            break;
          case "specialReq":
            next.specialReq = /^(no|none|nothing|n\/a)$/i.test(text)
              ? null
              : text;
            break;
        }
        return next;
      });
    }

    await send(text);
    setInput("");
  }

  /* ---- last assistant index with options ---- */
  const lastOptionsIndex = useMemo(() => {
    for (let i = messages.length - 1; i >= 0; i--) {
      const m = messages[i] as any;
      if (m.role !== "assistant") continue;
      const ui = m.meta?.ui as string | undefined;
      const hasExplicit =
        Array.isArray(m.meta?.options) && m.meta.options.length > 0;
      const hasFallback = !!fallbackForUi(ui)?.length;
      if (hasExplicit || hasFallback) return i;
    }
    return -1;
  }, [messages]);

  /* ---- option click: update state + send/pick ---- */
  const onPickWithState =
    (
      field:
        | "groupSize"
        | "budget"
        | "interests"
        | "source"
        | "destination"
        | "tripDuration"
        | "specialReq",
      isLastSet: boolean
    ) =>
    async (val: string | string[]) => {
      setFinalInput((prev) => {
        const next = { ...prev };
        if (field === "groupSize" && typeof val === "string")
          next.groupSize = val as any;
        if (field === "budget" && typeof val === "string")
          next.budget = val as any;
        if (field === "interests")
          next.interests = Array.isArray(val) ? val : [val];
        return next;
      });

      const text = Array.isArray(val) ? val.join(", ") : val;
      if (!isLastSet) await send(`${field}: ${text}`);
      else await pick(val);
    };

  /* ---- helper to actually call the itinerary API ---- */
  const requestItinerary = async () => {
    setPlanError(null);
    setPlanBuilding(true);
    try {
      const payload = {
        source: finalInput.source ?? "",
        destination: finalInput.destination ?? "",
        groupSize: finalInput.groupSize ?? "Solo",
        budget: finalInput.budget ?? "Medium",
        tripDurationDays: finalInput.tripDurationDays ?? 3,
        interests: finalInput.interests ?? [],
        specialReq: finalInput.specialReq ?? null,
      };
      const plan = await buildItinerary(payload); // calls /api/ai/itinerary (Next route)
      setPlanCached(plan);
      if (onPlanReady) onPlanReady(plan); // immediately show on the right
    } catch (e: any) {
      setPlanError(e?.message || "Failed to build itinerary");
      setPlanCached(null);
    } finally {
      setPlanBuilding(false);
    }
  };

  /* ---- AUTO build when assistant returns ui === 'final' (only once per final) ---- */
  const sawFinalRef = useRef(false);
  useEffect(() => {
    if (reply?.ui === "final" && !sawFinalRef.current) {
      if (finalInput.specialReq === undefined) {
        setAwaitingSpecialReq(true);
        return;
      }
      sawFinalRef.current = true;
      requestItinerary();
    }
  }, [reply?.ui, finalInput.specialReq]); // runs once per final turn

  /* ---- “View Trip” just re-emits the cached plan to the right panel ---- */
  const handleViewTrip = () => {
    if (planCached && onPlanReady) onPlanReady(planCached);
  };

  /* ---- render ---- */
  const showEmpty = !loading && messages.length === 0;

  return (
    <div className="h-[80vh] flex flex-col border rounded-2xl">
      <div ref={listRef} className="flex-1 overflow-y-auto p-4 space-y-3">
        {showEmpty ? (
          <EmptyBoxState
            onSuggestionClick={(t) => {
              setInput(t);
              textareaRef.current?.focus();
            }}
          />
        ) : (
          <>
            {messages.map((m, i) => {
              const meta = (m as any).meta as
                | {
                    ui?: string;
                    options?: UiOption[];
                    multi?: boolean;
                    hint?: string;
                  }
                | undefined;

              const opts =
                (meta?.options && meta.options.length > 0
                  ? meta.options
                  : fallbackForUi(meta?.ui)) ?? [];

              const isAssistant = m.role === "assistant";
              const isLastSet = i === lastOptionsIndex;
              const field = meta?.ui as
                | "source"
                | "destination"
                | "groupSize"
                | "budget"
                | "tripDuration"
                | "interests"
                | "specialReq"
                | "final"
                | undefined;

              return (
                <div
                  key={i}
                  className={`flex ${
                    m.role === "user" ? "justify-end" : "justify-start"
                  }`}
                >
                  <div
                    className={`max-w-[75%] px-4 py-2 rounded-2xl ${
                      m.role === "user" ? "bg-primary text-white" : "bg-muted"
                    }`}
                  >
                    {/* assistant/user text */}
                    {m.content}

                    {/* options turn */}
                    {isAssistant && opts.length > 0 && field !== "final" && (
                      <div className="mt-2">
                        <AssistantOptions
                          options={opts}
                          multi={meta?.ui === "interests" || !!meta?.multi}
                          hint={meta?.hint}
                          loading={loading}
                          onPick={onPickWithState(field as any, isLastSet)}
                        />
                        {!isLastSet && (
                          <div className="mt-1 text-xs text-muted-foreground">
                            You can still answer the previous question 👆
                          </div>
                        )}
                      </div>
                    )}

                    {/* final card */}
                    {isAssistant && field === "final" && (
                      <>
                        <FinalTripCard
                          summary="" // don't duplicate assistant's final sentence
                          ready={!!planCached && !planBuilding && !planError}
                          building={planBuilding}
                          onView={handleViewTrip}
                        />
                        {planError && (
                          <div className="mt-2 text-xs text-red-600">
                            {planError}{" "}
                            <Button
                              variant="link"
                              className="h-auto p-0 align-baseline"
                              onClick={() => {
                                // allow retry, and also allow rebuild if user changes answers later
                                sawFinalRef.current = true;
                                requestItinerary();
                              }}
                            >
                              Retry
                            </Button>
                          </div>
                        )}
                      </>
                    )}
                  </div>
                </div>
              );
            })}

            {awaitingSpecialReq && (
              <div className="flex justify-start">
                <div className="max-w-[75%] px-4 py-2 rounded-2xl bg-muted">
                  Any special requirements? (Optional)
                </div>
              </div>
            )}

            {loading && (
              <div className="flex justify-start">
                <div className="max-w-lg px-4 py-2 rounded-2xl bg-muted/70">
                  Thinking…
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* composer */}
      <div className="p-3 border-t relative">
        <Textarea
          ref={textareaRef}
          className="min-h-[100px] resize-none border-0 bg-transparent px-0 focus-visible:ring-0"
          placeholder="e.g., Weekend getaway near Tbilisi, 3 days, food + culture"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              onSend();
            }
          }}
          disabled={loading}
        />
        <Button
          size="icon"
          className="absolute bottom-5 right-5"
          onClick={onSend}
          disabled={loading || !input.trim()}
          aria-label="Send"
        >
          <Send className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}
