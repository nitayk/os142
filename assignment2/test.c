// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1000
/*
void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}
*/

void
foo(void)
{
	printf(1,"This is an alternative signal handler.\n");
}

int
main(void)
{
  printf(1,"Testing alarm()...\n");
  signal(14,&foo);
  alarm(5);
  sleep(6);
  
  exit();
} 