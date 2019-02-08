(load "/home/ubuntu/collectiwise/math.scm")

;utility functions that are repeatedly used by the main functions:
(define (property prop x p)
        (Evaluation
                (PredicateNode prop)
                (List
                        (ConceptNode x)
                        (ConceptNode p)
                 )
        )
)

;basic properties:
(define (has_name x n)
        (property "name" x n)
)

(define (has_desc x d)
        (property "desc" x d)
)

(define (is_a x y p); users should be allowed to make such statements, either probabilistically or certainly (maybe using voting)
	(ListLink
   		(InheritanceLink (stv p 1)
      			(ConceptNode x)
      			(ConceptNode y)
   		)

   	)
)

;practical meaning of properties of relations; for terms (shortcut so that PLN doesn't have to do the work
(define (symmetry predicate x y p)
	(AndLink (stv p 1)
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

(define (reflexivity predicate x y p)
     (AndLink (stv p 1)
	(Evaluation
		(PredicateNode predicate)
		(list 
			(ConceptNode x)
			(ConceptNode y)))
	(Evaluation
		(PredicateNode predicate)
		(List 
			(ConceptNode x)
			(ConceptNode x)))
	(Evaluation
		(PredicateNode predicate)
		(List
			(ConceptNode y)
			(ConceptNode y)))
     )        
)

(define (variable_reflexivity predicate p)
        (ImplicationScope (stv p 1)
             (VariableList
                 (TypedVariable
                     (VariableNode "$x")
                     (Type "ConceptNode"))
                  (TypedVariable
                         (VariableNode "$y")
                         (Type "ConceptNode")))

                (Evaluation
                   (PredicateNode predicate)
                       (VariableNode "$x")
                       (VariableNode "$y")) ; y represents any other element in the same hence
                (AndLink
                  (Evaluation
                      (PredicateNode predicate)
                          (VariableNode "$x")
                          (VariableNode "$x"))
                  (Evaluation
                      (PredicateNode predicate)
                          (VariableNode "$y")
                          (VariableNode "$y")))

                      


        )
)

(define (transitivity predicate x y p)
        (Evaluation (stv p 1)
             (PredicateNode predicate)
             (List
	         (ConceptNode x)
                 (ConceptNode y))
	         ;run PLN logic here to resolve all triadic relations.
         )
)

;properties of relations that are not caught by our initial encoding and have to be worked out by PLN:
(define (variable_symmetry predicate p)
        (ImplicationScope (stv p 1)
             (VariableList
                 (TypedVariable
                     (VariableNode "$X")
                     (Type "ConceptNode"))
                 (TypedVariable
                     (VariableNode "$Y")
                     (Type "ConceptNode")))
             (Evaluation
                 (PredicateNode predicate)
                 (List
                     (VariableNode "$X")
                     (VariableNode "$Y")))
             (Evaluation
                 (PredicateNode predicate)
                 (List
                     (VariableNode "$Y")
                     (VariableNode "$X")))
        )
)



(define (variable_transitivity predicate p)
        (ImplicationScope (stv p 1)
            (VariableList
                (TypedVariable
                    (VariableNode "$A")
                    (Type "ConceptNode"))
                (TypedVariable
                    (VariableNode "$B")
                    (Type "ConceptNode"))
                (TypedVariable
                (VariableNode "$C")
                    (Type "ConceptNode"))

             )
             (AndLink
                (Evaluation
                        (PredicateNode predicate)
                        (List
                                (VariableNode "$A")
                                (VariableNode "$B"))
                )
                (Evaluation
                        (PredicateNode predicate)
                        (List
                                (VariableNode "$B")
                                (VariableNode "$C"))
                )
            )
            (Evaluation
                      (PredicateNode predicate)
                      (List
                           (VariableNode "$A")
                           (VariableNode "$C"))

             )
           )
)
