"use client";

import { useRouter } from "next/navigation";
import type { Title } from "@/data/types";

export function HeroSection({ title }: { title: Title }) {
  const router = useRouter();

  return (
    <section className="hero" data-testid="detail-hero">
      <div className="hero__topbar">
        <button
          type="button"
          aria-label="Back"
          data-testid="detail-back"
          className="hero__icon"
          onClick={() => router.back()}
        >
          ‹
        </button>
        <div className="hero__topbar-actions">
          <button
            type="button"
            aria-label="Search"
            data-testid="detail-search"
            className="hero__icon"
            onClick={() => router.push("/search")}
          >
            🔍
          </button>
          {/* 공유 아이콘은 PDF 변경 지시에 따라 렌더하지 않는다 */}
        </div>
      </div>
      <div className="hero__poster" aria-hidden />
      <div className="hero__title">{title.title}</div>
      <div className="hero__rating">★ {title.rating.toFixed(1)}</div>
    </section>
  );
}
