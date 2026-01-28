"use client";
import { useCallback, useRef, useState } from "react";

export type Role = "system" | "user" | "assistant";

export type UiStage =
  | "source"
  | "destination"
  | "groupSize"
  | "budget"
  | "tripDuration"
  | "interests"
  | "specialReq"
  | "final";

export type UiOption =
  | string
  | { label: string; value: string; emoji?: string; subtitle?: string };

export interface AgentReply {
  resp: string;
  ui: UiStage;
  options?: UiOption[];
  multi?: boolean;
  hint?: string;
}

export interface AssistantMeta {
  ui: UiStage;
  options?: UiOption[];
  multi?: boolean;
  hint?: string;
}

export interface ChatMsg {
  role: Role;
  content: string;
  meta?: AssistantMeta; // ⬅️ добавили мету для assistant-сообщений
}

export function useTripAi(initial: ChatMsg[] = []) {
  const [messages, setMessages] = useState<ChatMsg[]>(initial);
  const [reply, setReply] = useState<AgentReply | null>(null);
  const [loading, setLoading] = useState(false);
  const abortRef = useRef<AbortController | null>(null);

  const post = useCallback(async (msgs: ChatMsg[]) => {
    abortRef.current?.abort();
    abortRef.current = new AbortController();

    const res = await fetch("/api/ai", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ messages: msgs }),
      signal: abortRef.current.signal,
    });

    if (!res.ok) throw new Error(`AI_${res.status}`);
    const json = await res.json();
    return (json.response ?? json) as AgentReply;
  }, []);

  const send = useCallback(
    async (userText: string) => {
      const text = userText.trim();
      if (!text || loading) return null;

      setMessages((prev) => [...prev, { role: "user", content: text }]);
      setLoading(true);

      try {
        const current: ChatMsg[] = [
          ...messages,
          { role: "user", content: text },
        ];
        const agent = await post(current);

        setMessages((prev) => [
          ...prev,
          {
            role: "assistant",
            content: agent.resp,
            meta: {
              ui: agent.ui,
              options: agent.options,
              multi: agent.multi,
              hint: agent.hint,
            },
          } as any,
        ]);

        setReply(agent);
        return agent;
      } catch (err) {
        setMessages((prev) => [
          ...prev,
          { role: "assistant", content: "Sorry, I had an issue. Try again." },
        ]);
        setReply(null);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [loading, messages, post]
  );

  const pick = useCallback(
    async (val: string | string[]) => {
      const text = Array.isArray(val) ? val.join(", ") : val;
      return send(text);
    },
    [send]
  );

  const reset = useCallback(() => {
    abortRef.current?.abort();
    setMessages([]);
    setReply(null);
    setLoading(false);
  }, []);

  const appendMessage = useCallback((msg: ChatMsg) => {
    setMessages((prev) => [...prev, msg]);
  }, []);

  return { messages, reply, loading, send, pick, reset, appendMessage };
}
