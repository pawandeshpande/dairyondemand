(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

;;; Add a new attribute. 


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



(defun dod-controller-add-ui-attributes ()
    (if (is-dod-session-valid?)
	(standard-page (:title "Welcome to Dairy ondemand- Add New Attributes")
	    (:div :class "row" 
		(:div :class "col-sm-6 col-md-4 col-md-offset-4"
			(:h1 :class "text-center login-title"  "Define Policy ")
			(:form :class "form-order" :role "form" :method "POST" :action "/dodaddattraction"
			    (:div  :class "form-group" (:label :for "attrname" "Attribute Name" )
				(:input :class "form-control" :name "attrname" :value "" :type "text"  ))
			    (:div :class "form-group" (:label :for "attrexpr" "Lisp Expression" )
				(:input :class "form-control" :name "attrexpr" :value "" :type "textarea" :rows "3" :columns "50"))
			    (:div  :class "form-group" (:label :for "attrtype" "Attribute Type" )
				(:input :class "form-control" :name "attrname" :value "" :type "text"  ))
			   			    (:input :type "submit"  :class "btn btn-primary" :value "Confirm")))))
	(hunchentoot:redirect "/opr-login.html")))




;;;; function list-attributes

(defun ui-list-attributes (data lstattrcart)
    (cl-who:with-html-output (*standard-output* nil)
	(:div :class "row-fluid"	  (mapcar (lambda (attr)
						      (htm (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-4" 
							       (:div :class "attribute-box"   (attribute-card attr (attrinlist-p (slot-value attr 'row-id)  lstattrcart))))))
					      data))))

(defun attribute-card (attribute-instance attrincart-p)
    (let ((attr-id (slot-value attribute-instance 'row-id))
	  (name (slot-value attribute-instance 'name))
	  (description (slot-value attribute-instance 'description))
	  (attr-type (slot-value attribute-instance 'attr-type)))
	(cl-who:with-html-output (*standard-output* nil)
	  
		(:div :class "row"
		    (:div :class "col-sm-6"
		(:h5 :class "attribute-name"  (str name) ))
    		    (:div :class "col-sm-6"
		(:h5 :class "attribute-desc"  (str description) ))
    		    (:div :class "col-sm-6"
		(:h5 :class "attribute-type"  (str attr-type) ))
		    (:div :class "row"
		    (if  attrincart-p (htm   (:div :class "col-sm-6" (:a :class "btn btn-sm btn-success" :role "button"  :onclick "return false;" :href (format nil "javascript:void(0);") (:span :class "glyphicon glyphicon-ok"  ))))
			 ;else 
			 
		     (htm    (:form :class "form-attribute" :method "POST" :action "dodaddattrtocart" 
		      (:input :type "hidden" :name "attr-id" :value (format nil "~A" attr-id))
			  (:div :class "col-sm-6" (:button :class "btn btn-sm btn-primary" :type "submit" :name "btnaddattrtocart" "Add"))))) )))))
