export interface ValidationError {
  field: string;
  message: string;
}

export function validateCreateInput(body: Record<string, unknown>): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!body.title || typeof body.title !== "string" || body.title.trim() === "") {
    errors.push({ field: "title", message: "title is required" });
  }

  if (body.rating === undefined || body.rating === null) {
    errors.push({ field: "rating", message: "rating is required" });
  } else if (
    typeof body.rating !== "number" ||
    !Number.isInteger(body.rating) ||
    body.rating < 1 ||
    body.rating > 5
  ) {
    errors.push({ field: "rating", message: "rating must be an integer between 1 and 5" });
  }

  if (!body.watched_date || typeof body.watched_date !== "string") {
    errors.push({ field: "watched_date", message: "watched_date is required" });
  } else if (!/^\d{4}-\d{2}-\d{2}$/.test(body.watched_date)) {
    errors.push({ field: "watched_date", message: "watched_date must be YYYY-MM-DD format" });
  }

  return errors;
}

export function validateUpdateInput(body: Record<string, unknown>): ValidationError[] {
  const errors: ValidationError[] = [];

  if (body.title !== undefined && (typeof body.title !== "string" || body.title.trim() === "")) {
    errors.push({ field: "title", message: "title must be a non-empty string" });
  }

  if (body.rating !== undefined) {
    if (
      typeof body.rating !== "number" ||
      !Number.isInteger(body.rating) ||
      body.rating < 1 ||
      body.rating > 5
    ) {
      errors.push({ field: "rating", message: "rating must be an integer between 1 and 5" });
    }
  }

  if (body.watched_date !== undefined) {
    if (typeof body.watched_date !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(body.watched_date)) {
      errors.push({ field: "watched_date", message: "watched_date must be YYYY-MM-DD format" });
    }
  }

  return errors;
}
