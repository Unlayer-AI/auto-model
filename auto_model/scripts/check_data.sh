#!/usr/bin/env bash
# check_data.sh — Phase 1 data audit helper
# Usage: bash check_data.sh <path_to_data_file>
# Exit 0 = all checks passed, non-zero = something needs attention.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS="${GREEN}[PASS]${NC}"
WARN="${YELLOW}[WARN]${NC}"
FAIL="${RED}[FAIL]${NC}"

issues=0

# ── 1. Argument check ──────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo -e "${FAIL} Usage: bash check_data.sh <path_to_data_file>"
  exit 1
fi

FILE="$1"

# ── 2. File exists ─────────────────────────────────────────────────────────────
if [[ ! -e "$FILE" ]]; then
  echo -e "${FAIL} File not found: $FILE"
  exit 1
fi
echo -e "${PASS} File exists: $FILE"

# ── 3. File is not empty ───────────────────────────────────────────────────────
if [[ ! -s "$FILE" ]]; then
  echo -e "${FAIL} File is empty: $FILE"
  exit 1
fi
echo -e "${PASS} File is non-empty"

# ── 4. File size ───────────────────────────────────────────────────────────────
SIZE_BYTES=$(wc -c < "$FILE")
if command -v numfmt &>/dev/null; then
  SIZE_HUMAN=$(numfmt --to=iec "$SIZE_BYTES")
else
  SIZE_HUMAN="${SIZE_BYTES} bytes"
fi
echo -e "      File size: ${SIZE_HUMAN}"

# ── 5. Extension / format detection ───────────────────────────────────────────
EXT="${FILE##*.}"
EXPECTED_BINARY=0
case "${EXT,,}" in
  csv)
    echo -e "${PASS} Format: CSV"
    # Count rows (lines minus header)
    TOTAL_LINES=$(wc -l < "$FILE")
    DATA_ROWS=$(( TOTAL_LINES - 1 ))
    echo -e "      Rows (excl. header): ${DATA_ROWS}"
    if [[ $DATA_ROWS -lt 50 ]]; then
      echo -e "${WARN} Very few rows (${DATA_ROWS}). Consider k-fold CV instead of a held-out val set."
      ((issues++)) || true
    fi
    # Count columns from header
    HEADER=$(head -1 "$FILE")
    # Use awk to count comma-separated fields (handles quoted commas imperfectly but good enough)
    NCOLS=$(echo "$HEADER" | awk -F',' '{print NF}')
    echo -e "      Columns: ${NCOLS}"
    echo -e "      Header preview: $(echo "$HEADER" | cut -c1-120)"
    ;;
  tsv)
    echo -e "${PASS} Format: TSV"
    TOTAL_LINES=$(wc -l < "$FILE")
    DATA_ROWS=$(( TOTAL_LINES - 1 ))
    echo -e "      Rows (excl. header): ${DATA_ROWS}"
    NCOLS=$(head -1 "$FILE" | awk -F'\t' '{print NF}')
    echo -e "      Columns: ${NCOLS}"
    ;;
  parquet)
    echo -e "${PASS} Format: Parquet (cannot inspect without Python)"
    echo -e "      Run: python3 -c \"import pandas as pd; df=pd.read_parquet('${FILE}'); print(df.shape)\""
    EXPECTED_BINARY=1
    ;;
  json|jsonl|ndjson)
    echo -e "${PASS} Format: JSON/JSONL"
    TOTAL_LINES=$(wc -l < "$FILE")
    echo -e "      Lines: ${TOTAL_LINES}"
    ;;
  xlsx|xls)
    echo -e "${WARN} Format: Excel (${EXT}). Convert to CSV first with:"
    echo -e "      python3 -c \"import pandas as pd; pd.read_excel('${FILE}').to_csv('data.csv', index=False)\""
    EXPECTED_BINARY=1
    ((issues++)) || true
    ;;
  mat)
    echo -e "${WARN} Format: MATLAB (.mat). Convert to CSV/Parquet before training:"
    echo -e "      python3 -c \"from scipy.io import loadmat; import pandas as pd; m=loadmat('${FILE}'); print([k for k in m.keys() if not k.startswith('__')])\""
    EXPECTED_BINARY=1
    ((issues++)) || true
    ;;
  rds|rda|rdata)
    echo -e "${WARN} Format: R binary data (.${EXT,,}). Convert to CSV/Parquet before training:"
    echo -e "      Rscript -e \"obj <- readRDS('${FILE}'); write.csv(as.data.frame(obj), 'data.csv', row.names = FALSE)\""
    echo -e "      # For .rda/.rdata: Rscript -e \"e <- new.env(); load('${FILE}', envir=e); n <- ls(e)[1]; write.csv(as.data.frame(e[[n]]), 'data.csv', row.names = FALSE)\""
    EXPECTED_BINARY=1
    ((issues++)) || true
    ;;
  *)
    echo -e "${WARN} Unrecognised extension: .${EXT}. Attempting to treat as text."
    TOTAL_LINES=$(wc -l < "$FILE")
    echo -e "      Lines: ${TOTAL_LINES}"
    ((issues++)) || true
    ;;
esac

# ── 6. Encoding / binary check ────────────────────────────────────────────────
if file "$FILE" | grep -qi "binary\|executable\|data"; then
  if [[ $EXPECTED_BINARY -eq 1 ]]; then
    echo -e "${PASS} Binary file type detected as expected for this format"
  else
    echo -e "${WARN} File appears to be binary. If it is Parquet/Excel/HDF5/MATLAB/R binary data that is expected."
    ((issues++)) || true
  fi
else
  echo -e "${PASS} File appears to be text/UTF-8"
fi

# ── 7. Duplicate rows (CSV only, rough check via sort|uniq) ───────────────────
if [[ "${EXT,,}" == "csv" ]]; then
  UNIQUE_LINES=$(sort "$FILE" | uniq | wc -l)
  DUP_LINES=$(( TOTAL_LINES - UNIQUE_LINES ))
  if [[ $DUP_LINES -gt 0 ]]; then
    echo -e "${WARN} Approximately ${DUP_LINES} duplicate line(s) detected (including possible header). Deduplicate before splitting."
    ((issues++)) || true
  else
    echo -e "${PASS} No obvious duplicate rows detected"
  fi
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
if [[ $issues -eq 0 ]]; then
  echo -e "${PASS} Data check complete — no issues. Ready for Phase 2 (splits)."
else
  echo -e "${WARN} Data check complete — ${issues} warning(s). Review before proceeding."
fi

exit 0