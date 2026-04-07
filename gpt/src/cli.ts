import { createInterface } from "node:readline";

import { streamText } from "./lib/anthropic.js";
import { loadConfig } from "./lib/config.js";
import { runPromptCommand } from "./lib/run-prompt-command.js";
import { runReplCommand } from "./lib/run-repl-command.js";

async function main(): Promise<void> {
  const args = process.argv.slice(2);

  if (args.length > 0) {
    const exitCode = await runPromptCommand(
      args,
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
    const exitCode = await runReplCommand(
      rl,
      {
        loadConfig,
        streamText,
      },
      {
        writeStdout: (text) => process.stdout.write(text),
        writeStderr: (text) => process.stderr.write(text),
        writePrompt: (text) => process.stdout.write(text),
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
