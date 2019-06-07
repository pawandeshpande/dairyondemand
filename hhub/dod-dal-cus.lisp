(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
(clsql:def-view-class dod-cust-profile ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (NAME
    :accessor name
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 70)
    :INITARG :name)
   (address
    :ACCESSOR address 
    :type (string 256)
    :initarg :address)
   (phone
    :accessor phone
    :type (string 30)
    :initarg :phone)

   (password 
    :accessor password
    :type (string 128) 
    :initarg :password)

   (salt 
    :accessor salt
    :type (string 128)
    :initarg :salt)
   
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
   
   
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)
   
   (cust-type
    :accessor cust-type
    :type (string 50)
    :initarg :cust-type)
   
   
   (active-flag
    :type (string 1)
    :void-value "N"
    :initarg :active-flag)
   
   
   
   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR customer-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET T)))
  
  
  (:BASE-TABLE dod_cust_profile))


;;;;; Create class for DOD_CUST_WALLET table
(clsql:def-view-class dod-cust-wallet ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   
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
   
   (all-customers
    :ACCESSOR get-all-customers
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-cust-profile
	                  :HOME-KEY cust-id
                          :FOREIGN-KEY row-id
                          :SET T))
   
   
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
   
   
   
   (balance 
    :type (number ) 
    :initarg :balance)
   
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)
   
   
   
   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR get-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET nil)))
  
  
  (:BASE-TABLE dod_cust_wallet))


