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
(define Anna (ConceptNode "Anna" (stv 1/6 1)))
(define anna_user (InheritanceLink Anna User (stv 1 1)))

(define Bob (ConceptNode "Bob" (stv 1/6 1)))
(define bob_user (InheritanceLink Bob User (stv 1 1)))

(define Edward (ConceptNode "Edward" (stv 1/6 1)))
(define edward_user (InheritanceLink Edward User (stv 1 1)))

(define Frank (ConceptNode "Frank" (stv 1/6 1)))
(define frank_user (InheritanceLink Frank User (stv 1 1)))

(define Gary (ConceptNode "Gary" (stv 1/6 1)))
(define gary_user (InheritanceLink Gary User (stv 1 1)))

(define Helen (ConceptNode "Helen" (stv 1/6 1)))
(define helen_user (InheritanceLink Helen User (stv 1 1)))

;;;;;;;;;;;;;
;; Friends ;;
;;;;;;;;;;;;;

(define friends (PredicateNode "friends"))
; friendship is symmetric
; If X and Y are friends, then Y and X are friends.
 
(EquivalenceLink (stv 1.0 1.0)
    (EvaluationLink
        friends
        (ListLink
            (VariableNode "$X")
            (VariableNode "$Y")))
    (EvaluationLink
        friends
        (ListLink
            (VariableNode "$Y")
(VariableNode "$X"))))
 
;evidence (friendships could be fractional ... not sure or degree of friendship):

; Anna and Bob are friends. Our social network logic ...but of course there can be many other relationships aside from friendship; more similar to LinkdIn but also note that we can have varying degrees of certainty about who is who's friend etc. The first number in the stv can be between 0 and 1. There can be a market on that!  
(EvaluationLink (stv 1.0 1.0)
    friends
    (ListLink
        Anna
        Bob))

(EvaluationLink (stv 1.0 1.0)
    friends
    (ListLink
        Anna
        Edward))

(EvaluationLink (stv 1.0 1.0)
    friends
    (ListLink
        Anna
        Frank))

(EvaluationLink (stv 1.0 1.0)
    friends
    (ListLink
        Edward
        Frank))

(EvaluationLink (stv 1.0 1.0)
    friends
    (ListLink
        Gary
        Helen))

;;;;;;;;;;;;;
;; Speed   ;;
;;;;;;;;;;;;;

; is Anna fast?  Now here please recognize that the first number in the stv (the only relevant one for the time being) can be interpreted as a probability if a person can either be fast or slow, or it could be interpreted as a degree of being fast.  Once there is evidence, the probability and thus the market price of the value will either rise or decline, depending on the evidence and thus the value of holding shares (if you will) in the speed of Anna will rise or decline, depending on the evidence and depending on others beliefs:

;; Probability of being fast, market

;(Predicate "is-honest" (stv 0.8 1))
;(show-cnts)
(cog-execute! (GetLink
      (AndLink
           (EvaluationLink (Predicate "has-account")   (ListLink
(Variable "$X")))
           (EvaluationLink (PredicateNode "points")
                    (ListLink (Variable "$X") (NumberNode 100000)))
            (Inheritance (VariableNode "$X") (ConceptNode "animal"))))) 
