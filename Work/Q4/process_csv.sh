#!/bin/bash

# This script processes a CSV file containing plant data and generates diagrams for each plant.
if [ -z "$1" ]; then
  CSV_FILE=$(ls *.csv 2>/dev/null | head -n 1)
  if [ -z "$CSV_FILE" ]; then
    echo "No CSV file provided and none found in the current directory." >&2
    exit 1
  else
    echo "Using CSV file: $CSV_FILE"
  fi
else
  CSV_FILE="$1"
  if [ ! -f "$CSV_FILE" ]; then
    echo "CSV file $CSV_FILE not found." >&2
    exit 1
  fi
fi


VENV_DIR="$HOME/.venv_course_lin_Q4"
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment in $VENV_DIR"
  python3 -m venv "$VENV_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to create virtual environment." >&2
    exit 1
  fi
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"
if [ $? -ne 0 ]; then
  echo "Failed to activate virtual environment." >&2
  exit 1
fi

# Install the required packages
REQ_FILE="../../Work/Q2/requirements.txt"
if [ ! -f "$REQ_FILE" ]; then
  echo "Requirements file not found at $REQ_FILE" >&2
  deactivate
  exit 1
fi
pip install -r "$REQ_FILE"


DIAGRAMS_DIR="Diagrams"
mkdir -p "$DIAGRAMS_DIR"

LOG_FILE="process_log.txt"
ERROR_LOG="error_log.txt"
echo "Processing started at $(date)" > "$LOG_FILE"
echo "Processing started at $(date)" > "$ERROR_LOG"


tail -n +2 "$CSV_FILE" | while IFS=',' read -r plant heights leaf_counts dry_weights; do
  plant=$(echo "$plant" | tr -d '"' | xargs)
  if [ -z "$plant" ]; then
    echo "Empty plant name, skipping." >> "$ERROR_LOG"
    continue
  fi
  echo "Processing plant: $plant" | tee -a "$LOG_FILE"
  
  # Create a directory for the plant
  PLANT_DIR="$DIAGRAMS_DIR/$plant"
  mkdir -p "$PLANT_DIR"
  

  heights=$(echo "$heights" | tr -d '"' | xargs)
  leaf_counts=$(echo "$leaf_counts" | tr -d '"' | xargs)
  dry_weights=$(echo "$dry_weights" | tr -d '"' | xargs)
  
  # Run the python script to generate the diagram
  OUTPUT=$(python3 ../Q2/plant_plots.py --plant "$plant" --height $heights --leaf_count $leaf_counts --dry_weight $dry_weights 2>&1)
  EXIT_CODE=$?
  echo "Output for $plant:" >> "$LOG_FILE"
  echo "$OUTPUT" >> "$LOG_FILE"
  if [ $EXIT_CODE -ne 0 ]; then
    echo "Error running python for $plant" >> "$ERROR_LOG"
  else
    echo "Python script executed successfully for $plant" >> "$LOG_FILE"
  fi
  
  # Move the diagram to the plant's folder
  mv *"${plant}"*_diagram.png "$PLANT_DIR/" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "Diagram for $plant moved to $PLANT_DIR" >> "$LOG_FILE"
  else
    echo "No diagram found for $plant" >> "$ERROR_LOG"
  fi
done

deactivate


BACKUP_FILE="../../BACKUPS/Diagrams_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czvf "$BACKUP_FILE" "$DIAGRAMS_DIR"
if [ $? -eq 0 ]; then
  echo "Diagrams compressed into backup file: $BACKUP_FILE" >> "$LOG_FILE"
else
  echo "Failed to compress Diagrams folder." >> "$ERROR_LOG"
fi

echo "Processing completed at $(date)" >> "$LOG_FILE"
echo "Processing completed at $(date)" >> "$ERROR_LOG"

exit 0
