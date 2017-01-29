(defclass food() 
	      ((name
		:initarg :name)
	       (color
		:initarg :color)
	       (taste
		:initarg :taste)))



(defclass veg-food (food) 
  ((list-of-ingredients
   :initarg :list-of-ingredients)
  (source
   :initarg :source)))


(defclass non-veg-food (food) 
  ((list-of-ingredients
   :initarg :list-of-ingredients)
  (source
   :initarg :source)))

(defgeneric cook (food)
 ( :documentation "Type and name of the food you want to cook"))

(defmethod cook ((fd veg-food))
    (let (( ingredients (slot-value fd 'list-of-ingredients)))
   (loop for ingr in ingredients
      do (format t "Adding ingredient ~A~C" ingr #\linefeed)))
    )

(defmethod cook ((fd food))
  (format t "Cooking food now ~C" #\linefeed)
  (format t "~A is cooking has ~A color and tastes ~A~C" (slot-value fd 'name)
	  (slot-value fd 'color)
	  (slot-value fd 'taste) #\linefeed))





(defparameter GulabJamoon (make-instance 'veg-food
					 :name "Gulab Jamoon"
					 :color "Light Brown"
					 :taste "Sweet"
					 :source "Plants"
					 :list-of-ingredients '("Maida" "Sugar" "Water" "Khova" "Oil")))

(defparameter Rasgulla (make-instance 'veg-food
					 :name "Rasgulla"
					 :color "White"
					 :taste "Sweet"
					 :source "Plants"
					 :list-of-ingredients '("Milk Solids" "Sugar" "Water" "Paneer")))


(defparameter IndianFood (make-instance 'food
					:name "Some Indian food"
					:color "Great"
					:taste "Awesome"))
