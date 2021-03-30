;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)



(defun hhub-controller-get-vendor-push-subscription ()
  (let ((params nil))
	(setf params (acons "vendor" (get-login-vendor)  params))
    (let ((templist '())
	  (mylist '())
	  (appendlist '())
	  (returnlist (hhub-execute-business-function  "com.hhub.businessfunction.bl.getpushnotifysubscriptionforvendor" params)))
      (if (null (nth 1 returnlist)) ; check for any exeptions from business function. If there are no exceptions, then we will go ahead with the data processing.  
	  (progn (mapcar (lambda(sub)
		    (let ((ep (endpoint sub)))
		      (setf templist (acons "endpoint" ep templist))
		      (setf appendlist (append appendlist (list templist))) 
		      (setf templist nil))) (nth 0 returnlist))
		 (setf mylist (acons "result" appendlist  mylist))    
		 (setf mylist (acons "success" 1 mylist)))
					; else
	  (progn
	    (setf mylist (acons "exception" (nth 1 returnlist) mylist)) 
	    (setf mylist (acons "success" 0 mylist))))

      (json:encode-json-to-string mylist))))
  
	

(defun hhub-save-customer-push-subscription ()
  (let ((endpoint (hunchentoot:parameter "notificationEndPoint"))
	(publicKey (hunchentoot:parameter "publicKey"))
	(auth (hunchentoot:parameter "auth"))
	(params nil))
	
    (setf params (acons "customer" (get-login-customer) params))
    (setf params (acons "endpoint" endpoint params))
    (setf params (acons "publickey" publickey params))
    (setf params (acons "auth" auth params))
    (setf params (acons "browser-name" "chrome" params))
    (setf params (acons "created-by" (select-user-by-id 1 1) params))
    (setf params (acons "tenant-id" (get-login-cust-tenant-id) params))

    (hhub-business-adapter 'create-push-notify-subscription-for-customer params)
    "Subscription Accepted"))


(defun hhub-controller-save-vendor-push-subscription ()
  (let ((endpoint (hunchentoot:parameter "notificationEndPoint"))
	(publicKey (hunchentoot:parameter "publicKey"))
	(auth (hunchentoot:parameter "auth"))
	(params nil))
	
    (setf params (acons "endpoint" endpoint params))
    (setf params (acons "publickey" publickey params))
    (setf params (acons "auth" auth params))
    (setf params (acons "browser-name" "chrome" params))
    (setf params (acons "created-by" (select-user-by-id 1 1) params))
    (setf params (acons "data-storage-in" "tempstorage" params))
    (setf params (acons "business-session" (gethash (hunchentoot:session-value :login-vendor-business-session-id) *HHUBBUSINESSSESSIONS-HT*) params))

    (let ((returnlist (hhub-execute-business-function  "com.hhub.businessfunction.bl.createpushnotifysubscriptionforvendor" params)))
      (if (nth 1 returnlist)
      "Subscription Accepted"))))


(defun hhub-remove-customer-push-subscription ()
  (let ((params nil))
    (setf params (acons "customer" (get-login-customer) params))
    (let* ((subscription-list (hhub-business-adapter 'get-push-notify-subscription-for-customer params)))
      (setf params nil)
      (if subscription-list (setf params (acons "subscription-list" subscription-list params)))
      (hhub-business-adapter 'remove-webpush-subscription params)
    "Customer Subscription Removed")))

(defun hhub-remove-vendor-push-subscription ()
  (let ((params nil))
    (setf params (acons "vendor" (get-login-vendor) params))
    (let* ((subscription-list (hhub-business-adapter 'get-push-notify-subscription-for-vendor  params)))
      (setf params nil)
      (if subscription-list (setf params (acons "subscription-list" subscription-list params)))
      (hhub-business-adapter 'remove-webpush-subscription params)
    "Vendor Subscription Removed")))


(defun test-webpush-notification-for-vendor (vendor)
  (let* ((title "HighriseHub")
	 (message (format nil "Welcome to HighriseHub - ~A" (slot-value vendor 'name)))
	 (clickTarget "https://www.highrisehub.com")
	 (params nil))
    (setf params (acons "vendor" vendor params))
    (let ((returnlist (hhub-execute-business-function  "com.hhub.businessfunction.bl.getpushnotifysubscriptionforvendor" (setf params (acons "vendor" vendor  params))))) 
      (if (null (nth 1 returnlist))
	  (mapcar (lambda (subscription)
		    (let ((endpoint (slot-value subscription 'endpoint))
			  (publickey (slot-value subscription 'publickey))
			  (auth  (slot-value subscription 'auth)))
		      (send-webpush-notification title message clickTarget endpoint publickey auth))) (nth 0 returnlist))))))



(defun send-webpush-message (person message)
  (let* ((title "HighriseHub")
	 (params nil)
	 (returnlist  (cond ((equal 'DOD-CUST-PROFILE (type-of person)) (hhub-execute-business-function  "com.hhub.businessfunction.bl.getpushnotifysubscriptionforcustomer" (setf params (acons "customer" person params))))
			    ((equal 'DOD-VEND-PROFILE (type-of person)) (hhub-execute-business-function  "com.hhub.businessfunction.bl.getpushnotifysubscriptionforvendor" (setf params (acons "vendor" person params))))))
	 (clickTarget "https://www.highrisehub.com"))
    (if (null (nth 1 returnlist)) ; check for any exeptions from business function. If there are no exceptions, then we will go ahead with the data processing.  
	(mapcar (lambda (subscription)
		  (let ((endpoint (slot-value subscription 'endpoint))
			(publickey (slot-value subscription 'publickey))
			(auth  (slot-value subscription 'auth)))
		    (send-webpush-notification title message clickTarget endpoint publickey auth))) (nth 0 returnlist)))))





(defun test-webpush-notification-for-customer (customer)
  (let* ((title "HighriseHub")
	 (message (format nil "Welcome to HighriseHub - ~A" (slot-value customer 'name)))
	 (clickTarget "https://www.highrisehub.com")
	 (subscriptions (get-push-notify-subscription-for-customer customer)))
    (mapcar (lambda (subscription)
	      (let ((endpoint (slot-value subscription 'endpoint))
		    (publickey (slot-value subscription 'publickey))
		    (auth  (slot-value subscription 'auth)))
		(send-webpush-notification title message clickTarget endpoint publickey auth))) subscriptions)))


					;Experiment with push notification 
(defun send-webpush-notification (title message clickTarget endpoint publicKey auth)
:documentation "Test Webpush Notification" 
  (let* ((paramnames (list "title" "message" "clickTarget" "endpoint" "publicKey" "auth"))
	 (paramvalues (list title message clickTarget endpoint publicKey auth))
	 (param-alist (pairlis paramnames paramvalues))
	 (headers nil) 
	 (headers (acons "auth-secret" "highrisehub1234" headers)))
    ; Execution
    (drakma:http-request "https://www.highrisehub.com/push/notify/user"
			 :additional-headers headers
			     :parameters param-alist)))



(defun send-sms-notification (number senderid message)
  (let* ((paramnames (list "number" "senderid" "message"))
	 (paramvalues (list number senderid message))
	 (param-alist (pairlis paramnames paramvalues))
	 (headers nil) 
	 (headers (acons "auth-secret" "highrisehub1234" headers)))
    ; Execution
    (drakma:http-request "https://www.highrisehub.com/sms/sendsms"
			 :additional-headers headers
			     :parameters param-alist)))
  
