;;; find-codeium.el --- Locate Codeium package and API key  -*- lexical-binding: t; -*-

(message "=== Starting Codeium search ===\n")

;; 1. Find all ELPA directories
(message "1. Searching for ELPA directories...")
(let ((elpa-dirs
       (append
        (file-expand-wildcards "~/.emacs.d/elpa/*")
        (file-expand-wildcards "~/.emacs.d/elpa/*/*")
        (file-expand-wildcards "/usr/local/share/emacs/*/site-lisp/*")
        (file-expand-wildcards "/opt/homebrew/share/emacs/site-lisp/*"))))
  (dolist (dir elpa-dirs)
    (when (and (file-directory-p dir)
               (or (file-exists-p (expand-file-name "codeium.el" dir))
                   (file-exists-p (expand-file-name "codeium/codeium.el" dir))
                   (file-exists-p (expand-file-name "codeium-*/codeium.el" dir))))
      (message "   Found possible Codeium in: %s" dir)
      (add-to-list 'load-path dir))))

;; 2. Try to load Codeium
(message "\n2. Attempting to load Codeium...")
(condition-case err
    (progn
      (require 'codeium nil t)
      (if (featurep 'codeium)
          (message "   ✓ Successfully loaded Codeium")
        (message "   ✗ Failed to load Codeium")))
  (error
   (message "   ✗ Error loading Codeium: %S" err)))

;; 3. Check for API key in various locations
(message "\n3. Checking for API key in common locations...")

;; 3.1 Environment variables
(message "   Environment variables:")
(dolist (var '("CODEIUM_API_KEY" "CODEIUM_APIKEY" "WINDSURF_API_KEY"))
  (let ((val (getenv var)))
    (message "   - %s = %s" var (if val "[set]" "[not set]"))))

;; 3.2 Custom file
(message "\n   Custom file:")
(if (boundp 'custom-file)
    (if (and custom-file (file-exists-p custom-file))
        (progn
          (message "   - Found: %s" custom-file)
          (with-temp-buffer
            (insert-file-contents custom-file)
            (goto-char (point-min))
            (if (re-search-forward "codeium-.*api-key" nil t)
                (message "     Contains Codeium API key configuration")
              (message "     No Codeium API key found"))))
      (message "   - Not found: %s" (or custom-file "not set")))
  (message "   - custom-file not bound"))

;; 3.3 Auth sources
(message "\n   Auth sources:")
(if (require 'auth-source nil t)
    (let ((creds (auth-source-search :host "codeium")))
      (if creds
          (progn
            (message "   - Found auth info for Codeium:")
            (dolist (cred creds)
              (message "     - User: %s, Host: %s" 
                       (or (plist-get cred :user) "<none>")
                       (or (plist-get cred :host) "<none>"))))
        (message "   - No auth info found for Codeium")))
  (message "   - auth-source not available"))

;; 4. Check for Codeium in init files
(message "\n4. Checking init files for Codeium configuration:")
(dolist (file (list user-init-file "~/.spacemacs" "~/.emacs.d/init.el" "~/.emacs"))
  (when (and file (file-exists-p file))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (when (search-forward "codeium" nil t)
        (message "   - Found in: %s" file)))))

;; 5. Print final load path
(message "\n5. Final load path:")
(dolist (dir load-path)
  (when (string-match-p "codeium" (or dir ""))
    (message "   - %s" dir)))

(message "\n=== Search complete ===\n")
