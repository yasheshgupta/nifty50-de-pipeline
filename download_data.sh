#!/bin/bash

# ============================================================
# Nifty 50 Data Pipeline - Kaggle Download Script
# Handles spaces in filenames automatically (%20 issue)
# ============================================================

DATASET="debashis74017/nifty-50-minute-data"
OUTPUT_DIR="data/raw"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo " Nifty 50 Pipeline - Downloading datasets"
echo "============================================"

# ------------------------------------------------------------
# Define files to download
# Format: "Kaggle filename" "renamed filename"
# ------------------------------------------------------------
declare -A FILES=(
  ["NIFTY 50_minute.csv"]="nifty50_minute.csv"
  ["NIFTY 50_5minute.csv"]="nifty50_5minute.csv"
  ["NIFTY 50_day.csv"]="nifty50_day.csv"
  ["INDIA VIX_minute.csv"]="india_vix_minute.csv"
  ["INDIA VIX_5minute.csv"]="india_vix_5minute.csv"
  ["INDIA VIX_day.csv"]="india_vix_day.csv"
)

# ------------------------------------------------------------
# Download and rename each file
# ------------------------------------------------------------
SUCCESS=0
FAILED=0

for ORIGINAL in "${!FILES[@]}"; do
  RENAMED="${FILES[$ORIGINAL]}"

  echo ""
  echo ">>> Downloading: $ORIGINAL"

  # Download using kaggle API
  kaggle datasets download "$DATASET" \
    --file "$ORIGINAL" \
    -p "$OUTPUT_DIR" \
    --unzip 2>/dev/null

  # Handle %20 spaces - kaggle sometimes saves with %20 or with spaces
  # Try all possible saved names and rename cleanly
  ENCODED="${ORIGINAL// /%20}"         # NIFTY%2050_minute.csv
  SPACED="$ORIGINAL"                   # NIFTY 50_minute.csv

  if [ -f "$OUTPUT_DIR/$ENCODED" ]; then
    mv "$OUTPUT_DIR/$ENCODED" "$OUTPUT_DIR/$RENAMED"
    echo "✅ Saved as: $RENAMED (was %20 encoded)"
    ((SUCCESS++))
  elif [ -f "$OUTPUT_DIR/$SPACED" ]; then
    mv "$OUTPUT_DIR/$SPACED" "$OUTPUT_DIR/$RENAMED"
    echo "✅ Saved as: $RENAMED (had spaces)"
    ((SUCCESS++))
  elif [ -f "$OUTPUT_DIR/$RENAMED" ]; then
    echo "✅ Already saved as: $RENAMED"
    ((SUCCESS++))
  else
    echo "❌ FAILED: $ORIGINAL — file not found after download"
    ((FAILED++))
  fi

done

# ------------------------------------------------------------
# Also clean up any leftover zip files
# ------------------------------------------------------------
echo ""
echo ">>> Cleaning up any zip files..."
rm -f "$OUTPUT_DIR"/*.zip
echo "✅ Done"

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
echo ""
echo "============================================"
echo " Download Summary"
echo "============================================"
echo " ✅ Success : $SUCCESS files"
echo " ❌ Failed  : $FAILED files"
echo ""
echo " Files in data/raw/:"
ls -lh "$OUTPUT_DIR"/*.csv 2>/dev/null || echo " No CSV files found."
echo "============================================"

# ------------------------------------------------------------
# Git commit
# ------------------------------------------------------------
echo ""
read -p "Push downloaded data info to GitHub? (y/n): " PUSH
if [ "$PUSH" == "y" ]; then
  # Add everything except actual CSVs (too large for git)
  echo "data/raw/*.csv" >> .gitignore
  git add .gitignore
  git commit -m "Day 1: add data/raw to gitignore, download script added"
  git push origin main
  echo "✅ Pushed to GitHub!"
else
  echo "Skipped git push."
fi
