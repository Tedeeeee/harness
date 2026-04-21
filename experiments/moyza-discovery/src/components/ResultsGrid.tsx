import Link from "next/link";
import type { Title } from "@/data/types";

export function ResultsGrid({ titles }: { titles: readonly Title[] }) {
  if (titles.length === 0) {
    return (
      <div className="results-empty" data-testid="results-empty">
        일치하는 결과가 없습니다.
      </div>
    );
  }

  return (
    <div className="results-grid" data-testid="results-grid">
      {titles.map((t) => (
        <Link
          key={t.id}
          href={`/titles/${t.id}`}
          className="result-card"
          data-testid="result-card"
        >
          <div className="result-card__thumb" />
          <div className="result-card__title">{t.title}</div>
        </Link>
      ))}
    </div>
  );
}
