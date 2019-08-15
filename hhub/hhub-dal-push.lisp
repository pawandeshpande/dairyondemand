(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
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

   (endpoint-json
    :accessor endpoint-json 
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 512)
    :INITARG :endpoint-json)

   
   (expired
    :type (string 1)
    :void-value "N"
       :initarg :expired)

  (expires-on
    :accessor expires-on
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE clsql:date
    :initarg :expires-on)


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
   (updated
    :type clsql:wall-time
    :initarg :updated)

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

   (updated-by
    :type integer
    :initarg :updated-by)
   (updated-by-user
    :accessor get-updated-by-user
    :db-kind :join
    :db-info (:join-class dod-users
			  :home-key updated-by
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


