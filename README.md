# Cache-Optimization

Improving cache hit rate on MIPS GEMM (general matrix multiply) using blocking.

The optimized version operates of 4x4 submatrices to increase hit rate.

## Optimized C Code

Altered from page 415 of _Hennesy and Patterson Computer Organization and Design_.
The book's example is optimized DGEMM, with incorrect indexing. The code below (found in `optimized.c`) is GEMM with fixed indexing.

```
#define N 8 // 8x8 matrix
#define MATRIX_SIZE N*N
#define BLOCKSIZE 4 // blocking into 4 4x4 matrices

void do_block(int si, int sj, int sk, int *A, int *B, int *C)
{
    for (int i = si; i < si + BLOCKSIZE; ++i)
        for (int j = sj; j < sj + BLOCKSIZE; ++j)
        {
            int cij = C[(i * N) + j]; /* cij = C[i][j] */
            for (int k = sk; k < sk + BLOCKSIZE; k++)
                cij += A[(i * N) + k] * B[(k * N) + j]; /* cij+=A[i][k]*B[k][j] */
            C[(i * N) + j] = cij;                       /* C[i][j] = cij */
        }
}

void matrix_multiply(int *A, int *B, int *C)
{
    for (int si = 0; si < N; si += BLOCKSIZE)
        for (int sj = 0; sj < N; sj += BLOCKSIZE)
            for (int sk = 0; sk < N; sk += BLOCKSIZE)
                do_block(si, sj, sk, A, B, C);
}
```
