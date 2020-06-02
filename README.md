# Cache-Optimization
Improving cache hit rate on MIPS GEMM (general matrix multiply) using blocking.\n
The comments under unoptimized.c contain code exploiting subword parallelism.\n
The optimized version operates of 4x4 submatrices to increase hit rate.
