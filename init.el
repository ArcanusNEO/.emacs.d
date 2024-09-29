(add-to-list 'load-path (expand-file-name "extern" user-emacs-directory))

(require 'goto-chg)
(require 'whole-line-or-region)
(require 'clang-format)
(require 'eglot)
(require 'ox-reveal)
(require 'sql-indent)

(whole-line-or-region-global-mode 1)
(delete-selection-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
;; (global-display-line-numbers-mode 1)
(global-prettify-symbols-mode 1)
(global-subword-mode 1)
(menu-bar-mode 0)

(put 'dired-find-alternate-file 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'upcase-region 'disabled nil)

(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8-unix)
(set-language-environment 'utf-8)
(set-terminal-coding-system 'utf-8-unix)

(setq-default auto-save-default nil)
(setq-default bookmark-save-flag nil)
(setq-default create-lockfiles nil)
(setq-default make-backup-files nil)
(save-place-mode 1)

(setq-default indent-tabs-mode nil)
(setq-default tab-always-indent 'complete)
(setq-default tab-width 2)
(setq-default truncate-lines t)
(setq-default word-wrap t)
(setq-default line-move-visual nil)
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)

(setq-default inhibit-startup-message t)
(setq-default search-whitespace-regexp "[-_ \t\n]+")
(setq-default use-short-answers t)
(setq-default display-time-24hr-format t)
(setq-default windmove-wrap-around t)
(setq-default split-width-threshold 1)

(add-hook 'js-json-mode-hook
          (lambda () (local-set-key (kbd "M-i") 'json-pretty-print-buffer)))
(defun eglot-major-hook ()
  (interactive)
  (eglot-ensure)
  (local-set-key (kbd "M-i") 'eglot-format))
(add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx")))
(add-hook 'nxml-mode-hook 'eglot-major-hook)
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode) .
               ("clangd" "--enable-config" "-j=4" "--pch-storage=memory"
                "--clang-tidy" "--all-scopes-completion"
                "--header-insertion=never" "--completion-style=detailed"
                "--fallback-style=GNU" "--background-index")))
(add-hook 'c-mode-hook 'eglot-major-hook)
(add-hook 'c++-mode-hook 'eglot-major-hook)
;; pylsp
(add-hook 'python-mode-hook 'eglot-major-hook)
;; typescript-language-server
(add-hook 'js-mode-hook 'eglot-major-hook)
;; jdtls
(add-hook 'java-mode-hook 'eglot-major-hook)
;; sql-indent
(add-hook 'sql-mode-hook
          (lambda ()
             (sqlind-minor-mode 1)
             (local-set-key (kbd "M-i") 'align-current)))

(global-set-key (kbd "C-x k") 'kill-this-buffer)
(defun kill-terminal ()
  (interactive)
  (condition-case nil (delete-frame) (error (kill-emacs))))
(global-set-key (kbd "C-x C-c") 'kill-terminal)
(global-set-key (kbd "C-\\") 'goto-last-change)
(define-key key-translation-map (kbd "<backtab>") (kbd "C-x o"))
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)

(setq-default org-reveal-root "https://testingcf.jsdelivr.net/npm/reveal.js")

(setq-default custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
