(in-package :dairyondemand)
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


