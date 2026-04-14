import { NextRequest } from "next/server";
import { createReview, listReviews, type ListParams } from "@/lib/reviews";
import { validateCreateInput } from "@/lib/validate";

export async function GET(request: NextRequest) {
  const url = request.nextUrl;
  const params: ListParams = {};

  const ratingMin = url.searchParams.get("rating_min");
  const ratingMax = url.searchParams.get("rating_max");
  const dateFrom = url.searchParams.get("date_from");
  const dateTo = url.searchParams.get("date_to");
  const sort = url.searchParams.get("sort");
  const order = url.searchParams.get("order");

  if (ratingMin) params.rating_min = Number(ratingMin);
  if (ratingMax) params.rating_max = Number(ratingMax);
  if (dateFrom) params.date_from = dateFrom;
  if (dateTo) params.date_to = dateTo;
  if (sort === "latest" || sort === "rating" || sort === "title") {
    params.sort = sort;
  }
  if (order === "asc" || order === "desc") {
    params.order = order;
  }

  const reviews = listReviews(params);
  return Response.json(reviews);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const errors = validateCreateInput(body);

  if (errors.length > 0) {
    return Response.json({ errors }, { status: 400 });
  }

  const review = createReview({
    title: body.title.trim(),
    rating: body.rating,
    short_review: body.short_review ?? "",
    detail_review: body.detail_review ?? "",
    watched_date: body.watched_date,
  });

  return Response.json(review, { status: 201 });
}
