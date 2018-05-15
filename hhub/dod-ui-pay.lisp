(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun make-payment-request-html (amount)
  (let* ((description "This is test description")
	 (order-id "testorder1234")
	 (mode "LIVE")
	 (currency "INR")
	 (customer-name "Test customer")
	 (customer-email "pawan.deshpande@gmail.com")
	 (customer-phone "+919972022281")
	 (customer-city "Bangalore")
	 (customer-country "India")
	 (customer-zipcode "560096")
	 (return-url "http://www.highrisehub.com/hhub/custpaymentsuccess")
	 (return-url-failure "http://www.highrisehub.com/hhub/custpaymentfailure")
	 (param_names (list "amount" "api_key" "city" "country" "currency" "description" "email" "mode" "name" "order_id" "phone" "return_url" "return_url_failure" "zip_code"))
	 (param-values (list amount *PAYMENTAPIKEY* customer-city customer-country currency description customer-email mode customer-name order-id  customer-phone return-url return-url-failure  customer-zipcode))
	 (params-alist (pairlis param_names param-values))
	 (hash (generatehashkey params-alist  *PAYMENTAPISALT* :sha512)))
    					;do something
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (:form :class "form-makepaymentrequest" :role "form" :method "POST" :action "https://biz.traknpay.in/v2/paymentrequest"
		    (:div :class "form-group" 
			 (:input :class "form-control" :name "amount"  :maxlength "10" :value amount  :placeholder "Enter Amount"  :type "text" ))
		  (:input :class "form-control" :type "hidden" :value *PAYMENTAPIKEY* :name "api_key") 
		  (:input :class "form-control" :type "hidden" :value order-id :name "order_id") 
		  (:input :class "form-control" :type "hidden" :value mode :name "mode") ; Change this to LIVE for real payment request. 
		  (:input :class "form-control" :type "hidden" :value currency :name "currency")
		  (:input :class "form-control" :type "hidden" :value description :name "description")
		  (:input :class "form-control" :type "hidden" :value customer-name :name "name")
		  (:input :class "form-control" :type "hidden" :value customer-email :name "email")
		  (:input :class "form-control" :type "hidden" :value customer-phone :name "phone")
		  (:input :class "form-control" :type "hidden" :value customer-city :name "city")
		  (:input :class "form-control" :type "hidden" :value customer-country :name "country")
		   (:input :class "form-control" :type "hidden" :value hash :name "hash") 
		  (:input :class "form-control" :type "hidden" :value customer-zipcode :name "zip_code")
		  (:input :class "form-control" :type "hidden" :value return-url :name "return_url") 
		  		 
		  (:div :class "form-group"
			(:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))
	


(defun dod-controller-make-payment-request-action ()
 (if (is-dod-cust-session-valid?) 
					;do something
  (let* ((api-key (hunchentoot:parameter "api_key"))
	(order-id (hunchentoot:parameter "order_id"))
	(mode (hunchentoot:parameter "mode"))
	(currency (hunchentoot:parameter "currency"))
	(description (hunchentoot:parameter "description"))
	(name (hunchentoot:parameter "name"))
	(return-url (hunchentoot:parameter "return_url"))
	(hash (hunchentoot:parameter "hash"))
	(paramname (list "api_key" "order_id" "mode" "currency" "description" "name" "return_url" "hash" ) ) 
	(paramvalue (list api-key order-id mode currency description name return-url hash))
	(param-alist (pairlis paramname paramvalue )))
    (json:decode-json-from-string  (map 'string 'code-char(drakma:http-request "https://biz.traknpay.in/v2/paymentrequest"
												      :method :POST
												      :parameters param-alist  ))))
      
      ;else
  (hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-customer-payment-successful-page ()
  (if (is-dod-cust-session-valid?)
      (standard-customer-page (:title "Payment Successful" ) 
	(:div :class "row" 
	      (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		    (:h4 "Payment Successful"))))
       (hunchentoot:redirect "/hhub/customer-login.html")))



(defun dod-controller-customer-payment-failure-page ()
  (if (is-dod-cust-session-valid?)
      (standard-customer-page (:title "Payment Failure! " ) 
	(:div :class "row" 
	      (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		    (:h4 "Payment Failure! Please contact your System Administrator or try after some time."))))
       (hunchentoot:redirect "/hhub/customer-login.html")))
