;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
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
  



(defun create-push-notify-subscription-for-customer (params)
   (let* ((customer (cdr (assoc "customer" params :test 'equal)))
	 (endpoint (cdr (assoc "endpoint" params :test 'equal)))
	 (publickey (cdr (assoc "publickey" params :test 'equal)))
	 (auth (cdr (assoc "auth" params :test 'equal)))
	 (browser-name (cdr (assoc "browser-name" params :test 'equal)))
	 (created-by (cdr (assoc "created-by" params :test 'equal)))
	 (tenant-id (cdr (assoc "tenant-id" params :test 'equal)))
	 (cust-id (if customer (slot-value customer 'row-id)))
	 (user-id (slot-value created-by 'row-id)))
     ;Here we are going to call the DB layer. We will call the DB Adapter here in future. 
     (persist-push-notify-subscription cust-id nil "CUSTOMER" endpoint publickey auth browser-name user-id tenant-id)))



  

(defun com-hhub-businessfunction-bl-createpushnotifysubscriptionforvendor (params)
  :documentation "Business layer function to create the push notification subscriptions for a given vendor. This function is responsible for creating the push notify subscription for vendor and save it current business session for further requirement within the session."
  (let ((datastoragein (cdr (assoc "data-storage-in" params :test 'equal))))
    (if (equal datastoragein "tempstorage") 
	(let ((returnlist (hhub-execute-business-function "com.hhub.businessfunction.tempstorage.createpushnotifysubscriptionforvendor" params)))
	  (if (null (nth 1 returnlist))
	      (nth 0 returnlist) ; return this value 
	      ;; else if condition is signalled
	      (error 'hhub-business-function-error :errstring "Error during vendor subscription create in temporary storage")))
					;else data is stored in database
	(let ((returnlist (hhub-execute-business-function  "com.hhub.businessfunction.db.createpushnotifysubscriptionforvendor" params)))
	  (if (null (nth 1 returnlist))
	      (nth 0 returnlist) ; return this value
	      ;; else if condition is signalled
	      (error 'hhub-business-function-error :errstring "Error during vendor subscription create in  database."))))))



(defun com-hhub-business-function-db-getpushnotifysubscriptionforvendor  (params)
:documentation "This function will create push notify subscription in a temporary storage." 
  (if params 
      (error 'hhub-business-function-error :errstring "Function not implemented")))



(defun com-hhub-businessfunction-tempstorage-createpushnotifysubscriptionforvendor (params)
:documentation "This function is responsible for storing the HHUBEntity in temporary storage."
  (let* ((business-session (cdr (assoc "business-session" params :test 'equal)))
	 
	 (vendor (cdr (assoc "vendor" business-session :test 'equal)))
	 (vendor-id (if vendor (slot-value vendor 'row-id)))
	 (tenant (cdr (assoc "tenant" business-session :test 'equal)))
	 (tenant-id (if tenant (slot-value tenant 'row-id)))
	 (endpoint (cdr (assoc "endpoint" params :test 'equal)))
	 (publickey (cdr (assoc "publickey" params :test 'equal)))
	 (auth (cdr (assoc "auth" params :test 'equal)))
	 (browser-name (cdr (assoc "browser-name" params :test 'equal)))
	 (created-by (cdr (assoc "created-by" params :test 'equal)))
	 (user-id (slot-value created-by 'row-id))
	 (WebPushNotifyVendorInstance (make-instance 'WebPushNotifyVendor)))
    
    (setf (slot-value WebPushNotifyVendorInstance 'id)  (format nil "~A" (uuid:make-v1-uuid )))
    (setf (slot-value WebPushnotifyVendorInstance 'vendor) vendor)
    (setf (slot-value WebPushnotifyVendorInstance 'browser-name) browser-name)
    (setf (slot-value WebPushnotifyVendorInstance 'endpoint) endpoint)
    (setf (slot-value WebPushnotifyVendorInstance 'publickey) publickey)
    (setf (slot-value WebPushnotifyVendorInstance 'auth) auth)
    (setf (slot-value WebPushnotifyVendorInstance 'expired) "N")
    (setf (slot-value WebPushnotifyVendorInstance 'perm-granted) "Y")
		   ;; Now fill the tombstone fields
    (setf (slot-value WebPushnotifyVendorInstance 'tenant) tenant)
    ;; Add the newly created 
    (addBusinessSessionObject business-session "WebPushNotifyVendor" WebPushNotifyVendorInstance)
    ;; Update the Business session 
    (updateBusinessSession business-session) 
    ;; WE may save the WebPushNotifyVendor instance to the 
    (createEntity WebPushNotifyVendorInstance *HHUBENTITY-WEBPUSHNOTIFYVENDOR-HT*)))
    

(defun delete-subscriptions ( list)
  (mapcar (lambda (object)
		(setf (slot-value object 'deleted-state) "Y")
		(clsql:update-record-from-slot object  'deleted-state)) list ))


(defun remove-webpush-subscription (params)
  (let ((subscription-list (cdr (assoc "subscription-list" params :test 'equal))))
  (delete-subscriptions subscription-list)))

(defun get-push-notify-subscription-for-customer (params)
  (let* ((customer (cdr (assoc "customer" params :test 'equal)))
	 (cust-id (slot-value customer 'row-id))
	 (tenant-id (slot-value customer 'tenant-id)))
    (clsql:select 'dod-webpush-notify :where
		  [and
		  [= [:deleted-state] "N"]
		  [= [:active-flag] "Y"]
		  [= [:cust-id] cust-id]
		  [= [:person-type] "CUSTOMER"]
		  [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))



(defun com-hhub-businessfunction-bl-getpushnotifysubscriptionforvendor (params)
  :documentation "Business layer function to get the push notification subscriptions for a given vendor. This function will act like a proxy and pass on the params to DB layer function."
  (let ((datastoragein (cdr (assoc "data-storage-in" params :test 'equal))))
    (if (equal datastoragein "tempstorage") 
	(let ((returnlist (hhub-execute-business-function "com.hhub.businessfunction.tempstorage.getpushnotifysubscriptionforvendor" params)))
	  (if (null (nth 1 returnlist))
	      (nth 0 returnlist) ; return this value 
	      ;; else if condition is signalled
	      (error 'hhub-business-function-error :errstring "Error during vendor subscription fetch from temporary storage")))
					;else data is stored in database
	(let ((returnlist (hhub-execute-business-function  "com.hhub.businessfunction.db.getpushnotifysubscriptionforvendor" params)))
	  (if (null (nth 1 returnlist))
	      (nth 0 returnlist) ; return this value
	      ;; else if condition is signalled
	      (error 'hhub-business-function-error :errstring "Error during vendor subscription fetch from database."))))))
	  
(defun com-hhub-businessfunction-db-getpushnotifysubscriptionforvendor (params)
  :documentation "This function will fetch the push notify subscription from Database"
  (let* ((vendor (cdr (assoc "vendor" params :test 'equal)))
	 (vendor-id (slot-value vendor  'row-id))
	 (tenant-id (slot-value vendor 'tenant-id))
	 (exceptions nil)
	 (returnvalues  (clsql:select 'dod-webpush-notify :where
				      [and
				      [= [:deleted-state] "N"]
				      [= [:active-flag] "Y"]
				      [= [:vendor-id] vendor-id]
				      [= [:person-type] "VENDOR"]
				      [= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t)))
	(values returnvalues exceptions)))
   

(defun com-hhub-business-function-tempstorage-getpushnotifysubscriptionforvendor  (params)
:documentation "This function will fetch the push notify subscription from a temporary storage." 
  (if params 
      (error 'hhub-business-function-error :errstring "Function not implemented")))



