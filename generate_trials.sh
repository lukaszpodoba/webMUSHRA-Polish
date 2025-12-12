#!/bin/bash

# This script generates MUSHRA trial blocks for webMUSHRA's YAML configuration.
# It assumes that for each audio sample, there are corresponding files
# in the 'hidden_original', 'our_model', 'other_model', and 'other_model_2' directories.

# --- Configuration ---
AUDIO_BASE_PATH="configs/resources/audio"
HIDDEN_ORIGINAL_DIR="${AUDIO_BASE_PATH}/hidden_original"
OUR_MODEL_DIR="${AUDIO_BASE_PATH}/our_model"
OTHER_MODEL_DIR="${AUDIO_BASE_PATH}/other_model"
OTHER_MODEL_2_DIR="${AUDIO_BASE_PATH}/other_model_2"

# Check if the reference directory exists
if [ ! -d "$HIDDEN_ORIGINAL_DIR" ]; then
  echo "Error: Directory '$HIDDEN_ORIGINAL_DIR' not found."
  exit 1
fi

# --- Main Loop ---
COUNTER=1
# Find all .wav files in the hidden_original directory
# and iterate over them.
for ref_file_path in "$HIDDEN_ORIGINAL_DIR"/*.wav; do
  # Check if any files were found
  if [ ! -f "$ref_file_path" ]; then
    echo "No .wav files found in '$HIDDEN_ORIGINAL_DIR'. Please add your audio files."
    exit 0
  fi

  # Get the base filename (e.g., "sample1.wav")
  ref_filename=$(basename "$ref_file_path")

  # Construct the paths for the other stimuli
  our_model_file="${OUR_MODEL_DIR}/${ref_filename}"
  other_model_file="${OTHER_MODEL_DIR}/${ref_filename}"
  other_model_2_file="${OTHER_MODEL_2_DIR}/${ref_filename}"

  # Check if the corresponding files exist
  if [ ! -f "$our_model_file" ]; then
    echo "Warning: Corresponding file for '$ref_filename' not found in '$OUR_MODEL_DIR'. Skipping."
    continue
  fi
  if [ ! -f "$other_model_file" ]; then
    echo "Warning: Corresponding file for '$ref_filename' not found in '$OTHER_MODEL_DIR'. Skipping."
    continue
  fi
  if [ ! -f "$other_model_2_file" ]; then
    echo "Warning: Corresponding file for '$ref_filename' not found in '$OTHER_MODEL_2_DIR'. Skipping."
    continue
  fi

  # --- YAML Template ---
  cat << EOF
    - type: mushra
      id: trial_${COUNTER}
      name: Ocena - Próbka ${COUNTER}
      content: Proszę ocenić jakość dźwięku próbek. Użyj suwaków, aby ocenić podobieństwo do <strong>Wzorca</strong>. Wynik <strong>100</strong> oznacza brzmienie identyczne z oryginałem.
      showWaveform: false
      enableLooping: true
      reference: ${ref_file_path}
      createAnchor35: true
      stimuli:
          OurModel: ${our_model_file}
          OtherModel: ${other_model_file}
          OtherModel2: ${other_model_2_file}
EOF

  COUNTER=$((COUNTER + 1))
done

echo ""
echo "# ---"
echo "# Script finished. Copy the generated YAML blocks above and paste them into your 'pages' list in the main configuration file."
