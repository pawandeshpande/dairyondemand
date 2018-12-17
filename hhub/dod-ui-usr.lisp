(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

  
(defun dod-controller-list-users ()
(if (is-dod-session-valid?)
   (let* ((tenant-id (hunchentoot:parameter "tenant-id"))
	 (users (get-users-for-company tenant-id)))
     (standard-page (:title "List HHUB Users")
       (:h3 "Users")
       (:a  :data-toggle "modal" :data-target (format nil "#adduser-modal")  :href "#"  (:span :class "glyphicon glyphicon-plus") " Add User")
	(modal-dialog (format nil "adduser-modal") "Add/Edit Policy" (com-hhub-transaction-edit-user))
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
  (let* ((fullname (if user (slot-value user 'name)))
	 (username (if user (slot-value user 'username)))
	 (email (if user (slot-value user 'email)))
	 (phone (if user (slot-value user 'phone-mobile)))
	 (row-id (if user (slot-value user 'row-id)))
	 (tenant-id (if user (slot-value user 'tenant-id)))
	 (userrole-instance (if user (select-user-role-by-userid row-id tenant-id)))
	 (userrolename (if userrole-instance (slot-value (get-user-roles.role userrole-instance) 'name)))
	 (transaction (select-bus-trans-by-trans-func "com-hhub-transaction-edit-user")))
    (if (has-permission transaction)
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		      (:form :class "form-adduser" :role "form" :method "POST" :action "dasadduseraction"
			     (if user (htm (:input :class "form-control" :type "hidden" :value row-id :name "id")))
			     (:img :class "profile-img" :src "/img/logo.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit User")
			     (:div :class "form-group input-group"
				   (:input :class "form-control" :name "fullname" :aria-describedby "fullnameprefix" :placeholder "Enter Full Name" :maxlength "60" :size "50" :type "text"  :value fullname)) 
			    
			     
			     (:div :class "form-group input-group"
				   (:input :class "form-control" :name "username" :aria-describedby "nameprefix" :placeholder "Enter username" :maxlength "30" :type "text"  :value username)) 
			     (:div :class "form-group"
				   (:label :for "email")
				   (:input :class "form-control" :name "email"  :placeholder "Enter User Email " :type "text" :value email ))
			    (:div :class "form-group"
				   (:label :for "userrole")
				   (role-dropdown "userrole" userrolename))
			    (:div :class "form-group input-group"
				   (:input :class "form-control" :name "phone" :maxlength "30"  :value phone :placeholder "Phone"  :type "text"))
			    (:div :class "form-group input-group"
				   (:input :class "form-control" :name "password" :maxlength "30"  :placeholder "Password"  :type "password"))
			    
			    (:div :class "form-group input-group"
				   (:input :class "form-control" :name "confirmpass" :maxlength "30"  :placeholder "Password"  :type "password"))
			    (:div :class "form-group input-group"
				   (:input :class "form-control" :name "userid" :type "hidden" :value row-id))
			    (:div :class "form-group input-group"
				   (:input :class "form-control" :name "usertenantid" :type "hidden" :value tenant-id))
			    
			    
			    (:div :class "form-group"
				   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:h3 "Permission Denied"))))))



(defun dod-controller-add-user-action ()
  (if (is-dod-session-valid?)
      (let*  ((userid (hunchentoot:parameter "userid"))
	      (usertenantid (hunchentoot:parameter "usertenantid"))
	      (fullname (hunchentoot:parameter "fullname"))
	      (username (hunchentoot:parameter "username"))
	      (phone (hunchentoot:parameter "phone"))
	      (email (hunchentoot:parameter "email"))
	      (userrole-name (hunchentoot:parameter "userrole"))
	      (password (hunchentoot:parameter "password"))
	      (confirmpass (hunchentoot:parameter "confirmpass"))
	      (salt-octet (secure-random:bytes 56 secure-random:*generator*))
	      (salt (flexi-streams:octets-to-string  salt-octet))
	      (encryptedpass (check&encrypt password confirmpass salt))
      	      (user (select-user-by-id userid usertenantid))
	      (userrole-instance (select-user-role-by-userid userid usertenantid))
	      (roletobeupdated (select-role-by-name userrole-name)))
	 
	      

	(unless (and  
		 (or (null fullname) (zerop (length fullname)))
		 (or (null username) (zerop (length username)))
		 (or (null phone) (zerop (length phone)))
		 (or (null email) (zerop (length email))))		
	  (if user (progn 
		     (setf (slot-value user 'name) fullname)
		     (setf (slot-value user 'username) username)
		     (setf (slot-value user 'phone-mobile) phone)
		     (setf (slot-value user 'email) email)
		     (setf (slot-value user 'password) encryptedpass)
		     (setf (slot-value user 'salt) salt)
		     (setf (slot-value userrole-instance 'role-id) (slot-value roletobeupdated 'row-id))
		     (update-user user)
		     (update-user-role userrole-instance))
	      ;else
	      (progn 
		(create-dod-user fullname username encryptedpass salt  email usertenantid)
		(let ((user-id  (slot-value (select-user-by-phonenumber phone usertenantid) 'phone-mobile))
		      (role-id (slot-value roletobeupdated 'row-id))) 
		(create-user-role user-id role-id usertenantid)))))
	(hunchentoot:redirect  "/hhub/sadminhome"))
      (hunchentoot:redirect "/hhub/opr-login.html")))


(defun get-login-userid ()
     (hunchentoot:session-value :login-userid))


(defun get-login-user-name ()
  (hunchentoot:session-value :login-username))


