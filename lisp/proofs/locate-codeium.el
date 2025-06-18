;;; locate-codeium.el --- Find Codeium installation  -*- lexical-binding: t; -*-

(message "=== Locating Codeium Installation ===\n")

;; 1. Common installation directories to check
(defconst codeium-search-dirs
  '("~/.emacs.d/elpa/"
    "~/.emacs.d/elpa/*/"
    "~/.emacs.d/"
    "~/.emacs.d/straight/repos/"
    "~/.emacs.d/straight/build/"
    "/usr/local/share/emacs/"
    "/opt/homebrew/share/emacs/"
    "/usr/share/emacs/")
  "Directories to search for Codeium installation.")

;; 2. Search for Codeium files
(message "1. Searching for Codeium installation...")
(let ((found nil))
  (dolist (dir-pattern codeium-search-dirs)
    (dolist (dir (file-expand-wildcards dir-pattern))
      (when (file-directory-p dir)
        (dolist (subdir (directory-files dir t))
          (when (and (file-directory-p subdir)
                     (string-match-p "codeium" (downcase (file-name-nondirectory subdir))))
            (setq found t)
            (message "   Found: %s" subdir)
            (let ((codeium-el (expand-file-name "codeium.el" subdir)))
              (if (file-exists-p codeium-el)
                  (message "     - Contains: codeium.el")
                (message "     - No codeium.el found"))))))))
  (unless found
    (message "   No Codeium installation found in common locations")))

;; 3. Check for package.el metadata
(message "\n2. Checking package.el metadata...")
(let ((pkg-file (expand-file-name "~/.emacs.d/elpa/archives/melpa/archive-contents")))
  (if (file-exists-p pkg-file)
      (with-temp-buffer
        (insert-file-contents pkg-file)
        (goto-char (point-min))
        (if (re-search-forward "codeium" nil t)
            (message "   Codeium package found in package archive")
          (message "   Codeium package not found in package archive")))
    (message "   No package archive found at: %s" pkg-file)))

;; 4. Check for straight.el installation
(message "\n3. Checking for straight.el installation...")
(let ((straight-dir (expand-file-name "~/.emacs.d/straight/")))
  (if (file-exists-p straight-dir)
      (progn
        (message "   Found straight.el directory: %s" straight-dir)
        (let ((codeium-dir (car (file-expand-wildcards 
                                (expand-file-name "straight/repos/codeium*" 
                                                 (file-name-directory straight-dir))))))
          (if (and codeium-dir (file-directory-p codeium-dir))
              (message "   Found Codeium repository: %s" codeium-dir)
            (message "   No Codeium repository found in straight"))))
    (message "   straight.el not found")))

;; 5. Print current load-path
(message "\n4. Current load-path:")
(dolist (dir load-path)
  (when (and dir (file-directory-p dir))
    (when (or (string-match-p "codeium" (or dir ""))
              (file-exists-p (expand-file-name "codeium.el" dir)))
      (message "   - %s" dir)
      (let ((default-directory dir))
        (when (file-exists-p "codeium.el")
          (message "     Contains: codeium.el"))
        (when (file-exists-p "codeium")
          (message "     Contains: codeium/"))))))

(message "\n=== Search complete ===\n")
