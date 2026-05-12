#include "svdpi.h"
#include <math.h>
#include <stdlib.h>

float rne(float num){

    float out = num;

    if(round(num) != num){  // If rounding is necessary.

        out = round(num); // Round away from zero.

        if(round(num*2) == (num*2)){ // If at halfway point.

            if((int)out % 2 != 0){  // If output is odd, round towards zero.
                if(out > 0){
                    out -= 1;
                }else{
                    out += 1;
                }
            }
        }
    }

    return out;
}

DPI_DLLESPEC
int rnd_rne_ref(uint32_t i_num, uint32_t width_diff, uint32_t width_o){

    float num = i_num;

    num /= (1 << width_diff);

    if(width_diff >= 32)
        num = 0;

    int rounded = rne(num);

    return rounded;
}
