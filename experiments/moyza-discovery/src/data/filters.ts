import type { Country, FilterOptions, Genre, Platform } from "./types";

export const COUNTRIES: readonly Country[] = ["USA", "Korea", "China", "Japan"];

export const GENRES: readonly Genre[] = [
  "Romance",
  "Horror",
  "Action",
  "Comedy",
  "B/L",
];

export const PLATFORMS: readonly Platform[] = ["A", "B", "C", "D", "E"];

export const FILTER_OPTIONS: FilterOptions = {
  countries: COUNTRIES,
  genres: GENRES,
  platforms: PLATFORMS,
};

export const DEFAULT_SORT: "latest-first" = "latest-first";
