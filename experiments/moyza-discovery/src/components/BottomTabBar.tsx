"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { getSurveyUrl } from "@/lib/env";

export function BottomTabBar() {
  const pathname = usePathname() ?? "/";
  const isHome = pathname === "/";
  const isSearch = pathname.startsWith("/search");
  const surveyUrl = getSurveyUrl();

  return (
    <nav className="bottom-tabs" data-testid="bottom-tabs" aria-label="Primary">
      <Link
        href="/"
        data-testid="tab-home"
        className={`bottom-tabs__item${isHome ? " is-active" : ""}`}
        aria-current={isHome ? "page" : undefined}
      >
        <span aria-hidden>🏠</span>
        <span>Home</span>
      </Link>
      <Link
        href="/search"
        data-testid="tab-event"
        className={`bottom-tabs__item${isSearch ? " is-active" : ""}`}
        aria-current={isSearch ? "page" : undefined}
      >
        <span aria-hidden>🔍</span>
        <span>Event</span>
      </Link>
      <a
        href={surveyUrl}
        target="_blank"
        rel="noopener noreferrer"
        data-testid="tab-board"
        className="bottom-tabs__item"
      >
        <span aria-hidden>📋</span>
        <span>Board</span>
      </a>
    </nav>
  );
}
