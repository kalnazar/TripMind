"use client";

import React, { useState } from "react";
import { Send } from "lucide-react";

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    message: "",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Form submitted:", formData);
    // Later: Send to backend or email service
    alert("Thank you for reaching out! We’ll get back to you soon.");
    setFormData({ name: "", email: "", message: "" });
  };

  return (
    <div className="flex flex-col items-center text-center py-16 px-6">
      <h1 className="text-4xl font-bold mb-6">Contact Us</h1>
      <p className="text-lg text-gray-600 mb-12 max-w-2xl">
        Got questions or feedback? We’d love to hear from you. Fill out the form
        below and our team will get back to you.
      </p>

      <form
        onSubmit={handleSubmit}
        className="w-full max-w-xl bg-white dark:bg-neutral-900 p-8 rounded-xl shadow-md"
      >
        <div className="mb-4">
          <input
            type="text"
            placeholder="Your Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            className="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-primary"
            required
          />
        </div>
        <div className="mb-4">
          <input
            type="email"
            placeholder="Your Email"
            value={formData.email}
            onChange={(e) =>
              setFormData({ ...formData, email: e.target.value })
            }
            className="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-primary"
            required
          />
        </div>
        <div className="mb-6">
          <textarea
            placeholder="Your Message"
            value={formData.message}
            onChange={(e) =>
              setFormData({ ...formData, message: e.target.value })
            }
            className="w-full border rounded-lg px-4 py-2 h-32 resize-none focus:ring-2 focus:ring-primary"
            required
          />
        </div>
        <button
          type="submit"
          className="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary/90 flex items-center gap-2 mx-auto"
        >
          Send <Send className="h-4 w-4" />
        </button>
      </form>
    </div>
  );
}
