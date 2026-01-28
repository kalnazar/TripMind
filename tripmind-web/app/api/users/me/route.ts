import { cookies } from "next/headers";
import { NextResponse } from "next/server";

const BACKEND =
  process.env.BACKEND_BASE || process.env.NEXT_PUBLIC_API_BASE_URL!;

export async function DELETE() {
  const cookieName = process.env.JWT_COOKIE_NAME || "tm_token";
  const c = (await cookies()).get(cookieName);
  const token = c?.value;

  if (!token) {
    return NextResponse.json(
      { error: "Unauthorized", message: "No authentication token" },
      { status: 401 }
    );
  }

  const upstream = await fetch(`${BACKEND.replace(/\/$/, "")}/api/users/me`, {
    method: "DELETE",
    headers: { Authorization: `Bearer ${token}` },
    cache: "no-store",
  });

  if (upstream.status === 204) {
    return new NextResponse(null, { status: 204 });
  }

  const text = await upstream.text();
  try {
    return NextResponse.json(JSON.parse(text), { status: upstream.status });
  } catch {
    return NextResponse.json({ error: text }, { status: upstream.status });
  }
}
