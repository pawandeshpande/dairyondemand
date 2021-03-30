;; -*- mode: common%-lisp; coding: utf-8 -*-
(in-package :hhub)


(defun hhub-html-page-footer ()
  (cl-who:with-html-output (*standard-output* nil)
    (:footer
        (:div :class "container"
            (:div :class "row"
                (:div :class "col-lg-12"
                    (:ul :class "list-inline"
			 (:li (:a :href "https://www.highrisehub.com" "Home"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :href "#about" "About"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :href "contactuspage" "Contact Us"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :href "pricing" "Pricing"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :href "tnc.html" "Terms and Conditions"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :href "privacy.html" "Privacy Policy"))
			 (:li :class "footer-menu-divider" "&sdot;")
			 (:li (:a :id "hhubcookiepolidylink" :data-toggle "modal" :data-target (format nil "#hhubcookiepolicy-modal")  :href "#"  "Cookie Policy")))))
	    (:div :class "row"
		  (:div :class "col-lg-12" 
			 (:p :class="copyright text-muted small" "Copyright &copy; HighriseHub 2021. All Rights Reserved")))))
        (modal-dialog (format nil "hhubcookiepolicy-modal") "Accept Cookies" (modal.hhub-cookie-policy))))

(defun modal.hhub-cookie-policy ()
  (cl-who:with-html-output (*standard-output* nil)
    (:div :class "panel panel-default"
	  (:div :class "panel-heading" "Cookie Policy"
	  (:div :class "row"
		(:div :class "col-lg-12"
		      (:p :class "small"  "To enrich and perfect your online experience, HighriseHub uses Cookies, similar technologies and services provided by others to display personalized content, appropriate advertising and store your preferences on your computer.")

(:p :class "small" "A cookie is a string of information that a website stores on a visitor's computer, and that the visitor's browser provides to the website each time the visitor returns. HighriseHub uses cookies to help HighriseHub identify and track visitors, their usage of https://www.highrisehub.com, and their website access preferences. HighriseHub visitors who do not wish to have cookies placed on their computers should set their browsers to refuse cookies before using HighriseHub's websites, with the drawback that certain features of HighriseHub's websites may not function properly without the aid of cookies.")

(:p :class "small" "By continuing to navigate our website without changing your cookie settings, you hereby acknowledge and agree to HighriseHub's use of cookies.")))
	  (with-html-form "hhubcookiesacceptform" "hhubcookiesacceptaction"
	    (:div :class "form-group"
		  	      (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Accept and Continue")))))))

(defun hhub-controller-contactus-page ()
  (with-standard-admin-page (:title "HighriseHub - Contact Us")
    (:div :class "row"
	  (:div :class "col-lg-4" (:h2 "HighriseHub - Contact Us")))
    (:div :class "row"
	  (:div :class "col-lg-6"
		(:img :class "profile-img" :src "/img/logo.png" :alt "")
		(with-html-form "hhubcontactusform" "contactusaction" 
		  (:div :class "panel panel-default"
			(:div :class "panel-heading" "To: support@highrisehub.com"
			      (:div :class "panel-body"
			;;Panel content
			(:div :class "form-group"
			      (:input :class "form-control" :name "firstname" :maxlength "90"  :value "" :placeholder "First Name " :type "text" :required T ))
			(:div :class "form-group"
			      (:input :class "form-control" :name "lastname" :maxlength "90"  :value "" :placeholder "Last Name " :type "text" :required T ))
			(:div :class "form-group"
			      (:input :class "form-control" :name "companyname" :maxlength "90"  :value "" :placeholder "Company Name " :type "text" :required T ))


			(:div :class "form-group"
			      (:input :class "form-control" :name "contactusemail" :maxlength "90"  :value "" :placeholder "Business Email Address " :type "email" :data-error "Invalid Email Address" :required T ))
			(:div :class "form-group"
			      (:input :class "form-control" :name "contactusemailsubject" :maxlength "100"  :value "" :placeholder "Subject " :type "text" :required T  ))
			(:div :class "form-group"
			      (:label :for "contactemailmessage" "Message")
			      (:textarea :class "form-control" :name "contactusemailmessage"  :placeholder "Message ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" :required T ))
			(:div :class "form-group" :id "charcount")
			(:div :class "form-group"
			  (:div :class "g-recaptcha" :data-sitekey *HHUBRECAPTCHAKEY* ))
			(:div :class "form-group"
			      (:label "By clicking submit, you consent to allow HighriseHub to store and process the personal information submitted above to provide you the content requested. We will not share your information with other companies."))
			(:div :class "form-group"
			      (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))
      (hhub-html-page-footer)))

(defun hhub-controller-contactus-action ()
  (let* ((firstname (hunchentoot:parameter "firstname"))
	 (lastname (hunchentoot:parameter "lastname"))
	 (captcha-resp (hunchentoot:parameter "g-recaptcha-response"))
	  (paramname (list "secret" "response" ) ) 
	  (paramvalue (list *HHUBRECAPTCHASECRET*  captcha-resp))
	  (param-alist (pairlis paramname paramvalue ))
	  (json-response (json:decode-json-from-string  (map 'string 'code-char(drakma:http-request "https://www.google.com/recaptcha/api/siteverify"
                       :method :POST
                       :parameters param-alist  ))))
     	 
	 (companyname (hunchentoot:parameter "companyname"))
	 (contactusemail (hunchentoot:parameter "contactusemail"))
	 (contactusemailsubject (hunchentoot:parameter "contactusemailsubject"))
	 (contactusemailmessage (hunchentoot:parameter "contactusemailmessage")))

    (unless (and (or (null firstname) (zerop (length firstname)))
		(or (null lastname) (zerop (length lastname)))
		(or (null companyname) (zerop (length companyname)))
		(or (null contactusemail) (zerop (length contactusemail)))
		(or (null contactusemailsubject) (zerop (length contactusemailsubject)))
		(or (null contactusemailmessage) (zerop (length contactusemailmessage))))
	  (cond 
	    ((null (cdr (car json-response))) (dod-response-captcha-error))
	    (T (send-contactus-email firstname lastname companyname contactusemail contactusemailsubject contactusemailmessage))))
    (with-standard-admin-page (:title "Thank You For Contacting Us")
      (:div :class "row"
	    (:div :class "col-lg-12"
		  (:img :class "profile-img" :src "/img/logo.png" :alt "")))
      (:div :class "row"
	    (:div :class "col-lg-12"
		  (:h3 "Thank You for contacting us. We will get back to you shortly.")))
      (hhub-html-page-footer))))
		  

(defun hhub-controller-pricing ()
  (let ((names (list  "Free - 30 Days" "Basic" "Professional"))
	(prices (list "00" "499" "999"))
	(pricing-features 
	  (list  "No of Vendors" "No of Customers" "Revenue/Month" "Inventory Control" "Product Images & Zoom" "Guest Login/Phone Order" "Products" "Shipping Integration" "Payment Gateway Integration" 
			 "Domain Registration" "Sub Domains" "Email/SMS (Transactional)" "Browser Notifications"  "Email Support" "Products Bulk Upload (CSV)" "Product Subscriptions" "Wallets"  "COD Orders"
			  "Customer Loyalty Points" "API Access" "Blocked IPs" "Save Cart" "Customer Groups" "SEO Tools" "Facebook Store"))
	(features-active (list T T NIL T T T T T T NIL NIL T T T T T T T NIL NIL NIL NIL nil nil nil))
	(pricing-table
	  (list	   
	   (list "1"  "50"   "Upto &#8377; 1 Lac"   "Y" "1"  "Y" "100"  "Y" "Y" "Y" "N" "Y" "Y" "Y" "N" "N" "N" "N" "N")
	   (list "5"  "500"  "Upto &#8377; 5 Lacs"  "Y" "5"  "Y" "1000" "Y" "Y" "Y" "2" "Y" "Y" "Y" "Y" "Y" "N" "N" "N")
	   (list "10" "1000" "Upto &#8377; 10 Lacs" "Y" "10" "Y" "3000" "Y" "Y" "Y" "5" "Y" "Y" "Y" "Y" "Y" "Y" "Y" "Y" ))))
    (with-standard-admin-page 
      (:link :href "/css/pricing.css" :rel "stylesheet")
	   (:div :id "hhub_pt"  
		 (:section
		  (:div :class "container"
			(:div :class "row"
			      (:div :class "col-md-12"
			     (:div  :class="price-heading clearfix"
				    (:h1 "HighriseHub Pricing")))))
		  (:div  :class  "container"  
			 (:div  :class  "row"
				;; Print Header
				(format-pricing-features pricing-features features-active )
				;; Print Data
				(mapcar  (lambda (name price items)
					   (cl-who:with-html-output (*standard-output* nil)
					     (format-pricing-plans name price items features-active))) names prices pricing-table)))))
		  (:div :class "row"
			(:div :class "col-lg-12" (:hr)))
		  (hhub-html-page-footer))))

(defun format-pricing-features (features features-active)
  (cl-who:with-html-output (*standard-output* nil)
    (:div  :class  "col-md-3"  
	   (:div  :class  "generic_content clearfix"  
		  (:div  :class  "generic_head_price clearfix"  
			 (:div  :class  "generic_head_content clearfix"  
				(:div  :class  "head_bg"  )
				(:div  :class  "head"  
				       (:span "Plan Details")))
					; price starts
			 	(:div  :class  "generic_price_tag clearfix"    
				       (:span :class  "price"  
					      (:span :class  "sign"  "")
					      (:span :class  "currency" "")
					      (:span :class  "cent"  "")
					      (:span :class  "month"  ""))))
		  
		  (:div  :class  "generic_feature_list"  
			 (:ul  
				 (mapcar (lambda (obj active)
					   (if active (cond
							((equal obj "Y") (cl-who:htm (:li (:span "&#10003"))))
							((equal obj "N") (cl-who:htm (:li (:span "&#10005"))))
							(T (cl-who:htm (:li (:span (cl-who:str obj))))))))  features features-active)))))))
  

  

(defun format-pricing-plans (name price plans active-plans)
  (cl-who:with-html-output (*standard-output* nil)
    (:div  :class  "col-md-3"  
     (:div  :class  "generic_content clearfix"  
       (:div  :class  "generic_head_price clearfix"  
	(:div  :class  "generic_head_content clearfix"  
	 (:div  :class  "head_bg"  )
	 (:div  :class  "head"  
	  (:span (cl-who:str name))))
					; price starts
	(:div  :class  "generic_price_tag clearfix"    
	       (:span :class  "price"  
		      (:span :class  "sign"  "&#8377;")
		      (:span :class  "currency" (cl-who:str price))
		      (:span :class  "cent"  "00")
		      (:span :class  "month"  "/Mon"))))
       (:div  :class  "generic_feature_list"  
	      (:ul  
	       (mapcar (lambda (obj active)
			 (if active (cond
			   ((equal obj "Y") (cl-who:htm (:li (:span "&#10003"))))
			   ((equal obj "N") (cl-who:htm (:li (:span "&#10005"))))
			   (T (cl-who:htm (:li (:span (cl-who:str obj))))))))   plans active-plans)))
       (:div  :class  "generic_price_btn clearfix"  
	      (:a :class  "" :href  ""  "Sign up"))))))
    
