import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const body = await req.json();

  // call Spring
  const r = await fetch(
    `${process.env.NEXT_PUBLIC_API_BASE_URL}/api/auth/login`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }
  );

  const data = await r.json();
  if (!r.ok) {
    return NextResponse.json(data, { status: r.status });
  }

  // set httpOnly cookie on *3000*
  const res = NextResponse.json({ ok: true });
  res.cookies.set(process.env.JWT_COOKIE_NAME!, data.token, {
    httpOnly: true,
    sameSite: "lax",
    path: "/", // IMPORTANT
    maxAge: 60 * 60 * 24 * 7,
    secure: process.env.NODE_ENV === "production",
  });
  return res;
}
