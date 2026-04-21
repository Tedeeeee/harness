import { render, screen, within } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import HomePage from "../../app/page";
import { BottomTabBar } from "@/components/BottomTabBar";
import { SurveyBanner } from "@/components/SurveyBanner";

const ORIGINAL_ENV = { ...process.env };

beforeEach(() => {
  process.env = { ...ORIGINAL_ENV };
});

describe("HomePage", () => {
  it("renders the three home sections in the required order", () => {
    render(<HomePage />);
    const main = screen.getByTestId("home-main");
    const sections = within(main).getAllByTestId(/^section-/);
    expect(sections.map((el) => el.getAttribute("data-testid"))).toEqual([
      "section-new-releases",
      "section-popular-picks",
      "section-korea-picks",
    ]);
  });

  it("renders each section with a visible label and at least one poster", () => {
    render(<HomePage />);
    for (const label of ["업데이트된 신작", "인기작 픽", "코리아 픽"]) {
      const heading = screen.getByRole("heading", { name: label });
      const section = heading.closest("section")!;
      expect(within(section).getAllByTestId("poster-card").length).toBeGreaterThan(0);
    }
  });

  it("exposes the survey banner at the top of the page", () => {
    render(<HomePage />);
    const banner = screen.getByTestId("survey-banner-home");
    expect(banner).toHaveAttribute("target", "_blank");
    expect(banner).toHaveAttribute("rel", expect.stringContaining("noopener"));
  });
});

describe("SurveyBanner URL behavior", () => {
  it("falls back to placeholder URL when env var is unset", () => {
    delete process.env.NEXT_PUBLIC_SURVEY_URL;
    render(<SurveyBanner />);
    expect(screen.getByTestId("survey-banner-home")).toHaveAttribute(
      "href",
      "https://example.invalid/survey"
    );
  });

  it("uses NEXT_PUBLIC_SURVEY_URL when present", async () => {
    vi.resetModules();
    process.env.NEXT_PUBLIC_SURVEY_URL = "https://forms.invalid/x";
    const { SurveyBanner: Fresh } = await import("@/components/SurveyBanner");
    render(<Fresh />);
    expect(screen.getByTestId("survey-banner-home")).toHaveAttribute(
      "href",
      "https://forms.invalid/x"
    );
  });
});

describe("BottomTabBar", () => {
  it("contains exactly three tabs: Home, Event, Board (no Account)", () => {
    render(<BottomTabBar />);
    const bar = screen.getByTestId("bottom-tabs");
    const items = within(bar).getAllByTestId(/^tab-/);
    expect(items.map((el) => el.getAttribute("data-testid"))).toEqual([
      "tab-home",
      "tab-event",
      "tab-board",
    ]);
    expect(within(bar).queryByText(/account/i)).toBeNull();
  });

  it("Event tab links to /search", () => {
    render(<BottomTabBar />);
    expect(screen.getByTestId("tab-event")).toHaveAttribute("href", "/search");
  });

  it("Board tab points to the survey URL and opens in a new tab", () => {
    render(<BottomTabBar />);
    const board = screen.getByTestId("tab-board");
    expect(board).toHaveAttribute("target", "_blank");
    expect(board.getAttribute("href")?.length).toBeGreaterThan(0);
  });
});
