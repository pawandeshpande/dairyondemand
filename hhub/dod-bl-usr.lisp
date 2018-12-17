(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun list-dod-users ()
  (clsql:select 'dod-users  :where [and [= [:deleted-state] "N"] 
		[= [:tenant-id] (get-login-tenant-id)]
		[<> [:name] "superadmin"]]    :caching nil :flatp t ))

(defun get-users-for-company (tenant-id)
  (clsql:select 'dod-users  :where [and [= [:deleted-state] "N"] 
		[= [:tenant-id] tenant-id]
		[<> [:name] "superadmin"]]    :caching nil :flatp t ))


(defun select-user-by-id (user-id tenant-id)
  (car (clsql:select 'dod-users  :where [and [= [:deleted-state] "N"] 
		[= [:tenant-id] tenant-id]
		[= [:row-id] user-id]
		[<> [:name] "superadmin"]]    :caching nil :flatp t )))

(defun select-user-by-phonenumber (phone tenant-id)
  (car (clsql:select 'dod-users  :where [and [= [:deleted-state] "N"] 
		[= [:tenant-id] tenant-id]
		[= [:phone] phone]
		[<> [:name] "superadmin"]]    :caching nil :flatp t )))



(defun delete-dod-user ( id )
  (let ((doduser (car (clsql:select 'dod-users :where [= [:row-id] id] :flatp t :caching nil))))
    (setf (slot-value doduser 'deleted-state) "Y")
    (clsql:update-record-from-slot doduser 'deleted-state)))



(defun update-user (user-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance user-instance))

(defun delete-dod-users ( list )
  (mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-users :where [= [:row-id] id] :flatp t :caching nil))))
			  (setf (slot-value doduser 'deleted-state) "Y")
			  (clsql:update-record-from-slot doduser  'deleted-state))) list ))


(defun restore-deleted-dod-users ( list )
(mapcar (lambda (id)  (let ((doduser (car (clsql:select 'dod-users :where [= [:row-id] id] :flatp t :caching nil))))
    (setf (slot-value doduser 'deleted-state) "N")
    (clsql:update-record-from-slot doduser 'deleted-state))) list ))


(defun verify-superadmin ();;"Verifies whether username is superadmin" 
  (if (equal (get-current-login-username) "superadmin") T NIL ))

(defun superadmin-login ()
(if (verify-superadmin )
  (setf ( hunchentoot:session-value :login-company) "super")))

  
(defun create-dod-user(name uname passwd salt email-address tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-users
				    :name name
				    :username uname
				    :salt salt
				    :password passwd
				    :email email-address
				    :tenant-id tenant-id
				    :deleted-state "N"
				    :created-by tenant-id
				    :updated-by tenant-id)))
 


