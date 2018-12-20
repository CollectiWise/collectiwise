
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


(print (square 3))
(print (average 3 4))
(print (sqrt 9))
(print (list_sum (list 1 2 2)))
