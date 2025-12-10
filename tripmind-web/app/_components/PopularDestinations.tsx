import { cn } from "@/lib/utils";
import { Marquee } from "@/components/ui/marquee";

const destinations = [
  {
    category: "World Wonder",
    title: "Discover Chichen Itza",
    src: "/hero/chichen.webp",
    link: "https://en.wikipedia.org/wiki/Chichen_Itza",
  },
  {
    category: "World Wonder",
    title: "Marvel at Christ the Redeemer",
    src: "/hero/christ.webp",
    link: "https://en.wikipedia.org/wiki/Christ_the_Redeemer_(statue)",
  },
  {
    category: "Ancient History",
    title: "Step inside the Colosseum",
    src: "/hero/colosseum.webp",
    link: "https://en.wikipedia.org/wiki/Colosseum",
  },
  {
    category: "Ancient History",
    title: "Uncover the Great Pyramid of Giza",
    src: "/hero/giza.webp",
    link: "https://en.wikipedia.org/wiki/Great_Pyramid_of_Giza",
  },
  {
    category: "Adventure",
    title: "Explore Machu Picchu",
    src: "/hero/peru.webp",
    link: "https://en.wikipedia.org/wiki/Machu_Picchu",
  },
  {
    category: "World Wonder",
    title: "Admire the Taj Mahal",
    src: "/hero/taj.webp",
    link: "https://en.wikipedia.org/wiki/Taj_Mahal",
  },
  {
    category: "Landmark",
    title: "Visit the India Gate",
    src: "/hero/india.webp",
    link: "https://en.wikipedia.org/wiki/India_Gate",
  },
  {
    category: "World Wonder",
    title: "Walk the Great Wall of China",
    src: "/hero/wall.webp",
    link: "https://en.wikipedia.org/wiki/Great_Wall_of_China",
  },
  {
    category: "Iconic Landmark",
    title: "See the Eiffel Tower",
    src: "/hero/tower.webp",
    link: "https://en.wikipedia.org/wiki/Eiffel_Tower",
  },
  {
    category: "Iconic Landmark",
    title: "Experience the Statue of Liberty",
    src: "/hero/liberty.webp",
    link: "https://en.wikipedia.org/wiki/Statue_of_Liberty",
  },
  {
    category: "Architecture",
    title: "Admire the Sydney Opera House",
    src: "/hero/sydney.webp",
    link: "https://en.wikipedia.org/wiki/Sydney_Opera_House",
  },
  {
    category: "Adventure",
    title: "Conquer Mount Everest",
    src: "/hero/everest.webp",
    link: "https://en.wikipedia.org/wiki/Mount_Everest",
  },
  {
    category: "Ancient History",
    title: "Unlock the mystery of Stonehenge",
    src: "/hero/stonehenge.webp",
    link: "https://en.wikipedia.org/wiki/Stonehenge",
  },
];

const firstRow = destinations.slice(0, destinations.length / 2);
const secondRow = destinations.slice(destinations.length / 2);

const DestinationCard = ({
  src,
  title,
  category,
  link,
}: {
  src: string;
  title: string;
  category: string;
  link: string;
}) => {
  return (
    <a
      href={link}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(
        "relative h-full w-64 cursor-pointer overflow-hidden rounded-xl border p-4",
        "border-gray-950/[.1] bg-gray-950/[.01] hover:bg-gray-950/[.05]",
        "dark:border-gray-50/[.1] dark:bg-gray-50/[.10] dark:hover:bg-gray-50/[.15]"
      )}
    >
      <img
        className="w-full h-40 object-cover rounded-md mb-3"
        src={src}
        alt={title}
      />
      <div className="flex flex-col">
        <figcaption className="text-sm font-medium dark:text-white">
          {title}
        </figcaption>
        <p className="text-xs font-medium text-neutral-500 dark:text-white/40">
          {category}
        </p>
      </div>
    </a>
  );
};

export function PopularDestinations() {
  return (
    <div className="relative flex w-full flex-col items-center justify-center overflow-hidden py-10">
      <h2 className="text-xl md:text-4xl font-bold mb-6 text-neutral-800 dark:text-neutral-200">
        Popular Destinations
      </h2>
      <Marquee pauseOnHover className="[--duration:25s]">
        {firstRow.map((dest) => (
          <DestinationCard key={dest.title} {...dest} />
        ))}
      </Marquee>
      <Marquee reverse pauseOnHover className="[--duration:25s]">
        {secondRow.map((dest) => (
          <DestinationCard key={dest.title} {...dest} />
        ))}
      </Marquee>
      <div className="from-background pointer-events-none absolute inset-y-0 left-0 w-1/4 bg-gradient-to-r"></div>
      <div className="from-background pointer-events-none absolute inset-y-0 right-0 w-1/4 bg-gradient-to-l"></div>
    </div>
  );
}
