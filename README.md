# TP-Orga

```
  nasm -f elf64 codificador.asm -o codificador.o
```
```
 gcc -c main.c -o main.o
```

```
gcc main.o codificador.o -o programa
```
```
./programa
``` 

Proceso:

    Convertir los 3 bytes a binario (24 bits).
    Dividir los 24 bits en 4 grupos de 6 bits.
    Convertir cada grupo de 6 bits a decimal.
    Usar la tabla de conversión para obtener el carácter base64 correspondiente.
    Almacenar los 4 caracteres base64 en secuenciaImprimibleA.

Repetir:

    Avanzar 3 bytes en la secuencia y repetir el proceso hasta que se haya procesado toda la secuencia.
