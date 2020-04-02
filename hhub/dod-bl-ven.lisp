(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun select-vendors-for-company (company)
  (let ((tenant-id (slot-value company 'row-id)))
(clsql:select 'dod-vend-profile  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]    :caching nil :flatp t )))


(defun select-vendor-by-id (id)
  (car (clsql:select 'dod-vend-profile  :where
		[and [= [:deleted-state] "N"]
		[=[:row-id] id]]    :caching nil :flatp t )))

(defun select-vendor-by-phone (phone company)
  (let ((tenant-id (slot-value company 'row-id)))
    (car (clsql:select 'dod-vend-profile  :where
		       [and [= [:deleted-state] "N"]
		       [= [:phone] phone]
		       [= [:tenant-id] tenant-id]
		       [= [:active-flag] "Y"]]
		       :caching nil :flatp t ))))


(defun select-vendor-by-email (email)
  (car (clsql:select 'dod-vend-profile  :where
		[and [= [:deleted-state] "N"]
		;[= [:active-flag] "Y"]
		[=[:email] email]]    :caching nil :flatp t )))


(defun select-vendor-by-name (name-like-clause company)
  (let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-vend-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[like  [:name] name-like-clause]]
		:caching nil :flatp t))))


(defun reset-vendor-password (vendor)
  (let* ((confirmpassword (hhub-random-password 8))
	(salt-octet (secure-random:bytes 56 secure-random:*generator*))
	(salt (flexi-streams:octets-to-string  salt-octet))
	(encryptedpass (check&encrypt confirmpassword confirmpassword salt)))
	  
    (setf (slot-value vendor 'password) encryptedpass)
    (setf (slot-value vendor 'salt) salt) 
    ; Whenever we reset the vendor password, we activate the vendor, as he is in-activated when this process started. 
    (setf (slot-value vendor 'active-flag) "Y") 
    (update-vendor-details  vendor )
    confirmpassword)) ; return the newly generated password. 





(defun update-vendor-payment-params (payment-api-key payment-api-salt vendor)
  (setf (slot-value vendor 'payment-api-key) payment-api-key)
  (setf (slot-value vendor 'payment-api-salt) payment-api-salt)
  (update-vendor-details vendor))
 

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

  
  
(defun create-vendor(name address phone email password salt city state zipcode company )
  (let ((tenant-id (slot-value company 'row-id)))
 (clsql:update-records-from-instance (make-instance 'dod-vend-profile
				    :name name
				    :address address
				    :email email 
				    :password password 
				    :salt salt
				    :phone phone
				    :city city 
				    :state state 
				    :zipcode zipcode
				    :tenant-id tenant-id
				    :push-notify-subs-flag "N"
				    :deleted-state "N"))))
 

 

; DOD_VENDOR_TENANTS related functions
(defun create-vendor-tenant (vendor default-flag company)
  (let ((tenant-id (slot-value company 'row-id))
	(vendor-id (slot-value vendor 'row-id)))
    (clsql:update-records-from-instance (make-instance 'dod-vendor-tenants
						       :vendor-id vendor-id
						       :tenant-id tenant-id
						       :default-flag default-flag
						       :deleted-state "N"))))

(defun delete-vendor-tenant (vendor-tenantlist company)
   (let ((tenant-id (slot-value company 'row-id)))
  (mapcar (lambda (id)  (let ((dodvendortenant (car (clsql:select 'dod-vendor-tenants :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching nil))))
			  (setf (slot-value dodvendortenant 'deleted-state) "Y")
			  (clsql:update-record-from-slot dodvendortenant  'deleted-state))) vendor-tenantlist )))




(defun get-vendor-tenants (vendor)
  (let ((vendor-id (slot-value vendor 'row-id)))
 (clsql:select 'dod-vendor-tenants  :where
		[and [= [:deleted-state] "N"]
		[= [:vendor-id] vendor-id]]
	           :caching nil :flatp t )))



(defun get-vendor-tenants-as-companies (vendor) 
  (let ((vendor-tenants-list (get-vendor-tenants vendor)))
    (mapcar (lambda (vt) 
	      (let ((tenant-id (slot-value vt 'tenant-id)))
		(select-company-by-id tenant-id))) vendor-tenants-list)))

    
