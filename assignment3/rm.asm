
_rm:     file format elf32-i386


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

  if(argc < 2){
    1009:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
    100d:	7f 19                	jg     1028 <main+0x28>
    printf(2, "Usage: rm files...\n");
    100f:	c7 44 24 04 43 18 00 	movl   $0x1843,0x4(%esp)
    1016:	00 
    1017:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    101e:	e8 54 04 00 00       	call   1477 <printf>
    exit();
    1023:	e8 cf 02 00 00       	call   12f7 <exit>
  }

  for(i = 1; i < argc; i++){
    1028:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
    102f:	00 
    1030:	eb 4f                	jmp    1081 <main+0x81>
    if(unlink(argv[i]) < 0){
    1032:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1036:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    103d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1040:	01 d0                	add    %edx,%eax
    1042:	8b 00                	mov    (%eax),%eax
    1044:	89 04 24             	mov    %eax,(%esp)
    1047:	e8 fb 02 00 00       	call   1347 <unlink>
    104c:	85 c0                	test   %eax,%eax
    104e:	79 2c                	jns    107c <main+0x7c>
      printf(2, "rm: %s failed to delete\n", argv[i]);
    1050:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    105b:	8b 45 0c             	mov    0xc(%ebp),%eax
    105e:	01 d0                	add    %edx,%eax
    1060:	8b 00                	mov    (%eax),%eax
    1062:	89 44 24 08          	mov    %eax,0x8(%esp)
    1066:	c7 44 24 04 57 18 00 	movl   $0x1857,0x4(%esp)
    106d:	00 
    106e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1075:	e8 fd 03 00 00       	call   1477 <printf>
      break;
    107a:	eb 0e                	jmp    108a <main+0x8a>
  if(argc < 2){
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
    107c:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
    1081:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1085:	3b 45 08             	cmp    0x8(%ebp),%eax
    1088:	7c a8                	jl     1032 <main+0x32>
      printf(2, "rm: %s failed to delete\n", argv[i]);
      break;
    }
  }

  exit();
    108a:	e8 68 02 00 00       	call   12f7 <exit>

0000108f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    108f:	55                   	push   %ebp
    1090:	89 e5                	mov    %esp,%ebp
    1092:	57                   	push   %edi
    1093:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1094:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1097:	8b 55 10             	mov    0x10(%ebp),%edx
    109a:	8b 45 0c             	mov    0xc(%ebp),%eax
    109d:	89 cb                	mov    %ecx,%ebx
    109f:	89 df                	mov    %ebx,%edi
    10a1:	89 d1                	mov    %edx,%ecx
    10a3:	fc                   	cld    
    10a4:	f3 aa                	rep stos %al,%es:(%edi)
    10a6:	89 ca                	mov    %ecx,%edx
    10a8:	89 fb                	mov    %edi,%ebx
    10aa:	89 5d 08             	mov    %ebx,0x8(%ebp)
    10ad:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    10b0:	5b                   	pop    %ebx
    10b1:	5f                   	pop    %edi
    10b2:	5d                   	pop    %ebp
    10b3:	c3                   	ret    

000010b4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    10b4:	55                   	push   %ebp
    10b5:	89 e5                	mov    %esp,%ebp
    10b7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    10ba:	8b 45 08             	mov    0x8(%ebp),%eax
    10bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10c0:	90                   	nop
    10c1:	8b 45 08             	mov    0x8(%ebp),%eax
    10c4:	8d 50 01             	lea    0x1(%eax),%edx
    10c7:	89 55 08             	mov    %edx,0x8(%ebp)
    10ca:	8b 55 0c             	mov    0xc(%ebp),%edx
    10cd:	8d 4a 01             	lea    0x1(%edx),%ecx
    10d0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10d3:	0f b6 12             	movzbl (%edx),%edx
    10d6:	88 10                	mov    %dl,(%eax)
    10d8:	0f b6 00             	movzbl (%eax),%eax
    10db:	84 c0                	test   %al,%al
    10dd:	75 e2                	jne    10c1 <strcpy+0xd>
    ;
  return os;
    10df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10e2:	c9                   	leave  
    10e3:	c3                   	ret    

000010e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10e4:	55                   	push   %ebp
    10e5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10e7:	eb 08                	jmp    10f1 <strcmp+0xd>
    p++, q++;
    10e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10f1:	8b 45 08             	mov    0x8(%ebp),%eax
    10f4:	0f b6 00             	movzbl (%eax),%eax
    10f7:	84 c0                	test   %al,%al
    10f9:	74 10                	je     110b <strcmp+0x27>
    10fb:	8b 45 08             	mov    0x8(%ebp),%eax
    10fe:	0f b6 10             	movzbl (%eax),%edx
    1101:	8b 45 0c             	mov    0xc(%ebp),%eax
    1104:	0f b6 00             	movzbl (%eax),%eax
    1107:	38 c2                	cmp    %al,%dl
    1109:	74 de                	je     10e9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    110b:	8b 45 08             	mov    0x8(%ebp),%eax
    110e:	0f b6 00             	movzbl (%eax),%eax
    1111:	0f b6 d0             	movzbl %al,%edx
    1114:	8b 45 0c             	mov    0xc(%ebp),%eax
    1117:	0f b6 00             	movzbl (%eax),%eax
    111a:	0f b6 c0             	movzbl %al,%eax
    111d:	29 c2                	sub    %eax,%edx
    111f:	89 d0                	mov    %edx,%eax
}
    1121:	5d                   	pop    %ebp
    1122:	c3                   	ret    

00001123 <strlen>:

uint
strlen(char *s)
{
    1123:	55                   	push   %ebp
    1124:	89 e5                	mov    %esp,%ebp
    1126:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1129:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1130:	eb 04                	jmp    1136 <strlen+0x13>
    1132:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1136:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1139:	8b 45 08             	mov    0x8(%ebp),%eax
    113c:	01 d0                	add    %edx,%eax
    113e:	0f b6 00             	movzbl (%eax),%eax
    1141:	84 c0                	test   %al,%al
    1143:	75 ed                	jne    1132 <strlen+0xf>
    ;
  return n;
    1145:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1148:	c9                   	leave  
    1149:	c3                   	ret    

0000114a <memset>:

void*
memset(void *dst, int c, uint n)
{
    114a:	55                   	push   %ebp
    114b:	89 e5                	mov    %esp,%ebp
    114d:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    1150:	8b 45 10             	mov    0x10(%ebp),%eax
    1153:	89 44 24 08          	mov    %eax,0x8(%esp)
    1157:	8b 45 0c             	mov    0xc(%ebp),%eax
    115a:	89 44 24 04          	mov    %eax,0x4(%esp)
    115e:	8b 45 08             	mov    0x8(%ebp),%eax
    1161:	89 04 24             	mov    %eax,(%esp)
    1164:	e8 26 ff ff ff       	call   108f <stosb>
  return dst;
    1169:	8b 45 08             	mov    0x8(%ebp),%eax
}
    116c:	c9                   	leave  
    116d:	c3                   	ret    

0000116e <strchr>:

char*
strchr(const char *s, char c)
{
    116e:	55                   	push   %ebp
    116f:	89 e5                	mov    %esp,%ebp
    1171:	83 ec 04             	sub    $0x4,%esp
    1174:	8b 45 0c             	mov    0xc(%ebp),%eax
    1177:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    117a:	eb 14                	jmp    1190 <strchr+0x22>
    if(*s == c)
    117c:	8b 45 08             	mov    0x8(%ebp),%eax
    117f:	0f b6 00             	movzbl (%eax),%eax
    1182:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1185:	75 05                	jne    118c <strchr+0x1e>
      return (char*)s;
    1187:	8b 45 08             	mov    0x8(%ebp),%eax
    118a:	eb 13                	jmp    119f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    118c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1190:	8b 45 08             	mov    0x8(%ebp),%eax
    1193:	0f b6 00             	movzbl (%eax),%eax
    1196:	84 c0                	test   %al,%al
    1198:	75 e2                	jne    117c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    119a:	b8 00 00 00 00       	mov    $0x0,%eax
}
    119f:	c9                   	leave  
    11a0:	c3                   	ret    

000011a1 <gets>:

char*
gets(char *buf, int max)
{
    11a1:	55                   	push   %ebp
    11a2:	89 e5                	mov    %esp,%ebp
    11a4:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    11ae:	eb 4c                	jmp    11fc <gets+0x5b>
    cc = read(0, &c, 1);
    11b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    11b7:	00 
    11b8:	8d 45 ef             	lea    -0x11(%ebp),%eax
    11bb:	89 44 24 04          	mov    %eax,0x4(%esp)
    11bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    11c6:	e8 44 01 00 00       	call   130f <read>
    11cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11d2:	7f 02                	jg     11d6 <gets+0x35>
      break;
    11d4:	eb 31                	jmp    1207 <gets+0x66>
    buf[i++] = c;
    11d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d9:	8d 50 01             	lea    0x1(%eax),%edx
    11dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11df:	89 c2                	mov    %eax,%edx
    11e1:	8b 45 08             	mov    0x8(%ebp),%eax
    11e4:	01 c2                	add    %eax,%edx
    11e6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ea:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11ec:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11f0:	3c 0a                	cmp    $0xa,%al
    11f2:	74 13                	je     1207 <gets+0x66>
    11f4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11f8:	3c 0d                	cmp    $0xd,%al
    11fa:	74 0b                	je     1207 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ff:	83 c0 01             	add    $0x1,%eax
    1202:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1205:	7c a9                	jl     11b0 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1207:	8b 55 f4             	mov    -0xc(%ebp),%edx
    120a:	8b 45 08             	mov    0x8(%ebp),%eax
    120d:	01 d0                	add    %edx,%eax
    120f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1212:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1215:	c9                   	leave  
    1216:	c3                   	ret    

00001217 <stat>:

int
stat(char *n, struct stat *st)
{
    1217:	55                   	push   %ebp
    1218:	89 e5                	mov    %esp,%ebp
    121a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    121d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1224:	00 
    1225:	8b 45 08             	mov    0x8(%ebp),%eax
    1228:	89 04 24             	mov    %eax,(%esp)
    122b:	e8 07 01 00 00       	call   1337 <open>
    1230:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1237:	79 07                	jns    1240 <stat+0x29>
    return -1;
    1239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    123e:	eb 23                	jmp    1263 <stat+0x4c>
  r = fstat(fd, st);
    1240:	8b 45 0c             	mov    0xc(%ebp),%eax
    1243:	89 44 24 04          	mov    %eax,0x4(%esp)
    1247:	8b 45 f4             	mov    -0xc(%ebp),%eax
    124a:	89 04 24             	mov    %eax,(%esp)
    124d:	e8 fd 00 00 00       	call   134f <fstat>
    1252:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1255:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1258:	89 04 24             	mov    %eax,(%esp)
    125b:	e8 bf 00 00 00       	call   131f <close>
  return r;
    1260:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1263:	c9                   	leave  
    1264:	c3                   	ret    

00001265 <atoi>:

int
atoi(const char *s)
{
    1265:	55                   	push   %ebp
    1266:	89 e5                	mov    %esp,%ebp
    1268:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    126b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1272:	eb 25                	jmp    1299 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1274:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1277:	89 d0                	mov    %edx,%eax
    1279:	c1 e0 02             	shl    $0x2,%eax
    127c:	01 d0                	add    %edx,%eax
    127e:	01 c0                	add    %eax,%eax
    1280:	89 c1                	mov    %eax,%ecx
    1282:	8b 45 08             	mov    0x8(%ebp),%eax
    1285:	8d 50 01             	lea    0x1(%eax),%edx
    1288:	89 55 08             	mov    %edx,0x8(%ebp)
    128b:	0f b6 00             	movzbl (%eax),%eax
    128e:	0f be c0             	movsbl %al,%eax
    1291:	01 c8                	add    %ecx,%eax
    1293:	83 e8 30             	sub    $0x30,%eax
    1296:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1299:	8b 45 08             	mov    0x8(%ebp),%eax
    129c:	0f b6 00             	movzbl (%eax),%eax
    129f:	3c 2f                	cmp    $0x2f,%al
    12a1:	7e 0a                	jle    12ad <atoi+0x48>
    12a3:	8b 45 08             	mov    0x8(%ebp),%eax
    12a6:	0f b6 00             	movzbl (%eax),%eax
    12a9:	3c 39                	cmp    $0x39,%al
    12ab:	7e c7                	jle    1274 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    12ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    12b0:	c9                   	leave  
    12b1:	c3                   	ret    

000012b2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    12b2:	55                   	push   %ebp
    12b3:	89 e5                	mov    %esp,%ebp
    12b5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    12b8:	8b 45 08             	mov    0x8(%ebp),%eax
    12bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    12be:	8b 45 0c             	mov    0xc(%ebp),%eax
    12c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    12c4:	eb 17                	jmp    12dd <memmove+0x2b>
    *dst++ = *src++;
    12c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12c9:	8d 50 01             	lea    0x1(%eax),%edx
    12cc:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12cf:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12d2:	8d 4a 01             	lea    0x1(%edx),%ecx
    12d5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12d8:	0f b6 12             	movzbl (%edx),%edx
    12db:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12dd:	8b 45 10             	mov    0x10(%ebp),%eax
    12e0:	8d 50 ff             	lea    -0x1(%eax),%edx
    12e3:	89 55 10             	mov    %edx,0x10(%ebp)
    12e6:	85 c0                	test   %eax,%eax
    12e8:	7f dc                	jg     12c6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12ed:	c9                   	leave  
    12ee:	c3                   	ret    

000012ef <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12ef:	b8 01 00 00 00       	mov    $0x1,%eax
    12f4:	cd 40                	int    $0x40
    12f6:	c3                   	ret    

000012f7 <exit>:
SYSCALL(exit)
    12f7:	b8 02 00 00 00       	mov    $0x2,%eax
    12fc:	cd 40                	int    $0x40
    12fe:	c3                   	ret    

000012ff <wait>:
SYSCALL(wait)
    12ff:	b8 03 00 00 00       	mov    $0x3,%eax
    1304:	cd 40                	int    $0x40
    1306:	c3                   	ret    

00001307 <pipe>:
SYSCALL(pipe)
    1307:	b8 04 00 00 00       	mov    $0x4,%eax
    130c:	cd 40                	int    $0x40
    130e:	c3                   	ret    

0000130f <read>:
SYSCALL(read)
    130f:	b8 05 00 00 00       	mov    $0x5,%eax
    1314:	cd 40                	int    $0x40
    1316:	c3                   	ret    

00001317 <write>:
SYSCALL(write)
    1317:	b8 10 00 00 00       	mov    $0x10,%eax
    131c:	cd 40                	int    $0x40
    131e:	c3                   	ret    

0000131f <close>:
SYSCALL(close)
    131f:	b8 15 00 00 00       	mov    $0x15,%eax
    1324:	cd 40                	int    $0x40
    1326:	c3                   	ret    

00001327 <kill>:
SYSCALL(kill)
    1327:	b8 06 00 00 00       	mov    $0x6,%eax
    132c:	cd 40                	int    $0x40
    132e:	c3                   	ret    

0000132f <exec>:
SYSCALL(exec)
    132f:	b8 07 00 00 00       	mov    $0x7,%eax
    1334:	cd 40                	int    $0x40
    1336:	c3                   	ret    

00001337 <open>:
SYSCALL(open)
    1337:	b8 0f 00 00 00       	mov    $0xf,%eax
    133c:	cd 40                	int    $0x40
    133e:	c3                   	ret    

0000133f <mknod>:
SYSCALL(mknod)
    133f:	b8 11 00 00 00       	mov    $0x11,%eax
    1344:	cd 40                	int    $0x40
    1346:	c3                   	ret    

00001347 <unlink>:
SYSCALL(unlink)
    1347:	b8 12 00 00 00       	mov    $0x12,%eax
    134c:	cd 40                	int    $0x40
    134e:	c3                   	ret    

0000134f <fstat>:
SYSCALL(fstat)
    134f:	b8 08 00 00 00       	mov    $0x8,%eax
    1354:	cd 40                	int    $0x40
    1356:	c3                   	ret    

00001357 <link>:
SYSCALL(link)
    1357:	b8 13 00 00 00       	mov    $0x13,%eax
    135c:	cd 40                	int    $0x40
    135e:	c3                   	ret    

0000135f <mkdir>:
SYSCALL(mkdir)
    135f:	b8 14 00 00 00       	mov    $0x14,%eax
    1364:	cd 40                	int    $0x40
    1366:	c3                   	ret    

00001367 <chdir>:
SYSCALL(chdir)
    1367:	b8 09 00 00 00       	mov    $0x9,%eax
    136c:	cd 40                	int    $0x40
    136e:	c3                   	ret    

0000136f <dup>:
SYSCALL(dup)
    136f:	b8 0a 00 00 00       	mov    $0xa,%eax
    1374:	cd 40                	int    $0x40
    1376:	c3                   	ret    

00001377 <getpid>:
SYSCALL(getpid)
    1377:	b8 0b 00 00 00       	mov    $0xb,%eax
    137c:	cd 40                	int    $0x40
    137e:	c3                   	ret    

0000137f <sbrk>:
SYSCALL(sbrk)
    137f:	b8 0c 00 00 00       	mov    $0xc,%eax
    1384:	cd 40                	int    $0x40
    1386:	c3                   	ret    

00001387 <sleep>:
SYSCALL(sleep)
    1387:	b8 0d 00 00 00       	mov    $0xd,%eax
    138c:	cd 40                	int    $0x40
    138e:	c3                   	ret    

0000138f <uptime>:
SYSCALL(uptime)
    138f:	b8 0e 00 00 00       	mov    $0xe,%eax
    1394:	cd 40                	int    $0x40
    1396:	c3                   	ret    

00001397 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1397:	55                   	push   %ebp
    1398:	89 e5                	mov    %esp,%ebp
    139a:	83 ec 18             	sub    $0x18,%esp
    139d:	8b 45 0c             	mov    0xc(%ebp),%eax
    13a0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13aa:	00 
    13ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13ae:	89 44 24 04          	mov    %eax,0x4(%esp)
    13b2:	8b 45 08             	mov    0x8(%ebp),%eax
    13b5:	89 04 24             	mov    %eax,(%esp)
    13b8:	e8 5a ff ff ff       	call   1317 <write>
}
    13bd:	c9                   	leave  
    13be:	c3                   	ret    

000013bf <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13bf:	55                   	push   %ebp
    13c0:	89 e5                	mov    %esp,%ebp
    13c2:	56                   	push   %esi
    13c3:	53                   	push   %ebx
    13c4:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13ce:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13d2:	74 17                	je     13eb <printint+0x2c>
    13d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13d8:	79 11                	jns    13eb <printint+0x2c>
    neg = 1;
    13da:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13e1:	8b 45 0c             	mov    0xc(%ebp),%eax
    13e4:	f7 d8                	neg    %eax
    13e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13e9:	eb 06                	jmp    13f1 <printint+0x32>
  } else {
    x = xx;
    13eb:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13fb:	8d 41 01             	lea    0x1(%ecx),%eax
    13fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1401:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1404:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1407:	ba 00 00 00 00       	mov    $0x0,%edx
    140c:	f7 f3                	div    %ebx
    140e:	89 d0                	mov    %edx,%eax
    1410:	0f b6 80 bc 2a 00 00 	movzbl 0x2abc(%eax),%eax
    1417:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    141b:	8b 75 10             	mov    0x10(%ebp),%esi
    141e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1421:	ba 00 00 00 00       	mov    $0x0,%edx
    1426:	f7 f6                	div    %esi
    1428:	89 45 ec             	mov    %eax,-0x14(%ebp)
    142b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    142f:	75 c7                	jne    13f8 <printint+0x39>
  if(neg)
    1431:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1435:	74 10                	je     1447 <printint+0x88>
    buf[i++] = '-';
    1437:	8b 45 f4             	mov    -0xc(%ebp),%eax
    143a:	8d 50 01             	lea    0x1(%eax),%edx
    143d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1440:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1445:	eb 1f                	jmp    1466 <printint+0xa7>
    1447:	eb 1d                	jmp    1466 <printint+0xa7>
    putc(fd, buf[i]);
    1449:	8d 55 dc             	lea    -0x24(%ebp),%edx
    144c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144f:	01 d0                	add    %edx,%eax
    1451:	0f b6 00             	movzbl (%eax),%eax
    1454:	0f be c0             	movsbl %al,%eax
    1457:	89 44 24 04          	mov    %eax,0x4(%esp)
    145b:	8b 45 08             	mov    0x8(%ebp),%eax
    145e:	89 04 24             	mov    %eax,(%esp)
    1461:	e8 31 ff ff ff       	call   1397 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1466:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    146a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    146e:	79 d9                	jns    1449 <printint+0x8a>
    putc(fd, buf[i]);
}
    1470:	83 c4 30             	add    $0x30,%esp
    1473:	5b                   	pop    %ebx
    1474:	5e                   	pop    %esi
    1475:	5d                   	pop    %ebp
    1476:	c3                   	ret    

00001477 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1477:	55                   	push   %ebp
    1478:	89 e5                	mov    %esp,%ebp
    147a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    147d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1484:	8d 45 0c             	lea    0xc(%ebp),%eax
    1487:	83 c0 04             	add    $0x4,%eax
    148a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    148d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1494:	e9 7c 01 00 00       	jmp    1615 <printf+0x19e>
    c = fmt[i] & 0xff;
    1499:	8b 55 0c             	mov    0xc(%ebp),%edx
    149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    149f:	01 d0                	add    %edx,%eax
    14a1:	0f b6 00             	movzbl (%eax),%eax
    14a4:	0f be c0             	movsbl %al,%eax
    14a7:	25 ff 00 00 00       	and    $0xff,%eax
    14ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14b3:	75 2c                	jne    14e1 <printf+0x6a>
      if(c == '%'){
    14b5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14b9:	75 0c                	jne    14c7 <printf+0x50>
        state = '%';
    14bb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14c2:	e9 4a 01 00 00       	jmp    1611 <printf+0x19a>
      } else {
        putc(fd, c);
    14c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14ca:	0f be c0             	movsbl %al,%eax
    14cd:	89 44 24 04          	mov    %eax,0x4(%esp)
    14d1:	8b 45 08             	mov    0x8(%ebp),%eax
    14d4:	89 04 24             	mov    %eax,(%esp)
    14d7:	e8 bb fe ff ff       	call   1397 <putc>
    14dc:	e9 30 01 00 00       	jmp    1611 <printf+0x19a>
      }
    } else if(state == '%'){
    14e1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14e5:	0f 85 26 01 00 00    	jne    1611 <printf+0x19a>
      if(c == 'd'){
    14eb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14ef:	75 2d                	jne    151e <printf+0xa7>
        printint(fd, *ap, 10, 1);
    14f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f4:	8b 00                	mov    (%eax),%eax
    14f6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    14fd:	00 
    14fe:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1505:	00 
    1506:	89 44 24 04          	mov    %eax,0x4(%esp)
    150a:	8b 45 08             	mov    0x8(%ebp),%eax
    150d:	89 04 24             	mov    %eax,(%esp)
    1510:	e8 aa fe ff ff       	call   13bf <printint>
        ap++;
    1515:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1519:	e9 ec 00 00 00       	jmp    160a <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    151e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1522:	74 06                	je     152a <printf+0xb3>
    1524:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1528:	75 2d                	jne    1557 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    152a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    152d:	8b 00                	mov    (%eax),%eax
    152f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1536:	00 
    1537:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    153e:	00 
    153f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1543:	8b 45 08             	mov    0x8(%ebp),%eax
    1546:	89 04 24             	mov    %eax,(%esp)
    1549:	e8 71 fe ff ff       	call   13bf <printint>
        ap++;
    154e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1552:	e9 b3 00 00 00       	jmp    160a <printf+0x193>
      } else if(c == 's'){
    1557:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    155b:	75 45                	jne    15a2 <printf+0x12b>
        s = (char*)*ap;
    155d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1560:	8b 00                	mov    (%eax),%eax
    1562:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1565:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1569:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    156d:	75 09                	jne    1578 <printf+0x101>
          s = "(null)";
    156f:	c7 45 f4 70 18 00 00 	movl   $0x1870,-0xc(%ebp)
        while(*s != 0){
    1576:	eb 1e                	jmp    1596 <printf+0x11f>
    1578:	eb 1c                	jmp    1596 <printf+0x11f>
          putc(fd, *s);
    157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    157d:	0f b6 00             	movzbl (%eax),%eax
    1580:	0f be c0             	movsbl %al,%eax
    1583:	89 44 24 04          	mov    %eax,0x4(%esp)
    1587:	8b 45 08             	mov    0x8(%ebp),%eax
    158a:	89 04 24             	mov    %eax,(%esp)
    158d:	e8 05 fe ff ff       	call   1397 <putc>
          s++;
    1592:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1596:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1599:	0f b6 00             	movzbl (%eax),%eax
    159c:	84 c0                	test   %al,%al
    159e:	75 da                	jne    157a <printf+0x103>
    15a0:	eb 68                	jmp    160a <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15a2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15a6:	75 1d                	jne    15c5 <printf+0x14e>
        putc(fd, *ap);
    15a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15ab:	8b 00                	mov    (%eax),%eax
    15ad:	0f be c0             	movsbl %al,%eax
    15b0:	89 44 24 04          	mov    %eax,0x4(%esp)
    15b4:	8b 45 08             	mov    0x8(%ebp),%eax
    15b7:	89 04 24             	mov    %eax,(%esp)
    15ba:	e8 d8 fd ff ff       	call   1397 <putc>
        ap++;
    15bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15c3:	eb 45                	jmp    160a <printf+0x193>
      } else if(c == '%'){
    15c5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15c9:	75 17                	jne    15e2 <printf+0x16b>
        putc(fd, c);
    15cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15ce:	0f be c0             	movsbl %al,%eax
    15d1:	89 44 24 04          	mov    %eax,0x4(%esp)
    15d5:	8b 45 08             	mov    0x8(%ebp),%eax
    15d8:	89 04 24             	mov    %eax,(%esp)
    15db:	e8 b7 fd ff ff       	call   1397 <putc>
    15e0:	eb 28                	jmp    160a <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15e2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    15e9:	00 
    15ea:	8b 45 08             	mov    0x8(%ebp),%eax
    15ed:	89 04 24             	mov    %eax,(%esp)
    15f0:	e8 a2 fd ff ff       	call   1397 <putc>
        putc(fd, c);
    15f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15f8:	0f be c0             	movsbl %al,%eax
    15fb:	89 44 24 04          	mov    %eax,0x4(%esp)
    15ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1602:	89 04 24             	mov    %eax,(%esp)
    1605:	e8 8d fd ff ff       	call   1397 <putc>
      }
      state = 0;
    160a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1611:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1615:	8b 55 0c             	mov    0xc(%ebp),%edx
    1618:	8b 45 f0             	mov    -0x10(%ebp),%eax
    161b:	01 d0                	add    %edx,%eax
    161d:	0f b6 00             	movzbl (%eax),%eax
    1620:	84 c0                	test   %al,%al
    1622:	0f 85 71 fe ff ff    	jne    1499 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1628:	c9                   	leave  
    1629:	c3                   	ret    

0000162a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    162a:	55                   	push   %ebp
    162b:	89 e5                	mov    %esp,%ebp
    162d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1630:	8b 45 08             	mov    0x8(%ebp),%eax
    1633:	83 e8 08             	sub    $0x8,%eax
    1636:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1639:	a1 d8 2a 00 00       	mov    0x2ad8,%eax
    163e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1641:	eb 24                	jmp    1667 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1643:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1646:	8b 00                	mov    (%eax),%eax
    1648:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    164b:	77 12                	ja     165f <free+0x35>
    164d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1650:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1653:	77 24                	ja     1679 <free+0x4f>
    1655:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1658:	8b 00                	mov    (%eax),%eax
    165a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    165d:	77 1a                	ja     1679 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    165f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1662:	8b 00                	mov    (%eax),%eax
    1664:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1667:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    166d:	76 d4                	jbe    1643 <free+0x19>
    166f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1672:	8b 00                	mov    (%eax),%eax
    1674:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1677:	76 ca                	jbe    1643 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1679:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167c:	8b 40 04             	mov    0x4(%eax),%eax
    167f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1686:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1689:	01 c2                	add    %eax,%edx
    168b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168e:	8b 00                	mov    (%eax),%eax
    1690:	39 c2                	cmp    %eax,%edx
    1692:	75 24                	jne    16b8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1694:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1697:	8b 50 04             	mov    0x4(%eax),%edx
    169a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169d:	8b 00                	mov    (%eax),%eax
    169f:	8b 40 04             	mov    0x4(%eax),%eax
    16a2:	01 c2                	add    %eax,%edx
    16a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ad:	8b 00                	mov    (%eax),%eax
    16af:	8b 10                	mov    (%eax),%edx
    16b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b4:	89 10                	mov    %edx,(%eax)
    16b6:	eb 0a                	jmp    16c2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    16b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bb:	8b 10                	mov    (%eax),%edx
    16bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    16c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c5:	8b 40 04             	mov    0x4(%eax),%eax
    16c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d2:	01 d0                	add    %edx,%eax
    16d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16d7:	75 20                	jne    16f9 <free+0xcf>
    p->s.size += bp->s.size;
    16d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16dc:	8b 50 04             	mov    0x4(%eax),%edx
    16df:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16e2:	8b 40 04             	mov    0x4(%eax),%eax
    16e5:	01 c2                	add    %eax,%edx
    16e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16f0:	8b 10                	mov    (%eax),%edx
    16f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f5:	89 10                	mov    %edx,(%eax)
    16f7:	eb 08                	jmp    1701 <free+0xd7>
  } else
    p->s.ptr = bp;
    16f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16ff:	89 10                	mov    %edx,(%eax)
  freep = p;
    1701:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1704:	a3 d8 2a 00 00       	mov    %eax,0x2ad8
}
    1709:	c9                   	leave  
    170a:	c3                   	ret    

0000170b <morecore>:

static Header*
morecore(uint nu)
{
    170b:	55                   	push   %ebp
    170c:	89 e5                	mov    %esp,%ebp
    170e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1711:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1718:	77 07                	ja     1721 <morecore+0x16>
    nu = 4096;
    171a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1721:	8b 45 08             	mov    0x8(%ebp),%eax
    1724:	c1 e0 03             	shl    $0x3,%eax
    1727:	89 04 24             	mov    %eax,(%esp)
    172a:	e8 50 fc ff ff       	call   137f <sbrk>
    172f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1732:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1736:	75 07                	jne    173f <morecore+0x34>
    return 0;
    1738:	b8 00 00 00 00       	mov    $0x0,%eax
    173d:	eb 22                	jmp    1761 <morecore+0x56>
  hp = (Header*)p;
    173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1742:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1745:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1748:	8b 55 08             	mov    0x8(%ebp),%edx
    174b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1751:	83 c0 08             	add    $0x8,%eax
    1754:	89 04 24             	mov    %eax,(%esp)
    1757:	e8 ce fe ff ff       	call   162a <free>
  return freep;
    175c:	a1 d8 2a 00 00       	mov    0x2ad8,%eax
}
    1761:	c9                   	leave  
    1762:	c3                   	ret    

00001763 <malloc>:

void*
malloc(uint nbytes)
{
    1763:	55                   	push   %ebp
    1764:	89 e5                	mov    %esp,%ebp
    1766:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1769:	8b 45 08             	mov    0x8(%ebp),%eax
    176c:	83 c0 07             	add    $0x7,%eax
    176f:	c1 e8 03             	shr    $0x3,%eax
    1772:	83 c0 01             	add    $0x1,%eax
    1775:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1778:	a1 d8 2a 00 00       	mov    0x2ad8,%eax
    177d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1784:	75 23                	jne    17a9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1786:	c7 45 f0 d0 2a 00 00 	movl   $0x2ad0,-0x10(%ebp)
    178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1790:	a3 d8 2a 00 00       	mov    %eax,0x2ad8
    1795:	a1 d8 2a 00 00       	mov    0x2ad8,%eax
    179a:	a3 d0 2a 00 00       	mov    %eax,0x2ad0
    base.s.size = 0;
    179f:	c7 05 d4 2a 00 00 00 	movl   $0x0,0x2ad4
    17a6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ac:	8b 00                	mov    (%eax),%eax
    17ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b4:	8b 40 04             	mov    0x4(%eax),%eax
    17b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17ba:	72 4d                	jb     1809 <malloc+0xa6>
      if(p->s.size == nunits)
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	8b 40 04             	mov    0x4(%eax),%eax
    17c2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17c5:	75 0c                	jne    17d3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ca:	8b 10                	mov    (%eax),%edx
    17cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17cf:	89 10                	mov    %edx,(%eax)
    17d1:	eb 26                	jmp    17f9 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d6:	8b 40 04             	mov    0x4(%eax),%eax
    17d9:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17dc:	89 c2                	mov    %eax,%edx
    17de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e7:	8b 40 04             	mov    0x4(%eax),%eax
    17ea:	c1 e0 03             	shl    $0x3,%eax
    17ed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17f6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17fc:	a3 d8 2a 00 00       	mov    %eax,0x2ad8
      return (void*)(p + 1);
    1801:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1804:	83 c0 08             	add    $0x8,%eax
    1807:	eb 38                	jmp    1841 <malloc+0xde>
    }
    if(p == freep)
    1809:	a1 d8 2a 00 00       	mov    0x2ad8,%eax
    180e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1811:	75 1b                	jne    182e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    1813:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1816:	89 04 24             	mov    %eax,(%esp)
    1819:	e8 ed fe ff ff       	call   170b <morecore>
    181e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1821:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1825:	75 07                	jne    182e <malloc+0xcb>
        return 0;
    1827:	b8 00 00 00 00       	mov    $0x0,%eax
    182c:	eb 13                	jmp    1841 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1831:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1834:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1837:	8b 00                	mov    (%eax),%eax
    1839:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    183c:	e9 70 ff ff ff       	jmp    17b1 <malloc+0x4e>
}
    1841:	c9                   	leave  
    1842:	c3                   	ret    
