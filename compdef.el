;;; compdef.el --- A stupid completion definer. -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Uros Perisic

;; Author: Uros Perisic
;; URL: https://gitlab.com/jjzmajic/compdef
;;
;; Version: 0.1
;; Keywords: convenience
;; Package-Requires: ((emacs "24.4"))

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <https://www.gnu.org/licenses/>.

;; This file is not part of Emacs.

;;; Commentary:
;; A stupid completion definer.

;; We keep reinventing the wheel on how to set local completion
;; backends.  `compdef' does this for both CAPF and company
;; simultaneously (in case `company-capf' needs tweaking), with some
;; auto-magic thrown in for convenience.  `compdef' is intentionally
;; stupid.  I've seen some really powerful solutions to this problem,
;; but they all seem to assume a certain approach to configuring
;; completions and are thus usually embedded in a starter kit like
;; Doom Emacs, Spacemacs... `compdef' isn't that clever. It just
;; works.

;;; Code:
(defvar company-backends)

(defun compdef--enlist (exp)
  "Return EXP wrapped in a list, or as-is if already a list."
  (declare (pure t) (side-effect-free t))
  (if (listp exp) exp (list exp)))

(cl-defun compdef (&key modes hooks capf company)
  "Set local completion backends for MODES using HOOKS.
Set `company-backends' to COMPANY if not nil. Set
`completion-at-point-functions' to CAPF if not nil.  If HOOKS are
nil, infer them from MODES.  All arguments can be quoted lists as
well as atoms.  If HOOKS are not nil, they must be of the same
length as MODES."
  (let* ((capf (compdef--enlist capf))
         (company (compdef--enlist company))
         (modes (compdef--enlist modes))
         (hooks (or hooks (cl-loop for mode in modes collect
                                   (intern (concat (symbol-name mode)
                                                   "-hook"))))))
    (cl-loop for hook in hooks
             for mode in modes
             do (add-hook hook
                          (defalias
                            (intern (format "compdef-%s-fun" (symbol-name mode)))
                            (lambda ()
                              (when capf (setq-local completion-at-point-functions capf))
                              (when company (setq-local company-backends company)))
                            (format
                             "Set completion backends for %s. Added by `compdef'."
                             (symbol-name mode)))))))

(provide 'compdef)
;;; compdef.el ends here
