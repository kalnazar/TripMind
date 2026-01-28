import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function GET() {
  const cookieName = process.env.JWT_COOKIE_NAME || "tm_token";
  const c = (await cookies()).get(cookieName);

  // If cookie is missing -> 401 with reason
  if (!c?.value) {
    return NextResponse.json(
      { authenticated: false, reason: "no_cookie", cookieName },
      { status: 401 }
    );
  }

  const token = c.value;
  const api = process.env.NEXT_PUBLIC_API_BASE_URL!; // e.g. http://localhost:8080

  // Forward to Spring with Bearer token
  const upstream = await fetch(`${api}/api/users/me`, {
    headers: { Authorization: `Bearer ${token}` },
    cache: "no-store",
  });

  const text = await upstream.text();

  // If Spring rejects, bubble up details so we can see *why*
  if (!upstream.ok) {
    return NextResponse.json(
      {
        authenticated: false,
        upstreamStatus: upstream.status,
        upstreamBody: text,
      },
      { status: upstream.status }
    );
  }

  // Ok → return user
  const user = JSON.parse(text); // { email, name, avatarUrl }
  return NextResponse.json({ authenticated: true, user });
}
