;;; -*- lexical-binding: t; -*-

;; Запрещаем Emacs менять размер окна при загрузке шрифтов
(setq frame-inhibit-implied-resize t)

;; Говорим C-ядру не выделять место под элементы UI при создании окна
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Отключаем всплывающие подсказки (оставляем старый вариант, так как это Lisp-фича)
(tooltip-mode -1)
