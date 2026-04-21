import { HOME_SECTIONS } from "./home-sections";
import { TITLES } from "./titles";
import type {
  FilterSelection,
  HomeSectionKey,
  ResolvedHomeSection,
  Title,
} from "./types";

const TITLES_BY_ID: ReadonlyMap<string, Title> = new Map(
  TITLES.map((t) => [t.id, t])
);

export function getTitleById(id: string): Title | undefined {
  return TITLES_BY_ID.get(id);
}

export function getAllTitles(): readonly Title[] {
  return TITLES;
}

export function getSection(key: HomeSectionKey): ResolvedHomeSection | undefined {
  const section = HOME_SECTIONS.find((s) => s.key === key);
  if (!section) {
    return undefined;
  }
  const titles = section.titleIds
    .map((id) => TITLES_BY_ID.get(id))
    .filter((t): t is Title => t !== undefined)
    .slice(0, section.maxItems);
  return {
    key: section.key,
    label: section.label,
    maxItems: section.maxItems,
    titles,
  };
}

export function getAllSections(): ResolvedHomeSection[] {
  return HOME_SECTIONS.map((s) => getSection(s.key)).filter(
    (s): s is ResolvedHomeSection => s !== undefined
  );
}

function sortLatestFirst(titles: Title[]): Title[] {
  return titles.slice().sort((a, b) => {
    if (b.year !== a.year) {
      return b.year - a.year;
    }
    return a.id.localeCompare(b.id);
  });
}

function matchesEither<T extends string>(
  value: T,
  selection: T | readonly T[] | undefined
): boolean {
  if (selection === undefined) return true;
  if (typeof selection === "string") return value === selection;
  return selection.length === 0 || selection.includes(value);
}

export function filterTitles(selection: FilterSelection = {}): Title[] {
  const { country, genre, platform, keyword } = selection;
  const lowered = keyword?.trim().toLowerCase() ?? "";
  const matched = TITLES.filter((t) => {
    if (!matchesEither(t.country, country)) return false;
    if (!matchesEither(t.genre, genre)) return false;
    if (!matchesEither(t.platform, platform)) return false;
    if (lowered) {
      const haystack = `${t.title} ${t.cast.join(" ")}`.toLowerCase();
      if (!haystack.includes(lowered)) return false;
    }
    return true;
  });
  return sortLatestFirst(matched);
}

export function searchTitles(keyword: string): Title[] {
  return filterTitles({ keyword });
}
