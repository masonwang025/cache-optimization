// using cache blocking to increase hit rate
// operating on submatrices
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 8 // 8x8 matrix
#define MATRIX_SIZE N *N
#define BLOCKSIZE 4 // blocking into 4 4x4 matrices

// M1 and M2 initalized in main
int product[MATRIX_SIZE];

// MIPS print_matrix procedure
void print_matrix(int *C)
{
    for (int i = 0; i < N; i++)
    {
        printf("Row %d: ", (i + 1));
        // MIPS print_vector procedure
        for (int j = 0; j < N; j++)
            printf("%d ", C[(i * N) + j]); // (i*N) is row number * row size
        printf("\n");
    }
}

// UNOPTIMIZED DGEMM (exploiting subword parallelism):
// for (int j = 0; j < n; ++j) {
// int cij = C[i+j*n]; /* cij = C[i][j] */
// for( int k = 0; k < n; k++ )
// cij += A[i+k*n] * B[k+j*n]; /* cij += A[i][k]*B[k][j] */
// C[i+j*n] = cij; /* C[i][j] = cij */
// }
// }
// UNOPTIMIZED INT MATRIX MULTIPLICATION:
// void matrix_multiply(int c[][N], int a[][N], int b[][N])
// {
// int i, j, k;// $s0, $s1, $s2
// for (i = 0; i != N; i++) // L1
// for (j = 0; j != N; j++) // L2
// for (k = 0; k != N; k++) // L3
// c[i][j] = c[i][j] + a[i][k] * b[k][j];
// }

void do_block(int si, int sj, int sk, int *A, int *B, int *C)
{
    for (int i = si; i < si + BLOCKSIZE; ++i)
        for (int j = sj; j < sj + BLOCKSIZE; ++j)
        {
            int cij = C[(i * N) + j]; /* cij = C[i][j] */
            for (int k = sk; k < sk + BLOCKSIZE; k++)
                cij += A[(i * N) + k] * B[(k * N) + j]; /* cij+=A[i][k]*B[k][j] */
            C[(i * N) + j] = cij;                       /* C[i][j] = cij */
            // this code block can be shortened by removing the usage of cij
        }
}

void matrix_multiply(int *A, int *B, int *C)
{
    for (int si = 0; si < N; si += BLOCKSIZE)
        for (int sj = 0; sj < N; sj += BLOCKSIZE)
            for (int sk = 0; sk < N; sk += BLOCKSIZE)
                do_block(si, sj, sk, A, B, C);
}

int main()
{
    // see unoptimized.c for read_matrix()
    // if you don't want predefined arrays
    // defined in .data
    int M1[MATRIX_SIZE] =
        {1, 2, 1, 1, 0, 0, 1, 2,
         0, 4, 0, 1, 7, 4, 3, 3,
         2, 3, 4, 1, 6, 1, 9, 1,
         1, 9, 7, 0, 7, 8, 1, 2,
         2, 1, 8, 6, 8, 2, 1, 1,
         6, 1, 8, 1, 0, 2, 1, 7,
         1, 2, 9, 1, 2, 7, 1, 9,
         6, 1, 1, 1, 6, 2, 2, 1};
    int M2[MATRIX_SIZE] =
        {8, 8, 9, 1, 7, 1, 2, 3,
         1, 3, 0, 0, 1, 2, 4, 5,
         5, 2, 5, 7, 2, 8, 5, 7,
         3, 3, 0, 5, 2, 0, 0, 0,
         2, 0, 0, 5, 9, 7, 8, 8,
         1, 9, 7, 8, 3, 3, 0, 1,
         2, 3, 5, 1, 6, 6, 2, 3,
         7, 0, 1, 1, 2, 4, 6, 4};

    // MIPS: $a1 * $a2 -> $a0
    matrix_multiply(M1, M2, product);

    print_matrix(product);

    return 0;
}