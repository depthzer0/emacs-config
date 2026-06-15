;;; depthzer0-core.el --- Базовые настройки ядра Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Этот модуль содержит фундаментальные настройки поведения редактора.
;; Здесь настраиваются встроенные механизмы: работа с файлами, бэкапы,
;; отключение лишних звуков, поведение окон и базовые переменные среды.
;; Философия модуля: только встроенный функционал, никаких внешних пакетов.

;;; Code:

;; --- Глобальная кодировка (UTF-8 Everywhere) ---
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; --- Отключаем звуковой сигнал (beep) при ошибках ---
(setq ring-bell-function 'ignore)

;; --- Устанавливаем домашнюю директорию по умолчанию для новых буферов ---
(setq-default default-directory "~/")

;; --- Изоляция автоматически сгенерированного кода ---
(setq custom-file (expand-file-name "custom-auto.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; --- Отключение сохранения сессии между запусками ---
(desktop-save-mode -1)

;; --- Удалять выделенный текст при нажатии Backspace ---
(delete-selection-mode 1)

;; --- Отображение номеров строк ---
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; --- Настройка окон и встроенного режима повторения (repeat-mode) ---
(repeat-mode 1)

(global-set-key (kbd "C-x ]") 'enlarge-window)
(global-set-key (kbd "C-x [") 'shrink-window)

(defvar my-window-resize-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "]") 'enlarge-window)
    (define-key map (kbd "[") 'shrink-window)
    (define-key map (kbd "}") 'enlarge-window-horizontally)
    (define-key map (kbd "{") 'shrink-window-horizontally)
    map)
  "Моя кастомная карта для быстрого изменения размеров окон.")

(put 'enlarge-window 'repeat-map 'my-window-resize-repeat-map)
(put 'shrink-window 'repeat-map 'my-window-resize-repeat-map)
(put 'enlarge-window-horizontally 'repeat-map 'my-window-resize-repeat-map)
(put 'shrink-window-horizontally 'repeat-map 'my-window-resize-repeat-map)

;; --- Оптимизация работы с файлами на Windows ---
(when (eq system-type 'windows-nt)
  ;; Отключаем запрос точных прав доступа и владельца файла (POSIX).
  ;; Это убирает кракозябры (слово "Отсутствует") в аннотациях Marginalia
  ;; и значительно ускоряет работу с файловой системой на Windows.
  (setq w32-get-true-file-attributes nil))

(provide 'depthzer0-core)
;;; depthzer0-core.el ends here
