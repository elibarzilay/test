#lang pl 02

(: foo : Number -> Number)
(define (foo n)
  (* n 8))

(test (foo 1) => 8)
