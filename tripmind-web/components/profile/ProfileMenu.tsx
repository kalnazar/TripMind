"use client";

import Link from "next/link";
import { useAuth } from "@/app/providers/AuthProvider";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  User as UserIcon,
  LogOut,
  PlusCircle,
  UserRound,
  MapIcon,
  CalendarClock,
} from "lucide-react";

export default function ProfileMenu() {
  const { user, logout } = useAuth();
  if (!user) return null;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="ghost"
          className="h-9 px-2 rounded-full data-[state=open]:bg-muted"
        >
          <div className="flex items-center gap-2">
            <Avatar className="h-8 w-8">
              <AvatarImage src={user.avatarUrl || ""} alt={user.email} />
              <AvatarFallback className="bg-primary/10 text-primary">
                <UserIcon className="h-5 w-5" />
              </AvatarFallback>
            </Avatar>
            <span className="text-sm hidden sm:block max-w-[140px] truncate">
              {user.name || user.email}
            </span>
          </div>
        </Button>
      </DropdownMenuTrigger>

      <DropdownMenuContent align="end" className="w-56 z-50">
        <DropdownMenuLabel className="truncate">
          {user.name || "User"}
        </DropdownMenuLabel>
        <div className="px-2 -mt-1 mb-1 text-xs text-muted-foreground truncate">
          {user.email}
        </div>
        <DropdownMenuSeparator />

        <DropdownMenuItem asChild>
          <Link href="/create-new-trip" className="flex items-center gap-2">
            <PlusCircle className="h-4 w-4" />
            Create New Trip
          </Link>
        </DropdownMenuItem>

        <DropdownMenuItem asChild>
          <Link href="/my-itineraries" className="flex items-center gap-2">
            <MapIcon className="h-4 w-4" />
            My Itineraries
          </Link>
        </DropdownMenuItem>

        <DropdownMenuItem asChild>
          <Link href="/my-expert-bookings" className="flex items-center gap-2">
            <CalendarClock className="h-4 w-4" />
            Expert Bookings
          </Link>
        </DropdownMenuItem>

        <DropdownMenuItem asChild>
          <Link href="/my-profile" className="flex items-center gap-2">
            <UserRound className="h-4 w-4" />
            My Profile
          </Link>
        </DropdownMenuItem>

        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={logout}
          className="text-red-600 focus:text-red-600"
        >
          <LogOut className="h-4 w-4 mr-2" />
          Logout
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
