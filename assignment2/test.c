// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

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
	printf(1,"Hello from thread number %d\n", num);
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
  uthred_join(2);
  printf(1,"j = %d\n",j);
  sleep(5);
  exit();
  return 0;
} 