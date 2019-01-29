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

(define (is-a x y p); users should be allowed to make such statements, either probabilistically or certainly (maybe using voting) 
	(ListLink
   		(InheritanceLink (stv p 1)
      			(ConceptNode x)
      			(ConceptNode y)
   		)
   	
   	)
)

(define (is_symmetric predicate x y p)
	(ImplicationScope (stv p 1)
   		(Evaluation
      			(PredicateNode predicate)
      			(List
         			(ConceptNode x)
         			(ConceptNode y))
		)
   		(Evaluation
      			(PredicateNode predicate)
      			(List
         			(ConceptNode y)
				(ConceptNode x))
		)
	)
)
