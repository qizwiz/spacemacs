;; Minimal init file for Codeium tests
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'dash)
  (package-refresh-contents)
  (package-install 'dash))
(require 'dash)

;; Add test directories to load path
(add-to-list 'load-path "/tmp/emacs-test/lisp")
(add-to-list 'load-path "/tmp/emacs-test/lisp/proofs")

;; Debug: Print load path and check if files exist
(message "Current directory: %s" default-directory)
(message "Load path: %S" load-path)
(mapc (lambda (file)
        (let ((found (locate-library file)))
          (message "Checking for %s: %s" file (if found (concat "found at " found) "not found"))))
      '("proof-harness" "proof-commit-message" "proof-chat" 
        "proof-explain-region" "proof-generate-docstring"))

;; Try to load proof harness
(condition-case err
    (require 'proof-harness)
  (error 
   (message "Failed to load proof-harness: %s" (error-message-string err))
   (message "Trying to load files directly...")
   (load "proof-harness.el" nil t)))

;; Run the tests with error handling
(setq proof-results nil)
(mapc (lambda (proof) 
        (condition-case err
            (push (funcall proof) proof-results)
          (error
           (push (format "ERROR in %s: %s" 
                        (symbol-name proof)
                        (error-message-string err))
                 proof-results))))
      (list #'my/prove-commit-message
            #'my/prove-chat
            #'my/prove-explain-region
            #'my/prove-generate-docstring))

;; Print results
(princ "\n=== Test Results ===\n")
(princ (mapconcat 'identity (reverse proof-results) "\n"))

;; Exit with appropriate status
(if (seq-every-p (lambda (r) (string-match-p "PASS\\|SKIP" r)) proof-results)
    (progn
      (princ "\n\nAll tests passed!")
      (kill-emacs 0))
  (princ "\n\nSome tests failed!")
  (kill-emacs 1))
