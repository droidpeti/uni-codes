#include <stdio.h>
#include <stdlib.h>

int main()
{
  int prev = -1;  /* ensure that the first number is ok */
  int curr;

  while ( 1 == scanf("%d", &curr) )
  {
    if ( curr < prev )	  /* inversion!!! */
    {
      fprintf( stderr, "Inversion: %d %d\n", prev, curr);
    }
    printf("%d ", curr); 
    prev = curr;    
  }  
  return 0;	
}
