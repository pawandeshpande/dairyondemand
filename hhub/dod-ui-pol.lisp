(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;; Add a new attribute. 

(defun com-das-policy-create-company ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 


(defun com-das-policy-create-attribute ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 

(defun com-das-policy-create ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 

(defun dod-controller-add-transaction-action ()
 (if (is-dod-session-valid?)
     (let* ((company (get-login-company))
	    (id (hunchentoot:parameter "id"))
	    (bo-id (hunchentoot:parameter "bo-id"))
	    (transbo (get-bus-object bo-id))
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
	(create-bus-transaction transname transuri nil transbo transtype transfunc company))
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
	    (setf (slot-value policy 'name) (concatenate 'string "com.das.policy." policyname))
	    (setf (slot-value policy 'description) policydesc)
	    (setf (slot-value policy 'policy-func) (concatenate 'string "com-das-policy-" policyfunc))
	    (update-auth-policy policy))
	  ;else
	(create-auth-policy (concatenate 'string "com.das.policy." policyname)  policydesc (concatenate 'string "com-das-policy-" policyfunc) company))
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
	(create-auth-attr-lookup (concatenate 'string  "com.das.attr." attrname)   attrdesc (concatenate 'string "com-das-attribute-" attrfunc)  attrtype company))
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
	       (modal-dialog (format nil "editbustrans-modal~a" row-id) "Add/Edit Business Transaction" (new-transaction-html row-id))))))





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
	(modal-dialog (format nil "editpolicy-modal~a" row-id) "Add/Edit Policy" (new-policy-html row-id))))))
		

  

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
				  (:input :class "form-control" :name "transuri" :aria-describedby "transuri" :maxlength "50" :value transuri :placeholder "Enter transaction URI" :type "text"))
			    
			
			    ;(:div :class "form-group" :id "charcount")
			    (:div :class "form-group input-group"
				  
				  (:span :class "input-group-addon" :id "transfuncprefix" (str *ABAC-TRANSACTION-FUNC-PREFIX* ))
				  (:label :class "input-group"  :for "transfunc" "Function:")
				  (:input :class "form-control" :name "transfunc" :maxlength "30"  :value (if transaction (subseq transname (length *ABAC-TRANSACTION-FUNC-PREFIX*))) :placeholder "Declare Transaction Function Name ( max 100 characters) " :aria-describedby "transfuncprefix"  :type "text" )
				  (:h5 "Note: If function name is changed here, then this function must be renamed in the file as well.")
				  )
			    
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


(defun new-policy-html (&optional id)
  (let* ((policy (if id (select-auth-policy-by-id id)))
	 (policyname (if policy (slot-value policy 'name)))
	 (policydesc (if policy (slot-value policy 'description)))
	 (policyfunc (if policy (slot-value policy 'policy-func)))
	 (transaction (select-bus-trans-by-trans-func "new-policy-html")))
    (if (has-permission transaction)
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		      (:form :class "form-addpolicy" :role "form" :method "POST" :action "dasaddpolicyaction"
			     (if policy (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit Policy")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "attrnameprefix" "com.das.policy.") 
				   (:input :class "form-control" :name "policyname" :aria-describedby "polnameprefix" :maxlength "30"  :value (if policy (subseq policyname (length "com.das.policy."))) :placeholder "Enter Policy  Name ( max 30 characters) " :type "text" ))
			     (:div :class "form-group"
				   (:label :for "policydesc")
				   (:textarea :class "form-control" :name "policydesc"  :placeholder "Enter Policy Description ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str policydesc) ))
			     (:div :class "form-group" :id "charcount")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "policyfuncprefix" "com-das-policy-") 
				   (:input :class "form-control" :name "policyfunc" :maxlength "30"  :value (if policy (subseq  policyfunc (length "com-das-policy-"))) :placeholder "Declare Policy Function Name ( max 100 characters) " :aria-describedby "policyfuncprefix"  :type "text" ))
			     (:div :class "form-group"
				   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:h3 "Permission Denied"))))))
