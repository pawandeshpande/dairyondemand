(in-package :cl-user)
(defpackage :com.desh.hhub
  (:use :cl :uuid :secure-random :drakma :cl-json :cl-who :hunchentoot :clsql :clsql-mysql  )
  (:nicknames :highrisehub :hhub :dairyondemand :dod)
  (:export #:*logged-in-users*
	   #:*dod-db-instance*
	    #:*http-server*))

