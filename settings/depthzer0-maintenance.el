;;; depthzer0-maintenance.el --- Обслуживание и автоматизация системы -*- lexical-binding: t; -*-

;;; Commentary:
;; Настройка пакетов для поддержания конфигурации и автоматизации рутины.
;; Содержит настройку шаблонов файлов (autoinsert) и системные хаки (reverse-im).

;;; Code:

;; --- Шаблонизатор (Autoinsert) ---
(use-package autoinsert
  :ensure nil
  :init
  (auto-insert-mode 1)
  :config
  (setq auto-insert-query nil)
  (setq auto-insert-directory (locate-user-emacs-file "templates/"))
  (add-to-list 'auto-insert-alist '("\\.gitignore\\'" . "gitignore.template"))
  (add-to-list 'auto-insert-alist '("\\.org\\'" . "org.template")))

;; --- Поддержка русской раскладки для горячих клавиш ---
(use-package reverse-im
  :ensure t
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

(provide 'depthzer0-maintenance)
;;; depthzer0-maintenance.el ends here
