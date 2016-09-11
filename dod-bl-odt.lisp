(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun get-order-details (order-instance)
  (let ((tenant-id (slot-value order-instance 'tenant-id))
	(order-id (slot-value order-instance 'row-id)))
 (clsql:select 'dod-order-details  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:order-id] order-id]]    :caching nil :flatp t )))

(defun get-order-details-for-vendor (order-instance vendor-instance)
    (let* ((tenant-id (slot-value order-instance 'tenant-id))
	     (vendor-id (slot-value vendor-instance 'row-id))
	     (order-id (slot-value order-instance 'row-id))
	(odtlist (clsql:select 'dod-order-details  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		     [=[:order-id] order-id]]    :caching nil :flatp t )))
	(delete nil (mapcar (lambda (odt)
		    (let ((product  (get-odt-product odt)))
			(if (equal vendor-id (slot-value product 'vendor-id)) odt))) odtlist))))



(defun get-order-details-by-prd (prd-id order-instance)
 (let ((tenant-id (slot-value order-instance 'tenant-id))
	(order-id (slot-value order-instance 'row-id)))
 (car (clsql:select 'dod-order-details  :where
		[and [= [:deleted-state] "N"]
     [= [:tenant-id] tenant-id]
     [= [:prd-id] prd-id]
		[=[:order-id] order-id]]    :caching nil :flatp t ))))
    



(defun update-order-detail (odt-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance odt-instance))


(defun delete-order-details ( list company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (mapcar (lambda (id)  (let ((dodorder (car (clsql:select 'dod-order-details :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodorder 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodorder  'deleted-state))) list )))


(defun restore-deleted-order-details ( list company-instance )
    (let ((tenant-id (slot-value company-instance 'row-id)))
(mapcar (lambda (id)  (let ((dodorder (car (clsql:select 'dod-order-details :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodorder 'deleted-state) "N")
    (clsql:update-record-from-slot dodorder 'deleted-state))) list )))

  

  
(defun persist-order-details(order-id product-id unit-price product-qty  tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-order-details
						    :order-id order-id
						    :prd-id product-id
						    :unit-price unit-price
						    :prd-qty product-qty
						    :tenant-id tenant-id
						    :deleted-state "N")))
 ;This is a clean function with no side effect.
(defun create-order-details (order product product-qty unit-price company-instance)
  (let ((order-id (slot-value order 'row-id))
	(product-id (slot-value product 'row-id))
	(tenant-id (slot-value company-instance 'row-id)))
    (persist-order-details order-id product-id unit-price product-qty tenant-id)))


 ;This is a clean function with no side effect.
(defun create-odtinst-shopcart (order product product-qty unit-price company-instance)
  (let ((product-id (slot-value product 'row-id))
	   (tenant-id (slot-value company-instance 'row-id))
	   (order-id (if order (slot-value order 'row-id) nil)))
    (make-instance 'dod-order-details
						    :order-id order-id
						    :prd-id product-id
						    :unit-price unit-price
						    :prd-qty product-qty
						    :tenant-id tenant-id
						    :deleted-state "N")))

(defun search-odt-by-prd-id (prd-id list)
    (if (not (equal prd-id (slot-value (car list) 'prd-id))) (search-odt-by-prd-id prd-id (cdr list))
    (car list)))
