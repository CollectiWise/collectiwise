
(define (print x) (display x) (newline))

(define (square x) (* x x))
(define (average x y)
  (/ (+ x y) 2))

(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))

(define (list_sum lst) (let ((x lst))
   (do ((x x (cdr x))
        (sum 0 (+ sum (car x ))))
       ((null? x) sum))))

(define (list_min lst)
    (cond ((null? (cdr lst)) (car lst))
          ((< (car lst) (list_min (cdr lst))) (car lst))
          (else (list_min (cdr lst)))) )

(define (list_max lst)
    (cond ((null? (cdr lst)) (car lst))                
        ((> (car lst) (list_max (cdr lst))) (car lst))
	(else (list_max (cdr lst)))) )

(print (sqrt 9))
(print (list_sum (list 1 2 2)))
(print (average 3 4)) 
(print (square 3)) 
