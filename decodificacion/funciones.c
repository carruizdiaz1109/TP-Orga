#include <stdio.h>

void imprimir_secuencia(unsigned char* secuenciaBinaria) {
    for (int i = 0; i < 24; i++) {
        // Imprimir cada bit de la secuencia
        for (int j = 7; j >= 0; j--) {
            // Imprimir el bit más significativo primero
            if (secuenciaBinaria[i] & (1 << j)) {
                printf("1");
            } else {
                printf("0");
            }
        }
        printf(" "); // Espacio entre bytes
    }
    printf("\n");
}
