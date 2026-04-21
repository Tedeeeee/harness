import Link from "next/link";
import type { Title } from "@/data/types";

export function PosterCard({ title }: { title: Title }) {
  return (
    <Link
      href={`/titles/${title.id}`}
      className="poster-card"
      data-testid="poster-card"
    >
      <div className="poster-card__thumb">
        {title.isTop ? (
          <span className="poster-card__badge" aria-label="TOP">
            TOP
          </span>
        ) : null}
      </div>
      <div className="poster-card__meta">
        <div className="poster-card__title">{title.title}</div>
        <div className="poster-card__sub">
          {title.episodes} EP · {title.genre}
        </div>
        <div className="poster-card__rating">★ {title.rating.toFixed(1)}</div>
      </div>
    </Link>
  );
}
