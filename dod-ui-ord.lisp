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
										       (:td :height "12px" (:a :class "btn btn-primary" :role "button" :href  (format nil  "/delorder?id=~A" (slot-value order 'row-id)) "Delete")
											    (:a  :class "btn btn-primary" :role "button" :href  (format nil  "/orderdetails?id=~A" (slot-value order 'row-id)) "Details"))
											    )))) (if (not (typep data 'list)) (list data) data))))))


(defun ui-list-vendor-orders (ordlist)
    (let*  ((vendor (hunchentoot:session-value :login-vendor))
	       (products  (select-products-by-vendor vendor  (select-company-by-id 2)))
	     (odtlst (mapcar (lambda (prd)
			(delete nil (mapcar (lambda (ord)
				    (get-order-details-by-prd (slot-value prd 'row-id) ord))  ordlist) :test #'equal))
				   products)))

	 (cl-who:with-html-output (*standard-output* nil)	       
		    (mapcar (lambda (prd odtlstbyprd)
				(let ((quantity (reduce #'+ (mapcar (lambda (odt)
									(if odt (slot-value odt 'prd-qty)))   odtlstbyprd)))
					 (subtotal (reduce #'+ (mapcar (lambda (odt)
									   (if odt (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))  )) odtlstbyprd))))
				    (if (>  subtotal 0)  
				  (htm  (:div :class "thumbnail row"
			(:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			    (str (slot-value prd 'prd-name)))
			(:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
    			    (str (slot-value prd 'qty-per-unit)))
					    
		       (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			  (:h5 "Rs " (str (slot-value prd 'unit-price)) " Each"))
		     (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			  (:span :class "badge" (str quantity)))

		   (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			(:h4 (:span :class "label label-default" (str (format nil "Rs. ~$" subtotal))  )))))) )) products odtlst))))


(defun ui-list-vendor-orders-by-customers (ordlist vendor-instance)
 	 (cl-who:with-html-output (*standard-output* nil)	       
     (mapcar (lambda (ord )
	 (let ((odtlst (get-order-details-for-vendor  ord vendor-instance))
		  (customer (get-ord-customer ord)))
	     (htm (:div :class "row"
		      (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			  (:h3 (:span :class "label label-primary" (str (format nil "~A. ~A. " (slot-value customer 'name) (slot-value customer 'address)))       )))))
		 (mapcar (lambda (odt)
			     (let ((prd (get-odt-product odt)))
				 (htm (:div :class "row"
			     	(:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			    (str (slot-value prd 'prd-name)))
			(:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
    			    (str (slot-value odt 'prd-qty)))
    			(:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
    			    (str (slot-value prd 'qty-per-unit)))
		       (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			   (:h5 (str (format nil "Rs ~$ Each" (slot-value odt 'unit-price))) )))))) odtlst))) ordlist)))
	

    

(defun ui-list-customer-orders (header data)
  (cl-who:with-html-output (*standard-output* nil)
          (:a :class "btn btn-primary" :role "button" :href (format nil "/dodcustindex") "Shop Now")
    (:h3 "Orders") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (order)
									      (htm (:tr (:td  :height "12px" (str (slot-value order 'row-id)))
											(:td  :height "12px" (str (get-date-string (slot-value order 'ord-date))))
										       (:td  :height "12px" (str (get-date-string (slot-value order 'req-date))))
										       (:td :height "12px" (:a :href  (format nil  "/delorder?id=~A" (slot-value order 'row-id)) (:b :class "label label-primary"  "Delete")) "&nbsp;&nbsp;"
											   (:a :href  (format nil  "/dodmyorderdetails?id=~A" (slot-value order 'row-id)) (:span :class "label label-primary" "Details" )))
											    ))) (if (not (typep data 'list)) (list data) data) )))))

(defun concat-ord-dtl-name (order-instance)
  (let ((odt ( get-order-details order-instance)))
    (mapcar (lambda (odt-ins)
	      (concatenate 'string (slot-value (get-odt-product odt-ins) 'prd-name) ",")) odt)))
