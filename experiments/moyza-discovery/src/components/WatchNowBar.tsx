import type { Title } from "@/data/types";

export function WatchNowBar({ title }: { title: Title }) {
  return (
    <div className="watch-now-bar" data-testid="watch-now-bar">
      <a
        href={title.externalUrl}
        target="_blank"
        rel="noopener noreferrer"
        className="watch-now-bar__cta"
        data-testid="watch-now-link"
      >
        Watch Now
      </a>
    </div>
  );
}
