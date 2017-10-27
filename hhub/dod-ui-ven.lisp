(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defvar *current-vendor-session* nil)


(defun dod-controller-list-vendors ()
(if (is-dod-session-valid?)
   (let (( dodvendors (select-vendors-for-company (get-login-company)))
	 (header (list "Name" "Address" "Phone"  "Action")))
     (if dodvendors (ui-list-vendors header dodvendors) "No vendors"))
     (hunchentoot:redirect "vendor-login.html")))




(defun ui-list-vendors (header data)
    (standard-page (:title "List DOD Vendors")
    (:h3 "Vendors") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (vendor)
									     (htm (:tr (:td  :height "12px" (str (slot-value vendor 'name)))
										      (:td  :height "12px" (str (slot-value vendor 'address)))
										      (:td  :height "12px" (str (slot-value vendor 'phone)))
		    (:td :height "12px" (:a :href  (format nil  "delvendor?id=~A" (slot-value vendor 'row-id)) "Delete"))))) data)))))
									  



(defun dod-controller-vendor-loginpage ()
    (if (is-dod-vend-session-valid?)
	(hunchentoot:redirect "/dodvendindex")
    (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:form :class "form-vendorsignin" :role "form" :method "POST" :action "dodvendlogin"
		    (:div :class "account-wall"
			(:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			(:h1 :class "text-center login-title"  "Vendor - Login to DAS")
			(:div :class "form-group"
			    (:input :class "form-control" :name "phone" :placeholder "Phone" :type "text" ))
				(:div :class "form-group"
			    (:input :class "form-control" :name "password" :placeholder "password" :type "password" ))
		
			(:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))
  

(defun dod-controller-vendor-search-cust-wallet-page ()
    (if (is-dod-vend-session-valid?)
    (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:form :class "form-cust-wallet-search" :role "form" :method "POST" :action "dodsearchcustwalletaction"
		    (:div :class "account-wall"
			  (:div :class "form-group"
			    (:input :class "form-control" :name "phone" :placeholder "Enter Customer Phone Number" :type "text" ))
					
			(:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))
    (hunchentoot:redirect "/hhub/vendor-login.html")
))

(defun dod-controller-vendor-search-cust-wallet-action ()
(let* ((phone (hunchentoot:parameter "phone"))
	(customer (select-customer-by-phone phone (get-login-vendor-company)))
	(wallet (get-cust-wallet-by-vendor customer (get-login-vendor) (get-login-vendor-company))))
(if (is-dod-vend-session-valid?)
(standard-vendor-page (:title "Welcome to DAS Platform")
 
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Name: ~A" (if customer (slot-value customer 'name)))))))
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Phone: ~A" (if customer (slot-value customer 'phone)))))))
   (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Address: ~A" (if customer (slot-value customer 'address)))))))

  (:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Balance = Rs.~$" (if wallet (slot-value wallet 'balance)))))))
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		  (:form :class "form-vendor-update-balance" :role "form" :method "POST" :action "dodupdatewalletbalance"
		    (:div :class "account-wall"
			  (:div :class "form-group"
			    (:input :class "form-control" :name "balance" :placeholder "recharge amount" :type "text" ))
			  (:input :class "form-control" :name "wallet-id" :value (slot-value wallet 'row-id) :type "hidden")
			   (:input :class "form-control" :name "phone" :value phone :type "hidden")
			  (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))
(hunchentoot:redirect "/hhub/vendor-login.html"))))


(defun dod-controller-update-wallet-balance ()
  (if (is-dod-vend-session-valid?)
  (let* ((amount (parse-integer (hunchentoot:parameter "balance")))
	 (phone (hunchentoot:parameter "phone"))
	(wallet (get-cust-wallet-by-id (hunchentoot:parameter "wallet-id") (get-login-vendor-company)))
	(current-balance (slot-value wallet 'balance))
	(latest-balance (+ current-balance amount)))
    (set-wallet-balance latest-balance wallet)
    (hunchentoot:redirect (format nil "/hhub/dodsearchcustwalletaction?phone=~A" phone)))
  ;else 
  (hunchentoot:redirect "/hhub/vendor-login.html")))
    
	
	
   
   
(defun dod-controller-vend-profile ()
(if (is-dod-vend-session-valid?)
    (standard-vendor-page (:title "Welcome to Highrisehub")
       (:h3 "Welcome " (str (format nil "~A" (get-login-vendor-name))))
       (:form :class "form-update-wallet" :method "POST" :action "dodsearchcustwalletpage"
	      (:div :class "row"
		     (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		     (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Recharge Customer Wallet")))))
    (hunchentoot:redirect "vendor-login.html")))




(defmacro standard-vendor-page ((&key title) &body body)
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
 		 (:link :href "css/theme.css" :rel "stylesheet")
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "js/spin.min.js")
		 ) ;; Header completes here.
	     (:body
		 (:div :id "dod-main-container"
		 (:div :id "dod-error" (:h2 "Error..."))
		 (:div :id "busy-indicator")
		 (if (is-dod-vend-session-valid?) (vendor-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		     (:div :id "header"	; DOD System header
			 ,@body))	;container div close
		 ;; Rangeslider
		 (:script :src "js/nouislider.min.js")
		 (:script :src "js/dod.js")
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js"))))))


(defmacro vendor-navigation-bar ()
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
			 (:li :class "active" :align "center" (:a :href "dodvendindex" "Home"))
			 (:li :align "center" (:a :href "dodvenproducts"  "My Products"))
			 (:li :align "cener"  (:a :href "dodvendindex?context=pendingorders"  "Pending Orders"))
			 (:li :align "center" (:a :href "dodvendindex?context=completedorders"  "Completed Orders"))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "dodvendprofile" "My Profile" )) 
			 (:li :align "center" (:a :href "https://goo.gl/forms/XaZdzF30Z6K43gQm2" "Feedback" ))
			     (:li :align "center" (:a :href "https://goo.gl/forms/SGizZXYwXDUiTgVY2" (:span :class "glyphicon glyphicon-bug") "Bug" ))
			     (:li :align "center" (:a :href "dodvendlogout"  (:span :class "glyphicon glyphicon-off") " Logout "  ))))))))

(defun dod-controller-vend-login ()
  (let  ((phone (hunchentoot:parameter "phone"))
	 (password (hunchentoot:parameter "password")))
    (unless (and  ( or (null phone) (zerop (length phone)))
		  (or (null password) (zerop (length password))))
      (if (equal (dod-vend-login  :phone phone :password password) NIL) 
	  (hunchentoot:redirect "/hhub/vendor-login.html")
	  ;else
	  (hunchentoot:redirect "/hhub/dodvendindex")))))



(defun dod-vend-login (&key  phone password)
  (let* ((vendor (car (clsql:select 'dod-vend-profile :where [and
				   [= [slot-value 'dod-vend-profile 'phone] phone]
				   [= [:deleted-state] "N"]]
				   :caching nil :flatp t)))
	(pwd (if vendor (slot-value vendor 'password)))
	(salt (if vendor (slot-value vendor 'salt)))
	(password-verified (if vendor  (check-password password salt pwd)))
	(vendor-id (if vendor (slot-value vendor 'row-id)))
	(vendor-name (if vendor (slot-value vendor 'name)))
	(vendor-tenant-id (if vendor (slot-value (car  (vendor-company vendor)) 'row-id)))
	(vendor-company-name (if vendor (slot-value (car (if vendor (vendor-company vendor))) 'name)))
	(vendor-company (if vendor (car (vendor-company vendor))))
	(log (if password-verified (hunchentoot:log-message* :info (format nil  "phone : ~A password : ~A" phone password)))))
	 
	
   (when (and  vendor
	       password-verified
	       (null (hunchentoot:session-value :login-vendor-name))) ;; vendor should not be logged-in in the first place.
     (progn
       (format T "Starting session")
        
       (setf *current-vendor-session* (hunchentoot:start-session))
       (setf (hunchentoot:session-value :login-vendor ) vendor)
       (setf (hunchentoot:session-value :login-vendor-name) vendor-name)
       (setf (hunchentoot:session-value :login-vendor-id) vendor-id)
       (setf (hunchentoot:session-value :login-vendor-tenant-id) vendor-tenant-id)
       (setf (hunchentoot:session-value :login-vendor-company-name) vendor-company-name)
       (setf (hunchentoot:session-value :login-vendor-company) vendor-company)
       (setf (hunchentoot:session-value :login-prd-cache )  (select-products-by-company vendor-company))
       (setf (hunchentoot:session-value :order-func-list) (dod-gen-order-functions vendor))
       (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions vendor))
       
       ))))

(defun dod-controller-vendor-products ()
(let ((vendor-products-func (first (hunchentoot:session-value :login-vendor-products-functions))))
  (standard-vendor-page (:title "Welcome to Dairy Ondemand - vendor")
    (ui-list-vendor-products (funcall vendor-products-func)))))

(defun dod-gen-vendor-products-functions (vendor)
  (let ((vendor-products (select-products-by-vendor vendor (get-login-vendor-company))))
    (list (function (lambda () vendor-products)))))

(defun dod-gen-order-functions (vendor)
(let ((pending-orders (get-orders-for-vendor vendor ))
      (completed-orders (get-orders-for-vendor vendor "Y"))
       (all-order-items (get-order-items-for-vendor  vendor)))

  (list (function (lambda () pending-orders ))
	(function (lambda () completed-orders))
	(function (lambda () all-order-items)))))



(defun dod-reset-order-functions (vendor)
  (let ((order-func-list (dod-gen-order-functions vendor)))
    (setf (hunchentoot:session-value :order-func-list) order-func-list)))


(defun dod-get-cached-pending-orders()
  (let ((pending-orders-func (first (hunchentoot:session-value :order-func-list))))
    (funcall pending-orders-func)))

(defun dod-get-cached-completed-orders ()
  (let ((completed-orders-func (second (hunchentoot:session-value :order-func-list))))
    (funcall completed-orders-func)))

(defun dod-get-cached-order-items-by-order-id (order)
(let* ((order-items-func (third (hunchentoot:session-value :order-func-list)))
      (order-items (funcall order-items-func))
      (order-id (slot-value order 'row-id)))
 (remove nil (mapcar (lambda (item)
	    (if (equal (slot-value item 'order-id) order-id) item)) order-items))))






(defun dod-controller-vend-index () 
    (if (is-dod-vend-session-valid?)
	(let (( dodorders (dod-get-cached-pending-orders ))
		 (btnordprd (hunchentoot:parameter "btnordprd"))
		 (reqdate (hunchentoot:parameter "reqdate"))
		 (btnexpexl (hunchentoot:parameter "btnexpexl"))
		 (context (hunchentoot:parameter "context"))
		 (btnordcus (hunchentoot:parameter "btnordcus")))
	(standard-vendor-page (:title "Welcome to Dairy Ondemand - vendor")
	    (:h3 "Welcome " (str (format nil "~A" (get-login-vendor-name))))
	    (:form :class "form-venorders" :method "POST" :action "dodvendindex"
		(:div :class "row" :style "display: none"
		(:div :class "btn-group" :role "group" :aria-label "..."
		(:button  :name "btnpendord" :type "submit" :class "btn btn-default active" "Pending Orders" )
		(:button  :name "btnordcomp" :type "submit" :class "btn btn-default" "Completed Orders")))
	   ; (:hr)
	    (:div :class "row" :style "display: none"
		(:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12" 
			(:input :type "text" :name "reqdate" :placeholder "yyyy/mm/dd")
			(:button :class "btn btn-primary" :type "submit" :name "btnordprd" "Get Orders by Products")
			(:button :class "btn btn-primary" :type "submit" :name "btnordcus" "Get Orders by Customers")
			(if (and reqdate dodorders)
			(htm (:a :href (format nil "/dodvenexpexl?reqdate=~A" (cl-who:escape-string reqdate)) :class "btn btn-primary" "Export To Excel")))
			(:button :class "btn btn-primary"  :type "submit" :name "btnprint" :onclick "javascript:window.print();" "Print") 
		   )))
	   ; (:hr)
	    (cond ((and dodorders btnordprd) (ui-list-vendor-orders dodorders))
		((and dodorders btnexpexl) (hunchentoot:redirect (format nil "/hhub/dodvenexpexl?reqdate=~A" reqdate)))
		((and dodorders btnordcus) (ui-list-vendor-orders-by-customers dodorders (get-login-vendor)))
		((equal context "pendingorders") 
		 (progn ()
			(ui-list-vendor-orders-tiles dodorders)))
		((equal context "completedorders") (let ((orders (dod-get-cached-completed-orders)))
						(ui-list-vendor-orders-tiles orders)))
		(T ()) )))
					; Else
	(hunchentoot:redirect "/hhub/vendor-login.html")))




(defun dod-controller-ven-order-fulfilled ()
    (if (is-dod-vend-session-valid?)
	(let* ((id (hunchentoot:parameter "id"))
	       (company-instance (hunchentoot:session-value :login-vendor-company))
	       (order-instance (get-order-by-id id company-instance))
	       (customer (get-ord-customer order-instance)) 
	       (vendor (get-login-vendor))
	       (wallet (get-cust-wallet-by-vendor customer vendor company-instance))
	       (vendor-order-items (get-order-items-for-vendor-by-order-id  order-instance (get-login-vendor) )))
	  (if (check-wallet-balance (get-order-items-total-for-vendor vendor  vendor-order-items) wallet)
	      (progn (set-order-fulfilled "Y"  order-instance company-instance)
	       (hunchentoot:redirect "/hhub/dodvendindex?context=completedorders"))
	      ;else 
	      (display-wallet-for-customer wallet "Not enough balance for the transaction.")))
	(hunchentoot:redirect "/hhub/vendor-login.html")))


(defun display-wallet-for-customer (wallet-instance custom-message)
  (standard-vendor-page (:title "Wallet Display")
    (wallet-card wallet-instance custom-message)))

(defun dod-controller-ven-expexl ()
    (if (is-dod-vend-session-valid?)
	(let ((header (list "Product " "Quantity" "Qty per unit" "Unit Price" ""))
		 (reqdate (hunchentoot:parameter "reqdate"))
		 (vendor-instance (get-login-vendor))
		 ( dodorders (get-orders-by-date (hunchentoot:parameter "reqdate") (get-login-vendor-company))))
	    (setf (hunchentoot:content-type*) "application/vnd.ms-excel")
	    (setf (header-out "Content-Disposition" ) (format nil "inline; filename=Orders_~A.csv" reqdate))
	(ui-list-orders-for-excel header dodorders vendor-instance))
    (hunchentoot:redirect "/hhub/vendor-login.html")))



(defun get-login-vendor ()
    :documentation "Get the login session for vendor"
    (hunchentoot:session-value :login-vendor ))
(defun get-login-vendor-name ()
    :documentation "Get the login vendor name"
    (hunchentoot:session-value :login-vendor-name))

(defun get-login-vend-company ()
    :documentation "Get the login vendor company."
    ( hunchentoot:session-value :login-vendor-company))

(defun is-dod-vend-session-valid? ()
    :documentation "Checks whether the current login session is valid or not."
    (if  (null (get-login-vend-name)) NIL T))

(defun get-login-vend-name ()
    :documentation "Gets the name of the currently logged in vendor"
    (hunchentoot:session-value :login-vendor-name))


(defun dod-controller-vendor-logout ()
    :documentation "Vendor logout."
    (progn (hunchentoot:remove-session *current-vendor-session*)
	(hunchentoot:redirect "/index.html")))




(defun vendor-details-card (vendor-instance)
    (let ((vend-name (slot-value vendor-instance 'name))
	     (vend-address  (slot-value vendor-instance 'address))
	     (phone (slot-value vendor-instance 'phone)))
	(cl-who:with-html-output (*standard-output* nil)
		(:h4 (str vend-name) )
	    (:div (str vend-address))
		(:div  (str phone)))))
		  




(defun dod-controller-vendor-orderdetails ()
    (if (is-dod-vend-session-valid?)
	(standard-vendor-page (:title "List Vendor Order Details")   
	    (let* (( dodvenorder (get-vendor-orders-by-orderid (hunchentoot:parameter "id") (get-login-vendor-company)))
		   (venorderfulfilled (slot-value dodvenorder 'fulfilled))
		   (order (get-order-by-id (hunchentoot:parameter "id") (get-login-vendor-company)))
		   (header (list "Product" "Product Qty" "Unit Price"  "Sub-total"))
		      (odtlst (dod-get-cached-order-items-by-order-id order) )
      		  
		   (total   (reduce #'+  (mapcar (lambda (odt)
			(* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst))))
		(display-order-header order) 
		(if odtlst (ui-list-vend-orderdetails header odtlst) "No order details")
					    (htm(:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))
				    (if (equal venorderfulfilled "Y") 
					(htm (:span :class "label label-info" "FULFILLED"))
					;ELSE
					(htm  (:a :href (format nil "dodvenordfulfilled?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Set Order Completed"))))
					;ELSE
					
						    )))))
	(hunchentoot:redirect "/hhub/vendor-login.html")))



(defun ui-list-vend-orderdetails (header data)
    (cl-who:with-html-output (*standard-output* nil)

	(:h3 "Order Details") 
	(:table :class "table table-striped"  (:thead (:tr
							  (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
														       (mapcar (lambda (odt)
																   (let ((odt-product  (get-odt-product odt))
																	    (unit-price (slot-value odt 'unit-price))
																	    (prd-qty (slot-value odt 'prd-qty)))
																	    (htm (:tr (:td  :height "12px" (str (slot-value odt-product 'prd-name)))
																		(:td  :height "12px" (str (format nil  "~d" prd-qty)))
																		(:td  :height "12px" (str (format nil  "Rs. ~$" unit-price)))
																		(:td  :height "12px" (str (format nil "Rs. ~$" (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty)))))
																		)))) (if (not (typep data 'list)) (list data) data))))))
