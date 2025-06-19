;;; proof-harness.el --- Proof harness for Codeium tests  -*- lexical-binding: t; -*-

;; This script sets up the environment for running Codeium tests in batch mode.
;; It handles:
;; 1. Setting up straight.el
;; 2. Installing and loading Codeium
;; 3. Setting up the load path for test files

(message "=== Starting Proof Harness ===\n")

;; Add lisp directory to load-path
(let ((lisp-dir (expand-file-name "lisp" (file-name-directory (file-truename user-emacs-directory)))))
  (when (file-directory-p lisp-dir)
    (add-to-list 'load-path lisp-dir)
    (message "Added to load-path: %s" lisp-dir)))

;; Set up straight.el
(message "\n=== Setting up straight.el ===")
(setq straight-repository-branch "develop")
(defvar bootstrap-version)

;; Try to get the test directory from the environment variable
(defvar test-dir (or (getenv "TEST_DIR") 
                    (file-name-directory (file-truename 
                                       (expand-file-name ".." (file-name-directory load-file-name))))))

;; Define the bootstrap file path
(defvar bootstrap-file
  (expand-file-name "straight/repos/straight.el/bootstrap.el" test-dir))

(message "Using test directory: %s" test-dir)
(message "Looking for bootstrap file at: %s" bootstrap-file)

;; Check if the bootstrap file exists
(if (file-exists-p bootstrap-file)
    (message "Found bootstrap file at: %s" bootstrap-file)
  (message "WARNING: Bootstrap file not found at: %s" bootstrap-file)
  (message "Directory contents: %S" (directory-files (file-name-directory bootstrap-file) t)))

;; Set up straight.el
(let ((bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (message "Bootstrap file not found, installing straight.el...")
    (with-temp-buffer
      (let ((bootstrap-src (expand-file-name "lisp/proofs/straight-bootstrap.el" test-dir)))
        (if (file-exists-p bootstrap-src)
            (progn
              (insert-file-contents-literally bootstrap-src)
              (eval-buffer)
              (message "Installed straight.el from %s" bootstrap-src))
          (message "ERROR: Could not find straight-bootstrap.el at %s" bootstrap-src)
          (kill-emacs 1)))))
  
  (if (file-exists-p bootstrap-file)
      (progn
        (load bootstrap-file nil 'nomessage)
        (message "Loaded straight.el from %s" bootstrap-file))
    (message "ERROR: Failed to load bootstrap file at %s" bootstrap-file)
    (kill-emacs 1)))

;; Set up Codeium
(message "\n=== Setting up Codeium ===")
(let ((codeium-build-dir (expand-file-name "straight/build/codeium" user-emacs-directory)))
  (unless (file-exists-p (expand-file-name "codeium.el" codeium-build-dir))
    (message "Installing Codeium...")
    (straight-use-package
     '(codeium :type git :host github :repo "Exafunction/codeium.el")))
  
  (add-to-list 'load-path codeium-build-dir)
  (message "Added to load-path: %s" codeium-build-dir)
  
  (let ((autoloads (expand-file-name "codeium-autoloads.el" codeium-build-dir)))
    (when (file-exists-p autoloads)
      (load autoloads nil 'nomessage)
      (message "Loaded autoloads from: %s" autoloads))))

;; Verify setup
(message "\n=== Verifying Setup ===")
(condition-case err
    (progn
      (require 'codeium)
      (message "✓ Codeium loaded successfully")
      (when (fboundp 'codeium-init)
        (codeium-init)
        (message "✓ Codeium initialized")))
  (error
   (message "❌ Error setting up Codeium: %S" err)
   (kill-emacs 1)))

(message "\n=== Proof Harness Ready ===\n")

;; Add any additional setup or test running code here

(provide 'proof-harness)
;;; proof-harness.el ends here
