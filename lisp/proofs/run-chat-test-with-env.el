;;; run-chat-test-with-env.el --- Test Codeium chat with environment setup  -*- lexical-binding: t; -*-

(message "=== Starting Codeium Chat Test with Environment Setup ===\n")

;; 1. Add lisp directory to load-path
(let ((lisp-dir (expand-file-name "lisp" (file-name-directory (file-truename user-emacs-directory)))))
  (when (file-directory-p lisp-dir)
    (add-to-list 'load-path lisp-dir)))

;; 2. Set up the environment
(load (expand-file-name "setup-codeium-env.el" (file-name-directory load-file-name)) nil 'nomessage)

;; 3. Load codeium-extras with error handling
(condition-case err
    (require 'codeium-extras)
  (error
   (message "❌ Error loading codeium-extras: %S" err)
   (message "Current load-path: %S" load-path)
   (signal (car err) (cdr err))))

;; 3. Define test function
(defun test-codeium-chat ()
  "Test the Codeium chat functionality with environment setup."
  (message "\n=== Testing Codeium Chat ===")
  (let ((test-prompt "Hello, can you explain what this code does?"))
    (message "Sending test prompt: %s" test-prompt)
    (let ((response (codeium-chat--send-message test-prompt)))
      (if response
          (progn
            (message "✅ Chat test passed")
            (message "Response: %s" (substring response 0 (min 200 (length response))))
            t)
        (message "❌ Chat test failed: No response received")
        nil))))

;; 4. Run the test
(condition-case err
    (progn
      (require 'codeium)
      (message "Codeium loaded successfully")
      (if (fboundp 'codeium-chat--send-message)
          (if (test-codeium-chat)
              (progn
                (message "✅ All tests passed")
                (kill-emacs 0))
            (message "❌ Chat test failed")
            (kill-emacs 1))
        (message "❌ codeium-chat--send-message is not available")
        (kill-emacs 1)))
  (error
   (message "❌ Error during test: %S" err)
   (kill-emacs 1)))

(message "\n=== Test complete ===\n")
