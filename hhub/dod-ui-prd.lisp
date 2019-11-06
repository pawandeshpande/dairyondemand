(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun ui-list-prod-catg-dropdown (name catglist)
  (cl-who:with-html-output (*standard-output* nil)
    (htm (:select :class "form-control"  :name name  
      (loop for catg in catglist
	 do   (htm  (:option :value  (slot-value catg 'row-id) (str (slot-value catg 'catg-name)))))))))

(defun ui-list-yes-no-dropdown (value) 
(cl-who:with-html-output (*standard-output* nil) 
  (:select :class "form-control" :name "yesno"
	  (if (equal value "N") (htm (:option :value "N" "NO" :selected)
				     (:option :value "Y" "YES"))
	   (htm (:option :value "Y" "YES" :selected)
		(:option :value "N" "NO"))))))
	   
(defun ui-list-prod-catg (catglist)
  (cl-who:with-html-output (*standard-output* nil :prologue t :indent t)
	(:div :class "row-fluid"	  (mapcar (lambda (prdcatg)
						      (htm (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-4" 
							       (:div :class "prdcatg-box"   (prdcatg-card prdcatg )))))
					     catglist))))


  

(defun ui-list-customer-products (data lstshopcart)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
    (:div :id "searchresult"  :class "container" 
	  (:div :class "row-fluid"  (mapcar (lambda (product)
					            (htm (:div :class "col-xs-12 col-sm-6 col-md-4 col-lg-4" 
							              (:div :class "product-box"   (product-card product (prdinlist-p (slot-value product 'row-id)  lstshopcart))))))
					          data)))))


(defun product-card-shopcart (product-instance odt-instance)
    (let* ((prd-name (slot-value product-instance 'prd-name))
	   (qty-per-unit (slot-value product-instance 'qty-per-unit))
	   (prdqty (slot-value odt-instance 'prd-qty))
	   (unit-price (slot-value product-instance 'unit-price))
	   (prd-image-path (slot-value product-instance 'prd-image-path))
	   (prd-id (slot-value product-instance 'row-id))
	   (subtotal (* prdqty unit-price))
	   (prd-vendor (product-vendor product-instance)))

      (cl-who:with-html-output (*standard-output* nil)
	(with-html-form "form-shopcart" "dodcustupdatecart"    
	  (:div :class "row"
			 (:div  :class "col-xs-6" (:a :href "#" (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " ")))
		    			;Remove button.
			 (:div :class "col-xs-6" :align "right"
			       (htm (:a :data-toggle "tooltip" :title "Remove from shopcart"  :href (format nil "dodcustremshctitem?action=remitem&id=~A" prd-id) (:span :class "glyphicon glyphicon-remove")))))
					;Product name and other details
		   (:div :class "row"
			 (:div :class "col-xs-12"
			       (:h5 :class "product-name"  (str prd-name) )
			       (:p  (str (format nil "  ~A. Fulfilled By: ~A" qty-per-unit (name prd-vendor)))))
			 (:div :class "row"
			 (:div :class "col-sm-12"
			       (:div  (:h3(:span :class "label label-default" (str (format nil "Rs. ~$ X ~A = Rs. ~$"  unit-price prdqty subtotal))))))))))))



(defun product-card-for-email (product-instance odt-instance)
  (let* ((prd-name (slot-value product-instance 'prd-name))
	 (qty-per-unit (slot-value product-instance 'qty-per-unit))
	 (prdqty (slot-value odt-instance 'prd-qty))
	 (unit-price (slot-value product-instance 'unit-price))
	 (prd-image-path (slot-value product-instance 'prd-image-path))
	 (subtotal (* prdqty unit-price))
	 (prd-vendor (product-vendor product-instance)))
    (cl-who:with-html-output-to-string (*standard-output* nil)
      (:tr 
	    (:td  (:a :href "#" (:img :src  (str (format nil "https://www.highrisehub.com~A" prd-image-path)) :height "83" :width "100" :alt prd-name " "))))
					;Product name and other details
      (:tr
	    (:td
		  (:h5 :class "product-name"  (str prd-name) )
		  (:p   (str (format nil "  ~A. Fulfilled By: ~A" qty-per-unit (name prd-vendor))))))
      (:tr
	    (:td
		  (:h3(:span :class "label label-default" (str (format nil "Rs. ~$ X ~A = Rs. ~$"  unit-price prdqty subtotal)))))))))



(defun product-card-shopcart-readonly (product-instance odt-instance)
  (let* ((prd-name (slot-value product-instance 'prd-name))
	 (qty-per-unit (slot-value product-instance 'qty-per-unit))
	 (prdqty (slot-value odt-instance 'prd-qty))
	 (unit-price (slot-value product-instance 'unit-price))
	 (prd-image-path (slot-value product-instance 'prd-image-path))
	 (subtotal (* prdqty unit-price))
	 (prd-vendor (product-vendor product-instance)))
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row"
	    (:div  :class "col-xs-6" (:a :href "#" (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " "))))
					;Product name and other details
      (:div :class "row"
	    (:div :class "col-xs-12"
		  (:h5 :class "product-name"  (str prd-name) )
		  (:p  (str (format nil "  ~A. Fulfilled By: ~A" qty-per-unit (name prd-vendor))))))
      (:div :class "row"
	    (:div :class "col-sm-12"
		  (:h3(:span :class "label label-default" (str (format nil "Rs. ~$ X ~A = Rs. ~$"  unit-price prdqty subtotal)))))))))



(defun prdcatg-card (prdcatg-instance)
    (let ((catg-name (slot-value prdcatg-instance 'catg-name))
	  (row-id (slot-value prdcatg-instance 'row-id)))
	(cl-who:with-html-output (*standard-output* nil)
		(:div :class "row"
		(:div :class "col-sm-12" (:a :href (format nil "dodproducts?id=~A" row-id) (str catg-name)))))))
		

(defun modal.vendor-product-edit-html (product mode) 
  (let* ((prd-image-path (slot-value product 'prd-image-path))
	 (description (slot-value product 'description))
	 (unit-price (slot-value product 'unit-price))
	 (subscribe-flag (slot-value product 'subscribe-flag))
	 (qty-per-unit (slot-value product 'qty-per-unit))
	 (units-in-stock (slot-value product 'units-in-stock))
	 (prd-id (slot-value product 'row-id))
	 (prd-name (slot-value product 'prd-name)))

 (cl-who:with-html-output (*standard-output* nil)
   (:div :class "row" 
	 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
	       (:form :id (format nil "form-vendorprod~A" mode) :data-toggle "validator"  :role "form" :method "POST" :action "dodvenaddproductaction" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
		(if (and product (equal mode "EDIT")) (htm (:input :class "form-control" :type "hidden" :value prd-id :name "id")))
		 (:div :align "center"  :class "form-group" 
		       (:a :href "#" (:img :src (if prd-image-path  (format nil "~A" prd-image-path)) :height "83" :width "100" :alt prd-name " ")))
		 (:h1 :class "text-center login-title"  "Edit/Copy Product")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "prdname" :value prd-name :placeholder "Enter Product Name ( max 30 characters) " :type "text" ))
		      (:div :class "form-group"
			    (:label :for "description")
			    (:textarea :class "form-control" :name "description"  :placeholder "Enter Product Description ( max 1000 characters) "  :rows "5" :onkeyup "countChar(this, 1000)" (str (format nil "~A" description))))
		      (:div :class "form-group" :id "charcount")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "prdprice"  :value (format nil "~$" unit-price)  :type "number" :min "0.00" :max "10000.00" :step "0.10"  ))
		      		      
		      (:div :class "form-group"
			    (:input :class "form-control" :name "qtyperunit" :value qty-per-unit :placeholder "Quantity per unit. Ex - KG, Grams, Nos" :type "text" ))
					;(:div  :class "form-group" (:label :for "prodcatg" "Select Produt Category:" )
					;(ui-list-prod-catg-dropdown "prodcatg" catglist))
		      (:div :class "form-group"
			    (:input :class "form-control" :name "unitsinstock" :placeholder "Units In Stock"  :value units-in-stock  :type "number" :min "1" :max "10000" :step "1"  ))

		      (:br) 
		      (:div :class "form-group" (:label :for "yesno" "Product/Service Subscription")
			    (if (equal subscribe-flag "Y") (ui-list-yes-no-dropdown "Y")
				(ui-list-yes-no-dropdown "N")))
		      
		      (:div :class "form-group" (:label :for "prodimage" "Select Product Image:")
			    (:input :class "form-control" :name "prodimage" :placeholder "Product Image" :type "file" ))
		      (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))



(defun modal.vendor-product-reject-html (prd-id tenant-id)
  (let* ((company (select-company-by-id tenant-id))
	 (product (select-product-by-id prd-id company))
	 (prd-image-path (slot-value product 'prd-image-path))
	 (description (slot-value product 'description))
	 (prd-name (slot-value product 'prd-name))
	 (prd-id (slot-value product 'row-id)))
 (cl-who:with-html-output (*standard-output* nil)
   (:div :class "row" 
	 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
	       (:form :id (format nil "form-vendorprod")  :role "form" :method "POST" :action "hhubcadprdrejectaction" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
		      (:input :class "form-control" :type "hidden" :value prd-id :name "id")
		 (:div :align "center"  :class "form-group" 
		       (:a :href "#" (:img :src (if prd-image-path  (format nil "~A" prd-image-path)) :height "83" :width "100" :alt prd-name " ")))
		 (:h1 :class "text-center login-title"  "Reject Product")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "prdname" :value prd-name :placeholder "Enter Product Name ( max 30 characters) " :type "text" :readonly "true" ))
		      (:div :class "form-group"
			    (:label :for "description" "Enter Rejection Reason")
			    (:textarea :class "form-control" :name "description"  :placeholder "Enter Reject Reason "  :rows "5" :onkeyup "countChar(this, 1000)" (str (format nil "~A" description))))
		      (:div :class "form-group" :id "charcount")
		      
		       (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))


(defun modal.vendor-product-accept-html (prd-id tenant-id)
  (let* ((company (select-company-by-id tenant-id))
	 (product (select-product-by-id prd-id company))
	 (prd-image-path (slot-value product 'prd-image-path))
	 (description (slot-value product 'description))
	 (prd-name (slot-value product 'prd-name))
	 (prd-id (slot-value product 'row-id)))
 (cl-who:with-html-output (*standard-output* nil)
   (:div :class "row" 
	 (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
	       (:form :id (format nil "form-vendorprod")  :role "form" :method "POST" :action "hhubcadprdapproveaction" :enctype "multipart/form-data" 
					;(:div :class "account-wall"
		      (:input :class "form-control" :type "hidden" :value prd-id :name "id")
		 (:div :align "center"  :class "form-group" 
		       (:a :href "#" (:img :src (if prd-image-path  (format nil "~A" prd-image-path)) :height "83" :width "100" :alt prd-name " ")))
		 (:h1 :class "text-center login-title"  "Accept Product")
		      (:div :class "form-group"
			    (:input :class "form-control" :name "prdname" :value prd-name :placeholder "Enter Product Name ( max 30 characters) " :type "text" :readonly "true" ))
		      (:div :class "form-group"
			    (:label :for "description")
			    (:textarea :class "form-control" :name "description"  :placeholder "Description "  :rows "5" :onkeyup "countChar(this, 1000)" (str (format nil "~A" description))))
		      (:div :class "form-group" :id "charcount")
		      
		       (:div :class "form-group"
			    (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))



(defun product-card-for-vendor (product-instance)
    (let ((prd-name (slot-value product-instance 'prd-name))
	  ;(qty-per-unit (slot-value product-instance 'qty-per-unit))
	  (unit-price (slot-value product-instance 'unit-price))
	  (units-in-stock (slot-value product-instance 'units-in-stock))
	  (description (slot-value product-instance 'description))
	  (prd-image-path (slot-value product-instance 'prd-image-path))
	  (prd-id (slot-value product-instance 'row-id))
	  (active-flag (slot-value product-instance 'active-flag))
	  (approved-flag (slot-value product-instance 'approved-flag))
	  (approval-status (slot-value product-instance 'approval-status))
	  (subscribe-flag (slot-value product-instance 'subscribe-flag)))
	    
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "product-box" 
	  (:div :style "background-color:#E2DBCD; border-bottom: solid 1px; margin-bottom: 3px;" :class "row"
		
		(if (equal active-flag "Y")
		    (htm (:div :class "col-xs-2" :data-toggle "tooltip" :title "Turn Off" 
		      (:a   :href (format nil "dodvenddeactivateprod?id=~A" prd-id) (:span :class "glyphicon glyphicon-off"))))
		    ;else
		    (htm (:div :class "col-xs-2" :data-toggle "tooltip" :title "Turn On" 
		      (:a :href (format nil "dodvendactivateprod?id=~A" prd-id) (:span :class "glyphicon glyphicon-off")))))
		(:div :class "col-xs-2" 
		      (:a :data-toggle "modal" :data-target (format nil "#dodvendcopyprod-modal~A" prd-id)  :href "#"  (:span :class "glyphicon glyphicon-copy"))
		      (modal-dialog (format nil "dodvendcopyprod-modal~A" prd-id) "Copy Product" (modal.vendor-product-edit-html  product-instance "COPY")))
		(:div :class "col-xs-2" :align "right" 
		     (:a :data-toggle "modal" :data-target (format nil "#dodvendeditprod-modal~A" prd-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
		     (modal-dialog (format nil "dodvendeditprod-modal~A" prd-id) "Edit Product" (modal.vendor-product-edit-html product-instance  "EDIT"))) 
		    
		(:div :class "col-xs-4" :align "right" "")
		(:div :class "col-xs-2" :align "right"
		      (:a :onclick "return DeleteConfirm();"  :href (format nil "dodvenddelprod?id=~A" prd-id) (:span :class "glyphicon glyphicon-remove"))))
	  (:div :class "row"
		(if (<= units-in-stock 0) 
		    (htm (:div :class "stampbox rotated" "NO STOCK" ))
		    ;else
		    (htm (:div :class "col-xs-12" (:h5 (:span :class "badge" (str (format nil "In stock ~A  units"  units-in-stock ))))))))
		      
	  (:div :class "row"
		(:div :class "col-xs-5" 
		      (:a :href (format nil "dodprddetailsforvendor?id=~A" prd-id)  (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " ")))
		(:div :class "col-xs-3" (:h3 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price))))))
	
	  (:div :class "row"
		(:div :class "col-xs-6"
		      (:h5 :class "product-name" (str (if (> (length prd-name) 30)  (subseq prd-name  0 30) prd-name))))
		(:div :class "col-xs-6"
		      (if (equal subscribe-flag "Y") (htm (:div :class "col-xs-6"  (:h5 (:span :class "label label-default" "Can be Subscribed")))))))
	  (:div :class "row" 
		(:div :class "col-xs-12" 
		      (:h6 (str (if (> (length description) 90)  (subseq description  0 90) description)))))
	  
	  (if (equal active-flag "N") 
	      (htm (:div :class "stampbox rotated" "INACTIVE" )))
	  (if (equal approved-flag "N")
	      (htm (:div :class "stampbox rotated" (str (format nil "~A" approval-status)))))))))


(defun product-card-for-approval (product-instance)
    (let* ((prd-name (slot-value product-instance 'prd-name))
	  (unit-price (slot-value product-instance 'unit-price))
	  ;(description (slot-value product-instance 'description))
	  (prd-image-path (slot-value product-instance 'prd-image-path))
	  (prd-id (slot-value product-instance 'row-id))
	  ;(active-flag (slot-value product-instance 'active-flag))
	  (approved-flag (slot-value product-instance 'approved-flag))
	  (tenant-id (slot-value product-instance 'tenant-id))
	  (company (select-company-by-id tenant-id))
	  (company-name (slot-value company 'name))
	  (approval-status (slot-value product-instance 'approval-status))
	  (subscribe-flag (slot-value product-instance 'subscribe-flag)))
	    
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "product-box" 
		(:div :style "background-color:#E2DBCD; border-bottom: solid 1px; margin-bottom: 3px;" :class "row"
		      (:div :class "col-xs-12" (:h5 (str (format nil "~A" company-name)))))
		 

	  (:div :class "row"
		(:div :class "col-xs-5" 
		      (:a :href (format nil "dodprddetailsforvendor?id=~A" prd-id)  (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " ")))
		(:div :class "col-xs-3" (:h3 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price))))))
		
		(:div :class "row"
		      (:div :class "col-xs-6"
			    (:h5 :class "product-name" (str (if (> (length prd-name) 30)  (subseq prd-name  0 30) prd-name))))
		(:div :class "col-xs-6"
		      (if (equal subscribe-flag "Y") (htm (:div :class "col-xs-6"  (:h5 (:span :class "label label-default" "Can be Subscribed")))))))
			(if (equal approved-flag "N")
		    (htm (:div :class "stampbox rotated" (str (format nil "~A" approval-status)))))
			
		(:div :class "row"
		      (:div :class "col-xs-6"
			    (:button :data-toggle "modal" :data-target (format nil "#dodvendrejectprod-modal~A" prd-id)  :href "#"  (:span :class "glyphicon glyphicon-remove") "Reject")
			    (modal-dialog (format nil "dodvendrejectprod-modal~A" prd-id) "Reject Product" (modal.vendor-product-reject-html  prd-id tenant-id)))
		      (:div :class "col-xs-6"
			    (:button :data-toggle "modal" :data-target (format nil "#dodvendacceptprod-modal~A" prd-id)  :href "#"  (:span :class "glyphicon glyphicon-ok") "Accept")
			    (modal-dialog (format nil "dodvendacceptprod-modal~A" prd-id) "Accept Product" (modal.vendor-product-accept-html  prd-id tenant-id))))
			))))







(defun product-card (product-instance prdincart-p)
    (let ((prd-name (slot-value product-instance 'prd-name))
	  (unit-price (slot-value product-instance 'unit-price))
	  (prd-image-path (slot-value product-instance 'prd-image-path))
	  ;(qty-per-unit (slot-value product-instance 'qty-per-unit))
	  (units-in-stock (slot-value product-instance 'units-in-stock))
	  (description (slot-value product-instance 'description))
	  (prd-id (slot-value product-instance 'row-id))
	  (subscribe-flag (slot-value product-instance 'subscribe-flag))
	  (customer-type (get-login-customer-type)))
      (cl-who:with-html-output (*standard-output* nil)
	(:div :class "row" 
	      (:div  :class "col-xs-5" (:a :href (format nil "dodprddetailsforcust?id=~A" prd-id) (:img :src  (format nil "~A" prd-image-path) :height "83" :width "100" :alt prd-name " ")))
	      (:div :class "col-xs-6" 
		 	(:div  (:h3 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price)))))))
	(:div :class "row"
	      (:div :class "col-xs-12" 	(:a :href (format nil "dodprddetailsforcust?id=~A" prd-id) (:h5 :class "product-name"  (str prd-name)))))
	(:div :class "row"
	      (if (equal subscribe-flag "Y") 
		  (htm 
					;(:form :class "form-subscribe" :method "POST" :action "dodprodsubscribe"
					;     (:input :type "hidden" :name "prd-id" :value (format nil "~A" prd-id))
		   (if (equal customer-type "STANDARD") (htm (:div :class "col-xs-6"  
		      (:button :data-toggle "modal" :data-target (format nil "#productsubscribe-modal~A" prd-id)  :href "#"   :class "btn btn-sm btn-primary" :name "btnsubscribe"  (:span :class "glyphicon glyphicon glyphicon-hand-up") " Subscribe"))))
		   (modal-dialog (format nil "productsubscribe-modal~A" prd-id) "Subscribe Product/Service" (product-subscribe-html prd-id))))

			  (if  prdincart-p 
			       (htm   (:div :class "col-xs-6"  (:a :class "btn btn-sm btn-success" :role "button"  :onclick "return false;" :href (format nil "javascript:void(0);") (:span :class "glyphicon glyphicon-ok"  ))))
			 ;else 
			       (if (and units-in-stock (> units-in-stock 0))
				(htm (:div  :class "col-xs-6"   
				       (:button :data-toggle "modal" :data-target (format nil "#producteditqty-modal~A" prd-id)  :href "#"   :class "btn btn-sm btn-primary" :name "btnsubscribe"  (:span :class "glyphicon glyphicon glyphicon-plus") " Add")
(modal-dialog (format nil "producteditqty-modal~A" prd-id) (str (format nil "Edit Product Quantity - Available: ~A" units-in-stock)) (product-qty-edit-html prd-id))))
;else
(htm (:div :class "col-xs-6" 
	  (:h5 (:span :class "label label-danger" "Out Of Stock")))))))


		(:div :class "row" 
		      (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12" 
			    (:h6 (str (if (> (length description) 150)  (subseq description  0 150) description)))))
		
)))

(defun product-card-with-details-for-customer (product-instance prdincart-p)
    (let* ((prd-name (slot-value product-instance 'prd-name))
	  (qty-per-unit (slot-value product-instance 'qty-per-unit))
	  ;(units-in-stock (slot-value product-instance 'units-in-stock))
	  (unit-price (slot-value product-instance 'unit-price))
	  (description (slot-value product-instance 'description))
	  (prd-image-path (slot-value product-instance 'prd-image-path))
	  (prd-id (slot-value product-instance 'row-id))
	  (prd-vendor (product-vendor product-instance))
	  (vendor-id (slot-value prd-vendor 'row-id)))
      (cl-who:with-html-output (*standard-output* nil)
	(:div :class "container"
	      (:div :class "row"
					; Product image only here
		    (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6 image-responsive"
			  (:img :src  (format nil "~A" prd-image-path) :height "300" :width "400" :alt prd-name " "))
		    (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6"
			  (:h1  (str prd-name))
			  (:div (str qty-per-unit))
			  (:button :data-toggle "modal" :data-target (format nil "#vendordetails-modal~A" vendor-id)  :href "#"   :class "btn btn-sm btn-primary" :name "btnvendormodal" (str (name prd-vendor)))  
			  (modal-dialog (format nil "vendordetails-modal~A" vendor-id) (str (format nil "Vendor Details")) (modal.vendor-details vendor-id))
			 ; (:div (str (format nil "Supplier - "))  (:a :href (format nil  "dodvendordetails?id=~A" (slot-value prd-vendor 'row-id)) (str (name prd-vendor))))
			  (:hr)
			  (:div  (:h2 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price))) ))
			  (:hr)
			  (:div (:h4 (str description)))
			  (if  prdincart-p 
			       (htm (:a :class "btn btn-sm btn-success" :role "button"  :onclick "return false;" :href (format nil "javascript:void(0);") (:span :class "glyphicon glyphicon-ok"  )))
					;else
			       (htm
				(:div  :class "col-xs-6"   
				       (:button :data-toggle "modal" :data-target (format nil "#producteditqty-modal~A" prd-id)  :href "#"   :class "btn btn-sm btn-primary" :name "btnsubscribe"  (:span :class "glyphicon glyphicon glyphicon-plus") " Add")
				       (modal-dialog (format nil "producteditqty-modal~A" prd-id) "Edit Product Quantity" (product-qty-edit-html prd-id )))))))))))




(defun product-card-with-details-for-vendor (product-instance)
    (let ((prd-name (slot-value product-instance 'prd-name))
	  (qty-per-unit (slot-value product-instance 'qty-per-unit))
	  (unit-price (slot-value product-instance 'unit-price))
	  (description (slot-value product-instance 'description))   
	  (prd-image-path (slot-value product-instance 'prd-image-path)))
      (cl-who:with-html-output (*standard-output* nil)
	(:div :class "container"
	      (:div :class "row"
					; Product image only here
		    (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6 image-responsive"
			  (:img :src  (format nil "~A" prd-image-path) :height "300" :width "400" :alt prd-name " "))
		    (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-6"
			  (:form :class "form-product" :method "POST" :action "dodcustaddtocart" 
				 (:h1  (str prd-name))
				 (:div (str qty-per-unit))
		
				 (:hr)
				 (:div  (:h2 (:span :class "label label-default" (str (format nil "Rs. ~$"  unit-price))) ))
				 (:hr)
				 (:div (:h4 (str description)))
		)))))))

