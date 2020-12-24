;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

;; Generic Functions

;; Entity class
;; Webpush notify general class
(defclass WebPushNotify (BusinessObject) 
  ((browser-name)
   (endpoint)
   (publickey)
   (auth)
   (perm-granted)
   (expired)))


;; Entity class
;; Web Push Notify Customer class represents the webpush notify subscription for the customer. 
(defclass WebPushNotifyCustomer (WebPushNotify)
  ((customer)))

;; Entity class. 
;; Web Push Notify Vendor class represents the webpush notify subscription for the Vendor. 
(defclass WebPushNotifyVendor (WebPushNotify)
  ((vendor)))


(defclass WebPushNotifyVendorContainer (BusinessObjectContainer)
  ((WebPushNotifyVendor)))

(defgeneric getWebPushNotifyVendorSubscriptions (BusinessObjectContainer Vendor)
  (:documentation "Get Web Push Notify Subscriptions for a given Vendor"))
  

;; This is database releated class. 

(clsql:def-view-class dod-webpush-notify ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg row-id)

   
   (cust-id
    :type integer 
    :initarg :cust-id)
   (customer
    :ACCESSOR get-customer
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-cust-profile
	                  :HOME-KEY cust-id
                          :FOREIGN-KEY row-id
                          :SET nil))

   (vendor-id
    :type integer
    :initarg :vendor-id)
   (vendor
    :ACCESSOR get-vendor
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-vend-profile
	                  :HOME-KEY vendor-id
                          :FOREIGN-KEY row-id
                          :SET nil))
   
   
   (person-type
    :type (string 30)
    :initarg :person-type) 

   (browser-name
    :accessor browser-name
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 30)
    :INITARG :browser-name)

   (endpoint
    :accessor endpoint 
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 512)
    :INITARG :endpoint)

   (publicKey
    :accessor publickey
    :db-constraints :not-null
    :type (string 100)
    :initarg :publickey)

   (auth
    :accessor auth
    :db-constraints :not-null
    :type (string 100)
    :initarg :auth)

   
   (expired
    :type (string 1)
    :void-value "N"
       :initarg :expired)

   (active-flag
    :type (string 1)
    :void-value "N"
       :initarg :active-flag)


   (deleted-state
    :type (string 1)
    :void-value "N"
       :initarg :deleted-state)


   (perm-granted
    :type (string 1) 
    :void-value "Y"
    :initarg :perm-granted)
   
   (created
    :type clsql:wall-time
    :initarg :created)

   (created-by
    :type integer
    :initarg :created-by)
   (created-by-user
    :accessor get-created-by-user
    :db-kind :join
    :db-info (:join-class dod-users
			  :home-key created-by
			  :foreign-key row-id
			  :set NIL))


   
    (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR get-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET T)))

   
  (:BASE-TABLE DOD_WEBPUSH_NOTIFY))


  (defmethod getWebPushNotifyVendorSubscriptions ((webpushsubscontainer BusinessObjectContainer) vendor)
    (let ((db-vendor (getDBVendor vendor))
	  (vendor-id (slot-value 'db-vendor 'row-id))
	  (db-vendorpushsubs     (clsql:select 'dod-webpush-notify :where
						[and
						[= [:deleted-state] "N"]
						[= [:active-flag] "Y"]
						[= [:vendor-id] vendor-id]
						[= [:person-type] "VENDOR"]
						[= [:tenant-id] tenant-id]] :caching *dod-database-caching* :flatp t))
	  (WebPushNotifyVendorSubs (slot-value webpushsubscontainer 'WebPushNotifyVendor)))
      (mapcar (lambda (db-vendorpush)
		(with-slots (browser-name  endpoint publickey auth perm-granted expired vendor) WebPushNotifyVendorSubs
		  (setf browser-name (slot-value db-vendorpush 'browser-name)))) db-vendorpushsubs)))
		  

      



  
