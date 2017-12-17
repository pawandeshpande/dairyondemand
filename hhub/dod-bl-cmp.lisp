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



(defun equal-companiesp (cmp1 cmp2)
  (equal (slot-value cmp1 'row-id) (slot-value cmp2 'row-id)))


(defun select-company-by-name (name-like-clause)
(car (clsql:select 'dod-company :where [and
		[= [:deleted-state] "N"]
		[like  [:name] name-like-clause]]
		:caching *dod-database-caching* :flatp t)))


(defun select-companies-by-name (name-like-clause)
 (clsql:select 'dod-company :where [and
		[= [:deleted-state] "N"]
		[like  [:name] (format NIL "%~a%"  name-like-clause)]]
		:caching *dod-database-caching* :flatp t))



(defun select-company-by-id (id)
(car (clsql:select 'dod-company :where [and
		[= [:deleted-state] "N"]
		[= [:row-id] id]]
		:caching *dod-database-caching* :flatp t)))


(defun list-dod-companies ()
  (clsql:select 'dod-company  :where [and [= [:deleted-state] "N"]
		[<> [:name] "super"] ; Avoid super company in any list. 
		]   :caching *dod-database-caching* :flatp t ))

(defun delete-dod-company ( id )
  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value company 'deleted-state) "Y")
    (clsql:update-record-from-slot company 'deleted-state)))
    

(defun delete-dod-companies ( list )
  (mapcar (lambda (id)  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching *dod-database-caching*))))
			  (setf (slot-value company 'deleted-state) "Y")
			  (clsql:update-record-from-slot company 'deleted-state))) list ))


(defun restore-deleted-dod-companies ( list )
(mapcar (lambda (id)  (let ((company (car (clsql:select 'dod-company :where [= [:row-id] id] :flatp t :caching *dod-database-caching*))))
    (setf (slot-value company 'deleted-state) "N")
    (clsql:update-record-from-slot company 'deleted-state))) list ))



