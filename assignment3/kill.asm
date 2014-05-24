
_kill:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 e4 f0             	and    $0xfffffff0,%esp
    1006:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 1){
    1009:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    100d:	7f 19                	jg     1028 <main+0x28>
    printf(2, "usage: kill pid...\n");
    100f:	c7 44 24 04 1b 18 00 	movl   $0x181b,0x4(%esp)
    1016:	00 
    1017:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    101e:	e8 2c 04 00 00       	call   144f <printf>
    exit();
    1023:	e8 a7 02 00 00       	call   12cf <exit>
  }
  for(i=1; i<argc; i++)
    1028:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
    102f:	00 
    1030:	eb 27                	jmp    1059 <main+0x59>
    kill(atoi(argv[i]));
    1032:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1036:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    103d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1040:	01 d0                	add    %edx,%eax
    1042:	8b 00                	mov    (%eax),%eax
    1044:	89 04 24             	mov    %eax,(%esp)
    1047:	e8 f1 01 00 00       	call   123d <atoi>
    104c:	89 04 24             	mov    %eax,(%esp)
    104f:	e8 ab 02 00 00       	call   12ff <kill>

  if(argc < 1){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
    1054:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
    1059:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    105d:	3b 45 08             	cmp    0x8(%ebp),%eax
    1060:	7c d0                	jl     1032 <main+0x32>
    kill(atoi(argv[i]));
  exit();
    1062:	e8 68 02 00 00       	call   12cf <exit>

00001067 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1067:	55                   	push   %ebp
    1068:	89 e5                	mov    %esp,%ebp
    106a:	57                   	push   %edi
    106b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    106c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    106f:	8b 55 10             	mov    0x10(%ebp),%edx
    1072:	8b 45 0c             	mov    0xc(%ebp),%eax
    1075:	89 cb                	mov    %ecx,%ebx
    1077:	89 df                	mov    %ebx,%edi
    1079:	89 d1                	mov    %edx,%ecx
    107b:	fc                   	cld    
    107c:	f3 aa                	rep stos %al,%es:(%edi)
    107e:	89 ca                	mov    %ecx,%edx
    1080:	89 fb                	mov    %edi,%ebx
    1082:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1085:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1088:	5b                   	pop    %ebx
    1089:	5f                   	pop    %edi
    108a:	5d                   	pop    %ebp
    108b:	c3                   	ret    

0000108c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    108c:	55                   	push   %ebp
    108d:	89 e5                	mov    %esp,%ebp
    108f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1092:	8b 45 08             	mov    0x8(%ebp),%eax
    1095:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1098:	90                   	nop
    1099:	8b 45 08             	mov    0x8(%ebp),%eax
    109c:	8d 50 01             	lea    0x1(%eax),%edx
    109f:	89 55 08             	mov    %edx,0x8(%ebp)
    10a2:	8b 55 0c             	mov    0xc(%ebp),%edx
    10a5:	8d 4a 01             	lea    0x1(%edx),%ecx
    10a8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10ab:	0f b6 12             	movzbl (%edx),%edx
    10ae:	88 10                	mov    %dl,(%eax)
    10b0:	0f b6 00             	movzbl (%eax),%eax
    10b3:	84 c0                	test   %al,%al
    10b5:	75 e2                	jne    1099 <strcpy+0xd>
    ;
  return os;
    10b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10ba:	c9                   	leave  
    10bb:	c3                   	ret    

000010bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10bc:	55                   	push   %ebp
    10bd:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10bf:	eb 08                	jmp    10c9 <strcmp+0xd>
    p++, q++;
    10c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10c5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10c9:	8b 45 08             	mov    0x8(%ebp),%eax
    10cc:	0f b6 00             	movzbl (%eax),%eax
    10cf:	84 c0                	test   %al,%al
    10d1:	74 10                	je     10e3 <strcmp+0x27>
    10d3:	8b 45 08             	mov    0x8(%ebp),%eax
    10d6:	0f b6 10             	movzbl (%eax),%edx
    10d9:	8b 45 0c             	mov    0xc(%ebp),%eax
    10dc:	0f b6 00             	movzbl (%eax),%eax
    10df:	38 c2                	cmp    %al,%dl
    10e1:	74 de                	je     10c1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10e3:	8b 45 08             	mov    0x8(%ebp),%eax
    10e6:	0f b6 00             	movzbl (%eax),%eax
    10e9:	0f b6 d0             	movzbl %al,%edx
    10ec:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ef:	0f b6 00             	movzbl (%eax),%eax
    10f2:	0f b6 c0             	movzbl %al,%eax
    10f5:	29 c2                	sub    %eax,%edx
    10f7:	89 d0                	mov    %edx,%eax
}
    10f9:	5d                   	pop    %ebp
    10fa:	c3                   	ret    

000010fb <strlen>:

uint
strlen(char *s)
{
    10fb:	55                   	push   %ebp
    10fc:	89 e5                	mov    %esp,%ebp
    10fe:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1101:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1108:	eb 04                	jmp    110e <strlen+0x13>
    110a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    110e:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1111:	8b 45 08             	mov    0x8(%ebp),%eax
    1114:	01 d0                	add    %edx,%eax
    1116:	0f b6 00             	movzbl (%eax),%eax
    1119:	84 c0                	test   %al,%al
    111b:	75 ed                	jne    110a <strlen+0xf>
    ;
  return n;
    111d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1120:	c9                   	leave  
    1121:	c3                   	ret    

00001122 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1122:	55                   	push   %ebp
    1123:	89 e5                	mov    %esp,%ebp
    1125:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    1128:	8b 45 10             	mov    0x10(%ebp),%eax
    112b:	89 44 24 08          	mov    %eax,0x8(%esp)
    112f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1132:	89 44 24 04          	mov    %eax,0x4(%esp)
    1136:	8b 45 08             	mov    0x8(%ebp),%eax
    1139:	89 04 24             	mov    %eax,(%esp)
    113c:	e8 26 ff ff ff       	call   1067 <stosb>
  return dst;
    1141:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1144:	c9                   	leave  
    1145:	c3                   	ret    

00001146 <strchr>:

char*
strchr(const char *s, char c)
{
    1146:	55                   	push   %ebp
    1147:	89 e5                	mov    %esp,%ebp
    1149:	83 ec 04             	sub    $0x4,%esp
    114c:	8b 45 0c             	mov    0xc(%ebp),%eax
    114f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1152:	eb 14                	jmp    1168 <strchr+0x22>
    if(*s == c)
    1154:	8b 45 08             	mov    0x8(%ebp),%eax
    1157:	0f b6 00             	movzbl (%eax),%eax
    115a:	3a 45 fc             	cmp    -0x4(%ebp),%al
    115d:	75 05                	jne    1164 <strchr+0x1e>
      return (char*)s;
    115f:	8b 45 08             	mov    0x8(%ebp),%eax
    1162:	eb 13                	jmp    1177 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1164:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1168:	8b 45 08             	mov    0x8(%ebp),%eax
    116b:	0f b6 00             	movzbl (%eax),%eax
    116e:	84 c0                	test   %al,%al
    1170:	75 e2                	jne    1154 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1172:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1177:	c9                   	leave  
    1178:	c3                   	ret    

00001179 <gets>:

char*
gets(char *buf, int max)
{
    1179:	55                   	push   %ebp
    117a:	89 e5                	mov    %esp,%ebp
    117c:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    117f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1186:	eb 4c                	jmp    11d4 <gets+0x5b>
    cc = read(0, &c, 1);
    1188:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    118f:	00 
    1190:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1193:	89 44 24 04          	mov    %eax,0x4(%esp)
    1197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    119e:	e8 44 01 00 00       	call   12e7 <read>
    11a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11aa:	7f 02                	jg     11ae <gets+0x35>
      break;
    11ac:	eb 31                	jmp    11df <gets+0x66>
    buf[i++] = c;
    11ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11b1:	8d 50 01             	lea    0x1(%eax),%edx
    11b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11b7:	89 c2                	mov    %eax,%edx
    11b9:	8b 45 08             	mov    0x8(%ebp),%eax
    11bc:	01 c2                	add    %eax,%edx
    11be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c8:	3c 0a                	cmp    $0xa,%al
    11ca:	74 13                	je     11df <gets+0x66>
    11cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d0:	3c 0d                	cmp    $0xd,%al
    11d2:	74 0b                	je     11df <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d7:	83 c0 01             	add    $0x1,%eax
    11da:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11dd:	7c a9                	jl     1188 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11df:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11e2:	8b 45 08             	mov    0x8(%ebp),%eax
    11e5:	01 d0                	add    %edx,%eax
    11e7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ed:	c9                   	leave  
    11ee:	c3                   	ret    

000011ef <stat>:

int
stat(char *n, struct stat *st)
{
    11ef:	55                   	push   %ebp
    11f0:	89 e5                	mov    %esp,%ebp
    11f2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11fc:	00 
    11fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1200:	89 04 24             	mov    %eax,(%esp)
    1203:	e8 07 01 00 00       	call   130f <open>
    1208:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    120b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    120f:	79 07                	jns    1218 <stat+0x29>
    return -1;
    1211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1216:	eb 23                	jmp    123b <stat+0x4c>
  r = fstat(fd, st);
    1218:	8b 45 0c             	mov    0xc(%ebp),%eax
    121b:	89 44 24 04          	mov    %eax,0x4(%esp)
    121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1222:	89 04 24             	mov    %eax,(%esp)
    1225:	e8 fd 00 00 00       	call   1327 <fstat>
    122a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    122d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1230:	89 04 24             	mov    %eax,(%esp)
    1233:	e8 bf 00 00 00       	call   12f7 <close>
  return r;
    1238:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    123b:	c9                   	leave  
    123c:	c3                   	ret    

0000123d <atoi>:

int
atoi(const char *s)
{
    123d:	55                   	push   %ebp
    123e:	89 e5                	mov    %esp,%ebp
    1240:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1243:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    124a:	eb 25                	jmp    1271 <atoi+0x34>
    n = n*10 + *s++ - '0';
    124c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    124f:	89 d0                	mov    %edx,%eax
    1251:	c1 e0 02             	shl    $0x2,%eax
    1254:	01 d0                	add    %edx,%eax
    1256:	01 c0                	add    %eax,%eax
    1258:	89 c1                	mov    %eax,%ecx
    125a:	8b 45 08             	mov    0x8(%ebp),%eax
    125d:	8d 50 01             	lea    0x1(%eax),%edx
    1260:	89 55 08             	mov    %edx,0x8(%ebp)
    1263:	0f b6 00             	movzbl (%eax),%eax
    1266:	0f be c0             	movsbl %al,%eax
    1269:	01 c8                	add    %ecx,%eax
    126b:	83 e8 30             	sub    $0x30,%eax
    126e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1271:	8b 45 08             	mov    0x8(%ebp),%eax
    1274:	0f b6 00             	movzbl (%eax),%eax
    1277:	3c 2f                	cmp    $0x2f,%al
    1279:	7e 0a                	jle    1285 <atoi+0x48>
    127b:	8b 45 08             	mov    0x8(%ebp),%eax
    127e:	0f b6 00             	movzbl (%eax),%eax
    1281:	3c 39                	cmp    $0x39,%al
    1283:	7e c7                	jle    124c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1285:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1288:	c9                   	leave  
    1289:	c3                   	ret    

0000128a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    128a:	55                   	push   %ebp
    128b:	89 e5                	mov    %esp,%ebp
    128d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1290:	8b 45 08             	mov    0x8(%ebp),%eax
    1293:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1296:	8b 45 0c             	mov    0xc(%ebp),%eax
    1299:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    129c:	eb 17                	jmp    12b5 <memmove+0x2b>
    *dst++ = *src++;
    129e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a1:	8d 50 01             	lea    0x1(%eax),%edx
    12a4:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12a7:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12aa:	8d 4a 01             	lea    0x1(%edx),%ecx
    12ad:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12b0:	0f b6 12             	movzbl (%edx),%edx
    12b3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12b5:	8b 45 10             	mov    0x10(%ebp),%eax
    12b8:	8d 50 ff             	lea    -0x1(%eax),%edx
    12bb:	89 55 10             	mov    %edx,0x10(%ebp)
    12be:	85 c0                	test   %eax,%eax
    12c0:	7f dc                	jg     129e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12c5:	c9                   	leave  
    12c6:	c3                   	ret    

000012c7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12c7:	b8 01 00 00 00       	mov    $0x1,%eax
    12cc:	cd 40                	int    $0x40
    12ce:	c3                   	ret    

000012cf <exit>:
SYSCALL(exit)
    12cf:	b8 02 00 00 00       	mov    $0x2,%eax
    12d4:	cd 40                	int    $0x40
    12d6:	c3                   	ret    

000012d7 <wait>:
SYSCALL(wait)
    12d7:	b8 03 00 00 00       	mov    $0x3,%eax
    12dc:	cd 40                	int    $0x40
    12de:	c3                   	ret    

000012df <pipe>:
SYSCALL(pipe)
    12df:	b8 04 00 00 00       	mov    $0x4,%eax
    12e4:	cd 40                	int    $0x40
    12e6:	c3                   	ret    

000012e7 <read>:
SYSCALL(read)
    12e7:	b8 05 00 00 00       	mov    $0x5,%eax
    12ec:	cd 40                	int    $0x40
    12ee:	c3                   	ret    

000012ef <write>:
SYSCALL(write)
    12ef:	b8 10 00 00 00       	mov    $0x10,%eax
    12f4:	cd 40                	int    $0x40
    12f6:	c3                   	ret    

000012f7 <close>:
SYSCALL(close)
    12f7:	b8 15 00 00 00       	mov    $0x15,%eax
    12fc:	cd 40                	int    $0x40
    12fe:	c3                   	ret    

000012ff <kill>:
SYSCALL(kill)
    12ff:	b8 06 00 00 00       	mov    $0x6,%eax
    1304:	cd 40                	int    $0x40
    1306:	c3                   	ret    

00001307 <exec>:
SYSCALL(exec)
    1307:	b8 07 00 00 00       	mov    $0x7,%eax
    130c:	cd 40                	int    $0x40
    130e:	c3                   	ret    

0000130f <open>:
SYSCALL(open)
    130f:	b8 0f 00 00 00       	mov    $0xf,%eax
    1314:	cd 40                	int    $0x40
    1316:	c3                   	ret    

00001317 <mknod>:
SYSCALL(mknod)
    1317:	b8 11 00 00 00       	mov    $0x11,%eax
    131c:	cd 40                	int    $0x40
    131e:	c3                   	ret    

0000131f <unlink>:
SYSCALL(unlink)
    131f:	b8 12 00 00 00       	mov    $0x12,%eax
    1324:	cd 40                	int    $0x40
    1326:	c3                   	ret    

00001327 <fstat>:
SYSCALL(fstat)
    1327:	b8 08 00 00 00       	mov    $0x8,%eax
    132c:	cd 40                	int    $0x40
    132e:	c3                   	ret    

0000132f <link>:
SYSCALL(link)
    132f:	b8 13 00 00 00       	mov    $0x13,%eax
    1334:	cd 40                	int    $0x40
    1336:	c3                   	ret    

00001337 <mkdir>:
SYSCALL(mkdir)
    1337:	b8 14 00 00 00       	mov    $0x14,%eax
    133c:	cd 40                	int    $0x40
    133e:	c3                   	ret    

0000133f <chdir>:
SYSCALL(chdir)
    133f:	b8 09 00 00 00       	mov    $0x9,%eax
    1344:	cd 40                	int    $0x40
    1346:	c3                   	ret    

00001347 <dup>:
SYSCALL(dup)
    1347:	b8 0a 00 00 00       	mov    $0xa,%eax
    134c:	cd 40                	int    $0x40
    134e:	c3                   	ret    

0000134f <getpid>:
SYSCALL(getpid)
    134f:	b8 0b 00 00 00       	mov    $0xb,%eax
    1354:	cd 40                	int    $0x40
    1356:	c3                   	ret    

00001357 <sbrk>:
SYSCALL(sbrk)
    1357:	b8 0c 00 00 00       	mov    $0xc,%eax
    135c:	cd 40                	int    $0x40
    135e:	c3                   	ret    

0000135f <sleep>:
SYSCALL(sleep)
    135f:	b8 0d 00 00 00       	mov    $0xd,%eax
    1364:	cd 40                	int    $0x40
    1366:	c3                   	ret    

00001367 <uptime>:
SYSCALL(uptime)
    1367:	b8 0e 00 00 00       	mov    $0xe,%eax
    136c:	cd 40                	int    $0x40
    136e:	c3                   	ret    

0000136f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    136f:	55                   	push   %ebp
    1370:	89 e5                	mov    %esp,%ebp
    1372:	83 ec 18             	sub    $0x18,%esp
    1375:	8b 45 0c             	mov    0xc(%ebp),%eax
    1378:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    137b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1382:	00 
    1383:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1386:	89 44 24 04          	mov    %eax,0x4(%esp)
    138a:	8b 45 08             	mov    0x8(%ebp),%eax
    138d:	89 04 24             	mov    %eax,(%esp)
    1390:	e8 5a ff ff ff       	call   12ef <write>
}
    1395:	c9                   	leave  
    1396:	c3                   	ret    

00001397 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1397:	55                   	push   %ebp
    1398:	89 e5                	mov    %esp,%ebp
    139a:	56                   	push   %esi
    139b:	53                   	push   %ebx
    139c:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    139f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13a6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13aa:	74 17                	je     13c3 <printint+0x2c>
    13ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13b0:	79 11                	jns    13c3 <printint+0x2c>
    neg = 1;
    13b2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13b9:	8b 45 0c             	mov    0xc(%ebp),%eax
    13bc:	f7 d8                	neg    %eax
    13be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c1:	eb 06                	jmp    13c9 <printint+0x32>
  } else {
    x = xx;
    13c3:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13d0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13d3:	8d 41 01             	lea    0x1(%ecx),%eax
    13d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13df:	ba 00 00 00 00       	mov    $0x0,%edx
    13e4:	f7 f3                	div    %ebx
    13e6:	89 d0                	mov    %edx,%eax
    13e8:	0f b6 80 7c 2a 00 00 	movzbl 0x2a7c(%eax),%eax
    13ef:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13f3:	8b 75 10             	mov    0x10(%ebp),%esi
    13f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13f9:	ba 00 00 00 00       	mov    $0x0,%edx
    13fe:	f7 f6                	div    %esi
    1400:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1403:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1407:	75 c7                	jne    13d0 <printint+0x39>
  if(neg)
    1409:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    140d:	74 10                	je     141f <printint+0x88>
    buf[i++] = '-';
    140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1412:	8d 50 01             	lea    0x1(%eax),%edx
    1415:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1418:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    141d:	eb 1f                	jmp    143e <printint+0xa7>
    141f:	eb 1d                	jmp    143e <printint+0xa7>
    putc(fd, buf[i]);
    1421:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1424:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1427:	01 d0                	add    %edx,%eax
    1429:	0f b6 00             	movzbl (%eax),%eax
    142c:	0f be c0             	movsbl %al,%eax
    142f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1433:	8b 45 08             	mov    0x8(%ebp),%eax
    1436:	89 04 24             	mov    %eax,(%esp)
    1439:	e8 31 ff ff ff       	call   136f <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    143e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1442:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1446:	79 d9                	jns    1421 <printint+0x8a>
    putc(fd, buf[i]);
}
    1448:	83 c4 30             	add    $0x30,%esp
    144b:	5b                   	pop    %ebx
    144c:	5e                   	pop    %esi
    144d:	5d                   	pop    %ebp
    144e:	c3                   	ret    

0000144f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    144f:	55                   	push   %ebp
    1450:	89 e5                	mov    %esp,%ebp
    1452:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1455:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    145c:	8d 45 0c             	lea    0xc(%ebp),%eax
    145f:	83 c0 04             	add    $0x4,%eax
    1462:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1465:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    146c:	e9 7c 01 00 00       	jmp    15ed <printf+0x19e>
    c = fmt[i] & 0xff;
    1471:	8b 55 0c             	mov    0xc(%ebp),%edx
    1474:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1477:	01 d0                	add    %edx,%eax
    1479:	0f b6 00             	movzbl (%eax),%eax
    147c:	0f be c0             	movsbl %al,%eax
    147f:	25 ff 00 00 00       	and    $0xff,%eax
    1484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1487:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    148b:	75 2c                	jne    14b9 <printf+0x6a>
      if(c == '%'){
    148d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1491:	75 0c                	jne    149f <printf+0x50>
        state = '%';
    1493:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    149a:	e9 4a 01 00 00       	jmp    15e9 <printf+0x19a>
      } else {
        putc(fd, c);
    149f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14a2:	0f be c0             	movsbl %al,%eax
    14a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    14a9:	8b 45 08             	mov    0x8(%ebp),%eax
    14ac:	89 04 24             	mov    %eax,(%esp)
    14af:	e8 bb fe ff ff       	call   136f <putc>
    14b4:	e9 30 01 00 00       	jmp    15e9 <printf+0x19a>
      }
    } else if(state == '%'){
    14b9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14bd:	0f 85 26 01 00 00    	jne    15e9 <printf+0x19a>
      if(c == 'd'){
    14c3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14c7:	75 2d                	jne    14f6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    14c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14cc:	8b 00                	mov    (%eax),%eax
    14ce:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    14d5:	00 
    14d6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    14dd:	00 
    14de:	89 44 24 04          	mov    %eax,0x4(%esp)
    14e2:	8b 45 08             	mov    0x8(%ebp),%eax
    14e5:	89 04 24             	mov    %eax,(%esp)
    14e8:	e8 aa fe ff ff       	call   1397 <printint>
        ap++;
    14ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14f1:	e9 ec 00 00 00       	jmp    15e2 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    14f6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14fa:	74 06                	je     1502 <printf+0xb3>
    14fc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1500:	75 2d                	jne    152f <printf+0xe0>
        printint(fd, *ap, 16, 0);
    1502:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1505:	8b 00                	mov    (%eax),%eax
    1507:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    150e:	00 
    150f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1516:	00 
    1517:	89 44 24 04          	mov    %eax,0x4(%esp)
    151b:	8b 45 08             	mov    0x8(%ebp),%eax
    151e:	89 04 24             	mov    %eax,(%esp)
    1521:	e8 71 fe ff ff       	call   1397 <printint>
        ap++;
    1526:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    152a:	e9 b3 00 00 00       	jmp    15e2 <printf+0x193>
      } else if(c == 's'){
    152f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1533:	75 45                	jne    157a <printf+0x12b>
        s = (char*)*ap;
    1535:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1538:	8b 00                	mov    (%eax),%eax
    153a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    153d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1545:	75 09                	jne    1550 <printf+0x101>
          s = "(null)";
    1547:	c7 45 f4 2f 18 00 00 	movl   $0x182f,-0xc(%ebp)
        while(*s != 0){
    154e:	eb 1e                	jmp    156e <printf+0x11f>
    1550:	eb 1c                	jmp    156e <printf+0x11f>
          putc(fd, *s);
    1552:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1555:	0f b6 00             	movzbl (%eax),%eax
    1558:	0f be c0             	movsbl %al,%eax
    155b:	89 44 24 04          	mov    %eax,0x4(%esp)
    155f:	8b 45 08             	mov    0x8(%ebp),%eax
    1562:	89 04 24             	mov    %eax,(%esp)
    1565:	e8 05 fe ff ff       	call   136f <putc>
          s++;
    156a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1571:	0f b6 00             	movzbl (%eax),%eax
    1574:	84 c0                	test   %al,%al
    1576:	75 da                	jne    1552 <printf+0x103>
    1578:	eb 68                	jmp    15e2 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    157a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    157e:	75 1d                	jne    159d <printf+0x14e>
        putc(fd, *ap);
    1580:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1583:	8b 00                	mov    (%eax),%eax
    1585:	0f be c0             	movsbl %al,%eax
    1588:	89 44 24 04          	mov    %eax,0x4(%esp)
    158c:	8b 45 08             	mov    0x8(%ebp),%eax
    158f:	89 04 24             	mov    %eax,(%esp)
    1592:	e8 d8 fd ff ff       	call   136f <putc>
        ap++;
    1597:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159b:	eb 45                	jmp    15e2 <printf+0x193>
      } else if(c == '%'){
    159d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15a1:	75 17                	jne    15ba <printf+0x16b>
        putc(fd, c);
    15a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15a6:	0f be c0             	movsbl %al,%eax
    15a9:	89 44 24 04          	mov    %eax,0x4(%esp)
    15ad:	8b 45 08             	mov    0x8(%ebp),%eax
    15b0:	89 04 24             	mov    %eax,(%esp)
    15b3:	e8 b7 fd ff ff       	call   136f <putc>
    15b8:	eb 28                	jmp    15e2 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15ba:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    15c1:	00 
    15c2:	8b 45 08             	mov    0x8(%ebp),%eax
    15c5:	89 04 24             	mov    %eax,(%esp)
    15c8:	e8 a2 fd ff ff       	call   136f <putc>
        putc(fd, c);
    15cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15d0:	0f be c0             	movsbl %al,%eax
    15d3:	89 44 24 04          	mov    %eax,0x4(%esp)
    15d7:	8b 45 08             	mov    0x8(%ebp),%eax
    15da:	89 04 24             	mov    %eax,(%esp)
    15dd:	e8 8d fd ff ff       	call   136f <putc>
      }
      state = 0;
    15e2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15ed:	8b 55 0c             	mov    0xc(%ebp),%edx
    15f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f3:	01 d0                	add    %edx,%eax
    15f5:	0f b6 00             	movzbl (%eax),%eax
    15f8:	84 c0                	test   %al,%al
    15fa:	0f 85 71 fe ff ff    	jne    1471 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1600:	c9                   	leave  
    1601:	c3                   	ret    

00001602 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1602:	55                   	push   %ebp
    1603:	89 e5                	mov    %esp,%ebp
    1605:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1608:	8b 45 08             	mov    0x8(%ebp),%eax
    160b:	83 e8 08             	sub    $0x8,%eax
    160e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1611:	a1 98 2a 00 00       	mov    0x2a98,%eax
    1616:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1619:	eb 24                	jmp    163f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    161b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161e:	8b 00                	mov    (%eax),%eax
    1620:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1623:	77 12                	ja     1637 <free+0x35>
    1625:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1628:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    162b:	77 24                	ja     1651 <free+0x4f>
    162d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1630:	8b 00                	mov    (%eax),%eax
    1632:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1635:	77 1a                	ja     1651 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1637:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163a:	8b 00                	mov    (%eax),%eax
    163c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    163f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1642:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1645:	76 d4                	jbe    161b <free+0x19>
    1647:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164a:	8b 00                	mov    (%eax),%eax
    164c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    164f:	76 ca                	jbe    161b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1651:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1654:	8b 40 04             	mov    0x4(%eax),%eax
    1657:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    165e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1661:	01 c2                	add    %eax,%edx
    1663:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1666:	8b 00                	mov    (%eax),%eax
    1668:	39 c2                	cmp    %eax,%edx
    166a:	75 24                	jne    1690 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    166c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166f:	8b 50 04             	mov    0x4(%eax),%edx
    1672:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1675:	8b 00                	mov    (%eax),%eax
    1677:	8b 40 04             	mov    0x4(%eax),%eax
    167a:	01 c2                	add    %eax,%edx
    167c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1682:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1685:	8b 00                	mov    (%eax),%eax
    1687:	8b 10                	mov    (%eax),%edx
    1689:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168c:	89 10                	mov    %edx,(%eax)
    168e:	eb 0a                	jmp    169a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1690:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1693:	8b 10                	mov    (%eax),%edx
    1695:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1698:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    169a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169d:	8b 40 04             	mov    0x4(%eax),%eax
    16a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16aa:	01 d0                	add    %edx,%eax
    16ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16af:	75 20                	jne    16d1 <free+0xcf>
    p->s.size += bp->s.size;
    16b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b4:	8b 50 04             	mov    0x4(%eax),%edx
    16b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ba:	8b 40 04             	mov    0x4(%eax),%eax
    16bd:	01 c2                	add    %eax,%edx
    16bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c8:	8b 10                	mov    (%eax),%edx
    16ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16cd:	89 10                	mov    %edx,(%eax)
    16cf:	eb 08                	jmp    16d9 <free+0xd7>
  } else
    p->s.ptr = bp;
    16d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d4:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16d7:	89 10                	mov    %edx,(%eax)
  freep = p;
    16d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16dc:	a3 98 2a 00 00       	mov    %eax,0x2a98
}
    16e1:	c9                   	leave  
    16e2:	c3                   	ret    

000016e3 <morecore>:

static Header*
morecore(uint nu)
{
    16e3:	55                   	push   %ebp
    16e4:	89 e5                	mov    %esp,%ebp
    16e6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16e9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16f0:	77 07                	ja     16f9 <morecore+0x16>
    nu = 4096;
    16f2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16f9:	8b 45 08             	mov    0x8(%ebp),%eax
    16fc:	c1 e0 03             	shl    $0x3,%eax
    16ff:	89 04 24             	mov    %eax,(%esp)
    1702:	e8 50 fc ff ff       	call   1357 <sbrk>
    1707:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    170a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    170e:	75 07                	jne    1717 <morecore+0x34>
    return 0;
    1710:	b8 00 00 00 00       	mov    $0x0,%eax
    1715:	eb 22                	jmp    1739 <morecore+0x56>
  hp = (Header*)p;
    1717:	8b 45 f4             	mov    -0xc(%ebp),%eax
    171a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1720:	8b 55 08             	mov    0x8(%ebp),%edx
    1723:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1726:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1729:	83 c0 08             	add    $0x8,%eax
    172c:	89 04 24             	mov    %eax,(%esp)
    172f:	e8 ce fe ff ff       	call   1602 <free>
  return freep;
    1734:	a1 98 2a 00 00       	mov    0x2a98,%eax
}
    1739:	c9                   	leave  
    173a:	c3                   	ret    

0000173b <malloc>:

void*
malloc(uint nbytes)
{
    173b:	55                   	push   %ebp
    173c:	89 e5                	mov    %esp,%ebp
    173e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1741:	8b 45 08             	mov    0x8(%ebp),%eax
    1744:	83 c0 07             	add    $0x7,%eax
    1747:	c1 e8 03             	shr    $0x3,%eax
    174a:	83 c0 01             	add    $0x1,%eax
    174d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1750:	a1 98 2a 00 00       	mov    0x2a98,%eax
    1755:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1758:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    175c:	75 23                	jne    1781 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    175e:	c7 45 f0 90 2a 00 00 	movl   $0x2a90,-0x10(%ebp)
    1765:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1768:	a3 98 2a 00 00       	mov    %eax,0x2a98
    176d:	a1 98 2a 00 00       	mov    0x2a98,%eax
    1772:	a3 90 2a 00 00       	mov    %eax,0x2a90
    base.s.size = 0;
    1777:	c7 05 94 2a 00 00 00 	movl   $0x0,0x2a94
    177e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1781:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1784:	8b 00                	mov    (%eax),%eax
    1786:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1789:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178c:	8b 40 04             	mov    0x4(%eax),%eax
    178f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1792:	72 4d                	jb     17e1 <malloc+0xa6>
      if(p->s.size == nunits)
    1794:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1797:	8b 40 04             	mov    0x4(%eax),%eax
    179a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    179d:	75 0c                	jne    17ab <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a2:	8b 10                	mov    (%eax),%edx
    17a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a7:	89 10                	mov    %edx,(%eax)
    17a9:	eb 26                	jmp    17d1 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ae:	8b 40 04             	mov    0x4(%eax),%eax
    17b1:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17b4:	89 c2                	mov    %eax,%edx
    17b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	8b 40 04             	mov    0x4(%eax),%eax
    17c2:	c1 e0 03             	shl    $0x3,%eax
    17c5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17ce:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17d4:	a3 98 2a 00 00       	mov    %eax,0x2a98
      return (void*)(p + 1);
    17d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17dc:	83 c0 08             	add    $0x8,%eax
    17df:	eb 38                	jmp    1819 <malloc+0xde>
    }
    if(p == freep)
    17e1:	a1 98 2a 00 00       	mov    0x2a98,%eax
    17e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17e9:	75 1b                	jne    1806 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    17eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    17ee:	89 04 24             	mov    %eax,(%esp)
    17f1:	e8 ed fe ff ff       	call   16e3 <morecore>
    17f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17fd:	75 07                	jne    1806 <malloc+0xcb>
        return 0;
    17ff:	b8 00 00 00 00       	mov    $0x0,%eax
    1804:	eb 13                	jmp    1819 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1806:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1809:	89 45 f0             	mov    %eax,-0x10(%ebp)
    180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180f:	8b 00                	mov    (%eax),%eax
    1811:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1814:	e9 70 ff ff ff       	jmp    1789 <malloc+0x4e>
}
    1819:	c9                   	leave  
    181a:	c3                   	ret    
