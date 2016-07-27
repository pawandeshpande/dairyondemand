
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
(defvar *dod-debug-mode* nil)
(defvar *dod-database-caching* nil)

(defun init-dairyondemand ()
  (cond  (*dod-debug-mode* (setf *dod-database-caching* NIL))
       ( (not *dod-debug-mode*) (setf *dod-database-caching* T))
       (T (setf *dod-database-caching* NIL))))


(defun start-dairyondemand () 
(setf *dod-debug-mode* T)
  (setf *js-string-delimiter* #\")
  (setf  *http-server* (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4243 :document-root #p"~/dairyondemand/")))
(setf (hunchentoot:acceptor-access-log-destination *http-server* ) #p"~/dairyondemand-access.log")
(setf (hunchentoot:acceptor-message-log-destination *http-server*) #p"~/dairyondemand-messages.log")
(progn (init-dairyondemand) 
  (crm-db-connect :strdb "dairyondemand" :strusr "TestCRMCore" :strpwd "TestCRMCore" :strdbtype :odbc))

;(defparameter *ACCOUNT-BC* (make-instance 'crm-business-component
;		 :name "Account"
;		 :persistance-class (type-of 'crm-account)
;		 :can-delete? t))
)

(defun shutdown-dairyondemand ()
  (format t "******** Stopping SQL Recording *******~C"  #\linefeed)
  (clsql:stop-sql-recording :type :both)
  (format t "******** DB Disconnect ********~C" #\linefeed)
  (clsql:disconnect)
  (format t "******* Stopping HTTP Server *********~C"  #\linefeed)
  (hunchentoot:stop *http-server*)
)




