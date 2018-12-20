(load "/home/ubuntu/collectiwise/load_all.scm")

(define p (PredicateNode "p" (stv 0.6 1)))
(cog-execute! negation-introduction-rule)
(print (Not p))
