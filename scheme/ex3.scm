(define ** expt)
(define diff
    (lambda (form)
        (cond   ((number? form) list 0)
                ((eqv? form 'x) list 1)
                ((eqv? (car form) '+) (cons '+ (map diff (cdr form))))
                ((eqv? (car form) '-) (cons '- (map diff (cdr form))))
                ((eqv? (car form) '*) `(+ (* ,(cadr form) ,(diff (caddr form))) (* ,(diff (cadr form)) ,(caddr form))))
                ((eqv? (car form) '**) `(* ,(caddr form) (* ,(diff (cadr form)) (** ,(cadr form) ,(- (caddr form) 1)))))
        )
    )
)

(diff 'x)
(diff '(+ x 5))
(diff '(+ (** x 3) (* 2 x) 4))
(diff '(** (* x 3) 2))
(diff '(* (+ x 2) (- (** x 2) x)))

(define tangent 
    (lambda (form a) 
        (let (
            (fx ((eval `(lambda (x) ,form) (interaction-environment)) a))
            (fdx ((eval `(lambda (x) ,(diff form)) (interaction-environment)) a))
            )
            `(+ (* ,fdx x) ,(- fx (* fdx a)))
        )
    )
)

(tangent '(+ (** x 3) (* -2 (** x 2)) 9) 2)

(define diff2
    (lambda (form val)
        (cond   ((number? form) list 0)
                ((eqv? form val) list 1)
                ((symbol? form) list 0) 
                ((eqv? (car form) '+) (cons '+ (map (lambda (f) (diff2 f val)) (cdr form))))
                ((eqv? (car form) '-) (cons '- (map (lambda (f) (diff2 f val)) (cdr form))))
                ((eqv? (car form) '*) `(+ (* ,(cadr form) ,(diff2 (caddr form) val)) (* ,(diff2 (cadr form) val) ,(caddr form))))
                ((eqv? (car form) '**) `(* ,(caddr form) (* ,(diff2 (cadr form) val) (** ,(cadr form) ,(- (caddr form) 1)))))
        )
    )
)

(diff2 'x 'x)
(diff2 'y 'x)
(diff2 '(+ y z) 'z)
(diff2 '(* x y) 'x)

(define non-zero-list
    (lambda (lst)
        (cond   ((null? lst) '())
                ((equal? (car lst) '0) (non-zero-list (cdr lst)))
                (else (cons (car lst) (non-zero-list (cdr lst))))
        )
    )
)

(define simple+
    (lambda (lst)
        (cond   ((null? (non-zero-list (map simple lst))) '0)
                ((null? (cdr (non-zero-list (map simple lst)))) (car (non-zero-list (map simple lst))))
                (else (cons '+ (non-zero-list (map simple lst))))
        )
    )
)

(define simple-
    (lambda (lst)
        (cond   ((null? (non-zero-list (cdr lst))) (car (map simple lst)))
                (else (cons '-  (cons (car (map simple lst)) (non-zero-list (map simple (cdr lst))))))
        ) 
    )
)

(define simple*
    (lambda (lst)
        (let (
                (p (simple (car lst)))
                (q (simple (cadr lst)))
            )
            (cond       ((equal? p '0) '0)
                        ((equal? q '0) '0)
                        ((equal? p '1) q)
                        ((equal? q '1) p)
                        (else (cons '* (map simple lst)))   
            )
        )
    )
)

(define simple**
    (lambda (lst)
        (let (
                (p (simple (car lst)))
                (q (simple (cadr lst)))
            )
            (cond   ((equal? q '0) '1)
                    ((equal? q '1) p)
                    (else (cons '** (map simple lst)))   
            )
        )
    )
)

(define simple
    (lambda (lst)
        (cond   ((number? lst) lst)
                ((equal? lst 'x) 'x)
                ((equal? (car lst) '+) (simple+ (cdr lst)))
                ((equal? (car lst) '-) (simple- (cdr lst)))
                ((equal? (car lst) '*) (simple* (cdr lst)))
                ((equal? (car lst) '**) (simple** (cdr lst)))
                (else lst)
        )
    )
)

(simple (diff '(+ x 3)))
(simple (diff '(+ (** x 2) (* 4 x) 5)))
(simple (diff '(- (** x 2) (* 4 x) 5)))