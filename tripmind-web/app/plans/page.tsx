"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { CheckCircle } from "lucide-react";
import { useAuth } from "@/app/providers/AuthProvider";
import { PaymentDialog } from "@/components/ui/payment-dialog";
import { Button } from "@/components/ui/button";

const plans = [
  {
    name: "Basic",
    price: "Free",
    description: "Perfect for short trips and simple itineraries.",
    features: ["AI Trip Suggestions", "Up to 3 itineraries", "Email support"],
  },
  {
    name: "Pro",
    price: "$9.99/month",
    description: "For frequent travelers who want flexibility and insights.",
    features: [
      "Unlimited itineraries",
      "Personalized recommendations",
      "Priority support",
    ],
  },
  {
    name: "Premium",
    price: "$19.99/month",
    description: "For luxury and business travelers who want it all.",
    features: [
      "Everything in Pro",
      "Exclusive deals & offers",
      "24/7 concierge AI assistant",
    ],
  },
];

export default function PlansPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [selectedPlan, setSelectedPlan] = useState<{
    name: string;
    price: string;
  } | null>(null);
  const [isPaymentOpen, setIsPaymentOpen] = useState(false);

  const handleGetStarted = (plan: { name: string; price: string }) => {
    if (loading) return;

    if (!user) {
      router.push("/login?next=/plans");
      return;
    }

    // For free plan, just redirect to create trip
    if (plan.price === "Free") {
      router.push("/create-new-trip");
      return;
    }

    // For paid plans, show payment dialog
    setSelectedPlan(plan);
    setIsPaymentOpen(true);
  };

  const handlePaymentSuccess = () => {
    // After successful payment, redirect to create trip
    router.push("/create-new-trip");
  };

  return (
    <div className="flex flex-col items-center text-center py-16 px-6">
      <h1 className="text-4xl font-bold mb-6">Pricing Plans</h1>
      <p className="text-lg text-gray-600 mb-12 max-w-2xl">
        Choose the plan that fits your travel style. Whether it's a weekend
        getaway or a world tour, Trip<span className="text-primary">Mind</span>{" "}
        has you covered.
      </p>

      <div className="grid md:grid-cols-3 gap-8 w-full max-w-6xl">
        {plans.map((plan, index) => (
          <div
            key={index}
            className="border rounded-xl shadow-md p-6 flex flex-col items-center hover:scale-105 transition"
          >
            <h2 className="text-2xl font-bold mb-2">{plan.name}</h2>
            <p className="text-xl text-primary mb-4">{plan.price}</p>
            <p className="text-sm text-gray-500 mb-6">{plan.description}</p>
            <ul className="text-left space-y-2 mb-6">
              {plan.features.map((feature, i) => (
                <li key={i} className="flex items-center gap-2">
                  <CheckCircle className="text-green-500 w-5 h-5" />
                  {feature}
                </li>
              ))}
            </ul>
            <Button
              onClick={() => handleGetStarted(plan)}
              className="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary/90"
              disabled={loading}
            >
              Get Started
            </Button>
          </div>
        ))}
      </div>

      {selectedPlan && (
        <PaymentDialog
          isOpen={isPaymentOpen}
          onClose={() => {
            setIsPaymentOpen(false);
            setSelectedPlan(null);
          }}
          planName={selectedPlan.name}
          planPrice={selectedPlan.price}
          onPaymentSuccess={handlePaymentSuccess}
        />
      )}
    </div>
  );
}
