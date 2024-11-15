#define CARACTERES_HEXA 16

// Estructura para almacenar una letra y su valor decimal
typedef struct {
    char letra;
    int valor;
} LetraValor;


LetraValor lista[] = {
    {'1', 1},
    {'2', 2},
    {'3', 3},
    {'4', 4},
    {'5', 5},
    {'6', 6},
    {'7', 7},
    {'8', 8},
    {'9', 9},
    {'A', 10},
    {'B', 11},
    {'C', 12},
    {'D', 13},
    {'E', 14},
    {'F', 15}

};

// Función para buscar el valor correspondiente a una letra
int _caracterHexadecimalADecimal(char letra) {
    for (int i = 0; i < CARACTERES_HEXA; i++) {
        if (lista[i].letra == letra) {
            return lista[i].valor;
        }
    }
    return -1;  // Retorna -1 si la letra no se encuentra
}