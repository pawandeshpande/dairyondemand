(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun list-dod-users ()
  (clsql:select 'dod-users  :where [and [= [:deleted-state] "N"] [= [:tenant-id] (get-login-tenant-id)]]    :caching nil :flatp t ))


(defun delete-dod-user ( id )
  (let ((doduser (car (clsql:select 'dod-users :where [= [:row-id] id] :flatp t :caching nil))))
    (setf (slot-value doduser 'deleted-state) "Y")
    (clsql:update-record-from-slot doduser 'deleted-state)))



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

(defun superadmin-login (company-id)
(if (verify-superadmin )
  (setf ( hunchentoot:session-value :login-company)   (get-tenant-name company-id))))

	    

  
(defun create-dod-user(name uname passwd email-address tenant-id )
 (clsql:update-records-from-instance (make-instance 'dod-users
				    :name name
				    :username uname
				    :password passwd
				    :email email-address
				    :tenant-id tenant-id
				    :deleted-state "N"
				    :created-by tenant-id
				    :updated-by tenant-id)))
 
