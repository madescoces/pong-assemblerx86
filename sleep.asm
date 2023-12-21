;----------------------------------------------------------------------------
; delay con tiempo predeterminado, por registro cl
; 1. -> 1sec: 	CX:000fh + DX:4240h
; 2. -> 500ms: 	CX:0007h + DX:a120h
; 3. -> 250ms: 	CX:0003h + DX:d090h
; 4. -> 100ms: 	CX:0001h + DX:86a0h
; 5. -> 50ms: 	CX:0000h + DX:c350h
; 6. -> 10ms: 	CX:0000h + DX:2710h
; 7. -> 1ms: 	CX:0000h + DX:03e8h
; no devuelve valor
;----------------------------------------------------------------------------
.8086
.model large
.stack 100h

.data
.code

public sleep

sleep proc far
	push ax cx dx
	
	mov al, 00h
	mov ah, 86h

	cmp cl, 01h 
	je uno
	cmp cl, 02h 
	je dos
	cmp cl, 03h 
	je tres
	cmp cl, 04h 
	je cuatro
	cmp cl, 05h 
	je cinco
	cmp cl, 06h 
	je seis
	cmp cl, 06h 
	je siete
	jmp close

uno:	
	mov cx, 000fh
	mov dx, 4240h
	jmp set
dos:
	mov cx, 0007h
	mov dx, 0a120h
	jmp set
tres:
	mov cx, 0003h
	mov dx, 0d090h
	jmp set
cuatro:
	mov cx, 0001h
	mov dx, 86a0h
	jmp set
cinco:
	mov cx, 0000h
	mov dx, 0c350h
	jmp set
seis:
	mov cx, 0000h
	mov dx, 2710h
	jmp set
siete:
	mov cx, 0000h
	mov dx, 03e8h
	jmp set

set:	
	int 15h
close:	
	pop dx cx ax
	ret
sleep endp
end