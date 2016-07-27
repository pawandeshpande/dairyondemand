(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-orderprefs ()
(if (is-dod-session-valid?)
   (let (( dodorderprefs (get-opreflist-by-company  (get-login-company)))
	 (header (list  "Sl No" "Customer" "Product" "Product Qty" "Action")))
     (if dodorderprefs (ui-list-orderprefs header dodorderprefs) "No Order Prefernces"))
   (hunchentoot:redirect "/customer-login.html")))




;**************Function to list an individual customer's order preferences ******************
(defun ui-list-cust-orderprefs (header data)
    (standard-customer-page (:title "List DOD Order Preferences")

      (:a :class "btn btn-primary" :role "button" :href (format nil "/dodcustaddorderpref") "Add Order Preference")
      (:h3 "My Order Preferences")      
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (orderpref)
									    (let ((opf-customer  (get-opf-customer orderpref))
										  (opf-product (get-opf-product orderpref)))
										(htm (:tr
											 
										       (:td  :height "12px" (str (slot-value opf-product  'prd-name)))
										       (:td  :height "12px" (str (slot-value orderpref 'prd-qty)))

										       (:td :height "12px" (:a :href  (format nil  "/delorderpref?id=~A" (slot-value orderpref 'row-id)):onclick "return false" "Delete")))))) data)))))


;********************Function to list all customer order preferences for a given company.************************
(defun ui-list-orderprefs (header data)
    (standard-page (:title "List DOD Order Preferences")
    (:h3 "Order Preferences") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (orderpref)
									    (let ((opf-customer  (get-opf-customer orderpref))
										  (opf-product (get-opf-product orderpref)))
									      (htm (:tr (:td  :height "12px" (str (slot-value orderpref 'row-id)))
											
											(:td  :height "12px" (str (slot-value opf-customer 'name)))
										       (:td  :height "12px" (str (slot-value opf-product  'prd-name)))
										       (:td  :height "12px" (str (slot-value orderpref 'prd-qty)))

										       (:td :height "12px" (:a :href  (format nil  "/delorderpref?id=~A" (slot-value orderpref 'row-id)):onclick "return false" "Delete")
											    (:a :href  (format nil  "/editorderpref?id=~A" (slot-value orderpref 'row-id))  :onclick "return false" "Edit")

											    ))))) data)))))






(defun dod-controller-create-orderpref ()
  (standard-page (:title "Welcome to DOD - Order Preferences")
    (:div :class "row background-image:resources/login-background.png;background-color:lightblue;" 
	  (:div :class "col-sm-6 col-md-4 col-md-offset-4"
		(:div :class "account-wall"
		      (:h1 :class "text-center login-title"  "Order Preferences")
		      (:form :class "form-signin" :role "form" :method "POST" :action "/dodorderpref"
			     (:div :class "form-group"
				   (:input :class "form-control" :name "product" :placeholder "Product"  :type "text"))
			     (:div :class "form-group"
				   (:input :class "form-control" :name "quantity" :placeholder "Quantity" :type "text"))
			     (:input :type "submit"  :class "btn btn-primary" :value "Add      ")))))))


