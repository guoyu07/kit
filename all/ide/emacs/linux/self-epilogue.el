;;;;
;; sample-self-epilogue.el: specify the epilogue of yourself
;;   define self-epilogue, it will be run the last end
;;
;;;;



(message "#self epilogue ...")


(safe-fn-when org-agenda
  (global-set-key (kbd "C-c a") 'org-agenda))
(safe-fn-when org-capture
  (global-set-key (kbd "C-c c") 'org-capture))


(version-supported-when
    <= 25.2
  (setq source-directory "/opt/open/emacs-25/"))


(comment
 (require 'rmail)
 (setq rmail-primary-inbox-list
       '("pop://majunjie:Hell0620/@mail.xwtec.cn"))
 (setq rmail-remote-password-required t))

(comment
 (require 'sendmail)
 (setq send-mail-function 'smtpmail-send-it)
 (setq smtpmail-smtp-server "<smtp-server>")
 (setq smtpmail-smtp-server 587))
