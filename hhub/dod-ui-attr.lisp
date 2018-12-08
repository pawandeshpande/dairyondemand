(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


; This is a Resource attribute function for order.
(defun com-hhub-attribute-order ()
  "Order")

; This is an Action attribute function for create order.
(defun com-hhub-attribute-create-order ()
"com.hhub.transaction.create.order")

; This is an Action attribute functin for customer order edit. 
(defun com-hhub-attribute-cust-edit-order ()
"com.hhub.transaction.cust.edit.order")

(defun com-hhub-attribute-maxordertime ()
  "23:59:00")

(defun com-hhub-attribute-cust-order-payment-mode (order-id)
 (let ((order (get-order-by-id order-id (get-login-cust-company))))
   (slot-value order 'payment-mode)))



(defun com-hhub-attribute-role-name ()
:documentation "Role name is described. The attribute function will get the role name of the currently logged in user"
(let* ((userid (get-login-userid))
      (userrole (select-user-role-by-userid userid (get-login-tenant-id))))
      (slot-value (get-user-roles.role userrole) 'name)))
