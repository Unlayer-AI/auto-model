#!/usr/bin/env bash
# check_splits.sh — Phase 2 split verification
# Usage: bash check_splits.sh <splits_dir> [original_data_file]
#
# Checks:
#   1. train.*, val.*, test.* (or exact train/val/test) all exist in splits_dir
#   2. None are empty
#   3. Header consistency is checked when all splits are CSV or all TSV
#   4. Row counts are printed when format supports line-based counting
#   5. If original_data_file is provided and countable: total rows ≈ original row count
#
# Exit 0 = all hard checks passed (warnings may still be printed).

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS="${GREEN}[PASS]${NC}"
WARN="${YELLOW}[WARN]${NC}"
FAIL="${RED}[FAIL]${NC}"
INFO="${CYAN}[INFO]${NC}"

issues=0
fatal=0

lower_ext() {
  local path="$1"
  local name="${path##*/}"
  if [[ "$name" == *.* ]]; then
    printf "%s" "${name##*.}" | tr '[:upper:]' '[:lower:]'
  else
    printf ""
  fi
}

is_line_countable_ext() {
  case "$1" in
    csv|tsv|txt|json|jsonl|ndjson)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_header_comparable_ext() {
  case "$1" in
    csv|tsv)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

count_rows_for_file() {
  local path="$1"
  local ext="$2"
  local total_lines

  case "$ext" in
    csv|tsv|txt)
      total_lines=$(wc -l < "$path")
      echo $(( total_lines - 1 ))
      ;;
    json|jsonl|ndjson)
      wc -l < "$path"
      ;;
    *)
      echo "-1"
      ;;
  esac
}

resolve_split_file() {
  local base="$1"
  local exact="${SPLITS_DIR}/${base}"
  local matches=()
  local path

  if [[ -f "$exact" ]]; then
    echo "$exact"
    return 0
  fi

  while IFS= read -r path; do
    matches+=("$path")
  done < <(find "$SPLITS_DIR" -maxdepth 1 -type f -name "${base}.*" | sort)

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo ""
    return 0
  fi

  if [[ ${#matches[@]} -gt 1 ]]; then
    echo -e "${FAIL} Multiple candidates found for '${base}':" >&2
    for path in "${matches[@]}"; do
      echo -e "       - ${path}" >&2
    done
    echo -e "       Keep only one file per split base name (train/val/test)." >&2
    ((fatal++)) || true
    echo ""
    return 0
  fi

  echo "${matches[0]}"
}

# ── Args ───────────────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo -e "${FAIL} Usage: bash check_splits.sh <splits_dir> [original_data_file]"
  exit 1
fi

SPLITS_DIR="${1%/}"   # strip trailing slash
ORIG_FILE="${2:-}"

echo -e "${INFO} Checking splits in: ${SPLITS_DIR}/"
echo ""

# ── 1. Directory exists ────────────────────────────────────────────────────────
if [[ ! -d "$SPLITS_DIR" ]]; then
  echo -e "${FAIL} Directory not found: ${SPLITS_DIR}"
  exit 1
fi

# ── 2. Required files present ─────────────────────────────────────────────────
REQUIRED_BASES=("train" "val" "test")
declare -A SPLIT_FILES
declare -A SPLIT_EXTS

for base in "${REQUIRED_BASES[@]}"; do
  FPATH="$(resolve_split_file "$base")"
  if [[ -z "$FPATH" ]]; then
    echo -e "${FAIL} Missing split file for '${base}' (expected ${SPLITS_DIR}/${base} or ${SPLITS_DIR}/${base}.*)"
    ((fatal++)) || true
  else
    echo -e "${PASS} Found: ${FPATH}"
    SPLIT_FILES["$base"]="$FPATH"
    SPLIT_EXTS["$base"]="$(lower_ext "$FPATH")"
  fi
done

if [[ $fatal -gt 0 ]]; then
  echo ""
  echo -e "${FAIL} ${fatal} required file(s) missing. Cannot continue checks."
  exit 1
fi

# ── 3. None are empty ─────────────────────────────────────────────────────────
for base in "${REQUIRED_BASES[@]}"; do
  FPATH="${SPLIT_FILES[$base]}"
  if [[ ! -s "$FPATH" ]]; then
    echo -e "${FAIL} File is empty: ${FPATH}"
    ((fatal++)) || true
  fi
done

if [[ $fatal -gt 0 ]]; then
  echo ""
  echo -e "${FAIL} Empty split file(s) found. Recreate splits."
  exit 1
fi

# ── 4. Row counts ─────────────────────────────────────────────────────────────
echo ""
echo -e "${INFO} Row counts (excluding header):"

declare -A ROWS
TOTAL_SPLIT_ROWS=0
ALL_LINE_COUNTABLE=1
for base in "${REQUIRED_BASES[@]}"; do
  FPATH="${SPLIT_FILES[$base]}"
  FEXT="${SPLIT_EXTS[$base]}"
  if is_line_countable_ext "$FEXT"; then
    DATA_ROWS="$(count_rows_for_file "$FPATH" "$FEXT")"
    ROWS[$base]=$DATA_ROWS
    TOTAL_SPLIT_ROWS=$(( TOTAL_SPLIT_ROWS + DATA_ROWS ))
    printf "      %-12s  %d rows (%s)\n" "$base" "$DATA_ROWS" "${FEXT:-no-ext}"
  else
    ROWS[$base]=-1
    ALL_LINE_COUNTABLE=0
    printf "      %-12s  n/a (%s not line-countable in bash)\n" "$base" "${FEXT:-unknown}"
  fi
done
if [[ $ALL_LINE_COUNTABLE -eq 1 ]]; then
  echo -e "      ─────────────────────"
  printf "      %-12s  %d rows\n" "TOTAL" "$TOTAL_SPLIT_ROWS"
else
  echo -e "${WARN} At least one split format is not line-countable; totals/proportions are skipped."
  ((issues++)) || true
fi

# ── 5. Check proportions make rough sense ────────────────────────────────────
TRAIN_ROWS=${ROWS["train"]}
VAL_ROWS=${ROWS["val"]}
TEST_ROWS=${ROWS["test"]}

if [[ $ALL_LINE_COUNTABLE -eq 1 && $TOTAL_SPLIT_ROWS -gt 0 ]]; then
  TRAIN_PCT=$(( 100 * TRAIN_ROWS / TOTAL_SPLIT_ROWS ))
  VAL_PCT=$(( 100 * VAL_ROWS / TOTAL_SPLIT_ROWS ))
  TEST_PCT=$(( 100 * TEST_ROWS / TOTAL_SPLIT_ROWS ))
  echo ""
  echo -e "${INFO} Proportions: train=${TRAIN_PCT}%  val=${VAL_PCT}%  test=${TEST_PCT}%"

  if [[ $TRAIN_PCT -lt 50 ]]; then
    echo -e "${WARN} Training set is less than 50% of data. This is unusual."
    ((issues++)) || true
  fi
  if [[ $TEST_PCT -lt 5 ]]; then
    echo -e "${WARN} Test set is less than 5% of data. May be too small for reliable evaluation."
    ((issues++)) || true
  fi
  if [[ $VAL_PCT -lt 5 ]]; then
    echo -e "${WARN} Validation set is less than 5% of data. May be too small."
    ((issues++)) || true
  fi
fi

# ── 6. Column consistency ──────────────────────────────────────────────────────
echo ""
TRAIN_EXT="${SPLIT_EXTS[train]}"
VAL_EXT="${SPLIT_EXTS[val]}"
TEST_EXT="${SPLIT_EXTS[test]}"

if is_header_comparable_ext "$TRAIN_EXT" \
  && [[ "$TRAIN_EXT" == "$VAL_EXT" ]] \
  && [[ "$TRAIN_EXT" == "$TEST_EXT" ]]; then
  TRAIN_HEADER=$(head -1 "${SPLIT_FILES[train]}")
  VAL_HEADER=$(head -1 "${SPLIT_FILES[val]}")
  TEST_HEADER=$(head -1 "${SPLIT_FILES[test]}")

  if [[ "$TRAIN_HEADER" == "$VAL_HEADER" ]]; then
    echo -e "${PASS} train and val have identical headers"
  else
    echo -e "${FAIL} Header mismatch between train and val"
    echo -e "       train: $(echo "$TRAIN_HEADER" | cut -c1-100)"
    echo -e "       val:   $(echo "$VAL_HEADER"   | cut -c1-100)"
    ((fatal++)) || true
  fi

  if [[ "$TRAIN_HEADER" == "$TEST_HEADER" ]]; then
    echo -e "${PASS} train and test have identical headers"
  else
    echo -e "${FAIL} Header mismatch between train and test"
    echo -e "       train: $(echo "$TRAIN_HEADER" | cut -c1-100)"
    echo -e "       test:  $(echo "$TEST_HEADER"  | cut -c1-100)"
    ((fatal++)) || true
  fi

  if [[ "$TRAIN_EXT" == "csv" ]]; then
    NCOLS=$(echo "$TRAIN_HEADER" | awk -F',' '{print NF}')
  else
    NCOLS=$(echo "$TRAIN_HEADER" | awk -F'\t' '{print NF}')
  fi
  echo -e "${INFO} Columns per split: ${NCOLS}"
  echo -e "      Header: $(echo "$TRAIN_HEADER" | cut -c1-120)"
else
  echo -e "${WARN} Header consistency check skipped (requires all splits to be CSV or all TSV)."
  ((issues++)) || true
fi

# ── 7. Compare to original if provided ────────────────────────────────────────
if [[ -n "$ORIG_FILE" ]]; then
  echo ""
  if [[ ! -f "$ORIG_FILE" ]]; then
    echo -e "${WARN} Original file not found at ${ORIG_FILE} — skipping row-count reconciliation."
    ((issues++)) || true
  elif [[ $ALL_LINE_COUNTABLE -ne 1 ]]; then
    echo -e "${WARN} Split rows are not fully countable for current formats — skipping row-count reconciliation."
    ((issues++)) || true
  else
    ORIG_EXT="$(lower_ext "$ORIG_FILE")"
    if is_line_countable_ext "$ORIG_EXT"; then
      ORIG_ROWS="$(count_rows_for_file "$ORIG_FILE" "$ORIG_EXT")"
    else
      ORIG_ROWS=-1
    fi

    if [[ $ORIG_ROWS -lt 0 ]]; then
      echo -e "${WARN} Original format '${ORIG_EXT:-unknown}' is not line-countable in bash — skipping reconciliation."
      ((issues++)) || true
      ORIG_ROWS=0
    fi

    if [[ $ORIG_ROWS -gt 0 ]]; then
    DIFF=$(( ORIG_ROWS - TOTAL_SPLIT_ROWS ))
    echo -e "${INFO} Original file rows: ${ORIG_ROWS}   Split total: ${TOTAL_SPLIT_ROWS}   Difference: ${DIFF}"
    if [[ $DIFF -ne 0 ]]; then
      ABS_DIFF=${DIFF#-}   # absolute value
      PCT_DIFF=$(( 100 * ABS_DIFF / ORIG_ROWS ))
      if [[ $PCT_DIFF -gt 2 ]]; then
        echo -e "${WARN} Row count differs by ${DIFF} (${PCT_DIFF}%). Check for dropped rows (NaN removal, deduplication)."
        ((issues++)) || true
      else
        echo -e "${PASS} Row count difference of ${DIFF} is within 2% — likely due to deduplication or NaN drops."
      fi
    else
      echo -e "${PASS} Row counts reconcile exactly with original."
    fi
    fi
  fi
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
if [[ $fatal -gt 0 ]]; then
  echo -e "${FAIL} Splits check FAILED — ${fatal} critical error(s). Fix before Phase 3."
  exit 1
elif [[ $issues -gt 0 ]]; then
  echo -e "${WARN} Splits check passed with ${issues} warning(s). Review before proceeding."
  exit 0
else
  echo -e "${PASS} Splits check complete — all good. Ready for Phase 3 (model selection)."
  exit 0
fi