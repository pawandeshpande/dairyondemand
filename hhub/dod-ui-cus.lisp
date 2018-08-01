(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)



(defun modal.customer-update-details ()
  (let* ((customer (get-login-customer))
	 (name (name customer))
	 (address (address customer))
	 (phone  (phone customer))
	 (email (email customer)))
	 

 (cl-who:with-html-output (*standard-output* nil)
   (:div :class "row" 
	 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
	       (:form :id (format nil "form-customerupdate")  :role "form" :method "POST" :action "hhubcustupdateaction" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
		 
		 (:h1 :class "text-center login-title"  "Update Customer Details")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "name" :value name :placeholder "Customer Name" :type "text"))
		      (:div :class "form-group"
			    (:label :for "address")
			    (:textarea :class "form-control" :name "address"  :placeholder "Enter Address ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str (format nil "~A" address))))
		      (:div :class "form-group" :id "charcount")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "phone"  :value phone  :type "text" ))
		      
		      (:div :class "form-group"
			    (:input :class "form-control" :name "email" :value email :placeholder "Email" :type "text"))
			
		      (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))

(defun dod-controller-customer-update-action ()
  (if (is-dod-cust-session-valid?)
    (let* ((name (hunchentoot:parameter "name"))
	   (address (hunchentoot:parameter "address"))
	   (phone (hunchentoot:parameter "phone"))
	   (email (hunchentoot:parameter "email"))
	   (customer (get-login-customer)))
      (setf (slot-value customer 'name) name)
      (setf (slot-value customer 'address) address)
      (setf (slot-value customer 'phone) phone)
      (setf (slot-value customer 'email) email)
      (update-customer customer)
      (hunchentoot:redirect "/hhub/dodcustprofile"))
    ;else
    (hunchentoot:redirect "/hhub/customer-login.html")))
      

  

(defun dod-controller-customer-profile ()
(if (is-dod-cust-session-valid?)
    (standard-customer-page (:title "welcome to highrisehub - customer")
       (:h3 "Welcome " (str (format nil "~a" (get-login-cust-name))))
       (:hr)
       (:div :class "list-group col-sm-6 col-md-6 col-lg-6 col-xs-12"
	     (:a :class "list-group-item" :data-toggle "modal" :data-target (format nil "#dodcustupdate-modal")  :href "#"  "Contact Info")
	     (modal-dialog (format nil "dodcustupdate-modal") "Update Customer" (modal.customer-update-details)) 
	     (:a :class "list-group-item" :href "#" "Settings")
	     (:a :class "list-group-item" :href "https://goo.gl/forms/hI9LIM9ebPSFwOrm1" "Feature Wishlist")
	     (:a :class "list-group-item" :href "https://goo.gl/forms/3iWb2BczvODhQiWW2" "Report Issues")))
    (hunchentoot:redirect "/hhub/customer-login.html")))



(defun get-login-customer ()
    :documentation "get the login session for customer"
    (hunchentoot:session-value :login-customer ))

(defun get-login-customer-id ()
  :documentation "get login customer id"
  (hunchentoot:session-value :login-customer-id))


(defun get-login-cust-company ()
    :documentation "get the login customer company."
    ( hunchentoot:session-value :login-customer-company))

(defun is-dod-cust-session-valid? ()
    :documentation "checks whether the current login session is valid or not."
	(if (null (get-login-cust-name)) nil t))

;    (handler-case 
	;expression
;	(if (not (null (get-login-cust-name)))
;	       (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) t))	      
        ; handle this condition
   
 ;     (clsql:sql-database-data-error (condition)
;	  (if (equal (clsql:sql-error-error-id condition) 2006 ) (clsql:reconnect :database *dod-db-instance*)))
;      (clsql:sql-fatal-error (errorinst) (if (equal (clsql:sql-error-database-message errorinst) "database is closed.") 
;					     (progn (clsql:stop-sql-recording :type :both)
;					            (clsql:disconnect) 
;						    (crm-db-connect :servername *crm-database-server* :strdb *crm-database-name* :strusr *crm-database-user*  :strpwd *crm-database-password* :strdbtype :mysql))))))
      

(defun get-login-cust-name ()
    :documentation "gets the name of the currently logged in customer"
    (hunchentoot:session-value :login-customer-name))

(defun dod-controller-customer-logout ()
    :documentation "customer logout."
    (progn (hunchentoot:remove-session *current-customer-session*)
	(hunchentoot:redirect "/index.html")))

(defun dod-controller-list-customers ()
    :documentation "a callback function which prints a list of customers in html format."
    (if (is-dod-session-valid?)
	(let (( dodcustomers (list-cust-profiles (get-login-company)))
		 (header (list "name" "address" "phone"  "action")))
	    (if dodcustomers (ui-list-customers header dodcustomers) "no customers"))
	(hunchentoot:redirect "/hhub/opr-login.html")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; das-cust-page-with-tiles;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun das-cust-page-with-tiles (displayfunc pagetitle &rest args)
:documentation "this is a standard higher order function which takes the display function as argument and displays the information"
(if (is-dod-cust-session-valid?)
    (standard-customer-page (:title pagetitle) 
    (apply displayfunc args))
(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-my-orderprefs ()
 :documentation "a callback function which prints daily order preferences for a logged in customer in html format." 
 (let (( dodorderprefs (hunchentoot:session-value :login-cusopf-cache))
	(header (list   "product"  "day"  "qty" "qty per unit" "price"  "actions")))
  (das-cust-page-with-tiles 'ui-list-cust-orderprefs "customer order preferences" header dodorderprefs)))



(defun dod-controller-cust-wallet-display ()
:documentation "a callback function which displays the wallets for a customer" 
(let* ((company (hunchentoot:session-value :login-customer-company))
      (customer (hunchentoot:session-value :login-customer))
      (wallets (get-cust-wallets customer company)))
       
(das-cust-page-with-tiles 'list-customer-wallets "Customer Wallets" wallets)))



(defun wallet-card (wallet-instance custom-message)
    (let ((customer (get-customer wallet-instance))
	  
	  (balance (slot-value wallet-instance 'balance)) 
	  (lowbalancep (if (check-low-wallet-balance wallet-instance) t nil)))

	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "wallet-box"
		(:div :class "row"
		      (:div :class "col-sm-6"  (:h3  (str (format nil "customer: ~a " (slot-value customer 'name)))))
		(:div :class "col-sm-6"  (:h3  (str (format nil "ph:  ~a " (slot-value customer 'phone))))))
		(:div :class "row"
		(if lowbalancep 
		   (htm  (:div :class "col-sm-6 " (:h4 (:span :class "label label-warning" (str (format nil "rs ~$ - low balance. please recharge the  wallet."  balance))))))
					   ;else
		   (htm (:div :class "col-sm-3"  (:h4 (:span :class "label label-info" (str (format nil "balance: rs. ~$"  balance))))))))
		(:div :class "row"
		(:form :class "cust-wallet-recharge-form" :method "post" :action "dodsearchcustwalletaction"
				(:input :class "form-control" :name "phone" :type "hidden" :value (str (format nil "~a" (slot-value customer 'phone))))
				(:div :class "col-sm-3" (:div :class "form-group"
			      (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "recharge")))))
		(:div :class "row"
		      (:div :class "col-sm-6"  (:h3  (str (format nil " ~a " custom-message)))))))))
		



(defun list-customer-wallets (wallets)
(let ((header (list "Vendor" "Phone" "Balance" "Recharge")))
  (cl-who:with-html-output (*standard-output* nil)
      (:h3 "My Wallets.")      
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) 
	      (:tbody
	       (mapcar (lambda (wallet)
			 (let ((vendor (slot-value wallet 'vendor))
			       (balance (slot-value wallet 'balance))
			       (wallet-id (slot-value wallet 'row-id))
			       (lowbalancep (if (check-low-wallet-balance wallet) t nil)))
			   (htm (:tr
				 (:td  :height "12px" (str (slot-value vendor  'name)))
				  (:td  :height "12px" (str (slot-value vendor  'phone)))
				  
				  (if lowbalancep
				      (htm (:td :height "12px" (:h4 (:span :class "label label-danger" (str (format nil "Rs. ~$ " balance))))))
				      ;else
				      (htm (:td :height "12px" (str (format nil "Rs. ~$ " balance)))))
				 
				  (:td :height "12px" 
				       (:a  :class "btn btn-primary" :role "button" :data-toggle "modal" :href (format nil "/hhub/dasmakepaymentrequest?amount=500&wallet-id=~A" wallet-id)  "500")
				   
					; Recharge 1500 
				        
				       (:a  :class "btn btn-primary" :role "button"  :href (format nil "/hhub/dasmakepaymentrequest?amount=1000&wallet-id=~A" wallet-id) "1000"))

				  
				  
				  
				  )))) wallets))))))




(defun list-customer-low-wallet-balance (wallets order-items-totals)
(let ((header (list "Vendor" "Phone" "Balance" "Order Items Total"  "Recharge")))
  (cl-who:with-html-output (*standard-output* nil)
      (:h3 "My Wallets.")      
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) 
	      (:tbody
	       (mapcar (lambda (wallet order-item-total)
			 (let* ((vendor (slot-value wallet 'vendor))
			       (balance (slot-value wallet 'balance))
			       (wallet-id (slot-value wallet 'row-id))
			       (lowbalancep (or (if (check-low-wallet-balance wallet) t nil)
						(< balance order-item-total))))
			   (htm (:tr
				 (:td  :height "12px" (str (slot-value vendor  'name)))
				  (:td  :height "12px" (str (slot-value vendor  'phone)))
				  
				  (if lowbalancep
				      (htm (:td :height "12px" (:h4 (:span :class "label label-danger" (str (format nil "Rs. ~$ " balance))))))
				      ;else
				      (htm (:td :height "12px" (str (format nil "Rs. ~$ " balance)))))
				
				  (:td :height "12px" (str (format nil "Rs. ~$ " order-item-total)))
				  
				  (:td :height "12px" 
				       (:a  :class "btn btn-primary" :role "button" :data-toggle "modal" :href (format nil "/hhub/dasmakepaymentrequest?amount=500&wallet-id=~A" wallet-id)  "500")
				   
					; Recharge 1500 
				        
				       (:a  :class "btn btn-primary" :role "button"  :href (format nil "/hhub/dasmakepaymentrequest?amount=1000&wallet-id=~A" wallet-id) "1000"))

				  
				  
				  
				  )))) wallets order-items-totals))))))






(defun dod-controller-del-opref ()
    :documentation "delete order preference"
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
    :documentation "a callback function which prints orders for a logged in customer in html format."
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "list dod customer orders")   
	  (:ul :class "nav nav-pills" 
	       (:li :role "presentation" :class "active" (:a :href "dodmyorders" (:span :class "glyphicon glyphicon-th-list")))
	       (:li :role "presentation" :class "active" (:a :href "dodcustorderscal" (:span :class "glyphicon glyphicon-calendar")))
	       (:li :role "presentation" :class "active" (:a :href "dodcustindex" "Shop Now")))

	  (let (( dodorders (hunchentoot:session-value :login-cusord-cache))
		     (header (list  "order no" "order date" "request date"  "actions")))
	    (if dodorders (ui-list-customer-orders header dodorders) "no orders")))
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-cust-order-data-json ()
 (if (is-dod-cust-session-valid?)
  (let ((templist '())
	(appendlist '())
	(mylist '())
	(dodorders (hunchentoot:session-value :login-cusord-cache)))
	
    (setf (hunchentoot:content-type*) "application/json")
    
    (mapcar (lambda (order) 
	      (let* ((reqdate (slot-value order 'req-date))
		    (fulfilled (slot-value order 'order-fulfilled))
		    (id (slot-value order 'row-id)))
	 (progn 
	   (setf templist (acons "start"  (format nil "~A" (* 1000 (universal-to-unix-time (get-universal-time-from-date reqdate )))) templist))
	   (setf templist (acons "end"  (format nil "~A" (* 1000 (universal-to-unix-time (get-universal-time-from-date reqdate)))) templist))
	   (if (equal fulfilled "Y")
	       (progn (setf templist (acons "title" (format nil "Order ~A (Completed)" id)  templist))
		      (setf templist (acons "class" "event-success" templist)))
	   ;else
	       (progn (setf templist (acons "title" (format nil "Order ~A (Pending)" id)  templist))
		      (setf templist (acons "class" "event-warning" templist))))
	   (setf templist (acons "url" (format nil "dodmyorderdetails?id=~A" id )  templist))
	   (setf templist (acons "id" (format nil "~A" id) templist))
	   
	   (setf appendlist (append appendlist (list templist))) 
	   (setf templist nil)))) dodorders)
	  
           
    (setf mylist (acons "result" appendlist  mylist))    
    (setf mylist (acons "success" 1 mylist))
    (json:encode-json-to-string mylist))
  ;else
	(hunchentoot:redirect "/hhub/customer-login.html")))
    

(defun dod-controller-cust-orders-calendar ()
  (if (is-dod-cust-session-valid?)
  (standard-customer-page (:title "list dod customer orders")   
     (:link :href "css/calendar.css" :rel "stylesheet")
 (:ul :class "nav nav-pills" 
	       (:li :role "presentation" :class "active" (:a :href "dodmyorders" (:span :class "glyphicon glyphicon-th-list")))
	       (:li :role "presentation" :class "active" (:a :href "dodcustorderscal" (:span :class "glyphicon glyphicon-calendar")))
	       (:li :role "presentation" :class "active" (:a :href "dodcustindex" "Shop Now")))
 
     
     (:div :class "container"
	   (:div :class "page-header"
		 (:div :class "pull-right form-inline"
		       (:div :class "btn-group"
			     (:button :class "btn btn-primary" :data-calendar-nav "prev" "<< Prev")
			     (:button :class "btn btn-default" :data-calendar-nav "today" "Today")
			     (:button :class "btn btn-primary" :data-calendar-nav "next" "Next >>"))
		       		       
		       (:h3)))
	   (:div :class "row"
		 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		       (:div :id "calendar"))))
     
     (:script :type "text/javascript" :src "js/underscore-min.js")
     (:script :type "text/javascript" :src "js/calendar.js")
     (:script :type "text/javascript" :src "js/app.js"))
;else
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-my-orders1 ()
    :documentation "a callback function which prints orders for a logged in customer in html format."
    (let (( dodorders (hunchentoot:session-value :login-cusord-cache)))
      (setf (hunchentoot:content-type*) "application/json")
      (json:encode-json-to-string (get-date-string (slot-value (first dodorders) 'req-date)))))
      ;(standard-customer-page (:title "list dod customer orders")   
      ;(if dodorders (mapcar (lambda (ord)
			   ;   (json:encode-json-to-string (get-date-string (slot-value ord 'req-date)))) dodorders))))
					;(str (format nil "\"~a\"," (get-date-string (slot-value ord 'req-date))))) dodorders)))))



(defun dod-controller-del-order()
    (if (is-dod-cust-session-valid?)
	    (let* ((order-id (parse-integer (hunchentoot:parameter "id")))
		  (cust (hunchentoot:session-value :login-customer))
		  (company (hunchentoot:session-value :login-customer-company))
		  (dodorder (get-order-by-id order-id company)))

		(delete-order dodorder)
		(setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
		(hunchentoot:redirect "/hhub/dodmyorders"))
					;else
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-vendor-details ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "vendor details")
	    (let ((vendor (select-vendor-by-id  (hunchentoot:parameter "id") )))
		(vendor-details-card vendor)))
	(hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-del-cust-ord-item ()
  (if (is-dod-cust-session-valid?)
      (let* ((order-id (parse-integer (hunchentoot:parameter "ord")))
	     (redirect-url (format nil "/hhub/dodmyorderdetails?id=~a" order-id))
	     (item-id (parse-integer (hunchentoot:parameter "id")))
	     (company (hunchentoot:session-value :login-customer-company))
	     (order (get-order-by-id order-id company)))
     
					; delete the order item. 
	(delete-order-items (list item-id) company)
	
	; get the new order items list and find out the total. update the order with this new amount.
	(let* ((odtlst (get-order-items order))
	       (vendors (get-vendors-by-orderid order-id company))
	       (custordertotal (if odtlst (reduce #'+ (mapcar (lambda (odt) (* (slot-value odt 'prd-qty) (slot-value odt 'unit-price))) odtlst )) 0))) 
	  
	  ; for each vendor, delete vendor-order if the order items total for that vendor is 0. 
	  (mapcar (lambda (vendor) 
		    (let ((vendororder (get-vendor-orders-by-orderid order-id vendor company))
			  (vendorordertotal (get-order-items-total-for-vendor vendor odtlst)))
		      (if (equal vendorordertotal 0)
			  (delete-order vendororder)))) vendors)
	  
	  (setf (slot-value order 'order-amt) custordertotal)
	  (update-order order)
	  
	  (if (equal custordertotal 0) 
	      (delete-order order))
					;(sleep 1) 
	  (setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer (get-login-customer)))) 
	     
      (hunchentoot:redirect redirect-url))
      ;else
      (hunchentoot:redirect "/hhub/customer-login.html")))
	    

	    

(defun dod-controller-my-orderdetails ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "list dod customer orders")   
	    (let* ((order-id (parse-integer (hunchentoot:parameter "id")))
		   ( dodorder (get-order-by-id order-id (get-login-cust-company)))
		   (header (list "status" "action" "name" "qty"   "sub-total" ))
		   (odtlst (get-order-items dodorder))
		   (total (reduce #'+ (mapcar (lambda (odt) (* (slot-value odt 'prd-qty) (slot-value odt 'unit-price))) odtlst)))) 
    
		(display-order-header-for-customer  dodorder) 
		(if odtlst (ui-list-cust-orderdetails header odtlst) "no order details")
		 (htm (:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total)))))))			    
		
		))
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun ui-list-customers (header data)
    (standard-page (:title "list dod customers")
	(:h3 "customers") 
	(:table :class "table table-striped"  (:thead (:tr
							  (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
														       (mapcar (lambda (customer)
																   (htm (:tr (:td  :height "12px" (str (slot-value customer 'name)))
																	    (:td  :height "12px" (str (slot-value customer 'address)))
																	    (:td  :height "12px" (str (slot-value customer 'phone)))
																    (:td :height "12px" (:a :href  (format nil  "delcustomer?id=~a" (slot-value customer 'row-id)):onclick "return false"  "delete"))))) data)))))
									  


(defun dod-controller-search-products ()
(let* ((search-clause (hunchentoot:parameter "livesearch"))
      (products (if (not (equal "" search-clause)) (search-products search-clause (get-login-cust-company))))
      (shoppingcart (hunchentoot:session-value :login-shopping-cart)))
(ui-list-customer-products  products shoppingcart)))





(defmacro customer-navigation-bar ()
    :documentation "this macro returns the html text for generating a navigation bar using bootstrap."
    `(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-inverse  navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navheadercollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "highrisehub" (:img :style "width: 50px; height: 50px;" :src "resources/logo.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navheadercollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/hhub/dodcustindex" (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li :align "center" (:a :href "dodcustorderprefs" "Subscriptions"))
			 (:li :align "center" (:a :href "dodcustorderscal" "Orders"))
			 (:li :align "center" (:a :href "dodcustwallet" (:span :class "glyphicon glyphicon-piggy-bank") " Wallets" ))
			 ;(:li :align "center" (:a :href "#" (print-web-session-timeout)))
			  (:li :align "center" (:a :href "#" (str (format nil "Group: ~a" (get-login-customer-company-name))))))
		     
		     (:ul :class "nav navbar-nav navbar-right"
			 
			   (:li :align "center" (:a :href "dodcustprofile"   (:span :class "glyphicon glyphicon-user") " Profile" )) 
			
	;(:li :align "center" (:a :href "/dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " my cart " (:span :class "badge" (str (format nil " ~a " (length (hunchentoot:session-value :login-shopping-cart)))) )))
			 (:li :align "center" (:a :href "dodcustlogout" (:span :class "glyphicon glyphicon-off")  ))))))))
    



(defmacro standard-customer-page ((&key title) &body body)
 `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	 (:html :xmlns "http://www.w3.org/1999/xhtml"
	     :xml\:lang "en" 
	     :lang "en"
	     (:head 
		 (:meta :http-equiv "content-type" 
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
		 ;; js files
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "https://code.jquery.com/ui/1.12.0/jquery-ui.min.js")
		 (:script :src "js/spin.min.js")
		 (:script :src "https://www.google.com/recaptcha/api.js")
		 ) ;; header completes here.
	     (:body
		 (:div :id "dod-main-container"
		     (:a :href "#" :class "scrollup" :style "display: none;") 
		 (:div :id "dod-error" (:h2 "error..."))
		 (:div :id "busy-indicator")
		 (if (is-dod-cust-session-valid?) (customer-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		   (:div :id "header"  ,@body))
		       		 ;; rangeslider
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js")
		  (:script :src "js/dod.js"))))))

;**********************************************************************************
;***************** customer login related functions ******************************

(defun dod-controller-cust-apt-no ()
 (let ((cname (hunchentoot:parameter "cname")))
   (standard-customer-page (:title "welcome to das platform - your demand and supply destination.")
     (:form :class "form-custresister" :role "form" :method "post" :action "dodcustregisteraction"
	    (:div :class "row" 
		  (:div :class "col-lg-6 col-md-6 col-sm-6"
			(:div :class "form-group"
			      (:input :class "form-control" :name "address" :placeholder "Apartment No (Required)" :type "text" ))
			(:div :class "form-group"
			      (:input :class "form-control" :name "tenant-name" :value (format nil "~A" cname) :type "text" :readonly T ))))))))

			


(defun dod-controller-cust-register-page ()
  (let* ((cname (hunchentoot:parameter "cname"))
	 (company (select-company-by-name cname))
	 (cmpaddress (slot-value company 'address)))
   
    (standard-customer-page (:title "Welcome to HighriseHub Platform- Your Demand And Supply destination.")
      	(:form :class "form-custregister" :role "form" :method "POST" :action "dodcustregisteraction"
	   (:div :class "row"
			(:img :class "profile-img" :src "resources/logo.png" :alt "")
				(:h1 :class "text-center login-title"  "New Registration to HighriseHub")
				(:hr)) 
	       (:div :class "row" 
	    (:div :class "col-lg-6 col-md-6 col-sm-6"
		  (:div :class "form-group"
			(:input :class "form-control" :name "tenant-name" :value (format nil "~A" cname) :type "text" :readonly T ))
		  (:div :class "form-group" 
			(:textarea :class "form-control" :name "address"   :rows "2" :readonly T (str (format nil "~A" cmpaddress))))
		  
		   (:div  :class "form-group" (:label :for "reg-type" "Register as:" )
				    (customer-vendor-dropdown))
			   
		  (:div :class "form-group"
			(:input :class "form-control" :name "name" :placeholder "Full Name (Required)" :type "text" ))
		  (:div :class "form-group"
			(:input :class "form-control" :id "housenum" :name "housenum" :placeholder "Apt/Flat (Required)" :type "text" ))
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
       (housenum (hunchentoot:parameter "housenum"))
       (groupname (hunchentoot:parameter "tenant-name"))
       (address (hunchentoot:parameter "address"))
       (fulladdress (concatenate 'string  housenum ", " groupname ", " address)) 
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
       (sleep 1) ; Sleep for 1 second after creating the vendor record.  
       (let ((vendor (select-vendor-by-name name company)))
       (create-vendor-tenant vendor "Y" company))
					; 2
       
       (standard-customer-page (:title "Welcome to HighriseHub platform")
	 (:h3 (str(format nil "Your record has been successfully added" )))
	 (:a :href "/hhub/vendor-login.html" "Login now"))))
    
    ((and encryptedpass (equal reg-type "CUS"))  
	 (progn 
       ; 1 
       (create-customer name fulladdress phone email nil encryptedpass salt nil nil nil company)
       ; 2
       
       (standard-customer-page (:title "Welcome to HighriseHub platform")
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
     (standard-customer-page (:title "Welcome to HighriseHub platform")
	 (:h3 (str(format nil "Customer record has already been created" )))
	 (:a :href "cust-register.html" "Register new customer")))
  
    
(defun dod-controller-company-search-action ()
  (let*  ((qrystr (hunchentoot:parameter "livesearch"))
	(company-list (if (not (equal "" qrystr)) (select-companies-by-name qrystr))))
    (ui-list-companies company-list)))




(defun dod-controller-company-search-page ()
  (handler-case
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (standard-customer-page (:title "Welcome to HighriseHub platform") 
		(:div :class "row"
		      (:h2 "Search Apartment/Group")
		      (:div :id "custom-search-input"
			    (:div :class "input-group col-md-12"
				  (:form :id "theForm" :action "companysearchaction" :OnSubmit "return false;" 
					 (:input :type "text" :class "  search-query form-control" :id "livesearch" :name "livesearch" :placeholder "Search for an Apartment/Group"))
				  (:span :class "input-group-btn" (:<button :class "btn btn-danger" :type "button" 
									    (:span :class " glyphicon glyphicon-search"))))))

		(:div :id "searchresult")))
		      
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
		  (standard-customer-page (:title "Welcome to HighriseHub Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:form :class "form-custsignin" :role "form" :method "POST" :action "dodcustlogin"
				       (:div :class "account-wall"
					     (:img :class "profile-img" :src "resources/logo.png" :alt "")
					     (:h1 :class "text-center login-title"  "Customer - Login to HighriseHub")
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
	(standard-customer-page (:title "Welcome to HighriseHub- Add Customer Order preference")
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

(defun product-qty-edit-html (prd-id)
 (let* ((productlist (hunchentoot:session-value :login-prd-cache))
	 (product (search-prd-in-list prd-id  productlist))
	 (prd-image-path (slot-value product 'prd-image-path))
	(description (slot-value product 'description))
	(unit-price (slot-value product 'unit-price))
	 (prd-name (slot-value product 'prd-name)))
 
  (cl-who:with-html-output (*standard-output* nil)
   (:div :align "center" :class "row account-wall" 
	 (:div :class "col-sm-12  col-xs-12 col-md-12 col-lg-12"
	       (:form :class "form-product" :method "POST" :action "dodcustaddtocart" 
		      (:input :type "hidden" :name "prd-id" :value (format nil "~A" prd-id))
		      (:div :class "row"
		      (:div :class "col-xs-12" 	 (:h5 :class "product-name"  (str prd-name))))
		      (:div  :class "row" 
		     (:div  :class "col-xs-6" 
			     (:a :href (format nil "dodprddetailsforcust?id=~A" prd-id) 
				 (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " ")))
		     (:div  :class "col-xs-3"	(:div  (:h3 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price)))))))
		     
		      (:div :class "row" 
		      (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12" 
			    (:h6 (str (if (> (length description) 150)  (subseq description  0 150) description)))))
		
		      
	        (:div  :class "inputQty row" 
	       (:div :class "col-xs-4"
		     (:a :class "down btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-minus" ""))) 
	       (:div :class "form-group col-xs-4" 
		     (:input :class "form-control input-quantity" :readonly "true" :name "prdqty" :placeholder "Enter a number"  :value "1" :min "1" :max "99"  :type "number"))
	       (:div :class "col-xs-4"
		     (:a :class "up btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-plus" ""))))
	 
			    (:div :class "form-group" 
			    (:input :type "submit"  :class "btn btn-primary" :value "Add To Cart"))
			    ))))))
  
  
(defun product-subscribe-html (prd-id) 
  (let* ((productlist (hunchentoot:session-value :login-prd-cache))
	 (product (search-prd-in-list prd-id  productlist))
	 (prd-image-path (slot-value product 'prd-image-path))
	 (prd-name (slot-value product 'prd-name)))
    
 (cl-who:with-html-output (*standard-output* nil)
   (:div :align "center" :class "row account-wall" 
	 (:div :class "col-sm-12  col-xs-12 col-md-12 col-lg-12"
	       (:div  :class "row" 
		     (:div  :class "col-xs-12" 
			     (:a :href (format nil "dodprddetailsforcust?id=~A" prd-id) 
				 (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " "))))
			(:form :class "form-oprefadd" :role "form" :method "POST" :action "dodcustaddopfaction"
			    (:div :class "form-group row"  (:label :for "product-id" (str (format nil  " ~a" (slot-value product 'prd-name))) ))
			         (:input :type "hidden" :name "product-id" :value (format nil "~a" (slot-value product 'row-id)))
				 ; (products-dropdown "product-id"  (hunchentoot:session-value :login-prd-cache)))
				 
				 ;(:div :class "inputQty"
				  ;     (:span :class "up" "up" )
				   ;    (:input :type "text" :maxlength "6" :name "oa_quantity" :class "input-quantity"  :value "1")
				    ;   (:span :class "down" "down"))

				 (:div  :class "inputQty row" 
				 (:div :class "col-xs-4"
				  (:a :class "down btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-minus" ""))) 
				  (:div :class "form-group col-xs-4" 
				(:input :class "form-control input-quantity" :readonly "true" :name "prdqty" :placeholder "Enter a number"  :value "1" :min "1" :max "99"  :type "number"))
				  (:div :class "col-xs-4"
				  (:a :class "up btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-plus" ""))))
			    (:div :class "form-group row" 
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-mon" :value "Monday" :checked "" "Monday"))
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-tue" :value "Tuesday" :checked "" "Tuesday"))
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-wed" :value "Wednesday" :checked "" "Wednesday")))
			    (:div :class "form-group row" 
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-thu" :value "Thursday" :checked "" "Thursday"))
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-fri" :value "Friday" :checked "" "Friday"))
				  (:label :class "checkbox-inline" (:input :type "checkbox" :name "subs-sat" :value "Saturday" :checked "" "Saturday"))
				  (:label :class "checkbox-inline"  (:input :type "checkbox" :name "subs-sun"  :value "Sunday" :checked "" "Sunday" )))
			    
			    (:div :class "form-group" 
			    (:input :type "submit"  :class "btn btn-primary" :value "Subscribe"))
			    ))))))




(defun dod-controller-cust-add-order-page ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to HighriseHub- Add Customer Order")
	    (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-6 col-lg-6"
			(:h1 :class "text-center login-title"  "Customer - Add order ")
			(:form :class "form-order" :role "form" :method "POST" :action "dodmyorderaddaction"
			    (:div  :class "form-group" (:label :for "orddate" "Order Date" )
				(:input :class "form-control" :name "orddate" :value (str (get-date-string (get-date))) :type "text"  :readonly "true"  ))
			    (:div :class "form-group"  (:label :for "reqdate" "Required On - Click To Change" )
				(:input :class "form-control" :name "reqdate" :id "required-on" :placeholder  (str (format nil "~A. Click to change" (get-date-string (date+ (get-date) (make-duration :day 1))))) :type "text" :value (get-date-string (date+ (get-date) (make-duration :day 1)))))

			    ;(:div :class "form-group" (:label :for "shipaddress" "Ship Address" )
			;	(:textarea :class "form-control" :name "shipaddress" :rows "4"  (str (format nil "~A" (slot-value customer 'address)))  ))
			     (:div  :class "form-group" (:label :for "payment-mode" "Payment Mode" )
				    (payment-mode-dropdown))
			    (:input :type "submit"  :class "btn btn-primary" :value "Confirm")))))
	(hunchentoot:redirect "/hhub/customer-login.html")))




(defun dod-controller-cust-add-order-detail-page ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to HighriseHub- Add Customer Order")
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
     (htm (:select :class "form-control" :id "reg-type"  :name "reg-type"
		   (:option    :value  "CUS" :selected "true"  (str "Customer"))
		   (:option :value "VEN" (str "Vendor"))))))



;; This is company/tenant name dropdown
(defun company-dropdown (name list)
  (cl-who:with-html-output (*standard-output* nil)
    (htm (:select :class "form-control" :placeholder "Group/Apartment"  :name name 
	(loop for company in list 
	     do ( htm (:option :value (slot-value company 'row-id) (str (slot-value company 'name)))))))))

(defun dod-controller-low-wallet-balance-for-shopcart ()
  (if (is-dod-cust-session-valid?)
      (let* ((odts (hunchentoot:session-value :login-shopping-cart))
	     (vendor-list (get-shopcart-vendorlist odts))
	     (company (get-login-customer-company)) 
	     (customer (get-login-customer))
	     (wallets (mapcar (lambda (vendor) 
				(get-cust-wallet-by-vendor  customer vendor company)) vendor-list))
	     (order-items-totals (mapcar (lambda (vendor)
					   (get-order-items-total-for-vendor vendor odts)) vendor-list)))
	    	
	(standard-customer-page (:title "Low Wallet Balance")
	(:div :class "row" 
	      (:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12"
		    (:h3 (:span :class "label label-danger" "Low Wallet Balance."))))
	(list-customer-low-wallet-balance   wallets order-items-totals)
	(:a :class "btn btn-primary" :role "button" :href "dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " Modify Cart  ")))
	
      (hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-low-wallet-balance-for-orderitems ()
  (if (is-dod-cust-session-valid?)
      (let* ((item-id (hunchentoot:parameter "item-id"))
	     (prd-qty (parse-integer (hunchentoot:parameter "prd-qty")))
	     (odts  (list (get-order-item-by-id item-id)))
	     (vendor-list (get-shopcart-vendorlist odts))
	     (company (get-login-customer-company)) 
	     (customer (get-login-customer))
	     (wallets (mapcar (lambda (vendor) 
				(get-cust-wallet-by-vendor  customer vendor company)) vendor-list))
	     (order-items-totals (mapcar (lambda (vendor)
					   (if prd-qty (setf (slot-value (first odts) 'prd-qty) prd-qty))
					   (get-order-items-total-for-vendor vendor odts)) vendor-list)))
	
	(standard-customer-page (:title "Low Wallet Balance")
	(:div :class "row" 
	      (:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12"
		    (:h3 (:span :class "label label-danger" "Low Wallet Balance."))))
	(list-customer-low-wallet-balance   wallets order-items-totals)))
      (hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-cust-login ()
    (let  ( (phone (hunchentoot:parameter "phone"))
	   (password (hunchentoot:parameter "password")))
      (unless (and  ( or (null phone) (zerop (length phone)))
		    (or (null password) (zerop (length password))))
	    (if (equal (dod-cust-login  :phone phone :password password) NIL) (hunchentoot:redirect "/hhub/customer-login.html") (hunchentoot:redirect  "/hhub/dodcustindex")))))

(defun dod-controller-cust-ordersuccess ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Welcome to HighriseHub- Add Customer Order")
	    (:div :class "row"
		(:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12"
		    (htm (:h1 "Your order has been successfully placed"))
    		    (:a :class "btn btn-primary" :role "button" :href (format nil "dodmyorders") " My Orders Page"))))))


(defun com-hhub-transaction-create-order ()
 (if (is-dod-cust-session-valid?)
     (let* ((odts (hunchentoot:session-value :login-shopping-cart))
	    (products (hunchentoot:session-value :login-prd-cache))
	    (payment-mode (hunchentoot:parameter "payment-mode"))
	    (odate (get-date-from-string  (hunchentoot:parameter "orddate")))
	    (cust (hunchentoot:session-value :login-customer))
	    (shopcart-total (get-shop-cart-total))
	    (custcomp (hunchentoot:session-value :login-customer-company))
	    (vendor-list (get-shopcart-vendorlist odts))
	    (reqdate (get-date-from-string (hunchentoot:parameter "reqdate")))
	    (shipaddr (hunchentoot:parameter "shipaddress")))
       
       (with-hhub-transaction "com-hhub-transaction-create-order" 
	 (progn  
	   (if  (equal payment-mode "PRE")
					; at least one vendor wallet has low balance 
		(if (not (every #'(lambda (x) (if x T))  (mapcar (lambda (vendor) 
								   (check-wallet-balance (get-order-items-total-for-vendor vendor odts) (get-cust-wallet-by-vendor cust vendor custcomp))) vendor-list))) (hunchentoot:redirect "/hhub/dodcustlowbalanceshopcarts")))
					;(if (equal payment-mode "COD")  
	   (create-order-from-shopcart  odts products odate reqdate nil  shipaddr shopcart-total payment-mode cust custcomp)
	   (setf (hunchentoot:session-value :login-cusord-cache) (get-orders-for-customer cust))
	   (setf (hunchentoot:session-value :login-shopping-cart ) nil)
	   (hunchentoot:redirect "/hhub/dodcustordsuccess"))))
 (hunchentoot:redirect "/hhub/customer-login.html")))




(defun get-order-items-total-for-vendor (vendor order-items) 
 (let ((vendor-id (slot-value vendor 'row-id)))
  (reduce #'+ (remove nil (mapcar (lambda (item) (if (equal vendor-id (slot-value item 'vendor-id)) 
					 (* (slot-value item 'unit-price) (slot-value item 'prd-qty)))) order-items)))))

(defun get-opref-items-total-for-vendor (vendor opref-items) 
 (let ((vendor-id (slot-value vendor 'row-id)))
  (reduce #'+ (remove nil (mapcar (lambda (item) 
				    (let* ((product (get-opf-product item))
				    (vendor (product-vendor product)))
				      (if (equal vendor-id (slot-value vendor 'row-id))
					 (* (slot-value product 'unit-price) (slot-value item 'prd-qty))))) opref-items)))))


(defun filter-order-items-by-vendor (vendor order-items)
  (let ((vendor-id (slot-value vendor 'row-id)))
	(remove nil (mapcar (lambda (item) (if (equal vendor-id (slot-value item 'vendor-id)) item)) order-items))))

(defun filter-opref-items-by-vendor (vendor opref-items)
  (let ((vendor-id (slot-value vendor 'row-id)))
	(remove nil (mapcar (lambda (item) 
			      (let* ((product (get-opf-product item))
				    (vendor (product-vendor product)))
			      (if (equal vendor-id (slot-value vendor 'row-id)) item))) opref-items))))


(defun get-shop-cart-total ()
  (let* ((odts (hunchentoot:session-value :login-shopping-cart))
       (total (reduce #'+  (mapcar (lambda (odt)
	  (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odts))))
    total ))
	

(defun get-shopcart-vendorlist (shopcart-items)
(remove-duplicates  (mapcar (lambda (odt) 
	   (select-vendor-by-id (slot-value odt 'vendor-id)))  shopcart-items)
:test #'equal
:key (lambda (vendor) (slot-value vendor 'row-id)))) 

(defun get-opref-vendorlist (opreflist) 
  (remove-duplicates (mapcar (lambda (opref) 
			       (let ((product (get-opf-product opref))) 
				 (product-vendor product))) opreflist) 
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
  (let ((vendor (select-vendor-by-id (hunchentoot:parameter "vendor-id"))))
    (if vendor (create-wallet (get-login-customer) vendor (get-login-customer-company)))
    (if vendor (hunchentoot:log-message* :info "Created wallet for vendor ~A" (slot-value vendor 'name)))))

(defun dod-controller-cust-add-to-cart ()
    :documentation "This function is responsible for adding the product and product quantity to the shopping cart."
    (if (is-dod-cust-session-valid?)
	(let* ((prd-id (hunchentoot:parameter "prd-id"))
	       (prdqty (parse-integer (hunchentoot:parameter "prdqty")))
	       (productlist (hunchentoot:session-value :login-prd-cache))
		  (myshopcart (hunchentoot:session-value :login-shopping-cart))
		  (product (search-prd-in-list (parse-integer prd-id) productlist))
		  (vendor (product-vendor product))
		  (vendor-id (slot-value vendor 'row-id))
		  (wallet (get-cust-wallet-by-vendor (get-login-customer) vendor (get-login-customer-company)))
		  (odt (create-odtinst-shopcart nil product  prdqty (slot-value product 'unit-price) (hunchentoot:session-value :login-customer-company))))
	  (if (and wallet (> prdqty 0)) 
	      (progn (setf (hunchentoot:session-value :login-shopping-cart) (append (list odt)  myshopcart  ))
		     (if (length (hunchentoot:session-value :login-shopping-cart)) (hunchentoot:redirect (format nil "/hhub/dodcustindex"))))
	      ;else 
	      (hunchentoot:redirect (format nil "/hhub/createcustwallet?vendor-id=~A" vendor-id))))
	(hunchentoot:redirect "/hhub/customer-login.html")))


(defun dod-controller-prd-details-for-customer ()
    (if (is-dod-cust-session-valid?)
	(standard-customer-page (:title "Product Details")
	    (let* ((company (hunchentoot:session-value :login-customer-company))
		      (lstshopcart (hunchentoot:session-value :login-shopping-cart))
		      (product (select-product-by-id (parse-integer (hunchentoot:parameter "id")) company)))
		(product-card-with-details-for-customer product (prdinlist-p (slot-value product 'row-id)  lstshopcart))))
	(hunchentoot:redirect "/hhub/customer-login.html")))

(defun dod-controller-cust-index () 
  (if (is-dod-cust-session-valid?)
   (let ((lstshopcart (hunchentoot:session-value :login-shopping-cart))
	 (lstproducts (hunchentoot:session-value :login-prd-cache)))
					;(sleep 5)
     (standard-customer-page (:title "Welcome to HighriseHub - customer")
       (:form :id "theForm" :name "theForm" :method "POST" :action "dodsearchproducts" :onSubmit "return false"
	      (:div :class "container" 
		    (:div :class "col-lg-6 col-md-6 col-sm-12" 
			  (:div :class "input-group"
				(:input :type "text" :name "livesearch" :id "livesearch"  :class "form-control" :placeholder "Search products...")
				(:span :class "input-group-btn" (:button :class "btn btn-primary" :type "submit" "Go!" ))))
					; Display the My Cart button. 
		    (:div :class "col-lg-6 col-md-6 col-sm-6" :align "right"
			  (:a :class "btn btn-primary" :role "button" :href "dodcustshopcart" (:span :class "glyphicon glyphicon-shopping-cart") " My Cart  " (:span :class "badge" (str (format nil " ~A " (length lstshopcart))))))))
       (:hr)       
       
       (str(ui-list-customer-products lstproducts lstshopcart))))
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
			      (:div :class "col-xs-12" 
				    (ui-list-shop-cart products lstshopcart))))
		    (htm
		     (:hr)
		     (:div :class "row" 
			   (:div :class "col-xs-12" :align "right" 
				 (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total)))))
			   
			   (:div :class "col-xs-12" :align "right"
				 (:a :class "btn btn-primary" :role "button" :href (format nil "dodmyorderaddpage") "Checkout"))
			   )
		     (:hr)
		     ))
					;If condition ends here. 
		  (htm(:div :class "row" 
			    (:div :class "col-xs-12" (:span :class "label label-info"  (str (format nil " ~A Items in cart.   " lstcount)))
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
      








