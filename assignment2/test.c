// Test that fork fails gracefully.

#include "types.h"
#include "stat.h"
#include "user.h"
#include "uthread.h"

#define N  1000
/*
void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}
*/

static struct binary_semaphore* semaphore;

void foo(void* num);

int
main(void)
{
  uthread_init();
  printf(1,"Back from threads init\n");
  int i=0;
  int j=0;
  
  semaphore = malloc(sizeof(struct binary_semaphore));
  
  binary_semaphore_init(semaphore, 1);
  printf(1,"Back from semaphore init\n");
  
  
  
  for (i=0;i<4; i++){
	j = uthread_create(foo,(void *)i );
	printf(1,"Created thread %d\n",j);
	}
  uthred_join(1);
  uthred_join(2);
  uthred_join(3);
  uthred_join(4);
  printf(1,"j = %d\n",j);
  sleep(5);
  uthread_exit();
  return 0;
} 

void
foo(void* num)
{
	int i = (int)num + 1;
	
	printf(1,"thread %d requesting key\n",i);
	binary_semaphore_down(semaphore);
	printf(1,"thread %d got key\n",i);
	
	printf(1,"Hello from thread number %d\n", i);
	
	sleep(6);
	
	printf(1,"thread %d returning key\n",i);
	binary_semaphore_up(semaphore);
	printf(1,"thread %d returned key\n",i);
}