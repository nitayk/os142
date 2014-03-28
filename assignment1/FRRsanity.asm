
_FRRsanity:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

#define NUM_OF_CHILDRENS 10
#define NUM_OF_CHILD_LOOPS 50

int main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	83 e4 f0             	and    $0xfffffff0,%esp
   8:	81 ec e0 00 00 00    	sub    $0xe0,%esp
	int i,j,index,wTime,rTime,ioTime = 0;
   e:	c7 84 24 c4 00 00 00 	movl   $0x0,0xc4(%esp)
  15:	00 00 00 00 
	int fork_id = 1;
  19:	c7 84 24 d0 00 00 00 	movl   $0x1,0xd0(%esp)
  20:	01 00 00 00 
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
  24:	c7 84 24 dc 00 00 00 	movl   $0x0,0xdc(%esp)
  2b:	00 00 00 00 
  2f:	eb 40                	jmp    71 <main+0x71>
		for (j=0 ; j < 4 ; j++)
  31:	c7 84 24 d8 00 00 00 	movl   $0x0,0xd8(%esp)
  38:	00 00 00 00 
  3c:	eb 21                	jmp    5f <main+0x5f>
			c_array[i][j] = 0;
  3e:	8b 84 24 dc 00 00 00 	mov    0xdc(%esp),%eax
  45:	c1 e0 02             	shl    $0x2,%eax
  48:	03 84 24 d8 00 00 00 	add    0xd8(%esp),%eax
  4f:	c7 44 84 24 00 00 00 	movl   $0x0,0x24(%esp,%eax,4)
  56:	00 
{
	int i,j,index,wTime,rTime,ioTime = 0;
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
		for (j=0 ; j < 4 ; j++)
  57:	83 84 24 d8 00 00 00 	addl   $0x1,0xd8(%esp)
  5e:	01 
  5f:	83 bc 24 d8 00 00 00 	cmpl   $0x3,0xd8(%esp)
  66:	03 
  67:	7e d5                	jle    3e <main+0x3e>
int main(int argc, char *argv[])
{
	int i,j,index,wTime,rTime,ioTime = 0;
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
  69:	83 84 24 dc 00 00 00 	addl   $0x1,0xdc(%esp)
  70:	01 
  71:	83 bc 24 dc 00 00 00 	cmpl   $0x9,0xdc(%esp)
  78:	09 
  79:	7e b6                	jle    31 <main+0x31>
		for (j=0 ; j < 4 ; j++)
			c_array[i][j] = 0;
	for (i=0 ; i < NUM_OF_CHILDRENS && fork_id !=0; i++) {
  7b:	c7 84 24 dc 00 00 00 	movl   $0x0,0xdc(%esp)
  82:	00 00 00 00 
  86:	eb 6a                	jmp    f2 <main+0xf2>
		fork_id = fork();
  88:	e8 77 04 00 00       	call   504 <fork>
  8d:	89 84 24 d0 00 00 00 	mov    %eax,0xd0(%esp)
		if (fork_id == 0) {
  94:	83 bc 24 d0 00 00 00 	cmpl   $0x0,0xd0(%esp)
  9b:	00 
  9c:	75 4c                	jne    ea <main+0xea>
			for (j=0 ; j < NUM_OF_CHILD_LOOPS ; j++)
  9e:	c7 84 24 d8 00 00 00 	movl   $0x0,0xd8(%esp)
  a5:	00 00 00 00 
  a9:	eb 30                	jmp    db <main+0xdb>
				printf(2,"child <%d> prints for the <%d>\n",getpid(),j);
  ab:	e8 ec 04 00 00       	call   59c <getpid>
  b0:	8b 94 24 d8 00 00 00 	mov    0xd8(%esp),%edx
  b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  bf:	c7 44 24 04 58 0a 00 	movl   $0xa58,0x4(%esp)
  c6:	00 
  c7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ce:	e8 c0 05 00 00       	call   693 <printf>
		for (j=0 ; j < 4 ; j++)
			c_array[i][j] = 0;
	for (i=0 ; i < NUM_OF_CHILDRENS && fork_id !=0; i++) {
		fork_id = fork();
		if (fork_id == 0) {
			for (j=0 ; j < NUM_OF_CHILD_LOOPS ; j++)
  d3:	83 84 24 d8 00 00 00 	addl   $0x1,0xd8(%esp)
  da:	01 
  db:	83 bc 24 d8 00 00 00 	cmpl   $0x31,0xd8(%esp)
  e2:	31 
  e3:	7e c6                	jle    ab <main+0xab>
				printf(2,"child <%d> prints for the <%d>\n",getpid(),j);
			exit();
  e5:	e8 22 04 00 00       	call   50c <exit>
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
		for (j=0 ; j < 4 ; j++)
			c_array[i][j] = 0;
	for (i=0 ; i < NUM_OF_CHILDRENS && fork_id !=0; i++) {
  ea:	83 84 24 dc 00 00 00 	addl   $0x1,0xdc(%esp)
  f1:	01 
  f2:	83 bc 24 dc 00 00 00 	cmpl   $0x9,0xdc(%esp)
  f9:	09 
  fa:	0f 8f b6 00 00 00    	jg     1b6 <main+0x1b6>
 100:	83 bc 24 d0 00 00 00 	cmpl   $0x0,0xd0(%esp)
 107:	00 
 108:	0f 85 7a ff ff ff    	jne    88 <main+0x88>
				printf(2,"child <%d> prints for the <%d>\n",getpid(),j);
			exit();
		}
	}

	while ((fork_id = wait2(&wTime,&rTime,&ioTime)) > 0) {
 10e:	e9 a3 00 00 00       	jmp    1b6 <main+0x1b6>
		c_array[index][0] = fork_id;
 113:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 11a:	c1 e0 04             	shl    $0x4,%eax
 11d:	8d 94 24 e0 00 00 00 	lea    0xe0(%esp),%edx
 124:	01 d0                	add    %edx,%eax
 126:	8d 90 44 ff ff ff    	lea    -0xbc(%eax),%edx
 12c:	8b 84 24 d0 00 00 00 	mov    0xd0(%esp),%eax
 133:	89 02                	mov    %eax,(%edx)
		c_array[index][1] = wTime;	// waiting time
 135:	8b 84 24 cc 00 00 00 	mov    0xcc(%esp),%eax
 13c:	8b 94 24 d4 00 00 00 	mov    0xd4(%esp),%edx
 143:	c1 e2 04             	shl    $0x4,%edx
 146:	8d 8c 24 e0 00 00 00 	lea    0xe0(%esp),%ecx
 14d:	01 ca                	add    %ecx,%edx
 14f:	81 ea b8 00 00 00    	sub    $0xb8,%edx
 155:	89 02                	mov    %eax,(%edx)
		c_array[index][2] = rTime;	// run time
 157:	8b 84 24 c8 00 00 00 	mov    0xc8(%esp),%eax
 15e:	8b 94 24 d4 00 00 00 	mov    0xd4(%esp),%edx
 165:	c1 e2 04             	shl    $0x4,%edx
 168:	8d b4 24 e0 00 00 00 	lea    0xe0(%esp),%esi
 16f:	01 f2                	add    %esi,%edx
 171:	81 ea b4 00 00 00    	sub    $0xb4,%edx
 177:	89 02                	mov    %eax,(%edx)
		c_array[index][3] = wTime+ioTime+rTime; // turnaround time -> end time - creation time
 179:	8b 94 24 cc 00 00 00 	mov    0xcc(%esp),%edx
 180:	8b 84 24 c4 00 00 00 	mov    0xc4(%esp),%eax
 187:	01 c2                	add    %eax,%edx
 189:	8b 84 24 c8 00 00 00 	mov    0xc8(%esp),%eax
 190:	01 c2                	add    %eax,%edx
 192:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 199:	c1 e0 04             	shl    $0x4,%eax
 19c:	8d 8c 24 e0 00 00 00 	lea    0xe0(%esp),%ecx
 1a3:	01 c8                	add    %ecx,%eax
 1a5:	2d b0 00 00 00       	sub    $0xb0,%eax
 1aa:	89 10                	mov    %edx,(%eax)
		index++;
 1ac:	83 84 24 d4 00 00 00 	addl   $0x1,0xd4(%esp)
 1b3:	01 
 1b4:	eb 01                	jmp    1b7 <main+0x1b7>
				printf(2,"child <%d> prints for the <%d>\n",getpid(),j);
			exit();
		}
	}

	while ((fork_id = wait2(&wTime,&rTime,&ioTime)) > 0) {
 1b6:	90                   	nop
 1b7:	8d 84 24 c4 00 00 00 	lea    0xc4(%esp),%eax
 1be:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c2:	8d 84 24 c8 00 00 00 	lea    0xc8(%esp),%eax
 1c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cd:	8d 84 24 cc 00 00 00 	lea    0xcc(%esp),%eax
 1d4:	89 04 24             	mov    %eax,(%esp)
 1d7:	e8 40 03 00 00       	call   51c <wait2>
 1dc:	89 84 24 d0 00 00 00 	mov    %eax,0xd0(%esp)
 1e3:	83 bc 24 d0 00 00 00 	cmpl   $0x0,0xd0(%esp)
 1ea:	00 
 1eb:	0f 8f 22 ff ff ff    	jg     113 <main+0x113>
		c_array[index][2] = rTime;	// run time
		c_array[index][3] = wTime+ioTime+rTime; // turnaround time -> end time - creation time
		index++;
	}

	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++) {
 1f1:	c7 84 24 d4 00 00 00 	movl   $0x0,0xd4(%esp)
 1f8:	00 00 00 00 
 1fc:	e9 94 00 00 00       	jmp    295 <main+0x295>
		printf(2,"Child <%d>: Waiting time %d , Running time %d , Turnaround time %d\n",c_array[index][0],c_array[index][1],c_array[index][2],c_array[index][3]);
 201:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 208:	c1 e0 04             	shl    $0x4,%eax
 20b:	8d b4 24 e0 00 00 00 	lea    0xe0(%esp),%esi
 212:	01 f0                	add    %esi,%eax
 214:	2d b0 00 00 00       	sub    $0xb0,%eax
 219:	8b 18                	mov    (%eax),%ebx
 21b:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 222:	c1 e0 04             	shl    $0x4,%eax
 225:	8d 94 24 e0 00 00 00 	lea    0xe0(%esp),%edx
 22c:	01 d0                	add    %edx,%eax
 22e:	2d b4 00 00 00       	sub    $0xb4,%eax
 233:	8b 08                	mov    (%eax),%ecx
 235:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 23c:	c1 e0 04             	shl    $0x4,%eax
 23f:	8d b4 24 e0 00 00 00 	lea    0xe0(%esp),%esi
 246:	01 f0                	add    %esi,%eax
 248:	2d b8 00 00 00       	sub    $0xb8,%eax
 24d:	8b 10                	mov    (%eax),%edx
 24f:	8b 84 24 d4 00 00 00 	mov    0xd4(%esp),%eax
 256:	c1 e0 04             	shl    $0x4,%eax
 259:	8d b4 24 e0 00 00 00 	lea    0xe0(%esp),%esi
 260:	01 f0                	add    %esi,%eax
 262:	2d bc 00 00 00       	sub    $0xbc,%eax
 267:	8b 00                	mov    (%eax),%eax
 269:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 26d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 271:	89 54 24 0c          	mov    %edx,0xc(%esp)
 275:	89 44 24 08          	mov    %eax,0x8(%esp)
 279:	c7 44 24 04 78 0a 00 	movl   $0xa78,0x4(%esp)
 280:	00 
 281:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 288:	e8 06 04 00 00       	call   693 <printf>
		c_array[index][2] = rTime;	// run time
		c_array[index][3] = wTime+ioTime+rTime; // turnaround time -> end time - creation time
		index++;
	}

	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++) {
 28d:	83 84 24 d4 00 00 00 	addl   $0x1,0xd4(%esp)
 294:	01 
 295:	83 bc 24 d4 00 00 00 	cmpl   $0x9,0xd4(%esp)
 29c:	09 
 29d:	0f 8e 5e ff ff ff    	jle    201 <main+0x201>
		printf(2,"Child <%d>: Waiting time %d , Running time %d , Turnaround time %d\n",c_array[index][0],c_array[index][1],c_array[index][2],c_array[index][3]);
	}
	exit();
 2a3:	e8 64 02 00 00       	call   50c <exit>

000002a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	57                   	push   %edi
 2ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2b0:	8b 55 10             	mov    0x10(%ebp),%edx
 2b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b6:	89 cb                	mov    %ecx,%ebx
 2b8:	89 df                	mov    %ebx,%edi
 2ba:	89 d1                	mov    %edx,%ecx
 2bc:	fc                   	cld    
 2bd:	f3 aa                	rep stos %al,%es:(%edi)
 2bf:	89 ca                	mov    %ecx,%edx
 2c1:	89 fb                	mov    %edi,%ebx
 2c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c9:	5b                   	pop    %ebx
 2ca:	5f                   	pop    %edi
 2cb:	5d                   	pop    %ebp
 2cc:	c3                   	ret    

000002cd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2d9:	90                   	nop
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	0f b6 10             	movzbl (%eax),%edx
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	88 10                	mov    %dl,(%eax)
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	84 c0                	test   %al,%al
 2ed:	0f 95 c0             	setne  %al
 2f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2f4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 2f8:	84 c0                	test   %al,%al
 2fa:	75 de                	jne    2da <strcpy+0xd>
    ;
  return os;
 2fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ff:	c9                   	leave  
 300:	c3                   	ret    

00000301 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 304:	eb 08                	jmp    30e <strcmp+0xd>
    p++, q++;
 306:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 30a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 30e:	8b 45 08             	mov    0x8(%ebp),%eax
 311:	0f b6 00             	movzbl (%eax),%eax
 314:	84 c0                	test   %al,%al
 316:	74 10                	je     328 <strcmp+0x27>
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	0f b6 10             	movzbl (%eax),%edx
 31e:	8b 45 0c             	mov    0xc(%ebp),%eax
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	38 c2                	cmp    %al,%dl
 326:	74 de                	je     306 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	0f b6 00             	movzbl (%eax),%eax
 32e:	0f b6 d0             	movzbl %al,%edx
 331:	8b 45 0c             	mov    0xc(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	0f b6 c0             	movzbl %al,%eax
 33a:	89 d1                	mov    %edx,%ecx
 33c:	29 c1                	sub    %eax,%ecx
 33e:	89 c8                	mov    %ecx,%eax
}
 340:	5d                   	pop    %ebp
 341:	c3                   	ret    

00000342 <strlen>:

uint
strlen(char *s)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 348:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 34f:	eb 04                	jmp    355 <strlen+0x13>
 351:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 355:	8b 45 fc             	mov    -0x4(%ebp),%eax
 358:	03 45 08             	add    0x8(%ebp),%eax
 35b:	0f b6 00             	movzbl (%eax),%eax
 35e:	84 c0                	test   %al,%al
 360:	75 ef                	jne    351 <strlen+0xf>
    ;
  return n;
 362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 365:	c9                   	leave  
 366:	c3                   	ret    

00000367 <memset>:

void*
memset(void *dst, int c, uint n)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 36d:	8b 45 10             	mov    0x10(%ebp),%eax
 370:	89 44 24 08          	mov    %eax,0x8(%esp)
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	89 44 24 04          	mov    %eax,0x4(%esp)
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 04 24             	mov    %eax,(%esp)
 381:	e8 22 ff ff ff       	call   2a8 <stosb>
  return dst;
 386:	8b 45 08             	mov    0x8(%ebp),%eax
}
 389:	c9                   	leave  
 38a:	c3                   	ret    

0000038b <strchr>:

char*
strchr(const char *s, char c)
{
 38b:	55                   	push   %ebp
 38c:	89 e5                	mov    %esp,%ebp
 38e:	83 ec 04             	sub    $0x4,%esp
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 397:	eb 14                	jmp    3ad <strchr+0x22>
    if(*s == c)
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3a2:	75 05                	jne    3a9 <strchr+0x1e>
      return (char*)s;
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	eb 13                	jmp    3bc <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ad:	8b 45 08             	mov    0x8(%ebp),%eax
 3b0:	0f b6 00             	movzbl (%eax),%eax
 3b3:	84 c0                	test   %al,%al
 3b5:	75 e2                	jne    399 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <gets>:

char*
gets(char *buf, int max)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cb:	eb 44                	jmp    411 <gets+0x53>
    cc = read(0, &c, 1);
 3cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3d4:	00 
 3d5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3e3:	e8 4c 01 00 00       	call   534 <read>
 3e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ef:	7e 2d                	jle    41e <gets+0x60>
      break;
    buf[i++] = c;
 3f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f4:	03 45 08             	add    0x8(%ebp),%eax
 3f7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 3fb:	88 10                	mov    %dl,(%eax)
 3fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 401:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 405:	3c 0a                	cmp    $0xa,%al
 407:	74 16                	je     41f <gets+0x61>
 409:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40d:	3c 0d                	cmp    $0xd,%al
 40f:	74 0e                	je     41f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 411:	8b 45 f4             	mov    -0xc(%ebp),%eax
 414:	83 c0 01             	add    $0x1,%eax
 417:	3b 45 0c             	cmp    0xc(%ebp),%eax
 41a:	7c b1                	jl     3cd <gets+0xf>
 41c:	eb 01                	jmp    41f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 41e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	03 45 08             	add    0x8(%ebp),%eax
 425:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 428:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42b:	c9                   	leave  
 42c:	c3                   	ret    

0000042d <stat>:

int
stat(char *n, struct stat *st)
{
 42d:	55                   	push   %ebp
 42e:	89 e5                	mov    %esp,%ebp
 430:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 433:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 43a:	00 
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	89 04 24             	mov    %eax,(%esp)
 441:	e8 16 01 00 00       	call   55c <open>
 446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 449:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44d:	79 07                	jns    456 <stat+0x29>
    return -1;
 44f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 454:	eb 23                	jmp    479 <stat+0x4c>
  r = fstat(fd, st);
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	89 44 24 04          	mov    %eax,0x4(%esp)
 45d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 460:	89 04 24             	mov    %eax,(%esp)
 463:	e8 0c 01 00 00       	call   574 <fstat>
 468:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46e:	89 04 24             	mov    %eax,(%esp)
 471:	e8 ce 00 00 00       	call   544 <close>
  return r;
 476:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 479:	c9                   	leave  
 47a:	c3                   	ret    

0000047b <atoi>:

int
atoi(const char *s)
{
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 481:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 488:	eb 23                	jmp    4ad <atoi+0x32>
    n = n*10 + *s++ - '0';
 48a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 48d:	89 d0                	mov    %edx,%eax
 48f:	c1 e0 02             	shl    $0x2,%eax
 492:	01 d0                	add    %edx,%eax
 494:	01 c0                	add    %eax,%eax
 496:	89 c2                	mov    %eax,%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	0f be c0             	movsbl %al,%eax
 4a1:	01 d0                	add    %edx,%eax
 4a3:	83 e8 30             	sub    $0x30,%eax
 4a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4ad:	8b 45 08             	mov    0x8(%ebp),%eax
 4b0:	0f b6 00             	movzbl (%eax),%eax
 4b3:	3c 2f                	cmp    $0x2f,%al
 4b5:	7e 0a                	jle    4c1 <atoi+0x46>
 4b7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	3c 39                	cmp    $0x39,%al
 4bf:	7e c9                	jle    48a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c4:	c9                   	leave  
 4c5:	c3                   	ret    

000004c6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4c6:	55                   	push   %ebp
 4c7:	89 e5                	mov    %esp,%ebp
 4c9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4d8:	eb 13                	jmp    4ed <memmove+0x27>
    *dst++ = *src++;
 4da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4dd:	0f b6 10             	movzbl (%eax),%edx
 4e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4e3:	88 10                	mov    %dl,(%eax)
 4e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4e9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4f1:	0f 9f c0             	setg   %al
 4f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4f8:	84 c0                	test   %al,%al
 4fa:	75 de                	jne    4da <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ff:	c9                   	leave  
 500:	c3                   	ret    
 501:	90                   	nop
 502:	90                   	nop
 503:	90                   	nop

00000504 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 504:	b8 01 00 00 00       	mov    $0x1,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <exit>:
SYSCALL(exit)
 50c:	b8 02 00 00 00       	mov    $0x2,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <wait>:
SYSCALL(wait)
 514:	b8 03 00 00 00       	mov    $0x3,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <wait2>:
SYSCALL(wait2)
 51c:	b8 16 00 00 00       	mov    $0x16,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <add_path>:
SYSCALL(add_path)
 524:	b8 17 00 00 00       	mov    $0x17,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <pipe>:
SYSCALL(pipe)
 52c:	b8 04 00 00 00       	mov    $0x4,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <read>:
SYSCALL(read)
 534:	b8 05 00 00 00       	mov    $0x5,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <write>:
SYSCALL(write)
 53c:	b8 10 00 00 00       	mov    $0x10,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <close>:
SYSCALL(close)
 544:	b8 15 00 00 00       	mov    $0x15,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <kill>:
SYSCALL(kill)
 54c:	b8 06 00 00 00       	mov    $0x6,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <exec>:
SYSCALL(exec)
 554:	b8 07 00 00 00       	mov    $0x7,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <open>:
SYSCALL(open)
 55c:	b8 0f 00 00 00       	mov    $0xf,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <mknod>:
SYSCALL(mknod)
 564:	b8 11 00 00 00       	mov    $0x11,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <unlink>:
SYSCALL(unlink)
 56c:	b8 12 00 00 00       	mov    $0x12,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <fstat>:
SYSCALL(fstat)
 574:	b8 08 00 00 00       	mov    $0x8,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <link>:
SYSCALL(link)
 57c:	b8 13 00 00 00       	mov    $0x13,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <mkdir>:
SYSCALL(mkdir)
 584:	b8 14 00 00 00       	mov    $0x14,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <chdir>:
SYSCALL(chdir)
 58c:	b8 09 00 00 00       	mov    $0x9,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <dup>:
SYSCALL(dup)
 594:	b8 0a 00 00 00       	mov    $0xa,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <getpid>:
SYSCALL(getpid)
 59c:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <sbrk>:
SYSCALL(sbrk)
 5a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sleep>:
SYSCALL(sleep)
 5ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <uptime>:
SYSCALL(uptime)
 5b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	83 ec 28             	sub    $0x28,%esp
 5c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5cf:	00 
 5d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	89 04 24             	mov    %eax,(%esp)
 5dd:	e8 5a ff ff ff       	call   53c <write>
}
 5e2:	c9                   	leave  
 5e3:	c3                   	ret    

000005e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e4:	55                   	push   %ebp
 5e5:	89 e5                	mov    %esp,%ebp
 5e7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f5:	74 17                	je     60e <printint+0x2a>
 5f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5fb:	79 11                	jns    60e <printint+0x2a>
    neg = 1;
 5fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 604:	8b 45 0c             	mov    0xc(%ebp),%eax
 607:	f7 d8                	neg    %eax
 609:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60c:	eb 06                	jmp    614 <printint+0x30>
  } else {
    x = xx;
 60e:	8b 45 0c             	mov    0xc(%ebp),%eax
 611:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 614:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 61b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 61e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 621:	ba 00 00 00 00       	mov    $0x0,%edx
 626:	f7 f1                	div    %ecx
 628:	89 d0                	mov    %edx,%eax
 62a:	0f b6 90 04 0d 00 00 	movzbl 0xd04(%eax),%edx
 631:	8d 45 dc             	lea    -0x24(%ebp),%eax
 634:	03 45 f4             	add    -0xc(%ebp),%eax
 637:	88 10                	mov    %dl,(%eax)
 639:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 63d:	8b 55 10             	mov    0x10(%ebp),%edx
 640:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 643:	8b 45 ec             	mov    -0x14(%ebp),%eax
 646:	ba 00 00 00 00       	mov    $0x0,%edx
 64b:	f7 75 d4             	divl   -0x2c(%ebp)
 64e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 651:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 655:	75 c4                	jne    61b <printint+0x37>
  if(neg)
 657:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65b:	74 2a                	je     687 <printint+0xa3>
    buf[i++] = '-';
 65d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 660:	03 45 f4             	add    -0xc(%ebp),%eax
 663:	c6 00 2d             	movb   $0x2d,(%eax)
 666:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 66a:	eb 1b                	jmp    687 <printint+0xa3>
    putc(fd, buf[i]);
 66c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 66f:	03 45 f4             	add    -0xc(%ebp),%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	0f be c0             	movsbl %al,%eax
 678:	89 44 24 04          	mov    %eax,0x4(%esp)
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 04 24             	mov    %eax,(%esp)
 682:	e8 35 ff ff ff       	call   5bc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 687:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 68b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68f:	79 db                	jns    66c <printint+0x88>
    putc(fd, buf[i]);
}
 691:	c9                   	leave  
 692:	c3                   	ret    

00000693 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 693:	55                   	push   %ebp
 694:	89 e5                	mov    %esp,%ebp
 696:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 699:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a0:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a3:	83 c0 04             	add    $0x4,%eax
 6a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b0:	e9 7d 01 00 00       	jmp    832 <printf+0x19f>
    c = fmt[i] & 0xff;
 6b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bb:	01 d0                	add    %edx,%eax
 6bd:	0f b6 00             	movzbl (%eax),%eax
 6c0:	0f be c0             	movsbl %al,%eax
 6c3:	25 ff 00 00 00       	and    $0xff,%eax
 6c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cf:	75 2c                	jne    6fd <printf+0x6a>
      if(c == '%'){
 6d1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d5:	75 0c                	jne    6e3 <printf+0x50>
        state = '%';
 6d7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6de:	e9 4b 01 00 00       	jmp    82e <printf+0x19b>
      } else {
        putc(fd, c);
 6e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e6:	0f be c0             	movsbl %al,%eax
 6e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ed:	8b 45 08             	mov    0x8(%ebp),%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 c4 fe ff ff       	call   5bc <putc>
 6f8:	e9 31 01 00 00       	jmp    82e <printf+0x19b>
      }
    } else if(state == '%'){
 6fd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 701:	0f 85 27 01 00 00    	jne    82e <printf+0x19b>
      if(c == 'd'){
 707:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 70b:	75 2d                	jne    73a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 70d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 719:	00 
 71a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 721:	00 
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 b3 fe ff ff       	call   5e4 <printint>
        ap++;
 731:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 735:	e9 ed 00 00 00       	jmp    827 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 73a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 73e:	74 06                	je     746 <printf+0xb3>
 740:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 744:	75 2d                	jne    773 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 746:	8b 45 e8             	mov    -0x18(%ebp),%eax
 749:	8b 00                	mov    (%eax),%eax
 74b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 752:	00 
 753:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 75a:	00 
 75b:	89 44 24 04          	mov    %eax,0x4(%esp)
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 7a fe ff ff       	call   5e4 <printint>
        ap++;
 76a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76e:	e9 b4 00 00 00       	jmp    827 <printf+0x194>
      } else if(c == 's'){
 773:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 777:	75 46                	jne    7bf <printf+0x12c>
        s = (char*)*ap;
 779:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 781:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 785:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 789:	75 27                	jne    7b2 <printf+0x11f>
          s = "(null)";
 78b:	c7 45 f4 bc 0a 00 00 	movl   $0xabc,-0xc(%ebp)
        while(*s != 0){
 792:	eb 1e                	jmp    7b2 <printf+0x11f>
          putc(fd, *s);
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	0f b6 00             	movzbl (%eax),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a1:	8b 45 08             	mov    0x8(%ebp),%eax
 7a4:	89 04 24             	mov    %eax,(%esp)
 7a7:	e8 10 fe ff ff       	call   5bc <putc>
          s++;
 7ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7b0:	eb 01                	jmp    7b3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b2:	90                   	nop
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	0f b6 00             	movzbl (%eax),%eax
 7b9:	84 c0                	test   %al,%al
 7bb:	75 d7                	jne    794 <printf+0x101>
 7bd:	eb 68                	jmp    827 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c3:	75 1d                	jne    7e2 <printf+0x14f>
        putc(fd, *ap);
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	0f be c0             	movsbl %al,%eax
 7cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d1:	8b 45 08             	mov    0x8(%ebp),%eax
 7d4:	89 04 24             	mov    %eax,(%esp)
 7d7:	e8 e0 fd ff ff       	call   5bc <putc>
        ap++;
 7dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e0:	eb 45                	jmp    827 <printf+0x194>
      } else if(c == '%'){
 7e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e6:	75 17                	jne    7ff <printf+0x16c>
        putc(fd, c);
 7e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	89 04 24             	mov    %eax,(%esp)
 7f8:	e8 bf fd ff ff       	call   5bc <putc>
 7fd:	eb 28                	jmp    827 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 806:	00 
 807:	8b 45 08             	mov    0x8(%ebp),%eax
 80a:	89 04 24             	mov    %eax,(%esp)
 80d:	e8 aa fd ff ff       	call   5bc <putc>
        putc(fd, c);
 812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 815:	0f be c0             	movsbl %al,%eax
 818:	89 44 24 04          	mov    %eax,0x4(%esp)
 81c:	8b 45 08             	mov    0x8(%ebp),%eax
 81f:	89 04 24             	mov    %eax,(%esp)
 822:	e8 95 fd ff ff       	call   5bc <putc>
      }
      state = 0;
 827:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 832:	8b 55 0c             	mov    0xc(%ebp),%edx
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	01 d0                	add    %edx,%eax
 83a:	0f b6 00             	movzbl (%eax),%eax
 83d:	84 c0                	test   %al,%al
 83f:	0f 85 70 fe ff ff    	jne    6b5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 845:	c9                   	leave  
 846:	c3                   	ret    
 847:	90                   	nop

00000848 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 848:	55                   	push   %ebp
 849:	89 e5                	mov    %esp,%ebp
 84b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	83 e8 08             	sub    $0x8,%eax
 854:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 857:	a1 20 0d 00 00       	mov    0xd20,%eax
 85c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85f:	eb 24                	jmp    885 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 869:	77 12                	ja     87d <free+0x35>
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 871:	77 24                	ja     897 <free+0x4f>
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87b:	77 1a                	ja     897 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	89 45 fc             	mov    %eax,-0x4(%ebp)
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88b:	76 d4                	jbe    861 <free+0x19>
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 895:	76 ca                	jbe    861 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	c1 e0 03             	shl    $0x3,%eax
 8a0:	89 c2                	mov    %eax,%edx
 8a2:	03 55 f8             	add    -0x8(%ebp),%edx
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	39 c2                	cmp    %eax,%edx
 8ac:	75 24                	jne    8d2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	8b 50 04             	mov    0x4(%eax),%edx
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	8b 40 04             	mov    0x4(%eax),%eax
 8bc:	01 c2                	add    %eax,%edx
 8be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	8b 10                	mov    (%eax),%edx
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	89 10                	mov    %edx,(%eax)
 8d0:	eb 0a                	jmp    8dc <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d5:	8b 10                	mov    (%eax),%edx
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 40 04             	mov    0x4(%eax),%eax
 8e2:	c1 e0 03             	shl    $0x3,%eax
 8e5:	03 45 fc             	add    -0x4(%ebp),%eax
 8e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8eb:	75 20                	jne    90d <free+0xc5>
    p->s.size += bp->s.size;
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 50 04             	mov    0x4(%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	8b 40 04             	mov    0x4(%eax),%eax
 8f9:	01 c2                	add    %eax,%edx
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	8b 10                	mov    (%eax),%edx
 906:	8b 45 fc             	mov    -0x4(%ebp),%eax
 909:	89 10                	mov    %edx,(%eax)
 90b:	eb 08                	jmp    915 <free+0xcd>
  } else
    p->s.ptr = bp;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 55 f8             	mov    -0x8(%ebp),%edx
 913:	89 10                	mov    %edx,(%eax)
  freep = p;
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	a3 20 0d 00 00       	mov    %eax,0xd20
}
 91d:	c9                   	leave  
 91e:	c3                   	ret    

0000091f <morecore>:

static Header*
morecore(uint nu)
{
 91f:	55                   	push   %ebp
 920:	89 e5                	mov    %esp,%ebp
 922:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 925:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 92c:	77 07                	ja     935 <morecore+0x16>
    nu = 4096;
 92e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 935:	8b 45 08             	mov    0x8(%ebp),%eax
 938:	c1 e0 03             	shl    $0x3,%eax
 93b:	89 04 24             	mov    %eax,(%esp)
 93e:	e8 61 fc ff ff       	call   5a4 <sbrk>
 943:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 946:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 94a:	75 07                	jne    953 <morecore+0x34>
    return 0;
 94c:	b8 00 00 00 00       	mov    $0x0,%eax
 951:	eb 22                	jmp    975 <morecore+0x56>
  hp = (Header*)p;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	8b 55 08             	mov    0x8(%ebp),%edx
 95f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 962:	8b 45 f0             	mov    -0x10(%ebp),%eax
 965:	83 c0 08             	add    $0x8,%eax
 968:	89 04 24             	mov    %eax,(%esp)
 96b:	e8 d8 fe ff ff       	call   848 <free>
  return freep;
 970:	a1 20 0d 00 00       	mov    0xd20,%eax
}
 975:	c9                   	leave  
 976:	c3                   	ret    

00000977 <malloc>:

void*
malloc(uint nbytes)
{
 977:	55                   	push   %ebp
 978:	89 e5                	mov    %esp,%ebp
 97a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 97d:	8b 45 08             	mov    0x8(%ebp),%eax
 980:	83 c0 07             	add    $0x7,%eax
 983:	c1 e8 03             	shr    $0x3,%eax
 986:	83 c0 01             	add    $0x1,%eax
 989:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 98c:	a1 20 0d 00 00       	mov    0xd20,%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 998:	75 23                	jne    9bd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 99a:	c7 45 f0 18 0d 00 00 	movl   $0xd18,-0x10(%ebp)
 9a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a4:	a3 20 0d 00 00       	mov    %eax,0xd20
 9a9:	a1 20 0d 00 00       	mov    0xd20,%eax
 9ae:	a3 18 0d 00 00       	mov    %eax,0xd18
    base.s.size = 0;
 9b3:	c7 05 1c 0d 00 00 00 	movl   $0x0,0xd1c
 9ba:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 40 04             	mov    0x4(%eax),%eax
 9cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ce:	72 4d                	jb     a1d <malloc+0xa6>
      if(p->s.size == nunits)
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 40 04             	mov    0x4(%eax),%eax
 9d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d9:	75 0c                	jne    9e7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9de:	8b 10                	mov    (%eax),%edx
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	89 10                	mov    %edx,(%eax)
 9e5:	eb 26                	jmp    a0d <malloc+0x96>
      else {
        p->s.size -= nunits;
 9e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ea:	8b 40 04             	mov    0x4(%eax),%eax
 9ed:	89 c2                	mov    %eax,%edx
 9ef:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 40 04             	mov    0x4(%eax),%eax
 9fe:	c1 e0 03             	shl    $0x3,%eax
 a01:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a10:	a3 20 0d 00 00       	mov    %eax,0xd20
      return (void*)(p + 1);
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	83 c0 08             	add    $0x8,%eax
 a1b:	eb 38                	jmp    a55 <malloc+0xde>
    }
    if(p == freep)
 a1d:	a1 20 0d 00 00       	mov    0xd20,%eax
 a22:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a25:	75 1b                	jne    a42 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 ed fe ff ff       	call   91f <morecore>
 a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a39:	75 07                	jne    a42 <malloc+0xcb>
        return 0;
 a3b:	b8 00 00 00 00       	mov    $0x0,%eax
 a40:	eb 13                	jmp    a55 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4b:	8b 00                	mov    (%eax),%eax
 a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a50:	e9 70 ff ff ff       	jmp    9c5 <malloc+0x4e>
}
 a55:	c9                   	leave  
 a56:	c3                   	ret    
