"use client";

import { useState } from "react";
import dynamic from "next/dynamic";
import Chatbox, { TripPlan } from "./_components/ChatUI";

const TripPlanPanel = dynamic(() => import("./_components/TripPlanPanel"), {
  ssr: false,
  loading: () => <div className="p-6">Loading trip panel…</div>,
});

export default function CreateNewTrip() {
  const [plan, setPlan] = useState<TripPlan | null>(null);

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-5 p-10">
      <div>
        <Chatbox onPlanReady={setPlan} />
      </div>
      <div>
        <TripPlanPanel plan={plan} />
      </div>
    </div>
  );
}
