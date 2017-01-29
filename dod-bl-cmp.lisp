(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun new-dod-company(cname caddress city state country zipcode createdby updatedby)
  (let  ((company-name cname)(company-address caddress))
	(clsql:update-records-from-instance (make-instance 'dod-company
							   :name company-name
							   :address company-address
							   :city city
							   :state state 
							   :country country
							   :zipcode zipcode
							   :deleted-state "N"
							   :created-by createdby
							   :updated-by updatedby))))



(defun select-company-by-name (name-like-clause)
(car (clsql:select 'dod-company :where [and
		[= [:deleted-state] "N"]
		[like  [:name] name-like-clause]]
		:caching nil :flatp t)))


(defun select-company-by-id (id)
(car (clsql:select 'dod-company :where [and
		[= [:deleted-state] "N"]
		[= [:row-id] id]]
		:caching nil :flatp t)))


(defun list-dod-companies ()
  (clsql:select 'dod-company  :where [= [:deleted-state] "N"]   :caching nil :flatp t ))

(defun delete-dod-company ( id )
  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching nil))))
    (setf (slot-value company 'deleted-state) "Y")
    (clsql:update-record-from-slot company 'deleted-state)))
    

(defun delete-dod-companies ( list )
  (mapcar (lambda (id)  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching nil))))
			  (setf (slot-value company 'deleted-state) "Y")
			  (clsql:update-record-from-slot company 'deleted-state))) list ))


(defun restore-deleted-dod-companies ( list )
(mapcar (lambda (id)  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching nil))))
    (setf (slot-value company 'deleted-state) "N")
    (clsql:update-record-from-slot company 'deleted-state))) list ))



