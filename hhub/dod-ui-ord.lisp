(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-orders ()
(if (is-dod-session-valid?)
   (let (( dodorders (get-orders-by-company  (get-login-company)))
	 (header (list  "Order No" "Order Date" "Customer" "Request Date"  "Ship Date" "Ship Address" "Action")))
     (if dodorders (ui-list-orders header dodorders) "No orders"))
     (hunchentoot:redirect "login")))


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
											(:td :height "12px" (:a :class "btn btn-primary" :role "button" :href  (format nil  "delorder?id=~A" (slot-value order 'row-id)) "Cancel Order")
											     (:a  :class "btn btn-primary" :role "button" :href  (format nil  "orderdetails?id=~A" (slot-value order 'row-id)) "Details"))
											)))) (if (not (typep data 'list)) (list data) data))))))



(defun ui-list-orders-for-excel (header ordlist)
  (cl-who:with-html-output-to-string (*standard-output* nil)
      (mapcar (lambda (item) (str (format nil "~A," item ))) header)
      (str (format nil " ~C~C" #\return #\linefeed))
      (mapcar (lambda (ord )
		(let* ((odtlst (dod-get-cached-order-items-by-order-id (slot-value ord 'order-id)))
		       (total   (reduce #'+  (mapcar (lambda (odt)
						       (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst)))
		       (customer (get-customer ord)))
		  (if (>  (length odtlst) 0) 
		      (progn  
			
			(str (format nil "Order: ~A Customer: ~A. ~A." (slot-value ord 'order-id)  (slot-value customer 'name) (slot-value customer 'address) )) 
			(if (equal (slot-value ord 'fulfilled) "Y") 
			    (str (format nil "Order status - Fulfilled ~C~C" #\return #\linefeed )) 
			    ;else
			    (str (format nil "Order status - Pending ~C~C" #\return #\linefeed)))
			(mapcar (lambda (odt)
			     (let ((prd (get-odt-product odt))
				   (subtotal (* (slot-value odt 'prd-qty) (slot-value odt 'unit-price))))


				 (str (format nil "~a,~a,~a,Rs ~$ ,Each,~$,~C~C"  (slot-value prd 'prd-name)  (slot-value odt 'prd-qty) (slot-value prd 'qty-per-unit)  (slot-value odt 'unit-price) subtotal  #\return #\linefeed  )))) odtlst)
		
			(str (format nil ",,,,,Total = Rs ~$~C~C" total #\return #\linefeed)))
		 ))) ordlist)))




(defun ui-list-vendor-orders-by-products (ordlist)
    (let*  ((vendor (get-login-vendor))
	    (tenant-id (get-login-vendor-tenant-id))
	    (vendor-company (get-login-vendor-company))
	    (products  (select-products-by-vendor vendor vendor-company))
	    (odtlst (mapcar (lambda (prd)
			      (let ((prd-id (slot-value prd 'row-id)))
				(delete nil (mapcar (lambda (ord)
						      (let ((order-id (slot-value ord 'order-id)))
							(get-order-items-by-product-id  prd-id  order-id tenant-id)))  ordlist) :test #'equal)))
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
			  (:h5 (str (format nil "Rs ~$ Each" ( slot-value prd 'unit-price)))))
		     (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			  (:span :class "badge" (str quantity)))

		   (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			(:h4 (:span :class "label label-default" (str (format nil "Rs. ~$" subtotal))  )))))) )) products odtlst))))


(defun ui-list-vendor-orders-by-customers (ordlist)
 (cl-who:with-html-output (*standard-output* nil)	       
   (:a :class "btn btn-primary btn-xs" :role "button" :onclick "window.print();" :href "#" "Print&nbsp;&nbsp;"(:span :class "glyphicon glyphicon-print"))
					; For every vendor order
   (mapcar (lambda (ord )
	     (let*  ((odtlst (dod-get-cached-order-items-by-order-id (slot-value ord 'order-id) ))
		     (total   (reduce #'+  (mapcar (lambda (odt)
						     (* (slot-value odt 'unit-price) (slot-value odt 'prd-qty))) odtlst)))
		     (customer (get-customer ord)))
	       ;(if (>  (length odtlst) 0) 
		   (progn 
		     (htm (:div :class "row"
			    (:div :class "col-sm-12 col-xs-12 col-md-4 col-lg-2"
			     (:h4 (str (format nil "Order: ~A ~A. ~A. ~A. " (slot-value ord 'order-id) (slot-value customer 'name) (slot-value customer 'phone)(slot-value customer 'address)))))))
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
						  (:h5 (str (format nil "Rs ~$ Each" (slot-value odt 'unit-price))) )))))) odtlst)
					; Display the total for an order
			  
		     (htm (:hr) (:div :class "row"
				      (:div :class "col-sm-12" 
					    (:h4 (:span :class "label label-default" (str (format nil "Total ~$" total))))))
			  			  
			       (:hr))
		     
		     ))) ordlist)))


    

(defun ui-list-customer-orders (header data)
  (cl-who:with-html-output (*standard-output* nil)
    
    (:h3 "Orders")
  
      (:table :class "table table-striped table-hover"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (order)
									    (htm (:tr (:td  :height "12px" (str (slot-value order 'row-id)))
											(:td  :height "12px" (str (get-date-string (slot-value order 'ord-date))))
										       (:td  :height "12px" (str (get-date-string (slot-value order 'req-date))))
											   (if (equal (slot-value order 'order-fulfilled) "Y")
											      (htm  (:td :height "12px"   (:a :href  (format nil  "dodmyorderdetails?id=~A" (slot-value order 'row-id)) (:span :class "label label-primary" "Details" ))  "&nbsp;&nbsp;" (:span :class "label label-info" "FULFILLED")
))
											       ; ELSE
										       	  (htm  (:td :height "12px" (:a :href  (format nil  "dodmyorderdetails?id=~A" (slot-value order 'row-id)) (:span :class "label label-primary" "Details" ))))
											    )))) (if (not (typep data 'list)) (list data) data) )))))

(defun concat-ord-dtl-name (order-instance)
  (let ((odt ( get-order-items order-instance)))
    (mapcar (lambda (odt-ins)
	      (concatenate 'string (slot-value (get-odt-product odt-ins) 'prd-name) ",")) odt)))


(defun vendor-order-card (order-instance)
    (let* ((id (slot-value order-instance 'cust-id))
	   (customer (select-customer-by-id id (get-login-vendor-company)))
	  (order-id (slot-value order-instance 'order-id))
	  (name (if customer (slot-value customer 'name)))
	  (address (if customer (slot-value customer 'address))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "order-box" 
	  (:div :class "row"
		      (:div :class "col-sm-12" (str name ))
		      (:div :class "col-sm-12" (str (if (> (length address) 20)  (subseq (slot-value customer 'address) 0 20) address)))
		(:div :class "col-sm-12"  (:a :href (format nil "dodvendororderdetails?id=~A" order-id) (:span :class "label label-info" (str order-id) ))))))))

