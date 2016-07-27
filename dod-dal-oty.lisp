(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(clsql:def-view-class crm-journal-entry ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
  ; not using currently
;   (opportunity-id
 ;   :type (string 10)
  ;  :db-constraints :not-null
   ; :initarg :opportunity-id)
   (name
    :type (string 30)
    :db-constraints :not-null
    :initarg :name)
   (description
    :type (string 100)
    :initarg :description)

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
    :ACCESSOR journal-entry-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL))

   
   (deleted-state
    :type (string 1)
    :void-value "N"
    :initarg :deleted-state))
  
  (:base-table crm_opportunity))


(clsql:def-view-class crm-journal-debit-credit-entry ()
  ((row-id
    :db-kind :key
    :db-constraints :not-null
    :type integer
    :initarg :row-id)
  
   (acct-id
    :TYPE INTEGER
    :db-constraints :not-null
    :INITARG :acct-id)
   (journal-account-id
    :ACCESSOR journal-entry-account
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-account
                          :HOME-KEY acct-id
                          :FOREIGN-KEY row-id
                          :SET NIL))
     (opty-id
    :TYPE INTEGER
    :INITARG :opty-id)
   (journal-opty-id
    :ACCESSOR journal-entry-opty
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-journal-entry
                          :HOME-KEY opty-id
                          :FOREIGN-KEY row-id
                          :SET NIL))
   (amount
    :type (number)
    :initarg :amount)

   (created-by
    :TYPE INTEGER
    :INITARG :created-by)
   (user-created-by
    :ACCESSOR journal-entry-created-by
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
    :ACCESSOR journal-entry-company
    :DB-KIND :JOIN
    :DB-INFO (:JOIN-CLASS crm-company
	                  :HOME-KEY tenant-id
                          :FOREIGN-KEY row-id
                          :SET NIL)))

  (:base-table crm_acct_opty))


