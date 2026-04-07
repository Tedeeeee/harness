import dotenv from "dotenv";

export type AppConfig = {
  anthropicApiKey: string;
  anthropicModel: string;
};

const DEFAULT_MODEL = "claude-sonnet-4-20250514";

export function loadConfig(): AppConfig {
  dotenv.config();

  const anthropicApiKey = process.env.ANTHROPIC_API_KEY?.trim();
  const anthropicModel =
    process.env.ANTHROPIC_MODEL?.trim() || DEFAULT_MODEL;

  if (!anthropicApiKey) {
    throw new Error(
      "ANTHROPIC_API_KEY 환경 변수가 없습니다. .env 파일을 만들고 API 키를 설정해주세요."
    );
  }

  return {
    anthropicApiKey,
    anthropicModel,
  };
}
