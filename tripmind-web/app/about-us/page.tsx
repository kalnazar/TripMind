import React from "react";
import { ArrowDown, Users, Globe2, Compass } from "lucide-react";
import { HeroVideoDialog } from "@/components/ui/hero-video-dialog";

const AboutUsPage = () => {
  return (
    <div className="my-10 flex flex-col items-center justify-center px-6 md:px-12 space-y-10">
      {/* Mission Section */}
      <div className="max-w-4xl text-center space-y-6">
        <h3 className="text-3xl font-bold">Our Mission</h3>
        <p className="text-lg text-gray-600 dark:text-gray-300 leading-relaxed">
          At TripMind, we believe travel planning should be exciting—not
          overwhelming. Our mission is to make discovering destinations,
          creating itineraries, and booking trips as seamless as possible with
          the power of AI.
        </p>
      </div>

      {/* Values Section */}
      <div className="grid md:grid-cols-3 gap-10 max-w-6xl w-full">
        <div className="flex flex-col items-center text-center space-y-3 p-6 border rounded-xl shadow-sm">
          <Users className="h-10 w-10 text-primary" />
          <h4 className="font-semibold text-xl">Built for Travelers</h4>
          <p className="text-gray-600 dark:text-gray-300 text-sm">
            Whether you’re a backpacker or a luxury explorer, TripMind adapts to
            your needs.
          </p>
        </div>
        <div className="flex flex-col items-center text-center space-y-3 p-6 border rounded-xl shadow-sm">
          <Globe2 className="h-10 w-10 text-green-500" />
          <h4 className="font-semibold text-xl">Global Perspective</h4>
          <p className="text-gray-600 dark:text-gray-300 text-sm">
            We pull inspiration and data from destinations all over the world,
            helping you explore beyond the obvious.
          </p>
        </div>
        <div className="flex flex-col items-center text-center space-y-3 p-6 border rounded-xl shadow-sm">
          <Compass className="h-10 w-10 text-blue-500" />
          <h4 className="font-semibold text-xl">Smart Planning</h4>
          <p className="text-gray-600 dark:text-gray-300 text-sm">
            AI-driven suggestions help you uncover hidden gems, optimize routes,
            and save time planning.
          </p>
        </div>
      </div>

      {/* Video Section */}
      <div className="max-w-2xl text-center">
        <h2 className="mb-7 flex items-center justify-center gap-2 text-md md:text-3xl font-semibold">
          New here?{" "}
          <strong>
            Discover how Trip<sup className="text-primary">Mind</sup> works
          </strong>
          <ArrowDown className="h-6 w-6 text-primary" />
        </h2>
        <HeroVideoDialog
          className="block dark:hidden"
          animationStyle="from-center"
          videoSrc="https://www.youtube.com/embed/eRGXq4t9wY4?si=Wc_VsBCt1Gck2sKP"
          thumbnailSrc="hero/tower.webp"
          thumbnailAlt="Illustrating the usage of an app"
        />
      </div>

      {/* CTA Section */}
      <div className="text-center max-w-3xl space-y-4">
        <h3 className="text-3xl font-bold">Join Us on the Journey</h3>
        <p className="text-lg text-gray-600 dark:text-gray-300">
          TripMind is more than just an app—it’s a community of explorers.
          Whether you’re looking to plan your next vacation or just dream about
          faraway places, we’re here to guide the way.
        </p>
        <button className="px-6 py-3 bg-primary text-white rounded-lg font-medium hover:bg-primary/80 transition">
          Start Planning
        </button>
      </div>
    </div>
  );
};

export default AboutUsPage;
