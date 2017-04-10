(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defvar *logged-in-users* nil)
(defvar *current-user-session* nil)


(defun copy-hash-table (hash-table)
  (let ((ht (make-hash-table 
             :test (hash-table-test hash-table)
             :rehash-size (hash-table-rehash-size hash-table)
             :rehash-threshold (hash-table-rehash-threshold hash-table)
             :size (hash-table-size hash-table))))
    (loop for key being each hash-key of hash-table
       using (hash-value value)
       do (setf (gethash key ht) value)
       finally (return ht))))


(defmacro navigation-bar ()
  `(cl-who:with-html-output (*standard-output* nil)
     (:div :class "navbar navbar-default navbar-inverse navbar-fixed-top"  
	   (:ul :class "nav navbar-nav"
		      (:li :class "active" (:a :href "/dodindex" "Home"))
		      (:li  (:a :href "/list-customers" "Customers"))
		      (:li  (:a :href "/list-vendors" "Vendors"))
		      (:li  (:a :href "/list-orders" "Orders"))
		      (:li  (:a :href "/list-orderprefs" "Order Preferences"))
     		      (:li  (:a :href "/list-products" "Products"))
		      (:li  (:a :href "/dodlogout" "Logout"))))))





(defmacro standard-page-handler ( &rest body)
  (if (is-dod-session-valid?)
      `(,@body)
      (hunchentoot:redirect "/login")))


(defmacro standard-page ((&key title) &body body)
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
	     (if (is-dod-session-valid?) (navigation-bar))
		   (:div :class "container theme-showcase" :role "main" 

			 (:div :id "header"	 ; DOD System header
			      
	 
			       (:table :class "table" 
				       (:tr (:th "Tenant") (:th "Company") (:th "User"))
				       (:tr (:td  :height "12px" (str (get-login-tenant-id)))
					    (:td  :height "12px" (str (get-current-login-company)))
					    (:td  :height "12px" (str (get-current-login-username)))))
		   

			    					 
			       ,@body))	;container div close
		   ;; bootstrap core javascript
		   (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js")
	
		   (:script :src "js/bootstrap.min.js")))))



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



(defun dod-controller-index () 
  (if (is-dod-session-valid?)
      (standard-page (:title "Welcome to Dairy Ondemand")

	(when (verify-superadmin)(htm (:p "Want to create a new company?" (:a :href "/new-company" "here"))
				      	(:p "List companies?" (:a :href "/list-companies" "here"))))

	(unless (verify-superadmin)
	  (htm 
	(:p "Want to create a new customer?" (:a :href "/new-customer" "here"))
	(:p "List Customers" (:a :href "/list-customers" "here"))
	)))
	(hunchentoot:redirect "/opr-login.html")))
  
(setq *logged-in-users* (make-hash-table :test 'equal))


(defun dod-controller-list-attrs ()
:documentation "This function lists the attributes used in policy making"
    (if (is-dod-session-valid?)
	(standard-page (:title "attributes ...")
    (let* ((company (hunchentoot:session-value :login-company))
      (lstattrcart (hunchentoot:session-value :login-attribute-cart))
      (lstattributes (select-auth-attrs-by-company company)))

(htm (:div :class "row"
	   (:div :class "col-md-12" :align "right"
		 (:a :class "btn btn-primary" :role "button" :href "/dodattrcart" (:span :class "glyphicon glyphicon-shopping-cart") " Attributes  " (:span :class "badge" (str (format nil " ~A " (length lstattrcart))) ))))
		    (:hr))		       
(ui-list-attributes lstattributes lstattrcart)))
(hunchentoot:redirect "/opr-login.html")))

    


(defun dod-controller-loginpage ()
  (standard-page (:title "Welcome to Dairy ondemand")
    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:div :class "account-wall"
		      (:h1 :class "text-center login-title"  "Login to Dairy Ondemand")
		      (:form :class "form-signin" :role "form" :method "POST" :action "/dodlogin"
			     (:div :class "form-group"
				   (:input :class "form-control" :name "company" :placeholder "Company Name"  :type "text"))
			     (:div :class "form-group"
				   (:input :class "form-control" :name "username" :placeholder "User name" :type "text"))
			     (:div :class "form-group"
				   (:input :class "form-control" :name "password"  :placeholder "Password" :type "password"))
			     (:input :type "submit"  :class "btn btn-primary" :value "Login      ")))))))





(defun dod-controller-login ()
  (let  ((uname (hunchentoot:parameter "username"))
	 (passwd (hunchentoot:parameter "password"))
	 (cname (hunchentoot:parameter "company")))
    
      (unless(and
	    ( or (null cname) (zerop (length cname)))
	    ( or (null uname) (zerop (length uname)))
	    ( or (null passwd) (zerop (length passwd))))
      (if (equal (dod-login :company-name cname :username uname :password passwd) NIL) (hunchentoot:redirect "/opr-login.html") (hunchentoot:redirect  "/dodindex")))))
   
  
   (defun dod-controller-logout ()
     (progn (dod-logout (get-current-login-username))
	    (hunchentoot:remove-session *current-user-session*)
	    (hunchentoot:redirect "/opr-login.html")))


(defun get-current-login-company ()
 ( hunchentoot:session-value :login-company))

(defun is-dod-session-valid? ()
 (if  (null (get-current-login-username)) NIL T))


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
      (standard-page (:title "Add a new company")
	(:h1 "Add a new company")
	(:form :action "/company-added" :method "post" 
	       (:p "Name: " 
		   (:input :type "text"  
			   :name "name" 
			   :class "txt"))
	       (:p "Address: " (:input :type "textarea"  
				       :name "address" 
				       :class "txtarea"))

	       (:p "City: " (:input :type "text"  
				       :name "city" 
				       ))
	       (:p "State: " (:input :type "text"  
				       :name "state" 
				       ))

	       (:p "Country: " (:input :type "text"  
				       :name "country" 
				       ))

	       (:p "Zipcode: " (:input :type "text"  
				       :name "zipcode" 
				       ))


	       

	       (:h3 "Create the Admin user")
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
					 :class "txt")))

					   
	       (:p (:input :type "submit" 
			   :value "Add" 
			   :class "btn"))))
      (hunchentoot:redirect "/login")))




(defun dod-controller-company-added ()
  (if (is-dod-session-valid?)
      (let  ((cname (hunchentoot:parameter "name"))
	     (caddress (hunchentoot:parameter "address"))
	     (city (hunchentoot:parameter "city"))
	     (state (hunchentoot:parameter "state"))
	     (country (hunchentoot:parameter "country"))
	     (zipcode (hunchentoot:parameter "zipcode"))
	     (name (hunchentoot:parameter "name"))
	     (username (hunchentoot:parameter "username"))
	     (password (hunchentoot:parameter "password"))
	     (email (hunchentoot:parameter "email"))
	     (loginuser (get-login-userid)))
    
	(unless(and  ( or (null cname) (zerop (length cname)))
		     ( or (null caddress) (zerop (length caddress)))
		     ( or (null name) (zerop (length name)))
 		      ( or (null username) (zerop (length username)))
		      ( or (null password) (zerop (length password)))
		      ( or (null email) (zerop (length email))))
	  (new-dod-company cname caddress city state country zipcode loginuser loginuser))
	;; By this time the new company is created.
	(let ((company (car (clsql:select 'dod-company :where [= [:name] cname] :caching nil :flatp t))))
	  (create-dod-user  name username password email (slot-value company 'row-id)))
                      	  
	(hunchentoot:redirect  "/dodindex"))
      (hunchentoot:redirect "/login")))


(setq hunchentoot:*dispatch-table*
    (list
	;***************** OPERATOR RELATED ********************
	(hunchentoot:create-regex-dispatcher "^/dodindex" 'dod-controller-index)
	(hunchentoot:create-regex-dispatcher "^/company-added" 'dod-controller-company-added)
	(hunchentoot:create-regex-dispatcher "^/new-company" 'dod-controller-new-company)
	(hunchentoot:create-regex-dispatcher "^/opr-login.html" 'dod-controller-loginpage)
	(hunchentoot:create-regex-dispatcher "^/dodlogin" 'dod-controller-login)
	(hunchentoot:create-regex-dispatcher "^/new-customer" 'dod-controller-new-customer)
	(hunchentoot:create-regex-dispatcher "^/delcustomer" 'dod-controller-delete-customer)
	(hunchentoot:create-regex-dispatcher "^/list-customers" 'dod-controller-list-customers)
	(hunchentoot:create-regex-dispatcher "^/list-orders" 'dod-controller-list-orders)
	(hunchentoot:create-regex-dispatcher "^/orderdetails" 'dod-controller-list-order-details)
	(hunchentoot:create-regex-dispatcher "^/list-vendors" 'dod-controller-list-vendors)
	(hunchentoot:create-regex-dispatcher "^/list-orderprefs" 'dod-controller-list-orderprefs)
	(hunchentoot:create-regex-dispatcher "^/list-products" 'dod-controller-list-products)
	(hunchentoot:create-regex-dispatcher "^/user-added" 'dod-controller-user-added)
	(hunchentoot:create-regex-dispatcher "^/dodlogout" 'dod-controller-logout)
	(hunchentoot:create-regex-dispatcher "^/delcomp" 'dod-controller-delete-company)
	(hunchentoot:create-regex-dispatcher "^/journal-entry-added" 'dod-controller-journal-entry-added)
        (hunchentoot:create-regex-dispatcher "^/account-added" 'dod-controller-account-added)
	(hunchentoot:create-regex-dispatcher "^/new-account" 'dod-controller-new-account)
	(hunchentoot:create-regex-dispatcher "^/delaccount" 'dod-controller-delete-account)
	(hunchentoot:create-regex-dispatcher "^/deljournal-entry" 'dod-controller-delete-journal-entry)
	(hunchentoot:create-regex-dispatcher "^/list-journal-entries" 'dod-controller-list-journal-entries2)
        (hunchentoot:create-regex-dispatcher "^/new-journal-entry" 'dod-controller-new-journal-entry)
	(hunchentoot:create-regex-dispatcher "^/list-users" 'dod-controller-list-users)
	(hunchentoot:create-regex-dispatcher "^/list-accounts" 'dod-controller-list-accounts)
	(hunchentoot:create-regex-dispatcher "^/list-attributes" 'dod-controller-list-attrs)
	
	;************CUSTOMER LOGIN RELATED ********************
	(hunchentoot:create-regex-dispatcher "^/customer-login.html" 'dod-controller-customer-loginpage)
	(hunchentoot:create-regex-dispatcher "^/dodcustlogin" 'dod-controller-cust-login)
	(hunchentoot:create-regex-dispatcher "^/dodcustindex" 'dod-controller-cust-index)
	(hunchentoot:create-regex-dispatcher "^/dodcustlogout" 'dod-controller-customer-logout)
	(hunchentoot:create-regex-dispatcher "^/dodmyorders" 'dod-controller-my-orders)
	(hunchentoot:create-regex-dispatcher "^/delorder" 'dod-controller-del-order)
	(hunchentoot:create-regex-dispatcher "^/dodcustordsuccess" 'dod-controller-cust-ordersuccess)
	(hunchentoot:create-regex-dispatcher "^/dodcustorderprefs" 'dod-controller-my-orderprefs)
	(hunchentoot:create-regex-dispatcher "^/dodmyorderdetails" 'dod-controller-my-orderdetails)
	(hunchentoot:create-regex-dispatcher "^/dodcustaddorderpref" 'dod-controller-cust-add-orderpref-page)
	(hunchentoot:create-regex-dispatcher "^/dodcustaddopfaction" 'dod-controller-cust-add-orderpref-action)
	(hunchentoot:create-regex-dispatcher "^/delopref" 'dod-controller-del-opref)
	(hunchentoot:create-regex-dispatcher "^/dodmyorderaddpage" 'dod-controller-cust-add-order-page)
	(hunchentoot:create-regex-dispatcher "^/dodmyorderaddaction" 'dod-controller-cust-add-order-action)
	(hunchentoot:create-regex-dispatcher "^/dodmyorderdetailaddpage" 'dod-controller-cust-add-order-detail-page)
	(hunchentoot:create-regex-dispatcher "^/dodmyorderdetailaddaction" 'dod-controller-cust-add-order-detail-action)
	(hunchentoot:create-regex-dispatcher "^/dodcustaddtocart" 'dod-controller-cust-add-to-cart)
	(hunchentoot:create-regex-dispatcher "^/dodcustupdatecart" 'dod-controller-cust-update-cart)
	(hunchentoot:create-regex-dispatcher "^/dodcustshopcart" 'dod-controller-cust-show-shopcart)
	(hunchentoot:create-regex-dispatcher "^/dodcustremshctitem" 'dod-controller-remove-shopcart-item )
	(hunchentoot:create-regex-dispatcher "^/dodcustplaceorder" 'dod-controller-cust-placeorder )
	(hunchentoot:create-regex-dispatcher "^/list-companies" 'dod-controller-list-companies)
	(hunchentoot:create-regex-dispatcher "^/dodvendordetails" 'dod-controller-vendor-details)
	(hunchentoot:create-regex-dispatcher "^/dodprddetails" 'dod-controller-prd-details)
	(hunchentoot:create-regex-dispatcher "^/dodprodsubscribe" 'dod-controller-cust-add-orderpref-page)
	(hunchentoot:create-regex-dispatcher "^/dodproducts" 'dod-controller-customer-products)
	(hunchentoot:create-regex-dispatcher "^/dodsearchproducts" 'dod-controller-search-products)
	(hunchentoot:create-regex-dispatcher "^/doddelcustorditem" 'dod-controller-del-cust-ord-item)
	(hunchentoot:create-regex-dispatcher "^/dodcustlowbalance" 'dod-controller-low-wallet-balance)
	(hunchentoot:create-regex-dispatcher "^/dodcustwallet" 'dod-controller-cust-wallet-display)

;************VENDOR RELATED ********************
	(hunchentoot:create-regex-dispatcher "^/vendor-login.html" 'dod-controller-vendor-loginpage)
	(hunchentoot:create-regex-dispatcher "^/dodvendlogin" 'dod-controller-vend-login)
	(hunchentoot:create-regex-dispatcher "^/dodvendindex" 'dod-controller-vend-index)
	(hunchentoot:create-regex-dispatcher "^/dodvendlogout" 'dod-controller-vendor-logout)
	(hunchentoot:create-regex-dispatcher "^/dodvenexpexl" 'dod-controller-ven-expexl)
	(hunchentoot:create-regex-dispatcher "^/dodvenordfulfilled" 'dod-controller-ven-order-fulfilled)
	(hunchentoot:create-regex-dispatcher "^/dodvendororderdetails" 'dod-controller-vendor-orderdetails)
	))



