(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(defclass crm-bo ()
  ((name
    :accessor name
    :initarg :name
    :initform (error "Must supply Business Object name")
    :documentation "Business object name.")
   (bo-method
    :accessor bo-method
    :initarg :bo-method
    :initform (error "Must supply Business Object method")
    :documentation "Business object method which is responsible for querying the database/persistance.")
   (business-component-list
    :accessor business-component-list
    :initarg :business-component-list
    :initform (error "Must have a list of Business components")
    :documentation "Business component list associated with this business object")))

(defclass crm-bc ()
  ((name
    :accessor name
    :initarg :name
    :initform (error "Must supply Business component name")
    :documentation "Business component name.")
   (persistance-class-instance
    :accessor persistance-class-instance
    :initarg :persistance-class-instance
    :initform (error "Must supply a persistance class instance, defined using clsql:def-view-class")
    
    :documentation "The persistance class instance used in this implementation is defined using CLSQL:DEF-VIEW-CLASS")
    (can-delete?
     :accessor can-delete?
     :allocation :class ; Defined only once per class and shared by all instances. 
    :initarg :can-delete?
    :initform nil 
    :documentation "A boolean TRUE/NIL value, which specifies whether this business component can be deleted by a user of the CRM system.") ))



(defgeneric delete-business-component (bus-comp-instance)
  ( :documentation "Delete the business component"))


(defgeneric save-business-component ( bus-comp/s )
  (:documentation "Save the business component"))







