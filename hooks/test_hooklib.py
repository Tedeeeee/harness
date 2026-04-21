from __future__ import annotations

import datetime
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

    def test_closure_mismatch_done_with_current_step(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="step-03",
            current_status="done",
            next_allowed_action="start-retrospective",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
            completed_steps=["step-01", "step-02", "step-03"],
        )
        planning = hooklib.PlanningSummary(
            exists=True,
            project="x",
            stages={},
            planning_final_status="closed",
            requirements_confirmed="yes",
        )
        requirements = hooklib.RequirementsSummary(exists=False, status=None, path=None)

        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

        self.assertIsNotNone(reason)
        self.assertIn("Current Step is not cleared", reason)

    def test_closure_mismatch_all_completed_but_not_done(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="none",
            current_status="in_progress",
            next_allowed_action="",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
            completed_steps=["step-01", "step-02"],
        )
        planning = hooklib.PlanningSummary(exists=True, project="x", stages={})
        requirements = hooklib.RequirementsSummary(exists=False, status=None, path=None)

        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

        self.assertIsNotNone(reason)
        self.assertIn("not 'done'", reason)

    def test_closure_mismatch_impl_done_but_planning_not_closed(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="none",
            current_status="done",
            next_allowed_action="start-retrospective",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
            completed_steps=["step-01"],
        )
        planning = hooklib.PlanningSummary(
            exists=True,
            project="x",
            stages={},
            planning_final_status="not-closed",
            requirements_confirmed="yes",
        )
        requirements = hooklib.RequirementsSummary(exists=False, status=None, path=None)

        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

        self.assertIsNotNone(reason)
        self.assertIn("Planning Final Status", reason)

    def test_closure_mismatch_requirements_confirmed_but_planning_sync_missing(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="step-01",
            current_status="in_progress",
            next_allowed_action="",
            blockers="- None",
            pending_steps=["step-02"],
            active_steps=["step-01"],
            completed_steps=[],
        )
        planning = hooklib.PlanningSummary(
            exists=True,
            project="x",
            stages={},
            planning_final_status="not-closed",
            requirements_confirmed="no",
        )
        requirements = hooklib.RequirementsSummary(
            exists=True,
            status="confirmed",
            path=pathlib.Path("docs/requirements/example.md"),
        )

        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

        self.assertIsNotNone(reason)
        self.assertIn("Requirements Confirmed", reason)

    def test_closure_mismatch_returns_none_when_in_sync(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="none",
            current_status="done",
            next_allowed_action="start-retrospective",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
            completed_steps=["step-01", "step-02"],
        )
        planning = hooklib.PlanningSummary(
            exists=True,
            project="x",
            stages={},
            planning_final_status="closed",
            requirements_confirmed="yes",
        )
        requirements = hooklib.RequirementsSummary(
            exists=True,
            status="confirmed",
            path=pathlib.Path("docs/requirements/example.md"),
        )

        reason = hooklib.detect_closure_mismatch(summary, planning, requirements)

        self.assertIsNone(reason)

    def test_append_trace_creates_file_with_header(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = pathlib.Path(tmpdir)
            moment = datetime.datetime(2026, 4, 21, 10, 23, 0)

            trace_path = hooklib.append_trace(
                event_type="hook",
                actor="session-start",
                reason="existing project detected",
                project_root=root,
                now=moment,
            )

            self.assertTrue(trace_path.exists())
            self.assertEqual(trace_path.name, "trace-2026-04-21.md")
            content = trace_path.read_text(encoding="utf-8")
            self.assertIn("# Trace — 2026-04-21", content)
            self.assertIn(
                "- 2026-04-21T10:23:00 [hook] session-start — existing project detected",
                content,
            )

    def test_append_trace_appends_to_existing_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = pathlib.Path(tmpdir)
            moment1 = datetime.datetime(2026, 4, 21, 10, 23, 0)
            moment2 = datetime.datetime(2026, 4, 21, 10, 24, 0)

            hooklib.append_trace(
                event_type="hook",
                actor="session-start",
                reason="first",
                project_root=root,
                now=moment1,
            )
            hooklib.append_trace(
                event_type="skill-selected",
                actor="route-self-harness",
                reason="second",
                detail="chose verify-current-step",
                project_root=root,
                now=moment2,
            )

            trace_path = root / "docs" / "trace" / "trace-2026-04-21.md"
            content = trace_path.read_text(encoding="utf-8")
            self.assertEqual(content.count("# Trace — 2026-04-21"), 1)
            self.assertIn("[hook] session-start — first", content)
            self.assertIn(
                "[skill-selected] route-self-harness — second | chose verify-current-step",
                content,
            )

    def test_append_trace_rejects_unknown_event_type(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = pathlib.Path(tmpdir)
            with self.assertRaises(ValueError):
                hooklib.append_trace(
                    event_type="not-a-real-event",
                    actor="x",
                    reason="y",
                    project_root=root,
                )

    def _active_summary(self, status: str = "in_progress") -> "hooklib.ImplementationSummary":
        return hooklib.ImplementationSummary(
            exists=True,
            current_step="step-02",
            current_status=status,
            next_allowed_action="",
            blockers="- None",
            pending_steps=[],
            active_steps=["step-02"],
            completed_steps=["step-01"],
        )

    def test_detect_interrupt_triggers_on_wait_keyword(self) -> None:
        summary = self._active_summary()
        self.assertTrue(hooklib.detect_interrupt("잠깐 다른 것부터 확인해줘", summary))

    def test_detect_interrupt_ignores_simple_continuation(self) -> None:
        summary = self._active_summary()
        self.assertFalse(hooklib.detect_interrupt("계속 진행해", summary))
        self.assertFalse(hooklib.detect_interrupt("ok proceed", summary))

    def test_detect_interrupt_does_not_fire_when_not_active(self) -> None:
        summary = hooklib.ImplementationSummary(
            exists=True,
            current_step="none",
            current_status="done",
            next_allowed_action="start-retrospective",
            blockers="- None",
            pending_steps=[],
            active_steps=[],
            completed_steps=["step-01"],
        )
        self.assertFalse(hooklib.detect_interrupt("잠깐만요", summary))

    def test_detect_interrupt_wait_over_continue_takes_priority(self) -> None:
        summary = self._active_summary()
        self.assertTrue(
            hooklib.detect_interrupt("계속 전에 잠깐 확인 좀", summary)
        )

    def test_output_helpers_emit_json(self) -> None:
        payload = json.loads(hooklib.additional_context_json("SessionStart", "hello"))
        self.assertEqual(payload["hookSpecificOutput"]["hookEventName"], "SessionStart")
        self.assertEqual(payload["hookSpecificOutput"]["additionalContext"], "hello")

        block = json.loads(hooklib.block_decision_json("wait"))
        self.assertEqual(block["decision"], "block")
        self.assertEqual(block["reason"], "wait")


if __name__ == "__main__":
    unittest.main()
