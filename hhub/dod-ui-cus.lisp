(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun get-login-customer ()
    :documentation "Get the login session for customer"
    (hunchentoot:session-value :login-customer ))

(defun get-login-cust-company ()
    :documentation "Get the login customer company."
    ( hunchentoot:session-value :login-customer-company))

(defun is-dod-cust-session-valid? ()
    :documentation "Checks whether the current login session is valid or not."
	(if (null (get-login-cust-name)) NIL T))

;    (handler-case 
	;expression
;	(if (not (null (get-login-cust-name)))
;	       (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T))	      
        ; Handle this condition
   
 ;     (clsql:sql-database-data-error (condition)
;	  (if (equal (clsql:sql-error-error-id condition) 2006 ) (clsql:reconnect :database *dod-db-instance*)))
;      (clsql:sql-fatal-error (errorinst) (if (equal (clsql:sql-error-database-message errorinst) "Database is closed.") 
;					     (progn (clsql:stop-sql-recording :type :both)
;					            (clsql:disconnect) 
;						    (crm-db-connect :servername *crm-database-server* :strdb *crm-database-name* :strusr *crm-database-user*  :strpwd *crm-database-password* :strdbtype :mysql))))))
      

(defun get-login-cust-name ()
    :documentation "Gets the name of the currently logged in customer"
    (hunchentoot:session-value :login-customer-name))

(defun dod-controller-customer-logout ()
    :documentation "Customer logout."
    (progn (hunchentoot:remove-session *current-customer-session*)
	(hunchentoot:redirect "/index.html")))

(defun dod-controller-list-customers ()
    :documentation "A callback function which prints a list of customers in HTML format."
    (if (is-dod-session-valid?)
	(let (( dodcustomers (list-cust-profiles (get-login-company)))
		 (header (list "Name" "Address" "Phone"  "Action")))
	    (if dodcustomers (ui-list-customers header dodcustomers) "No customers"))
	(hunchentoot:redirect "/hhub/opr-login.html")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DAS-CUST-PAGE-WITH-TILES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun das-cust-page-with-tiles (displayfunc pagetitle &rest args)
:documentation "This is a standard higher order function which takes the display function as argument and displays the information"
(if (is-dod-cust-session-valid?)
    (standard-customer-page (:title pagetitle) 
    (apply displayfunc args))
(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-my-orderprefs ()
 :documentation "A callback function which prints daily order preferences for a logged in customer in HTML format." 
 (let (( dodorderprefs (hunchentoot:session-value :login-cusopf-cache))
	(header (list   "Product"  "Day"  "Qty" "Qty Per Unit" "Price"  "Actions")))
  (das-cust-page-with-tiles 'ui-list-cust-orderprefs "Customer Order Preferences" header dodorderprefs)))



(defun dod-controller-cust-wallet-display ()
:documentation "A callback function which displays the wallets for a customer" 
(let* ((company (hunchentoot:session-value :login-customer-company))
      (customer (hunchentoot:session-value :login-customer))
      (wallets (get-cust-wallets customer company))
       (header (list "Vendor" "Balance")))
(das-cust-page-with-tiles 'list-customer-wallets "Customer Wallets" header wallets)))



(defun wallet-card (wallet-instance custom-message)
    (let ((customer (get-customer wallet-instance))
	  
	  (balance (slot-value wallet-instance 'balance)) 
	  (lowbalancep (if (check-low-wallet-balance wallet-instance) T NIL)))

	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "wallet-box"
		(:div :class "row"
		      (:div :class "col-sm-6"  (:h3  (str (format nil "Customer: ~A " (slot-value customer 'name)))))
		(:div :class "col-sm-6"  (:h3  (str (format nil "Ph:  ~A " (slot-value customer 'phone))))))
		(:div :class "row"
		(if lowbalancep 
		   (htm  (:div :class "col-sm-6 " (:h4 (:span :class "label label-warning" (str (format nil "Rs ~$ - Low Balance. Please recharge the  wallet."  balance))))))
					   ;else
		   (htm (:div :class "col-sm-3"  (:h4 (:span :class "label label-info" (str (format nil "Balance: Rs. ~$"  balance))))))))
		(:div :class "row"
		(:form :class "cust-wallet-recharge-form" :method "POST" :action "dodsearchcustwalletaction"
				(:input :class "form-control" :name "phone" :type "hidden" :value (str (format nil "~A" (slot-value customer 'phone))))
				(:div :class "col-sm-3" (:div :class "form-group"
			      (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Recharge")))))
		(:div :class "row"
		      (:div :class "col-sm-6"  (:h3  (str (format nil " ~A " custom-message)))))))))
		



(defun list-customer-wallets (header wallets)
(cl-who:with-html-output (*standard-output* nil)
      (:h3 "My Wallets.")      
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) 
	      (:tbody
	       (mapcar (lambda (wallet)
			 (let ((vendor (slot-value wallet 'vendor))
			       (balance (slot-value wallet 'balance)))
			   (htm (:tr
				 (:td  :height "12px" (str (slot-value vendor  'name)))
				  (:td  :height "12px" (str (slot-value vendor  'phone)))
				 (:td :height "12px" (str (format nil "Rs. ~$" balance))))))) wallets)))))






(defun dod-controller-del-opref ()
    :documentation "Delete order preference"
    (if (is-dod-cust-session-valid?)
	(let ((ordpref-id (parse-integer (hunchentoot:parameter "id")))
		     (cust (hunchentoot:session-value :login-customer))
		 (company (hunchentoot:session-value :login-customer-company)))
	    (delete-opref (get-opref-by-id ordpref-id company))
	    (setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer cust))
	(hunchentoot:redirect "/hhub/dodcustorderprefs"))
					;else
	(hunchentoot:redirect "/hhub/customer-login.html")))

(defun dod-controller-my-orders ()
    :documentation "A callback function which prints orders for a logged in customer in HTML format."
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "List DOD Customer orders")   
	(let (( dodorders (hunchentoot:session-value :login-cusord-cache))
		     (header (list  "Order No" "Order Date" "Request Date"  "Actions")))
	    (if dodorders (ui-list-customer-orders header dodorders) "No orders")))
	(hunchentoot:redirect "/hhub/customer-login.html")))

(defun dod-controller-del-order()
    (if (is-dod-cust-session-valid?)
	    (let ((order-id (parse-integer (hunchentoot:parameter "id")))
		     (cust (hunchentoot:session-value :login-customer))
		     (company (hunchentoot:session-value :login-customer-company)))
		(delete-order (get-order-by-id order-id company))
		(setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
		(hunchentoot:redirect "/hhub/dodmyorders"))
					;else
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-vendor-details ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Vendor Details")
	    (let ((vendor (select-vendor-by-id  (hunchentoot:parameter "id") (hunchentoot:session-value :login-customer-company))))
		(vendor-details-card vendor)))
	(hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-del-cust-ord-item ()
  (if (is-dod-cust-session-valid?)
      (let* ((order-id (parse-integer (hunchentoot:parameter "ord")))
	    (redirect-url (format nil "/hhub/dodmyorderdetails?id=~A" order-id))
	    (item-id (parse-integer (hunchentoot:parameter "id")))
	    (company (hunchentoot:session-value :login-customer-company)))

	(delete-order-details (list item-id) company)
	(hunchentoot:redirect redirect-url))
      ;else
      (hunchentoot:redirect "/hhub/customer-login.html")))
	    

	    

(defun dod-controller-my-orderdetails ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "List DOD Customer orders")   
	    (let* (( dodorder (get-order-by-id (hunchentoot:parameter "id") (get-login-cust-company)))
		      (header (list "Product" "Product Qty" "Unit Price"  "Sub-total" "Status" "Action"))
		      (odtlst (get-order-items dodorder) )
      		      (total   (reduce #'+  (mapcar (lambda (odt)
			(* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst))))
		(display-order-header dodorder) 
		(if odtlst (ui-list-cust-orderdetails header odtlst) "No order details")
					    (htm(:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total)))))))
		))
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun ui-list-customers (header data)
    (standard-page (:title "List DOD Customers")
	(:h3 "Customers") 
	(:table :class "table table-striped"  (:thead (:tr
							  (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
														       (mapcar (lambda (customer)
																   (htm (:tr (:td  :height "12px" (str (slot-value customer 'name)))
																	    (:td  :height "12px" (str (slot-value customer 'address)))
																	    (:td  :height "12px" (str (slot-value customer 'phone)))
																    (:td :height "12px" (:a :href  (format nil  "delcustomer?id=~A" (slot-value customer 'row-id)):onclick "return false"  "Delete"))))) data)))))
									  


(defun dod-controller-search-products ()
(let* ((search-clause (hunchentoot:parameter "search-clause"))
      (products (search-products search-clause (hunchentoot:session-value :login-customer-company)))
      (shoppingcart (hunchentoot:session-value :login-shopping-cart)))
(das-cust-page-with-tiles 'ui-list-customer-products "Search results..." products shoppingcart)))





(defmacro customer-navigation-bar ()
    :documentation "This macro returns the html text for generating a navigation bar using bootstrap."
    `(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-inverse  navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "HighriseHub" (:img :style "width: 30px; height: 30px;" :src "resources/demand&supply.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/hhub/dodcustindex" (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li :align "center" (:a :href "dodcustorderprefs" "My Subscriptions"))
			 (:li :align "center" (:a :href "dodmyorders" "My Orders"))
			 (:li :align "center" (:a :href "dodcustwallet" (:i :class "fa fa-google-wallet" :style "color:white") ))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     (:ul :class "nav navbar-nav navbar-right"
			 
			 
			 (:li :align "center" (:a :href "https://goo.gl/forms/XaZdzF30Z6K43gQm2" "Feedback" ))
			 (:li :align "center" (:a :href "https://goo.gl/forms/SGizZXYwXDUiTgVY2" (:span :class "glyphicon glyphicon-bug") "Bug" ))
	;(:li :align "center" (:a :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart " (:span :class "badge" (str (format nil " ~A " (length (hunchentoot:session-value :login-shopping-cart)))) )))
			 (:li :align "center" (:a :href "dodcustlogout" (:span :class "glyphicon glyphicon-off") " Logout "  ))))))))
    



(defmacro standard-customer-page ((&key title) &body body)
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
		 (:link :href "https://code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css" :rel "stylesheet")
		 (:link :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" :rel "stylesheet")
		 (:link :href "css/theme.css" :rel "stylesheet")
		
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "https://code.jquery.com/ui/1.12.0/jquery-ui.min.js")
		 (:script :src "js/spin.min.js")
		 (:script :src "https://www.google.com/recaptcha/api.js")
		 ) ;; Header completes here.
	     (:body
		 (:div :id "dod-main-container"
		     (:a :href "#" :class "scrollup" :style "display: none;") 
		 (:div :id "dod-error" (:h2 "Error..."))
		 (:div :id "busy-indicator")
		 (if (is-dod-cust-session-valid?) (customer-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		     (:div :id "header"	; DOD System header
			 ,@body))	;container div close
		 ;; Rangeslider
		
		
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js")
		 (:script :src "js/dod.js"))))))


;**********************************************************************************
;***************** CUSTOMER LOGIN RELATED FUNCTIONS ******************************

(defun dod-controller-cust-apt-no ()
 (let ((cname (hunchentoot:parameter "cname")))
   (standard-customer-page (:title "Welcome to DAS Platform - Your Demand and Supply destination.")
     (:form :class "form-custresister" :role "form" :method "POST" :action "dodcustregisteraction"
	    (:div :class "row" 
		  (:div :class "col-lg-6 col-md-6 col-sm-6"
			(:div :class "form-group"
			      (:input :class "form-control" :name "address" :placeholder "Apartment No (Required)" :type "text" ))
			(:div :class "form-group"
			      (:input :class "form-control" :name "tenant-name" :value (format nil "~A" cname) :type "text" :readonly T ))))))))

			


(defun dod-controller-cust-register-page ()
  (let ((cname (hunchentoot:parameter "cname")))
   
    (standard-customer-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
      	(:form :class "form-custregister" :role "form" :method "POST" :action "dodcustregisteraction"
	   (:div :class "row"
			(:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
				(:h1 :class "text-center login-title"  "New Registration to DAS")
				(:hr)) 
	       (:div :class "row" 
	    (:div :class "col-lg-6 col-md-6 col-sm-6"
		  (:div :class "form-group"
			(:input :class "form-control" :name "tenant-name" :value (format nil "~A" cname) :type "text" :readonly T ))
		 
		   (:div  :class "form-group" (:label :for "reg-type" "Register as:" )
				    (customer-vendor-dropdown))
			   
		  (:div :class "form-group"
			(:input :class "form-control" :name "name" :placeholder "Full Name (Required)" :type "text" ))
		  (:div :class "form-group"
			(:input :class "form-control" :name "address" :placeholder "Address (Required)" :type "text" ))
		  (:div :class "form-group"
			(:input :class "form-control" :name "email" :placeholder "Email (Required)" :type "text" ))
		  
		  (:hr))
	    
	    (:div :class "col-lg-6 col-md-6 col-sm-6"     
		  
		  
					; (:label :for "tenant-id" (str "Group/Apartment"))
					; (company-dropdown "tenant-id" (list-dod-companies)) )
		  (:div :class "form-group"
			(:input :class "form-control" :name "phone" :placeholder "Your Mobile Number (Required)" :type "text" ))
		  
		  (:div :class "form-group"
			(:input :class "form-control" :name "password" :placeholder "Password" :type "password" ))
		  (:div :class "form-group"
			(:input :class "form-control" :name "confirmpass" :placeholder "Confirm Password" :type "password" ))
		  (:div :class "form-group"
			(:div :class "g-recaptcha" :data-sitekey "6LeiXSQUAAAAAO-qh28CcnBFva6cQ68PCfxiMC0V")
			(:div :class "form-group"
			      (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))
	        )))))

(defun check&encrypt (password confirmpass salt)
 (when 
	 (and (or  password  (length password)) 
	      (or  confirmpass (length confirmpass))
	      (equal password confirmpass))
 
       (encrypt password salt)))


(defun dod-controller-cust-register-action ()
(let* ((captcha-resp (hunchentoot:parameter "g-recaptcha-response"))
       (reg-type (hunchentoot:parameter "reg-type"))
       (paramname (list "secret" "response" ) ) 
       (paramvalue (list "6LeiXSQUAAAAAFDP0jgtajXXvrOplfkMR9rWnFdO" captcha-resp))
       (param-alist (pairlis paramname paramvalue ))
       (json-response (json:decode-json-from-string  (map 'string 'code-char(drakma:http-request "https://www.google.com/recaptcha/api/siteverify"
                       :method :POST
                       :parameters param-alist  ))))
       (name (hunchentoot:parameter "name"))
       (email (hunchentoot:parameter "email"))
       (address (hunchentoot:parameter "address"))
       (phone (hunchentoot:parameter "phone"))
       (password (hunchentoot:parameter "password"))
       (confirmpass (hunchentoot:parameter "confirmpass"))
       (salt-octet (secure-random:bytes 56 secure-random:*generator*))
       (salt (flexi-streams:octets-to-string  salt-octet))
       (encryptedpass (check&encrypt password confirmpass salt))
       (tenant-name (hunchentoot:parameter "tenant-name"))
       (company (select-company-by-name tenant-name)))
  

  ; If we receive a True from the google verifysite then, add the user to the backend. 
  (cond
    
    ; Check for duplicate customer
    ((duplicate-customerp phone company) (hunchentoot:redirect "/hhub/duplicate-cust.html"))
    ; Check whether captcha has been solved 
    ((null (cdr (car json-response))) (dod-response-captcha-error)  )
    
    ; Check whether password was entered correctly 
    ((null encryptedpass) (dod-response-passwords-do-not-match-error)) 
    
    ((and encryptedpass (equal reg-type "VEN"))  
	 (progn 
       ; 1 
       (create-vendor name address phone email  encryptedpass salt nil nil nil company)
       ; 2
       
       (standard-customer-page (:title "Welcome to DAS platform")
	 (:h3 (str(format nil "Your record has been successfully added" )))
	 (:a :href "/hhub/customer-login.html" "Login now"))))
    
    ((and encryptedpass (equal reg-type "CUS"))  
	 (progn 
       ; 1 
       (create-customer name address phone email nil encryptedpass salt nil nil nil company)
       ; 2
       
       (standard-customer-page (:title "Welcome to DAS platform")
	 (:h3 (str(format nil "Your record has been successfully added" )))
	 (:a :href "/hhub/customer-login.html" "Login now")))))))

(defun dod-response-passwords-do-not-match-error ()
   (standard-customer-page (:title "Passwords do not match error.")
    (:h2 "Passwords do not match. Please try again. ")
    	(:a :class "btn btn-primary" :role "button" :onclick "goBack();"  :href "#" (:span :class "glyphicon glyphicon-arrow-left" "Go Back"))))


(defun dod-response-captcha-error ()
  (standard-customer-page (:title "Captcha response error from Google")
    (:h2 "Captcha response error from Google. Looks like some unusual activity. Please try again later")))


(defun dod-controller-duplicate-customer ()
     (standard-customer-page (:title "Welcome to DAS platform")
	 (:h3 (str(format nil "Customer record has already been created" )))
	 (:a :href "cust-register.html" "Register new customer")))
  
    
(defun dod-controller-company-search-action ()
  (let*  ((qrystr (hunchentoot:parameter "livesearch"))
	(company-list (if (not (equal "" qrystr)) (select-companies-by-name qrystr))))
    (ui-list-companies company-list)))



(defun ui-list-companies (company-list)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
  ; (standard-customer-page (:title "Welcome to DAS Platform")
    (if company-list 
	(htm (:div :class "row-fluid"	  (mapcar (lambda (cmp)
						      (htm 
						       (:form :method "POST" :action "custsignup1action" :id "custsignup1form" 
							      (:div :class "col-sm-4 col-lg-3 col-md-4"
								    (:div :class "form-group"
									  (:input :class "form-control" :name "cname" :type "hidden" :value (str (format nil "~A" (slot-value cmp 'name)))))
								    (:div :class "form-group"
									  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" (str (format nil "~A" (slot-value cmp 'name)))))))))  company-list)))
	;else
	(htm (:div :class "col-sm-12 col-md-12 col-lg-12"
	      (:h3 "No records found"))))))



(defun dod-controller-company-search-page ()
  (handler-case
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (standard-customer-page (:title "Welcome to DAS platform") 
		(:div :class "row"
		      (:h2 "Search Apartment/Group")
		      (:div :id "custom-search-input"
			    (:div :class "input-group col-md-12"
				  (:form :id "theForm" :action "companysearchaction" :OnSubmit "return false;" 
					 (:input :type "text" :class "  search-query form-control" :id "livesearch" :name "livesearch" :placeholder "Search for an Apartment/Group"))
				  (:span :class "input-group-btn" (:<button :class "btn btn-danger" :type "button" 
									    (:span :class " glyphicon glyphicon-search")))))
		      (:div :id "finalResult" ""))))
    (clsql:sql-database-data-error (condition)
      (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
							       (stop-das) 
							       (start-das)
							       (hunchentoot:redirect "/hhub/customer-login.html"))))))

 
			   


 


(defun dod-controller-customer-loginpage ()
  (handler-case 
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (if (is-dod-cust-session-valid?)
		  (hunchentoot:redirect "/hhub/dodcustindex")
		  (standard-customer-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:form :class "form-custsignin" :role "form" :method "POST" :action "dodcustlogin"
				       (:div :class "account-wall"
					     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
					     (:h1 :class "text-center login-title"  "Customer - Login to DAS")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "phone" :placeholder "Enter RMN. Ex: 9999999999" :type "text" ))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "password" :placeholder "password=demo" :type "password" ))
					     (:div :class "form-group"
						   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))
    (clsql:sql-database-data-error (condition)
      (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
							       (stop-das) 
							       (start-das)
							       (hunchentoot:redirect "/hhub/customer-login.html"))))))







(defun dod-controller-cust-add-orderpref-page ()
    (if (is-dod-cust-session-valid?)
	(let* ((prd-id (hunchentoot:parameter "prd-id"))
	  (productlist (hunchentoot:session-value :login-prd-cache))
	  (product (search-prd-in-list (parse-integer prd-id) productlist)))
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order preference")
	    (:div :class "row" 
		(:div :class "col-sm-12  col-xs-12 col-md-12 col-lg-12"
		   (:h1 :class "text-center login-title"  "Subscription - Add ")
			(:form :class "form-oprefadd" :role "form" :method "POST" :action "dodcustaddopfaction"
			    (:div :class "form-group row"  (:label :for "product-id" (str (format nil  "Product: ~a" (slot-value product 'prd-name))) ))
			         (:input :type "hidden" :name "product-id" :value (format nil "~a" (slot-value product 'row-id)))
				 ; (products-dropdown "product-id"  (hunchentoot:session-value :login-prd-cache)))
			    (:div :class "form-group row" (:label :for "prdqty" "Product Quantity")
				(:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :value "1" :min "1" :max "99"  :type "number"))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline"  (:input :type "checkbox" :name "subs-sun"  :value "Sunday" :checked "" "Sunday" ))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-mon" :value "Monday" :checked "" "Monday"))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-tue" :value "Tuesday" :checked "" "Tuesday")))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-wed" :value "Wednesday" :checked "" "Wednesday"))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-thu" :value "Thursday" :checked "" "Thursday"))
				(:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-fri" :value "Friday" :checked "" "Friday")))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-sat" :value "Saturday" :checked "" "Saturday")))
			    
			    (:div :class "form-group" 
			    (:input :type "submit"  :class "btn btn-primary" :value "Add      "))
			    )))))
	(hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-cust-add-order-page ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row" 
		(:div :class "col-sm-6 col-md-4 col-md-offset-4"
			(:h1 :class "text-center login-title"  "Customer - Add order ")
			(:form :class "form-order" :role "form" :method "POST" :action "dodmyorderaddaction"
			    (:div  :class "form-group" (:label :for "orddate" "Order Date" )
				(:input :class "form-control" :name "orddate" :value (str (get-date-string (get-date))) :type "text"  :readonly "true"  ))
			    (:div :class "form-group" (:label :for "reqdate" "Required On" )
				(:input :class "form-control" :name "reqdate" :id "required-on" :value (str (get-date-string (date+ (get-date) (make-duration :day 1)))) :type "text"))
			    ;(:div :class "form-group" (:label :for "shipaddress" "Ship Address" )
			;	(:textarea :class "form-control" :name "shipaddress" :rows "4"  (str (format nil "~A" (slot-value customer 'address)))  ))
			     (:div  :class "form-group" (:label :for "payment-mode" "Payment Mode" )
				    (payment-mode-dropdown))
			    (:input :type "submit"  :class "btn btn-primary" :value "Confirm")))))
	(hunchentoot:redirect "/hhub/customer-login.html")))




(defun dod-controller-cust-add-order-detail-page ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
		(:div :class "col-sm-6 col-md-4 col-md-offset-4"
		    (:div :class "orderpref"
			(:h1 :class "text-center login-title"  "Customer - Add order preference")
			(:form :class "form-order" :role "form" :method "POST" :action "dodcustaddorderaction"
			    (:div :class "form-group" (:label :for "orddate" "Order Date" )
				(:input :class "form-control" :name "orddate" :placeholder "DD/MM/YYYY" :type "text"))
			    (:div :class "form-group" (:label :for "reqdate" "Required On" )
				(:input :class "form-control" :name "reqdate" :placeholder "DD/MM/YYYY" :type "text"))
			    (:div :class "form-group" (:label :for "shipaddress" "Required On" )
				(:input :class "form-control" :name "shipaddress" :type "text"))
			    (products-dropdown "product-id" (select-products-by-company (hunchentoot:session-value :login-customer-company ))))
			(:div :class "form-group" (:label :for "prdqty" "Product Quantity")
			    (:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :type "text"))
			(:input :type "submit"  :class "btn btn-primary" :value "Add      ")))))
	(hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-cust-add-orderpref-action ()
    (if (is-dod-cust-session-valid?)
	(let ((product-id (hunchentoot:parameter "product-id"))
		 (login-cust (hunchentoot:session-value :login-customer))
		 (login-cust-comp (hunchentoot:session-value :login-customer-company  ))
		 (prd-qty (parse-integer (hunchentoot:parameter "prdqty")))
		 (subs-mon (hunchentoot:parameter "subs-mon"))
		 (subs-tue (hunchentoot:parameter "subs-tue"))
		 (subs-wed (hunchentoot:parameter "subs-wed"))
		 (subs-thu (hunchentoot:parameter "subs-thu"))
		 (subs-fri (hunchentoot:parameter "subs-fri"))
		 (subs-sat (hunchentoot:parameter "subs-sat"))
		 (subs-sun (hunchentoot:parameter "subs-sun"))		 )
	  
		(if (> prd-qty 0) 
		(create-opref login-cust  (select-product-by-id product-id login-cust-comp )  prd-qty  (list subs-mon subs-tue subs-wed subs-thu subs-fri subs-sat subs-sun)  login-cust-comp))
		(setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer login-cust))
		(hunchentoot:redirect "/hhub/dodcustorderprefs"))
	(hunchentoot:redirect "/hhub/customer-login.html")))

  
;; This is products dropdown
(defun  products-dropdown (dropdown-name products)
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name dropdown-name  
      (loop for prd in products
	 do (if (equal (slot-value prd 'subscribe-flag) "Y")  (htm  (:option :value  (slot-value prd 'row-id) (str (slot-value prd 'prd-name))))))))))

  
;; This is payment-mode dropdown
(defun  payment-mode-dropdown ()
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name "payment-mode"
		   (:option    :value  "PRE" :selected "true"  (str "Prepaid Wallet"))
		   (:option :value "COD" (str "Cash On Demand"))))))

;; This is customer/vendor  dropdown
(defun customer-vendor-dropdown ()
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name "reg-type"
		   (:option    :value  "CUS" :selected "true"  (str "Customer"))
		   (:option :value "VEN" (str "Vendor"))))))



;; This is company/tenant name dropdown
(defun company-dropdown (name list)
  (cl-who:with-html-output (*standard-output* nil)
    (htm (:select :class "form-control" :placeholder "Group/Apartment"  :name name 
	(loop for company in list 
	     do ( htm (:option :value (slot-value company 'row-id) (str (slot-value company 'name)))))))))


(defun dod-controller-low-wallet-balance ()
  (if (is-dod-cust-session-valid?)
      (let* ((company (hunchentoot:session-value :login-customer-company))
	     (customer (hunchentoot:session-value :login-customer))
	     (wallets (get-cust-wallets customer company))
	     (header (list "Vendor" "Phone" "Balance")))
	
	(standard-customer-page (:title "Low Wallet Balance")
	(:div :class "row" 
	      (:h3 (:span :class "label label-danger"  "Low Wallet Balance. Please call vendor and recharge your wallet. ")))
	(list-customer-wallets header wallets)
	(:a :class "btn btn-primary" :role "button" :href "dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  ")))
	
      (hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-cust-login ()
    (let  ( (phone (hunchentoot:parameter "phone"))
	   (password (hunchentoot:parameter "password")))
      (unless (and  ( or (null phone) (zerop (length phone)))
		    (or (null password) (zerop (length password))))
	    (if (equal (dod-cust-login  :phone phone :password password) NIL) (hunchentoot:redirect "/hhub/customer-login.html") (hunchentoot:redirect  "/hhub/dodcustindex")))))

(defun dod-controller-cust-ordersuccess ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row"
		(:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12"
		    (htm (:h1 "Your order has been successfully placed"))
    		    (:a :class "btn btn-primary" :role "button" :href (format nil "dodmyorders") " My Orders Page"))))))


(defun dod-controller-cust-add-order-action ()
    (if (is-dod-cust-session-valid?)
	(let* ((odts (hunchentoot:session-value :login-shopping-cart))
	       (products (hunchentoot:session-value :login-prd-cache))
	       (payment-mode (hunchentoot:parameter "payment-mode"))
	       (odate (get-date-from-string  (hunchentoot:parameter "orddate")))
	       (cust (hunchentoot:session-value :login-customer))
	       (shopcart-total (get-shop-cart-total))
	       (custcomp (hunchentoot:session-value :login-customer-company))
	       (vendor-list (get-shopcart-vendorlist odts custcomp))
	       (reqdate (get-date-from-string (hunchentoot:parameter "reqdate")))
	       (shipaddr (hunchentoot:parameter "shipaddress")))
	  
	  (progn 
	    
	    (if  (equal payment-mode "PRE")
		      ; at least one vendor wallet has low balance 
		      (if (not (every #'(lambda (x) (if x T))  (mapcar (lambda (vendor) 
							(check-wallet-balance (get-order-items-total-for-vendor vendor odts) (get-cust-wallet-by-vendor cust vendor custcomp))) vendor-list))) (hunchentoot:redirect "/hhub/dodcustlowbalance")))
		;(if (equal payment-mode "COD")  
	    (create-order-from-shopcart  odts products odate reqdate nil  shipaddr shopcart-total payment-mode cust custcomp)
	    (setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
	    (setf (hunchentoot:session-value :login-shopping-cart ) nil)
	    (hunchentoot:redirect "/hhub/dodcustordsuccess")))
	 (hunchentoot:redirect "/hhub/customer-login.html")))




(defun get-order-items-total-for-vendor (vendor order-items) 
 (let ((vendor-id (slot-value vendor 'row-id)))
  (reduce #'+ (remove nil (mapcar (lambda (item) (if (equal vendor-id (slot-value item 'vendor-id)) 
					 (* (slot-value item 'unit-price) (slot-value item 'prd-qty)))) order-items)))))




(defun get-shop-cart-total ()
  (let* ((odts (hunchentoot:session-value :login-shopping-cart))
       (total (reduce #'+  (mapcar (lambda (odt)
	  (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odts))))
    total ))
	

(defun get-shopcart-vendorlist (shopcart-items company)
( remove-duplicates  (mapcar (lambda (odt) 
	   (select-vendor-by-id (slot-value odt 'vendor-id) company))  shopcart-items)
:test #'equal
:key (lambda (vendor) (slot-value vendor 'row-id)))) 

 

(defun dod-controller-cust-update-cart ()
    :documentation "update the shopping cart by modifying the product quantity"
    (if (is-dod-cust-session-valid?)
	(let* ((prd-id (hunchentoot:parameter "prd-id"))
		 (prd-qty (hunchentoot:parameter "nprdqty"))
		 (myshopcart (hunchentoot:session-value :login-shopping-cart))
		 (odt (if myshopcart (search-odt-by-prd-id  (parse-integer prd-id)  myshopcart ))))
	    (progn  ;(remove odt  myshopcart)
		(setf (slot-value odt 'prd-qty) (parse-integer prd-qty))
		;(setf (hunchentoot:session-value :login-shopping-cart) (append (list odt)  myshopcart  ))
		(hunchentoot:redirect "/hhub/dodcustshopcart")))
	(hunchentoot:redirect "/hhub/customer-login.html")))
		 
(defun dod-controller-create-cust-wallet ()
  :documentation "If the customer wallet is not defined, then define it now"
  (let ((vendor (select-vendor-by-id (hunchentoot:parameter "vendor-id") (get-login-customer-company))))
    (create-wallet (get-login-customer) vendor (get-login-customer-company))))

(defun dod-controller-cust-add-to-cart ()
    :documentation "This function is responsible for adding the product and product quantity to the shopping cart."
    (if (is-dod-cust-session-valid?)
	(let* (	  (prd-id (hunchentoot:parameter "prd-id"))
		  (productlist (hunchentoot:session-value :login-prd-cache))
		  (myshopcart (hunchentoot:session-value :login-shopping-cart))
		  (product (search-prd-in-list (parse-integer prd-id) productlist))
		  (vendor (product-vendor product))
		  (vendor-id (slot-value vendor 'row-id))
		  (wallet (get-cust-wallet-by-vendor (get-login-customer) vendor (get-login-customer-company)))
		  (category-id (slot-value product 'catg-id))
		  (odt (create-odtinst-shopcart nil product  1 (slot-value product 'unit-price) (hunchentoot:session-value :login-customer-company))))
	  (if wallet 
	      (progn (setf (hunchentoot:session-value :login-shopping-cart) (append (list odt)  myshopcart  ))
		     (if (length (hunchentoot:session-value :login-shopping-cart)) (hunchentoot:redirect (format nil "/hhub/dodproducts?id=~a" category-id)))
		   )
	      ;else 
	      (hunchentoot:redirect (format nil "/hhub/createcustwallet?vendor-id=~A" vendor-id))))
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-prd-details ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Product Details")
	    (let* ((company (hunchentoot:session-value :login-customer-company))
		      (lstshopcart (hunchentoot:session-value :login-shopping-cart))
		      (product (select-product-by-id (parse-integer (hunchentoot:parameter "id")) company)))
		(product-card-with-details product (prdinlist-p (slot-value product 'row-id)  lstshopcart))))
	(hunchentoot:redirect "/hhub/customer-login.html")))

(defun dod-controller-cust-index () 
  (if (is-dod-cust-session-valid?)
      (let ((lstshopcart (hunchentoot:session-value :login-shopping-cart))
	    (lstprodcatg (hunchentoot:session-value :login-prdcatg-cache)))
	(standard-customer-page (:title "Welcome to Dairy Ondemand - customer")
	  ; Display the product search form. 
	  (:form :id "prdsearch" :name "prdsearch" :method "POST" :action "dodsearchproducts"
		 (:div :class "container" 
		       (:div :class "col-lg-6 col-md-6 col-sm-12" 
			     (:div :class "input-group"
				   (:input :type "text" :name "search-clause"  :class "form-control" :placeholder "Search products...")
				   (:span :class "input-group-btn" (:button :class "btn btn-primary" :type "submit" "Go!" ))))
	  ; Display the My Cart button. 
	  (:div :class "col-lg-6 col-md-6 col-sm-6" :align "right"
		(:a :class "btn btn-primary" :role "button" :href "dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))))))))
	(:hr)		       
	(ui-list-prod-catg lstprodcatg)))
(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-customer-products ()
:documentation "This function lists the customer products by category"
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Products ...")
    (let* ((catg-id (hunchentoot:parameter "id"))
      (company (hunchentoot:session-value :login-customer-company))
      (lstshopcart (hunchentoot:session-value :login-shopping-cart))
      (lstproducts (select-products-by-category catg-id company)))

(htm (:div :class "row"
	   (:div :class "col-md-12" :align "right"
		 (:a :class "btn btn-primary" :role "button" :href "dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))) ))))
		    (:hr))		       
(ui-list-customer-products lstproducts lstshopcart)))
(hunchentoot:redirect "/hhub/customer-login.html")))

 
    

(defun dod-controller-cust-show-shopcart ()
    :documentation "This is a function to display the shopping cart."
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "My Shopping Cart")
	    (let* ((lstshopcart (hunchentoot:session-value :login-shopping-cart))
		      (prd-cache (hunchentoot:session-value :login-prd-cache))
		      (lstcount (length lstshopcart))
		      (total  (get-shop-cart-total) ))
		(if (> lstcount 0)
		    (let ((products (mapcar (lambda (odt)
						(let ((prd-id (slot-value odt 'prd-id)))
						    (search-prd-in-list prd-id prd-cache ))) lstshopcart))) ; Need to select the order details instance here instead of product instance. Also, ui-list-shop-cart should be based on order details instances. 
					; This function is responsible for displaying the shopping cart. 
			(htm(:div :class "row"
			    (:div :class "col-md-12" 
			(ui-list-shop-cart products lstshopcart))))
			(htm
			    (:hr)
			    (:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total)))))
				
				(:div :class "col-md-12" :align "right"
				    (:a :class "btn btn-primary" :role "button" :href (format nil "dodmyorderaddpage") "Checkout"))
				)
			    (:hr)
			    ))
					;If condition ends here. 
		    (htm(:div :class "row" 
			    (:div :class "col-md-12" (:span :class "label label-info"  (str (format nil " ~A Items in cart.   " lstcount)))
				(:a :class "btn btn-primary" :role "button" :href "dodcustindex" "Shop Now"  )))))))
	(hunchentoot:redirect  "/hhub/customer-login.html")))



(defun dod-controller-remove-shopcart-item ()
    :documentation "This is a function to remove an item from shopping cart."
    (if (is-dod-cust-session-valid?)
	(let ((action (hunchentoot:parameter "action"))
		 (prd-id (parse-integer (hunchentoot:parameter "id")))
		 (myshopcart (hunchentoot:session-value :login-shopping-cart)))
	    (progn (if (equal action "remitem" ) (setf (hunchentoot:session-value :login-shopping-cart) (remove (search-odt-by-prd-id  prd-id  myshopcart  ) myshopcart)))
		(hunchentoot:redirect  "/hhub/dodcustshopcart")))))


(defun dod-cust-login (&key phone password)
    (handler-case 
	;expression

       (let* ((customer (car (clsql:select 'dod-cust-profile :where [and
			      [= [slot-value 'dod-cust-profile 'phone] phone]
			      [= [:deleted-state] "N"]]
			      :caching nil :flatp t :database *dod-db-instance* )))
	   (pwd (if customer (slot-value customer 'password)))
	   (salt (if customer (slot-value customer 'salt)))
	   (password-verified (if customer  (check-password password salt pwd)))
	   (customer-id (if customer (slot-value customer 'row-id)))
	   (customer-name (if customer (slot-value customer 'name)))
	   (customer-tenant-id (if customer (slot-value (car  (customer-company customer)) 'row-id)))
	   (customer-company-name (if customer (slot-value (car (if customer (customer-company customer))) 'name)))
	   (login-shopping-cart '())
	   (customer-company (if customer (car (customer-company customer)))))
      (when (and customer
		 password-verified
		 (null (hunchentoot:session-value :login-customer-name))) ;; customer should not be logged-in in the first place.
	(progn
	  (princ "Starting session")
	  (setf *current-customer-session* (hunchentoot:start-session))
	  (setf (hunchentoot:session-value :login-customer ) customer)
	  (setf (hunchentoot:session-value :login-customer-name) customer-name)
	  (setf (hunchentoot:session-value :login-customer-id) customer-id)
	  (setf (hunchentoot:session-value :login-customer-tenant-id) customer-tenant-id)
	  (setf (hunchentoot:session-value :login-customer-company-name) customer-company-name)
	  (setf (hunchentoot:session-value :login-customer-company) customer-company)
	  (setf (hunchentoot:session-value :login-shopping-cart) login-shopping-cart)
	  (setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer  customer)) 
	  (setf (hunchentoot:session-value :login-prd-cache )  (select-products-by-company customer-company))
	  (setf (hunchentoot:session-value :login-prdcatg-cache) (select-prdcatg-by-company customer-company))
	  (setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer customer))
	  )))

        ; Handle this condition
   
      (clsql:sql-database-data-error (condition)
	  (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
								   (stop-das) 
								   (start-das)
;								   (clsql:reconnect :database *dod-db-instance*)
								   (hunchentoot:redirect "/hhub/customer-login.html"))))))
 ;     (clsql:sql-fatal-error (errorinst) (if (equal (clsql:sql-error-database-message errorinst) "Database is closed.") 
;					     (progn (clsql:stop-sql-recording :type :both)
;					            (clsql:disconnect) 
;						    (crm-db-connect :servername *crm-database-server* :strdb *crm-database-name* :strusr *crm-database-user*  :strpwd *crm-database-password* :strdbtype :mysql)
;(hunchentoot:redirect "/hhub/customer-login.html"))))))
      








