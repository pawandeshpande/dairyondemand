(push "~/dairyondemand/" asdf:*central-registry*)
(ql:quickload :uuid)
(ql:quickload '(:cl-who :hunchentoot :clsql ))
(ql:quickload :dairyondemand :verbose T)
(in-package :dairyondemand)
