#lang racket
;; code from mode.rkt
(define prompt?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

;; main loop
(define (main history next-id)
  (when prompt?
    (display "input ('quit' to exit): "))

  (let ([in (read-line)])
    (cond
      ;; 1. base case
      [(eof-object? in) (void)]
      [(equal? in "quit") (displayln "Program exited.")]
      [else
       (let ([result (with-handlers ([exn:fail? (lambda (e) 'error)])
                       ;; call tokenize
                       (let* ([tokens (tokenize in)]
                              [res (eval-expr tokens history)]
                              [val (car res)]
                              [rem (cadr res)])
                         (unless (null? rem)
                           (error "Error: tokens remaining")) val))])
         (if (equal? result 'error)
             (begin
               (displayln "Error: Invalid Expression")
               (main history next-id))
             (begin
               ;; print "id: result"
               (display next-id)
               (display ": ")
               (displayln (real->double-flonum result))
               ;; recursive loop: add new result to hisotry and increment id by 1
               (main (cons result history) (+ next-id 1)))))])))

;; chars = a list of chars
(define (read-digits chars)
  ;; recursive loop | acc = an accumulator stores consecutive numbers
  (define (loop chars acc)
    (cond
      ;; when no more chars (empty)
      [(null? chars)
       ;; reverse b/c of "cons (car chars) acc"
       (values (list->string (reverse acc)) '() )]
      
      ;; when first char (car chars) is a number (char-numeric?)
      [(char-numeric? (car chars))
       ;; recursive call (chars = remaining chars | put first char into acc)
       (loop (cdr chars) (cons (car chars) acc))]
      
      [else
       ;; when first char is a non-number char
       (values (list->string (reverse acc)) chars)]))

  ;; start a loop with an empty accumulator
  (loop chars '()))

(define (tokenize str)
  (define (loop chars acc)
    (cond
      ;; no more chars -> complete
      [(null? chars)
       (reverse acc)]

      ;; first char is whitespace-> skip
      [(char-whitespace? (car chars))
       (loop (cdr chars) acc)]

      ;; expression | first char =? + OR * OR / OR -
      [(member (car chars) '(#\+ #\* #\/ #\-))
       (loop (cdr chars) (cons (string (car chars)) acc))]

      ;; history: $ + num
      [(char=? (car chars) #\$) ; first char =? $
       (let-values ([(digits rest) (read-digits (cdr chars))])
         (when (string=? digits "")
           (error "Error: tokenize - id does not have id number"))
         (loop rest (cons (string-append "$" digits) acc)))]

      ;; number
      [(char-numeric? (car chars))
       (let-values ([(digits rest) (read-digits chars)])
         (loop rest (cons digits acc)))]

      ;; unknown
      [else
       (error (format "Error: tokenize - unknown character '~a'" (car chars)))]))

  ;; convert string to a list and start a loop with an empty accumulator
  (loop (string->list str) '()))

(define (eval-expr tokens history)
  (when (null? tokens)
    (error "Error: incomplete expression"))

  (let ([tok (car tokens)]
        [rest (cdr tokens)])
    (cond
      ;; if binary operation
      [(member tok '("+" "*" "/"))
       (let* ([L (eval-expr rest history)]
              [L-val (car L)] [L-rem (cadr L)]
              [R (eval-expr L-rem history)]
              [R-val (car R)] [R-rem (cadr R)])
         (list (cond
                 [(equal? tok "+") (+ L-val R-val)]
                 [(equal? tok "*") (* L-val R-val)]
                 [(equal? tok "/")
                  (when (= R-val 0) (error "Error: cannot divide by 0"))
                  (quotient L-val R-val)]) R-rem))]

      ;; unary operation
      [(equal? tok "-")
       (let* ([sub (eval-expr rest history)]
              [sub-val (car sub)]
              [sub-rest (cadr sub)])
         (list (- sub-val) sub-rest))]

      ;; history
      [(and (> (string-length tok) 1)
            (char=? (string-ref tok 0) #\$))
       (let* ([idx (string->number (substring tok 1))]
              [rev-hist (reverse history)])
         (when (or (not idx) (< idx 1) (> idx (length rev-hist)))
           (error "Error: The history id does not exist"))
         (list (list-ref rev-hist (- idx 1)) rest))]

      ;; number
      [(string->number tok) => (lambda (n) (list n rest))]

      ;; unknown token
      [else
       (error (format "Error: unknown token: '~a'" tok))])))
        
(main '() 1)