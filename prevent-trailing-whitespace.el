;;; prevent-trailing-whitespace.el --- Editing without trailing whitespace -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Tobias Zawada

;; Author: Tobias Zawada <i@tn-home.de>
;; Keywords: wp
;; Version: 0.1
;; URL: http://www.github.com/TobiasZawada/prevent-trailing-whitespace
;; Package-Requires: ((emacs "25.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Prevent trailing whitespace in the edited parts of current buffer.
;; Trailing whitespace is prevented as long as `prevent-trailing-whitespace-mode' is active.

;;; Code:

(defvar-local prevent-trailing-whitespace-list nil
  "List of regions with potential trailing whitespace.
Each region is a cons (B . E) with beginning position B and end position E.")

(defun prevent-trailing-whitespace (b e &optional register)
  "Remove trailing white spaces in all lines in the region from B to E.
More exactly all trailing white space in lines with non-empty
intersection with the region from B to E are considered.
Register trailing whitespace before point in `prevent-trailing-whitespace-list'
when REGISTER is non-nil."
  (interactive "r")
  (setq b (save-excursion
            (goto-char b)
            (line-beginning-position))
        e (save-excursion
            (goto-char e)
            (line-end-position)))
  (let ((p (line-end-position -1))
		(inhibit-modification-hooks t))
    (when (< b p)
      (delete-trailing-whitespace b p))
    (setq p (line-beginning-position 2))
    (when (< p e)
      (delete-trailing-whitespace p e))
    (setq p (point))
    (save-excursion
      (goto-char (line-end-position))
      (when (and (looking-back "\\s-+$" (line-beginning-position))
                 (< p (match-end 0)))
	(delete-region (max p (match-beginning 0)) (line-end-position)))
      (when (and register
		 (< (match-beginning 0) p))
        (setq prevent-trailing-whitespace-list
              (cons (cons (match-beginning 0) p) prevent-trailing-whitespace-list))
        ))))

(defun prevent-trailing-whitespace-post-command ()
  "Clean up trailing whitespace in edited region.
Used for `post-command-hook' in `prevent-trailing-whitespace-mode'.
It removes trailing whitespace registered by `prevent-trailing-whitespace'
in `prevent-trailing-whitespace-list'."
  (cl-loop for r in-ref prevent-trailing-whitespace-list do
           (let ((b (car r))
                 (e (save-excursion
                      (goto-char (cdr r))
                      (set-marker (make-marker) (line-end-position)))))
             (prevent-trailing-whitespace b e)
             (unless (save-excursion
                       (goto-char b)
                       (re-search-forward "\\s-$" e t))
               (setf r nil))))
  (setq prevent-trailing-whitespace-list
        (cl-remove nil prevent-trailing-whitespace-list)))

;;;###autoload
(define-minor-mode prevent-trailing-whitespace-mode
  "Prevent trailing whitespace while modfying the buffer."
  nil
  " -ws"
  nil
  (if prevent-trailing-whitespace-mode
      (progn
        (add-hook 'after-change-functions #'prevent-trailing-whitespace nil t)
        (add-hook 'post-command-hook #'prevent-trailing-whitespace-post-command nil t))
    (remove-hook 'after-change-functions #'prevent-trailing-whitespace t)
    (remove-hook 'post-command-hook #'prevent-trailing-whitespace-post-command t)))

(provide 'prevent-trailing-whitespace)
;;; prevent-trailing-whitespace.el ends here
