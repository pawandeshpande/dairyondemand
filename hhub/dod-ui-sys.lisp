(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defvar *logged-in-users* nil)
(defvar *current-user-session* nil)



(defmacro navigation-bar ()
    :documentation "This macro returns the html text for generating a navigation bar using bootstrap."
    `(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-default navbar-inverse navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "DAS" (:img :style "width: 30px; height: 30px;" :src "resources/demand&supply.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/hhub/dodindex"  (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li  (:a :href "/hhub/dasabacsecurity" "ABAC Security"))
			 (:li  (:a :href "/hhub/adminsettings" "Admin Settings"))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "dodvendprofile"   (:span :class "glyphicon glyphicon-user") " My Profile" )) 
			 (:li :align "center" (:a :href "dodlogout"  (:span :class "glyphicon glyphicon-off") " Logout "  ))))))))





(defmacro standard-page ( (&key title) &body body)
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
		 (:link :href "css/style.css" :rel "stylesheet")
		 (:link :href "css/bootstrap.min.css" :rel "stylesheet")
		 (:link :href "css/bootstrap-theme.min.css" :rel "stylesheet")
 		 (:link :href "css/theme.css" :rel "stylesheet")
		 (:link :href "https://code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css" :rel "stylesheet")
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "https://code.jquery.com/ui/1.12.0/jquery-ui.min.js")
		 (:script :src "js/spin.min.js")
		 ) ;; Header completes here.
	     (:body
	      (:div :id "dod-main-container"
		    (:a :href "#" :class "scrollup" :style "display: none;") 
		    (:div :id "dod-error" (:h2 "Error..."))
		 (:div :id "busy-indicator")
		 (if (is-dod-session-valid?) (navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		     (:div :id "header"	; DOD System header
			 ,@body))	;container div close
		 
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js")
		 (:script :src "js/dod.js"))))))
   







(defmacro test-standard-page ((&key title) &body body)
  `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"
	    :xml\:lang "en" 
	    :lang "en"
	    (:head 
	     (:meta :http-equiv "Content-Type" 
		    :content    "text/html;charset=utf-8")
	     (:meta :name "viewport" :content "width=device-width, initial-scale=1")
	     (:meta :name "description" :content "")
	     (:meta :name "author" :content "")
	     (:link :rel "icon" :href "favicon.ico")
	     (:title ,title )
	  
	     (:link :href "css/style.css" :rel "stylesheet")
	     (:link :href "css/bootstrap.min.css" :rel "stylesheet")
	     (:link :href "css/bootstrap-theme.min.css" :rel "stylesheet")
	     
	     );; Header completes here.
	    (:body 
		   (navigation-bar)
		   (:div :class "container theme-showcase" :role "main" 

			 (:div :id "header"	 ; DOD System header
			      
	 
			       (:table :class "table" 
				       (:tr (:th "Tenant") (:th "Company") (:th "User"))
				       (:tr (:td  :height "12px" "000")
					    (:td  :height "12px" "test comapny")
					    (:td  :height "12px" "test username")))
		   

			    					 
			       ,@body))	;container div close
		   ;; bootstrap core javascript
		   (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js")
	
		   (:script :src "js/bootstrap.min.js")))))

(defun dod-controller-dbreset-page () 
  :documentation "No longer used now" 
(standard-page (:title "Restart Higirisehub.com")
  (:div :class "row"
	(:div :class "col-sm-12 col-md-12 col-lg-12"
	      (:form :id "restartsiteform" :method "POST" :action "dbresetaction"
		     (:div :class "form-group"
			   (:input :class "form-control" :name "password" :placeholder "password"  :type "password"))
		      (:div :class "form-group"
			    (:input :type "submit" :name "submit" :class "btn btn-primary" :value "Go...      ")))))))




(defun dod-controller-dbreset-action ()
  :documentation "No longer used now" 
  (let ((pass (hunchentoot:parameter "password")))
    (if (equal (encrypt  pass "highrisehub.com") *sitepass*)
       (progn  (stop-das) 
	      (start-das) 
	      (standard-page (:title "Restart Highrisehub.com")
		(:h3 "DB Reset successful"))))))



(defun company-search-html ()
(cl-who:with-html-output (*standard-output* nil)
	(:div :class "row"
	      (:div :id "custom-search-input"
		    (:div :class "input-group col-xs-12 col-sm-6 col-md-6 col-lg-6"
			  (:form :id "theForm" :action "dodsyssearchtenantaction" :OnSubmit "return false;" 
				 (:input :type "text" :class "  search-query form-control" :id "livesearch" :name "livesearch" :placeholder "Search for an Apartment/Group"))
			  (:span :class "input-group-btn" (:<button :class "btn btn-danger" :type "button" 
								(:span :class " glyphicon glyphicon-search"))))))))
	     




	
(defun com-hhub-transaction-create-company (&optional id)
  (let* ((company (if id (select-company-by-id id)))
	 (cmpname (if company (slot-value company 'name)))
	 (cmpaddress (if company(slot-value company 'address)))
	 (cmpcity (if company (slot-value company 'city)))
	 (cmpstate (if company (slot-value company 'state))) 
	 (cmpzipcode (if company (slot-value company 'zipcode))))
    (with-hhub-transaction "com-hhub-transaction-create-company" 
    	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		      (:form :class "form-addcompany" :role "form" :method "POST" :action "company-added" 
			     (if company (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit Group")
			    (:div :class "form-group"
				  (:input :class "form-control" :name "cmpname" :maxlength "30"  :value cmpname :placeholder "Enter Group/Apartment Name ( max 30 characters) " :type "text" ))
			    (:div :class "form-group"
				  (:label :for "cmpaddress")
				  (:textarea :class "form-control" :name "cmpaddress"  :placeholder "Enter Group/Apartment Address ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str cmpaddress) ))
			    (:div :class "form-group" :id "charcount")
			    (:div :class "form-group"
				  (:input :class "form-control" :type "text" :value cmpcity :placeholder "City"  :name "cmpcity" ))
			    (:div :class "form-group"
				  (:input :class "form-control" :type "text" :value cmpstate :placeholder "State"  :name "cmpstate" ))
			    (:div :class "form-group"
				  (:input :class "form-control" :type "text" :value "INDIA" :readonly "true"  :name "cmpcountry" ))
			    (:div :class "form-group"
				  (:input :class "form-control" :type "text" :maxlength "6" :value cmpzipcode :placeholder "Pincode" :name "cmpzipcode" ))
			    
			    (:div :class "form-group"
				  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))


(defun dod-controller-company-search-for-sys-action ()
  (let*  ((qrystr (hunchentoot:parameter "livesearch"))
	  (company-list (if (not (equal "" qrystr)) (select-companies-by-name qrystr))))
    (display-as-tiles company-list 'company-card )))

(defun dod-controller-abac-security ()
  (if (is-dod-session-valid?) 
      (let ((policies (get-auth-policies (get-login-tenant-id))))
	(standard-page (:title "Welcome to Highrisehub")
	  (:div :class "row" 
		(:div :class "col-xs-6" 
		      (:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#addpolicy-modal" "Add New Policy")
		      (:a :class "btn btn-primary" :role "button" :href "/hhub/listattributes"  " Attributes  ")
		      (:a :class "btn btn-primary" :role "button" :href "/hhub/listbusobjects"  " Business Objects  ")
		      (:a :class "btn btn-primary" :role "button" :href "/hhub/listbustrans"  " Transactions  ")))
	  (:hr)
	    (:div :class "row"
	      (:div :class "col-md-12" (:h4 "Business Policies")))
	  (str (display-as-table (list "Name" "Description" "Policy Function" "Action")  policies 'policy-card))
	  (modal-dialog "addpolicy-modal" "Add/Edit Policy" (com-hhub-transaction-policy-create))))
      (hunchentoot:redirect "/hhub/opr-login.html")))


(defun dod-controller-index () 
  (if (is-dod-session-valid?)
   (let (( companies (list-dod-companies)))
      (standard-page (:title "Welcome to Highrisehub.")
	(:div :class "container"
	(:div :id "row"
	      (:div :id "col-xs-6" 
	(:h3 "Welcome " (str (format nil "~A" (get-login-user-name))))))
	  (company-search-html)
	(:div :id "row"
	      (:div :id "col-xs-6"
		  ;  (:a :class "btn btn-primary" :role "button" :href "new-company" :data-toggle "modal" :data-target "#editcompany-modal" (:span :class "glyphicon glyphicon-shopping-plus") " Add New Group  ")
	       (:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#editcompany-modal" "Add New Group"))
	      (:div :id "col-xs-6" :align "right" 
		    (:span :class "badge" (str (format nil "~A" (length companies))))))
	(:hr)
	(modal-dialog "editcompany-modal" "Add/Edit Group" (com-hhub-transaction-create-company))
   	(str (display-as-tiles companies 'company-card )))))
   (hunchentoot:redirect "/hhub/opr-login.html")))
  
(setq *logged-in-users* (make-hash-table :test 'equal))

(defun dod-controller-list-busobjs () 
:documentation "List all the business objects"
(if (is-dod-session-valid?)
(let ((busobjs (select-bus-object-by-company (get-login-company))))
(standard-page (:title "Business Objects ...")
	(:div :class "row"
	      (:div :class "col-md-12" (:h4 "Business Objects")))
  (str (display-as-table (list "Name")  busobjs 'busobj-card))
    (:h4 "Note: To add new business objects to the system, follow these steps.")
    (:h4 "In the Lisp REPL call the function, (create-bus-object)")))
(hunchentoot:redirect "/hhub/opr-login.html")))


(defun dod-controller-list-bustrans ()
:documentation "List all the business transactions" 
(if (is-dod-session-valid?)
    (let ((bustrans (select-bus-trans-by-company (get-login-company))))
      (standard-page (:title "Business Transactions...")
	(:div :class "row"
	 (:div :class "col-md-12" 
	  (:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#addtransaction-modal" "Add New Transaction"))
	   (:div :class "col-md-12" 
	    (:div :class "col-md-12" (:h4 "Business Transactions"))))
	(str (display-as-table (list "Name" "URI" "Function" "Action")  bustrans 'bustrans-card))
	(modal-dialog "addtransaction-modal" "Add/Edit Transaction" (new-transaction-html))))
(hunchentoot:redirect "/hhub/opr-login.html")))


(defun dod-controller-list-attrs ()
:documentation "This function lists the attributes used in policy making"
    (if (is-dod-session-valid?)
	(let ((lstattributes (select-auth-attrs-by-company (get-login-company))))
(standard-page (:title "attributes ...")
  
  (:div :class "row"
	(:div :class "col-md-12" (:h4 "Attributes"))
	(:div :class "col-md-12" 
	      (:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#addattribute-modal" "Add New Attribute")))
  (:hr)		       
  
  (str (display-as-table (list "Name" "Description" "Function" "Type" )  lstattributes 'attribute-card))
;  (ui-list-attributes lstattributes)
  (modal-dialog "addattribute-modal" "Add/Edit Attribute" (com-hhub-transaction-create-attribute))))
(hunchentoot:redirect "/hhub/opr-login.html")))

    


(defun dod-controller-loginpage ()
  (handler-case 
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (if (is-dod-session-valid?)
		  (hunchentoot:redirect "/hhub/dodindex")
		  ;else
		  (standard-page (:title "Welcome to Dairy ondemand")
		    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:div :class "account-wall"
				      (:h1 :class "text-center login-title"  "Login to Dairy Ondemand")
				      (:form :class "form-signin" :role "form" :method "POST" :action "dodlogin"
					     (:div :class "form-group"
						   (:input :class "form-control" :name "company" :placeholder "Company Name"  :type "text"))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "username" :placeholder "User name" :type "text"))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "password"  :placeholder "Password" :type "password"))
					     (:input :type "submit"  :class "btn btn-primary" :value "Login      "))))))))
	      (clsql:sql-database-data-error (condition)
					     (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
												      (stop-das) 
												      (start-das)
												      (hunchentoot:redirect "/hhub/opr-login.html"))))))





(defun dod-controller-login ()
  (let  ((uname (hunchentoot:parameter "username"))
	 (passwd (hunchentoot:parameter "password"))
	 (cname (hunchentoot:parameter "company")))
    
      (unless(and
	    ( or (null cname) (zerop (length cname)))
	    ( or (null uname) (zerop (length uname)))
	    ( or (null passwd) (zerop (length passwd))))
      (if (equal (dod-login :company-name cname :username uname :password passwd) NIL) (hunchentoot:redirect "/hhub/opr-login.html") (hunchentoot:redirect  "/hhub/dodindex")))))
   
  
   (defun dod-controller-logout ()
     (progn (dod-logout (get-login-user-name))
	    (hunchentoot:remove-session *current-user-session*)
	    (hunchentoot:redirect "/hhub/opr-login.html")))


(defun is-dod-session-valid? ()
 (if  (null (get-login-user-name)) NIL T))


(defun dod-login (&key company-name username password)
  (let* ((login-user (car (clsql:select 'dod-users :where [and
				       [= [slot-value 'dod-users 'username] username]
				       [= [slot-value 'dod-users 'password] password]]
				      :caching nil :flatp t)))
	 (login-userid (slot-value login-user 'row-id))
	 (login-attribute-cart '())
	 (login-tenant-id (slot-value  (users-company login-user) 'row-id))
	 (login-company (slot-value login-user 'company))
	 (login-company-name (slot-value (users-company login-user) 'name)))

    (when (and(equal  login-company-name company-name)
	    login-user 
	      (null (hunchentoot:session-value :login-username)) ;; User should not be logged-in in the first place.
	      )  (progn (add-login-user username  login-user)
				      (setf *current-user-session* (hunchentoot:start-session))
				      (setf (hunchentoot:session-value :login-username) username)
				      (setf (hunchentoot:session-value :login-userid) login-userid)
				      (setf (hunchentoot:session-value :login-attribute-cart) login-attribute-cart)
				      (setf (hunchentoot:session-value :login-tenant-id) login-tenant-id)
				      (setf (hunchentoot:session-value :login-company-name) company-name)
				      (setf (hunchentoot:session-value :login-company) login-company))
		 
       	 )))


  
  


(defun get-tenant-id (company-name)
  ( car ( clsql:select [row-id] :from [dod-company] :where [= [slot-value 'dod-company 'name] company-name]
		       :flatp t)))

(defun get-tenant-name (company-id)
  ( car ( clsql:select [name] :from [dod-company] :where [= [slot-value 'dod-company 'row-id] company-id]
		       :flatp t)))
  

(defun get-login-user-object (username)
  (gethash username *logged-in-users*))


(defun is-user-already-login? (username)
(if (equal (gethash username *logged-in-users*) NIL ) NIL T))


(defun add-login-user(username object)
  (unless (is-user-already-login? username)
	   (setf (gethash username *logged-in-users*) object)))


(defun dod-logout (username)
  (remhash username *logged-in-users*))


(defun dod-controller-new-company () 
  (if (is-dod-session-valid?)
      (let* ((id (hunchentoot:parameter "id"))
	    (company (if id (select-company-by-id id)))
	    (cmpname (if company (slot-value company 'name)))
	     (cmpaddress (if company(slot-value company 'address)))
	     (cmpcity (if company (slot-value company 'city)))
	     (cmpstate (if company (slot-value company 'state))) 
	     (cmpzipcode (if company (slot-value company 'zipcode))))

    (standard-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
      (:div :class "row" 
	 (:div :class "col-sm-6 col-md-4 col-md-offset-4"
	       (:form :class "form-addcompany" :role "form" :method "POST" :action "company-added" 
		      (if company 
			  (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			  
			  
		      (:div :class "account-wall"
			    (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			    (:h1 :class "text-center login-title"  "Add/Edit Group")
			    (:div :class "form-group"
				  (:input :class "form-control" :name "cmpname" :value cmpname :placeholder "Enter Group/Apartment Name ( max 30 characters) " :type "text" ))
			    (:div :class "form-group"
				  (:label :for "cmpaddress")
				  (:textarea :class "form-control" :name "cmpaddress"  :placeholder "Enter Group/Apartment Address ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str cmpaddress) ))
			    (:div :class "form-group" :id "charcount")
			    (:div :class "form-group"
				   (:input :class "form-control" :type "text":value cmpcity :placeholder "City"  :name "cmpcity" ))
			    (:div :class "form-group"
				   (:input :class "form-control" :type "text" :value cmpstate :placeholder "State"  :name "cmpstate" ))
			    (:div :class "form-group"
				   (:input :class "form-control" :type "text" :value "INDIA" :readonly "true"  :name "cmpcountry" ))
			    (:div :class "form-group"
				  (:input :class "form-control" :type "text" :value cmpzipcode :placeholder "Pincode" :name "cmpzipcode" ))
			    
			    (:div :class "form-group"
				  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))
      (hunchentoot:redirect "/hhub/opr-login.html")))					    





(defun dod-controller-company-added ()
  (if (is-dod-session-valid?)
      (let*  ((id (hunchentoot:parameter "id"))
	     (company (if id (select-company-by-id id)))
	     (cmpname (hunchentoot:parameter "cmpname"))
	     (cmpaddress (hunchentoot:parameter "cmpaddress"))
	     (cmpcity (hunchentoot:parameter "cmpcity"))
	     (cmpstate (hunchentoot:parameter "cmpstate"))
	     (cmpcountry (hunchentoot:parameter "cmpcountry"))
	     (cmpzipcode (hunchentoot:parameter "cmpzipcode"))
	     (loginuser (get-login-userid)))
	  
    
	(unless(and  ( or (null cmpname) (zerop (length cmpname)))
		     ( or (null cmpaddress) (zerop (length cmpaddress)))
		     ( or (null cmpzipcode) (zerop (length cmpzipcode))))
	  (if company 
	      (progn (setf (slot-value company 'name) cmpname)
		     (setf (slot-value company 'address) cmpaddress)
		     (setf (slot-value company 'city) cmpcity)
		     (setf (slot-value company 'state) cmpstate)
		     (setf (slot-value company 'zipcode) cmpzipcode)
		     (update-company company))
					;else
	      (new-dod-company cmpname cmpaddress cmpcity cmpstate cmpcountry cmpzipcode loginuser loginuser)))
	(hunchentoot:redirect  "/hhub/dodindex"))
      (hunchentoot:redirect "/hhub/opr-login.html")))


(setq hunchentoot:*dispatch-table*
    (list
	;***************** OPERATOR RELATED ********************
     
	(hunchentoot:create-regex-dispatcher "^/hhub/dodindex" 'dod-controller-index)
	(hunchentoot:create-regex-dispatcher "^/hhub/dasabacsecurity" 'dod-controller-abac-security)
	(hunchentoot:create-regex-dispatcher "^/hhub/company-added" 'dod-controller-company-added)
	(hunchentoot:create-regex-dispatcher "^/hhub/new-company" 'dod-controller-new-company)
	(hunchentoot:create-regex-dispatcher "^/hhub/editcompany" 'dod-controller-new-company)
	(hunchentoot:create-regex-dispatcher "^/hhub/opr-login.html" 'dod-controller-loginpage)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodlogin" 'dod-controller-login)
	(hunchentoot:create-regex-dispatcher "^/hhub/new-customer" 'dod-controller-new-customer)
	(hunchentoot:create-regex-dispatcher "^/hhub/delcustomer" 'dod-controller-delete-customer)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-customers" 'dod-controller-list-customers)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-orders" 'dod-controller-list-orders)
	(hunchentoot:create-regex-dispatcher "^/hhub/orderdetails" 'dod-controller-list-order-details)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-vendors" 'dod-controller-list-vendors)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-orderprefs" 'dod-controller-list-orderprefs)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-products" 'dod-controller-list-products)
	(hunchentoot:create-regex-dispatcher "^/hhub/user-added" 'dod-controller-user-added)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodlogout" 'dod-controller-logout)
	(hunchentoot:create-regex-dispatcher "^/hhub/delcomp" 'dod-controller-delete-company)
	(hunchentoot:create-regex-dispatcher "^/hhub/journal-entry-added" 'dod-controller-journal-entry-added)
        (hunchentoot:create-regex-dispatcher "^/hhub/account-added" 'dod-controller-account-added)
	(hunchentoot:create-regex-dispatcher "^/hhub/new-account" 'dod-controller-new-account)
	(hunchentoot:create-regex-dispatcher "^/hhub/delaccount" 'dod-controller-delete-account)
	(hunchentoot:create-regex-dispatcher "^/hhub/deljournal-entry" 'dod-controller-delete-journal-entry)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-journal-entries" 'dod-controller-list-journal-entries2)
        (hunchentoot:create-regex-dispatcher "^/hhub/new-journal-entry" 'dod-controller-new-journal-entry)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-users" 'dod-controller-list-users)
	(hunchentoot:create-regex-dispatcher "^/hhub/list-accounts" 'dod-controller-list-accounts)
	(hunchentoot:create-regex-dispatcher "^/hhub/listattributes" 'dod-controller-list-attrs)
	(hunchentoot:create-regex-dispatcher "^/hhub/dbreset.html" 'dod-controller-dbreset-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dbresetaction" 'dod-controller-dbreset-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodsyssearchtenantaction" 'dod-controller-company-search-for-sys-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dasaddattribute" 'dod-controller-add-attribute)
	(hunchentoot:create-regex-dispatcher "^/hhub/listbusobjects" 'dod-controller-list-busobjs)
	(hunchentoot:create-regex-dispatcher "^/hhub/listbustrans" 'dod-controller-list-bustrans)
	(hunchentoot:create-regex-dispatcher "^/hhub/dasaddpolicyaction" 'dod-controller-add-policy-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dasaddtransactionaction" 'dod-controller-add-transaction-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dassearchpolicies" 'dod-controller-policy-search-action )
	(hunchentoot:create-regex-dispatcher "^/hhub/transtopolicylinkpage" 'dod-controller-trans-to-policy-link-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/transtopolicylinkaction" 'dod-controller-trans-to-policy-link-action)
	
		
	
	;************CUSTOMER LOGIN RELATED ********************
	(hunchentoot:create-regex-dispatcher  "^/hhub/customer-login.html" 'dod-controller-customer-loginpage)
	(hunchentoot:create-regex-dispatcher  "^/hhub/dodcustlogin"  'dod-controller-cust-login)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustindex" 'dod-controller-cust-index)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustlogout" 'dod-controller-customer-logout)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorders" 'dod-controller-my-orders)
	(hunchentoot:create-regex-dispatcher "^/hhub/delorder" 'dod-controller-del-order)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustordsuccess" 'dod-controller-cust-ordersuccess)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustorderprefs" 'dod-controller-my-orderprefs)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorderdetails" 'dod-controller-my-orderdetails)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustaddorderpref" 'dod-controller-cust-add-orderpref-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustaddopfaction" 'dod-controller-cust-add-orderpref-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/delopref" 'dod-controller-del-opref)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorderaddpage" 'dod-controller-cust-add-order-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorderaddaction" 'com-hhub-transaction-create-order)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorderdetailaddpage" 'dod-controller-cust-add-order-detail-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodmyorderdetailaddaction" 'dod-controller-cust-add-order-detail-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustaddtocart" 'dod-controller-cust-add-to-cart)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustupdatecart" 'dod-controller-cust-update-cart)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustshopcart" 'dod-controller-cust-show-shopcart)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustremshctitem" 'dod-controller-remove-shopcart-item )
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustplaceorder" 'dod-controller-cust-placeorder )
	(hunchentoot:create-regex-dispatcher "^/hhub/list-companies" 'dod-controller-list-companies)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendordetails" 'dod-controller-vendor-details)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodprddetailsforcust" 'dod-controller-prd-details-for-customer)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodprodsubscribe" 'dod-controller-cust-add-orderpref-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodproducts" 'dod-controller-customer-products)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodsearchproducts" 'dod-controller-search-products)
	(hunchentoot:create-regex-dispatcher "^/hhub/doddelcustorditem" 'dod-controller-del-cust-ord-item)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustlowbalanceshopcart" 'dod-controller-low-wallet-balance-for-shopcart)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustlowbalanceorderitems" 'dod-controller-low-wallet-balance-for-orderitems)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustwallet" 'dod-controller-cust-wallet-display)
	(hunchentoot:create-regex-dispatcher "^/hhub/custsignup1action" 'dod-controller-cust-register-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustregisteraction" 'dod-controller-cust-register-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/duplicate-cust.html" 'dod-controller-duplicate-customer)
	(hunchentoot:create-regex-dispatcher "^/hhub/custsignup1.html" 'dod-controller-company-search-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/companysearchaction" 'dod-controller-company-search-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/createcustwallet" 'dod-controller-create-cust-wallet)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustprofile" 'dod-controller-customer-profile)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustorditemedit" 'dod-controller-order-item-edit )
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustorderscal" 'dod-controller-cust-orders-calendar) 
	(hunchentoot:create-regex-dispatcher "^/hhub/dodcustordersdata" 'dod-controller-cust-order-data-json)
	(hunchentoot:create-regex-dispatcher "^/hhub/dasmakepaymentrequest" 'dod-controller-make-payment-request-html)
	(hunchentoot:create-regex-dispatcher "^/hhub/custpaymentsuccess" 'dod-controller-customer-payment-successful-page )
	(hunchentoot:create-regex-dispatcher "^/hhub/custpaymentfailure" 'dod-controller-customer-payment-failure-page )
	(hunchentoot:create-regex-dispatcher "^/hhub/custpaymentcancel" 'dod-controller-customer-payment-cancel-page )
	

;************VENDOR RELATED ********************
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenddeactivateprod" 'dod-controller-vendor-deactivate-product)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendactivateprod" 'dod-controller-vendor-activate-product)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendcopyprod" 'dod-controller-vendor-copy-product)
	(hunchentoot:create-regex-dispatcher "^/hhub/vendor-login.html" 'dod-controller-vendor-loginpage)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendsearchtenantpage" 'dod-controller-cmpsearch-for-vend-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodrefreshpendingorders" 'dod-controller-refresh-pending-orders)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendrevenue" 'dod-controller-vendor-revenue)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenddelprod" 'dod-controller-vendor-delete-product)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendsearchtenantaction" 'dod-controller-cmpsearch-for-vend-action )
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendaddtenantaction" 'dod-controller-vend-add-tenant-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendortenants" 'dod-controller-display-vendor-tenants)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendswitchtenant" 'dod-controller-vendor-switch-tenant)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendlogin" 'dod-controller-vend-login)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendloginpage" 'dod-controller-vendor-loginpage)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendindex" 'dod-controller-vend-index)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendlogout" 'dod-controller-vendor-logout)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenexpexl" 'dod-controller-ven-expexl)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenproducts" 'dod-controller-vendor-products)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodprddetailsforvendor" 'dod-controller-prd-details-for-vendor)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenordfulfilled" 'dod-controller-ven-order-fulfilled)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendprofile" 'dod-controller-vend-profile)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodsearchcustwalletpage" 'dod-controller-vendor-search-cust-wallet-page )
	(hunchentoot:create-regex-dispatcher "^/hhub/dodsearchcustwalletaction" 'dod-controller-vendor-search-cust-wallet-action )
	(hunchentoot:create-regex-dispatcher "^/hhub/dodupdatewalletbalance" 'dod-controller-update-wallet-balance)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvendororderdetails" 'dod-controller-vendor-orderdetails)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenaddprodpage" 'dod-controller-vendor-add-product-page)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenaddproductaction" 'dod-controller-vendor-add-product-action)
	(hunchentoot:create-regex-dispatcher "^/hhub/dodvenordcancel" 'dod-controller-vendor-order-cancel)
	))



