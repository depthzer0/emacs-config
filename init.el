;;; -*- lexical-binding: t; -*-

;; Мой первый конфигурационный файл Emacs

;; --- Отключаем звуковой сигнал (beep) при ошибках ---
(setq ring-bell-function 'ignore)

;; --- Устанавливаем домашнюю директорию по умолчанию для новых буферов ---
(setq-default default-directory "~/")

;; Отключение сохранения сессии между запусками
(desktop-save-mode -1)

;; --- Включаем встроенный режим повторения команд (удобно для окон, undo и т.д.) ---
(repeat-mode 1)

;; Удалять выделенный текст при нажатии Backspace или вводе нового текста
(delete-selection-mode 1)

;; --- Отображение номеров строк ---
;; Включаем нумерацию строк для всех языков программирования (включая Elisp)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; --- Настройка шрифта ---

;; Проверяем, есть ли нужный шрифт в системе, чтобы избежать ошибок
;;(let ((my-font "JetBtains Mono")
;;(let ((my-font "Hack")
;;(let ((my-font "Fira Code")
(let ((my-font "FiraCode Nerd Font Mono")
      (my-size 11))
  (when (find-font (font-spec :name my-font))
    ;; 1. Основной моноширинный шрифт (для кода)
    (set-face-attribute 'default nil :font (format "%s-%d" my-font my-size))
    ;; 2. Явно указываем моноширинный шрифт для таблиц и выравниваний
    (set-face-attribute 'fixed-pitch nil :font (format "%s-%d" my-font my-size))
    ;; 3. Пропорциональный шрифт (для чтения текста, например в Org-mode)
    ;; "Sans Serif" — это системный алиас, ОС сама подберет красивый шрифт без засечек
    (set-face-attribute 'variable-pitch nil :font (format "Sans Serif-%d" my-size))))

;; Включаем панель вкладок (Workspaces)
(tab-bar-mode 1)

;; Указываем, что новая вкладка должна открывать дашборд
(setq tab-bar-new-tab-choice "*dashboard*")
 
;; Изменение высоты окон (симметрично ширине, без Shift)
(global-set-key (kbd "C-x ]") 'enlarge-window)
(global-set-key (kbd "C-x [") 'shrink-window)

;; Создаем нашу личную карту для repeat-mode
(defvar my-window-resize-repeat-map
  (let ((map (make-sparse-keymap)))
    ;; Вертикаль (наши новые скобки без Shift)
    (define-key map (kbd "]") 'enlarge-window)
    (define-key map (kbd "[") 'shrink-window)
    ;; Горизонталь (стандартные скобки с Shift, чтобы они тоже работали в цикле)
    (define-key map (kbd "}") 'enlarge-window-horizontally)
    (define-key map (kbd "{") 'shrink-window-horizontally)
    map)
  "Моя кастомная карта для быстрого изменения размеров окон.")

;; Сообщаем repeat-mode, что эти команды должны использовать нашу карту
(put 'enlarge-window 'repeat-map 'my-window-resize-repeat-map)
(put 'shrink-window 'repeat-map 'my-window-resize-repeat-map)
(put 'enlarge-window-horizontally 'repeat-map 'my-window-resize-repeat-map)
(put 'shrink-window-horizontally 'repeat-map 'my-window-resize-repeat-map)

;; --- Изоляция автоматически сгенерированного кода ---
;; Указываем Emacs сохранять настройки custom в отдельный файл
(setq custom-file (expand-file-name "custom-auto.el" user-emacs-directory))

;; Загружаем этот файл, если он существует (чтобы настройки применялись)
(when (file-exists-p custom-file)
  (load custom-file))

;; Добавляем MELPA в список репозиториев
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Настраиваем приоритеты репозиториев (чем больше число, тем выше приоритет)
(setq package-archive-priorities
      '(("gnu"    . 10)    ; Официальный репозиторий Emacs (самый надежный)
        ("nongnu" . 5)     ; Официальный репозиторий для пакетов вне ядра
        ("melpa"  . 0)))   ; Репозиторий сообщества (самые свежие версии)

;; --- Инициализация use-package ---
(require 'use-package)

;; Заставляем use-package автоматически скачивать пакеты из MELPA, 
;; если их нет на компьютере (заменяет ручное написание :ensure t)
(setq use-package-always-ensure t)

;; --- Пользовательские пакеты ---

;; --- Иконки ---
(use-package nerd-icons
  :ensure t
  :custom
  ;; Явно указываем движку использовать наш моноширинный шрифт
  (nerd-icons-font-family "FiraCode Nerd Font Mono"))

;; Добавляем иконки в файловый менеджер Dired
(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

;; --- Встроенная память недавних файлов ---
(use-package recentf
  :ensure nil ; Пакет встроен в ядро
  :hook (after-init . recentf-mode) ; Включаем сразу после загрузки Emacs
  :custom
  (recentf-max-saved-items 25)) ; Сколько файлов запоминать

;; --- Стартовый экран (Dashboard) ---
(use-package dashboard
  :ensure t
  :config
  ;; Наш ASCII баннер
  (setq dashboard-startup-banner "
  _____ __  __          _____  _____ 
 |  ___|  \\/  |   /\\   / ____|/ ____|
 | |__ | \\  / |  /  \\ | |    | (___  
 |  __|| |\\/| | / /\\ \\| |     \\___ \\ 
 | |___| |  | |/ ____ \\ |____ ____) |
 |_____|_|  |_/_/    \\_\\_____|_____/ 
")
  ;; Центрируем контент по горизонтали
  (setq dashboard-center-content t)
  
  ;; Указываем, какие виджеты выводить и по сколько строк
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)))
                          
  ;; Команда, которая заменяет стандартный *scratch* на дашборд при старте
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook (lambda () (setq default-directory "~/"))))

;; --- Внешний вид (Тема оформления) ---
(use-package zenburn-theme
  :ensure t
  :init
  ;; Задаем новые цвета ДО того, как тема начнет загружаться
  (setq zenburn-override-colors-alist
        '(("zenburn-bg" . "#353535")))
  :config
  (load-theme 'zenburn t))

;; Включение обработки нажатий в русской раскладке
(use-package reverse-im
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

;; --- Современный интерфейс (Минибуфер) ---
(use-package vertico
  :init
  (vertico-mode 1))

;; --- Аннотации в минибуфере (Заметки на полях) ---
(use-package marginalia
  :init
  ;; Включаем глобальный минорный режим аннотаций
  (marginalia-mode 1))

;; --- Умный поиск (Orderless) ---
(use-package orderless
  :custom
  ;; Указываем Emacs использовать orderless как основной стиль автодополнения
  (completion-styles '(orderless basic))
  ;; Тонкая настройка для путей к файлам (чтобы работали стандартные фишки вроде вложенности)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; --- Продвинутые команды поиска (Consult) ---
(use-package consult
  :bind (;; Заменяем стандартный поиск по файлу на продвинутый
         ("C-s" . consult-line)
	 ;; Заменяем вставку из буфера
	 ("M-y" . consult-yank-replace)
         ;; Заменяем стандартное переключение буферов
         ("C-x b" . consult-buffer)))

;; --- Быстрый переключатель окон (ace-window) ---
(use-package ace-window
  :bind ("M-o" . ace-window))
  
;; Удобная навигация и работа с Dired
(with-eval-after-load 'dired

  ;; 1. Проваливаться в папки, не плодя новые буферы
  (setq dired-kill-when-opening-new-dired-buffer t)

  ;; 2. Функция для клика мышью
  (defun my-dired-mouse-find-file (event)
    "Обрабатывает клик мыши, открывая файл/папку в текущем окне."
    (interactive "e")
    (mouse-set-point event)
    (dired-find-file))

  ;; 3. Переназначаем клик мыши
  (define-key dired-mode-map (kbd "<mouse-2>") 'my-dired-mouse-find-file)

  ;; 4. Настройка возврата
  (define-key dired-mode-map (kbd "DEL") 'dired-up-directory)

  ;; 5. Добавляем суффикс " : dired" к имени буфера
  (defun my-dired-rename-buffer ()
    "Добавляет суффикс к имени буфера Dired."
    (let ((name (buffer-name)))
      (unless (string-suffix-p " : dired" name)
        (rename-buffer (concat name " : dired") t))))

  ;; 6. Вешаем функцию на хук запуска Dired
  (add-hook 'dired-mode-hook 'my-dired-rename-buffer))

;; --- Среда для Scheme (SICP) ---
(use-package geiser-racket
  :ensure t
  :hook (scheme-mode . geiser-mode)
  :custom
  ;; Указываем Geiser использовать Racket по умолчанию
  (geiser-active-implementations '(racket))
  ;; Отключаем всплывающие окна с документацией, чтобы не отвлекали
  (geiser-autodoc-mode nil))

;; --- Настройка текста и переноса строк ---
;; Включаем визуальный перенос строк (мягкий перенос по границе окна)
;; только для текстовых режимов (Org-mode, Markdown, обычный текст)
(add-hook 'text-mode-hook 'visual-line-mode)

;; --- Система быстрого захвата (Org Capture) ---
(use-package org
  :ensure nil ; Пакет встроен в ядро, скачивать не нужно
  :bind ("C-c c" . org-capture) ; Глобальный шорткат для вызова меню захвата
  :custom
  ;; Записывать время закрытия задачи
  (org-log-done 'time)
  ;; Прятать логи и заметки в ящик
  (org-log-into-drawer t)
  :config
  ;; Настраиваем шаблоны
  (setq org-capture-templates
        `(("e" "Emacs Шпаргалка" plain
           ;; Указываем путь к нашему файлу-шпаргалке внутри проекта Emacs
           (file ,(expand-file-name "cheatsheet.org" user-emacs-directory))
           ;; Шаблон: Emacs сам спросит комбинацию и описание, а потом подставит их сюда
           "- =%^{Комбинация клавиш}= :: %^{Описание}\n"
           ;; Добавлять новые записи в самый конец файла
           :append t))))

;; --- Git интерфейс (Magit) ---
(use-package magit
  ;; Назначаем глобальный шорткат для открытия панели Magit
  :bind ("C-x g" . magit-status)
  :defer 1)

;; --- Фикс для Magit/Server на Windows ---
(when (eq system-type 'windows-nt)
  (defun my-server-ensure-safe-dir (dir) "Создает директорию DIR, если её нет, но пропускает строгую проверку прав на Windows."
	 (unless (file-exists-p dir) (make-directory dir t)) t)
  (advice-add 'server-ensure-safe-dir :override #'my-server-ensure-safe-dir))

;; Явно указываем абсолютный путь к emacsclient для Magit
(with-eval-after-load 'with-editor
  (when (eq system-type 'windows-nt)
    (setq with-editor-emacsclient-executable (expand-file-name "emacsclient.exe" invocation-directory))))
;; Запускаем сервер Emacs (теперь он использует наш фикс безопасной директории)
(server-mode 1)

;; --- Настройка SSH для Magit в Windows ---
;; Указываем Git использовать нативный SSH-клиент Windows, 
;; который умеет работать с системным ssh-agent (и KeePassXC)
(when (eq system-type 'windows-nt)
  (setenv "GIT_SSH" "C:/Windows/System32/OpenSSH/ssh.exe"))

(use-package which-key
  :ensure nil ; Явно указываем, что пакет встроен в ядро (не требует скачивания)
  :defer 2   ; Ленивая загрузка: загрузить в фоне через 2 секунды простоя
  :config    ; Код в этом блоке выполнится ТОЛЬКО после того, как пакет загрузится
  (which-key-mode 1))

;; --- Автодополнение в буфере (Corfu) ---
(use-package corfu
  :custom
  (corfu-auto t)          ;; Автоматически выводить подсказки при печати
  (corfu-quit-no-match t) ;; Скрывать окно, если совпадений больше нет
  :init
  (global-corfu-mode))

;; --- Визуализация дерева отмены (Vundo) ---
(use-package vundo
  :bind ("C-x u" . vundo))

;; --- Продвинутая самодокументация (Helpful) ---
(use-package helpful
  :bind
  ;; remap перехватывает вызовы стандартных функций справки и заменяет их на helpful
  ([remap describe-function] . helpful-callable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key))

;; --- Модульная система ---
;; Добавляем папку lisp в пути поиска Emacs
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Подключаем наши модули
(require 'depthzer0-workspaces)

;; Подключаем иконки к дашборду
(setq dashboard-icon-type 'nerd-icons)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)

;; Возвращаем сборщик мусора в нормальное состояние (16 MB) после загрузки
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))
