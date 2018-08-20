(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;;;;;;;;;;;;;;;;;;;; business logic for dod-bus-object ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun get-bus-object (id)
  (car (clsql:select 'dod-bus-object  :where [and [= [:deleted-state] "N"] [= [:row-id] id]]    :caching *dod-database-caching* :flatp t )))


(defun get-bus-object-by-name (name)
  (car (clsql:select 'dod-bus-object  :where [and [= [:deleted-state] "N"] [= [:name] name]]    :caching *dod-database-caching* :flatp t )))

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

(defun get-bus-transaction (id)
 (car  (clsql:select 'dod-bus-transaction  :where [and [= [:deleted-state] "N"] [= [:row-id] id]]    :caching *dod-database-caching* :flatp t )))

(defun select-bus-trans-by-trans-func (name)
  (car (clsql:select 'dod-bus-transaction  :where
		[and [= [:deleted-state] "N"]
		[= [:trans-func] name]]
     :caching *dod-database-caching* :flatp t )))


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

(defun update-bus-transaction (instance); This function has side effect of modifying the database record.
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

(defun persist-bus-transaction(name  uri  bo-id trans-type trans-func tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-bus-transaction
						    :name name
						    :uri uri
						    :bo-id bo-id 
						    :auth-policy-id 1
						    :trans-type trans-type
						    :active-flg "Y" 
						    :trans-func trans-func
						    :tenant-id tenant-id
						    :deleted-state "N")))
 


(defun create-bus-transaction (name  uri  bus-object trans-type trans-func company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id))
	(bo-id (if bus-object (slot-value bus-object 'row-id))))
    	      (persist-bus-transaction name  uri  bo-id trans-type trans-func  tenant-id)))


; POLICY ENFORCEMENT POINT 
(defun has-permission1 (policy-id subject resource action env)
  (let* ((policy (if policy-id (select-auth-policy-by-id policy-id)))
	(policy-func (if policy (slot-value policy 'policy-func))))
     (if policy-func (funcall (intern  (string-upcase policy-func)) subject resource action env))))


(defun has-permission (transaction)
  :documentation "This function is the PEP (Policy Enforcement Point) in the ABAC system"
  (let* ((policy-id (if transaction (slot-value transaction 'auth-policy-id)))
	(policy (if policy-id (search-prd-in-list policy-id (HHUB-GET-CACHED-AUTH-POLICIES))))
	(policy-func (if policy (slot-value policy 'policy-func))))
     (if policy-func (funcall (intern  (string-upcase policy-func) :hhub) transaction))))


