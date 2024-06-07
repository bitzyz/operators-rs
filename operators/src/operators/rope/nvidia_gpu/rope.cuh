#include <cuda_fp16.h>

static __device__ void padding(
    half2 *__restrict__ t_,
    int const stride_token,
    int const stride_head,
    unsigned int const *__restrict__ pos_,
    float const theta) {

    auto// nt = gridDim.y,
        // nh_h = gridDim.x,
        nh_l = blockDim.y,
        dh = blockDim.x,

        it = blockIdx.y,        // token index
        ih_h = blockIdx.x,      // head index (high)
        ih_l = threadIdx.y,     // head index (low)
        ih = ih_h * nh_l + ih_l,// head index
        i = threadIdx.x;        // element index

    auto &x = t_[it * stride_token + ih * stride_head + i];
    auto pos = float(pos_[it]);

    float sin, cos;
    sincosf(pos / powf(theta, float(i) / float(dh)), &sin, &cos);

    x = x * half2(cos, cos) + half2(-x.y, x.x) * half2(sin, sin);
}
