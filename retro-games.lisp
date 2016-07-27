
(defpackage :retro-games
  (:use :cl :cl-who :hunchentoot :parenscript))

 (in-package :retro-games) 
  
(defclass game ()
  ((name :reader name
	 :initarg :name)
   (votes :accessor votes
	  :initform 0)))

(defvar *games* '())


(defmethod vote-for (user-selected-game)
  (incf (votes user-selected-game)))

(defun game-from-name (name)
  (find name  *games* :test #'string-equal
	:key #'name))

(defun game-stored? (game-name)
 ( game-from-name game-name))


(defun games ()
  (sort (copy-list *games*) #'> :key #'votes))

(defun add-game(name)
  (unless (game-stored? name)
	   (push (make-instance 'game :name name) *games*)))


(defmacro standard-page ((&key title) &body body)
	 `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	   (:html :xmlns "http://www.w3.org/1999/xhtml"
		  :xml\:lang "en" 
		  :lang "en"
		  (:head 
		   (:meta :http-equiv "Content-Type" 
			  :content    "text/html;charset=utf-8")
		   (:title ,title)
		   (:link :type "text/css" 
			  :rel "stylesheet"
			  :href "./retro.css"))
		  (:body 
		   (:div :id "header" ; Retro games header
			 (:img :src "logo.png" 
			       :alt "Commodore 64" 
			       :class "logo")
			 (:span :class "strapline" 
				"Welcome to CRM System"))
		   ,@body))))
      

(defun controller-index () 
	 (standard-page (:title "Top Retro Games")
			(:h1 "Vote on your all time favourite retro games!")
			(:p "Missing a game? Make it available for votes " (:a :href "/new-game" "here"))
			(:h2 "Current stand")
			(:div :id "chart" ; For CSS styling of links
			      (:ol
			       (dolist (game (games))
				 (htm  
				  (:li 
				   (:a :href (format nil "vote?name=~a" (name game)) "Vote!")
				   (fmt "~A with ~d votes" (name game) (votes game)))))))))



(defun controller-vote ()
  (let ((game (game-from-name (parameter "name"))))
  (if game
      (vote-for game))
      (redirect "/index")))


(defun controller-new-game ()
 	 (standard-page (:title "Add a new game")
			(:h1 "Add a new game to the chart")
			(:form :action "/game-added" :method "post" 
			       (:p "What is the name of the game?" (:br)
				   (:input :type "text"  
					   :name "name" 
					   :class "txt"))
			       (:p (:input :type "submit" 
					   :value "Add" 
					   :class "btn")))))

      

(defun controller-game-added ()
  (let  ((name (parameter "name")))
  (unless ( or (null name) (zerop (length name)))
    (add-game name))
  (redirect "/index")))







