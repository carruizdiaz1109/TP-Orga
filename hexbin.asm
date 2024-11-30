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

        ; Avanzar 3 bytes en secuenciaBinariaA
        add rsi, 3
        ; Avanzar 3 bytes en el contador
        add rdi, 3
     
        jmp procesar_bloques              ; Repite el proceso para el siguiente bloque

    fin_codificacion:
%endmacro



section .text

main:
    ALINEAR_PILA 16                      ; Configurar el marco de pila y reservar espacio
    CODIFICADOR
    DESALINEAR_PILA                      ; Restaurar el marco de pila

section	.data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d

	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d
	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

section	.bss
	secuenciaImprimibleA	resb	32
	secuenciaBinariaB		resb	24
