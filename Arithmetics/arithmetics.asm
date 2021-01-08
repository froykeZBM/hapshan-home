

;; --------------------------------------------------------------------
;; file name:   arithmetic.asm
;; purpose:     implement addition, subtraction multiply and division
;; Author:      Roi Garonfunkel
;; --------------------------------------------------------------------
org 100h

jmp main

DATA:

first_arg   dw 10
second_arg  dw 21



CODE:

main:

push    first_arg
push    second_arg
;call    sum
;call    sub2
;call    mul2
call    div2
add     sp, 4
mov     bx, ax
mov     ax, 0



int     21h

;; --------------------------------------------------------------------
;;                              Functions:  
;; --------------------------------------------------------------------



;; --------------------------------------------------------------------
;; function name:   sum
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
    
    mov     ax, [bp + 4]
    mov     cx, [bp + 6]
    
    ;; if cx is 0 nothing to add   (this is alsso stopping conditiob for recursion)
    and     cx, 0ffffh
    jz      end
    
    mov     bx, cx
    
    and     cx, ax 
    shl     cx ,1  ;; (cx&ax)<<1 is the carry on
    xor     ax, bx ;; xor is the addition_without_carry_on
    
    
    ;; add the carry on and the addition_without_carry_on (recursion)
    push    cx
    push    ax
    call    sum
    add     sp, 4
    
    ;; end of function - equalize stack and restore registers
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
    and     bx, 0ffffh
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
    ;; stack initialization & register preservation:
    push    bp
    push    cx
    push    bx
    mov     bp, sp
    sub     sp, 2 ; 1 local variable - result
    
    mov     dx, [bp + 10]   ; first argument - dx will also be the remainder
    mov     [bp - 2], 0     ; initialize result to 0
    
    
    
    ;; loop on the remainder: each time find largest power of 2 which when multiplies by 
    ;; divident, is less than remainder
    divide_remainder:
    
    ;; check if remainder is less than divident (then result is found)
    mov     cx, 1 ; cx is the number to add to the result
    mov     bx, [bp + 8] ; bx is the divisor multiplied by cx
    
    ;; dx -= bx
    push    dx
    push    [bp + 8]
    call    sub2
    add     sp, 4
    mov     dx, ax
    
    ;; if ax (= dx) is negative than result is found (because previous remainder was smaller
    ;; than cx * divisor
    and     ax, 8000h ;; ignore all bit other than sign bit
    jnz     found_result_and_remainder
         
    
    ;; find the p = max{2^n : (2^n)*(divisor) < remainder}
    ;; basically its a long division.
    find_largest_power_of_2:
    
    ;; dx -= bx
    push    dx
    push    bx
    call    sub2
    add     sp, 4
    mov     dx, ax
    
    ;; check if ax(=dx) is negative
    and     ax, 8000h  ;; ignore all bit other than sign bit
    jnz     add_largest_power_of_2
    
    ;; multiply by 2 cx and bx (to increase them)
    ;; bx is still cx * divisor
    shl     cx, 1
    shl     bx, 1
    
    jmp find_largest_power_of_2    
    
    
    ;; add the largest power of 2 that can be added to the divide result
    add_largest_power_of_2:
    
    ;; dx is negative - adding bx back to get current remainder:
    push    dx
    push    bx
    call    sum
    add     sp, 4
    mov     dx, ax
    
    ;; add the cx (power of 2 which was found) to result
    push    cx
    push    [bp - 2]
    call    sum
    add     sp, 4
    mov     [bp - 2], ax
    
    jmp     divide_remainder
    
    
    
    ;; dx is negative - add divisor which was reduced from dx to get final remainder
    found_result_and_remainder:
    push    dx
    push    [bp + 8]
    call    sum
    add     sp, 4
    mov     dx, ax
    
    mov     ax, [bp - 2]
     
     
    ;; stack restoration:
    mov sp, bp
    pop     bx
    pop     cx
    pop     bp
    ret




