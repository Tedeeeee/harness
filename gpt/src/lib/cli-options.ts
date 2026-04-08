export const DEFAULT_SESSION_ID = "default";

export type CliOptions =
  | {
      mode: "prompt";
      promptArgs: string[];
    }
  | {
      mode: "repl";
      sessionId: string;
    };

export function parseCliOptions(args: string[]): CliOptions {
  if (args.length === 0) {
    return {
      mode: "repl",
      sessionId: DEFAULT_SESSION_ID,
    };
  }

  if (args[0] === "--session") {
    const sessionId = args[1]?.trim();

    if (!sessionId) {
      throw new Error("--session 다음에는 세션 이름을 입력해야 합니다.");
    }

    if (args.length > 2) {
      throw new Error(
        "이번 단계에서는 --session 플래그를 REPL 모드에서만 사용할 수 있습니다."
      );
    }

    return {
      mode: "repl",
      sessionId,
    };
  }

  return {
    mode: "prompt",
    promptArgs: args,
  };
}
