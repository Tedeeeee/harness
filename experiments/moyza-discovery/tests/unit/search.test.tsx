import { fireEvent, render, screen, within } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import SearchPage from "../../app/search/page";
import { filterTitles } from "@/data/accessors";

describe("SearchPage filtering", () => {
  it("lists all titles on first render when no query is set", () => {
    render(<SearchPage />);
    const count = screen.getByTestId("results-count").textContent ?? "0";
    expect(Number(count)).toBe(filterTitles().length);
  });

  it("narrows results with combined Country + Genre + Platform selections", () => {
    render(<SearchPage />);
    const initial = Number(screen.getByTestId("results-count").textContent ?? "0");

    fireEvent.click(screen.getByTestId("filter-country-Korea"));
    fireEvent.click(screen.getByTestId("filter-genre-Romance"));
    fireEvent.click(screen.getByTestId("filter-platform-A"));

    const narrowed = Number(screen.getByTestId("results-count").textContent ?? "0");
    expect(narrowed).toBeLessThan(initial);
    const expected = filterTitles({
      country: "Korea",
      genre: "Romance",
      platform: "A",
    }).length;
    expect(narrowed).toBe(expected);
  });

  it("allows multiple chips within a single category (OR within, AND across)", () => {
    render(<SearchPage />);
    fireEvent.click(screen.getByTestId("filter-genre-Romance"));
    fireEvent.click(screen.getByTestId("filter-genre-Comedy"));
    const both = Number(screen.getByTestId("results-count").textContent ?? "0");
    const expected = filterTitles({ genre: ["Romance", "Comedy"] }).length;
    expect(both).toBe(expected);
  });

  it("renders zero results when no title matches the combo", () => {
    render(<SearchPage />);
    fireEvent.click(screen.getByTestId("filter-country-Japan"));
    fireEvent.click(screen.getByTestId("filter-genre-Horror"));
    expect(screen.getByTestId("results-count").textContent).toBe("0");
    expect(screen.getByTestId("results-empty")).toBeInTheDocument();
  });
});

describe("Result cards", () => {
  it("link to /titles/{id}", () => {
    render(<SearchPage />);
    const grid = screen.getByTestId("results-grid");
    const first = within(grid).getAllByTestId("result-card")[0];
    const href = first.getAttribute("href") ?? "";
    expect(href).toMatch(/^\/titles\/t-\d{2}$/);
  });
});

describe("Platform chip style", () => {
  it("uses text-only chip variant", () => {
    render(<SearchPage />);
    const chip = screen.getByTestId("filter-platform-A");
    expect(chip.className).toContain("chip--text");
    expect(chip.className).not.toContain("chip--pill");
  });
});
