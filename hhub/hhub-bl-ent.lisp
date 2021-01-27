;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)


;; Level 1 
(defclass BusinessServer () 
  ((id)
   (name)
   (ipaddress)
   (BusinessContexts)))

;; Level 2 
(defclass BusinessContext ()
  ((id)
   (name)
   (BusinessObjectRepositories)))

;; Level 3 
(defclass BusinessObjectRepository () ;; Equivalent of a business objects repository
  ((id)
   (name)
   (BusinessObjects)))

;; Level 4 
(defclass BusinessObject ()  ;; This is the domain model entity in DDD
  ((id)))


(defgeneric getBusinessContext (BusinessServer name)
  (:documentation "Searches the business context by name"))

(defmethod getBusinessContext ((server BusinessServer) name)
  (let ((contexts (slot-value server 'BusinessContexts)))
    (find-if #'(lambda (ctx)
		 (equal name (slot-value ctx 'name))) contexts))) 	  

(defgeneric getBusinessContextRepository (BusinessContext Name)
  (:Documentation "Returns the repository stored under a business context "))

(defmethod getBusinessContextRepository ((context BusinessContext) Name)
  (let* ((BusinessRepositories-HT (slot-value context 'BusinessRepositories)))
    (gethash Name BusinessRepositories-HT)))


;;;;;;;;;;;;;; Generic functions ;;;;;;;;;;;;;;;
(defgeneric addRepository (BusinessContext BusinessObjectRepository)
  (:documentation "Adds a new BusinessObjectRepository to a given BusinessContext"))

(defgeneric createBO (BusinessObjectRepository BusinessObject)
  (:documentation "Adds a new businessobject to the BusinessRepository"))
(defgeneric deleteBO (BusinessObjectRepository BusinessObject)
  (:documentation "Deletes the BusinessObject from the BusinessObjectRepository"))

;;;;;;;;;;;;;; Method implementations ;;;;;;;;;;

(defmethod addRepository ((ctx BusinessContext) (rep BusinessObjectRepository))
   (let ((BRs (slot-value ctx 'BusinessObjectRepositories)))
    (setf BRs (append BRs (list rep)))
    (setf (slot-value ctx 'BusinessObjectRepositories) BRs)))
  
(defclass BusinessSession ()
  ((session-id)
   (start-time)
   (end-time)
   (active-flag)
   (BusinessObjectsShelf)))

(defclass VendorSession ()
  ((vendor)))


;; Generic functions for HHUBSession

(defgeneric createBusinessSession (HHUBBusinessSession)
  (:documentation "This generic function is responsible for creating a session under which all the business functions will be executed"))
(defgeneric deleteBusinessSession (HHUBBusinessSession)
  (:documentation "This generic function is responsible for deleting the HHUB Session"))
(defgeneric addBusinessSessionObject (HHUBBusinessSession name value)
  (:documentation "Add an object to the session-obj association list"))
(defgeneric updateBusinessSession (HHUBBusinessSession)
  (:documentation "Update the old business session with new one"))

(defmethod createBusinessSession (HHUBBusinessSession)
  (setf (gethash (slot-value HHUBBusinessSession 'session-id) *HHUBBUSINESSSESSIONS-HT*) HHUBBusinessSession))
(defmethod deleteBusinessSession (id)
  (remhash id *HHUBBUSINESSSESSIONS-HT*))
(defmethod addBusinessSessionObject (HHUBBusinessSession name value)
  (setf (slot-value HHUBBusinessSession 'session-obj) (acons name value (slot-value HHUBBusinessSession 'session-obj))))

(defmethod updateBusinessSession (HHUBBusinessSession)
  (let ((old (gethash (slot-value HHUBBusinessSession 'session-id) *HHUBBUSINESSSESSIONS-HT*))
	(new HHUBBusinessSession))
    (when (eql (slot-value old 'session-id) (slot-value new 'session-id))
      (remhash (slot-value old 'session-id) *HHUBBUSINESSSESSIONS-HT*)
      (setf (gethash (slot-value new 'session-id) *HHUBBUSINESSSESSIONS-HT*) new))))

