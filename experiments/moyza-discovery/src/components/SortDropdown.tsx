"use client";

export type SortKey = "latest-first";

export const SORT_OPTIONS: ReadonlyArray<{ key: SortKey; label: string }> = [
  { key: "latest-first", label: "Latest first" },
];

interface Props {
  value?: SortKey;
  onChange?: (value: SortKey) => void;
}

export function SortDropdown({ value = "latest-first", onChange }: Props) {
  return (
    <label className="sort-dropdown" data-testid="sort-dropdown">
      <select
        value={value}
        onChange={(e) => onChange?.(e.target.value as SortKey)}
        aria-label="Sort results"
      >
        {SORT_OPTIONS.map((opt) => (
          <option key={opt.key} value={opt.key}>
            {opt.label}
          </option>
        ))}
      </select>
    </label>
  );
}
