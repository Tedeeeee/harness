import { createInterface } from "node:readline";

import { streamText } from "./lib/anthropic.js";
import { parseCliOptions } from "./lib/cli-options.js";
import { loadConfig } from "./lib/config.js";
import { runPromptCommand } from "./lib/run-prompt-command.js";
import { runReplCommand } from "./lib/run-repl-command.js";
import { createFileSessionStore } from "./lib/session-store.js";

async function main(): Promise<void> {
  const options = parseCliOptions(process.argv.slice(2));

  if (options.mode === "prompt") {
    const exitCode = await runPromptCommand(
      options.promptArgs,
      {
        loadConfig,
        streamText,
      },
      {
        writeStdout: (text) => process.stdout.write(text),
        writeStderr: (text) => process.stderr.write(text),
      }
    );

    process.exitCode = exitCode;
    return;
  }

  const rl = createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: true,
  });

  try {
    const sessionStore = createFileSessionStore();
    const exitCode = await runReplCommand(
      rl,
      {
        loadConfig,
        loadSessionMessages: sessionStore.loadSessionMessages,
        saveSessionMessages: sessionStore.saveSessionMessages,
        streamText,
      },
      {
        writeStdout: (text) => process.stdout.write(text),
        writeStderr: (text) => process.stderr.write(text),
        writePrompt: (text) => process.stdout.write(text),
      },
      {
        sessionId: options.sessionId,
      }
    );

    process.exitCode = exitCode;
  } finally {
    rl.close();
  }
}

main().catch((error) => {
  const message = error instanceof Error ? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
