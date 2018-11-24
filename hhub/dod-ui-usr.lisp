(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

  
(defun dod-controller-list-users ()
(if (is-dod-session-valid?)
   (let* ((tenant-id (hunchentoot:parameter "tenant-id"))
	 (users (get-users-for-company tenant-id)))
     (standard-page (:title "List HHUB Users")
       (:h3 "Users")
       (str (display-as-table (list "Name" "Phone number" "Email" "Action")  users 'user-card))))
   (hunchentoot:redirect "/hhub/opr-login.html")))


(defun user-card (user-instance)
  (let ((name (slot-value user-instance 'name))
	(phone-mobile (slot-value user-instance 'phone-mobile))
	(email (slot-value user-instance 'email))
	(row-id (slot-value user-instance 'row-id)))

    (cl-who:with-html-output (*standard-output* nil)
      
      (:td :height "10px" 
	(:h6 :class "user-name"  (str name)))
      (:td :height "10px" 
	(:h6 :class "user-phone-mobile"  (str phone-mobile)))
      (:td :height "10px" 
       	 (:h6 :class "user-email"  (str email) ))
      (:td :height "10px" 
       (:a  :data-toggle "modal" :data-target (format nil "#edituser-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
	(modal-dialog (format nil "edituser-modal~a" row-id) "Add/Edit Policy" (com-hhub-transaction-edit-user user-instance))))))



(defun com-hhub-transaction-edit-user (&optional user)
  (let* ((name (if user (slot-value user 'name)))
	 (email (if user (slot-value user 'email)))
	 (phone (if user (slot-value user 'phone-mobile)))
	 (row-id (if user (slot-value user 'row-id)))
	 (tenant-id (if user (slot-value user 'tenant-id)))
	 (userrole (if user (select-user-role-by-userid row-id tenant-id)))
	 (transaction (select-bus-trans-by-trans-func "com-hhub-transaction-edit-user")))
    (if (has-permission transaction)
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		      (:form :class "form-adduser" :role "form" :method "POST" :action "dasadduseraction"
			     (if user (htm (:input :class "form-control" :type "hidden" :value row-id :name "id")))
			     (:img :class "profile-img" :src "/img/demand&supply.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit User")
			     (:div :class "form-group input-group"
				   (:input :class "form-control" :name "username" :aria-describedby "polnameprefix" :maxlength "30" :type "text"  :value name)) 
			     (:div :class "form-group"
				   (:label :for "useremail")
				   (:input :class "form-control" :name "useremail"  :placeholder "Enter User Email " :type "text" :value email ))
			    (:div :class "form-group"
				   (:label :for "useremail")
				   (:input :class "form-control" :name "userrole"  :placeholder "Enter User role " :type "text" :readonly "true" :value email ))
			    
			     (:div :class "form-group input-group"
				   (:input :class "form-control" :name "userphone" :maxlength "30"  :value phone :type "text"))
			     (:div :class "form-group"
				   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:h3 "Permission Denied"))))))







(defun crm-controller-new-user ()
 (if (is-dod-session-valid?)
      (standard-page (:title "Add a new User")
	(:h1 "Add a new User")
	(:form :action "/user-added" :method "post" 
	       (:p "Name: "
		   (:input :type "text"  
			   :name "name" 
			   :class "txt")
		   (:p "Username: " (:input :type "text"  
					    :name "username" 
					    :class "txt"))
		   (:p "Password: " (:input :type "password"  
					    :name "password" 
					    :class "password"))
		   (:p "Email: " (:input :type "text"  
					 :name "email" 
					 :class "txt"))

		   ;; Add a drop down list of available roles for the user.
				  
				  
		   (:p (:input :type "submit" 
			       :value "Add" 
			       :class "btn")))))
      (hunchentoot:redirect "/login")))


(defun crm-controller-user-added ()
  (if (is-dod-session-valid?)
      (let  ((name (hunchentoot:parameter "name"))
	     (username (hunchentoot:parameter "username"))
	     (password (hunchentoot:parameter "password"))
	     (email (hunchentoot:parameter "email")))
    
	(unless (and  ( or (null name) (zerop (length name)))
		      ( or (null username) (zerop (length username)))
		      ( or (null password) (zerop (length password)))
		      ( or (null email) (zerop (length email))))		
	  (create-dod-user name username password email (get-login-tenant-id)))
	(hunchentoot:redirect  "/dodindex"))
      (hunchentoot:redirect "/login")))



(defun new-dod-user(name uname passwd email-address tenant-id )
 (if ( is-dod-session-valid?)
	;; if session is valid then go ahead and create the company
    (create-dod-user name uname passwd email-address tenant-id)
     ;; else redirect to the login page
    (hunchentoot:redirect "/login")))


(defun get-login-userid ()
     (hunchentoot:session-value :login-userid))


(defun get-login-user-name ()
  (hunchentoot:session-value :login-username))


