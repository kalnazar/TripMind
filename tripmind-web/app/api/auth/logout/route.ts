import { NextResponse } from "next/server";

export async function POST() {
  const res = NextResponse.json({ ok: true });
  res.cookies.set(process.env.JWT_COOKIE_NAME!, "", { path: "/", maxAge: 0 });
  return res;
}
