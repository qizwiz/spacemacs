;;; run-with-harness.el --- Run tests with proof harness  -*- lexical-binding: t; -*-

(message "=== Starting Test with Proof Harness ===\n")

;; 1. Set up test authentication first
(condition-case err
    (load (expand-file-name "setup-test-auth.el" (file-name-directory load-file-name)) 
          nil 'nomessage)
  (error
   (message "⚠️ Could not load test auth setup: %S" err)))

;; 2. Load the proof harness
(load (expand-file-name "proof-harness.el" (file-name-directory load-file-name)) nil 'nomessage)

;; 3. Load codeium-extras
(condition-case err
    (require 'codeium-extras)
  (error
   (message "❌ Error loading codeium-extras: %S" err)
   (message "Current load-path: %S" load-path)
   (kill-emacs 1)))

;; 3. Test function
(defun test-codeium-chat ()
  "Test the Codeium chat functionality with the proof harness."
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
    (if (fboundp 'codeium-chat--send-message)
        (if (test-codeium-chat)
            (progn
              (message "✅ All tests passed")
              (kill-emacs 0))
          (message "❌ Chat test failed")
          (kill-emacs 1))
      (message "❌ codeium-chat--send-message is not available")
      (kill-emacs 1))
  (error
   (message "❌ Error during test: %S" err)
   (kill-emacs 1)))

(message "\n=== Test complete ===\n")
