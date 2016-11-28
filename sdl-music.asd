;;;; sdl-music.asd
;;;;
;;;; Copyright (c) 2016 Jeremiah LaRocco <jeremiah.larocco@gmail.com>

(asdf:defsystem #:sdl-music
  :description "Describe sdl-music here"
  :author "Jeremiah LaRocco <jeremiah.larocco@gmail.com>"
  :license "ISC"
  :depends-on (#:sdl2
               #:mixalot-mp3
               #:trivial-main-thread
               #:cl-opengl
               #:cl-glu
               #:anim-utils)
  :serial t
  :components ((:file "package")
               (:file "sdl-music")))

