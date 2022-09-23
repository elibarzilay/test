#lang pl 02

(: foo : Number -> Number)
(define (foo n)
  (+ n 7))

(test (foo 1) => 8)
