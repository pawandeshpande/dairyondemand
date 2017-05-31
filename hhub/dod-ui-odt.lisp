(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-order-details ()
    (if (is-dod-session-valid?)
	(let* (( dodorder (get-order-by-id (hunchentoot:parameter "id") (get-login-company)))
		  (header (list  "Order No" "Product" "Product Qty" "Unit Price"  "Total"  "Action"))
		  (odt (get-order-details dodorder) ))
	    (if odt (ui-list-order-details header odt) "No order details"))
	(hunchentoot:redirect "/login")))


(defun ui-list-order-details (header data)
    (cl-who:with-html-output (*standard-output* nil)
	(:h3 "Order Details") 
	(:table :class "table table-striped"  (:thead (:tr
				 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
				       (mapcar (lambda (odt)
				   (let ((odt-product  (get-odt-product odt)))
				     (htm (:tr (:td  :height "12px" (str (slot-value odt 'order-id)))
				       (:td  :height "12px" (str (slot-value odt-product 'prd-name)))
				       (:td  :height "12px" (str (slot-value odt 'prd-qty)))
				       (:td  :height "12px" (str (slot-value odt 'unit-price)))
				       (:td :height "12px" (:a :href  (format nil  "/hhub/delorderdetail?id=~A" (slot-value odt 'row-id)) :onclick "return false"  "Delete")
					    (:a :href  (format nil  "/hhub/editorderdetail?id=~A" (slot-value odt 'row-id)) :onclick "return false"  "Edit")
					    ))))) (if (not (typep data 'list)) (list data) data) )))))


(defun ui-list-shop-cart (data shopcart)
    :documentation "A function used for rendering the shopping cart data in HTML format."
    (time (cl-who:with-html-output (*standard-output* nil)
					; Header section.
	      (:div :class "row"
		  (:div :class "col-sm-6" 
		      (:h4 (str (format nil "Shopping Cart (~A Items)" (length data)))))
		  (:div :class "col-sm-6" :align "right"
		      (htm  (:a :class "btn btn-primary" :role "button" :href "/hhub/dodcustindex" "Back To Shopping"  ))))
	      (:hr)
					; Data section.
	      (:div :class "row"
		  (mapcar (lambda (product odt)
			      (htm (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-4" 
				       (:div :class "product-box" (product-card-shopcart product odt)))))      data shopcart )) )))


(defun ui-list-cust-orderdetails (header data)
    (cl-who:with-html-output (*standard-output* nil)

	(:h3 "Order Details") 
	(:table :class "table table-striped"  (:thead (:tr
					  (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
					      (mapcar (lambda (odt)
						 (let ((odt-product  (get-odt-product odt))
						       (unit-price (slot-value odt 'unit-price))
						       (ordid (slot-value odt 'order-id))
						       (prd-qty (slot-value odt 'prd-qty)))
						   (htm (:tr (:td  :height "12px" (str (slot-value odt-product 'prd-name)))
							     (:td  :height "12px" (str (format nil  "~d" prd-qty)))
							     (:td  :height "12px" (str (format nil  "Rs. ~$" unit-price)))
							     (:td  :height "12px" (str (format nil "Rs. ~$" (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty)))))
							     (:td  :height "12px" (:a :onclick "return DeleteConfirm();" :href  (format nil "/hhub/doddelcustorditem?id=~A&ord=~A" (slot-value odt 'row-id) ordid) :onclick "return false" "Cancel"))
)))) (if (not (typep data 'list)) (list data) data))))))


(defun display-order-header (order-instance)
    (let ((shipped-date (slot-value order-instance 'shipped-date)))
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class "jumbotron"
	    (:div :class "row" (:div :class "col-md-4"
				   (:h5 "Order No:") (:h4 (str (slot-value order-instance 'row-id)))
				   (:h5 "Status: " ) (:h4 (str (slot-value order-instance 'status)))
				   (:h5 "Order Date:") (:h4 (str (get-date-string (slot-value order-instance 'ord-date)))))
		(:div :class "col-md-4"
		    (:h5 "Requested On:")(:h4 (str (get-date-string (slot-value order-instance 'req-date))))
		    (:h5 "Shipped On:")(:h4 (if shipped-date (str (get-date-string shipped-date))))))))))
