#!/bin/bash
set -e

# Enable verbose output for debugging
set -x

# Print current working directory
echo "=== Current working directory: $(pwd) ==="

# Debugging: Print environment variables
echo "=== Environment Variables ==="
env | sort
echo "==========================="

# Print user and group info
echo "=== User and Group Info ==="
id
echo "==========================="

# Print disk usage
echo "=== Disk Usage ==="
df -h
echo "================="

# Create test directory structure
echo "=== Creating test directory structure ==="
mkdir -p "$TEST_DIR/lisp/proofs"

# Copy lisp files if they exist
if [ -d "lisp" ]; then
  echo "=== Copying lisp files to $TEST_DIR/lisp/ ==="
  cp -r lisp/* "$TEST_DIR/lisp/" 2>/dev/null || true
  
  # Copy proof files if they exist
  if [ -d "lisp/proofs" ]; then
    echo "=== Copying proof files to $TEST_DIR/lisp/proofs/ ==="
    cp -r lisp/proofs/* "$TEST_DIR/lisp/proofs/" 2>/dev/null || true
  fi
fi

# Create straight-bootstrap.el in the test directory
echo "=== Creating dummy straight-bootstrap.el in $TEST_DIR/lisp/proofs/ ==="
mkdir -p "$TEST_DIR/lisp/proofs"
cat > "$TEST_DIR/lisp/proofs/straight-bootstrap.el" << 'EOL'
;;; Minimal straight.el bootstrap for CI testing
(defun straight-bootstrap-fetch-recipes (&optional from-version)
  "Minimal implementation to avoid errors during testing."
  (message "Skipping straight.el recipe fetch in test environment"))

(defun straight-bootstrap-download-package (package version)
  "Minimal implementation to avoid errors during testing."
  (message "Skipping package download in test environment"))

(provide 'straight-bootstrap)
EOL

# Debug: Show the contents of the file we just created
echo "=== Contents of $TEST_DIR/lisp/proofs/straight-bootstrap.el ==="
cat "$TEST_DIR/lisp/proofs/straight-bootstrap.el"
echo -e "\n=== End of file ===\n"

# Function to create bootstrap files in a given directory
create_bootstrap_files() {
  local base_dir="$1"
  local straight_dir="$base_dir/straight/repos/straight.el"
  
  echo "=== Creating straight.el bootstrap in $straight_dir ==="
  
  # Create parent directories with verbose output
  echo "Current directory: $(pwd)"
  echo "Creating directory: $(dirname "$straight_dir")"
  mkdir -pv "$(dirname "$straight_dir")" || {
    echo "Failed to create directory: $(dirname "$straight_dir")"
    echo "Current directory: $(pwd)"
    echo "Directory permissions:"
    ls -ld "$(dirname "$straight_dir" 2>/dev/null || echo "(does not exist)")"
    return 1
  }
  
  # Create the directory for the bootstrap file
  echo "Creating directory: $straight_dir"
  mkdir -pv "$straight_dir" || {
    echo "Failed to create directory: $straight_dir"
    return 1
  }
  
  # Create a minimal bootstrap.el file
  echo "Creating bootstrap.el in $straight_dir"
  cat > "$straight_dir/bootstrap.el" << 'EOL'
;;; Minimal straight.el bootstrap for CI testing
(defun straight-bootstrap--version () "1.0.0")
(defun straight-bootstrap--dependencies () '())
(defun straight-bootstrap--bootstrap-version () 5)
(provide 'bootstrap)
EOL

  # Also create a straight.el file that loads our bootstrap
  cat > "$base_dir/straight/straight.el" << 'EOL'
;;; straight.el - A simple package manager for Emacs
(require 'cl-lib)

(defvar straight-repository-branch "master")
(defvar straight-repository-user "radian-software")
(defvar straight-repo-dir (file-name-directory (or load-file-name
                                                 (buffer-file-name)
                                                 default-directory)))

(provide 'straight)
EOL

  # Verify the files were created
  for file in "$straight_dir/bootstrap.el" "$base_dir/straight/straight.el"; do
    if [ -f "$file" ]; then
      echo "=== Successfully created $(basename "$file") ==="
      echo "File location: $file"
      echo "File contents:"
      cat "$file"
      echo -e "\n=== End of file ===\n"
    else
      echo "ERROR: Failed to create $file"
      echo "Directory contents of $(dirname "$file")/:"
      ls -la "$(dirname "$file")/" 2>/dev/null || echo "Directory does not exist"
      return 1
    fi
  done
}

# Create bootstrap files in the test directory
create_bootstrap_files "$TEST_DIR"

# Also create bootstrap files in the runner's home directory
RUNNER_HOME="/home/runner"
if [ -d "$RUNNER_HOME" ] && [ -w "$RUNNER_HOME" ]; then
  echo "=== Creating bootstrap files in $RUNNER_HOME/.emacs.d ==="
  create_bootstrap_files "$RUNNER_HOME/.emacs.d"
else
  echo "=== WARNING: Cannot create bootstrap files in $RUNNER_HOME/.emacs.d (directory not writable or doesn't exist) ==="
  echo "Current user: $(whoami)"
  echo "Directory permissions:"
  ls -ld "$RUNNER_HOME" 2>/dev/null || echo "$RUNNER_HOME does not exist"
  echo "Trying with sudo..."
  
  # Try with sudo if available
  if command -v sudo >/dev/null 2>&1; then
    echo "Attempting to create directory with sudo..."
    sudo mkdir -p "$RUNNER_HOME/.emacs.d/straight/repos/straight.el"
    
    if [ -d "$RUNNER_HOME/.emacs.d/straight/repos/straight.el" ]; then
      echo "Directory created with sudo, setting permissions..."
      sudo chown -R $(whoami) "$RUNNER_HOME/.emacs.d"
      create_bootstrap_files "$RUNNER_HOME/.emacs.d"
    else
      echo "Failed to create directory with sudo"
    fi
  else
    echo "sudo not available, cannot create directory"
  fi
fi

# Also create straight-bootstrap.el in the home directory for tests that expect it there
echo -e "\n=== Copying straight-bootstrap.el to home directory ==="
HOME_EMACS_DIR="$HOME/.emacs.d"
mkdir -p "$HOME_EMACS_DIR/lisp/proofs"
echo "Copying from: $TEST_DIR/lisp/proofs/straight-bootstrap.el"
echo "Copying to: $HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"

# Check if source file exists
if [ ! -f "$TEST_DIR/lisp/proofs/straight-bootstrap.el" ]; then
  echo "ERROR: Source file does not exist: $TEST_DIR/lisp/proofs/straight-bootstrap.el"
  echo "Current directory: $(pwd)"
  echo "Test directory contents:"
  find "$TEST_DIR" -type f | sort
  exit 1
fi

# Copy the file
cp -v "$TEST_DIR/lisp/proofs/straight-bootstrap.el" "$HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"

# Verify the copy was successful
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to copy straight-bootstrap.el to $HOME_EMACS_DIR/lisp/proofs/"
  exit 1
fi

echo -e "\n=== Verifying file was copied successfully ==="
if [ -f "$HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el" ]; then
  echo "SUCCESS: File exists at $HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"
  echo "File contents:"
  cat "$HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"
  echo -e "\n=== End of file ==="
else
  echo "ERROR: File was not copied to $HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"
  echo "Directory contents of $HOME_EMACS_DIR/lisp/proofs/:"
  ls -la "$HOME_EMACS_DIR/lisp/proofs/" || echo "Could not list directory"
  exit 1
fi

# Copy the init file from the repository
echo -e "\n=== Copying init file to $TEST_DIR/init.el ==="
mkdir -p "$TEST_DIR"
cp tests/config/init-test.el "$TEST_DIR/init.el"

# Show the directory structure for debugging
echo -e "\n=== Test directory structure ==="
find "$TEST_DIR" -type f | sort || true

# Verify the init file was copied
echo -e "\n=== Init file contents ==="
cat "$TEST_DIR/init.el"
