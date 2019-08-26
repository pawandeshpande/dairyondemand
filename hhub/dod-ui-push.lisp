(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun hhub-save-customer-push-subscription ()
  (let ((endpoint (hunchentoot:parameter "notificationEndPoint"))
	(publicKey (hunchentoot:parameter "publicKey"))
	(auth (hunchentoot:parameter "auth")))
    (create-push-notify-subscription-for-customer (get-login-customer) endpoint publicKey auth "chrome"  (select-user-by-id 1 1) (get-login-cust-tenant-id))
    "Subscription Accepted"))


(defun hhub-save-vendor-push-subscription ()
  (let ((endpoint (hunchentoot:parameter "notificationEndPoint"))
	(publicKey (hunchentoot:parameter "publicKey"))
	(auth (hunchentoot:parameter "auth")))
    (create-push-notify-subscription-for-vendor (get-login-vendor) endpoint publicKey auth  "chrome" (select-user-by-id 1 1) (get-login-vend-tenant-id))
    "Subscription Accepted"))


(defun hhub-remove-customer-push-subscription ()
  (let* ((customer (get-login-customer))
	 (subscriptions-list (get-push-notify-subscription-for-customer customer)))
    (remove-webpush-subscription-for-customer subscriptions-list )
    "Customer Subscription Removed"))



(defun hhub-remove-vendor-push-subscription ()
  (let* ((vendor-id (hunchentoot:parameter "vendor-id"))
	 (vendor (select-vendor-by-id vendor-id))
	 (subscription (get-push-notify-subscription-for-vendor vendor)))
    (remove-webpush-subscription-for-vendor subscription)
    "Vendor Subscription Removed"))



(defun test-webpush-notification-for-vendor (vendor)
  (let* ((title "HighriseHub")
	 (message (format nil "Welcome to HighriseHub - ~A" (slot-value vendor 'name)))
	 (clickTarget "https://www.highrisehub.com")
	 (subscriptions (get-push-notify-subscription-for-vendor vendor)))
    (mapcar (lambda (subscription)
	      (let ((endpoint (slot-value subscription 'endpoint))
		    (publickey (slot-value subscription 'publickey))
		    (auth  (slot-value subscription 'auth)))
		(send-webpush-notification title message clickTarget endpoint publickey auth))) subscriptions)))




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

