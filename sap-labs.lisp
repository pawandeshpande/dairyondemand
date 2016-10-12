(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
					;**********Get the company***********
(defparameter dod-company (select-company-by-name "SAP Labs"))


;******Create the customer ******
(defparameter *customer-params* nil)
(setf GuruDesai (list "Gururaj Desai" "SAP Labs, Whitefield, Bangalore" "9886732790"  dod-company))
;Create the customer now.
(apply #'create-customer *customer-params*)

