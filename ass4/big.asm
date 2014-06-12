
_big:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  char buf[512];
  int fd, i,j;
  char a;

  fd = open("big.file", O_CREATE | O_WRONLY);
   c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  13:	00 
  14:	c7 04 24 10 09 00 00 	movl   $0x910,(%esp)
  1b:	e8 d4 03 00 00       	call   3f4 <open>
  20:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
  if(fd < 0){
  27:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
  2e:	00 
  2f:	79 19                	jns    4a <main+0x4a>
    printf(2, "big: cannot open big.file for writing\n");
  31:	c7 44 24 04 1c 09 00 	movl   $0x91c,0x4(%esp)
  38:	00 
  39:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  40:	e8 ff 04 00 00       	call   544 <printf>
    exit();
  45:	e8 6a 03 00 00       	call   3b4 <exit>
  }
  a = 'A';
  4a:	c6 84 24 23 02 00 00 	movb   $0x41,0x223(%esp)
  51:	41 
  for (i=0; i<1024; i++){
  52:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  59:	00 00 00 00 
  5d:	e9 c5 00 00 00       	jmp    127 <main+0x127>
    for (j=0; j<1024; j++){
  62:	c7 84 24 28 02 00 00 	movl   $0x0,0x228(%esp)
  69:	00 00 00 00 
  6d:	eb 46                	jmp    b5 <main+0xb5>
      *(char*)buf = a;
  6f:	0f b6 84 24 23 02 00 	movzbl 0x223(%esp),%eax
  76:	00 
  77:	88 44 24 1c          	mov    %al,0x1c(%esp)
      int cc = write(fd, buf, sizeof(buf));
  7b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  82:	00 
  83:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  87:	89 44 24 04          	mov    %eax,0x4(%esp)
  8b:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
  92:	89 04 24             	mov    %eax,(%esp)
  95:	e8 3a 03 00 00       	call   3d4 <write>
  9a:	89 84 24 1c 02 00 00 	mov    %eax,0x21c(%esp)
      if(cc <= 0){
  a1:	83 bc 24 1c 02 00 00 	cmpl   $0x0,0x21c(%esp)
  a8:	00 
  a9:	7f 02                	jg     ad <main+0xad>
    	  break;
  ab:	eb 15                	jmp    c2 <main+0xc2>
    printf(2, "big: cannot open big.file for writing\n");
    exit();
  }
  a = 'A';
  for (i=0; i<1024; i++){
    for (j=0; j<1024; j++){
  ad:	83 84 24 28 02 00 00 	addl   $0x1,0x228(%esp)
  b4:	01 
  b5:	81 bc 24 28 02 00 00 	cmpl   $0x3ff,0x228(%esp)
  bc:	ff 03 00 00 
  c0:	7e ad                	jle    6f <main+0x6f>
      int cc = write(fd, buf, sizeof(buf));
      if(cc <= 0){
    	  break;
      }
    }
    if (i == 5)
  c2:	83 bc 24 2c 02 00 00 	cmpl   $0x5,0x22c(%esp)
  c9:	05 
  ca:	75 14                	jne    e0 <main+0xe0>
      printf(1, "Finished writing 6KB (direct)\n");
  cc:	c7 44 24 04 44 09 00 	movl   $0x944,0x4(%esp)
  d3:	00 
  d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  db:	e8 64 04 00 00       	call   544 <printf>
    if (i == 69)
  e0:	83 bc 24 2c 02 00 00 	cmpl   $0x45,0x22c(%esp)
  e7:	45 
  e8:	75 14                	jne    fe <main+0xfe>
      printf(1, "Finished writing 70KB (single indirect)\n");
  ea:	c7 44 24 04 64 09 00 	movl   $0x964,0x4(%esp)
  f1:	00 
  f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f9:	e8 46 04 00 00       	call   544 <printf>
    if (i == 1023)
  fe:	81 bc 24 2c 02 00 00 	cmpl   $0x3ff,0x22c(%esp)
 105:	ff 03 00 00 
 109:	75 14                	jne    11f <main+0x11f>
      printf(1, "Finished writing 1MB\n");
 10b:	c7 44 24 04 8d 09 00 	movl   $0x98d,0x4(%esp)
 112:	00 
 113:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11a:	e8 25 04 00 00       	call   544 <printf>
  if(fd < 0){
    printf(2, "big: cannot open big.file for writing\n");
    exit();
  }
  a = 'A';
  for (i=0; i<1024; i++){
 11f:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 126:	01 
 127:	81 bc 24 2c 02 00 00 	cmpl   $0x3ff,0x22c(%esp)
 12e:	ff 03 00 00 
 132:	0f 8e 2a ff ff ff    	jle    62 <main+0x62>
      printf(1, "Finished writing 70KB (single indirect)\n");
    if (i == 1023)
      printf(1, "Finished writing 1MB\n");
  }

  close(fd);
 138:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
 13f:	89 04 24             	mov    %eax,(%esp)
 142:	e8 95 02 00 00       	call   3dc <close>

  exit();
 147:	e8 68 02 00 00       	call   3b4 <exit>

0000014c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	57                   	push   %edi
 150:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 151:	8b 4d 08             	mov    0x8(%ebp),%ecx
 154:	8b 55 10             	mov    0x10(%ebp),%edx
 157:	8b 45 0c             	mov    0xc(%ebp),%eax
 15a:	89 cb                	mov    %ecx,%ebx
 15c:	89 df                	mov    %ebx,%edi
 15e:	89 d1                	mov    %edx,%ecx
 160:	fc                   	cld    
 161:	f3 aa                	rep stos %al,%es:(%edi)
 163:	89 ca                	mov    %ecx,%edx
 165:	89 fb                	mov    %edi,%ebx
 167:	89 5d 08             	mov    %ebx,0x8(%ebp)
 16a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 16d:	5b                   	pop    %ebx
 16e:	5f                   	pop    %edi
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    

00000171 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 177:	8b 45 08             	mov    0x8(%ebp),%eax
 17a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 17d:	90                   	nop
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	8d 50 01             	lea    0x1(%eax),%edx
 184:	89 55 08             	mov    %edx,0x8(%ebp)
 187:	8b 55 0c             	mov    0xc(%ebp),%edx
 18a:	8d 4a 01             	lea    0x1(%edx),%ecx
 18d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 190:	0f b6 12             	movzbl (%edx),%edx
 193:	88 10                	mov    %dl,(%eax)
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	84 c0                	test   %al,%al
 19a:	75 e2                	jne    17e <strcpy+0xd>
    ;
  return os;
 19c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 19f:	c9                   	leave  
 1a0:	c3                   	ret    

000001a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1a4:	eb 08                	jmp    1ae <strcmp+0xd>
    p++, q++;
 1a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ae:	8b 45 08             	mov    0x8(%ebp),%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	84 c0                	test   %al,%al
 1b6:	74 10                	je     1c8 <strcmp+0x27>
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	0f b6 10             	movzbl (%eax),%edx
 1be:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c1:	0f b6 00             	movzbl (%eax),%eax
 1c4:	38 c2                	cmp    %al,%dl
 1c6:	74 de                	je     1a6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	0f b6 00             	movzbl (%eax),%eax
 1ce:	0f b6 d0             	movzbl %al,%edx
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	0f b6 c0             	movzbl %al,%eax
 1da:	29 c2                	sub    %eax,%edx
 1dc:	89 d0                	mov    %edx,%eax
}
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <strlen>:

uint
strlen(char *s)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1ed:	eb 04                	jmp    1f3 <strlen+0x13>
 1ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	01 d0                	add    %edx,%eax
 1fb:	0f b6 00             	movzbl (%eax),%eax
 1fe:	84 c0                	test   %al,%al
 200:	75 ed                	jne    1ef <strlen+0xf>
    ;
  return n;
 202:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <memset>:

void*
memset(void *dst, int c, uint n)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 20d:	8b 45 10             	mov    0x10(%ebp),%eax
 210:	89 44 24 08          	mov    %eax,0x8(%esp)
 214:	8b 45 0c             	mov    0xc(%ebp),%eax
 217:	89 44 24 04          	mov    %eax,0x4(%esp)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 26 ff ff ff       	call   14c <stosb>
  return dst;
 226:	8b 45 08             	mov    0x8(%ebp),%eax
}
 229:	c9                   	leave  
 22a:	c3                   	ret    

0000022b <strchr>:

char*
strchr(const char *s, char c)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	83 ec 04             	sub    $0x4,%esp
 231:	8b 45 0c             	mov    0xc(%ebp),%eax
 234:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 237:	eb 14                	jmp    24d <strchr+0x22>
    if(*s == c)
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 242:	75 05                	jne    249 <strchr+0x1e>
      return (char*)s;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	eb 13                	jmp    25c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 249:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	84 c0                	test   %al,%al
 255:	75 e2                	jne    239 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 257:	b8 00 00 00 00       	mov    $0x0,%eax
}
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <gets>:

char*
gets(char *buf, int max)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 264:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 26b:	eb 4c                	jmp    2b9 <gets+0x5b>
    cc = read(0, &c, 1);
 26d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 274:	00 
 275:	8d 45 ef             	lea    -0x11(%ebp),%eax
 278:	89 44 24 04          	mov    %eax,0x4(%esp)
 27c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 283:	e8 44 01 00 00       	call   3cc <read>
 288:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 28b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 28f:	7f 02                	jg     293 <gets+0x35>
      break;
 291:	eb 31                	jmp    2c4 <gets+0x66>
    buf[i++] = c;
 293:	8b 45 f4             	mov    -0xc(%ebp),%eax
 296:	8d 50 01             	lea    0x1(%eax),%edx
 299:	89 55 f4             	mov    %edx,-0xc(%ebp)
 29c:	89 c2                	mov    %eax,%edx
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	01 c2                	add    %eax,%edx
 2a3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ad:	3c 0a                	cmp    $0xa,%al
 2af:	74 13                	je     2c4 <gets+0x66>
 2b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b5:	3c 0d                	cmp    $0xd,%al
 2b7:	74 0b                	je     2c4 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bc:	83 c0 01             	add    $0x1,%eax
 2bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2c2:	7c a9                	jl     26d <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	01 d0                	add    %edx,%eax
 2cc:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d2:	c9                   	leave  
 2d3:	c3                   	ret    

000002d4 <stat>:

int
stat(char *n, struct stat *st)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
 2d7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2e1:	00 
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	89 04 24             	mov    %eax,(%esp)
 2e8:	e8 07 01 00 00       	call   3f4 <open>
 2ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2f4:	79 07                	jns    2fd <stat+0x29>
    return -1;
 2f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2fb:	eb 23                	jmp    320 <stat+0x4c>
  r = fstat(fd, st);
 2fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 300:	89 44 24 04          	mov    %eax,0x4(%esp)
 304:	8b 45 f4             	mov    -0xc(%ebp),%eax
 307:	89 04 24             	mov    %eax,(%esp)
 30a:	e8 fd 00 00 00       	call   40c <fstat>
 30f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 312:	8b 45 f4             	mov    -0xc(%ebp),%eax
 315:	89 04 24             	mov    %eax,(%esp)
 318:	e8 bf 00 00 00       	call   3dc <close>
  return r;
 31d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 320:	c9                   	leave  
 321:	c3                   	ret    

00000322 <atoi>:

int
atoi(const char *s)
{
 322:	55                   	push   %ebp
 323:	89 e5                	mov    %esp,%ebp
 325:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 328:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 32f:	eb 25                	jmp    356 <atoi+0x34>
    n = n*10 + *s++ - '0';
 331:	8b 55 fc             	mov    -0x4(%ebp),%edx
 334:	89 d0                	mov    %edx,%eax
 336:	c1 e0 02             	shl    $0x2,%eax
 339:	01 d0                	add    %edx,%eax
 33b:	01 c0                	add    %eax,%eax
 33d:	89 c1                	mov    %eax,%ecx
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	8d 50 01             	lea    0x1(%eax),%edx
 345:	89 55 08             	mov    %edx,0x8(%ebp)
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	0f be c0             	movsbl %al,%eax
 34e:	01 c8                	add    %ecx,%eax
 350:	83 e8 30             	sub    $0x30,%eax
 353:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 356:	8b 45 08             	mov    0x8(%ebp),%eax
 359:	0f b6 00             	movzbl (%eax),%eax
 35c:	3c 2f                	cmp    $0x2f,%al
 35e:	7e 0a                	jle    36a <atoi+0x48>
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	0f b6 00             	movzbl (%eax),%eax
 366:	3c 39                	cmp    $0x39,%al
 368:	7e c7                	jle    331 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 36a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 37b:	8b 45 0c             	mov    0xc(%ebp),%eax
 37e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 381:	eb 17                	jmp    39a <memmove+0x2b>
    *dst++ = *src++;
 383:	8b 45 fc             	mov    -0x4(%ebp),%eax
 386:	8d 50 01             	lea    0x1(%eax),%edx
 389:	89 55 fc             	mov    %edx,-0x4(%ebp)
 38c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 38f:	8d 4a 01             	lea    0x1(%edx),%ecx
 392:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 395:	0f b6 12             	movzbl (%edx),%edx
 398:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 39a:	8b 45 10             	mov    0x10(%ebp),%eax
 39d:	8d 50 ff             	lea    -0x1(%eax),%edx
 3a0:	89 55 10             	mov    %edx,0x10(%ebp)
 3a3:	85 c0                	test   %eax,%eax
 3a5:	7f dc                	jg     383 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3aa:	c9                   	leave  
 3ab:	c3                   	ret    

000003ac <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3ac:	b8 01 00 00 00       	mov    $0x1,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <exit>:
SYSCALL(exit)
 3b4:	b8 02 00 00 00       	mov    $0x2,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <wait>:
SYSCALL(wait)
 3bc:	b8 03 00 00 00       	mov    $0x3,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <pipe>:
SYSCALL(pipe)
 3c4:	b8 04 00 00 00       	mov    $0x4,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <read>:
SYSCALL(read)
 3cc:	b8 05 00 00 00       	mov    $0x5,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <write>:
SYSCALL(write)
 3d4:	b8 10 00 00 00       	mov    $0x10,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <close>:
SYSCALL(close)
 3dc:	b8 15 00 00 00       	mov    $0x15,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <kill>:
SYSCALL(kill)
 3e4:	b8 06 00 00 00       	mov    $0x6,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <exec>:
SYSCALL(exec)
 3ec:	b8 07 00 00 00       	mov    $0x7,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <open>:
SYSCALL(open)
 3f4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <mknod>:
SYSCALL(mknod)
 3fc:	b8 11 00 00 00       	mov    $0x11,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <unlink>:
SYSCALL(unlink)
 404:	b8 12 00 00 00       	mov    $0x12,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <fstat>:
SYSCALL(fstat)
 40c:	b8 08 00 00 00       	mov    $0x8,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <link>:
SYSCALL(link)
 414:	b8 13 00 00 00       	mov    $0x13,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <mkdir>:
SYSCALL(mkdir)
 41c:	b8 14 00 00 00       	mov    $0x14,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <chdir>:
SYSCALL(chdir)
 424:	b8 09 00 00 00       	mov    $0x9,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <dup>:
SYSCALL(dup)
 42c:	b8 0a 00 00 00       	mov    $0xa,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <getpid>:
SYSCALL(getpid)
 434:	b8 0b 00 00 00       	mov    $0xb,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <sbrk>:
SYSCALL(sbrk)
 43c:	b8 0c 00 00 00       	mov    $0xc,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <sleep>:
SYSCALL(sleep)
 444:	b8 0d 00 00 00       	mov    $0xd,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <uptime>:
SYSCALL(uptime)
 44c:	b8 0e 00 00 00       	mov    $0xe,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <symlink>:
SYSCALL(symlink)
 454:	b8 16 00 00 00       	mov    $0x16,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <readlink>:
SYSCALL(readlink)
 45c:	b8 17 00 00 00       	mov    $0x17,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 464:	55                   	push   %ebp
 465:	89 e5                	mov    %esp,%ebp
 467:	83 ec 18             	sub    $0x18,%esp
 46a:	8b 45 0c             	mov    0xc(%ebp),%eax
 46d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 470:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 477:	00 
 478:	8d 45 f4             	lea    -0xc(%ebp),%eax
 47b:	89 44 24 04          	mov    %eax,0x4(%esp)
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	89 04 24             	mov    %eax,(%esp)
 485:	e8 4a ff ff ff       	call   3d4 <write>
}
 48a:	c9                   	leave  
 48b:	c3                   	ret    

0000048c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48c:	55                   	push   %ebp
 48d:	89 e5                	mov    %esp,%ebp
 48f:	56                   	push   %esi
 490:	53                   	push   %ebx
 491:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 494:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 49b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 49f:	74 17                	je     4b8 <printint+0x2c>
 4a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4a5:	79 11                	jns    4b8 <printint+0x2c>
    neg = 1;
 4a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b1:	f7 d8                	neg    %eax
 4b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b6:	eb 06                	jmp    4be <printint+0x32>
  } else {
    x = xx;
 4b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4c5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4c8:	8d 41 01             	lea    0x1(%ecx),%eax
 4cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d4:	ba 00 00 00 00       	mov    $0x0,%edx
 4d9:	f7 f3                	div    %ebx
 4db:	89 d0                	mov    %edx,%eax
 4dd:	0f b6 80 f0 0b 00 00 	movzbl 0xbf0(%eax),%eax
 4e4:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4e8:	8b 75 10             	mov    0x10(%ebp),%esi
 4eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ee:	ba 00 00 00 00       	mov    $0x0,%edx
 4f3:	f7 f6                	div    %esi
 4f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4fc:	75 c7                	jne    4c5 <printint+0x39>
  if(neg)
 4fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 502:	74 10                	je     514 <printint+0x88>
    buf[i++] = '-';
 504:	8b 45 f4             	mov    -0xc(%ebp),%eax
 507:	8d 50 01             	lea    0x1(%eax),%edx
 50a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 50d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 512:	eb 1f                	jmp    533 <printint+0xa7>
 514:	eb 1d                	jmp    533 <printint+0xa7>
    putc(fd, buf[i]);
 516:	8d 55 dc             	lea    -0x24(%ebp),%edx
 519:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51c:	01 d0                	add    %edx,%eax
 51e:	0f b6 00             	movzbl (%eax),%eax
 521:	0f be c0             	movsbl %al,%eax
 524:	89 44 24 04          	mov    %eax,0x4(%esp)
 528:	8b 45 08             	mov    0x8(%ebp),%eax
 52b:	89 04 24             	mov    %eax,(%esp)
 52e:	e8 31 ff ff ff       	call   464 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 533:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 537:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53b:	79 d9                	jns    516 <printint+0x8a>
    putc(fd, buf[i]);
}
 53d:	83 c4 30             	add    $0x30,%esp
 540:	5b                   	pop    %ebx
 541:	5e                   	pop    %esi
 542:	5d                   	pop    %ebp
 543:	c3                   	ret    

00000544 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 54a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 551:	8d 45 0c             	lea    0xc(%ebp),%eax
 554:	83 c0 04             	add    $0x4,%eax
 557:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 55a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 561:	e9 7c 01 00 00       	jmp    6e2 <printf+0x19e>
    c = fmt[i] & 0xff;
 566:	8b 55 0c             	mov    0xc(%ebp),%edx
 569:	8b 45 f0             	mov    -0x10(%ebp),%eax
 56c:	01 d0                	add    %edx,%eax
 56e:	0f b6 00             	movzbl (%eax),%eax
 571:	0f be c0             	movsbl %al,%eax
 574:	25 ff 00 00 00       	and    $0xff,%eax
 579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 57c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 580:	75 2c                	jne    5ae <printf+0x6a>
      if(c == '%'){
 582:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 586:	75 0c                	jne    594 <printf+0x50>
        state = '%';
 588:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 58f:	e9 4a 01 00 00       	jmp    6de <printf+0x19a>
      } else {
        putc(fd, c);
 594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 bb fe ff ff       	call   464 <putc>
 5a9:	e9 30 01 00 00       	jmp    6de <printf+0x19a>
      }
    } else if(state == '%'){
 5ae:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5b2:	0f 85 26 01 00 00    	jne    6de <printf+0x19a>
      if(c == 'd'){
 5b8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5bc:	75 2d                	jne    5eb <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c1:	8b 00                	mov    (%eax),%eax
 5c3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ca:	00 
 5cb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5d2:	00 
 5d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	89 04 24             	mov    %eax,(%esp)
 5dd:	e8 aa fe ff ff       	call   48c <printint>
        ap++;
 5e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e6:	e9 ec 00 00 00       	jmp    6d7 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5eb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5ef:	74 06                	je     5f7 <printf+0xb3>
 5f1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5f5:	75 2d                	jne    624 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fa:	8b 00                	mov    (%eax),%eax
 5fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 603:	00 
 604:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 60b:	00 
 60c:	89 44 24 04          	mov    %eax,0x4(%esp)
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	89 04 24             	mov    %eax,(%esp)
 616:	e8 71 fe ff ff       	call   48c <printint>
        ap++;
 61b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61f:	e9 b3 00 00 00       	jmp    6d7 <printf+0x193>
      } else if(c == 's'){
 624:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 628:	75 45                	jne    66f <printf+0x12b>
        s = (char*)*ap;
 62a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 632:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 636:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63a:	75 09                	jne    645 <printf+0x101>
          s = "(null)";
 63c:	c7 45 f4 a3 09 00 00 	movl   $0x9a3,-0xc(%ebp)
        while(*s != 0){
 643:	eb 1e                	jmp    663 <printf+0x11f>
 645:	eb 1c                	jmp    663 <printf+0x11f>
          putc(fd, *s);
 647:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64a:	0f b6 00             	movzbl (%eax),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	89 44 24 04          	mov    %eax,0x4(%esp)
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	89 04 24             	mov    %eax,(%esp)
 65a:	e8 05 fe ff ff       	call   464 <putc>
          s++;
 65f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 663:	8b 45 f4             	mov    -0xc(%ebp),%eax
 666:	0f b6 00             	movzbl (%eax),%eax
 669:	84 c0                	test   %al,%al
 66b:	75 da                	jne    647 <printf+0x103>
 66d:	eb 68                	jmp    6d7 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 673:	75 1d                	jne    692 <printf+0x14e>
        putc(fd, *ap);
 675:	8b 45 e8             	mov    -0x18(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	0f be c0             	movsbl %al,%eax
 67d:	89 44 24 04          	mov    %eax,0x4(%esp)
 681:	8b 45 08             	mov    0x8(%ebp),%eax
 684:	89 04 24             	mov    %eax,(%esp)
 687:	e8 d8 fd ff ff       	call   464 <putc>
        ap++;
 68c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 690:	eb 45                	jmp    6d7 <printf+0x193>
      } else if(c == '%'){
 692:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 696:	75 17                	jne    6af <printf+0x16b>
        putc(fd, c);
 698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69b:	0f be c0             	movsbl %al,%eax
 69e:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a2:	8b 45 08             	mov    0x8(%ebp),%eax
 6a5:	89 04 24             	mov    %eax,(%esp)
 6a8:	e8 b7 fd ff ff       	call   464 <putc>
 6ad:	eb 28                	jmp    6d7 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6af:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6b6:	00 
 6b7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ba:	89 04 24             	mov    %eax,(%esp)
 6bd:	e8 a2 fd ff ff       	call   464 <putc>
        putc(fd, c);
 6c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c5:	0f be c0             	movsbl %al,%eax
 6c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cc:	8b 45 08             	mov    0x8(%ebp),%eax
 6cf:	89 04 24             	mov    %eax,(%esp)
 6d2:	e8 8d fd ff ff       	call   464 <putc>
      }
      state = 0;
 6d7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6e2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e8:	01 d0                	add    %edx,%eax
 6ea:	0f b6 00             	movzbl (%eax),%eax
 6ed:	84 c0                	test   %al,%al
 6ef:	0f 85 71 fe ff ff    	jne    566 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6f5:	c9                   	leave  
 6f6:	c3                   	ret    

000006f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f7:	55                   	push   %ebp
 6f8:	89 e5                	mov    %esp,%ebp
 6fa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fd:	8b 45 08             	mov    0x8(%ebp),%eax
 700:	83 e8 08             	sub    $0x8,%eax
 703:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 706:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 70b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 70e:	eb 24                	jmp    734 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 710:	8b 45 fc             	mov    -0x4(%ebp),%eax
 713:	8b 00                	mov    (%eax),%eax
 715:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 718:	77 12                	ja     72c <free+0x35>
 71a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 720:	77 24                	ja     746 <free+0x4f>
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72a:	77 1a                	ja     746 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	89 45 fc             	mov    %eax,-0x4(%ebp)
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73a:	76 d4                	jbe    710 <free+0x19>
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 00                	mov    (%eax),%eax
 741:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 744:	76 ca                	jbe    710 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	8b 40 04             	mov    0x4(%eax),%eax
 74c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	01 c2                	add    %eax,%edx
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	39 c2                	cmp    %eax,%edx
 75f:	75 24                	jne    785 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 761:	8b 45 f8             	mov    -0x8(%ebp),%eax
 764:	8b 50 04             	mov    0x4(%eax),%edx
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	8b 00                	mov    (%eax),%eax
 76c:	8b 40 04             	mov    0x4(%eax),%eax
 76f:	01 c2                	add    %eax,%edx
 771:	8b 45 f8             	mov    -0x8(%ebp),%eax
 774:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	8b 10                	mov    (%eax),%edx
 77e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 781:	89 10                	mov    %edx,(%eax)
 783:	eb 0a                	jmp    78f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	8b 10                	mov    (%eax),%edx
 78a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 79c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79f:	01 d0                	add    %edx,%eax
 7a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a4:	75 20                	jne    7c6 <free+0xcf>
    p->s.size += bp->s.size;
 7a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a9:	8b 50 04             	mov    0x4(%eax),%edx
 7ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7af:	8b 40 04             	mov    0x4(%eax),%eax
 7b2:	01 c2                	add    %eax,%edx
 7b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	8b 10                	mov    (%eax),%edx
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	89 10                	mov    %edx,(%eax)
 7c4:	eb 08                	jmp    7ce <free+0xd7>
  } else
    p->s.ptr = bp;
 7c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7cc:	89 10                	mov    %edx,(%eax)
  freep = p;
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	a3 0c 0c 00 00       	mov    %eax,0xc0c
}
 7d6:	c9                   	leave  
 7d7:	c3                   	ret    

000007d8 <morecore>:

static Header*
morecore(uint nu)
{
 7d8:	55                   	push   %ebp
 7d9:	89 e5                	mov    %esp,%ebp
 7db:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7de:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7e5:	77 07                	ja     7ee <morecore+0x16>
    nu = 4096;
 7e7:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7ee:	8b 45 08             	mov    0x8(%ebp),%eax
 7f1:	c1 e0 03             	shl    $0x3,%eax
 7f4:	89 04 24             	mov    %eax,(%esp)
 7f7:	e8 40 fc ff ff       	call   43c <sbrk>
 7fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ff:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 803:	75 07                	jne    80c <morecore+0x34>
    return 0;
 805:	b8 00 00 00 00       	mov    $0x0,%eax
 80a:	eb 22                	jmp    82e <morecore+0x56>
  hp = (Header*)p;
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 812:	8b 45 f0             	mov    -0x10(%ebp),%eax
 815:	8b 55 08             	mov    0x8(%ebp),%edx
 818:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 81b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81e:	83 c0 08             	add    $0x8,%eax
 821:	89 04 24             	mov    %eax,(%esp)
 824:	e8 ce fe ff ff       	call   6f7 <free>
  return freep;
 829:	a1 0c 0c 00 00       	mov    0xc0c,%eax
}
 82e:	c9                   	leave  
 82f:	c3                   	ret    

00000830 <malloc>:

void*
malloc(uint nbytes)
{
 830:	55                   	push   %ebp
 831:	89 e5                	mov    %esp,%ebp
 833:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 836:	8b 45 08             	mov    0x8(%ebp),%eax
 839:	83 c0 07             	add    $0x7,%eax
 83c:	c1 e8 03             	shr    $0x3,%eax
 83f:	83 c0 01             	add    $0x1,%eax
 842:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 845:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 84a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 84d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 851:	75 23                	jne    876 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 853:	c7 45 f0 04 0c 00 00 	movl   $0xc04,-0x10(%ebp)
 85a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85d:	a3 0c 0c 00 00       	mov    %eax,0xc0c
 862:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 867:	a3 04 0c 00 00       	mov    %eax,0xc04
    base.s.size = 0;
 86c:	c7 05 08 0c 00 00 00 	movl   $0x0,0xc08
 873:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
 879:	8b 00                	mov    (%eax),%eax
 87b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	8b 40 04             	mov    0x4(%eax),%eax
 884:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 887:	72 4d                	jb     8d6 <malloc+0xa6>
      if(p->s.size == nunits)
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	8b 40 04             	mov    0x4(%eax),%eax
 88f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 892:	75 0c                	jne    8a0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 10                	mov    (%eax),%edx
 899:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89c:	89 10                	mov    %edx,(%eax)
 89e:	eb 26                	jmp    8c6 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8a9:	89 c2                	mov    %eax,%edx
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	8b 40 04             	mov    0x4(%eax),%eax
 8b7:	c1 e0 03             	shl    $0x3,%eax
 8ba:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8c3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c9:	a3 0c 0c 00 00       	mov    %eax,0xc0c
      return (void*)(p + 1);
 8ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d1:	83 c0 08             	add    $0x8,%eax
 8d4:	eb 38                	jmp    90e <malloc+0xde>
    }
    if(p == freep)
 8d6:	a1 0c 0c 00 00       	mov    0xc0c,%eax
 8db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8de:	75 1b                	jne    8fb <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8e3:	89 04 24             	mov    %eax,(%esp)
 8e6:	e8 ed fe ff ff       	call   7d8 <morecore>
 8eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8f2:	75 07                	jne    8fb <malloc+0xcb>
        return 0;
 8f4:	b8 00 00 00 00       	mov    $0x0,%eax
 8f9:	eb 13                	jmp    90e <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8b 00                	mov    (%eax),%eax
 906:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 909:	e9 70 ff ff ff       	jmp    87e <malloc+0x4e>
}
 90e:	c9                   	leave  
 90f:	c3                   	ret    
