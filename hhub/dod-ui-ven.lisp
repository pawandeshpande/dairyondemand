(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defvar *current-vendor-session* nil)

  

(defun dod-controller-vendor-order-cancel ()
(if (is-dod-vend-session-valid?)
  (let* ((id (hunchentoot:parameter "id"))
	(order (get-order-by-id id (get-login-vendor-company)))
	(order-id (slot-value order 'row-id)))
    (cancel-order-by-vendor order)
    (cancel-order-by-vendor (get-vendor-order-instance order-id (get-login-vendor))))
  ;else
    (hunchentoot:redirect "/hhub/vendor-login.html")))
 


(defun dod-controller-vendor-revenue ()
(if (is-dod-vend-session-valid?)
    ;list all the completed orders for Today. 
    (let* ((todaysorders (dod-get-cached-completed-orders-today))
	  (total (if todaysorders (reduce #'+ (mapcar (lambda (ord) (slot-value ord 'order-amt)) todaysorders)))))
    (standard-vendor-page (:title "Welcome to DAS Platform- Vendor")
      (:div :class "row"
	    (:div :class "col-xs-12 col-sm-4 col-md-4 col-lg-4" 
		   "Completed orders "
		  (:span :class "badge" (str (format nil " ~d " (length todaysorders))))) 
	(:div :class  "col-xs-12 col-sm-4 col-md-4 col-lg-4"  :align "right" (:h1(:span :class "label label-default" "Todays Revenue")))	  
      (:div :class  "col-xs-12 col-sm-4 col-md-4 col-lg-4"  :align "right" 
	    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))))
      (:hr)
      (ui-list-vendor-orders-tiles todaysorders)))
;else
    (hunchentoot:redirect "/hhub/vendor-login.html")))
 
(defun dod-controller-refresh-pending-orders ()
  (if (is-dod-vend-session-valid?)
      (progn 
	(dod-reset-order-functions (get-login-vendor) (get-login-vendor-company))
	(hunchentoot:redirect "/hhub/dodvendindex?context=pendingorders"))
;else
           (hunchentoot:redirect "/hhub/vendor-login.html")))

(defun dod-controller-display-vendor-tenants ()
  (if (is-dod-vend-session-valid?)
      (let* ((vendor-company (get-login-vendor-company))
	     (cmplist (hunchentoot:session-value :login-vendor-tenants)))
	   
	(standard-vendor-page (:title "Welcome to DAS Platform - Vendor")
	  (:a :class "btn btn-primary" :role "button" :href "dodvendsearchtenantpage" (:span :class "glyphicon glyphicon-shopping-cart") " Add New Tenant  ")
	  (:hr)
	  (:h5 (str (format nil "Currently logged into tenant - ~A" (slot-value vendor-company 'name))))
	  (:div :class "list-group col-sm-6 col-md-6 col-lg-6"
	 (if cmplist (mapcar (lambda (cmp)
			       (unless (equal (slot-value vendor-company 'name)  (slot-value cmp 'name))
	    (htm  (:a :class "list-group-item" :href (format nil "dodvendswitchtenant?id=~A"  (slot-value cmp 'row-id)) (str (format nil "Login to ~A " (slot-value cmp 'name))))
		  ))) cmplist)))))
      (hunchentoot:redirect "/hhub/vendor-login.html")))




(defun dod-controller-cmpsearch-for-vend-page ()
  (if (is-dod-vend-session-valid?)
      (standard-vendor-page (:title "Welcome to DAS platform") 
	(:div :class "row"
	      (:h2 "Search Apartment/Group")
	      (:div :id "custom-search-input"
		    (:div :class "input-group col-md-12"
			  (:form :id "theForm" :action "dodvendsearchtenantaction" :OnSubmit "return false;" 
				 (:input :type "text" :class "  search-query form-control" :id "livesearch" :name "livesearch" :placeholder "Search for an Apartment/Group"))
			  (:span :class "input-group-btn" (:<button :class "btn btn-danger" :type "button" 
								(:span :class " glyphicon glyphicon-search")))))
	      (:div :id "searchresult" "")))
      (hunchentoot:redirect "/hhub/vendor-login.html")))





(defun dod-controller-cmpsearch-for-vend-action ()
  (let*  ((qrystr (hunchentoot:parameter "livesearch"))
	  (matching-tenants-list (if (not (equal "" qrystr)) (select-companies-by-name qrystr)))
	  (existing-tenants-list (get-vendor-tenants-as-companies (get-login-vendor)))
	  (final-list (set-difference matching-tenants-list existing-tenants-list :test #'equal-companiesp)))
    (ui-list-cmp-for-vend-tenant final-list)))



(defun ui-list-cmp-for-vend-tenant (company-list)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
  ; (standard-customer-page (:title "Welcome to DAS Platform")
    (if company-list 
	(htm (:div :class "row-fluid"	  (mapcar (lambda (cmp)
						      (htm 
						       (:form :method "POST" :action "dodvendaddtenantaction" :id "dodvendaddtenantform" 
							      (:div :class "col-sm-4 col-lg-3 col-md-4"
								    (:div :class "form-group"
									  (:input :class "form-control" :name "cname" :type "hidden" :value (str (format nil "~A" (slot-value cmp 'name)))))
								    
								    (:div :class "form-group"
									  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" (str (format nil "~A" (slot-value cmp 'name)))))))))  company-list)))
	;else
	(htm (:div :class "col-sm-12 col-md-12 col-lg-12"
	      (:h3 "No records found"))))))



(defun dod-controller-vend-add-tenant-action ()
  (if (is-dod-vend-session-valid?)
      (let* ((cname (hunchentoot:parameter "cname"))
	     (default-flag (hunchentoot:parameter "default"))
	    (company (select-company-by-name cname)))
	(progn 
	  (if (equal default-flag "Y") 
	  (create-vendor-tenant (get-login-vendor) "Y"  company)
	  (create-vendor-tenant (get-login-vendor) "N"  company))
	  (hunchentoot:redirect "/hhub/dodvendortenants")))
      ;else
      (hunchentoot:redirect "/hhub/vendor-login.html")))





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
									  





(defun dod-controller-vendor-add-product-page ()
  (if (is-dod-vend-session-valid?)
      (let ((catglist (get-prod-cat (get-login-vendor-tenant-id))))

    (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:form :class "form-vendorprodadd" :role "form" :method "POST" :action "dodvenaddproductaction" :enctype "multipart/form-data" 
				       (:div :class "account-wall"
					     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
					     (:h1 :class "text-center login-title"  "Add new product")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "prdname" :placeholder "Enter Product Name ( max 30 characters) " :type "text" ))
					    
					     (:div :class "form-group"
						  (:label :for "description")
						  (:textarea :class "form-control" :name "description" :placeholder "Enter Product Description ( max 1000 characters) "  :rows "5" :onkeyup "countChar(this, 1000)"  ))
					      (:div :class "form-group" :id "charcount")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "prdprice" :placeholder "Price"  :type "number" :min "0.00" :max "10000.00" :step "1" ))
					    
					     (:div :class "form-group"
						   (:input :class "form-control" :name "qtyperunit" :placeholder "Quantity per unit. Ex - KG, Grams, Nos" :type "text" ))
					     (:div  :class "form-group" (:label :for "prodcatg" "Select Produt Category:" )
					     (ui-list-prod-catg-dropdown "prodcatg" catglist))
					     (:br) 
					     (:div :class "form-group" (:label :for "yesno" "Product/Service Subscription")
						   (ui-list-yes-no-dropdown))
					     (:div :class "form-group" (:label :for "prodimage" "Select Product Image:")
						   (:input :class "form-control" :name "prodimage" :placeholder "Product Image" :type "file" ))
					      (:div :class "form-group"
						   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))
(hunchentoot:redirect "/hhub/vendor-login.html")))					    
					     
		
(defun dod-controller-vendor-add-product-action ()
  (if (is-dod-vend-session-valid?)
  (let* ((prodname (hunchentoot:parameter "prdname"))
	 (description (hunchentoot:parameter "description"))
	(prodprice (parse-integer (hunchentoot:parameter "prdprice")))
	(qtyperunit (hunchentoot:parameter "qtyperunit"))
	(catg-id (hunchentoot:parameter "prodcatg"))
	 (subscriptionflag (hunchentoot:parameter "yesno"))
	(prodimageparams (hunchentoot:post-parameter "prodimage"))
	;(destructuring-bind (path file-name content-type) prodimageparams))
	 (tempfilewithpath (first prodimageparams))
	 (file-name (format nil "~A-~A" (second prodimageparams) (get-universal-time)))
	 )
	;(content-type (third prodimageparams)))
    (progn 
      (if (probe-file tempfilewithpath )
	  (rename-file tempfilewithpath (make-pathname :directory "/home/hunchentoot/dairyondemand/hhub/resources/" :name file-name)))
      (create-product prodname description (get-login-vendor) (select-prdcatg-by-id catg-id (get-login-vendor-company)) qtyperunit prodprice (format nil "resources/~A" file-name)  subscriptionflag  (get-login-vendor-company))
      (dod-reset-vendor-products-functions (get-login-vendor))
      (hunchentoot:redirect "/hhub/dodvenproducts")))

  (hunchentoot:redirect "/hhub/vendor-login.html")))

    


(defun dod-controller-vendor-loginpage ()
  (handler-case
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (if (is-dod-vend-session-valid?)
		  (hunchentoot:redirect "/hhub/dodvendindex?context=home")
		  (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:form :class "form-vendorsignin" :role "form" :method "POST" :action "dodvendlogin"
				       (:div :class "account-wall"
					     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
					     (:h1 :class "text-center login-title"  "Vendor - Login to DAS")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "phone" :placeholder "Enter RMN. Ex:9999999990" :type "text" ))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "password" :placeholder "password=demo" :type "password" ))
					     (:div :class "form-group"
						   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))
	      (clsql:sql-database-data-error (condition)
					     (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
												      (stop-das) 
												      (start-das)
												      (hunchentoot:redirect "/hhub/vendor-login.html"))))))


(defun dod-controller-vendor-search-cust-wallet-page ()
    (if (is-dod-vend-session-valid?)
    (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:form :class "form-cust-wallet-search" :role "form" :method "POST" :action "dodsearchcustwalletaction"
		    (:div :class "account-wall"
			  (:div :class "form-group"
			    (:input :class "form-control" :name "phone" :placeholder "Enter Customer Phone Number" :type "number" :size "10" ))
					
			(:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))
    (hunchentoot:redirect "/hhub/vendor-login.html")
))

(defun dod-controller-vendor-search-cust-wallet-action ()
(if (is-dod-vend-session-valid?)
  (let* ((phone (hunchentoot:parameter "phone"))
	(customer (select-customer-by-phone phone (get-login-vendor-company)))
	(wallet (if customer (get-cust-wallet-by-vendor customer (get-login-vendor) (get-login-vendor-company)))))
 
(if (null wallet) 
(standard-vendor-page (:title "Welcome to DAS Platform")
 (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 "Wallet does not exist"))))
;else
(standard-vendor-page (:title "Welcome to DAS Platform")
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Name: ~A" (if customer (slot-value customer 'name)))))))
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Phone: ~A" (if customer (slot-value customer 'phone)))))))
   (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Address: ~A" (if customer (slot-value customer 'address)))))))

  (:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Balance = Rs.~$" (if wallet (slot-value wallet 'balance) 0.00 ) )))))
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		  (:form :class "form-vendor-update-balance" :role "form" :method "POST" :action "dodupdatewalletbalance"
		    (:div :class "account-wall"
			  (:div :class "form-group"
			    (:input :class "form-control" :name "balance" :placeholder "recharge amount" :type "text" ))
			  (:input :class "form-control" :name "wallet-id" :value (if wallet (slot-value wallet 'row-id) 0.00) :type "hidden")
			   (:input :class "form-control" :name "phone" :value phone :type "hidden")
			  (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))
(hunchentoot:redirect "/hhub/vendor-login.html")))


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
       (:hr)
       (:div :class "list-group col-sm-6 col-md-6 col-lg-6"
		    (:a :class "list-group-item" :href "dodsearchcustwalletpage" "Recharge Customer Wallet")
		    (:a :class "list-group-item" :href "dodvendortenants" "My Groups")
		    (:a :class "list-group-item" :href "#" "Contact Information")
		    (:a :class "list-group-item" :href "#" "Settings")))
    (hunchentoot:redirect "/hhub/vendor-login.html")))




(defmacro standard-vendor-page ((&key title)  &body body)
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
		 (if (is-dod-vend-session-valid?) (vendor-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		     (:div :id "header"	; DOD System header
			 ,@body))	;container div close
		 
		 ;; bootstrap core javascript
		 (:script :src "js/bootstrap.min.js")
		 (:script :src "js/dod.js"))))))





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
			 (:li :class "active" :align "center" (:a :href "dodvendindex?context=home"  (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li :align "center" (:a :href "dodvenproducts"  "My Products"))
			 (:li :align "center" (:a :href "dodvendindex?context=completedorders"  "Completed Orders"))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout)))
			 (:li :align "center" (:a :href "#" (str (format nil "Tenant: ~A" (get-login-vendor-company-name))))))
		     
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "dodvendprofile"   (:span :class "glyphicon glyphicon-user") " My Profile" )) 
			 (:li :align "center" (:a :href "https://goo.gl/forms/XaZdzF30Z6K43gQm2"  (:span :class "glyphicon glyphicon-envelope") " " ))
			     (:li :align "center" (:a :href "https://goo.gl/forms/SGizZXYwXDUiTgVY2" (:span :class "glyphicon glyphicon-bug") " Bug" ))
			     (:li :align "center" (:a :href "dodvendlogout"  (:span :class "glyphicon glyphicon-off") " Logout "  ))))))))



(defun dod-controller-vend-login ()
  (let  ((phone (hunchentoot:parameter "phone"))
	 (password (hunchentoot:parameter "password")))
    (unless (and  ( or (null phone) (zerop (length phone)))
		  (or (null password) (zerop (length password))))
      (if (equal (dod-vend-login :phone  phone :password  password) NIL) 
	  (hunchentoot:redirect "/hhub/vendor-login.html")
	  ;else
	  (hunchentoot:redirect "/hhub/dodvendindex?context=home")))))



(defun dod-vend-login (&key phone password )
  (handler-case 
      (let* ((vendor (car (clsql:select 'dod-vend-profile :where [and
				   [= [slot-value 'dod-vend-profile 'phone] phone]
				   [= [:deleted-state] "N"]]
				   :caching nil :flatp t)))
	     (pwd (if vendor (slot-value vendor 'password)))
	     (salt (if vendor (slot-value vendor 'salt)))
	     (password-verified (if vendor  (check-password password salt pwd)))
	     (vendor-company (if vendor (car (vendor-company vendor)))))
					;(log (if password-verified (hunchentoot:log-message* :info (format nil  "phone : ~A password : ~A" phone password)))))
	(when (and  vendor
		    password-verified
		    (null (hunchentoot:session-value :login-vendor-name))) ;; vendor should not be logged-in in the first place.
	  (progn
	    (format T "Starting session")
	    (setf *current-vendor-session* (hunchentoot:start-session))
	    (set-vendor-session-params  vendor-company vendor))))

					;handle the exception. 
    (clsql:sql-database-data-error (condition)
      (if (equal (clsql:sql-error-error-id condition) 2006 ) 
	  (progn
	    (stop-das) 
	    (start-das)
	    (hunchentoot:redirect "/hhub/customer-login.html"))))))

(defun dod-controller-vendor-switch-tenant ()
(if (is-dod-vend-session-valid?) 
(let* ((company (select-company-by-id (hunchentoot:parameter "id")))
       (vendor (get-login-vendor)))
      
  (progn
	(set-vendor-session-params company vendor)
	(hunchentoot:redirect "/hhub/dodvendindex?context=home")))
  ;else  
(hunchentoot:redirect "/hhub/vendor-login.html")))

(defun set-vendor-session-params ( company  vendor)
 (progn 

   					;set vendor company related params 
   (setf (hunchentoot:session-value :login-vendor-tenant-id) (slot-value company 'row-id ))
   (setf (hunchentoot:session-value :login-vendor-company-name) (slot-value company 'name))
   (setf (hunchentoot:session-value :login-vendor-company) company)
   ;(setf (hunchentoot:session-value :login-prd-cache )  (select-products-by-company company))
   ;set vendor related params 
   (if vendor (setf (hunchentoot:session-value :login-vendor ) vendor))
   (if vendor (setf (hunchentoot:session-value :login-vendor-name) (slot-value vendor 'name)))
   (if vendor (setf (hunchentoot:session-value :login-vendor-id) (slot-value vendor 'row-id)))
   (if vendor (setf (hunchentoot:session-value :login-vendor-tenants) (get-vendor-tenants-as-companies vendor)))
   (if vendor (setf (hunchentoot:session-value :order-func-list) (dod-gen-order-functions vendor company)))
   (if vendor (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions vendor)))   
   (dod-reset-vendor-products-functions (get-login-vendor))))
   
   
   
(defun dod-controller-vendor-delete-product () 
 (if (is-dod-vend-session-valid?)
  (let ((id (hunchentoot:parameter "id")))
    (if (= (length (get-pending-order-items-for-vendor-by-product (select-product-by-id id (get-login-vendor-company)) (get-login-vendor))) 0)
	(progn 
	  (delete-product id (get-login-vendor-company))
	  (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor)))))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
     	(hunchentoot:redirect "/hhub/vendor-login.html"))) 

(defun dod-controller-prd-details-for-vendor ()
    (if (is-dod-vend-session-valid?)
	(standard-vendor-page (:title "Product Details")
	    (let* ((company (hunchentoot:session-value :login-vendor-company))
		   (product (select-product-by-id (parse-integer (hunchentoot:parameter "id")) company)))
		(product-card-with-details-for-vendor product)))
	(hunchentoot:redirect "/hhub/vendor-login.html")))


(defun dod-controller-vendor-deactivate-product ()
  (if (is-dod-vend-session-valid?)
  (let ((id (parse-integer (hunchentoot:parameter "id"))))
    (deactivate-product id (get-login-vendor-company))
    (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor)))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
  ;else
  (hunchentoot:redirect "/hhub/vendor-login.html")))

(defun dod-controller-vendor-activate-product ()
  (if (is-dod-vend-session-valid?)
  (let ((id (hunchentoot:parameter "id")))
    (activate-product id (get-login-vendor-company))
    (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor)))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
  ;else
  (hunchentoot:redirect "/hhub/vendor-login.html")))


(defun dod-controller-vendor-copy-product ()
) 


(defun dod-controller-vendor-products ()
(if (is-dod-vend-session-valid?)
(let ((vendor-products-func (first (hunchentoot:session-value :login-vendor-products-functions))))
  (standard-vendor-page (:title "Welcome to Dairy Ondemand - vendor")
    (ui-list-vendor-products (funcall vendor-products-func))))
;else
(hunchentoot:redirect "/hhub/vendor-login.html")))

(defun dod-gen-vendor-products-functions (vendor)
  (let ((vendor-products (select-products-by-vendor vendor (get-login-vendor-company))))
    (list (function (lambda () vendor-products)))))

(defun dod-gen-order-functions (vendor company)
(let ((pending-orders (get-orders-for-vendor vendor 500 company ))
      (completed-orders (get-orders-for-vendor vendor 500 company  "Y" ))
      (top1000-order-items (get-order-items-for-vendor  vendor 1000 company)) ; get only the top 1000 order items for efficiency. 
      (completed-orders-today (get-orders-for-vendor-by-shipped-date vendor (get-date-string-mysql (get-date)) company "Y"))) 


  (list (function (lambda () pending-orders ))
	(function (lambda () completed-orders))
	(function (lambda () top1000-order-items))
	(function (lambda () completed-orders-today)))))


(defun dod-reset-vendor-products-functions (vendor)
  (let ((vendor-products-func-list (dod-gen-vendor-products-functions vendor)))
	(setf (hunchentoot:session-value :login-vendor-products-functions) vendor-products-func-list)))



(defun dod-reset-order-functions (vendor company)
  (let ((order-func-list (dod-gen-order-functions vendor company)))
    (setf (hunchentoot:session-value :order-func-list) order-func-list)))


(defun dod-get-cached-pending-orders()
  (let ((pending-orders-func (first (hunchentoot:session-value :order-func-list))))
    (funcall pending-orders-func)))


(defun dod-get-cached-completed-orders ()
  (let ((completed-orders-func (second (hunchentoot:session-value :order-func-list))))
    (funcall completed-orders-func)))

(defun dod-get-cached-completed-orders-today ()
  (let ((completed-orders-func (fourth (hunchentoot:session-value :order-func-list))))
    (funcall completed-orders-func)))

(defun dod-get-cached-order-items-by-order-id (order)
(let* ((order-items-func (third (hunchentoot:session-value :order-func-list)))
      (order-items (funcall order-items-func))
      (order-id (slot-value order 'row-id)))
 (remove nil (mapcar (lambda (item)
	    (if (equal (slot-value item 'order-id) order-id) item)) order-items))))






(defun dod-controller-vend-index () 
   (hunchentoot:log-message* :info (if (is-dod-vend-session-valid?) (format nil  "vendor session is valid Inside vend index  " ) (format nil "vendor session is invalid")))  
  (if (is-dod-vend-session-valid?)
	
	(let (( dodorders (dod-get-cached-pending-orders ))
	      (reqdate (hunchentoot:parameter "reqdate"))
	      (btnexpexl (hunchentoot:parameter "btnexpexl"))
	      (context (hunchentoot:parameter "context"))
	      (btnordcus (hunchentoot:parameter "btnordcus")))
	     

	(standard-vendor-page (:title "Welcome to Dairy Ondemand - vendor")
	    (:h3 "Welcome " (str (format nil "~A" (get-login-vendor-name))))
	    (:hr)
	    
	    (:form :class "form-venorders" :method "POST" :action "dodvendindex"
		(:div :class "row" :style "display: none"
		(:div :class "btn-group" :role "group" :aria-label "..."
		(:button  :name "btnpendord" :type "submit" :class "btn btn-default active" "Orders" )
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
	    (cond ((equal context "ctxordprd") (ui-list-vendor-orders-by-products dodorders))
		((and dodorders btnexpexl) (hunchentoot:redirect (format nil "/hhub/dodvenexpexl?reqdate=~A" reqdate)))
		((and dodorders btnordcus) (ui-list-vendor-orders-by-customers dodorders (get-login-vendor)))
		((equal context "home")
		 (htm (:div :class "list-group col-xs-6 col-sm-6 col-md-6 col-lg-6" 
			    (:a :class "list-group-item" :href "dodvendindex?context=pendingorders" " Orders " (:span :class "badge" (str (format nil " ~d " (length dodorders)))))
			    (:a :class "list-group-item" :href "dodvendindex?context=ctxordprd" "Product Demand")
			    (:a :class "list-group-item" :href "#" "List orders by Customers")
			    (:a :class "list-group-item" :href (str (format nil "dodvendrevenue"))  "Today's Revenue")
			    )))  
   
		((equal context "pendingorders") 
		 (progn (htm (str "Pending Orders") (:span :class "badge" (str (format nil " ~d " (length dodorders))))
			     (:a :class "btn btn-primary btn-xs" :role "button" :href "dodrefreshpendingorders" (:span :class "glyphicon glyphicon-refresh"))
			     (:hr))
			(str (display-as-tiles dodorders 'vendor-order-card))))
		((equal context "completedorders") (let ((orders (dod-get-cached-completed-orders)))
						     (progn (htm (str (format nil "Completed orders"))
								 (:span :class "badge" (str (format nil " ~d " (length orders)))) 
								 (:hr))
							(str(display-as-tiles orders 'vendor-order-card)))))
							    
		(T ()) )))
					; Else
	(hunchentoot:redirect "/hhub/vendor-login.html")))


(defun dod-controller-ven-order-fulfilled ()
    (if (is-dod-vend-session-valid?)
	(let* ((id (hunchentoot:parameter "id"))
	       (company-instance (hunchentoot:session-value :login-vendor-company))
	       (order-instance (get-order-by-id id company-instance))
	       (payment-mode (slot-value order-instance 'payment-mode))
	       (customer (get-ord-customer order-instance)) 
	       (vendor (get-login-vendor))
	       (wallet (get-cust-wallet-by-vendor customer vendor company-instance))
	       (vendor-order-items (get-order-items-for-vendor-by-order-id  order-instance (get-login-vendor) )))
	  
	  (progn (if (equal payment-mode "PRE")
		     (if (not (check-wallet-balance (get-order-items-total-for-vendor vendor  vendor-order-items) wallet))
			 (display-wallet-for-customer wallet "Not enough balance for the transaction.")))
		 (set-order-fulfilled "Y"  order-instance company-instance)
		 (hunchentoot:redirect "/hhub/dodvendindex?context=pendingorders")))
	;else     
	(hunchentoot:redirect "/hhub/vendor-login.html")))


(defun display-wallet-for-customer (wallet-instance custom-message)
  (standard-vendor-page (:title "Wallet Display")
    (wallet-card wallet-instance custom-message)))

(defun dod-controller-ven-expexl ()
    (if (is-dod-vend-session-valid?)
	(let ((header (list "Product " "Quantity" "Qty per unit" "Unit Price" ""))
		 (reqdate (hunchentoot:parameter "reqdate"))
		 (vendor-instance (get-login-vendor))
		 ( dodorders (get-orders-by-req-date (hunchentoot:parameter "reqdate") (get-login-vendor-company))))
	    (setf (hunchentoot:content-type*) "application/vnd.ms-excel")
	    (setf (header-out "Content-Disposition" ) (format nil "inline; filename=Orders_~A.csv" reqdate))
	(ui-list-orders-for-excel header dodorders vendor-instance))
    (hunchentoot:redirect "/hhub/vendor-login.html")))



(defun get-login-vendor ()
    :documentation "Get the login session for vendor"
    (hunchentoot:session-value :login-vendor ))


(defun get-login-vend-company ()
    :documentation "Get the login vendor company."
    ( hunchentoot:session-value :login-vendor-company))

(defun get-login-vendor-tenant-id () 
  :documentation "Get the login vendor tenant-id"
  (hunchentoot:session-value :login-vendor-tenant-id))

(defun is-dod-vend-session-valid? ()
    :documentation "Checks whether the current login session is valid or not."
    (if  (null (get-login-vendor-name)) NIL T))

(defun get-login-vendor-name ()
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
	    (let* (( dodvenorder  (get-vendor-orders-by-orderid (hunchentoot:parameter "id") (get-login-vendor) (get-login-vendor-company)))
		   (venorderfulfilled (if dodvenorder (slot-value dodvenorder 'fulfilled)))
		   (order (get-order-by-id (hunchentoot:parameter "id") (get-login-vendor-company)))
		   (header (list "Product" "Product Qty" "Unit Price"  "Sub-total"))
		      (odtlst (if order (dod-get-cached-order-items-by-order-id order)) )
      		  
		   (total   (reduce #'+  (mapcar (lambda (odt)
			(* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst))))
		(if order (display-order-header-for-vendor  order)) 
		(if odtlst (ui-list-vend-orderdetails header odtlst) "No order details")
					    (htm(:div :class "row" 
				(:div :class "col-md-12" :align "right" 
				    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))
				    (if (equal venorderfulfilled "Y") 
					(htm (:span :class "label label-info" "FULFILLED"))
					;ELSE
					(htm (:a :onclick "return CancelConfirm();" :href (format nil "dodvenordcancel?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Cancel")) "&nbsp;&nbsp;"  (:a :href (format nil "dodvenordfulfilled?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Complete")))))
					;ELSE
					
						    ))))
	(hunchentoot:redirect "/hhub/vendor-login.html")))



(defun ui-list-vend-orderdetails (header data)
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class  "panel panel-default"
	    (:div :class "panel-heading" "Order Items")
	    (:div :class "panel-body"
		  (:table :class "table table-hover"  
			  (:thead (:tr
				   (mapcar (lambda (item) (htm (:th (str item)))) header))) 
			  (:tbody
			   (mapcar (lambda (odt)
				     (let ((odt-product  (get-odt-product odt))
					   (unit-price (slot-value odt 'unit-price))
					   (prd-qty (slot-value odt 'prd-qty)))
				       (htm (:tr (:td  :height "12px" (str (slot-value odt-product 'prd-name)))
						 (:td  :height "12px" (str (format nil  "~d" prd-qty)))
						 (:td  :height "12px" (str (format nil  "Rs. ~$" unit-price)))
						 (:td  :height "12px" (str (format nil "Rs. ~$" (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty)))))
						 )))) (if (not (typep data 'list)) (list data) data))))))))
