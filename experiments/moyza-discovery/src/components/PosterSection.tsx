import type { ResolvedHomeSection } from "@/data/types";
import { PosterCard } from "./PosterCard";

export function PosterSection({ section }: { section: ResolvedHomeSection }) {
  return (
    <section
      className="poster-section"
      data-testid={`section-${section.key}`}
    >
      <h2 className="poster-section__label">{section.label}</h2>
      <div className="poster-section__row">
        {section.titles.map((title) => (
          <PosterCard key={title.id} title={title} />
        ))}
      </div>
    </section>
  );
}
