
_s2:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[]) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  char *path, *password;
  int pid;
  int fd,n;
  
  if(argc <= 2) {
   c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  10:	7f 19                	jg     2b <main+0x2b>
    printf(2,"not enough arguments\n");
  12:	c7 44 24 04 a4 09 00 	movl   $0x9a4,0x4(%esp)
  19:	00 
  1a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  21:	e8 b1 05 00 00       	call   5d7 <printf>
    exit();
  26:	e8 04 04 00 00       	call   42f <exit>
  } else {
    path = argv[1];
  2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  2e:	8b 40 04             	mov    0x4(%eax),%eax
  31:	89 84 24 2c 02 00 00 	mov    %eax,0x22c(%esp)
    password = argv[2];
  38:	8b 45 0c             	mov    0xc(%ebp),%eax
  3b:	8b 40 08             	mov    0x8(%eax),%eax
  3e:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
    fprot(path, password);//Protect the file in the given path with the given password
  45:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  50:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  57:	89 04 24             	mov    %eax,(%esp)
  5a:	e8 80 04 00 00       	call   4df <fprot>

    pid = fork(); //Use fork:
  5f:	e8 c3 03 00 00       	call   427 <fork>
  64:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
    
    if (pid == 0) { //Child process
  6b:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
  72:	00 
  73:	0f 85 f0 00 00 00    	jne    169 <main+0x169>
      funlock(path,password);			//a. Unlock the file
  79:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  80:	89 44 24 04          	mov    %eax,0x4(%esp)
  84:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8b:	89 04 24             	mov    %eax,(%esp)
  8e:	e8 5c 04 00 00       	call   4ef <funlock>
      fd = open(path, O_RDONLY);		 //b. Open the file and print its content.
  93:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  9a:	00 
  9b:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  a2:	89 04 24             	mov    %eax,(%esp)
  a5:	e8 c5 03 00 00       	call   46f <open>
  aa:	89 84 24 20 02 00 00 	mov    %eax,0x220(%esp)
      if (fd<0)
  b1:	83 bc 24 20 02 00 00 	cmpl   $0x0,0x220(%esp)
  b8:	00 
  b9:	79 24                	jns    df <main+0xdf>
    	  printf(2, "chld_proc: could not open file %s\n", path);
  bb:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  c6:	c7 44 24 04 bc 09 00 	movl   $0x9bc,0x4(%esp)
  cd:	00 
  ce:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d5:	e8 fd 04 00 00       	call   5d7 <printf>
  da:	e9 85 00 00 00       	jmp    164 <main+0x164>
      else {
    	  char buf[512];
    	  printf(1," chld_proc: The file content is \n");
  df:	c7 44 24 04 e0 09 00 	movl   $0x9e0,0x4(%esp)
  e6:	00 
  e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ee:	e8 e4 04 00 00       	call   5d7 <printf>
    	  while((n = read(fd, buf, sizeof(buf))) > 0){
  f3:	eb 1c                	jmp    111 <main+0x111>
    		  printf(1,"%s", buf);
  f5:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  fd:	c7 44 24 04 02 0a 00 	movl   $0xa02,0x4(%esp)
 104:	00 
 105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 10c:	e8 c6 04 00 00       	call   5d7 <printf>
      if (fd<0)
    	  printf(2, "chld_proc: could not open file %s\n", path);
      else {
    	  char buf[512];
    	  printf(1," chld_proc: The file content is \n");
    	  while((n = read(fd, buf, sizeof(buf))) > 0){
 111:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 118:	00 
 119:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 11d:	89 44 24 04          	mov    %eax,0x4(%esp)
 121:	8b 84 24 20 02 00 00 	mov    0x220(%esp),%eax
 128:	89 04 24             	mov    %eax,(%esp)
 12b:	e8 17 03 00 00       	call   447 <read>
 130:	89 84 24 1c 02 00 00 	mov    %eax,0x21c(%esp)
 137:	83 bc 24 1c 02 00 00 	cmpl   $0x0,0x21c(%esp)
 13e:	00 
 13f:	7f b4                	jg     f5 <main+0xf5>
    		  printf(1,"%s", buf);
    	  }
    	  printf(1,"\n");
 141:	c7 44 24 04 05 0a 00 	movl   $0xa05,0x4(%esp)
 148:	00 
 149:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 150:	e8 82 04 00 00       	call   5d7 <printf>
    	  close(fd);  //c. Close the file
 155:	8b 84 24 20 02 00 00 	mov    0x220(%esp),%eax
 15c:	89 04 24             	mov    %eax,(%esp)
 15f:	e8 f3 02 00 00       	call   457 <close>
      }
      exit();
 164:	e8 c6 02 00 00       	call   42f <exit>
    } else {
      wait(); 	// a. Wait for child process to die.
 169:	e8 c9 02 00 00       	call   437 <wait>
      if (open(path, O_RDONLY ) < 0) //	b. Open the file in the given path.
 16e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 175:	00 
 176:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 17d:	89 04 24             	mov    %eax,(%esp)
 180:	e8 ea 02 00 00       	call   46f <open>
 185:	85 c0                	test   %eax,%eax
 187:	79 1f                	jns    1a8 <main+0x1a8>
    	  printf(2, "parent_proc: could not open file name: %s\n", path); //c. If the open failed, write failed to open file.
 189:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 190:	89 44 24 08          	mov    %eax,0x8(%esp)
 194:	c7 44 24 04 08 0a 00 	movl   $0xa08,0x4(%esp)
 19b:	00 
 19c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1a3:	e8 2f 04 00 00       	call   5d7 <printf>
      funprot(path, password); //d. Unprotect the file.
 1a8:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1af:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b3:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 25 03 00 00       	call   4e7 <funprot>
    }
    exit();
 1c2:	e8 68 02 00 00       	call   42f <exit>

000001c7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1c7:	55                   	push   %ebp
 1c8:	89 e5                	mov    %esp,%ebp
 1ca:	57                   	push   %edi
 1cb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1cf:	8b 55 10             	mov    0x10(%ebp),%edx
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	89 cb                	mov    %ecx,%ebx
 1d7:	89 df                	mov    %ebx,%edi
 1d9:	89 d1                	mov    %edx,%ecx
 1db:	fc                   	cld    
 1dc:	f3 aa                	rep stos %al,%es:(%edi)
 1de:	89 ca                	mov    %ecx,%edx
 1e0:	89 fb                	mov    %edi,%ebx
 1e2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1e5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1e8:	5b                   	pop    %ebx
 1e9:	5f                   	pop    %edi
 1ea:	5d                   	pop    %ebp
 1eb:	c3                   	ret    

000001ec <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1f8:	90                   	nop
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	8d 50 01             	lea    0x1(%eax),%edx
 1ff:	89 55 08             	mov    %edx,0x8(%ebp)
 202:	8b 55 0c             	mov    0xc(%ebp),%edx
 205:	8d 4a 01             	lea    0x1(%edx),%ecx
 208:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 20b:	0f b6 12             	movzbl (%edx),%edx
 20e:	88 10                	mov    %dl,(%eax)
 210:	0f b6 00             	movzbl (%eax),%eax
 213:	84 c0                	test   %al,%al
 215:	75 e2                	jne    1f9 <strcpy+0xd>
    ;
  return os;
 217:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21a:	c9                   	leave  
 21b:	c3                   	ret    

0000021c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 21f:	eb 08                	jmp    229 <strcmp+0xd>
    p++, q++;
 221:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 225:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	84 c0                	test   %al,%al
 231:	74 10                	je     243 <strcmp+0x27>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 10             	movzbl (%eax),%edx
 239:	8b 45 0c             	mov    0xc(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	38 c2                	cmp    %al,%dl
 241:	74 de                	je     221 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	0f b6 00             	movzbl (%eax),%eax
 249:	0f b6 d0             	movzbl %al,%edx
 24c:	8b 45 0c             	mov    0xc(%ebp),%eax
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	0f b6 c0             	movzbl %al,%eax
 255:	29 c2                	sub    %eax,%edx
 257:	89 d0                	mov    %edx,%eax
}
 259:	5d                   	pop    %ebp
 25a:	c3                   	ret    

0000025b <strlen>:

uint
strlen(char *s)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 261:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 268:	eb 04                	jmp    26e <strlen+0x13>
 26a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 26e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 271:	8b 45 08             	mov    0x8(%ebp),%eax
 274:	01 d0                	add    %edx,%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	84 c0                	test   %al,%al
 27b:	75 ed                	jne    26a <strlen+0xf>
    ;
  return n;
 27d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 280:	c9                   	leave  
 281:	c3                   	ret    

00000282 <memset>:

void*
memset(void *dst, int c, uint n)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 288:	8b 45 10             	mov    0x10(%ebp),%eax
 28b:	89 44 24 08          	mov    %eax,0x8(%esp)
 28f:	8b 45 0c             	mov    0xc(%ebp),%eax
 292:	89 44 24 04          	mov    %eax,0x4(%esp)
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	89 04 24             	mov    %eax,(%esp)
 29c:	e8 26 ff ff ff       	call   1c7 <stosb>
  return dst;
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a4:	c9                   	leave  
 2a5:	c3                   	ret    

000002a6 <strchr>:

char*
strchr(const char *s, char c)
{
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	83 ec 04             	sub    $0x4,%esp
 2ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 2af:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b2:	eb 14                	jmp    2c8 <strchr+0x22>
    if(*s == c)
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2bd:	75 05                	jne    2c4 <strchr+0x1e>
      return (char*)s;
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	eb 13                	jmp    2d7 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	0f b6 00             	movzbl (%eax),%eax
 2ce:	84 c0                	test   %al,%al
 2d0:	75 e2                	jne    2b4 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    

000002d9 <gets>:

char*
gets(char *buf, int max)
{
 2d9:	55                   	push   %ebp
 2da:	89 e5                	mov    %esp,%ebp
 2dc:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e6:	eb 4c                	jmp    334 <gets+0x5b>
    cc = read(0, &c, 1);
 2e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2ef:	00 
 2f0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2fe:	e8 44 01 00 00       	call   447 <read>
 303:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 306:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30a:	7f 02                	jg     30e <gets+0x35>
      break;
 30c:	eb 31                	jmp    33f <gets+0x66>
    buf[i++] = c;
 30e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 311:	8d 50 01             	lea    0x1(%eax),%edx
 314:	89 55 f4             	mov    %edx,-0xc(%ebp)
 317:	89 c2                	mov    %eax,%edx
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	01 c2                	add    %eax,%edx
 31e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 322:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 324:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 328:	3c 0a                	cmp    $0xa,%al
 32a:	74 13                	je     33f <gets+0x66>
 32c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 330:	3c 0d                	cmp    $0xd,%al
 332:	74 0b                	je     33f <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 334:	8b 45 f4             	mov    -0xc(%ebp),%eax
 337:	83 c0 01             	add    $0x1,%eax
 33a:	3b 45 0c             	cmp    0xc(%ebp),%eax
 33d:	7c a9                	jl     2e8 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 33f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 342:	8b 45 08             	mov    0x8(%ebp),%eax
 345:	01 d0                	add    %edx,%eax
 347:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34d:	c9                   	leave  
 34e:	c3                   	ret    

0000034f <stat>:

int
stat(char *n, struct stat *st)
{
 34f:	55                   	push   %ebp
 350:	89 e5                	mov    %esp,%ebp
 352:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 355:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 35c:	00 
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	89 04 24             	mov    %eax,(%esp)
 363:	e8 07 01 00 00       	call   46f <open>
 368:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 36b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 36f:	79 07                	jns    378 <stat+0x29>
    return -1;
 371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 376:	eb 23                	jmp    39b <stat+0x4c>
  r = fstat(fd, st);
 378:	8b 45 0c             	mov    0xc(%ebp),%eax
 37b:	89 44 24 04          	mov    %eax,0x4(%esp)
 37f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 382:	89 04 24             	mov    %eax,(%esp)
 385:	e8 fd 00 00 00       	call   487 <fstat>
 38a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 38d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 390:	89 04 24             	mov    %eax,(%esp)
 393:	e8 bf 00 00 00       	call   457 <close>
  return r;
 398:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 39b:	c9                   	leave  
 39c:	c3                   	ret    

0000039d <atoi>:

int
atoi(const char *s)
{
 39d:	55                   	push   %ebp
 39e:	89 e5                	mov    %esp,%ebp
 3a0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3aa:	eb 25                	jmp    3d1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 3ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3af:	89 d0                	mov    %edx,%eax
 3b1:	c1 e0 02             	shl    $0x2,%eax
 3b4:	01 d0                	add    %edx,%eax
 3b6:	01 c0                	add    %eax,%eax
 3b8:	89 c1                	mov    %eax,%ecx
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	8d 50 01             	lea    0x1(%eax),%edx
 3c0:	89 55 08             	mov    %edx,0x8(%ebp)
 3c3:	0f b6 00             	movzbl (%eax),%eax
 3c6:	0f be c0             	movsbl %al,%eax
 3c9:	01 c8                	add    %ecx,%eax
 3cb:	83 e8 30             	sub    $0x30,%eax
 3ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	3c 2f                	cmp    $0x2f,%al
 3d9:	7e 0a                	jle    3e5 <atoi+0x48>
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	0f b6 00             	movzbl (%eax),%eax
 3e1:	3c 39                	cmp    $0x39,%al
 3e3:	7e c7                	jle    3ac <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e8:	c9                   	leave  
 3e9:	c3                   	ret    

000003ea <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3ea:	55                   	push   %ebp
 3eb:	89 e5                	mov    %esp,%ebp
 3ed:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3fc:	eb 17                	jmp    415 <memmove+0x2b>
    *dst++ = *src++;
 3fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 401:	8d 50 01             	lea    0x1(%eax),%edx
 404:	89 55 fc             	mov    %edx,-0x4(%ebp)
 407:	8b 55 f8             	mov    -0x8(%ebp),%edx
 40a:	8d 4a 01             	lea    0x1(%edx),%ecx
 40d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 410:	0f b6 12             	movzbl (%edx),%edx
 413:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 415:	8b 45 10             	mov    0x10(%ebp),%eax
 418:	8d 50 ff             	lea    -0x1(%eax),%edx
 41b:	89 55 10             	mov    %edx,0x10(%ebp)
 41e:	85 c0                	test   %eax,%eax
 420:	7f dc                	jg     3fe <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 422:	8b 45 08             	mov    0x8(%ebp),%eax
}
 425:	c9                   	leave  
 426:	c3                   	ret    

00000427 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 427:	b8 01 00 00 00       	mov    $0x1,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <exit>:
SYSCALL(exit)
 42f:	b8 02 00 00 00       	mov    $0x2,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <wait>:
SYSCALL(wait)
 437:	b8 03 00 00 00       	mov    $0x3,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <pipe>:
SYSCALL(pipe)
 43f:	b8 04 00 00 00       	mov    $0x4,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <read>:
SYSCALL(read)
 447:	b8 05 00 00 00       	mov    $0x5,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <write>:
SYSCALL(write)
 44f:	b8 10 00 00 00       	mov    $0x10,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <close>:
SYSCALL(close)
 457:	b8 15 00 00 00       	mov    $0x15,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <kill>:
SYSCALL(kill)
 45f:	b8 06 00 00 00       	mov    $0x6,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <exec>:
SYSCALL(exec)
 467:	b8 07 00 00 00       	mov    $0x7,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <open>:
SYSCALL(open)
 46f:	b8 0f 00 00 00       	mov    $0xf,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <mknod>:
SYSCALL(mknod)
 477:	b8 11 00 00 00       	mov    $0x11,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <unlink>:
SYSCALL(unlink)
 47f:	b8 12 00 00 00       	mov    $0x12,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <fstat>:
SYSCALL(fstat)
 487:	b8 08 00 00 00       	mov    $0x8,%eax
 48c:	cd 40                	int    $0x40
 48e:	c3                   	ret    

0000048f <link>:
SYSCALL(link)
 48f:	b8 13 00 00 00       	mov    $0x13,%eax
 494:	cd 40                	int    $0x40
 496:	c3                   	ret    

00000497 <mkdir>:
SYSCALL(mkdir)
 497:	b8 14 00 00 00       	mov    $0x14,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <chdir>:
SYSCALL(chdir)
 49f:	b8 09 00 00 00       	mov    $0x9,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <dup>:
SYSCALL(dup)
 4a7:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <getpid>:
SYSCALL(getpid)
 4af:	b8 0b 00 00 00       	mov    $0xb,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <sbrk>:
SYSCALL(sbrk)
 4b7:	b8 0c 00 00 00       	mov    $0xc,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <sleep>:
SYSCALL(sleep)
 4bf:	b8 0d 00 00 00       	mov    $0xd,%eax
 4c4:	cd 40                	int    $0x40
 4c6:	c3                   	ret    

000004c7 <uptime>:
SYSCALL(uptime)
 4c7:	b8 0e 00 00 00       	mov    $0xe,%eax
 4cc:	cd 40                	int    $0x40
 4ce:	c3                   	ret    

000004cf <symlink>:
SYSCALL(symlink)
 4cf:	b8 16 00 00 00       	mov    $0x16,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <readlink>:
SYSCALL(readlink)
 4d7:	b8 17 00 00 00       	mov    $0x17,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <fprot>:
SYSCALL(fprot)
 4df:	b8 18 00 00 00       	mov    $0x18,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <funprot>:
SYSCALL(funprot)
 4e7:	b8 19 00 00 00       	mov    $0x19,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <funlock>:
SYSCALL(funlock)
 4ef:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f7:	55                   	push   %ebp
 4f8:	89 e5                	mov    %esp,%ebp
 4fa:	83 ec 18             	sub    $0x18,%esp
 4fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 500:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 503:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 50a:	00 
 50b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 50e:	89 44 24 04          	mov    %eax,0x4(%esp)
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	89 04 24             	mov    %eax,(%esp)
 518:	e8 32 ff ff ff       	call   44f <write>
}
 51d:	c9                   	leave  
 51e:	c3                   	ret    

0000051f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51f:	55                   	push   %ebp
 520:	89 e5                	mov    %esp,%ebp
 522:	56                   	push   %esi
 523:	53                   	push   %ebx
 524:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 527:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 52e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 532:	74 17                	je     54b <printint+0x2c>
 534:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 538:	79 11                	jns    54b <printint+0x2c>
    neg = 1;
 53a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 541:	8b 45 0c             	mov    0xc(%ebp),%eax
 544:	f7 d8                	neg    %eax
 546:	89 45 ec             	mov    %eax,-0x14(%ebp)
 549:	eb 06                	jmp    551 <printint+0x32>
  } else {
    x = xx;
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 551:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 558:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 55b:	8d 41 01             	lea    0x1(%ecx),%eax
 55e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 561:	8b 5d 10             	mov    0x10(%ebp),%ebx
 564:	8b 45 ec             	mov    -0x14(%ebp),%eax
 567:	ba 00 00 00 00       	mov    $0x0,%edx
 56c:	f7 f3                	div    %ebx
 56e:	89 d0                	mov    %edx,%eax
 570:	0f b6 80 80 0c 00 00 	movzbl 0xc80(%eax),%eax
 577:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 57b:	8b 75 10             	mov    0x10(%ebp),%esi
 57e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 581:	ba 00 00 00 00       	mov    $0x0,%edx
 586:	f7 f6                	div    %esi
 588:	89 45 ec             	mov    %eax,-0x14(%ebp)
 58b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 58f:	75 c7                	jne    558 <printint+0x39>
  if(neg)
 591:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 595:	74 10                	je     5a7 <printint+0x88>
    buf[i++] = '-';
 597:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59a:	8d 50 01             	lea    0x1(%eax),%edx
 59d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5a0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5a5:	eb 1f                	jmp    5c6 <printint+0xa7>
 5a7:	eb 1d                	jmp    5c6 <printint+0xa7>
    putc(fd, buf[i]);
 5a9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5af:	01 d0                	add    %edx,%eax
 5b1:	0f b6 00             	movzbl (%eax),%eax
 5b4:	0f be c0             	movsbl %al,%eax
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 31 ff ff ff       	call   4f7 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ce:	79 d9                	jns    5a9 <printint+0x8a>
    putc(fd, buf[i]);
}
 5d0:	83 c4 30             	add    $0x30,%esp
 5d3:	5b                   	pop    %ebx
 5d4:	5e                   	pop    %esi
 5d5:	5d                   	pop    %ebp
 5d6:	c3                   	ret    

000005d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d7:	55                   	push   %ebp
 5d8:	89 e5                	mov    %esp,%ebp
 5da:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e7:	83 c0 04             	add    $0x4,%eax
 5ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f4:	e9 7c 01 00 00       	jmp    775 <printf+0x19e>
    c = fmt[i] & 0xff;
 5f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ff:	01 d0                	add    %edx,%eax
 601:	0f b6 00             	movzbl (%eax),%eax
 604:	0f be c0             	movsbl %al,%eax
 607:	25 ff 00 00 00       	and    $0xff,%eax
 60c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 60f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 613:	75 2c                	jne    641 <printf+0x6a>
      if(c == '%'){
 615:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 619:	75 0c                	jne    627 <printf+0x50>
        state = '%';
 61b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 622:	e9 4a 01 00 00       	jmp    771 <printf+0x19a>
      } else {
        putc(fd, c);
 627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62a:	0f be c0             	movsbl %al,%eax
 62d:	89 44 24 04          	mov    %eax,0x4(%esp)
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	89 04 24             	mov    %eax,(%esp)
 637:	e8 bb fe ff ff       	call   4f7 <putc>
 63c:	e9 30 01 00 00       	jmp    771 <printf+0x19a>
      }
    } else if(state == '%'){
 641:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 645:	0f 85 26 01 00 00    	jne    771 <printf+0x19a>
      if(c == 'd'){
 64b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 64f:	75 2d                	jne    67e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 651:	8b 45 e8             	mov    -0x18(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 65d:	00 
 65e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 665:	00 
 666:	89 44 24 04          	mov    %eax,0x4(%esp)
 66a:	8b 45 08             	mov    0x8(%ebp),%eax
 66d:	89 04 24             	mov    %eax,(%esp)
 670:	e8 aa fe ff ff       	call   51f <printint>
        ap++;
 675:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 679:	e9 ec 00 00 00       	jmp    76a <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 67e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 682:	74 06                	je     68a <printf+0xb3>
 684:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 688:	75 2d                	jne    6b7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 68a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 696:	00 
 697:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 69e:	00 
 69f:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a3:	8b 45 08             	mov    0x8(%ebp),%eax
 6a6:	89 04 24             	mov    %eax,(%esp)
 6a9:	e8 71 fe ff ff       	call   51f <printint>
        ap++;
 6ae:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b2:	e9 b3 00 00 00       	jmp    76a <printf+0x193>
      } else if(c == 's'){
 6b7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6bb:	75 45                	jne    702 <printf+0x12b>
        s = (char*)*ap;
 6bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6cd:	75 09                	jne    6d8 <printf+0x101>
          s = "(null)";
 6cf:	c7 45 f4 33 0a 00 00 	movl   $0xa33,-0xc(%ebp)
        while(*s != 0){
 6d6:	eb 1e                	jmp    6f6 <printf+0x11f>
 6d8:	eb 1c                	jmp    6f6 <printf+0x11f>
          putc(fd, *s);
 6da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6dd:	0f b6 00             	movzbl (%eax),%eax
 6e0:	0f be c0             	movsbl %al,%eax
 6e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	89 04 24             	mov    %eax,(%esp)
 6ed:	e8 05 fe ff ff       	call   4f7 <putc>
          s++;
 6f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f9:	0f b6 00             	movzbl (%eax),%eax
 6fc:	84 c0                	test   %al,%al
 6fe:	75 da                	jne    6da <printf+0x103>
 700:	eb 68                	jmp    76a <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 702:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 706:	75 1d                	jne    725 <printf+0x14e>
        putc(fd, *ap);
 708:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	89 44 24 04          	mov    %eax,0x4(%esp)
 714:	8b 45 08             	mov    0x8(%ebp),%eax
 717:	89 04 24             	mov    %eax,(%esp)
 71a:	e8 d8 fd ff ff       	call   4f7 <putc>
        ap++;
 71f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 723:	eb 45                	jmp    76a <printf+0x193>
      } else if(c == '%'){
 725:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 729:	75 17                	jne    742 <printf+0x16b>
        putc(fd, c);
 72b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72e:	0f be c0             	movsbl %al,%eax
 731:	89 44 24 04          	mov    %eax,0x4(%esp)
 735:	8b 45 08             	mov    0x8(%ebp),%eax
 738:	89 04 24             	mov    %eax,(%esp)
 73b:	e8 b7 fd ff ff       	call   4f7 <putc>
 740:	eb 28                	jmp    76a <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 742:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 749:	00 
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	89 04 24             	mov    %eax,(%esp)
 750:	e8 a2 fd ff ff       	call   4f7 <putc>
        putc(fd, c);
 755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 758:	0f be c0             	movsbl %al,%eax
 75b:	89 44 24 04          	mov    %eax,0x4(%esp)
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 8d fd ff ff       	call   4f7 <putc>
      }
      state = 0;
 76a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 771:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 775:	8b 55 0c             	mov    0xc(%ebp),%edx
 778:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77b:	01 d0                	add    %edx,%eax
 77d:	0f b6 00             	movzbl (%eax),%eax
 780:	84 c0                	test   %al,%al
 782:	0f 85 71 fe ff ff    	jne    5f9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 788:	c9                   	leave  
 789:	c3                   	ret    

0000078a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78a:	55                   	push   %ebp
 78b:	89 e5                	mov    %esp,%ebp
 78d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	83 e8 08             	sub    $0x8,%eax
 796:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 799:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 79e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a1:	eb 24                	jmp    7c7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ab:	77 12                	ja     7bf <free+0x35>
 7ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b3:	77 24                	ja     7d9 <free+0x4f>
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bd:	77 1a                	ja     7d9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cd:	76 d4                	jbe    7a3 <free+0x19>
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d7:	76 ca                	jbe    7a3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	8b 40 04             	mov    0x4(%eax),%eax
 7df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e9:	01 c2                	add    %eax,%edx
 7eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	39 c2                	cmp    %eax,%edx
 7f2:	75 24                	jne    818 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f7:	8b 50 04             	mov    0x4(%eax),%edx
 7fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	01 c2                	add    %eax,%edx
 804:	8b 45 f8             	mov    -0x8(%ebp),%eax
 807:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	8b 00                	mov    (%eax),%eax
 80f:	8b 10                	mov    (%eax),%edx
 811:	8b 45 f8             	mov    -0x8(%ebp),%eax
 814:	89 10                	mov    %edx,(%eax)
 816:	eb 0a                	jmp    822 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 10                	mov    (%eax),%edx
 81d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 820:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 822:	8b 45 fc             	mov    -0x4(%ebp),%eax
 825:	8b 40 04             	mov    0x4(%eax),%eax
 828:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	01 d0                	add    %edx,%eax
 834:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 837:	75 20                	jne    859 <free+0xcf>
    p->s.size += bp->s.size;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 50 04             	mov    0x4(%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	8b 40 04             	mov    0x4(%eax),%eax
 845:	01 c2                	add    %eax,%edx
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	8b 10                	mov    (%eax),%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	89 10                	mov    %edx,(%eax)
 857:	eb 08                	jmp    861 <free+0xd7>
  } else
    p->s.ptr = bp;
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85f:	89 10                	mov    %edx,(%eax)
  freep = p;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	a3 9c 0c 00 00       	mov    %eax,0xc9c
}
 869:	c9                   	leave  
 86a:	c3                   	ret    

0000086b <morecore>:

static Header*
morecore(uint nu)
{
 86b:	55                   	push   %ebp
 86c:	89 e5                	mov    %esp,%ebp
 86e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 871:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 878:	77 07                	ja     881 <morecore+0x16>
    nu = 4096;
 87a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 881:	8b 45 08             	mov    0x8(%ebp),%eax
 884:	c1 e0 03             	shl    $0x3,%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 28 fc ff ff       	call   4b7 <sbrk>
 88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 892:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 896:	75 07                	jne    89f <morecore+0x34>
    return 0;
 898:	b8 00 00 00 00       	mov    $0x0,%eax
 89d:	eb 22                	jmp    8c1 <morecore+0x56>
  hp = (Header*)p;
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	8b 55 08             	mov    0x8(%ebp),%edx
 8ab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	83 c0 08             	add    $0x8,%eax
 8b4:	89 04 24             	mov    %eax,(%esp)
 8b7:	e8 ce fe ff ff       	call   78a <free>
  return freep;
 8bc:	a1 9c 0c 00 00       	mov    0xc9c,%eax
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <malloc>:

void*
malloc(uint nbytes)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c9:	8b 45 08             	mov    0x8(%ebp),%eax
 8cc:	83 c0 07             	add    $0x7,%eax
 8cf:	c1 e8 03             	shr    $0x3,%eax
 8d2:	83 c0 01             	add    $0x1,%eax
 8d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d8:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e4:	75 23                	jne    909 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e6:	c7 45 f0 94 0c 00 00 	movl   $0xc94,-0x10(%ebp)
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	a3 9c 0c 00 00       	mov    %eax,0xc9c
 8f5:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 8fa:	a3 94 0c 00 00       	mov    %eax,0xc94
    base.s.size = 0;
 8ff:	c7 05 98 0c 00 00 00 	movl   $0x0,0xc98
 906:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 91a:	72 4d                	jb     969 <malloc+0xa6>
      if(p->s.size == nunits)
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	8b 40 04             	mov    0x4(%eax),%eax
 922:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 925:	75 0c                	jne    933 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	8b 10                	mov    (%eax),%edx
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	89 10                	mov    %edx,(%eax)
 931:	eb 26                	jmp    959 <malloc+0x96>
      else {
        p->s.size -= nunits;
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	2b 45 ec             	sub    -0x14(%ebp),%eax
 93c:	89 c2                	mov    %eax,%edx
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	c1 e0 03             	shl    $0x3,%eax
 94d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8b 55 ec             	mov    -0x14(%ebp),%edx
 956:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	a3 9c 0c 00 00       	mov    %eax,0xc9c
      return (void*)(p + 1);
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	83 c0 08             	add    $0x8,%eax
 967:	eb 38                	jmp    9a1 <malloc+0xde>
    }
    if(p == freep)
 969:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 96e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 971:	75 1b                	jne    98e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 973:	8b 45 ec             	mov    -0x14(%ebp),%eax
 976:	89 04 24             	mov    %eax,(%esp)
 979:	e8 ed fe ff ff       	call   86b <morecore>
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 985:	75 07                	jne    98e <malloc+0xcb>
        return 0;
 987:	b8 00 00 00 00       	mov    $0x0,%eax
 98c:	eb 13                	jmp    9a1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 00                	mov    (%eax),%eax
 999:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99c:	e9 70 ff ff ff       	jmp    911 <malloc+0x4e>
}
 9a1:	c9                   	leave  
 9a2:	c3                   	ret    
