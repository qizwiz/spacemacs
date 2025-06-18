;;; proof-explain-region.el --- Codeium explain-region proof -*- lexical-binding: t; -*-

(require 'proof-harness)

(defun my/prove-explain-region (&optional dir)
  "Return first 120 characters from Codeium explain-region helper.
Explain a dummy C statement and return first 120 chars of the explanation."
  (if noninteractive
      (my/prove-harness "explain-region" (lambda () ""))
    (my/prove-harness "explain-region"
                      (lambda ()
                        (when (fboundp 'my/codeium-explain-region)
                          (with-temp-buffer
                            (insert "int x = 0;")
                            (set-mark (point-min))
                            (goto-char (point-max))
                            (let ((mark-active t))
                              (my/codeium-explain-region))
                            (sleep-for 0.5)
                            (with-current-buffer "*Codeium Explain*"
                              (buffer-substring-no-properties (point-min)
                                                               (min 120 (point-max))))))))))

(provide 'proof-explain-region)

;;; proof-explain-region.el ends here
