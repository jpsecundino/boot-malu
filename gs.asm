    org 0x7c00
 
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp init
    
enter_number:
    db 'Enter a number: ', 0x0
invalid:
    db 0xd, 0xa, 'This number is too large. Try another one: ', 0x0
prime:
    db 0xd, 0xa, 'The number is prime', 0xd, 0xa, 0x0
composite:
    db 0xd, 0xa, 'The number is composite', 0xd, 0xa, 0x0
one:
    db 0xd, 0xa, 'The number is one', 0xd, 0xa, 0x0
zero:
    db 0xd, 0xa, 'The number is zero', 0xd, 0xa, 0x0
    
;; bx = string address
print_str:
    push bx
    
    mov ah, 0xe
print_str_loop:
    mov al, [bx]
    add bx, 0x1
    cmp al, 0x0
    je print_str_end
    int 0x10
    jmp print_str_loop
print_str_end:
    pop bx
    ret
    
;; bx <- integer read
read_int:
    push cx
read_int_start:
    mov bx, 0x0
read_int_loop:
    mov ah, 0x0
    int 0x16
    cmp al, 0xd
    je read_int_end
    cmp al, '0'
    jl read_int_loop
    cmp al, '9'
    jg read_int_loop
    mov ah, 0xe
    int 0x10
    movzx cx, al
    sub cx, '0'
    imul bx, 0xa
    jo read_int_overflow
    add bx, cx
    jo read_int_overflow
    jmp read_int_loop
read_int_overflow:
    mov bx, invalid
    call print_str
    jmp read_int_start
read_int_end:
    pop cx
    ret
    
;; cx = 1 if bx divides ax, 0 otherwise
is_divisible:
    push ax
    cmp ax, 0
    je is_divisible_true
is_divisible_loop:
    cmp ax, bx
    je is_divisible_true
    jl is_divisible_false
    sub ax, bx
    jmp is_divisible_loop
is_divisible_true:
    mov cx, 1
    jmp is_divisible_end
is_divisible_false:
    mov cx, 0
    jmp is_divisible_end
is_divisible_end:
    pop ax
    ret
    
;; ax = integer
check_prime:
    push ax
    push bx
    
    cmp ax, 0
    jl check_prime_end
    je check_prime_zero
    cmp ax, 1
    je check_prime_one
    mov bx, 2
check_prime_loop:
    cmp bx, ax
    je check_prime_prime
    call is_divisible
    cmp cx, 1
    je check_prime_composite
    add bx, 1
    jmp check_prime_loop
check_prime_zero:
    mov bx, zero
    call print_str
    jmp check_prime_end
check_prime_one:
    mov bx, one
    call print_str
    jmp check_prime_end
check_prime_composite:
    mov bx, composite
    call print_str
    jmp check_prime_end
check_prime_prime:
    mov bx, prime
    call print_str
    jmp check_prime_end
check_prime_end:
    pop bx
    pop ax
    ret

init:
    mov bx, enter_number
    call print_str
    call read_int
    mov ax, bx
    call check_prime
    jmp init
    
    times 510 - ($-$$) db 0
    dw 0xaa55