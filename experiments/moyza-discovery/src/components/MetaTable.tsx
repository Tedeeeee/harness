import type { Title } from "@/data/types";

export function MetaTable({ title }: { title: Title }) {
  const rows: Array<[string, string]> = [
    ["Title", title.title],
    ["Genre", title.genre],
    ["Release Year", String(title.year)],
    ["Episodes", `${title.episodes} Episodes`],
    ["Country", title.country],
    ["Age Rating", title.ageRating],
  ];

  return (
    <dl className="meta-table" data-testid="meta-table">
      {rows.map(([k, v]) => (
        <div className="meta-table__row" key={k}>
          <dt>{k}</dt>
          <dd>{v}</dd>
        </div>
      ))}
    </dl>
  );
}
