(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
(clsql:def-view-class dod-bus-object ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
  (name
    :type (string 50)
    :initarg :name)
   
 (created-by
    :TYPE INTEGER
    :INITARG :created-by)
   (bus-obj-created-by
    :ACCESSOR get-bus-obj-created-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-users
                          :HOME-KEY created-by
                          :FOREIGN-KEY row-id
                          :SET NIL))
 
  
   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR policy-attr-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL)))

     (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)

        (active-flg
    :type (string 1)
    :void-value "Y"
    :initarg :active-flg)



   (:base-table dod_bus_object))


;;;;; DOD_BUS_TRANSACTION

(clsql:def-view-class dod-bus-transaction ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
  (name
    :type (string 50)
    :initarg :name)
 
 (uri
  :type (string 100)
    :initarg :name)
 
 (trans-func
  :type (string 100)
    :initarg :trans-func)

 (auth-policy-id
  :type integer
  :initarg :auth-policy-id)
  (bus-tran-policy
    :ACCESSOR get-bus-tran-policy
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-auth-policy
                          :HOME-KEY auth-policy-id
                          :FOREIGN-KEY row-id
                          :SET NIL))

(bo-id
 :type integer
 :initarg :bo-id)
(bus-object-for-bus-tran
 :accessor get-bus-object-for-bus-tran
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-bus-object
                          :HOME-KEY bo-id
                          :FOREIGN-KEY row-id
                          :SET NIL))
 

(trans-type
 :type (string 15)
 :initarg :trans-type)
  
 (created-by
    :TYPE INTEGER
    :INITARG :created-by)
   (bus-tran-created-by
    :ACCESSOR get-bus-tran-created-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-users
                          :HOME-KEY created-by
                          :FOREIGN-KEY row-id
                          :SET NIL))
 
  
   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR policy-attr-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL)))

     (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)

        (active-flg
    :type (string 1)
    :void-value "Y"
    :initarg :active-flg)



   (:base-table dod_bus_transaction))

   
