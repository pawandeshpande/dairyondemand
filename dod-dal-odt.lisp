(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(clsql:def-view-class dod-order-details ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   
(order-id
    :accessor get-order-order
    :TYPE integer
    :initarg :order-id)

(prd-id
    :accessor get-odt-prd-id
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE integer
    :initarg :prd-id)
(productobject
 :ACCESSOR get-odt-product
 :db-kind :join
 :db-info (:join-class dod-prd-master
		       :home-key prd-id
		       :foreign-key row-id
		       :set nil))


(prd-qty
    :accessor get-product-qty
    :DB-CONSTRAINTS :NOT-NULL
    :TYPE integer
    :initarg :prd-qty)


(unit-price
 :accessor get-unit-price
 :db-constraints :not-null
 :type (number 5 2)
 :initarg :unit-price)

(deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)

    (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR customer-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET nil)))

   
  (:BASE-TABLE dod_order_details))
