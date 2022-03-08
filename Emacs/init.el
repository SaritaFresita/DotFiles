(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs
					   helm-lsp projectile
					   hydra flycheck company
					   avy which-key helm-xref
					   dap-mode lsp-ui treemacs
					   magit treemacs-magit
					   treemacs-projectile emms
					   use-package dashboard abyss-theme
					   spacemacs-theme visual-fill-column org-bullets
					   all-the-icons elcord exwm org-roam org-tree-slide
					   treemacs-all-the-icons))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

;; Helm mode
(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

;; Which key
(which-key-mode)

;; lsp
(use-package lsp-mode
  :config
  (setq lsp-enable-snippet nil)

  ;; clangd
  (setq lsp-clients-clangd-args '(
                                  "--all-scopes-completion"
                                  "--background-index"
                                  "--clang-tidy"
                                  "--completion-parse=auto"
                                  "--completion-style=detailed"
                                  "--fallback-style=GNU"
                                  "--function-arg-placeholders"
                                  "--header-insertion=iwyu"
                                  "--index"
                                  "--suggest-missing-includes"
                                  "-j=2"
                                  ))
  :hook
  (
   (c-mode . lsp))
  :commands lsp)

(setq gc-cons-treshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.3)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (setq lsp-modeline-diagnostics-scope :workspace)
  (require 'dap-cpptools)
  (yas-global-mode))

(defun my-c-mode-before-save-hook ()
  (when (eq major-mode 'c-mode)
    (lsp-format-buffer)))

(add-hook 'before-save-hook #'my-c-mode-before-save-hook)

;; use-package
(require 'use-package)

;; ;; lsp-ui
(use-package lsp-ui)

(setq lsp-ui-sideline-show-diagnostics t
      lsp-ui-sideline-show-hover t
      lsp-ui-sideline-show-code-actions t
      lsp-ui-sideline-update-mode t
      lsp-ui-sideline-delay 0.5)

(setq lsp-ui-doc-enable t
      lsp-ui-doc-delay 1
      lsp-ui-doc-show-with-cursor t)

;; Magit
(require 'magit)
(global-set-key (kbd "<f9>") 'magit-status)

;; treemacs
(use-package treemacs
  :ensure t
  :defer t
  :init
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                5000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)

    (treemacs-hide-gitignored-files-mode))

  :bind
  (:map global-map
	("<f8>" . treemacs)))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

;; The 80 characters rule
(setq display-fill-column-indicator-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(set-frame-parameter (selected-frame) 'alpha '(85 . 80))
(add-to-list 'default-frame-alist '(alpha . (85 . 80)))

;; Show line and column number
(defun show-column-and-lines ()
  (setq column-number-mode t)
  (display-line-numbers-mode))

(add-hook 'prog-mode-hook #'show-column-and-lines)

;; Theme
(load-theme 'abyss t)

;; Some configurations
(tool-bar-mode -1) ;; Hide toolbar and top menu
(toggle-scroll-bar -1)
(menu-bar-mode -1)

(add-to-list 'default-frame-alist ; Hide the scrollbar
             '(vertical-scroll-bars . nil))

(blink-cursor-mode 0) ;; Disable cursor blinking

;; Change backup files
(setq make-backup-files nil)

;; all-the-icons
(when (display-graphic-p)
  (require 'all-the-icons)

  (require 'treemacs-all-the-icons)
  (treemacs-load-theme "all-the-icons"))

;; elcord
(require 'elcord)
(elcord-mode)

;; Some other configs
(setq-default tab-width 2
	          c-basic-offset 2
	          kill-whole-line t
	          indent-tabs-mode nil)

(setq mouse-autoselect-window t
      focus-follow-mouse t)

;; EXWM
(defun exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun exwm-init-hook ()
  (display-battery-mode 1)

  (setq display-time-and-date t)
  (display-time-mode 1))

(use-package exwm
  :config
  ;; Set the default number of workspaces
  (setq exwm-workspace-number 10)

  ;; When window "class" updates, use it to set the buffer name
  (add-hook 'exwm-update-class-hook #'exwm-update-class)

  ;; When EXWM starts up, do some extra configuration
  (add-hook 'exwm-init-hookj #'exwm-init-hook)

  ;; Rebind CapsLock to Ctrl
  (start-process-shell-command "xmodmap" nil "xmodmap ~/.emacs.d/exwm/Xmodmap")

  ;; Set the screen resolution (update this to be the correct resolution for your screen!)
  (require 'exwm-randr)
  (exwm-randr-enable)
  (start-process-shell-command "xrandr" nil "xrandr --output eDP1 --primary --mode 1366x768 --pos 0x0 --rotate normal")
  (start-process-shell-command "xrandr" nil "xrandr --output DP1 --mode 1600x900 --right-of eDP1")

  ;; Assign workspaces to second monitor
  (setq exwm-randr-workspace-monitor-plist '(1 "DP1" 3 "DP1" 5 "DP1" 7 "DP1" 9 "DP1"))

  ;; Load the system tray before exwm-init
  (require 'exwm-systemtray)
  (setq exwm-systemtray-height 32)
  (exwm-systemtray-enable)

  ;; Automatically send the mouse cursor to the selected workspace's display
  (setq exwm-workspace-warp-cursor t)

  ;; These keys should always pass through to Emacs
  (setq exwm-input-prefix-keys
        '(?\C-x
          ?\C-u
          ?\C-h
          ?\M-x
          ?\M-`
          ?\M-&
          ?\M-:
          ?\C-\M-j  ;; Buffer list
          ?\C-\ ))  ;; Ctrl+Space

  ;; Ctrl+Q will enable the next key to be sent directly
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Set up global key bindings.  These always work, no matter the input state!
  ;; Keep in mind that changing this list after EXWM initializes has no effect.
  (setq exwm-input-global-keys
        `(
          ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
          ([?\s-r] . exwm-reset)

          ;; Move between windows
          ([s-left] . windmove-left)
          ([s-right] . windmove-right)
          ([s-up] . windmove-up)
          ([s-down] . windmove-down)

          ;; Launch applications via shell command
          ([?\s-&] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))

          ;; Switch workspace
          ([?\s-w] . exwm-workspace-switch)
          ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

          ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))

  (exwm-input-set-key (kbd "<print>")
        (lambda ()
          (interactive)
          (start-process-shell-command "~/Repositories/DotFiles/scrot-xclip --select --freeze" nil "~/Repositories/DotFiles/scrot-xclip --select --freeze")))

  (exwm-input-set-key (kbd "<XF86AudioLowerVolume>")
                      (lambda ()
                        (interactive)
                        (start-process-shell-command "amixer -q sset Master 3%-" nil "amixer -q sset Master 3%-")))

  (exwm-input-set-key (kbd "<XF86AudioRaiseVolume>")
                      (lambda ()
                        (interactive)
                        (start-process-shell-command "amixer -q sset Master 3%+" nil "amixer -q sset Master 3%+")))

  (setq exwm-input-simulation-keys
        '(([?\C-b] . [left])
          ([?\C-f] . [right])
          ([?\C-p] . [up])
          ([?\C-n] . [down])
          ([?\C-a] . [home])
          ([?\C-e] . [end])
          ([?\M-v] . [prior])
          ([?\C-v] . [next])
          ([?\C-d] . [delete])
          ([?\C-k] . [S-end delete])))

  (exwm-enable))

;; Dashboard
(require 'dashboard)
(dashboard-setup-startup-hook)

(setq dashboard-banner-logo-title "No matter where you go, everybody's connected")
(setq dashboard-startup-banner "~/Repositories/DotFiles/Emacs/logo.png")
(setq dashboard-center-content nil)
(setq dashboard-show-shortcuts nil)

(setq dashboard-items '((projects . 5)
                        (agenta . 5)
                        (registers . 5)))

;; Org
(defun org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
  (org-display-inline-images)
  (setq org-clock-sound "~/.emacs.d/alert.wav")
  (visual-line-mode 1))

(defun org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appear that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :hook (org-mode . org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . org-mode-visual-fill))

;; Org Roam
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/RoamNotes")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup))

;; Org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
   (C . t)))

;; Org-fc
;; git clone https://github.com/l3kn/org-fc ~/.emacs.d/el/org-fc
(add-to-list 'load-path "~/.emacs.d/el/org-fc")

(require 'org-fc)
(setq org-fc-directories '("~/OrgFc"))

;; EMMS
(require 'emms)
(require 'emms-setup)
(emms-all)
(emms-default-players)
(setq emms-source-file-default-directory "~/Music")

(require 'emms-info-libtag)
(setq emms-info-functions '(emms-info-libtag))

;; org-tree-slide
(defun presentation-setup ()
  (setq text-scale-mode-amount 2.5)
  (text-scale-mode 1))

(defun presentation-end ()
  (text-scale-mode 0))

(use-package org-tree-slide
  :hook ((org-tree-slide-play . presentation-setup)
         (org-tree-slide-stop . presentation-end))
  :custom
  (org-tree-slide-slide-in-effect t)
  (org-tree-slide-activate-message "Oniichan >.< yamete kudasaii")
  (org-tree-slide-deactivate-message "uwu owo nya nya arigato")
  (org-tree-single-header t)
  (org-tree-slide-breadcrumbs " // ")
  (org-image-actual-width nil))
