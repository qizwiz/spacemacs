;;; proofs.el --- automated proof helpers -*- lexical-binding: t; -*-

;;; Commentary:
;; Generic harness and individual feature proofs for Spacemacs Codeium setup.
;; Usage: (require 'proofs) then call (my/prove-<feature>)

;;; Code:

(provide 'proofs)

(defconst my/proof-log-file (expand-file-name "proof.log" user-emacs-directory)
  "File where proof results are appended for live telemetry.")

(defun my/prove-harness (desc thunk)
  "Run zero-arg THUNK, emit a proof message, and return its result.
The message format is `PROOF:DESC:RESULT` so external scripts can grep it."
  (let ((res (funcall thunk)))
    (let ((msg (format "PROOF:%s:%s" desc (if (stringp res) res (prin1-to-string res)))))
      (message "%s" msg)
      (when (file-writable-p my/proof-log-file)
        (with-temp-buffer
          (insert msg "\n")
          (append-to-file (point-min) (point-max) my/proof-log-file)))
      res)))

(defun my/prove-commit-message (&optional dir)
  "Return first 120 characters of Codeium-generated commit message for DIR.
Assumes Codeium is authenticated and `my/codeium--insert-commit-message` exists."
  (let ((default-directory (or dir default-directory)))
    (with-temp-buffer
      (let ((major-mode 'git-commit-mode))
        (when (fboundp 'my/codeium--insert-commit-message)
          (my/codeium--insert-commit-message))
        (buffer-substring-no-properties (point-min)
                                        (min 120 (point-max)))))) )


;;; --- Proof Generator ---

(defun my/create-proof (feature)
  "Interactively scaffold a new proof helper for FEATURE.
Creates a `my/prove-FEATURE` stub in `proofs.el` and
adds FEATURE to the `PROOFS` variable in the Makefile if present."
  (interactive "sFeature name: ")
  (let* ((sym (intern (format "my/prove-%s" feature)))
         (file (or load-file-name (buffer-file-name)))
         (makefile (expand-file-name "../Makefile" (file-name-directory file)))
         (stub (format "\n(defun %s (&optional dir)\n  \"Proof stub for %s.  Replace BODY with real assertions.\"\n  (my/prove-harness \"%s\" (lambda ()\n                                   ;; TODO: implement proof\n                                   (format \"PROOF-%s-NOT-IMPLEMENTED\"))))\n" sym feature feature feature)))
    ;; Insert stub at end of current file (before footer)
    (save-excursion
      (goto-char (point-max))
      (search-backward ";;; proofs.el ends here")
      (beginning-of-line)
      (insert stub))
    ;; Update Makefile and CI workflow
    (when (file-exists-p makefile)
      ;; read and update PROOFS variable
      
      (with-temp-buffer
        (insert-file-contents makefile)
        (goto-char (point-min))
        (when (re-search-forward "^PROOFS *= *\\(.*\\)$" nil t)
          (let ((already (match-string 1)))
            (unless (string-match-p feature already)
              (replace-match (format "commit-message %s" feature) nil nil nil 1))))
        (write-region (point-min) (point-max) makefile)))
    ;; Update workflow yaml if present
    (let* ((workflow (expand-file-name "../.github/workflows/proofs.yml" (file-name-directory file)))
           (step (format "      - name: Run %s proof\n        run: |\n          make proof-%s\n" feature feature)))
      (when (file-exists-p workflow)
        (with-temp-buffer
          (insert-file-contents workflow)
          (goto-char (point-max))
          (unless (search-backward step nil t)
            (goto-char (point-max))
            (insert "\n" step))
          (write-region (point-min) (point-max) workflow))))
    (save-buffer)
    (message "Scaffolded %s; remember to implement the proof body." sym)))


(defun my/prove-chat (&optional dir)
  "Return first 120 chars from Codeium chat buffer after invoking chat command."
  (my/prove-harness "chat" (lambda ()
                               (when (fboundp 'my/codeium-chat)
                                 (let ((buf (get-buffer-create "*Codeium Chat*")))
                                   (with-current-buffer buf (erase-buffer))
                                   (my/codeium-chat)
                                   (sleep-for 0.5) ;; allow message to stream briefly
                                   (with-current-buffer "*Codeium Chat*"
                                     (buffer-substring-no-properties (point-min) (min 120 (point-max))))))))


(defun my/prove-explain-region (&optional dir)
  "Run explanation helper on dummy region and return explanation snippet."
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
                                                            (min 120 (point-max))))))))

(defun my/prove-generate-docstring (&optional dir)
  "Run docstring generator in temp Python function and return inserted string."
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
                                                          (min 120 (point-max)))))))


;;; --- Live Log Viewer ---

(defun my/view-proof-log ()
  "Tail `my/proof-log-file` with `auto-revert-tail-mode`. Creates file if absent."
  (interactive)
  (let ((buf (find-file-noselect my/proof-log-file)))
    (with-current-buffer buf
      (goto-char (point-max))
      (auto-revert-tail-mode 1))
    (pop-to-buffer buf)))

;;; --- Proof Registry ---

(defun my/list-capabilities ()
  "Run all `my/prove-*` functions and display pass/fail summary."
  (interactive)
  (let ((proofs (seq-filter (lambda (s)
                              (and (string-prefix-p "my/prove-" (symbol-name s))
                                   (fboundp s)))
                            (apropos-internal "^my/prove-" 'boundp)))
        (buf (get-buffer-create "*Proof Registry*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "%-25s %s\n%s\n" "Capability" "Result" (make-string 50 ?-)))
      (dolist (sym proofs)
        (let* ((result (condition-case e
                           (funcall sym)
                         (error (format "ERROR: %s" e))))
               (status (if (and (stringp result) (> (length result) 0) (not (string-match-p "NOT-IMPLEMENTED" result)))
                            "PASS" "FAIL")))
          (insert (format "%-25s %s\n" (string-remove-prefix "my/prove-" (symbol-name sym)) status))))
      (read-only-mode 1))
    (display-buffer buf)))

)
))
;;; proofs.el ends here
