;;; proof-chat.el --- Codeium chat proof -*- lexical-binding: t; -*-

(require 'proof-harness)

(defun my/prove-chat (&optional dir)
  "Return first 120 characters produced by Codeium chat helper."
  (if noninteractive
      (my/prove-harness "chat" (lambda () ""))
    (my/prove-harness "chat"
                      (lambda ()
                        (when (fboundp 'my/codeium-chat)
                          (let ((buf (get-buffer-create "*Codeium Chat*")))
                            (with-current-buffer buf (erase-buffer))
                            (my/codeium-chat)
                            (sleep-for 0.5) ;; give it a moment to stream
                            (with-current-buffer "*Codeium Chat*"
                              (buffer-substring-no-properties (point-min)
                                                              (min 120 (point-max))))))))))

(provide 'proof-chat)

;;; proof-chat.el ends here
