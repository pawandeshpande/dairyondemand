(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(clsql:def-view-class dod-order ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   
(ord-date
    :accessor order-date
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE clsql:date
    :initarg :ord-date)

(req-date
    :accessor get-requested-date
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE clsql:date
    :initarg :req-date)

(shipped-date
    :accessor get-shipped-date
    :TYPE clsql:date
    :INITARG :shipped-date)   


 (ship-address
    :ACCESSOR get-ship-address 
    :type (string 100)
    :initarg :ship-address)

   (order-fulfilled
    :type (string 1)
    :void-value "N"
    :initarg :order-fulfilled)


 (context-id
    :ACCESSOR get-context-id 
    :type (string 100)
    :initarg :context-id)


    (cust-id
    :type integer
    :initarg :cust-id)
   (customer
    :ACCESSOR get-ord-customer
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-cust-profile
	                  :HOME-KEY cust-id
                          :FOREIGN-KEY row-id
                          :SET nil))

  
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)

    (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR order-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET nil)))

   
  (:BASE-TABLE dod_order))
