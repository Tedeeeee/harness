import { streamText } from "./lib/anthropic.js";
import { loadConfig } from "./lib/config.js";
import { runPromptCommand } from "./lib/run-prompt-command.js";

async function main(): Promise<void> {
  const exitCode = await runPromptCommand(
    process.argv.slice(2),
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
}

main().catch((error) => {
  const message = error instanceof Error ? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
