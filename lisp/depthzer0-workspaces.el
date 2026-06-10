;;; depthzer0-workspaces.el --- Управление рабочими пространствами -*- lexical-binding: t; -*-

;;; Commentary:
;; Универсальная система загрузки рабочих пространств (Data-Driven).
;; 
;; Формат описания макета (DSL):
;; - (horizontal ЛЕВО ПРАВО) : Разделить окно по горизонтали
;; - (vertical ВЕРХ НИЗ)     : Разделить окно по вертикали
;; - (file "имя_файла")      : Открыть файл относительно корня проекта
;; - (scratch)               : Создать буфер *scratch*
;; - (magit)                 : Открыть статус Git
;;
;; Пример: (horizontal (file "init.el") (magit))

;;; Code:

(defvar depthzer0-project-layout nil
  "Декларативное описание макета окон для текущего проекта.
Обычно переопределяется локально в файле .dir-locals.el каждого проекта.
Если равно nil, кастомное рабочее пространство не создается.")

(defvar depthzer0--current-project-name nil
  "Внутренняя динамическая переменная. 
Хранит имя текущего проекта во время постройки макета.")

(put 'depthzer0-project-layout 'safe-local-variable #'listp)

(defun depthzer0-workspace--build-node (node)
  "Рекурсивно строит окна на основе узла NODE."
  (pcase node

    ;; --- НОВЫЙ УЗЕЛ ---
    (`(project ,name ,child)
     ;;  Задаем значение нашей динамической переменной.
     ;; Пока выполняется этот let, все функции остальных узлов внутри будут видеть это имя.
     (let ((depthzer0--current-project-name name))
       ;; Запускаем парсер для вложенного макета (child)
       (depthzer0-workspace--build-node child)))
    
    ;; Если это горизонтальное разделение
    (`(horizontal ,left ,right)
     (let ((new-win (split-window-right)))
       (depthzer0-workspace--build-node left)
       (with-selected-window new-win
         (depthzer0-workspace--build-node right))))
    
    ;; Если это вертикальное разделение
    (`(vertical ,top ,bottom)
     (let ((new-win (split-window-below)))
       (depthzer0-workspace--build-node top)
       (with-selected-window new-win
         (depthzer0-workspace--build-node bottom))))

        ;; Если это группа вкладок для одного окна
    (`(tabs . ,nodes)
     ;; Гарантируем, что пакет локальных вкладок загружен в память
     (require 'tab-line)
     ;; Проходим по списку с конца
     (dolist (n (reverse nodes))
       (depthzer0-workspace--build-node n))
     ;; Передаем движку отрисовки правильный формат (mode-line construct)
     (set-window-parameter nil 'tab-line-format '(:eval (tab-line-format))))
    
    ;; Если это команда открытия файла
    (`(file ,filename)
     (find-file filename))

    ;; Если это команда открытия dired
    (`(dired)
     (dired default-directory))

    ;; Если это команда открытия пустой песочницы
   (`(scratch)
     (let* ((root default-directory)
            ;; Читаем имя проекта прямо из "эфира" (динамической переменной)
            (buf-name (if depthzer0--current-project-name 
                          (format "*scratch: %s*" depthzer0--current-project-name)
                        "*scratch*")))
       (switch-to-buffer (get-buffer-create buf-name))
       (setq default-directory root)
       
       ;; Если буфер свежий и имеет базовый режим, включаем Lisp-режим
       (when (eq major-mode 'fundamental-mode)
         (lisp-interaction-mode))))
    
    ;; Если это команда открытия Magit
    (`(magit)
     (magit-status))))

(defun depthzer0-workspace-load (&optional layout)
  "Читает переменную макета и строит рабочее пространство."
  (interactive)
  (let* ((root default-directory)
         (pr (project-current nil))
         (proj-name (when pr (project-name pr))))
    
    (delete-other-windows) 
    (switch-to-buffer (get-buffer-create " *depthzer0-init*"))
    (setq default-directory root)
    (set-window-prev-buffers (selected-window) nil)
    
    (let ((current-layout (or layout depthzer0-project-layout)))
      (if current-layout
          ;; --- ИЗМЕНЕНИЯ ЗДЕСЬ ---
          (progn
            ;; Если мы в проекте, конструируем новый список-обертку.
            ;; Если нет — оставляем макет как есть.
            (let ((wrapped-layout (if proj-name
                                      (list 'project proj-name current-layout)
                                    current-layout)))
              ;; Передаем обернутый макет в парсер (аргумент снова только один!)
              (depthzer0-workspace--build-node wrapped-layout)))
        (progn
          (dired default-directory)
          (message "Для этого проекта нет кастомного макета."))))
    (kill-buffer " *depthzer0-init*")))

(defun depthzer0-workspace-project-action ()
  "Действие для project.el: открывает воркспейс в новой вкладке."  (interactive)
  (let* ((pr (project-current t))
         (name (project-name pr))
         (root (project-root pr))
         (layout (with-temp-buffer
                   (setq default-directory root)
                   (hack-dir-local-variables-non-file-buffer)
                   depthzer0-project-layout)))
    
    (tab-bar-new-tab)
    (tab-bar-rename-tab name)
    
    ;; ПРИНУДИТЕЛЬНАЯ ИЗОЛЯЦИЯ:
    ;; Возвращаем default-directory на корень проекта, 
    ;; так как tab-bar-new-tab (через dashboard) мог её перезаписать.
    (let ((default-directory root))
      (depthzer0-workspace-load layout))))

;; Добавляем наше действие в меню project.el
;; with-eval-after-load гарантирует, что код выполнится только тогда,
;; когда встроенный пакет 'project' будет загружен в память.
(with-eval-after-load 'project
  (add-to-list 'project-switch-commands
               '(?w "Workspace" depthzer0-workspace-project-action)))

(provide 'depthzer0-workspaces)
;;; depthzer0-workspaces.el ends here
