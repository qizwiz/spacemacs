;; Minimal straight.el bootstrap for CI testing
;; This is a minimal implementation that just provides the necessary functions
;; to avoid errors during testing.

(defun straight-bootstrap-fetch-recipes (&optional from-version)
  "Minimal implementation to avoid errors during testing."
  (message "Skipping straight.el recipe fetch in test environment"))

(defun straight-bootstrap-download-package (package version)
  "Minimal implementation to avoid errors during testing."
  (message "Skipping package download in test environment"))

(provide 'straight-bootstrap)
