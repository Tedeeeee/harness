import { mkdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

import type { ChatMessage } from "./chat-message.js";

type SessionFilePayload = {
  id: string;
  messages: ChatMessage[];
  updatedAt: string;
};

export type SessionStore = {
  loadSessionMessages: (sessionId: string) => Promise<ChatMessage[]>;
  saveSessionMessages: (
    sessionId: string,
    messages: ChatMessage[]
  ) => Promise<void>;
};

const SESSION_NAME_PATTERN = /^[A-Za-z0-9_-]+$/;

export function createFileSessionStore(
  baseDir = join(process.cwd(), "data")
): SessionStore {
  async function loadSessionMessages(sessionId: string): Promise<ChatMessage[]> {
    const filePath = getSessionFilePath(baseDir, sessionId);

    try {
      const raw = await readFile(filePath, "utf8");
      const payload = JSON.parse(raw) as SessionFilePayload;

      if (!Array.isArray(payload.messages)) {
        throw new Error("세션 파일 형식이 올바르지 않습니다.");
      }

      return payload.messages;
    } catch (error) {
      if (isMissingFileError(error)) {
        return [];
      }

      const message = error instanceof Error ? error.message : String(error);
      throw new Error(`세션을 불러오지 못했습니다: ${message}`);
    }
  }

  async function saveSessionMessages(
    sessionId: string,
    messages: ChatMessage[]
  ): Promise<void> {
    const sessionsDir = join(baseDir, "sessions");
    const filePath = getSessionFilePath(baseDir, sessionId);
    const payload: SessionFilePayload = {
      id: sessionId,
      messages,
      updatedAt: new Date().toISOString(),
    };

    await mkdir(sessionsDir, { recursive: true });
    await writeFile(filePath, JSON.stringify(payload, null, 2), "utf8");
  }

  return {
    loadSessionMessages,
    saveSessionMessages,
  };
}

function getSessionFilePath(baseDir: string, sessionId: string): string {
  assertValidSessionId(sessionId);
  return join(baseDir, "sessions", `${sessionId}.json`);
}

function assertValidSessionId(sessionId: string): void {
  if (!SESSION_NAME_PATTERN.test(sessionId)) {
    throw new Error(
      "세션 이름은 영문, 숫자, 하이픈(-), 밑줄(_)만 사용할 수 있습니다."
    );
  }
}

function isMissingFileError(error: unknown): error is NodeJS.ErrnoException {
  return (
    error instanceof Error &&
    "code" in error &&
    (error as NodeJS.ErrnoException).code === "ENOENT"
  );
}
