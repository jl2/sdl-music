;;;; sdl-music.lisp
;;;;
;;;; Copyright (c) 2016 Jeremiah LaRocco <jeremiah.larocco@gmail.com>

(in-package #:sdl-music)

(defparameter *fps* 24)

(defun render (rotation win-width win-height)
  "Used OpenGL to display the grid."
  (declare (ignorable win-width win-height))
  (gl:matrix-mode :modelview)
  (gl:push-matrix)

  (gl:rotate rotation 0 0 1)
  (gl:color 0.0 0.8 0.0 1.0)
  (gl:with-primitives :lines
    (gl:vertex -10.0 0.0 0.0)
    (gl:vertex 10.0 0.0 0.0)
    
    (gl:vertex 0.0 -10.0 0.0)
    (gl:vertex 0.0 10.0 0.0)
    
    (gl:vertex 0.0 0.0 -10.0)
    (gl:vertex 0.0 0.0 10.0))
  (gl:pop-matrix))


(defun handle-window-size (win-width win-height)
  "Adjusting the viewport and projection matrix for when the window size changes."

  (gl:viewport 0 0 win-width win-height)
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho -20.0 20.0 -20.0 20.0 -1.0 1.0)
  (gl:clear :color-buffer :depth-buffer))

(defun real-main (args)
  "Run the game of life in an SDL window."
  (declare (ignorable args))
  (let ((frame-count 0)
        (start-time (get-internal-real-time)))

    (sdl2:with-init (:video)
      (sdl2:with-window (window :title "SDL With Mixalot"
                                :flags '(:shown :resizable :opengl))
        (sdl2:with-gl-context (gl-context window)

          (sdl2:gl-make-current window gl-context)

          ;; This *must* be inside of the sdl2:with-init call.
          (mixalot:main-thread-init)
          
          (format t "Arguments: ~a~%" args)
          (let* ((mp3-file-name (cadr args))
                 (current-stream (mixalot-mp3:make-mp3-streamer mp3-file-name))
                 (mixer (mixalot:create-mixer))
                 (rotation 0.0)
                 (paused nil))


            (multiple-value-bind (win-width win-height) (sdl2:get-window-size window)
              (handle-window-size win-width win-height)

              (gl:matrix-mode :modelview)
              (gl:load-identity)
              
              (gl:clear-color 0 0 0 0)
              (gl:shade-model :flat)
              (gl:cull-face :back)
              (gl:polygon-mode :front :fill)
              (gl:draw-buffer :back)
              (gl:enable :cull-face :depth-test)

              (gl:clear :color-buffer :depth-buffer)

              (render rotation win-width win-height)

              (gl:flush)
              (sdl2:gl-swap-window window)

              (mixalot:mixer-add-streamer mixer current-stream)

              (sdl2:with-event-loop ()
                (:windowevent
                 (:event event :data1 w :data2 h)
                 (when (= event sdl2-ffi:+sdl-windowevent-resized+)
                   (setf win-width w)
                   (setf win-height h)
                   (handle-window-size w h)))
                

                (:keyup
                 (:keysym keysym)
                 (when (or (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
                           (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-q))
                   (sdl2:push-event :quit))

                 (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-p)
                   (setf paused (not paused))))


                (:idle
                 ()
                 (incf frame-count)
                 (when (not paused)
                   (incf rotation (/ pi 10)))

                 (gl:clear :color-buffer :depth-buffer)
                 (render rotation win-width win-height)

                 (gl:flush)
                 (sdl2:gl-swap-window window))
                (:quit () t)))

            (mixalot:mixer-remove-all-streamers mixer)
            (mixalot:destroy-mixer mixer)))))
    (let* ((end-time (get-internal-real-time))
           (time-diff (- end-time start-time))
           (fpt (/ time-diff frame-count 1.0)))
      (format t "Frames: ~a in ~a ticks: ~a fpt~%" frame-count time-diff fpt ))))
  

(defun main (args)
  (sdl2:make-this-thread-main 
   (lambda ()
     (real-main args))))
