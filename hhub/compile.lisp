(in-package :cl-user)
(defun compile-hhub-files ()
  (let ((filelist (list 
		   "packages.lisp"
		   "secretkeys.lisp"

		   ;;;;;;;;;;;;;;;;;; Init data

;;;;;;;;;; Utilities
		    "dod-bl-utl.lisp"
		    "dod-ui-utl.lisp"
		    "dod-ini-sys.lisp"
		   ;;;;;;;;;;;;;;; DATA ACCESS LAYER 
		    "hhub-bl-ent.lisp"
		    "dod-dal-push.lisp"
		    "dod-dal-bo.lisp"
		    "dod-dal-cmp.lisp"
		    "dod-dal-cus.lisp"
		    "dod-dal-odt.lisp"
		    "dod-dal-opf.lisp"
		    "dod-dal-ord.lisp"
		    "dod-dal-otk.lisp"
		    "dod-dal-oty.lisp"
		    "dod-dal-pas.lisp"
		    "dod-dal-pay.lisp"
		    "dod-dal-pol.lisp"
		    "dod-dal-prd.lisp"
		    "dod-dal-rol.lisp"
		    "dod-dal-usr.lisp"
		    "dod-dal-vad.lisp"
		    "dod-dal-vas.lisp"
		    "dod-dal-ven.lisp"
		    "dod-dal-vnd.lisp"
		    "dod-dal-act.lisp"
;;;;;;;;;;;;;;; BUSINESS LAYER
		    "dod-bl-push.lisp" 
		    "dod-bl-bo.lisp"
		    "dod-bl-cmp.lisp"
		    "dod-bl-cus.lisp"
		    "dod-bl-odt.lisp"
		    "dod-bl-opf.lisp"
		    "dod-bl-ord.lisp"
		    "dod-bl-pas.lisp"
		    "dod-bl-pay.lisp"
		    "dod-bl-pol.lisp"
		    "dod-bl-prd.lisp"
		    "dod-bl-rol.lisp"
		    "dod-bl-usr.lisp"
		    "dod-bl-vad.lisp"
		    "dod-bl-vas.lisp"
		    "dod-bl-ven.lisp"
		  ;  "dod-seed-data.lisp"
		    "dod-test-ord.lisp"
		    "dod-bl-err.lisp"
		    "dod-bl-sys.lisp"
		    
;;;;;;;;;;;;;; UI LAYER
		    "dod-ui-push.lisp" 
		    "dod-ui-act.lisp"
		    "dod-ui-attr.lisp"
		    "dod-ui-cad.lisp"
		    "dod-ui-cmp.lisp"
		    "dod-ui-cus.lisp"
		    "dod-ui-odt.lisp"
		    "dod-ui-opf.lisp"
		    "dod-ui-ord.lisp"
		    "dod-ui-oty.lisp"
		    "dod-ui-pay.lisp"
		    "dod-ui-pol.lisp"
		    "dod-ui-prd.lisp"
		    "dod-ui-rol.lisp"
		    "dod-ui-sys.lisp"
		    "dod-ui-usr.lisp"
		    "dod-ui-vad.lisp"
		    "dod-ui-ven.lisp"
		    "dod-ui-site.lisp"
		  ;  "unit-tests.lisp"
		    "/email/templates/registration.lisp"))
	
(path "~/dairyondemand/hhub/"))

(mapcar (lambda (file)
	  (compile-file  (concatenate 'string path file) :verbose *compile-verbose*)) filelist)))
