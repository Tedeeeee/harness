export const DEFAULT_SURVEY_URL = "https://example.invalid/survey";

export function getSurveyUrl(): string {
  const v = process.env.NEXT_PUBLIC_SURVEY_URL;
  return v && v.length > 0 ? v : DEFAULT_SURVEY_URL;
}

export function isPlatformBadgesEnabled(): boolean {
  return process.env.NEXT_PUBLIC_SHOW_PLATFORM_BADGES === "true";
}
