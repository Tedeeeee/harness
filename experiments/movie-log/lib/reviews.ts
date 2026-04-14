import { getDb } from "./db";

export interface Review {
  id: number;
  title: string;
  rating: number;
  short_review: string;
  detail_review: string;
  watched_date: string;
  created_at: string;
  updated_at: string;
}

export interface CreateReviewInput {
  title: string;
  rating: number;
  short_review?: string;
  detail_review?: string;
  watched_date: string;
}

export interface UpdateReviewInput {
  title?: string;
  rating?: number;
  short_review?: string;
  detail_review?: string;
  watched_date?: string;
}

export interface ListParams {
  rating_min?: number;
  rating_max?: number;
  date_from?: string;
  date_to?: string;
  sort?: "latest" | "rating" | "title";
  order?: "asc" | "desc";
}

export function createReview(input: CreateReviewInput): Review {
  const db = getDb();
  const stmt = db.prepare(`
    INSERT INTO reviews (title, rating, short_review, detail_review, watched_date)
    VALUES (@title, @rating, @short_review, @detail_review, @watched_date)
  `);
  const result = stmt.run({
    title: input.title,
    rating: input.rating,
    short_review: input.short_review ?? "",
    detail_review: input.detail_review ?? "",
    watched_date: input.watched_date,
  });
  return getReviewById(Number(result.lastInsertRowid))!;
}

export function getReviewById(id: number): Review | undefined {
  const db = getDb();
  return db.prepare("SELECT * FROM reviews WHERE id = ?").get(id) as
    | Review
    | undefined;
}

export function listReviews(params: ListParams): Review[] {
  const db = getDb();
  const conditions: string[] = [];
  const values: Record<string, unknown> = {};

  if (params.rating_min !== undefined) {
    conditions.push("rating >= @rating_min");
    values.rating_min = params.rating_min;
  }
  if (params.rating_max !== undefined) {
    conditions.push("rating <= @rating_max");
    values.rating_max = params.rating_max;
  }
  if (params.date_from) {
    conditions.push("watched_date >= @date_from");
    values.date_from = params.date_from;
  }
  if (params.date_to) {
    conditions.push("watched_date <= @date_to");
    values.date_to = params.date_to;
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const sortColumn =
    params.sort === "rating"
      ? "rating"
      : params.sort === "title"
        ? "title"
        : "watched_date";
  const sortOrder = params.order === "asc" ? "ASC" : "DESC";

  const sql = `SELECT * FROM reviews ${where} ORDER BY ${sortColumn} ${sortOrder}`;
  return db.prepare(sql).all(values) as Review[];
}

export function updateReview(
  id: number,
  input: UpdateReviewInput
): Review | undefined {
  const existing = getReviewById(id);
  if (!existing) return undefined;

  const db = getDb();
  const fields: string[] = [];
  const values: Record<string, unknown> = { id };

  if (input.title !== undefined) {
    fields.push("title = @title");
    values.title = input.title;
  }
  if (input.rating !== undefined) {
    fields.push("rating = @rating");
    values.rating = input.rating;
  }
  if (input.short_review !== undefined) {
    fields.push("short_review = @short_review");
    values.short_review = input.short_review;
  }
  if (input.detail_review !== undefined) {
    fields.push("detail_review = @detail_review");
    values.detail_review = input.detail_review;
  }
  if (input.watched_date !== undefined) {
    fields.push("watched_date = @watched_date");
    values.watched_date = input.watched_date;
  }

  if (fields.length === 0) return existing;

  fields.push("updated_at = datetime('now', 'localtime')");

  db.prepare(`UPDATE reviews SET ${fields.join(", ")} WHERE id = @id`).run(
    values
  );
  return getReviewById(id);
}

export function deleteReview(id: number): boolean {
  const db = getDb();
  const result = db.prepare("DELETE FROM reviews WHERE id = ?").run(id);
  return result.changes > 0;
}
