;;;* Emacs
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-display-line-numbers-mode t)
;(global-visual-line-mode t)
(global-auto-revert-mode t)
(setq auto-revert-interval 5)
(setq inhibit-splash-screen t)
(setq initial-major-mode 'org-mode)
(setq initial-scratch-message nil)

;;;* Packages
;(setq package-archives '(("gnu"   . "http://mirror.nju.edu.cn/elpa/gnu/")
;                         ("melpa" . "http://mirror.nju.edu.cn/elpa/melpa/")))
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(setq use-package-always-ensure t)

;;;* Fonts
(when (display-graphic-p)
  ;; 英文字体（height=140 表示 14pt 左右，你可以改 160/180）
  (set-face-attribute 'default nil
                      :family "Source Code Pro"
                      :height 140)

  ;; 中文字体：直接指定，不做 member 检查
  (set-fontset-font t 'han
                    (font-spec :family "WenQuanYi Zen Hei Mono"))

  ;; 如果你觉得中文偏小/偏大，用这一行微调中文比例：
  ;; 例如 1.1 让中文稍大一点，0.95 让中文稍小一点
  (setq face-font-rescale-alist
        '(("WenQuanYi Zen Hei Mono" . 1.05))))

;;;* Theme
(use-package doom-themes
  :config
  ;; 启用一个主题
  (load-theme 'doom-zenburn t)

  ;; （可选，但推荐）更好的 org / diff / treemacs 支持
  (doom-themes-org-config)
  (doom-themes-visual-bell-config))

;;;* Helm
(use-package helm
  :bind (("M-x"     . helm-M-x)
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-f" . helm-find-files))
  :init
  (helm-mode 1))

(use-package helm-bibtex
  :after helm
  :bind (("C-c h" . helm-bibtex)))

;;;* Evil mode
(use-package evil
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil      ;; 让 evil-collection 接管各 mode 的键位
	evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; 特殊情况：这些 buffer 不用 Evil
(dolist (hook '(eshell-mode-hook
                shell-mode-hook
                term-mode-hook
                vterm-mode-hook
                minibuffer-setup-hook))
  (add-hook hook (lambda () (evil-local-mode -1))))

(global-set-key (kbd "C-c v")		;evil-mode快捷键
                (lambda ()
                  (interactive)
                  (if (bound-and-true-p evil-local-mode)
                      (evil-local-mode -1)
                    (evil-local-mode 1))))

(with-eval-after-load 'evil
  ;; 让 emacs-state 里按 ESC 回到 normal（像 Vim 一样）
  (define-key evil-emacs-state-map [escape] #'evil-normal-state)

  ;; 一些“像 Vim 的进入插入点”的动作，但进入的是 emacs-state
  (defun my/evil-emacs-insert ()
    "像 vim 的 i：进入 emacs-state 开始输入（Emacs 键位）。"
    (interactive)
    (evil-emacs-state))

  (defun my/evil-emacs-append ()
    "像 vim 的 a：右移一格再进入 emacs-state。"
    (interactive)
    (unless (eolp) (forward-char 1))
    (evil-emacs-state))

  (defun my/evil-emacs-open-below ()
    "像 vim 的 o：下一行新开一行再进入 emacs-state。"
    (interactive)
    (end-of-line)
    (newline-and-indent)
    (evil-emacs-state))

  (defun my/evil-emacs-open-above ()
    "像 vim 的 O：上一行新开一行再进入 emacs-state。"
    (interactive)
    (beginning-of-line)
    (newline)
    (forward-line -1)
    (indent-according-to-mode)
    (evil-emacs-state))

  ;; 用这些替换 normal 里的 i/a/o/O
  (evil-define-key 'normal 'global
    (kbd "i") #'my/evil-emacs-insert
    (kbd "a") #'my/evil-emacs-append
    (kbd "o") #'my/evil-emacs-open-below
    (kbd "O") #'my/evil-emacs-open-above)

  ;; 可选：也给 I/A 做同样事
  (evil-define-key 'normal 'global
    (kbd "I") (lambda () (interactive) (beginning-of-line) (evil-emacs-state))
    (kbd "A") (lambda () (interactive) (end-of-line) (evil-emacs-state)))

;; 关键：只让由 change 触发的 insert，切到 emacs-state
  (defvar my/evil--change-triggered nil)

  (advice-add 'evil-change :around
              (lambda (orig &rest args)
                (let ((my/evil--change-triggered t))
                  (apply orig args))))

  (add-hook 'evil-insert-state-entry-hook
            (lambda ()
              (when my/evil--change-triggered
                (setq my/evil--change-triggered nil)
                (evil-emacs-state))))

  (defun my/evil-q ()
    "Vim-like :q.
If multiple windows: delete current window.
If single window: kill current buffer (do NOT exit Emacs)."
    (interactive)
    (if (one-window-p)
        (kill-current-buffer)
      (delete-window)))
  (defun my/evil-q-bang ()
    "Vim-like :q! (force).
Kill current buffer without saving; if multiple windows, still just close this view."
    (interactive)
    (let ((kill-buffer-query-functions nil)) ; avoid some prompts when killing buffer
      (set-buffer-modified-p nil)
      (my/evil-q)))

  (defun my/evil-wq ()
    "Vim-like :wq."
    (interactive)
    (save-buffer)
    (my/evil-q))

  ;; bind Ex commands
  (evil-ex-define-cmd "q"  #'my/evil-q)
  (evil-ex-define-cmd "q!" #'my/evil-q-bang)
  (evil-ex-define-cmd "wq" #'my/evil-wq)

  ;; only these exit Emacs
  (evil-ex-define-cmd "qa"  #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "qall" #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "wqa" (lambda () (interactive)
                              (save-some-buffers t)
                              (save-buffers-kill-terminal))))

;;;* Org mode
(use-package org
  :ensure nil
  :init
  (setq org-directory "~/notes"
        org-default-notes-file "~/notes/quicknote.org"
        org-agenda-files '("~/notes"))
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (setq org-todo-keywords
        '((sequence "TODO(t)" "DOING(i)" "|" "DONE(d)" "CANCELLED(c)")))

  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "~/notes/quicknote.org" "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("j" "Journal" entry (file+olp+datetree "~/notes/dairy.org")
           "* %?\nEntered on %U\n  %i\n  %a")
          ("n" "note" entry (file "~/notes/quicknote.org")
           "* %? :NOTE:\n%U\n%a\n")))

  (setq org-file-apps
        '((auto-mode . emacs)
          ("\\.pdf\\'" . "zathura %s")))

  (setq org-startup-with-latex-preview t
	org-startup-with-inline-images t
	org-startup-folded t
	org-preview-latex-default-process 'dvisvgm)

  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.6))
  (setq org-format-latex-options
	(plist-put org-format-latex-options
                   :foreground (face-foreground 'default)))
  (setq org-format-latex-options
	(plist-put org-format-latex-options
                   :background (face-background 'default))))

;; 表格对齐
(use-package valign
  :hook (org-mode . valign-mode))
; 上面这个好像说处理大型表格不太行，alternative: https://github.com/TobiasZawada/orgplus-align-tables

;;;* Org-ref / Bibtex
(use-package bibtex
  :ensure nil
  :config
  (setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5))

(use-package org-ref
  :after org
  :config
  (setq bibtex-completion-bibliography '("~/notes/ref.bib"
					 "~/paper/01/fifth.bib"
					 "~/paper/00/confining.bib")
	bibtex-completion-library-path '("~/Research/")
					;bibtex-completion-pdf-field "File"
	bibtex-completion-find-additional-pdfs t
	bibtex-completion-pdf-extension '(".pdf" ".djvu" ".ps")
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "zathura" nil 0 nil fpath))
	bibtex-completion-pdf-symbol "⌘"
	bibtex-completion-notes-symbol "✎"
	bibtex-completion-notes-path "~/notes/reading.org"
	bibtex-completion-notes-template-one-file
	(concat
	 "** ${title}\n"
	 "    :PROPERTIES:\n"
	 "      :Custom_ID: ${=key=}\n"
	 "      :AUTHOR: ${author-or-editor}\n"
	 "      :JOURNAL: ${journal}\n"
	 "      :YEAR: ${year}\n"
	 "      :DOI: ${doi}\n"
	 "      :URL: ${url}\n"
	 "    :END:\n\n"
	 "[[cite:&${=key=}]]\n"
	 )
	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	`((t . ,(concat
		 "${=has-pdf=:1}${=has-note=:1} "
		 "[${=key=}] "
		 "${author:15} "
		 "${title:*}"))))
  (with-eval-after-load 'bibtex
    (define-key bibtex-mode-map (kbd "C-c ]") #'org-ref-bibtex-hydra/body))
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c ]") #'org-ref-insert-link-hydra/body)))

;;;* Org LaTeX
(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode)
  :defer t)
(with-eval-after-load 'evil
  (defun shh/org-fragtog-evil-control ()
    "Enable org-fragtog only in emacs/insert state, disable in normal."
    (when (and (derived-mode-p 'org-mode)
               (boundp 'org-fragtog-mode))
      (pcase evil-state
        ('normal
         (when org-fragtog-mode
           (org-fragtog-mode -1)))
        ((or 'insert 'emacs)
         (unless org-fragtog-mode
           (org-fragtog-mode 1)))
        (_ nil))))

  ;; 在 evil 状态变化后执行
  (add-hook 'evil-normal-state-entry-hook #'shh/org-fragtog-evil-control)
  (add-hook 'evil-insert-state-entry-hook #'shh/org-fragtog-evil-control)
  (add-hook 'evil-emacs-state-entry-hook  #'shh/org-fragtog-evil-control))

(defun my/text-scale-adjust-latex-previews ()
  "Adjust the size of latex preview fragments when changing the
buffer's text scale."
  (pcase major-mode
    ('latex-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (when (eq (overlay-get ov 'category)
		 'preview-overlay)
         (my/text-scale--resize-fragment ov))))
    ('org-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (when (eq (overlay-get ov 'org-overlay-type)
		 'org-latex-overlay)
         (my/text-scale--resize-fragment ov))))))
(defun my/text-scale--resize-fragment (ov)
  (overlay-put
   ov 'display
   (cons 'image
         (plist-put
          (cdr (overlay-get ov 'display))
          :scale (+ 1.0 (* 0.25 text-scale-mode-amount))))))
(add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews)

;; org-latex-export
(with-eval-after-load 'ox-latex
  (setq org-latex-default-packages-alist nil
        org-latex-packages-alist nil
        org-latex-hyperref-template nil
        org-latex-compiler "xelatex"))

;;;* Org Babel
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (julia . t)
     (calc . t)
     (emacs-lisp . t))))

;;;* Vterm
(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "/usr/bin/zsh")

  ;; 回滚历史行数
  (setq vterm-max-scrollback 10000)

  ;; 不让 vterm 抢 Emacs 的 M-x 等键
  (setq vterm-keymap-exceptions
        '("C-c" "C-x" "C-u" "M-x" "M-o" "M-p" "M-n")))

(use-package vterm-toggle
  :bind (("C-<return>" . vterm-toggle)
         ("C-c t"      . vterm-toggle)))

;;;* Dired
(use-package dired
  :ensure nil
  :config
  ;; 总是递归删除 / 复制
  (setq dired-recursive-deletes 'always
	dired-recursive-copies 'always)

  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file))

  (defun shh-dired-open-image-feh ()
    "Open the image at point using feh (external viewer)."
    (interactive)
    (let ((file (dired-get-file-for-visit)))
      (start-process
       "feh"
       nil
       "feh"
       "--auto-zoom"
       "--scale-down"
       file)))

  (defun shh-dired-find-file-advice (orig-fn &rest args)
    (let* ((file (dired-get-file-for-visit))
           (ext (downcase (or (file-name-extension file) ""))))
      (if (member ext '("png" "jpg" "jpeg" "gif" "webp" "tif" "tiff" "svg" "avif"))
          (shh-dired-open-image-feh)
        (apply orig-fn args))))
  (advice-add 'dired-find-file :around #'shh-dired-find-file-advice)

  ;; 显式快捷键（可选）
  (define-key dired-mode-map (kbd "E") #'shh-dired-open-image-feh))

;; 代码折叠
(add-hook 'prog-mode-hook #'hs-minor-mode)
(defun my/outline-setup-elisp ()
  "Outline folding for init.el style headings."
  (setq-local outline-regexp ";;;\\*+ ")
  (outline-minor-mode 1))

(add-hook 'emacs-lisp-mode-hook #'my/outline-setup-elisp)
(add-hook 'lisp-interaction-mode-hook #'my/outline-setup-elisp)

;;;; Open PDF-like files with zathura (from dired or find-file)
(defgroup shh-external-doc nil
  "Open some documents externally."
  :group 'convenience)

(defcustom shh-external-doc-extensions '("pdf" "djvu" "ps" "eps")
  "File extensions to open with zathura."
  :type '(repeat string))

(defcustom shh-zathura-program "zathura"
  "Zathura executable name."
  :type 'string)

(defun shh--external-doc-p (filename)
  (let ((ext (downcase (or (file-name-extension filename) ""))))
    (member ext shh-external-doc-extensions)))

(defun shh-open-with-zathura (file)
  "Open FILE with zathura asynchronously."
  (start-process "zathura" nil shh-zathura-program (expand-file-name file)))

(define-derived-mode shh-external-doc-mode special-mode "ExternalDoc"
  "Major mode for docs that should be opened externally."
  (let ((file buffer-file-name))
    (when (and file (file-exists-p file) (shh--external-doc-p file))
      (shh-open-with-zathura file)
      ;; 不留在 Emacs 里
      (let ((buf (current-buffer)))
        (run-at-time 0 nil (lambda (b) (when (buffer-live-p b) (kill-buffer b))) buf)))))

;; 让这些扩展名走上面的 mode（dired 和 C-x C-f 都会生效）
(dolist (ext shh-external-doc-extensions)
  (add-to-list 'auto-mode-alist
               (cons (format "\\.%s\\'" (regexp-quote ext)) #'shh-external-doc-mode)))

;; dired 复制文件到剪贴板
(defun dired-copy-files-to-x-clipboard ()
  "Copy marked files in dired to system clipboard as file URIs (X11)."
  (interactive)
  (let* ((files (dired-get-marked-files))
         (uris (mapconcat
                (lambda (f) (concat "file://" (expand-file-name f)))
                files "\n")))
    (with-temp-buffer
      (insert uris)
      (call-process-region
       (point-min) (point-max)
       "xclip" nil nil nil
       "-selection" "clipboard"
       "-t" "text/uri-list"))
    (message "Copied %d file(s) to clipboard" (length files))))
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c C-c")
    #'dired-copy-files-to-x-clipboard))

(defun my/dired-home ()
  "Switch to ~/ dired buffer, or open one if it doesn't exist."
  (interactive)
  (if-let ((buf (cl-find-if
                 (lambda (b)
                   (with-current-buffer b
                     (and (eq major-mode 'dired-mode)
                          (string-equal
                           (expand-file-name default-directory)
                           (expand-file-name "~")))))
                 (buffer-list))))
      (switch-to-buffer buf)
    (dired "~")))

(global-set-key (kbd "C-c f") #'my/dired-home)

;;;* Ibuffer
(use-package ibuffer
  :ensure nil
  :bind (("C-x C-b" . ibuffer))
  :init
  (setq ibuffer-saved-filter-groups
	'(("main"
	   ("Scratch" (name . "^\\*scratch\\*$"))
           ("fm" (mode . dired-mode))
           ("Programming" (derived-mode . prog-mode))
	   ("Org"
            (or
             (derived-mode . org-mode)
             (mode . org-agenda-mode)
             (mode . org-capture-mode)
             (name . "^\\*Org Src")
             (name . "^\\*org-src")
             (name . "^\\*Org Agenda\\*")))
           ("Terminal" (mode . vterm-mode))
           ("Emacs" (name . "^\\*")))))
  :hook
  (ibuffer-mode . (lambda ()
                    (ibuffer-switch-to-saved-filter-groups "main")
                    (ibuffer-update nil t))))

;;;* Fcitx.el (for fcitx5)
(use-package fcitx
  :config
  ;; Prefix-key
  (fcitx-prefix-keys-add "C-x" "C-c")
  (fcitx-prefix-keys-turn-on)

  ;; Evil
  (fcitx-evil-turn-on)

  ;; Character & Key Input Support

  ;; org-speed-command Support

  ;; M-x, M-!, M-& and M-: Support
  ;(fcitx-M-x-turn-on)
  ;(fcitx-shell-command-turn-on)
  ;(fcitx-eval-expression-turn-on)

  ;; Disable Fcitx in MinibufferDisable Fcitx in Minibuffer
  (fcitx-aggressive-minibuffer-turn-on)

  ;; I-search Support
  (fcitx-isearch-turn-on)

  ;; Using D-Bus Interface
  (setq fcitx-use-dbus 'fcitx5))

;;;* Magit
(use-package magit
  :commands (magit-status magit-dispatch)
  :bind (("C-x g" . magit-status)))

;;;* Julia
(use-package julia-mode
  :mode "\\.jl\\'")

;;;* Programming helpers
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;;* Cdlatex
(use-package cdlatex
  :commands (cdlatex-mode org-cdlatex-mode))

;;;* Mode Line
;; 定义 Evil state
(defun shh/evil-state-label ()
  (when (bound-and-true-p evil-local-mode)
    (pcase evil-state
      ((or 'insert 'emacs)
       (propertize "--INSERT--"
                   'face '(:weight bold :foreground "#dca3a3")))
      ('visual
       (propertize "--VISUAL--"
                   'face '(:weight bold :foreground "#96cbfe")))
      (_ ""))))

;; 定义 buffer 名 + [+]
(defun shh/modeline-buffer-name ()
  (let ((name (buffer-name)))
    (concat
     "[" name "]"
     (if (buffer-modified-p) "[+]" ""))))

;; pwd
(defun shh/modeline-pwd ()
  "Return pretty pwd for mode-line.
Show ~ instead of ~/; other dirs unchanged."
  (let ((dir (abbreviate-file-name (expand-file-name default-directory))))
    (if (string= dir "~/")
        "~"
      (directory-file-name dir))))

;; 右侧
(defun shh/modeline-right ()
  (format "%d,%d  %s"
          (line-number-at-pos)
          (1+ (current-column))   ;; 列号从 1 开始
          (format-mode-line "%p")))

;; 组合
(setq-default
 mode-line-format
 '("%e "
   ;; 左侧：evil label（非 normal 才显示）
   (:eval (let ((s (shh/evil-state-label)))
            (if (string-empty-p (format "%s" s)) "" (concat s " "))))
   ;; 左侧：[buffer] + [+]
   (:eval (shh/modeline-buffer-name))
   " | pwd: "
   (:eval (shh/modeline-pwd))
   " |"
   " ["
   mode-name
   "]"

   ;; 右侧：行,列 + 百分比（纯数字）
   (:eval
    (let ((pos (shh/modeline-right)))
      (propertize " "
		  'display
		  `((space :align-to (- right ,(string-width pos)))))))
   (:eval (shh/modeline-right))
   ))
