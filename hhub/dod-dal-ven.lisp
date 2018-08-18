(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
(clsql:def-view-class dod-vend-profile ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (name
    :accessor vendor-name
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

   (payment-api-key 
    :accessor payment-api-key
    :type (string 40)
    :initarg :payment-api-key)

   (payment-api-salt 
    :accessor payment-api-salt
    :type (string 40)
    :initarg :payment-api-salt)


      
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)

   (approved-flag 
    :type (string 1) 
    :void-value "N"
    :initarg :approved-flag)

    (tenant-id
    :type integer
    :initarg :tenant-id)
(COMPANY
    :ACCESSOR vendor-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET T)))
   

   
  (:BASE-TABLE dod_vend_profile))



; DOD_VENDOR_TENANTS table is created to support multiple tenants for a given vendor. 

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
