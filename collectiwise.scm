(load "/root/collectiwise/load_all.scm")
(add-to-load-path "/root/collectiwise")
(load "/root/collectiwise/math.scm")
(load-from-path "utility_functions.scm")
(add-to-load-path "/root/opencog/opencog/pln/rules/term/")
(load "/root/opencog/opencog/pln/rules/term/deduction.scm")
(print "yo")
(use-modules (ice-9 readline)) (activate-readline)
(add-to-load-path "/usr/local/share/opencog/scm")
(add-to-load-path ".")
(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog exec))
(use-modules (opencog pln))
(add-to-load-path "..")
(define shares (ConceptNode "shares"))
(define score (Concept "score")) 
(define User (ConceptNode "User"))
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

(define (find-users)
    (cog-execute! 
        (BindLink
            (VariableNode "$X")
            (InheritanceLink
                (VariableNode "$X")
                (ConceptNode "User"))
        (ListLink
            (VariableNode "$X")))))
                                 
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

(define (change-cost statement neg-statement p b)
 	(define quantitees (list (cog-number (quantity statement)) (cog-number (quantity neg-statement))))
	(define new_quantities (quantities (list p (- 1 p)) b)) 	
	(define old_cost (cost quantitees b))
	(define inner (map (lambda (n) (exp (/ n b))) new_quantities))
        (define new_cost (* b (log (list_sum inner))))
	;(if (positive? (- p (cog-stv-strength predicate))) (- old_cost new_cost) (- new_cost old_cost))
	(- new_cost old_cost)
)

(define (change-quantity statement neg-statement p b)
	(define quantitees (list (cog-number (quantity statement)) (cog-number (quantity neg-statement))))
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
;mk-concept
(define (mk-concept user name) (ConceptNode name) (made-by (ConceptNode name) (ConceptNode user)))

(define (set-user-shares user predicate n) (cog-set-value! (EvaluationLink (AnchorNode "shares") (ListLink user predicate)) shares (NumberNode n)))
(define (user-shares user predicate) (define inner (cog-value (EvaluationLink (AnchorNode "shares") (ListLink user predicate)) shares)) (if (null? inner) (NumberNode 0) inner))

(define (mk-binary-statement user statement neg-statement p b)
	(define qs (quantities (list 0.5 0.5) b))
	(define NotPQ (* b (log (exp (/ (- 1 p) p)))))	
 	(define points (cost qs b))
	(cog-set-tv! neg-statement (stv (- 1 p) 1))
	(made-by statement user)
	(made-by neg-statement user)
	(add-score user (- points))
	(set-user-shares user statement b)
	(set-user-shares user neg-statement NotPQ)
	(set-quantity statement b)
	(set-quantity neg-statement NotPQ)  
	(attach statement user)
	(attach neg-statement user) 	
  )


(define (mk-predicate user predicate p b)
	(define pred (Predicate predicate (stv p 1)))
	(define neg-pred (Not pred)) 	 	
	(mk-binary-statement user pred neg-pred p b)	
) 

(define (mk-relationship userString concept1 concept2 relation p b)
  	(define user (ConceptNode userString))
	(define relationship (EvaluationLink (PredicateNode relation) (ListLink (ConceptNode concept1) (ConceptNode concept2))))
	(define neg-relationship (Not relationship))
	(mk-binary-statement user relationship neg-relationship p b)
 )

(define (mk-attribute userString concept predicate contxt p b)
	(define pred (Predicate predicate))
	(define user (ConceptNode userString))
	(define cncpt (ConceptNode concept))
	(define attribute (EvaluationLink (stv p 1.0) pred cncpt))
	(define neg-attribute (Not attribute))
	(contextualize attribute (ConceptNode contxt) 1.0)
	(contextualize neg-attribute (ConceptNode contxt) 1.0)
	(mk-binary-statement user attribute neg-attribute p b)

)

(define (change-relationship userString concept1 concept2 relation p b)
  	(define user (ConceptNode userString))
	(define relationship (EvaluationLink (PredicateNode relation) (ListLink (ConceptNode concept1) (ConceptNode concept2))))
	(define neg-relationship (Not relationship))
	(change-binary-statement user relationship neg-relationship p b)
)

(define (change-attribute userString concept predicate contxt p b)
  	(define pred (Predicate predicate))
	(define user (ConceptNode userString))
	(define cncpt (ConceptNode concept))
	(define attribute (EvaluationLink pred cncpt))
	(define neg-attribute (Not attribute))
	(contextualize attribute (ConceptNode contxt) 1.0)
	(contextualize neg-attribute (ConceptNode contxt) 1.0)
	(change-binary-statement user attribute neg-attribute p b)

)
;(define (change-cost predicate quant)
;	(define quantities (list (quantity predicate) (quantity (Not predicate))))
;	b*ln(sum([e**(qi/b) for qi in quantities])) - (cost quantities b)
;)
(define (change-binary-statement user statement neg-statement p b)

	(define maker (get-maker statement))
	(define costs (change-cost statement neg-statement p b))
	(define quantz (change-quantity statement neg-statement p b))
	(define user-quantz (map + (list (cog-number (user-shares user statement)) (cog-number (user-shares user neg-statement))) quantz))    
	(define maker-quantz (map - (list (cog-number (user-shares maker statement)) (cog-number (user-shares maker neg-statement))) quantz))
	(define statement-quantz (map + (list (cog-number (quantity statement)) (cog-number (quantity neg-statement))) quantz)) 
  	(cog-set-tv! statement (stv p 1))
  	(cog-set-tv! neg-statement (stv (- 1 p) 1))
  	
  	(add-score maker costs)
  	(add-score user (- costs))
	(map attach (list statement neg-statement) (list user user))                          
	(map set-user-shares (list user user) (list statement neg-statement) user-quantz)
	(map set-user-shares (list maker maker) (list statement neg-statement) maker-quantz)
	(map set-quantity (list statement neg-statement) statement-quantz)
)

(define (change-predicate user predicate p b)
	(define neg-pred (Not predicate))
	(change-binary-statement user predicate neg-pred p b)

)

(define (contextualize statement Context p)
	(ContextLink (stv p 1)
		Context
		statement))

(define (predicate-objectify statement list-link-objects p)
	(EvaluationLink (stv p 1)
		statement
		list-link-objects
		
	)
) 
(define (mk-context-predicate user NC predicate p b)
	
	(define context-predicate (contextualize predicate NC p)) 
	(define neg-pred (Not predicate))

	(define context-negpred (contextualize neg-pred NC (- 1 p))) 

	(mk-binary-statement user context-predicate context-negpred p b)		

)

(define (change-context-predicate user NC predicate p b)
	(define neg-pred (Not predicate)) 	
	(define context-predicate (contextualize predicate NC p))    	
	(define context-negpred (contextualize neg-pred NC (- 1 p))) 	;(define context-predicate
	(change-binary-statement user context-predicate context-negpred p b)
)

(define (mk-predicate-with-objects user predicate list-link-objects p b)
	(define neg-pred (Not predicate))
	(define predicate-with-objects (predicate-objectify predicate list-link-objects p))
	(define negpred-with-objects  (predicate-objectify neg-pred list-link-objects (- 1 p)))
	(mk-binary-statement user predicate-with-objects negpred-with-objects p b)
)

(define (find-context context)
    (cog-execute! 
	(BindLink
        	(VariableNode "$X")
        	(ContextLink
	    		context
            	(VariableNode "$X"))
        (ListLink
            (VariableNode "$X")))))


;(mk-context-predicate (ConceptNode "Johannes Castner") (ConceptNode "Java") (PredicateNode "is-fast" (stv 0.7 1)) 0.2 10)
;(find-users)
;(print (find-context (ConceptNode "Java")))
;(print (cost '(1 2) 10))
;(print (cost '(1 2 3)  10))
;(print (price '(1 3 2) 1 10));
;(print (price '(1 5) 1 10))
;(print (quantities '(0.6 0.4) 10))
;(print (price (quantities '(0.6 0.4) 10) 10 10))
;(make-user "john" "steward")
;(make-user "hanna" "rodwinkle")
;(print (find-users))
