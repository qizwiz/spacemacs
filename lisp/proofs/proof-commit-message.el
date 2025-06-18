;;; proof-commit-message.el --- Codeium commit message proof -*- lexical-binding: t; -*-

(require 'proof-harness)

(defun my/prove-commit-message (&optional dir)
  "Return first 120 characters of a Codeium-generated commit message for DIR."
  (if noninteractive
      (my/prove-harness "commit-message" (lambda () ""))
    (my/prove-harness
     "commit-message"
     (lambda ()
       (let ((default-directory (or dir default-directory)))
         (with-temp-buffer
           (let ((major-mode 'git-commit-mode))
             (when (fboundp 'my/codeium--insert-commit-message)
               (my/codeium--insert-commit-message))
             (buffer-substring-no-properties
              (point-min)
              (min 120 (point-max))))))))))

(provide 'proof-commit-message)

;;; proof-commit-message.el ends here
