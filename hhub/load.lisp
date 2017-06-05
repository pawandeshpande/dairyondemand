(push "~/dairyondemand/hhub/" asdf:*central-registry*)

(ql:quickload '(:uuid :secure-random :drakma :cl-json :cl-who :hunchentoot :clsql :clsql-mysql ))
(ql:quickload :dairyondemand :verbose T)
(in-package :dairyondemand)


