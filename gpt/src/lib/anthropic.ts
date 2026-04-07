import Anthropic from "@anthropic-ai/sdk";

import type { AppConfig } from "./config.js";

export async function generateText(
  prompt: string,
  config: AppConfig
): Promise<string> {
  // 지금 단계에서는 Anthropic 하나만 직접 연결한다.
  const anthropic = new Anthropic({
    apiKey: config.anthropicApiKey,
  });

  try {
    const response = await anthropic.messages.create({
      model: config.anthropicModel,
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    });

    // Messages API는 여러 블록을 반환할 수 있으므로 텍스트만 모아 하나의 문자열로 만든다.
    const text = response.content
      .filter((block) => block.type === "text")
      .map((block) => block.text)
      .join("\n")
      .trim();

    if (!text) {
      throw new Error("응답에 텍스트가 없습니다.");
    }

    return text;
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.";

    throw new Error(`Anthropic API 호출에 실패했습니다: ${message}`);
  }
}
