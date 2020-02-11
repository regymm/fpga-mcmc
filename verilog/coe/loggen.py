#!/usr/bin/env python3
import math
for i in range(4096):
    x = i / 4096
    if x < 0.00034:
        x = math.exp(-7.99)
    print(hex(int(- math.log(x) * 65536)) + ',')
