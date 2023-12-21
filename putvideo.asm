.8086
.model large
.stack 100h

.data
.code

public putVIDEOM

putVIDEOM proc far
	;    copia el buffer en la memoria de video
    ;    input:  1. BX <- offset del buffer de video
    ;            2. AX <- dirección de memoria de video físico 
    ;            3. DX <- formato de video para cálculo 
    ;    output: memoria de video actualizada
    push ax bx cx dx di si es ds
   
    push bx
    pop ds
    xor si, si              ;ds:si -> frame buffer (origen) 
   
    push ax
    pop es
    xor di, di              ;es:di -> video memory (destino)

    shl dx, 1
    mov cx, dx              ;escribe 32,000 palabras como pixels
            
                            ;If vert. retrace bit is set, wait for it to clear
    mov dx, 3dah            ;dx <- puerto que indica el estado de la VGA 

vret_set:
    in al, dx               ;al <- byte de estado
    and al, 8               ;mascara para ver si esta encendido el bit 3
    jnz vret_set            ;si esta encendido, espera a que se limpie

vret_clr:                   ;cuando esta limpio espera a que se encienda.
    in al, dx
    and al, 8
    jz vret_clr

    rep movsw               ;pisa la memoria de video, buffer->video 
    
    pop ds es si di dx cx bx ax
    ret
putVIDEOM endp
end