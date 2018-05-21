;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :dairyondemand)

 


(defun get-ht-val (key hash-table)
    :documentation "If the key is found in the hash table, then return the value. Otherwise it returns nil in two cases. One- the key was present and value was nil. Second - key itself is not present"
  (multiple-value-bind (value present) (gethash key hash-table)
      (if present value )))

(defun parse-date-string (datestr)
  "Read a date string of the form \"DD/MM/YYYY\" and return the 
corresponding universal time."
  (let ((date (parse-integer datestr :start 0 :end 2))
        (month (parse-integer datestr :start 3 :end 5))
        (year (parse-integer datestr :start 6 :end 10)))
    (encode-universal-time 0 0 0 date month year)))

(defun parse-time-string (timestr)
  :documentation "Read a time string of the form \"HH:MM:SS\" and return the corresponding universal time"
 (let ((hour (parse-integer timestr :start 0 :end 2))
       (minute (parse-integer timestr :start 3 :end 5))
       (second (parse-integer timestr :start 6 :end 8)))
   (encode-universal-time second minute hour 1 1 0)))

(defun current-time-string ()
  "Returns current time  as a string in HH:MM:SS  format"
  (multiple-value-bind (sec min hr day mon yr dow dst-p tz)
                       (get-decoded-time)
    (declare (ignore day mon yr dow dst-p tz))
      (format nil "~2,'0d:~2,'0d:~2,'0d" hr min  sec)))


(defun get-date-from-string (datestr)
    :documentation  "Read a date string of the form \"DD/MM/YYYY\" and return the corresponding date object."
(if (not (equal datestr ""))
(let ((date (parse-integer datestr :start 0 :end 2))
        (month (parse-integer datestr :start 3 :end 5))
        (year (parse-integer datestr :start 6 :end 10)))
    (make-date :year year :month month :day date :hour 0 :minute 0 :second 0 ))))

(defun current-date-string ()
  "Returns current date as a string in YYYY/MM/DD format"
  (multiple-value-bind (sec min hr day mon yr dow dst-p tz)
                       (get-decoded-time)
    (declare (ignore sec min hr dow dst-p tz))
      (format nil "~4,'0d/~2,'0d/~2,'0d" yr mon day)))

(defun get-date-string (dateobj)
  "Returns current date as a string in DD/MM/YYYY format."
  (multiple-value-bind (yr mon day)
                       (date-ymd dateobj)  (format nil "~2,'0d/~2,'0d/~4,'0d" day mon yr)))


(defun get-date-string-mysql (dateobj) 
  "Returns current date as a string in DD-MM-YYYY format."
  (multiple-value-bind (yr mon day)
                       (date-ymd dateobj)  (format nil "~4,'0d-~2,'0d-~2,'0d 00:00:00" yr mon day)))



(defun test-alist ( amount salt )
  (let* (
	 (description "This is test description")
	 (order-id "testorder1234")
	 (mode "TEST")
	 (currency "INR")
	 (customer-name "Test customer")
	 (customer-email "pawan.deshpande@gmail.com")
	 (customer-phone "+919972022281")
	 (customer-city "Bangalore")
	 (customer-country "India")
	 (customer-zipcode "560096")
	 (return-url "http://www.highrisehub.com/hhub/paymentsuccessful")
	 (msg (concatenate 'string  salt ""))
	 (param-names (list "amount" "api_key" "city" "country" "currency" "description" "email" "mode" "name" "order_id" "phone" "return_url" "zip_code"))
	 (param-values (list amount *PAYMENTAPIKEY* customer-city customer-country currency description customer-email mode customer-name order-id  customer-phone return-url customer-zipcode))
	 (params-alist (pairlis param-names param-values)))
	
    



    (setf param-names (sort param-names  #'string-lessp))
    
    (loop for item in param-names do 
	 (let ((str (find item params-alist :test #'equal :key #'car )))
	   (setf msg (concatenate 'string msg  "|" (cdr str)))))
    msg))

    


(defun generatehashkey (params-alist salt hashmethod)
  (let* ((msg salt)
	(param-names (mapcar (lambda (param) 
				(car param)) params-alist)))
    (setf param-names (sort param-names  #'string-lessp))
    (loop for item in param-names do 
	 (let ((str (find item params-alist :test #'equal :key #'car)))
	 (setf msg (concatenate 'string msg "|" (cdr str)))))
    (string-upcase (ironclad:byte-array-to-hex-string 
     (ironclad:digest-sequence
      hashmethod
      (ironclad:ascii-string-to-byte-array msg))))))


(defun responsehashcheck (params-alist salt hashmethod)
  (let* ((received-hash (cdr (find "hash" params-alist :test #'equal :key #'car)))
	 (params-alist (remove (find "hash" params-alist :test #'equal :key #'car) params-alist))
	 (newhash (generatehashkey params-alist salt hashmethod)))
    (equal newhash received-hash)))
    
	

(defun get-cipher (salt)
  (ironclad:make-cipher :blowfish
    :mode :ecb
    :key (ironclad:ascii-string-to-byte-array salt)))

(defun encrypt (plaintext salt)
  (let ((cipher (get-cipher salt))
        (msg (ironclad:ascii-string-to-byte-array plaintext)))
    (ironclad:encrypt-in-place cipher msg)
    (flexi-streams:octets-to-string  msg)))


(defun decrypt (ciphertext key)
  (let ((cipher (get-cipher key))
        (msg (ironclad:integer-to-octets (ironclad:octets-to-integer (ironclad:ascii-string-to-byte-array ciphertext)))))
    (ironclad:decrypt-in-place cipher msg)
    (coerce (mapcar #'code-char (coerce msg 'list)) 'string)))

(defun check-password (plaintext salt ciphertext)
  (if (equal (encrypt plaintext salt) ciphertext) T NIL)) 





;;;; Virtual host related things ;;;; 
  
