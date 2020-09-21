(defun f-test ()
  (let ((elisp-shorthands '(("^foo-" . "bar-"))))
    (with-temp-buffer
      (insert "(foo-bar)")
      (goto-char (point-min))
      (read (current-buffer)))))

(defun f-test2 ()
  (let ((elisp-shorthands '(("^foo-" . "bar-"))))
    (read-from-string "(foo-bar)")))


(defun f-test3 ()
  (let ((elisp-shorthands '(("^foo-" . "bar-"))))
    (intern "foo-bar")))

(when nil
  (f-test3)
  (f-test2)
  (f-test))


;; Local Variables:
;; elisp-shorthands: (("^f-" . "elisp--foo-"))
;; End: