import type { ChatMessage } from "./chat-message.js";
import type { AppConfig } from "./config.js";

type ReplDependencies = {
  loadConfig: () => AppConfig;
  loadSessionMessages: (sessionId: string) => Promise<ChatMessage[]>;
  saveSessionMessages: (
    sessionId: string,
    messages: ChatMessage[]
  ) => Promise<void>;
  streamText: (
    messages: ChatMessage[],
    config: AppConfig,
    onChunk: (chunk: string) => void
  ) => Promise<string>;
};

type ReplIO = {
  writeStdout: (text: string) => void;
  writeStderr: (text: string) => void;
  writePrompt: (text: string) => void;
};

type ReplOptions = {
  sessionId: string;
};

export async function runReplCommand(
  lines: AsyncIterable<string>,
  deps: ReplDependencies,
  io: ReplIO,
  options: ReplOptions
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

  let history: ChatMessage[];

  try {
    history = await deps.loadSessionMessages(options.sessionId);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    io.writeStderr(`${message}\n`);
    return 1;
  }

  if (history.length > 0) {
    io.writeStdout(
      `세션 "${options.sessionId}"에서 ${history.length}개 메시지를 복원했습니다.\n`
    );
  } else {
    io.writeStdout(`세션 "${options.sessionId}"을 시작합니다.\n`);
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

    const requestMessages: ChatMessage[] = [
      ...history,
      {
        role: "user",
        content: line,
      },
    ];

    try {
      const assistantText = await deps.streamText(
        requestMessages,
        config,
        (chunk) => {
          io.writeStdout(chunk);
        }
      );

      history.push(
        {
          role: "user",
          content: line,
        },
        {
          role: "assistant",
          content: assistantText,
        }
      );

      io.writeStdout("\n");
      await deps.saveSessionMessages(options.sessionId, history);
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
