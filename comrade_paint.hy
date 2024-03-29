;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                  This file is part of Comrade Paint.                    ;;;
;;;                                                                         ;;;
;;;  Comrade Paint is free software: you can redistribute it and/or modify  ;;;
;;;  it under the terms of the GNU General Public License as published by   ;;;
;;;     the Free Software Foundation, either version 3 of the License, or   ;;;
;;;                 (at your option) any later version.                     ;;;
;;;                                                                         ;;;
;;;     Comrade Paint is distributed in the hope that it will be useful,    ;;;
;;;     but WITHOUT ANY WARRANTY; without even the implied warranty of      ;;;
;;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       ;;;
;;;              GNU General Public License for more details.               ;;;
;;;                                                                         ;;; 
;;;    You should have received a copy of the GNU General Public License    ;;;
;;;  along with Comrade Paint.  If not, see <https://www.gnu.org/licenses/> ;;;
;;;                                                                         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import pygame)

((. pygame init))

;; Window setup
(setv window-width 800
      window-height 600
      window-surface ((. pygame display set-mode) (, window-width window-height)))
((. pygame display set-caption) "Comrade Paint")

;; The drawing surface occupies the whole screen minus some pixels at the
;; bottom that are used to show the colors
(setv toolbar-size 40
      drawing-surface
        ((. pygame Surface) (, window-width (- window-height toolbar-size))))
((. drawing-surface fill) (, 255 255 255))

(setv pink (, 245 66 218)
      green (, 0 250 0)
      red (, 250 0 0)
      blue (, 0 0 250)
      black (, 0 0 0)
      yellow (, 249 255 66)
      purple (, 161 66 255)
      brown (, 112 75 52)
      grey (, 150 150 150)
      white (, 255 255 255) 
      orange (, 255 135 15)
      pink (, 255 36 233)
      colors [red orange yellow green blue purple pink black white brown grey]
      current-color black

      current-size 40)

(defn new-text-surface [font text]
  ((. font render) text False white))

(setv font-size 30 
      font ((. pygame font SysFont) "ubuntumono" font-size)
      text-surface (new-text-surface font (str current-size))
      text-margin (* 0.5 (- toolbar-size font-size)))

(defn mouse-handler [event]
  ;; :[ I will try to eliminate this somehow in the future
  (global current-color) 
  (setv position ((. pygame mouse get-pos)))
  ;; Check if the mouse click was inside the drawing area
  (if (<= (get position 1) (- window-height toolbar-size))
    ((. pygame draw circle) drawing-surface current-color position current-size)
    ;; If it wasn't, check if the mouse click was within the color squares
    (when (<= (get position 0) (* (len colors) toolbar-size))
      ;; Determine which color was selected with floor division
      (setv current-color (get colors (// (get position 0) toolbar-size))))))

(setv running True)
(while running
  ;; Process events
  (for [event ((. pygame event get))]
    (cond [(= (. event type) (. pygame QUIT))
            (setv running False)]
          [(= (. event type) (. pygame MOUSEBUTTONDOWN))
            (mouse-handler event)]
          [(= (. event type) (. pygame KEYDOWN))
            (cond
              [(= (. event key) (. pygame K_UP))
                (setv current-size (+ current-size 10)
                      text-surface (new-text-surface font (str current-size)))]
              [(= (. event key) (. pygame K_DOWN))
                (setv current-size (max (- current-size 10) 0)
                      text-surface (new-text-surface font (str current-size)))])]))
              
  ;; Clear the window surface, this will become necessary at some point
  ((. window-surface fill) (, 0 0 0))
  ;; Draw color picker squares to bottom of the window surface
  (for [(, index color) (enumerate colors)]
    (setv rect (,
                 (* index toolbar-size)
                 (- window-height toolbar-size)
                 toolbar-size
                 toolbar-size))
    ((. pygame draw rect) window-surface color rect))

  ;; Display the drawing surface on top of the main window surface
  ((. window-surface blit) drawing-surface (, 0 0))

  (setv text-position (, (- window-width ((. text-surface get-width)) text-margin)
                         (- window-height ((. text-surface get-height)) text-margin)))
  ((. window-surface blit) text-surface text-position)
  ((. pygame display flip)))
