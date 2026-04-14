"use client";

import StarRating from "./StarRating";

interface ReviewCardProps {
  id: number;
  title: string;
  rating: number;
  short_review: string;
  watched_date: string;
  onEdit: (id: number) => void;
  onDelete: (id: number) => void;
}

export default function ReviewCard({
  id,
  title,
  rating,
  short_review,
  watched_date,
  onEdit,
  onDelete,
}: ReviewCardProps) {
  return (
    <div className="border border-gray-200 rounded-lg p-4 flex flex-col gap-2">
      <div className="flex items-start justify-between gap-2">
        <h3 className="text-lg font-semibold text-gray-900 leading-tight">
          {title}
        </h3>
        <span className="text-sm text-gray-500 whitespace-nowrap">
          {watched_date}
        </span>
      </div>
      <StarRating value={rating} readonly />
      {short_review && (
        <p className="text-gray-600 text-sm">{short_review}</p>
      )}
      <div className="flex gap-2 mt-2">
        <button
          onClick={() => onEdit(id)}
          className="text-sm px-3 py-1 rounded border border-gray-300 text-gray-700 hover:bg-gray-50"
        >
          Edit
        </button>
        <button
          onClick={() => onDelete(id)}
          className="text-sm px-3 py-1 rounded border border-red-300 text-red-600 hover:bg-red-50"
        >
          Delete
        </button>
      </div>
    </div>
  );
}
