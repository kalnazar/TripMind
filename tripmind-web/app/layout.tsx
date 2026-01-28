import type { Metadata } from "next";
import { Outfit } from "next/font/google";
import "./globals.css";

import Header from "../components/Header";
import Footer from "../components/Footer";
import { AuthProvider } from "./providers/AuthProvider";
import { ToastProvider } from "./providers/ToastProvider";

export const metadata: Metadata = {
  title: "TripMind",
  description: "AI-powered trip planner application",
};

const outfit = Outfit({ subsets: ["latin"] });

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <link rel="icon" type="image/svg+xml" href="/logo.svg" />
      <body className={`${outfit.className} min-h-screen flex flex-col`}>
        <ToastProvider>
          <AuthProvider>
            <Header />
            <main className="flex-grow">{children}</main>
            <Footer />
          </AuthProvider>
        </ToastProvider>
      </body>
    </html>
  );
}
