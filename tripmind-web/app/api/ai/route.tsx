import { NextRequest, NextResponse } from "next/server";

const BACKEND =
  process.env.BACKEND_BASE || process.env.NEXT_PUBLIC_API_BASE_URL!;

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const cookie = req.headers.get("cookie") ?? "";
  const auth = req.headers.get("authorization") ?? "";

  // ✅ point to /api/ai (Spring) — not /api/ai/chat
  const url = `${BACKEND.replace(/\/$/, "")}/api/ai`;

  const upstream = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(cookie ? { cookie } : {}),
      ...(auth ? { authorization: auth } : {}),
    },
    body: JSON.stringify(body),
  });

  const text = await upstream.text();
  console.log("[/api/ai] backend", upstream.status, text);

  try {
    return NextResponse.json(JSON.parse(text), { status: upstream.status });
  } catch {
    return NextResponse.json({ error: text }, { status: upstream.status });
  }
}
