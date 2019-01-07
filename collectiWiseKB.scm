;(add-to-load-path "~/.")
(load "/home/ubuntu/collectiwise/load_all.scm")
(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog exec))

(add-to-load-path ".")
(load-from-path "math.scm")
(load-from-path "utility_functions.scm")
(load-from-path "collectiwise.scm")

;; Kownledge base for our first CollectiWise demo.
;;
;;;;;;;;;;;;;
;; Users   ;;
;;;;;;;;;;;;;
; there are 6 users ...hence the probability of running into Anna when running into a random user, is 1/6 (no market needed)
; this will have to be calculated automatically, when adding a user (add_user function) and it will have to be updated for all users each time a user is added! 

; part of a later encapsulated function make_user
(make-user "Kelvin" "Shi" )
(make-user "Austin" "Agbo")
(make-user "Barbara" "Krecak")
(make-user "Naireen" "Imtiaz")
(make-user "Lorena" "Konjevic")
(make-user "Lukas" "Genever")
(make-user "Johannes" "Castner")

; basic object identifiers of the users, for easier handling of examples 
; this will of course not be necessary internally. We'll need a function to fetch users by their unique id
(define kelvin (ConceptNode "Kelvin Shi"))
(define austin (ConceptNode "Austin Agbo"))
(define barbara (ConceptNode "Barbara Krecak"))
(define naireen (ConceptNode "Naireen Imtiaz"))
(define lorena (ConceptNode "Lorena Konjevic"))
(define lukas (ConceptNode "Lukas" "Genever"))
(define johannes (ConceptNode "Johannes Castner"))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; team-mates           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(define team-mates (PredicateNode "team-mates"))
; membership is symmetric
; If X and Y are team-mates, then Y and X are team-mates. This is defined by the system (a system primitive)
 
(EquivalenceLink (stv 1.0 1.0)
    (EvaluationLink
        team-mates
        (ListLink
            (VariableNode "$X")
            (VariableNode "$Y")))
    (EvaluationLink
        team-mates
        (ListLink
            (VariableNode "$Y")
(VariableNode "$X"))))
 
;evidence (team-mate-ship could be fractional (number of projects worked on together divided by total number of projects worked on) ... not sure or degree of team-mateness):

; Kelvin and Johannes are team-mates. Our social network logic ...but of course there can be many other relationships aside from being team-mates; more similar to LinkdIn but also note that we can have varying degrees of certainty about who is who's team-mate (with people expressing that in form of incentivized beliefs) etc. The first number in the stv can be between 0 and 1. There can be a market on that! For simplicity we now assume that team-mate-ness is hard-coded in our system (we know 100% whenever two people are team-mates and they either are 100% team-mates or not at all). 
(EvaluationLink (stv 1.0 1.0)
    team-mates
    (ListLink
        kelvin
        johannes))

(EvaluationLink (stv 1.0 1.0)
    team-mates
    (ListLink
        barbara
        lorena))

(EvaluationLink (stv 1.0 1.0)
    team-mates
    (ListLink
        naireen
        austin))

(EvaluationLink (stv 1.0 1.0)
    team-mates
    (ListLink
        lukas
        johannes))

(EvaluationLink (stv 1.0 1.0)
    team-mates
    (ListLink
        lukas
        barbara))

;;;;;;;;;;;;;
;; Speed   ;;
;;;;;;;;;;;;;
(mk-predicate lorena "is-fast" 0.5 10) ; lorena asserts that the probability of something being fast is 0.5 and pays some cost to assert that

(print "johannes's score")
(print (cog-value johannes score))
(print "lorena's score")
(print (cog-value lorena score))

;(print (cog-execute! get-users))
(print "lorena's shares")
(print (user-shares lorena (PredicateNode "is-fast")))
(print "johannes's shares")
(print (user-shares johannes (PredicateNode "is-fast")))
(print "maker of 'is-fast' predicate: ")
(print (get-maker (PredicateNode "is-fast")))
(print "all users attached to 'is-fast':")
(print (get-pred-users (PredicateNode "is-fast")))
;(print (Not (PredicateNode "is-fast")))
;(print (cog-execute! find-users))
;(print (mk-predicate (ConceptNode "Hanna") "is-fast" 0.6 10))
;(print (cog-execute! pidefine pred-quantz (map + (list (cog-number (quantity predicate)) (cog-number (quantity (Not predicate)))) quantz)) redicate-search))      
(define Helen (ConceptNode "Helen" (stv 1/6 1)))
(define helen_user (InheritanceLink Helen User (stv 1 1)))
;(print (get-pred-users (Not (PredicateNode "is-fast")))) 
;(print (change-cost (PredicateNode "is-fast") 0.01 10))
;(print (change-quantity (PredicateNode "is-fast") 0.01 10)) 
;(print (change-cost (PredicateNode "is-fast") 0.9 10))
;(print (change-quantity (PredicateNode "is-fast") 0.9 10))
;(print (expected-gain (list 0.9 0.1) (change-quantity (PredicateNode "is-fast") 0.9 10)))
;(print (worst-case (change-quantity (PredicateNode "is-fast") 0.9 10)))
;(print (best-case (change-quantity (PredicateNode "is-fast") 0.9 10)))  
;(print (lookup_cases (PredicateNode "is-fast") 0.9 10))
(change-predicate johannes (Predicate "is-fast") 0.1 10)
(print "johannes's scores: ")
(print (cog-value johannes score))
(print "lorena's scores: ")
(print (cog-value lorena score))
(print "all users attached to is-fast now:")
(print (get-pred-users (PredicateNode "is-fast")))
(print "all users:")
(print (cog-execute! find-users))
(define java (ConceptNode "Java"))
(define is-fast (Predicate "is-fast"))
(mk-context-predicate johannes java is-fast 0.2 10)
;(change-context-predicate lorena java (PredicateNode "is-fast") 0.4 10)
(define neg-pred (Not is-fast))
(define neg-context (contextualize neg-pred java 0.5))
(define context-predicate (contextualize is-fast java 0.5))
(change-binary-statement lorena context-predicate neg-context 0.5 10)
(define maker (get-maker context-predicate)) 
;(print maker)
(print (find-context java))


; is Johannes fast?  Now here please recognize that the first number in the stv (the only relevant one for the time being) can be interpreted as a probability if a person can either be fast or slow, or it could be interpreted as a degree of being fast.  Once there is evidence, the probability and thus the market price of the value will either rise or decline, depending on the evidence and thus the value of holding shares (if you will) in the speed of Johannes will rise or decline, depending on the evidence and depending on others beliefs:

;; Probability of being fast, market

;(Predicate "is-honest" (stv 0.8 1))
;(show-cnts)
;(cog-execute! (GetLink
;      (AndLink
;           (EvaluationLink (Predicate "has-account")   (ListLink
;(Variable "$X")))
;           (EvaluationLink (PredicateNode "points")
;                    (ListLink (Variable "$X") (NumberNode 100000)))
;            (Inheritance (VariableNode "$X") (ConceptNode "animal")))))
;
;(define ms 3)
(use-modules (opencog miner))
(define minedPatterns (cog-mine (cog-atomspace)) )
;(print minedPatterns)
;(help cog-mine)
