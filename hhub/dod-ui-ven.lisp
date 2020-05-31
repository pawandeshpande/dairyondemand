(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

(defvar *current-vendor-session* nil)



(defun modal.vendor-update-details ()
  (let* ((vendor (get-login-vendor))
	 (name (name vendor))
	 (address (address vendor))
	 (phone  (phone vendor))
	 (email (email vendor))
	 (picture-path (picture-path vendor)))


 (cl-who:with-html-output (*standard-output* nil)
   (:div :class "row" :style "align: center"
   (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6 image-responsive"
			  (:img :src  (format nil "~A" picture-path) :height "300" :width "400" :alt name " ")))
   (:div :class "row" 
	 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
	       (:form :id (format nil "form-customerupdate")  :role "form" :method "POST" :action "hhubvendupdateaction" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
		 
		 (:h1 :class "text-center login-title"  "Update Vendor Details")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "name" :value name :placeholder "Customer Name" :type "text"))
		      (:div :class "form-group"
			    (:label :for "address")
			    (:textarea :class "form-control" :name "address"  :placeholder "Enter Address ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str (format nil "~A" address))))
		      (:div :class "form-group" :id "charcount")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "phone"  :value phone :placeholder "Phone"  :type "text" ))
		      
		      (:div :class "form-group"
			    (:input :class "form-control" :name "email" :value email :placeholder "Email" :type "text"))
			
		      (:div :class "form-group" (:label :for "prodimage" "Select Picture:")
			    (:input :class "form-control" :name "picturepath" :placeholder "Picture" :type "file" ))
		      
		      (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))

(defun dod-controller-vendor-update-action ()
  (with-vend-session-check 
    (let* ((name (hunchentoot:parameter "name"))
	   (address (hunchentoot:parameter "address"))
	   (phone (hunchentoot:parameter "phone"))
	   (email (hunchentoot:parameter "email"))
	   (vendor (get-login-vendor))
	   (prodimageparams (hunchentoot:post-parameter "picturepath"))
	   (tempfilewithpath (first prodimageparams))
	   (file-name (format nil "~A-~A" (get-universal-time) (second prodimageparams))))
     
      (process-image prodimageparams)
    
      (setf (slot-value vendor 'name) name)
      (setf (slot-value vendor 'address) address)
      (setf (slot-value vendor 'phone) phone)
      (setf (slot-value vendor 'email) email)
      (if tempfilewithpath (setf (slot-value vendor 'picture-path) (format nil "/img/~A"  file-name)))
      (update-vendor-details vendor)
      (hunchentoot:redirect "/hhub/dodvendprofile"))))


    


(defun modal.vendor-update-settings ()
  (let* ((vendor (get-login-vendor))
	 (payment-api-key (payment-api-key vendor))
	 (payment-api-salt (payment-api-salt vendor))
	 (pg-mode (slot-value vendor 'payment-gateway-mode)))
       
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (:form :id (format nil "form-customerupdate")  :role "form" :method "POST" :action "hhubvendupdatesettings" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
			 
			 (:h1 :class "text-center login-title"  "Update Vendor Settings")
			 (:div :class "form-group"
			       (:label :for "payment-api-key" "Payment API Key")
			       (:input :class "form-control" :name "payment-api-key" :value payment-api-key :placeholder "Payment API Key" :type "text"))
			 (:div :class "form-group"
			       (:label :for "payment-api-salt" "Payment API Salt")
			       (:input :class "form-control" :name "payment-api-salt"  :value payment-api-salt :placeholder "Payment API Salt"  :type "text" ))
			 (:div :class "form-group"
			       (:label :for "pg-mode" "Payment Gateway Mode"
				       (payment-gateway-mode-options pg-mode)))
			 
			 (:div :class "form-group"
			       (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))



;; @@ deprecated : start using with-html-dropdown instead. 
(defun payment-gateway-mode-options (selectedkey) 
  (let ((pg-mode (make-hash-table)))
    (setf (gethash "TEST" pg-mode) "TEST") 
    (setf (gethash "LIVE" pg-mode) "LIVE")
    (with-html-dropdown "pg-mode" pg-mode selectedkey)))


(defun dod-controller-vendor-update-settings ()
  (with-vend-session-check 
    (let* ((payment-api-key (hunchentoot:parameter "payment-api-key"))
	   (payment-api-salt (hunchentoot:parameter "payment-api-salt"))
	   (pg-mode (hunchentoot:parameter "pg-mode"))
	   (vpushnotifysubs (hunchentoot:parameter "vpushnotifysubs"))
	   (vendor (get-login-vendor)))
      (setf (slot-value vendor 'payment-api-key) payment-api-key)
      (setf (slot-value vendor 'payment-api-salt) payment-api-salt)
      (setf (slot-value vendor 'payment-gateway-mode) pg-mode)
      (setf (slot-value vendor 'push-notify-subs-flag) (if (null vpushnotifysubs) "N" vpushnotifysubs))
      (update-vendor-details vendor)
      (hunchentoot:redirect "/hhub/dodvendprofile"))))


(defun modal.vendor-change-pin ()
  (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (with-html-form "form-vendorchangepin" "hhubvendorchangepin"  
					;(:div :class "account-wall"
			 (:h1 :class "text-center login-title"  "Change Password")
			 (:div :class "form-group"
			       (:label :for "password" "Password")
			       (:input :class "form-control" :name "password" :value "" :placeholder "Old Password" :type "password" :required T))
			 (:div :class "form-group"
			       (:label :for "newpassword" "New Password")
			       (:input :class "form-control" :id "newpassword" :data-minlength "8" :name "newpassword" :value "" :placeholder "New Password" :type "password" :required T))
			 (:div :class "form-group"
			       (:label :for "confirmpassword" "Confirm New Password")
			       (:input :class "form-control" :name "confirmpassword" :value "" :data-minlength "8" :placeholder "Confirm New Password" :type "password" :required T :data-match "#newpassword"  :data-match-error "Passwords dont match"  ))
			 (:div :class "form-group"
			       (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))




(defun dod-controller-vendor-change-pin ()
  (with-vend-session-check 
    (let* ((password (hunchentoot:parameter "password"))
	   (newpassword (hunchentoot:parameter "newpassword"))
	   (confirmpassword (hunchentoot:parameter "confirmpassword"))
	   (salt-octet (secure-random:bytes 56 secure-random:*generator*))
	   (salt (flexi-streams:octets-to-string  salt-octet))
	   (encryptedpass (check&encrypt newpassword confirmpassword salt))
	   (vendor (get-login-vendor))
	   (present-salt (if vendor (slot-value vendor 'salt)))
	   (present-pwd (if vendor (slot-value vendor 'password)))
	   (password-verified (if vendor  (check-password password present-salt present-pwd))))
     (cond 
       ((or
	 (not password-verified) 
	 (null encryptedpass)) (dod-response-passwords-do-not-match-error)) 
       ((and password-verified encryptedpass) (progn 
       (setf (slot-value vendor 'password) encryptedpass)
       (setf (slot-value vendor 'salt) salt) 
       (update-vendor-details vendor)
       (hunchentoot:redirect "/hhub/dodvendprofile")))))))



(defun dod-controller-vendor-customer-list ()
  (with-vend-session-check 
    (let* ((wallets (get-cust-wallets-for-vendor (get-login-vendor) (get-login-vendor-company)))
	   (customers (mapcar (lambda (wallet) 
			   (get-customer wallet)) wallets)))
      (with-standard-vendor-page (:title "Customers list for vendor") 
	(str (display-as-table (list "Name" "Mobile" "Email" "Actions") customers 'vendor-customers-card))))))
 

  

(defun dod-controller-vendor-order-cancel ()
 (with-vend-session-check
  (let* ((id (hunchentoot:parameter "id"))
	(order (get-order-by-id id (get-login-vendor-company)))
	(order-id (slot-value order 'row-id)))
    (cancel-order-by-vendor order)
    (cancel-order-by-vendor (get-vendor-order-instance order-id (get-login-vendor))))))


(defun dod-controller-vendor-revenue ()
(with-vend-session-check
    ;list all the completed orders for Today. 
    (let* ((todaysorders (dod-get-cached-completed-orders-today))
	   (total (if todaysorders (reduce #'+ (mapcar (lambda (ord) (slot-value ord 'order-amt)) todaysorders)))))
    (with-standard-vendor-page (:title "Welcome to DAS Platform- Vendor")
      (:div :class "row"
	    (:div :class "col-xs-12 col-sm-4 col-md-4 col-lg-4" 
		   "Completed orders "
		  (:span :class "badge" (str (format nil " ~d " (length todaysorders))))) 
	(:div :class  "col-xs-12 col-sm-4 col-md-4 col-lg-4"  :align "right" (:h1(:span :class "label label-default" "Todays Revenue")))	  
      (:div :class  "col-xs-12 col-sm-4 col-md-4 col-lg-4"  :align "right" 
	    (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))))
      (:hr)
      (str (display-as-tiles todaysorders 'vendor-order-card ))))))


 
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
	   
	(with-standard-vendor-page (:title "Welcome to DAS Platform - Vendor")
	  (:a :class "btn btn-primary" :role "button" :href "dodvendsearchtenantpage" (:span :class "glyphicon glyphicon-shopping-cart") " Add New Group  ")
	  (:hr)
	  (:h5 (str (format nil "Currently Logged Into Group - ~A" (slot-value vendor-company 'name))))
	  (:div :class "list-group col-sm-6 col-md-6 col-lg-6"
	 (if cmplist (mapcar (lambda (cmp)
			       (unless (equal (slot-value vendor-company 'name)  (slot-value cmp 'name))
	    (htm  (:a :class "list-group-item" :href (format nil "dodvendswitchtenant?id=~A"  (slot-value cmp 'row-id)) (str (format nil "Login to ~A " (slot-value cmp 'name))))
		  ))) cmplist)))))
      (hunchentoot:redirect "/hhub/vendor-login.html")))




(defun dod-controller-cmpsearch-for-vend-page ()
  (if (is-dod-vend-session-valid?)
      (with-standard-vendor-page (:title "Welcome to DAS platform") 
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
	  (existing-tenants-list (append (get-vendor-tenants-as-companies (get-login-vendor)) (list (get-login-vendor-company))))
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
	     (company (select-company-by-name cname)))
	
	(create-vendor-tenant (get-login-vendor) "N"  company)
	(hunchentoot:redirect "/hhub/dodvendortenants"))
      ;else
      (hunchentoot:redirect "/hhub/vendor-login.html")))







(defun dod-controller-vendor-add-product-page ()
(with-vend-session-check 
      ;(let ((catglist (get-prod-cat (get-login-vendor-tenant-id))))
  (with-standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:form :class "form-vendorprodadd" :role "form" :method "POST" :action "dodvenaddproductaction" :data-toggle "validator" :enctype "multipart/form-data" 
				       (:div :class "account-wall"
					     (:img :class "profile-img" :src "/img/logo.png" :alt "")
					     (:h1 :class "text-center login-title"  "Add new product")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "prdname" :placeholder "Enter Product Name ( max 30 characters) " :type "text" ))
					    
					     (:div :class "form-group"
						  (:label :for "description")
						  (:textarea :class "form-control" :name "description" :placeholder "Enter Product Description ( max 1000 characters) "  :rows "5" :onkeyup "countChar(this, 1000)"  ))
					      (:div :class "form-group" :id "charcount")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "prdprice" :placeholder "Price"  :type "text" :min "0.00" :max "10000.00" :step "0.01" ))
					    (:div :class "form-group"
						   (:input :class "form-control" :name "unitsinstock" :placeholder "Units In Stock"  :type "number" :min "1" :max "10000" :step "1" ))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "qtyperunit" :placeholder "Quantity per unit. Ex - KG, Grams, Nos" :type "text" ))
					     ;(:div  :class "form-group" (:label :for "prodcatg" "Select Produt Category:" )
					     ;(ui-list-prod-catg-dropdown "prodcatg" catglist))
					     (:br) 
					     (:div :class "form-group" (:label :for "yesno" "Product/Service Subscription")
						   (ui-list-yes-no-dropdown "N"))
					     (:div :class "form-group" (:label :for "prodimage" "Select Product Image:")
						   (:input :class "form-control" :name "prodimage" :placeholder "Product Image" :type "file" ))
					      (:div :class "form-group"
						   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))))))))



(defun dod-controller-vendor-add-product-action ()
 (with-vend-session-check 
   (let* ((prodname (hunchentoot:parameter "prdname"))
	  (id (hunchentoot:parameter "id"))
	  (product (if id (select-product-by-id id (get-login-vendor-company))))
	  (description (hunchentoot:parameter "description"))
	  (prodprice (with-input-from-string (in (hunchentoot:parameter "prdprice"))
		       (read in)))
	  (qtyperunit (hunchentoot:parameter "qtyperunit"))
	  (units-in-stock (parse-integer (hunchentoot:parameter "unitsinstock")))
	  (catg-id (hunchentoot:parameter "prodcatg"))
	  (subscriptionflag (hunchentoot:parameter "yesno"))
	  (prodimageparams (hunchentoot:post-parameter "prodimage"))
					;(destructuring-bind (path file-name content-type) prodimageparams))
	  (tempfilewithpath (first prodimageparams))
	  (file-name (format nil "~A-~A" (get-universal-time) (second prodimageparams))))
     
     (if tempfilewithpath 
	 (progn 
	   (probe-file tempfilewithpath)
	   (rename-file tempfilewithpath (make-pathname :directory *HHUBRESOURCESDIR*  :name file-name))))
     (if product 
	 (progn 
	   (setf (slot-value product 'description) description)
	   (setf (slot-value product 'unit-price) prodprice)
	   (setf (slot-value product 'qty-per-unit) qtyperunit)
	   (setf (slot-value product 'units-in-stock) units-in-stock)
	   (setf (slot-value product 'subscribe-flag) subscriptionflag)
	   (if tempfilewithpath (setf (slot-value product 'prd-image-path) (format nil "/img/~A"  file-name)))
	   (update-prd-details product))
					;else
	 (create-product prodname description (get-login-vendor) (select-prdcatg-by-id catg-id (get-login-vendor-company)) qtyperunit prodprice units-in-stock (if tempfilewithpath (format nil "/img/~A" file-name) (format nil "/img/~A"   *HHUBDEFAULTPRDIMG*))  subscriptionflag  (get-login-vendor-company)))
     (dod-reset-vendor-products-functions (get-login-vendor) (get-login-vendor-company))
     (hunchentoot:redirect "/hhub/dodvenproducts"))))


(defun dod-controller-vendor-password-reset-action ()
  (let* ((pwdresettoken (hunchentoot:parameter "token"))
	 (rstpassinst (get-reset-password-instance-by-token pwdresettoken))
	 (user-type (if rstpassinst (slot-value rstpassinst 'user-type)))
	 (password (hunchentoot:parameter "password"))
	 (newpassword (hunchentoot:parameter "newpassword"))
	 (confirmpassword (hunchentoot:parameter "confirmpassword"))
	 (salt-octet (secure-random:bytes 56 secure-random:*generator*))
	 (salt (flexi-streams:octets-to-string  salt-octet))
	 (encryptedpass (check&encrypt newpassword confirmpassword salt))
	 (email (if rstpassinst (slot-value rstpassinst 'email)))
	 (vendor (select-vendor-by-email email))
	 (present-salt (if vendor (slot-value vendor 'salt)))
	 (present-pwd (if vendor (slot-value vendor 'password)))
	 (password-verified (if vendor  (check-password password present-salt present-pwd))))
     (cond 
       ((or  (not password-verified)  (null encryptedpass)) (dod-response-passwords-do-not-match-error)) 
       ;Token has expired
       ((and (equal user-type "VENDOR")
		 (duration> (time-difference (clsql-sys:get-time) (slot-value rstpassinst 'created))  (make-duration :minute *HHUBPASSRESETTIMEWINDOW*))) (hunchentoot:redirect "/hhub/hhubpassresettokenexpired.html"))
       ((and password-verified encryptedpass) (progn 
       (setf (slot-value vendor 'password) encryptedpass)
       (setf (slot-value vendor 'salt) salt) 
       (update-vendor-details vendor)
       (hunchentoot:redirect "/hhub/vendor-login.html"))))))
 


(defun dod-controller-vendor-password-reset-page ()
  (let ((token (hunchentoot:parameter "token")))
(with-standard-vendor-page (:title "Password Reset") 
(:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (with-html-form "form-vendorchangepin" "hhubvendpassresetaction"  
					;(:div :class "account-wall"
			 (:h1 :class "text-center login-title"  "Change Password")
			 (:div :class "form-group"
			  
			       (:input :class "form-control" :name "token" :value token :type "hidden"))
			 (:div :class "form-group"
			       (:label :for "password" "Password")
			       (:input :class "form-control" :name "password" :value "" :placeholder "Enter OTP from Email Old" :type "password" :required T))
			 (:div :class "form-group"
			       (:label :for "newpassword" "New Password")
			       (:input :class "form-control" :id "newpassword" :data-minlength "8" :name "newpassword" :value "" :placeholder "New Password" :type "password" :required T))
			 (:div :class "form-group"
			       (:label :for "confirmpassword" "Confirm New Password")
			       (:input :class "form-control" :name "confirmpassword" :value "" :data-minlength "8" :placeholder "Confirm New Password" :type "password" :required T :data-match "#newpassword"  :data-match-error "Passwords dont match"  ))
			 (:div :class "form-group"
			       (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))


(defun dod-controller-vendor-generate-temp-password ()
  (let* ((token (hunchentoot:parameter "token"))
	 (rstpassinst (get-reset-password-instance-by-token token))
	 (user-type (if rstpassinst (slot-value rstpassinst 'user-type)))
	 (url (format nil "https://www.highrisehub.com/hhub/hhubvendpassreset.html?token=~A" token))
	 (email (if rstpassinst (slot-value rstpassinst 'email))))
    
	 (cond 
	   ((and (equal user-type "VENDOR")
		 (duration< (time-difference (clsql-sys:get-time) (slot-value rstpassinst 'created))  (make-duration :minute *HHUBPASSRESETTIMEWINDOW*)))
	    (let* ((vendor (select-vendor-by-email email))
		   (newpassword (reset-vendor-password vendor)))
					;send mail to the vendor with new password 
	      (send-temp-password vendor newpassword url)
	      (hunchentoot:redirect "/hhub/hhubpassresetmailsent.html")))	  
	   ((and (equal user-type "VENDOR")
		 (duration> (time-difference (clsql-sys:get-time) (slot-value rstpassinst 'created))  (make-duration :minute *HHUBPASSRESETTIMEWINDOW*))) (hunchentoot:redirect "/hhub/hhubpassresettokenexpired.html"))
	   ((equal user-type "CUSTOMER") ())
	   ((equal user-type "EMPLOYEE") ()))))



(defun dod-controller-vendor-reset-password-action-link ()
(let* ((email (hunchentoot:parameter "email"))
       (vendor (select-vendor-by-email email))
       (token (format nil "~A" (uuid:make-v1-uuid )))
       (user-type (hunchentoot:parameter "user-type"))
       (tenant-id (if vendor (slot-value vendor 'tenant-id)))
       (captcha-resp (hunchentoot:parameter "g-recaptcha-response"))
       (paramname (list "secret" "response" ))
       (url (format nil "https://www.highrisehub.com/hhub/hhubvendgentemppass?token=~A" token))
       (paramvalue (list *HHUBRECAPTCHASECRET*  captcha-resp))
       (param-alist (pairlis paramname paramvalue ))
       (json-response (json:decode-json-from-string  (map 'string 'code-char(drakma:http-request "https://www.google.com/recaptcha/api/siteverify"
												 :method :POST
												 :parameters param-alist  )))))
  
  
  (cond 
	 ; Check whether captcha has been solved 
    ((null (cdr (car json-response))) (dod-response-captcha-error))
    ((null vendor) (hunchentoot:redirect "/hhub/hhubinvalidemail.html"))
    ; if vendor is valid then create an entry in the password reset table. 
    ((and (equal user-type "VENDOR") vendor)
     (progn 
       (create-reset-password-instance user-type token email  tenant-id)
       ; temporarily disable the vendor record 
       (setf (slot-value vendor 'active-flag) "N")
       (update-vendor-details vendor) 
       ; Send vendor an email with password reset link. 
       (send-password-reset-link vendor url)
       (hunchentoot:redirect "/hhub/hhubpassresetmaillinksent.html"))))))





(defun modal.vendor-forgot-password() 
  (cl-who:with-html-output (*standard-output* nil)
    (:div :class "row" 
	  (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		(:form :id (format nil "form-vendorforgotpass")  :role "form" :method "POST" :action "hhubvendforgotpassactionlink" :enctype "multipart/form-data" 
		      (:h1 :class "text-center login-title"  "Forgot Password")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "email" :value "" :placeholder "Email" :type "text")
			    (:input :class "form-control" :name "user-type" :value "VENDOR"  :type "hidden" :required "true"))
		      (:div :class "form-group"
			(:div :class "g-recaptcha" :data-sitekey *HHUBRECAPTCHAKEY* ))
		      (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Reset Password")))))))


    

(defun dod-controller-vendor-loginpage ()
  (handler-case
      (progn  (if (equal (caar (clsql:query "select 1" :flatp nil :field-names nil :database *dod-db-instance*)) 1) T)	      
	      (if (is-dod-vend-session-valid?)
		  (hunchentoot:redirect "/hhub/dodvendindex?context=home")
		  (with-standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
		    (:div :class "row" 
			  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
				(:div :class "account-wall"
					     (:form :class "form-vendorsignin" :role "form" :method "POST" :action "dodvendlogin"
					     (:img :class "profile-img" :src "/img/logo.png" :alt "")
					     (:h1 :class "text-center login-title"  "Vendor - Login to DAS")
					     (:div :class "form-group"
						   (:input :class "form-control" :name "phone" :placeholder "Enter RMN. Ex:9999999990" :type "text" ))
					     (:div :class "form-group"
						   (:input :class "form-control" :name "password" :placeholder "password=demo" :type "password" ))
					     (:div :class "form-group"
						   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit")))
					     
					     (:div :class ""
					     (:a :data-toggle "modal" :data-target (format nil "#dasvendforgotpass-modal")  :href "#"  "Forgot Password?"))
					     (modal-dialog (format nil "dasvendforgotpass-modal") "Forgot Password?" (modal.vendor-forgot-password))
				       
					     
					     ))))))
	      (clsql:sql-database-data-error (condition)
					     (if (equal (clsql:sql-error-error-id condition) 2006 ) (progn
												      (stop-das) 
												      (start-das)
												      (hunchentoot:redirect "/hhub/vendor-login.html"))))))


(defun dod-controller-vendor-search-cust-wallet-page ()
    (if (is-dod-vend-session-valid?)
    (with-standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
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
(with-standard-vendor-page (:title "Welcome to DAS Platform")
 (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 "Wallet does not exist"))))
;else
(with-standard-vendor-page (:title "Welcome to DAS Platform")
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Name: ~A" (if customer (slot-value customer 'name)))))))
  (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Phone: ~A" (if customer (slot-value customer 'phone)))))))
   (:div :class "row" 
	(:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Address: ~A" (if customer (slot-value customer 'address)))))))

  (:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4" (:h3 (str (format nil "Balance = Rs.~$" (slot-value wallet 'balance))))))
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		  (:form :class "form-vendor-update-balance" :role "form" :method "POST" :action "dodupdatewalletbalance"
		    (:div :class "account-wall"
			  (:div :class "form-group"
			    (:input :class "form-control" :name "balance" :placeholder "recharge amount" :type "text" ))
			  (:input :class "form-control" :name "wallet-id" :value (slot-value wallet 'row-id) :type "hidden")
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
    (with-standard-vendor-page (:title "Welcome to Highrisehub")
       (:h3 "Welcome " (str (format nil "~A" (get-login-vendor-name))))
       (:hr)
       (:div :class "list-group col-sm-6 col-md-6 col-lg-6"
		    (:a :class "list-group-item" :href "dodsearchcustwalletpage" "My Customers")
		    (:a :class "list-group-item" :href "dodvendortenants" "My Groups")
		    (:a :class "list-group-item" :data-toggle "modal" :data-target (format nil "#dodvendupdate-modal")  :href "#"  "Contact Information")
		    (modal-dialog (format nil "dodvendupdate-modal") "Update Vendor" (modal.vendor-update-details)) 
		    
		    (:a :class "list-group-item" :data-toggle "modal" :data-target (format nil "#dodvendchangepin-modal")  :href "#"  "Change Password")
		    (modal-dialog (format nil "dodvendchangepin-modal") "Change Password" (modal.vendor-change-pin))
		    (:a :class "list-group-item" :href "/pushsubscribe.html" "Push Notifications")
		    (:a :class "list-group-item" :data-toggle "modal" :data-target (format nil "#dodvendsettings-modal")  :href "#"  "Settings")
		    (modal-dialog (format nil "dodvendsettings-modal") "Update Settings" (modal.vendor-update-settings))))
    (hunchentoot:redirect "/hhub/vendor-login.html")))






(defmacro with-vendor-navigation-bar ()
    :documentation "This macro returns the html text for generating a navigation bar using bootstrap."
    `(cl-who:with-html-output (*standard-output* nil)
	 (:div :class "navbar navbar-default navbar-inverse navbar-static-top"
	     (:div :class "container-fluid"
		 (:div :class "navbar-header"
		     (:button :type "button" :class "navbar-toggle" :data-toggle "collapse" :data-target "#navHeaderCollapse"
			 (:span :class "icon-bar")
			 (:span :class "icon-bar")
			 (:span :class "icon-bar"))
		     (:a :class "navbar-brand" :href "#" :title "HHUB" (:img :style "width: 50px; height: 50px;" :src "/img/logo.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "dodvendindex?context=home"  (:span :class "glyphicon glyphicon-home")  " Home"))
			 (:li :align "center" (:a :href "dodvenproducts"  "My Products"))
			 (:li :align "center" (:a :href "dodvendindex?context=completedorders"  "Completed Orders"))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout)))
			 (:li :align "center" (:a :href "#" (str (format nil "Group: ~A" (get-login-vendor-company-name))))))
		     
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "dodvendprofile?context=home"   (:span :class "glyphicon glyphicon-user") " My Profile" )) 
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
	     (vendor-company (if vendor  (vendor-company vendor))))
					;(log (if password-verified (hunchentoot:log-message* :info (format nil  "phone : ~A password : ~A" phone password)))))
	(when (and  vendor
		    password-verified
		    (null (hunchentoot:session-value :login-vendor-name))) ;; vendor should not be logged-in in the first place.
	  (progn
	    (format T "Starting session")
	    (setf *current-vendor-session* (hunchentoot:start-session))
	    (if vendor (setf (hunchentoot:session-value :login-vendor ) vendor))
	    (if vendor (setf (hunchentoot:session-value :login-vendor-name) (slot-value vendor 'name)))
	    (if vendor (setf (hunchentoot:session-value :login-vendor-id) (slot-value vendor 'row-id)))
	    (set-vendor-session-params  vendor-company vendor))))

					;handle the exception. 
    (clsql:sql-database-data-error (condition)
      (if (equal (clsql:sql-error-error-id condition) 2006 ) 
	  (progn
	    (stop-das) 
	    (start-das)
	    (hunchentoot:redirect "/hhub/vendor-login.html"))))))

(defun dod-controller-vendor-switch-tenant ()
(with-vend-session-check
(let* ((company (select-company-by-id (hunchentoot:parameter "id")))
       (vendor (get-login-vendor)))
      
  (progn
	(set-vendor-session-params company vendor)
	(hunchentoot:redirect "/hhub/dodvendindex?context=home")))))

(defun set-vendor-session-params ( company  vendor)
 (progn 

   					;set vendor company related params 
   (setf (hunchentoot:session-value :login-vendor-tenant-id) (slot-value company 'row-id ))
   (setf (hunchentoot:session-value :login-vendor-company-name) (slot-value company 'name))
   (setf (hunchentoot:session-value :login-vendor-company) company)
   ;(setf (hunchentoot:session-value :login-prd-cache )  (select-products-by-company company))
   ;set vendor related params 
   (if vendor (setf (hunchentoot:session-value :login-vendor-tenants) (get-vendor-tenants-as-companies vendor)))
   (if vendor (setf (hunchentoot:session-value :order-func-list) (dod-gen-order-functions vendor company)))
   (if vendor (setf (hunchentoot:session-value :vendor-order-items-hashtable) (make-hash-table)))
   (if vendor (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions vendor company)))))
   
   
   
(defun dod-controller-vendor-delete-product () 
 (if (is-dod-vend-session-valid?)
  (let ((id (hunchentoot:parameter "id")))
    (if (= (length (get-pending-order-items-for-vendor-by-product (select-product-by-id id (get-login-vendor-company)) (get-login-vendor))) 0)
	(progn 
	  (delete-product id (get-login-vendor-company))
	  (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor) (get-login-vendor-company)))))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
     	(hunchentoot:redirect "/hhub/vendor-login.html"))) 

(defun dod-controller-prd-details-for-vendor ()
    (if (is-dod-vend-session-valid?)
	(with-standard-vendor-page (:title "Product Details")
	    (let* ((company (hunchentoot:session-value :login-vendor-company))
		   (product (select-product-by-id (parse-integer (hunchentoot:parameter "id")) company)))
		(product-card-with-details-for-vendor product)))
	(hunchentoot:redirect "/hhub/vendor-login.html")))


(defun dod-controller-vendor-deactivate-product ()
  (if (is-dod-vend-session-valid?)
  (let ((id (parse-integer (hunchentoot:parameter "id"))))
    (deactivate-product id (get-login-vendor-company))
    (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor) (get-login-vendor-company)))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
  ;else
  (hunchentoot:redirect "/hhub/vendor-login.html")))

(defun dod-controller-vendor-activate-product ()
  (if (is-dod-vend-session-valid?)
  (let ((id (hunchentoot:parameter "id")))
    (activate-product id (get-login-vendor-company))
    (setf (hunchentoot:session-value :login-vendor-products-functions) (dod-gen-vendor-products-functions (get-login-vendor) (get-login-vendor-company)))   
    (hunchentoot:redirect "/hhub/dodvenproducts"))
  ;else
  (hunchentoot:redirect "/hhub/vendor-login.html")))


(defun dod-controller-vendor-copy-product ()
) 


(defun dod-controller-vendor-products ()
(with-vend-session-check 
  (with-standard-vendor-page (:title "Welcome to HighriseHub  - Vendor")
			     (:a :class "btn btn-primary" :role "button" :href "dodvenaddprodpage" (:span :class "glyphicon glyphicon-shopping-cart") " Add New Product  ")
			     (:hr)
			     (str (display-as-tiles (hhub-get-cached-vendor-products)  'product-card-for-vendor)))))
   


(defun dod-gen-vendor-products-functions (vendor company)
  (let ((vendor-products (select-products-by-vendor vendor company)))
    (list (function (lambda () vendor-products)))))

(defun dod-gen-order-functions (vendor company)
(let ((pending-orders (get-orders-for-vendor vendor 500 company ))
      (completed-orders (get-orders-for-vendor vendor 500 company  "Y" ))
      (order-items (get-order-items-for-vendor  vendor  company)) ; Get order items for last 30 days and next 30 days. 
      (completed-orders-today (get-orders-for-vendor-by-shipped-date vendor (get-date-string-mysql (get-date)) company "Y"))) 


  (list (function (lambda () pending-orders ))
	(function (lambda () completed-orders))
	(function (lambda () order-items))
	(function (lambda () completed-orders-today)))))


(defun dod-reset-vendor-products-functions (vendor company)
  (let ((vendor-products-func-list (dod-gen-vendor-products-functions vendor company)))
	(setf (hunchentoot:session-value :login-vendor-products-functions) vendor-products-func-list)))



(defun dod-reset-order-functions (vendor company)
  (let ((order-func-list (dod-gen-order-functions vendor company)))
    (setf (hunchentoot:session-value :order-func-list) order-func-list)))


(defun hhub-get-cached-vendor-products ()
  (let ((vendor-products-func (first (hunchentoot:session-value :login-vendor-products-functions))))
    (funcall vendor-products-func)))

(defun dod-get-cached-pending-orders()
  (let ((pending-orders-func (nth 0 (hunchentoot:session-value :order-func-list))))
    (funcall pending-orders-func)))


(defun dod-get-cached-completed-orders ()
  (let ((completed-orders-func (nth 1 (hunchentoot:session-value :order-func-list))))
    (funcall completed-orders-func)))

(defun dod-get-cached-completed-orders-today ()
  (let ((completed-orders-func (nth 3 (hunchentoot:session-value :order-func-list))))
    (funcall completed-orders-func)))

(defun dod-get-cached-order-items-by-order-id (order-id order-func-list)
  					; Add the order item to a hash table. Key - order-id to improve performance.
					; Discovered in May 2020
					; If the order-items are not found in the hash table, search them and add them to hash table.
  (let ((order-items-from-ht (get-ht-val order-id (hunchentoot:session-value :vendor-order-items-hashtable))))
    (if (null order-items-from-ht)
	  (let* ((order-items-func (nth 2 order-func-list))
		 (order-items (funcall order-items-func)))
	    (setf (gethash order-id (hunchentoot:session-value :vendor-order-items-hashtable))
		  (remove nil (mapcar (lambda (item)
					(if (equal (slot-value item 'order-id) order-id) item)) order-items))))
	  
	;otherwise, return the retrieved item from the hash table. 
	order-items-from-ht)))






(defun dod-controller-vend-index () 
  (with-vend-session-check 
    (let (( dodorders (dod-get-cached-pending-orders ))
	  (reqdate (hunchentoot:parameter "reqdate"))
	  (btnexpexl (hunchentoot:parameter "btnexpexl"))
	  (context (hunchentoot:parameter "context")))
      (with-standard-vendor-page (:title "Welcome to HighriseHub - Vendor")
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
				       ((equal context "ctxordcus") (ui-list-vendor-orders-by-customers dodorders))
				       ((equal context "home")	(htm (:div :class "list-group col-xs-6 col-sm-6 col-md-6 col-lg-6" 
									   (:a :class "list-group-item" :href "dodvendindex?context=pendingorders" " Orders " (:span :class "badge" (str (format nil " ~d " (length dodorders)))))
									   (:a :class "list-group-item" :href "dodvendindex?context=ctxordprd" "Todays Demand")
									   (:a :class "list-group-item" :href (str (format nil "dodvendrevenue"))  "Today's Revenue"))))  
				       
				       ((equal context "pendingorders") 
					(progn (htm (str "Pending Orders") (:span :class "badge" (str (format nil " ~d " (length dodorders))))
						    (:a :class "btn btn-primary btn-xs" :role "button" :href "dodrefreshpendingorders" (:span :class "glyphicon glyphicon-refresh"))
						    (:a :class "btn btn-primary btn-xs" :role "button" :href "dodvendindex?context=ctxordcus" "Printer Friendly View")
						    (:a :class "btn btn-primary btn-xs" :role "button" :href "dodvenexpexl?type=pendingorders" "Export To Excel")
						    (:hr))
					       (str (display-as-tiles dodorders 'vendor-order-card))))
				       ((equal context "completedorders") (let ((vorders (dod-get-cached-completed-orders)))
									    (progn (htm (str (format nil "Completed orders"))
											(:span :class "badge" (str (format nil " ~d " (length vorders)))) 
											(:a :class "btn btn-primary btn-xs" :role "button" :href "dodvenexpexl?type=completedorders" "Export To Excel")
											(:hr))
										   (str(display-as-tiles vorders 'vendor-order-card)))))
				       
		 )))))



(defun dod-controller-ven-order-fulfilled ()
  (with-vend-session-check 
	(let* ((id (hunchentoot:parameter "id"))
	       (company-instance (hunchentoot:session-value :login-vendor-company))
	       (order-instance (get-order-by-id id company-instance))
	       (payment-mode (slot-value order-instance 'payment-mode))
	       (customer (get-customer order-instance)) 
	       (vendor (get-login-vendor))
	       (wallet (get-cust-wallet-by-vendor customer vendor company-instance))
	       (vendor-order-items (get-order-items-for-vendor-by-order-id  order-instance (get-login-vendor) )))
	  
	  (progn (if (equal payment-mode "PRE")
		     (if (not (check-wallet-balance (get-order-items-total-for-vendor vendor  vendor-order-items) wallet))
			 (display-wallet-for-customer wallet "Not enough balance for the transaction.")))
		 (set-order-fulfilled "Y"  order-instance company-instance)
		 (hunchentoot:redirect "/hhub/dodvendindex?context=pendingorders")))))
	


(defun display-wallet-for-customer (wallet-instance custom-message)
  (with-standard-vendor-page (:title "Wallet Display")
    (wallet-card wallet-instance custom-message)))

(defun dod-controller-ven-expexl ()
    (if (is-dod-vend-session-valid?)
	(let ((type (hunchentoot:parameter "type"))
	      (header (list "Product " "Quantity" "Qty per unit" "Unit Price" ""))
	      (today (get-date-string (get-date))))
	      (setf (hunchentoot:content-type*) "application/vnd.ms-excel")
	      (setf (header-out "Content-Disposition" ) (format nil "inline; filename=Orders_~A.csv" today))
	      (cond ((equal type "pendingorders") (ui-list-orders-for-excel header (dod-get-cached-pending-orders)))
		    ((equal type "completedorders") (ui-list-orders-for-excel header (dod-get-cached-completed-orders)))))
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
    (let* ((vc (get-login-vendor-company))
	   (company-website (if vc (slot-value vc 'website))))
      (progn 
	(hunchentoot:remove-session *current-vendor-session*)
	(if company-website (hunchentoot:redirect (format nil "http://~A" company-website)) 
					;else
	    (hunchentoot:redirect (hunchentoot:redirect "/index.html"))))))




(defun vendor-details-card (vendor-instance)
    (let ((vend-name (slot-value vendor-instance 'name))
	     (vend-address  (slot-value vendor-instance 'address))
	     (phone (slot-value vendor-instance 'phone))
	  (picture-path (slot-value vendor-instance 'picture-path)))
	(cl-who:with-html-output (*standard-output* nil)
		(:h4 (str vend-name) )
	    (:div (str vend-address))
		(:div  (str phone))
		(:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6 image-responsive"
			  (:img :src  (format nil "~A" picture-path) :height "300" :width "400" :alt vend-name " ")))))
		  


(defun modal.vendor-order-details (vorder-instance company)
  (let* ((customer (if vorder-instance (get-customer vorder-instance)))
	 (wallet (if customer (get-cust-wallet-by-vendor customer (get-login-vendor) company)))
	 (balance (if wallet (slot-value wallet 'balance) 0))
	 (venorderfulfilled (if vorder-instance (slot-value vorder-instance 'fulfilled)))
	 (mainorder (get-order-by-id (slot-value vorder-instance 'order-id) company))
	 (payment-mode (if mainorder (slot-value mainorder 'payment-mode)))
	 (header (list "Product" "Product Qty" "Unit Price"  "Sub-total"))
	 (odtlst (if mainorder (dod-get-cached-order-items-by-order-id (slot-value mainorder 'row-id) (hunchentoot:session-value :order-func-list) )) )
	 (total   (reduce #'+  (mapcar (lambda (odt)
					 (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst)))
	 (lowwalletbalance (< balance total)))
    
        (cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
	       (:div :class "col-md-12" :align "right" 
		     (if (and lowwalletbalance (equal payment-mode "PRE")) 
			 (htm (:h2 (:span :class "label label-danger" (str (format nil "Low wallet Balance = Rs ~$" balance))))))
					;else
		     (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))
		     (if (equal venorderfulfilled "Y") 
			 (htm (:span :class "label label-info" "FULFILLED"))
					;ELSE
					; Convert the complete button to a submit button and introduce a form here. 
			 (htm (with-html-form "form-vendordercomplete" "dodvenordfulfilled"
				(:input :type "hidden" :name "id" :value (slot-value mainorder 'row-id))
					; (:a :onclick "return CancelConfirm();" :href (format nil "dodvenordcancel?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Cancel")) "&nbsp;&nbsp;"  
				(:div :class "form-group" 
				      (:input :type "submit"  :class "btn btn-primary" :value "Complete")))))))

	
	 (if odtlst (ui-list-vend-orderdetails header odtlst) "No order details")
	 (if mainorder (display-order-header-for-vendor mainorder)))))

(defun dod-controller-vendor-orderdetails ()
 (if (is-dod-vend-session-valid?)
     (with-standard-vendor-page (:title "List Vendor Order Details")   
       (let* (( dodvenorder  (get-vendor-orders-by-orderid (hunchentoot:parameter "id") (get-login-vendor) (get-login-vendor-company)))
	      (customer (get-customer dodvenorder))
	      (wallet (get-cust-wallet-by-vendor customer (get-login-vendor) (get-login-vendor-company)))
	      (balance (slot-value wallet 'balance))
	      (venorderfulfilled (if dodvenorder (slot-value dodvenorder 'fulfilled)))
	      (order (get-order-by-id (hunchentoot:parameter "id") (get-login-vendor-company)))
	      (payment-mode (slot-value order 'payment-mode))
	      (header (list "Product" "Product Qty" "Unit Price"  "Sub-total"))
	      (odtlst (if order (dod-get-cached-order-items-by-order-id (slot-value order 'row-id) (hunchentoot:session-value :order-func-list)  )) )
	      (total   (reduce #'+  (mapcar (lambda (odt)
					      (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst)))
	      (lowwalletbalance (< balance total)))
	 (if order (display-order-header-for-vendor  order)) 
	 (if odtlst (ui-list-vend-orderdetails header odtlst) "No order details")
	 (htm(:div :class "row" 
		   (:div :class "col-md-12" :align "right" 
			 (if (and lowwalletbalance (equal payment-mode "PRE")) 
			     (htm (:h2 (:span :class "label label-danger" (str (format nil "Low wallet Balance = Rs ~$" balance))))))
			     ;else
			     (:h2 (:span :class "label label-default" (str (format nil "Total = Rs ~$" total))))
			 (if (equal venorderfulfilled "Y") 
			     (htm (:span :class "label label-info" "FULFILLED"))
					;ELSE
			    ; Convert the complete button to a submit button and introduce a form here. 
			     (htm 
			     ; (:a :onclick "return CancelConfirm();" :href (format nil "dodvenordcancel?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Cancel")) "&nbsp;&nbsp;"  
			       (:a :href (format nil "dodvenordfulfilled?id=~A" (slot-value order 'row-id) ) (:span :class "btn btn-primary"  "Complete")))))))))
					;ELSE		   						   
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
