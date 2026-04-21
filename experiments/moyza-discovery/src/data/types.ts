export type Country = "USA" | "Korea" | "China" | "Japan";

export type Genre = "Romance" | "Horror" | "Action" | "Comedy" | "B/L";

export type Platform = "A" | "B" | "C" | "D" | "E";

export type HomeSectionKey = "new-releases" | "popular-picks" | "korea-picks";

export interface Title {
  id: string;
  title: string;
  posterUrl: string;
  year: number;
  episodes: number;
  country: Country;
  genre: Genre;
  platform: Platform;
  rating: number;
  ageRating: string;
  externalUrl: string;
  synopsis: string;
  cast: string[];
  similarIds: string[];
  isTop?: boolean;
}

export interface FilterOptions {
  countries: readonly Country[];
  genres: readonly Genre[];
  platforms: readonly Platform[];
}

export interface FilterSelection {
  country?: Country | readonly Country[];
  genre?: Genre | readonly Genre[];
  platform?: Platform | readonly Platform[];
  keyword?: string;
}

export interface HomeSection {
  key: HomeSectionKey;
  label: string;
  titleIds: readonly string[];
  maxItems: number;
}

export interface ResolvedHomeSection {
  key: HomeSectionKey;
  label: string;
  maxItems: number;
  titles: Title[];
}
