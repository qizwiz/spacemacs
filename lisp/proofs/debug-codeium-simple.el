;;; debug-codeium-simple.el --- Simple Codeium debug script  -*- lexical-binding: t; -*-

(message "=== Loading Codeium package ===")
(require 'codeium nil t)

(message "\n=== Codeium Variables ===")
(dolist (sym (all-completions "codeium-" obarray 'boundp))
  (let ((var (intern sym)))
    (message "%s = %S" var (symbol-value var))))

(message "\n=== Environment Variables ===")
(dolist (env '("CODEIUM_API_KEY" "CODEIUM_APIKEY" "WINDSURF_API_KEY"))
  (when-let ((val (getenv env)))
    (message "%s = %s" env val)))

(message "\n=== Custom File ===")
(when (boundp 'custom-file)
  (message "Custom file: %s" (or custom-file "not set"))
  (when (and custom-file (file-exists-p custom-file))
    (message "Custom file exists")))

(message "\n=== Auth Sources ===")
(when (boundp 'auth-sources)
  (message "Auth sources: %S" auth-sources)
  (when (require 'auth-source nil t)
    (let ((creds (auth-source-search :host "codeium")))
      (if creds
          (message "Found auth info: %S" (mapcar (lambda (c) (plist-get c :user)) creds))
        (message "No auth info found in auth-source")))))
