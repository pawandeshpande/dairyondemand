(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;;;;;;;;;;;;;;;;;;;; business logic for dod-bus-object ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun get-bus-object (tenant-id)
  (clsql:select 'dod-bus-object  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching *dod-database-caching* :flatp t ))

(defun select-bus-object-by-company (company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
 (clsql:select 'dod-bus-object  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]]
     :caching *dod-database-caching* :flatp t )))

  
(defun persist-bus-object(name tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-bus-object
						    :name name
						    :active-flg "Y" 
						    :tenant-id tenant-id
						    :deleted-state "N")))
 


(defun create-bus-object (name company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id))) 
	      (persist-bus-object name tenant-id)))





;;;;;;;;;;;;;;;;; Functions for dod-bus-transaction ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-bus-transaction (tenant-id)
  (clsql:select 'dod-bus-transaction  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching *dod-database-caching* :flatp t ))

(defun select-bus-trans-by-company (company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
 (clsql:select 'dod-bus-transaction  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]]
     :caching *dod-database-caching* :flatp t )))

  (defun select-bus-trans-by-name (name-like-clause company-instance )
      (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-bus-transaction :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[like  [:name] name-like-clause]]
		:caching *dod-database-caching* :flatp t))))



(defun update-auth-attr-lookup (instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance instance))

(defun delete-bus-transaction( id company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (let ((object (car (clsql:select 'dod-bus-transaction :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value object 'deleted-state) "Y")
    (clsql:update-record-from-slot object 'deleted-state))))



(defun delete-bus-transactions ( list company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (mapcar (lambda (id)  (let ((object (car (clsql:select 'dod-bus-transaction :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
			  (setf (slot-value object 'deleted-state) "Y")
			  (clsql:update-record-from-slot object  'deleted-state))) list )))


(defun restore-deleted-bus-transactions ( list company-instance )
    (let ((tenant-id (slot-value company-instance 'row-id)))
(mapcar (lambda (id)  (let ((object (car (clsql:select 'dod-bus-transaction :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value object 'deleted-state) "N")
    (clsql:update-record-from-slot object 'deleted-state))) list )))

(defun persist-bus-transaction(name description uri auth-policy-id bo-id trans-type tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-bus-transaction
						    :name name
						    :description description
						    :uri uri
						    :auth-policy-id auth-policy-id
						    :bo-id bo-id 
						    :trans-type trans-type
						     :active-flg "Y" 
						    :tenant-id tenant-id
						    :deleted-state "N")))
 


(defun create-bus-transaction (name description uri auth-policy bus-object trans-type company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id))
	(auth-policy-id (slot-value auth-policy 'row-id))
	(bo-id (slot-value bus-object 'row-id)))
    	      (persist-bus-transaction name description uri auth-policy-id bo-id trans-type  tenant-id)))

