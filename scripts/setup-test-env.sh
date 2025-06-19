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

# Also create straight-bootstrap.el in the home directory for tests that expect it there
HOME_EMACS_DIR="$HOME/.emacs.d"
mkdir -p "$HOME_EMACS_DIR/lisp/proofs"
cp "$TEST_DIR/lisp/proofs/straight-bootstrap.el" "$HOME_EMACS_DIR/lisp/proofs/straight-bootstrap.el"
echo "Copied straight-bootstrap.el to $HOME_EMACS_DIR/lisp/proofs/"

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
