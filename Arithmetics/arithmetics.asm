name "add-2"

; this example calculates the sum of a vector with
; another vector and saves result in third vector.

; you can see the result if you click the "vars" button.
; set elements for vec1, vec2 and vec3 to 4 and show as "signed".

org 100h

jmp main

DATA:

first_arg   dw -1h
second_arg  dw -1h



CODE:

main:

push    first_arg
push    second_arg
call    sum
call    sub2
call    mul2
add     sp, 4
mov     bx, ax
mov     ax, 0



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
    
    mov     bx, [bp + 4]
    mov     cx, [bp + 6]
    
    ;; if cx is 0 nothing to add   (this is alsso stopping conditiob for recursion)
    and     cx, 0ffh
    jz      end
    
    mov     ax, cx
    
    and     cx, bx 
    shl     cx ,1  ;; shifted and is the carry on
    xor     ax, bx ;; xor is the addition without carry on
    
    
    ;; add the carry on and the addition without carry on
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




;; --------------------------------------------------------------------
;; function name:   sub2
;; purpose:         implement subtraction
;; input:
;;      - first_argument:   first argument for the sub function
;;      - second_argument:  second argument for sub function
;; --------------------------------------------------------------------
sub2:       
    ;; stack initialization:
    push    bp
    mov     bp, sp       
    
    ;; register preservation
    push    bx
    push    cx
    
    mov     bx, [bp + 6] ; first argument
    mov     cx, [bp + 4] ; second argument
    
    neg     cx
    
    push    bx
    push    cx
    call    sum
    add     sp, 4
    
    
    ;;register preservation
    pop     cx
    pop     bx
    
    
    
    ;; stack restoration:
    mov sp, bp
    pop bp
    ret

 ;; --------------------------------------------------------------------
;; function name:   mul2
;; purpose:         implement multiply
;; input:
;;      - first_argument:   first argument for the mul2 function
;;      - second_argument:  second argument for mul2 function
;; --------------------------------------------------------------------
mul2:       
    ;; stack initialization & register preservation:
    push    bp
    push    cx
    push    bx
    mov     bp, sp
    sub     sp, 2 ; 1 local variable
    
    mov     bx, [bp + 10] ; first argument
    mov     cx, [bp + 8]  ; second argument
    mov     ax, 0
    
    
    ;; bitwise addition - if nth bit of cx is 1, then add a<n to the result
bitwise_loop_start:
    ; while bx is not 0:
    and     bx, 0ffh
    jz      after_loop
    
    
    mov     [bp - 2], cx ; save cx for restoration
    and     cx, 1
    jz      bit_is_zero  ; if nth bit is zero, do not add
        
    add     ax, bx
    
bit_is_zero:
    mov     cx, [bp - 2] ; restore cx
    shr     cx, 1  ; prepare cx for next loop (to check next bit of cx)
    shl     bx, 1  ; prepare bx for next loop (multiply by 2)
    jmp     bitwise_loop_start              
    
after_loop:    
    ;; stack restoration:
    mov     sp, bp
    pop     bx
    pop     cx
    pop     bp
    ret

  
  
 ;; --------------------------------------------------------------------
;; function name:   div2
;; purpose:         implement division (numerator/denominator)
;; input:
;;      - dividend:   first argument for the mul2 function
;;      - divisor:  second argument for mul2 function 
;; output:
;;      - division output: stored in ax
;;      - division remainder: stored in dx
;; --------------------------------------------------------------------
div2:       
    ;; stack initialization:
    push    bp
    push    dx
    push    cx
    push    bx
    mov     bp, sp
    sub     sp, 2 ; 1 local variables
    
    mov     dx, [bp + 10]   ; first argument - dx will also be the remainder
    mov     [bp - 2], 0     ; initialize local variable to 0
    
    ;; check if remainder is less than divident (then result is found)
    push    dx
    push    [bp + 8]
    mov     dx, ax
    push    dx
    and     dx, 1000000b ;; ignore all bit other than sign bit
    jnz     found_result_and_remainder
    pop     dx ;; pop doesnot change ZF
    
    mov     cx, 1
    push    [bp + 8]
    push    cx
    call    mul2
    add     sp, 4
    mov     bx, ax ;store result in bx
    
    push    dx
    push    bx
    call    sub2
    add     sp, 4
    mov     dx, ax
    
    cmp     dx, bx
    jl      add_largest_power_of_2
    
    shl     cx, 1
    push    [bp + 8]
    push    cx
    call    mul2
    add     sp, 4
    mov     bx, ax
    
    push    dx
    push    bx
    call    sub2
    add     sp, 4
    mov     dx, ax
    
    
    
    
    
    ;; add the largest power of 2 that cna be added to the disvide result
    add_largest_power_of_2:
    
    add [bp-2], bx
    
    found_result_and_remainder:
    
    
    ;; stack restoration:
    mov sp, bp
    pop bp
    ret




