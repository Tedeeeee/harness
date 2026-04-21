"use client";

import { useState } from "react";

const TABS = [
  { key: "synopsis", label: "Synopsis" },
  { key: "cast", label: "Cast" },
  { key: "similar", label: "Similar" },
] as const;

export type DetailTabKey = (typeof TABS)[number]["key"];

export function DetailTabs({
  onSelect,
}: {
  onSelect?: (key: DetailTabKey) => void;
}) {
  const [active, setActive] = useState<DetailTabKey>("synopsis");

  const handle = (key: DetailTabKey) => {
    setActive(key);
    onSelect?.(key);
    if (typeof document !== "undefined") {
      const target = document.getElementById(`detail-section-${key}`);
      target?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  return (
    <nav className="detail-tabs" data-testid="detail-tabs" role="tablist">
      {TABS.map((tab) => (
        <button
          key={tab.key}
          type="button"
          role="tab"
          aria-selected={active === tab.key}
          data-testid={`detail-tab-${tab.key}`}
          className={`detail-tabs__item${active === tab.key ? " is-active" : ""}`}
          onClick={() => handle(tab.key)}
        >
          {tab.label}
        </button>
      ))}
    </nav>
  );
}
