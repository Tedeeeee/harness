import assert from "node:assert/strict";
import test from "node:test";

import type { AppConfig } from "../src/lib/config.js";
import { runReplCommand } from "../src/lib/run-repl-command.js";

async function* createLines(lines: string[]): AsyncIterable<string> {
  for (const line of lines) {
    yield line;
  }
}

test("REPL은 각 줄을 스트리밍 호출하고 quit 입력 시 종료한다", async () => {
  const stdout: string[] = [];
  const stderr: string[] = [];
  const prompts: string[] = [];
  const config: AppConfig = {
    anthropicApiKey: "test-key",
    anthropicModel: "test-model",
  };

  const receivedPrompts: string[] = [];

  const exitCode = await runReplCommand(
    createLines(["안녕하세요", "quit"]),
    {
      loadConfig: () => config,
      streamText: async (prompt, loadedConfig, onChunk) => {
        receivedPrompts.push(prompt);
        assert.equal(loadedConfig, config);

        onChunk("응답 ");
        onChunk("완료");
      },
    },
    {
      writeStdout: (text) => stdout.push(text),
      writeStderr: (text) => stderr.push(text),
      writePrompt: (text) => prompts.push(text),
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(receivedPrompts, ["안녕하세요"]);
  assert.deepEqual(stderr, []);
  assert.deepEqual(stdout, [
    "REPL 모드입니다. 종료하려면 exit 또는 quit를 입력하세요.\n",
    "응답 ",
    "완료",
    "\n",
    "REPL을 종료합니다.\n",
  ]);
  assert.deepEqual(prompts, ["> ", "> "]);
});

test("REPL은 빈 입력을 무시하고 다음 프롬프트를 계속 보여준다", async () => {
  const prompts: string[] = [];

  const exitCode = await runReplCommand(
    createLines(["   ", "exit"]),
    {
      loadConfig: () => ({
        anthropicApiKey: "test-key",
        anthropicModel: "test-model",
      }),
      streamText: async () => {
        throw new Error("호출되면 안 됩니다.");
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: () => undefined,
      writePrompt: (text) => prompts.push(text),
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(prompts, ["> ", "> "]);
});

test("REPL에서 스트리밍 오류가 발생하면 stderr를 출력하고 종료한다", async () => {
  const stderr: string[] = [];

  const exitCode = await runReplCommand(
    createLines(["질문"]),
    {
      loadConfig: () => ({
        anthropicApiKey: "test-key",
        anthropicModel: "test-model",
      }),
      streamText: async () => {
        throw new Error("REPL 스트리밍 실패");
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: (text) => stderr.push(text),
      writePrompt: () => undefined,
    }
  );

  assert.equal(exitCode, 1);
  assert.deepEqual(stderr, ["REPL 스트리밍 실패\n"]);
});
