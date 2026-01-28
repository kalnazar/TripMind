"use client";

import { Button } from "@/components/ui/button";
import Link from "next/link";
import { usePathname } from "next/navigation";
import Image from "next/image";
import { Menu, X, User } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/app/providers/AuthProvider";
import ProfileMenu from "./profile/ProfileMenu";

const menuOptions = [
  { name: "Home", path: "/" },
  { name: "Experts", path: "/experts" },
  { name: "Plans", path: "/plans" },
  { name: "About Us", path: "/about-us" },
  { name: "Contact Us", path: "/contact-us" },
];

export default function Header() {
  const [menuOpen, setMenuOpen] = useState(false);
  const { user, loading, logout } = useAuth();
  const pathname = usePathname();

  const isActive = (path: string) => {
    if (path === "/") return pathname === "/";
    return pathname === path || pathname?.startsWith(`${path}/`);
  };

  return (
    <header className="p-4 border-b bg-white dark:bg-black sticky top-0 z-50">
      <div className="max-w-7xl mx-auto flex justify-between items-center">
        <div className="flex gap-2 items-center">
          <Image src="/logo.svg" alt="Logo" width={30} height={30} />
          <a href="/" className="font-bold text-2xl">
            Trip<sup className="text-md text-primary">Mind</sup>
          </a>
        </div>

        {/* Desktop Menu */}
        <nav className="hidden md:flex gap-6 items-center">
          {menuOptions.map((m) => {
            const active = isActive(m.path);
            return (
            <Link
              key={m.path}
              href={m.path}
              className={`text-lg transition-all hover:scale-105 hover:text-primary hover:underline underline-offset-8 ${
                active ? "text-primary underline" : ""
              }`}
            >
              {m.name}
            </Link>
          )})}

          {loading ? (
            <span className="text-sm opacity-70">loading...</span>
          ) : user ? (
            <ProfileMenu />
          ) : (
            <Button asChild>
              <Link href="/login">Sign in</Link>
            </Button>
          )}
        </nav>

        <div className="md:hidden">
          <button onClick={() => setMenuOpen(!menuOpen)}>
            {menuOpen ? <X size={28} /> : <Menu size={28} />}
          </button>
        </div>
      </div>

      {menuOpen && (
        <nav className="md:hidden mt-4 flex flex-col gap-4 items-center bg-gray-100 dark:bg-gray-900 p-4 rounded-lg">
          {menuOptions.map((m) => {
            const active = isActive(m.path);
            return (
            <Link
              key={m.path}
              href={m.path}
              className={`text-lg hover:text-primary ${
                active ? "text-primary underline underline-offset-8" : ""
              }`}
              onClick={() => setMenuOpen(false)}
            >
              {m.name}
            </Link>
          )})}

          {loading ? (
            <span className="text-sm opacity-70">loading...</span>
          ) : user ? (
            <ProfileMenu />
          ) : (
            <Button asChild>
              <Link href="/login">Sign in</Link>
            </Button>
          )}
        </nav>
      )}
    </header>
  );
}
