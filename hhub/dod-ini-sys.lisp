;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)
;; You must set these variables to appropriate values.
(defvar *crm-database-type* :odbc
  "Possible values are :postgresql :postgresql-socket, :mysql,
:oracle, :odbc, :aodbc or :sqlite")
(defvar *crm-database-name* "dairyondemand"
  "The name of the database we will work in.")
(defvar *crm-database-user* "TestCRMCore"
  "The name of the database user we will work as.")
(defvar *crm-database-server* "localhost"
  "The name of the database server if required")
(defvar *crm-database-password* "TestCRMCore"
  "The password if required")


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
       (clsql:connect `(,servername
			,strdb
			,strusr
			,strpwd)
		      :database-type strdbtype))
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
       ( *dod-debug-mode* (setf *dod-database-caching* nil))
       (T (setf *dod-database-caching* NIL))))


(defun start-das(&optional (withssl nil) (debug-mode T)  )
:documentation "Start dairyondemand server with or without ssl. If withssl is T, then start 
the hunchentoot server with ssl settings"
 
(setf *dod-debug-mode* debug-mode)
(setf *http-server* (make-instance 'hunchentoot:easy-acceptor :port 4244 :document-root #p"~/dairyondemand/"))
(setf (hunchentoot:acceptor-access-log-destination *http-server*)   #p"~/dairyondemand/hhub/logs/dairyondemand-access.log")
(setf (hunchentoot:acceptor-message-log-destination *http-server*) #p"~/dairyondemand/hhub/logs/dairyondemand-messages.log")

(progn (init-dairyondemand)
       (if withssl  (init-httpserver-withssl))
       (if withssl  (hunchentoot:start *ssl-http-server*) (hunchentoot:start *http-server*) )
       (crm-db-connect :servername "localhost" :strdb "DAIRYONDEMAND" :strusr "TestCRMCore" :strpwd "TestCRMCore" :strdbtype :mysql)))



(defun init-httpserver-withssl ()

;(ssl-accslogdest (hunchentoot:acceptor-access-log-destination *ssl-http-server* ))
;(ssl-msglogdest  (hunchentoot:acceptor-message-log-destination *ssl-http-server*)))

(progn 
  (setf *ssl-http-server* (make-instance 'hunchentoot:easy-ssl-acceptor :port 9443 
							  :document-root #p"~/dairyondemand/hhub/"
							  :ssl-privatekey-file #p"~/dairyondemand/privatekey.key"
							  :ssl-certificate-file #p"~/dairyondemand/certificate.crt" ))
  (setf (hunchentoot:acceptor-access-log-destination *ssl-http-server* )  #p"~/dairyondemand/logs/dairyondemand-ssl-access.log")
       (setf  (hunchentoot:acceptor-message-log-destination *ssl-http-server*)   #p"~/dairyondemand/logs/dairyondemand-ssl-messages.log")))



(defun stop-das ()
  (format t "******** Stopping SQL Recording *******~C"  #\linefeed)
  (clsql:stop-sql-recording :type :both)
  (format t "******** DB Disconnect ********~C" #\linefeed)
  (clsql:disconnect)
  (format t "******* Stopping HTTP Server *********~C"  #\linefeed)
(progn (if *ssl-http-server*  (hunchentoot:stop *ssl-http-server*) (hunchentoot:stop *http-server*))
(setf *ssl-http-server* nil) 
(setf *http-server* nil))
)




