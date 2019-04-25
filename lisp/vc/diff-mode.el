  :type 'boolean
  :group 'diff-mode)
  :type 'boolean
  :group 'diff-mode)
  :type 'boolean
  :group 'diff-mode)
  :type 'boolean
  :group 'diff-mode)
  :options '(diff-delete-empty-files diff-make-unified)
  :group 'diff-mode)
  :type '(choice (string "\e") (string "C-c=") string)
  :group 'diff-mode)
  "Toggle automatic diff hunk highlighting (Diff Auto Refine mode).
With a prefix argument ARG, enable Diff Auto Refine mode if ARG
is positive, and disable it otherwise.  If called from Lisp,
enable the mode if ARG is omitted or nil.
  :group 'diff-mode :init-value t :lighter nil ;; " Auto-Refine"
  (when diff-auto-refine-mode
    (condition-case-unless-debug nil (diff-refine-hunk) (error nil))))
     :background "grey80")
  "`diff-mode' face inherited by hunk and index header faces."
  :group 'diff-mode)
     :background "grey70" :weight bold)
  "`diff-mode' face used to highlight file header lines."
  :group 'diff-mode)
  "`diff-mode' face used to highlight index header lines."
  :group 'diff-mode)
  "`diff-mode' face used to highlight hunk header lines."
  :group 'diff-mode)
     :background "#ffdddd")
  "`diff-mode' face used to highlight removed lines."
  :group 'diff-mode)
     :background "#ddffdd")
  "`diff-mode' face used to highlight added lines."
  :group 'diff-mode)
  :version "25.1"
  :group 'diff-mode)
  '((t :inherit diff-removed))
  :group 'diff-mode
  '((t :inherit diff-added))
  :group 'diff-mode
  '((t :inherit diff-changed))
  :group 'diff-mode
  "`diff-mode' face used to highlight function names produced by \"diff -p\"."
  :group 'diff-mode)
  '((((class color grayscale) (min-colors 88) (background light))
     :foreground "#333333")
    (((class color grayscale) (min-colors 88) (background dark))
     :foreground "#dddddd"))
  :version "25.1"
  :group 'diff-mode)
  "`diff-mode' face used to highlight nonexistent files in recursive diffs."
  :group 'diff-mode)
    ("^[^-=+*!<>#].*\n" (0 'diff-context))))
                        (`unified
                        (`context "^[^-+#! \\]")
                        (`normal "^[^<>#\\]")
 (when diff-auto-refine-mode
         (cl-do* ((files fs (delq nil (mapcar 'diff-filename-drop-dir files)))
		  (if (not (save-excursion (re-search-forward "^+" nil t)))
   \\{diff-mode-map}"
  (add-hook 'font-lock-mode-hook
            (lambda () (remove-overlays nil nil 'diff-mode 'fine))
            nil 'local)
  (set (make-local-variable 'next-error-function) 'diff-next-error)
       'diff-beginning-of-file-and-junk)
       'diff-end-of-file)
      (add-hook 'write-contents-functions 'diff-write-contents-hooks nil t)
    (add-hook 'after-change-functions 'diff-after-change-function nil t)
    (add-hook 'post-command-hook 'diff-post-command-hook nil t))
       'diff-current-defun)
  (unless (buffer-file-name)
With a prefix argument ARG, enable Diff minor mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil.
      (add-hook 'write-contents-functions 'diff-write-contents-hooks nil t)
    (add-hook 'after-change-functions 'diff-after-change-function nil t)
    (add-hook 'post-command-hook 'diff-post-command-hook nil t)))
	     (eq 0 (nth 7 (file-attributes buffer-file-name))))
  (add-hook 'after-save-hook 'diff-delete-if-empty nil t))
	  (let ((kill-char (if destp ?- ?+)))
	      (if (eq (char-after) kill-char)
		     (mapconcat 'regexp-quote (split-string text) "[ \t\n]+")
	   (buf (find-file-noselect file)))
then `diff-jump-to-old-file' is also set, for the next invocations."
  (let ((rev (not (save-excursion (beginning-of-line) (looking-at "[-<]")))))
                 (diff-find-source-location other-file rev)))
      (diff-hunk-status-msg line-offset (diff-xor rev switched) t))))
  "Face used for char-based changes shown by `diff-refine-hunk'."
  :group 'diff-mode)
     :background "#ffbbbb")
  :group 'diff-mode
     :background "#aaffaa")
  :group 'diff-mode
  (require 'smerge-mode)
      (diff-beginning-of-hunk t)
      (let* ((start (point))
             (style (diff-hunk-style))    ;Skips the hunk header as well.
             (beg (point))
             (props-c '((diff-mode . fine) (face diff-refine-changed)))
             (props-r '((diff-mode . fine) (face diff-refine-removed)))
             (props-a '((diff-mode . fine) (face diff-refine-added)))
             ;; Be careful to go back to `start' so diff-end-of-hunk gets
             ;; to read the hunk header's line info.
             (end (progn (goto-char start) (diff-end-of-hunk) (point))))

        (remove-overlays beg end 'diff-mode 'fine)
        (pcase style
          (`unified
           (while (re-search-forward "^-" end t)
             (let ((beg-del (progn (beginning-of-line) (point)))
                   beg-add end-add)
               (when (and (diff--forward-while-leading-char ?- end)
                          ;; Allow for "\ No newline at end of file".
                          (progn (diff--forward-while-leading-char ?\\ end)
                                 (setq beg-add (point)))
                          (diff--forward-while-leading-char ?+ end)
                          (progn (diff--forward-while-leading-char ?\\ end)
                                 (setq end-add (point))))
                 (smerge-refine-regions beg-del beg-add beg-add end-add
                                      nil 'diff-refine-preproc props-r props-a)))))
          (`context
           (let* ((middle (save-excursion (re-search-forward "^---")))
                  (other middle))
             (while (re-search-forward "^\\(?:!.*\n\\)+" middle t)
               (smerge-refine-regions (match-beginning 0) (match-end 0)
                                    (save-excursion
                                      (goto-char other)
                                      (re-search-forward "^\\(?:!.*\n\\)+" end)
                                      (setq other (match-end 0))
                                      (match-beginning 0))
                                    other
                                    (if diff-use-changed-face props-c)
                                    'diff-refine-preproc
                                    (unless diff-use-changed-face props-r)
                                    (unless diff-use-changed-face props-a)))))
          (_ ;; Normal diffs.
           (let ((beg1 (1+ (point))))
             (when (re-search-forward "^---.*\n" end t)
               ;; It's a combined add&remove, so there's something to do.
               (smerge-refine-regions beg1 (match-beginning 0)
                                    (match-end 0) end
                                    nil 'diff-refine-preproc props-r props-a)))))))))
                  (concat "\n[!+-<>]"