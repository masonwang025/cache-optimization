// C program to multiply two square matrices
// Note: program is long to mirror the MIPS program

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 4 // 4x4 matrix

// defined in .data
int M[N][N];
int M1[N][N];
int product[N][N];

// C= C + A * B
// MIPS: $a1 * $a2 -> $a0
void matrix_multiply(int c[][N], int a[][N], int b[][N])
{
    int i, j, k;                     // $s0, $s1, $s2
    for (i = 0; i != N; i++)         // L1
        for (j = 0; j != N; j++)     // L2
            for (k = 0; k != N; k++) // L3
                c[i][j] = c[i][j] + a[i][k] * b[k][j];
}

void read_matrix(int x[][N])
{
    for (int i = 0; i < N; i++)
    {
        printf("Row %d: ", (i + 1));
        // MIPS read_vector procedure
        // vector_string is defined in .data
        char vector_string[8];
        scanf("%[^\n]%*c", vector_string);
        // for each digit in vector_string, place into current row
        convertASCII(vector_string, x[i]);
    }
}

// converts string and fills x[]
// MIPS: converts string $a0 (length $a1) to integer array and stores it in $a2
void convertASCII(char vector_string[], int x[])
{
    // fill x[i] with converted vector_string[i*2]
    for (int i = 0; i < sizeof(x), i * 2 < sizeof(vector_string); i++)
        x[i] = vector_string[i * 2] - 48; // CONVERT BY SUBTRACTION
                                          // can also use & to mask off bits
}

// MIPS print_matrix procedure
void print_matrix(int c[][N])
{
    for (int i = 0; i < N; i++)
    {
        printf("Row %d: ", (i + 1));
        // MIPS print_vector procedure
        for (int j = 0; j < N; j++)
            printf("%d ", c[i][j]);
        printf("\n");
    }
}

int main()
{
    read_matrix(M);
    printf("\n");

    read_matrix(M1);
    printf("\n");

    // MIPS: $a1 * $a2 -> $a0
    matrix_multiply(product, M, M1);

    print_matrix(product);

    return 0;
}