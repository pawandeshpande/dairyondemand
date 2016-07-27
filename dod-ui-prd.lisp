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





(defun ui-list-customer-products (header data lstshopcart)
 (cl-who:with-html-output (*standard-output* nil)
     (:div :class "row-fluid"	  (mapcar (lambda (product)
				      (htm (:div :class "col-sm-4 col-xs-6 col-md-6 col-lg-3" 
					       (:div :class "thumbnail" (product-card product (member (slot-value product 'row-id) lstshopcart))))))
			      data))))







(defun product-card-shopcart (product-instance)
  (let ((prd-name (slot-value product-instance 'prd-name))
	(qty-per-unit (slot-value product-instance 'qty-per-unit))
	(unit-price (slot-value product-instance 'unit-price))
	(prd-image-path (slot-value product-instance 'prd-image-path))
	(prd-id (slot-value product-instance 'row-id))
	   (prd-vendor (get-prd-vendor product-instance))
	   (nprdqty 0)
	(shopcart (hunchentoot:session-value :login-shopping-cart)))


      
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "card"

	  (:div :class "row card-block"
	      (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
		  (:img :class "card-img-top img-responsive" :src  prd-image-path :alt prd-name " "))
	      (:div :class "col-sm-6 col-xs-6 col-md-6 col-lg-6"
	  (:div :class "form-group" :align "right" (htm (:a :href (str(format nil "/dodcustremshctitem?action=remitem&id=~A" prd-id)) (:span :class "glyphicon glyphicon-remove"))))) )

	  (:div :class "row card-block"
	      (:div :class "col-xs-6"
	  (:h5 :class "card-title" (str prd-name) )
	  (:p :class "card-text" (str qty-per-unit))
	  (:p :class "cart-text" (str (format nil "Fulfilled By: ~A" (vendor-name prd-vendor)))))

	          (:div :class "col-sm-6"
		  (:div :class "form-group"  (:h4(:span :class "label label-primary" (str unit-price)) ))))

	  (:div :class "form-group"
	      (:label :for "nprdqty" "Qty")
	      (:select :class "form-control" :id="nprdqty"
		  (:option "1")(:option "2")(:option "3")(:option "4")(:option "5")(:option "6")(:option "7")(:option "8")(:option "9") ))
	 ; (:div :class "form-group" (:input :class "form-control" :name (format nil "prdqty~A" (incf nprdqty)) :placeholder "1"  :type "text"))
	     
(:div :class "form-group"  (htm (:a :class "btn btn-primary" :role "button" :href (format nil "/dodcustupdshctitem?action=upditem&id=~A" prd-id) "Update"))))

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
		  (if  prdincart-p (htm (:a :class "btn btn-success" :role "button"  :onclick "return false;" :href (format nil "javascript:void(0);") "Added"))
		      (htm (:input :type "hidden" :name "prd-id" :value (format nil "~A" prd-id))
			  (:input :type "hidden" :name "action" :value "addtocart")
		      (:button :class "btn btn-primary" :type "submit" "Add"))))
		       
		  )))))
		  
  
