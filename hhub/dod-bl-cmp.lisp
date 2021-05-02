;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)


(defun new-dod-company(cname caddress city state country zipcode website cmp-type subscription-plan createdby updatedby)
  (let  ((company-name cname)(company-address caddress))
	(clsql:update-records-from-instance (make-instance 'dod-company
							   :name company-name
							   :address company-address
							   :city city
							   :state state 
							   :country country
							   :zipcode zipcode
							   :website website 
							   :deleted-state "N"
							   :suspend-flag "N"
							   :tshirt-size "SM"
							   :revenue 0
							   :cmp-type cmp-type
							   :subscription-plan subscription-plan
							   :created-by createdby
							   :updated-by updatedby))))



(defun suspendaccount (tenant-id)
  (let ((company (select-company-by-id tenant-id)))
    (unless (com-hhub-attribute-company-issuspended company)
      (setf (slot-value company 'suspend-flag) "Y"))
    (update-company company)
    (setf *HHUBGLOBALLYCACHEDLISTSFUNCTIONS* (hhub-gen-globally-cached-lists-functions))))

(defun restoreaccount (tenant-id)
  (let ((company (select-company-by-id tenant-id)))
    (when (com-hhub-attribute-company-issuspended company)
      (setf (slot-value company 'suspend-flag) "N"))
    (update-company company)
    (setf *HHUBGLOBALLYCACHEDLISTSFUNCTIONS* (hhub-gen-globally-cached-lists-functions))))



;(defun get-count-company-customers (company) 
;  (let ((old-func (symbol-function 'count-company-customers))
;	(previous (make-hash-table)))
;    (defun count-company-customers (company)
;      (or (gethash company previous)
;	  (setf (gethash company previous) (funcall old-func company))))))

(defun count-company-customers (company) 
 (let ((tenant-id (slot-value company 'row-id))) 
    (first (clsql:select [count [*]] :from 'dod-cust-profile  :where 
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]]   :caching nil :flatp t ))))


(defun count-company-vendors (company) 
 (let ((tenant-id (slot-value company 'row-id))) 
    (first (clsql:select [count [*]] :from 'dod-vend-profile  :where 
		[and [= [:deleted-state] "N"]
		[= [:tenant-id] tenant-id]]   :caching nil :flatp t ))))



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



(defun get-system-companies ()
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



(defun update-company (instance); This function has side effect of modifying the database record.
  (clsql:update-records-from-instance instance))
