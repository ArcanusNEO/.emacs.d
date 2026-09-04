;;; eglot-groovy-hook.el --- Eglot classpath integration for Groovy -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'eglot)
(require 'json)
(require 'project)

(defconst eglot-groovy-hook--library-file
  (or load-file-name
      (locate-library "eglot-groovy-hook")
      (error "Cannot locate eglot-groovy-hook library")))

(defgroup eglot-groovy-hook nil
  "Groovy language server integration."
  :group 'tools)

(defcustom eglot-groovy-hook-java-home nil
  "JDK used by Gradle and Maven classpath resolver.
If nil, use the JAVA_HOME environment variable."
  :type '(choice (const :tag "Use JAVA_HOME environment variable" nil)
                 (directory :tag "Explicit path"))
  :group 'eglot-groovy-hook)

(defcustom eglot-groovy-hook-timeout 300
  "Timeout in seconds for Gradle and Maven classpath resolution."
  :type 'integer
  :group 'eglot-groovy-hook)

(defconst eglot-groovy-hook--build-file-names
  '("build.gradle" "build.gradle.kts"
    "settings.gradle" "settings.gradle.kts"
    "gradle.properties" "libs.versions.toml" "pom.xml"))

(defconst eglot-groovy-hook--ignored-directories
  '(".git" ".gradle" ".idea" ".mvn" "build" "dist" "node_modules" "out" "target"))

(defconst eglot-groovy-hook--gradle-build-files
  '("build.gradle" "build.gradle.kts"))

(defconst eglot-groovy-hook--gradle-settings-files
  '("settings.gradle" "settings.gradle.kts"))

(defconst eglot-groovy-hook--gradle-init-script
  "import java.util.Base64

def groovyLsEncode = { value ->
    Base64.encoder.encodeToString(value.toString().getBytes('UTF-8'))
}

allprojects {
    tasks.register('groovyLsPrintClasspath') {
        doLast {
            def paths = new LinkedHashSet<File>()
            ['testCompileClasspath', 'testRuntimeClasspath',
             'compileClasspath', 'runtimeClasspath'].each { name ->
                def configuration = project.configurations.findByName(name)
                if (configuration != null && configuration.canBeResolved) {
                    try {
                        paths.addAll(configuration.resolvedConfiguration
                                                  .lenientConfiguration.files)
                    } catch (Throwable ignored) {
                    }
                }
            }

            def sourceSets = project.extensions.findByName('sourceSets')
            if (sourceSets != null) {
                sourceSets.each { sourceSet ->
                    paths.addAll(sourceSet.output.classesDirs.files)
                    if (sourceSet.output.resourcesDir != null) {
                        paths.add(sourceSet.output.resourcesDir)
                    }
                }
            }

            paths.findAll { it.exists() }.each { entry ->
                println('GROOVY_LS_CP_V1::' +
                        groovyLsEncode(project.projectDir.absolutePath) + '::' +
                        groovyLsEncode(entry.absolutePath))
            }
        }
    }
}
")

(cl-defstruct eglot-groovy-hook--state
  root
  (generation 0)
  process
  refresh-timer
  started)

(defvar eglot-groovy-hook--states (make-hash-table :test #'eq :weakness 'key))

(defun eglot-groovy-hook--get-java-home ()
  "Return the Java home directory to use for classpath resolution."
  (or eglot-groovy-hook-java-home
      (getenv "JAVA_HOME")
      (error "Neither eglot-groovy-hook-java-home nor JAVA_HOME is set")))

(defun eglot-groovy-hook--state (server root)
  (or (gethash server eglot-groovy-hook--states)
      (let ((state (make-eglot-groovy-hook--state :root (file-truename root))))
        (puthash server state eglot-groovy-hook--states)
        state)))

(defun eglot-groovy-hook--log-errors (root errors)
  (when errors
    (with-current-buffer (get-buffer-create "*eglot-groovy-hook-classpath-errors*")
      (goto-char (point-max))
      (insert (format-time-string "\n[%Y-%m-%d %H:%M:%S] "))
      (insert root "\n")
      (dolist (error errors)
        (insert (format "%s: %s\n"
                        (or (alist-get 'projectPath error) root)
                        (or (alist-get 'message error) "Unknown error")))))))

(defun eglot-groovy-hook--notify-batch-complete (server)
  (when (jsonrpc-running-p server)
    (jsonrpc-notify server :groovy/classpathBatchComplete
                    '(:source "emacs-classpath-resolver"))))

(defun eglot-groovy-hook--walk-build-files (root)
  "Return (GRADLE-BUILDS GRADLE-SETTINGS MAVEN-POMS) under ROOT."
  (let (gradle-builds gradle-settings maven-poms)
    (cl-labels
        ((walk (directory)
           (when (file-accessible-directory-p directory)
             (dolist (name (sort (directory-files directory) #'string<))
               (unless (string-prefix-p "." name)
                 (let ((path (expand-file-name name directory)))
                   (cond
                    ((file-directory-p path)
                     (unless (member name eglot-groovy-hook--ignored-directories)
                       (walk path)))
                    ((member name eglot-groovy-hook--gradle-build-files)
                     (push path gradle-builds))
                    ((member name eglot-groovy-hook--gradle-settings-files)
                     (push path gradle-settings))
                    ((string= name "pom.xml")
                     (push path maven-poms)))))))))
      (walk root))
    (list (nreverse gradle-builds)
          (nreverse gradle-settings)
          (nreverse maven-poms))))

(defun eglot-groovy-hook--gradle-roots (builds settings)
  "Return Gradle project roots from BUILDS and SETTINGS files."
  (let ((roots (mapcar (lambda (s) (file-name-directory (file-truename s)))
                       settings)))
    (dolist (build builds)
      (let ((directory (file-name-directory (file-truename build))))
        (unless (cl-some (lambda (root) (file-in-directory-p directory root))
                         roots)
          (push directory roots))))
    (sort roots
          (lambda (a b)
            (let ((a-depth (length (split-string a "/" t)))
                  (b-depth (length (split-string b "/" t))))
              (if (= a-depth b-depth)
                  (string< a b)
                (< a-depth b-depth)))))))

(defun eglot-groovy-hook--find-upward (start names)
  "Find first file matching NAMES upward from START."
  (setq start (file-truename start))
  (let ((directory (if (file-directory-p start)
                       start
                     (file-name-directory start))))
    (catch 'found
      (while directory
        (dolist (name names)
          (let ((candidate (expand-file-name name directory)))
            (when (file-regular-p candidate)
              (throw 'found candidate))))
        (let ((parent (file-name-directory (directory-file-name directory))))
          (setq directory (unless (equal parent directory) parent)))))))

(defun eglot-groovy-hook--command-for-wrapper (wrapper)
  "Return command list for executing WRAPPER."
  (if (file-executable-p wrapper)
      (list wrapper)
    (list shell-file-name wrapper)))

(defun eglot-groovy-hook--gradle-root-covered-p (root projects)
  "Return non-nil when PROJECTS already contains a project under ROOT."
  (let ((root (file-name-as-directory (file-truename root))))
    (cl-some (lambda (project)
               (string-prefix-p
                root
                (file-name-as-directory (file-truename (car project)))))
             projects)))

(defun eglot-groovy-hook--resolve-gradle (roots projects errors)
  "Resolve Gradle classpath for ROOTS, updating PROJECTS and ERRORS."
  (let ((script-path (make-temp-file "eglot-groovy-hook-gradle-" nil ".init.gradle"
                                     eglot-groovy-hook--gradle-init-script)))
    (unwind-protect
        (dolist (root roots)
          (unless (eglot-groovy-hook--gradle-root-covered-p root projects)
            (let* ((wrapper (eglot-groovy-hook--find-upward root '("gradlew")))
                   (command (if wrapper
				(eglot-groovy-hook--command-for-wrapper wrapper)
                              (when-let ((gradle (executable-find "gradle")))
				(list gradle))))
                   (java-home (eglot-groovy-hook--get-java-home))
                   (process-environment
                    (cons (format "JAVA_HOME=%s" java-home)
                          (cons (format "PATH=%s/bin:%s"
					java-home
					(getenv "PATH"))
				process-environment))))
              (unless command
		(push `((projectPath . ,root)
			(message . "Gradle executable not found"))
                      errors)
		(cl-return))
              (setq command
                    (append command
                            (list "--quiet" "--no-daemon"
                                  "--init-script" script-path
                                  "--project-dir" root
                                  "groovyLsPrintClasspath")))
              (with-temp-buffer
		(let* ((exit-code
			(with-timeout
                            (eglot-groovy-hook-timeout
                             (push `((projectPath . ,root)
                                     (message . "Gradle timed out"))
                                   errors)
                             nil)
                          (apply #'call-process (car command) nil t nil (cdr command)))))
                  (if (and exit-code (= exit-code 0))
                      (progn
			(goto-char (point-min))
			(while (re-search-forward "^GROOVY_LS_CP_V1::\\([^:]+\\)::\\(.+\\)$" nil t)
                          (let* ((project-b64 (match-string 1))
				 (entry-b64 (match-string 2))
				 (project (decode-coding-string
                                           (base64-decode-string project-b64) 'utf-8))
				 (entry (decode-coding-string
					 (base64-decode-string entry-b64) 'utf-8)))
                            (when (file-exists-p entry)
                              (let ((key (file-truename project)))
				(unless (assoc key projects)
                                  (push (cons key nil) projects))
				(push entry (cdr (assoc key projects))))))))
                    (push `((projectPath . ,root)
                            (message . ,(string-trim (buffer-string))))
                          errors)))))))
      (delete-file script-path))
    (cons projects errors)))

(defun eglot-groovy-hook--resolve-maven (poms projects errors)
  "Resolve Maven classpath for POMS, updating PROJECTS and ERRORS."
  (dolist (pom poms)
    (let* ((root (file-name-directory (file-truename pom)))
           (wrapper (eglot-groovy-hook--find-upward root '("mvnw")))
           (command (if wrapper
                        (eglot-groovy-hook--command-for-wrapper wrapper)
                      (when-let ((mvn (executable-find "mvn")))
                        (list mvn))))
           (output-file (make-temp-file "eglot-groovy-hook-maven-classpath-" nil ".txt"))
           (java-home (eglot-groovy-hook--get-java-home))
           (process-environment
            (cons (format "JAVA_HOME=%s" java-home)
                  (cons (format "PATH=%s/bin:%s"
                                java-home
                                (getenv "PATH"))
                        process-environment))))
      (unless command
        (push `((projectPath . ,root)
                (message . "Maven executable not found"))
              errors)
        (cl-return))
      (setq command
            (append command
                    (list "--quiet" "--file" pom
                          "dependency:build-classpath"
                          "-Dmdep.includeScope=test"
                          "-Dmdep.outputAbsoluteArtifactFilename=true"
                          (format "-Dmdep.outputFile=%s" output-file))))
      (unwind-protect
          (with-temp-buffer
            (let ((exit-code
                   (with-timeout
                       (eglot-groovy-hook-timeout
                        (push `((projectPath . ,root)
                                (message . "Maven timed out"))
                              errors)
                        nil)
                     (apply #'call-process (car command) nil t nil (cdr command)))))
              (if (and exit-code (= exit-code 0))
                  (progn
                    (when (file-exists-p output-file)
                      (dolist (entry (split-string
                                     (with-temp-buffer
                                       (insert-file-contents output-file)
                                       (string-trim (buffer-string)))
                                     path-separator t))
                        (when (file-exists-p entry)
                          (let ((key (file-truename root)))
                            (unless (assoc key projects)
                              (push (cons key nil) projects))
                            (push entry (cdr (assoc key projects)))))))
                    (dolist (relative '("target/classes" "target/test-classes"))
                      (let ((path (expand-file-name relative root)))
                        (when (file-exists-p path)
                          (let ((key (file-truename root)))
                            (unless (assoc key projects)
                              (push (cons key nil) projects))
                            (push path (cdr (assoc key projects))))))))
                (push `((projectPath . ,root)
                        (message . ,(string-trim (buffer-string))))
                      errors))))
        (when (file-exists-p output-file)
          (delete-file output-file)))))
  (cons projects errors))

(defun eglot-groovy-hook--resolve-classpath (root)
  "Resolve Gradle and Maven classpaths under ROOT.
Returns (PROJECTS . ERRORS) where PROJECTS is an alist of
(PROJECT-PATH . ENTRIES) and ERRORS is a list of error alists."
  (cl-destructuring-bind (builds settings poms)
      (eglot-groovy-hook--walk-build-files root)
    (let* ((gradle-roots (eglot-groovy-hook--gradle-roots builds settings))
           (projects nil)
           (errors nil))
      (pcase-let ((`(,resolved-projects . ,resolved-errors)
                   (eglot-groovy-hook--resolve-gradle
                    gradle-roots projects errors)))
        (setq projects resolved-projects
              errors resolved-errors))
      (let ((gradle-directories (mapcar #'car projects)))
        (setq poms
              (cl-remove-if
               (lambda (pom)
                 (member (file-truename (file-name-directory pom))
                         gradle-directories))
               poms)))
      (pcase-let ((`(,resolved-projects . ,resolved-errors)
                   (eglot-groovy-hook--resolve-maven poms projects errors)))
        (setq projects resolved-projects
              errors resolved-errors))
      (cons projects errors))))

(defun eglot-groovy-hook--helper-command (root)
  "Return the isolated Emacs command used to resolve classpaths under ROOT."
  (list (expand-file-name invocation-name invocation-directory)
        "--batch" "--quick"
        "--eval"
        (format "(progn \
(setq eglot-groovy-hook-java-home %S) \
(setq eglot-groovy-hook-timeout %d) \
(load %S nil t) \
(prin1 (eglot-groovy-hook--resolve-classpath %S)))"
                (eglot-groovy-hook--get-java-home)
                eglot-groovy-hook-timeout
                eglot-groovy-hook--library-file
                root)))

(defun eglot-groovy-hook--handle-helper-exit (process _event)
  (when (memq (process-status process) '(exit signal))
    (let* ((server (process-get process 'eglot-groovy-hook-server))
           (generation (process-get process 'eglot-groovy-hook-generation))
           (root (process-get process 'eglot-groovy-hook-root))
           (state (gethash server eglot-groovy-hook--states)))
      (when (and state
                 (= generation (eglot-groovy-hook--state-generation state)))
        (setf (eglot-groovy-hook--state-process state) nil)
        (condition-case error
            (if (not (= (process-exit-status process) 0))
                (progn
                  (eglot-groovy-hook--log-errors
                   root
                   `(((projectPath . ,root)
                      (message . "Classpath resolver subprocess failed"))))
                  (message "Groovy classpath resolver failed for %s" root))
              (let* ((output (apply #'concat
                                    (nreverse
                                     (process-get process
                                                  'eglot-groovy-hook-output))))
                     (result (read output))
                     (projects (car result))
                     (errors (cdr result))
                     (sent 0))
                (when (jsonrpc-running-p server)
                  (dolist (project-entry projects)
                    (let* ((project-path (car project-entry))
                           (entries (cdr project-entry))
                           (unique-entries (delete-dups (nreverse entries))))
                      (when unique-entries
                        (jsonrpc-notify
                         server :groovy/classpathUpdate
                         `(:projectUri ,(concat "file://" project-path)
                           :projectPath ,project-path
                           :entries ,(vconcat unique-entries)))
                        (cl-incf sent)))))
                (eglot-groovy-hook--log-errors root errors)
                (message "Groovy classpath: sent %d project(s), %d error(s)"
                         sent (length errors))))
          (error
           (eglot-groovy-hook--log-errors
            root
            `(((projectPath . ,root)
               (message . ,(error-message-string error)))))
           (message "Failed to process Groovy classpath: %s"
                    (error-message-string error))))
         ;; Delegated startup must always be released.
        (condition-case error
            (eglot-groovy-hook--notify-batch-complete server)
          (error
           (message "Failed to complete Groovy classpath batch: %s"
                    (error-message-string error))))))))


(defun eglot-groovy-hook--run-helper (server root)
  (let* ((state (eglot-groovy-hook--state server root))
         (old-process (eglot-groovy-hook--state-process state))
         (generation (1+ (eglot-groovy-hook--state-generation state))))
    (when (timerp (eglot-groovy-hook--state-refresh-timer state))
      (cancel-timer (eglot-groovy-hook--state-refresh-timer state)))
    (setf (eglot-groovy-hook--state-refresh-timer state) nil)
    (setf (eglot-groovy-hook--state-generation state) generation)
    (when (process-live-p old-process)
      (delete-process old-process))
    (condition-case error
        (let ((process
                (make-process
                 :name (format "eglot-groovy-hook-classpath-%d" generation)
                 :buffer nil
                 :command (eglot-groovy-hook--helper-command root)
                :connection-type 'pipe
                :coding 'utf-8-unix
                :noquery t
                 :sentinel #'eglot-groovy-hook--handle-helper-exit
                 :filter
                 (lambda (proc output)
                   (process-put
                    proc 'eglot-groovy-hook-output
                    (cons output
                          (process-get proc 'eglot-groovy-hook-output)))))))
          (process-put process 'eglot-groovy-hook-server server)
          (process-put process 'eglot-groovy-hook-generation generation)
          (process-put process 'eglot-groovy-hook-root root)
          (setf (eglot-groovy-hook--state-process state) process)
          (message "Resolving Groovy classpath for %s" root))
      (error
       (eglot-groovy-hook--log-errors
        root
        `(((projectPath . ,root)
           (message . ,(error-message-string error)))))
       (eglot-groovy-hook--notify-batch-complete server)
       (message "Failed to start Groovy classpath resolver: %s"
                (error-message-string error))))))

(defun eglot-groovy-hook--managed-mode-hook ()
  (when (derived-mode-p 'groovy-mode)
    (when-let* ((server (eglot-current-server))
                (project (project-current))
                (root (project-root project))
                (state (eglot-groovy-hook--state server root)))
      (unless (eglot-groovy-hook--state-started state)
        (setf (eglot-groovy-hook--state-started state) t)
        (eglot-groovy-hook--run-helper server (eglot-groovy-hook--state-root state))))))

(add-hook 'eglot-managed-mode-hook #'eglot-groovy-hook--managed-mode-hook)

(defun eglot-groovy-hook-refresh-classpath ()
  "Resolve and resend the classpath for the current Groovy Eglot server."
  (interactive)
  (let* ((server (eglot-current-server))
         (state (and server (gethash server eglot-groovy-hook--states))))
    (unless state
      (user-error "Current buffer is not managed by a Groovy Eglot server"))
    (eglot-groovy-hook--run-helper server (eglot-groovy-hook--state-root state))))

(defun eglot-groovy-hook--build-file-p (file)
  (and file
       (member (file-name-nondirectory file) eglot-groovy-hook--build-file-names)))

(defun eglot-groovy-hook--server-for-file (file)
  (let (best-server best-length)
    (maphash
     (lambda (server state)
       (let ((root (eglot-groovy-hook--state-root state)))
         (when (and (jsonrpc-running-p server)
                    (file-in-directory-p file root)
                    (or (null best-length) (> (length root) best-length)))
           (setq best-server server
                 best-length (length root)))))
     eglot-groovy-hook--states)
    best-server))

(defun eglot-groovy-hook--refresh-after-build-file-save ()
  (when (eglot-groovy-hook--build-file-p buffer-file-name)
    (when-let* ((server (eglot-groovy-hook--server-for-file buffer-file-name))
                (state (gethash server eglot-groovy-hook--states)))
      (when (timerp (eglot-groovy-hook--state-refresh-timer state))
        (cancel-timer (eglot-groovy-hook--state-refresh-timer state)))
      (setf (eglot-groovy-hook--state-refresh-timer state)
            (run-at-time 3 nil #'eglot-groovy-hook--run-helper
                         server (eglot-groovy-hook--state-root state))))))

(add-hook 'after-save-hook #'eglot-groovy-hook--refresh-after-build-file-save)

(provide 'eglot-groovy-hook)
;;; eglot-groovy-hook.el ends here
