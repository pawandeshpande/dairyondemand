(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-orders ()
(if (is-dod-session-valid?)
   (let (( dodorders (get-orders-by-company  (get-login-company)))
	 (header (list  "Order No" "Order Date" "Customer" "Request Date"  "Ship Date" "Ship Address" "Action")))
     (if dodorders (ui-list-orders header dodorders) "No orders"))
     (hunchentoot:redirect "/login")))


(defun ui-list-orders (header data)
  (cl-who:with-html-output (*standard-output* nil)
      (:a :class "btn btn-primary" :role "button" :href (format nil "/dodcustindex") "Shop Now")
    (:h3 "Orders")
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (order)
									    (let ((ord-customer  (get-ord-customer order)))
									      (htm (:tr (:td  :height "12px" (str (slot-value order 'row-id)))
											(:td  :height "12px" (str (slot-value order 'ord-date)))
											(:td  :height "12px" (str (slot-value ord-customer 'name)))
										       (:td  :height "12px" (str (slot-value order 'req-date)))
										       (:td  :height "12px" (str (slot-value order 'shipped-date)))
										       (:td  :height "12px" (str (slot-value order 'ship-address)))
										       (:td :height "12px" (:a :href  (format nil  "/delorder?id=~A" (slot-value order 'row-id)) "Delete")
											    (:a :href  (format nil  "/editorder?id=~A" (slot-value order 'row-id)) :onclick "return false"  "Edit")
											    (:a :href  (format nil  "/orderdetails?id=~A" (slot-value order 'row-id))  "Details")
											    ))))) (if (not (typep data 'list)) (list data) data))))))





(defun ui-list-customer-orders (header data)
  (cl-who:with-html-output (*standard-output* nil)
          (:a :class "btn btn-primary" :role "button" :href (format nil "/dodcustindex") "Shop Now")
    (:h3 "Orders") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (order)
									    (let ((ord-customer  (get-ord-customer order)))
									      (htm (:tr (:td  :height "12px" (str (slot-value order 'row-id)))
											(:td  :height "12px" (str (slot-value order 'ord-date)))
											(:td :height "12px" (:a :href  (format nil  "/dodmyorderdetails?id=~A" (slot-value order 'row-id))(str (concat-ord-dtl-name order))))
											;(:td  :height "12px" (str (slot-value ord-customer 'name)))
										       (:td  :height "12px" (str (slot-value order 'req-date)))
										       (:td  :height "12px" (str (slot-value order 'shipped-date)))
										       (:td  :height "12px" (str (slot-value order 'ship-address)))
										       (:td :height "12px" (:a :href  (format nil  "/delorder?id=~A" (slot-value order 'row-id)) "Delete")
											    (:a :href  (format nil  "/editorder?id=~A" (slot-value order 'row-id)) :onclick "return false"  "Edit")
											    (:a :href  (format nil  "/dodmyorderdetails?id=~A" (slot-value order 'row-id))  "Details")
											    ))))) (if (not (typep data 'list)) (list data) data) )))))


(defun concat-ord-dtl-name (order-instance)
  (let ((odt ( get-order-details order-instance)))
    (mapcar (lambda (odt-ins)
	      (concatenate 'string (slot-value (get-odt-product odt-ins) 'prd-name) ",")) odt)))
