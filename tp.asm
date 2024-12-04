; Colocar nombre y padron de los integrantes del grupo

global	main
extern puts

section	.data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d
	mensajeCodificado db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	
; Casos de prueba:
; SecuenciaBinariaDePrueba db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
;						   db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A 
;						   db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F
; SecuenciaImprimibleCodificada	db	"czjn9zQsT5JJVeWfjvJ1WtPFU2VoUng/"

; SecuenciaImprimibleDePrueba db "Qy2A2dhEivizBySXb/09gX+tk/2ExnYb"
; SecuenciaBinariaDecodificada	db	0x43, 0x2D, 0x80, 0xD9, 0xD8, 0x44, 0x8A, 0xF8 
;								db	0xB3, 0x07, 0x24, 0x97, 0x6F, 0xFD, 0x3D, 0x81 
;								db	0x7F, 0xAD, 0x93, 0xFD, 0x84, 0xC6, 0x76, 0x1B
 
; Un codificador/decodificador online se puede encontrar en https://www.rapidtables.com/web/tools/base64-encode.html
	
section	.bss
	secuenciaImprimibleA	resb	32
	secuenciaBinariaB		resb	24
	
section	.text

main:
    ; Inicializar registros
    mov rsi, secuenciaBinariaA      ; Puntero a la secuencia binaria
    mov rdi, mensajeCodificado      ; Puntero al buffer de salida
    xor rdx, rdx                    ; Inicializar índice de bytes procesados

procesar_secuencia:
    ; Comprobar si hemos procesado todos los bytes
    cmp rdx, 0x18                   ; Comparar rdx con el tamaño de la entrada (24 bytes)
    jae fin_codificacion            ; Si rdx >= 24, terminamos

    ; Limpiar rax para procesar un nuevo bloque
    xor rax, rax

    ; Leer los 3 bytes en rax
    mov al, byte [rsi]              ; Primer byte
    shl rax, 8                      ; Desplazar 8 bits
    mov al, byte [rsi+1]            ; Segundo byte
    shl rax, 8                      ; Desplazar 8 bits
    mov al, byte [rsi+2]            ; Tercer byte

    ; Dividir en 4 bloques de 6 bits
    mov rcx, 4                      ; Procesar 4 bloques de 6 bits
    mov rbx, 0x3F                   ; Máscara para extraer los 6 bits (0b111111)

generar_bloque:
    ; Desplazar rax y extraer los bits relevantes
    mov r8, rax                     ; Copiar rax a r8
    shr r8, 18                      ; Desplazar 18 bits (primer bloque)
    and r8, rbx                     ; Aplicar la máscara para obtener los 6 bits
    add r8, TablaConversion         ; Mapear índice a carácter en la tabla
    mov r9b, byte [r8]              ; Obtener el carácter correspondiente
    mov byte [rdi], r9b             ; Guardar el carácter en el buffer de salida
    inc rdi                          ; Avanzar el puntero de salida
    shl rax, 6                       ; Preparar para el siguiente bloque
    loop generar_bloque             ; Repetir para los 4 bloques

    ; Avanzar en la entrada y el índice de procesamiento
    add rsi, 3                       ; Avanzar 3 bytes en la entrada
    add rdx, 3                       ; Incrementar el índice de bytes procesados
    jmp procesar_secuencia           ; Procesar el siguiente bloque

fin_codificacion:
    ; Agregar terminador null al buffer de salida
    mov byte [rdi], 0

    ; Imprimir la salida usando puts
    mov rdi, mensajeCodificado
    call puts

    ; Salida del programa
    mov rax, 60                      ; Syscall para exit
    xor rdi, rdi                     ; Código de salida 0
    syscall
