(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun select-all-roles ()
(clsql:select 'dod-roles :where 
	      [and 
	      [= [:deleted-state] "N"]
	      [<> [:name] "SUPERADMIN"]]
	      :caching nil :flatp t ))

(defun select-role-by-name (name )
  (car (clsql:select 'dod-roles :where 
		     [= [:name] name]
		     :caching nil :flatp t)))


(defun select-user-role-by-userid (user-id tenant-id)
  (car (clsql:select 'dod-user-roles :where [and 
		[= [:tenant-id] tenant-id]
		[= [:user-id] user-id]]
	        :caching nil :flatp t )))



(defun update-user-role (userrole-instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance userrole-instance))
