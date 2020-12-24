;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :hhub)

(defun crm-controller-delete-journal-entry ()
(if (is-crm-session-valid?)
    (let ((id (hunchentoot:parameter "id")) )
      (delete-crm-journal-entry id)
      (hunchentoot:redirect "/list-journal-entries"))
     (hunchentoot:redirect "/login")))


(defun crm-controller-list-journal-entries ()
(if (is-crm-session-valid?)
   (let (( journal-entries (list-crm-drcr-entries (get-login-tenant-id))))
    (standard-page (:title "List Journal Entries")
      (:table :class "table table-striped" 
	      (:tr  (:th "Name") (:th "Description") (:th "Action"))
      (if (= (list-length journal-entries) 0) (cl-who:htm (:tr (:td  :height "12px" (:p "No journal-entry Found"))))
      (loop for journal-entry in journal-entries
       do (cl-who:htm (:tr (:td  (cl-who:str (slot-value journal-entry 'name)))
		    (:td  (cl-who:str (slot-value journal-entry 'description)))
		    (:td  (:a :href  (format nil  "/deljournal-entry?id=~A" (slot-value journal-entry 'row-id)) "Delete")))))))))
    (hunchentoot:redirect "/login")))


(defun crm-controller-list-journal-entry-details ()
(if (is-crm-session-valid?)
   (let*  ( ( opty-id (hunchentoot:parameter "opty-id")) ( journal-entries (list-crm-journal-entry-details opty-id (get-login-tenant-id))))
    (standard-page (:title "List Journal Entry Details")
      (:table :class "table table-striped" 
	      (:tr (:th "Name") (:th "Description") (:th "Action"))
      (if (= (list-length journal-entries) 0) (cl-who:htm (:tr (:td  :height "12px" (:p "No journal-entry Found"))))
      (loop for journal-entry in journal-entries
       do (cl-who:htm (:tr (:td  (cl-who:str (slot-value journal-entry 'name)))
		    (:td  (cl-who:str (slot-value journal-entry 'description)))
		    (:td  (:a :href  (format nil  "/deljournal-entry?id=~A" (slot-value journal-entry 'row-id)) "Delete")))))))))
    (hunchentoot:redirect "/login")))

(defun crm-controller-list-journal-entries2 ()
(if (is-crm-session-valid?)
    (let*  (( jnr-entries (list-crm-drcr-entries (get-login-tenant-id))))

    (standard-page (:title "List Journal Entry Details for Account")
      (:table :class "table table-striped" 
	      (:tr (:th "Date") (:th "Name") (:th "Description")(:th "Debit") (:th "Credit") (:th "Action"))
      (if (= (list-length jnr-entries) 0) (cl-who:htm (:tr (:td  :height "12px" (:p "No journal-entry Found"))))
      (loop for jnr-entry in jnr-entries
	 do (let ((jnr-entry-acct (journal-entry-account jnr-entry))
		  (jnr-entry-opty (journal-entry-opty jnr-entry)))

	   (cl-who:htm (:tr 
		     (:td  (cl-who:str (slot-value jnr-entry-acct 'name)))
		    (:td  (cl-who:str (slot-value jnr-entry-opty 'name)))
		    (:td  (cl-who:str (slot-value jnr-entry-opty 'description)))
		    (:td  (str(slot-value jnr-entry 'amount)))
		   ))))))))
    (hunchentoot:redirect "/login")))





(defun crm-controller-new-journal-entry ()
(if (is-crm-session-valid?)
      (standard-page (:title "Add a new journal-entry")
	(:h1 "Add a new journal-entry")
	(:form :action "/journal-entry-added" :method "post" 
	       (:p "Name: "
		   (:input :type "text"  :maxlength 30
			   :name "name" 
			   :class "txt")
		   (:p "Description: " (:textarea :rows 4 :cols 50  :maxlength 255   
					    :name "description" 
					    :class "txt"))

		   (:p (journal-entry-page)))))
      (hunchentoot:redirect "/login")))


;;(defun crm-controller-drcr-added (jr-name srcAct dstAct srcDR srcCR dstDR dstCR)
  	;; get the journal entry just created above. 
;;  (let ((object (get-journal-entry jr-name))
;;	(src
	  ;; let us create a debit and credit entry for the journal entry
	  ;; debit entry
	 ;; (new-crm-drcr-entry (slot-value object 'row-id) SourceAccount
	  ;; credit entry
	  
;;	  (new-crm-debit-credit-entry 
;;)))
	   
(defun crm-controller-journal-entry-added ()
  (if (is-crm-session-valid?)
      (let  ((name (hunchentoot:parameter "name"))
	     (description (hunchentoot:parameter "description"))
	     (SourceAccount (hunchentoot:parameter "SourceAccount"))
	     (DestAccount (hunchentoot:parameter "DestAccount"))
	     (SrcDr (hunchentoot:parameter "Debit-SourceAccount"))
	     (SrcCr (hunchentoot:parameter "Credit-SourceAccount"))
	     (DstDr (hunchentoot:parameter "Debit-DestAccount"))
	     (DstCr (hunchentoot:parameter "Credit-DestAccount")))
	     
	     
	(unless(and  ( or (null name) (zerop (length name)))
		     ( or (null description) (zerop (length description)))
		     (or (null SourceAccount) (zerop (length SourceAccount)))
		     (or (null SrcDr) (zerop (length SrcDr)))
     		     (or (null SrcCr) (zerop (length SrcCr)))
     		     (or (null DestAccount) (zerop (length DestAccount)))
     		     (or (null DstDr) (zerop (length DstDr)))
     		     (or (null DstCr) (zerop (length DstCr))))		     
	  (crm-journal-entry-with-drcr name description (parse-integer SourceAccount) (parse-integer DestAccount) (parse-integer SrcDr) (parse-integer SrcCr) (parse-integer DstDr) (parse-integer DstCr) (get-login-tenant-id) (get-login-userid)))		 	  
	(hunchentoot:redirect  "/crmindex"))
      (hunchentoot:redirect "/login")))


;; This is accounts dropdown
(defmacro accounts-dropdown (dropdown-name)
  `(cl-who:with-html-output (*standard-output* nil)
     (let ((accounts (list-crm-accounts (get-login-tenant-id))))
     (cl-who:htm (:select :name ',dropdown-name  
      (loop for acct in accounts
	 do (cl-who:htm  (:option :value  (slot-value acct 'row-id) (cl-who:str (slot-value acct 'name))))))))))

;; This is a text control with account dropdown and debit and credit text fields.
(defmacro drcr-entry-control (dropdown-name)
  `(cl-who:with-html-output (*standard-output* nil)
     (:p (:label :for ',dropdown-name "Account: ")
	 (let ((accounts (list-crm-accounts (get-login-tenant-id))))
	   (cl-who:htm (:select :name ',dropdown-name  
			 (loop for acct in accounts
			    do (cl-who:htm  (:option :value  (slot-value acct 'row-id)  (cl-who:str (slot-value acct 'name)))))))))

     (:p "Debit" (:input :type "text"  
			 :name ',(format nil "Debit-~A" dropdown-name)
			 :class "txt"))
     (:p "Credit" (:input :type "text"  
			  :name ',(format nil "Credit-~A" dropdown-name) 
			  :class "txt"))))




(defmacro journal-entry-details-buttons ()
  `(cl-who:with-html-output (*standard-output* nil)
     (:p (:input :type "submit"
		 
			       :value "Add" 
			       :class "btn")
(:input :type "submit" :value "Finalize" :class "btn")
(:ijput :type "cancel" :value "Cancel" :class "btn"))))





(defmacro journal-entry-page ()
  `(cl-who:with-html-output (*standard-output* nil)
     (:p "Source: " (drcr-entry-control "SourceAccount" ))
     (:p "Destination: " (drcr-entry-control "DestAccount"))
     (:p (journal-entry-details-buttons))))





