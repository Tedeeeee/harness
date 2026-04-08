import assert from "node:assert/strict";
import test from "node:test";

import type { AppConfig } from "../src/lib/config.js";
import { runReplCommand } from "../src/lib/run-repl-command.js";

async function* createLines(lines: string[]): AsyncIterable<string> {
  for (const line of lines) {
    yield line;
  }
}

test("REPL은 각 질문을 스트리밍 호출하고 저장 후 quit 입력 시 종료한다", async () => {
  const stdout: string[] = [];
  const stderr: string[] = [];
  const prompts: string[] = [];
  const config: AppConfig = {
    anthropicApiKey: "test-key",
    anthropicModel: "test-model",
  };

  const receivedMessageLists: Array<
    Array<{ role: "user" | "assistant"; content: string }>
  > = [];
  const savedHistories: Array<
    Array<{ role: "user" | "assistant"; content: string }>
  > = [];

  const exitCode = await runReplCommand(
    createLines(["안녕하세요", "quit"]),
    {
      loadConfig: () => config,
      loadSessionMessages: async () => [],
      saveSessionMessages: async (_sessionId, messages) => {
        savedHistories.push(messages);
      },
      streamText: async (messages, loadedConfig, onChunk) => {
        receivedMessageLists.push(messages);
        assert.equal(loadedConfig, config);

        onChunk("응답 ");
        onChunk("완료");
        return "응답 완료";
      },
    },
    {
      writeStdout: (text) => stdout.push(text),
      writeStderr: (text) => stderr.push(text),
      writePrompt: (text) => prompts.push(text),
    },
    {
      sessionId: "default",
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(receivedMessageLists, [
    [{ role: "user", content: "안녕하세요" }],
  ]);
  assert.deepEqual(savedHistories, [
    [
      { role: "user", content: "안녕하세요" },
      { role: "assistant", content: "응답 완료" },
    ],
  ]);
  assert.deepEqual(stderr, []);
  assert.match(stdout[0] ?? "", /REPL 모드입니다\./);
  assert.match(stdout[1] ?? "", /세션 "default"/);
  assert.deepEqual(stdout.slice(2), ["응답 ", "완료", "\n", "REPL을 종료합니다.\n"]);
  assert.deepEqual(prompts, ["> ", "> "]);
});

test("REPL은 저장된 세션 이력을 복원해 다음 호출에 함께 전달한다", async () => {
  const config: AppConfig = {
    anthropicApiKey: "test-key",
    anthropicModel: "test-model",
  };

  const receivedMessageLists: Array<
    Array<{ role: "user" | "assistant"; content: string }>
  > = [];

  const exitCode = await runReplCommand(
    createLines(["새 질문", "quit"]),
    {
      loadConfig: () => config,
      loadSessionMessages: async (sessionId) => {
        assert.equal(sessionId, "bugfix-chat");
        return [
          { role: "user", content: "예전 질문" },
          { role: "assistant", content: "예전 답변" },
        ];
      },
      saveSessionMessages: async () => undefined,
      streamText: async (messages, _loadedConfig, onChunk) => {
        receivedMessageLists.push(messages);
        onChunk("새 답변");
        return "새 답변";
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: () => undefined,
      writePrompt: () => undefined,
    },
    {
      sessionId: "bugfix-chat",
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(receivedMessageLists, [
    [
      { role: "user", content: "예전 질문" },
      { role: "assistant", content: "예전 답변" },
      { role: "user", content: "새 질문" },
    ],
  ]);
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
      loadSessionMessages: async () => [],
      saveSessionMessages: async () => undefined,
      streamText: async () => {
        throw new Error("호출되면 안 됩니다");
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: () => undefined,
      writePrompt: (text) => prompts.push(text),
    },
    {
      sessionId: "default",
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
      loadSessionMessages: async () => [],
      saveSessionMessages: async () => undefined,
      streamText: async () => {
        throw new Error("REPL 스트리밍 실패");
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: (text) => stderr.push(text),
      writePrompt: () => undefined,
    },
    {
      sessionId: "default",
    }
  );

  assert.equal(exitCode, 1);
  assert.deepEqual(stderr, ["REPL 스트리밍 실패\n"]);
});

test("REPL에서 세션 이력 저장이 실패하면 stderr를 출력하고 종료한다", async () => {
  const stderr: string[] = [];

  const exitCode = await runReplCommand(
    createLines(["질문"]),
    {
      loadConfig: () => ({
        anthropicApiKey: "test-key",
        anthropicModel: "test-model",
      }),
      loadSessionMessages: async () => [],
      saveSessionMessages: async () => {
        throw new Error("세션 저장 실패");
      },
      streamText: async (_messages, _config, onChunk) => {
        onChunk("응답");
        return "응답";
      },
    },
    {
      writeStdout: () => undefined,
      writeStderr: (text) => stderr.push(text),
      writePrompt: () => undefined,
    },
    {
      sessionId: "default",
    }
  );

  assert.equal(exitCode, 1);
  assert.deepEqual(stderr, ["세션 저장 실패\n"]);
});
