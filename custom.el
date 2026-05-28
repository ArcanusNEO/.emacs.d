(add-to-list 'eglot-server-programs
             '((java-mode) .
               ("jdtls" "--jvm-arg=-javaagent:/usr/local/share/java/lombok.jar")))

(setq-default jdecomp-decompiler-type 'cfr)
(setq-default jdecomp-decompiler-paths '((cfr . "/usr/local/share/java/cfr.jar")))
