import { getSurveyUrl } from "@/lib/env";

export function SurveyBanner({
  variant = "home",
}: {
  variant?: "home" | "detail";
}) {
  const href = getSurveyUrl();
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={`survey-banner survey-banner--${variant}`}
      data-testid={`survey-banner-${variant}`}
    >
      <div className="survey-banner__text">
        <strong>Join now and get a</strong>
        <span>free Americano !</span>
      </div>
      <span className="survey-banner__icon" aria-hidden>
        ☕ 100%
      </span>
    </a>
  );
}
