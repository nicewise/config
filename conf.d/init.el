(defvar my/org-dir
  (expand-file-name "~/org-agenda/"))
(defvar my/research-dir
  (expand-file-name "~/Research/"))

;;;* Emacs
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-display-line-numbers-mode t)
(global-visual-line-mode t)
(global-auto-revert-mode t)
(setq auto-revert-interval 5)
(setq inhibit-splash-screen t)
(setq initial-major-mode 'org-mode)
(setq initial-scratch-message nil)

;;;* scratch
;; ===== 快速切换到 scratch 缓冲区 =====
(defun my/switch-to-scratch-buffer ()
  "Switch to /scratch/ buffer, create it if doesn't exist."
  (interactive)
  (let ((scratch-buffer (get-buffer-create "*scratch*")))
    (switch-to-buffer scratch-buffer)))

;; 绑定快捷键 C-c s
(global-set-key (kbd "C-c s") #'my/switch-to-scratch-buffer)

;;;* Windows move and resize
(global-set-key (kbd "C-c w h") #'windmove-left)
(global-set-key (kbd "C-c w l") #'windmove-right)
(global-set-key (kbd "C-c w k") #'windmove-up)
(global-set-key (kbd "C-c w j") #'windmove-down)

(global-set-key (kbd "C-x w h") #'shrink-window-horizontally)
(global-set-key (kbd "C-x w l") #'enlarge-window-horizontally)
(global-set-key (kbd "C-x w j") #'shrink-window)
(global-set-key (kbd "C-x w k") #'enlarge-window)

;;;* Packages
;(setq package-archives
;      '(("gnu"   . "https://elpa.gnu.org/packages/")
;        ("melpa" . "https://melpa.org/packages/")))
(setq package-archives
      '(("gnu"    . "https://mirror.nju.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirror.nju.edu.cn/elpa/nongnu/")
        ("melpa"  . "https://mirror.nju.edu.cn/elpa/melpa/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
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
  (doom-themes-org-config))
  ;(doom-themes-visual-bell-config))

;;;* Helm
(use-package helm
  :bind (("M-x"     . helm-M-x)
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-f" . helm-find-files))
  :init
  (helm-mode 1)
  :config
  ;; Ctrl+hjkl 导航绑定
  (define-key helm-map (kbd "C-j") 'helm-next-line)        ; 向下移动
  (define-key helm-map (kbd "C-k") 'helm-previous-line)    ; 向上移动
  (define-key helm-map (kbd "C-h") 'helm-previous-source)  ; 向左切换搜索源 / 文件搜索时返回上级目录
  (define-key helm-map (kbd "C-l") 'helm-execute-persistent-action) ; 向右进入目录/预览/执行当前项

  (define-key helm-map (kbd "C-f") 'helm-next-page)    ; 向下翻页
  (define-key helm-map (kbd "C-b") 'helm-previous-page) ; 向上翻页

  ;; 可选：文件搜索场景下的增强绑定
  (with-eval-after-load 'helm-files
    (dolist (keymap (list helm-find-files-map helm-read-file-map))
      (define-key keymap (kbd "C-h") 'helm-find-files-up-one-level)
      (define-key keymap (kbd "C-l") 'helm-execute-persistent-action))))

(use-package helm-bibtex
  :after helm
  :bind (("C-c h" . helm-bibtex)))

;;;* Evil mode
(use-package evil
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil) ;; 让 evil-collection 接管各 mode 的键位
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

  (evil-define-command my/evil-q ()
    "Vim-like :q and :q! (but never exits Emacs).
With bang (!), force kill without saving.
Without bang, refuse if buffer has unsaved changes."
    :ex-bang t
    (let* ((buf (current-buffer))
           (wins (get-buffer-window-list buf nil t)))
      (cond
       ;; Bang: force kill
       (evil-ex-bang
        (if (> (length wins) 1)
            (delete-window)
          (let ((kill-buffer-query-functions nil))
            (set-buffer-modified-p nil)
            (kill-current-buffer))))
       ;; No bang but modified: error
       ((and (buffer-modified-p buf) (buffer-file-name buf))
        (user-error "Buffer modified; use :q! (or save first)"))
       ;; No bang, not modified: normal close
       ((> (length wins) 1)
        (delete-window))
       (t
        (kill-current-buffer)))))

  (defun my/evil-wq ()
    "Vim-like :wq."
    (interactive)
    (save-buffer)
    (my/evil-q))

  ;; bind Ex commands
  (evil-ex-define-cmd "q" #'my/evil-q)
  (evil-ex-define-cmd "wq" #'my/evil-wq)
  (evil-ex-define-cmd "qa" #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "qall" #'save-buffers-kill-terminal)
  (evil-ex-define-cmd "wqa" (lambda () (interactive)
                              (save-some-buffers t)
                              (save-buffers-kill-terminal))))

;;;* Org mode
(use-package org
  :ensure nil
  :init
  (setq org-directory my/org-dir
	org-agenda-files
	(list (expand-file-name "todo.org" my/org-dir))
	org-archive-location
	(expand-file-name "archive.org::" my/org-dir))
  (defvar my/inbox-file
    (expand-file-name "inbox.org" my/org-dir))
  (defvar my/todo-file
    (expand-file-name "todo.org" my/org-dir))
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (setq org-todo-keywords
	'((sequence "TODO(t)" "|" "DONE(d)" "CANCELLED(c)")))

  (setq org-capture-templates
        '(("i" "Inbox" entry
           (file my/inbox-file)
           "* %?\n  %U\n")
	  ("t" "Todo" entry
	   (file my/todo-file)
           "* TODO %?\n  %i\n  %a")))

  (setq org-file-apps
        '((auto-mode . emacs)
          ("\\.pdf\\'" . "zathura %s")))

  (setq org-startup-with-latex-preview nil
	org-startup-with-inline-images nil
	org-startup-folded t
	org-preview-latex-default-process 'dvisvgm)

  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.2))
  (setq org-format-latex-options
	(plist-put org-format-latex-options
                   :foreground (face-foreground 'default)))
  (setq org-format-latex-options
	(plist-put org-format-latex-options
                   :background (face-background 'default))))

;;;** 表格对齐
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
  (setq bibtex-completion-bibliography
	(list (expand-file-name "ref.bib" my/research-dir))
	bibtex-completion-library-path
	(list my/research-dir)
	;; bibtex-completion-pdf-field "File"
	bibtex-completion-find-additional-pdfs t
	bibtex-completion-pdf-extension '(".pdf" ".djvu" ".ps")
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "zathura" nil 0 nil fpath))
	bibtex-completion-pdf-symbol "⌘"
	bibtex-completion-notes-symbol "✎"
	bibtex-completion-notes-path
	(expand-file-name "reading.org" my/research-dir)
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
  (add-hook 'evil-normal-state-entry-hook #'shh/org-fragtog-evil-control))
;; 下面这两个有需要再自己用吧
;;  (add-hook 'evil-insert-state-entry-hook #'shh/org-fragtog-evil-control)
;;  (add-hook 'evil-emacs-state-entry-hook  #'shh/org-fragtog-evil-control)

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
;; 添加防抖（debounce）
(defvar my/text-scale-timer nil)
(defun my/text-scale-adjust-latex-previews-debounced ()
  (when my/text-scale-timer
    (cancel-timer my/text-scale-timer))
  (setq my/text-scale-timer
        (run-with-idle-timer 0.3 nil
                             #'my/text-scale-adjust-latex-previews)))

(add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews-debounced)

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

;;;* Agent-shell (AI coding agents)
(use-package agent-shell
  :config
  (setq agent-shell-preferred-agent-config
	(agent-shell-opencode-make-agent-config)))

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

  ;; ===== 颜色增强 =====
  (set-face-attribute 'dired-directory nil
                      :foreground "#8cd0d3"      ; 亮青色目录
                      :weight 'bold)
  (set-face-attribute 'dired-symlink nil
                      :foreground "#f0dfaf"      ; 金色链接
                      :slant 'italic)
  (set-face-attribute 'dired-marked nil
                      :foreground "#cc9393"      ; 红色标记
                      :weight 'bold)
  (set-face-attribute 'dired-flagged nil
                      :foreground "#bc6c5c"      ; 深红待删除
                      :weight 'bold)

  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "/")   #'dired-narrow))

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

;;;** Dired-subtree (tree 式展开)
(use-package dired-subtree
  :after dired
  :config
  (setq dired-subtree-use-backgrounds nil)
  ;; tree 风格缩进
  (setq dired-subtree-line-prefix "│ ")
  (add-hook 'dired-subtree-after-insert-hook
            (lambda ()
              (when (fboundp 'hl-line-highlight)
                (hl-line-highlight))))
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))

;;;** Dired-narrow (实时过滤)
(use-package dired-narrow
  :load-path "~/open-source/dired-hacks"
  :bind (:map dired-mode-map
              ("/" . dired-narrow))
  :config
  ;; vim-like 导航，同时保留方向键
  (define-key dired-narrow-map (kbd "C-j") #'dired-narrow-next-file)
  (define-key dired-narrow-map (kbd "C-k") #'dired-narrow-previous-file)
  (define-key dired-narrow-map (kbd "C-l") #'dired-narrow-enter-directory))
;;;** Dired-rainbow (文件类型着色)
(use-package dired-rainbow
  :config
  (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
  (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
  (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
  (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
  (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
  (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
  (dired-rainbow-define media "#de751f" ("mp3" "mp4" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
  (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
  (dired-rainbow-define log "#c17d11" ("log"))
  (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
  (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
  (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
  (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
  (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
  (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
  (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
  (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
  (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
  (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
  (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

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
;; 只在系统安装了 fcitx5 时加载
(when (executable-find "fcitx5")
  (add-to-list 'load-path "~/open-source/fcitx.el")
  (setq fcitx-remote-command "fcitx5-remote")
  (use-package fcitx
    :config
    (setq fcitx-use-dbus 'fcitx5)
    (fcitx-prefix-keys-add "C-x" "C-c")
    (fcitx-prefix-keys-turn-on)
    (fcitx-evil-turn-on)
    (fcitx-aggressive-minibuffer-turn-on)
    (fcitx-isearch-turn-on)))
;;;* Magit
(use-package magit
  :commands (magit-status magit-dispatch)
  :bind (("C-x g" . magit-status)))

;;;* Julia
(use-package julia-mode
  :mode "\\.jl\\'")

;;;* rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;;* Cdlatex
(use-package cdlatex
  :commands (cdlatex-mode org-cdlatex-mode)
  :config
  (setq cdlatex-insert-auto-labels-in-env-templates nil))

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
  (let ((name (buffer-name))
	(modified-file (and (buffer-file-name)
			    (buffer-modified-p))))
    (concat "[" name "]"
            (if modified-file "[+]" ""))))

;; pwd
(defun shh/modeline-pwd ()
  "Return pretty pwd for mode-line.
Show ~ instead of ~/; other dirs unchanged."
  (let ((dir (abbreviate-file-name (expand-file-name default-directory))))
    (if (string= dir "~/")
        "~"
      (directory-file-name dir))))

;; mode name
(defun shh/modeline-mode-name ()
  (format "[%s]" (format-mode-line mode-name)))

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
   ;; 中间：[mode-name]
   (:eval (shh/modeline-mode-name))

   ;; 右侧：行,列 + 百分比（纯数字）
   (:eval
    (let ((pos (shh/modeline-right)))
      (propertize " "
		  'display
		  `((space :align-to (- right ,(string-width pos)))))))
   (:eval (shh/modeline-right))
   ))
;;;* 代码折叠
(add-hook 'prog-mode-hook #'hs-minor-mode)
(defun my/outline-setup-init-el ()
  "Outline folding for init.el only."
  (when (and (derived-mode-p 'emacs-lisp-mode)
             (buffer-file-name)
             (string= (file-name-nondirectory (buffer-file-name)) "init.el"))
    (setq-local outline-regexp ";;;\\*+ ")
    (outline-minor-mode 1)
    (outline-hide-body)))
(add-hook 'find-file-hook #'my/outline-setup-init-el)
