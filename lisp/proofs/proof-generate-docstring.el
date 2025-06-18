;;; proof-generate-docstring.el --- Codeium docstring generation proof -*- lexical-binding: t; -*-

(require 'proof-harness)

(defun my/prove-generate-docstring (&optional dir)
  "Return first 120 characters from Codeium docstring helper."
  (if noninteractive
      (my/prove-harness "generate-docstring" (lambda () ""))
    (my/prove-harness "generate-docstring"
                    (lambda ()
                      (when (fboundp 'my/codeium-generate-docstring)
                        (with-temp-buffer
                          (python-mode)
                          (insert "def foo(a, b):\n    return a + b\n")
                          (goto-char (point-min))
                          (my/codeium-generate-docstring)
                          (sleep-for 0.5)
                          (buffer-substring-no-properties (point-min)
                                                          (min 120 (point-max)))))))))

(provide 'proof-generate-docstring)

;;; proof-generate-docstring.el ends here
