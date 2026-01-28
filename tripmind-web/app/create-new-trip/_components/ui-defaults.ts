import type { UiOption } from "./useTripAi";

export function fallbackForUi(ui?: string): UiOption[] | undefined {
  switch (ui) {
    case "groupSize":
      return [
        { label: "Solo", value: "Solo", emoji: "🧍", subtitle: "Just me" },
        { label: "Couple", value: "Couple", emoji: "💞", subtitle: "2 people" },
        {
          label: "Family",
          value: "Family",
          emoji: "👨‍👩‍👧‍👦",
          subtitle: "With family",
        },
        {
          label: "Friends",
          value: "Friends",
          emoji: "🧑‍🤝‍🧑",
          subtitle: "Group trip",
        },
      ];
    case "budget":
      return [
        {
          label: "Low",
          value: "Low",
          emoji: "💵",
          subtitle: "Budget friendly",
        },
        {
          label: "Medium",
          value: "Medium",
          emoji: "💳",
          subtitle: "Balanced spend",
        },
        {
          label: "High",
          value: "High",
          emoji: "💎",
          subtitle: "Premium comfort",
        },
      ];
    case "interests":
      return [
        { label: "Adventure", value: "Adventure", emoji: "🧗" },
        { label: "Sightseeing", value: "Sightseeing", emoji: "🗺️" },
        { label: "Cultural", value: "Cultural", emoji: "🏛️" },
        { label: "Food", value: "Food", emoji: "🍽️" },
        { label: "Nightlife", value: "Nightlife", emoji: "🎉" },
        { label: "Relaxation", value: "Relaxation", emoji: "🌿" },
      ];
    default:
      return undefined;
  }
}
