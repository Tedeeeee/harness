import Link from "next/link";
import type { Title } from "@/data/types";
import { getTitleById } from "@/data/accessors";

export function SimilarSection({ title }: { title: Title }) {
  const similar = title.similarIds
    .map((id) => getTitleById(id))
    .filter((t): t is Title => t !== undefined);

  if (similar.length === 0) {
    return null;
  }

  return (
    <section
      id="detail-section-similar"
      className="detail-section similar-section"
      data-testid="similar-section"
    >
      <header className="detail-section__header">
        <h2>Similar</h2>
      </header>
      <div className="similar-section__row">
        {similar.map((s) => (
          <Link
            key={s.id}
            href={`/titles/${s.id}`}
            className="similar-card"
            data-testid="similar-card"
          >
            <div className="similar-card__thumb" aria-hidden />
            <div className="similar-card__title">{s.title}</div>
          </Link>
        ))}
      </div>
    </section>
  );
}
