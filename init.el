;;; -*- lexical-binding: t; -*-

;; Мой первый конфигурационный файл Emacs

;; Отключаем звуковой сигнал (beep) при ошибках
(setq ring-bell-function 'ignore)

;; Стартовое окно
(setq inhibit-startup-message t)

;; Включаем встроенный режим повторения команд (удобно для окон, undo и т.д.)
(repeat-mode 1)

;; Удалять выделенный текст при нажатии Backspace или вводе нового текста
(delete-selection-mode 1)

;; Включаем панель вкладок (Workspaces)
(tab-bar-mode 1)

;; --- Настройка шрифта ---

;; Проверяем, есть ли нужный шрифт в системе, чтобы избежать ошибок
;;(let ((my-font "JetBtains Mono")
;;(let ((my-font "Hack")
(let ((my-font "Fira Code")
      (my-size 11))
  (when (member my-font (font-family-list))
    ;; 1. Основной моноширинный шрифт (для кода)
    (set-face-attribute 'default nil :font (format "%s-%d" my-font my-size))
    ;; 2. Явно указываем моноширинный шрифт для таблиц и выравниваний
    (set-face-attribute 'fixed-pitch nil :font (format "%s-%d" my-font my-size))
    ;; 3. Пропорциональный шрифт (для чтения текста, например в Org-mode)
    ;; "Sans Serif" — это системный алиас, ОС сама подберет красивый шрифт без засечек
    (set-face-attribute 'variable-pitch nil :font (format "Sans Serif-%d" my-size))))

;; Сохранять сессию (открытые буферы, окна и вкладки) между запусками
(desktop-save-mode 1)

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

;; --- Менеджер пакетов ---
(require 'package)

;; Добавляем MELPA в список репозиториев
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Настраиваем приоритеты репозиториев (чем больше число, тем выше приоритет)
(setq package-archive-priorities
      '(("gnu"    . 10)    ; Официальный репозиторий Emacs (самый надежный)
        ("nongnu" . 5)     ; Официальный репозиторий для пакетов вне ядра
        ("melpa"  . 0)))   ; Репозиторий сообщества (самые свежие версии)

;; Инициализируем менеджер пакетов
(package-initialize)

;; --- Инициализация use-package ---
(require 'use-package)

;; Заставляем use-package автоматически скачивать пакеты из MELPA, 
;; если их нет на компьютере (заменяет ручное написание :ensure t)
(setq use-package-always-ensure t)

;; --- Пользовательские пакеты ---

(use-package which-key
  :ensure nil ; Явно указываем, что пакет встроен в ядро (не требует скачивания)
  :defer 2   ; Ленивая загрузка: загрузить в фоне через 2 секунды простоя
  :config    ; Код в этом блоке выполнится ТОЛЬКО после того, как пакет загрузится
  (which-key-mode 1))

;; Включение обработки нажатий в русской раскладке
(use-package reverse-im
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

;; --- Git интерфейс (Magit) ---
(use-package magit
  ;; Назначаем глобальный шорткат для открытия панели Magit
  :bind ("C-x g" . magit-status)
  :defer 1)

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

;; --- Внешний вид (Тема оформления) ---
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  
  ;; Добавляем нашу личную папку в список мест, где Emacs ищет темы
  (add-to-list 'custom-theme-load-path (expand-file-name "themes/" user-emacs-directory))
  
  ;; Загружаем НАШУ форкнутую тему
  (load-theme 'doom-dark++ t))
  
;; Удобная навигация в Dired
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "DEL") 'dired-up-directory))
