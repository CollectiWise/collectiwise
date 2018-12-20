
(add-to-load-path "/home/ubuntu/opencog/opencog/pln/rules/term/")
(load "/home/ubuntu/opencog/opencog/pln/rules/term/deduction.scm")
(load "/home/ubuntu/collectiwise/load_all.scm")
(use-modules (ice-9 readline)) (activate-readline)
(add-to-load-path "/usr/local/share/opencog/scm")
(add-to-load-path ".")
(add-to-load-path "/home/ubuntu/collectiwise")
;(add-to-load-path "home/collectiwise/")
(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog exec))
(use-modules (opencog pln))
;(add-to-load-path "..")
(load-from-path "math.scm")
(load-from-path "utility_functions.scm")
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

; cost function for the logarithmic scoring rule:

(define (cost quantities b) 
	(define (inner) (map (lambda (n) (exp (/ n b))) quantities))
	(* b (log (list_sum (inner)))))

; the price of one case among n cases
(define (price qs q b)
	(define (inner) (map (lambda (n) (exp (/ n b))) qs))
	(/ (exp (/ q b)) (list_sum (inner))))

(define (quantities ps b)
	(define p1 (car ps))
	(map (lambda (n) (* b (log (exp (/ n p1))))) ps))

; creating a new proposition one ought to commit some tokens. 
(define (set-quantity predicate n) (cog-set-value! predicate shares (NumberNode n)))
(define (quantity predicate) (define inner (cog-value predicate shares)) inner)
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
	(define qs (quantities (list p (- 1 p)) b))
	(define points (cost qs b)) 
	(define pred (Predicate predicate (stv p 1)))
	(made-by pred user)
	(add-score user (- points))
	(set-user-shares user pred b)
	(set-quantity pred b)
	(attach pred user)
;have to add the negation rule here so that the user also has a quantity of "shares" of the negation of the predicate
;corresponding with the probability of the negation of the predicate.	
) 


;(print (cost '(1 2) 10))
;(print (cost '(1 2 3)  10))
;(print (price '(1 3 2) 1 10));
;(print (price '(1 5) 1 10))
;(print (quantities '(0.6 0.4) 10))
;(print (price (quantities '(0.6 0.4) 10) 10 10))
(make-user "john" "steward")
(define john (ConceptNode "john steward"))
(define hanna (ConceptNode "hanna rodwinkle"))
(print (cog-value john score))
(mk-predicate hanna "is-fast" 0.5 10) ; john asserts that the probability of something being fast is 0.5 and pays some cost to assert that
(attach (PredicateNode "is-fast") john)
(print (cog-value john score))
(print (cog-execute! find-users))
;(print (cog-execute! get-users))
(print (user-shares hanna (PredicateNode "is-fast")))
(print (get-maker (PredicateNode "is-fast")))
(print (get-pred-users (PredicateNode "is-fast")))
;(print (cog-execute! find-users))
;(print (mk-predicate (ConceptNode "Hanna") "is-fast" 0.6 10))
;(print (cog-execute! predicate-search))        
