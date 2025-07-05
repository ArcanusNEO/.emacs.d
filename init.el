(add-to-list 'load-path "/etc/emacs/extern")
(add-to-list 'load-path
             (expand-file-name "extern" user-emacs-directory))

(require 'dabbrev)
(require 'goto-chg)
(require 'whole-line-or-region)
(require 'cape)
(require 'cape-keyword)
(require 'yaml-mode)
(require 'csv-mode)
(require 'sql-indent)
(require 'clang-format)
(require 'eglot)
(require 'ox-reveal)
(require 'xclip)
(require 'corfu)

(whole-line-or-region-global-mode 1)
(delete-selection-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-prettify-symbols-mode 1)
(global-subword-mode 1)
(menu-bar-mode 0)
(tool-bar-mode 0)
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
(setq-default initial-scratch-message "")
(setq-default initial-major-mode 'text-mode)
(add-hook 'text-mode-hook #'turn-on-auto-fill)

(setq-default viper-inhibit-startup-message t)
(setq-default viper-expert-level 5)

(setq-default corfu-cycle t)
(setq-default corfu-preselect 'prompt)
(keymap-set corfu-map "TAB" #'corfu-next)
(keymap-set corfu-map "<backtab>" #'corfu-previous)
(custom-set-faces '(corfu-default ((t nil))))
(global-corfu-mode 1)
(unless (display-graphic-p)
  (require 'corfu-terminal)
  (corfu-terminal-mode 1))

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
(setq-default truncate-lines nil)
(setq-default word-wrap t)
(setq-default line-move-visual t)
(setq-default completion-ignore-case t)
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)
(setq-default c-basic-offset 2)
(setq-default js-indent-level 2)
;; (setq-default python-indent-offset 2)
(setq-default yaml-indent-offset 2)
(setq-default gdb-debuginfod-enable-setting nil)
(setq-default flymake-indicator-type nil)

(setq-default completion-at-point-functions
              `(,(cape-capf-super
                  #'tags-completion-at-point-function
                  #'cape-line #'cape-dabbrev
                  #'cape-keyword
                  #'cape-abbrev #'cape-dict
                  #'cape-file)))

(add-hook 'emacs-lisp-mode-hook
          #'(lambda ()
              (setq-local completion-at-point-functions
                          `(,(cape-capf-super
                              #'elisp-completion-at-point
                              #'cape-line #'cape-dabbrev
                              #'cape-abbrev #'cape-dict
                              #'cape-file)
                            t))
              (local-set-key (kbd "C-M-i")
                             #'(lambda ()
                                 (interactive)
                                 (save-excursion (pp-buffer))))))

(add-hook 'makefile-mode-hook
          #'(lambda ()
              (setq-local completion-at-point-functions
                          `(,(cape-capf-super
                              #'makefile-completions-at-point
                              #'cape-line #'cape-dabbrev
                              #'cape-keyword
                              #'cape-abbrev #'cape-dict
                              #'cape-file)
                            t))))

(defun eglot-local-set-capf ()
  (setq-local completion-at-point-functions
              `(,(cape-capf-super
                  #'eglot-completion-at-point
                  #'cape-line #'cape-dabbrev
                  #'cape-abbrev #'cape-dict
                  #'cape-file)
                t)))

(add-hook 'eglot-managed-mode-hook #'eglot-local-set-capf)

(defun eglot-major-hook ()
  (interactive)
  (eglot-ensure)
  (local-set-key (kbd "M-r") #'eglot-rename)
  (local-set-key (kbd "C-M-i") #'eglot-format))

(add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx")))
(add-hook 'nxml-mode-hook #'eglot-major-hook)

(add-hook 'js-json-mode-hook
          #'(lambda ()
              (local-set-key (kbd "C-M-i") #'json-pretty-print-buffer)))

(defun c-indent-then-complete ()
  (interactive)
  (if (= 0 (c-indent-line-or-region))
      (completion-at-point)))
(defun cc-mode-hook ()
  (interactive)
  (eglot-major-hook)
  (local-set-key (kbd "TAB") #'c-indent-then-complete))
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode) .
               ("clangd"
                "--enable-config" "--pch-storage=memory"
                "--clang-tidy" "--all-scopes-completion"
                "--header-insertion=never"
                "--completion-style=detailed"
                "--fallback-style=GNU" "--background-index")))
(add-hook 'c-mode-hook #'cc-mode-hook)
(add-hook 'c++-mode-hook #'cc-mode-hook)

;; pylsp
(add-hook 'python-mode-hook #'eglot-major-hook)

(add-to-list 'auto-mode-alist '("\\.[cm]js\\'" . javascript-mode))
;; typescript-language-server
(add-hook 'js-mode-hook #'eglot-major-hook)

;; jdtls
(add-hook 'java-mode-hook #'cc-mode-hook)

;; sql-indent
(add-hook 'sql-mode-hook
          #'(lambda ()
              (sqlind-minor-mode 1)
              (setq-local completion-at-point-functions
                          `(,(cape-capf-super
                              #'cape-dabbrev
                              #'cape-keyword
                              #'cape-abbrev #'cape-dict)))
              (local-set-key (kbd "C-M-i") #'align-current)))

(global-set-key (kbd "C-x k") #'kill-current-buffer)
(defun kill-terminal ()
  (interactive)
  (condition-case nil (delete-frame) (error (kill-emacs))))
(global-set-key (kbd "C-x C-c") #'kill-terminal)
(global-set-key (kbd "C-\\") #'goto-last-change)
;; (define-key key-translation-map (kbd "<backtab>") (kbd "C-x o"))
(global-set-key (kbd "<backtab>") #'other-window)
(global-set-key (kbd "C-z") #'xclip-mode)

(setq-default custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
