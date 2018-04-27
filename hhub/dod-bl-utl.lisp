;; -*- mode: common-lisp; coding: utf-8 -*-
(in-package :dairyondemand)

 


(defun get-ht-val (key hash-table)
    :documentation "If the key is found in the hash table, then return the value. Otherwise it returns nil in two cases. One- the key was present and value was nil. Second - key itself is not present"
  (multiple-value-bind (value present) (gethash key hash-table)
      (if present value )))

(defun parse-date-string (date)
  "Read a date string of the form \"DD/MM/YYYY\" and return the 
corresponding universal time."
  (let ((date (parse-integer date :start 0 :end 2))
        (month (parse-integer date :start 3 :end 5))
        (year (parse-integer date :start 6 :end 10)))
    (encode-universal-time 0 0 0 date month year)))



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
  
