;;; install-codeium-straight.el --- Install Codeium using straight.el  -*- lexical-binding: t; -*-

(message "=== Installing Codeium using straight.el ===\n")

;; 1. Set up straight.el
(message "1. Setting up straight.el...")
(setq straight-repository-branch "develop")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; 2. Install Codeium
(message "\n2. Installing Codeium from GitHub...")
(straight-use-package
 '(codeium :type git :host github :repo "Exafunction/codeium.el"))

;; 3. Verify installation
(message "\n3. Verifying installation...")
(let ((codeium-dir (locate-library "codeium" 'no-suffix 'no-error)))
  (if codeium-dir
      (progn
        (message "   ✓ Codeium found at: %s" codeium-dir)
        ;; Check for codeium.el
        (let ((codeium-el (expand-file-name "codeium.el" (file-name-directory codeium-dir))))
          (if (file-exists-p codeium-el)
              (message "   ✓ Found codeium.el at: %s" codeium-el)
            (message "   ✗ codeium.el not found in: %s" (file-name-directory codeium-dir))))
        
        ;; Load autoloads
        (let ((autoloads (expand-file-name "codeium-autoloads.el" (file-name-directory codeium-dir))))
          (if (file-exists-p autoloads)
              (progn
                (message "   ✓ Found autoloads at: %s" autoloads)
                (load autoloads)
                (message "   ✓ Loaded autoloads"))
            (message "   ✗ Autoloads not found"))))
    
    (message "   ✗ Codeium not found in load-path")))

;; 4. Check available Codeium functions
(message "\n4. Checking available Codeium functions:")
(let ((codeium-funcs (all-completions "codeium-" obarray 'functionp)))
  (if codeium-funcs
      (progn
        (message "   Found %d Codeium functions:" (length codeium-funcs))
        (dolist (func (sort codeium-funcs 'string<))
          (message "   - %s" func)))
    (message "   No Codeium functions found")))

;; 5. Initialize Codeium
(message "\n5. Initializing Codeium...")
(condition-case err
    (progn
      (require 'codeium)
      (message "   ✓ Codeium loaded successfully")
      (when (fboundp 'codeium-init)
        (codeium-init)
        (message "   ✓ Codeium initialized")))
  (error
   (message "   ✗ Error initializing Codeium: %S" err)))

(message "\n=== Installation complete ===\n")
