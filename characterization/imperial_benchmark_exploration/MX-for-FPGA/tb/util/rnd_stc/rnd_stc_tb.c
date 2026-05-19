#include "svdpi.h"
#include <math.h>
#include <stdlib.h>


DPI_DLLESPEC
int rnd_stc_ref(uint32_t i_num, uint32_t width_diff, uint32_t width_o, uint32_t noise){

    float num = i_num;

    num /= (1 << width_diff);

    if(width_diff >= 32)
        num = 0;
    
    float noise_shifted;

    noise_shifted = noise / pow(2,6);

    float rounded_add = num + noise_shifted;

    int rounded = rounded_add;

    return rounded;
}
