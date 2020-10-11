(in-package :cl-user)
(defpackage :com.hhub.app
  (:use :cl :uuid :secure-random :cl-json :cl-who :drakma :hunchentoot :clsql :clsql-mysql :cl-smtp :parenscript)
  (:nicknames :hhub :dairyondemand) 
  (:export #:*logged-in-users*
	   #:*dod-db-instance*
	    #:*http-server*))

