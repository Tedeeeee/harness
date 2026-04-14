"use client";

import { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import ReviewForm from "@/components/ReviewForm";

interface Review {
  id: number;
  title: string;
  rating: number;
  short_review: string;
  detail_review: string;
  watched_date: string;
}

export default function EditReviewPage() {
  const params = useParams();
  const id = params.id as string;
  const [review, setReview] = useState<Review | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    fetch(`/api/reviews/${id}`)
      .then((res) => {
        if (!res.ok) throw new Error("not found");
        return res.json();
      })
      .then(setReview)
      .catch(() => setError(true));
  }, [id]);

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="text-gray-500">Review not found.</p>
      </div>
    );
  }

  if (!review) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="text-gray-500">Loading...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-3xl mx-auto px-4 py-4">
          <h1 className="text-xl font-bold text-gray-900">Edit Review</h1>
        </div>
      </header>
      <main className="max-w-3xl mx-auto px-4 py-6">
        <ReviewForm initialData={review} />
      </main>
    </div>
  );
}
