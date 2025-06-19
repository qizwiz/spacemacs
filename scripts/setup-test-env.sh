#!/bin/bash
set -e

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

# Create the straight.el bootstrap file that's being looked for
STRAIGHT_DIR="$HOME/.emacs.d/straight/repos/straight.el"
echo "=== Creating straight.el bootstrap in $STRAIGHT_DIR ==="
mkdir -p "$STRAIGHT_DIR"

# Create a minimal bootstrap.el file
cat > "$STRAIGHT_DIR/bootstrap.el" << 'EOL'
;;; Minimal straight.el bootstrap for CI testing
(defun straight-bootstrap--version () "1.0.0")
(defun straight-bootstrap--dependencies () '())
(defun straight-bootstrap--bootstrap-version () 5)
(provide 'bootstrap)
EOL

echo "=== Contents of $STRAIGHT_DIR/bootstrap.el ==="
cat "$STRAIGHT_DIR/bootstrap.el"
echo -e "\n=== End of file ===\n"

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
