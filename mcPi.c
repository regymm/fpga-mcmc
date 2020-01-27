#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define N 4200000000

int main(int argc, char* argv[])
{
	srand((unsigned)time(0));
	unsigned int pi_no = 0;
	unsigned int i;
	for(i = 0; i < N; i++) {
		double random1, random2;
		random1 = (double) rand() / RAND_MAX;
		random2 = (double) rand() / RAND_MAX;
		if (random1 * random1 + random2 * random2 > 1.)
			pi_no++;
	}
	printf("%lf\n", 4 * (1 - (double) pi_no / N));
	return 0;
}
