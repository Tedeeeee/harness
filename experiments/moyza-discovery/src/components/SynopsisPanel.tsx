"use client";

import { useState } from "react";
import type { Title } from "@/data/types";
import { MetaTable } from "./MetaTable";
import { PlatformBadges } from "./PlatformBadges";
import { SurveyBanner } from "./SurveyBanner";

export function SynopsisPanel({ title }: { title: Title }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <section
      id="detail-section-synopsis"
      className="detail-section synopsis-panel"
      data-testid="synopsis-panel"
    >
      <header className="detail-section__header">
        <h2>Synopsis</h2>
      </header>
      <p className="synopsis-panel__body">{title.synopsis}</p>
      <div className="synopsis-panel__meta-chips" data-testid="meta-chips">
        <span className="chip chip--pill chip--age">{title.ageRating}</span>
        <span className="chip--muted">{title.year}</span>
        <span className="chip--muted">{title.episodes} EP</span>
        <span className="chip--muted">{title.genre}</span>
        <button
          type="button"
          className="chip--link"
          data-testid="synopsis-more"
          aria-expanded={expanded}
          onClick={() => setExpanded((prev) => !prev)}
        >
          {expanded ? "Less" : "More"}
        </button>
      </div>
      <PlatformBadges />
      {expanded ? (
        <div className="synopsis-panel__expanded" data-testid="synopsis-expanded">
          <MetaTable title={title} />
          <button
            type="button"
            className="view-summary"
            data-testid="view-summary"
            onClick={() => setExpanded(false)}
          >
            View Summary ∧
          </button>
        </div>
      ) : null}
      <SurveyBanner variant="detail" />
    </section>
  );
}
