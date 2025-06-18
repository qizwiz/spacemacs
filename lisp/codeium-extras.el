;;; codeium-extras.el - Additional Codeium functionality
;;; -*- lexical-binding: t; -*-

;; Stub for missing function
(unless (fboundp 'codeium-request-synchronously)
  (defun codeium-request-synchronously (url &optional params)
    "Stub for missing codeium-request-synchronously function."
    (message "codeium-request-synchronously called with URL: %S" url)
    nil))


;;;###autoload
(defvar codeium-chat-buffer "*Codeium Chat*"
  "Buffer name for Codeium chat.")

;;;###autoload
(defvar codeium-chat-history nil
  "List of (role . content) messages in the current chat.")

(defun codeium-chat--format-messages ()
  "Format chat history for the API.
Returns a list of plists with :role and :content keys."
  (mapcar (lambda (msg)
            (list :role (car msg)
                  :content (cdr msg)))
          codeium-chat-history))

(defun codeium-chat--fallback-response (prompt)
  "Generate a fallback response when Codeium chat is unavailable."
  (format "I'm sorry, but I couldn't connect to the Codeium chat service. Here's a fallback response to your query:

%s

Note: This is a fallback response because the chat service is currently unavailable. The original query was: %s"
          (cond
           ((string-match-p "explain" (downcase prompt))
            "This code appears to be part of a larger system. Without more context, I can't provide a detailed explanation. Could you share more about what specific part you'd like me to explain?")
           (t
            "I'd be happy to help! Could you provide more details about what you're trying to accomplish?"))
          prompt))

(defun codeium-chat--send-message (prompt &optional _state)
  "Send PROMPT to Codeium and return the response.
If STATE is not provided, the global codeium-state is used.
If codeium is not initialized, it will be initialized automatically.
If the chat service is unavailable, returns a fallback response."
  (let ((fallback-response (codeium-chat--fallback-response prompt)))
    (condition-case err
        (if (require 'codeium nil 'noerror)
            (let* ((state (if (and (boundp 'codeium-state) codeium-state)
                             codeium-state
                           (condition-case _
                               (progn
                                 (codeium-init)
                                 (when (boundp 'codeium-state)
                                   codeium-state))
                             (error nil))))
                   (codeium-chat-history (append codeium-chat-history
                                              (list (cons "user" prompt))))
                   (messages (codeium-chat--format-messages))
                   (response (if (not state)
                                fallback-response
                              (condition-case _
                                  (let ((result (codeium-request-synchronously
                                                'ChatCompletion
                                                state
                                                (list (cons 'messages messages)))))
                                    (if (and (consp result) (cdr result))
                                        (cdr result)
                                      fallback-response))
                                (error fallback-response)))))
              (push (cons "assistant" response) codeium-chat-history)
              response)
          fallback-response)
      (error
       (message "Codeium chat error: %S" err)
       fallback-response))))

(defun codeium-chat ()
  "Start or continue a chat with Codeium."
  (interactive)
  (let ((buf (get-buffer-create codeium-chat-buffer)))
    (with-current-buffer buf
      (unless (eq major-mode 'markdown-mode)
        (markdown-mode))
      (setq buffer-read-only nil)
      (let ((inhibit-read-only t))
        (when (zerop (buffer-size))
          (insert "# Codeium Chat\n\n"))))
    (pop-to-buffer buf)
    (let ((prompt (read-string "You: ")))
      (with-current-buffer buf
        (goto-char (point-max))
        (insert (format "\n\n**You:** %s\n" prompt))
        (let ((response (codeium-chat--send-message prompt)))
          (when response
            (insert (format "**Codeium:** %s\n" response))))))))

;;;###autoload
(defun codeium-explain-region (start end)
  "Explain the code in the region from START to END."
  (interactive "r")
  (message "Codeium: Explain region functionality not yet implemented"))

;;;###autoload
(defun codeium-generate-docstring ()
  "Generate a docstring for the function at point."
  (interactive)
  (message "Codeium: Generate docstring functionality not yet implemented"))

;;;###autoload
(defun codeium-insert-commit-message ()
  "Generate and insert a commit message based on the current changes."
  (interactive)
  (message "Codeium: Insert commit message functionality not yet implemented"))

(provide 'codeium-extras)

;; Local Variables:
;; lexical-binding: t
;; End:
