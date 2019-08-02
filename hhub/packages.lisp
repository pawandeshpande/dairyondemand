(in-package :cl-user)
(defpackage :com.desh.hhub
  (:use :cl :uuid :secure-random :cl-json :cl-who :drakma :hunchentoot :clsql :clsql-mysql :cl-smtp :parenscript)
  (:nicknames :highrisehub :hhub :dairyondemand :dod)
  (:export #:*logged-in-users*
	   #:*dod-db-instance*
	    #:*http-server*))

