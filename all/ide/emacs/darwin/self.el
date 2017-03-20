;;;;
;; self-sample.el: specified yourself private configuration elisp file
;;                 and named it with self.el
;;;;


(defmacro self-package-spec ()
  `(let ((ss (self-symbol "packages-setup")))
     (setf (symbol-value ss) 'nil)
     (append
      (when (bin-exists-p "latex")
        '(auctex))
      (when (bin-exists-p "docker")
        (version-supported-p <= 24.4
          '(dockerfile-mode
            docker-tramp)))
      (when (bin-exists-p "erlang")
        (when (bin-exists-p "lfe")
          (setf (symbol-value ss)
                (append (symbol-value ss) '("setup-lfe.el"))))
        '(erlang
          lfe-mode))
      (version-supported-p <= 25.1
        '(ereader))
      (when (bin-exists-p "git")
        (version-supported-p <= 24.4
          '(magit)))
      (when (bin-exists-p "java")
        (setf (symbol-value ss)
              (append (symbol-value ss) '("setup-clojure.el")))
        (version-supported-p <= 24.4
          '(cider
            clojure-mode
            clojure-mode-extra-font-locking
            inf-clojure)))
      (when (bin-exists-p "racket")
        (version-supported-p <= 23.2
          '(geiser)))
      (when (or (bin-exists-p "sbcl")
                (bin-exists-p "ecl"))
        (setf (symbol-value ss)
              (append (symbol-value ss) '("setup-slime.el")))
        '(slime)))))

(comment
 (platform-supported-p
     gnu/linux
   (defvar self-gnu/linux-font "White Rabbit-12"
     "default font-size for gnu/linux")
   (defvar self-gnu/linux-cjk-font (cons "Microsoft Yahei" 12)
     "default cjk font for gnu/linux")
   (DEFVAR self-gnu/linux-theme 'tomorrow-night-eighties
     "default theme for linux")))

(platform-supported-p
    darwin
  (defvar self-darwin-font "Monaco-13"
    "default font-size for darwin")
  (comment (defvar self-darwin-packages '(ecb)
             "default packages for darwin"))
  (comment (defvar self-darwin-packages '(racket-mode)
             "default packages for darwin"))

  (defvar self-darwin-prelogue
    (lambda () 
      ;; (start-socks)
      (message "#self prelogue ...")))
  (defvar self-darwin-epilogue
    (lambda ()
      (message "#self epilogue ..."))))

(comment
 (platform-supported-p
     windows-nt
   (defvar self-windows-nt-font "Consolas-13"
     "default font-size for windows nt")
   (defvar self-windows-nt-cjk-font (cons "Microsoft Yahei" 12))))
