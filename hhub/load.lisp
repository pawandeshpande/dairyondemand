(push "~/dairyondemand/hhub/" asdf:*central-registry*)

(ql:quickload '(:uuid :secure-random :drakma :cl-json :cl-who :hunchentoot :clsql :clsql-mysql :timer ))
(ql:quickload :hhub :verbose T)
(in-package :hhub)


