;;; setup-codeium-env.el --- Setup environment for Codeium in batch mode  -*- lexical-binding: t; -*-

(message "=== Setting up Codeium environment ===\n")

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

;; 2. Ensure Codeium is installed and get its build directory
(message "\n2. Setting up Codeium...")
(let ((codeium-build-dir (expand-file-name "straight/build/codeium" user-emacs-directory)))
  (unless (file-exists-p (expand-file-name "codeium.el" codeium-build-dir))
    (message "   Installing Codeium...")
    (straight-use-package
     '(codeium :type git :host github :repo "Exafunction/codeium.el")))
  
  ;; Add build directory to load-path
  (add-to-list 'load-path codeium-build-dir)
  (message "   Added to load-path: %s" codeium-build-dir)
  
  ;; Load autoloads
  (let ((autoloads (expand-file-name "codeium-autoloads.el" codeium-build-dir)))
    (when (file-exists-p autoloads)
      (load autoloads nil 'nomessage)
      (message "   Loaded autoloads from: %s" autoloads))))

;; 3. Verify the setup
(message "\n3. Verifying setup...")
(let ((codeium-el (locate-library "codeium")))
  (if codeium-el
      (message "   ✓ Codeium found at: %s" codeium-el)
    (message "   ✗ Codeium not found in load-path")))

;; 4. Print load-path for debugging
(message "\n4. Current load-path:")
(dolist (dir load-path)
  (when (and dir (stringp dir) (file-directory-p dir))
    (when (string-match-p "codeium" dir)
      (message "   - %s" dir))))

(message "\n=== Environment setup complete ===\n")
