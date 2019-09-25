;; counsel-etags-tests.el --- unit tests for counsel-etags -*- coding: utf-8 -*-

;; Author: Chen Bin <chenbin DOT sh AT gmail DOT com>

;;; License:

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

(require 'ert)
(require 'counsel-etags-sdk)
(require 'counsel-etags-javascript)
(require 'js)

(defvar tags-file-content '("\014\nhello.js,124\n"
                            "function hello() {\177hello\0011,0\n"
                            "export class CHello {\177CHello\0013,21\n"
                            " hello() {\177hello\0014,43\n"
                            " test() {\177test\0016,59\n"
                            "  hi() {\177hi\0018,74\n"
                            "\014\ntest.js,29\n"
                            "function hello() {\177hello\0011,0\n"))

(defun create-tags-file (filepath)
  (with-temp-buffer
    (apply #'insert tags-file-content)
    ;; not empty
    (should (> (length (buffer-string)) 50))
    (write-region (point-min) (point-max) filepath)))

(defun get-full-path (filename)
  (concat
   (if load-file-name (file-name-directory load-file-name) default-directory)
   filename))

(create-tags-file (get-full-path "TAGS"))

(ert-deftest counsel-etags-test-find-tag ()
  ;; one hello function in test.js
  ;; one hello function, one hello method and one test method in hello.js
  (let* (cands context)
    ;; all tags across project, case insensitive, fuzzy match.
    ;; So "CHello" is also included
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" t nil))
    (should (eq (length cands) 4))

    ;; all tags across project, case sensitive
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil nil))
    (should (eq (length cands) 3))

    ;; all functions
    (setq context (list :major-mode 'js2-mode
                        :line-number 10
                        :local-only nil ; here
                        :fullpath (get-full-path "hello.js")))
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil context))
    (should (eq (length cands) 3))

    ;; local function in hello.js when :local-only is t
    (setq context (list :major-mode 'js2-mode
                        :line-number 10
                        :local-only t ; here
                        :fullpath (get-full-path "hello.js")))
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil context))
    (should (eq (length cands) 2))

    ;; one function named "test"
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "test" nil nil))
    (should (eq (length cands) 1))))

(ert-deftest counsel-etags-test-sort-cands-by-filename ()
  (let* (cands)
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil nil))
    (should (eq (length cands) 3))
    ;; the function in the external file is at the top
    (should (string-match "test.js" (car (nth 2 cands))))
    ;; sort the candidate by string-distance from "hello.js"
    (let* ((f (get-full-path "test.js")))
      (should (string-match "test.js" (car (nth 0 (counsel-etags-sort-candidates-maybe cands 3 nil f))))))))

(ert-deftest counsel-etags-test-tags-file-cache ()
  (let* (cands)
    ;; clear cache
    (setq counsel-etags-cache nil)
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil nil))
    (should (eq (length cands) 3))
    ;; cache is filled
    (should counsel-etags-cache)
    (should (counsel-etags-cache-content (get-full-path "TAGS")))))

(ert-deftest counsel-etags-test-tag-history ()
  (let* (cands
         (dir (get-full-path "")))
    ;; clear history
    (setq counsel-etags-tag-history nil)
    (setq cands (counsel-etags-extract-cands (get-full-path "TAGS") "hello" nil nil))
    (should (eq (length cands) 3))
    ;; only add tag when it's accessed by user manually
    (should (not counsel-etags-tag-history))
    (setq cands (mapcar 'car cands))
    (dolist (c cands) (counsel-etags-remember c dir))
    (should counsel-etags-tag-history)
    (should (eq (length counsel-etags-tag-history) 3))))

(ert-run-tests-batch-and-exit)