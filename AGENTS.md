You are working in a Ruby on Rails project that uses mutation testing, line and branch coverage, and static analysis.

## Goal

Maintain 100% line and branch coverage (overall and per file) and 100% mutation coverage for all configured subjects. Run SimpleCov before Mutant so Mutant uses a fresh per-test coverage map:

```sh
bin/ci
RAILS_ENV=test bin/rails db:test:prepare test
bundle exec mutant run --selection context_map
```

When working through surviving mutations, use `--fail-fast` to address one at a time. Add `--since origin/main` to focus on changed code while iterating, but run the full configured suite before declaring the gate green.

## When you find a surviving mutation

- **The implementation is more complex than the behavior requires.** Simplify it without changing intended behavior.
- **A test is missing.** Add a focused test that observes the intended behavior through a public interface.

Decide which case applies before editing. If the intended behavior is unclear, ask the user.

## Constraints

- Do not ignore mutants, narrow the configured scope, or weaken coverage thresholds or `coverage_criteria` to make a check pass.
- Prefer public-behavior tests over tests that call private methods solely to kill a mutant.
- Use `minitest-strict` assertions such as `assert_true`, `assert_false`, and `assert_eql` when an exact value or type is part of the contract.
- Keep changes minimal and targeted to the surviving mutant.

## Static analysis

- Keep `bundle exec reek .` warning-free. Pass `.` explicitly so non-interactive runs scan the project rather than stdin. Simplify code before considering a narrow exclusion.
- Keep `bundle exec standardrb --no-fix` offense-free. Use `bundle exec standardrb --fix` for safe autocorrections before fixing remaining offenses manually.
- Keep `bundle exec ruby script/check_rubydex.rb` free of project diagnostics.
