;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)
(clsql:file-enable-sql-reader-syntax)

(defun com-hhub-attribute-customer-type ()
(get-login-customer-type))

(defun com-hhub-attribute-order ()
  "Order")

(defun com-hhub-attribute-create-order ()
"com.hhub.transaction.create.order")

; This is an Action attribute functin for customer order edit. 
(defun com-hhub-attribute-cust-edit-order-item ()
"com.hhub.transaction.cust.edit.order.item")

(defun com-hhub-attribute-customer-order-cutoff-time ()
  *HHUB-CUSTOMER-ORDER-CUTOFF-TIME*)

(defun com-hhub-attribute-cust-order-payment-mode (order-id)
 (let ((order (get-order-by-id order-id (get-login-cust-company))))
   (slot-value order 'payment-mode)))



(defun com-hhub-attribute-role-instance ()
  (let* ((user-id (get-login-userid))
	 (tenant-id (get-login-tenant-id))
	 (userrole-instance (select-user-role-by-userid user-id tenant-id))
	 (role-id (slot-value userrole-instance 'role-id)))
    (select-role-by-id role-id)))
    

(defun com-hhub-attribute-role-name ()
:documentation "Role name is described. The attribute function will get the role name of the currently logged in user"
(let ((role (com-hhub-attribute-role-instance)))
       (slot-value role 'name)))


(defun com-hhub-attribute-vendor-bulk-product-count ()
  100)

(defun com-hhub-attribute-vendor-issuspended (vendor)
  (equal (slot-value vendor 'suspend-flag) "Y"))


(defun com-hhub-attribute-company-issuspended (company)
  (equal (slot-value company 'suspend-flag) "Y"))

(defun com-hhub-attribute-company-maxvendorcount (company)
  (let ((company-type (slot-value company 'cmp-type)))
    (cond ((equal company-type "BASIC") 5)
	  ((equal company-type "PROFESSIONAL") 10)
	  ((equal company-type "HHUBTEST") 1))))

(defun com-hhub-attribute-company-maxproductcount (company)
    (let ((company-type (slot-value company 'cmp-type)))
    (cond ((equal company-type "BASIC") 1000)
	  ((equal company-type "PROFESSIONAL") 3000)
	  ((equal company-type "HHUBTEST") 100))))


(defun com-hhub-attribute-company-prdbulkupload-enabled (company)
    (let ((company-type (slot-value company 'cmp-type)))
    (cond ((equal company-type "BASIC") T)
	  ((equal company-type "PROFESSIONAL") T)
	  ((equal company-type "HHUBTEST") NIL))))

