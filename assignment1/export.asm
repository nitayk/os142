
_export:     file format elf32-i386


Disassembly of section .text:

00000000 <export>:
#include "user.h"
#include "our_header.h"


void export(char* buf)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	53                   	push   %ebx
   5:	81 ec a0 00 00 00    	sub    $0xa0,%esp
  int next_c,i = 0;
   b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  char tempPath[MAX_ENTRY_LEN] = "";
  12:	c7 85 70 ff ff ff 00 	movl   $0x0,-0x90(%ebp)
  19:	00 00 00 
  1c:	8d 9d 74 ff ff ff    	lea    -0x8c(%ebp),%ebx
  22:	b8 00 00 00 00       	mov    $0x0,%eax
  27:	ba 1f 00 00 00       	mov    $0x1f,%edx
  2c:	89 df                	mov    %ebx,%edi
  2e:	89 d1                	mov    %edx,%ecx
  30:	f3 ab                	rep stos %eax,%es:(%edi)

  while(*buf != 0 && *buf != '\n' && *buf != '\t' && *buf != '\r' && *buf != ' ') {
  32:	eb 78                	jmp    ac <export+0xac>
    if(*buf != ':') {
  34:	8b 45 08             	mov    0x8(%ebp),%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 3a                	cmp    $0x3a,%al
  3c:	74 17                	je     55 <export+0x55>
    	tempPath[next_c] = *buf;
  3e:	8b 45 08             	mov    0x8(%ebp),%eax
  41:	0f b6 10             	movzbl (%eax),%edx
  44:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  4a:	03 45 f4             	add    -0xc(%ebp),%eax
  4d:	88 10                	mov    %dl,(%eax)
    	next_c++;
  4f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  53:	eb 53                	jmp    a8 <export+0xa8>
    }
    else	// : delimiter , new path
    {

      tempPath[next_c] = 0; // NULL terminated
  55:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  5b:	03 45 f4             	add    -0xc(%ebp),%eax
  5e:	c6 00 00             	movb   $0x0,(%eax)
      add_path(tempPath);
  61:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  67:	89 04 24             	mov    %eax,(%esp)
  6a:	e8 ad 03 00 00       	call   41c <add_path>
      for (i = 0 ; i < strlen(tempPath) ; i++) {
  6f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  76:	eb 14                	jmp    8c <export+0x8c>
    	  tempPath[i] = *"";
  78:	ba 00 00 00 00       	mov    $0x0,%edx
  7d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  83:	03 45 f0             	add    -0x10(%ebp),%eax
  86:	88 10                	mov    %dl,(%eax)
    else	// : delimiter , new path
    {

      tempPath[next_c] = 0; // NULL terminated
      add_path(tempPath);
      for (i = 0 ; i < strlen(tempPath) ; i++) {
  88:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  95:	89 04 24             	mov    %eax,(%esp)
  98:	e8 15 01 00 00       	call   1b2 <strlen>
  9d:	39 c3                	cmp    %eax,%ebx
  9f:	72 d7                	jb     78 <export+0x78>
    	  tempPath[i] = *"";
      }
      next_c = 0;
  a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    }
    buf++;
  a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
void export(char* buf)
{
  int next_c,i = 0;
  char tempPath[MAX_ENTRY_LEN] = "";

  while(*buf != 0 && *buf != '\n' && *buf != '\t' && *buf != '\r' && *buf != ' ') {
  ac:	8b 45 08             	mov    0x8(%ebp),%eax
  af:	0f b6 00             	movzbl (%eax),%eax
  b2:	84 c0                	test   %al,%al
  b4:	74 2c                	je     e2 <export+0xe2>
  b6:	8b 45 08             	mov    0x8(%ebp),%eax
  b9:	0f b6 00             	movzbl (%eax),%eax
  bc:	3c 0a                	cmp    $0xa,%al
  be:	74 22                	je     e2 <export+0xe2>
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	0f b6 00             	movzbl (%eax),%eax
  c6:	3c 09                	cmp    $0x9,%al
  c8:	74 18                	je     e2 <export+0xe2>
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	0f b6 00             	movzbl (%eax),%eax
  d0:	3c 0d                	cmp    $0xd,%al
  d2:	74 0e                	je     e2 <export+0xe2>
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	3c 20                	cmp    $0x20,%al
  dc:	0f 85 52 ff ff ff    	jne    34 <export+0x34>
      }
      next_c = 0;
    }
    buf++;
  }
}
  e2:	81 c4 a0 00 00 00    	add    $0xa0,%esp
  e8:	5b                   	pop    %ebx
  e9:	5f                   	pop    %edi
  ea:	5d                   	pop    %ebp
  eb:	c3                   	ret    

000000ec <main>:

int
main(int argc, char *argv[])
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  ef:	83 e4 f0             	and    $0xfffffff0,%esp
  f2:	83 ec 10             	sub    $0x10,%esp
  if(argc < 2){
  f5:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  f9:	7f 05                	jg     100 <main+0x14>
    exit();
  fb:	e8 7c 02 00 00       	call   37c <exit>
  }
  export(argv[1]);
 100:	8b 45 0c             	mov    0xc(%ebp),%eax
 103:	83 c0 04             	add    $0x4,%eax
 106:	8b 00                	mov    (%eax),%eax
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 f0 fe ff ff       	call   0 <export>
  exit();
 110:	e8 67 02 00 00       	call   37c <exit>
 115:	90                   	nop
 116:	90                   	nop
 117:	90                   	nop

00000118 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	57                   	push   %edi
 11c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 11d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 120:	8b 55 10             	mov    0x10(%ebp),%edx
 123:	8b 45 0c             	mov    0xc(%ebp),%eax
 126:	89 cb                	mov    %ecx,%ebx
 128:	89 df                	mov    %ebx,%edi
 12a:	89 d1                	mov    %edx,%ecx
 12c:	fc                   	cld    
 12d:	f3 aa                	rep stos %al,%es:(%edi)
 12f:	89 ca                	mov    %ecx,%edx
 131:	89 fb                	mov    %edi,%ebx
 133:	89 5d 08             	mov    %ebx,0x8(%ebp)
 136:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 139:	5b                   	pop    %ebx
 13a:	5f                   	pop    %edi
 13b:	5d                   	pop    %ebp
 13c:	c3                   	ret    

0000013d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 149:	90                   	nop
 14a:	8b 45 0c             	mov    0xc(%ebp),%eax
 14d:	0f b6 10             	movzbl (%eax),%edx
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	88 10                	mov    %dl,(%eax)
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	0f 95 c0             	setne  %al
 160:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 164:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 168:	84 c0                	test   %al,%al
 16a:	75 de                	jne    14a <strcpy+0xd>
    ;
  return os;
 16c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 16f:	c9                   	leave  
 170:	c3                   	ret    

00000171 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 174:	eb 08                	jmp    17e <strcmp+0xd>
    p++, q++;
 176:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	0f b6 00             	movzbl (%eax),%eax
 184:	84 c0                	test   %al,%al
 186:	74 10                	je     198 <strcmp+0x27>
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 10             	movzbl (%eax),%edx
 18e:	8b 45 0c             	mov    0xc(%ebp),%eax
 191:	0f b6 00             	movzbl (%eax),%eax
 194:	38 c2                	cmp    %al,%dl
 196:	74 de                	je     176 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	0f b6 d0             	movzbl %al,%edx
 1a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	0f b6 c0             	movzbl %al,%eax
 1aa:	89 d1                	mov    %edx,%ecx
 1ac:	29 c1                	sub    %eax,%ecx
 1ae:	89 c8                	mov    %ecx,%eax
}
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <strlen>:

uint
strlen(char *s)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1bf:	eb 04                	jmp    1c5 <strlen+0x13>
 1c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c8:	03 45 08             	add    0x8(%ebp),%eax
 1cb:	0f b6 00             	movzbl (%eax),%eax
 1ce:	84 c0                	test   %al,%al
 1d0:	75 ef                	jne    1c1 <strlen+0xf>
    ;
  return n;
 1d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d5:	c9                   	leave  
 1d6:	c3                   	ret    

000001d7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1dd:	8b 45 10             	mov    0x10(%ebp),%eax
 1e0:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	89 04 24             	mov    %eax,(%esp)
 1f1:	e8 22 ff ff ff       	call   118 <stosb>
  return dst;
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f9:	c9                   	leave  
 1fa:	c3                   	ret    

000001fb <strchr>:

char*
strchr(const char *s, char c)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 04             	sub    $0x4,%esp
 201:	8b 45 0c             	mov    0xc(%ebp),%eax
 204:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 207:	eb 14                	jmp    21d <strchr+0x22>
    if(*s == c)
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	0f b6 00             	movzbl (%eax),%eax
 20f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 212:	75 05                	jne    219 <strchr+0x1e>
      return (char*)s;
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	eb 13                	jmp    22c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 219:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	0f b6 00             	movzbl (%eax),%eax
 223:	84 c0                	test   %al,%al
 225:	75 e2                	jne    209 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 227:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22c:	c9                   	leave  
 22d:	c3                   	ret    

0000022e <gets>:

char*
gets(char *buf, int max)
{
 22e:	55                   	push   %ebp
 22f:	89 e5                	mov    %esp,%ebp
 231:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 234:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23b:	eb 44                	jmp    281 <gets+0x53>
    cc = read(0, &c, 1);
 23d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 244:	00 
 245:	8d 45 ef             	lea    -0x11(%ebp),%eax
 248:	89 44 24 04          	mov    %eax,0x4(%esp)
 24c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 253:	e8 3c 01 00 00       	call   394 <read>
 258:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25f:	7e 2d                	jle    28e <gets+0x60>
      break;
    buf[i++] = c;
 261:	8b 45 f4             	mov    -0xc(%ebp),%eax
 264:	03 45 08             	add    0x8(%ebp),%eax
 267:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 26b:	88 10                	mov    %dl,(%eax)
 26d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0a                	cmp    $0xa,%al
 277:	74 16                	je     28f <gets+0x61>
 279:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27d:	3c 0d                	cmp    $0xd,%al
 27f:	74 0e                	je     28f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 281:	8b 45 f4             	mov    -0xc(%ebp),%eax
 284:	83 c0 01             	add    $0x1,%eax
 287:	3b 45 0c             	cmp    0xc(%ebp),%eax
 28a:	7c b1                	jl     23d <gets+0xf>
 28c:	eb 01                	jmp    28f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 292:	03 45 08             	add    0x8(%ebp),%eax
 295:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 298:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    

0000029d <stat>:

int
stat(char *n, struct stat *st)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2aa:	00 
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	89 04 24             	mov    %eax,(%esp)
 2b1:	e8 06 01 00 00       	call   3bc <open>
 2b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2bd:	79 07                	jns    2c6 <stat+0x29>
    return -1;
 2bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c4:	eb 23                	jmp    2e9 <stat+0x4c>
  r = fstat(fd, st);
 2c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	89 04 24             	mov    %eax,(%esp)
 2d3:	e8 fc 00 00 00       	call   3d4 <fstat>
 2d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2de:	89 04 24             	mov    %eax,(%esp)
 2e1:	e8 be 00 00 00       	call   3a4 <close>
  return r;
 2e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e9:	c9                   	leave  
 2ea:	c3                   	ret    

000002eb <atoi>:

int
atoi(const char *s)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f8:	eb 23                	jmp    31d <atoi+0x32>
    n = n*10 + *s++ - '0';
 2fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fd:	89 d0                	mov    %edx,%eax
 2ff:	c1 e0 02             	shl    $0x2,%eax
 302:	01 d0                	add    %edx,%eax
 304:	01 c0                	add    %eax,%eax
 306:	89 c2                	mov    %eax,%edx
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	01 d0                	add    %edx,%eax
 313:	83 e8 30             	sub    $0x30,%eax
 316:	89 45 fc             	mov    %eax,-0x4(%ebp)
 319:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31d:	8b 45 08             	mov    0x8(%ebp),%eax
 320:	0f b6 00             	movzbl (%eax),%eax
 323:	3c 2f                	cmp    $0x2f,%al
 325:	7e 0a                	jle    331 <atoi+0x46>
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	3c 39                	cmp    $0x39,%al
 32f:	7e c9                	jle    2fa <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 331:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 334:	c9                   	leave  
 335:	c3                   	ret    

00000336 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 336:	55                   	push   %ebp
 337:	89 e5                	mov    %esp,%ebp
 339:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 348:	eb 13                	jmp    35d <memmove+0x27>
    *dst++ = *src++;
 34a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 34d:	0f b6 10             	movzbl (%eax),%edx
 350:	8b 45 fc             	mov    -0x4(%ebp),%eax
 353:	88 10                	mov    %dl,(%eax)
 355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 359:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 361:	0f 9f c0             	setg   %al
 364:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 368:	84 c0                	test   %al,%al
 36a:	75 de                	jne    34a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36f:	c9                   	leave  
 370:	c3                   	ret    
 371:	90                   	nop
 372:	90                   	nop
 373:	90                   	nop

00000374 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 374:	b8 01 00 00 00       	mov    $0x1,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <exit>:
SYSCALL(exit)
 37c:	b8 02 00 00 00       	mov    $0x2,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <wait>:
SYSCALL(wait)
 384:	b8 03 00 00 00       	mov    $0x3,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <pipe>:
SYSCALL(pipe)
 38c:	b8 04 00 00 00       	mov    $0x4,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <read>:
SYSCALL(read)
 394:	b8 05 00 00 00       	mov    $0x5,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <write>:
SYSCALL(write)
 39c:	b8 10 00 00 00       	mov    $0x10,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <close>:
SYSCALL(close)
 3a4:	b8 15 00 00 00       	mov    $0x15,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <kill>:
SYSCALL(kill)
 3ac:	b8 06 00 00 00       	mov    $0x6,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <exec>:
SYSCALL(exec)
 3b4:	b8 07 00 00 00       	mov    $0x7,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <open>:
SYSCALL(open)
 3bc:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <mknod>:
SYSCALL(mknod)
 3c4:	b8 11 00 00 00       	mov    $0x11,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <unlink>:
SYSCALL(unlink)
 3cc:	b8 12 00 00 00       	mov    $0x12,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <fstat>:
SYSCALL(fstat)
 3d4:	b8 08 00 00 00       	mov    $0x8,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <link>:
SYSCALL(link)
 3dc:	b8 13 00 00 00       	mov    $0x13,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <mkdir>:
SYSCALL(mkdir)
 3e4:	b8 14 00 00 00       	mov    $0x14,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <chdir>:
SYSCALL(chdir)
 3ec:	b8 09 00 00 00       	mov    $0x9,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <dup>:
SYSCALL(dup)
 3f4:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <getpid>:
SYSCALL(getpid)
 3fc:	b8 0b 00 00 00       	mov    $0xb,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <sbrk>:
SYSCALL(sbrk)
 404:	b8 0c 00 00 00       	mov    $0xc,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <sleep>:
SYSCALL(sleep)
 40c:	b8 0d 00 00 00       	mov    $0xd,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <uptime>:
SYSCALL(uptime)
 414:	b8 0e 00 00 00       	mov    $0xe,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <add_path>:
SYSCALL(add_path)
 41c:	b8 16 00 00 00       	mov    $0x16,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	83 ec 28             	sub    $0x28,%esp
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 430:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 437:	00 
 438:	8d 45 f4             	lea    -0xc(%ebp),%eax
 43b:	89 44 24 04          	mov    %eax,0x4(%esp)
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	89 04 24             	mov    %eax,(%esp)
 445:	e8 52 ff ff ff       	call   39c <write>
}
 44a:	c9                   	leave  
 44b:	c3                   	ret    

0000044c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
 44f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 452:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 459:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 45d:	74 17                	je     476 <printint+0x2a>
 45f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 463:	79 11                	jns    476 <printint+0x2a>
    neg = 1;
 465:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 46c:	8b 45 0c             	mov    0xc(%ebp),%eax
 46f:	f7 d8                	neg    %eax
 471:	89 45 ec             	mov    %eax,-0x14(%ebp)
 474:	eb 06                	jmp    47c <printint+0x30>
  } else {
    x = xx;
 476:	8b 45 0c             	mov    0xc(%ebp),%eax
 479:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 47c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 483:	8b 4d 10             	mov    0x10(%ebp),%ecx
 486:	8b 45 ec             	mov    -0x14(%ebp),%eax
 489:	ba 00 00 00 00       	mov    $0x0,%edx
 48e:	f7 f1                	div    %ecx
 490:	89 d0                	mov    %edx,%eax
 492:	0f b6 90 2c 0b 00 00 	movzbl 0xb2c(%eax),%edx
 499:	8d 45 dc             	lea    -0x24(%ebp),%eax
 49c:	03 45 f4             	add    -0xc(%ebp),%eax
 49f:	88 10                	mov    %dl,(%eax)
 4a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4a5:	8b 55 10             	mov    0x10(%ebp),%edx
 4a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ae:	ba 00 00 00 00       	mov    $0x0,%edx
 4b3:	f7 75 d4             	divl   -0x2c(%ebp)
 4b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bd:	75 c4                	jne    483 <printint+0x37>
  if(neg)
 4bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c3:	74 2a                	je     4ef <printint+0xa3>
    buf[i++] = '-';
 4c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4c8:	03 45 f4             	add    -0xc(%ebp),%eax
 4cb:	c6 00 2d             	movb   $0x2d,(%eax)
 4ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4d2:	eb 1b                	jmp    4ef <printint+0xa3>
    putc(fd, buf[i]);
 4d4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4d7:	03 45 f4             	add    -0xc(%ebp),%eax
 4da:	0f b6 00             	movzbl (%eax),%eax
 4dd:	0f be c0             	movsbl %al,%eax
 4e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e4:	8b 45 08             	mov    0x8(%ebp),%eax
 4e7:	89 04 24             	mov    %eax,(%esp)
 4ea:	e8 35 ff ff ff       	call   424 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4ef:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f7:	79 db                	jns    4d4 <printint+0x88>
    putc(fd, buf[i]);
}
 4f9:	c9                   	leave  
 4fa:	c3                   	ret    

000004fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4fb:	55                   	push   %ebp
 4fc:	89 e5                	mov    %esp,%ebp
 4fe:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 501:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 508:	8d 45 0c             	lea    0xc(%ebp),%eax
 50b:	83 c0 04             	add    $0x4,%eax
 50e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 511:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 518:	e9 7d 01 00 00       	jmp    69a <printf+0x19f>
    c = fmt[i] & 0xff;
 51d:	8b 55 0c             	mov    0xc(%ebp),%edx
 520:	8b 45 f0             	mov    -0x10(%ebp),%eax
 523:	01 d0                	add    %edx,%eax
 525:	0f b6 00             	movzbl (%eax),%eax
 528:	0f be c0             	movsbl %al,%eax
 52b:	25 ff 00 00 00       	and    $0xff,%eax
 530:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 533:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 537:	75 2c                	jne    565 <printf+0x6a>
      if(c == '%'){
 539:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 53d:	75 0c                	jne    54b <printf+0x50>
        state = '%';
 53f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 546:	e9 4b 01 00 00       	jmp    696 <printf+0x19b>
      } else {
        putc(fd, c);
 54b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54e:	0f be c0             	movsbl %al,%eax
 551:	89 44 24 04          	mov    %eax,0x4(%esp)
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	89 04 24             	mov    %eax,(%esp)
 55b:	e8 c4 fe ff ff       	call   424 <putc>
 560:	e9 31 01 00 00       	jmp    696 <printf+0x19b>
      }
    } else if(state == '%'){
 565:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 569:	0f 85 27 01 00 00    	jne    696 <printf+0x19b>
      if(c == 'd'){
 56f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 573:	75 2d                	jne    5a2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 575:	8b 45 e8             	mov    -0x18(%ebp),%eax
 578:	8b 00                	mov    (%eax),%eax
 57a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 581:	00 
 582:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 589:	00 
 58a:	89 44 24 04          	mov    %eax,0x4(%esp)
 58e:	8b 45 08             	mov    0x8(%ebp),%eax
 591:	89 04 24             	mov    %eax,(%esp)
 594:	e8 b3 fe ff ff       	call   44c <printint>
        ap++;
 599:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59d:	e9 ed 00 00 00       	jmp    68f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5a2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5a6:	74 06                	je     5ae <printf+0xb3>
 5a8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5ac:	75 2d                	jne    5db <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b1:	8b 00                	mov    (%eax),%eax
 5b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5ba:	00 
 5bb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5c2:	00 
 5c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ca:	89 04 24             	mov    %eax,(%esp)
 5cd:	e8 7a fe ff ff       	call   44c <printint>
        ap++;
 5d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d6:	e9 b4 00 00 00       	jmp    68f <printf+0x194>
      } else if(c == 's'){
 5db:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5df:	75 46                	jne    627 <printf+0x12c>
        s = (char*)*ap;
 5e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e4:	8b 00                	mov    (%eax),%eax
 5e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f1:	75 27                	jne    61a <printf+0x11f>
          s = "(null)";
 5f3:	c7 45 f4 bf 08 00 00 	movl   $0x8bf,-0xc(%ebp)
        while(*s != 0){
 5fa:	eb 1e                	jmp    61a <printf+0x11f>
          putc(fd, *s);
 5fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ff:	0f b6 00             	movzbl (%eax),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	89 44 24 04          	mov    %eax,0x4(%esp)
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	89 04 24             	mov    %eax,(%esp)
 60f:	e8 10 fe ff ff       	call   424 <putc>
          s++;
 614:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 618:	eb 01                	jmp    61b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 61a:	90                   	nop
 61b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61e:	0f b6 00             	movzbl (%eax),%eax
 621:	84 c0                	test   %al,%al
 623:	75 d7                	jne    5fc <printf+0x101>
 625:	eb 68                	jmp    68f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 627:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 62b:	75 1d                	jne    64a <printf+0x14f>
        putc(fd, *ap);
 62d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	0f be c0             	movsbl %al,%eax
 635:	89 44 24 04          	mov    %eax,0x4(%esp)
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	89 04 24             	mov    %eax,(%esp)
 63f:	e8 e0 fd ff ff       	call   424 <putc>
        ap++;
 644:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 648:	eb 45                	jmp    68f <printf+0x194>
      } else if(c == '%'){
 64a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 64e:	75 17                	jne    667 <printf+0x16c>
        putc(fd, c);
 650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 653:	0f be c0             	movsbl %al,%eax
 656:	89 44 24 04          	mov    %eax,0x4(%esp)
 65a:	8b 45 08             	mov    0x8(%ebp),%eax
 65d:	89 04 24             	mov    %eax,(%esp)
 660:	e8 bf fd ff ff       	call   424 <putc>
 665:	eb 28                	jmp    68f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 667:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 66e:	00 
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
 672:	89 04 24             	mov    %eax,(%esp)
 675:	e8 aa fd ff ff       	call   424 <putc>
        putc(fd, c);
 67a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67d:	0f be c0             	movsbl %al,%eax
 680:	89 44 24 04          	mov    %eax,0x4(%esp)
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	89 04 24             	mov    %eax,(%esp)
 68a:	e8 95 fd ff ff       	call   424 <putc>
      }
      state = 0;
 68f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 696:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 69a:	8b 55 0c             	mov    0xc(%ebp),%edx
 69d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a0:	01 d0                	add    %edx,%eax
 6a2:	0f b6 00             	movzbl (%eax),%eax
 6a5:	84 c0                	test   %al,%al
 6a7:	0f 85 70 fe ff ff    	jne    51d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6ad:	c9                   	leave  
 6ae:	c3                   	ret    
 6af:	90                   	nop

000006b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	83 e8 08             	sub    $0x8,%eax
 6bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bf:	a1 48 0b 00 00       	mov    0xb48,%eax
 6c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c7:	eb 24                	jmp    6ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d1:	77 12                	ja     6e5 <free+0x35>
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d9:	77 24                	ja     6ff <free+0x4f>
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e3:	77 1a                	ja     6ff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f3:	76 d4                	jbe    6c9 <free+0x19>
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6fd:	76 ca                	jbe    6c9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	8b 40 04             	mov    0x4(%eax),%eax
 705:	c1 e0 03             	shl    $0x3,%eax
 708:	89 c2                	mov    %eax,%edx
 70a:	03 55 f8             	add    -0x8(%ebp),%edx
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	39 c2                	cmp    %eax,%edx
 714:	75 24                	jne    73a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 716:	8b 45 f8             	mov    -0x8(%ebp),%eax
 719:	8b 50 04             	mov    0x4(%eax),%edx
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 00                	mov    (%eax),%eax
 721:	8b 40 04             	mov    0x4(%eax),%eax
 724:	01 c2                	add    %eax,%edx
 726:	8b 45 f8             	mov    -0x8(%ebp),%eax
 729:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	8b 10                	mov    (%eax),%edx
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	89 10                	mov    %edx,(%eax)
 738:	eb 0a                	jmp    744 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 73a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 744:	8b 45 fc             	mov    -0x4(%ebp),%eax
 747:	8b 40 04             	mov    0x4(%eax),%eax
 74a:	c1 e0 03             	shl    $0x3,%eax
 74d:	03 45 fc             	add    -0x4(%ebp),%eax
 750:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 753:	75 20                	jne    775 <free+0xc5>
    p->s.size += bp->s.size;
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 50 04             	mov    0x4(%eax),%edx
 75b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75e:	8b 40 04             	mov    0x4(%eax),%eax
 761:	01 c2                	add    %eax,%edx
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	8b 10                	mov    (%eax),%edx
 76e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 771:	89 10                	mov    %edx,(%eax)
 773:	eb 08                	jmp    77d <free+0xcd>
  } else
    p->s.ptr = bp;
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77b:	89 10                	mov    %edx,(%eax)
  freep = p;
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	a3 48 0b 00 00       	mov    %eax,0xb48
}
 785:	c9                   	leave  
 786:	c3                   	ret    

00000787 <morecore>:

static Header*
morecore(uint nu)
{
 787:	55                   	push   %ebp
 788:	89 e5                	mov    %esp,%ebp
 78a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 78d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 794:	77 07                	ja     79d <morecore+0x16>
    nu = 4096;
 796:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
 7a0:	c1 e0 03             	shl    $0x3,%eax
 7a3:	89 04 24             	mov    %eax,(%esp)
 7a6:	e8 59 fc ff ff       	call   404 <sbrk>
 7ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ae:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b2:	75 07                	jne    7bb <morecore+0x34>
    return 0;
 7b4:	b8 00 00 00 00       	mov    $0x0,%eax
 7b9:	eb 22                	jmp    7dd <morecore+0x56>
  hp = (Header*)p;
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	8b 55 08             	mov    0x8(%ebp),%edx
 7c7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	83 c0 08             	add    $0x8,%eax
 7d0:	89 04 24             	mov    %eax,(%esp)
 7d3:	e8 d8 fe ff ff       	call   6b0 <free>
  return freep;
 7d8:	a1 48 0b 00 00       	mov    0xb48,%eax
}
 7dd:	c9                   	leave  
 7de:	c3                   	ret    

000007df <malloc>:

void*
malloc(uint nbytes)
{
 7df:	55                   	push   %ebp
 7e0:	89 e5                	mov    %esp,%ebp
 7e2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e5:	8b 45 08             	mov    0x8(%ebp),%eax
 7e8:	83 c0 07             	add    $0x7,%eax
 7eb:	c1 e8 03             	shr    $0x3,%eax
 7ee:	83 c0 01             	add    $0x1,%eax
 7f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f4:	a1 48 0b 00 00       	mov    0xb48,%eax
 7f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 800:	75 23                	jne    825 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 802:	c7 45 f0 40 0b 00 00 	movl   $0xb40,-0x10(%ebp)
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	a3 48 0b 00 00       	mov    %eax,0xb48
 811:	a1 48 0b 00 00       	mov    0xb48,%eax
 816:	a3 40 0b 00 00       	mov    %eax,0xb40
    base.s.size = 0;
 81b:	c7 05 44 0b 00 00 00 	movl   $0x0,0xb44
 822:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	8b 40 04             	mov    0x4(%eax),%eax
 833:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 836:	72 4d                	jb     885 <malloc+0xa6>
      if(p->s.size == nunits)
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 40 04             	mov    0x4(%eax),%eax
 83e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 841:	75 0c                	jne    84f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 843:	8b 45 f4             	mov    -0xc(%ebp),%eax
 846:	8b 10                	mov    (%eax),%edx
 848:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84b:	89 10                	mov    %edx,(%eax)
 84d:	eb 26                	jmp    875 <malloc+0x96>
      else {
        p->s.size -= nunits;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	89 c2                	mov    %eax,%edx
 857:	2b 55 ec             	sub    -0x14(%ebp),%edx
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	c1 e0 03             	shl    $0x3,%eax
 869:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 872:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 875:	8b 45 f0             	mov    -0x10(%ebp),%eax
 878:	a3 48 0b 00 00       	mov    %eax,0xb48
      return (void*)(p + 1);
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	83 c0 08             	add    $0x8,%eax
 883:	eb 38                	jmp    8bd <malloc+0xde>
    }
    if(p == freep)
 885:	a1 48 0b 00 00       	mov    0xb48,%eax
 88a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 88d:	75 1b                	jne    8aa <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 88f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 892:	89 04 24             	mov    %eax,(%esp)
 895:	e8 ed fe ff ff       	call   787 <morecore>
 89a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 89d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a1:	75 07                	jne    8aa <malloc+0xcb>
        return 0;
 8a3:	b8 00 00 00 00       	mov    $0x0,%eax
 8a8:	eb 13                	jmp    8bd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b3:	8b 00                	mov    (%eax),%eax
 8b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8b8:	e9 70 ff ff ff       	jmp    82d <malloc+0x4e>
}
 8bd:	c9                   	leave  
 8be:	c3                   	ret    
