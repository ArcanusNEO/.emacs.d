(delete-selection-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
;;(global-display-line-numbers-mode 1)
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

(setq auto-save-default nil)
(setq bookmark-save-flag nil)
(setq create-lockfiles nil)
(setq make-backup-files nil)
(save-place-mode 1)

(setq-default indent-tabs-mode nil)
(setq-default tab-always-indent 'complete)
(setq-default tab-width 2)
(setq-default truncate-lines t)
(setq-default word-wrap t)
(setq line-move-visual nil)

(setq inhibit-startup-message t)
(setq search-whitespace-regexp "[-_ \t\n]+")
(defalias 'yes-or-no-p 'y-or-n-p)
(setq use-short-answers t)

(setq-default c-default-style "java")
