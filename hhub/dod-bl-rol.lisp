(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)



(defun select-user-role-by-userid (user-id tenant-id)
  (get-user-roles.role (car (clsql:select 'dod-user-roles :where [and 
		[= [:tenant-id] tenant-id]
		[= [:user-id] user-id]]
	        :caching nil :flatp t ))))



