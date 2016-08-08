(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-products ()
(if (is-dod-session-valid?)
    (let ((prd-ini (initialize-products (get-login-company))) ; This will initialize all the functions required for products
	  ( dodproducts (select-products-by-company))
	 (header (list  "Name" "Vendor" "Quantity Per Unit" "Unit Price")))
     (if dodproducts (ui-list-products header dodproducts) "No Products"))
     (hunchentoot:redirect "/login")))




(defun ui-list-products (header data)
    (standard-page (:title "List DOD Products")
    (:h3 "Products") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (product)
									    (let ((prd-vendor  (get-prd-vendor product)))
									      (htm (:tr 
											(:td  :height "12px" (str (slot-value product 'prd-name)))
											(:td  :height "12px" (str (slot-value prd-vendor 'name)))
										       (:td  :height "12px" (str (slot-value product  'qty-per-unit)))
										       (:td  :height "12px" (str (slot-value product 'unit-price)))

										       (:td :height "12px" (:a :href  (format nil  "/delproduct?id=~A" (slot-value product 'row-id)):onclick "return false" "Delete")
											    (:a :href (format nil  "/editproduct?id=~A" (slot-value product 'row-id)) :onclick "return false"  "Edit")

											    ))))) data)))))


(defun dod-controller-order-confirmation ()
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row-fluid" )))


(defun ui-list-customer-products (header data lstshopcart)
 (cl-who:with-html-output (*standard-output* nil)
     (:div :class "row-fluid"	  (mapcar (lambda (product)
				      (htm (:div :class "col-sm-12 col-xs-12 col-md-3 col-lg-3" 
					       (:div :class "thumbnail" (product-card product (prdinlist-p (slot-value product 'row-id)  lstshopcart))))))
			      data))))


(defun product-card-shopcart (product-instance odt-instance)
  (let ((prd-name (slot-value product-instance 'prd-name))
	(qty-per-unit (slot-value product-instance 'qty-per-unit))
	(unit-price (slot-value product-instance 'unit-price))
	(prd-image-path (slot-value product-instance 'prd-image-path))
	(prd-id (slot-value product-instance 'row-id))
	   (prd-vendor (get-prd-vendor product-instance)))
    (cl-who:with-html-output (*standard-output* nil)

	(:div :class "card"
	  (:div :class "row card-block"
	      ; Product image
	      (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
		  (:img :class "card-img-top img-responsive" :src  prd-image-path :alt prd-name " "))

	        ;Remove button.
	      (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
		  (:div :class "form-group" :align "right" (htm (:a :href (str(format nil "/dodcustremshctitem?action=remitem&id=~A" prd-id)) (:span :class "glyphicon glyphicon-remove"))))) )

	    (:div :class "row card-block"
	      ;Product name and other details
	      (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
	  (:h5 :class "card-title" (str prd-name) )
	  (:p :class "cart-text" (str (format nil "  ~A.    Fulfilled By: ~A" qty-per-unit (vendor-name prd-vendor)))))

	          (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
		      (:div :class "form-group" :align "right"  (:h3(:span :class "label label-default" (str (format nil "Rs. ~A"  unit-price))) ))))


	  (:div :class "row"
	      (:form :class "form-shopcart" :role "form" :method "POST" :action "dodcustupdatecart" 
   	      (:input :class "form-control" :type "hidden" :name "prd-id" :value (format nil "~A" prd-id))
	      (:div :class "form-group col-sm-9 col-xs-9 col-md-9 col-lg-9"
		  (:input :class "form-control" :name "nprdqty" :value (slot-value odt-instance 'prd-qty) :type "text" ))
      	      (:div :class "form-group col-sm-2 col-xs-2 col-md-2 col-lg-2"
		  (:button :class "btn btn-sm btn-primary" :type "submit" "Update"))
        	      (:div :class "form-group col-sm-1 col-xs-1 col-md-1 col-lg-1" " ")

	      )))
	  )))

(defun product-card (product-instance prdincart-p)
  (let ((prd-name (slot-value product-instance 'prd-name))
	(qty-per-unit (slot-value product-instance 'qty-per-unit))
	(unit-price (slot-value product-instance 'unit-price))
	(prd-image-path (slot-value product-instance 'prd-image-path))
	(prd-id (slot-value product-instance 'row-id))
	(prd-vendor (get-prd-vendor product-instance))
	)

    (cl-who:with-html-output (*standard-output* nil)
	(:form :class "form-product" :method "POST" :action "dodcustaddtocart" 
	(:div :class "card"
    	    (:div :class "card-block"
	    (:h4 :class "card-title" (str prd-name) ))

	    (:img :class "card-img-top img-responsive" :src  prd-image-path :alt prd-name " ")
	    (:div :class "card-block"
		  
		  (:div :class "card-text" (str qty-per-unit))
		  (:div :class "card-text" (str (format nil "Fulfilled By: ~A" (vendor-name prd-vendor))))
		  (:h5 :class "card-text" (str unit-price))
		 ; (princ shopcart)
		 ; (princ prd-id)
		 ; (princ (find prd-id shopcart))
		  (if  prdincart-p (htm (:a :class "btn btn-success" :role "button"  :onclick "return false;" :href (format nil "javascript:void(0);") (:span :class "glyphicon glyphicon-ok"  )))
		      (htm (:input :type "hidden" :name "prd-id" :value (format nil "~A" prd-id))
			  (:input :type "hidden" :name "action" :value "addtocart")
		      (:button :class "btn btn-primary" :type "submit" "Add"))))
		       
		  )))))
		  
  
