
_zombie:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 e4 f0             	and    $0xfffffff0,%esp
    1006:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
    1009:	e8 75 02 00 00       	call   1283 <fork>
    100e:	85 c0                	test   %eax,%eax
    1010:	7e 0c                	jle    101e <main+0x1e>
    sleep(5);  // Let child exit before parent.
    1012:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
    1019:	e8 fd 02 00 00       	call   131b <sleep>
  exit();
    101e:	e8 68 02 00 00       	call   128b <exit>

00001023 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1023:	55                   	push   %ebp
    1024:	89 e5                	mov    %esp,%ebp
    1026:	57                   	push   %edi
    1027:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1028:	8b 4d 08             	mov    0x8(%ebp),%ecx
    102b:	8b 55 10             	mov    0x10(%ebp),%edx
    102e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1031:	89 cb                	mov    %ecx,%ebx
    1033:	89 df                	mov    %ebx,%edi
    1035:	89 d1                	mov    %edx,%ecx
    1037:	fc                   	cld    
    1038:	f3 aa                	rep stos %al,%es:(%edi)
    103a:	89 ca                	mov    %ecx,%edx
    103c:	89 fb                	mov    %edi,%ebx
    103e:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1041:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1044:	5b                   	pop    %ebx
    1045:	5f                   	pop    %edi
    1046:	5d                   	pop    %ebp
    1047:	c3                   	ret    

00001048 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1048:	55                   	push   %ebp
    1049:	89 e5                	mov    %esp,%ebp
    104b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    104e:	8b 45 08             	mov    0x8(%ebp),%eax
    1051:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1054:	90                   	nop
    1055:	8b 45 08             	mov    0x8(%ebp),%eax
    1058:	8d 50 01             	lea    0x1(%eax),%edx
    105b:	89 55 08             	mov    %edx,0x8(%ebp)
    105e:	8b 55 0c             	mov    0xc(%ebp),%edx
    1061:	8d 4a 01             	lea    0x1(%edx),%ecx
    1064:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1067:	0f b6 12             	movzbl (%edx),%edx
    106a:	88 10                	mov    %dl,(%eax)
    106c:	0f b6 00             	movzbl (%eax),%eax
    106f:	84 c0                	test   %al,%al
    1071:	75 e2                	jne    1055 <strcpy+0xd>
    ;
  return os;
    1073:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1076:	c9                   	leave  
    1077:	c3                   	ret    

00001078 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1078:	55                   	push   %ebp
    1079:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    107b:	eb 08                	jmp    1085 <strcmp+0xd>
    p++, q++;
    107d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1081:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1085:	8b 45 08             	mov    0x8(%ebp),%eax
    1088:	0f b6 00             	movzbl (%eax),%eax
    108b:	84 c0                	test   %al,%al
    108d:	74 10                	je     109f <strcmp+0x27>
    108f:	8b 45 08             	mov    0x8(%ebp),%eax
    1092:	0f b6 10             	movzbl (%eax),%edx
    1095:	8b 45 0c             	mov    0xc(%ebp),%eax
    1098:	0f b6 00             	movzbl (%eax),%eax
    109b:	38 c2                	cmp    %al,%dl
    109d:	74 de                	je     107d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    109f:	8b 45 08             	mov    0x8(%ebp),%eax
    10a2:	0f b6 00             	movzbl (%eax),%eax
    10a5:	0f b6 d0             	movzbl %al,%edx
    10a8:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ab:	0f b6 00             	movzbl (%eax),%eax
    10ae:	0f b6 c0             	movzbl %al,%eax
    10b1:	29 c2                	sub    %eax,%edx
    10b3:	89 d0                	mov    %edx,%eax
}
    10b5:	5d                   	pop    %ebp
    10b6:	c3                   	ret    

000010b7 <strlen>:

uint
strlen(char *s)
{
    10b7:	55                   	push   %ebp
    10b8:	89 e5                	mov    %esp,%ebp
    10ba:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10c4:	eb 04                	jmp    10ca <strlen+0x13>
    10c6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10cd:	8b 45 08             	mov    0x8(%ebp),%eax
    10d0:	01 d0                	add    %edx,%eax
    10d2:	0f b6 00             	movzbl (%eax),%eax
    10d5:	84 c0                	test   %al,%al
    10d7:	75 ed                	jne    10c6 <strlen+0xf>
    ;
  return n;
    10d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10dc:	c9                   	leave  
    10dd:	c3                   	ret    

000010de <memset>:

void*
memset(void *dst, int c, uint n)
{
    10de:	55                   	push   %ebp
    10df:	89 e5                	mov    %esp,%ebp
    10e1:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    10e4:	8b 45 10             	mov    0x10(%ebp),%eax
    10e7:	89 44 24 08          	mov    %eax,0x8(%esp)
    10eb:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    10f2:	8b 45 08             	mov    0x8(%ebp),%eax
    10f5:	89 04 24             	mov    %eax,(%esp)
    10f8:	e8 26 ff ff ff       	call   1023 <stosb>
  return dst;
    10fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1100:	c9                   	leave  
    1101:	c3                   	ret    

00001102 <strchr>:

char*
strchr(const char *s, char c)
{
    1102:	55                   	push   %ebp
    1103:	89 e5                	mov    %esp,%ebp
    1105:	83 ec 04             	sub    $0x4,%esp
    1108:	8b 45 0c             	mov    0xc(%ebp),%eax
    110b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    110e:	eb 14                	jmp    1124 <strchr+0x22>
    if(*s == c)
    1110:	8b 45 08             	mov    0x8(%ebp),%eax
    1113:	0f b6 00             	movzbl (%eax),%eax
    1116:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1119:	75 05                	jne    1120 <strchr+0x1e>
      return (char*)s;
    111b:	8b 45 08             	mov    0x8(%ebp),%eax
    111e:	eb 13                	jmp    1133 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1120:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1124:	8b 45 08             	mov    0x8(%ebp),%eax
    1127:	0f b6 00             	movzbl (%eax),%eax
    112a:	84 c0                	test   %al,%al
    112c:	75 e2                	jne    1110 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    112e:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1133:	c9                   	leave  
    1134:	c3                   	ret    

00001135 <gets>:

char*
gets(char *buf, int max)
{
    1135:	55                   	push   %ebp
    1136:	89 e5                	mov    %esp,%ebp
    1138:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    113b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1142:	eb 4c                	jmp    1190 <gets+0x5b>
    cc = read(0, &c, 1);
    1144:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    114b:	00 
    114c:	8d 45 ef             	lea    -0x11(%ebp),%eax
    114f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    115a:	e8 44 01 00 00       	call   12a3 <read>
    115f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1162:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1166:	7f 02                	jg     116a <gets+0x35>
      break;
    1168:	eb 31                	jmp    119b <gets+0x66>
    buf[i++] = c;
    116a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    116d:	8d 50 01             	lea    0x1(%eax),%edx
    1170:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1173:	89 c2                	mov    %eax,%edx
    1175:	8b 45 08             	mov    0x8(%ebp),%eax
    1178:	01 c2                	add    %eax,%edx
    117a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    117e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1180:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1184:	3c 0a                	cmp    $0xa,%al
    1186:	74 13                	je     119b <gets+0x66>
    1188:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    118c:	3c 0d                	cmp    $0xd,%al
    118e:	74 0b                	je     119b <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1190:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1193:	83 c0 01             	add    $0x1,%eax
    1196:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1199:	7c a9                	jl     1144 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    119b:	8b 55 f4             	mov    -0xc(%ebp),%edx
    119e:	8b 45 08             	mov    0x8(%ebp),%eax
    11a1:	01 d0                	add    %edx,%eax
    11a3:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11a9:	c9                   	leave  
    11aa:	c3                   	ret    

000011ab <stat>:

int
stat(char *n, struct stat *st)
{
    11ab:	55                   	push   %ebp
    11ac:	89 e5                	mov    %esp,%ebp
    11ae:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11b8:	00 
    11b9:	8b 45 08             	mov    0x8(%ebp),%eax
    11bc:	89 04 24             	mov    %eax,(%esp)
    11bf:	e8 07 01 00 00       	call   12cb <open>
    11c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11cb:	79 07                	jns    11d4 <stat+0x29>
    return -1;
    11cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11d2:	eb 23                	jmp    11f7 <stat+0x4c>
  r = fstat(fd, st);
    11d4:	8b 45 0c             	mov    0xc(%ebp),%eax
    11d7:	89 44 24 04          	mov    %eax,0x4(%esp)
    11db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11de:	89 04 24             	mov    %eax,(%esp)
    11e1:	e8 fd 00 00 00       	call   12e3 <fstat>
    11e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ec:	89 04 24             	mov    %eax,(%esp)
    11ef:	e8 bf 00 00 00       	call   12b3 <close>
  return r;
    11f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11f7:	c9                   	leave  
    11f8:	c3                   	ret    

000011f9 <atoi>:

int
atoi(const char *s)
{
    11f9:	55                   	push   %ebp
    11fa:	89 e5                	mov    %esp,%ebp
    11fc:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    11ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1206:	eb 25                	jmp    122d <atoi+0x34>
    n = n*10 + *s++ - '0';
    1208:	8b 55 fc             	mov    -0x4(%ebp),%edx
    120b:	89 d0                	mov    %edx,%eax
    120d:	c1 e0 02             	shl    $0x2,%eax
    1210:	01 d0                	add    %edx,%eax
    1212:	01 c0                	add    %eax,%eax
    1214:	89 c1                	mov    %eax,%ecx
    1216:	8b 45 08             	mov    0x8(%ebp),%eax
    1219:	8d 50 01             	lea    0x1(%eax),%edx
    121c:	89 55 08             	mov    %edx,0x8(%ebp)
    121f:	0f b6 00             	movzbl (%eax),%eax
    1222:	0f be c0             	movsbl %al,%eax
    1225:	01 c8                	add    %ecx,%eax
    1227:	83 e8 30             	sub    $0x30,%eax
    122a:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    122d:	8b 45 08             	mov    0x8(%ebp),%eax
    1230:	0f b6 00             	movzbl (%eax),%eax
    1233:	3c 2f                	cmp    $0x2f,%al
    1235:	7e 0a                	jle    1241 <atoi+0x48>
    1237:	8b 45 08             	mov    0x8(%ebp),%eax
    123a:	0f b6 00             	movzbl (%eax),%eax
    123d:	3c 39                	cmp    $0x39,%al
    123f:	7e c7                	jle    1208 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1241:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1244:	c9                   	leave  
    1245:	c3                   	ret    

00001246 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1246:	55                   	push   %ebp
    1247:	89 e5                	mov    %esp,%ebp
    1249:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    124c:	8b 45 08             	mov    0x8(%ebp),%eax
    124f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1252:	8b 45 0c             	mov    0xc(%ebp),%eax
    1255:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1258:	eb 17                	jmp    1271 <memmove+0x2b>
    *dst++ = *src++;
    125a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    125d:	8d 50 01             	lea    0x1(%eax),%edx
    1260:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1263:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1266:	8d 4a 01             	lea    0x1(%edx),%ecx
    1269:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    126c:	0f b6 12             	movzbl (%edx),%edx
    126f:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1271:	8b 45 10             	mov    0x10(%ebp),%eax
    1274:	8d 50 ff             	lea    -0x1(%eax),%edx
    1277:	89 55 10             	mov    %edx,0x10(%ebp)
    127a:	85 c0                	test   %eax,%eax
    127c:	7f dc                	jg     125a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    127e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1281:	c9                   	leave  
    1282:	c3                   	ret    

00001283 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1283:	b8 01 00 00 00       	mov    $0x1,%eax
    1288:	cd 40                	int    $0x40
    128a:	c3                   	ret    

0000128b <exit>:
SYSCALL(exit)
    128b:	b8 02 00 00 00       	mov    $0x2,%eax
    1290:	cd 40                	int    $0x40
    1292:	c3                   	ret    

00001293 <wait>:
SYSCALL(wait)
    1293:	b8 03 00 00 00       	mov    $0x3,%eax
    1298:	cd 40                	int    $0x40
    129a:	c3                   	ret    

0000129b <pipe>:
SYSCALL(pipe)
    129b:	b8 04 00 00 00       	mov    $0x4,%eax
    12a0:	cd 40                	int    $0x40
    12a2:	c3                   	ret    

000012a3 <read>:
SYSCALL(read)
    12a3:	b8 05 00 00 00       	mov    $0x5,%eax
    12a8:	cd 40                	int    $0x40
    12aa:	c3                   	ret    

000012ab <write>:
SYSCALL(write)
    12ab:	b8 10 00 00 00       	mov    $0x10,%eax
    12b0:	cd 40                	int    $0x40
    12b2:	c3                   	ret    

000012b3 <close>:
SYSCALL(close)
    12b3:	b8 15 00 00 00       	mov    $0x15,%eax
    12b8:	cd 40                	int    $0x40
    12ba:	c3                   	ret    

000012bb <kill>:
SYSCALL(kill)
    12bb:	b8 06 00 00 00       	mov    $0x6,%eax
    12c0:	cd 40                	int    $0x40
    12c2:	c3                   	ret    

000012c3 <exec>:
SYSCALL(exec)
    12c3:	b8 07 00 00 00       	mov    $0x7,%eax
    12c8:	cd 40                	int    $0x40
    12ca:	c3                   	ret    

000012cb <open>:
SYSCALL(open)
    12cb:	b8 0f 00 00 00       	mov    $0xf,%eax
    12d0:	cd 40                	int    $0x40
    12d2:	c3                   	ret    

000012d3 <mknod>:
SYSCALL(mknod)
    12d3:	b8 11 00 00 00       	mov    $0x11,%eax
    12d8:	cd 40                	int    $0x40
    12da:	c3                   	ret    

000012db <unlink>:
SYSCALL(unlink)
    12db:	b8 12 00 00 00       	mov    $0x12,%eax
    12e0:	cd 40                	int    $0x40
    12e2:	c3                   	ret    

000012e3 <fstat>:
SYSCALL(fstat)
    12e3:	b8 08 00 00 00       	mov    $0x8,%eax
    12e8:	cd 40                	int    $0x40
    12ea:	c3                   	ret    

000012eb <link>:
SYSCALL(link)
    12eb:	b8 13 00 00 00       	mov    $0x13,%eax
    12f0:	cd 40                	int    $0x40
    12f2:	c3                   	ret    

000012f3 <mkdir>:
SYSCALL(mkdir)
    12f3:	b8 14 00 00 00       	mov    $0x14,%eax
    12f8:	cd 40                	int    $0x40
    12fa:	c3                   	ret    

000012fb <chdir>:
SYSCALL(chdir)
    12fb:	b8 09 00 00 00       	mov    $0x9,%eax
    1300:	cd 40                	int    $0x40
    1302:	c3                   	ret    

00001303 <dup>:
SYSCALL(dup)
    1303:	b8 0a 00 00 00       	mov    $0xa,%eax
    1308:	cd 40                	int    $0x40
    130a:	c3                   	ret    

0000130b <getpid>:
SYSCALL(getpid)
    130b:	b8 0b 00 00 00       	mov    $0xb,%eax
    1310:	cd 40                	int    $0x40
    1312:	c3                   	ret    

00001313 <sbrk>:
SYSCALL(sbrk)
    1313:	b8 0c 00 00 00       	mov    $0xc,%eax
    1318:	cd 40                	int    $0x40
    131a:	c3                   	ret    

0000131b <sleep>:
SYSCALL(sleep)
    131b:	b8 0d 00 00 00       	mov    $0xd,%eax
    1320:	cd 40                	int    $0x40
    1322:	c3                   	ret    

00001323 <uptime>:
SYSCALL(uptime)
    1323:	b8 0e 00 00 00       	mov    $0xe,%eax
    1328:	cd 40                	int    $0x40
    132a:	c3                   	ret    

0000132b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    132b:	55                   	push   %ebp
    132c:	89 e5                	mov    %esp,%ebp
    132e:	83 ec 18             	sub    $0x18,%esp
    1331:	8b 45 0c             	mov    0xc(%ebp),%eax
    1334:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1337:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    133e:	00 
    133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1342:	89 44 24 04          	mov    %eax,0x4(%esp)
    1346:	8b 45 08             	mov    0x8(%ebp),%eax
    1349:	89 04 24             	mov    %eax,(%esp)
    134c:	e8 5a ff ff ff       	call   12ab <write>
}
    1351:	c9                   	leave  
    1352:	c3                   	ret    

00001353 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1353:	55                   	push   %ebp
    1354:	89 e5                	mov    %esp,%ebp
    1356:	56                   	push   %esi
    1357:	53                   	push   %ebx
    1358:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    135b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1362:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1366:	74 17                	je     137f <printint+0x2c>
    1368:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    136c:	79 11                	jns    137f <printint+0x2c>
    neg = 1;
    136e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1375:	8b 45 0c             	mov    0xc(%ebp),%eax
    1378:	f7 d8                	neg    %eax
    137a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    137d:	eb 06                	jmp    1385 <printint+0x32>
  } else {
    x = xx;
    137f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1382:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1385:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    138c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    138f:	8d 41 01             	lea    0x1(%ecx),%eax
    1392:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1395:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1398:	8b 45 ec             	mov    -0x14(%ebp),%eax
    139b:	ba 00 00 00 00       	mov    $0x0,%edx
    13a0:	f7 f3                	div    %ebx
    13a2:	89 d0                	mov    %edx,%eax
    13a4:	0f b6 80 24 2a 00 00 	movzbl 0x2a24(%eax),%eax
    13ab:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13af:	8b 75 10             	mov    0x10(%ebp),%esi
    13b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13b5:	ba 00 00 00 00       	mov    $0x0,%edx
    13ba:	f7 f6                	div    %esi
    13bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13c3:	75 c7                	jne    138c <printint+0x39>
  if(neg)
    13c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13c9:	74 10                	je     13db <printint+0x88>
    buf[i++] = '-';
    13cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ce:	8d 50 01             	lea    0x1(%eax),%edx
    13d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
    13d4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    13d9:	eb 1f                	jmp    13fa <printint+0xa7>
    13db:	eb 1d                	jmp    13fa <printint+0xa7>
    putc(fd, buf[i]);
    13dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
    13e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e3:	01 d0                	add    %edx,%eax
    13e5:	0f b6 00             	movzbl (%eax),%eax
    13e8:	0f be c0             	movsbl %al,%eax
    13eb:	89 44 24 04          	mov    %eax,0x4(%esp)
    13ef:	8b 45 08             	mov    0x8(%ebp),%eax
    13f2:	89 04 24             	mov    %eax,(%esp)
    13f5:	e8 31 ff ff ff       	call   132b <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    13fa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    13fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1402:	79 d9                	jns    13dd <printint+0x8a>
    putc(fd, buf[i]);
}
    1404:	83 c4 30             	add    $0x30,%esp
    1407:	5b                   	pop    %ebx
    1408:	5e                   	pop    %esi
    1409:	5d                   	pop    %ebp
    140a:	c3                   	ret    

0000140b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    140b:	55                   	push   %ebp
    140c:	89 e5                	mov    %esp,%ebp
    140e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1411:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1418:	8d 45 0c             	lea    0xc(%ebp),%eax
    141b:	83 c0 04             	add    $0x4,%eax
    141e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1421:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1428:	e9 7c 01 00 00       	jmp    15a9 <printf+0x19e>
    c = fmt[i] & 0xff;
    142d:	8b 55 0c             	mov    0xc(%ebp),%edx
    1430:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1433:	01 d0                	add    %edx,%eax
    1435:	0f b6 00             	movzbl (%eax),%eax
    1438:	0f be c0             	movsbl %al,%eax
    143b:	25 ff 00 00 00       	and    $0xff,%eax
    1440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1443:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1447:	75 2c                	jne    1475 <printf+0x6a>
      if(c == '%'){
    1449:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    144d:	75 0c                	jne    145b <printf+0x50>
        state = '%';
    144f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1456:	e9 4a 01 00 00       	jmp    15a5 <printf+0x19a>
      } else {
        putc(fd, c);
    145b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    145e:	0f be c0             	movsbl %al,%eax
    1461:	89 44 24 04          	mov    %eax,0x4(%esp)
    1465:	8b 45 08             	mov    0x8(%ebp),%eax
    1468:	89 04 24             	mov    %eax,(%esp)
    146b:	e8 bb fe ff ff       	call   132b <putc>
    1470:	e9 30 01 00 00       	jmp    15a5 <printf+0x19a>
      }
    } else if(state == '%'){
    1475:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1479:	0f 85 26 01 00 00    	jne    15a5 <printf+0x19a>
      if(c == 'd'){
    147f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1483:	75 2d                	jne    14b2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1485:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1488:	8b 00                	mov    (%eax),%eax
    148a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1491:	00 
    1492:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1499:	00 
    149a:	89 44 24 04          	mov    %eax,0x4(%esp)
    149e:	8b 45 08             	mov    0x8(%ebp),%eax
    14a1:	89 04 24             	mov    %eax,(%esp)
    14a4:	e8 aa fe ff ff       	call   1353 <printint>
        ap++;
    14a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14ad:	e9 ec 00 00 00       	jmp    159e <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    14b2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14b6:	74 06                	je     14be <printf+0xb3>
    14b8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14bc:	75 2d                	jne    14eb <printf+0xe0>
        printint(fd, *ap, 16, 0);
    14be:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14c1:	8b 00                	mov    (%eax),%eax
    14c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    14ca:	00 
    14cb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    14d2:	00 
    14d3:	89 44 24 04          	mov    %eax,0x4(%esp)
    14d7:	8b 45 08             	mov    0x8(%ebp),%eax
    14da:	89 04 24             	mov    %eax,(%esp)
    14dd:	e8 71 fe ff ff       	call   1353 <printint>
        ap++;
    14e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e6:	e9 b3 00 00 00       	jmp    159e <printf+0x193>
      } else if(c == 's'){
    14eb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14ef:	75 45                	jne    1536 <printf+0x12b>
        s = (char*)*ap;
    14f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f4:	8b 00                	mov    (%eax),%eax
    14f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    14f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    14fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1501:	75 09                	jne    150c <printf+0x101>
          s = "(null)";
    1503:	c7 45 f4 d7 17 00 00 	movl   $0x17d7,-0xc(%ebp)
        while(*s != 0){
    150a:	eb 1e                	jmp    152a <printf+0x11f>
    150c:	eb 1c                	jmp    152a <printf+0x11f>
          putc(fd, *s);
    150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1511:	0f b6 00             	movzbl (%eax),%eax
    1514:	0f be c0             	movsbl %al,%eax
    1517:	89 44 24 04          	mov    %eax,0x4(%esp)
    151b:	8b 45 08             	mov    0x8(%ebp),%eax
    151e:	89 04 24             	mov    %eax,(%esp)
    1521:	e8 05 fe ff ff       	call   132b <putc>
          s++;
    1526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    152d:	0f b6 00             	movzbl (%eax),%eax
    1530:	84 c0                	test   %al,%al
    1532:	75 da                	jne    150e <printf+0x103>
    1534:	eb 68                	jmp    159e <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1536:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    153a:	75 1d                	jne    1559 <printf+0x14e>
        putc(fd, *ap);
    153c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    153f:	8b 00                	mov    (%eax),%eax
    1541:	0f be c0             	movsbl %al,%eax
    1544:	89 44 24 04          	mov    %eax,0x4(%esp)
    1548:	8b 45 08             	mov    0x8(%ebp),%eax
    154b:	89 04 24             	mov    %eax,(%esp)
    154e:	e8 d8 fd ff ff       	call   132b <putc>
        ap++;
    1553:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1557:	eb 45                	jmp    159e <printf+0x193>
      } else if(c == '%'){
    1559:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    155d:	75 17                	jne    1576 <printf+0x16b>
        putc(fd, c);
    155f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1562:	0f be c0             	movsbl %al,%eax
    1565:	89 44 24 04          	mov    %eax,0x4(%esp)
    1569:	8b 45 08             	mov    0x8(%ebp),%eax
    156c:	89 04 24             	mov    %eax,(%esp)
    156f:	e8 b7 fd ff ff       	call   132b <putc>
    1574:	eb 28                	jmp    159e <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1576:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    157d:	00 
    157e:	8b 45 08             	mov    0x8(%ebp),%eax
    1581:	89 04 24             	mov    %eax,(%esp)
    1584:	e8 a2 fd ff ff       	call   132b <putc>
        putc(fd, c);
    1589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    158c:	0f be c0             	movsbl %al,%eax
    158f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1593:	8b 45 08             	mov    0x8(%ebp),%eax
    1596:	89 04 24             	mov    %eax,(%esp)
    1599:	e8 8d fd ff ff       	call   132b <putc>
      }
      state = 0;
    159e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15a5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15a9:	8b 55 0c             	mov    0xc(%ebp),%edx
    15ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15af:	01 d0                	add    %edx,%eax
    15b1:	0f b6 00             	movzbl (%eax),%eax
    15b4:	84 c0                	test   %al,%al
    15b6:	0f 85 71 fe ff ff    	jne    142d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15bc:	c9                   	leave  
    15bd:	c3                   	ret    

000015be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15be:	55                   	push   %ebp
    15bf:	89 e5                	mov    %esp,%ebp
    15c1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15c4:	8b 45 08             	mov    0x8(%ebp),%eax
    15c7:	83 e8 08             	sub    $0x8,%eax
    15ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15cd:	a1 40 2a 00 00       	mov    0x2a40,%eax
    15d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15d5:	eb 24                	jmp    15fb <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15da:	8b 00                	mov    (%eax),%eax
    15dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15df:	77 12                	ja     15f3 <free+0x35>
    15e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15e7:	77 24                	ja     160d <free+0x4f>
    15e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ec:	8b 00                	mov    (%eax),%eax
    15ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15f1:	77 1a                	ja     160d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f6:	8b 00                	mov    (%eax),%eax
    15f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1601:	76 d4                	jbe    15d7 <free+0x19>
    1603:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1606:	8b 00                	mov    (%eax),%eax
    1608:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    160b:	76 ca                	jbe    15d7 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    160d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1610:	8b 40 04             	mov    0x4(%eax),%eax
    1613:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    161a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    161d:	01 c2                	add    %eax,%edx
    161f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1622:	8b 00                	mov    (%eax),%eax
    1624:	39 c2                	cmp    %eax,%edx
    1626:	75 24                	jne    164c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1628:	8b 45 f8             	mov    -0x8(%ebp),%eax
    162b:	8b 50 04             	mov    0x4(%eax),%edx
    162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1631:	8b 00                	mov    (%eax),%eax
    1633:	8b 40 04             	mov    0x4(%eax),%eax
    1636:	01 c2                	add    %eax,%edx
    1638:	8b 45 f8             	mov    -0x8(%ebp),%eax
    163b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    163e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1641:	8b 00                	mov    (%eax),%eax
    1643:	8b 10                	mov    (%eax),%edx
    1645:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1648:	89 10                	mov    %edx,(%eax)
    164a:	eb 0a                	jmp    1656 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    164c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164f:	8b 10                	mov    (%eax),%edx
    1651:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1654:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1656:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1659:	8b 40 04             	mov    0x4(%eax),%eax
    165c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1663:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1666:	01 d0                	add    %edx,%eax
    1668:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    166b:	75 20                	jne    168d <free+0xcf>
    p->s.size += bp->s.size;
    166d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1670:	8b 50 04             	mov    0x4(%eax),%edx
    1673:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1676:	8b 40 04             	mov    0x4(%eax),%eax
    1679:	01 c2                	add    %eax,%edx
    167b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1681:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1684:	8b 10                	mov    (%eax),%edx
    1686:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1689:	89 10                	mov    %edx,(%eax)
    168b:	eb 08                	jmp    1695 <free+0xd7>
  } else
    p->s.ptr = bp;
    168d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1690:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1693:	89 10                	mov    %edx,(%eax)
  freep = p;
    1695:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1698:	a3 40 2a 00 00       	mov    %eax,0x2a40
}
    169d:	c9                   	leave  
    169e:	c3                   	ret    

0000169f <morecore>:

static Header*
morecore(uint nu)
{
    169f:	55                   	push   %ebp
    16a0:	89 e5                	mov    %esp,%ebp
    16a2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16a5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16ac:	77 07                	ja     16b5 <morecore+0x16>
    nu = 4096;
    16ae:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16b5:	8b 45 08             	mov    0x8(%ebp),%eax
    16b8:	c1 e0 03             	shl    $0x3,%eax
    16bb:	89 04 24             	mov    %eax,(%esp)
    16be:	e8 50 fc ff ff       	call   1313 <sbrk>
    16c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16ca:	75 07                	jne    16d3 <morecore+0x34>
    return 0;
    16cc:	b8 00 00 00 00       	mov    $0x0,%eax
    16d1:	eb 22                	jmp    16f5 <morecore+0x56>
  hp = (Header*)p;
    16d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16dc:	8b 55 08             	mov    0x8(%ebp),%edx
    16df:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16e5:	83 c0 08             	add    $0x8,%eax
    16e8:	89 04 24             	mov    %eax,(%esp)
    16eb:	e8 ce fe ff ff       	call   15be <free>
  return freep;
    16f0:	a1 40 2a 00 00       	mov    0x2a40,%eax
}
    16f5:	c9                   	leave  
    16f6:	c3                   	ret    

000016f7 <malloc>:

void*
malloc(uint nbytes)
{
    16f7:	55                   	push   %ebp
    16f8:	89 e5                	mov    %esp,%ebp
    16fa:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    16fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1700:	83 c0 07             	add    $0x7,%eax
    1703:	c1 e8 03             	shr    $0x3,%eax
    1706:	83 c0 01             	add    $0x1,%eax
    1709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    170c:	a1 40 2a 00 00       	mov    0x2a40,%eax
    1711:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1714:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1718:	75 23                	jne    173d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    171a:	c7 45 f0 38 2a 00 00 	movl   $0x2a38,-0x10(%ebp)
    1721:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1724:	a3 40 2a 00 00       	mov    %eax,0x2a40
    1729:	a1 40 2a 00 00       	mov    0x2a40,%eax
    172e:	a3 38 2a 00 00       	mov    %eax,0x2a38
    base.s.size = 0;
    1733:	c7 05 3c 2a 00 00 00 	movl   $0x0,0x2a3c
    173a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1740:	8b 00                	mov    (%eax),%eax
    1742:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1745:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1748:	8b 40 04             	mov    0x4(%eax),%eax
    174b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    174e:	72 4d                	jb     179d <malloc+0xa6>
      if(p->s.size == nunits)
    1750:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1753:	8b 40 04             	mov    0x4(%eax),%eax
    1756:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1759:	75 0c                	jne    1767 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    175e:	8b 10                	mov    (%eax),%edx
    1760:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1763:	89 10                	mov    %edx,(%eax)
    1765:	eb 26                	jmp    178d <malloc+0x96>
      else {
        p->s.size -= nunits;
    1767:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176a:	8b 40 04             	mov    0x4(%eax),%eax
    176d:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1770:	89 c2                	mov    %eax,%edx
    1772:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1775:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1778:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177b:	8b 40 04             	mov    0x4(%eax),%eax
    177e:	c1 e0 03             	shl    $0x3,%eax
    1781:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1784:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1787:	8b 55 ec             	mov    -0x14(%ebp),%edx
    178a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1790:	a3 40 2a 00 00       	mov    %eax,0x2a40
      return (void*)(p + 1);
    1795:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1798:	83 c0 08             	add    $0x8,%eax
    179b:	eb 38                	jmp    17d5 <malloc+0xde>
    }
    if(p == freep)
    179d:	a1 40 2a 00 00       	mov    0x2a40,%eax
    17a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17a5:	75 1b                	jne    17c2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    17a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    17aa:	89 04 24             	mov    %eax,(%esp)
    17ad:	e8 ed fe ff ff       	call   169f <morecore>
    17b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17b9:	75 07                	jne    17c2 <malloc+0xcb>
        return 0;
    17bb:	b8 00 00 00 00       	mov    $0x0,%eax
    17c0:	eb 13                	jmp    17d5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17cb:	8b 00                	mov    (%eax),%eax
    17cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17d0:	e9 70 ff ff ff       	jmp    1745 <malloc+0x4e>
}
    17d5:	c9                   	leave  
    17d6:	c3                   	ret    
