(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun get-opreflist-by-company (company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
(clsql:select 'dod-ord-pref  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching nil :flatp t )))


(defun get-opref-by-id (id company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-ord-pref  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:row-id] id]]    :caching nil :flatp t ))))

(defun get-opreflist-for-customer (customer)
(let ((tenant-id (slot-value customer 'tenant-id))
	(cust-id (slot-value customer 'row-id)))
(clsql:select 'dod-ord-pref  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] cust-id ]]
		:caching nil :flatp t )))


(defun get-latest-opref-for-customer (customer)
  (let ((tenant-id (slot-value customer 'tenant-id))
	(cust-id (slot-value customer 'row-id)))
(car (clsql:select 'dod-ord-pref  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] cust-id ]
		[= [:row-id] (get-max-opref-id cust-id tenant-id)]]    :caching nil :flatp t ))))
  
(defun get-max-opref-id (customer-id tenant-id)
 (clsql:select [max [row-id]] :from 'dod-opref  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] customer-id]]    :caching nil :flatp t ))
  



(defun update-opref (opref-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance opref-instance))



(defun delete-opref( opref-instance )
  (let ((tenant-id (slot-value opref-instance 'tenant-id))
	(id (slot-value opref-instance 'row-id)))
  (let ((dodorderpref (car (clsql:select 'dod-ord-pref :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodorderpref 'deleted-state) "Y")
    (clsql:update-record-from-slot dodorderpref 'deleted-state))))



(defun delete-oprefs ( list company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (mapcar (lambda (id)  (let ((dodorderpref (car (clsql:select 'dod-ord-pref :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodorderpref 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodorderpref  'deleted-state))) list )))


(defun restore-deleted-orderprefs ( list tenant-id )
(mapcar (lambda (id)  (let ((dodorderpref (car (clsql:select 'dod-ord-pref :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodorderpref 'deleted-state) "N")
    (clsql:update-record-from-slot dodorderpref 'deleted-state))) list ))

  

  
(defun persist-orderpref( customer-id product-id prd-qty  tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-ord-pref
						    :cust-id customer-id
						    :prd-id product-id
						    :prd-qty prd-qty
						    :tenant-id tenant-id
						    :deleted-state "N")))



(defun create-opref (customer product prd-qty  company-instance)
  (let ((customer-id (slot-value  customer 'row-id) )
	(tenant-id (slot-value company-instance 'row-id))
	(product-id (slot-value product 'row-id)))
    (persist-orderpref customer-id product-id prd-qty tenant-id )))



