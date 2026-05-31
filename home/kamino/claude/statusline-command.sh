#!/usr/bin/env bash
# Claude Code statusline
# Format: model · dir (git) · S: $cost · ctx% · L: X% (timer) · W: X% (timer)
# Input: JSON from Claude Code via stdin

input=$(cat)

reset='\033[0m'
bg='\033[48;5;220m'
fg='\033[38;5;232m'
green='\033[38;5;22m'
orange='\033[38;5;130m'
red='\033[38;5;124m'
dim_fg='\033[38;5;238m'

pipe="${bg}${dim_fg} · ${fg}"

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# --- Directory ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  short_dir=$(basename "$cwd")
else
  short_dir="?"
fi

# --- Git ---
git_info=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -z "$porcelain" ]; then
      git_info="★"
    else
      git_info="★"
    fi
    short_dir="${branch}${git_info}"
  fi
fi

# --- Session cost ---
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost_seg="${fg}S: ${green}\$$(printf '%.2f' "$cost")${fg}"
else
  cost_seg="${fg}S: —"
fi

# --- Context ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if [ "$pct_int" -ge 80 ]; then ctx_color="$red"
  elif [ "$pct_int" -ge 50 ]; then ctx_color="$orange"
  else ctx_color="$green"
  fi
  ctx_seg="${fg}ctx: ${ctx_color}${pct_int}%${fg}"
else
  ctx_seg="${fg}ctx: —"
fi

# --- Rate limits helper: convert epoch to human duration ---
human_duration() {
  local resets_at=$1
  local now
  now=$(date +%s)
  local diff=$(( resets_at - now ))
  [ "$diff" -le 0 ] && echo "now" && return
  local h=$(( diff / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  [ "$h" -gt 0 ] && echo "${h}h${m}m" || echo "${m}m"
}

human_duration_long() {
  local resets_at=$1
  local now
  now=$(date +%s)
  local diff=$(( resets_at - now ))
  [ "$diff" -le 0 ] && echo "now" && return
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  [ "$d" -gt 0 ] && echo "${d}d${h}h" || echo "${h}h"
}

# --- L: 5-hour rate limit ---
l_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | xargs printf '%.0f' 2>/dev/null)
l_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$l_pct" ]; then
  l_timer=$(human_duration "$l_reset")
  if [ "$l_pct" -ge 80 ]; then l_color="$red"
  elif [ "$l_pct" -ge 50 ]; then l_color="$orange"
  else l_color="$green"
  fi
  l_seg="${fg}L: ${l_color}${l_pct}%${fg} (${l_timer})"
else
  l_seg=""
fi

# --- W: 7-day rate limit ---
w_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | xargs printf '%.0f' 2>/dev/null)
w_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$w_pct" ]; then
  w_timer=$(human_duration_long "$w_reset")
  if [ "$w_pct" -ge 80 ]; then w_color="$red"
  elif [ "$w_pct" -ge 50 ]; then w_color="$orange"
  else w_color="$green"
  fi
  w_seg="${fg}W: ${w_color}${w_pct}%${fg} (${w_timer})"
else
  w_seg=""
fi

# --- Compose ---
out="${bg}${fg} ${model}${pipe}${short_dir}${pipe}${cost_seg}${pipe}${ctx_seg}"
[ -n "$l_seg" ] && out="${out}${pipe}${l_seg}"
[ -n "$w_seg" ] && out="${out}${pipe}${w_seg}"
out="${out} ${reset}"

printf "%b" "$out"
