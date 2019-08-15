(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun hhub-save-customer-push-subscription ()
  (let* ((browser-name (hunchentoot:parameter "browser-name"))
	 (notificationEndPoint (hunchentoot:parameter "notificationEndPoint"))
	 (publicKey (hunchentoot:parameter "publicKey"))
	 (auth (hunchentoot:parameter "auth"))
	 (list1 nil)
	 (list1 (acons "endpoint" notificationEndPoint list1))
	 (list2 (acons "p256dh" publicKey list2))
	 (list2 (acons "auth" auth list2))
	 (list1 (acons "keys" list2 list1))
	 (endpoint-json (json:encode-json list1)))
    
    (create-push-notify-subscription-for-customer (get-login-customer) endpoint-json browser-name 1 (get-login-cust-tenant-id))
    "Subscription Accepted"))


(defun hhub-save-vendor-push-subscription ()
  (let* ((browser-name (hunchentoot:parameter "browser-name"))
	 (notificationEndPoint (hunchentoot:parameter "notificationEndPoint"))
	 (publicKey (hunchentoot:parameter "publicKey"))
	 (auth (hunchentoot:parameter "auth"))
	 (list1 nil)
	 (list1 (acons "endpoint" notificationEndPoint list1))
	 (list2 (acons "p256dh" publicKey list2))
	 (list2 (acons "auth" auth list2))
	 (list1 (acons "keys" list2 list1))
	 (endpoint-json (json:encode-json list1)))
  
    (create-push-notify-subscription-for-customer (get-login-vendor) endpoint-json browser-name 1 (get-login-vend-tenant-id))
    "Subscription Accepted"))


(defun hhub-remove-customer-push-subscription ()
  (let* ((cust-id (hunchentoot:parameter "cust-id"))
	 (customer (select-customer-by-id cust-id (get-login-customer-company)))
	 (subscription (get-push-notify-subscription-for-customer customer)))
    (remove-webpush-subscription-for-customer subscription)
    "Customer Subscription Removed"))



(defun hhub-remove-vendor-push-subscription ()
  (let* ((vendor-id (hunchentoot:parameter "vendor-id"))
	 (vendor (select-vendor-by-id vendor-id))
	 (subscription (get-push-notify-subscription-for-vendor vendor)))
    (remove-webpush-subscription-for-vendor subscription)
    "Vendor Subscription Removed"))






