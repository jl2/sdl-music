QL_SETUP=~/quicklisp/setup.lisp

sdl-music: sdl-music.lisp sdl-music.asd package.lisp systems.txt
	buildapp --manifest-file systems.txt \
		 --load-system sdl-music \
		 --entry sdl-music::main \
		 --output sdl-music

systems.txt: 
	sbcl --no-userinit --no-sysinit --non-interactive --load $(QL_SETUP) --eval '(ql:write-asdf-manifest-file "systems.txt")'

