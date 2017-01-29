(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun crm-controller-delete-company ()
(if (is-dod-session-valid?)
    (let ((id (hunchentoot:parameter "id")) )
      (delete-dod-company id)
      (hunchentoot:redirect "/list-companies"))
     (hunchentoot:redirect "/login")))


(defun crm-controller-list-companies ()
(if (is-dod-session-valid?)
   (let (( companies (list-dod-companies)))
    (standard-page (:title "List companies")
      (:table :cellpadding "0" :cellspacing "0" :border "1"
     (loop for company in companies
       do (htm (:tr (:td :colspan "3" :height "12px" (str (slot-value company 'name)))
		    (:td :colspan "12px" (:a :href  (format nil  "/delcomp?id=~A" (slot-value company 'row-id)) "Delete"))
		    
		    ))))))
 (hunchentoot:redirect "/login")))

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
