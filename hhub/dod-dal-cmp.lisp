(in-package :dairyondemand)
(clsql:def-view-class dod-company ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (name
    :type (string 255)
    :initarg :name)
   (address
    :type (string 512)
    :initarg :address)


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
      
      
 (created-by
    :TYPE INTEGER
    :INITARG :created-by)
   (user-created-by
    :ACCESSOR company-created-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-users
                          :HOME-KEY created-by
                          :FOREIGN-KEY row-id
                          :SET NIL))
   (updated-by
    :TYPE INTEGER
    :INITARG :updated-by)
   (user-updated-by
    :ACCESSOR company-updated-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS dod-users
                          :HOME-KEY updated-by
                          :FOREIGN-KEY row-id
                          :SET NIL))
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)
  
   (employees
    :reader company-employees
    :db-kind :join
    :db-info (:join-class dod-users
                          :home-key row-id
                          :foreign-key tenant-id
                          :set t)))
  (:base-table dod_company))




