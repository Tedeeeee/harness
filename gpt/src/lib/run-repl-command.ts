import type { ChatMessage } from "./chat-message.js";
import type { AppConfig } from "./config.js";

type ReplDependencies = {
  loadConfig: () => AppConfig;
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

  // REPL이 살아 있는 동안의 대화 문맥만 메모리에 유지한다.
  const history: ChatMessage[] = [];

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

    // 기존 세션 이력 위에 새 user 메시지를 덧붙여 이번 호출의 전체 문맥을 만든다.
    const requestMessages: ChatMessage[] = [
      ...history,
      {
        role: "user",
        content: line,
      },
    ];

    try {
      const assistantText = await deps.streamText(requestMessages, config, (chunk) => {
        io.writeStdout(chunk);
      });

      // 호출이 성공하면 이번 user/assistant 쌍을 세션 이력에 추가한다.
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
