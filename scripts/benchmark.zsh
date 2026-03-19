#!/usr/bin/env zsh
# ============================================================================
# @file        scripts/benchmark.zsh
# @description ZSH startup time profiler. Measures shell initialization
#              performance with multiple iterations, identifies slow
#              components, and provides optimization recommendations.
#
# @usage       zsh scripts/benchmark.zsh
#              just benchmark
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
# ============================================================================

# ============================================================================
# Configuration
# ============================================================================

readonly ITERATIONS="${1:-10}"
readonly WARMUP=3

# ============================================================================
# Benchmark Functions
# ============================================================================

# @description  Run the startup benchmark
run_benchmark() {
  printf "\n  🏎  ZSH Startup Benchmark\n"
  printf "  ═══════════════════════════════════\n\n"
  printf "  Iterations: %d (+ %d warmup)\n\n" "$ITERATIONS" "$WARMUP"

  # -- Warmup runs (not counted)
  printf "  Warming up..."
  local i
  for (( i=0; i < WARMUP; i++ )); do
    zsh -ic exit 2>/dev/null
  done
  printf " done\n\n"

  # -- Timed runs
  local -a times=()
  local total=0

  for (( i=1; i <= ITERATIONS; i++ )); do
    local start end elapsed_ms

    start=$( { date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))'; } )
    zsh -ic exit 2>/dev/null
    end=$( { date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))'; } )

    elapsed_ms=$(( (end - start) / 1000000 ))
    times+=("$elapsed_ms")
    total=$(( total + elapsed_ms ))

    printf "  Run %2d: %4dms\n" "$i" "$elapsed_ms"
  done

  # -- Statistics
  local avg=$(( total / ITERATIONS ))

  # -- Sort for min/max/median
  local sorted=("${(on)times[@]}")
  local min="${sorted[1]}"
  local max="${sorted[-1]}"
  local median_idx=$(( (ITERATIONS + 1) / 2 ))
  local median="${sorted[$median_idx]}"

  # -- Standard deviation
  local variance=0
  local t
  for t in "${times[@]}"; do
    variance=$(( variance + (t - avg) ** 2 ))
  done
  variance=$(( variance / ITERATIONS ))
  # -- Integer square root approximation
  local stddev=0
  if (( variance > 0 )); then
    stddev=$(( ${(l:1::0:)$(( variance ))} ))
    # Simple Newton's method
    local guess=$(( variance / 2 ))
    local j
    for (( j=0; j < 10; j++ )); do
      (( guess > 0 )) && guess=$(( (guess + variance / guess) / 2 ))
    done
    stddev=$guess
  fi

  printf "\n  ─────────────────────────────────\n"
  printf "  Average:  %4dms\n" "$avg"
  printf "  Median:   %4dms\n" "$median"
  printf "  Min:      %4dms\n" "$min"
  printf "  Max:      %4dms\n" "$max"
  printf "  Stddev:   ~%dms\n" "$stddev"
  printf "  ─────────────────────────────────\n\n"

  # -- Rating
  if (( avg < 80 )); then
    printf "  🟢 ${avg}ms — Excellent! Blazing fast startup\n"
  elif (( avg < 150 )); then
    printf "  🟢 ${avg}ms — Great! Startup is fast\n"
  elif (( avg < 250 )); then
    printf "  🟡 ${avg}ms — Good, but there's room for improvement\n"
  elif (( avg < 500 )); then
    printf "  🟠 ${avg}ms — Acceptable, consider lazy-loading more tools\n"
  else
    printf "  🔴 ${avg}ms — Slow! Run profiling: ZSH_PROFILE=1 zsh -ic exit\n"
  fi

  printf "\n"
}

# @description  Run detailed profiling with zprof
run_profiling() {
  printf "\n  📊 Detailed Profiling (zprof)\n"
  printf "  ═══════════════════════════════════\n\n"

  ZSH_PROFILE=1 zsh -ic exit 2>&1 | head -40

  printf "\n  💡 Tip: For full output, run: ZSH_PROFILE=1 zsh -ic exit\n\n"
}

# @description  Compare with other shells
run_comparison() {
  printf "\n  📊 Shell Startup Comparison\n"
  printf "  ═══════════════════════════════════\n\n"

  local -a shells=("zsh" "bash")
  command -v fish &>/dev/null && shells+=("fish")

  local sh
  for sh in "${shells[@]}"; do
    if command -v "$sh" &>/dev/null; then
      local start end elapsed
      start=$(date +%s%N 2>/dev/null || echo 0)
      "$sh" -ic exit 2>/dev/null
      end=$(date +%s%N 2>/dev/null || echo 0)
      elapsed=$(( (end - start) / 1000000 ))
      printf "  %-8s %4dms\n" "$sh" "$elapsed"
    fi
  done

  printf "\n"
}

# ============================================================================
# Main
# ============================================================================

main() {
  run_benchmark

  if [[ "${2:-}" == "--profile" ]]; then
    run_profiling
  fi

  if [[ "${2:-}" == "--compare" ]]; then
    run_comparison
  fi

  printf "  Options:\n"
  printf "    zsh scripts/benchmark.zsh 20           # 20 iterations\n"
  printf "    zsh scripts/benchmark.zsh 10 --profile # With zprof output\n"
  printf "    zsh scripts/benchmark.zsh 10 --compare # Compare with bash/fish\n"
  printf "\n"
}

main "$@"
