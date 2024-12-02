section .data
    secuenciaImprimibleA db "vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU" ; Secuencia Base64 codificada
    largoSecuenciaA      db 0x20                                    ; Longitud de la secuencia codificada (32 caracteres)
    TablaConversion      db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"  ; Tabla Base64

section .bss
    secuenciaBinariaA    resb 24                                    ; Espacio para los datos decodificados (24 bytes)

section .text
global _start

_start:
    ; Inicializamos los registros
    mov rsi, secuenciaImprimibleA  ; Dirección de la secuencia codificada
    mov rdi, secuenciaBinariaA     ; Dirección de la salida de la secuencia binaria
    movzx rcx, byte [largoSecuenciaA] ; Longitud de la secuencia codificada
    call decode_loop               ; Llamada al loop de decodificación
    call mostrar_salida            ; Mostrar la salida decodificada

    ; Terminar el programa
    mov rax, 60                    ; syscall: exit
    xor rdi, rdi                   ; Código de salida: 0
    syscall

decode_loop:
    cmp rcx, 0                     ; Comprobamos si hemos procesado toda la secuencia
    je  fin_decode                 ; Si no hay más caracteres, terminamos

    ; Obtener el índice para el primer carácter
    call obtener_indice
    movzx ebx, al                  ; Guardamos el índice en ebx (32 bits)

    ; Obtener el segundo carácter
    inc rsi                         ; Avanzamos al siguiente carácter
    call obtener_indice
    shl ebx, 6                      ; Desplazamos el primer índice 6 bits a la izquierda
    or ebx, eax                     ; Combinamos los dos índices

    ; Obtener el tercer carácter
    inc rsi                         ; Avanzamos al siguiente carácter
    call obtener_indice
    shl ebx, 6                      ; Desplazamos el resultado 6 bits más
    or ebx, eax                     ; Combinamos

    ; Obtener el cuarto carácter
    inc rsi                         ; Avanzamos al siguiente carácter
    call obtener_indice

   ; Ahora tenemos los 4 índices en rbx
  ; Reconstruimos los 3 bytes de datos
    mov al, bl                      ; Copiar el primer byte de rbx a al
    mov [rdi], al                   ; Primer byte

    shr rbx, 8
    mov al, bl                      ; Copiar el segundo byte de rbx a al
    mov [rdi+1], al                 ; Segundo byte

    shr rbx, 8
    mov al, bl                      ; Copiar el tercer byte de rbx a al
    mov [rdi+2], al                 ; Tercer byte

    ; Avanzar punteros y reducir contador
    add rdi, 3                      ; Avanzar en la salida
    dec rcx                         ; Reducir longitud de la secuencia codificada
    jmp decode_loop                 ; Repetir para el siguiente bloque

fin_decode:
    ret

obtener_indice:
    ; Obtener el índice de la tabla de conversión a partir del carácter en [rsi]
    movzx eax, byte [rsi]            ; Cargar el carácter en eax (solo 8 bits relevantes)
    mov ecx, 0                       ; Limpiar ecx
    ; Buscar el carácter en la tabla
    jmp buscar_indice               ; Saltar a la etiqueta buscar_indice

buscar_indice:
    cmp eax, [TablaConversion + ecx]  ; Comparar con el carácter actual en la tabla
    je  encontrado                   ; Si es igual, salimos
    inc ecx                           ; Incrementamos el índice
    cmp ecx, 0x40                     ; Comprobamos si hemos recorrido toda la tabla
    jl  buscar_indice                 ; Volver a la comparación
    jmp fin_indice                    ; Si no se encuentra, saltamos

encontrado:
    mov eax, ecx                      ; Guardamos el índice en eax
fin_indice:
    ret

mostrar_salida:
    ; Mostrar la secuencia binaria decodificada
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; stdout
    mov rsi, secuenciaBinariaA ; Dirección de salida
    mov rdx, 24       ; Longitud de salida
    syscall
    ret


