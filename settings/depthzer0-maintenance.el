;;; depthzer0-maintenance.el --- Обслуживание и автоматизация системы -*- lexical-binding: t; -*-

;;; Commentary:
;; Утилиты для поддержания конфигурации в чистоте и автоматизации рутины.
;; Содержит самописные функции для сборки мусора (удаление пакетов-сирот),
;; а также настройку шаблонов файлов (autoinsert).

;;; Code:

(defun depthzer0--find-packages-in-form (form)
  "Рекурсивно обходит Lisp-форму (AST) и ищет вызовы use-package."
  (cond
   ((not (consp form)) nil)
   ((eq (car form) 'use-package) (list (cadr form)))
   (t (let ((res nil))
        (while (consp form)
          (setq res (append res (depthzer0--find-packages-in-form (car form))))
          (setq form (cdr form)))
        res))))

(defun depthzer0-sync-packages ()
  "Читает init.el и модули в settings/ и lisp/, удаляя пакеты-сироты."
  (interactive)
  (let ((declared-packages nil)
        ;; ВАЖНО: Обновленный список путей для сканирования
        (config-files 
         (append (list (locate-user-emacs-file "init.el"))
                 (when (file-directory-p (locate-user-emacs-file "settings"))
                   (directory-files (locate-user-emacs-file "settings") t "\\.el$"))
                 (when (file-directory-p (locate-user-emacs-file "lisp"))
                   (directory-files (locate-user-emacs-file "lisp") t "\\.el$")))))
    
    (dolist (file config-files)
      (when (and file (file-exists-p file))
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (condition-case nil
              (while t
                (let ((form (read (current-buffer))))
                  (setq declared-packages 
                        (append declared-packages (depthzer0--find-packages-in-form form)))))
            (end-of-file nil)))))
            
    (setq declared-packages (delete-dups declared-packages))
    (setq package-selected-packages declared-packages)
    (message "Найдено %d задекларированных пакетов. Запускаю очистку..." (length declared-packages))
    (package-autoremove)))

(provide 'depthzer0-maintenance)
;;; depthzer0-maintenance.el ends here
