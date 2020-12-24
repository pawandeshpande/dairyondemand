;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)

(clsql:def-view-class crm-account ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
  ; not using currently
;   (account-no
 ;   :type (string 10)
  ;  :db-constraints :not-null
   ; :initarg :account-no)
   (name
    :type (string 30)
    :db-constraints :not-null
    :initarg :name)
   (description
    :type (string 100)
    :initarg :description)

   (account-type
    :type integer
    :db-constraints :not-null
    :initarg :account-type)
   (type-of-account
    :accessor type-of-account
    :db-kind :join
    :db-info (:join-class crm-account-type
			  :home-key account-type
			  :foreign-key row-id
			  :set nil))
   
   (created-by
    :TYPE INTEGER
    :INITARG :created-by)
   (user-created-by
    :ACCESSOR company-created-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-users
                          :HOME-KEY created-by
                          :FOREIGN-KEY row-id
                          :SET NIL))

   (updated-by
    :TYPE INTEGER
    :INITARG :updated-by)
   (user-updated-by
    :ACCESSOR company-updated-by
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-users
                          :HOME-KEY updated-by
                          :FOREIGN-KEY row-id
                          :SET NIL))

   (tenant-id
    :type integer
    :initarg :tenant-id)
   (COMPANY
    :ACCESSOR account-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL))

   
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state)
   (pawan
    :type (string 30)
    :initarg :pawan
    :db-kind :virtual)  )
  (:base-table crm_account))



(clsql:def-view-class crm-account-type ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
   (name
    :type (string 50)
    :db-constraints :not-null
    :initarg :name)
    (description
    :type (string 255)
    :initarg :description))
(:base-table crm_account_type))


