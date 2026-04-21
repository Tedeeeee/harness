"use client";

import { useSearchParams } from "next/navigation";
import { Suspense, useMemo, useState } from "react";
import { BottomTabBar } from "@/components/BottomTabBar";
import { FilterBar } from "@/components/FilterBar";
import { FilterHeader } from "@/components/FilterHeader";
import { ResultsGrid } from "@/components/ResultsGrid";
import { SortDropdown } from "@/components/SortDropdown";
import { filterTitles } from "@/data/accessors";
import type { Country, Genre, Platform } from "@/data/types";

function SearchPageContent() {
  const searchParams = useSearchParams();
  const initialKeyword = searchParams?.get("q") ?? "";

  const [keyword, setKeyword] = useState(initialKeyword);
  const [countries, setCountries] = useState<readonly Country[]>([]);
  const [genres, setGenres] = useState<readonly Genre[]>([]);
  const [platforms, setPlatforms] = useState<readonly Platform[]>([]);

  const results = useMemo(
    () =>
      filterTitles({
        country: countries,
        genre: genres,
        platform: platforms,
        keyword,
      }),
    [countries, genres, platforms, keyword]
  );

  return (
    <div className="app-shell search-shell">
      <FilterHeader value={keyword} onChange={setKeyword} />
      <FilterBar
        countries={countries}
        genres={genres}
        platforms={platforms}
        onCountriesChange={setCountries}
        onGenresChange={setGenres}
        onPlatformsChange={setPlatforms}
      />
      <div className="search-meta">
        <span>
          Results <strong data-testid="results-count">{results.length}</strong>
        </span>
        <SortDropdown />
      </div>
      <ResultsGrid titles={results} />
      <BottomTabBar />
    </div>
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={null}>
      <SearchPageContent />
    </Suspense>
  );
}
