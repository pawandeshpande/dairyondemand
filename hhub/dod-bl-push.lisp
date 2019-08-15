(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun persist-push-notify-subscription(cust-id vendor-id person-type endpoint-json browser-name created-by tenant-id)
 (clsql:update-records-from-instance (make-instance 'hhub-webpush-notify
						    :cust-id cust-id
						    :vendor-id vendor-id
						    :person-type person-type 
						    :endpoint-json endpoint-json 
						    :browser-name browser-name 
						    :perm-granted "Y"
						    :expired "N"
						    :expires-on NIL
						    :tenant-id tenant-id
						    :active-flag "Y"
						    :created-by created-by
						    :deleted-state "N")))



(defun create-push-notify-subscription-for-customer (customer endpoint-json browser-name created-by tenant-id) 
  (let ((cust-id (if customer (slot-value customer 'row-id)))
	(user-id (slot-value created-by 'row-id)))
    (persist-push-notify-subscription cust-id nil "CUSTOMER" endpoint-json browser-name user-id tenant-id)))


(defun create-push-notify-subscription-for-vendor (vendor endpoint-json browser-name created-by tenant-id) 
  (let ((vendor-id (if vendor (slot-value vendor 'row-id)))
	(user-id (slot-value created-by 'row-id)))
    (persist-push-notify-subscription nil vendor-id "VENDOR" endpoint-json browser-name user-id tenant-id)))


(defun get-push-notify-subscription-for-customer (customer)
  (let ((cust-id (slot-value customer 'row-id))
	(tenant-id (slot-value customer 'tenant-id)))
    (clsql:select 'hhub-webpush-notify :where
		  [and
		  [= [:deleted-state] "N"]
		  [= [:active-flag] "Y"]
		  [= [:person-id] cust-id]
		  [= [:person-type] "CUSTOMER"]
		  [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))

(defun remove-webpush-subscription-for-customer (customer) 
  (let* ((cust-id (slot-value customer 'cust-id))
	(tenant-id (slot-value customer 'tenant-id))
	(push-subscription (car (clsql:select 'dod-webpush-notify :where [and [= [:cust-id] cust-id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value push-subscription 'deleted-state) "Y")
    (clsql:update-record-from-slot push-subscription 'deleted-state)))



(defun remove-webpush-subscription-for-vendor (vendor) 
  (let* ((vendor-id (slot-value vendor 'vendor-id))
	(tenant-id (slot-value vendor 'tenant-id))
	(push-subscription (car (clsql:select 'dod-webpush-notify :where [and [= [:vendor-id] vendor-id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value push-subscription 'deleted-state) "Y")
    (clsql:update-record-from-slot push-subscription 'deleted-state)))



(defun get-push-notify-subscription-for-vendor (vendor)
  (let ((vendor-id (slot-value vendor 'row-id))
	(tenant-id (slot-value vendor 'tenant-id)))
    (clsql:select 'hhub-webpush-notify :where
		  [and
		  [= [:deleted-state] "N"]
		  [= [:active-flag] "Y"]
		  [= [:person-id] vendor-id]
		  [= [:person-type] "VENDOR"]
		  [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))







