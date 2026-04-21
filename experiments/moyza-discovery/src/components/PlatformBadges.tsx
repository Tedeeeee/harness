import { isPlatformBadgesEnabled } from "@/lib/env";

const DISPLAY_PLATFORMS = ["NETFLIX", "TVING", "coupang play"];

export function PlatformBadges() {
  if (!isPlatformBadgesEnabled()) {
    return null;
  }
  return (
    <div className="platform-badges" data-testid="platform-badges">
      {DISPLAY_PLATFORMS.map((p) => (
        <span key={p} className="platform-badge">
          {p}
        </span>
      ))}
    </div>
  );
}
