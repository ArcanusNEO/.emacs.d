(add-to-list 'eglot-server-programs
             '((java-mode) .
               ("jdtls" "--jvm-arg=-javaagent:/usr/local/lib/java/lombok.jar")))
(setq-default jdecomp-decompiler-type 'cfr)
(setq-default jdecomp-decompiler-paths '((cfr . "/usr/local/lib/java/cfr.jar")))
;; (add-hook 'java-mode-hook
;;           #'(lambda ()
;;               (setq-local tab-width 4)
;;               (setq-local c-basic-offset 4)))

(setq-default minuet-provider 'openai-fim-compatible)
(setq-default minuet-auto-suggestion-throttle-delay 1.5)
(setq-default minuet-auto-suggestion-debounce-delay 0.6)
(plist-put minuet-openai-fim-compatible-options :end-point "https://api.deepseek.com/beta/completions")
(plist-put minuet-openai-fim-compatible-options :api-key (lambda () "sk-"))
(plist-put minuet-openai-fim-compatible-options :model "deepseek-v4-flash")
(minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 56)
(minuet-set-optional-options minuet-openai-fim-compatible-options :top_p 0.9)
