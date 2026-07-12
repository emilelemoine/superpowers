# Shared Slurm helpers for BigPurple. Paste/append into ~/.bashrc on the
# cluster. All log-viewing aliases require $CLUSTER_LOG_DIR, which each
# project's cluster/env-setup.sh exports. Run `qh` for the in-shell reference.

alias qq='squeue -u "$USER" -o "%.10i %.20j %.10P %.2t %.10M %.4D %.6b %.20R"'

_slurm_pick_log() {
  # Usage: _slurm_pick_log <ext> [pattern]
  # Returns the most recent log file matching the extension (and optional pattern).
  local ext="$1" pattern="${2:-}" files
  if [ -z "$CLUSTER_LOG_DIR" ]; then
    echo "CLUSTER_LOG_DIR is not set — source a project env-setup.sh first" >&2
    return 1
  fi
  if [ -n "$pattern" ]; then
    files=($(ls -t "$CLUSTER_LOG_DIR"/*"$pattern"*."$ext" 2>/dev/null))
  else
    files=($(ls -t "$CLUSTER_LOG_DIR"/*."$ext" 2>/dev/null))
  fi
  if [ ${#files[@]} -eq 0 ]; then
    echo "No .$ext files in $CLUSTER_LOG_DIR${pattern:+ matching '$pattern'}" >&2
    return 1
  fi
  echo "${files[0]}"
}

ql() { local f; f="$(_slurm_pick_log out "$1")" && tail -f "$f"; }
qe() { ql "$@"; }                                              # stderr merged into .out
qc() { local f; f="$(_slurm_pick_log out "$1")" && cat "$f"; } # full log, no follow

qr() {
  # 10 most recent jobs with sacct state and duration.
  if [ -z "$CLUSTER_LOG_DIR" ]; then
    echo "CLUSTER_LOG_DIR is not set — source a project env-setup.sh first" >&2
    return 1
  fi
  local files running_ids
  running_ids=" $(squeue -u "$USER" -h -o '%i' 2>/dev/null | tr '\n' ' ') "
  files=($(ls -t "$CLUSTER_LOG_DIR"/*.out 2>/dev/null | head -10))
  if [ ${#files[@]} -eq 0 ]; then
    echo "No .out files in $CLUSTER_LOG_DIR" >&2
    return 1
  fi
  local ids=()
  for f in "${files[@]}"; do
    local _name; _name="$(basename "$f" .out)"; ids+=("${_name##*_}")
  done
  local id_list sacct_data
  id_list="$(IFS=,; echo "${ids[*]}")"
  sacct_data="$(sacct -j "$id_list" -o JobID,Elapsed,State -n -X -P 2>/dev/null)"
  printf '%-19s  %-14s  %-10s  %s\n' "TIME" "STATE" "DURATION" "JOB"
  local RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DIM=$'\e[2m' RST=$'\e[0m'
  for f in "${files[@]}"; do
    local ts name jobid state duration entry sacct_state padded color
    name="$(basename "$f" .out)"
    jobid="${name##*_}"
    entry="$(echo "$sacct_data" | awk -F'|' -v id="$jobid" '$1 == id {print; exit}')"
    duration="$(echo "$entry" | cut -d'|' -f2)"
    sacct_state="$(echo "$entry" | cut -d'|' -f3)"
    sacct_state="${sacct_state%% *}"  # "CANCELLED by 12345" -> "CANCELLED"
    if [[ "$running_ids" == *" $jobid "* ]]; then
      state="RUNNING"
    else
      state="${sacct_state:-UNKNOWN}"
    fi
    duration="${duration:----}"
    ts="$(stat -c '%y' "$f" 2>/dev/null || stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null)"
    ts="${ts%.*}"
    padded="$(printf '%-14s' "$state")"
    case "$state" in
      COMPLETED) color="$GRN" ;;
      RUNNING)   color="$YLW" ;;
      FAILED|CANCELLED|TIMEOUT|NODE_FAIL|OUT_OF_MEMORY|BOOT_FAIL|DEADLINE|PREEMPTED)
                 color="$RED" ;;
      *)         color="$DIM" ;;
    esac
    printf '%-19s  %s%s%s  %-10s  %s\n' "$ts" "$color" "$padded" "$RST" "$duration" "$name"
  done
}

# All my pending jobs, any partition, with reason and est. start
alias qop='squeue --me -t PENDING -o "%.10i %.20j %.10P %.10r %.20S %R"'

# All my jobs, any partition (running + pending)
alias qom='squeue --me -o "%.10i %.20j %.10P %.2t %.10M %.10l %.4D %.6b %.20S %R"'

# Oermannlab queue, all users
alias qo='squeue -p oermannlab -o "%.10i %.20j %.10u %.2t %.10M %.10l %.6D %.4C %.6b %R"'

# Live refresh of the oermannlab queue (Ctrl-C to exit)
alias qow='watch -n 10 "squeue -p oermannlab -o \"%.10i %.20j %.10u %.2t %.10M %.4D %R\""'

# Deep-dive on a single job: why pending, when expected, what GPU, where
qwhy() {
    scontrol show job "$1" \
      | grep -E "JobName|JobState|Reason|StartTime|NodeList|ReqNode|ExcNode|Partition|TRES|GresPerNode|JobId"
  }

qh() {
  cat <<'HELP'
Slurm helpers (q*):

  Queue views
    qq             your queue, compact (running + pending)
    qom            your jobs, any partition (full columns)
    qop            your pending jobs with reason + est. start
    qo             oermannlab queue, all users
    qow            qo on watch (10s refresh)

  Logs (CLUSTER_LOG_DIR; arg = job ID or substring, omit for latest)
    ql [pat]       tail -f most recent .out
    qe [pat]       alias of ql (stderr merged into .out)
    qc [pat]       cat full .out
    qr             10 most recent jobs with state + duration (colored)

  Diagnosis
    qwhy <jobid>   scontrol fields explaining a pending/odd job
    qh             this help
HELP
}
