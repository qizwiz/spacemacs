;;; setup-test-auth.el --- Set up test authentication for Codeium  -*- lexical-binding: t; -*-

(message "=== Setting up test authentication ===\n")

(require 'auth-source)

;; 1. Create a test auth-source file
(let* ((auth-file (expand-file-name "test-authinfo.gpg" (file-name-directory load-file-name)))
       (auth-data "machine api.codeium.com login test@example.com password test-api-key-123"))
  
  (with-temp-file auth-file
    (insert auth-data))
  
  (message "Created test auth file at: %s" auth-file)
  
  ;; Add to auth-sources
  (add-to-list 'auth-sources auth-file)
  (message "Added to auth-sources: %s" auth-file))

;; 2. Set the auth-source search to be non-interactive
(setq auth-source-do-cache t)
(setq auth-sources '("~/.authinfo.gpg" "~/.authinfo" "~/.netrc"))

;; 3. Test authentication
(message "\n=== Testing authentication ===")
(condition-case err
    (let ((creds (auth-source-search :host "api.codeium.com"
                                   :max 1
                                   :require '(:user :secret))))
      (if creds
          (let ((secret (plist-get (car creds) :secret)))
            (message "✓ Found credentials for api.codeium.com")
            (message "   User: %s" (or (plist-get (car creds) :user) "<none>"))
            (message "   Secret: %s" (if (functionp secret) (funcall secret) "<hidden>")))
        (message "✗ No credentials found for api.codeium.com")))
  (error
   (message "✗ Error during auth test: %S" err)))

(message "\n=== Test authentication setup complete ===\n")

(provide 'setup-test-auth)
