(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defmacro compadmin-navigation-bar ()
    :documentation "This macro returns the html text for generating a navigation bar using bootstrap."
    `(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-default navbar-inverse navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "HighriseHub" (:img :style "width: 30px; height: 30px;" :src "/img/logo.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/hhub/hhubcadindex"  (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li  (:a :href "/hhub/dasproductapprovals" "Customer Approvals"))
			 (:li  (:a :href "/hhub/dasproductapprovals" "Vendor Approvals"))
			 (:li :align "center" (:a :href "#" (str (format nil "Group: ~a" (slot-value (get-login-company) 'name)))))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "#"   (:span :class "glyphicon glyphicon-user") " My Profile" )) 
			 (:li :align "center" (:a :href "/hhub/hhubcadlogout"  (:span :class "glyphicon glyphicon-off") " Logout "  ))))))))


(defmacro standard-compadmin-page ( (&key title) &body body)
  `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	 (:html :xmlns "http://www.w3.org/1999/xhtml"
	     :xml\:lang "en" 
	     :lang "en"
	     (:head 
		 (:meta :http-equiv "Content-Type" 
		     :content    "text/html;charset=utf-8")
		 (:meta :name "viewport" :content "width=device-width,user-scalable=no")
		 (:meta :name "description" :content "")
		 (:meta :name "author" :content "")
		 (:link :rel "icon" :href "favicon.ico")
		 (:title ,title )
		 (:link :href "/css/style.css" :rel "stylesheet")
		 (:link :href "/css/bootstrap.min.css" :rel "stylesheet")
		 (:link :href "/css/bootstrap-theme.min.css" :rel "stylesheet")
 		 (:link :href "/css/theme.css" :rel "stylesheet")
		 (:link :href "https://code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css" :rel "stylesheet")
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "https://code.jquery.com/ui/1.12.0/jquery-ui.min.js")
		 (:script :src "/js/spin.min.js")
		 ) ;; Header completes here.
	     (:body
	      (:div :id "dod-main-container"
		    (:a :href "#" :class "scrollup" :style "display: none;") 
		    (:div :id "dod-error" (:h2 "Error..."))
		 (:div :id "busy-indicator")
		 (if (is-dod-session-valid?) (compadmin-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		     (:div :id "header"	; DOD System header
			 ,@body))	;container div close
		 
		 ;; bootstrap core javascript
		 (:script :src "/js/bootstrap.min.js")
		 (:script :src "/js/dod.js"))))))
   


(defun dod-controller-compadmin-loginpage ()
  (handler-case 
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (if (is-dod-session-valid?)
		  (hunchentoot:redirect "/hhub/dodcadindex")
		  ;else
		  (standard-compadmin-page (:title "Welcome to HighriseHub Company Administrator")
		    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:div :class "account-wall"
				      (:h1 :class "text-center login-title"  "Login to HighriseHub")
				      (:form :class "form-signin" :role "form" :method "POST" :action "hhubcadlogin"
					     
					     (:div :class "form-group"
						   (:input :class "form-control" :name "phone" :placeholder "Enter RMN. Ex: 9999999999" :type "text"))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "password"  :placeholder "Password=demo" :type "password"))
					     (:input :type "submit"  :class "btn btn-primary" :value "Login      "))))))))
	      (clsql:sql-database-data-error (condition)
					     (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
												      (stop-das) 
												      (start-das)
												      (hunchentoot:redirect "/hhub/cad-login.html"))))))



(defun dod-controller-compadmin-index () 
  (if (is-dod-session-valid?)
      (let ((products (get-products-for-approval (get-login-tenant-id))))
	(standard-compadmin-page (:title "Welcome to Highrisehub.")
	  (:div :class "container"
		(:div :id "row"
		      (:div :id "col-xs-6" 
			    (:h3 "Welcome " (str (format nil "~A" (get-login-user-name))))))
		(:hr)
		(:h4 "Pending Product Approvals")
		(:div :id "row"
		      (:div :id "col-xs-6"
			    (:div :id "col-xs-6" :align "right" 
				  (:span :class "badge" (str (format nil "~A" (length products)))))))
		(:hr)
		(str (display-as-tiles products 'product-card-for-approval )))))
	
					;else
      (hunchentoot:redirect "/hhub/cad-login.html")))



(defun dod-controller-cadlogin ()
  (let  ((phone (hunchentoot:parameter "phone"))
	 (passwd (hunchentoot:parameter "password")))
      (unless(and
	    ( or (null phone) (zerop (length phone)))
	    ( or (null passwd) (zerop (length passwd))))
      (if (equal (dod-cad-login :phone phone :password passwd) NIL) (hunchentoot:redirect "/hhub/cad-login.html") (hunchentoot:redirect  "/hhub/hhubcadindex")))))
   

(defun dod-cad-login (&key phone  password)
  (let* ((login-user (car (clsql:select 'dod-users :where [and
				       [= [slot-value 'dod-users 'phone-mobile] phone]
				       [= [slot-value 'dod-users 'password] password]]
				      :caching nil :flatp t)))
	 (login-userid (if login-user (slot-value login-user 'row-id)))
	 (login-attribute-cart '())
	 (login-tenant-id (if login-user (slot-value  (users-company login-user) 'row-id)))
	 (login-company (if login-user (slot-value login-user 'company)))
	 (username (if login-user (slot-value login-user 'username)))
	 (company-name (if login-user (slot-value (users-company login-user) 'name))))


    (when (and   
	   login-user 
	   (null (hunchentoot:session-value :login-username)) ;; User should not be logged-in in the first place.
	   )  (progn 				      (setf *current-user-session* (hunchentoot:start-session))
				      (setf (hunchentoot:session-value :login-username) username)
				      (setf (hunchentoot:session-value :login-userid) login-userid)
				      (setf (hunchentoot:session-value :login-attribute-cart) login-attribute-cart)
				      (setf (hunchentoot:session-value :login-tenant-id) login-tenant-id)
				      (setf (hunchentoot:session-value :login-company-name) company-name)
				      (setf (hunchentoot:session-value :login-company) login-company))
		 
       	 )))


  
   (defun dod-controller-cadlogout ()
     (progn (dod-logout (get-login-user-name))
	    (hunchentoot:remove-session *current-user-session*)
	    (hunchentoot:redirect "/hhub/cad-login.html")))



(defun dod-controller-vendor-reject-product-action ()
  (if (is-dod-session-valid?)
      (let ((id (hunchentoot:parameter "id"))
	    (description (hunchentoot:parameter "description")))
	(reject-product id description (get-login-company))
	(hunchentoot:redirect "/hhub/hhubcadindex"))
      					;else
  (hunchentoot:redirect "/hhub/cad-login.html")))



(defun dod-controller-vendor-accept-product-action ()
  (if (is-dod-session-valid?)
      (let ((id (hunchentoot:parameter "id"))
	    (description (hunchentoot:parameter "description")))

	(approve-product id description (get-login-company))
	(hunchentoot:redirect "/hhub/hhubcadindex"))
      					;else
      (hunchentoot:redirect "/hhub/cad-login.html")))


