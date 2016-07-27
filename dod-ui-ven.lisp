(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-vendors ()
(if (is-dod-session-valid?)
   (let (( dodvendors (get-vendors (get-login-company)))
	 (header (list "Name" "Address" "Phone"  "Action")))
     (if dodvendors (ui-list-vendors header dodvendors) "No vendors"))
     (hunchentoot:redirect "/login")))




(defun ui-list-vendors (header data)
    (standard-page (:title "List DOD Vendors")
    (:h3 "Vendors") 
      (:table :class "table table-striped"  (:thead (:tr
 (mapcar (lambda (item) (htm (:th (str item)))) header))) (:tbody
								  (mapcar (lambda (vendor)
									     (htm (:tr (:td  :height "12px" (str (slot-value vendor 'name)))
										      (:td  :height "12px" (str (slot-value vendor 'address)))
										      (:td  :height "12px" (str (slot-value vendor 'phone)))
		    (:td :height "12px" (:a :href  (format nil  "/delvendor?id=~A" (slot-value vendor 'row-id)) "Delete"))))) data)))))
									  

