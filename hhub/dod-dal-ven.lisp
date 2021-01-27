;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

(defclass Vendor (BusinessObject)
  ((name)
   (address)
   (phone) 
   (email)
   (firstname)
   (lastname)
   (salutation)
   (title)
   (birthdate)
   (city)
   (state)
   (country)
   (zipcode)
   (picture-path)
   (password)
   (salt)
   (payment-gateway-mode)
   (payment-api-key)
   (payment-api-salt)
   (push-notify-subs-flag)
   (email-add-verified)
   (tenantobj)))




(clsql:def-view-class dod-vend-profile ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (name
    :accessor name
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 70)
    :INITARG :name)
   (address
    :ACCESSOR address 
    :type (string 70)
    :initarg :address)
   (phone
    :accessor phone
    :type (string 30)
    :initarg :phone)

   (email
    :accessor email
    :type (string 255)
    :initarg email)
   (firstname
    :accessor firstname
    :type (string 50)
    :initarg :firstname)
   (lastname
    :accessor lastname
    :type (string 50)
    :initarg :lastname)
   (salutation
    :accessor salutation
    :type (string 10)
    :initarg :salutation)
   (title
    :accessor title
    :type (string 255)
    :initarg :title)
   (birthdate
    :accessor birthdate
    :type clsql:date
    :initarg :birthdate)
   (city
    :accessor city
    :type (string 256)
    :initarg :city)
   (state
    :accessor city
    :type (string 256)
    :initarg :state)
   (country
    :accessor city
    :type (string 256)
    :initarg :country)
   (zipcode
    :accessor zipcode
    :type (string 10)
    :initarg :zipcode)
   
   (picture-path
    :accessor picture-path
    :type (string 256)
    :initarg :picture-path)
   
   (password 
    :accessor password
    :type (string 128) 
    :initarg :password)
   
   (salt 
    :accessor salt
    :type (string 128)
    :initarg :salt)
   
   (payment-gateway-mode
    :accessor payment-gateway-mode
    :type (string 10)
    :initarg :payment-gateway-mode)
   
   (payment-api-key 
    :accessor payment-api-key
    :type (string 40)
    :initarg :payment-api-key)
   
   (payment-api-salt 
    :accessor payment-api-salt
    :type (string 40)
    :initarg :payment-api-salt)
   
   (active-flag
    :accessor active-flag
    :type (string 1)
    :void-value "N"
    :initarg :active-flag ) 

   (push-notify-subs-flag
    :accessor push-notify-subs-flag 
    :type (string 1)
    :void-value "N"
    :initarg :push-notify-subs-flag)

   (email-add-verified
    :type (string 1)
    :void-value "N"
    :initarg :email-add-verified)
   
   
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)
   

   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR vendor-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL)))
   

   
  (:BASE-TABLE dod_vend_profile))



; DOD_VENDOR_TENANTS table is created to support multiple tenants for a given vendor. 

(defclass HHUBVendorTenants (BusinessObject) 
  ((vendor)
   (tenant)
   (default-flag)))

(clsql:def-view-class dod-vendor-tenants ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (vendor-id
    :accessor vendor-id
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE integer 
    :INITARG :vendor-id)
   (tenant-id 
    :type integer 
    :initarg :tenant-id)
    (COMPANY
    :ACCESSOR get-vendor-tenants-list
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET T))
   (default-flag 
       :type (string 1) 
     :void-value "N" 
     :initarg :default-flag)

   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state))
  (:BASE-TABLE dod_vendor_tenants))

;;;;;;;;;;; Generic functions ;;;;;;;;;;;;;;;;;;;;;;;;;

(defgeneric loadVendors (BusinessObjectRepository Company)
  (:documentation "Loads all the Vendors from database"))
(defgeneric getVendor (BusinessObjectRepository Phone)
  (:documentation "Returns the single instance of Vendor object stored in the repository. Key being the phone number."))


;;;;;;;;;; Method implementations ;;;;;;;;;;;;;;;;;;;;

(defmethod getVendor ((vr BusinessObjectRepository) Phone)
  (gethash Phone (slot-value vr 'BusinessObjects)))


(defun transform (db-vendor vendor)
  (with-slots (id name address phone email firstname lastname salutation title birthdate city state country zipcode picture-path password salt payment-gateway-mode payment-api-key
		     payment-api-salt push-notify-subs-flag email-add-verified tenantobj)
      vendor
    (setf id (slot-value db-vendor 'row-id))
    (setf name (slot-value db-vendor 'name))
    (setf address (slot-value db-vendor 'address))
    (setf phone (slot-value db-vendor 'phone))
    (setf email (slot-value db-vendor 'email))
    (setf firstname (slot-value db-vendor 'firstname))
    (setf lastname (slot-value db-vendor 'lastname))
    (setf salutation (slot-value db-vendor 'salutation))
    (setf title (slot-value db-vendor 'title))
    (setf birthdate (slot-value db-vendor 'birthdate))
    (setf city (slot-value db-vendor 'city))
    (setf state (slot-value db-vendor 'state))
    (setf country (slot-value db-vendor 'country))
    (setf zipcode (slot-value db-vendor 'zipcode))
    (setf picture-path (slot-value db-vendor 'picture-path))
    (setf password (slot-value db-vendor 'password))
    (setf salt (slot-value db-vendor 'salt))
    (setf payment-gateway-mode  (slot-value db-vendor 'payment-gateway-mode))
    (setf payment-api-key (slot-value db-vendor 'payment-api-key))
    (setf payment-api-salt (slot-value db-vendor 'payment-api-salt))
    (setf push-notify-subs-flag (slot-value db-vendor 'push-notify-subs-flag))
    (setf email-add-verified (slot-value db-vendor 'email-add-verified))
    (setf tenantobj (vendor-company db-vendor))))


(defmethod getVendorCompany ((vendor BusinessObject))
  (slot-value vendor 'tenantobj))


(defmethod loadVendorByPhone ((vr BusinessObjectRepository) Phone)
  :documentation "This method will load the vendor by phone"
  (let* ((ht (make-hash-table :test 'equal))
	 (allvendors (clsql:select 'dod-vend-profile  :where  [and [= [:phone] Phone] [= [:deleted-state] "N"]] :caching nil :flatp t)))
    (loop for db-vendor in allvendors do
      (let ((key (slot-value db-vendor 'phone))
	    (vendor (make-instance 'Vendor)))
	(transform db-vendor vendor)
	(setf (gethash key ht) vendor)))
    ;; Return  the hash table. 
    (setf (slot-value vr 'BusinessObjects) ht)))
  

(defmethod loadAllVendors ((vr BusinessObjectRepository))
  :documentation "This method will load all the vendors from the database irrespective of the company they belong to."
  (let* ((ht (make-hash-table :test 'equal))
	 (allvendors (clsql:select 'dod-vend-profile  :where  [= [:deleted-state] "N"] :caching nil :flatp t)))
    (loop for db-vendor in allvendors do
      (let ((key (slot-value db-vendor 'phone))
	    (vendor (make-instance 'Vendor)))
	(transform db-vendor vendor)
	(setf (gethash key ht) vendor)))
    ;; Return  the hash table. 
    (setf (slot-value vr 'BusinessObjects) ht)))
  

(defmethod loadVendors ((vr BusinessObjectRepository) company)
  :documentation "This method will load all the vendors from database by company."
  (let* ((tenant-id (slot-value company 'id))
	 (ht (make-hash-table :test 'equal))
	 (allvendors (clsql:select 'dod-vend-profile  :where [and [= [:tenant-id] tenant-id] [= [:deleted-state] "N"]] :caching nil :flatp t)))
    (loop for db-vendor in allvendors do
      (let ((key (slot-value db-vendor 'phone))
	    (vendor (make-instance 'Vendor)))
	(transform db-vendor vendor)
	(setf (gethash key ht) vendor)))
    ;; Return  the hash table. 
    (setf (slot-value vr 'BusinessObjects) ht)))








