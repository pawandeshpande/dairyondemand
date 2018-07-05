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


(defun test-func123 ())
