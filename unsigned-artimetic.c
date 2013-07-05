#include <stdio.h>
#include <math.h>

int main(int argv, char **argc)
{
	unsigned short range = 1024;
	unsigned short mid = 512;
	unsigned short dial2 = 540;
	unsigned short dial = 500;
	// unsigned char end = start;
	
	printf("dial - mid %d - %d = %d\n", dial, mid, dial - mid);
	printf("dial - mid %d - %d = %d\n", dial2, mid, dial2 - mid);
	printf("%d\n", 0 - (dial - mid));

	return 0;
}