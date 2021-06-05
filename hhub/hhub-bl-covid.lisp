(in-package :hhub)

(defclass coviddata (BusinessObject)
  ((centername)
   (vaccine)
   (dose1availability)
   (dose2availability)
   (pincode)
   (date)
   (minagelimit)
   (district_id)
   (phone)
   (sendsms)))
      
(defclass covid-details-by-pincode-service (BusinessService)
  ())

(defclass covid-details-by-district-service (BusinessService)
  ())


(defmethod doservice ((service covid-details-by-pincode-service) params)
  (let* ((repository (cdr (assoc "repository" params :test 'equal)))
	 (bo-key (cdr (assoc "bo-key" params :test 'equal)))
	 (bo-ht  (slot-value repository 'businessobjects))
	 (busobject (gethash bo-key bo-ht))
	 (pincode (slot-value busobject 'pincode))
	 (agelimit (slot-value busobject 'minagelimit))
	 (vaccine (slot-value busobject 'vaccine))
	 (sendsms (slot-value busobject 'sendsms))
	 (phone (slot-value busobject 'phone)))
    (if (and (equal sendsms "Y") pincode)
	(getcoviddetails pincode phone agelimit vaccine T)
	;;else
	(getcoviddetails pincode phone agelimit vaccine nil))))


(defmethod doservice ((service covid-details-by-district-service) params)
  (let* ((repository (cdr (assoc "repository" params :test 'equal)))
	 (bo-key (cdr (assoc "bo-key" params :test 'equal)))
	 (bo-ht  (slot-value repository 'businessobjects))
	 (busobject (gethash bo-key bo-ht))
	 (agelimit (slot-value busobject 'minagelimit))
	 (vaccine (slot-value busobject 'vaccine))
	 (districtid (slot-value busobject 'district_id))
	 (sendsms (slot-value busobject 'sendsms))
	 (phone (slot-value busobject 'phone)))

    (if (and
	 (equal sendsms "Y")
	 districtid)
	
	(getvaccineslotsbydistrict districtid agelimit vaccine phone T)
	;;else
	(getvaccineslotsbydistrict districtid agelimit vaccine phone nil))))


(defun hhub-controller-findvaccineslots-bypincode ()
  (let* ((sendsms (hunchentoot:parameter "sendsms"))
	 (phone (hunchentoot:parameter "phone"))
	 (agelimit (parse-integer (hunchentoot:parameter "agelimit")))
	 (vaccine (hunchentoot:parameter "vaccine"))
	 (pincode (hunchentoot:parameter "pincode"))
	 (coviddata (make-instance 'coviddata))
	 (bo-key (slot-value coviddata 'id))
	 (covid-repo (make-instance 'BusinessObjectRepository))
	 (service (make-instance 'covid-details-by-pincode-service))
	 (params nil))

    (setf (slot-value coviddata 'pincode) pincode)
    (setf (slot-value coviddata 'minagelimit) agelimit)
    (setf (slot-value coviddata 'vaccine) vaccine)
    (setf (slot-value coviddata 'phone) phone)
    (setf (slot-value coviddata 'sendsms) sendsms)
    (addBO covid-repo coviddata)
    (setf params (acons "repository" covid-repo params))
    (setf params (acons "bo-key" bo-key params))
    (doservice service params)))
    
(defun test-findvaccineslotsbypincode ()
  (let* ((coviddata (make-instance 'coviddata))
	 (bo-key (slot-value coviddata 'id))
	 (covid-repo (make-instance 'BusinessObjectRepository))
	 (service (make-instance 'covid-details-by-pincode-service))
	 (params nil))

    (setf (slot-value coviddata 'pincode) "560096")
    (setf (slot-value coviddata 'minagelimit) 45)
    (setf (slot-value coviddata 'vaccine) "COVISHIELD")
    (setf (slot-value coviddata 'phone) "9972022281")
    (setf (slot-value coviddata 'sendsms) nil)
    (addBO covid-repo coviddata)
    (setf params (acons "repository" covid-repo params))
    (setf params (acons "bo-key" bo-key params))
    (doservice service params)))
    


(defun hhub-controller-findvaccineslots-bydistrict ()
  (let* ((sendsms (hunchentoot:parameter "sendsms"))
	(phone (hunchentoot:parameter "phone"))
	(agelimit  (parse-integer (hunchentoot:parameter "agelimit")))
	(vaccine (hunchentoot:parameter "vaccine"))
	(districtid (hunchentoot:parameter "district_id"))
	(coviddata (make-instance 'coviddata))
	(bo-key (slot-value coviddata 'id))
	(covid-repo (make-instance 'BusinessObjectRepository))
	(service (make-instance 'covid-details-by-district-service))
	(params nil))

    (setf (slot-value coviddata 'district_id) districtid)
    (setf (slot-value coviddata 'minagelimit) agelimit)
    (setf (slot-value coviddata 'vaccine) vaccine)
    (setf (slot-value coviddata 'phone) phone)
    (setf (slot-value coviddata 'sendsms) sendsms)
    (addBO covid-repo coviddata)
    (setf params (acons "repository" covid-repo params))
    (setf params (acons "bo-key" bo-key params))
    (doservice service params)))


(defun test-findvaccineslotsbydistrict ()
  (let*  ((coviddata (make-instance 'coviddata))
	 (bo-key (slot-value coviddata 'id))
	 (covid-repo (make-instance 'BusinessObjectRepository))
	 (service (make-instance 'covid-details-by-district-service))
	 (params nil))

    (setf (slot-value coviddata 'district_id) "294")
    (setf (slot-value coviddata 'minagelimit) 45)
    (setf (slot-value coviddata 'vaccine) "COVISHIELD")
    (setf (slot-value coviddata 'phone) nil)
    (setf (slot-value coviddata 'sendsms) nil)
    (addBO covid-repo coviddata)
    (setf params (acons "repository" covid-repo params))
    (setf params (acons "bo-key" bo-key params))
    (doservice service params)))



  


(defun getvaccineslotsbydistrict (districtid  &optional (agelimit 45) (vaccine "COVISHIELD") (phone nil) (sendsms nil))
  (let* ((mylist '())
	 (reqheadername (list  "Accept-Language"))
	 (requesturi "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict")
	 (reqheadervalue (list  "hi_IN"))
	 (param-name (list "district_id" "date"))
	 (param-values (list (format nil "~A" districtid) (format nil "~A" (current-date-string-ddmmyyyy))))
	 (param-alist (pairlis param-name param-values ))
	 (reqheaders-alist (pairlis reqheadername reqheadervalue))
	 (json-response (json:decode-json-from-string (map 'string 'code-char (drakma:http-request requesturi
												    :method :GET
												    :user-agent :FIREFOX
												    :close nil
												    :parameters param-alist
												    :protocol :http/1.1
												    :accept "application/json, text/plain, */*"
												    
												    :additional-headers reqheaders-alist

												    ))))
	  (covidcenters (nth 0 json-response))
	  (covidcenters (remove (nth 0 covidcenters) covidcenters))
	  (finallist (remove nil (mapcar
				  (lambda (covidcenter)
				    (let* ((templist '())
					   (appendlist '())
					   (centername  (cdr (assoc :NAME covidcenter :test 'equal)))
					   (dose1 (cdr (assoc :AVAILABLE--CAPACITY--DOSE-1 covidcenter :test 'equal)))
					   (dose2 (cdr (assoc :AVAILABLE--CAPACITY--DOSE-2 covidcenter :test 'equal)))
					   (minagelimit (cdr (assoc :MIN--AGE--LIMIT covidcenter :test 'equal)))
					   (vac (cdr (assoc :VACCINE covidcenter :test 'equal))))
				      ;; (format t "Centername - ~A ~C~C" centername #\return #\linefeed)
				      (if (and
					   (equal vaccine vac)
					   (= agelimit minagelimit)
					   (> dose1 5))
					  
					  (progn
					    (if (and phone sendsms)
						(progn
						  (send-sms-notification phone "HHUB" (format nil "[HIGHRISEHUB] ~d Dose1 of ~A are available in ~A." dose1 vaccine centername))
						  (sleep 2)))
					    (setf templist (acons "centername" (format nil "~A" centername) templist))
					    (setf templist (acons "vaccine" (format nil "~A" vaccine) templist))
					    (setf templist (acons "agelimit" (format nil "~A" minagelimit) templist))
					    (setf templist (acons "dose1" (format nil "~A" dose1) templist))
					    (setf templist (acons "dose2" (format nil "~A" dose2) templist))
					    (setf appendlist (append appendlist (list templist)))
					    appendlist)))) covidcenters))))

    ;; Send the response data
    (setf mylist (acons "result" finallist mylist))
    (setf mylist (acons "success" 1 mylist))
    (json:encode-json-to-string mylist)))




(defun getcoviddetails (pincode  &optional (agelimit 45) (vaccine "COVISHIELD") (phone nil) (sendsms nil))
  (let* ((mylist '())
	 (reqheadername (list  "Accept-Language"))
	 (reqheadervalue (list  "hi_IN"))
	 (requesturi "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin" )
	 (param-name (list "pincode" "date"))
	 (param-values (list (format nil "~A" pincode) (format nil "~A" (current-date-string-ddmmyyyy))))
	 (param-alist (pairlis param-name param-values ))
	 (reqheaders-alist (pairlis reqheadername reqheadervalue))
	
	 (json-response (json:decode-json-from-string (map 'string 'code-char (drakma:http-request requesturi
												    :method :GET
												    :user-agent :FIREFOX
												    :close nil
												    :parameters param-alist
												    :protocol :http/1.1
												    :accept "application/json, text/plain, */*"
												    
												    :additional-headers reqheaders-alist

												    ))))
	 (covidcenters (nth 0 json-response))
	 (covidcenters (remove (nth 0 covidcenters) covidcenters))
	 (finallist (remove nil (mapcar (lambda (covidcenter)
			      (let* ((templist '())
				     (appendlist '())
				     (centername  (cdr (assoc :NAME covidcenter :test 'equal)))
				     (sessions (nth 12 covidcenter))
				     (sessions (remove (nth 0 sessions) sessions)))
				
				;;(format t "searching pincode : ~A. Centername - ~A ~C~C" pincode centername #\return #\linefeed)
				;;(format t "center data : ~A" covidcenter)
				(loop for session in sessions do
				  (let ((date (cdr (assoc :DATE session :test 'equal)))
					(dose1 (cdr (assoc :AVAILABLE--CAPACITY--DOSE-1 session :test 'equal)))
					(dose2 (cdr (assoc :AVAILABLE--CAPACITY--DOSE-2 session :test 'equal)))
					(minagelimit (cdr (assoc :MIN--AGE--LIMIT session :test 'equal)))
					(vac (cdr (assoc :VACCINE  session :test 'equal))))
				    (if (and
					 (equal vac vaccine)
					 (= minagelimit agelimit)
					 (> dose1 5))
					(progn
					  ;;(format t "~A: ~d doses of ~A are available in ~A.~C~C" pincode availability vaccine centername  #\return #\linefeed)
					  (if (and phone sendsms)
					      (progn
						(send-sms-notification phone "HHUB" (format nil "[HIGHRISEHUB] ~d dose1 of ~A are available in ~A." dose1 vaccine centername))
						(sleep 1)))
					  (setf templist (acons "centername" (format nil "~A" centername) templist))
					  (setf templist (acons "date" (format nil "~A" date) templist))
					  (setf templist (acons "vaccine" (format nil "~A" vaccine) templist))
					  (setf templist (acons "dose1" (format nil "~A" dose1) templist))
					  (setf templist (acons "dose2" (format nil "~A" dose2) templist))
					  (setf appendlist (append appendlist (list templist)))))))
				(setf templist nil)
				appendlist)) covidcenters))))
		    
		    (setf mylist (acons "result" finallist mylist))
		    (setf mylist (acons "success" 1 mylist))
		    (json:encode-json-to-string mylist)))
