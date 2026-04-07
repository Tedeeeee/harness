import Anthropic from "@anthropic-ai/sdk";

import type { ChatMessage } from "./chat-message.js";
import type { AppConfig } from "./config.js";

export async function generateText(
  messages: ChatMessage[],
  config: AppConfig
): Promise<string> {
  const anthropic = new Anthropic({
    apiKey: config.anthropicApiKey,
  });

  try {
    const response = await anthropic.messages.create({
      model: config.anthropicModel,
      max_tokens: 1024,
      messages,
    });

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

export async function streamText(
  messages: ChatMessage[],
  config: AppConfig,
  onChunk: (chunk: string) => void
): Promise<string> {
  const anthropic = new Anthropic({
    apiKey: config.anthropicApiKey,
  });

  let fullText = "";

  try {
    const stream = anthropic.messages.stream({
      model: config.anthropicModel,
      max_tokens: 1024,
      messages,
    });

    stream.on("text", (textDelta) => {
      fullText += textDelta;
      onChunk(textDelta);
    });

    await stream.done();

    const trimmed = fullText.trim();

    if (!trimmed) {
      throw new Error("응답에 텍스트가 없습니다.");
    }

    return trimmed;
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.";

    throw new Error(`Anthropic API 호출에 실패했습니다: ${message}`);
  }
}
