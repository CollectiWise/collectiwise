(use-modules (ice-9 readline)) (activate-readline)
(add-to-load-path "/usr/local/share/opencog/scm")
(add-to-load-path "~/.")
(use-modules (opencog))
(use-modules (opencog query))
(use-modules (opencog exec))

(add-to-load-path ".")
(load-from-path "math.scm")

(define find-humans
    (BindLink
        (VariableNode "$X")
        (InheritanceLink
            (VariableNode "$X")
            (ConceptNode "Human"))
        (ListLink
            (VariableNode "$X"))))

(define (cnt-all)
   (define cnt 0)
   (define (incrm a) (set! cnt (+ cnt 1)) #f)
   (define (cnt-type x) (cog-map-type incrm x)) 
   (map cnt-type (cog-get-types))
   cnt
)

; note that this function only prints things and returns nothing:

(define (show-cnts)
  (define (cnt-type ty)
    (let ((cnt 0))
      (define (incrm a) (set! cnt (+ cnt 1)) #f)
      (cog-map-type incrm ty)

       ; printnly the non-zero counts
      (if (< 0 cnt)
        (begin
          (display ty)
          (display "  ")
          (display cnt)
          (newline)
        )
      )
    )
  )
  (for-each cnt-type (cog-get-types))
)

(define (prt-atomspace) 
  (define (prt-atom h) 
    ; print only the top-level atoms.
    (if (null? (cog-incoming-set h)) 
        (display h))   
  #f)
  (define (prt-type type)
    (cog-map-type prt-atom type)
    ; We have to recurse over sub-types
    (for-each prt-type (cog-get-subtypes type))
  )
  (prt-type 'Atom)                          
)

(define (killall lst) 
   (if (null? lst) 
       '() 
       (cons (cog-delete (car lst)) 
             (killall (cdr lst)))))

; before Atoms are added:
(print (cnt-all))
(show-cnts)
(prt-atomspace)

;(cog-new-node 'ConceptNode "some node name")
;(ConceptNode "some node name")

; Return the strength of a simple truth value
(define (get-tv-strength tv) (cdr (assoc 'mean (cog-tv->alist tv))))
 
; Return the confidence of a simple truth value
(define (get-tv-confidence tv) (cdr (assoc 'confidence (cog-tv->alist tv))))
 
; Return the strength of the truth value on atom h
(define (cog-stv-strength h) (get-tv-strength (cog-tv h)))
 
; Return a truth value where the strength was multiplied by 'val'
(define (scale-tv-strength val tv)
  (cog-new-stv
    (* val (get-tv-strength tv))
    (get-tv-confidence tv)
  )
)
 
; On atom h, multiply the truth-value strength by 'val'
(define (scale-strength h val)
  (cog-set-tv! h (scale-tv-strength val (cog-tv h)))
)
 
; Return the truth value strength of an atom
(define (cog-tv-strength x) (cdr (assoc 'mean (cog-tv->alist (cog-tv x)))))
 
; Given a threshold 'y' and a list of atoms 'z', returns a 
; list of atoms with truth value strength above the threshold
(define (cog-tv-strength-above y z) (filter (lambda (x) (> (cog-tv-strength x) y)) z))

; after an Atom is added:
(print (cnt-all))
(show-cnts)
(prt-atomspace)
