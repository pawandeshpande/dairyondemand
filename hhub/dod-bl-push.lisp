(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun persist-push-notify-subscription(cust-id vendor-id person-type endpoint publickey auth  browser-name created-by tenant-id)
 (clsql:update-records-from-instance (make-instance 'dod-webpush-notify
						    :cust-id cust-id
						    :vendor-id vendor-id
						    :person-type person-type 
						    :endpoint endpoint
						    :publickey publickey
						    :auth auth 
						    :browser-name browser-name 
						    :perm-granted "Y"
						    :expired "N"
						    :tenant-id tenant-id
						    :active-flag "Y"
						    :created-by created-by
						    :deleted-state "N")))



(defun create-push-notify-subscription-for-customer (customer endpoint publickey auth browser-name created-by tenant-id) 
  (let ((cust-id (if customer (slot-value customer 'row-id)))
	(user-id (slot-value created-by 'row-id)))
    (persist-push-notify-subscription cust-id nil "CUSTOMER" endpoint publickey auth browser-name user-id tenant-id)))


(defun create-push-notify-subscription-for-vendor (vendor endpoint publickey auth browser-name created-by tenant-id) 
  (let ((vendor-id (if vendor (slot-value vendor 'row-id)))
	(user-id (slot-value created-by 'row-id)))
    (persist-push-notify-subscription nil vendor-id "VENDOR" endpoint publickey auth browser-name user-id tenant-id)))



(defun remove-webpush-subscription-for-customer (subscriptions-list)
  (delete-subscriptions subscriptions-list))


(defun delete-subscriptions ( list)
  (mapcar (lambda (object)
		(setf (slot-value object 'deleted-state) "Y")
		(clsql:update-record-from-slot object  'deleted-state)) list ))




(defun remove-webpush-subscription-for-vendor (subscriptions-list)
  (delete-subscriptions subscriptions-list))

(defun get-push-notify-subscription-for-customer (customer)
  (let ((cust-id (slot-value customer 'row-id))
	(tenant-id (slot-value customer 'tenant-id)))
    (clsql:select 'dod-webpush-notify :where
		  [and
		  [= [:deleted-state] "N"]
		  [= [:active-flag] "Y"]
		  [= [:cust-id] cust-id]
		  [= [:person-type] "CUSTOMER"]
		  [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))


(defun get-push-notify-subscription-for-vendor (vendor)
  (let ((vendor-id (slot-value vendor 'row-id))
	(tenant-id (slot-value vendor 'tenant-id)))
     (clsql:select 'dod-webpush-notify :where
		  [and
		  [= [:deleted-state] "N"]
		  [= [:active-flag] "Y"]
		  [= [:vendor-id] vendor-id]
		  [= [:person-type] "VENDOR"]
		  [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))







