;; emacs
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-display-line-numbers-mode t)
(global-visual-line-mode t)
(global-auto-revert-mode t)
(setq auto-revert-interval 5)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

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
        '(("WenQuanYi Zen Hei Mono" . 1.05)))

  ;; 黑底白字
  (set-face-attribute 'default nil
                      :background "#2b2b2b"
                      :foreground "#dcdccc")
  ;; 关键字（function, struct, if, end）
  (set-face-attribute 'font-lock-keyword-face nil
                      :foreground "#96cbfe"  ;; 柔蓝
                      :weight 'bold)

  ;; 函数名
  (set-face-attribute 'font-lock-function-name-face nil
                      :foreground "#ffd2a7") ;; 偏黄

  ;; 类型 / struct / abstract
  (set-face-attribute 'font-lock-type-face nil
                      :foreground "#ffffb6") ;; 淡黄

  ;; 变量名
  (set-face-attribute 'font-lock-variable-name-face nil
                      :foreground "#dcdccc")

  ;; 字符串
  (set-face-attribute 'font-lock-string-face nil
                      :foreground "#a8ff60") ;; Vim 风绿

  ;; 注释（不抢眼，但清楚）
  (set-face-attribute 'font-lock-comment-face nil
                      :foreground "#7f9f7f"
                      :slant 'italic)

  ;; 常量
  (set-face-attribute 'font-lock-constant-face nil
                      :foreground "#dca3a3"))

;; packages
;(setq package-archives '(("gnu"   . "http://mirror.nju.edu.cn/elpa/gnu/")
;                         ("melpa" . "http://mirror.nju.edu.cn/elpa/melpa/")))
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize) ;; You might already have this line
(defvar my-packages '(magit
		      org-ref
		      julia-mode
		      helm-bibtex
		      cdlatex
		      auctex
		      valign
                      rainbow-delimiters
		      org-fragtog
		      matlab-mode
		      vterm vterm-toggle
		      evil evil-collection))

(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))

;; helm
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(helm-mode 1)
(global-set-key (kbd "C-c h") #'helm-bibtex)

;; latex-mode
(setq-default TeX-engine 'xetex)

;; org-mode
(setq org-directory "~/notes")
(setq org-default-notes-file "~/notes/quicknote.org")
(setq org-agenda-files '("~/notes"))
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(with-eval-after-load 'org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "DOING(i)" "|" "DONE(d)" "CANCELLED(c)"))))
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/notes/quicknote.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/notes/dairy.org")
         "* %?\nEntered on %U\n  %i\n  %a")
	("n" "note" entry (file "~/notes/quicknote.org")
         "* %? :NOTE:\n%U\n%a\n")))
(setq org-file-apps
      (quote
       ((auto-mode . emacs)
	("\\.pdf\\'" . "zathura %s"))))
;; 表格对齐
(add-hook 'org-mode-hook #'valign-mode)
; 上面这个好像说处理大型表格不太行，alternative: https://github.com/TobiasZawada/orgplus-align-tables

;; org-ref
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
(require 'bibtex)
(setq bibtex-autokey-year-length 4
      bibtex-autokey-name-year-separator "-"
      bibtex-autokey-year-title-separator "-"
      bibtex-autokey-titleword-separator "-"
      bibtex-autokey-titlewords 2
      bibtex-autokey-titlewords-stretch 1
      bibtex-autokey-titleword-length 5)
(define-key bibtex-mode-map (kbd "C-c ]") 'org-ref-bibtex-hydra/body)
(require 'org-ref)
(require 'org-ref-helm)
(define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link-hydra/body)

;; org-latex
(add-hook 'org-mode-hook 'org-fragtog-mode)
(setq org-startup-with-latex-preview t)
(setq org-startup-with-inline-images t)
(setq org-startup-folded t)
(setq org-preview-latex-default-process 'dvisvgm)
(defun my/text-scale-adjust-latex-previews ()
  "Adjust the size of latex preview fragments when changing the
buffer's text scale."
  (pcase major-mode
    ('latex-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (if (eq (overlay-get ov 'category)
               'preview-overlay)
           (my/text-scale--resize-fragment ov))))
    ('org-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (if (eq (overlay-get ov 'org-overlay-type)
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
(setq org-latex-default-packages-alist nil)
(setq org-latex-packages-alist nil)
(setq org-latex-hyperref-template nil)
(setq org-latex-compiler "xelatex")

;; og-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (julia . t)
   (calc . t)
   (emacs-lisp . t)))

;; vterm
(use-package vterm
  :ensure t
  :commands vterm
  :config
  ;; 用系统 shell
  (setq vterm-shell "/usr/bin/zsh")

  ;; 回滚历史行数
  (setq vterm-max-scrollback 10000)

  ;; 不让 vterm 抢 Emacs 的 M-x 等键
  (setq vterm-keymap-exceptions
        '("C-c" "C-x" "C-u" "M-x" "M-o" "M-p" "M-n")))

(defun my/vterm-here ()
  "Open vterm in current buffer's directory."
  (interactive)
  (let ((default-directory (or (and (buffer-file-name)
                                    (file-name-directory (buffer-file-name)))
                               default-directory)))
    (vterm (generate-new-buffer-name "*vterm*"))))

(use-package vterm-toggle
  :ensure t
  :bind (("C-<return>" . vterm-toggle)))

;; evil-mode
;; 必须在加载 evil 之前设置
(setq evil-want-integration t
      evil-want-keybinding nil      ;; 让 evil-collection 接管各 mode 的键位
      evil-want-C-u-scroll t)

(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
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

  (defun shh/evil-q ()
    "Vim-like :q.
If multiple windows: delete current window.
If single window: kill current buffer (do NOT exit Emacs)."
    (interactive)
    (if (one-window-p)
        (kill-current-buffer)
      (delete-window)))
  (defun shh/evil-q-bang ()
    "Vim-like :q! (force).
Kill current buffer without saving; if multiple windows, still just close this view."
    (interactive)
    (let ((kill-buffer-query-functions nil)) ; avoid some prompts when killing buffer
      (set-buffer-modified-p nil)
      (shh/evil-q)))

  (defun shh/evil-wq ()
    "Vim-like :wq."
    (interactive)
    (save-buffer)
    (shh/evil-q))

  ;; bind Ex commands
  (evil-ex-define-cmd "q"  #'shh/evil-q)
  (evil-ex-define-cmd "q!" #'shh/evil-q-bang)
  (evil-ex-define-cmd "wq" #'shh/evil-wq)

  ;; only these exit Emacs
  (evil-ex-define-cmd "qa"  #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "qall" #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "wqa" (lambda () (interactive)
                              (save-some-buffers t)
                              (save-buffers-kill-terminal))))

(use-package dired
  :ensure nil
  :config
  ;; 总是递归删除 / 复制
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always))

(with-eval-after-load 'dired
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

(with-eval-after-load 'dired
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
