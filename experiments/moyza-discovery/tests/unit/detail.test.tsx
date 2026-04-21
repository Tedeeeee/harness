import { fireEvent, render, screen, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { HeroSection } from "@/components/HeroSection";
import { SynopsisPanel } from "@/components/SynopsisPanel";
import { CastList } from "@/components/CastList";
import { WatchNowBar } from "@/components/WatchNowBar";
import { PlatformBadges } from "@/components/PlatformBadges";
import { SimilarSection } from "@/components/SimilarSection";
import { DetailTabs } from "@/components/DetailTabs";
import { getTitleById } from "@/data/accessors";

const ORIGINAL_ENV = { ...process.env };
const TITLE = getTitleById("t-08")!; // 레이디 두아

beforeEach(() => {
  process.env = { ...ORIGINAL_ENV };
});

afterEach(() => {
  process.env = { ...ORIGINAL_ENV };
});

describe("HeroSection", () => {
  it("renders title, rating, back, and search — but no share icon", () => {
    render(<HeroSection title={TITLE} />);
    expect(screen.getByTestId("detail-back")).toBeInTheDocument();
    expect(screen.getByTestId("detail-search")).toBeInTheDocument();
    expect(screen.queryByLabelText(/share/i)).toBeNull();
    expect(screen.getByText(TITLE.title)).toBeInTheDocument();
    expect(screen.getByText(/★\s5\.0/)).toBeInTheDocument();
  });
});

describe("SynopsisPanel", () => {
  it("renders collapsed by default with meta chips", () => {
    render(<SynopsisPanel title={TITLE} />);
    expect(screen.getByTestId("meta-chips")).toBeInTheDocument();
    expect(screen.queryByTestId("synopsis-expanded")).toBeNull();
  });

  it("expands meta table on More and collapses on View Summary", () => {
    render(<SynopsisPanel title={TITLE} />);
    fireEvent.click(screen.getByTestId("synopsis-more"));
    expect(screen.getByTestId("meta-table")).toBeInTheDocument();
    fireEvent.click(screen.getByTestId("view-summary"));
    expect(screen.queryByTestId("synopsis-expanded")).toBeNull();
  });
});

describe("PlatformBadges flag", () => {
  it("does not render when NEXT_PUBLIC_SHOW_PLATFORM_BADGES is unset", async () => {
    delete process.env.NEXT_PUBLIC_SHOW_PLATFORM_BADGES;
    const { rerender } = render(<PlatformBadges />);
    expect(screen.queryByTestId("platform-badges")).toBeNull();
    rerender(<PlatformBadges />);
    expect(screen.queryByTestId("platform-badges")).toBeNull();
  });

  it("renders when flag is 'true'", async () => {
    process.env.NEXT_PUBLIC_SHOW_PLATFORM_BADGES = "true";
    const mod = await import("@/components/PlatformBadges");
    render(<mod.PlatformBadges />);
    expect(screen.getByTestId("platform-badges")).toBeInTheDocument();
  });
});

describe("CastList", () => {
  it("renders each cast as name-only without role labels", () => {
    render(<CastList title={TITLE} />);
    const items = screen.getAllByTestId("cast-item");
    expect(items.length).toBe(TITLE.cast.length);
    for (const item of items) {
      expect(within(item).queryByText(/lead cast/i)).toBeNull();
      expect(within(item).queryByText(/supporting/i)).toBeNull();
    }
  });
});

describe("WatchNowBar", () => {
  it("uses externalUrl, target=_blank, and excludes heart icon", () => {
    render(<WatchNowBar title={TITLE} />);
    const bar = screen.getByTestId("watch-now-bar");
    const link = screen.getByTestId("watch-now-link");
    expect(link).toHaveAttribute("href", TITLE.externalUrl);
    expect(link).toHaveAttribute("target", "_blank");
    expect(within(bar).queryByLabelText(/favorite|heart|좋아요|찜/i)).toBeNull();
    // text content does not contain an emoji heart
    expect(bar.textContent?.includes("❤")).toBe(false);
    expect(bar.textContent?.includes("♥")).toBe(false);
  });
});

describe("SimilarSection", () => {
  it("links similar cards to /titles/{id}", () => {
    render(<SimilarSection title={TITLE} />);
    const cards = screen.getAllByTestId("similar-card");
    expect(cards.length).toBeGreaterThan(0);
    for (const card of cards) {
      expect(card.getAttribute("href")).toMatch(/^\/titles\/t-\d{2}$/);
    }
  });
});

describe("DetailTabs", () => {
  it("renders 3 tabs with Synopsis active by default", () => {
    render(<DetailTabs />);
    const tabs = screen.getAllByRole("tab");
    expect(tabs).toHaveLength(3);
    expect(screen.getByTestId("detail-tab-synopsis")).toHaveAttribute(
      "aria-selected",
      "true"
    );
  });

  it("switches aria-selected on click", () => {
    render(<DetailTabs />);
    fireEvent.click(screen.getByTestId("detail-tab-cast"));
    expect(screen.getByTestId("detail-tab-cast")).toHaveAttribute(
      "aria-selected",
      "true"
    );
  });
});
