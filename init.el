(add-to-list 'load-path "/etc/emacs/extern")
(add-to-list 'load-path (expand-file-name "extern" user-emacs-directory))

(require 'goto-chg)
(require 'whole-line-or-region)
(require 'clang-format)
(require 'eglot)
(require 'ox-reveal)
(require 'sql-indent)
(require 'xclip)

(whole-line-or-region-global-mode 1)
(delete-selection-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-prettify-symbols-mode 1)
(global-subword-mode 1)
(menu-bar-mode 0)
(electric-pair-mode 0)
(winner-mode 1)
(xclip-mode 0)

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

(setq-default viper-inhibit-startup-message 't)
(setq-default viper-expert-level '5)

(setq-default inhibit-startup-message t)
(setq-default search-whitespace-regexp "[-_ \t\n]+")
(setq-default use-short-answers t)
(setq-default display-time-24hr-format t)
(setq-default windmove-wrap-around t)
(setq-default split-width-threshold 1)
(setq-default comint-process-echoes 0)
(setq-default indent-tabs-mode nil)
(setq-default tab-always-indent 'complete)
(setq-default tab-width 2)
(setq-default truncate-lines t)
(setq-default word-wrap t)
(setq-default line-move-visual nil)
(setq-default completion-ignore-case t)
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)
(setq-default c-basic-offset 2)
(setq-default js-indent-level 2)

(add-to-list 'auto-mode-alist '("\\.[cm]js\\'" . javascript-mode))

(defun eglot-major-hook ()
  (interactive)
  (display-line-numbers-mode 1)
  (eglot-ensure)
  (local-set-key (kbd "C-M-i") 'eglot-format))

(add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx")))
(add-hook 'nxml-mode-hook 'eglot-major-hook)

(add-hook 'js-json-mode-hook
          (lambda () (local-set-key (kbd "C-M-i") 'json-pretty-print-buffer)))

(defun c-indent-then-complete ()
  (interactive)
  (if (= 0 (c-indent-line-or-region))
      (completion-at-point)))
(defun cc-mode-hook ()
  (interactive)
  (eglot-major-hook)
  (local-set-key (kbd "TAB") 'c-indent-then-complete))
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode) .
               ("clangd" "--enable-config" "--pch-storage=memory"
                "--clang-tidy" "--all-scopes-completion"
                "--header-insertion=never" "--completion-style=detailed"
                "--fallback-style=GNU" "--background-index")))
(add-hook 'c-mode-hook 'cc-mode-hook)
(add-hook 'c++-mode-hook 'cc-mode-hook)

;; pylsp
(add-hook 'python-mode-hook 'eglot-major-hook)

;; typescript-language-server
(add-hook 'js-mode-hook 'eglot-major-hook)

;; jdtls
(add-hook 'java-mode-hook 'cc-mode-hook)

;; sql-indent
(add-hook 'sql-mode-hook
          (lambda ()
            (sqlind-minor-mode 1)
            (local-set-key (kbd "C-M-i") 'align-current)))

(global-set-key (kbd "C-x k") 'kill-current-buffer)
(defun kill-terminal ()
  (interactive)
  (condition-case nil (delete-frame) (error (kill-emacs))))
(global-set-key (kbd "C-x C-c") 'kill-terminal)
(global-set-key (kbd "C-\\") 'goto-last-change)
(define-key key-translation-map (kbd "<backtab>") (kbd "C-x o"))
(global-set-key (kbd "C-z") 'xclip-mode)

(setq-default custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
