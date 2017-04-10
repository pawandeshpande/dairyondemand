(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun select-vendors-for-company (company)
  (let ((tenant-id (slot-value company 'row-id)))
(clsql:select 'dod-vend-profile  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching nil :flatp t )))


(defun select-vendor-by-id (id company)
  (let ((tenant-id (slot-value company 'row-id)))
 (car (clsql:select 'dod-vend-profile  :where
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=[:row-id] id]]    :caching nil :flatp t ))))


(defun select-vendor-by-name (name-like-clause company)
  (let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-vend-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[like  [:name] name-like-clause]]
		:caching nil :flatp t))))





(defun update-vendor-details (vendor-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance vendor-instance))



(defun delete-vendor( id company )
  (let ((tenant-id (slot-value company 'row-id)))
  (let ((dodvendor (car (clsql:select 'dod-vend-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodvendor 'deleted-state) "Y")
    (clsql:update-record-from-slot dodvendor 'deleted-state))))



(defun delete-vendors ( list company)
  (let ((tenant-id (slot-value company 'row-id)))
  (mapcar (lambda (id)  (let ((dodvendor (car (clsql:select 'dod-vend-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodvendor 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodvendor  'deleted-state))) list )))


(defun restore-deleted-vendors ( list company )
  (let ((tenant-id (slot-value company 'row-id)))
(mapcar (lambda (id)  (let ((dodvendor (car (clsql:select 'dod-vend-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
    (setf (slot-value dodvendor 'deleted-state) "N")
    (clsql:update-record-from-slot dodvendor 'deleted-state))) list )))

  

  
(defun create-vendor(name address phone company )
  (let ((tenant-id (slot-value company 'row-id)))
 (clsql:update-records-from-instance (make-instance 'dod-vend-profile
				    :name name
				    :address address
				    :phone phone
				    :tenant-id tenant-id
				    :deleted-state "N"))))
 

