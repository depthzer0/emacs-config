;;; init.el --- Точка входа конфигурации Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Это главный конфигурационный файл. Его единственная задача —
;; инициализировать менеджер пакетов и загрузить модули из папок settings/ и lisp/.

;;; Code:

;; --- 1. Настройка путей ---
;; Указываем Emacs, где искать наши самописные модули
(add-to-list 'load-path (expand-file-name "settings" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; --- 2. Инициализация менеджера пакетов (MELPA) ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq package-archive-priorities
      '(("gnu"    . 10)
        ("nongnu" . 5)
        ("melpa"  . 0)))

;; --- 3. Инициализация use-package ---
(require 'use-package)
;; Заставляем use-package автоматически скачивать пакеты, если их нет
(setq use-package-always-ensure t)

;; --- 4. Загрузка модулей (Порядок имеет значение!) ---
(require 'depthzer0-core)        ; Базовые настройки ядра
(require 'depthzer0-ui)          ; Внешний вид и интерфейс
(require 'depthzer0-minibuffer)  ; Экосистема поиска и автодополнения
(require 'depthzer0-tools)       ; Рабочие инструменты (Git, Dired, Org)
(require 'depthzer0-maintenance) ; Пакеты обслуживания
(require 'depthzer0-utils)       ; Самописные функции и скрипты
(require 'depthzer0-workspaces)  ; Кастомная логика воркспейсов

;; --- 5. Пост-загрузка ---
;; Возвращаем сборщик мусора в нормальное состояние (16 MB) 
;; после того, как early-init.el выделил ему максимум памяти для быстрого старта.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))

;;; init.el ends here
