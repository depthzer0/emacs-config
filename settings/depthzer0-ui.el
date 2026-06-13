;;; depthzer0-ui.el --- Визуальное оформление и интерфейс -*- lexical-binding: t; -*-

;;; Commentary:
;; Модуль отвечает за внешний вид редактора.
;; Включает в себя настройку шрифтов, цветовой темы (Zenburn),
;; стартового экрана (Dashboard), панели вкладок (Tab-bar) и иконок.

;;; Code:

;; --- Настройка шрифта ---
(let* ((my-size 11)
       (my-prop-size 12)
       (my-mono-font "FiraCode Nerd Font Mono")
       ;; Список пропорциональных шрифтов от самого желанного к запасному
       (prop-fonts '("Segoe UI" "Ubuntu" "Noto Sans" "Roboto" "Arial"))
       ;; Ищем первый шрифт из списка, который установлен в системе
       (my-prop-font (seq-find (lambda (f) (find-font (font-spec :name f))) prop-fonts)))
  
  ;; 1. Устанавливаем моноширинные шрифты (если FiraCode найден)
  (when (find-font (font-spec :name my-mono-font))
    (set-face-attribute 'default nil :font (format "%s-%d" my-mono-font my-size))
    (set-face-attribute 'fixed-pitch nil :font (format "%s-%d" my-mono-font my-size)))
  
  ;; 2. Устанавливаем пропорциональный шрифт (если нашёлся хотя бы один из списка)
  (when my-prop-font
    (set-face-attribute 'variable-pitch nil :font (format "%s-%d" my-prop-font my-prop-size))))

;; --- Внешний вид (Тема оформления) ---
(use-package zenburn-theme
  :ensure t
  :init
  ;; Задаем новые цвета ДО того, как тема начнет загружаться
  (setq zenburn-override-colors-alist
        '(("zenburn-bg" . "#353535")))
  :config
  (load-theme 'zenburn t))

;; --- Иконки ---
(use-package nerd-icons
  :ensure t
  :custom
  ;; Явно указываем движку использовать наш моноширинный шрифт
  (nerd-icons-font-family "FiraCode Nerd Font Mono"))

;; --- Стартовый экран (Dashboard) ---
(use-package dashboard
  :ensure t
  :custom
  ;; Наш ASCII баннер
  (dashboard-startup-banner "
  _____ __  __          _____  _____ 
 |  ___|  \\/  |   /\\   / ____|/ ____|
 | |__ | \\  / |  /  \\ | |    | (___  
 |  __|| |\\/| | / /\\ \\| |     \\___ \\ 
 | |___| |  | |/ ____ \\ |____ ____) |
 |_____|_|  |_/_/    \\_\\_____|_____/ 
")
  ;; Центрируем контент по горизонтали
  (dashboard-center-content t)
  
  ;; Указываем, какие виджеты выводить и по сколько строк
  (dashboard-items '((recents  . 5)
                     (projects . 5)))
                     
  ;; Подключаем иконки к дашборду (перенесено из конца старого init.el)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  
  :config
  ;; Команда, которая заменяет стандартный *scratch* на дашборд при старте
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook (lambda () (setq default-directory "~/"))))

;; --- Панель вкладок (Workspaces) ---
;; Включаем панель вкладок
(tab-bar-mode 1)
;; Указываем, что новая вкладка должна открывать дашборд
(setq tab-bar-new-tab-choice "*dashboard*")

;; --- Настройка текста и переноса строк ---
;; Включаем визуальный перенос строк (мягкий перенос по границе окна)
;; только для текстовых режимов (Org-mode, Markdown, обычный текст)
(add-hook 'text-mode-hook 'visual-line-mode)

(provide 'depthzer0-ui)
;;; depthzer0-ui.el ends here
