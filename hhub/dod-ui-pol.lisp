(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;; Add a new attribute. 

(defun DOD-POL-SA-CREATE-COMPANY ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 


(defun DOD-POL-SA-CREATE-ATTRIBUTE ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 

(defun com-das-policy-create ()
  (if (equal (get-login-user-name) "superadmin") T NIL)) 


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
	      (setf (slot-value attribute 'name) attrname)
	      (setf (slot-value attribute 'description ) attrdesc)
	      (setf (slot-value attribute 'attr-func ) attrfunc)
	      (setf (slot-value attribute 'attr-type) attrtype)
	      (update-auth-attr-lookup attribute))
	    ;else 
	(create-auth-attr-lookup (concatenate 'string  "com.das.attr." attrname)   attrdesc (concatenate 'string "com-das-attribute-" attrfunc)  attrtype company))
	(hunchentoot:redirect "/hhub/list-attributes"))
  ;else
  (hunchentoot:redirect "/hhub/opr-login.html")))


(defun dod-controller-add-ui-policy ()
    (if (is-dod-session-valid?)
	(standard-page (:title "Welcome to Dairy ondemand- Add Customer Order")
	    (:div :class "row" 
		(:div :class "col-sm-6 col-md-4 col-md-offset-4"
			(:h1 :class "text-center login-title"  "Define Policy ")
			(:form :class "form-order" :role "form" :method "POST" :action "/dodaddpolicyaction"
			    (:div  :class "form-group" (:label :for "policyname" "Policy Name" )
				(:input :class "form-control" :name "policyname" :value "" :type "text"  ))
			    (:div :class "form-group" (:label :for "policyexpr" "Expression" )
				(:input :class "form-control" :name "policyexpr" :value "" :type "textarea" :rows "3" :columns "50"))
			    ;(:div :class "form-group" (:label :for "shipaddress" "Ship Address" )
			;	(:textarea :class "form-control" :name "shipaddress" :rows "4"  (str (format nil "~A" (slot-value customer 'address)))  ))
			   			    (:input :type "submit"  :class "btn btn-primary" :value "Confirm")))))
	(hunchentoot:redirect "/opr-login.html")))




(defun busobj-card (busobj-instance)
  (let ((name (slot-value busobj-instance 'name)))
	(cl-who:with-html-output (*standard-output* nil)
	  
	  (:div :class "product-box row"
		(:div :class "col-xs-12"
		      (:h3 :class "busobj-name"  (str name)))))))
		    

(defun attribute-card (attribute-instance)
    (let (;(attr-id (slot-value attribute-instance 'row-id))
	  (name (slot-value attribute-instance 'name))
	  (description (slot-value attribute-instance 'description))
	  (attr-func (slot-value attribute-instance 'attr-func))
	  (row-id (slot-value attribute-instance 'row-id))
	  (attr-type (slot-value attribute-instance 'attr-type)))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "product-box"
	  (:div :class "row" 
		(:div :class "col-xs-12" :align "right"
		      (:a  :data-toggle "modal" :data-target (format nil "#editattribute-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
		       ;(:button :type "button" :class "btn btn-primary" :data-toggle "modal" :data-target "#editcompany-modal" "Add New Group")
		     (modal-dialog (format nil "editattribute-modal~a" row-id) "Add/Edit Attribute" (new-attribute-html row-id))))
		      
		(:div :class "row"
		    (:div :class "col-xs-12"
		(:h3 :class "attribute-name"  (str name) )))
		(:div :class "row"
		    (:div :class "col-xs-12"
		(:h5 :class "attribute-desc"  (str description) )))
		(:div :class "row"
		   (:div :class "col-xs-12"
			 (:h5 :class "attribute-name"  (str attr-func) )))
		(:div :class "row"   
		      (:div :class "col-xs-12"
			    (:h5 :class "attribute-type" (str  (format nil "Type : ~A"  attr-type)))))))))

(defun policy-card (policy-instance)
  (let ((name (slot-value policy-instance 'name))
	(description (slot-value policy-instance 'description))
	(policy-func (slot-value policy-instance 'policy-func))
	(row-id (slot-value policy-instance 'row-id)))
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "product-box"
	  (:div :class "row" 
		(:div :class "col-xs-12" :align "right"
		      (:a  :data-toggle "modal" :data-target (format nil "#editpolicy-modal~A" row-id)  :href "#"  (:span :class "glyphicon glyphicon-pencil"))
		      (modal-dialog (format nil "editpolicy-modal~a" row-id) "Add/Edit Policy" (new-policy-html row-id))))
		      
		(:div :class "row"
		    (:div :class "col-xs-12"
		(:h3 :class "attribute-name"  (str name) )))
		(:div :class "row"
		    (:div :class "col-xs-12"
		(:h5 :class "attribute-desc"  (str description) )))
		(:div :class "row"
		   (:div :class "col-xs-12"
			 (:h5 :class "attribute-name"  (str policy-func) )))))))
		

  
;; This is payment-mode dropdown
(defun  attribute-type-dropdown ()
  (cl-who:with-html-output (*standard-output* nil)
     (htm (:select :class "form-control"  :name "attrtype"
		   (:option    :value  "SUBJECT" :selected "true"  (str "Subject Attribute"))
		   (:option :value "ACTION" (str "Action Attribute"))
		   (:option :value "RESOURCE" (str "Resource Attribute"))
		   (:option :value "ENVIRONMENT" (str "Environment Attribute")) ))))


(defun new-attribute-html (&optional id)
  (let* ((attribute (if id (select-auth-attr-by-id id)))
	 (attrname (if attribute (slot-value attribute 'name)))
	 (attrdesc (if attribute (slot-value attribute 'description)))
	 ;(attrtype (if attribute (slot-value attribute 'attr-type)))
	 (attrfunc (if attribute (slot-value attribute 'attr-func)))
	 (transaction (select-bus-trans-by-trans-func "new-attribute-html")))

(if (has-permission transaction)
    (cl-who:with-html-output (*standard-output* nil)
      (:div :class "row" 
	    (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		  (:form :class "form-addattribute" :role "form" :method "POST" :action "dasaddattribute"
			 (if attribute (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			 (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			    (:h1 :class "text-center login-title"  "Add/Edit Attribute")
			    (:div :class "form-group input-group"
				  (:span :class "input-group-addon" :id "attrnameprefix" "com.das.attr.") 
				  (:input :class "form-control" :name "attrname" :aria-describedby "attrnameprefix" :maxlength "30"  :value attrname :placeholder "Enter Attribute  Name ( max 30 characters) " :type "text" ))
			    (:div :class "form-group"
				  (:label :for "attrdesc")
				  (:textarea :class "form-control" :name "attrdesc"  :placeholder "Enter Attribute Description ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 200)" (str attrdesc) ))
			    (:div :class "form-group" :id "charcount")
			    (:div :class "form-group input-group"
				  
				  (:span :class "input-group-addon" :id "attrfuncprefix" "com-das-attribute-") 
				  (:input :class "form-control" :name "attrfunc" :maxlength "30"  :value attrfunc :placeholder "Declare Attribute Function Name ( max 100 characters) " :aria-describedby "attrfuncprefix"  :type "text" ))
			    (:div :class "form-group"
				  (attribute-type-dropdown))
			    
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
		      (:form :class "form-addpolicy" :role "form" :method "POST" :action "dasaddpolicy"
			     (if policy (htm (:input :class "form-control" :type "hidden" :value id :name "id")))
			     (:img :class "profile-img" :src "resources/demand&supply.png" :alt "")
			     (:h1 :class "text-center login-title"  "Add/Edit Policy")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "attrnameprefix" "com.das.policy.") 
				   (:input :class "form-control" :name "policyname" :aria-describedby "polnameprefix" :maxlength "30"  :value policyname :placeholder "Enter Policy  Name ( max 30 characters) " :type "text" ))
			     (:div :class "form-group"
				   (:label :for "policydesc")
				   (:textarea :class "form-control" :name "policydesc"  :placeholder "Enter Policy Description ( max 400 characters) "  :rows "5" :onkeyup "countChar(this, 400)" (str policydesc) ))
			     (:div :class "form-group" :id "charcount")
			     (:div :class "form-group input-group"
				   (:span :class "input-group-addon" :id "policyfuncprefix" "com-das-policy-") 
				   (:input :class "form-control" :name "attrfunc" :maxlength "30"  :value policyfunc :placeholder "Declare Policy Function Name ( max 100 characters) " :aria-describedby "policyfuncprefix"  :type "text" ))
			     (:div :class "form-group"
				   (:button :class "btn btn-lg btn-primary btn-block" :type "submit" "Submit"))))))
	(cl-who:with-html-output (*standard-output* nil)
	  (:div :class "row" 
		(:h3 "Permission Denied"))))))
