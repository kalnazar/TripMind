"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";

export default function AvatarUpload({
  onUploaded,
}: {
  onUploaded?: (url: string) => void;
}) {
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");

  async function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) {
      setErr("Max size 5MB");
      return;
    }

    setBusy(true);
    setErr("");
    try {
      const fd = new FormData();
      fd.append("file", file);
      const r = await fetch("/api/upload/avatar", { method: "POST", body: fd });
      const data = await r.json();
      if (!r.ok) throw new Error(data.error || "Upload failed");
      onUploaded?.(data.url);
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex items-center gap-3">
      <input
        id="avatar"
        type="file"
        accept="image/*"
        onChange={handleChange}
        className="hidden"
      />
      <Button asChild disabled={busy}>
        <label htmlFor="avatar">
          {busy ? "Uploading..." : "Upload avatar"}
        </label>
      </Button>
      {err && <span className="text-xs text-red-500">{err}</span>}
    </div>
  );
}
