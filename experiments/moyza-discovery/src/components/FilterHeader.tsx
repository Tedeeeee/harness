"use client";

import { useRouter } from "next/navigation";
import type { ChangeEvent, FormEvent } from "react";

interface Props {
  value: string;
  onChange: (value: string) => void;
}

export function FilterHeader({ value, onChange }: Props) {
  const router = useRouter();

  const handleBack = () => {
    router.back();
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
  };

  const handleInput = (e: ChangeEvent<HTMLInputElement>) => {
    onChange(e.target.value);
  };

  return (
    <header className="filter-header" data-testid="filter-header">
      <button
        type="button"
        aria-label="Back"
        className="filter-header__back"
        data-testid="filter-header-back"
        onClick={handleBack}
      >
        ‹
      </button>
      <form
        role="search"
        className="filter-header__search"
        onSubmit={handleSubmit}
      >
        <input
          type="search"
          placeholder="Please enter a keyword."
          value={value}
          onChange={handleInput}
          aria-label="Search titles"
        />
        <button type="submit" aria-label="Search">
          <span aria-hidden>🔍</span>
        </button>
      </form>
    </header>
  );
}
