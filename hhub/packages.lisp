(in-package :cl-user)
(defpackage :com.desh.hhub
  (:use :cl :uuid :cl-who :hunchentoot :clsql :clsql-sys)
  (:nicknames :highrisehub :hhub :dairyondemand :dod)
  (:export #:*logged-in-users*
	   #:*dod-db-instance*
	    #:*http-server*))

