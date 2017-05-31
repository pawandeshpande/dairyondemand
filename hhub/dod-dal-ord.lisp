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

   (order-amt
    :type (number)
    :initarg :order-amt)


(comments
    :accessor comments
    :type (string 70)
    :initarg :comments)

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

(status
    :type (string 3)
    :initarg :status)

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; CLASS - DOD-VENDOR-ORDERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(clsql:def-view-class dod-vendor-orders ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   
(order-id
    :accessor odt-order-id
    :TYPE integer
    :initarg :order-id)


(vendor-id
    :accessor odt-vendor-id
    :db-constraints :NOT-NULL
    :type integer
    :initarg :vendor-id)

(vendorobject
	:accessor odt-vendorobject
	:db-kind :join
	:db-info (:join-class dod-vend-master
		     :home-key vendor-id
		     :foreign-key row-id
		     :set nil))

(fulfilled
    :type (string 1)
    :void-value "N"
    :initarg :fulfilled)


(status 
    :accessor odt-status
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE (string 3)
    :initarg :status)


    (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET nil)))

   
  (:BASE-TABLE dod_vendor_orders))
