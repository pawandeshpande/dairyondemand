(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun dod-controller-delete-company ()
(if (is-dod-session-valid?)
    (let ((id (hunchentoot:parameter "id")) )
      (delete-dod-company id)
      (hunchentoot:redirect "/list-companies"))
     (hunchentoot:redirect "/login")))



																		   
(defun ui-list-companies (complist)
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class "row-fluid"	  (mapcar (lambda (company)
						      (htm (:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12" 
							       (:div :class "company-box"   (company-card company )))))
					     complist))))



(defun company-card (instance)
    (let ((comp-name (slot-value instance 'name))
	     (address  (slot-value instance 'address))
	     (city (slot-value instance 'city))
	  (state (slot-value instance 'state)) 
	  (country (slot-value instance 'country))
	  (zipcode (slot-value instance 'zipcode))
	  (row-id (slot-value instance 'row-id)))

	   
	(cl-who:with-html-output (*standard-output* nil)
	  
		(:div :class "row"
		    
		(:div :class "col-sm-2" (str comp-name))
		(:div :class "col-sm-2" (str address))
		(:div :class "col-sm-2" (str city))
		(:div :class "col-sm-2" (str state))
		(:div :class "col-sm-2" (str country))
		(:div :class "col-sm-1" (str zipcode))
		(:div :class "col-sm-1"  (:a :href  (format nil  "/delcomp?id=~A" row-id )  "Delete"))
		))))




(defun dod-controller-list-companies ()
(if (is-dod-session-valid?)
   (let (( companies (list-dod-companies)))
    (standard-page (:title "List companies")
      (ui-list-companies companies)))
(hunchentoot:redirect "opr-login.html")))



(defun get-login-tenant-id ()
  (hunchentoot:session-value :login-tenant-id))

(defun get-login-cust-tenant-id ()
  (hunchentoot:session-value :login-customer-tenant-id))

(defun get-login-vend-tenant-id ()
  (hunchentoot:session-value :login-vendor-tenant-id))



(defun get-login-company ()
  (let ((tenant-id (get-login-tenant-id)))
    (select-company-by-id tenant-id)))


(defun get-login-customer-company ()
  (let ((tenant-id (get-login-cust-tenant-id)))
    (select-company-by-id tenant-id)))


(defun get-login-vendor-company ()
  (let ((tenant-id (get-login-vend-tenant-id)))
    (select-company-by-id tenant-id)))
