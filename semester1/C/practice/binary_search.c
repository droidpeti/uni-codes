#include <stdio.h>
#include <stdlib.h>
#include <time.h>

struct node   /* one node of the search tree */
{
  int          value;   /* payload */
  struct node *left;    /* pointer to left child  */
  struct node *right;   /* pointer to right child */
};
typedef struct node node_t;

void insert(node_t **pRoot, int i);
void print(node_t *root);
void delete(node_t *root);

int main()
{
  node_t *head = NULL;	/* pointer to binary search tree */
  int i;
  int cnt = 0;

  clock_t start = clock();   /* start the timer */
  while ( scanf("%d", &i) == 1 )
  {
    ++cnt;
    insert(&head, i);	  /* recursive insert */
  }  
  clock_t end = clock();    /* stop the timer */
  double diff = (end - start); /* elapsed time in 'tick's */
  diff = diff / CLOCKS_PER_SEC; /* ..converted to seconds */

  print(head);  /* print tree elements: recursive inorder */

  fprintf(stderr,"sorted %d elems in %f sec\n", cnt, diff); 

  delete(head); /* delete the tree: recursive postorder */
  return 0;
}

void insert( node_t **pRoot, int i)
{
  if ( NULL == *pRoot )  /* need to allocate new element */
  {
    *pRoot = (node_t*) malloc(sizeof(node_t));
    if ( NULL == *pRoot )
    {
      fprintf( stderr, "No memory\n");
      exit(1);      
    }	    
    else
    {
      node_t *root = *pRoot; /* make more readable */
      root->value = i;       /* set payload */
      root->left  = NULL;    /* no children (yet) */
      root->right = NULL;
    }
  }	  
  else /* not to allocate, just descent left or right */
  {
    node_t *root = *pRoot;  /* make more readable */
    if ( i <= root->value )
      insert( &root->left, i);  /* descend to left */
    else
      insert( &root->right, i);	/* descend to right */
  }
}
void print(node_t *root)
{
  if ( root ) 	/* if this is a real node */
  {	  
    print(root->left);
    printf("%d ", root->value);  /* inorder */
    print(root->right);  
  }
}	
void delete(node_t *root)
{
  if ( root ) 	/* if this is a real node */
  {	  
    delete(root->left);
    delete(root->right);  
    free(root);          /* postorder */
  }
}
