(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun get-orders-by-company (company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
(clsql:select 'dod-order  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching nil :flatp t )))


(defun get-order-by-id (id company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-order  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:row-id] id]]    :caching nil :flatp t ))))



(defun get-order-by-context-id (context-id company-instance)
 (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-order  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:context-id] context-id]]    :caching nil :flatp t ))))



(defun get-orders-for-customer (customer)
(let ((tenant-id (slot-value customer 'tenant-id))
	(cust-id (slot-value customer 'row-id)))
(clsql:select 'dod-order  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] cust-id ]]
		:caching nil :flatp t )))

(defun get-orders-by-date (ord-date company-instance)
(let ((tenant-id (slot-value company-instance 'row-id)))
(clsql:select 'dod-order  :where
    [and [= [:deleted-state] "N"]
    [= [:tenant-id] tenant-id]
    [=[:ord-date] ord-date]]
		:caching nil :flatp t )))


(defun get-latest-order-for-customer (customer)
  (let ((tenant-id (slot-value customer 'tenant-id))
	(cust-id (slot-value customer 'row-id)))
(car (clsql:select 'dod-order  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] cust-id ]
		[= [:row-id] (get-max-order-id cust-id tenant-id)]]    :caching nil :flatp t ))))
  
(defun get-max-order-id (customer-id tenant-id)
  (clsql:select [max [row-id]] :from 'dod-order  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:cust-id] customer-id]]    :caching nil :flatp t ))
  



(defun update-order (order-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance order-instance))



(defun delete-order( order-instance )
  (let ((tenant-id (slot-value order-instance 'tenant-id))
	(id (slot-value order-instance 'row-id)))
  (let ((dodorder (car (clsql:select 'dod-order :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodorder 'deleted-state) "Y")
    (clsql:update-record-from-slot dodorder 'deleted-state))))



(defun delete-orders ( list company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (mapcar (lambda (id)  (let ((dodorder (car (clsql:select 'dod-order :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodorder 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodorder  'deleted-state))) list )))


(defun restore-deleted-orders ( list tenant-id )
(mapcar (lambda (id)  (let ((dodorder (car (clsql:select 'dod-order :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodorder 'deleted-state) "N")
    (clsql:update-record-from-slot dodorder 'deleted-state))) list ))

  

  
(defun persist-order(order-date customer-id request-date ship-date ship-address context-id tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-order
						    :ord-date order-date
						    :cust-id customer-id
						    :req-date request-date
						    :shipped-date ship-date
						    :ship-address ship-address
						    :context-id context-id
						    :tenant-id tenant-id
						    :deleted-state "N")))



(defun create-order (order-date customer-instance request-date ship-date ship-address context-id company-instance)
  (let ((customer-id (slot-value  customer-instance 'row-id) )
	(tenant-id (slot-value company-instance 'row-id)))
    (persist-order order-date customer-id request-date ship-date ship-address context-id tenant-id)))



(defun create-order-from-pref (order-pref-list order-date request-date ship-date ship-address customer-instance company-instance)
  (let ((uuid (uuid:make-v1-uuid )))
    (progn 	(create-order order-date customer-instance request-date ship-date ship-address (print-object uuid nil) company-instance)
		(let ((order (get-order-by-context-id (print-object uuid nil) company-instance)))
		      (mapcar (lambda (preference)
				(let* ((prd (get-opf-product preference))
				       (unit-price (slot-value prd 'unit-price))
				      (prd-qty (slot-value preference 'prd-qty)))
				  (create-order-details order prd  prd-qty unit-price company-instance))) order-pref-list)))))



(defun create-order-from-shopcart (order-details-list products  order-date request-date ship-date ship-address customer-instance company-instance)
  (let ((uuid (uuid:make-v1-uuid )))
    (progn 	(create-order order-date customer-instance request-date ship-date ship-address (print-object uuid nil) company-instance)
		(let ((order (get-order-by-context-id (print-object uuid nil) company-instance)))
		      (mapcar (lambda (odt)
				(let* ((prd (search-prd-in-list (slot-value odt 'prd-id) products))
				       (unit-price (slot-value odt 'unit-price))
				      (prd-qty (slot-value odt 'prd-qty)))
				  (create-order-details order prd  prd-qty unit-price company-instance))) order-details-list)))))


