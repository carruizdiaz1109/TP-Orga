global main
extern printf, scanf

;PILA
%macro ALINEAR_PILA 1
    push rbp
    mov rbp, rsp
    sub rsp, %1
%endmacro

%macro DESALINEAR_PILA 0
    add rsp, 16
    leave
    ret
%endmacro

; Macro para recorrer palabra y buscar posiciones en la tabla
%macro RECORRER_PALABRA 0
    ; Inicializamos iterador
    mov dword [iterador], 0
    iterar_palabra:
        ; cargar caracter actual
        mov ecx, [iterador]
        mov al, [palabra + ecx]

        ; cotejamos que no sea el final de palabra
        cmp al, 0
        je fin

        ; Llamar a buscar_posicion (pasar carácter en AL)
        push rsi         ; Guardar registros que usaremos
        push rdi
        push rdx

        lea rsi, [TablaConversion] ; Dirección de la tabla
        call buscar_posicion       ; AL = posición encontrada

        pop rdx          ; Restaurar registros
        pop rdi
        pop rsi

        ; Guardar posición en memoria
        mov ecx, [iterador]       ; Índice actual
        mov [posiciones + ecx], al ; Guardar posición encontrada

        ; imprimir letra y posición
        lea rdi, [informe]
        movzx esi, byte [palabra + ecx]
        movzx edx, al             ; AL contiene la posición encontrada
        xor eax, eax
        call printf

        ; Incrementar iterador
        add dword [iterador], 1

        ; Repetir bucle
        jmp iterar_palabra
%endmacro

; Función para buscar la posición de un carácter en la tabla
buscar_posicion:
    ; Entrada: AL = carácter, RSI = dirección de la tabla
    xor rcx, rcx        ; RCX será el índice
    buscar_bucle:
        mov dl, [rsi + rcx]  ; Cargar carácter de la tabla
        cmp dl, 0            ; ¿Fin de tabla?
        je no_encontrado

        cmp dl, al           ; ¿Carácter coincide?
        je encontrado

        inc rcx              ; Incrementar índice
        jmp buscar_bucle

    no_encontrado:
        mov al, -1           ; Retornar -1 si no se encuentra
        ret

    encontrado:
        mov al, cl           ; Retornar índice encontrado en AL
        ret

section .text
main:
    ALINEAR_PILA 16
    RECORRER_PALABRA

fin:
    DESALINEAR_PILA

section .data
    palabra db "LUNA", 0
    informe db "Letra: %c Posición: %d", 10, 0
    TablaConversion db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0

section .bss
    iterador resd 1          ; Iterador de la palabra
    posiciones resb 100      ; Espacio para almacenar posiciones (máx. 100 letras)

