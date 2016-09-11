(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defvar *current-vendor-session* nil)


(defun dod-controller-list-vendors ()
(if (is-dod-session-valid?)
   (let (( dodvendors (get-vendors (get-login-company)))
	 (header (list "Name" "Address" "Phone"  "Action")))
     (if dodvendors (ui-list-vendors header dodvendors) "No vendors"))
     (hunchentoot:redirect "/login")))




(defun ui-list-vendors (header data)
    (standard-page (:title "List DOD Vendors")
    (:h3 "Vendors") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (vendor)
									     (htm (:tr (:td  :height "12px" (str (slot-value vendor 'name)))
										      (:td  :height "12px" (str (slot-value vendor 'address)))
										      (:td  :height "12px" (str (slot-value vendor 'phone)))
		    (:td :height "12px" (:a :href  (format nil  "/delvendor?id=~A" (slot-value vendor 'row-id)) "Delete"))))) data)))))
									  


(defun dod-controller-vendor-loginpage ()
    (standard-vendor-page (:title "Welcome to DAS Platform- Your Demand And Supply destination.")
	(:div :class "row" 
	    (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:form :class "form-vendorsignin" :role "form" :method "POST" :action "dodvendlogin"
		    (:div :class "account-wall"
			(:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			(:h1 :class "text-center login-title"  "Vendor - Login to DAS")
			(:div :class "form-group"
			    (:input :class "form-control" :name "company" :placeholder "Group/Apartment"  :type "text" ))
			(:div :class "form-group"
			    (:input :class "form-control" :name "phone" :placeholder "Phone" :type "text" ))
			(:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Login"))))))
))
  


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
		     (:a :class "navbar-brand" :href "#" :title "DAS" (:img :style "width: 30px; height: 30px;" :src "/resources/demand&supply.png" )  ))
		 (:div :class "collapse navbar-collapse" :id "navHeaderCollapse"
		     (:ul :class "nav navbar-nav navbar-left"
			 (:li :class "active" :align "center" (:a :href "/dodvendindex" "Home"))
			 (:li :align "center" (:a :href "#" (print-web-session-timeout))))
		     (:ul :class "nav navbar-nav navbar-right"
			 (:li :align "center" (:a :href "/dodvendlogout" (:span :class "glyphicon glyphicon-log-out") " Logout "  ))))))))

(defun dod-controller-vend-login ()
   (let  ((cname (hunchentoot:parameter "company"))
	      (phone (hunchentoot:parameter "phone")))
	(unless(and
		   ( or (null cname) (zerop (length cname)))
		   ( or (null phone) (zerop (length phone))))
	    (if (equal (dod-vend-login :company-name cname :phone phone) NIL)
		(hunchentoot:redirect "/dodvendindex")
		; Else
		(hunchentoot:redirect  "/dodvendindex")))))

(defun dod-vend-login (&key company-name phone)
 (let* ((vendor (car (clsql:select 'dod-vend-profile :where [and
			      [= [slot-value 'dod-vend-profile 'phone] phone]
			     [= [:deleted-state] "N"]]
			      :caching nil :flatp t)))
	      
	      (vendor-id (if vendor (slot-value vendor 'row-id)))
	      (vendor-name (if vendor (slot-value vendor 'name)))
	      (vendor-tenant-id (if vendor (slot-value (car  (vendor-company vendor)) 'row-id)))
	      (vendor-company-name (if vendor (slot-value (car (if vendor (vendor-company vendor))) 'name)))
	      (vendor-company (if vendor (car (vendor-company vendor)))))
	
	(when (and (equal  vendor-company-name company-name)
		  vendor
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
		))))


(defun dod-controller-vend-index () 
    (if (is-dod-vend-session-valid?)
	(let (( dodorders (get-orders-by-date (hunchentoot:parameter "orderdate") (get-login-vendor-company)))
		 (btnordprd (hunchentoot:parameter "btnordprd"))
		 (orderdate (hunchentoot:parameter "orderdate"))
		 (btnordcus (hunchentoot:parameter "btnordcus")))

	(standard-vendor-page (:title "Welcome to Dairy Ondemand - vendor")
	    (:h3 "Welcome " (str (format nil "~A" (get-login-vendor-name))))
	   
	    (:div :class "row"
		(:div :class "col-sm-12 col-xs-12 col-md-12 col-lg-12" 
		    (:form :class "form-venorders" :method "POST" :action "dodvendindex"
			(:input :type "text" :name "orderdate" :placeholder "dd/mm/yyyy")
			(:button :class "btn btn-primary" :type "submit" :name "btnordprd" "Get Orders by Products")
			(:button :class "btn btn-primary" :type "submit" :name "btnordcus" "Get Orders by Customers")
			(:button :class "btn btn-primary"  :type "submit" :name "btnprint" :onclick "javascript:window.print();" "Print") 
			)
		    ))
	    (cond ((and dodorders btnordprd) (ui-list-vendor-orders dodorders))
		((and dodorders btnordcus) (ui-list-vendor-orders-by-customers dodorders (get-login-vendor)))
		(T ()) )))
					; Else
	(hunchentoot:redirect "/vendor-login.html")))




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
	(hunchentoot:redirect "/vendor-login.html")))




(defun vendor-details-card (vendor-instance)
    (let ((vend-name (slot-value vendor-instance 'name))
	     (vend-address  (slot-value vendor-instance 'address))
	     (phone (slot-value vendor-instance 'phone)))
	(cl-who:with-html-output (*standard-output* nil)
		(:h4 (str vend-name) )
	    (:div (str vend-address))
		(:div  (str phone)))))
		  





