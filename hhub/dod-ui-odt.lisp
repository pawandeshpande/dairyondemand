(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defun dod-controller-order-item-edit ()
  (let* ((item-id (hunchentoot:parameter "item-id"))
	; (company (hunchentoot:session-value :login-customer-company))
	 (prdqty (parse-integer (hunchentoot:parameter "prdqty")))
	 (order-id (hunchentoot:parameter "order-id"))
	 (order-item (get-order-item-by-id item-id)))
    (cond ((> prdqty 0) (progn 
			  (setf (slot-value order-item 'prd-qty) prdqty)
			  (update-order-item order-item))))
	 ; ((equal prdqty 0) (delete-order-items (list item-id) company)))
    (hunchentoot:redirect (format nil "/hhub/dodmyorderdetails?id=~A" order-id))))


(defun order-item-edit-popup (item-id) 
 (let* ((order-item (get-order-item-by-id item-id))
	(order-id (slot-value order-item 'order-id))
	(product (get-odt-product order-item))
	(prd-id (slot-value product 'row-id))
	(prd-image-path (slot-value product 'prd-image-path))
	(prd-name (slot-value product 'prd-name)))
   (cl-who:with-html-output (*standard-output* nil)
     (:div :align "center" :class "row account-wall" 
	   (:div :class "col-sm-12  col-xs-12 col-md-12 col-lg-12"
		 (:div  :class "row" 
			(:div  :class "col-xs-12" 
			       (:a :href (format nil "dodprddetailsforcust?id=~A" prd-id) 
				   (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " "))))
		 (:form :class "form-orditemedit" :role "form" :method "POST" :action "dodcustorditemedit"
			(:div :class "form-group row"  (:label :for "product-id" (str (format nil  " ~a" prd-name ))))
			(:input :type "hidden" :name "item-id" :value (format nil "~a" (slot-value order-item 'row-id)))
			(:input :type "hidden" :name "order-id" :value (format nil "~a" order-id ))
			(:div  :class "inputQty row" 
			       (:div :class "col-xs-4"
				     (:a :class "down btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-minus" ""))) 
			       (:div :class "form-group col-xs-4" 
				     (:input :class "form-control input-quantity" :readonly "true" :name "prdqty" :placeholder "Enter a number"  :value (format nil "~a" (slot-value order-item 'prd-qty))   :type "number"))
			(:div :class "col-xs-4"
			      (:a :class "up btn btn-primary" :href "#" (:span :class "glyphicon glyphicon-plus" ""))))
		 (:div :class "form-group" 
		       (:input :type "submit"  :class "btn btn-primary" :value "Save"))))))))
		 




(defun dod-controller-list-order-details ()
    (if (is-dod-session-valid?)
	(let* (( dodorder (get-order-by-id (hunchentoot:parameter "id") (get-login-company)))
		  (header (list  "Order No" "Product" "Product Qty" "Unit Price"  "Total"  "Action"))
		  (odt (get-order-items dodorder) ))
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
		  (:div :class "col-xs-6" 
		      (:h4 (str (format nil "Shopping Cart (~A Items)" (length data)))))
		  (:div :class "col-sm-6" :align "right"
		      (htm  (:a :class "btn btn-primary" :role "button" :href "/hhub/dodcustindex" "Back To Shopping"  ))))
	      (:hr)
					; Data section.
	      
	      (:div :class "container"
		    (:div :class "row"
			  (mapcar (lambda (product odt)
				    (htm (:div :class "col-xs-12 col-sm-6 col-md-4 col-lg-3" 
					       (:div :class "product-box" (product-card-shopcart product odt)))))      data shopcart ))))))


(defun ui-list-cust-orderdetails (header data)
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class  "panel panel-default"
	(:div :class "panel-heading" "Order Items")
	(:div :class "panel-body"
	(:table :class "table table-hover"  (:thead (:tr
					  (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
					      (mapcar (lambda (odt)
						 (let ((odt-product  (get-odt-product odt))
						       (item-id (slot-value odt 'row-id))
						       ;(unit-price (slot-value odt 'unit-price))
						       (ordid (slot-value odt 'order-id))
						       (fulfilled (slot-value odt 'fulfilled))
						       (status (slot-value odt 'status))
						       (prd-qty (slot-value odt 'prd-qty)))
						   (htm (:tr  (cond ((and (equal status "PEN") (equal fulfilled "N")) 
								    (htm (:td  :height "12px" (str (format nil "Pending")))
									 (:td  :height "12px" 
									       (:a  :data-toggle "modal" :data-target (format nil "#orditemedit-modal~A" item-id)  :href "#" (:span :class "glyphicon glyphicon-pencil")) "&nbsp;&nbsp;"
									       (modal-dialog (format nil "orditemedit-modal~A" item-id) "Order Item Edit" (order-item-edit-popup item-id))
																(:a :onclick "return CancelConfirm();" :href  (format nil "/hhub/doddelcustorditem?id=~A&ord=~A" (slot-value odt 'row-id) ordid) :onclick "return false" (:span :class "glyphicon glyphicon-remove")))))
								   ((and (equal status "CMP") (equal fulfilled "Y"))  (htm (:td  :height "12px" (str (format nil "Fulfilled"))))))
							     

							      (:td  :height "12px" (str (slot-value odt-product 'prd-name)))
							      (:td  :height "12px" (str (format nil  "~d" prd-qty)))
							      ;(:td  :height "12px" (str (format nil  "Rs. ~$" unit-price)))
							      (:td  :height "12px" (str (format nil "Rs. ~$" (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty)))))
							    
)))) (if (not (typep data 'list)) (list data) data))))))))


(defun display-order-header-for-customer (order-instance)
  (let ((payment-mode (slot-value order-instance 'payment-mode))
	  (shipped-date (slot-value order-instance 'shipped-date)))
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class "jumbotron"
	    (:div :class "row" (:div :class "col-md-4"
				   (:h5 "Order No:") (:h4 (str (slot-value order-instance 'row-id)))
				   (:h5 "Payment Mode:") (:h4 (str (cond ((equal payment-mode "PRE") "Prepaid Wallet")
								       ((equal payment-mode "COD") "Cash On Demand")))))
				  
				  
		(:div :class "col-md-4"
		      (:h5 "Status: " ) (:h4 (str (slot-value order-instance 'status)))
		      (:h5 "Order Date:") (:h4 (str (get-date-string (slot-value order-instance 'ord-date))))
		    (:h5 "Requested On:")(:h4 (str (get-date-string (slot-value order-instance 'req-date))))
		    (:h5 "Shipped On:")(:h4 (if shipped-date (str (get-date-string shipped-date))))))))))

(defun display-order-header-for-vendor (order-instance)
    (let ((customer (get-customer order-instance))
	  (payment-mode (slot-value order-instance 'payment-mode))
	  (shipped-date (slot-value order-instance 'shipped-date)))
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class "jumbotron"
	    (:div :class "row" (:div :class "col-md-4"
				   (:h5 "Order No:") (:h4 (str (slot-value order-instance 'row-id)))
				   (:h5 "Payment Mode:") (:h4 (str (cond ((equal payment-mode "PRE") "Prepaid Wallet")
								       ((equal payment-mode "COD") "Cash On Demand"))))
				   (:h5 "Customer:") (:h4 (str (slot-value customer 'name)))
				   (:h5 "Address:") (:h4 (str (slot-value customer 'address))))
				  
		(:div :class "col-md-4"
		       (:h5 "Phone:") (:h4 (str (slot-value customer 'phone)))
				   (:h5 "Status: " ) (:h4 (str (slot-value order-instance 'status)))
				   (:h5 "Order Date:") (:h4 (str (get-date-string (slot-value order-instance 'ord-date))))
		    (:h5 "Requested On:")(:h4 (str (get-date-string (slot-value order-instance 'req-date))))
		    (:h5 "Shipped On:")(:h4 (if shipped-date (str (get-date-string shipped-date)))))
		(:div :class "col-md-4" 
		      (if (equal (slot-value order-instance 'order-fulfilled) "Y")
			  (htm (:div :class "stampbox rotated" "FULFILLED"))))
		)))))
