;;; halo.lisp --- morphic-style object handles

;; Copyright (C) 2011  David O'Toole

;; Author: David O'Toole <dto@gnu.org>
;; Keywords: 

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

;;; Code:

(in-package :blocky)

(defparameter *handle-scale* 3.2)

(defparameter *indicator-positions* 
  '(:asterisk (0 1)
    :bang (0 1/5)
    :top-left-triangle (0 0)
    :menu (1/5 0)
    :collapse (0 1/5)
    :move (4/5 0)
    :resize (1 1)
    :reference (0 4/5)
    :close (0 0)
    :bottom-right-triangle (1 1)))

(define-block handle target indicator color)

(define-method initialize handle (&optional target)
  (super%initialize self)
  (setf %target target))

(define-method layout handle ()
  (with-fields (x y width height) %target
    (destructuring-bind (px py) (getf *indicator-positions* %indicator)
      (let* ((size (* *handle-scale* (indicator-size)))
	     (margin (* 2 size))
	     (x0 (- x size))
	     (y0 (- y size)))
	(setf %x (+ x0 
		    (* px (+ width margin))))
	(setf %y (+ y0 
		    (* py (+ height margin))))
	(setf %width size)
	(setf %height size)))))

(define-method draw handle ()
  (draw-indicator %indicator %x %y 
		  :color "white"
		  :scale *handle-scale*
		  :background %color))
		
(defmacro define-handle (name indicator &key (color "gray20"))
  (assert (symbolp name))
  (assert (string color))
  `(define-block (,name :super :handle)
     (indicator :initform ,indicator)
     (color :initform ,color)))

(define-handle evaluate :bang)

(define-method on-tap evaluate ()
  (evaluate %target))

(define-handle open-menu :menu)

(define-method on-tap open-menu ()
  (drop self (context-menu %target)))

(define-handle move :move)

(define-method do-drag move (x y)
  (move-to %target x y))

(define-handle resize :resize)

(define-handle reference :reference)

(define-handle discard :close)

(define-method on-tap discard ()
  (discard %target))
     
(define-handle collapse :collapse)

;;; The halo itself

(defparameter *halo-handles* 
  '(:evaluate :open-menu :move :resize :reference :discard :collapse))

(define-block halo target)

(define-method initialize halo (target)
  (assert (blockyp target))
  (setf %target target)
  (apply #'super%initialize self
	 (mapcar #'(lambda (handle)
		       (clone (make-prototype-id handle) target))
		 *halo-handles*)))

(define-method draw halo ()
  (draw-inputs self))
	  
;;; halo.lisp ends here
