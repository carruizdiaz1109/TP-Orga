global main
extern imprimir_secuencia  ; Declarar la función de C para imprimir

; PILA
%macro ALINEAR_PILA 1
    push rbp
    mov rbp, rsp
    sub rsp, %1
%endmacro

%macro DESALINEAR_PILA 0
    leave
    ret
%endmacro

%macro CODIFICADOR 0
    xor rdi, rdi                        ; Inicializa el contador (rdi = 0)
    lea rsi, [secuenciaBinariaA]        ; Apunta al inicio de secuenciaBinariaA
    movzx rcx, byte [largoSecuenciaA]   ; Carga largoSecuenciaA en rcx (64 bits)

    procesar_bloques:
        cmp rdi, rcx                     ; ¿Hemos procesado todos los bloques?
        je fin_codificacion              ; Salta si el contador alcanza el límite

        xor rax, rax                    ; Limpiar rax antes de cada carga

        mov al, byte [rsi]              ; Cargar el primer byte en al
        mov dl, byte [rsi + 1]          ; Cargar el segundo byte en dl        
        shl rax, 8                      ; Desplazo 8 bits a la izquierda
        or al, dl

        mov dl, byte [rsi + 2]          ; Cargar el tercer byte en RDX
        shl rax, 8                      ; Desplazo 8 bits a la izquierda
        or al, dl

        call dividir_bloque

        ; Avanzar 3 bytes en secuenciaBinariaA
        add rsi, 3
        ; Avanzar 3 bytes en el contador
        add rdi, 3
     
        jmp procesar_bloques           ; Repite el proceso para el siguiente bloque

    fin_codificacion:
%endmacro

dividir_bloque:
    push rbx                     ; Guardar registros que se usan en el procedimiento
    push r8

    mov rbx, rax                 ; Copia `rax` a `rbx` para no modificar el original
    xor r8, r8                   ; Inicializa el contador (r8 = 0)

procesar_bucle_6bits:
    cmp r8, 4                 ; ¿Hemos procesado los 4 grupos de 6 bits?
    je fin_proceso_caracter

    mov r10, rbx              ; Copia el valor original de `rbx` a `rcx`
    and r10, 0x3F             ; Enmascara los 6 bits menos significativos de `rcx`
    
    call guardar_caracter

    shr rbx, 6                ; Desplaza `rbx` 6 bits a la derecha para el siguiente grupo
    inc r8                    ; Incrementa el contador
    jmp procesar_bucle_6bits  ; Continua al siguiente grupo

fin_proceso_caracter:
    pop r8                       ; Restaurar registros
    pop rbx
    ret                          ; Retorna al llamador

guardar_caracter:
    push rsi                  ; Guardar registros que se modifican
    push rdi
    push rax

    ; Buscar el carácter en la tabla
    lea rsi, [TablaConversion] ; Cargar la dirección base de la tabla de conversión
    add rsi, r10              ; Sumar el índice (bits en R10)
    mov r11b, byte [rsi]      ; Cargar el carácter de la tabla en R11B

    ; Buscar la primera posición vacía (byte con valor 0)
    lea rdi, [secuenciaImprimibleA] ; Dirección base del buffer

.buscar_espacio:
    cmp byte [rdi], 0          ; ¿Es la posición actual igual a 0?
    je .escribir               ; Si es 0, es un espacio vacío
    add rdi, 1                 ; Avanzar a la siguiente posición
    cmp rdi, secuenciaImprimibleA + 32 ; Verificar si llegamos al límite
    jae .fin                   ; Si se excede el buffer, salir
    jmp .buscar_espacio        ; Continuar buscando

.escribir:
    mov byte [rdi], r11b       ; Escribir el carácter en la posición vacía

.fin:
    pop rax                   ; Restaurar el valor original de RAX
    pop rdi                   ; Restaurar registros
    pop rsi
    ret                       ; Retornar

section .text

main:
    ALINEAR_PILA 16                      ; Configurar el marco de pila y reservar espacio
    CODIFICADOR
    lea rdi, [secuenciaImprimibleA]      ; Cargar la dirección de secuenciaImprimibleA en rdi
    call imprimir_secuencia              ; Llamar a la función de C para imprimir la secuencia
    DESALINEAR_PILA                      ; Restaurar el marco de pila

section	.data
	secuenciaBinariaA	db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
;						db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A 
;						db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F 
	largoSecuenciaA		db	0x18 ; 24d

	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d
	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

section	.bss
	secuenciaImprimibleA	resb	32
	secuenciaBinariaB		resb	24
