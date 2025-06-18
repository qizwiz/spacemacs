;; Add lisp directories to load path
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/proofs"))
;; Add Codeium package directory to load path
(let ((codeium-dir (expand-file-name "~/.emacs.d/elpa/31.0/develop/codeium-20241112.154602")))
  (when (file-directory-p codeium-dir)
    (add-to-list 'load-path codeium-dir)
    (message "✅ Added Codeium to load path: %s" codeium-dir)))

;; Mock the read-string function to automatically respond to the authentication prompt
(defun read-string (prompt &optional initial-input history default-value inherit-input-method)
  (princ (format "DEBUG: read-string called with prompt: %s\n" prompt))
  (if (string-match-p "No Codeium API key found" prompt)
      (progn
        (princ "DEBUG: Auto-responding 'auto' to authentication prompt\n")
        "auto")
    (let ((inhibit-message t))
      (read-from-minibuffer prompt initial-input nil nil history default-value inherit-input-method))))

;; Simple debug message function
(defun debug-print (format-string &rest args)
  (let ((msg (apply 'format format-string args)))
    (princ (concat "DEBUG: " msg "\n"))
    (message "%s" msg)))

;; Define a mock codeium-state structure
(defvar codeium-state
  '((api_server_url . "https://test-api.codeium.com")
    (workspace . "test-workspace")
    (api_key . "test-api-key")))

;; Mock codeium-request-synchronously for testing
(defun codeium-request-synchronously (endpoint state params)
  "Mock version that returns a proper response structure."
  (cons 'dummy-response
        (format "I'm sorry, but I couldn't connect to the Codeium chat service. This is a fallback response for testing.

Your query was: %s"
                (cdr (assoc 'content (car (cdr (assoc 'messages params))))))))

;; Mock codeium-init to avoid actual initialization
(defun codeium-init ()
  "Mock initialization that just sets up the state."
  (setq codeium-state
        '((api_server_url . "https://test-api.codeium.com")
          (workspace . "test-workspace")
          (api_key . "test-api-key")))
  codeium-state)

;; Set up test state
(setq codeium-chat-history nil)

;; Skip actual Codeium initialization since we're using mocks

(condition-case err
    (require 'codeium-extras)
  (error
   (message "❌ Error loading codeium-extras: %S" err)
   (message "Current load-path: %S" load-path)
   (kill-emacs 1)))

(message "✅ Successfully loaded codeium-extras")
(message "Testing Codeium chat...")
(condition-case err
    (let* ((response (codeium-chat--send-message "Hello, can you explain what this code does?")))
      (if (and (stringp response)
               (not (string= response "404"))
               (string-match-p "fallback response" (downcase response)))
          (progn
            (message "✅ Chat test passed with fallback response")
            (message "Response: %s" (substring response 0 (min 200 (length response))))
            (kill-emacs 0))
        (progn
          (message "❌ Chat test failed: Unexpected response")
          (message "Expected fallback response, got: %S" response)
          (kill-emacs 1))))
  (error
   (message "❌ Error in chat test: %S" err)
   (message "Backtrace: %S" (with-output-to-string (backtrace)))
   (kill-emacs 1)))
