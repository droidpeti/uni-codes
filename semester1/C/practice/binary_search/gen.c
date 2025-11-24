#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char **argv)
{
  int i;
  int max = 100000; /* number of elements by default */

  if ( argc > 1 ) /* if command line argument is given */
  {
    int imax = atoi(argv[1]);  /* converts to int */
    if ( imax > 0 )   /* if argv[1] was meaningful */
      max = imax;
  }    
  srand(time(NULL));   /* seeding the random generator */
  for ( i = 0; i < max; ++i)
    printf( "%d ", rand() );  /* int between 0..MAXINT */

  return 0;
}
