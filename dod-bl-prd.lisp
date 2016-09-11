(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun get-products (tenant-id)
  (clsql:select 'dod-prd-master  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching nil :flatp t ))

(defun select-products-by-company (company-instance)
  (let ((tenant-id (slot-value company-instance 'row-id)))
 (clsql:select 'dod-prd-master  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]]
     :caching nil :flatp t )))

(defun select-products-by-vendor (vendor company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id))
	     (vendor-id (slot-value vendor 'row-id)))
 (clsql:select 'dod-prd-master  :where
		[and [= [:deleted-state] "N"]
     [= [:tenant-id] tenant-id]
     [=[:vendor-id] vendor-id]]
     :caching nil :flatp t )))



(defun search-prd-in-list (row-id list)
    (if (not (equal row-id (slot-value (car list) 'row-id))) (search-prd-in-list row-id (cdr list))
    (car list)))

(defun prdinlist-p  (prd-id list)
(member prd-id  (mapcar (lambda (item)
		(slot-value item 'prd-id)) list)))


(defun select-product-by-id (id company-instance ) 
  (let ((tenant-id (slot-value company-instance 'row-id)))
 (car (clsql:select 'dod-prd-master  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:row-id] id]]    :caching nil :flatp t ))))


  (defun select-product-by-name (name-like-clause company-instance )
      (let ((tenant-id (slot-value company-instance 'row-id)))
  (car (clsql:select 'dod-prd-master :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[like  [:prd-name] name-like-clause]]
		:caching nil :flatp t))))


(defun update-prd-details (prd-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance prd-instance))

(defun delete-product( id company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (let ((dodproduct (car (clsql:select 'dod-prd-master :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodproduct 'deleted-state) "Y")
    (clsql:update-record-from-slot dodproduct 'deleted-state))))



(defun delete-products ( list company-instance)
    (let ((tenant-id (slot-value company-instance 'row-id)))
  (mapcar (lambda (id)  (let ((dodproduct (car (clsql:select 'dod-vend-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodproduct 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodproduct  'deleted-state))) list )))


(defun restore-deleted-products ( list company-instance )
    (let ((tenant-id (slot-value company-instance 'row-id)))
(mapcar (lambda (id)  (let ((dodproduct (car (clsql:select 'dod-vend-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodproduct 'deleted-state) "N")
    (clsql:update-record-from-slot dodproduct 'deleted-state))) list )))

   

  
(defun persist-product(prdname vendor-id qtyperunit unitprice img-file-path subscribe-flag tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-prd-master
				    :prd-name prdname
				    :vendor-id vendor-id
				    :qty-per-unit qtyperunit
				    :unit-price unitprice
					 :prd-image-path img-file-path
					 :subscribe-flag subscribe-flag
				    :tenant-id tenant-id
				    :deleted-state "N")))
 


(defun create-product (prdname vendor-instance qty-per-unit unit-price img-file-path subscribe-flag company-instance)
  (let ((vendor-id (slot-value vendor-instance 'row-id))
	(tenant-id (slot-value company-instance 'row-id)))
 (persist-product prdname vendor-id qty-per-unit unit-price img-file-path subscribe-flag  tenant-id)))


