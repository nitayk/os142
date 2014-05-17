
_echo:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 e4 f0             	and    $0xfffffff0,%esp
    1006:	83 ec 20             	sub    $0x20,%esp
  int i;

  for(i = 1; i < argc; i++)
    1009:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
    1010:	00 
    1011:	eb 4b                	jmp    105e <main+0x5e>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    1013:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1017:	83 c0 01             	add    $0x1,%eax
    101a:	3b 45 08             	cmp    0x8(%ebp),%eax
    101d:	7d 07                	jge    1026 <main+0x26>
    101f:	b8 20 18 00 00       	mov    $0x1820,%eax
    1024:	eb 05                	jmp    102b <main+0x2b>
    1026:	b8 22 18 00 00       	mov    $0x1822,%eax
    102b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
    102f:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
    1036:	8b 55 0c             	mov    0xc(%ebp),%edx
    1039:	01 ca                	add    %ecx,%edx
    103b:	8b 12                	mov    (%edx),%edx
    103d:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1041:	89 54 24 08          	mov    %edx,0x8(%esp)
    1045:	c7 44 24 04 24 18 00 	movl   $0x1824,0x4(%esp)
    104c:	00 
    104d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1054:	e8 fb 03 00 00       	call   1454 <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
    1059:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
    105e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1062:	3b 45 08             	cmp    0x8(%ebp),%eax
    1065:	7c ac                	jl     1013 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
    1067:	e8 68 02 00 00       	call   12d4 <exit>

0000106c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    106c:	55                   	push   %ebp
    106d:	89 e5                	mov    %esp,%ebp
    106f:	57                   	push   %edi
    1070:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1071:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1074:	8b 55 10             	mov    0x10(%ebp),%edx
    1077:	8b 45 0c             	mov    0xc(%ebp),%eax
    107a:	89 cb                	mov    %ecx,%ebx
    107c:	89 df                	mov    %ebx,%edi
    107e:	89 d1                	mov    %edx,%ecx
    1080:	fc                   	cld    
    1081:	f3 aa                	rep stos %al,%es:(%edi)
    1083:	89 ca                	mov    %ecx,%edx
    1085:	89 fb                	mov    %edi,%ebx
    1087:	89 5d 08             	mov    %ebx,0x8(%ebp)
    108a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    108d:	5b                   	pop    %ebx
    108e:	5f                   	pop    %edi
    108f:	5d                   	pop    %ebp
    1090:	c3                   	ret    

00001091 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1091:	55                   	push   %ebp
    1092:	89 e5                	mov    %esp,%ebp
    1094:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1097:	8b 45 08             	mov    0x8(%ebp),%eax
    109a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    109d:	90                   	nop
    109e:	8b 45 08             	mov    0x8(%ebp),%eax
    10a1:	8d 50 01             	lea    0x1(%eax),%edx
    10a4:	89 55 08             	mov    %edx,0x8(%ebp)
    10a7:	8b 55 0c             	mov    0xc(%ebp),%edx
    10aa:	8d 4a 01             	lea    0x1(%edx),%ecx
    10ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10b0:	0f b6 12             	movzbl (%edx),%edx
    10b3:	88 10                	mov    %dl,(%eax)
    10b5:	0f b6 00             	movzbl (%eax),%eax
    10b8:	84 c0                	test   %al,%al
    10ba:	75 e2                	jne    109e <strcpy+0xd>
    ;
  return os;
    10bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10bf:	c9                   	leave  
    10c0:	c3                   	ret    

000010c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10c1:	55                   	push   %ebp
    10c2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10c4:	eb 08                	jmp    10ce <strcmp+0xd>
    p++, q++;
    10c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10ca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10ce:	8b 45 08             	mov    0x8(%ebp),%eax
    10d1:	0f b6 00             	movzbl (%eax),%eax
    10d4:	84 c0                	test   %al,%al
    10d6:	74 10                	je     10e8 <strcmp+0x27>
    10d8:	8b 45 08             	mov    0x8(%ebp),%eax
    10db:	0f b6 10             	movzbl (%eax),%edx
    10de:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e1:	0f b6 00             	movzbl (%eax),%eax
    10e4:	38 c2                	cmp    %al,%dl
    10e6:	74 de                	je     10c6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10e8:	8b 45 08             	mov    0x8(%ebp),%eax
    10eb:	0f b6 00             	movzbl (%eax),%eax
    10ee:	0f b6 d0             	movzbl %al,%edx
    10f1:	8b 45 0c             	mov    0xc(%ebp),%eax
    10f4:	0f b6 00             	movzbl (%eax),%eax
    10f7:	0f b6 c0             	movzbl %al,%eax
    10fa:	29 c2                	sub    %eax,%edx
    10fc:	89 d0                	mov    %edx,%eax
}
    10fe:	5d                   	pop    %ebp
    10ff:	c3                   	ret    

00001100 <strlen>:

uint
strlen(char *s)
{
    1100:	55                   	push   %ebp
    1101:	89 e5                	mov    %esp,%ebp
    1103:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1106:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    110d:	eb 04                	jmp    1113 <strlen+0x13>
    110f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1113:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1116:	8b 45 08             	mov    0x8(%ebp),%eax
    1119:	01 d0                	add    %edx,%eax
    111b:	0f b6 00             	movzbl (%eax),%eax
    111e:	84 c0                	test   %al,%al
    1120:	75 ed                	jne    110f <strlen+0xf>
    ;
  return n;
    1122:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1125:	c9                   	leave  
    1126:	c3                   	ret    

00001127 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1127:	55                   	push   %ebp
    1128:	89 e5                	mov    %esp,%ebp
    112a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    112d:	8b 45 10             	mov    0x10(%ebp),%eax
    1130:	89 44 24 08          	mov    %eax,0x8(%esp)
    1134:	8b 45 0c             	mov    0xc(%ebp),%eax
    1137:	89 44 24 04          	mov    %eax,0x4(%esp)
    113b:	8b 45 08             	mov    0x8(%ebp),%eax
    113e:	89 04 24             	mov    %eax,(%esp)
    1141:	e8 26 ff ff ff       	call   106c <stosb>
  return dst;
    1146:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1149:	c9                   	leave  
    114a:	c3                   	ret    

0000114b <strchr>:

char*
strchr(const char *s, char c)
{
    114b:	55                   	push   %ebp
    114c:	89 e5                	mov    %esp,%ebp
    114e:	83 ec 04             	sub    $0x4,%esp
    1151:	8b 45 0c             	mov    0xc(%ebp),%eax
    1154:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1157:	eb 14                	jmp    116d <strchr+0x22>
    if(*s == c)
    1159:	8b 45 08             	mov    0x8(%ebp),%eax
    115c:	0f b6 00             	movzbl (%eax),%eax
    115f:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1162:	75 05                	jne    1169 <strchr+0x1e>
      return (char*)s;
    1164:	8b 45 08             	mov    0x8(%ebp),%eax
    1167:	eb 13                	jmp    117c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    116d:	8b 45 08             	mov    0x8(%ebp),%eax
    1170:	0f b6 00             	movzbl (%eax),%eax
    1173:	84 c0                	test   %al,%al
    1175:	75 e2                	jne    1159 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1177:	b8 00 00 00 00       	mov    $0x0,%eax
}
    117c:	c9                   	leave  
    117d:	c3                   	ret    

0000117e <gets>:

char*
gets(char *buf, int max)
{
    117e:	55                   	push   %ebp
    117f:	89 e5                	mov    %esp,%ebp
    1181:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    118b:	eb 4c                	jmp    11d9 <gets+0x5b>
    cc = read(0, &c, 1);
    118d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1194:	00 
    1195:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1198:	89 44 24 04          	mov    %eax,0x4(%esp)
    119c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    11a3:	e8 44 01 00 00       	call   12ec <read>
    11a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11af:	7f 02                	jg     11b3 <gets+0x35>
      break;
    11b1:	eb 31                	jmp    11e4 <gets+0x66>
    buf[i++] = c;
    11b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11b6:	8d 50 01             	lea    0x1(%eax),%edx
    11b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11bc:	89 c2                	mov    %eax,%edx
    11be:	8b 45 08             	mov    0x8(%ebp),%eax
    11c1:	01 c2                	add    %eax,%edx
    11c3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11cd:	3c 0a                	cmp    $0xa,%al
    11cf:	74 13                	je     11e4 <gets+0x66>
    11d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d5:	3c 0d                	cmp    $0xd,%al
    11d7:	74 0b                	je     11e4 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11dc:	83 c0 01             	add    $0x1,%eax
    11df:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11e2:	7c a9                	jl     118d <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11e7:	8b 45 08             	mov    0x8(%ebp),%eax
    11ea:	01 d0                	add    %edx,%eax
    11ec:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11f2:	c9                   	leave  
    11f3:	c3                   	ret    

000011f4 <stat>:

int
stat(char *n, struct stat *st)
{
    11f4:	55                   	push   %ebp
    11f5:	89 e5                	mov    %esp,%ebp
    11f7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1201:	00 
    1202:	8b 45 08             	mov    0x8(%ebp),%eax
    1205:	89 04 24             	mov    %eax,(%esp)
    1208:	e8 07 01 00 00       	call   1314 <open>
    120d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1210:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1214:	79 07                	jns    121d <stat+0x29>
    return -1;
    1216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    121b:	eb 23                	jmp    1240 <stat+0x4c>
  r = fstat(fd, st);
    121d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1220:	89 44 24 04          	mov    %eax,0x4(%esp)
    1224:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1227:	89 04 24             	mov    %eax,(%esp)
    122a:	e8 fd 00 00 00       	call   132c <fstat>
    122f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1232:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1235:	89 04 24             	mov    %eax,(%esp)
    1238:	e8 bf 00 00 00       	call   12fc <close>
  return r;
    123d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1240:	c9                   	leave  
    1241:	c3                   	ret    

00001242 <atoi>:

int
atoi(const char *s)
{
    1242:	55                   	push   %ebp
    1243:	89 e5                	mov    %esp,%ebp
    1245:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1248:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    124f:	eb 25                	jmp    1276 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1251:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1254:	89 d0                	mov    %edx,%eax
    1256:	c1 e0 02             	shl    $0x2,%eax
    1259:	01 d0                	add    %edx,%eax
    125b:	01 c0                	add    %eax,%eax
    125d:	89 c1                	mov    %eax,%ecx
    125f:	8b 45 08             	mov    0x8(%ebp),%eax
    1262:	8d 50 01             	lea    0x1(%eax),%edx
    1265:	89 55 08             	mov    %edx,0x8(%ebp)
    1268:	0f b6 00             	movzbl (%eax),%eax
    126b:	0f be c0             	movsbl %al,%eax
    126e:	01 c8                	add    %ecx,%eax
    1270:	83 e8 30             	sub    $0x30,%eax
    1273:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1276:	8b 45 08             	mov    0x8(%ebp),%eax
    1279:	0f b6 00             	movzbl (%eax),%eax
    127c:	3c 2f                	cmp    $0x2f,%al
    127e:	7e 0a                	jle    128a <atoi+0x48>
    1280:	8b 45 08             	mov    0x8(%ebp),%eax
    1283:	0f b6 00             	movzbl (%eax),%eax
    1286:	3c 39                	cmp    $0x39,%al
    1288:	7e c7                	jle    1251 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    128a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    128d:	c9                   	leave  
    128e:	c3                   	ret    

0000128f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    128f:	55                   	push   %ebp
    1290:	89 e5                	mov    %esp,%ebp
    1292:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1295:	8b 45 08             	mov    0x8(%ebp),%eax
    1298:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    129b:	8b 45 0c             	mov    0xc(%ebp),%eax
    129e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    12a1:	eb 17                	jmp    12ba <memmove+0x2b>
    *dst++ = *src++;
    12a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a6:	8d 50 01             	lea    0x1(%eax),%edx
    12a9:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12af:	8d 4a 01             	lea    0x1(%edx),%ecx
    12b2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12b5:	0f b6 12             	movzbl (%edx),%edx
    12b8:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12ba:	8b 45 10             	mov    0x10(%ebp),%eax
    12bd:	8d 50 ff             	lea    -0x1(%eax),%edx
    12c0:	89 55 10             	mov    %edx,0x10(%ebp)
    12c3:	85 c0                	test   %eax,%eax
    12c5:	7f dc                	jg     12a3 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12ca:	c9                   	leave  
    12cb:	c3                   	ret    

000012cc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12cc:	b8 01 00 00 00       	mov    $0x1,%eax
    12d1:	cd 40                	int    $0x40
    12d3:	c3                   	ret    

000012d4 <exit>:
SYSCALL(exit)
    12d4:	b8 02 00 00 00       	mov    $0x2,%eax
    12d9:	cd 40                	int    $0x40
    12db:	c3                   	ret    

000012dc <wait>:
SYSCALL(wait)
    12dc:	b8 03 00 00 00       	mov    $0x3,%eax
    12e1:	cd 40                	int    $0x40
    12e3:	c3                   	ret    

000012e4 <pipe>:
SYSCALL(pipe)
    12e4:	b8 04 00 00 00       	mov    $0x4,%eax
    12e9:	cd 40                	int    $0x40
    12eb:	c3                   	ret    

000012ec <read>:
SYSCALL(read)
    12ec:	b8 05 00 00 00       	mov    $0x5,%eax
    12f1:	cd 40                	int    $0x40
    12f3:	c3                   	ret    

000012f4 <write>:
SYSCALL(write)
    12f4:	b8 10 00 00 00       	mov    $0x10,%eax
    12f9:	cd 40                	int    $0x40
    12fb:	c3                   	ret    

000012fc <close>:
SYSCALL(close)
    12fc:	b8 15 00 00 00       	mov    $0x15,%eax
    1301:	cd 40                	int    $0x40
    1303:	c3                   	ret    

00001304 <kill>:
SYSCALL(kill)
    1304:	b8 06 00 00 00       	mov    $0x6,%eax
    1309:	cd 40                	int    $0x40
    130b:	c3                   	ret    

0000130c <exec>:
SYSCALL(exec)
    130c:	b8 07 00 00 00       	mov    $0x7,%eax
    1311:	cd 40                	int    $0x40
    1313:	c3                   	ret    

00001314 <open>:
SYSCALL(open)
    1314:	b8 0f 00 00 00       	mov    $0xf,%eax
    1319:	cd 40                	int    $0x40
    131b:	c3                   	ret    

0000131c <mknod>:
SYSCALL(mknod)
    131c:	b8 11 00 00 00       	mov    $0x11,%eax
    1321:	cd 40                	int    $0x40
    1323:	c3                   	ret    

00001324 <unlink>:
SYSCALL(unlink)
    1324:	b8 12 00 00 00       	mov    $0x12,%eax
    1329:	cd 40                	int    $0x40
    132b:	c3                   	ret    

0000132c <fstat>:
SYSCALL(fstat)
    132c:	b8 08 00 00 00       	mov    $0x8,%eax
    1331:	cd 40                	int    $0x40
    1333:	c3                   	ret    

00001334 <link>:
SYSCALL(link)
    1334:	b8 13 00 00 00       	mov    $0x13,%eax
    1339:	cd 40                	int    $0x40
    133b:	c3                   	ret    

0000133c <mkdir>:
SYSCALL(mkdir)
    133c:	b8 14 00 00 00       	mov    $0x14,%eax
    1341:	cd 40                	int    $0x40
    1343:	c3                   	ret    

00001344 <chdir>:
SYSCALL(chdir)
    1344:	b8 09 00 00 00       	mov    $0x9,%eax
    1349:	cd 40                	int    $0x40
    134b:	c3                   	ret    

0000134c <dup>:
SYSCALL(dup)
    134c:	b8 0a 00 00 00       	mov    $0xa,%eax
    1351:	cd 40                	int    $0x40
    1353:	c3                   	ret    

00001354 <getpid>:
SYSCALL(getpid)
    1354:	b8 0b 00 00 00       	mov    $0xb,%eax
    1359:	cd 40                	int    $0x40
    135b:	c3                   	ret    

0000135c <sbrk>:
SYSCALL(sbrk)
    135c:	b8 0c 00 00 00       	mov    $0xc,%eax
    1361:	cd 40                	int    $0x40
    1363:	c3                   	ret    

00001364 <sleep>:
SYSCALL(sleep)
    1364:	b8 0d 00 00 00       	mov    $0xd,%eax
    1369:	cd 40                	int    $0x40
    136b:	c3                   	ret    

0000136c <uptime>:
SYSCALL(uptime)
    136c:	b8 0e 00 00 00       	mov    $0xe,%eax
    1371:	cd 40                	int    $0x40
    1373:	c3                   	ret    

00001374 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1374:	55                   	push   %ebp
    1375:	89 e5                	mov    %esp,%ebp
    1377:	83 ec 18             	sub    $0x18,%esp
    137a:	8b 45 0c             	mov    0xc(%ebp),%eax
    137d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1380:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1387:	00 
    1388:	8d 45 f4             	lea    -0xc(%ebp),%eax
    138b:	89 44 24 04          	mov    %eax,0x4(%esp)
    138f:	8b 45 08             	mov    0x8(%ebp),%eax
    1392:	89 04 24             	mov    %eax,(%esp)
    1395:	e8 5a ff ff ff       	call   12f4 <write>
}
    139a:	c9                   	leave  
    139b:	c3                   	ret    

0000139c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    139c:	55                   	push   %ebp
    139d:	89 e5                	mov    %esp,%ebp
    139f:	56                   	push   %esi
    13a0:	53                   	push   %ebx
    13a1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13ab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13af:	74 17                	je     13c8 <printint+0x2c>
    13b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13b5:	79 11                	jns    13c8 <printint+0x2c>
    neg = 1;
    13b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13be:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c1:	f7 d8                	neg    %eax
    13c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c6:	eb 06                	jmp    13ce <printint+0x32>
  } else {
    x = xx;
    13c8:	8b 45 0c             	mov    0xc(%ebp),%eax
    13cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13d5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13d8:	8d 41 01             	lea    0x1(%ecx),%eax
    13db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13de:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13e4:	ba 00 00 00 00       	mov    $0x0,%edx
    13e9:	f7 f3                	div    %ebx
    13eb:	89 d0                	mov    %edx,%eax
    13ed:	0f b6 80 74 1a 00 00 	movzbl 0x1a74(%eax),%eax
    13f4:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13f8:	8b 75 10             	mov    0x10(%ebp),%esi
    13fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13fe:	ba 00 00 00 00       	mov    $0x0,%edx
    1403:	f7 f6                	div    %esi
    1405:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1408:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    140c:	75 c7                	jne    13d5 <printint+0x39>
  if(neg)
    140e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1412:	74 10                	je     1424 <printint+0x88>
    buf[i++] = '-';
    1414:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1417:	8d 50 01             	lea    0x1(%eax),%edx
    141a:	89 55 f4             	mov    %edx,-0xc(%ebp)
    141d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1422:	eb 1f                	jmp    1443 <printint+0xa7>
    1424:	eb 1d                	jmp    1443 <printint+0xa7>
    putc(fd, buf[i]);
    1426:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1429:	8b 45 f4             	mov    -0xc(%ebp),%eax
    142c:	01 d0                	add    %edx,%eax
    142e:	0f b6 00             	movzbl (%eax),%eax
    1431:	0f be c0             	movsbl %al,%eax
    1434:	89 44 24 04          	mov    %eax,0x4(%esp)
    1438:	8b 45 08             	mov    0x8(%ebp),%eax
    143b:	89 04 24             	mov    %eax,(%esp)
    143e:	e8 31 ff ff ff       	call   1374 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1443:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1447:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    144b:	79 d9                	jns    1426 <printint+0x8a>
    putc(fd, buf[i]);
}
    144d:	83 c4 30             	add    $0x30,%esp
    1450:	5b                   	pop    %ebx
    1451:	5e                   	pop    %esi
    1452:	5d                   	pop    %ebp
    1453:	c3                   	ret    

00001454 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1454:	55                   	push   %ebp
    1455:	89 e5                	mov    %esp,%ebp
    1457:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    145a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1461:	8d 45 0c             	lea    0xc(%ebp),%eax
    1464:	83 c0 04             	add    $0x4,%eax
    1467:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    146a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1471:	e9 7c 01 00 00       	jmp    15f2 <printf+0x19e>
    c = fmt[i] & 0xff;
    1476:	8b 55 0c             	mov    0xc(%ebp),%edx
    1479:	8b 45 f0             	mov    -0x10(%ebp),%eax
    147c:	01 d0                	add    %edx,%eax
    147e:	0f b6 00             	movzbl (%eax),%eax
    1481:	0f be c0             	movsbl %al,%eax
    1484:	25 ff 00 00 00       	and    $0xff,%eax
    1489:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    148c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1490:	75 2c                	jne    14be <printf+0x6a>
      if(c == '%'){
    1492:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1496:	75 0c                	jne    14a4 <printf+0x50>
        state = '%';
    1498:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    149f:	e9 4a 01 00 00       	jmp    15ee <printf+0x19a>
      } else {
        putc(fd, c);
    14a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14a7:	0f be c0             	movsbl %al,%eax
    14aa:	89 44 24 04          	mov    %eax,0x4(%esp)
    14ae:	8b 45 08             	mov    0x8(%ebp),%eax
    14b1:	89 04 24             	mov    %eax,(%esp)
    14b4:	e8 bb fe ff ff       	call   1374 <putc>
    14b9:	e9 30 01 00 00       	jmp    15ee <printf+0x19a>
      }
    } else if(state == '%'){
    14be:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14c2:	0f 85 26 01 00 00    	jne    15ee <printf+0x19a>
      if(c == 'd'){
    14c8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14cc:	75 2d                	jne    14fb <printf+0xa7>
        printint(fd, *ap, 10, 1);
    14ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14d1:	8b 00                	mov    (%eax),%eax
    14d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    14da:	00 
    14db:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    14e2:	00 
    14e3:	89 44 24 04          	mov    %eax,0x4(%esp)
    14e7:	8b 45 08             	mov    0x8(%ebp),%eax
    14ea:	89 04 24             	mov    %eax,(%esp)
    14ed:	e8 aa fe ff ff       	call   139c <printint>
        ap++;
    14f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14f6:	e9 ec 00 00 00       	jmp    15e7 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    14fb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14ff:	74 06                	je     1507 <printf+0xb3>
    1501:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1505:	75 2d                	jne    1534 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    1507:	8b 45 e8             	mov    -0x18(%ebp),%eax
    150a:	8b 00                	mov    (%eax),%eax
    150c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1513:	00 
    1514:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    151b:	00 
    151c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1520:	8b 45 08             	mov    0x8(%ebp),%eax
    1523:	89 04 24             	mov    %eax,(%esp)
    1526:	e8 71 fe ff ff       	call   139c <printint>
        ap++;
    152b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    152f:	e9 b3 00 00 00       	jmp    15e7 <printf+0x193>
      } else if(c == 's'){
    1534:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1538:	75 45                	jne    157f <printf+0x12b>
        s = (char*)*ap;
    153a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    153d:	8b 00                	mov    (%eax),%eax
    153f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1542:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    154a:	75 09                	jne    1555 <printf+0x101>
          s = "(null)";
    154c:	c7 45 f4 29 18 00 00 	movl   $0x1829,-0xc(%ebp)
        while(*s != 0){
    1553:	eb 1e                	jmp    1573 <printf+0x11f>
    1555:	eb 1c                	jmp    1573 <printf+0x11f>
          putc(fd, *s);
    1557:	8b 45 f4             	mov    -0xc(%ebp),%eax
    155a:	0f b6 00             	movzbl (%eax),%eax
    155d:	0f be c0             	movsbl %al,%eax
    1560:	89 44 24 04          	mov    %eax,0x4(%esp)
    1564:	8b 45 08             	mov    0x8(%ebp),%eax
    1567:	89 04 24             	mov    %eax,(%esp)
    156a:	e8 05 fe ff ff       	call   1374 <putc>
          s++;
    156f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1573:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1576:	0f b6 00             	movzbl (%eax),%eax
    1579:	84 c0                	test   %al,%al
    157b:	75 da                	jne    1557 <printf+0x103>
    157d:	eb 68                	jmp    15e7 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    157f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1583:	75 1d                	jne    15a2 <printf+0x14e>
        putc(fd, *ap);
    1585:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1588:	8b 00                	mov    (%eax),%eax
    158a:	0f be c0             	movsbl %al,%eax
    158d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1591:	8b 45 08             	mov    0x8(%ebp),%eax
    1594:	89 04 24             	mov    %eax,(%esp)
    1597:	e8 d8 fd ff ff       	call   1374 <putc>
        ap++;
    159c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15a0:	eb 45                	jmp    15e7 <printf+0x193>
      } else if(c == '%'){
    15a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15a6:	75 17                	jne    15bf <printf+0x16b>
        putc(fd, c);
    15a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15ab:	0f be c0             	movsbl %al,%eax
    15ae:	89 44 24 04          	mov    %eax,0x4(%esp)
    15b2:	8b 45 08             	mov    0x8(%ebp),%eax
    15b5:	89 04 24             	mov    %eax,(%esp)
    15b8:	e8 b7 fd ff ff       	call   1374 <putc>
    15bd:	eb 28                	jmp    15e7 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15bf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    15c6:	00 
    15c7:	8b 45 08             	mov    0x8(%ebp),%eax
    15ca:	89 04 24             	mov    %eax,(%esp)
    15cd:	e8 a2 fd ff ff       	call   1374 <putc>
        putc(fd, c);
    15d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15d5:	0f be c0             	movsbl %al,%eax
    15d8:	89 44 24 04          	mov    %eax,0x4(%esp)
    15dc:	8b 45 08             	mov    0x8(%ebp),%eax
    15df:	89 04 24             	mov    %eax,(%esp)
    15e2:	e8 8d fd ff ff       	call   1374 <putc>
      }
      state = 0;
    15e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15f2:	8b 55 0c             	mov    0xc(%ebp),%edx
    15f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f8:	01 d0                	add    %edx,%eax
    15fa:	0f b6 00             	movzbl (%eax),%eax
    15fd:	84 c0                	test   %al,%al
    15ff:	0f 85 71 fe ff ff    	jne    1476 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1605:	c9                   	leave  
    1606:	c3                   	ret    

00001607 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1607:	55                   	push   %ebp
    1608:	89 e5                	mov    %esp,%ebp
    160a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    160d:	8b 45 08             	mov    0x8(%ebp),%eax
    1610:	83 e8 08             	sub    $0x8,%eax
    1613:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1616:	a1 90 1a 00 00       	mov    0x1a90,%eax
    161b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    161e:	eb 24                	jmp    1644 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1620:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1623:	8b 00                	mov    (%eax),%eax
    1625:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1628:	77 12                	ja     163c <free+0x35>
    162a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    162d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1630:	77 24                	ja     1656 <free+0x4f>
    1632:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1635:	8b 00                	mov    (%eax),%eax
    1637:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    163a:	77 1a                	ja     1656 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    163c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163f:	8b 00                	mov    (%eax),%eax
    1641:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1644:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1647:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    164a:	76 d4                	jbe    1620 <free+0x19>
    164c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164f:	8b 00                	mov    (%eax),%eax
    1651:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1654:	76 ca                	jbe    1620 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1656:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1659:	8b 40 04             	mov    0x4(%eax),%eax
    165c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1663:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1666:	01 c2                	add    %eax,%edx
    1668:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166b:	8b 00                	mov    (%eax),%eax
    166d:	39 c2                	cmp    %eax,%edx
    166f:	75 24                	jne    1695 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1671:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1674:	8b 50 04             	mov    0x4(%eax),%edx
    1677:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167a:	8b 00                	mov    (%eax),%eax
    167c:	8b 40 04             	mov    0x4(%eax),%eax
    167f:	01 c2                	add    %eax,%edx
    1681:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1684:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1687:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168a:	8b 00                	mov    (%eax),%eax
    168c:	8b 10                	mov    (%eax),%edx
    168e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1691:	89 10                	mov    %edx,(%eax)
    1693:	eb 0a                	jmp    169f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1695:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1698:	8b 10                	mov    (%eax),%edx
    169a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    169d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    169f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a2:	8b 40 04             	mov    0x4(%eax),%eax
    16a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16af:	01 d0                	add    %edx,%eax
    16b1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16b4:	75 20                	jne    16d6 <free+0xcf>
    p->s.size += bp->s.size;
    16b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b9:	8b 50 04             	mov    0x4(%eax),%edx
    16bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16bf:	8b 40 04             	mov    0x4(%eax),%eax
    16c2:	01 c2                	add    %eax,%edx
    16c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16cd:	8b 10                	mov    (%eax),%edx
    16cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d2:	89 10                	mov    %edx,(%eax)
    16d4:	eb 08                	jmp    16de <free+0xd7>
  } else
    p->s.ptr = bp;
    16d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d9:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16dc:	89 10                	mov    %edx,(%eax)
  freep = p;
    16de:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e1:	a3 90 1a 00 00       	mov    %eax,0x1a90
}
    16e6:	c9                   	leave  
    16e7:	c3                   	ret    

000016e8 <morecore>:

static Header*
morecore(uint nu)
{
    16e8:	55                   	push   %ebp
    16e9:	89 e5                	mov    %esp,%ebp
    16eb:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16ee:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16f5:	77 07                	ja     16fe <morecore+0x16>
    nu = 4096;
    16f7:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1701:	c1 e0 03             	shl    $0x3,%eax
    1704:	89 04 24             	mov    %eax,(%esp)
    1707:	e8 50 fc ff ff       	call   135c <sbrk>
    170c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    170f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1713:	75 07                	jne    171c <morecore+0x34>
    return 0;
    1715:	b8 00 00 00 00       	mov    $0x0,%eax
    171a:	eb 22                	jmp    173e <morecore+0x56>
  hp = (Header*)p;
    171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    171f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1722:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1725:	8b 55 08             	mov    0x8(%ebp),%edx
    1728:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    172e:	83 c0 08             	add    $0x8,%eax
    1731:	89 04 24             	mov    %eax,(%esp)
    1734:	e8 ce fe ff ff       	call   1607 <free>
  return freep;
    1739:	a1 90 1a 00 00       	mov    0x1a90,%eax
}
    173e:	c9                   	leave  
    173f:	c3                   	ret    

00001740 <malloc>:

void*
malloc(uint nbytes)
{
    1740:	55                   	push   %ebp
    1741:	89 e5                	mov    %esp,%ebp
    1743:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1746:	8b 45 08             	mov    0x8(%ebp),%eax
    1749:	83 c0 07             	add    $0x7,%eax
    174c:	c1 e8 03             	shr    $0x3,%eax
    174f:	83 c0 01             	add    $0x1,%eax
    1752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1755:	a1 90 1a 00 00       	mov    0x1a90,%eax
    175a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    175d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1761:	75 23                	jne    1786 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1763:	c7 45 f0 88 1a 00 00 	movl   $0x1a88,-0x10(%ebp)
    176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    176d:	a3 90 1a 00 00       	mov    %eax,0x1a90
    1772:	a1 90 1a 00 00       	mov    0x1a90,%eax
    1777:	a3 88 1a 00 00       	mov    %eax,0x1a88
    base.s.size = 0;
    177c:	c7 05 8c 1a 00 00 00 	movl   $0x0,0x1a8c
    1783:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1786:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1789:	8b 00                	mov    (%eax),%eax
    178b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1791:	8b 40 04             	mov    0x4(%eax),%eax
    1794:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1797:	72 4d                	jb     17e6 <malloc+0xa6>
      if(p->s.size == nunits)
    1799:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179c:	8b 40 04             	mov    0x4(%eax),%eax
    179f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17a2:	75 0c                	jne    17b0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a7:	8b 10                	mov    (%eax),%edx
    17a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ac:	89 10                	mov    %edx,(%eax)
    17ae:	eb 26                	jmp    17d6 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b3:	8b 40 04             	mov    0x4(%eax),%eax
    17b6:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17b9:	89 c2                	mov    %eax,%edx
    17bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17be:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c4:	8b 40 04             	mov    0x4(%eax),%eax
    17c7:	c1 e0 03             	shl    $0x3,%eax
    17ca:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17d3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17d9:	a3 90 1a 00 00       	mov    %eax,0x1a90
      return (void*)(p + 1);
    17de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e1:	83 c0 08             	add    $0x8,%eax
    17e4:	eb 38                	jmp    181e <malloc+0xde>
    }
    if(p == freep)
    17e6:	a1 90 1a 00 00       	mov    0x1a90,%eax
    17eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17ee:	75 1b                	jne    180b <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    17f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    17f3:	89 04 24             	mov    %eax,(%esp)
    17f6:	e8 ed fe ff ff       	call   16e8 <morecore>
    17fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1802:	75 07                	jne    180b <malloc+0xcb>
        return 0;
    1804:	b8 00 00 00 00       	mov    $0x0,%eax
    1809:	eb 13                	jmp    181e <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1811:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1814:	8b 00                	mov    (%eax),%eax
    1816:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1819:	e9 70 ff ff ff       	jmp    178e <malloc+0x4e>
}
    181e:	c9                   	leave  
    181f:	c3                   	ret    
