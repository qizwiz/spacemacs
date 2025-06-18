(require 'codeium-extras)

(defun test-codeium-chat ()
  "Test the Codeium chat functionality."
  (interactive)
  (let ((test-prompt "Hello, can you explain what this code does?"))
    (message "Testing Codeium chat with prompt: %s" test-prompt)
    (let ((response (codeium-chat--send-message test-prompt)))
      (if response
          (progn
            (message "✅ Chat test passed. Response: %s" (substring response 0 50))
            t)
        (message "❌ Chat test failed: No response received")
        nil))))

;; Run the test when loaded in batch mode
(when noninteractive
  (test-codeium-chat))
