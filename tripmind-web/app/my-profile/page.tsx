"use client";

import Link from "next/link";
import { useAuth } from "@/app/providers/AuthProvider";
import { useToast } from "@/app/providers/ToastProvider";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";
import {
  User as UserIcon,
  ArrowRight,
  Sparkles,
  Shield,
  Mail,
} from "lucide-react";

export default function ProfilePage() {
  const { user, logout } = useAuth();
  const { toast } = useToast();

  return (
    <div className="max-w-3xl mx-auto px-4 py-8 space-y-8">
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <Avatar className="h-16 w-16 ring-2 ring-primary/10">
            <AvatarFallback className="bg-primary/10 text-primary">
              <UserIcon className="h-7 w-7" />
            </AvatarFallback>
          </Avatar>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-semibold">{user?.name || "User"}</h1>
              <Badge variant="secondary" className="uppercase tracking-wide">
                Member
              </Badge>
            </div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground mt-1">
              <Mail className="h-4 w-4" />
              <span>{user?.email}</span>
            </div>
          </div>
        </div>

        <Button asChild className="group">
          <Link href="/create-new-trip">
            <Sparkles className="h-4 w-4 mr-2" />
            Create New Trip
            <ArrowRight className="h-4 w-4 ml-2 transition-transform group-hover:translate-x-0.5" />
          </Link>
        </Button>
      </div>

      <Separator />

      <div className="grid md:grid-cols-2 gap-6">
        <Card className="border-muted">
          <CardHeader>
            <CardTitle>Account</CardTitle>
            <CardDescription>
              Basic info linked to your account.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="name">Name</Label>
              <Input
                id="name"
                value={user?.name || ""}
                readOnly
                className="bg-muted/30"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                value={user?.email || ""}
                readOnly
                className="bg-muted/30"
              />
            </div>
            <p className="text-xs text-muted-foreground">
              Editing will be available soon.
            </p>
          </CardContent>
        </Card>

        {/* Security (placeholder) */}
        <Card className="border-muted">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Shield className="h-5 w-5 text-primary" />
              <CardTitle>Security</CardTitle>
            </div>
            <CardDescription>
              Change your password (coming soon).
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label htmlFor="curr">Current password</Label>
                <Input
                  id="curr"
                  type="password"
                  placeholder="••••••••"
                  disabled
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="new">New password</Label>
                <Input
                  id="new"
                  type="password"
                  placeholder="••••••••"
                  disabled
                />
              </div>
            </div>
            <Button disabled className="w-full">
              Update password
            </Button>
            <p className="text-xs text-muted-foreground">
              This section is disabled for now.
            </p>
          </CardContent>
        </Card>
      </div>

      <Card className="border-dashed">
        <CardHeader>
          <CardTitle className="text-base">Tips</CardTitle>
          <CardDescription>What’s next</CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground space-y-1.5">
          <p>
            • Click <span className="font-medium">Create New Trip</span> to
            start planning.
          </p>
          <p>
            • Avatar upload will be added later. A default icon is shown for
            now.
          </p>
        </CardContent>
      </Card>

      <Card className="border-red-200 bg-red-50/40">
        <CardHeader>
          <CardTitle className="text-base text-red-700">Danger Zone</CardTitle>
          <CardDescription>
            Delete your account and all saved itineraries.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Button
            variant="destructive"
            onClick={async () => {
              if (
                !window.confirm(
                  "Delete your account? This will remove all itineraries and cannot be undone."
                )
              )
                return;
              const res = await fetch("/api/users/me", { method: "DELETE" });
              if (!res.ok && res.status !== 204) {
                const text = await res.text();
                toast({
                  title: "Delete failed",
                  description: text || "Could not delete account",
                  variant: "error",
                });
                return;
              }
              await logout();
              toast({
                title: "Account deleted",
                description: "Your account has been removed.",
                variant: "success",
              });
            }}
          >
            Delete Account
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
