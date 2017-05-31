
;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-
;;; $Header: dod-system.asd,v 1.6 2016/01/26 18:31:03 

;;; Copyright (c) 2015-2016, Pawan Deshpande.  All rights reserved.

;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:

;;;   * Redistributions of source code must retain the above copyright
;;;     notice, this list of conditions and the following disclaimer.

;;;   * Redistributions in binary form must reproduce the above
;;;     copyright notice, this list of conditions and the following
;;;     disclaimer in the documentation and/or other materials
;;;     provided with the distribution.

;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
;;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(asdf:defsystem #:dairyondemand
  :serial t
  :description "Dairy ondemand is an application to calculate demand for dairy in an apartment. It can be extended to more than one apartment in a city or vendors can register their own areas as supply areas. Backend is MYSQL database and it is a web application."
  :author "Pawan Deshpande <pawan.deshpande@gmail.com>"
  :license "THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS"
    :version "0.0.1"

  :components ((:file "packages")
		  (:file "dod-ui-utl" :depends-on ("packages") )
		  (:file "dod-bl-utl")
		  (:file "dod-ui-sys" :depends-on ("packages") )
	       (:file "dod-ui-usr" :depends-on ("packages") )
	       (:file "dod-bl-usr" :depends-on ("packages") )
		  (:file "dod-dal-usr" :depends-on ("packages"))
		  (:file "dod-ui-cus":depends-on ("packages") )
	       (:file "dod-bl-cus" :depends-on ("packages") )
	       (:file "dod-dal-cus" :depends-on ("packages"))
	       (:file "dod-dal-prd" :depends-on ("packages"))
		  (:file "dod-bl-prd" :depends-on ("packages"))
	       (:file "dod-ui-prd" :depends-on ("packages"))
	       (:file "dod-ui-ven" :depends-on ("packages"))
	       (:file "dod-bl-ven" :depends-on ("packages"))
	       (:file "dod-dal-ven" :depends-on ("packages"))
	       (:file "dod-bl-ord" :depends-on ("packages"))
	       (:file "dod-ui-ord" :depends-on ("packages"))
	       (:file "dod-dal-ord" :depends-on ("packages"))
	       (:file "dod-bl-odt" :depends-on ("packages"))
	       (:file "dod-ui-odt" :depends-on ("packages"))
	       (:file "dod-dal-odt"  :depends-on ("packages"))
	       (:file "dod-dal-cmp" :depends-on ("packages"))
	       (:file "dod-bl-cmp" :depends-on ("packages"))
	       (:file "dod-ui-cmp" :depends-on ("packages"))
	       (:file "dod-ui-opf" :depends-on ("packages"))
	       (:file "dod-dal-opf" :depends-on ("packages"))
	       (:file "dod-bl-opf" :depends-on ("packages"))
	       (:file "dod-ini-sys" :depends-on ("packages"))))

