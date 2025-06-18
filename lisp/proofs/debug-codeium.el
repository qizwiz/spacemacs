;;; debug-codeium.el --- Debug Codeium configuration  -*- lexical-binding: t; -*-

;; Find all Codeium-related symbols
(message "=== Codeium Symbols ===")
(dolist (sym (apropos-internal "codeium-" 'boundp))
  (message "%s = %S" sym (symbol-value sym)))

;; Find all variables containing 'codeium' in their value
(message "\n=== Variables with Codeium in Value ===")
(dolist (var (apropos-value "codeium"))
  (message "%s = %S" var (symbol-value var)))

;; Check for API key in standard locations
(message "\n=== API Key Check ===")
(dolist (var '(codeium-api-key codeium/metadata/api-key))
  (when (boundp var)
    (message "Found API key in %s" var)))

;; Check auth info
(message "\n=== Auth Info ===")
(when (require 'auth-source nil t)
  (let ((creds (auth-source-search :host "codeium.com")))
    (if creds
        (message "Found auth info: %S" (mapcar (lambda (c) (plist-get c :user)) creds))
      (message "No auth info found in auth-source"))))

;; Check environment variables
(message "\n=== Environment Variables ===")
(dolist (env '("CODEIUM_API_KEY" "CODEIUM_APIKEY" "WINDSURF_API_KEY"))
  (when-let ((val (getenv env)))
    (message "%s is set" env)))

;; Check for custom configuration
(message "\n=== Custom Configuration ===")
(when (boundp 'custom-file)
  (when (file-exists-p custom-file)
    (with-temp-buffer
      (insert-file-contents custom-file)
      (when (re-search-forward "codeium" nil t)
        (message "Found Codeium configuration in %s" custom-file)
        (goto-char (point-min))
        (while (re-search-forward "(setq \(codeium-[^ )]+\)" nil t)
          (let ((var (intern (match-string 1))))
            (when (boundp var)
              (message "  %s = %S" var (symbol-value var)))))))))

(message "\nDebugging complete")
