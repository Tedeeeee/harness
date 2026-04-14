import { describe, it, expect, beforeEach } from "vitest";
import {
  createReview,
  getReviewById,
  listReviews,
  updateReview,
  deleteReview,
} from "@/lib/reviews";
import { getDb } from "@/lib/db";
import { validateCreateInput, validateUpdateInput } from "@/lib/validate";

beforeEach(() => {
  const db = getDb();
  db.exec("DELETE FROM reviews");
});

describe("createReview", () => {
  it("creates a review and returns it with an id", () => {
    const review = createReview({
      title: "Inception",
      rating: 5,
      short_review: "Mind-bending",
      watched_date: "2026-04-10",
    });
    expect(review.id).toBeGreaterThan(0);
    expect(review.title).toBe("Inception");
    expect(review.rating).toBe(5);
    expect(review.watched_date).toBe("2026-04-10");
  });
});

describe("getReviewById", () => {
  it("returns the review for a valid id", () => {
    const created = createReview({
      title: "Dune",
      rating: 4,
      watched_date: "2026-04-05",
    });
    const found = getReviewById(created.id);
    expect(found).toBeDefined();
    expect(found!.title).toBe("Dune");
  });

  it("returns undefined for a non-existent id", () => {
    expect(getReviewById(9999)).toBeUndefined();
  });
});

describe("listReviews", () => {
  beforeEach(() => {
    createReview({ title: "A Film", rating: 3, watched_date: "2026-03-01" });
    createReview({ title: "B Film", rating: 5, watched_date: "2026-04-01" });
    createReview({ title: "C Film", rating: 1, watched_date: "2026-02-01" });
  });

  it("returns all reviews by default (sorted by latest desc)", () => {
    const reviews = listReviews({});
    expect(reviews).toHaveLength(3);
    // default sort: watched_date DESC
    expect(reviews[0].title).toBe("B Film");
  });

  it("filters by rating_min", () => {
    const reviews = listReviews({ rating_min: 4 });
    expect(reviews).toHaveLength(1);
    expect(reviews[0].title).toBe("B Film");
  });

  it("filters by rating_max", () => {
    const reviews = listReviews({ rating_max: 3 });
    expect(reviews).toHaveLength(2);
  });

  it("filters by date range", () => {
    const reviews = listReviews({
      date_from: "2026-03-01",
      date_to: "2026-03-31",
    });
    expect(reviews).toHaveLength(1);
    expect(reviews[0].title).toBe("A Film");
  });

  it("sorts by title ascending", () => {
    const reviews = listReviews({ sort: "title", order: "asc" });
    expect(reviews[0].title).toBe("A Film");
    expect(reviews[2].title).toBe("C Film");
  });

  it("sorts by rating descending", () => {
    const reviews = listReviews({ sort: "rating", order: "desc" });
    expect(reviews[0].rating).toBe(5);
    expect(reviews[2].rating).toBe(1);
  });
});

describe("updateReview", () => {
  it("updates specified fields only", () => {
    const created = createReview({
      title: "Old Title",
      rating: 3,
      watched_date: "2026-01-01",
    });
    const updated = updateReview(created.id, { rating: 5 });
    expect(updated!.rating).toBe(5);
    expect(updated!.title).toBe("Old Title");
  });

  it("returns undefined for a non-existent id", () => {
    expect(updateReview(9999, { rating: 1 })).toBeUndefined();
  });
});

describe("deleteReview", () => {
  it("deletes an existing review", () => {
    const created = createReview({
      title: "To Delete",
      rating: 2,
      watched_date: "2026-01-01",
    });
    expect(deleteReview(created.id)).toBe(true);
    expect(getReviewById(created.id)).toBeUndefined();
  });

  it("returns false for a non-existent id", () => {
    expect(deleteReview(9999)).toBe(false);
  });
});

describe("validateCreateInput", () => {
  it("returns errors for missing fields", () => {
    const errors = validateCreateInput({});
    expect(errors.length).toBeGreaterThanOrEqual(3);
  });

  it("returns error for invalid rating", () => {
    const errors = validateCreateInput({
      title: "Test",
      rating: 6,
      watched_date: "2026-01-01",
    });
    expect(errors).toHaveLength(1);
    expect(errors[0].field).toBe("rating");
  });

  it("returns error for bad date format", () => {
    const errors = validateCreateInput({
      title: "Test",
      rating: 3,
      watched_date: "04/01/2026",
    });
    expect(errors).toHaveLength(1);
    expect(errors[0].field).toBe("watched_date");
  });

  it("returns empty array for valid input", () => {
    const errors = validateCreateInput({
      title: "Test",
      rating: 3,
      watched_date: "2026-01-01",
    });
    expect(errors).toHaveLength(0);
  });
});

describe("validateUpdateInput", () => {
  it("returns empty for empty body (no update fields)", () => {
    expect(validateUpdateInput({})).toHaveLength(0);
  });

  it("validates rating when present", () => {
    const errors = validateUpdateInput({ rating: 0 });
    expect(errors).toHaveLength(1);
  });
});
