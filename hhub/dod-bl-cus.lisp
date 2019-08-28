(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun list-cust-profiles (company)
 (with-database (dbinst *dod-dbconn-spec* :if-exists :old :pool t :database-type :mysql )
  (let ((tenant-id (slot-value company 'row-id)))
  (clsql:select 'dod-cust-profile  :where [and [= [:deleted-state] "N"] [= [:tenant-id] tenant-id]]  :database dbinst   :caching *dod-database-caching*  :flatp t ))))



(defun select-customer-by-name (name-like-clause company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:active-flag] "Y"]
		[like  [:name] name-like-clause]]
		:caching *dod-database-caching* :flatp t))))

(defun select-customer-by-phone (phone company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:cust_type] "STANDARD"]
		[= [:active-flag] "Y"]
		[like  [:phone] phone]]
		:caching *dod-database-caching* :flatp t))))


(defun select-guest-customer (company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:active-flag] "Y"]
		[= [:phone] *HHUBGUESTCUSTOMERPHONE*]
		[= [:cust-type] "GUEST"]]
		:caching *dod-database-caching* :flatp t))))




(defun update-customer (customer-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance customer-instance))

(defun duplicate-customerp(phone company)
  (if (select-customer-by-phone phone company) T NIL))
    

(defun select-customer-by-id (id company)
(let ((tenant-id (slot-value company 'row-id)))
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:active-flag] "Y"]
		[=  [:row-id] id]]
		:caching *dod-database-caching* :flatp t))))



(defun select-customer-by-email (email)
  (car (clsql:select 'dod-cust-profile :where [and
		[= [:deleted-state] "N"]
		;[= [:active-flag] "Y"]
		[=  [:email] email]]
		:caching *dod-database-caching* :flatp t)))




(defun reset-customer-password (customer)
  (let* ((confirmpassword (hhub-random-password 8))
	(salt-octet (secure-random:bytes 56 secure-random:*generator*))
	(salt (flexi-streams:octets-to-string  salt-octet))
	(encryptedpass (check&encrypt confirmpassword confirmpassword salt)))
	  
    (setf (slot-value customer 'password) encryptedpass)
    (setf (slot-value customer 'salt) salt) 
    ; Whenever we reset the customer password, we activate the customer, as he is in-activated when this process started. 
    (setf (slot-value customer 'active-flag) "Y") 
    (update-customer  customer )
    confirmpassword)) ; return the newly generated password. 

       

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

(defun delete-cust-profiles ( list company)
(let ((tenant-id (slot-value company 'row-id)))  
  (mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-cust-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
			  (setf (slot-value doduser 'deleted-state) "Y")
			  (clsql:update-record-from-slot doduser  'deleted-state))) list )))


(defun restore-deleted-cust-profile ( list tenant-id )
(mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-cust-profile :where [and [= [:row-id] id] [= [:tenant-id] tenant-id]] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value doduser 'deleted-state) "N")
    (clsql:update-record-from-slot doduser 'deleted-state))) list ))




(defun create-customer(name address phone  email birthdate password salt city state zipcode company  )
  (let ((tenant-id (slot-value company 'row-id)))
 (clsql:update-records-from-instance (make-instance 'dod-cust-profile
						    :name name
						    :address address
						    :email email 
						    :password password 
						    :salt salt
						    :birthdate birthdate 
						    :phone phone
						    :city city 
						    :state state 
						    :zipcode zipcode
						    :tenant-id tenant-id
						    :cust-type "STANDARD"
						    :active-flag "N"
						    :deleted-state "N"))))
 

(defun create-guest-customer(company)
  (let ((tenant-id (slot-value company 'row-id))
	(customer-name (format nil "Guest Customer - ~A" (slot-value company 'name))))
 (clsql:update-records-from-instance (make-instance 'dod-cust-profile
						    :name customer-name
						    :address (slot-value company 'address)
						    :email nil 
						    :password "demo"
						    :salt nil
						    :birthdate nil
						    :phone "9999999999"
						    :city (slot-value company 'city)
						    :state (slot-value company 'state)
						    :zipcode (slot-value company 'zipcode)
						    :tenant-id tenant-id
						    :cust-type "GUEST"
						    :active-flag "Y"
						    :deleted-state "N"))))



;;;;; Customer wallet related functions ;;;;;


(defun create-wallet(customer vendor company  )
  (let ((tenant-id (slot-value company 'row-id))
	(cust-id (slot-value customer 'row-id))
	(vendor-id (slot-value vendor 'row-id)))
    (persist-wallet cust-id vendor-id tenant-id)))

(defun persist-wallet (cust-id vendor-id tenant-id)
 (clsql:update-records-from-instance (make-instance 'dod-cust-wallet
						    :cust-id cust-id
						    :vendor-id vendor-id 
						    :tenant-id tenant-id
				    		    :deleted-state "N")))

(defun check-wallet-balance (amount customer-wallet)
(let ((cur-balance (slot-value customer-wallet  'balance)))
  (if (> cur-balance amount) T nil)))

(defun check-low-wallet-balance (customer-wallet) 
(if (< (slot-value customer-wallet 'balance) 50.00) T nil))

(defun check-zero-wallet-balance (customer-wallet)
(if (< (slot-value customer-wallet 'balance) 0.00) T nil)) 


(defun deduct-wallet-balance (amount customer-wallet)
(let ((cur-balance (slot-value customer-wallet 'balance)))
(progn  (setf (slot-value customer-wallet 'balance) (- cur-balance amount))
  (clsql:update-record-from-slot customer-wallet 'balance))))

(defun set-wallet-balance (amount customer-wallet)
 (progn  (setf (slot-value customer-wallet 'balance) amount)
	 (clsql:update-record-from-slot customer-wallet 'balance)))

(defun get-cust-wallets-for-vendor (vendor company)
  (let ((tenant-id (slot-value company 'row-id))
	(vendor-id (slot-value vendor 'row-id)))
  (clsql:select 'dod-cust-wallet :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[=  [:vendor-id] vendor-id]]
		:caching *dod-database-caching* :flatp t)))


(defun get-cust-wallet-by-vendor (customer vendor company) 
  (let ((tenant-id (slot-value company 'row-id))
	(cust-id (slot-value customer 'row-id))
	(vendor-id (slot-value vendor 'row-id)))
  (car (clsql:select 'dod-cust-wallet :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:cust-id] cust-id]
		[=  [:vendor-id] vendor-id]]
		:caching *dod-database-caching* :flatp t))))

(defun get-cust-wallets (customer company) 
  (let ((tenant-id (slot-value company 'row-id))
	(cust-id (slot-value customer 'row-id)))
   (clsql:select 'dod-cust-wallet :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:cust-id] cust-id]]
		:caching *dod-database-caching* :flatp t)))





(defun get-cust-wallet-by-id (id company) 
  (let ((tenant-id (slot-value company 'row-id)))
	
   (car (clsql:select 'dod-cust-wallet :where [and
		[= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]
		[= [:row-id] id]]
	
		:caching *dod-database-caching* :flatp t))))



