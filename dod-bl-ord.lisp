(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun set-order-fulfilled ( value order-instance company-instance)
    :documentation "value should be Y or N, followed by order instance and company instance"
    (let ((vendor-order-items (get-vendor-order-items-by-orderid  (slot-value order-instance 'row-id) company-instance))
	     (order-items (get-order-details order-instance)))
	     
    (if (eq (order-company order-instance) company-instance)
	(progn
	; complete the vendor order items 	
	    (mapcar (lambda (voitem)
			(progn     (setf (slot-value voitem 'status) "CMP")
			    (setf (slot-value voitem 'fulfilled) value)
			    (update-vendor-order voitem)))   vendor-order-items)
	    ; complete the order items 
	    (mapcar (lambda (oitem)
			(progn  (setf (slot-value oitem 'status) "CMP")
			    (setf (slot-value oitem 'fulfilled) value)
			(update-order-detail oitem)))    order-items)
					; Complete the main order
	     (setf (slot-value order-instance 'order-fulfilled) value)
	    (setf (slot-value order-instance 'shipped-date) (get-date))
	    (setf (slot-value order-instance 'status ) "CMP")
	    (update-order order-instance)))))   





(defun get-orders-by-company (company-instance &optional (fulfilled "N"))
  (let ((tenant-id (slot-value company-instance 'row-id)))
      (clsql:select 'dod-order  :where [and [= [:deleted-state] "N"]
	  [= [:tenant-id] tenant-id]
	  [= [:order-fulfilled] fulfilled]]    :caching *dod-debug-mode* :flatp t )))




(defun get-orders-for-vendor (vendor-instance &optional (fulfilled "N"))
    (let* ((tenant-id (slot-value vendor-instance 'tenant-id))
	      (company (car (vendor-company vendor-instance)))
	      (vendor-id (slot-value vendor-instance 'row-id))
	 (ordlist     (clsql:select [order-id] :from  'dod-vendor-orders :where
	    [and [= [:tenant-id] tenant-id]
		  [= [:vendor-id] vendor-id]
		   [= [:fulfilled] fulfilled]] 
			  :distinct t :caching nil :flatp t)))
	(remove nil (mapcar (lambda (order-id)
		    (get-order-by-id order-id company fulfilled)) ordlist))))



(defun get-order-by-id (id company-instance  &optional (fulfilled "N"))
  (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-order  :where
		[and [= [:deleted-state] "N"]
	   [= [:tenant-id] tenant-id]
	    [= [:order-fulfilled] fulfilled]
		[=[:row-id] id]]    :caching *dod-debug-mode* :flatp t ))))

(defun get-vendor-order-items-by-orderid (id company-instance  &optional (fulfilled "N"))
  (let ((tenant-id (slot-value company-instance 'row-id)))
   (clsql:select 'dod-vendor-orders  :where
	   [and [= [:tenant-id] tenant-id]
	   [= [:fulfilled] fulfilled]
	   [=[:order-id] id]]    :caching *dod-debug-mode* :flatp t )))



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
		[=[:cust-id] cust-id ]] :order-by '(([row-id] :desc))
		:caching nil :flatp t )))

(defun get-orders-by-date (req-date company-instance)
(let ((tenant-id (slot-value company-instance 'row-id)))
(clsql:select 'dod-order  :where
    [and [= [:deleted-state] "N"]
    [= [:tenant-id] tenant-id]
    [=[:req-date] req-date]]
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

(defun update-vendor-order (voitem); This function has side effect of modifying the database record.
    (clsql:update-records-from-instance voitem))  


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

  

  
(defun persist-order(order-date customer-id request-date ship-date ship-address  context-id order-amt tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-order
					 :ord-date order-date
					 :cust-id customer-id
					 :req-date request-date
					 :shipped-date ship-date
					 :ship-address ship-address
					 :context-id context-id
					 :tenant-id tenant-id
					 :order-fulfilled "N"
					 :status "PEN"
					 :order-amt order-amt
					 :deleted-state "N")))



(defun create-order (order-date customer-instance request-date ship-date ship-address context-id order-amt company-instance)
  (let ((customer-id (slot-value  customer-instance 'row-id) )
	(tenant-id (slot-value company-instance 'row-id)))
    (persist-order order-date customer-id request-date ship-date ship-address  context-id order-amt tenant-id)))



(defun create-order-from-pref (order-pref-list order-date request-date ship-date ship-address order-amt  customer-instance company-instance)
  (let ((uuid (uuid:make-v1-uuid )))
      (progn 	  (create-order order-date customer-instance request-date ship-date ship-address (print-object uuid nil) order-amt company-instance)
		(let ((order (get-order-by-context-id (print-object uuid nil) company-instance)))
		      (mapcar (lambda (preference)
				  (let* ((prd (get-opf-product preference))
						       (unit-price (slot-value prd 'unit-price))
					  (prd-qty (slot-value preference 'prd-qty))
					  
					  )
				  (if (prefpresent-p preference (date-dow request-date)) (create-order-details order prd  prd-qty unit-price company-instance)))) order-pref-list)))))


(defun prefpresent-p (preference day)
    (let  ((lst  (list (if (equal (slot-value preference 'sun) "Y") 0 )
	     (if (equal (slot-value preference 'mon) "Y")  1)
		(if (equal (slot-value preference 'tue) "Y") 2)
	     (if (equal (slot-value preference 'wed) "Y") 3)
		(if (equal (slot-value preference 'thu) "Y") 4)
	     (if (equal (slot-value preference 'fri) "Y") 5) 
		(if (equal (slot-value preference 'sat) "Y") 6))))
	(if (member day lst) t nil)))


(defun create-order-from-shopcart (order-details-list products  order-date request-date ship-date ship-address order-amt  customer-instance company-instance)
  (let ((uuid (uuid:make-v1-uuid )))
    (progn 	(create-order order-date customer-instance request-date ship-date ship-address (print-object uuid nil) order-amt  company-instance)
		(let ((order (get-order-by-context-id (print-object uuid nil) company-instance)))
		      (mapcar (lambda (odt)
				(let* ((prd (search-prd-in-list (slot-value odt 'prd-id) products))
					  (unit-price (slot-value odt 'unit-price))
				      (prd-qty (slot-value odt 'prd-qty)))
				    (create-order-details order prd   prd-qty unit-price company-instance))) order-details-list)))))


