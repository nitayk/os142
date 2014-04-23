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

void
foo(void* num)
{
	int i = (int) num;
	i = i*i;
	printf(1,"Hello from thread number %d\n", i);
}

int
main(void)
{
  uthread_init();
  printf(1,"Back from init\n");
  int i=0;
  int j=0;
  for (i=0;i<5; i++){
	j = uthread_create(foo,(void *)i);
	printf(1,"Created thread %d\n",i);
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