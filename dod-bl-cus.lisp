(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun list-cust-profiles (company)
  (let ((tenant-id (slot-value company 'row-id)))
  (clsql:select 'dod-cust-profile  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching *dod-database-caching*  :flatp t )))



(defun select-customer-by-name (name-like-clause company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[like  [:name] name-like-clause]]
		:caching *dod-database-caching* :flatp t))))



(defun select-customer-by-id (id company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=  [:row-id] id]]
		:caching *dod-database-caching* :flatp t))))



(defun select-deleted-customer-by-id (id company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "Y"]
		[= [:tenant-id] tenant-id]
		[=  [:row-id] id]]
		:caching *dod-database-caching* :flatp t))))


(defun delete-customer (object)
  (let ((cust-id (slot-value object 'row-id))
	 (tenant-id (slot-value object 'tenant-id)))
	 (delete-cust-profile cust-id tenant-id)))

(defun restore-deleted-customer (object)
  (let ((cust-id (slot-value object 'row-id))
	(tenant-id (slot-value object 'tenant-id)))
    (restore-deleted-cust-profile (list cust-id) tenant-id)))

    

(defun delete-cust-profile( id tenant-id )
  (let ((dodcust (car (clsql:select 'dod-cust-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value dodcust 'deleted-state) "Y")
    (clsql:update-record-from-slot dodcust 'deleted-state)))


(defun deduct-wallet-balance (amount customer-instance)
(let ((cur-balance (slot-value customer-instance 'wallet-balance)))
(progn  (setf (slot-value customer-instance 'wallet-balance) (- cur-balance amount))
  (clsql:update-record-from-slot customer-instance 'wallet-balance))))

(defun delete-cust-profiles ( list company)
(let ((tenant-id (slot-value company 'row-id)))  
  (mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-cust-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
			  (setf (slot-value doduser 'deleted-state) "Y")
			  (clsql:update-record-from-slot doduser  'deleted-state))) list )))


(defun restore-deleted-cust-profile ( list tenant-id )
(mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-cust-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value doduser 'deleted-state) "N")
    (clsql:update-record-from-slot doduser 'deleted-state))) list ))

  

(defun create-customer(name address phone wallet-bal city state zipcode company  )
  (let ((tenant-id (slot-value company 'row-id)))
 (clsql:update-records-from-instance (make-instance 'dod-cust-profile
						    :name name
						    :address address
						    :phone phone
						    :wallet-balance wallet-bal
						    :city city 
						    :state state 
						    :zipcode zipcode
						    :tenant-id tenant-id
						    :deleted-state "N"))))
 





