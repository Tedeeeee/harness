import { describe, expect, it } from "vitest";
import { HOME_SECTIONS } from "../home-sections";
import { TITLES } from "../titles";
import {
  filterTitles,
  getAllSections,
  getSection,
  getTitleById,
  searchTitles,
} from "../accessors";

describe("getTitleById", () => {
  it("returns the title for a known id", () => {
    const found = getTitleById("t-01");
    expect(found?.title).toBe("악동 탐정스2");
  });

  it("returns undefined for an unknown id", () => {
    expect(getTitleById("nope")).toBeUndefined();
  });
});

describe("getSection", () => {
  it.each(HOME_SECTIONS.map((s) => s.key))(
    "returns the %s section with resolved titles",
    (key) => {
      const section = getSection(key);
      expect(section).toBeDefined();
      expect(section!.titles.length).toBeGreaterThan(0);
      expect(section!.titles.length).toBeLessThanOrEqual(section!.maxItems);
    }
  );

  it("returns undefined for an unknown section key", () => {
    // @ts-expect-error - intentionally invalid key for runtime safety test
    expect(getSection("does-not-exist")).toBeUndefined();
  });

  it("caps results at maxItems", () => {
    const section = getSection("new-releases");
    expect(section!.titles.length).toBeLessThanOrEqual(6);
  });
});

describe("getAllSections", () => {
  it("returns all three sections in declared order", () => {
    const sections = getAllSections();
    expect(sections.map((s) => s.key)).toEqual([
      "new-releases",
      "popular-picks",
      "korea-picks",
    ]);
  });
});

describe("filterTitles", () => {
  it("returns all titles when no filter supplied", () => {
    const result = filterTitles();
    expect(result).toHaveLength(TITLES.length);
  });

  it("sorts by Latest first (year desc, id asc tiebreak)", () => {
    const result = filterTitles();
    for (let i = 1; i < result.length; i++) {
      const prev = result[i - 1];
      const cur = result[i];
      expect(prev.year).toBeGreaterThanOrEqual(cur.year);
      if (prev.year === cur.year) {
        expect(prev.id.localeCompare(cur.id)).toBeLessThanOrEqual(0);
      }
    }
  });

  it("applies AND across country + genre + platform", () => {
    const result = filterTitles({
      country: "Korea",
      genre: "Romance",
      platform: "A",
    });
    expect(result.length).toBeGreaterThan(0);
    for (const t of result) {
      expect(t.country).toBe("Korea");
      expect(t.genre).toBe("Romance");
      expect(t.platform).toBe("A");
    }
  });

  it("returns empty array when no title matches the combo", () => {
    const result = filterTitles({
      country: "Japan",
      genre: "Horror",
      platform: "A",
    });
    expect(result).toEqual([]);
  });

  it("keyword matches title or cast substring", () => {
    const result = searchTitles("레이디");
    expect(result.some((t) => t.title.includes("레이디"))).toBe(true);

    const byCast = searchTitles("사라 킴");
    expect(byCast.length).toBeGreaterThan(0);
    for (const t of byCast) {
      expect(
        t.title.includes("사라 킴") || t.cast.some((c) => c.includes("사라 킴"))
      ).toBe(true);
    }
  });
});

describe("seed distribution", () => {
  it("has at least 3 distinct countries", () => {
    const countries = new Set(TITLES.map((t) => t.country));
    expect(countries.size).toBeGreaterThanOrEqual(3);
  });

  it("has at least 3 distinct genres", () => {
    const genres = new Set(TITLES.map((t) => t.genre));
    expect(genres.size).toBeGreaterThanOrEqual(3);
  });

  it("has at least 3 distinct platforms", () => {
    const platforms = new Set(TITLES.map((t) => t.platform));
    expect(platforms.size).toBeGreaterThanOrEqual(3);
  });

  it("has 12..20 titles", () => {
    expect(TITLES.length).toBeGreaterThanOrEqual(12);
    expect(TITLES.length).toBeLessThanOrEqual(20);
  });
});

describe("home-sections integrity", () => {
  it("every section id resolves to a real title", () => {
    const knownIds = new Set(TITLES.map((t) => t.id));
    for (const section of HOME_SECTIONS) {
      for (const id of section.titleIds) {
        expect(knownIds.has(id), `unknown id ${id} in section ${section.key}`).toBe(
          true
        );
      }
    }
  });

  it("korea-picks contains only Korean titles", () => {
    const section = getSection("korea-picks")!;
    for (const t of section.titles) {
      expect(t.country).toBe("Korea");
    }
  });
});
