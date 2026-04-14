import { NextRequest } from "next/server";
import { getReviewById, updateReview, deleteReview } from "@/lib/reviews";
import { validateUpdateInput } from "@/lib/validate";

type RouteContext = { params: Promise<{ id: string }> };

export async function GET(
  _request: NextRequest,
  { params }: RouteContext
) {
  const { id } = await params;
  const review = getReviewById(Number(id));

  if (!review) {
    return Response.json({ error: "not found" }, { status: 404 });
  }

  return Response.json(review);
}

export async function PUT(
  request: NextRequest,
  { params }: RouteContext
) {
  const { id } = await params;
  const body = await request.json();
  const errors = validateUpdateInput(body);

  if (errors.length > 0) {
    return Response.json({ errors }, { status: 400 });
  }

  const review = updateReview(Number(id), {
    title: body.title?.trim(),
    rating: body.rating,
    short_review: body.short_review,
    detail_review: body.detail_review,
    watched_date: body.watched_date,
  });

  if (!review) {
    return Response.json({ error: "not found" }, { status: 404 });
  }

  return Response.json(review);
}

export async function DELETE(
  _request: NextRequest,
  { params }: RouteContext
) {
  const { id } = await params;
  const deleted = deleteReview(Number(id));

  if (!deleted) {
    return Response.json({ error: "not found" }, { status: 404 });
  }

  return Response.json({ success: true });
}
