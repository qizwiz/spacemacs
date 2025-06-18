;;; check-parens.el --- batch paren checker -*- lexical-binding: t; -*-
;; Ensure project lisp directories are on `load-path`
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/proofs"))

(let ((dirs '("~/.emacs.d/lisp" "~/.emacs.d/lisp/proofs")))
  (dolist (dir dirs)
    (dolist (file (directory-files-recursively (expand-file-name dir) "\\.el$"))
      (load file nil t t)
      (check-parens))))
(princ "LINT-OK\n")
;;; check-parens.el ends here
