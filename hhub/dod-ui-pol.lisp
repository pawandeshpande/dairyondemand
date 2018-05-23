(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;; Add a new attribute. 

(defun com-hhub-policy-create-order (&optional transaction)
  (let ((transbo (get-bus-tran-busobject transaction)))
    ; Match the Resource attribute and Action attribute for Create Order.
    (if  (and (string-equal (slot-value transbo 'name) (com-hhub-attribute-order)) 
	      (if (> (search (com-hhub-attribute-create-order) (slot-value transaction 'name)) 0) T NIL)
	      (if (< (parse-time-string (current-time-string)) (parse-time-string (com-hhub-attribute-maxordertime)))  T NIL)) T NIL)))


;(defun com-hhub-policy-create-order1 (subject resource action env ) 
;  (let ((transbo (get-bus-tran-busobject transaction)))
;    ; Match the Resource attribute and Action attribute for Create Order.
;    (if  (and (string-equal (slot-value transbo 'name) (com-hhub-attribute-order)) 
;	      (if (> (search (com-hhub-attribute-create-order) (slot-value transaction 'name)) 0) T NIL)
;	      (if (< (parse-time-string (current-time-string)) (parse-time-string (com-hhub-attribute-maxordertime)))  T NIL)) T NIL)))



; This is a Resource attribute function for order.
(defun com-hhub-attribute-order ()
  "Order")

; This is an Action attribute function for create order.
(defun com-hhub-attribute-create-order ()
"create.order")

(defun com-hhub-attribute-maxordertime ()
  "23:59:00")



(defun com-hhub-policy-create-company (&optional transaction)
  (if (equal (get-login-user-name) "superadmin") T NIL)) 


(defun com-hhub-policy-create-attribute (&optional transaction)
  (if (equal (get-login-user-name) "superadmin") T NIL)) 

(defun com-hhub-policy-create (&optional transaction)
  (if (equal (get-login-user-name) "superadmin") T NIL)) 

(defun dod-controller-add-transaction-action ()
 (if (is-dod-session-valid?)
     (let* ((company (get-login-company))
	    (id (hunchentoot:parameter "id"))
	    (boname (hunchentoot:parameter "busobject"))
	    (transbo (get-bus-object-by-name boname))
	    (transaction (get-bus-transaction id))
	    (transname (hunchentoot:parameter "transname"))
	    (transuri (hunchentoot:parameter "transuri"))
	    (transfunc (hunchentoot:parameter "transfunc"))
	    (transtype (hunchentoot:parameter "transtype")))
       (if transaction 
	   (progn 
	     (setf (slot-value transaction 'name) (concatenate 'string *ABAC-TRANSACTION-NAME-PREFIX* transname))
	     (setf (slot-value transaction 'uri) transuri)
	     (setf (slot-value transaction 'trans-func) (concatenate 'string *ABAC-TRANSACTION-FUNC-PREFIX* transfunc))
	     (setf (slot-value transaction 'trans-type) transtype)
	     (update-bus-transaction transaction))
	   ;else
	(create-bus-transaction (concatenate 'string *ABAC-TRANSACTION-NAME-PREFIX* transname)  transuri  transbo transtype (concatenate 'string *ABAC-TRANSACTION-FUNC-PREFIX* transfunc) company))
	(hunchentoot:redirect "/hhub/listbustrans"))
     ;else
   (hunchentoot:redirect "/hhub/opr-login.html")))
	     


(defun dod-controller-add-policy-action ()
(if (is-dod-session-valid?) 
    (let* ((company (get-login-company))
	   (id (hunchentoot:parameter "id"))
	   (policy (select-auth-policy-by-id id)) 
	   (policyname (hunchentoot:parameter "policyname"))
	   (policydesc (hunchentoot:parameter "policydesc"))
	   (policyfunc (hunchentoot:parameter "policyfunc")))
      (if policy 
	  (progn 
	    (setf (slot-value policy 'name) (concatenate 'string *ABAC-POLICY-NAME-PREFIX*  policyname))
	    (setf (slot-value policy 'description) policydesc)
	    (setf (slot-value policy 'policy-func) (concatenate 'string *ABAC-POLICY-FUNC-PREFIX*  policyfunc))
	    (update-auth-policy policy))
	  ;else
	(create-auth-policy (concatenate 'string *ABAC-POLICY-NAME-PREFIX*  policyname)  policydesc (concatenate 'string *ABAC-POLICY-FUNC-PREFIX*  policyfunc) company))
	(hunchentoot:redirect "/hhub/dasabacsecurity"))
      ;else
      (hunchentoot:redirect "/hhub/opr-login.html")))


(defun dod-controller-add-attribute ()
  (if (is-dod-session-valid?)
      (let* ((company (get-login-company))
	    (id (hunchentoot:parameter "id"))
	    (attribute (select-auth-attr-by-id id))
	    (attrtype (hunchentoot:parameter "attrtype"))
	    (attrname (hunchentoot:parameter "attrname"))
	    (attrdesc (hunchentoot:parameter "attrdesc"))
	    (attrfunc (hunchentoot:parameter "attrfunc")))
	(if attribute 
	    (progn 
	      (setf (slot-value attribute 'name) (concatenate 'string  *ABAC-ATTRIBUTE-NAME-PREFIX*  attrname))
	      (setf (slot-value attribute 'description ) attrdesc)
	      (setf (slot-value attribute 'attr-func ) (concatenate 'string *ABAC-ATTRIBUTE-FUNC-PREFIX*  attrfunc))
	      (setf (slot-value attribute 'attr-type) attrtype)
	      (update-auth-attr-lookup attribute))
	    ;else 
	(create-auth-attr-lookup (concatenate 'string  *ABAC-ATTRIBUTE-NAME-PREFIX* attrname)   attrdesc (concatenate 'string *ABAC-ATTRIBUTE-FUNC-PREFIX*  attrfunc)  attrtype company))
	(hunchentoot:redirect "/hhub/listattributes"))
  ;else
  (hunchentoot:redirect "/hhub/opr-login.html")))





(defun busobj-card (busobj-instance)
  (let ((name (slot-value busobj-instance 'name)))
	(cl-who:with-html-output (*standard-output* nil)
	  
	  (:div :class "product-box row"
		(:div :class "col-xs-12"
		      (:h3 :class "busobj-name"  (str name)))))))
		    

(defun bustrans-card (bustrans-instance)
  (let ((name (slot-value bustrans-instance 'name))
	(uri (slot-value bustrans-instance 'uri))
	(row-id (slot-value bustrans-instance 'row-id))
	(trans-func (slot-value bustrans-instance 'trans-func)))
    (cl-who:with-html-output (*standard-output* nil)
      (:td :height "10px" 
	   (:h6 :class "bustrans-name"  (str (format nil " ~A" name))))
      (:td :height "10px" 
	   (:h6 :class "bustrans-name"  (str (format nil " ~A" uri))))
      (:td :height "10px" 
	   (:h6 :class "bustrans-name"  (str (format nil "~A" trans-func))))
      (:td :height "10px" 
	   (:a  :data-toggle "modal" :data-target (format nil "#editbustrans-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
	   (:a  :data-toggle "modal"  :data-target (format nil "#linkbustrans-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-link"))
	   (modal-dialog (format nil "linkbustrans-modal~a" row-id) "Add/Edit Business Transaction" (link-bus-transaction-to-policy row-id))
	   (modal-dialog (format nil "editbustrans-modal~a" row-id) "Add/Edit Business Transaction" (new-transaction-html  row-id))))))

(defun attribute-card (attribute-instance)
 (let (;(attr-id (slot-value attribute-instance 'row-id))
       (name (slot-value attribute-instance 'name))
       (description (slot-value attribute-instance 'description))
       (attr-func (slot-value attribute-instance 'attr-func))
       (row-id (slot-value attribute-instance 'row-id))
       (attr-type (slot-value attribute-instance 'attr-type)))
   
  (cl-who:with-html-output (*standard-output* nil)
    (:td :height "10px" 
	 (:h6 :class "attribute-name"  (str name) ))
    (:td :height "10px" 
	 (:h6 :class "attribute-desc"  (str description) ))
    (:td :height "10px" 
	 (:h6 :class "attribute-name"  (str attr-func) ))
    (:td :height "10px" 
	 (:h6 :class "attribute-type" (str  (format nil "~A"  attr-type))))
    (:td :height "10px" 
	 (:a  :data-toggle "modal" :data-target (format nil "#editattribute-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
	 (modal-dialog (format nil "editattribute-modal~a" row-id) "Add/Edit Attribute" (com-hhub-transaction-create-attribute row-id))))))


(defun policy-card (policy-instance)
  (let ((name (slot-value policy-instance 'name))
	(description (slot-value policy-instance 'description))
	(policy-func (slot-value policy-instance 'policy-func))
	(row-id (slot-value policy-instance 'row-id)))
    (cl-who:with-html-output (*standard-output* nil)
      
      (:td :height "10px" 
	(:h6 :class "policy-name"  (str name)))
      (:td :height "10px" 
	(:h6 :class "policy-desc"  (str description)))
      (:td :height "10px" 
       	 (:h6 :class "policy-func-name"  (str policy-func) ))
      (:td :height "10px" 
       (:a  :data-toggle "modal" :data-target (format nil "#editpolicy-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
	(modal-dialog (format nil "editpolicy-modal~a" row-id) "Add/Edit Policy" (com-hhub-transaction-policy-create row-id))))))

;; @@ deprecated : start using with-html-dropdown instead. 
(defun  attribute-type-dropdown (selectedkey)
  (let ((attrtype (make-hash-table)))
    (setf (gethash "SUBJECT" attrtype) "Subject Attribute")
    (setf (gethash "ACTION" attrtype) "Action Attribute")
    (setf (gethash "RESOURCE" attrtype) "Resource Attribute")
    (setf (gethash "ENVIRONMENT" attrtype) "Environment Attribute")
    (with-html-dropdown "attrtype" attrtype selectedkey)))


(defun transaction-type-dropdown (selectedkey) 
  (let ((transtypes (make-hash-table)))
    (setf (gethash "CREATE" transtypes) "Create")
    (setf (gethash "READ" transtypes) "Read")
    (setf (gethash "UPDATE" transtypes) "Update")
    (setf (gethash "DELETE" transtypes) "Delete")
    (with-html-dropdown "transtype" transtypes selectedkey)))
	
(defun business-objects-dropdown (&optional selectedkey)
  (let* ((bolist (select-bus-object-by-company (get-login-company)))
	(bonameslist (mapcar (lambda (item) 
			       (slot-value item 'name)) bolist))
	(bohash (make-hash-table)))
	(mapcar (lambda (key) (setf (gethash key bohash) key)) bonameslist)
	(with-html-dropdown "busobject" bohash  (if (not selectedkey) (car bonameslist)))))
		     
(defun link-bus-transaction-to-policy (&optional id)
  (let* ((transaction (if id (get-bus-transaction id)))
	(policy (if transaction (get-bus-tran-policy transaction))))
	
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row"
	    (:div :class "col-xs-12"
		  (if policy (htm (:h4 (str (format nil "Linked Policy Name: ~A" (slot-value policy 'name)))))
		      (htm (:h4 (str (format nil "No Policy Linked! Create a New Policy.")))))))
      (:hr)
      (:a :class "btn btn-primary" :role "button" :href (format nil "/hhub/transtopolicylinkpage?trans-id=~A" (slot-value transaction 'row-id)) " Link Policy/Change "))))

	

(defun dod-controller-trans-to-policy-link-page ()
  (let* ((trans-id (hunchentoot:parameter "trans-id"))
	(transaction (get-bus-transaction trans-id)))
  (standard-page (:title "Link Transaction To Policy")  
    (:div :class "row" 
	  (:div :class "col-xs-12" 
		(:h4 (str (format nil "Change Transaction Policy for : ~A" (slot-value transaction 'name))))))
    (with-html-search-form "dassearchpolicies" "Enter Policy Name..." 
      (:input :class "form-control" :name "trans-id" :type "hidden" :value trans-id)))))
    

(defun dod-controller-policy-search-action ()
 (let* ((policysearch (hunchentoot:parameter "livesearch"))
	(trans-id (hunchentoot:parameter "trans-id"))
	(transaction (get-bus-transaction trans-id))
       (policies (select-auth-policy-by-name (format nil "%~A%" policysearch) (get-login-company))))
 (ui-list-policies-for-linking policies transaction)))
   


(defun ui-list-policies-for-linking (policy-list transaction)
  (let ((trans-id (slot-value transaction 'row-id)))

 (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
  (if policy-list 
      (htm (:div :class "row-fluid"	  
	    (mapcar (lambda (pol)
		      (htm (:form :method "POST" :action "transtopolicylinkaction" 
			   (:div :class "col-sm-4 col-lg-3 col-md-4"
			    (:div :class "form-group"
			     (:input :class "form-control" :name "trans-id" :type "hidden" :value trans-id ))
			    (:div :class "form-group"
			     (:input :class "form-control" :name "policy-id" :type "hidden" :value (slot-value pol 'row-id) ))
			    
			    (:div :class "form-group"
				  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" (str (format nil "~A" (slot-value pol 'name)))))))))  policy-list)))
					;else
      (htm (:div :class "col-sm-12 col-md-12 col-lg-12"
		 (:h3 "No records found")))))))

(defun dod-controller-trans-to-policy-link-action ()
  (let* ((trans-id (hunchentoot:parameter "trans-id"))
	(transaction (get-bus-transaction trans-id))
	(policy-id (parse-integer (hunchentoot:parameter "policy-id"))))
    (setf (slot-value transaction 'auth-policy-id) policy-id)
    (update-bus-transaction transaction)
    (hunchentoot:redirect "/hhub/listbustrans")))

	
    
    

(defun new-transaction-html (&optional id)
  (let* ((transaction (if id (get-bus-transaction id)))
	 (transname (if transaction (slot-value transaction 'name)))
	 (transuri (if transaction (slot-value transaction 'uri)))
	 (transbo (if transaction (get-bus-tran-busobject transaction)))
	 (bo-id (if transbo (slot-value transbo 'row-id)))
	 (transtype (if transaction (slot-value transaction 'trans-type)))
	 (transfunc (if transaction (slot-value transaction 'trans-func))))
	
(cl-who:with-html-output (*standard-output* nil)
  (:div :class "row" 
   (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
     (:form :class "form-addtransaction" :role "form" :method "POST" :action "dasaddtransactionaction"
       (if transaction (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
       (if transbo (htm (:input :class "form-control" :type "hidden" :value bo-id :name "bo-id")))
       (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
       (:h1 :class "text-center login-title"  "Add/Edit Transaction")
       (:div :class "form-group input-group"
	     (:span :class "input-group-addon"  "Business Object") 
	     (business-objects-dropdown))
       (:div :class "form-group input-group"
	(:span :class "input-group-addon" :id "transnameprefix" (str *ABAC-TRANSACTION-NAME-PREFIX*) )
	(:label :class "input-group"  :for "transname" "Name:")
	(:input :class "form-control" :name "transname" :aria-describedby "transnameprefix" :maxlength "30"  :value (if transaction (subseq transname (length *ABAC-TRANSACTION-NAME-PREFIX*)))  :placeholder "Enter Transaction  Name ( max 30 characters) " :type "text" ))
       (:div :class "form-group"
	 (:label :for "transuri" "URL")
	 (:input :class "form-control" :name "transuri" :aria-describedby "transuri" :maxlength "50" :value transuri :placeholder "Enter transaction URI" :type "text")
	 (:h6 "Note: If the URL is changed here, then this URL has to be updated in dod-ui-sys.lisp as well."))
       (:div :class "form-group input-group"
	(:span :class "input-group-addon" :id "transfuncprefix" (str *ABAC-TRANSACTION-FUNC-PREFIX* ))
	(:label :class "input-group"  :for "transfunc" "Function:")
	(:input :class "form-control" :name "transfunc" :maxlength "30"  :value (if transaction (subseq transfunc (length *ABAC-TRANSACTION-FUNC-PREFIX*))) :placeholder "Declare Transaction Function Name ( max 100 characters) " :aria-describedby "transfuncprefix"  :type "text" )
	(:h6 "Note: If function name is changed here, then this function must be renamed in the file as well."))
       (:div :class "form-group input-group"
	 (:span :class "input-group-addon"  "Type") 
	 (transaction-type-dropdown transtype))
       (:div :class "form-group"
	 (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))))





(defun com-hhub-transaction-create-attribute (&optional id)
  (let* ((attribute (if id (select-auth-attr-by-id id)))
	 (attrname (if attribute (slot-value attribute 'name)))
	 (attrdesc (if attribute (slot-value attribute 'description)))
	 (attrtype (if attribute (slot-value attribute 'attr-type)))
	 (attrfunc (if attribute (slot-value attribute 'attr-func)))
	 (transaction (select-bus-trans-by-trans-func "com-hhub-transaction-create-attribute")))

(if (has-permission transaction)
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (:form :class "form-addattribute" :role "form" :method "POST" :action "dasaddattribute"
			 (if attribute (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			 (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			    (:h1 :class "text-center login-title"  "Add/Edit Attribute")
			    (:div :class "form-group input-group"
				  (:span :class "input-group-addon" :id "attrnameprefix" (str *ABAC-ATTRIBUTE-NAME-PREFIX*)) 
				  (:input :class "form-control" :name "attrname" :aria-describedby "attrnameprefix" :maxlength "30"  :value (if attribute (subseq attrname (length *ABAC-ATTRIBUTE-NAME-PREFIX*))) :placeholder "Enter Attribute  Name ( max 30 characters) " :type "text" ))
			    (:div :class "form-group"
				  (:label :for "attrdesc")
				  (:textarea :class "form-control" :name "attrdesc"  :placeholder "Enter Attribute Description ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 200)" (str attrdesc) ))
			    (:div :class "form-group" :id "charcount")
			    (:div :class "form-group input-group"
				  
				  (:span :class "input-group-addon" :id "attrfuncprefix" (str *ABAC-ATTRIBUTE-FUNC-PREFIX*)) 
				  (:input :class "form-control" :name "attrfunc" :maxlength "30"  :value (if attribute (subseq attrfunc (length *ABAC-ATTRIBUTE-FUNC-PREFIX*))) :placeholder "Declare Attribute Function Name ( max 100 characters) " :aria-describedby "attrfuncprefix"  :type "text" ))
			    (:div :class "form-group"
				  (attribute-type-dropdown attrtype))
			    
			    (:div :class "form-group"
				  (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
(cl-who:with-html-output (*standard-output* nil)
  (:div :class "row" 
	(:h3 "Permission Denied"))))))


(defun com-hhub-transaction-policy-create (&optional id)
  (let* ((policy (if id (select-auth-policy-by-id id)))
	 (policyname (if policy (slot-value policy 'name)))
	 (policydesc (if policy (slot-value policy 'description)))
	 (policyfunc (if policy (slot-value policy 'policy-func)))
	 (transaction (select-bus-trans-by-trans-func "com-hhub-transaction-policy-create")))
    (if (has-permission transaction)
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		      (:form :class "form-addpolicy" :role "form" :method "POST" :action "dasaddpolicyaction"
			     (if policy (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit Policy")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "attrnameprefix" (str *ABAC-POLICY-NAME-PREFIX*) ) 
				   (:input :class "form-control" :name "policyname" :aria-describedby "polnameprefix" :maxlength "30"  :value (if policy (subseq policyname (length *ABAC-POLICY-NAME-PREFIX*))) :placeholder "Enter Policy  Name ( max 30 characters) " :type "text" ))
			     (:div :class "form-group"
				   (:label :for "policydesc")
				   (:textarea :class "form-control" :name "policydesc"  :placeholder "Enter Policy Description ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str policydesc) ))
			     (:div :class "form-group" :id "charcount")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "policyfuncprefix" (str *ABAC-POLICY-FUNC-PREFIX*)) 
				   (:input :class "form-control" :name "policyfunc" :maxlength "30"  :value (if policy (subseq  policyfunc (length *ABAC-POLICY-FUNC-PREFIX*))) :placeholder "Declare Policy Function Name ( max 100 characters) " :aria-describedby "policyfuncprefix"  :type "text" ))
			     (:div :class "form-group"
				   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:h3 "Permission Denied"))))))
