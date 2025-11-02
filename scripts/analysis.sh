#!/bin/sh
# Features:
#   1. Checks disk usage and alerts if usage > threshold.
#   2. Scans a log file for "error" entries.
#   3. Includes basic error handling and validation.
# ------------------------------------------------------------

# Exit immediately if a command fails (-e)
# Treat unset variables as errors (-u)
# Note: 'pipefail' is not POSIX, so we skip it here.
set -eu

# ---------------- CONFIGURATION ----------------
THRESHOLD=80                # % disk usage threshold
LOG_FILE="/var/log/syslog"  # Log file path
DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')  # Timestamp

# ---------------- HELPER FUNCTIONS ----------------
error_exit() {
  echo "ERROR: $1" >&2
  exit 1
}

# Check required commands
check_dependencies() {
  for cmd in df grep awk sed wc date; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error_exit "Required command '$cmd' not found. Please install it."
    fi
  done
}

# ---------------- DISK USAGE CHECK ----------------
check_disk_usage() {
  echo "[$DATE_NOW] ------ Disk Usage Report ------"

  # Get filesystem usage
  df -h 2>/dev/null | grep '^/dev/' | while read line; do
    # Extract usage % and filesystem name
    USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    FS=$(echo "$line" | awk '{print $1}')

    # Skip invalid lines
    if [ -z "$USAGE" ] || [ -z "$FS" ]; then
      echo "Skipping invalid entry: $line"
      continue
    fi

    # Compare usage
    if [ "$USAGE" -ge "$THRESHOLD" ]; then
      echo "ALERT: $FS usage is at ${USAGE}% (Threshold: ${THRESHOLD}%)"
    else
      echo "OK: $FS usage is ${USAGE}%"
    fi
  done
}

# ---------------- LOG ERROR ANALYSIS ----------------
analyze_log_errors() {
  echo ""
  echo "[$DATE_NOW] ------ Log Error Count ------"

  if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    return
  fi

  if [ ! -r "$LOG_FILE" ]; then
    error_exit "Permission denied reading $LOG_FILE"
  fi

  ERRORS=$(grep -i "error" "$LOG_FILE" 2>/dev/null | wc -l || echo 0)
  echo "Found $ERRORS error entries in $LOG_FILE"

  if [ "$ERRORS" -gt 0 ]; then
    echo "Review the log file for possible issues."
  else
    echo "No errors detected in logs."
  fi
}

# ---------------- MAIN EXECUTION ----------------
echo "=============================================="
echo "System Analysis Report - $DATE_NOW"
echo "=============================================="

check_dependencies
check_disk_usage
analyze_log_errors

echo ""
echo "Analysis completed successfully"
exit 0
