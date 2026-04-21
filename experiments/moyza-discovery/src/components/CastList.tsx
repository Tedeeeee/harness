import type { Title } from "@/data/types";

export function CastList({ title }: { title: Title }) {
  return (
    <section
      id="detail-section-cast"
      className="detail-section cast-list"
      data-testid="cast-list"
    >
      <header className="detail-section__header">
        <h2>Cast</h2>
      </header>
      <ul className="cast-list__items">
        {title.cast.map((name) => (
          <li key={name} className="cast-list__item" data-testid="cast-item">
            <span className="cast-list__avatar" aria-hidden />
            <span className="cast-list__name">{name}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
