(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
(clsql:def-view-class dod-prd-master ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg row-id)
   (prd-name
    :accessor prd-name
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 70)
    :INITARG :prd-name)
   (vendor-id
    :type integer 
    :initarg :vendor-id)
   (vendor
    :ACCESSOR get-prd-vendor
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-vend-profile
	                  :HOME-KEY vendor-id
                          :FOREIGN-KEY row-id
                          :SET NIL))
   (qty-per-unit
    :accessor qty-per-unit
    :type (string 30)
    :initarg :qty-per-unit)

   (prd-image-path
    :accessor prd-image-path
    :type (string 256)
    :initarg :prd-image-path)
   


   (unit-price
    :type (number)
    :initarg :unit-price)

      (units-in-stock
    :type (number)
    :initarg :units-in-stock)

   (deleted-state
    :type (string 1)
    :void-value "N"
       :initarg :deleted-state)

      (subscribe-flag
	  :type (string 1)
	  :void-value "N"
	  :initarg :subscribe-flag)

    (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR product-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET T)))

   
  (:BASE-TABLE dod_prd_master))



