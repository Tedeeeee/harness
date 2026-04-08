import assert from "node:assert/strict";
import test from "node:test";

import { parseCliOptions } from "../src/lib/cli-options.js";

test("인자가 없으면 default 세션의 REPL 모드로 해석한다", () => {
  assert.deepEqual(parseCliOptions([]), {
    mode: "repl",
    sessionId: "default",
  });
});

test("--session 플래그가 있으면 해당 세션의 REPL 모드로 해석한다", () => {
  assert.deepEqual(parseCliOptions(["--session", "bugfix-chat"]), {
    mode: "repl",
    sessionId: "bugfix-chat",
  });
});

test("일반 인자가 있으면 단일 프롬프트 모드로 해석한다", () => {
  assert.deepEqual(parseCliOptions(["안녕하세요", "한", "줄"]), {
    mode: "prompt",
    promptArgs: ["안녕하세요", "한", "줄"],
  });
});

test("--session 값이 없으면 오류를 던진다", () => {
  assert.throws(
    () => parseCliOptions(["--session"]),
    /--session 다음에는 세션 이름을 입력해야 합니다\./
  );
});

test("세션 플래그와 프롬프트 인자를 함께 쓰면 오류를 던진다", () => {
  assert.throws(
    () => parseCliOptions(["--session", "bugfix-chat", "질문"]),
    /이번 단계에서는 --session 플래그를 REPL 모드에서만 사용할 수 있습니다\./
  );
});
