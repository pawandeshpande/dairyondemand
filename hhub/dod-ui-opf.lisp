;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)


(defun dod-controller-list-orderprefs ()
(if (is-dod-session-valid?)
   (let (( dodorderprefs (get-opreflist-by-company  (get-login-company)))
	 (header (list  "Sl No" "Customer" "Product" "Product Qty" "Action")))
     (if dodorderprefs (ui-list-orderprefs header dodorderprefs) "No Order Prefernces"))
   (hunchentoot:redirect "/customer-login.html")))


(defun cust-opf-as-row (orderpref)
  (let ((opf-id (slot-value orderpref 'row-id))
	(opf-product (get-opf-product orderpref)))
    (cl-who:with-html-output (*standard-output* nil)
      (:td  :height "12px" (str (slot-value opf-product  'prd-name)))
	  (:td :height "12px"    (str (if (equal (slot-value orderpref 'sun) "Y") "Su, "))
	       (str (if (equal (slot-value orderpref 'mon) "Y") "Mo, "))
	       (str (if (equal (slot-value orderpref 'tue) "Y")  "Tu, "))
	       (str (if (equal (slot-value orderpref 'wed) "Y") "We, "))
	       (str (if (equal (slot-value orderpref 'thu) "Y")  "Th, "))
	       (str (if (equal (slot-value orderpref 'fri) "Y") "Fr, "))
	       (str (if (equal (slot-value orderpref 'sat) "Y")  "Sa ")))
	  (:td  :height "12px" (str (slot-value orderpref 'prd-qty)))
	  (:td  :height "12px" (str (slot-value opf-product  'qty-per-unit)))
	  (:td  :height "12px" (str (format nil "Rs. ~$"  (slot-value opf-product  'unit-price))))     
	  (:td :height "12px" (:a  :onclick "return DeleteConfirm();" :href  (format nil  "delopref?id=~A" opf-id ) (:span :class "glyphicon glyphicon-remove"))))))
  
  

