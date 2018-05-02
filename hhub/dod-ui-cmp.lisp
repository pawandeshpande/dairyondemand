(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun dod-controller-delete-company ()
(if (is-dod-session-valid?)
    (let ((id (hunchentoot:parameter "id")) )
      (delete-dod-company id)
      (hunchentoot:redirect "/list-companies"))
     (hunchentoot:redirect "/login")))


(defun company-card (instance)
    (let ((comp-name (slot-value instance 'name))
	  (address  (slot-value instance 'address))
	  (city (slot-value instance 'city))
	  (state (slot-value instance 'state)) 
	  (country (slot-value instance 'country))
	  (zipcode (slot-value instance 'zipcode))
	  (row-id (slot-value instance 'row-id)))
	(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "product-box" 
	  (:div :class "row" 
		(:div :class "col-xs-12" :align "right"
		      (:a  :data-toggle "modal" :data-target (format nil "#editcompany-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
		       ;(:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#editcompany-modal" "Add New Group")
		     (modal-dialog (format nil "editcompany-modal~a" row-id) "Add/Edit Group" (com-hhub-transaction-create-company row-id))
		      )) 
	  (:div :class "row"
		(:div :class "col-xs-12"  (:h3 (str (if (> (length comp-name) 20)  (subseq comp-name 0 20) comp-name)))))
	  (:div :class "row"
		(:div :class "col-xs-12"  (str address)))
	  (:div :class "row"
		(:div :class "col-xs-12" (str city)))
	  (:div :class "row"
		(:div :class "col-xs-6" (str state))
		(:div :class "col-xs-6" (str country)))
	  (:div :class "row"
		(:div :class "col-xs-6" (str zipcode)))
	  (:div :class "row" 
		(:div :class "col-xs-6" (:b (:h5 (str (format nil "No of Customers: ~A " (count-company-customers instance))))))
	  (:div :class "col-xs-6" (:b (:h5 (str (format nil  "No of Vendors: ~A " (count-company-vendors instance )))))))
	  ))))


(defun dod-controller-list-companies ()
(if (is-dod-session-valid?)
   (let (( companies (list-dod-companies)))
    (standard-page (:title "List companies")
      (ui-list-companies companies)))
(hunchentoot:redirect "opr-login.html")))


(defun ui-list-companies (company-list)
 (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
  (if company-list 
      (htm (:div :class "row-fluid"	  
	    (mapcar (lambda (cmp)
		      (htm (:form :method "POST" :action "custsignup1action" :id "custsignup1form" 
			   (:div :class "col-sm-4 col-lg-3 col-md-4"
			    (:div :class "form-group"
			     (:input :class "form-control" :name "cname" :type "hidden" :value (str (format nil "~A" (slot-value cmp 'name)))))
			    (:div :class "form-group"
				  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" (str (format nil "~A" (slot-value cmp 'name)))))))))  company-list)))
					;else
      (htm (:div :class "col-sm-12 col-md-12 col-lg-12"
		 (:h3 "No records found"))))))






(defun get-login-tenant-id ()
  (hunchentoot:session-value :login-tenant-id))

(defun get-login-cust-tenant-id ()
  (hunchentoot:session-value :login-customer-tenant-id))

(defun get-login-vend-tenant-id ()
  (hunchentoot:session-value :login-vendor-tenant-id))



(defun get-login-company ()
  ( hunchentoot:session-value :login-company))


(defun get-login-customer-company ()
  ( hunchentoot:session-value :login-customer-company))

(defun get-login-customer-company-name ()
    ( hunchentoot:session-value :login-customer-company-name))


(defun get-login-vendor-company ()
(hunchentoot:session-value :login-vendor-company))  



(defun get-login-vendor-company-name ()
 (hunchentoot:session-value :login-vendor-company-name))  
	
