(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun set-order-fulfilled ( value order-instance company-instance)
    :documentation "value should be Y or N, followed by order instance and company instance"
    (let ((vendor-order (get-vendor-order-instance (slot-value order-instance 'row-id)))
	     (vendor-order-items (get-order-items-for-vendor  order-instance (get-login-vendor) )))
	     
    (if (eq (order-company order-instance) company-instance)
	(progn
	; complete the order items for that particular vendor.  	
	    (mapcar (lambda (voitem)
			(progn     (setf (slot-value voitem 'status) "CMP")
			    (setf (slot-value voitem 'fulfilled) value)
			    (update-order-detail voitem)))   vendor-order-items)
	    (sleep 1) 
	    ; complete the vendor_order  
	    (mapcar (lambda (vo)
			(progn  (setf (slot-value vo 'status) "CMP")
			    (setf (slot-value vo 'fulfilled) value)
			(update-vendor-order vo)))    vendor-order)
					; Complete the main order only if all other vendor-order-items have been completed. 
	    
	    
	    (if (equal (count-order-items-pending order-instance company-instance) 0 ) 
	    (progn (setf (slot-value order-instance 'order-fulfilled) value)
	    (setf (slot-value order-instance 'shipped-date) (get-date))
	    (setf (slot-value order-instance 'status ) "CMP")
	    (update-order order-instance)))
	    
	    (dod-reset-order-functions (get-login-vendor))
	    ))))   





(defun get-orders-by-company (company-instance &optional (fulfilled "N"))
  (let ((tenant-id (slot-value company-instance 'row-id)))
      (clsql:select 'dod-order  :where [and [= [:deleted-state] "N"]
	  [= [:tenant-id] tenant-id]
	  [= [:order-fulfilled] fulfilled]]    :caching *dod-debug-mode* :flatp t )))


(defun count-vendor-orders-completed (vendor order company) 
 (let ((tenant-id (slot-value company 'row-id)) 
       (vendor-id (slot-value vendor 'row-id))
       (order-id (slot-value order 'row-id)))
    
    (first (clsql:select [count [*]] :from 'dod-vendor-order :where 
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:status] "CMP"]
		[= [:fulfilled] "Y"]
		[= [:vendor-id] vendor-id]
		[=[:order-id] order-id]]    :caching nil :flatp t ))))


(defun count-vendor-orders-pending (vendor order company) 
 (let ((tenant-id (slot-value company 'row-id)) 
       (vendor-id (slot-value vendor 'row-id))
       (order-id (slot-value order 'row-id)))
    
    (first (clsql:select [count [*]] :from 'dod-vendor-order :where 
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:status] "PEN"]
		[= [:fulfilled] "N"]
		[= [:vendor-id] vendor-id]
		[=[:order-id] order-id]]    :caching nil :flatp t ))))

(defun get-vendor-order-instance (order-id)
  (let ((vendor-id (slot-value (get-login-vendor) 'row-id))
	(tenant-id (slot-value (get-login-vendor) 'tenant-id)))
    (clsql:select 'dod-vendor-orders :where
	    [and [= [:tenant-id] tenant-id]
		  [= [:vendor-id] vendor-id]
		   [= [:order-id] order-id]] 
			  :caching nil :flatp t)))


(defun get-orders-for-vendor (vendor-instance &optional (fulfilled "N"))
  (let* ((tenant-id (slot-value vendor-instance 'tenant-id))
	 (company (car (vendor-company vendor-instance)))
	 (vendor-id (slot-value vendor-instance 'row-id))
	 (ordidlist     (clsql:select [order-id] :from  'dod-vendor-orders :where
	    [and [= [:tenant-id] tenant-id]
		  [= [:vendor-id] vendor-id]
		   [= [:fulfilled] fulfilled]] 
			  :caching nil :flatp t)))
    (remove nil (mapcar (lambda (ord-id) 
			  (get-order-by-id ord-id company)) ordidlist))))


(defun get-all-orders-for-vendor (vendor-instance)
  (let* ((tenant-id (slot-value vendor-instance 'tenant-id))
	 (company (car (vendor-company vendor-instance)))
	 (vendor-id (slot-value vendor-instance 'row-id))
	 (ordidlist     (clsql:select [order-id] :from  'dod-vendor-orders :where
	    [and [= [:tenant-id] tenant-id]
		  [= [:vendor-id] vendor-id]]
		  
			  :caching nil :flatp t)))
    (remove nil (mapcar (lambda (ord-id) 
			  (get-order-by-id ord-id company)) ordidlist))))



(defun get-vendor-order-by-status (order company-instance fulfilled)
 (let ((tenant-id (slot-value company-instance 'row-id))
       (order-id (slot-value order 'row-id)))
  (car (clsql:select 'dod-vendor-orders  :where
		     [and 
		     [= [:order-fulfilled] fulfilled]
		     [= [:tenant-id] tenant-id]
		     [=[:order-id] order-id]]    :caching *dod-debug-mode* :flatp t ))))


(defun get-order-by-status (id company-instance fulfilled)
 (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-order  :where
		     [and [= [:deleted-state] "N"]
		     [= [:order-fulfilled] fulfilled]
		     [= [:tenant-id] tenant-id]
		     [=[:row-id] id]]    :caching *dod-debug-mode* :flatp t ))))
  

(defun get-order-by-id (id company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-order  :where
		     [and [= [:deleted-state] "N"]
		     [= [:tenant-id] tenant-id]
		     [=[:row-id] id]]    :caching *dod-debug-mode* :flatp t ))))

(defun get-vendor-orders-by-orderid (id company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id))
	(vendor-id (slot-value (get-login-vendor) 'row-id)))
   (car (clsql:select 'dod-vendor-orders  :where
	   [and [= [:tenant-id] tenant-id]
	   [= [:vendor-id] vendor-id]
	   [=[:order-id] id]]    :caching nil :flatp t ))))



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
				  (if (prefpresent-p preference (date-dow request-date)) (create-order-items order prd  prd-qty unit-price company-instance)))) order-pref-list)))))


(defun prefpresent-p (preference day)
    (let  ((lst  (list (if (equal (slot-value preference 'sun) "Y") 0 )
	     (if (equal (slot-value preference 'mon) "Y")  1)
		(if (equal (slot-value preference 'tue) "Y") 2)
	     (if (equal (slot-value preference 'wed) "Y") 3)
		(if (equal (slot-value preference 'thu) "Y") 4)
	     (if (equal (slot-value preference 'fri) "Y") 5) 
		(if (equal (slot-value preference 'sat) "Y") 6))))
	(if (member day lst) t nil)))


(defun create-order-from-shopcart (order-items products  order-date request-date ship-date ship-address order-amt  customer-instance company-instance)
  (let ((uuid (uuid:make-v1-uuid )))
    
    (progn 	(create-order order-date customer-instance request-date ship-date ship-address (print-object uuid nil) order-amt  company-instance)
		(let 
		    ((order (get-order-by-context-id (print-object uuid nil) company-instance))
		  
		     (vendors (get-shopcart-vendorlist order-items company-instance))
		     (tenant-id (slot-value company-instance 'row-id)))

					;Create the order-items 
		  (mapcar (lambda (odt)
			    (let* ((prd (search-prd-in-list (slot-value odt 'prd-id) products))
				   (unit-price (slot-value odt 'unit-price))
				   (prd-qty (slot-value odt 'prd-qty)))
			      (create-order-items order prd   prd-qty unit-price company-instance))) order-items)
		  ; Create one row per vendor in the vendor_orders table. 
		(mapcar (lambda (vendor) 
			    (persist-vendor-orders (slot-value order 'row-id) (slot-value vendor 'row-id) tenant-id))  vendors)

		))))



(defun create-daily-orders-for-company (&key company-id odtstr reqstr)
    :documentation "odtstr and reqstr are of the format \"dd/mm/yyyy\" "
    (let* ((orderdate (get-date-from-string odtstr))
	      (requestdate (get-date-from-string reqstr))
	      (dodcompany (select-company-by-id company-id))
	      (customers (list-cust-profiles dodcompany)))
					;Get a list of all the customers belonging to the current company. 
					; For each customer, get the order preference list and pass to the below function.
	      (mapcar (lambda (customer)
			  (let ((custopflist (get-opreflist-for-customer customer)))
			    (if custopflist  (create-order-from-pref custopflist orderdate requestdate nil (slot-value customer 'address) nil   customer dodcompany)) )) customers)))



(defun run-daily-orders-batch ()
  :documentation "datestr is of the format \"dd/mm/yyyy\" "
  (let ((cmplist (list-dod-companies)))
    (mapcar (lambda (cmp) 
	      (let ((id (slot-value cmp 'row-id)))
		(create-daily-orders-for-company :company-id id :odtstr (get-date-string (get-date)) :reqstr (get-date-string (date+ (get-date) (make-duration :day 1)))))) cmplist))) 
