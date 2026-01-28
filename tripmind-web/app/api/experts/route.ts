import { NextResponse } from "next/server";

const BACKEND =
  process.env.BACKEND_BASE || process.env.NEXT_PUBLIC_API_BASE_URL!;

export async function GET() {
  const upstream = await fetch(
    `${BACKEND.replace(/\/$/, "")}/api/public/experts`,
    { cache: "no-store" }
  );

  const text = await upstream.text();
  try {
    return NextResponse.json(JSON.parse(text), { status: upstream.status });
  } catch {
    return NextResponse.json({ error: text }, { status: upstream.status });
  }
}
