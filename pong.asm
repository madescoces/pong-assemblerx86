.8086
.model large
.stack 100h

extrn clearBUFFER:far
extrn putVIDEOM:far
extrn sleep:far
extrn drawRECTANGLE:far

.data
    ballWidth dw 0
    ballHeigth dw 0
    ballLEFT dw 160
    ballRIGHT dw 165
    ballTOP dw 100
    ballBOT dw 105
    cBall dw 2
    ballVELX dw 01h
    ballVELY dw 01h

    anchowin dw 319
    altowin dw 199
    ;*------atributo de los dos pads------*
    padWidth dw 0
    padHeigth dw 0
    padVEL dw 1
    cPad dw 5 ;color del pad01
    ;*------atributo de los dos pads------*
    ;pad01
    pad01LEFT dw 30 
    pad01RIGTH dw 35
    pad01TOP dw 69
    pad01BOT dw 99
    ;pad01TOPTHIRD dw 80
    ;pad01BOTTHIRD dw 100  
    ;pad 02 mismos atributos que el pad 01
    pad02LEFT dw 284
    pad02RIGHT dw 289
    pad02TOP dw 69
    pad02BOT dw 99


.code

main PROC FAR
    mov ax, @data
    mov ds, ax
    
    mov ah, 0                       ;Seteo de video mode al 13h 320x200 256 colores
    mov al, 13h
    int 10h
    
    mov ax, ballRIGHT
    sub ax, ballLEFT
    mov ballWidth, ax

    mov ax, ballBOT            
    sub ax, ballTOP
    mov ballHeigth, ax         

    mov ax, pad01RIGTH
    sub ax, pad01LEFT          
    mov padWidth, ax

    mov ax, pad01BOT
    sub ax, pad01TOP
    mov padHeigth, ax

    checktime:
        mov cl, 06h
        call sleep
        
        push seg buff
        pop es
        mov dx, 0
        call clearBUFFER

        call moveBALL
        call movePAD01
        call movePAD02
        call collider_Bar_left 
        call loser_left

        ;imprime pelota en pantalla
        mov ax, seg buff
        push ax
        mov ax, ballWidth
        push ax
        mov ax, ballHeigth
        push ax
        mov ax, ballTOP
        push ax
        mov ax, ballLEFT
        push ax
        mov ax, cBall
        push ax
        
        xor al, al 
        call drawRECTANGLE

                ;imprime el pad01
        mov ax, seg buff
        push ax
        mov ax, padWidth
        push ax
        mov ax, padHeigth
        push ax
        mov ax, pad01TOP
        push ax
        mov ax, pad01LEFT
        push ax
        mov ax, cPad
        push ax
        
        xor al, al 
        call drawRECTANGLE
        
        ;imprime el pad 02
        mov ax, seg buff
        push ax
        mov ax, padWidth
        push ax
        mov ax, padHeigth
        push ax
        mov ax, pad02TOP
        push ax
        mov ax, pad02LEFT
        push ax
        mov ax, cpad
        push ax
        
        xor al, al 
        call drawRECTANGLE

        mov ah, 02
        mov dl, al
        int 21
        ;pauser:
        ;   cmp al, 00h 
        ;  je pauser 
           
        mov ax, 0a000h
        mov bx, seg buff 
        mov dx, 320*200
        call putVIDEOM

        
        jmp checktime

        mov ax, 4c00h
        int 21h
main ENDP

moveBALL proc far
    push ax bx cx dx
    mov ax, ballVELX            ; muevo la ball en X
    add ballLEFT, ax 
    add ballRIGHT, ax

    cmp ballLEFT, 0
    jle negballVELX
       
    mov ax, anchowin
    cmp ballRIGHT, ax
    jge negballVELX
    
    mov ax, ballVELY           
    add ballTOP, ax
    add ballBOT, ax

    cmp ballTOP, 0
    jle negballVELY
    
    mov ax, altowin
    cmp ballBOT, ax
    jge negballVELY
    
    jmp salirBALL

    negballVELX:
        neg ballVELX  
        jmp salirBALL

    negballVELY:
        neg ballVELY
        jmp salirBALL

    salirBALL:
        pop dx cx bx ax
        ret
moveBALL endp

movePAD01 proc far
    push ax bx cx dx
    mov dx, padVEL
    
    in al, 60h
    ;jz salirPAD

    cmp al, 11h
    je arriba

    cmp al, 1fh
    je abajo

    jmp salirPAD

    arriba:
        dec pad01TOP
        dec pad01BOT  ;decrementamos los pads para mover el hitbox de estos mismos
        cmp pad01TOP, 0 ;si la ref del pad en la fila alta es un numero negativo hay qeu fixearlo
        jl fixbarup
        cmp dx, 0
        je salirPAD
        dec dx
        jmp arriba

    abajo:
        inc pad01TOP
        inc pad01BOT
        mov ax, altowin
        cmp pad01BOT, ax
        jg fixbardown
        cmp dx, 0
        je salirPAD
        dec dx
        jmp abajo

    salirPADinter:
        jmp salirPAD

    fixbarup:
        mov pad01TOP, 0 ;lo posiciono en el pixel 0 a la ref del pad superior
        mov ax, padHeigth ; le pasamos la alutra del pad a ax
        mov pad01BOT, ax ;y posiciono la ref del pad inferior en la altura predefinida
        jmp salirPAD


    fixbardown:
        mov ax, altowin ;muevo el alto de la ventana
        mov pad01BOT, ax    ;muevo el alto de la ventana a la referencia de la poscicion de la barra inferior
        sub ax, padHeigth ; le resto la altura del pad a el ancho de la ventana
        mov pad01TOP, ax
        jmp salirPAD

    salirPAD:
        pop dx cx bx ax
        ret 
movePAD01 endp

    
movePAD02 proc far
    push ax bx cx dx
    mov dx, padVEL

    in al, 60h

    cmp al, 72
    je arriba2

    cmp al, 80
    je abajo2

    jmp salirPAD2

    arriba2:
        dec pad02TOP
        dec pad02BOT  
        cmp pad02TOP, 0 
    jl fixbarup2
        cmp dx, 0
    je salirPAD2
        dec dx
    jmp arriba2

    abajo2:
        inc pad02TOP
        inc pad02BOT
        mov ax, altowin
        cmp pad02BOT, ax
    jg fixbardown2
        cmp dx, 0
    je salirPAD2
        dec dx
    jmp abajo2

    fixbarup2:
        mov pad02TOP, 0 
        mov ax, padHeigth 
        mov pad02BOT, ax 
    jmp salirPAD2    

    fixbardown2:
        mov ax, altowin ;muevo el alto de la ventana
        mov pad02BOT, ax    
        sub ax, padHeigth ; le resto la altura del pad a el ancho de la ventana
        mov pad02TOP, ax
    jmp salirPAD2

    salirPAD2:
    pop dx cx bx ax
    ret
movePAD02 endp


;funcion: genera la colición contra la barra del lado izquierdo
;parametros:ninguno
;obs: esta funcion va en el main y se trabaja con las etiquetas de las variables
;retorna: nada
;vars_modf: ballVELX
;regs_modf: ax
collider_Bar_left proc far
    push ax bx cx dx
    mov ax, pad01RIGTH
    cmp ballLEFT, ax   ;cmp referencia de la pelota en columna izquierda contra ref pad columna derecha 
    je compar_range   ;si es inferior o igual saltamos (para comparar la ref columna izquierda de la pelota contra la ref columna izquierda de la barra) 
    jmp salirCOLLIDER   ;si la pelota no esta en el rango de la fila de la columna salir 
    compar_range:
        mov ax, pad01TOP
        sub ax, 10   ;le restamos 5 para que no se bugge y atraviese la barra por arriba
        cmp ballTOP, ax ;comparamos la ref superior de la pelota con la ref superior del pad
    jge casi_range  ; si la ref superior de la pelota es igual o mayor a la ref superior del pad saltamos
    jmp salirCOLLIDER ;si no es superior o igual es por que no esta dentro del rango
    casi_range:
        mov ax, pad01BOT
        add ax, 10 
        cmp ballBOT, ax
    jle range ;si es inferior o igual rebota
    jmp salirCOLLIDER ;si no es inferior o igual sale
    range:
        neg ballVELX ; hacemos complementoA2 a la velocidad de las filas para que en vez de restar empize a sumar a las columnas de ball y cambie la direccion
    salirCOLLIDER:
        pop dx cx bx ax
        ret
collider_Bar_left endp

collider_Bar_right proc far
    push ax bx cx dx
    mov ax, pad02RIGHT
    cmp ballLEFT, ax   ;cmp referencia de la pelota en columna izquierda contra ref pad columna derecha 
    je compar_range   ;si es inferior o igual saltamos (para comparar la ref columna izquierda de la pelota contra la ref columna izquierda de la barra) 
    jmp salirCOLLIDER1   ;si la pelota no esta en el rango de la fila de la columna salir 
    compar_range1:
        mov ax, pad02TOP
        sub ax, 10   ;le restamos 5 para que no se bugge y atraviese la barra por arriba
        cmp ballTOP, ax ;comparamos la ref superior de la pelota con la ref superior del pad
    jge casi_range1  ; si la ref superior de la pelota es igual o mayor a la ref superior del pad saltamos
    jmp salirCOLLIDER1 ;si no es superior o igual es por que no esta dentro del rango
    casi_range1:
        mov ax, pad02BOT
        add ax, 10 
        cmp ballBOT, ax
    jle range1 ;si es inferior o igual rebota
    jmp salirCOLLIDER1 ;si no es inferior o igual sale
    range1:
        neg ballVELX ; hacemos complementoA2 a la velocidad de las filas para que en vez de restar empize a sumar a las columnas de ball y cambie la direccion
    salirCOLLIDER1:
    pop dx cx bx ax
    ret
collider_Bar_right endp

;funcion: devuelve la pelota al centro cunado la ref a la columna de la posi de la pelota izquierda llega a la columna 0
;parametros:ninguno
;obs: esta funcion va en el main y se trabaja con las etiquetas de las variables
;retorna: nada
;vars_modf: ballLEFT,ballRIGHT,ballTOP,ballBOT
;regs_modf: 
loser_left proc far
    push ax bx cx dx
    cmp ballLEFT, 0
    je resetball_loser_left
    jmp fin_loser_left
    resetball_loser_left:
        mov ballLEFT, 160
        mov ballRIGHT, 165
        mov ballTOP, 100
        mov ballBOT, 105
    fin_loser_left:
    pop dx cx bx ax
    ret
loser_left endp

.fardata black                      ; Segmento donde guardo el double buffer
    buff db 64000 dup (0) 
black ends


end