
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc < 3){  // task1.b
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 b5 08 00 	movl   $0x8b5,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 c6 04 00 00       	call   4e9 <printf>
    exit();
  23:	e8 31 03 00 00       	call   359 <exit>
  }
  if(argc == 4 && strcmp(argv[1], "-s") == 0){
  28:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
  2c:	75 6c                	jne    9a <main+0x9a>
  2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  31:	83 c0 04             	add    $0x4,%eax
  34:	8b 00                	mov    (%eax),%eax
  36:	c7 44 24 04 c8 08 00 	movl   $0x8c8,0x4(%esp)
  3d:	00 
  3e:	89 04 24             	mov    %eax,(%esp)
  41:	e8 00 01 00 00       	call   146 <strcmp>
  46:	85 c0                	test   %eax,%eax
  48:	75 50                	jne    9a <main+0x9a>
  	if(symlink(argv[2], argv[3]) < 0)
  4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  4d:	83 c0 0c             	add    $0xc,%eax
  50:	8b 10                	mov    (%eax),%edx
  52:	8b 45 0c             	mov    0xc(%ebp),%eax
  55:	83 c0 08             	add    $0x8,%eax
  58:	8b 00                	mov    (%eax),%eax
  5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  5e:	89 04 24             	mov    %eax,(%esp)
  61:	e8 93 03 00 00       	call   3f9 <symlink>
  66:	85 c0                	test   %eax,%eax
  68:	79 2e                	jns    98 <main+0x98>
   		printf(1, "link -s %s %s: failed\n", argv[2], argv[3]);
  6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  6d:	83 c0 0c             	add    $0xc,%eax
  70:	8b 10                	mov    (%eax),%edx
  72:	8b 45 0c             	mov    0xc(%ebp),%eax
  75:	83 c0 08             	add    $0x8,%eax
  78:	8b 00                	mov    (%eax),%eax
  7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  82:	c7 44 24 04 cb 08 00 	movl   $0x8cb,0x4(%esp)
  89:	00 
  8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  91:	e8 53 04 00 00       	call   4e9 <printf>
  if(argc < 3){  // task1.b
    printf(2, "Usage: ln old new\n");
    exit();
  }
  if(argc == 4 && strcmp(argv[1], "-s") == 0){
  	if(symlink(argv[2], argv[3]) < 0)
  96:	eb 54                	jmp    ec <main+0xec>
  98:	eb 52                	jmp    ec <main+0xec>
   		printf(1, "link -s %s %s: failed\n", argv[2], argv[3]);
  } else if(argc == 3) {
  9a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  9e:	75 4c                	jne    ec <main+0xec>
  	if(link(argv[1], argv[2]) < 0)
  a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  a3:	83 c0 08             	add    $0x8,%eax
  a6:	8b 10                	mov    (%eax),%edx
  a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  ab:	83 c0 04             	add    $0x4,%eax
  ae:	8b 00                	mov    (%eax),%eax
  b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  b4:	89 04 24             	mov    %eax,(%esp)
  b7:	e8 fd 02 00 00       	call   3b9 <link>
  bc:	85 c0                	test   %eax,%eax
  be:	79 2c                	jns    ec <main+0xec>
    	printf(1, "link %s %s: failed\n", argv[1], argv[2]);
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	83 c0 08             	add    $0x8,%eax
  c6:	8b 10                	mov    (%eax),%edx
  c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  cb:	83 c0 04             	add    $0x4,%eax
  ce:	8b 00                	mov    (%eax),%eax
  d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  d8:	c7 44 24 04 e2 08 00 	movl   $0x8e2,0x4(%esp)
  df:	00 
  e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e7:	e8 fd 03 00 00       	call   4e9 <printf>
  }
  exit();
  ec:	e8 68 02 00 00       	call   359 <exit>

000000f1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  f4:	57                   	push   %edi
  f5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f9:	8b 55 10             	mov    0x10(%ebp),%edx
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	89 cb                	mov    %ecx,%ebx
 101:	89 df                	mov    %ebx,%edi
 103:	89 d1                	mov    %edx,%ecx
 105:	fc                   	cld    
 106:	f3 aa                	rep stos %al,%es:(%edi)
 108:	89 ca                	mov    %ecx,%edx
 10a:	89 fb                	mov    %edi,%ebx
 10c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 112:	5b                   	pop    %ebx
 113:	5f                   	pop    %edi
 114:	5d                   	pop    %ebp
 115:	c3                   	ret    

00000116 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 122:	90                   	nop
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	8d 50 01             	lea    0x1(%eax),%edx
 129:	89 55 08             	mov    %edx,0x8(%ebp)
 12c:	8b 55 0c             	mov    0xc(%ebp),%edx
 12f:	8d 4a 01             	lea    0x1(%edx),%ecx
 132:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 135:	0f b6 12             	movzbl (%edx),%edx
 138:	88 10                	mov    %dl,(%eax)
 13a:	0f b6 00             	movzbl (%eax),%eax
 13d:	84 c0                	test   %al,%al
 13f:	75 e2                	jne    123 <strcpy+0xd>
    ;
  return os;
 141:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 144:	c9                   	leave  
 145:	c3                   	ret    

00000146 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 149:	eb 08                	jmp    153 <strcmp+0xd>
    p++, q++;
 14b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 153:	8b 45 08             	mov    0x8(%ebp),%eax
 156:	0f b6 00             	movzbl (%eax),%eax
 159:	84 c0                	test   %al,%al
 15b:	74 10                	je     16d <strcmp+0x27>
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 10             	movzbl (%eax),%edx
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	38 c2                	cmp    %al,%dl
 16b:	74 de                	je     14b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	0f b6 d0             	movzbl %al,%edx
 176:	8b 45 0c             	mov    0xc(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	0f b6 c0             	movzbl %al,%eax
 17f:	29 c2                	sub    %eax,%edx
 181:	89 d0                	mov    %edx,%eax
}
 183:	5d                   	pop    %ebp
 184:	c3                   	ret    

00000185 <strlen>:

uint
strlen(char *s)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 192:	eb 04                	jmp    198 <strlen+0x13>
 194:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 198:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	01 d0                	add    %edx,%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 ed                	jne    194 <strlen+0xf>
    ;
  return n;
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1b2:	8b 45 10             	mov    0x10(%ebp),%eax
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	89 04 24             	mov    %eax,(%esp)
 1c6:	e8 26 ff ff ff       	call   f1 <stosb>
  return dst;
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ce:	c9                   	leave  
 1cf:	c3                   	ret    

000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	83 ec 04             	sub    $0x4,%esp
 1d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1dc:	eb 14                	jmp    1f2 <strchr+0x22>
    if(*s == c)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	0f b6 00             	movzbl (%eax),%eax
 1e4:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1e7:	75 05                	jne    1ee <strchr+0x1e>
      return (char*)s;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	eb 13                	jmp    201 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	0f b6 00             	movzbl (%eax),%eax
 1f8:	84 c0                	test   %al,%al
 1fa:	75 e2                	jne    1de <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 201:	c9                   	leave  
 202:	c3                   	ret    

00000203 <gets>:

char*
gets(char *buf, int max)
{
 203:	55                   	push   %ebp
 204:	89 e5                	mov    %esp,%ebp
 206:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 210:	eb 4c                	jmp    25e <gets+0x5b>
    cc = read(0, &c, 1);
 212:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 219:	00 
 21a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21d:	89 44 24 04          	mov    %eax,0x4(%esp)
 221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 228:	e8 44 01 00 00       	call   371 <read>
 22d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 230:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 234:	7f 02                	jg     238 <gets+0x35>
      break;
 236:	eb 31                	jmp    269 <gets+0x66>
    buf[i++] = c;
 238:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23b:	8d 50 01             	lea    0x1(%eax),%edx
 23e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 241:	89 c2                	mov    %eax,%edx
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	01 c2                	add    %eax,%edx
 248:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 252:	3c 0a                	cmp    $0xa,%al
 254:	74 13                	je     269 <gets+0x66>
 256:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25a:	3c 0d                	cmp    $0xd,%al
 25c:	74 0b                	je     269 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 261:	83 c0 01             	add    $0x1,%eax
 264:	3b 45 0c             	cmp    0xc(%ebp),%eax
 267:	7c a9                	jl     212 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 269:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	01 d0                	add    %edx,%eax
 271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <stat>:

int
stat(char *n, struct stat *st)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 286:	00 
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 07 01 00 00       	call   399 <open>
 292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 295:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 299:	79 07                	jns    2a2 <stat+0x29>
    return -1;
 29b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a0:	eb 23                	jmp    2c5 <stat+0x4c>
  r = fstat(fd, st);
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	89 04 24             	mov    %eax,(%esp)
 2af:	e8 fd 00 00 00       	call   3b1 <fstat>
 2b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 bf 00 00 00       	call   381 <close>
  return r;
 2c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <atoi>:

int
atoi(const char *s)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	eb 25                	jmp    2fb <atoi+0x34>
    n = n*10 + *s++ - '0';
 2d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d9:	89 d0                	mov    %edx,%eax
 2db:	c1 e0 02             	shl    $0x2,%eax
 2de:	01 d0                	add    %edx,%eax
 2e0:	01 c0                	add    %eax,%eax
 2e2:	89 c1                	mov    %eax,%ecx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 50 01             	lea    0x1(%eax),%edx
 2ea:	89 55 08             	mov    %edx,0x8(%ebp)
 2ed:	0f b6 00             	movzbl (%eax),%eax
 2f0:	0f be c0             	movsbl %al,%eax
 2f3:	01 c8                	add    %ecx,%eax
 2f5:	83 e8 30             	sub    $0x30,%eax
 2f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	3c 2f                	cmp    $0x2f,%al
 303:	7e 0a                	jle    30f <atoi+0x48>
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	0f b6 00             	movzbl (%eax),%eax
 30b:	3c 39                	cmp    $0x39,%al
 30d:	7e c7                	jle    2d6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 30f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 312:	c9                   	leave  
 313:	c3                   	ret    

00000314 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 314:	55                   	push   %ebp
 315:	89 e5                	mov    %esp,%ebp
 317:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 320:	8b 45 0c             	mov    0xc(%ebp),%eax
 323:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 326:	eb 17                	jmp    33f <memmove+0x2b>
    *dst++ = *src++;
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
 32b:	8d 50 01             	lea    0x1(%eax),%edx
 32e:	89 55 fc             	mov    %edx,-0x4(%ebp)
 331:	8b 55 f8             	mov    -0x8(%ebp),%edx
 334:	8d 4a 01             	lea    0x1(%edx),%ecx
 337:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 33a:	0f b6 12             	movzbl (%edx),%edx
 33d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33f:	8b 45 10             	mov    0x10(%ebp),%eax
 342:	8d 50 ff             	lea    -0x1(%eax),%edx
 345:	89 55 10             	mov    %edx,0x10(%ebp)
 348:	85 c0                	test   %eax,%eax
 34a:	7f dc                	jg     328 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34f:	c9                   	leave  
 350:	c3                   	ret    

00000351 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 351:	b8 01 00 00 00       	mov    $0x1,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <exit>:
SYSCALL(exit)
 359:	b8 02 00 00 00       	mov    $0x2,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <wait>:
SYSCALL(wait)
 361:	b8 03 00 00 00       	mov    $0x3,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <pipe>:
SYSCALL(pipe)
 369:	b8 04 00 00 00       	mov    $0x4,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <read>:
SYSCALL(read)
 371:	b8 05 00 00 00       	mov    $0x5,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <write>:
SYSCALL(write)
 379:	b8 10 00 00 00       	mov    $0x10,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <close>:
SYSCALL(close)
 381:	b8 15 00 00 00       	mov    $0x15,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <kill>:
SYSCALL(kill)
 389:	b8 06 00 00 00       	mov    $0x6,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <exec>:
SYSCALL(exec)
 391:	b8 07 00 00 00       	mov    $0x7,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <open>:
SYSCALL(open)
 399:	b8 0f 00 00 00       	mov    $0xf,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <mknod>:
SYSCALL(mknod)
 3a1:	b8 11 00 00 00       	mov    $0x11,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <unlink>:
SYSCALL(unlink)
 3a9:	b8 12 00 00 00       	mov    $0x12,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <fstat>:
SYSCALL(fstat)
 3b1:	b8 08 00 00 00       	mov    $0x8,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <link>:
SYSCALL(link)
 3b9:	b8 13 00 00 00       	mov    $0x13,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <mkdir>:
SYSCALL(mkdir)
 3c1:	b8 14 00 00 00       	mov    $0x14,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <chdir>:
SYSCALL(chdir)
 3c9:	b8 09 00 00 00       	mov    $0x9,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <dup>:
SYSCALL(dup)
 3d1:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <getpid>:
SYSCALL(getpid)
 3d9:	b8 0b 00 00 00       	mov    $0xb,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <sbrk>:
SYSCALL(sbrk)
 3e1:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <sleep>:
SYSCALL(sleep)
 3e9:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <uptime>:
SYSCALL(uptime)
 3f1:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <symlink>:
SYSCALL(symlink)
 3f9:	b8 16 00 00 00       	mov    $0x16,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <readlink>:
SYSCALL(readlink)
 401:	b8 17 00 00 00       	mov    $0x17,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 409:	55                   	push   %ebp
 40a:	89 e5                	mov    %esp,%ebp
 40c:	83 ec 18             	sub    $0x18,%esp
 40f:	8b 45 0c             	mov    0xc(%ebp),%eax
 412:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 415:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 41c:	00 
 41d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 420:	89 44 24 04          	mov    %eax,0x4(%esp)
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	89 04 24             	mov    %eax,(%esp)
 42a:	e8 4a ff ff ff       	call   379 <write>
}
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	56                   	push   %esi
 435:	53                   	push   %ebx
 436:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 439:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 440:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 444:	74 17                	je     45d <printint+0x2c>
 446:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 44a:	79 11                	jns    45d <printint+0x2c>
    neg = 1;
 44c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 453:	8b 45 0c             	mov    0xc(%ebp),%eax
 456:	f7 d8                	neg    %eax
 458:	89 45 ec             	mov    %eax,-0x14(%ebp)
 45b:	eb 06                	jmp    463 <printint+0x32>
  } else {
    x = xx;
 45d:	8b 45 0c             	mov    0xc(%ebp),%eax
 460:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 463:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 46a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 46d:	8d 41 01             	lea    0x1(%ecx),%eax
 470:	89 45 f4             	mov    %eax,-0xc(%ebp)
 473:	8b 5d 10             	mov    0x10(%ebp),%ebx
 476:	8b 45 ec             	mov    -0x14(%ebp),%eax
 479:	ba 00 00 00 00       	mov    $0x0,%edx
 47e:	f7 f3                	div    %ebx
 480:	89 d0                	mov    %edx,%eax
 482:	0f b6 80 44 0b 00 00 	movzbl 0xb44(%eax),%eax
 489:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 48d:	8b 75 10             	mov    0x10(%ebp),%esi
 490:	8b 45 ec             	mov    -0x14(%ebp),%eax
 493:	ba 00 00 00 00       	mov    $0x0,%edx
 498:	f7 f6                	div    %esi
 49a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 49d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a1:	75 c7                	jne    46a <printint+0x39>
  if(neg)
 4a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a7:	74 10                	je     4b9 <printint+0x88>
    buf[i++] = '-';
 4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ac:	8d 50 01             	lea    0x1(%eax),%edx
 4af:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4b7:	eb 1f                	jmp    4d8 <printint+0xa7>
 4b9:	eb 1d                	jmp    4d8 <printint+0xa7>
    putc(fd, buf[i]);
 4bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c1:	01 d0                	add    %edx,%eax
 4c3:	0f b6 00             	movzbl (%eax),%eax
 4c6:	0f be c0             	movsbl %al,%eax
 4c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	89 04 24             	mov    %eax,(%esp)
 4d3:	e8 31 ff ff ff       	call   409 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4d8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e0:	79 d9                	jns    4bb <printint+0x8a>
    putc(fd, buf[i]);
}
 4e2:	83 c4 30             	add    $0x30,%esp
 4e5:	5b                   	pop    %ebx
 4e6:	5e                   	pop    %esi
 4e7:	5d                   	pop    %ebp
 4e8:	c3                   	ret    

000004e9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4e9:	55                   	push   %ebp
 4ea:	89 e5                	mov    %esp,%ebp
 4ec:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4f6:	8d 45 0c             	lea    0xc(%ebp),%eax
 4f9:	83 c0 04             	add    $0x4,%eax
 4fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 506:	e9 7c 01 00 00       	jmp    687 <printf+0x19e>
    c = fmt[i] & 0xff;
 50b:	8b 55 0c             	mov    0xc(%ebp),%edx
 50e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 511:	01 d0                	add    %edx,%eax
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	25 ff 00 00 00       	and    $0xff,%eax
 51e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 521:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 525:	75 2c                	jne    553 <printf+0x6a>
      if(c == '%'){
 527:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 52b:	75 0c                	jne    539 <printf+0x50>
        state = '%';
 52d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 534:	e9 4a 01 00 00       	jmp    683 <printf+0x19a>
      } else {
        putc(fd, c);
 539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53c:	0f be c0             	movsbl %al,%eax
 53f:	89 44 24 04          	mov    %eax,0x4(%esp)
 543:	8b 45 08             	mov    0x8(%ebp),%eax
 546:	89 04 24             	mov    %eax,(%esp)
 549:	e8 bb fe ff ff       	call   409 <putc>
 54e:	e9 30 01 00 00       	jmp    683 <printf+0x19a>
      }
    } else if(state == '%'){
 553:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 557:	0f 85 26 01 00 00    	jne    683 <printf+0x19a>
      if(c == 'd'){
 55d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 561:	75 2d                	jne    590 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 563:	8b 45 e8             	mov    -0x18(%ebp),%eax
 566:	8b 00                	mov    (%eax),%eax
 568:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 56f:	00 
 570:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 577:	00 
 578:	89 44 24 04          	mov    %eax,0x4(%esp)
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
 57f:	89 04 24             	mov    %eax,(%esp)
 582:	e8 aa fe ff ff       	call   431 <printint>
        ap++;
 587:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58b:	e9 ec 00 00 00       	jmp    67c <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 590:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 594:	74 06                	je     59c <printf+0xb3>
 596:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 59a:	75 2d                	jne    5c9 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 59c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59f:	8b 00                	mov    (%eax),%eax
 5a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5a8:	00 
 5a9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5b0:	00 
 5b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	89 04 24             	mov    %eax,(%esp)
 5bb:	e8 71 fe ff ff       	call   431 <printint>
        ap++;
 5c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c4:	e9 b3 00 00 00       	jmp    67c <printf+0x193>
      } else if(c == 's'){
 5c9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5cd:	75 45                	jne    614 <printf+0x12b>
        s = (char*)*ap;
 5cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d2:	8b 00                	mov    (%eax),%eax
 5d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5df:	75 09                	jne    5ea <printf+0x101>
          s = "(null)";
 5e1:	c7 45 f4 f6 08 00 00 	movl   $0x8f6,-0xc(%ebp)
        while(*s != 0){
 5e8:	eb 1e                	jmp    608 <printf+0x11f>
 5ea:	eb 1c                	jmp    608 <printf+0x11f>
          putc(fd, *s);
 5ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ef:	0f b6 00             	movzbl (%eax),%eax
 5f2:	0f be c0             	movsbl %al,%eax
 5f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	89 04 24             	mov    %eax,(%esp)
 5ff:	e8 05 fe ff ff       	call   409 <putc>
          s++;
 604:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 608:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60b:	0f b6 00             	movzbl (%eax),%eax
 60e:	84 c0                	test   %al,%al
 610:	75 da                	jne    5ec <printf+0x103>
 612:	eb 68                	jmp    67c <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 614:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 618:	75 1d                	jne    637 <printf+0x14e>
        putc(fd, *ap);
 61a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	0f be c0             	movsbl %al,%eax
 622:	89 44 24 04          	mov    %eax,0x4(%esp)
 626:	8b 45 08             	mov    0x8(%ebp),%eax
 629:	89 04 24             	mov    %eax,(%esp)
 62c:	e8 d8 fd ff ff       	call   409 <putc>
        ap++;
 631:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 635:	eb 45                	jmp    67c <printf+0x193>
      } else if(c == '%'){
 637:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 63b:	75 17                	jne    654 <printf+0x16b>
        putc(fd, c);
 63d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 640:	0f be c0             	movsbl %al,%eax
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 b7 fd ff ff       	call   409 <putc>
 652:	eb 28                	jmp    67c <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 654:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 65b:	00 
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	89 04 24             	mov    %eax,(%esp)
 662:	e8 a2 fd ff ff       	call   409 <putc>
        putc(fd, c);
 667:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66a:	0f be c0             	movsbl %al,%eax
 66d:	89 44 24 04          	mov    %eax,0x4(%esp)
 671:	8b 45 08             	mov    0x8(%ebp),%eax
 674:	89 04 24             	mov    %eax,(%esp)
 677:	e8 8d fd ff ff       	call   409 <putc>
      }
      state = 0;
 67c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 683:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 687:	8b 55 0c             	mov    0xc(%ebp),%edx
 68a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 68d:	01 d0                	add    %edx,%eax
 68f:	0f b6 00             	movzbl (%eax),%eax
 692:	84 c0                	test   %al,%al
 694:	0f 85 71 fe ff ff    	jne    50b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 69a:	c9                   	leave  
 69b:	c3                   	ret    

0000069c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 69c:	55                   	push   %ebp
 69d:	89 e5                	mov    %esp,%ebp
 69f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a2:	8b 45 08             	mov    0x8(%ebp),%eax
 6a5:	83 e8 08             	sub    $0x8,%eax
 6a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ab:	a1 60 0b 00 00       	mov    0xb60,%eax
 6b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b3:	eb 24                	jmp    6d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6bd:	77 12                	ja     6d1 <free+0x35>
 6bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c5:	77 24                	ja     6eb <free+0x4f>
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	8b 00                	mov    (%eax),%eax
 6cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cf:	77 1a                	ja     6eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6df:	76 d4                	jbe    6b5 <free+0x19>
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e9:	76 ca                	jbe    6b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ee:	8b 40 04             	mov    0x4(%eax),%eax
 6f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fb:	01 c2                	add    %eax,%edx
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	39 c2                	cmp    %eax,%edx
 704:	75 24                	jne    72a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	8b 50 04             	mov    0x4(%eax),%edx
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	8b 00                	mov    (%eax),%eax
 711:	8b 40 04             	mov    0x4(%eax),%eax
 714:	01 c2                	add    %eax,%edx
 716:	8b 45 f8             	mov    -0x8(%ebp),%eax
 719:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 00                	mov    (%eax),%eax
 721:	8b 10                	mov    (%eax),%edx
 723:	8b 45 f8             	mov    -0x8(%ebp),%eax
 726:	89 10                	mov    %edx,(%eax)
 728:	eb 0a                	jmp    734 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 72a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72d:	8b 10                	mov    (%eax),%edx
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 40 04             	mov    0x4(%eax),%eax
 73a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	01 d0                	add    %edx,%eax
 746:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 749:	75 20                	jne    76b <free+0xcf>
    p->s.size += bp->s.size;
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 50 04             	mov    0x4(%eax),%edx
 751:	8b 45 f8             	mov    -0x8(%ebp),%eax
 754:	8b 40 04             	mov    0x4(%eax),%eax
 757:	01 c2                	add    %eax,%edx
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	8b 10                	mov    (%eax),%edx
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	89 10                	mov    %edx,(%eax)
 769:	eb 08                	jmp    773 <free+0xd7>
  } else
    p->s.ptr = bp;
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 771:	89 10                	mov    %edx,(%eax)
  freep = p;
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	a3 60 0b 00 00       	mov    %eax,0xb60
}
 77b:	c9                   	leave  
 77c:	c3                   	ret    

0000077d <morecore>:

static Header*
morecore(uint nu)
{
 77d:	55                   	push   %ebp
 77e:	89 e5                	mov    %esp,%ebp
 780:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 783:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 78a:	77 07                	ja     793 <morecore+0x16>
    nu = 4096;
 78c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 793:	8b 45 08             	mov    0x8(%ebp),%eax
 796:	c1 e0 03             	shl    $0x3,%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 40 fc ff ff       	call   3e1 <sbrk>
 7a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7a8:	75 07                	jne    7b1 <morecore+0x34>
    return 0;
 7aa:	b8 00 00 00 00       	mov    $0x0,%eax
 7af:	eb 22                	jmp    7d3 <morecore+0x56>
  hp = (Header*)p;
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ba:	8b 55 08             	mov    0x8(%ebp),%edx
 7bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c3:	83 c0 08             	add    $0x8,%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 ce fe ff ff       	call   69c <free>
  return freep;
 7ce:	a1 60 0b 00 00       	mov    0xb60,%eax
}
 7d3:	c9                   	leave  
 7d4:	c3                   	ret    

000007d5 <malloc>:

void*
malloc(uint nbytes)
{
 7d5:	55                   	push   %ebp
 7d6:	89 e5                	mov    %esp,%ebp
 7d8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7db:	8b 45 08             	mov    0x8(%ebp),%eax
 7de:	83 c0 07             	add    $0x7,%eax
 7e1:	c1 e8 03             	shr    $0x3,%eax
 7e4:	83 c0 01             	add    $0x1,%eax
 7e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ea:	a1 60 0b 00 00       	mov    0xb60,%eax
 7ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7f6:	75 23                	jne    81b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7f8:	c7 45 f0 58 0b 00 00 	movl   $0xb58,-0x10(%ebp)
 7ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 802:	a3 60 0b 00 00       	mov    %eax,0xb60
 807:	a1 60 0b 00 00       	mov    0xb60,%eax
 80c:	a3 58 0b 00 00       	mov    %eax,0xb58
    base.s.size = 0;
 811:	c7 05 5c 0b 00 00 00 	movl   $0x0,0xb5c
 818:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81e:	8b 00                	mov    (%eax),%eax
 820:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	8b 40 04             	mov    0x4(%eax),%eax
 829:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 82c:	72 4d                	jb     87b <malloc+0xa6>
      if(p->s.size == nunits)
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	8b 40 04             	mov    0x4(%eax),%eax
 834:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 837:	75 0c                	jne    845 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 10                	mov    (%eax),%edx
 83e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 841:	89 10                	mov    %edx,(%eax)
 843:	eb 26                	jmp    86b <malloc+0x96>
      else {
        p->s.size -= nunits;
 845:	8b 45 f4             	mov    -0xc(%ebp),%eax
 848:	8b 40 04             	mov    0x4(%eax),%eax
 84b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 84e:	89 c2                	mov    %eax,%edx
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	8b 40 04             	mov    0x4(%eax),%eax
 85c:	c1 e0 03             	shl    $0x3,%eax
 85f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 862:	8b 45 f4             	mov    -0xc(%ebp),%eax
 865:	8b 55 ec             	mov    -0x14(%ebp),%edx
 868:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 86b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86e:	a3 60 0b 00 00       	mov    %eax,0xb60
      return (void*)(p + 1);
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	83 c0 08             	add    $0x8,%eax
 879:	eb 38                	jmp    8b3 <malloc+0xde>
    }
    if(p == freep)
 87b:	a1 60 0b 00 00       	mov    0xb60,%eax
 880:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 883:	75 1b                	jne    8a0 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 885:	8b 45 ec             	mov    -0x14(%ebp),%eax
 888:	89 04 24             	mov    %eax,(%esp)
 88b:	e8 ed fe ff ff       	call   77d <morecore>
 890:	89 45 f4             	mov    %eax,-0xc(%ebp)
 893:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 897:	75 07                	jne    8a0 <malloc+0xcb>
        return 0;
 899:	b8 00 00 00 00       	mov    $0x0,%eax
 89e:	eb 13                	jmp    8b3 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a9:	8b 00                	mov    (%eax),%eax
 8ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8ae:	e9 70 ff ff ff       	jmp    823 <malloc+0x4e>
}
 8b3:	c9                   	leave  
 8b4:	c3                   	ret    
