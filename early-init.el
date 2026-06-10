;;; -*- lexical-binding: t; -*-

;; Отключаем сборщик мусора на время загрузки (выделяем максимум памяти)
(setq gc-cons-threshold most-positive-fixnum)

;; --- Стартовое окно ---
(setq inhibit-startup-message t)

;; Задаем точный размер окна (фрейма) в пикселях
(add-to-list 'default-frame-alist '(width  . (text-pixels . 2200)))
(add-to-list 'default-frame-alist '(height . (text-pixels . 1300)))

;; Позиционируем только самое первое окно при запуске
(add-to-list 'initial-frame-alist '(top . 5))
(add-to-list 'initial-frame-alist '(left . 150))

;; Запрещаем Emacs менять размер окна при загрузке шрифтов
(setq frame-inhibit-implied-resize t)

;; Говорим C-ядру не выделять место под элементы UI при создании окна
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Отключаем всплывающие подсказки
(tooltip-mode -1)
