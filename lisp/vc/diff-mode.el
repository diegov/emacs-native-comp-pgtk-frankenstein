;; Copyright (C) 1998-2019 Free Software Foundation, Inc.
(defcustom diff-refine 'font-lock
  "If non-nil, enable hunk refinement.

The value `font-lock' means to refine during font-lock.
The value `navigation' means to refine each hunk as you visit it
with `diff-hunk-next' or `diff-hunk-prev'.

You can always manually refine a hunk with `diff-refine-hunk'."
  :type '(choice (const :tag "Don't refine hunks" nil)
                 (const :tag "Refine hunks during font-lock" font-lock)
                 (const :tag "Refine hunks during navigation" navigation)))
Syntax highlighting is added over diff-mode's own highlighted changes.
If `hunk-only' fontification is based on hunk alone, without full source.
in wrong fontification.  This is the fastest option, but less reliable.

If `hunk-also', use reliable file-based syntax highlighting when available
and hunk-based syntax highlighting otherwise as a fallback."
                 (const :tag "Highlight syntax" t)
                 (const :tag "Allow hunk-based fallback" hunk-also)))
(defvar-local diff-default-directory nil
  :group 'diff-mode :init-value nil :lighter nil ;; " Auto-Refine"
  (if diff-auto-refine-mode
      (progn
        (customize-set-variable 'diff-refine 'navigation)
        (condition-case-unless-debug nil (diff-refine-hunk) (error nil)))
    (customize-set-variable 'diff-refine nil)))
(make-obsolete 'diff-auto-refine-mode "set `diff-refine' instead." "27.1")
(make-obsolete-variable 'diff-auto-refine-mode
                        "set `diff-refine' instead." "27.1")
     :background "grey85")
     :background "grey75" :weight bold)
     :background "#ffeeee")
     :background "#eeffee")
    ("^\\(?:new\\|deleted\\) file mode .*\n" . 'diff-header)
                        ('context (if diff-valid-unified-empty-line
                                      "^[^-+#! \n\\]" "^[^-+#! \\]"))
 (when (and (eq diff-refine 'navigation) (called-interactively-p 'interactive))
		  (if (not (save-excursion (re-search-forward "^\\+" nil t)))
  (unless buffer-file-name
     :background "#ffcccc")
     :background "#bbffbb")
       (let* ((middle (save-excursion (re-search-forward "^---" end)))
(defun diff--iterate-hunks (max fun)
  "Iterate over all hunks between point and MAX.
Call FUN with two args (BEG and END) for each hunk."
  (save-excursion
    (let* ((beg (or (ignore-errors (diff-beginning-of-hunk))
                    (ignore-errors (diff-hunk-next) (point))
                    max)))
      (while (< beg max)
        (goto-char beg)
        (cl-assert (looking-at diff-hunk-header-re))
        (let ((end
               (save-excursion (diff-end-of-hunk) (point))))
          (cl-assert (< beg end))
          (funcall fun beg end)
          (goto-char end)
          (setq beg (if (looking-at diff-hunk-header-re)
                        end
                      (or (ignore-errors (diff-hunk-next) (point))
                          max))))))))

  (when (eq diff-refine 'font-lock)
    (diff--iterate-hunks
     max
     (lambda (beg end)
       (unless (get-char-property beg 'diff--font-lock-refined)
         (diff--refine-hunk beg end)
         (let ((ol (make-overlay beg end)))
           (overlay-put ol 'diff--font-lock-refined t)
           (overlay-put ol 'diff-mode 'fine)
           (overlay-put ol 'evaporate t)
           (overlay-put ol 'modification-hooks
                        '(diff--overlay-auto-delete))))))))

(defun diff--overlay-auto-delete (ol _after _beg _end &optional _len)
		  (concat "\n[!+<>-]"
    (diff--iterate-hunks
     max
     (lambda (beg end)
       (unless (get-char-property beg 'diff--font-lock-syntax)
         (diff-syntax-fontify beg end)
         (let ((ol (make-overlay beg end)))
           (overlay-put ol 'diff--font-lock-syntax t)
           (overlay-put ol 'diff-mode 'syntax)
           (overlay-put ol 'evaporate t)
           (overlay-put ol 'modification-hooks
                        '(diff--overlay-auto-delete))))))))
  (remove-overlays beg end 'diff-mode 'syntax)
(defvar-local diff--syntax-file-attributes nil)
(put 'diff--syntax-file-attributes 'permanent-local t)

         ;; Trim a trailing newline to find hunk in diff-syntax-fontify-props
         ;; in diffs that have no newline at end of diff file.
         (text (string-trim-right
                (or (with-demoted-errors (diff-hunk-text hunk (not old) nil))
                    "")))
         (props
          (or
           (when (and diff-vc-backend
                      (not (eq diff-font-lock-syntax 'hunk-only)))
             (let* ((file (diff-find-file-name old t))
                    (revision (and file (if (not old) (nth 1 diff-vc-revisions)
                                          (or (nth 0 diff-vc-revisions)
                                              (vc-working-revision file))))))
               (when file
                 (if (not revision)
                     ;; Get properties from the current working revision
                     (when (and (not old) (file-readable-p file)
                                (file-regular-p file))
                       (let ((buf (get-file-buffer (expand-file-name file))))
                         ;; Try to reuse an existing buffer
                         (if buf
                             (with-current-buffer buf
                               (diff-syntax-fontify-props nil text line-nb))
                           ;; Get properties from the file.
                           (with-current-buffer (get-buffer-create
                                                 " *diff-syntax-file*")
                             (let ((attrs (file-attributes file)))
                               (if (equal diff--syntax-file-attributes attrs)
                                   ;; Same file as last-time, unmodified.
                                   ;; Reuse buffer as-is.
                                   (setq file nil)
                                 (insert-file-contents file)
                                 (setq diff--syntax-file-attributes attrs)))
                             (diff-syntax-fontify-props file text line-nb)))))
                   ;; Get properties from a cached revision
                   (let* ((buffer-name (format " *diff-syntax:%s.~%s~*"
                                               (expand-file-name file)
                                               revision))
                          (buffer (get-buffer buffer-name)))
                     (if buffer
                         ;; Don't re-initialize the buffer (which would throw
                         ;; away the previous fontification work).
                         (setq file nil)
                       (setq buffer (ignore-errors
                     (when buffer
                       (with-current-buffer buffer
                         (diff-syntax-fontify-props file text line-nb))))))))
           (let ((file (car (diff-hunk-file-names old))))
             (cond
              ((and file diff-default-directory
                    (not (eq diff-font-lock-syntax 'hunk-only))
                    (not diff-vc-backend)
                    (file-readable-p file) (file-regular-p file))
               ;; Try to get full text from the file.
               (with-temp-buffer
                 (insert-file-contents file)
                 (diff-syntax-fontify-props file text line-nb)))
              ;; Otherwise, get properties from the hunk alone
              ((memq diff-font-lock-syntax '(hunk-also hunk-only))
               (with-temp-buffer
                 (insert text)
                 (diff-syntax-fontify-props file text line-nb t))))))))
        ;; Skip the "\ No newline at end of file" lines as well as the lines
        ;; corresponding to the "other" version.
        (unless (looking-at-p (if old "[+>\\]" "[-<\\]"))
          (if (and old (not (looking-at-p "[-<]")))
              ;; Fontify context lines only from new source,
              ;; don't refontify context lines from old source.
              (pop props)
            (let ((line-props (pop props))
                  (bol (1+ (point))))
              (dolist (prop line-props)
                ;; Ideally, we'd want to use text-properties as in:
                ;;
                ;;     (add-face-text-property
                ;;      (+ bol (nth 0 prop)) (+ bol (nth 1 prop))
                ;;      (nth 2 prop) 'append)
                ;;
                ;; rather than overlays here, but they'd get removed by later
                ;; font-locking.
                ;; This is because we also apply faces outside of the
                ;; beg...end chunk currently font-locked and when font-lock
                ;; later comes to handle the rest of the hunk that we already
                ;; handled we don't (want to) redo it (we work at
                ;; hunk-granularity rather than font-lock's own chunk
                ;; granularity).
                ;; I see two ways to fix this:
                ;; - don't immediately apply the props that fall outside of
                ;;   font-lock's chunk but stash them somewhere (e.g. in another
                ;;   text property) and only later when font-lock comes back
                ;;   move them to `face'.
                ;; - change the code so work at font-lock's chunk granularity
                ;;   (this seems doable without too much extra overhead,
                ;;   contrary to the refine highlighting, which inherently
                ;;   works at a different granularity).
                (let ((ol (make-overlay (+ bol (nth 0 prop))
                                        (+ bol (nth 1 prop))
                                        nil 'front-advance nil)))
                  (overlay-put ol 'diff-mode 'syntax)
                  (overlay-put ol 'evaporate t)
                  (overlay-put ol 'face (nth 2 prop)))))))))))

(defun diff-syntax-fontify-props (file text line-nb &optional hunk-only)
FILE is the name of the source file.  If non-nil, it requests initialization
of the mode according to FILE.
TEXT is the literal source text from hunk.
LINE-NB is a pair of numbers: start line number and the number of
lines in the hunk.
When HUNK-ONLY is non-nil, then don't verify the existence of the
  (when file
    ;; When initialization is requested, we should be in a brand new
    ;; temp buffer.
    (cl-assert (null buffer-file-name))
      ;; FIXME: Is this really worth the trouble?
      (when (and (fboundp 'generic-mode-find-file-hook)
                 (memq #'generic-mode-find-file-hook
                       ;; There's no point checking the buffer-local value,
                       ;; we're in a fresh new buffer.
                       (default-value 'find-file-hook)))