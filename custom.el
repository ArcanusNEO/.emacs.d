(defun eglot-jdtls-contact (_interactive project)
  (let* ((project-root (file-truename (expand-file-name (project-root project))))
         (project-hash (secure-hash 'sha256 project-root))
         (data
          (expand-file-name
           project-hash
           (format "/dev/shm/jdtls-%s/" (user-uid)))))
    (make-directory data t)
    `("jdtls" "-data" ,data
      "--jvm-arg=-javaagent:/usr/local/lib/java/lombok.jar")))
(add-to-list 'eglot-server-programs
             '((java-mode) . eglot-jdtls-contact))
(defun eglot-groovy-language-server-contact (_interactive project)
  (let* ((project-root (file-truename (expand-file-name (project-root project))))
         (project-hash (secure-hash 'sha256 project-root))
         (data
          (expand-file-name
           project-hash
           (format "/dev/shm/groovy-language-server-edt-%s/" (user-uid)))))
    (make-directory data t)
    `("groovy-language-server-edt" "-data" ,data
      :initializationOptions (:delegatedClasspathStartup :json-false))))
(add-to-list 'eglot-server-programs
             '((groovy-mode) . eglot-groovy-language-server-contact))
(setq-default jdecomp-decompiler-paths '((cfr . "/usr/local/lib/java/cfr.jar")))

(plist-put minuet-openai-fim-compatible-options :end-point "https://api.deepseek.com/beta/completions")
(plist-put minuet-openai-fim-compatible-options :api-key (lambda () "sk-"))
(plist-put minuet-openai-fim-compatible-options :model "deepseek-v4-flash")
