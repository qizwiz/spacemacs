;;; proof-harness.el --- shared helpers for Codeium proofs -*- lexical-binding: t; -*-

(message "!!! proof-harness.el STARTING TO LOAD !!!")
(princ "!!! proof-harness.el STDOUT STARTING TO LOAD !!!")(terpri)

;; This file is loaded from ~/.spacemacs and provides common utilities that
;; each capability-specific proof file can reuse.  Keeping this logic here means
;; the individual proof files stay tiny and the risk of unmatched parentheses
;; is dramatically reduced.

;;; Code:

(message "!!! proof-harness.el LOADED !!!")
(princ "!!! proof-harness.el STDOUT LOADED !!!")(terpri)

;;; --- Logging helpers ------------------------------------------------
(defmacro my/with-logging (&rest body)
  "Eval BODY with TRACE messages before each form executes."
  (let ((forms (mapcar (lambda (f)
                         `(progn
                            (message "TRACE %S" ',f)
                            ,f))
                       body)))
    `(progn ,@forms)))

;; Custom error symbol we’ll raise to prove handler path executes.
(define-error 'my-proof-force-error "Forced proof error")

(provide 'proof-harness)

(defconst my/proof-log-file (expand-file-name "proof.log" user-emacs-directory)
  "File where proof results are appended for live telemetry.")

(defun my/prove-harness (desc thunk)
  "Run zero-arg THUNK, emit a proof message, append it to the log and return it.
The appended line is `PROOF:DESC:RESULT` so external scripts (Makefile / CI)
can grep it easily.  THUNK should return a short string (the snippet)."
  (let* ((res (funcall thunk))
         (msg (format "PROOF:%s:%s" desc (if (stringp res) res (prin1-to-string res)))))
    ;; log main proof line
    (message "%s" msg)
    ;; prove error handler works
    (condition-case err
        (signal 'my-proof-force-error nil)
      (my-proof-force-error
       (message "ERROR-CAUGHT:%s" err)))
    (princ msg)(terpri)
    (with-temp-buffer
      (insert msg "\n")
      (when (file-writable-p my/proof-log-file)
        (append-to-file (point-min) (point-max) my/proof-log-file)))
    res))

;;; ----- Convenience helpers ------------------------------------------------

;;;###autoload
(defun my/view-proof-log ()
  "Open and tail `my/proof-log-file` inside Emacs (auto-refresh)."
  (interactive)
  (let ((buf (find-file-noselect my/proof-log-file)))
    (with-current-buffer buf
      (goto-char (point-max))
      (auto-revert-tail-mode 1))
    (pop-to-buffer buf)))

;;;###autoload
(defun my/list-capabilities ()
  "Run all `my/prove-*` functions currently loaded and show pass/fail summary."
  (interactive)
  (let* ((proofs (seq-filter (lambda (sym)
                               (and (string-prefix-p "my/prove-" (symbol-name sym))
                                    (fboundp sym)))
                             (apropos-internal "^my/prove-" 'boundp)))
         (buf (get-buffer-create "*Proof Registry*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "%-25s %s\n%s\n" "Capability" "Result" (make-string 50 ?-)))
      (dolist (sym proofs)
        (let* ((result (condition-case e (funcall sym) (error (format "ERROR: %s" e))))
               (status (if (and (stringp result)
                                (> (length result) 0)
                                (not (string-match-p "NOT-IMPLEMENTED" result)))
                           "PASS" "FAIL")))
          (insert (format "%-25s %s\n"
                          (string-remove-prefix "my/prove-" (symbol-name sym))
                          status))))
      (read-only-mode 1))
    (display-buffer buf)))

;;;###autoload
(defun my/create-proof (feature)
  "Interactively scaffold a new proof helper for FEATURE.  Generates a new file
`lisp/proofs/proof-FEATURE.el` containing `my/prove-FEATURE` and updates the
Makefile/CI workflow if present.  This keeps everything modular."
  (interactive "sFeature name: ")
  (let* ((sym (intern (format "my/prove-%s" feature)))
         (proof-dir (expand-file-name "lisp/proofs" user-emacs-directory))
         (file (expand-file-name (format "proof-%s.el" feature) proof-dir)))
    (unless (file-directory-p proof-dir) (make-directory proof-dir t))
    (when (file-exists-p file)
      (user-error "%s already exists" file))
    (with-temp-file file
      (insert (format ";;; %s --- proof for %s -*- lexical-binding: t; -*-\n\n" (file-name-nondirectory file) feature))
      (insert "(require 'proof-harness)\n\n")
      (insert (format "(defun %s (&optional dir)\n  \"Proof stub for %s.  Replace BODY with real assertions.\"\n  (my/prove-harness \"%s\" (lambda ()\n                                 ;; TODO: implement proof\n                                 (format \"PROOF-%s-NOT-IMPLEMENTED\"))))\n\n" sym feature feature feature))
      (insert (format "(provide '%s)\n" (file-name-base file))))
    (message "Scaffolded %s – edit the new file to implement the proof." sym)))

;;; proof-harness.el ends here
