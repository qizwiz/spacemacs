;;; check-packages.el --- Check package installations  -*- lexical-binding: t; -*-

(message "=== Checking Package System ===\n")

;; 1. Initialize package system
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; 2. List all installed packages
(message "1. Installed packages:")
(if package-alist
    (dolist (pkg package-alist)
      (let ((pkg-name (car pkg)))
        (when (or (string-prefix-p "codeium" (symbol-name pkg-name))
                  (string-prefix-p "windsurf" (symbol-name pkg-name)))
          (message "   - %s" pkg-name)
          (when (package-installed-p pkg-name)
            (let ((desc (cadr (assq pkg-name package-alist))))
              (message "     Version: %s" (package-version-join (package-desc-version desc)))
              (message "     Status: Installed"))))))
  (message "   No packages found in package-alist"))

;; 3. Check package directories
(message "\n2. Package directories:")
(dolist (dir (cons package-user-dir load-path))
  (when (and dir (file-directory-p dir))
    (let ((codeium-dir (expand-file-name "codeium" dir)))
      (when (file-exists-p codeium-dir)
        (message "   Found Codeium in: %s" codeium-dir)
        (let ((el-files (directory-files codeium-dir t "\\.el\\'")))
          (dolist (file el-files)
            (message "     - %s" (file-name-nondirectory file))))))))

;; 4. Check for Codeium in load-path
(message "\n3. Codeium in load-path:")
(let ((found nil))
  (dolist (dir load-path)
    (when (and dir (file-directory-p dir))
      (let ((codeium-el (expand-file-name "codeium.el" dir)))
        (when (file-exists-p codeium-el)
          (setq found t)
          (message "   Found: %s" codeium-el)
          (with-temp-buffer
            (insert-file-contents codeium-el)
            (when (re-search-forward "def\(var\|const\)\s-+codeium-.*api-key" nil t)
              (message "     - Contains API key configuration")))))))
  (unless found
    (message "   No Codeium found in load-path")))

(message "\n=== Check complete ===\n")
