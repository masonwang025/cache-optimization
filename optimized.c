// using cache blocking to increase hit rate
// operating on submatrices
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 8         // 8x8 matrix
#define BLOCKSIZE 4 // blocking into 4 4x4 matrices

// UNOPTIMIZED DGEMM:
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


void do_block(int n, int si, int sj, int sk, int *A, int *B, int *C)
{
    for (int i = si; i < si + BLOCKSIZE; ++i)
        for (int j = sj; j < sj + BLOCKSIZE; ++j)
        {
            int cij = C[i + j * n]; /* cij = C[i][j] */
            for (int k = sk; k < sk + BLOCKSIZE; k++)
                cij += A[i + k * n] * B[k + j * n]; /* cij+=A[i][k]*B[k][j] */
            C[i + j * n] = cij;                     /* C[i][j] = cij */
        }
}

void matrix_multiply(int n, int A[][N], int B[][N], int C[][N])
{
    for (int sj = 0; sj < n; sj += BLOCKSIZE)
        for (int si = 0; si < n; si += BLOCKSIZE)
            for (int sk = 0; sk < n; sk += BLOCKSIZE)
                do_block(n, si, sj, sk, A, B, C);
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
    // defined in .data
    int M[N][N] = {
        {1, 2, 1, 1, 0, 0, 1, 2},
        {0, 4, 0, 1, 7, 4, 3, 3},
        {2, 3, 4, 1, 6, 1, 9, 1},
        {1, 9, 7, 0, 7, 8, 1, 2},
        {2, 1, 8, 6, 8, 0, 1, 1},
        {6, 1, 8, 1, 0, 0, 1, 7},
        {1, 2, 9, 1, 2, 7, 1, 9},
        {6, 1, 1, 1, 6, 2, 2, 1}};
    int M1[N][N] = {
        {8, 8, 9, 1, 7, 1, 2, 3},
        {1, 3, 0, 0, 1, 2, 4, 5},
        {5, 2, 5, 7, 2, 8, 5, 7},
        {3, 3, 0, 5, 2, 0, 0, 0},
        {2, 0, 0, 5, 9, 7, 8, 8},
        {1, 9, 7, 8, 3, 3, 0, 1},
        {2, 3, 5, 1, 6, 6, 2, 3},
        {7, 0, 1, 1, 2, 4, 6, 4}};

    int product[N][N];

    // MIPS: $a1 * $a2 -> $a0
    matrix_multiply(2, product, M, M1);

    print_matrix(product);

    return 0;
}