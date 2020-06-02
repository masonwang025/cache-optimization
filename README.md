# Cache-Optimization
Improving cache hit rate on MIPS GEMM (general matrix multiply) using blocking.

The comments under unoptimized.c contain code exploiting subword parallelism.

The optimized version operates of 4x4 submatrices to increase hit rate.
