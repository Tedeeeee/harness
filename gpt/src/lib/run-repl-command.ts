import type { AppConfig } from "./config.js";

type ReplDependencies = {
  loadConfig: () => AppConfig;
  streamText: (
    prompt: string,
    config: AppConfig,
    onChunk: (chunk: string) => void
  ) => Promise<void>;
};

type ReplIO = {
  writeStdout: (text: string) => void;
  writeStderr: (text: string) => void;
  writePrompt: (text: string) => void;
};

export async function runReplCommand(
  lines: AsyncIterable<string>,
  deps: ReplDependencies,
  io: ReplIO
): Promise<number> {
  io.writeStdout("REPL 모드입니다. 종료하려면 exit 또는 quit를 입력하세요.\n");

  let config: AppConfig;

  try {
    config = deps.loadConfig();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    io.writeStderr(`${message}\n`);
    return 1;
  }

  io.writePrompt("> ");

  for await (const rawLine of lines) {
    const line = rawLine.trim();

    if (!line) {
      io.writePrompt("> ");
      continue;
    }

    if (line === "exit" || line === "quit") {
      io.writeStdout("REPL을 종료합니다.\n");
      return 0;
    }

    try {
      await deps.streamText(line, config, (chunk) => {
        io.writeStdout(chunk);
      });

      io.writeStdout("\n");
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      io.writeStderr(`${message}\n`);
      return 1;
    }

    io.writePrompt("> ");
  }

  io.writeStdout("\n");
  return 0;
}
