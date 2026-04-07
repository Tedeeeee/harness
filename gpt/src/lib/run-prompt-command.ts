import type { AppConfig } from "./config.js";

type PromptCommandDependencies = {
  loadConfig: () => AppConfig;
  streamText: (
    prompt: string,
    config: AppConfig,
    onChunk: (chunk: string) => void
  ) => Promise<void>;
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

    await deps.streamText(prompt, config, (chunk) => {
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
