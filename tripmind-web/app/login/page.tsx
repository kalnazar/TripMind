"use client";

import Link from "next/link";
import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth } from "@/app/providers/AuthProvider";
import { useToast } from "@/app/providers/ToastProvider";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const sp = useSearchParams();
  const next = sp.get("next") || "/create-new-trip";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const { toast } = useToast();

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const result = await login(email, password);
    if (result.ok) {
      toast({ title: "Welcome back!", variant: "success" });
      router.replace(next);
    } else {
      toast({
        title: "Login failed",
        description: result.error || "Invalid email or password",
        variant: "error",
      });
    }
  }

  return (
    <div className="min-h-[calc(100vh-120px)] grid place-items-center bg-gradient-to-b from-background to-muted/40 px-4">
      <Card className="w-full max-w-md shadow-lg rounded-2xl border-muted">
        <CardHeader className="space-y-1">
          <div className="flex items-center justify-between">
            <CardTitle className="text-2xl">Welcome back</CardTitle>
            <div className="flex gap-2">
              {/* на /login нет смысла рендерить кнопку на /login */}
              <Button asChild variant="ghost" size="sm">
                <Link href="/register">Create account</Link>
              </Button>
            </div>
          </div>
          <CardDescription>
            Use your email and password to continue.
          </CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={onSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="you@mail.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="********"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <Button type="submit" className="w-full">
              Sign in
            </Button>

            <Separator className="my-2" />
            <p className="text-xs text-muted-foreground text-center">
              Don’t have an account?{" "}
              <Link
                href="/register"
                className="text-primary underline underline-offset-4"
              >
                Create one
              </Link>
            </p>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
