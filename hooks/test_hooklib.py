from __future__ import annotations

import json
import os
import pathlib
import tempfile
import textwrap
import unittest

import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))

import hooklib


class HookLibTests(unittest.TestCase):
    def test_get_implementation_summary_parses_expected_fields(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = pathlib.Path(tmpdir)
            state_path = root / "docs" / "implementation"
            state_path.mkdir(parents=True)
            (state_path / "implementation-state.md").write_text(
                textwrap.dedent(
                    """
                    # Implementation State

                    ## Summary

                    - Current Step: step-02
                    - Current Status: in_progress

                    ## Step Status

                    | Step | Title | Status | Verification Doc | Notes |
                    | --- | --- | --- | --- | --- |
                    | step-01 | One | completed | step-01-verification.md | |
                    | step-02 | Two | in_progress |  | |
                    | step-03 | Three | pending |  | |

                    ## Blockers

                    - None

                    ## Next Allowed Action

                    - Continue the current step
                    """
                ).strip()
                + "\n",
                encoding="utf-8",
            )

            summary = hooklib.get_implementation_summary(root)

            self.assertTrue(summary.exists)
            self.assertEqual(summary.current_step, "step-02")
            self.assertEqual(summary.current_status, "in_progress")
            self.assertEqual(summary.pending_steps, ["step-03"])
            self.assertEqual(summary.active_steps, ["step-02"])
            self.assertEqual(summary.blockers, "- None")

    def test_get_planning_summary_parses_stage_rows(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = pathlib.Path(tmpdir)
            planning_path = root / "docs" / "plans"
            planning_path.mkdir(parents=True)
            (planning_path / "planning-state.md").write_text(
                textwrap.dedent(
                    """
                    # Planning State

                    - Project: chatting

                    | Stage | Status | Notes |
                    | --- | --- | --- |
                    | requirements | completed | done |
                    | technical-approach | in_progress | deciding |
                    """
                ).strip()
                + "\n",
                encoding="utf-8",
            )

            summary = hooklib.get_planning_summary(root)

            self.assertTrue(summary.exists)
            self.assertEqual(summary.project, "chatting")
            self.assertEqual(summary.stages["requirements"], "completed")
            self.assertEqual(summary.stages["technical-approach"], "in_progress")

    def test_session_start_context_prefers_planning_state_when_no_implementation(self) -> None:
        planning = hooklib.PlanningSummary(
            exists=True,
            project="chatting",
            stages={"requirements": "completed", "technical-approach": "in_progress"},
        )
        implementation = hooklib.ImplementationSummary(
            exists=False,
            current_step=None,
            current_status=None,
            next_allowed_action=None,
            blockers=None,
            pending_steps=[],
            active_steps=[],
        )
        memory = hooklib.MemorySummary(
            has_harness_memory=False,
            has_project_memory=False,
            harness_memory=None,
            project_memory=None,
            combined_text="",
        )

        context = hooklib.build_session_start_context(implementation, planning, memory)

        self.assertIn("Planning is in progress", context)
        self.assertIn("technical-approach: in_progress", context)

    def test_stop_guard_blocks_when_verification_ready(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="step-02",
            current_status="verification-ready",
            next_allowed_action="Run verify-current-step",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
        )

        reason = hooklib.get_stop_guard_reason(summary)

        self.assertIsNotNone(reason)
        self.assertIn("verify-current-step", reason)

    def test_output_helpers_emit_json(self) -> None:
        payload = json.loads(hooklib.additional_context_json("SessionStart", "hello"))
        self.assertEqual(payload["hookSpecificOutput"]["hookEventName"], "SessionStart")
        self.assertEqual(payload["hookSpecificOutput"]["additionalContext"], "hello")

        block = json.loads(hooklib.block_decision_json("wait"))
        self.assertEqual(block["decision"], "block")
        self.assertEqual(block["reason"], "wait")


if __name__ == "__main__":
    unittest.main()
