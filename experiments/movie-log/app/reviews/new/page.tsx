import ReviewForm from "@/components/ReviewForm";

export default function NewReviewPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-3xl mx-auto px-4 py-4">
          <h1 className="text-xl font-bold text-gray-900">New Review</h1>
        </div>
      </header>
      <main className="max-w-3xl mx-auto px-4 py-6">
        <ReviewForm />
      </main>
    </div>
  );
}
