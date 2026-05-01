{
  "summary": "Explored evaluation/baselines/ and comparative_benchmark.py — 4 files in baselines/, 1 runner, and Makefile. All source code captured below with architecture analysis.",
  "files": [
    {
      "ref": "evaluation/baselines/__init__.py",
      "description": "Package init: imports, exports, shared utility functions (resolve_baseline_model, classify_error, get_litellm_kwargs, trim_messages_to_token_budget, build_compact_schema_text)"
    },
    {
      "ref": "evaluation/baselines/baseline_direct_llm.py",
      "description": "BaselineDirectLLM — single-pass LLM call, JSON extraction, retry loop with invalid-class-name feedback"
    },
    {
      "ref": "evaluation/baselines/baseline_react_agent.py",
      "description": "BaselineReActAgent — iterative tool-use loop via FastMCP, history compression, termination on finish()/fail()"
    },
    {
      "ref": "evaluation/baselines/baseline_code_gen.py",
      "description": "BaselineCodeGen — LLM writes Python code, exec() with Pydantic models in namespace, retries on exec errors"
    },
    {
      "ref": "evaluation/comparative_benchmark.py",
      "description": "ComparativeBenchmark runner — parses targets, loads metamodel, runs create/validate/evaluate steps per target, idempotent/resumable"
    },
    {
      "ref": "src/Makefile",
      "description": "Makefile with SUITE->target mapping, _T_BASELINES definition, benchmark-study and benchmark-comparative targets"
    }
  ]
}