import type { ChatMessage } from "./chat-message.js";
import type { AppConfig } from "./config.js";

type PromptCommandDependencies = {
  loadConfig: () => AppConfig;
  streamText: (
    messages: ChatMessage[],
    config: AppConfig,
    onChunk: (chunk: string) => void
  ) => Promise<string>;
};

type PromptCommandIO = {
  writeStdout: (text: string) => void;
  writeStderr: (text: string) => void;
};

export async function runPromptCommand(
  args: string[],
  deps: PromptCommandDependencies,
  io: PromptCommandIO
): Promise<number> {
  const prompt = args.join(" ").trim();

  if (!prompt) {
    io.writeStdout('사용법: npm run dev -- "질문 또는 프롬프트"\n');
    return 0;
  }

  try {
    const config = deps.loadConfig();
    const messages: ChatMessage[] = [
      {
        role: "user",
        content: prompt,
      },
    ];

    await deps.streamText(messages, config, (chunk) => {
      io.writeStdout(chunk);
    });

    io.writeStdout("\n");
    return 0;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    io.writeStderr(`${message}\n`);
    return 1;
  }
}
