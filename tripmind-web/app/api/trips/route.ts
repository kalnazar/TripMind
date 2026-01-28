import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";

const BACKEND =
  process.env.BACKEND_BASE || process.env.NEXT_PUBLIC_API_BASE_URL!;

export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => ({}));
  const cookieName = process.env.JWT_COOKIE_NAME || "tm_token";
  const c = (await cookies()).get(cookieName);
  const token = c?.value;

  if (!token) {
    return NextResponse.json(
      { error: "Unauthorized", message: "No authentication token" },
      { status: 401 }
    );
  }

  const upstream = await fetch(`${BACKEND.replace(/\/$/, "")}/api/trips`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
    cache: "no-store",
  });

  const text = await upstream.text();
  try {
    return NextResponse.json(JSON.parse(text), { status: upstream.status });
  } catch {
    return NextResponse.json({ error: text }, { status: upstream.status });
  }
}
