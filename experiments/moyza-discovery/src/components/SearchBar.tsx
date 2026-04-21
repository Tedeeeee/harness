"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

export function SearchBar() {
  const router = useRouter();
  const [q, setQ] = useState("");

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    const trimmed = q.trim();
    router.push(trimmed ? `/search?q=${encodeURIComponent(trimmed)}` : "/search");
  };

  return (
    <form
      role="search"
      className="search-bar"
      data-testid="search-bar"
      onSubmit={onSubmit}
    >
      <input
        type="search"
        placeholder="Please enter a keyword."
        value={q}
        onChange={(e) => setQ(e.target.value)}
        aria-label="Search titles"
      />
      <button type="submit" aria-label="Search">
        <span aria-hidden>🔍</span>
      </button>
    </form>
  );
}
