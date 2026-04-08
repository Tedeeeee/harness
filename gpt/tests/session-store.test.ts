import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import type { ChatMessage } from "../src/lib/chat-message.js";
import { createFileSessionStore } from "../src/lib/session-store.js";

test("세션 저장소는 없는 세션 파일을 읽으면 빈 이력을 반환한다", async () => {
  const tempDir = await mkdtemp(join(tmpdir(), "gpt-session-store-"));

  try {
    const store = createFileSessionStore(tempDir);
    const messages = await store.loadSessionMessages("default");

    assert.deepEqual(messages, []);
  } finally {
    await rm(tempDir, { recursive: true, force: true });
  }
});

test("세션 저장소는 메시지를 JSON 파일로 저장하고 다시 복원한다", async () => {
  const tempDir = await mkdtemp(join(tmpdir(), "gpt-session-store-"));

  try {
    const store = createFileSessionStore(tempDir);
    const messages: ChatMessage[] = [
      { role: "user", content: "안녕" },
      { role: "assistant", content: "안녕하세요." },
    ];

    await store.saveSessionMessages("bugfix-chat", messages);

    const payload = await readFile(
      join(tempDir, "sessions", "bugfix-chat.json"),
      "utf8"
    );
    const parsed = JSON.parse(payload) as {
      id: string;
      messages: ChatMessage[];
      updatedAt: string;
    };

    assert.equal(parsed.id, "bugfix-chat");
    assert.deepEqual(parsed.messages, messages);
    assert.ok(parsed.updatedAt);

    const loaded = await store.loadSessionMessages("bugfix-chat");
    assert.deepEqual(loaded, messages);
  } finally {
    await rm(tempDir, { recursive: true, force: true });
  }
});

test("세션 저장소는 위험한 세션 이름을 거부한다", async () => {
  const tempDir = await mkdtemp(join(tmpdir(), "gpt-session-store-"));

  try {
    const store = createFileSessionStore(tempDir);

    await assert.rejects(
      () => store.saveSessionMessages("../hack", []),
      /세션 이름은 영문, 숫자, 하이픈\(-\), 밑줄\(_\)만 사용할 수 있습니다\./
    );
  } finally {
    await rm(tempDir, { recursive: true, force: true });
  }
});
