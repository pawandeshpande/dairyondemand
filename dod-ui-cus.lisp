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
  (if  (null (get-login-cust-name)) NIL T))

(defun get-login-cust-name ()
  :documentation "Gets the name of the currently logged in customer"
 (hunchentoot:session-value :login-customer-name))

(defun dod-controller-customer-logout ()
  :documentation "Customer logout."
     (progn (hunchentoot:remove-session *current-customer-session*)
	    (hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-list-customers ()
  :documentation "A callback function which prints a list of customers in HTML format."
(if (is-dod-session-valid?)
   (let (( dodcustomers (list-cust-profiles (get-login-company)))
	 (header (list "Name" "Address" "Phone"  "Action")))
     (if dodcustomers (ui-list-customers header dodcustomers) "No customers"))
     (hunchentoot:redirect "/customer-login.html")))


(defun dod-controller-my-orderprefs ()
  :documentation "A callback function which prints daily order preferences for a logged in customer in HTML format."
(if (is-dod-cust-session-valid?)
   (let (( dodorderprefs (get-opreflist-for-customer  (get-login-customer)))
	 (header (list   "Product" "Product Qty" "Action")))
      (ui-list-cust-orderprefs header dodorderprefs))
     (hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-my-orders ()
  :documentation "A callback function which prints orders for a logged in customer in HTML format."
  (if (is-dod-cust-session-valid?)
       (standard-customer-page (:title "List DOD Customer orders")   
   (let (( dodorders (get-orders-for-customer  (get-login-customer)));
	 (header (list  "Order No" "Order Date" "Customer" "Request Date"  "Ship Date" "Ship Address" "Action")))
     (if dodorders (ui-list-customer-orders header dodorders) "No orders")))
   (hunchentoot:redirect "/customer-login.html")))


;(defun dod-controller-my-orders ()
;  (if (is-dod-cust-session-valid?)
;        (standard-page (:title "List DOD Customers")
;      (ui-list-cust-orders-with-details (get-login-customer)));
;	(hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-my-orderdetails ()
(if (is-dod-cust-session-valid?)
       (standard-customer-page (:title "List DOD Customer orders")   
    (let* (( dodorder (get-order-by-id (hunchentoot:parameter "id") (get-login-cust-company)))
	 (header (list  "Order No" "Product" "Product Qty" "Unit Price"  "Total"  "Action"))
	  (odt (get-order-details dodorder) ))
      (if odt (ui-list-cust-orderdetails header odt dodorder) "No order details")))
     (hunchentoot:redirect "/customer-login.html")))


(defun ui-list-customers (header data)
    (standard-page (:title "List DOD Customers")
    (:h3 "Customers") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (customer)
									     (htm (:tr (:td  :height "12px" (str (slot-value customer 'name)))
										      (:td  :height "12px" (str (slot-value customer 'address)))
										      (:td  :height "12px" (str (slot-value customer 'phone)))
		    (:td :height "12px" (:a :href  (format nil  "/delcustomer?id=~A" (slot-value customer 'row-id)):onclick "return false"  "Delete"))))) data)))))
									  


(defmacro customer-navigation-bar ()
    :documentation "This macro returns the html text for generating a navigation bar using bootstrap."
  `(cl-who:with-html-output (*standard-output* nil)
       (:div :class "navbar navbar-default navbar-inverse navbar-static-top"
	   (:div :class "container-fluid"
	       (:div :class "navbar-header"
	       (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
		   (:span :class "icon-bar")
		   (:span :class "icon-bar")
		   (:span :class "icon-bar"))
		   (:a :class "navbar-brand" :href "#" :title "DAS" (:img :style "width: 30px; height: 30px;" :src "/resources/demand&supply.png" )  ))
		   
	       
	       (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
	   (:ul :class "nav navbar-nav navbar-left"
		      (:li :class "active" :align "center" (:a :href "/dodcustindex" "Home"))
		      (:li :align "center" (:a :href "/dodcustorderprefs" "My Order Preferences"))
		      (:li :align "center" (:a :href "/dodmyorders" "My Orders"))
	   	      (:li :align "center" (:a :href "#" (print-web-session-timeout))))


	   (:ul :class "nav navbar-nav navbar-right"
		(:li :align "center" (:a :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart " (:span :class "badge" (str (format nil " ~A " (length (hunchentoot:session-value :login-shopping-cart)))) )))
		(:li :align "center" (:a :href "/dodcustlogout" (:span :class "glyphicon glyphicon-log-out") " Logout "  ))))))))



(defmacro standard-customer-page ((&key title) &body body)
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
		(:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		(:script :src "js/spin.min.js")
	     );; Header completes here.
	 (:body
	     (:div :id "dod-error" (:h2 "Error..."))

	     (:div :id "busy-indicator")
	     (if (is-dod-cust-session-valid?) (customer-navigation-bar))
		   (:div :class "container theme-showcase" :role "main" 
			 (:div :id "header"	 ; DOD System header
			       ,@body))	;container div close
		   ;; bootstrap core javascript
		   (:script :src "js/bootstrap.min.js")))))



(defmacro test-standard-customer-page ((&key title) &body body)
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

		   (:div :class "container theme-showcase" :role "main" 

			 (:div :id "header"	 ; DOD System header
			      
	 

			    					 
			       ,@body))	;container div close
		   ;; bootstrap core javascript
		   (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js")
	
		   (:script :src "js/bootstrap.min.js")))))




;**********************************************************************************
;***************** CUSTOMER LOGIN RELATED FUNCTIONS ******************************
(defvar *current-customer-session* nil) 



(defun dod-controller-customer-loginpage ()
  (standard-customer-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
    (:div :class "row" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
	      (:form :class "form-signin" :role "form" :method "POST" :action "/dodcustlogin"
	      (:div :class "account-wall"
		   (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
		      (:h1 :class "text-center login-title"  "Customer - Login to DAS")
		      
			  (:div :class "form-group"
				   (:input :class "form-control" :name "company" :placeholder "Group/Apartment"  :type "text" ))
			  (:div :class "form-group"
			      (:input :class "form-control" :name "phone" :placeholder "Phone" :type "text" ))
			  (:div :class "form-group"
			   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Login"))
			  ))))
(:script :src "/js/dod.js")      
      )

    )


(defun dod-controller-cust-add-orderpref-page ()
  (if (is-dod-cust-session-valid?)
  (standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order preference")
    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:div :class "orderpref"
		      (:h1 :class "text-center login-title"  "Customer - Add order preference")
		      (:form :class "form-signin" :role "form" :method "POST" :action "/dodcustaddopfaction"
			     (:div :class "form-group" (:label :for "product-id" "Select Product" )
				  (products-dropdown "product-id" (select-products-by-company)))
			     (:div :class "form-group" (:label :for "prdqty" "Product Quantity")
				   (:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :type "text"))
			     (:input :type "submit"  :class "btn btn-primary" :value "Add      "))))))
  (hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-cust-add-order-page ()
  (if (is-dod-cust-session-valid?)
    (standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:div :class "orderpref"
		      (:h1 :class "text-center login-title"  "Customer - Add order ")
		      (:form :class "form-order" :role "form" :method "POST" :action "/dodcustaddorderaction"
			     (:div :class "form-group" (:label :for "orddate" "Order Date" )
   				   (:input :class "form-control" :name "orddate" :placeholder "DD/MM/YYYY" :type "text"))
			     (:div :class "form-group" (:label :for "reqdate" "Required On" )
   				   (:input :class "form-control" :name "reqdate" :placeholder "DD/MM/YYYY" :type "text"))
			     (:div :class "form-group" (:label :for "shipaddress" "Required On" )
   				   (:input :class "form-control" :name "shipaddress" :type "text"))

			     (:input :type "submit"  :class "btn btn-primary" :value "Add      "))))))
  (hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-cust-add-order-detail-page ()
  (if (is-dod-cust-session-valid?)
  (standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
    (:div :class "row background-image: url(resources/login-background.png);background-color:lightblue;" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:div :class "orderpref"
		      (:h1 :class "text-center login-title"  "Customer - Add order preference")
		      (:form :class "form-order" :role "form" :method "POST" :action "/dodcustaddorderaction"
			     (:div :class "form-group" (:label :for "orddate" "Order Date" )
   				   (:input :class "form-control" :name "orddate" :placeholder "DD/MM/YYYY" :type "text"))
			     (:div :class "form-group" (:label :for "reqdate" "Required On" )
   				   (:input :class "form-control" :name "reqdate" :placeholder "DD/MM/YYYY" :type "text"))
			     (:div :class "form-group" (:label :for "shipaddress" "Required On" )
   				   (:input :class "form-control" :name "shipaddress" :type "text"))

			     (products-dropdown "product-id" (select-products-by-company)))
			     (:div :class "form-group" (:label :for "prdqty" "Product Quantity")
				   (:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :type "text"))
			     (:input :type "submit"  :class "btn btn-primary" :value "Add      ")))))
  (hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-cust-add-orderpref-action ()
(if (is-dod-cust-session-valid?)
       (let ((product-id (hunchentoot:parameter "product-id"))
	(prd-qty (parse-integer (hunchentoot:parameter "prdqty"))))
   (progn (format t "creating order preference now") 
     (create-opref (get-login-customer) (select-product-by-id product-id) prd-qty (get-login-cust-company))
     (hunchentoot:redirect "/dodcustorderprefs")))
       (hunchentoot:redirect "/customer-login.html")))

  
;; This is products dropdown
(defun  products-dropdown (dropdown-name products)
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name dropdown-name  
      (loop for prd in products
	 do (htm  (:option :value  (slot-value prd 'row-id) (str (slot-value prd 'prd-name)))))))))



(defun dod-controller-cust-login ()
  (let  ((cname (hunchentoot:parameter "company"))
	 (phone (hunchentoot:parameter "phone")))

      (unless(and
	    ( or (null cname) (zerop (length cname)))
	    ( or (null phone) (zerop (length phone))))
      (if (equal (dod-cust-login :company-name cname :phone phone) NIL) (hunchentoot:redirect "/customer-login.html") (hunchentoot:redirect  "/dodcustindex")))))
   

(defun dod-controller-cust-add-to-cart ()
  :documentation "This function is responsible for adding the product and product quantity to the shopping cart."
  (if (is-dod-cust-session-valid?)
  (let ((action (hunchentoot:parameter "action"))
	(prd-id (hunchentoot:parameter "prd-id"))
	(myshopcart (hunchentoot:session-value :login-shopping-cart)))
      (progn (if (equal action "addtocart" ) (setf (hunchentoot:session-value :login-shopping-cart) (append  (list (parse-integer prd-id)) myshopcart  )))
      (if (length (hunchentoot:session-value :login-shopping-cart)) (hunchentoot:redirect "/dodcustindex"))))))



(defun dod-controller-cust-index () 
  (if (is-dod-cust-session-valid?)
      (standard-customer-page (:title "Welcome to Dairy Ondemand - customer")
	  (let ((lstshopcart (hunchentoot:session-value :login-shopping-cart)))
	  (htm 
	   (:div :class "row"
		 (:div :class "col-md-12" :align "right"
		     (:a :class "btn btn-primary" :role "button" :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " Checkout " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))) ))))
	      (:hr)
		       
	    (let ( (dodproducts (select-products-by-company))
		      (header (list  "Name" )))
		(ui-list-customer-products header dodproducts lstshopcart))))
(:script :src "/js/dod.js")      
	  )
      (hunchentoot:redirect "/customer-login.html")))

    
(defun dod-controller-cust-show-shopcart ()
  :documentation "This is a function to display the shopping cart."
    (if (is-dod-cust-session-valid?)
  (standard-customer-page (:title "My Shopping Cart")
      (let* ((lstshopcart (hunchentoot:session-value :login-shopping-cart))
	       (lstcount (length lstshopcart)))
	(if (> lstcount 0)
	    (let ((products (mapcar (lambda (prd-id)
					 (select-product-by-id prd-id )) lstshopcart)))
		     (ui-list-shop-cart products))
	    (htm
		(:div :class "row"  "Shopping cart is empty")
		(:div (str (format nil "shop cart count ~A" lstcount)))
	      (:a :class "btn btn-primary" :role "button" :href "/dodcustindex" "Shop Now"  )
	      ))))
          (hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-remove-shopcart-item ()
  :documentation "This is a function to remove an item from shopping cart."
(if (is-dod-cust-session-valid?)
  (let ((action (hunchentoot:parameter "action"))
	(prd-id (hunchentoot:parameter "id"))
	(myshopcart (hunchentoot:session-value :login-shopping-cart)))
    (progn (if (equal action "remitem" ) (setf (hunchentoot:session-value :login-shopping-cart) (remove  (parse-integer prd-id) myshopcart  )))
	       (hunchentoot:redirect "/dodcustshopcart")))))

     
		    
(defun print-web-session-timeout ()
(let ((weseti ( get-web-session-timeout)))
  (if weseti (format t "Session will end at  ~2,'0d:~2,'0d:~2,'0d"
	     (nth 0  weseti)(nth 1 weseti) (nth 2 weseti)))))


(defun get-web-session-timeout ()
  (multiple-value-bind
	(second minute hour)
	(decode-universal-time (+ (get-universal-time) hunchentoot:*session-max-time*))
  (list hour minute second)))

  

(defun dod-cust-login (&key company-name phone)
  (let* ((customer (car (clsql:select 'dod-cust-profile :where [and
				       [= [slot-value 'dod-cust-profile 'phone] phone]]
				      :caching nil :flatp t)))
	 (customer-id (if customer (slot-value customer 'row-id)))
	 (customer-name (if customer (slot-value customer 'name)))
	 (customer-tenant-id (if customer (slot-value (car  (customer-company customer)) 'row-id)))
	 (customer-company-name (if customer (slot-value (car (if customer (customer-company customer))) 'name)))
	 (login-shopping-cart '())
	 (customer-company (if customer (car (customer-company customer)))))
    

    (when (and (equal  customer-company-name company-name)
	      customer
	      (null (hunchentoot:session-value :login-customer-name))) ;; customer should not be logged-in in the first place.
	        (progn
		    (format T "Starting session")
		    (setf *current-customer-session* (hunchentoot:start-session))
		    (setf (hunchentoot:session-value :login-customer ) customer)
		    (setf (hunchentoot:session-value :login-customer-name) customer-name)
		  (setf (hunchentoot:session-value :login-customer-id) customer-id)
		  (setf (hunchentoot:session-value :login-customer-tenant-id) customer-tenant-id)
		  (setf (hunchentoot:session-value :login-customer-company-name) customer-company-name)
		  (setf (hunchentoot:session-value :login-customer-company) customer-company)
		  (setf (hunchentoot:session-value :login-shopping-cart) login-shopping-cart)
		  (initialize-products customer-company)
		  (setf (hunchentoot:session-value :login-products-cache ) (initialize-products-cache))

		  ))))
		 


