;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
;; You must set these variables to appropriate values.
(defvar *crm-database-type* :odbc
  "Possible values are :postgresql :postgresql-socket, :mysql,
:oracle, :odbc, :aodbc or :sqlite")
(defvar *crm-database-name* "DAIRYONDEMAND"
  "The name of the database we will work in.")
(defvar *crm-database-user* "TESTCRMCORE"
  "The name of the database user we will work as.")
(defvar *crm-database-server* "localhost"
  "The name of the database server if required")
(defvar *crm-database-password* "TESTCRMCORE"
  "The password if required")
(defvar *dod-dbconn-spec* (list *crm-database-server* *crm-database-name* *crm-database-user* *crm-database-password*))


(defvar *HHUB-CUSTOMER-ORDER-CUTOFF-TIME* NIL)

(defvar *HHUB-EMAIL-CSS-FILE* "/data/www/highrisehub.com/public/css")
(defvar *HHUB-EMAIL-CSS-CONTENTS* NIL)
(defvar *HHUB-EMAIL-TEMPLATES-FOLDER* "~/dairyondemand/hhub/email/templates")
(defvar *HHUB-CUST-REG-TEMPLATE-FILE* "cust-reg.html")
(defvar *HHUB-CUST-PASSWORD-RESET-FILE* "cust-pass-reset.html")
(defvar *HHUB-CUST-TEMP-PASSWORD-FILE* "temppass.html")

(defvar *dod-db-instance*)
(defvar *sitepass* (encrypt "P@ssword1" "highrisehub.com"))
(defvar *current-customer-session* nil) 
(defvar *customer-page-title* nil) 
(defvar *vendor-page-title* nil) 
(defvar *admin-page-title* nil) 
(defvar *ABAC-ATTRIBUTE-NAME-PREFIX* "com.hhub.attribute.")
(defvar *ABAC-POLICY-NAME-PREFIX* "com.hhub.policy.")

(defvar *ABAC-TRANSACTION-NAME-PREFIX* "com.hhub.transaction.")
(defvar *ABAC-ATTRIBUTE-FUNC-PREFIX* "com-hhub-attribute-")
(defvar *ABAC-POLICY-FUNC-PREFIX* "com-hhub-policy-")
(defvar *ABAC-TRANSACTION-FUNC-PREFIX* "com-hhub-transaction-")
(defvar *PAYGATEWAYRETURNURL* "https://highrisehub.com/hhub/custpaymentsuccess")
(defvar *PAYGATEWAYCANCELURL* "https://highrisehub.com/hhub/custpaymentcancel")
(defvar *PAYGATEWAYFAILUREURL* "https://highrisehub.com/hhub/custpaymentfailure")
(defvar *HHUBRESOURCESDIR* "/data/www/highrisehub.com/public/img")
(defvar *HHUBDEFAULTPRDIMG* "HHubDefaultPrdImg.png")
(defvar *HHUBGLOBALLYCACHEDLISTSFUNCTIONS* NIL)
(defvar *HHUBGLOBALROLES* NIL) 
(defvar *HHUBFEATURESWISHLISTURL* "https://goo.gl/forms/hI9LIM9ebPSFwOrm1")
(defvar *HHUBBUGSURL* "https://goo.gl/forms/3iWb2BczvODhQiWW2") 
(defvar *HHUBCUSTLOGINPAGEURL* "/hhub/customer-login.html")
(defvar *HHUBVENDLOGINPAGEURL* "/hhub/vendor-login.html")
(defvar *HHUBOPRLOGINPAGEURL* "/hhub/opr-login.html")
(defvar *HHUBCADLOGINPAGEURL* "/hhub/cad-login.html")
(defvar *HHUBPASSRESETTIMEWINDOW* 20) ; 20 minutes. Depicts the reset password time window. 


(defun set-customer-page-title (name)
  (setf *customer-page-title* (format nil "Welcome to HighriseHub - ~A." name))) 
 
(defun set-vendor-page-title (name)
  (setf *vendor-page-title* (format nil "Welcome to HighriseHub - ~A." name))) 

(defun set-admin-page-title (name)
  (setf *admin-page-title* (format nil "Welcome to HighriseHub - ~A." name))) 


;; Connect to the database (see the CLSQL documentation for vendor
;; specific connection specs).

(defun crm-db-connect (&key strdb strusr strpwd servername strdbtype)
  :documentation "This function is responsibile for connecting to the CRM system. Arguments accepted are 
Database 
Username
Password 
Servername 
Database type: Supported type is ':odbc'"

  (progn 
    (case strdbtype
      ((:mysql :postgresql :postgresql-socket)
       (setf *dod-db-instance* (clsql:connect `(,servername
			,strdb
			,strusr
			,strpwd)
		      :database-type strdbtype)))
      ((:odbc :aodbc :oracle)
       (clsql:connect `(,strdb
			,strusr
			,strpwd)
		      :database-type strdbtype))
      (:sqlite
       (clsql:connect `(,strdb)
		      :database-type strdbtype)))

    (clsql:start-sql-recording)))



(defvar *http-server* nil)
(defvar *ssl-http-server* nil)
(defvar *dod-debug-mode* nil)
(defvar *dod-database-caching* nil)


(defun init-dairyondemand ()
  (cond  ((null *dod-debug-mode*) (setf *dod-database-caching* T))
	 (*dod-debug-mode* (setf *dod-database-caching* nil))
	 (T (setf *dod-database-caching* NIL))))


(defun start-das(&optional (withssl nil) (debug-mode T)  )
:documentation "Start dairyondemand server with or without ssl. If withssl is T, then start 
the hunchentoot server with ssl settings"
 
(setf *dod-debug-mode* debug-mode)
(setf *http-server* (make-instance 'hunchentoot:easy-acceptor :port 4244 :document-root #p"~/dairyondemand/"))
(setf (hunchentoot:acceptor-access-log-destination *http-server*)   #p"~/hhublogs/highrisehub-access.log")
(setf (hunchentoot:acceptor-message-log-destination *http-server*) #p"~/hhublogs/highrisehub-messages.log")

(progn (init-dairyondemand)
       (if withssl  (init-httpserver-withssl))
       (if withssl  (hunchentoot:start *ssl-http-server*) (hunchentoot:start *http-server*) )
       (crm-db-connect :servername *crm-database-server* :strdb *crm-database-name* :strusr *crm-database-user*  :strpwd *crm-database-password* :strdbtype :mysql)
       (setf *HHUBGLOBALLYCACHEDLISTSFUNCTIONS* (hhub-gen-globally-cached-lists-functions))
       (setf *HHUB-CUSTOMER-ORDER-CUTOFF-TIME* "23:00:00")))



(defun init-httpserver-withssl ()

;(ssl-accslogdest (hunchentoot:acceptor-access-log-destination *ssl-http-server* ))
;(ssl-msglogdest  (hunchentoot:acceptor-message-log-destination *ssl-http-server*)))

(progn 
  (setf *ssl-http-server* (make-instance 'hunchentoot:easy-ssl-acceptor :port 9443 
							  :document-root #p"~/dairyondemand/hhub/"
							  :ssl-privatekey-file #p"~/dairyondemand/privatekey.key"
							  :ssl-certificate-file #p"~/dairyondemand/certificate.crt" ))
  (setf (hunchentoot:acceptor-access-log-destination *ssl-http-server* )  #p"~/hhublogs/highrisehub-ssl-access.log")
       (setf  (hunchentoot:acceptor-message-log-destination *ssl-http-server*)   #p"~/hhublogs/highrisehub-ssl-messages.log")))



(defun stop-das ()
  (format t "******** Stopping SQL Recording *******~C"  #\linefeed)
  (clsql:stop-sql-recording :type :both)
  (format t "******** DB Disconnect ********~C" #\linefeed)
  (clsql:disconnect)
  (format t "******* Stopping HTTP Server *********~C"  #\linefeed)
(progn (if *ssl-http-server*  (hunchentoot:stop *ssl-http-server*) (hunchentoot:stop *http-server*))
(setf *ssl-http-server* nil) 
(setf *http-server* nil)
(setf *HHUBGLOBALLYCACHEDLISTSFUNCTIONS* NIL)))

;;;;*********** Globally Cached lists and their accessor functions *********************************

(defun hhub-gen-globally-cached-lists-functions ()
  :documentation "These functions are list returning functions. The various lists are accessible throughout the application. For example, list of all the authorization policies, attributes, etc."
  (let ((policies (get-system-auth-policies))
	(roles (get-system-roles))
	(transactions (get-system-bus-transactions)))
    (list (function (lambda () policies))
	  (function (lambda () roles))
	  (function (lambda () transactions)))))


(defun hhub-get-cached-auth-policies()
  :documentation "This function gets a list of all the globally cached policies."
  (let ((policiesfunc (first *HHUBGLOBALLYCACHEDLISTSFUNCTIONS*)))
    (funcall policiesfunc)))

(defun hhub-get-cached-roles ()
  :documentation "This function gets a list of all the globally cached roles."
  (let ((rolesfunc (nth 1 *HHUBGLOBALLYCACHEDLISTSFUNCTIONS*)))
    (funcall rolesfunc)))


(defun hhub-get-cached-transactions ()
  :documentation "This function gets a list of all the globally cached transactions."
  (let ((rolesfunc (nth 3 *HHUBGLOBALLYCACHEDLISTSFUNCTIONS*)))
    (funcall rolesfunc)))

