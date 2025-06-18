;;; install-codeium.el --- Install and verify Codeium package  -*- lexical-binding: t; -*-

(message "=== Installing and Verifying Codeium ===\n")

;; 1. Set up package system
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; 2. Refresh package contents
(message "1. Refreshing package archives...")
(package-refresh-contents)

;; 3. Install Codeium
(message "\n2. Installing Codeium package...")
(unless (package-installed-p 'codeium)
  (package-install 'codeium)
  (message "   ✓ Codeium installed"))

;; 4. Verify installation
(message "\n3. Verifying installation...")
(let ((codeium-dir (locate-library "codeium" 'no-suffix 'no-error)))
  (if codeium-dir
      (progn
        (message "   ✓ Codeium found at: %s" codeium-dir)
        ;; 5. Check for codeium.el
        (let ((codeium-el (expand-file-name "codeium.el" (file-name-directory codeium-dir))))
          (if (file-exists-p codeium-el)
              (message "   ✓ Found codeium.el at: %s" codeium-el)
            (message "   ✗ codeium.el not found in: %s" (file-name-directory codeium-dir))))
        
        ;; 6. Check for autoloads
        (let ((autoloads (expand-file-name "codeium-autoloads.el" (file-name-directory codeium-dir))))
          (if (file-exists-p autoloads)
              (progn
                (message "   ✓ Found autoloads at: %s" autoloads)
                (load autoloads)
                (message "   ✓ Loaded autoloads"))
            (message "   ✗ Autoloads not found"))))
    
    (message "   ✗ Codeium not found in load-path")))

;; 7. Check available Codeium functions
(message "\n4. Checking available Codeium functions:")
(let ((codeium-funcs (all-completions "codeium-" obarray 'functionp)))
  (if codeium-funcs
      (progn
        (message "   Found %d Codeium functions:" (length codeium-funcs))
        (dolist (func (sort codeium-funcs 'string<))
          (message "   - %s" func)))
    (message "   No Codeium functions found")))

;; 8. Check for chat functionality
(message "\n5. Checking for chat functionality:")
(if (fboundp 'codeium-chat)
    (message "   ✓ codeium-chat function is available")
  (message "   ✗ codeium-chat function is not available"))

(message "\n=== Installation check complete ===\n")
