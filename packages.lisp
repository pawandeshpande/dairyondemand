(in-package :cl-user)
(defpackage :com.desh.dairyondemand
  (:use :cl :uuid :cl-who :hunchentoot :clsql :clsql-sys)
  (:nicknames :dairyondemand :dod)
  (:export #:*logged-in-users*
	    #:*http-server*))

