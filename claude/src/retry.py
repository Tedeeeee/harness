import time
import random
import httpx

MAX_RETRIES = 10
MAX_529_RETRIES = 3
BASE_DELAY = 0.5  # seconds


def with_retry(fn, max_retries=MAX_RETRIES):
    """실패하면 점점 더 오래 기다렸다가 재시도한다 (지수 백오프)"""
    attempt = 1
    count_529 = 0

    while True:
        try:
            return fn()
        except (httpx.ConnectError, httpx.TimeoutException):
            # 네트워크 문제 — 재시도
            if attempt > max_retries:
                raise
        except httpx.HTTPStatusError as e:
            status = e.response.status_code
            if status in (400, 401, 403):
                raise  # 재시도해봤자 소용없음
            if status == 529:
                count_529 += 1
                if count_529 >= MAX_529_RETRIES:
                    raise  # 서버 과부하 3번이면 포기
            elif attempt > max_retries:
                raise

        # 지수 백오프: 0.5초 → 1초 → 2초 → 4초 ... (최대 60초)
        delay = min(BASE_DELAY * (2 ** (attempt - 1)), 60)
        delay += random.uniform(0, delay * 0.1)  # 약간의 랜덤 (동시 재시도 방지)
        print(f"\n재시도 중... ({attempt}/{max_retries}, {delay:.1f}초 후)")
        time.sleep(delay)
        attempt += 1
