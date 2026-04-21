"use client";

import { COUNTRIES, GENRES, PLATFORMS } from "@/data/filters";
import type { Country, Genre, Platform } from "@/data/types";

function toggle<T>(list: readonly T[], value: T): T[] {
  return list.includes(value) ? list.filter((v) => v !== value) : [...list, value];
}

interface Props {
  countries: readonly Country[];
  genres: readonly Genre[];
  platforms: readonly Platform[];
  onCountriesChange: (next: readonly Country[]) => void;
  onGenresChange: (next: readonly Genre[]) => void;
  onPlatformsChange: (next: readonly Platform[]) => void;
}

interface ChipProps {
  label: string;
  active: boolean;
  onToggle: () => void;
  textOnly?: boolean;
  testId?: string;
}

function Chip({ label, active, onToggle, textOnly, testId }: ChipProps) {
  const classes = [
    "chip",
    textOnly ? "chip--text" : "chip--pill",
    active ? "is-active" : "",
  ]
    .filter(Boolean)
    .join(" ");
  return (
    <button
      type="button"
      className={classes}
      aria-pressed={active}
      onClick={onToggle}
      data-testid={testId}
    >
      {label}
    </button>
  );
}

export function FilterBar({
  countries,
  genres,
  platforms,
  onCountriesChange,
  onGenresChange,
  onPlatformsChange,
}: Props) {
  return (
    <section className="filter-bar" data-testid="filter-bar">
      <div className="filter-row">
        <span className="filter-row__label">Country</span>
        <div className="filter-row__chips">
          {COUNTRIES.map((c) => (
            <Chip
              key={c}
              label={c}
              active={countries.includes(c)}
              onToggle={() => onCountriesChange(toggle(countries, c))}
              testId={`filter-country-${c}`}
            />
          ))}
        </div>
      </div>
      <div className="filter-row">
        <span className="filter-row__label">Genre</span>
        <div className="filter-row__chips">
          {GENRES.map((g) => (
            <Chip
              key={g}
              label={g}
              active={genres.includes(g)}
              onToggle={() => onGenresChange(toggle(genres, g))}
              testId={`filter-genre-${g.replace("/", "-")}`}
            />
          ))}
        </div>
      </div>
      <div className="filter-row">
        <span className="filter-row__label">Platform</span>
        <div className="filter-row__chips filter-row__chips--text">
          {PLATFORMS.map((p) => (
            <Chip
              key={p}
              label={p}
              active={platforms.includes(p)}
              onToggle={() => onPlatformsChange(toggle(platforms, p))}
              textOnly
              testId={`filter-platform-${p}`}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
