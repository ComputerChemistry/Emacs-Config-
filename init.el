;(require 'org)
;;(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

;;:org-babel-load-file
;; (expand-file-name
;;  "config.org"
;;  user-emacs-directory)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right
)
(add-to-list 'load-path "~/.config/emacs/org-mode/lisp") ; Ajusta la ruta de acceso según sea necesario
;;(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))
(require 'org-compat)
(load "org-compat")
(load "org-macs")

;;Temporary-Files

(setq auto-save-default nil)

;;(custom-set-faces
 ;; custom-set-faces se agregó automáticamente por Custom.
 ;; Si lo editas manualmente, podrías estropearlo, así que ten cuidado.
 ;; Tu archivo init debería contener solo una instancia de esta forma.
 ;; Si hay más de una, no funcionarán correctamente.
 ;;

;;.......................................................

;;
(require 'server)
(unless (server-running-p)
  (server-start))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
 ;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;;(package-initialize)

;;...........................................................

(setq package-archive-priorities
      '(("melpa" .  4)
        ("melpa-stable" . 3)
        ("org" . 2)
        ("gnu" . 1)))

;;; Generic packages
(require 'package)
;; Select the folder to store packages
;; Comment / Uncomment to use desired sites
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory)
      package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/"))
      package-quickstart nil)
;; ("cselpa" . "https://elpa.thecybershadow.net/packages/")
;; ("melpa-cn" . "http://mirrors.cloud.tencent.com/elpa/melpa/")
;; ("gnu-cn"   . "http://mirrors.cloud.tencent.com/elpa/gnu/"))

;; Configure Package Manager
(unless (bound-and-true-p package--initialized)
  (setq package-enable-at-startup nil) ; To prevent initializing twice
  (package-initialize))

;; set use-package-verbose to t for interpreted .emacs,
;; and to nil for byte-compiled .emacs.elc.
(eval-and-compile
  (setq use-package-verbose (not (bound-and-true-p byte-compile-current-file))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

;;elpaca
(defvar elpaca-installer-version 0.8)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Activar Elpaca
;;(elpaca `(,@elpaca-order))
;;(add-hook 'after-init-hook #'elpaca-process-queues)

 ;;Configurar elpaca-use-package
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;;________________________________________________________________
;;;;    Use package 
;;________________________________________________________________

;; Install use-package if not installed
(eval-and-compile
  (unless (and (fboundp 'package-installed-p)
               (package-installed-p 'use-package))
    (package-refresh-contents) ; update archives
    (package-install 'use-package)) ; grab the newest use-package
  (if init-file-debug
      (setq use-package-compute-statistics t)
    (setq use-package-compute-statistics nil))
  (require 'use-package))

;; Configure use-package
(use-package use-package
  :custom
  (use-package-verbose t)
  (use-package-always-ensure t)  ; :ensure t by default
  (use-package-always-defer nil) ; :defer t by default
  (use-package-expand-minimally t)
  (use-package-enable-imenu-support t))

;;Config.el
;;(add-to-list 'load-path "~/.config/emacs/scripts")

;;(require 'elpaca-setup)  ;; The Elpaca Package Manager
;;(require 'buffer-move)   ;; Buffer-move for better window management
;;(require 'app-launchers) ;; Use emacs as a run launcher like dmenu (experimental)

;;________________________________________________________________
;;;;    Fancy pkg
;;________________________________________________________________
(use-package fancy-battery
  :config
  (setq fancy-battery-show-percentage t)
  (setq battery-update-interval 15)
  (if window-system
      (fancy-battery-mode)
    (display-battery-mode)))

;;;;; hl-indent
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-delay 0)
  (highlight-indent-guides-responsive t)
  (highlight-indent-guides-method 'character)
  ;; (highlight-indent-guides-auto-enabled t)
  ;; (highlight-indent-guides-character ?\┆) ;; Indent character samples: | ┆ ┊
  :commands highlight-indent-guides-mode
  :hook (prog-mode  . highlight-indent-guides-mode)
  :delight " ㄓ")


;;;;; hl-volatile
(use-package volatile-highlights
  :diminish
  :commands volatile-highlights-mode
  :hook (after-init . volatile-highlights-mode)
  :custom-face)
;;  (vhl/default-face ((nil (:foreground "#FF3333" :background "BlanchedAlmond"))))) ; "#FFCDCD"
;; (set-face-background 'highlight "#3e4446") ; also try: "#3e4446"/"#gray6"
;; (set-face-foreground 'highlight nil)
;; (set-face-underline-p 'highlight "#ff0000")

;;;;; hl-numbers
(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))

;;;;; beacon
(use-package beacon
  :commands beacon-mode
  :init (beacon-mode t)
  :bind ("C-S-l" . 'beacon-blink)
  :config
  (setq
   beacon-blink-when-window-changes t  ; only flash on window/buffer changes...
   beacon-blink-when-window-scrolls nil
   beacon-blink-when-point-moves nil
   beacon-dont-blink-commands nil
   beacon-blink-when-focused t
   beacon-blink-duration .5
   beacon-blink-delay .5
   beacon-push-mark 1
   beacon-color "#57c7ff"
   beacon-size 20)
  :delight)

;;;;; emojify
(use-package emojify
  :bind ("M-<f1>" . emojify-insert-emoji)
  :config (if (display-graphic-p)
              (setq emojify-display-style 'image)
            (setq emojify-display-style 'unicode)
            (setq emojify-emoji-styles '(unicode)))
  :init (global-emojify-mode +1))

;;;;; alert
(use-package alert
  :commands alert
  :config
  (when (eq system-type 'darwin)
    (setq alert-default-style 'notifier))
  (when (eq system-type 'gnu/linux)
    (setq alert-default-style 'notifications))
  :delight)

(use-package try
  :defer t)

;;spotify client
(use-package smudge
  :bind-keymap ("C-c ." . smudge-command-map)
  :custom
  (smudge-oauth2-client-secret "...")
  (smudge-oauth2-client-id "...")
  ;; optional: enable transient map for frequent commands
  (smudge-player-use-transient-map t)
  :config
  ;; optional: display current song in mode line
  (global-smudge-remote-mode))

;;;;; comment-dwim-2
(use-package comment-dwim-2
  :bind ("M-;" . 'comment-dwim-2)
  :delight)

;;;; custom-themes
(use-package doom-themes
  :if window-system
  :custom-face
 ;; (cursor ((t (:background "#d699b6"))))
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
 (load-theme 'doom-ayu-dark t)
  (if (display-graphic-p)``
      (progn
        ;; Enable custom neotree theme (all-the-icons must be installed!)
        (doom-themes-neotree-config)
        ;; or for treemacs users
        (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
        (doom-themes-treemacs-config)
        ))
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))
 
(custom-set-faces
 '(font-lock-comment-face ((t (:foreground "#6A9955"))))) ;; Verde similar al de VS Code

;;Load themes directory
(add-to-list 'custom-theme-load-path "~/.config/emacs/themes")
;;(load-theme 'ef-reverie t)

;;(setq catppuccin-flavor 'macchiato) ;; Opciones: 'latte, 'macchiato, 'mocha, 'frappe
;;(load-theme 'catppuccin :no-confirm)
;;(catppuccin-reload)


;; Custom Enabled Theme
;; Auto lod custom theme.
;;(setq custom-enabled-themes '(doom-one))
;;(setq custom-safe-themes '(doom-one))

;; Restablece las caras de los números de línea
;;(set-face-attribute 'line-number nil :inherit 'default :foreground nil :background nil)
;;(set-face-attribute 'line-number-current-line nil :inherit 'default :foreground nil :background nil)
	 
;; Load theme
;;(load-theme ' doom-ayu-dark t)

;;(use-package olivetti
;;  :ensure t
;;  :config
  ;; Ajustar el ancho del texto en Olivetti
;;  (setq olivetti-body-width 100) ; Establece el ancho del texto a 100

  ;; Activar Olivetti en todos los buffers, excepto en ciertos modos
 ;; (defun my-enable-olivetti ()
 ;;   "Activar olivetti-mode en todos los buffers, excepto en modos excluidos."
 ;;   (unless (derived-mode-p 'org-mode 'dired-mode 'special-mode) ; Excluir modos específicos
 ;;     (olivetti-mode 1)))

  ;; Hook global para activar Olivetti
 ;; (add-hook 'after-change-major-mode-hook #'my-enable-olivetti))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-level-6 ((t (:inherit outline-5 :height 1.2))))
 '(org-level-7 ((t (:inherit outline-5 :height 1.1))))

;;(require 'rainbow-mode)

;;(use-package rainbow-mode
;;  :ensure t)


;;;;; rainbow
;;(use-package rainbow-mode
;;  :defer t
;;  :hook ((prog-mode . rainbow-mode)
;;         (web-mode . rainbow-mode)
;;         (css-mode . rainbow-mode)))

;;(use-package rainbow-delimiters
;;  :config (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
;;  :delight)

;; solaire-mode

;;(use-package solaire-mode
;;  :hook
;;  ((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
;;  (minibuffer-setup . solaire-mode-in-minibuffer)
;;  :config
;;  (solaire-global-mode +1)
;;  (add-hook 'after-make-frame-functions
;;            (lambda (_frame)
;;              (load-theme 'doom-ayu-dark t)
;;              (solaire-mode-swap-bg))))

;;(add-to-list 'solaire-mode-themes-to-face-swap "doom-ayu-dark")

;; TRUE Transparency
;;(set-frame-parameter nil 'alpha 100) ; For current frame
;;(add-to-list 'default-frame-alist '(alpha . 100)) ; For all new frames henceforth

;;Transparency
 ;; Configuración de transparencia para nuevas ventanas
(add-to-list 'default-frame-alist '(alpha . (85 . 70)))

;; Configurar transparencia también para nuevas ventanas (si las abres después)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (set-frame-parameter frame 'alpha '(85 . 70))))

;;(defun kb/toggle-window-transparency ()
;;  "Toggle transparency."
;;  (interactive)
;;  (let ((alpha-transparency 100))
;;    (pcase (frame-parameter nil 'alpha)
;;      (100 (set-frame-parameter nil 'alpha 85)) ; Change to desired value
;;     ( _ (set-frame-parameter nil 'alpha 100)))))


;; Set transparency of emacs
;;(defun transparency (value)
;; Sets the transparency of the frame window. 0=transparent/100=opaque
;;  (interactive "Transparency Value 0 - 100 opaque:")
;;  (set-frame-parameter (selected-frame) 'alpha value))


;; TRUE Transparency
(set-frame-parameter nil 'alpha 100) ; For current frame
(add-to-list 'default-frame-alist '(alpha . 100)) ; For all new frames henceforth

(defun kb/toggle-window-transparency ()
  "Toggle transparency."
  (interactive)
  (let ((alpha-transparency 100))
    (pcase (frame-parameter nil 'alpha)
      (100 (set-frame-parameter nil 'alpha 85)) ; Change to desired value
      ( _ (set-frame-parameter nil 'alpha 100)))))


;; Set transparency of emacs
(defun transparency (value)
;; Sets the transparency of the frame window. 0=transparent/100=opaque
  (interactive "Transparency Value 0 - 100 opaque:")
  (set-frame-parameter (selected-frame) 'alpha value))

;; all-the-icons

;;(use-package all-the-icons
;;  :ensure t
;;  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

;; company

;;Centaur-Tabs

;;(use-package centaur-tabs
;; :ensure t 
;; :config 
;;   (setq centaur-tabs-set-bar 'over
;;       centaur-tabs-style "wave"
;;       centaur-tabs-set-icons t
;;       centaur-tabs-gray-out-icons 'buffer
;;       centaur-tabs-height 32
;;       centaur-tabs-set-modified-marker t
;;       centaur-tabs-modified-marker "*")
;;    (centaur-tabs-mode t))

;;(setq centaur-tabs-icon-type 'nerd-icons)  ; or 'nerd-icons

;;(use-package company
;;  :defer 2
;;  :diminish
;;  :custom
;;  (company-begin-commands '(self-insert-command))
;;  (company-idle-delay .1)
;;  (company-minimum-prefix-length 2)
;;  (company-show-numbers t)
;  (company-tooltip-align-annotations 't)
;;  (global-company-mode t))

;;(use-package company-box
;;    :after company
;;  :diminish
;;  :hook (company-mode . company-box-mode))

;;(use-package company-box
;;  :if (display-graphic-p)
;;  :hook (company-mode . company-box-mode)
;;  :config
;;  (setq company-box-doc-enable nil)
;;  (setq company-box-scrollbar nil)
;;  (setq company-box-frame-behavior 'default))

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  ;;(setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.config/emacs/images/logo.png")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
 ;; (setq dashboard-vertically-center-content t)
  (setq dashboard-display-icons-p t)     ; display icons on both GUI and terminal
  (setq dashboard-icon-type 'nerd-icons) ; use `nerd-icons' package
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
				      (bookmarks . "book")))
  :config
 (dashboard-setup-startup-hook))

 (setq dashboard-max-width 10)

 (use-package diminish)

 (use-package dired-open
   :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))
 ;;restart-emacs
 (use-package restart-emacs 
   :ensure t)

;;(use-package peep-dired
;;  :after dired
;;  :hook (evil-normalize-keymaps . peep-dired-hook)
;;  :config
;;    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
;;    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
;;    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
;;    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
;)

;; Expands to: (elpaca evil (use-package evil :demand t))
;;(use-package evil
;;    :init      ;; tweak evil's configuration before loading it
;;    (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
;;          evil-want-keybinding nil
;;          evil-vsplit-window-right t
;;          evil-split-window-below t
;;         evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
;;    (evil-mode))

;;(use-package evil-collection
;;  :after evil
;;  :config
;; Do not uncomment this unless you want to specify each and every mode
;; that evil-collection should works withThe  following line is here
;; for documentation purposes in case you need it.
;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
;;  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
;;  (evil-collection-init))

;;(use-package evil-tutor)

;; Using RETURN to follow links in Org/Evil
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
;;(with-eval-after-load 'evil-maps
;;  (define-key evil-motion-state-map (kbd "SPC") nil)
;;  (define-key evil-motion-state-map (kbd "RET") nil)
;;  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
;;  (setq org-return-follows-link  t)

;;(use-package flycheck
;;  :ensure t
;;  :defer t
;;  :diminish
;;  :init (global-flycheck-mode))

;; Configuración del tamaño y posición de la ventana
(setq initial-frame-alist
      '((top . 0)     ;; Posición desde la parte superior de la pantalla
        (left . 0)    ;; Posición desde el borde izquierdo de la pantalla
        (width . 120) ;; Ancho de la ventana en columnas
        (height . 35))) ;; Alto de la ventana en líneas

(set-face-attribute 'default nil
  :font "Iosevka"
  :height 110)
 ;; :weight 'regular)
 (set-face-attribute 'variable-pitch nil
  :font "Iosevka"
  :height 110)
 ;; :weight 'regular)
(set-face-attribute 'fixed-pitch nil
  :font "Iosevka"
  :height 110)
 ;; :weight 'regular)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
;;(add-to-list 'default-frame-alist '(font . "SauceCodePro Nerd Font-10"))
(setq-default line-spacing 0.20)

;; Márgenes en los lados
(setq-default left-margin-width 4)  ;; Márgenes laterales más cómodos
(setq-default right-margin-width 4) ;; Márgenes laterales más cómodos

(set-window-buffer nil (current-buffer))

(add-to-list 'default-frame-alist '(font . "Iosevka-11"))  ;; Fuente para emacsclient
(global-font-lock-mode 1)    

;; Set up emoji rendering
;; Default Windows emoji font
(when (member "Segoe UI Emoji" (font-family-list))
  (set-fontset-font t 'symbol (font-spec :family "Segoe UI Emoji") nil 'prepend)
  (set-fontset-font "fontset-default" '(#xFE00 . #xFE0F) "Segoe UI Emoji"))

;; Linux emoji font
(when (member "Noto Color Emoji" (font-family-list))
  (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend)
  (set-fontset-font "fontset-default" '(#xFE00 . #xFE0F) "Noto Color Emoji"))

;;Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.20)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package general
  :config
  (general-evil-setup)
  
  ;; set up 'SPC' as the global leader key
  (general-create-definer cl/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (cl/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
    "TAB TAB" '(comment-line :wk "Comment lines")
    "u" '(universal-argument :wk "Universal argument"))

  (cl/leader-keys
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b b" '(switch-to-buffer :wk "Switch to buffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-current-buffer :wk "Kill current buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

  (cl/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired"))

  (cl/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate") 
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e R" '(eww-reload :which-key "Reload current page in EWW")
    "e s" '(eshell :which-key "Eshell")
    "e w" '(eww :which-key "EWW emacs web wowser"))

  (cl/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f c" '((lambda () (interactive)
              (find-file "~/.config/emacs/config.org")) 
            :wk "Open emacs config.org")
    "f e" '((lambda () (interactive)
              (dired "~/.config/emacs/")) 
            :wk "Open user-emacs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    "f i" '((lambda () (interactive)
              (find-file "~/.config/emacs/init.el")) 
            :wk "Open emacs init.el")
    "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file"))

  (cl/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

 (cl/leader-keys
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h r" '(:ignore t :wk "Reload")
    "h r r" '((lambda () (interactive)
                (load-file "~/.config/emacs/init.el")
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (cl/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (cl/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (cl/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (cl/leader-keys
    "o" '(:ignore t :wk "Open")
    "o d" '(dashboard-open :wk "Dashboard")
    "o e" '(elfeed :wk "Elfeed RSS")
    "o f" '(make-frame :wk "Open buffer in new frame")
    "o F" '(select-frame-by-name :wk "Select frame by name"))

  ;; projectile-command-map already has a ton of bindings 
  ;; set for us, so no need to specify each individually.
  (cl/leader-keys
    "p" '(projectile-command-map :wk "Projectile"))

  (cl/leader-keys
    "s" '(:ignore t :wk "Search")
    "s d" '(dictionary-search :wk "Search dictionary")
    "s m" '(man :wk "Man pages")
    "s t" '(tldr :wk "Lookup TLDR docs for a command")
    "s w" '(woman :wk "Similar to man but doesn't require man"))

  (cl/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t e" '(eshell-toggle :wk "Toggle eshell")
    "t f" '(flycheck-mode :wk "Toggle flycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
    "t o" '(org-mode :wk "Toggle org mode")
    "t r" '(rainbow-mode :wk "Toggle rainbow mode")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (cl/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))
 )

(use-package git-timemachine
  :after git-timemachine
  :config
  (add-hook 'git-timemachine-mode-hook
            (lambda ()
              (local-set-key (kbd "C-j") 'git-timemachine-show-previous-revision)
              (local-set-key (kbd "C-k") 'git-timemachine-show-next-revision))))

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package counsel
  :after ivy
  :diminish
  :config 
    (counsel-mode)
    (setq ivy-initial-inputs-alist nil)) ;; removes starting ^ regex in M-x


 (use-package link-hint 
    :ensure t)

(use-package minions
  :config
  (setq minions-mode-line-lighter "")
  (setq minions-mode-line-delimiters '("" . ""))
  (setq-default mode-line-buffer-identification '("%b // " (:eval (projectile-project-name))))
  (minions-mode +1))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :diminish
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )


(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev))
;; :config
 ;; (ivy-set-display-transformer 'ivy-switch-buffer
  ;;                             'ivy-rich-switch-buffer-transformer))

(global-set-key [escape] 'keyboard-escape-quit)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(require 'org-tempo)

;;(use-package perspective
  ;;:custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  ;;(persp-mode-prefix-key (kbd "C-c M-p"))
  ;;:init 
  ;;(persp-mode)
  ;;:config
  ;; Sets a file to write to when we save states
  ;;(setq persp-state-default-file "~/.config/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-delimiters

  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
;;(global-display-line-numbers-mode 1) ;;Display Line Numbers
;;(global-visual-line-mode t)  ;; Enable truncated lines
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar

(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative) 

(use-package eshell-toggle
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term))

  (use-package eshell-syntax-highlighting
    :after esh-mode
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
  ;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
  ;; eshell-aliases-file -- sets an aliases file for the eshell.

  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
:config
(setq shell-file-name "/bin/sh"
      vterm-max-scrollback 5000))

(use-package vterm-toggle
  :after vterm
  :config
  ;; When running programs in Vterm and in 'normal' mode, make sure that ESC
  ;; kills the program as it would in most standard terminal programs.
 ;; (evil-define-key 'normal vterm-mode-map (kbd "<escape>") 'vterm--self-insert)
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.4))))

(use-package sudo-edit)

(use-package tldr)

(add-to-list 'default-frame-alist '(alpha-background . 100)) ; For all new frames henceforth

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))



;;________________________________________________________________
;;;;   database clients 
;;________________________________________________________________
 
;;pg client for manage postgreSQL database 
 (use-package pg 
   :ensure t )

;;pgmacs
(unless (package-installed-p 'pg)
   (package-vc-install "https://github.com/emarsden/pg-el/" nil nil 'pg))
(unless (package-installed-p 'pgmacs)
   (package-vc-install "https://github.com/emarsden/pgmacs/" nil nil 'pgmacs))

(require 'pgmacs)


;;________________________________________________________________
;;;;    programming
;;________________________________________________________________
;;;;; flycheck
;;(use-package flycheck
;;  :hook (prog-mode . flycheck-mode)
;;  :bind (("M-g M-j" . flycheck-next-error)
;;         ("M-g M-k" . flycheck-previous-error)
;;         ("M-g M-l" . flycheck-list-errors))
;;  :config
;; (setq flycheck-indication-mode 'right-fringe
;;        flycheck-check-syntax-automatically '(save mode-enabled))
;; Small BitMap-Arrow
;;  (when (fboundp 'define-fringe-bitmap)
;;   (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
;;     [16 48 112 240 112 48 16] nil nil 'center))

;;     Explanation-Mark !
;;   (when window-system
;;     (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
;;       [0 24 24 24 24 24 24 0 0 24 24 0 0 0 0 0 0]))

  ;; BIG BitMap-Arrow
  ;; (when (fboundp 'define-fringe-bitmap)
  ;;   (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
  ;;     [0 0 0 0 0 4 12 28 60 124 252 124 60 28 12 4 0 0 0 0]))

;;  :custom-face
;;  (flycheck-warning ((t (:underline (:color "#f9e2af" :style line :position line)))))
;;  (flycheck-error ((t (:underline (:color "#f38ba8" :style line :position line)))))
;;  (flycheck-info ((t (:underline (:color "#a6e3a1" :style line :position line)))))
;;  :delight " ∰") ; "Ⓢ"

;;(use-package flycheck-popup-tip
;;  :config
;;  (add-hook 'flycheck-mode-hook 'flycheck-popup-tip-mode))

;; syntax highlight of the latest C++ language.
(use-package modern-cpp-font-lock
  :delight)
(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)

;;;;; projectile
(use-package projectile
  :disabled t
  :delight '(:eval (concat " [" projectile-project-name "]"))
  :pin melpa-stable
  :custom
  (projectile-enable-caching t)
  (projectile-completion-system 'ivy)
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map))

;;;;; GDB
;; Show main source buffer when using GDB
(setq gdb-show-main t ; keep your source code buffer displayed in a split window
      gdb-many-windows t) ; GDB interface supports a number of other windows

;;;;; web
;;(use-package emmet-mode
;;  :after (web-mode css-mode scss-mode)
;;  :commands (emmet-mode emmet-expand-line yas-insert-snippet company-complete)
;;  :config (setq emmet-move-cursor-between-quotes t)
;;  (add-hook 'emmet-mode-hook (lambda () (setq emmet-indent-after-insert nil)))
;;  (add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
;;  (add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
  ;; (setq emmet-indentation 2)
;;  (unbind-key "C-M-<left>" emmet-mode-keymap)
;;  (unbind-key "C-M-<right>" emmet-mode-keymap)
;;  ((:map emmet-mode-keymap
;;         ("C-c [" . emmet-prev-edit-point)
;;         ("C-c ]" . emmet-next-edit-point)))
 ;; )

;; Programming support and utilities

;; (add-to-list 'load-path (concat user-emacs-directory "lsp-bridge/"))
;; (use-package yasnippet)
;; (require 'lsp-bridge)
;; (global-lsp-bridge-mode)
;; (define-key acm-mode-map (kbd "<tab>") #'acm-select-next)
;; (define-key acm-mode-map (kbd "TAB") #'acm-select-next)
;; (define-key acm-mode-map (kbd "<backtab>") #'acm-select-prev)

;;(use-package lsp-mode
;;  :init
;;  (setq lsp-keymap-prefix "C-c l")
;;  :hook ((c-mode          ; clangd
;;          c++-mode        ; clangd
;;          c-or-c++-mode   ; clangd
;;          java-mode       ; eclipse-jdtls
;;          js-mode         ; ts-ls (tsserver wrapper)
;;          js-jsx-mode     ; ts-ls (tsserver wrapper)
;;          typescript-mode ; ts-ls (tsserver wrapper)
;;          python-mode     ; pyright
;;          web-mode        ; ts-ls/HTML/CSS
;;          rust-mode       ; rust-analyzer
;;          go-mode         ; gopls
;;          erlang-mode     ; erlang-mode
;;          haskell-mode    ; haskell-mode 
;;          lisp-mode       ; lisp-mode
;;          asm-mode        ;asm-lsp
;;          ) . lsp-deferred)
;;  :preface
;;  (defun cl/lsp-execute-code-action ()
;;    "Execute code action with pulse-line animation."
;;    (interactive)
;;  (cl/pulse-line)
;;    (call-interactively 'lsp-execute-code-action))
;;  :custom-face
;;  (lsp-headerline-breadcrumb-symbols-face                ((t (:inherit variable-pitch))))
;;  (lsp-headerline-breadcrumb-path-face                   ((t (:inherit variable-pitch))))
;;  (lsp-headerline-breadcrumb-project-prefix-face         ((t (:inherit variable-pitch))))
;;  (lsp-headerline-breadcrumb-unknown-project-prefix-face ((t (:inherit variable-pitch))))
;;  :commands lsp
;;  :config
;;  (add-hook 'java-mode-hook #'(lambda () (when (eq major-mode 'java-mode) (lsp-deferred))))
;;  (global-unset-key (kbd "<f2>"))
;;  (define-key lsp-mode-map (kbd "<f2>") #'lsp-rename)
;;  (setq lsp-auto-guess-root t)
;;  (setq lsp-log-io nil)
;;  (setq lsp-restart 'auto-restart)
;;  (setq lsp-enable-links nil)
;;  (setq lsp-enable-symbol-highlighting nil)
;;  (setq lsp-enable-on-type-formatting nil)
;;  (setq lsp-lens-enable nil)
;;  (setq lsp-signature-auto-activate nil)
;;  (setq lsp-signature-render-documentation nil)
;;  (setq lsp-eldoc-enable-hover nil)
;;  (setq lsp-eldoc-hook nil)
;;  (setq lsp-modeline-code-actions-enable nil)
;;  (setq lsp-modeline-diagnostics-enable nil)
;;  (setq lsp-headerline-breadcrumb-enable nil)
;;  (setq lsp-headerline-breadcrumb-icons-enable nil)
;;  (setq lsp-semantic-tokens-enable nil)
;;  (setq lsp-enable-folding nil)
;;  (setq lsp-enable-imenu nil)
;;  (setq lsp-enable-snippet nil)
;;  (setq lsp-enable-file-watchers nil)
;;  (setq lsp-keep-workspace-alive nil)
;;  (setq read-process-output-max (* 1024 1024)) ;; 1MB
;;  (setq lsp-idle-delay 0.25)
;;  (setq lsp-auto-execute-action nil)
;; (with-eval-after-load 'lsp-clangd
;;  (setq lsp-clients-clangd-args '("--header-insertion=never" "-j=4" "-background-index")))
;;  (add-to-list 'lsp-language-id-configuration '(js-jsx-mode . "javascriptreact")))

;;(use-package lsp-ui
;;  :commands lsp-ui-mode
;;  :custom-face
;;  (lsp-ui-sideline-global ((t (:italic t))))
;;  (lsp-ui-peek-highlight  ((t (:foreground unspecified :background unspecified :inherit isearch))))
;;  :config
;;  (with-eval-after-load 'evil
;;   (add-hook 'buffer-list-update-hook
;;              #'(lambda ()
;;                  (when (bound-and-true-p lsp-ui-mode)
;;                    (evil-define-key '(motion normal) 'local (kbd "K")
;;                      #'(lambda () (interactive) (lsp-ui-doc-glance) (cl/pulse-line)))))))
;; (setq lsp-ui-doc-enable nil)
;;  (setq lsp-ui-doc-show-with-mouse nil)
;;  (setq lsp-ui-doc-enhanced-markdown nil)
;;  (setq lsp-ui-doc-delay 0.01)
;;  (when (display-graphic-p)
;;    (setq lsp-ui-doc-use-childframe t)
;;    (setq lsp-ui-doc-text-scale-level -1.0)
;;    (setq lsp-ui-doc-max-width 80)
;;    (setq lsp-ui-doc-max-height 25)
;;    (setq lsp-ui-doc-position 'at-point))
;;  (setq lsp-ui-doc-include-signature t)
;;  (setq lsp-ui-doc-border (face-foreground 'font-lock-comment-face))
;;  (setq lsp-ui-sideline-diagnostic-max-line-length 80)
;;  (setq lsp-ui-sideline-diagnostic-max-lines 2)
;;  (setq lsp-ui-peek-always-show t)
;;  (setq lsp-ui-sideline-delay 0.05))

;;Paredit

;(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
;(add-hook 'lisp-mode-hook 'enable-paredit-mode)


;;(use-package lsp-java
;;  :after lsp)

;;(use-package lsp-haskell
;;  :after lsp)
  
;;(use-package java
;;  :ensure nil
;;  :after lsp-java
;;  :bind (:map java-mode-map ("C-c i" . lsp-java-add-import)))

;;(use-package lsp-pyright
;;  :hook (python-mode . (lambda () (require 'lsp-pyright)))
;;  :init (when (executable-find "python3")
;;          (setq lsp-pyright-python-executable-cmd "python3")))

;;Magit 
(use-package magit
  :ensure t )

;;Racket-Mode
(use-package racket-mode 
  :ensure t)

(use-package tree-sitter
  :after tree-sitter-langs
  :custom-face
  (tree-sitter-hl-face:property         ((t (:slant normal))))
  (tree-sitter-hl-face:method.call      ((t (:inherit font-lock-function-name-face))))
  (tree-sitter-hl-face:function.call    ((t (:inherit font-lock-function-name-face))))
  (tree-sitter-hl-face:function.builtin ((t (:inherit font-lock-function-name-face))))
  (tree-sitter-hl-face:operator         ((t (:inherit default))))
  (tree-sitter-hl-face:type.builtin     ((t (:inherit font-lock-type-face))))
  (tree-sitter-hl-face:number           ((t (:inherit highlight-numbers-number))))
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs)

(use-package pyvenv
  :config
  (setq pyvenv-mode-line-indicator '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] ")))
  (add-hook 'pyvenv-post-activate-hooks
            #'(lambda ()
                (call-interactively #'lsp-workspace-restart)))
  (pyvenv-mode +1))

(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-idle-delay 0.0)
  (setq company-tooltip-minimum-width 60)
  (setq company-tooltip-maximum-width 60)
  (setq company-tooltip-limit 7)
  (setq company-minimum-prefix-length 1)
  (setq company-tooltip-align-annotations t)
  (setq company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
                            company-echo-metadata-frontend))
  (unless (display-graphic-p)
    (define-key company-active-map (kbd "C-h") #'backward-kill-word)
    (define-key company-active-map (kbd "C-w") #'backward-kill-word))
  (define-key company-active-map (kbd "C-j") nil) ; avoid conflict with emmet-mode
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (if (display-graphic-p)
      (define-key company-active-map (kbd "<tab>") 'company-select-next)
    (define-key company-active-map (kbd "TAB") 'company-select-next))
  (define-key company-active-map (kbd "<backtab>") 'company-select-previous))

(use-package company-box
  :if (display-graphic-p)
  :hook (company-mode . company-box-mode)
  :config
  (setq company-box-doc-enable nil)
  (setq company-box-scrollbar nil)
  (setq company-box-frame-behavior 'default))

;;(use-package flycheck
;;  :hook ((prog-mode . flycheck-mode)
;;         (markdown-mode . flycheck-mode)
;;         (org-mode . flycheck-mode))
;;  :custom-face
;;  (flycheck-error   ((t (:inherit error :underline t))))
;;  (flycheck-warning ((t (:inherit warning :underline t))))
;;  :config
;;  (setq flycheck-check-syntax-automatically '(save mode-enabled))
;;  (setq flycheck-display-errors-delay 0.1)
;;  (setq-default flycheck-disabled-checkers '(python-pylint))
;;  (setq flycheck-flake8rc "~/.config/flake8")
;;  (setq flycheck-checker-error-threshold 1000)
;;  (setq flycheck-indication-mode nil)
;;  (define-key flycheck-mode-map (kbd "<f8>") #'flycheck-next-error)
;;  (define-key flycheck-mode-map (kbd "S-<f8>") #'flycheck-previous-error)
;; (flycheck-define-checker proselint
;;    "A linter for prose. Install the executable with `pip3 install proselint'."
;;    :command ("proselint" source-inplace)
;;    :error-patterns
;;    ((warning line-start (file-name) ":" line ":" column ": "
;;              (id (one-or-more (not (any " "))))
;;              (message) line-end))
;;    :modes (markdown-mode org-mode))
;;  (add-to-list 'flycheck-checkers 'proselint))

(use-package markdown-mode
  :hook (markdown-mode . auto-fill-mode)
  :custom-face
  (markdown-code-face ((t (:background unspecified :inherit lsp-ui-doc-background)))))

(use-package typescript-mode
  :mode ("\\.tsx?\\'" . typescript-mode))

  ;;:config
  ;;(setq typescript-indent-level cl/indent-width))

(use-package rust-mode)

;;(use-package flycheck-rust
;;  :config
;;  (with-eval-after-load 'rust-mode
;;    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))

(use-package go-mode)
  ;;:config
  ;;(with-eval-after-load 'evil
  ;;  (evil-define-key '(motion normal) go-mode-map (kbd "gd") #'xref-find-definitions)
    ;; (evil-define-key '(motion normal) go-mode-map (kbd "gd") #'lsp-bridge-find-def)
  ;;  (evil-define-key '(motion normal) go-mode-map (kbd "K") #'(lambda () (interactive) (lsp-ui-doc-glance) (cl/pulse-line)))))

(use-package slime
 :ensure t)

(use-package erlang
  :ensure t)

(use-package lua-mode)

(use-package json-mode)

(use-package vimrc-mode)

(use-package cmake-font-lock)

(use-package yaml-mode)

(use-package haskell-mode)

(use-package rjsx-mode
  :mode ("\\.jsx?\\'" . rjsx-mode)
  :custom-face
  (js2-error   ((t (:inherit default :underscore nil))))
  (js2-warning ((t (:inherit default :underscore nil))))
  :config
  (define-key rjsx-mode-map "<" nil)
  (define-key rjsx-mode-map (kbd "C-d") nil)
  (define-key rjsx-mode-map ">" nil))

;; (use-package web-mode
;;   :mode (("\\.html?\\'" . web-mode)
;;          ("\\.css\\'"   . web-mode)
;;          ("\\.jsx?\\'"  . web-mode)
;;          ("\\.tsx?\\'"  . web-mode)
;;          ("\\.json\\'"  . web-mode))
;;   :config
;;   (setq web-mode-markup-indent-offset cl/indent-width)
;;   (setq web-mode-code-indent-offset cl/indent-width)
;;   (setq web-mode-css-indent-offset cl/indent-width)
;;   (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'"))))

(use-package emmet-mode
  :hook ((html-mode
          css-mode
          js-mode
          js-jsx-mode
          typescript-mode
          web-mode
          ) . emmet-mode)
  :config
  (setq emmet-insert-flash-time 0.001) ; effectively disabling it
  (add-hook 'js-jsx-mode-hook #'(lambda ()
                                  (setq-local emmet-expand-jsx-className? t)))
  (add-hook 'web-mode-hook #'(lambda ()
                               (setq-local emmet-expand-jsx-className? t))))

(use-package cpp-auto-include 
  :bind (:map c++-mode-map ("C-c i" . cpp-auto-include/ensure-includes-for-file)))

(add-to-list 'auto-mode-alist '("\\.tpp\\'" . c++-mode))

(use-package format-all
  :preface
  (defun cl/format-code ()
    "Auto-format whole buffer."
    (interactive)
    (let ((windowstart (window-start)))
      (if (derived-mode-p 'prolog-mode)
          (prolog-indent-buffer)
        (format-all-buffer))
      (set-window-start (selected-window) windowstart)))
  (defalias 'format-document #'cl/format-code)
  :config
  (global-set-key (kbd "<f6>") #'cl/format-code)
  (global-set-key (kbd "C-M-l") #'cl/format-code)
  (add-hook 'prog-mode-hook #'format-all-ensure-formatter)
  (add-hook 'python-mode-hook #'(lambda ()
                                  (setq-local format-all-formatters '(("Python" yapf)))))
  (add-hook 'sql-mode-hook #'(lambda ()
                               (setq-local format-all-formatters '(("SQL" pgformatter))))))


;;C/C++ Config
;;(require 'package)
;;(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;;(package-initialize)

;;(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp
;;    projectile hydra flycheck company avy which-key helm-xref dap-mode))

;;(when (cl-find-if-not #'package-installed-p package-selected-packages)
;;  (package-refresh-contents)
;;  (mapc #'package-install package-selected-packages))

;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
;;(helm-mode)
;;(require 'helm-xref)
;;(define-key global-map [remap find-file] #'helm-find-files)
;;(define-key global-map [remap execute-extended-command] #'helm-M-x)
;;(define-key global-map [remap switch-to-buffer] #'helm-mini)

;;(which-key-mode)
;;(add-hook 'c-mode-hook 'lsp)
;;(add-hook 'c++-mode-hook 'lsp)
;;(add-hool 'java-mode 'lsp)
;;(setq gc-cons-threshold (* 100 1024 1024)
;;      read-process-output-max (* 1024 1024)
;;      treemacs-space-between-root-nodes nil
;;      company-idle-delay 0.0
;;      company-minimum-prefix-length 1
;;      lsp-idle-delay 0.1)  ;; clangd is fast

;;(with-eval-after-load 'lsp-mode
;;  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
;;  (require 'dap-cpptools)
;;  (yas-global-mode))



;;(use-package all-the-icons
;;  :if (display-graphic-p)
;;  :ensure t)

;; Instala las fuentes necesarias para all-the-icons
(use-package all-the-icons
  :config
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))
(put 'downcase-region 'disabled nil)

;;nov-mode

(use-package nov
    :init
    (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;;(use-package nov-xwidget
;;  :demand t
;;  :after nov
;;  :config
;;  (define-key nov-mode-map (kbd "o") 'nov-xwidget-view)
;;  (add-hook 'nov-mode-hook 'nov-xwidget-inject-all-files))

;;;; eww
(setq browse-url-browser-function 'eww-browse-url
      shr-use-colors nil
      shr-bullet "• "
      shr-folding-mode t
      eww-search-prefix "https://duckduckgo.com/html?q="
      url-privacy-level '(email agent cookies lastloc))

;;Org-Settings (LaTex)

;;(use-package org
;;  :hook ((org-mode . visual-line-mode)
;;         (org-mode . auto-fill-mode)
;;         (org-mode . org-indent-mode)
;;         (org-mode . (lambda ()
;;                       (setq-local evil-auto-indent nil)
;;                       (setq-local olivetti-body-width (+ fill-column 5)))))
;;:config
;;  (require 'org-tempo)
;;  (setq org-link-descriptive nil)
;;  (setq org-startup-folded nil)
;;  (setq org-todo-keywords '((sequence "TODO" "DOING" "DONE")))
;;  (add-to-list 'org-file-apps '("\\.pdf\\'" . emacs))
;;  (setq org-html-checkbox-type 'html))

;;(use-package org-bullets
;;  :hook (org-mode . org-bullets-mode))

;;(use-package ox
;;  :ensure nil
;;  :config
;;  (setq org-export-with-smart-quotes t))

;;(use-package ox-latex
;;  :ensure nil
;;  :config
;;  (define-key org-mode-map (kbd "<f9>") #'org-latex-export-to-pdf)
;;  (setq org-latex-packages-alist '(("margin=1in" "geometry" nil)
;;                                   ;; ("bitstream-charter" "mathdesign" nil)
;;                                   ;; ("default, light" "roboto" nil)
;;                                   "\\hypersetup{colorlinks=true,linkcolor=blue,urlcolor=blue}"
;;                                   ("scale=0.9" "inconsolata" nil)))
;;(setq org-latex-pdf-process
;;        '("/usr/bin/pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;          "/usr/bin/pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;          "/usr/bin/pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f")))

;;(put 'upcase-region 'disabled nil)
