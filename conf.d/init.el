;; emacs
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-display-line-numbers-mode t)
(global-auto-revert-mode t)
(setq auto-revert-interval 5)

;; packages
(setq package-archives '(("gnu"   . "http://mirror.nju.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirror.nju.edu.cn/elpa/melpa/")))
(package-initialize) ;; You might already have this line
(defvar my-packages '(magit
		      org-ref
		      julia-mode
		      helm-bibtex
		      cdlatex
		      auctex
                      rainbow-delimiters))

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
(setq org-defaul-notes-file "~/notes/quicknote.org")
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
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

;; org-ref
(setq bibtex-completion-bibliography '("~/notes/ref.bib")
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
      '((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	(inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	(incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	(inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	(t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}")))
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
(setq org-latex-packages-alist
      '(
	("zihao=-4,heading=true,punct=plain" "ctex")
	("bookmarks=true" "hyperref")
	("" "amssymb")
	("" "amsmath")
	("" "xcolor")
	("" "graphicx")
	("" "bm")
	("left=1in,right=1in,top=1in,bottom=1in" "geometry")
	("" "fancyhdr")
	"\\pagestyle{fancy}"
	"\\fancyhead[R]{}"
	"\\fancyfoot[L]{孙昊航}"
	"\\fancyfoot[C]{}"
	"\\fancyfoot[R]{\\thepage}"
	"\\renewcommand{\\headrulewidth}{0pt}"
	"\\renewcommand{\\footrulewidth}{0.4pt}"
	("" "tikz")
	("" "pgfplotstable")
	"\\pgfplotsset{compat=1.16}"
	)
      )
(setq org-latex-hyperref-template nil)
(setq org-latex-compiler "xelatex")

;; og-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (julia . t)
   (emacs-lisp . t)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files '("~/notes/reading.org")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
