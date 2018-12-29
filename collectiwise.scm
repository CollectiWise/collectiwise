(load "/home/ubuntu/collectiwise/load_all.scm")
(add-to-load-path "/home/ubuntu/collectiwise")
(load "/home/ubuntu/collectiwise/math.scm")
(load-from-path "utility_functions.scm")
(add-to-load-path "/home/ubuntu/opencog/opencog/pln/rules/term/")
(load "/home/ubuntu/opencog/opencog/pln/rules/term/deduction.scm")
(print "yo")
(use-modules (ice-9 readline)) (activate-readline)
(add-to-load-path "/usr/local/share/opencog/scm")
(add-to-load-path ".")
(add-to-load-path "home/collectiwise/")
(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog exec))
(use-modules (opencog pln))
(add-to-load-path "..")
(define shares (ConceptNode "shares"))
(define score (Concept "score")) 
(define User (ConceptNode "User" (stv 0.01 1)))
(define Animal (ConceptNode "Animal" (stv 0.1 1)))
(define alive (PredicateNode "alive" (stv 0.01 1))) ; something is alive
(define user_animal (InheritanceLink User Animal (stv 1 1))) ; all users are animals; defined by us (no market needed)
(define animal_alive (EvaluationLink alive (ListLink Animal) (stv 0.9 1))) ; most animals we will encounter are alive
;(define create-account (QuantityLink (ConceptNode "points") (NumberNode 100000)))
(define (name first last) (string-append first " " last))
;(ListLink                            
;   (InheritanceLink (stv 1 1)
;      (ConceptNode "User" (stv 1 1))
;      (ConceptNode "Human" (stv 1 1))
;   )
;   (InheritanceLink (stv 0.9 0.9)
;      (ConceptNode "Human" (stv 1 1))
;      (ConceptNode "Animal" (stv 1 1))
;   )
;)

(define (is-a x y p); users should be allowed to make such statements, either probabilistically or certainly (maybe using voting) 
	(ListLink
   		(InheritanceLink (stv p 1)
      			(ConceptNode x)
      			(ConceptNode y)
   		)
   	
   	)
)

(is-a "User" "Human" 1)
(is-a "Human" "Animal" 1)

(define (sum elemList)
  (if
    (null? elemList)
    (NumberNode 0)
    (cog-execute! (PlusLink (car elemList) (sum (cdr elemList))))
  )
)

(define find-users
    (BindLink
        (VariableNode "$X")
        (InheritanceLink
            (VariableNode "$X")
            (ConceptNode "User"))
        (ListLink
            (VariableNode "$X"))))
                                 
; all users have an account with scores
(define (add-score user n)
	(define current (cog-value user score))
	(cog-set-value! user score 
		(cog-execute! 
			(PlusLink (if (null? current) (NumberNode 0) current) (NumberNode n))
		)
	)
)

(define (make-user f l)
	(define usr (ConceptNode (name f l)))
	(InheritanceLink usr User (stv 1 1))
	(cog-execute! deduction-inheritance-rule); deduce what it logically means to be a user (to be a human and an animal etc.)
	(cog-set-value! usr score (NumberNode 100000))
)

(define (quantities ps b)
	(define p1 (car ps))                              ; cost function for the logarithmic scoring rule:
	(map (lambda (n) (* b (log (exp (/ n p1))))) ps))

; creating a new proposition one ought to commit some tokens. 
(define (set-quantity predicate n) (cog-set-value! predicate shares (NumberNode n)))
(define (quantity predicate) (define inner (cog-value predicate shares)) inner)



(define (cost quantz b) 
	(define (inner) (map (lambda (n) (exp (/ n b))) quantz))
	(* b (log (list_sum (inner)))))

(define (change-cost predicate p b)
 	(define quantitees (list (cog-number (quantity predicate)) (cog-number (quantity (Not predicate)))))
	(define new_quantities (quantities (list p (- 1 p)) b)) 	
	(define old_cost (cost quantitees b))
	(define inner (map (lambda (n) (exp (/ n b))) new_quantities))
        (define new_cost (* b (log (list_sum inner))))
	;(if (positive? (- p (cog-stv-strength predicate))) (- old_cost new_cost) (- new_cost old_cost))
	(- new_cost old_cost)
)

(define (change-quantity predicate p b)
	(define quantitees (list (cog-number (quantity predicate)) (cog-number (quantity (Not predicate)))))
 	(define new_quantities (quantities (list p (- 1 p)) b))
	(map - new_quantities quantitees) 	
)

(define (expected-gain probs quantz)
	(list_sum (map * probs quantz))  
)

(define (worst-case quantz)
	(list_min quantz)
)

(define (best-case quantz)
	(list_max quantz)
)

(define (lookup_cases predicate p b)
	(define costs (change-cost predicate p b))
	(define quantz (change-quantity predicate p b))
	(list (- (worst-case quantz) costs) (- (expected-gain (list p (- 1 p)) quantz) costs) (- (best-case quantz) costs))
)
; the price of one case among n cases
(define (price qs q b)
	(define (inner) (map (lambda (n) (exp (/ n b))) qs))
	(/ (exp (/ q b)) (list_sum (inner))))








;(define (set-user-quantity user p n))

; Functions we still need:

(define (made-by predicate user) (EvaluationLink (PredicateNode "made-by") (ListLink predicate user)))

(define (get-maker predicate)
    (define (inner pred) 
    (BindLink
        (EvaluationLink
	(PredicateNode "made-by")
		(ListLink
	    		pred
            		(VariableNode "$U")))
        (ListLink
            (VariableNode "$U"))))
	(cog-execute! (inner predicate)))

(define (get-pred-users predicate)
    (define (inner pred)
    (BindLink
        (EvaluationLink
        (PredicateNode "traded-in")
                (ListLink
                        pred
                        (VariableNode "$U")))
        (ListLink
            (VariableNode "$U"))))
        (cog-execute! (inner predicate)))


; (define (get-predicate-users) (all-the users who have shares in a predicate))
(define (attach predicate user) 
	(EvaluationLink (PredicateNode "traded-in") (ListLink predicate user)))
; (define (change-probability predicate user new-pr) should change the probability of the predicate to new-pr, it should also assign new quantities of the predicate as a whole and of the shares of the user and it should attach the user to that predicate as one of the users)

(define (set-user-shares user predicate n) (cog-set-value! (EvaluationLink (AnchorNode "shares") (ListLink user predicate)) shares (NumberNode n)))
(define (user-shares user predicate) (define inner (cog-value (EvaluationLink (AnchorNode "shares") (ListLink user predicate)) shares)) (if (null? inner) (NumberNode 0) inner))

(define (mk-predicate user predicate p b)
	(define qs (quantities (list 0.5 0.5) b)) ;the maker of the predicate must only pay for an even odds bet and then can set the probabilities for free because she in a sense buys shares from herself. 
	(define NotPQ (* b (log (exp (/ (- 1 p) p)))))	
	(define points (cost qs b)) 
	(define pred (Predicate predicate (stv p 1)))
	(cog-set-tv! (Not pred) (stv (- 1 p) 1))
	;(cog-execute! negation-introduction-rule) ;re-sets the prices on all negated predicates in the whole AtomSpace, based on current prices of all positive predicates. 	(define NotPQ (* b (log (exp (/ (- 1 p) p))))) 	
	;(print (Not pred))
	(made-by pred user)
	(made-by (Not pred) user) ; by making a statement about a predicate, one automatically makes a statement about its opposite; whatever that may be (in the case of fast, the opposite is slow). 
	(add-score user (- points))
	(set-user-shares user pred b)
	
	;the quantity for the not-predicate 
	(set-user-shares user (Not pred) NotPQ)
	(set-quantity pred b)
	(set-quantity (Not pred) NotPQ) 
	(attach pred user)
	(attach (Not pred) user)
	
) 

;(define (change-cost predicate quant)
;	(define quantities (list (quantity predicate) (quantity (Not predicate))))
;	b*ln(sum([e**(qi/b) for qi in quantities])) - (cost quantities b)
;)
(define (change-predicate user predicate p b)
	(define maker (get-maker predicate))
	(define costs (change-cost predicate p b))
	(define quantz (change-quantity predicate p b))
	(define user-quantz (map + (list (cog-number (user-shares user predicate)) (cog-number (user-shares user (Not predicate)))) quantz))     	
	(define maker-quantz (map - (list (cog-number (user-shares maker predicate)) (cog-number (user-shares maker (Not predicate)))) quantz))
	(define pred-quantz (map + (list (cog-number (quantity predicate)) (cog-number (quantity (Not predicate)))) quantz))  	
	(cog-set-tv! predicate (stv p 1))
	(cog-set-tv! (Not predicate) (stv (- 1 p) 1))
	;(cog-execute! negation-introduction-rule) 
	(print (Not predicate))
	(add-score maker costs)
	(add-score user (- costs))
       
	;selling shares from the maker to the user so that the predicate has the right number to give rise to the user-determined probabilities
	;note that the maker can change probabilities free of charge, only altering her expected gains and potential losses in the future.


	
	(map attach (list predicate (Not predicate)) (list user user))
	(map set-user-shares (list user user) (list predicate (Not predicate)) user-quantz)
	(map set-user-shares (list maker maker) (list predicate (Not predicate)) maker-quantz)
	(map set-quantity (list predicate (Not predicate)) pred-quantz)
)
;(print (cost '(1 2) 10))
;(print (cost '(1 2 3)  10))
;(print (price '(1 3 2) 1 10));
;(print (price '(1 5) 1 10))
;(print (quantities '(0.6 0.4) 10))
;(print (price (quantities '(0.6 0.4) 10) 10 10))
(make-user "john" "steward")
(make-user "hanna" "rodwinkle")
(define john (ConceptNode "john steward"))
(define hanna (ConceptNode "hanna rodwinkle"))
;(print (cog-value john score))
(mk-predicate hanna "is-fast" 0.5 10) ; john asserts that the probability of something being fast is 0.5 and pays some cost to assert that
;(attach (PredicateNode "is-fast") john)
(print "john's score")
(print (cog-value john score))
(print "hanna's score")
(print (cog-value hanna score))
;(print (cog-execute! find-users))
;(print (cog-execute! get-users))
(print "hanna's shares")
(print (user-shares hanna (PredicateNode "is-fast")))
(print "john's shares")
(print (user-shares john (PredicateNode "is-fast")))
(print "maker of 'is-fast' predicate: ")
(print (get-maker (PredicateNode "is-fast")))
(print "all users attached to 'is-fast':")
(print (get-pred-users (PredicateNode "is-fast")))
;(print (Not (PredicateNode "is-fast")))
;(print (cog-execute! find-users))
;(print (mk-predicate (ConceptNode "Hanna") "is-fast" 0.6 10))
;(print (cog-execute! pidefine pred-quantz (map + (list (cog-number (quantity predicate)) (cog-number (quantity (Not predicate)))) quantz)) redicate-search))      
;(print (get-pred-users (Not (PredicateNode "is-fast")))) 
;(print (change-cost (PredicateNode "is-fast") 0.01 10))
;(print (change-quantity (PredicateNode "is-fast") 0.01 10)) 
;(print (change-cost (PredicateNode "is-fast") 0.9 10))
;(print (change-quantity (PredicateNode "is-fast") 0.9 10))
;(print (expected-gain (list 0.9 0.1) (change-quantity (PredicateNode "is-fast") 0.9 10)))
;(print (worst-case (change-quantity (PredicateNode "is-fast") 0.9 10)))
;(print (best-case (change-quantity (PredicateNode "is-fast") 0.9 10)))  
;(print (lookup_cases (PredicateNode "is-fast") 0.9 10))
(change-predicate john (Predicate "is-fast") 0.1 10)
(print "john's scores: ")
(print (cog-value john score))
(print "hanna's scores: ")
(print (cog-value hanna score))
(print "not is fast probability (should be 0.99)")
(print (Not (Predicate "is-fast")))
(print "hanna's shares")
(print (user-shares hanna (PredicateNode "is-fast")))
(print "john's shares")
(print (user-shares john (PredicateNode "is-fast")))
(print "john's shares of negated predicate")
(print (user-shares john (Not (Predicate "is-fast"))))
(print "maker of 'is-fast' predicate: ")
(print (get-maker (PredicateNode "is-fast")))
(print "all users attached to 'is-fast':")
(print (get-pred-users (PredicateNode "is-fast")))
