name "add-2"

; this example calculates the sum of a vector with
; another vector and saves result in third vector.

; you can see the result if you click the "vars" button.
; set elements for vec1, vec2 and vec3 to 4 and show as "signed".

org 100h

jmp main

DATA:

first_arg   dw 14
second_arg  dw -10



CODE:

main:

push    first_arg
push    second_arg
call    sum
add     sp, 4



int     21h

;; --------------------------------------------------------------------
;;                              Functions:  
;; --------------------------------------------------------------------



;; --------------------------------------------------------------------
;; function name:   add2
;; purpose:         implement addition
;; input:
;;      - first_argument:   first argument for the addition
;;      - second_argument:  second argument for addition
;; --------------------------------------------------------------------
sum:       
    ;; stack initialization:
    push    bp
    mov     bp, sp       
    
    ;; register preservation:
    push    cx
    push    bx
    
    mov     cx, [bp + 6]
    mov     bx, [bp + 4]
    
    cmp     cx, 0
    je      end
    
    mov     ax, cx
    
    and     cx, bx
    shl     cx ,1
    xor     ax, bx
    
    push    cx
    push    ax
    call    sum
    add     sp, 4
    
    
    end:
    pop     bx
    pop     cx
    
    
    ;; stack restoration:
    mov sp, bp
    pop bp
    ret





