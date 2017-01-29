;; -*- mode: common-lisp; coding: utf-8 -*-
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
	(let (( dodorderprefs (hunchentoot:session-value :login-cusopf-cache))
		 (header (list   "Product"  "Weekday Preference"  "Product Qty" "Qty Per Unit" "Unit Price"  "Action")))
	    (ui-list-cust-orderprefs header dodorderprefs))
	(hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-del-opref ()
    :documentation "Delete order preference"
    (if (is-dod-cust-session-valid?)
	(let ((ordpref-id (parse-integer (hunchentoot:parameter "id")))
		     (cust (hunchentoot:session-value :login-customer))
		 (company (hunchentoot:session-value :login-customer-company)))
	    (delete-opref (get-opref-by-id ordpref-id company))
	    (setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer cust))
	(hunchentoot:redirect "/dodcustorderprefs"))
					;else
	(hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-my-orders ()
    :documentation "A callback function which prints orders for a logged in customer in HTML format."
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "List DOD Customer orders")   
	    (let (( dodorders (hunchentoot:session-value :login-cusord-cache))
		     (header (list  "Order No" "Order Date" "Request Date"  "Action")))
		(if dodorders (ui-list-customer-orders header dodorders) "No orders")))
	(hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-del-order()
    (if (is-dod-cust-session-valid?)
	    (let ((order-id (parse-integer (hunchentoot:parameter "id")))
		     (cust (hunchentoot:session-value :login-customer))
		     (company (hunchentoot:session-value :login-customer-company)))
		(delete-order (get-order-by-id order-id company))
		(setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
		(hunchentoot:redirect "/dodmyorders"))
					;else
	(hunchentoot:redirect "/customer-login.html")))


(defun dod-controller-vendor-details ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Vendor Details")
	    (let ((vendor (select-vendor-by-id  (hunchentoot:parameter "id") (hunchentoot:session-value :login-customer-company))))
		(vendor-details-card vendor)))
	(hunchentoot:redirect "/customer-login.html")))

	    

(defun dod-controller-my-orderdetails ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "List DOD Customer orders")   
	    (let* (( dodorder (get-order-by-id (hunchentoot:parameter "id") (get-login-cust-company)))
		      (header (list "Product" "Product Qty" "Unit Price"  "Sub-total"))
		      (odtlst (get-order-details dodorder) )
      		      (total   (reduce #'+  (mapcar (lambda (odt)
			(* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst))))
		(display-order-header dodorder) 
		(if odtlst (ui-list-cust-orderdetails header odtlst) "No order details")
					    (htm(:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total)))))))
		))
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
    `(let ((customer (hunchentoot:session-value :login-customer)))
       (cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-inverse  navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "HighriseHub" (:img :style "width: 30px; height: 30px;" :src "/resources/demand&supply.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/dodcustindex" (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li :align "center" (:a :href "/dodcustorderprefs" "My Subscriptions"))
			 (:li :align "center" (:a :href "/dodmyorders" "My Orders"))
			 (:li :align "center" (:a :href "#" (:i :class "fa fa-google-wallet" :style "color:white") (str(format nil "~$" (slot-value customer 'wallet-balance)))))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     (:ul :class "nav navbar-nav navbar-right"
			 
			 
			 (:li :align "center" (:a :href "https://goo.gl/forms/XaZdzF30Z6K43gQm2" "Feedback" ))
			 (:li :align "center" (:a :href "https://goo.gl/forms/SGizZXYwXDUiTgVY2" (:span :class "glyphicon glyphicon-bug") "Bug" ))
	;(:li :align "center" (:a :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart " (:span :class "badge" (str (format nil " ~A " (length (hunchentoot:session-value :login-shopping-cart)))) )))
			 (:li :align "center" (:a :href "/dodcustlogout" (:span :class "glyphicon glyphicon-off") " Logout "  )))))))))
    



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
		 (:link :href "css/rangeslider.css" :rel "stylesheet")
		 (:link :href "css/bootstrap.min.css" :rel "stylesheet")
		 (:link :href "css/bootstrap-theme.min.css" :rel "stylesheet")
		 (:link :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" :rel "stylesheet")
		 (:link :href "css/theme.css" :rel "stylesheet")
		 (:link :href "css/nouislider.min.css" :rel "stylesheet")
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "js/spin.min.js")
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
		 (:script :src "js/nouislider.min.js")
		 (:script :src "js/dod.js")
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js"))))))


					;**********************************************************************************
;***************** CUSTOMER LOGIN RELATED FUNCTIONS ******************************
(defvar *current-customer-session* nil) 



(defun dod-controller-customer-loginpage ()
    (if (is-dod-cust-session-valid?)
	(hunchentoot:redirect "/dodcustindex")
    (standard-customer-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:form :class "form-custsignin" :role "form" :method "POST" :action "/dodcustlogin"
		    (:div :class "account-wall"
			(:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			(:h1 :class "text-center login-title"  "Customer - Login to DAS")
			(:div :class "form-group"
			    (:input :class "form-control" :name "company" :placeholder "demo"  :type "text" ))
			(:div :class "form-group"
			    (:input :class "form-control" :name "phone" :placeholder "9999999999" :type "text" ))
			(:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Login"))))))
	(:script :src "/js/dod.js"))))



(defun dod-controller-cust-add-orderpref-page ()
    (if (is-dod-cust-session-valid?)
	(let* ((prd-id (hunchentoot:parameter "prd-id"))
	  (productlist (hunchentoot:session-value :login-prd-cache))
	  (product (search-prd-in-list (parse-integer prd-id) productlist)))

	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order preference")
	    (:div :class "row" 
		(:div :class "col-sm-12  col-xs-12 col-md-12 col-lg-12"
		   (:h1 :class "text-center login-title"  "Subscription - Add ")
			(:form :class "form-oprefadd" :role "form" :method "POST" :action "/dodcustaddopfaction"
			    (:div :class "form-group row"  (:label :for "product-id" (str (format nil  "Product: ~a" (slot-value product 'prd-name))) ))
			         (:input :type "hidden" :name "product-id" :value (format nil "~a" (slot-value product 'row-id)))
				 ; (products-dropdown "product-id"  (hunchentoot:session-value :login-prd-cache)))
			    (:div :class "form-group row" (:label :for "prdqty" "Product Quantity")
				(:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :maxlength "2" :type "text"))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline"  (:input :type "checkbox" :name "subs-sun" :value "Sunday" "Sunday"))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-mon" :value "Monday" "Monday"))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-tue" :value "Tuesday" "Tuesday")))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-wed" :value "Wednesday" "Wednesday"))
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-thu" :value "Thursday" "Thursday"))
				(:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-fri" :value "Friday" "Friday")))
			    (:div :class "form-group row" 
			    (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-sat" :value "Saturday" "Saturday")))
			    
			    (:div :class "form-group" 
			    (:input :type "submit"  :class "btn btn-primary" :value "Add      "))
			    )))))
	(hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-cust-add-order-page ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row" 
		(:div :class "col-sm-6 col-md-4 col-md-offset-4"
			(:h1 :class "text-center login-title"  "Customer - Add order ")
			(:form :class "form-order" :role "form" :method "POST" :action "/dodmyorderaddaction"
			    (:div  :class "form-group" (:label :for "orddate" "Order Date" )
				(:input :class "form-control" :name "orddate" :value (str (get-date-string (get-date))) :type "text"  :readonly "true"  ))
			    (:div :class "form-group" (:label :for "reqdate" "Required On" )
				(:input :class "form-control" :name "reqdate" :value (str (get-date-string (date+ (get-date) (make-duration :day 1)))) :type "text"))
			    ;(:div :class "form-group" (:label :for "shipaddress" "Ship Address" )
			;	(:textarea :class "form-control" :name "shipaddress" :rows "4"  (str (format nil "~A" (slot-value customer 'address)))  ))
			   			    (:input :type "submit"  :class "btn btn-primary" :value "Confirm")))))
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
			    (products-dropdown "product-id" (select-products-by-company (hunchentoot:session-value :login-customer-company ))))
			(:div :class "form-group" (:label :for "prdqty" "Product Quantity")
			    (:input :class "form-control" :name "prdqty" :placeholder "Enter a number" :type "text"))
			(:input :type "submit"  :class "btn btn-primary" :value "Add      ")))))
	(hunchentoot:redirect "/customer-login.html")))



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
	    (progn (format t "creating order preference now")
		
		(create-opref login-cust  (select-product-by-id product-id login-cust-comp )  prd-qty  (list subs-mon subs-tue subs-wed subs-thu subs-fri subs-sat subs-sun)  login-cust-comp)
		(setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer login-cust))
		(hunchentoot:redirect "/dodcustorderprefs")))
	(hunchentoot:redirect "/customer-login.html")))

  
;; This is products dropdown
(defun  products-dropdown (dropdown-name products)
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name dropdown-name  
      (loop for prd in products
	 do (if (equal (slot-value prd 'subscribe-flag) "Y")  (htm  (:option :value  (slot-value prd 'row-id) (str (slot-value prd 'prd-name))))))))))





(defun dod-controller-cust-login ()
    (let  ((cname (hunchentoot:parameter "company"))
	      (phone (hunchentoot:parameter "phone")))
	(unless(and
		   ( or (null cname) (zerop (length cname)))
		   ( or (null phone) (zerop (length phone))))
	    (if (equal (dod-cust-login :company-name cname :phone phone) NIL) (hunchentoot:redirect "/customer-login.html") (hunchentoot:redirect  "/dodcustindex")))))

(defun dod-controller-cust-ordersuccess ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row"
		(:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12"
		    (htm (:h1 "Your order has been successfully placed"))
    		    (:a :class "btn btn-primary" :role "button" :href (format nil "/dodmyorders") " My Orders Page"))))))


(defun dod-controller-cust-add-order-action ()
    (if (is-dod-cust-session-valid?)
	(let ((odts (hunchentoot:session-value :login-shopping-cart))
	      (customer (hunchentoot:session-value :login-customer))
		 (products (hunchentoot:session-value :login-prd-cache))
		 (odate (get-date-from-string  (hunchentoot:parameter "orddate")))
		 (cust (hunchentoot:session-value :login-customer))
	      (shopcart-total (get-shop-cart-total))
	      (custcomp (hunchentoot:session-value :login-customer-company))
		 (reqdate (get-date-from-string (hunchentoot:parameter "reqdate")))
		 (shipaddr (hunchentoot:parameter "shipaddress")))
	    (progn (create-order-from-shopcart  odts products odate reqdate nil  shipaddr shopcart-total cust custcomp)
		(setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
		(setf (hunchentoot:session-value :login-shopping-cart ) nil)
		; Deduct the wallet balance after the order has been created
		(deduct-wallet-balance shopcart-total  customer )
		(hunchentoot:redirect "/dodcustordsuccess")))))

(defun get-shop-cart-total ()
  (let* ((odts (hunchentoot:session-value :login-shopping-cart))
       (total (reduce #'+  (mapcar (lambda (odt)
	  (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odts))))
    total ))
	


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
		(hunchentoot:redirect "/dodcustshopcart")))
	(hunchentoot:redirect "/customer-login.html")))
		 

(defun dod-controller-cust-add-to-cart ()
    :documentation "This function is responsible for adding the product and product quantity to the shopping cart."
    (if (is-dod-cust-session-valid?)
	(let* (	  (prd-id (hunchentoot:parameter "prd-id"))
		  (productlist (hunchentoot:session-value :login-prd-cache))
		  (myshopcart (hunchentoot:session-value :login-shopping-cart))
		  (product (search-prd-in-list (parse-integer prd-id) productlist))
		  (category-id (slot-value product 'catg-id))
		  (odt (create-odtinst-shopcart nil product  1 (slot-value product 'unit-price) (hunchentoot:session-value :login-customer-company))))
	    
	      (progn (setf (hunchentoot:session-value :login-shopping-cart) (append (list odt)  myshopcart  ))
		     (if (length (hunchentoot:session-value :login-shopping-cart)) (hunchentoot:redirect (format nil "/dodproducts?id=~a" category-id)))
		   ))
	(hunchentoot:redirect "/customer-login.html")))


(defun dod-controller-prd-details ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Product Details")
	    (let* ((company (hunchentoot:session-value :login-customer-company))
		      (lstshopcart (hunchentoot:session-value :login-shopping-cart))
		      (product (select-product-by-id (parse-integer (hunchentoot:parameter "id")) company)))
		(product-card-with-details product (prdinlist-p (slot-value product 'row-id)  lstshopcart))))
	(hunchentoot:redirect "/customer-login.html")))

(defun dod-controller-cust-index () 
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to Dairy Ondemand - customer")
	    (let ((lstshopcart (hunchentoot:session-value :login-shopping-cart)))
		
		(htm 
		    (:div :class "row"
			(:div :class "col-md-12" :align "right"
			    (:a :class "btn btn-primary" :role "button" :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))) ))))
		    (:hr)		       
		    (let ((lstprodcatg (hunchentoot:session-value :login-prdcatg-cache))) 
		          (ui-list-prod-catg lstprodcatg)))))
	(hunchentoot:redirect "/customer-login.html")))


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
		 (:a :class "btn btn-primary" :role "button" :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))) ))))
		    (:hr))		       
(ui-list-customer-products lstproducts lstshopcart)))
(hunchentoot:redirect "/customer-login.html")))

 
    

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
				    (:a :class "btn btn-primary" :role "button" :href (format nil "/dodmyorderaddpage") "Checkout"))
				)
			    (:hr)
			    ))
					;If condition ends here. 
		    (htm(:div :class "row" 
			    (:div :class "col-md-12" (:span :class "label label-info"  (str (format nil " ~A Items in cart.   " lstcount)))
				(:a :class "btn btn-primary" :role "button" :href "/dodcustindex" "Shop Now"  )))))))
	(hunchentoot:redirect "/customer-login.html")))



(defun dod-controller-remove-shopcart-item ()
    :documentation "This is a function to remove an item from shopping cart."
    (if (is-dod-cust-session-valid?)
	(let ((action (hunchentoot:parameter "action"))
		 (prd-id (parse-integer (hunchentoot:parameter "id")))
		 (myshopcart (hunchentoot:session-value :login-shopping-cart)))
	    (progn (if (equal action "remitem" ) (setf (hunchentoot:session-value :login-shopping-cart) (remove (search-odt-by-prd-id  prd-id  myshopcart  ) myshopcart)))
		(hunchentoot:redirect "/dodcustshopcart")))))


(defun dod-cust-login (&key company-name phone)
    (let* ((customer (car (clsql:select 'dod-cust-profile :where [and
			      [= [slot-value 'dod-cust-profile 'phone] phone]
			     [= [:deleted-state] "N"]]
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
		(setf (hunchentoot:session-value :login-cusopf-cache) (get-opreflist-for-customer  customer)) 
		(setf (hunchentoot:session-value :login-prd-cache )  (select-products-by-company customer-company))
		(setf (hunchentoot:session-value :login-prdcatg-cache) (select-prdcatg-by-company customer-company))
		(setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer customer))
		))))
		 


