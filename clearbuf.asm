.8086
.model large
.stack 100h

.data
.code

extrn sleep:far
public clearBUFFER

clearBUFFER PROC FAR
	;    limpia el buffer
    ;    input:  1. BX <- dirección del buffer de video
    ;            2. DX <- offset desde el que borrar
    ;    output: buffer clear
    push ax bx cx di 
    
    mov di, dx
    xor al, al
    mov cx, 64000
    rep stosb
   
    pop di cx bx ax
    ret
clearBUFFER endp
end