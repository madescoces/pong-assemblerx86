.8086
.model large
.stack 100h

.data
.code

public drawRECTANGLE
public drawPixel

drawRECTANGLE proc far
    ;   imprime un rectangulo                               | ss:structure
    ;   input:  ip del proceso anterior ->                  | bp0
    ;           valor anterior de bp                        | bp4
    ;           1. color ball                               | bp6
    ;           2. x position                               | bp8
    ;           3. y position                               | bp10
    ;           4. heigth                                   | bp12 
    ;           5. width                                    | bp14
    ;           6. double buffer Address                    | bp16
    ;   output: 1 si terminó de dibujar

    push bp
    mov bp, sp
    push bx cx dx si di

    xor di, di
    xor si, si
    
    mov di, ss:[bp+8]               ;x positon
    mov si, ss:[bp+10]              ;y position
    mov cx, ss:[bp+12]              ;Alto del objeto
file:
    push cx
    mov cx, ss:[bp+14]              ;Ancho del objeto
    column:
        mov bx, ss:[bp+16]          ;Address del buffer de video
        push bx                     
        push di                     ;Push de [x]
        push si                     ;Push de [y]
        mov bx, ss:[bp+6]           ;Color del objeto
        push bx
        call drawPixel
        inc di
    loop column 
    pop cx
    inc si
    mov di, ss:[bp+8]
loop file
    ;xor al, al
    ;inc al

    pop di si dx cx bx bp
    ret 12                                
drawRECTANGLE endp                        

drawPIXEL proc far
    ;   imprime un pixel directamente en la memoria         | ss:structure
    ;   input:  1. double buffer Address                    | bp 12
    ;           2. x                                        | bp 10
    ;           3. y                                        | bp 8
    ;           4. Color                                    | bp 6    
    ;   output:

    push bp
    mov bp, sp
    push ax bx cx dx si ds
    
    push ss:[bp+12]                 ; paso el offset del buffer para poder escribirlo
    pop ds                          ; como es un segmento lo paso al DS para manejar las direcciones

    mov cx, 320                     ; Bytes per line in mode 13h
    mov ax, ss:[bp+8]               ; y
    mul cx                      
    add ax, ss:[bp+10]              ; x
    mov si, ax                      ; paso al registro si el valor de ax que da la pos del pixel
    xor ah, ah
    mov al, ss:[bp+6]               ; color
    mov byte ptr ds:[si], al        ; le pego el color a la posición de memoria que corresponde a X e Y     
    
    pop ds si dx cx bx ax bp
    ret 8
drawPIXEL endp

end