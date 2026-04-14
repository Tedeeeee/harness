"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import ReviewCard from "@/components/ReviewCard";
import FilterBar from "@/components/FilterBar";

interface Review {
  id: number;
  title: string;
  rating: number;
  short_review: string;
  detail_review: string;
  watched_date: string;
}

export default function Home() {
  const router = useRouter();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);

  const [ratingMin, setRatingMin] = useState("");
  const [ratingMax, setRatingMax] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [sort, setSort] = useState("latest");
  const [order, setOrder] = useState("desc");

  const fetchReviews = useCallback(async () => {
    setLoading(true);
    const params = new URLSearchParams();
    if (ratingMin) params.set("rating_min", ratingMin);
    if (ratingMax) params.set("rating_max", ratingMax);
    if (dateFrom) params.set("date_from", dateFrom);
    if (dateTo) params.set("date_to", dateTo);
    if (sort) params.set("sort", sort);
    if (order) params.set("order", order);

    const res = await fetch(`/api/reviews?${params.toString()}`);
    const data = await res.json();
    setReviews(data);
    setLoading(false);
  }, [ratingMin, ratingMax, dateFrom, dateTo, sort, order]);

  useEffect(() => {
    fetchReviews();
  }, [fetchReviews]);

  function handleFilterChange(key: string, value: string) {
    switch (key) {
      case "rating_min": setRatingMin(value); break;
      case "rating_max": setRatingMax(value); break;
      case "date_from": setDateFrom(value); break;
      case "date_to": setDateTo(value); break;
      case "sort": setSort(value); break;
      case "order": setOrder(value); break;
    }
  }

  function handleReset() {
    setRatingMin("");
    setRatingMax("");
    setDateFrom("");
    setDateTo("");
    setSort("latest");
    setOrder("desc");
  }

  async function handleDelete(id: number) {
    if (!confirm("Are you sure you want to delete this review?")) return;
    await fetch(`/api/reviews/${id}`, { method: "DELETE" });
    fetchReviews();
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <h1 className="text-xl font-bold text-gray-900">Movie Log</h1>
          <button
            onClick={() => router.push("/reviews/new")}
            className="px-4 py-2 bg-black text-white rounded text-sm hover:bg-gray-800"
          >
            + New Review
          </button>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-4 py-6 flex flex-col gap-4">
        <FilterBar
          ratingMin={ratingMin}
          ratingMax={ratingMax}
          dateFrom={dateFrom}
          dateTo={dateTo}
          sort={sort}
          order={order}
          onFilterChange={handleFilterChange}
          onReset={handleReset}
        />

        {loading ? (
          <p className="text-center text-gray-500 py-8">Loading...</p>
        ) : reviews.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-gray-500 mb-4">No reviews yet.</p>
            <button
              onClick={() => router.push("/reviews/new")}
              className="px-4 py-2 bg-black text-white rounded text-sm hover:bg-gray-800"
            >
              Write your first review
            </button>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {reviews.map((review) => (
              <ReviewCard
                key={review.id}
                {...review}
                onEdit={(id) => router.push(`/reviews/${id}/edit`)}
                onDelete={handleDelete}
              />
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
