import argparse
from src.session import load_session

parser = argparse.ArgumentParser(description="Claude Harness")
parser.add_argument("--resume", help="이전 세션 ID를 입력하면 대화를 이어갑니다")
args = parser.parse_args()

# 세션 복원 또는 새 시작
resume_messages = None
if args.resume:
    resume_messages = load_session(args.resume)

from src.repl import run_repl

try:
    run_repl(resume_messages=resume_messages)
except KeyboardInterrupt:
    print("\n세션을 종료합니다.")
