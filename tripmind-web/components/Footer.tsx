import Link from "next/link";
import { FaFacebookF, FaInstagram, FaTwitter } from "react-icons/fa";

export default function Footer() {
  return (
    <footer className="border-t bg-background text-foreground">
      <div className="max-w-7xl mx-auto px-6 py-10 grid grid-cols-1 md:grid-cols-4 gap-10">
        {/* Brand */}
        <div>
          <h2 className="text-xl font-bold">
            Trip<span className="text-primary">Mind</span>
          </h2>
          <p className="mt-2 text-sm text-muted-foreground">
            Your personal AI-powered travel concierge.
          </p>
        </div>

        {/* Navigation */}
        <div>
          <h3 className="text-sm font-semibold mb-3">Explore</h3>
          <ul className="space-y-2 text-sm text-muted-foreground">
            <li>
              <Link href="/destinations" className="hover:text-primary">
                Destinations
              </Link>
            </li>
            <li>
              <Link href="/plan-a-trip" className="hover:text-primary">
                Plan a Trip
              </Link>
            </li>
            <li>
              <Link href="/about" className="hover:text-primary">
                About Us
              </Link>
            </li>
          </ul>
        </div>

        {/* Resources */}
        <div>
          <h3 className="text-sm font-semibold mb-3">Resources</h3>
          <ul className="space-y-2 text-sm text-muted-foreground">
            <li>
              <Link href="/faq" className="hover:text-primary">
                FAQ
              </Link>
            </li>
            <li>
              <Link href="/blog" className="hover:text-primary">
                Blog
              </Link>
            </li>
            <li>
              <Link href="/contact" className="hover:text-primary">
                Contact
              </Link>
            </li>
          </ul>
        </div>

        {/* Social */}
        <div>
          <h3 className="text-sm font-semibold mb-3">Follow Us</h3>
          <div className="flex gap-4 text-muted-foreground">
            <a href="#" aria-label="Facebook" className="hover:text-primary">
              <FaFacebookF />
            </a>
            <a href="#" aria-label="Instagram" className="hover:text-primary">
              <FaInstagram />
            </a>
            <a href="#" aria-label="Twitter" className="hover:text-primary">
              <FaTwitter />
            </a>
          </div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="border-t text-center py-4 text-sm text-muted-foreground">
        © {new Date().getFullYear()} TripMind. All rights reserved.
      </div>
    </footer>
  );
}
