"use client";

interface FilterBarProps {
  ratingMin: string;
  ratingMax: string;
  dateFrom: string;
  dateTo: string;
  sort: string;
  order: string;
  onFilterChange: (key: string, value: string) => void;
  onReset: () => void;
}

export default function FilterBar({
  ratingMin,
  ratingMax,
  dateFrom,
  dateTo,
  sort,
  order,
  onFilterChange,
  onReset,
}: FilterBarProps) {
  return (
    <div className="border border-gray-200 rounded-lg p-4 flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-gray-700">Filter & Sort</span>
        <button
          onClick={onReset}
          className="text-xs text-gray-500 hover:text-gray-700 underline"
        >
          Reset
        </button>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div>
          <label className="block text-xs text-gray-500 mb-1">Min Rating</label>
          <select
            value={ratingMin}
            onChange={(e) => onFilterChange("rating_min", e.target.value)}
            className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
          >
            <option value="">All</option>
            {[1, 2, 3, 4, 5].map((n) => (
              <option key={n} value={n}>
                {n}+
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">Max Rating</label>
          <select
            value={ratingMax}
            onChange={(e) => onFilterChange("rating_max", e.target.value)}
            className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
          >
            <option value="">All</option>
            {[1, 2, 3, 4, 5].map((n) => (
              <option key={n} value={n}>
                {n} and below
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">From</label>
          <input
            type="date"
            value={dateFrom}
            onChange={(e) => onFilterChange("date_from", e.target.value)}
            className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
          />
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">To</label>
          <input
            type="date"
            value={dateTo}
            onChange={(e) => onFilterChange("date_to", e.target.value)}
            className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
          />
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <label className="text-xs text-gray-500">Sort by</label>
        <select
          value={sort}
          onChange={(e) => onFilterChange("sort", e.target.value)}
          className="border border-gray-300 rounded px-2 py-1 text-sm"
        >
          <option value="latest">Date</option>
          <option value="rating">Rating</option>
          <option value="title">Title</option>
        </select>
        <select
          value={order}
          onChange={(e) => onFilterChange("order", e.target.value)}
          className="border border-gray-300 rounded px-2 py-1 text-sm"
        >
          <option value="desc">Desc</option>
          <option value="asc">Asc</option>
        </select>
      </div>
    </div>
  );
}
