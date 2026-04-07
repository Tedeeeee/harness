import { generateText } from "./lib/anthropic.js";
import { loadConfig } from "./lib/config.js";

async function main(): Promise<void> {
  // CLI에서 전달된 여러 단어 인자를 하나의 프롬프트로 합친다.
  const prompt = process.argv.slice(2).join(" ").trim();

  if (!prompt) {
    console.log('사용법: npm run dev -- "질문 또는 프롬프트"');
    return;
  }

  // 설정 로드와 모델 호출을 분리해두면 이후 스트리밍이나 REPL로 확장하기 쉽다.
  const config = loadConfig();
  const result = await generateText(prompt, config);

  console.log(result);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
