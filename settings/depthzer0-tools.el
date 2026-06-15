;;; depthzer0-tools.el --- Рабочие инструменты и приложения -*- lexical-binding: t; -*-

;;; Commentary:
;; Модуль загружает и настраивает тяжелые рабочие инструменты,
;; которые превращают Emacs в полноценную среду разработки.
;; Включает Magit (Git), Dired (Файлы), Geiser (Scheme), Org-mode
;; и инструменты структурного редактирования (Smartparens, Vundo).

;;; Code:

;; --- Встроенная память недавних файлов ---
(use-package recentf
  :ensure nil ; Пакет встроен в ядро
  :hook (after-init . recentf-mode)
  :custom
  (recentf-max-saved-items 25))

;; --- Встроенная документация (Info) ---
(use-package info
  :ensure nil
  :hook (Info-mode . variable-pitch-mode))

;; --- Продвинутая самодокументация (Helpful) ---
(use-package helpful
  :ensure t
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key))

;; --- Подсказки горячих клавиш (Which-key) ---
(use-package which-key
  :ensure nil
  :defer 2
  :config
  (which-key-mode 1))

;; --- Быстрый переключатель окон (Ace-window) ---
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))

;; --- Визуализация дерева отмены (Vundo) ---
(use-package vundo
  :ensure t
  :bind ("C-x u" . vundo))

;; --- Структурное редактирование (Smartparens) ---
(use-package smartparens
  :ensure t
  :hook
  (after-init . smartparens-global-mode)
  (emacs-lisp-mode . smartparens-strict-mode)
  (scheme-mode     . smartparens-strict-mode)
  (lisp-mode       . smartparens-strict-mode)
  :config
  (require 'smartparens-config))

;; --- Поддержка Markdown и конвертация (Pandoc) ---
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode)
  :custom
  (markdown-command "pandoc"))

(use-package pandoc-mode
  :ensure t
  :hook (markdown-mode . pandoc-mode)
  :bind ("C-c b" . my-pandoc-build-project)
  :config
  ;; Легализуем путь к браузеру для mermaid-filter
  (setenv "PUPPETEER_EXECUTABLE_PATH" "C:\\Users\\Dima\\.cache\\puppeteer\\chrome\\win64-149.0.7827.22\\chrome-win64\\chrome.exe")

  (defun my-pandoc-build-project ()
    "Запускает асинхронную сборку Pandoc, используя build.yaml в текущей папке."
    (interactive)
    (if (file-exists-p "build.yaml")
        (progn
          (message "Pandoc: Сборка начата в фоне...")
          (make-process
           :name "pandoc-build"
           :buffer "*Pandoc Async Output*"
           :command '("pandoc" "-d" "build.yaml")
           :sentinel (lambda (process event)
                       (when (string= event "finished\n")
                         (message "Pandoc: Сборка УСПЕШНО завершена!"))
                       (when (string-match-p "exited abnormally" event)
                         (message "Pandoc: ОШИБКА сборки. Проверьте буфер *Pandoc Async Output*.")))))
      (error "Файл build.yaml не найден в текущей директории!"))))

;; --- Файловый менеджер (Dired) ---
(use-package dired
  :ensure nil
  :custom
  ;; Проваливаться в папки, не плодя новые буферы
  (dired-kill-when-opening-new-dired-buffer t)
  :bind (:map dired-mode-map
              ("<mouse-2>" . my-dired-mouse-find-file)
              ("DEL" . dired-up-directory))
  :hook (dired-mode . my-dired-rename-buffer)
  :config
  (defun my-dired-mouse-find-file (event)
    "Обрабатывает клик мыши, открывая файл/папку в текущем окне."
    (interactive "e")
    (mouse-set-point event)
    (dired-find-file))

  (defun my-dired-rename-buffer ()
    "Добавляет суффикс к имени буфера Dired."
    (let ((name (buffer-name)))
      (unless (string-suffix-p " : dired" name)
        (rename-buffer (concat name " : dired") t)))))

;; Иконки для Dired
(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

;; --- Управление проектами (project.el) ---
(use-package project
  :ensure nil ; Пакет встроен в ядро
  :bind (:map project-prefix-map
              ("+" . my-project-remember-current)
              ("-" . my-project-forget-current))
  :config
  (defun my-project-remember-current ()
    "Явно регистрирует текущую директорию как проект."
    (interactive)
    ;; Пытаемся получить объект проекта для текущей папки
    (let ((pr (project-current nil default-directory)))
      (if pr
          (progn
            ;; Если проект найден, передаем его во внутреннюю API-функцию
            (project-remember-project pr)
            (message "Проект успешно зарегистрирован: %s" (project-root pr)))
        ;; Если это обычная папка без .git
        (user-error "В текущей директории не найден маркер проекта (например, .git)"))))
  
  (defun my-project-forget-current ()
    "Явно удаляет текущую директорию из списка известных проектов."
    (interactive)
    (let ((pr (project-current nil default-directory)))
      (if pr
          (let ((root (project-root pr)))
            ;; Передаем путь напрямую, чтобы избежать диалогового окна
            (project-forget-project root)
            (message "Проект удален из дашборда: %s" root))
        (user-error "Текущая директория не является проектом")))))

;; --- Система быстрого захвата (Org Capture) ---
(use-package org
  :ensure nil
  :bind ("C-c c" . org-capture)
  :custom
  (org-log-done 'time)
  (org-log-into-drawer t)
  :config
  (setq org-capture-templates
        `(("e" "Emacs Шпаргалка" plain
           (file ,(expand-file-name "cheatsheet.org" user-emacs-directory))
           "- =%^{Комбинация клавиш}= :: %^{Описание}\n"
           :append t))))

;; --- Среда для Scheme (SICP) ---
(use-package geiser-racket
  :ensure t
  :hook (scheme-mode . geiser-mode)
  :custom
  (geiser-active-implementations '(racket))
  (geiser-autodoc-mode nil))

;; --- Git интерфейс (Magit) ---
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :defer 1
  :config
  ;; Настройка SSH для Magit в Windows
  (when (eq system-type 'windows-nt)
    (setenv "GIT_SSH" "C:/Windows/System32/OpenSSH/ssh.exe")))

;; --- Фикс для Magit/Server на Windows ---
(when (eq system-type 'windows-nt)
  (defun my-server-ensure-safe-dir (dir)
    "Создает директорию DIR, если её нет, но пропускает строгую проверку."
    (unless (file-exists-p dir) (make-directory dir t)) t)
  (advice-add 'server-ensure-safe-dir :override #'my-server-ensure-safe-dir)
  
  (with-eval-after-load 'with-editor
    (setq with-editor-emacsclient-executable (expand-file-name "emacsclient.exe" invocation-directory))))

;; Запускаем сервер
(server-mode 1)

(provide 'depthzer0-tools)
;;; depthzer0-tools.el ends here
