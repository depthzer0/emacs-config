;;; depthzer0-minibuffer.el --- Современный интерфейс автодополнения -*- lexical-binding: t; -*-

;;; Commentary:
;; Экосистема современного минибуфера и поиска.
;; Заменяет стандартные механизмы Emacs на связку:
;; Vertico (UI) + Marginalia (аннотации) + Orderless (стиль поиска)
;; + Consult (продвинутые команды) + Corfu (автодополнение в буфере).

;;; Code:

;; --- Современный интерфейс (Минибуфер) ---
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; --- Аннотации в минибуфере (Заметки на полях) ---
(use-package marginalia
  :ensure t
  :init
  ;; Включаем глобальный минорный режим аннотаций
  (marginalia-mode 1))

;; --- Умный поиск (Orderless) ---
(use-package orderless
  :ensure t
  :custom
  ;; Указываем Emacs использовать orderless как основной стиль автодополнения
  (completion-styles '(orderless basic))
  ;; Тонкая настройка для путей к файлам (чтобы работали стандартные фишки вроде вложенности)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; --- Продвинутые команды поиска (Consult) ---
(use-package consult
  :ensure t
  :bind (;; Заменяем стандартный поиск по файлу на продвинутый
         ("C-s" . consult-line)
         ;; Заменяем вставку из буфера
         ("M-y" . consult-yank-replace)
         ;; Заменяем стандартное переключение буферов
         ("C-x b" . consult-buffer)))

;; --- Автодополнение в буфере (Corfu) ---
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)          ;; Автоматически выводить подсказки при печати
  (corfu-quit-no-match t) ;; Скрывать окно, если совпадений больше нет
  :init
  (global-corfu-mode))

(provide 'depthzer0-minibuffer)
;;; depthzer0-minibuffer.el ends here
