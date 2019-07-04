(in-package :hhub)




(defun dod-controller-password-reset-mail-sent ()
(with-standard-customer-page 
    (:div :class "row" 
	  (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		(with-html-form "form-customerchangepin" "hhubcustpassreset"  
					;(:div :class "account-wall"
		  (:h1 :class "text-center login-title"  "Password Reset Email Sent."))))))
  

(defun dod-controller-invalid-email-error ()
  (with-standard-customer-page 
    (:div :class "row" 
	  (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		(with-html-form "form-customerchangepin" "hhubcustpassreset"  
					;(:div :class "account-wall"
		  (:h1 :class "text-center login-title"  "Invalid Customer Email."))))))
		  


(defun dod-controller-password-reset-token-expired ()
  (with-standard-customer-page 
    (:div :class "row" 
	  (:div :class "col-xs-12 col-sm-12 col-md-12 col-lg-12"
		(with-html-form "form-customerchangepin" "hhubcustpassreset"  
					;(:div :class "account-wall"
		  (:h1 :class "text-center login-title"  "Your password reset time window has expired. Please try again." ))))))
		  



(defun hhubsendmail (to subject body &optional attachments-list)
(let ((username *HHUBSMTPUSERNAME*) 
      (password  *HHUBSMTPPASSWORD*))  

 (cl-smtp:send-email *HHUBSMTPSERVER*
  *HHUBSMTPSENDER* to 
  subject "Ok, the HTML version of this email is totally impressive. Just trust me on this." 
  :authentication (list :login username password) 
  :ssl
  :tls
  :html-message body
  :display-name subject
  :attachments attachments-list)))



(defun hhubsendmail-test (to subject body &optional attachments-list)
(let ((username *HHUBSMTPUSERNAME*) 
      (password  *HHUBSMTPPASSWORD*)) 
  (cl-smtp:send-email *HHUBSMTPSERVER*
		      *HHUBSMTPTESTSENDER* to 
		      subject "Ok, the HTML version of this email is totally impressive. Just trust me on this." 
		      :authentication (list :login username password) 
		      :ssl
		      :tls
		      :html-message body
		      :display-name subject
		      :attachments attachments-list)))




(defmacro with-html-email ( &body body)
 `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
    (:html 
     (:body
       (:img :class "profile-img" :src "https://highrisehub.com/img/logo.png" :alt "Welcome to Highrisehub.com")
       (:p
	,@body)))))


(defmacro with-standard-page-template ((&key title nav-func)  &body body)
 `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	 (:html  :xmlns "http://www.w3.org/1999/xhtml"
	     :xml\:lang "en" 
	     :lang "en"
	     (:head 
		 (:meta :http-equiv "content-type" 
		     :content    "text/html;charset=utf-8")
		 (:meta :name "viewport" :content "width=device-width,user-scalable=no")
		 (:meta :names "description" :content "")
		 (:meta :name "author" :content "")
		 (:link :rel "icon" :href "/favicon.ico")
		 (:title ,title )
		 (:link :href "/css/style.css" :rel "stylesheet")
		 (:link :href "/css/bootstrap.min.css" :rel "stylesheet")
		 (:link :href "/css/bootstrap-theme.min.css" :rel "stylesheet")
		 (:link :href "https://code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css" :rel "stylesheet")
		 (:link :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" :rel "stylesheet")
		 (:link :href "/css/theme.css" :rel "stylesheet")
		 ;; js files
		 (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js")
		 (:script :src "https://code.jquery.com/ui/1.12.0/jquery-ui.min.js")
		 (:script :src "/js/spin.min.js")
		 (:script :src "https://www.google.com/recaptcha/api.js")
		 (:script :src "https://cdnjs.com/libraries/1000hz-bootstrap-validator")
		 ) ;; header completes here.
	     (:body
		 (:div :id "dod-main-container"
		     (:a :href "#" :class "scrollup" :style "display: none;") 
		 (:div :id "dod-error" (:h2 "error..."))
		 (:div :id "busy-indicator")
		 (:script :src "/js/hhubbusy.js")
		 (if hunchentoot:*session* (,nav-func)) 
		 ;(if (is-dod-cust-session-valid?) (with-customer-navigation-bar))
		 (:div :class "container theme-showcase" :role "main" 
		   (:div :id "header"  ,@body))
		       		 ;; rangeslider
		 ;; bootstrap core javascript
		 (:script :src "/js/bootstrap.min.js")
		  (:script :src "/js/dod.js"))))))

(defmacro with-standard-customer-page (&body body)
`(with-standard-page-template (:title "Welcome Customer" :nav-func with-customer-navigation-bar )  ,@body))

(defmacro with-standard-vendor-page (&body body)
  `(with-standard-page-template (:title "Welcome Vendor" :nav-func with-vendor-navigation-bar )  ,@body))

(defmacro with-standard-admin-page (&body body)
  `(with-standard-page-template (:title "Welcome System Administrator" :nav-func with-admin-navigation-bar )  ,@body))

(defmacro with-standard-compadmin-page (&body body)
  `(with-standard-page-template (:title "Welcome Company Administrator" :nav-func with-compadmin-navigation-bar )  ,@body))



(defun print-thread-info ()
:description "This function prints information about all threads" 
      (let* ((curr-thread (bt:current-thread))
             (curr-thread-name (bt:thread-name curr-thread))
             (all-threads (bt:all-threads))
	     (tc (length all-threads)))
        (format t "Current thread: ~a~%~%" curr-thread)
        (format t "Current thread name: ~a~%~%" curr-thread-name)
        (format t "All threads:~% ~{~a~%~}~%" all-threads)
	(format t "Threads count: ~a" tc)) 
      nil)



(defun print-web-session-timeout ()
    (let ((weseti ( get-web-session-timeout)))
	(if weseti (format t "Session will end at  ~2,'0d:~2,'0d:~2,'0d"
		       (nth 0  weseti)(nth 1 weseti) (nth 2 weseti)))))


(defun get-web-session-timeout ()
    (multiple-value-bind
	(second minute hour)
	(decode-universal-time (+ (get-universal-time) hunchentoot:*session-max-time*))
	(list hour minute second)))






(defmacro with-cust-session-check (&body body)
   `(if hunchentoot:*session* ,@body 
	;else 
  (hunchentoot:redirect *HHUBCUSTLOGINPAGEURL*)))

(defmacro with-vend-session-check (&body body)
   `(if hunchentoot:*session* ,@body 
	;else 
  (hunchentoot:redirect *HHUBVENDLOGINPAGEURL*)))

(defmacro with-opr-session-check (&body body)
    `(if hunchentoot:*session* ,@body 
	;else 
  (hunchentoot:redirect *HHUBOPRLOGINPAGEURL*)))

(defmacro with-cad-session-check (&body body)
 `(if hunchentoot:*session* ,@body 
	;else 
  (hunchentoot:redirect *HHUBCADLOGINPAGEURL*)))

(defmacro with-hhub-transaction (name &optional params &body body)
`(let ((transaction (select-bus-trans-by-trans-func ,name)))
   (if (has-permission transaction ,params) 
       ,@body
      ;else
       "Permission Denied")))

; Policy Enforcement Point for HHUB
(defmacro with-hhub-pep (name subject resource action env &body body)
`(let* ((transaction (select-bus-trans-by-trans-func ,name))
       (policy-id (slot-value transaction 'auth-policy-id)))
   (if (has-permission1 policy-id ,subject ,resource ,action ,env) 
       ,@body
       ;else 
      "Permission Denied")))



(defmacro with-html-dropdown (name kvhash selectedkey)
`(cl-who:with-html-output (*standard-output* nil)
   (:select :class "form-control" :name ,name 
      (maphash (lambda (key value) 
		 (if (equal key  ,selectedkey) 
		     (htm (:option :selected "true" :value key (str value)))
		     ;else
		     (htm (:option :value key (str value))))) ,kvhash))))



(defun display-as-table (header listdata rowdisplayfunc) 
:documentation "This is a generic function which will display items in list as a html table. You need to pass the html table header and  list data, and a display function which will display data. It also supports search functionality by including the searchresult div. To implement the search functionality refer to livesearch examples. For tiles sizing refer to style.css. " 
(let ((incr (let ((count 0)) (lambda () (incf count)))))
(cl-who:with-html-output-to-string (*standard-output* nil)
    (:table :class "table  table-striped  table-hover"
      (:thead (:tr
	(:th "No")
	       (mapcar (lambda (item) (htm (:th (str item)))) header))) 
          (:tbody
	    (mapcar (lambda (item)
		      (htm (:tr (:td (str (funcall incr))) (funcall rowdisplayfunc item))))  listdata))))))

;; Can this function be converted into a macro?
(defun display-as-tiles (listdata displayfunc) 
:documentation "This is a generic function which will display items in list as tiles. You need to pass the list data, and a display function which will display 
individual tiles. It also supports search functionality by including the searchresult div. To implement the search functionality refer to livesearch examples. For tiles sizingrefer to style.css. " 
  (cl-who:with-html-output-to-string (*standard-output* nil)
    ; searchresult div will be used to store the search result. 
    (:div :id "searchresult" 
    (:div :class "row-fluid"  (mapcar (lambda (item)
					(htm (:div :class "col-xs-12 col-sm-6 col-md-4 col-lg-4" 
						    (funcall displayfunc item))))  listdata)))))




(defmacro with-html-search-form (search-form-action search-placeholder &body body) 
:documentation "Arguments: search-form-action - the form's action, search-placeholder - placeholder for search text box, body - any additional hidden form input elements"  
`(cl-who:with-html-output (*standard-output* nil ) 
    (:form :id "theForm" :name "theForm" :method "POST" :action ,search-form-action :onSubmit "return false"
     (:div :class "row" 
      (:div :class "col-lg-6 col-md-6 col-sm-12 col-xs-12" 
       (:div :class "input-group"
	(:input :type "text" :name "livesearch" :id "livesearch"  :class "form-control" :placeholder ,search-placeholder)
	,@body
	(:span :class "input-group-btn" (:button :class "btn btn-primary" :type "submit" "Go!" ))))))
    (:div :id "searchresult")))

     
(defmacro with-html-form ( form-name form-action  &body body) 
:documentation "Arguments: form-action - the form's action, body - any additional hidden form input elements"  
`(cl-who:with-html-output (*standard-output* nil) 
    (:form :id "theForm" :name ,form-name  :method "POST" :action ,form-action :data-toggle "validator" 
,@body)))



 

(defun copy-hash-table (hash-table)
  (let ((ht (make-hash-table 
             :test (hash-table-test hash-table)
             :rehash-size (hash-table-rehash-size hash-table)
             :rehash-threshold (hash-table-rehash-threshold hash-table)
             :size (hash-table-size hash-table))))
    (loop for key being each hash-key of hash-table
       using (hash-value value)
       do (setf (gethash key ht) value)
       finally (return ht))))


(defmacro modal-dialog (id title &rest body )
:documentation "This macro returns the html text for generating a modal dialog using bootstrap."
`(cl-who:with-html-output (*standard-output* nil)
 (:div :class "modal fade" :id ,id :role "dialog"
       (:div :class "modal-dialog" 
	     (:div :class "modal-content" 
		   (:div :class "modal-header" 
			 (:button :type "button" :class "close" :data-dismiss "modal") 
			 (:h4 :class "modal-title" ,title))
		   (:div :class "modal-body" ,@body)
		   (:div :class "modal-footer" 
			 (:button :type "button" :class "btn btn-default" :data-dismiss "modal" "Close")))))))


