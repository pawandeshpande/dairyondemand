(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


; This is a Resource attribute function for order.
(defun com-hhub-attribute-order ()
  "Order")

; This is an Action attribute function for create order.
(defun com-hhub-attribute-create-order ()
"create.order")

(defun com-hhub-attribute-maxordertime ()
  "23:59:00")


(defun test-func123 ())
