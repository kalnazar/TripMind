import { NextRequest, NextResponse } from "next/server";

const PROTECTED = ["/dashboard", "/trips"];

export function middleware(req: NextRequest) {
  const token = req.cookies.get(process.env.JWT_COOKIE_NAME!)?.value;
  if (PROTECTED.some((p) => req.nextUrl.pathname.startsWith(p)) && !token) {
    const url = new URL("/login", req.url);
    url.searchParams.set("next", req.nextUrl.pathname);
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}
