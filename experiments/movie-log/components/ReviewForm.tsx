"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import StarRating from "./StarRating";

interface ReviewFormProps {
  initialData?: {
    id: number;
    title: string;
    rating: number;
    short_review: string;
    detail_review: string;
    watched_date: string;
  };
}

export default function ReviewForm({ initialData }: ReviewFormProps) {
  const router = useRouter();
  const isEdit = !!initialData;

  const [title, setTitle] = useState(initialData?.title ?? "");
  const [rating, setRating] = useState(initialData?.rating ?? 0);
  const [shortReview, setShortReview] = useState(
    initialData?.short_review ?? ""
  );
  const [detailReview, setDetailReview] = useState(
    initialData?.detail_review ?? ""
  );
  const [watchedDate, setWatchedDate] = useState(
    initialData?.watched_date ?? new Date().toISOString().slice(0, 10)
  );
  const [errors, setErrors] = useState<string[]>([]);
  const [saving, setSaving] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErrors([]);

    const validationErrors: string[] = [];
    if (!title.trim()) validationErrors.push("Title is required");
    if (rating < 1 || rating > 5) validationErrors.push("Select a rating (1-5)");
    if (!watchedDate) validationErrors.push("Watched date is required");

    if (validationErrors.length > 0) {
      setErrors(validationErrors);
      return;
    }

    setSaving(true);
    const body = {
      title: title.trim(),
      rating,
      short_review: shortReview,
      detail_review: detailReview,
      watched_date: watchedDate,
    };

    const url = isEdit
      ? `/api/reviews/${initialData.id}`
      : "/api/reviews";
    const method = isEdit ? "PUT" : "POST";

    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      const data = await res.json();
      setErrors(
        data.errors?.map((e: { message: string }) => e.message) ?? [
          "Failed to save",
        ]
      );
      setSaving(false);
      return;
    }

    router.push("/");
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-lg">
      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded p-3">
          {errors.map((err, i) => (
            <p key={i} className="text-red-600 text-sm">
              {err}
            </p>
          ))}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Title
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
          placeholder="Movie title"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Rating
        </label>
        <StarRating value={rating} onChange={setRating} />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Watched Date
        </label>
        <input
          type="date"
          value={watchedDate}
          onChange={(e) => setWatchedDate(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Short Review
        </label>
        <input
          type="text"
          value={shortReview}
          onChange={(e) => setShortReview(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
          placeholder="One line summary"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Detail Review
        </label>
        <textarea
          value={detailReview}
          onChange={(e) => setDetailReview(e.target.value)}
          rows={5}
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
          placeholder="Detailed thoughts..."
        />
      </div>

      <div className="flex gap-3">
        <button
          type="submit"
          disabled={saving}
          className="px-4 py-2 bg-black text-white rounded text-sm hover:bg-gray-800 disabled:opacity-50"
        >
          {saving ? "Saving..." : isEdit ? "Update" : "Create"}
        </button>
        <button
          type="button"
          onClick={() => router.back()}
          className="px-4 py-2 border border-gray-300 rounded text-sm text-gray-700 hover:bg-gray-50"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
