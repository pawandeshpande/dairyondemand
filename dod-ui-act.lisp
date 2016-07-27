
(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun crm-controller-delete-account ()
(if (is-crm-session-valid?)
    (let ((id (hunchentoot:parameter "id")) )
      (delete-crm-account id)
      (hunchentoot:redirect "/list-accounts"))
     (hunchentoot:redirect "/login")))


(defun crm-controller-list-accounts ()
(if (is-crm-session-valid?)
   (let (( accounts (list-current-login-crm-accounts)))
     (standard-page (:title "List Accounts")
       (:h3 "Accounts")

       
      (:table :class "table table-striped" 
	      (:tr (:th "Account name") (:th "Account Type") (:th "Action"))
      (if (= (list-length accounts) 0) (htm (:tr (:td  :height "12px" (:p "No Accounts Found"))))
      (loop for account in accounts
       do (htm (:tr (:td  :height "12px" (str (slot-value account 'name)))
		    (:td :height "12px" (str (nth (decf (slot-value account 'account-type)) *crm-account-types*)))
		    (:td :colspan "12px" (:a :href  (format nil  "/delaccount?id=~A" (slot-value account 'row-id)) "Delete")))))))))
    (hunchentoot:redirect "/login")))

 

(defmacro account-type-dropdown ()
  `(cl-who:with-html-output (*standard-output* nil)
     (let ((count 0))
     (htm (:select :name "accounttype"  
      (loop for acct-type in *crm-account-types*
	 do (htm  (:option :value (incf count) (str acct-type)))))))))


(defun crm-controller-new-account ()
  (if (is-crm-session-valid?)
      (standard-page (:title "Add a new Account")
	(:h1 "Add a new Account")
	(:div :id "row"
	      
	(:form :action "/account-added" :method "post" 
	       (:p "Name: "
(:div :id "col-md-4"
		   (:input :type "text"  :maxlength 30
			   :name "name" 
			   :class "txt")
		   (:p "Description: " (:textarea :rows 4 :cols 50  :maxlength 255   
					    :name "description" 
					    :class "txt"))
		   (:p "Account Type: " (account-type-dropdown))
		   
		   ;; Add a drop down list of available roles for the user.
		   (:p (:input :type "submit" 
			       :value "Add" 
			       :class "btn")))))))
      (hunchentoot:redirect "/login")))



	   
(defun crm-controller-account-added ()
  (if (is-crm-session-valid?)
      (let  ((name (hunchentoot:parameter "name"))
	     (description (hunchentoot:parameter "description"))
	     (accounttype (hunchentoot:parameter "accounttype")))
	     
	(unless(and  ( or (null name) (zerop (length name)))
		     ( or (null description) (zerop (length description)))
		     ( or (null accounttype) (zerop (length accounttype))))
	  
	  (new-crm-account name description (parse-integer accounttype) (get-login-tenant-id) ))

	(hunchentoot:redirect  "/crmindex"))
      (hunchentoot:redirect "/login")))


