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




