(in-package :dairyondemand)
(clsql:file-enable-sql-reader-syntax)

(new-dod-company "Gopalan Atlantis" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Gopalan Granduer" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Gopalan Urban Woods" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Palms" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Glen Woods" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Silver Oaks" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Langleigh" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Bogunville" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prestige Mayberry" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Sobha Rose" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Nitesh Forest Hills" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "AWHO Apartments" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Balaji Pristine" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Raghavendra Midas" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Umiya Woods" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Prithvi Layout" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)
(new-dod-company "Athashri" "ECC Road, Whitefield" "Bangalore" "Karnataka" "India" "560096" -1 -1)




					;**********Get the company***********
(defparameter dod-company (select-company-by-name "%demo"))

;;;;;;;;;;;;;;;;;;; CREATE SOME PRODUCT CATEGORIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defparameter *product-categories* nil)
(setf *product-categories* (list "Milk & Dairy Products" "Milk and Dairy Products." "resources/milkdairy.png" dod-company))
(apply #'create-prdcatg *product-categories*)

(setf *product-categories* nil) 
(setf *product-categories* (list "Other items" "Other items." "resources/otheritems.png" dod-company))
(apply #'create-prdcatg *product-categories*)


(setf *product-categories* nil) 
(setf *product-categories* (list "Newspapers & Magazines" "Newspapers & Magazines." "resources/newspapers&magazines.png" dod-company))
(apply #'create-prdcatg *product-categories*)


(defparameter salt (flexi-streams:octets-to-string  (secure-random:bytes 56 secure-random:*generator*)))
(defparameter password (encrypt "demo" salt))      

;******Create the customer ******
(defparameter *customer-params* nil)
;******Create a customer for demo company, with fixed phone number *******
(setf *customer-params* (list  "Demo Customer"   "GA Bangalore 560066" "9999999999" "abc@abc.com" nil password salt   "Bangalore" "Karnataka" "560066"  dod-company))
;Create the customer now.
(apply #'create-customer *customer-params*)

(loop for i from 1 to 10 do 
     (let* ((salt (flexi-streams:octets-to-string  (secure-random:bytes 56 secure-random:*generator*)))
	   (password (encrypt "P@ssword1" salt))
	   (*customer-params* (list (format nil "cust~a" (random 200)) "GA Bangalore 560066" (format nil "99999~a" (random 99999)) "abc@abc.com" nil password salt  "Bangalore" "Karnataka" "560066"  dod-company)))
       
       ;create the customer now.
       (apply #'create-customer *customer-params*)))

;Get the customer which we have created in the above steps. 
(defparameter Testcustomer1 (select-customer-by-name (car *customer-params*) dod-company))

; **** Create the vendor *****
(defparameter *vendor-params* nil)
(loop for i from 1 to 10 do 
(setf *vendor-params* (list (format nil "Vendor~a" (random 20)) "GA Bangalore 560066" (format nil "98456~a" (random 99999)) dod-company))
;Create the vendor now.
(apply #'create-vendor *vendor-params*))
;Get the vendor which we have created in the above steps. 
(defparameter Rajesh(select-vendor-by-id 1  dod-company))
(defparameter Suresh(select-vendor-by-id 2  dod-company))

(defparameter MilkCatg (select-prdcatg-by-name "%Milk & Dairy Products%" dod-company))
(defparameter NewspapersCatg (select-prdcatg-by-name "%Newspaper%" dod-company))
(defparameter OtherCatg (select-prdcatg-by-name "%Other items%" dod-company))


(defparameter NandiniBlue (list (format nil "Nandini Homogenised milk (Blue packet)") Rajesh MilkCatg "500 ml" 18.50 "resources/nandini-blue.png" "Y" dod-company))
(apply #'create-product NandiniBlue)
(defparameter NandiniPurple (list (format nil "Nandini Sumrudhi (Purple packet)") Rajesh MilkCatg "500 ml" 18.50 "resources/nandini-purple.png" "Y" dod-company))
(apply #'create-product NandiniPurple) 
(defparameter NandiniSTM (list (format nil "Nandini Special Toned Milk") Rajesh MilkCatg "500 ml" 18.50 "resources/nandini-STM.png" "Y"  dod-company))
(apply #'create-product NandiniSTM) 
(defparameter NandiniYellow (list (format nil "Nandini Double Toned Milk (Yellow packet)") Rajesh MilkCatg  "500 ml" 46.00 "resources/nandini-yellow.png" "Y"  dod-company))
(apply #'create-product NandiniYellow)
 
(defparameter TOI (list (format nil "Times Of India") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/timesofindia.png" "Y"  dod-company))
(apply #'create-product TOI)

(defparameter DeccanHerald (list (format nil "Deccan Herald") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/deccanherald.png" "Y"  dod-company))
(apply #'create-product DeccanHerald)

(defparameter TheHindu (list (format nil "The Hindu") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/thehindu.png" "Y"  dod-company))
(apply #'create-product TheHindu)

(defparameter IndianExpress (list (format nil "Indian Express") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/indianexpress.png" "Y"  dod-company))
(apply #'create-product IndianExpress)

(defparameter VijayKarnataka (list (format nil "Vijay Karnataka") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/vijaykarnataka.png" "Y"  dod-company))
(apply #'create-product VijayKarnataka)

(defparameter PrajaVani (list (format nil "Praja Vani") Suresh  NewspapersCatg  "1 Nos" 5.00 "resources/prajavani.png" "Y"  dod-company))
(apply #'create-product PrajaVani)


(defparameter *product-params* nil)
(defparameter *unitprice* nil) 
(loop for i from 1 to 10 do 
(setf *unitprice* (random 500.00)) 
(setf *product-params* (list (format nil "Test Product ~a" (random 200)) Rajesh OtherCatg "1 KG" *unitprice*  "resources/test-product.png" nil dod-company))
;Create the customer now.
(apply #'create-product *product-params*))

;;;; Create two wallets for the customer demo
(defparameter *demo-customer* (select-customer-by-name "%Demo Customer" dod-company)) 
(defparameter *demo-cust-wallet1* (list *demo-customer* Rajesh dod-company))
(defparameter *demo-cust-wallet2* (list *demo-customer* Suresh dod-company))

(apply #'create-wallet *demo-cust-wallet1*)
(apply #'create-wallet *demo-cust-wallet2*)

(defparameter *cust-wallet1* (get-cust-wallet-by-vendor *demo-customer* Rajesh dod-company))
(defparameter *cust-wallet2* (get-cust-wallet-by-vendor *demo-customer* Suresh dod-company))
(set-wallet-balance 1000.00 *cust-wallet1*) 
(set-wallet-balance 1000.00 *cust-wallet2*)



 


