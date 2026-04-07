import assert from "node:assert/strict";
import test from "node:test";

import type { AppConfig } from "../src/lib/config.js";
import { runPromptCommand } from "../src/lib/run-prompt-command.js";

test("프롬프트가 없으면 사용법을 출력하고 종료 코드 0을 반환한다", async () => {
  const stdout: string[] = [];
  const stderr: string[] = [];

  const exitCode = await runPromptCommand(
    [],
    {
      loadConfig: () => {
        throw new Error("호출되면 안 됩니다.");
      },
      streamText: async () => {
        throw new Error("호출되면 안 됩니다.");
      },
    },
    {
      writeStdout: (text) => stdout.push(text),
      writeStderr: (text) => stderr.push(text),
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(stdout, ['사용법: npm run dev -- "질문 또는 프롬프트"\n']);
  assert.deepEqual(stderr, []);
});

test("프롬프트가 있으면 단일 user 메시지를 만들어 스트리밍 호출한 뒤 줄바꿈을 추가한다", async () => {
  const stdout: string[] = [];
  const stderr: string[] = [];
  const config: AppConfig = {
    anthropicApiKey: "test-key",
    anthropicModel: "test-model",
  };

  const receivedMessageLists: Array<
    Array<{ role: "user" | "assistant"; content: string }>
  > = [];

  const exitCode = await runPromptCommand(
    ["안녕하세요.", "스트리밍", "테스트입니다."],
    {
      loadConfig: () => config,
      streamText: async (messages, loadedConfig, onChunk) => {
        receivedMessageLists.push(messages);
        assert.equal(loadedConfig, config);

        onChunk("첫 번째 ");
        onChunk("청크");
        return "첫 번째 청크";
      },
    },
    {
      writeStdout: (text) => stdout.push(text),
      writeStderr: (text) => stderr.push(text),
    }
  );

  assert.equal(exitCode, 0);
  assert.deepEqual(receivedMessageLists, [
    [{ role: "user", content: "안녕하세요. 스트리밍 테스트입니다." }],
  ]);
  assert.deepEqual(stdout, ["첫 번째 ", "청크", "\n"]);
  assert.deepEqual(stderr, []);
});

test("스트리밍 중 오류가 발생하면 stderr에 메시지를 출력하고 종료 코드 1을 반환한다", async () => {
  const stdout: string[] = [];
  const stderr: string[] = [];

  const exitCode = await runPromptCommand(
    ["오류", "테스트"],
    {
      loadConfig: () => ({
        anthropicApiKey: "test-key",
        anthropicModel: "test-model",
      }),
      streamText: async () => {
        throw new Error("스트리밍 실패");
      },
    },
    {
      writeStdout: (text) => stdout.push(text),
      writeStderr: (text) => stderr.push(text),
    }
  );

  assert.equal(exitCode, 1);
  assert.deepEqual(stdout, []);
  assert.deepEqual(stderr, ["스트리밍 실패\n"]);
});
