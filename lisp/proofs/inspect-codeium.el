;;; inspect-codeium.el --- Inspect Codeium configuration  -*- lexical-binding: t; -*-

(message "=== Starting Codeium inspection ===\n")

;; 1. Check if Codeium is installed
(message "1. Checking if Codeium is installed...")
(if (require 'codeium nil t)
    (message "   ✓ Codeium package is installed")
  (message "   ✗ Codeium package is NOT installed"))

;; 2. Look for Codeium files in load-path
(message "\n2. Searching for Codeium files in load-path:")
(dolist (dir load-path)
  (when (and (file-directory-p dir)
             (file-exists-p (expand-file-name "codeium.el" dir)))
    (message "   Found: %s/codeium.el" dir)))

;; 3. Check for API key in environment
(message "\n3. Checking environment variables:")
(dolist (var '("CODEIUM_API_KEY" "CODEIUM_APIKEY" "WINDSURF_API_KEY"))
  (let ((val (getenv var)))
    (message "   %s = %s" var (if val (concat "****" (substring val -4)) "not set"))))

;; 4. Check auth sources
(message "\n4. Checking auth sources:")
(if (require 'auth-source nil t)
    (let ((creds (auth-source-search :host "codeium")))
      (if creds
          (progn
            (message "   Found auth info for Codeium:")
            (dolist (cred creds)
              (message "   - User: %s, Host: %s" 
                       (or (plist-get cred :user) "<none>")
                       (or (plist-get cred :host) "<none>"))))
        (message "   No auth info found for Codeium in auth sources")))
  (message "   auth-source not available"))

;; 5. Check custom file
(message "\n5. Checking custom file:")
(if (boundp 'custom-file)
    (if (and custom-file (file-exists-p custom-file))
        (progn
          (message "   Custom file exists: %s" custom-file)
          (with-temp-buffer
            (insert-file-contents custom-file)
            (goto-char (point-min))
            (if (search-forward "codeium" nil t)
                (message "   Found Codeium configuration in custom file")
              (message "   No Codeium configuration found in custom file"))))
      (message "   Custom file not found: %s" (or custom-file "not set")))
  (message "   custom-file variable not bound"))

;; 6. Check for Codeium in init files
(message "\n6. Checking init files for Codeium configuration:")
(dolist (file (list user-init-file "~/.emacs.d/init.el" "~/.emacs"))
  (when (and file (file-exists-p file))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (when (search-forward "codeium" nil t)
        (message "   Found in: %s" file)))))

(message "\n=== Inspection complete ===\n")
