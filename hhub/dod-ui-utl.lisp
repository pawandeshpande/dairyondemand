(in-package :dairyondemand)

(defun print-web-session-timeout ()
    (let ((weseti ( get-web-session-timeout)))
	(if weseti (format t "Session will end at  ~2,'0d:~2,'0d:~2,'0d"
		       (nth 0  weseti)(nth 1 weseti) (nth 2 weseti)))))


(defun get-web-session-timeout ()
    (multiple-value-bind
	(second minute hour)
	(decode-universal-time (+ (get-universal-time) hunchentoot:*session-max-time*))
	(list hour minute second)))



(defmacro with-html-dropdown (name kvhash selectedkey)
`(cl-who:with-html-output (*standard-output* nil)
   (:select :class "form-control" :name ,name 
      (maphash (lambda (key value) 
		 (if (equal key  ,selectedkey) 
		     (htm (:option :selected "true" :value key (str value)))
		     ;else
		     (htm (:option :value key (str value))))) ,kvhash))))



(defun display-as-table (header data rowdisplayfunc) 
:documentation "This is a generic function which will display items in list as a html table. You need to pass the html table header and  list data, and a display function which will display data. It also supports search functionality by including the searchresult div. To implement the search functionality refer to livesearch examples. For tiles sizingrefer to style.css. " 
  (cl-who:with-html-output-to-string (*standard-output* nil)
    ; searchresult div will be used to store the search result. 
    (:div :id "searchresult" 
     (:table :class "table  table-striped  table-hover"
      (:thead (:tr
	(mapcar (lambda (item) (htm (:th (str item)))) header))) 
          (:tbody
	    (mapcar (lambda (item)
		      (htm (:tr (funcall rowdisplayfunc item))))  data))))))


(defun display-as-tiles (data displayfunc) 
:documentation "This is a generic function which will display items in list as tiles. You need to pass the list data, and a display function which will display 
individual tiles. It also supports search functionality by including the searchresult div. To implement the search functionality refer to livesearch examples. For tiles sizingrefer to style.css. " 
  (cl-who:with-html-output-to-string (*standard-output* nil)
    ; searchresult div will be used to store the search result. 
    (:div :id "searchresult" 
    (:div :class "row-fluid"  (mapcar (lambda (item)
					(htm (:div :class "col-sm-12 col-xs-12 col-md-6 col-lg-4" 
						    (funcall displayfunc item))))  data)))))


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


