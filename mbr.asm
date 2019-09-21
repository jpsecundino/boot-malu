org 0x7c00

xor 	ax, ax
mov 	ds, ax
mov 	es, ax
mov 	fs, ax
mov 	gs, ax
jmp 	init

;Strings 
start1: 	db 'So you traveled abroad and have no idea what to wear today?', 0xd, 0xa, 0x0
start2: 	db 'We can help you build your look of the day!', 0xd, 0xa, 0x0
temp:		db 'What is the local temperature?', 0xd, 0xa, 0x0

v_sunny_msg:	db 'Hotter than hell! You can wear your bikini today!', 0xd, 0xa, 0x0
sunny_msg:		db 'Good day to wear shorts and a t-shirt', 0xd, 0xa, 0x0
cold_msg:		db 'Do not leave without a coat!', 0xd, 0xa, 0x0
v_cold_msg:		db 'Wear at least 3 layers of clothes today!', 0xd, 0xa, 0x0

nl:	db 0xd, 0xa, 0x0

init:
	mov 	ah, 0xe		; Configure BIOS teletype mode

	mov		bx, start1
	call 	print_string 
	
	mov		bx, start2
	call 	print_string 

	mov bx, temp
	call print_string

	call read_input
	mov dx, bx			; dx guarda o valor da temperatura

	mov bx, nl
	call print_string

	jmp c_to_f

	jmp init

;	mov 	bx, 0		; May be 0 because org directive.
;	jmp 	stop

;; ---------------------------------------
;; ---- Celsius to Fahrenheit ------------
;; ---------------------------------------
c_to_f:
	push ax	;; auxiliar
	push cx ;; auxiliar
	push dx	;; valor da temp

	mov cx, 0x2
	mov ax, dx		;; ax armazena temporariamente 
	mul cx			;; ax = ax * cx

	add ax, 0x20	;;

	mov cx, ax
	cmp cx, 0x44	;; compara o resultado da conversao com 68ºF (20ºC)
	jle winter		;; break se menor que 68ºF
	jg summer		;; break se maior que 68ºF

	pop dx
	pop cx
	pop ax

	ret

summer:
	cmp cx, 0x5F
	jge very_hot
	jl hot
	ret

winter:
	cmp cx, 0x35
	jl very_cold
	jge cold
	ret

;; ---------------------------------------
;; ---- Print very sunny weather message ------
;; ---------------------------------------
very_hot:
	mov bx, v_sunny_msg
	call print_string
	ret

;; ---------------------------------------
;; ---- Print sunny weather message ------
;; ---------------------------------------
hot:
	mov bx, sunny_msg
	call print_string
	ret

;; ---------------------------------------
;; ---- Print cold weather message ------
;; ---------------------------------------
cold:
	mov bx, cold_msg
	call print_string
	ret

;; ---------------------------------------
;; ---- Print very cold weather message ------
;; ---------------------------------------
very_cold:
	mov bx, v_cold_msg
	call print_string
	ret

;; ---------------------------------------
;; ---- Prints some string ----------------
;; parameters:
;;	bx: string 
;; ---------------------------------------
print_string:
	push 	ax
	push 	bx

loop_print:
	mov 	al, [bx]
	
	cmp 	al, 0x0
	je 		end_loop_print

	call 	put_char
	add 	bx, 0x1
	
	jmp 	loop_print

end_loop_print:
	pop 	bx
	pop 	ax
	ret

;; ---------------------------------------
;; ---- Reads input ----------------------
;; ---------------------------------------
read_input:
	push ax
	push cx

	mov bx, 0
	
loop_read_input:
	mov ah, 0x0
	int 0x16

	cmp al, 13
	je end_loop_read_input

	mov ah, 0xe
	int 0x10

	movzx dx, al
	sub dx, '0'

	imul bx, 0xa
	add bx, dx

	jmp loop_read_input

end_loop_read_input:
	pop cx
	pop ax
	ret

;; ---------------------------------------
;; ---- Prints one char ------------------
;; ---------------------------------------
put_char:
	push 	ax

	mov 	ah, 0x0e
	int 	0x10

	pop 	ax
	ret

stop:
	jmp stop

times 510 - ($-$$) db 0
dw 0xaa55