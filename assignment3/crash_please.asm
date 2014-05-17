
_crash_please:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "user.h"
#include "fs.h"
#include "fcntl.h"
 

int main(int argc, char *argv[]) {
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 e4 f0             	and    $0xfffffff0,%esp
    1006:	83 ec 10             	sub    $0x10,%esp
 	char *buf = 0;
    1009:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1010:	00 
	buf[0] = 'a';
    1011:	8b 44 24 0c          	mov    0xc(%esp),%eax
    1015:	c6 00 61             	movb   $0x61,(%eax)
    	exit();
    1018:	e8 68 02 00 00       	call   1285 <exit>

0000101d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    101d:	55                   	push   %ebp
    101e:	89 e5                	mov    %esp,%ebp
    1020:	57                   	push   %edi
    1021:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1022:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1025:	8b 55 10             	mov    0x10(%ebp),%edx
    1028:	8b 45 0c             	mov    0xc(%ebp),%eax
    102b:	89 cb                	mov    %ecx,%ebx
    102d:	89 df                	mov    %ebx,%edi
    102f:	89 d1                	mov    %edx,%ecx
    1031:	fc                   	cld    
    1032:	f3 aa                	rep stos %al,%es:(%edi)
    1034:	89 ca                	mov    %ecx,%edx
    1036:	89 fb                	mov    %edi,%ebx
    1038:	89 5d 08             	mov    %ebx,0x8(%ebp)
    103b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    103e:	5b                   	pop    %ebx
    103f:	5f                   	pop    %edi
    1040:	5d                   	pop    %ebp
    1041:	c3                   	ret    

00001042 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1042:	55                   	push   %ebp
    1043:	89 e5                	mov    %esp,%ebp
    1045:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1048:	8b 45 08             	mov    0x8(%ebp),%eax
    104b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    104e:	90                   	nop
    104f:	8b 45 08             	mov    0x8(%ebp),%eax
    1052:	8d 50 01             	lea    0x1(%eax),%edx
    1055:	89 55 08             	mov    %edx,0x8(%ebp)
    1058:	8b 55 0c             	mov    0xc(%ebp),%edx
    105b:	8d 4a 01             	lea    0x1(%edx),%ecx
    105e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1061:	0f b6 12             	movzbl (%edx),%edx
    1064:	88 10                	mov    %dl,(%eax)
    1066:	0f b6 00             	movzbl (%eax),%eax
    1069:	84 c0                	test   %al,%al
    106b:	75 e2                	jne    104f <strcpy+0xd>
    ;
  return os;
    106d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1070:	c9                   	leave  
    1071:	c3                   	ret    

00001072 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1072:	55                   	push   %ebp
    1073:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1075:	eb 08                	jmp    107f <strcmp+0xd>
    p++, q++;
    1077:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    107b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    107f:	8b 45 08             	mov    0x8(%ebp),%eax
    1082:	0f b6 00             	movzbl (%eax),%eax
    1085:	84 c0                	test   %al,%al
    1087:	74 10                	je     1099 <strcmp+0x27>
    1089:	8b 45 08             	mov    0x8(%ebp),%eax
    108c:	0f b6 10             	movzbl (%eax),%edx
    108f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1092:	0f b6 00             	movzbl (%eax),%eax
    1095:	38 c2                	cmp    %al,%dl
    1097:	74 de                	je     1077 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1099:	8b 45 08             	mov    0x8(%ebp),%eax
    109c:	0f b6 00             	movzbl (%eax),%eax
    109f:	0f b6 d0             	movzbl %al,%edx
    10a2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10a5:	0f b6 00             	movzbl (%eax),%eax
    10a8:	0f b6 c0             	movzbl %al,%eax
    10ab:	29 c2                	sub    %eax,%edx
    10ad:	89 d0                	mov    %edx,%eax
}
    10af:	5d                   	pop    %ebp
    10b0:	c3                   	ret    

000010b1 <strlen>:

uint
strlen(char *s)
{
    10b1:	55                   	push   %ebp
    10b2:	89 e5                	mov    %esp,%ebp
    10b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10be:	eb 04                	jmp    10c4 <strlen+0x13>
    10c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10c7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ca:	01 d0                	add    %edx,%eax
    10cc:	0f b6 00             	movzbl (%eax),%eax
    10cf:	84 c0                	test   %al,%al
    10d1:	75 ed                	jne    10c0 <strlen+0xf>
    ;
  return n;
    10d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10d6:	c9                   	leave  
    10d7:	c3                   	ret    

000010d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
    10d8:	55                   	push   %ebp
    10d9:	89 e5                	mov    %esp,%ebp
    10db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    10de:	8b 45 10             	mov    0x10(%ebp),%eax
    10e1:	89 44 24 08          	mov    %eax,0x8(%esp)
    10e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e8:	89 44 24 04          	mov    %eax,0x4(%esp)
    10ec:	8b 45 08             	mov    0x8(%ebp),%eax
    10ef:	89 04 24             	mov    %eax,(%esp)
    10f2:	e8 26 ff ff ff       	call   101d <stosb>
  return dst;
    10f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
    10fa:	c9                   	leave  
    10fb:	c3                   	ret    

000010fc <strchr>:

char*
strchr(const char *s, char c)
{
    10fc:	55                   	push   %ebp
    10fd:	89 e5                	mov    %esp,%ebp
    10ff:	83 ec 04             	sub    $0x4,%esp
    1102:	8b 45 0c             	mov    0xc(%ebp),%eax
    1105:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1108:	eb 14                	jmp    111e <strchr+0x22>
    if(*s == c)
    110a:	8b 45 08             	mov    0x8(%ebp),%eax
    110d:	0f b6 00             	movzbl (%eax),%eax
    1110:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1113:	75 05                	jne    111a <strchr+0x1e>
      return (char*)s;
    1115:	8b 45 08             	mov    0x8(%ebp),%eax
    1118:	eb 13                	jmp    112d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    111a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    111e:	8b 45 08             	mov    0x8(%ebp),%eax
    1121:	0f b6 00             	movzbl (%eax),%eax
    1124:	84 c0                	test   %al,%al
    1126:	75 e2                	jne    110a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1128:	b8 00 00 00 00       	mov    $0x0,%eax
}
    112d:	c9                   	leave  
    112e:	c3                   	ret    

0000112f <gets>:

char*
gets(char *buf, int max)
{
    112f:	55                   	push   %ebp
    1130:	89 e5                	mov    %esp,%ebp
    1132:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1135:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    113c:	eb 4c                	jmp    118a <gets+0x5b>
    cc = read(0, &c, 1);
    113e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1145:	00 
    1146:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1149:	89 44 24 04          	mov    %eax,0x4(%esp)
    114d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1154:	e8 44 01 00 00       	call   129d <read>
    1159:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    115c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1160:	7f 02                	jg     1164 <gets+0x35>
      break;
    1162:	eb 31                	jmp    1195 <gets+0x66>
    buf[i++] = c;
    1164:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1167:	8d 50 01             	lea    0x1(%eax),%edx
    116a:	89 55 f4             	mov    %edx,-0xc(%ebp)
    116d:	89 c2                	mov    %eax,%edx
    116f:	8b 45 08             	mov    0x8(%ebp),%eax
    1172:	01 c2                	add    %eax,%edx
    1174:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1178:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    117a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    117e:	3c 0a                	cmp    $0xa,%al
    1180:	74 13                	je     1195 <gets+0x66>
    1182:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1186:	3c 0d                	cmp    $0xd,%al
    1188:	74 0b                	je     1195 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    118a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    118d:	83 c0 01             	add    $0x1,%eax
    1190:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1193:	7c a9                	jl     113e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1195:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1198:	8b 45 08             	mov    0x8(%ebp),%eax
    119b:	01 d0                	add    %edx,%eax
    119d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11a3:	c9                   	leave  
    11a4:	c3                   	ret    

000011a5 <stat>:

int
stat(char *n, struct stat *st)
{
    11a5:	55                   	push   %ebp
    11a6:	89 e5                	mov    %esp,%ebp
    11a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11b2:	00 
    11b3:	8b 45 08             	mov    0x8(%ebp),%eax
    11b6:	89 04 24             	mov    %eax,(%esp)
    11b9:	e8 07 01 00 00       	call   12c5 <open>
    11be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11c5:	79 07                	jns    11ce <stat+0x29>
    return -1;
    11c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11cc:	eb 23                	jmp    11f1 <stat+0x4c>
  r = fstat(fd, st);
    11ce:	8b 45 0c             	mov    0xc(%ebp),%eax
    11d1:	89 44 24 04          	mov    %eax,0x4(%esp)
    11d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d8:	89 04 24             	mov    %eax,(%esp)
    11db:	e8 fd 00 00 00       	call   12dd <fstat>
    11e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11e6:	89 04 24             	mov    %eax,(%esp)
    11e9:	e8 bf 00 00 00       	call   12ad <close>
  return r;
    11ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11f1:	c9                   	leave  
    11f2:	c3                   	ret    

000011f3 <atoi>:

int
atoi(const char *s)
{
    11f3:	55                   	push   %ebp
    11f4:	89 e5                	mov    %esp,%ebp
    11f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    11f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1200:	eb 25                	jmp    1227 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1202:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1205:	89 d0                	mov    %edx,%eax
    1207:	c1 e0 02             	shl    $0x2,%eax
    120a:	01 d0                	add    %edx,%eax
    120c:	01 c0                	add    %eax,%eax
    120e:	89 c1                	mov    %eax,%ecx
    1210:	8b 45 08             	mov    0x8(%ebp),%eax
    1213:	8d 50 01             	lea    0x1(%eax),%edx
    1216:	89 55 08             	mov    %edx,0x8(%ebp)
    1219:	0f b6 00             	movzbl (%eax),%eax
    121c:	0f be c0             	movsbl %al,%eax
    121f:	01 c8                	add    %ecx,%eax
    1221:	83 e8 30             	sub    $0x30,%eax
    1224:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1227:	8b 45 08             	mov    0x8(%ebp),%eax
    122a:	0f b6 00             	movzbl (%eax),%eax
    122d:	3c 2f                	cmp    $0x2f,%al
    122f:	7e 0a                	jle    123b <atoi+0x48>
    1231:	8b 45 08             	mov    0x8(%ebp),%eax
    1234:	0f b6 00             	movzbl (%eax),%eax
    1237:	3c 39                	cmp    $0x39,%al
    1239:	7e c7                	jle    1202 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    123b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    123e:	c9                   	leave  
    123f:	c3                   	ret    

00001240 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1240:	55                   	push   %ebp
    1241:	89 e5                	mov    %esp,%ebp
    1243:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1246:	8b 45 08             	mov    0x8(%ebp),%eax
    1249:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    124c:	8b 45 0c             	mov    0xc(%ebp),%eax
    124f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1252:	eb 17                	jmp    126b <memmove+0x2b>
    *dst++ = *src++;
    1254:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1257:	8d 50 01             	lea    0x1(%eax),%edx
    125a:	89 55 fc             	mov    %edx,-0x4(%ebp)
    125d:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1260:	8d 4a 01             	lea    0x1(%edx),%ecx
    1263:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1266:	0f b6 12             	movzbl (%edx),%edx
    1269:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    126b:	8b 45 10             	mov    0x10(%ebp),%eax
    126e:	8d 50 ff             	lea    -0x1(%eax),%edx
    1271:	89 55 10             	mov    %edx,0x10(%ebp)
    1274:	85 c0                	test   %eax,%eax
    1276:	7f dc                	jg     1254 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1278:	8b 45 08             	mov    0x8(%ebp),%eax
}
    127b:	c9                   	leave  
    127c:	c3                   	ret    

0000127d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    127d:	b8 01 00 00 00       	mov    $0x1,%eax
    1282:	cd 40                	int    $0x40
    1284:	c3                   	ret    

00001285 <exit>:
SYSCALL(exit)
    1285:	b8 02 00 00 00       	mov    $0x2,%eax
    128a:	cd 40                	int    $0x40
    128c:	c3                   	ret    

0000128d <wait>:
SYSCALL(wait)
    128d:	b8 03 00 00 00       	mov    $0x3,%eax
    1292:	cd 40                	int    $0x40
    1294:	c3                   	ret    

00001295 <pipe>:
SYSCALL(pipe)
    1295:	b8 04 00 00 00       	mov    $0x4,%eax
    129a:	cd 40                	int    $0x40
    129c:	c3                   	ret    

0000129d <read>:
SYSCALL(read)
    129d:	b8 05 00 00 00       	mov    $0x5,%eax
    12a2:	cd 40                	int    $0x40
    12a4:	c3                   	ret    

000012a5 <write>:
SYSCALL(write)
    12a5:	b8 10 00 00 00       	mov    $0x10,%eax
    12aa:	cd 40                	int    $0x40
    12ac:	c3                   	ret    

000012ad <close>:
SYSCALL(close)
    12ad:	b8 15 00 00 00       	mov    $0x15,%eax
    12b2:	cd 40                	int    $0x40
    12b4:	c3                   	ret    

000012b5 <kill>:
SYSCALL(kill)
    12b5:	b8 06 00 00 00       	mov    $0x6,%eax
    12ba:	cd 40                	int    $0x40
    12bc:	c3                   	ret    

000012bd <exec>:
SYSCALL(exec)
    12bd:	b8 07 00 00 00       	mov    $0x7,%eax
    12c2:	cd 40                	int    $0x40
    12c4:	c3                   	ret    

000012c5 <open>:
SYSCALL(open)
    12c5:	b8 0f 00 00 00       	mov    $0xf,%eax
    12ca:	cd 40                	int    $0x40
    12cc:	c3                   	ret    

000012cd <mknod>:
SYSCALL(mknod)
    12cd:	b8 11 00 00 00       	mov    $0x11,%eax
    12d2:	cd 40                	int    $0x40
    12d4:	c3                   	ret    

000012d5 <unlink>:
SYSCALL(unlink)
    12d5:	b8 12 00 00 00       	mov    $0x12,%eax
    12da:	cd 40                	int    $0x40
    12dc:	c3                   	ret    

000012dd <fstat>:
SYSCALL(fstat)
    12dd:	b8 08 00 00 00       	mov    $0x8,%eax
    12e2:	cd 40                	int    $0x40
    12e4:	c3                   	ret    

000012e5 <link>:
SYSCALL(link)
    12e5:	b8 13 00 00 00       	mov    $0x13,%eax
    12ea:	cd 40                	int    $0x40
    12ec:	c3                   	ret    

000012ed <mkdir>:
SYSCALL(mkdir)
    12ed:	b8 14 00 00 00       	mov    $0x14,%eax
    12f2:	cd 40                	int    $0x40
    12f4:	c3                   	ret    

000012f5 <chdir>:
SYSCALL(chdir)
    12f5:	b8 09 00 00 00       	mov    $0x9,%eax
    12fa:	cd 40                	int    $0x40
    12fc:	c3                   	ret    

000012fd <dup>:
SYSCALL(dup)
    12fd:	b8 0a 00 00 00       	mov    $0xa,%eax
    1302:	cd 40                	int    $0x40
    1304:	c3                   	ret    

00001305 <getpid>:
SYSCALL(getpid)
    1305:	b8 0b 00 00 00       	mov    $0xb,%eax
    130a:	cd 40                	int    $0x40
    130c:	c3                   	ret    

0000130d <sbrk>:
SYSCALL(sbrk)
    130d:	b8 0c 00 00 00       	mov    $0xc,%eax
    1312:	cd 40                	int    $0x40
    1314:	c3                   	ret    

00001315 <sleep>:
SYSCALL(sleep)
    1315:	b8 0d 00 00 00       	mov    $0xd,%eax
    131a:	cd 40                	int    $0x40
    131c:	c3                   	ret    

0000131d <uptime>:
SYSCALL(uptime)
    131d:	b8 0e 00 00 00       	mov    $0xe,%eax
    1322:	cd 40                	int    $0x40
    1324:	c3                   	ret    

00001325 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1325:	55                   	push   %ebp
    1326:	89 e5                	mov    %esp,%ebp
    1328:	83 ec 18             	sub    $0x18,%esp
    132b:	8b 45 0c             	mov    0xc(%ebp),%eax
    132e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1338:	00 
    1339:	8d 45 f4             	lea    -0xc(%ebp),%eax
    133c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1340:	8b 45 08             	mov    0x8(%ebp),%eax
    1343:	89 04 24             	mov    %eax,(%esp)
    1346:	e8 5a ff ff ff       	call   12a5 <write>
}
    134b:	c9                   	leave  
    134c:	c3                   	ret    

0000134d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    134d:	55                   	push   %ebp
    134e:	89 e5                	mov    %esp,%ebp
    1350:	56                   	push   %esi
    1351:	53                   	push   %ebx
    1352:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1355:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    135c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1360:	74 17                	je     1379 <printint+0x2c>
    1362:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1366:	79 11                	jns    1379 <printint+0x2c>
    neg = 1;
    1368:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    136f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1372:	f7 d8                	neg    %eax
    1374:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1377:	eb 06                	jmp    137f <printint+0x32>
  } else {
    x = xx;
    1379:	8b 45 0c             	mov    0xc(%ebp),%eax
    137c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    137f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1386:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1389:	8d 41 01             	lea    0x1(%ecx),%eax
    138c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    138f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1392:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1395:	ba 00 00 00 00       	mov    $0x0,%edx
    139a:	f7 f3                	div    %ebx
    139c:	89 d0                	mov    %edx,%eax
    139e:	0f b6 80 1c 1a 00 00 	movzbl 0x1a1c(%eax),%eax
    13a5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13a9:	8b 75 10             	mov    0x10(%ebp),%esi
    13ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13af:	ba 00 00 00 00       	mov    $0x0,%edx
    13b4:	f7 f6                	div    %esi
    13b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13bd:	75 c7                	jne    1386 <printint+0x39>
  if(neg)
    13bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13c3:	74 10                	je     13d5 <printint+0x88>
    buf[i++] = '-';
    13c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c8:	8d 50 01             	lea    0x1(%eax),%edx
    13cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
    13ce:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    13d3:	eb 1f                	jmp    13f4 <printint+0xa7>
    13d5:	eb 1d                	jmp    13f4 <printint+0xa7>
    putc(fd, buf[i]);
    13d7:	8d 55 dc             	lea    -0x24(%ebp),%edx
    13da:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13dd:	01 d0                	add    %edx,%eax
    13df:	0f b6 00             	movzbl (%eax),%eax
    13e2:	0f be c0             	movsbl %al,%eax
    13e5:	89 44 24 04          	mov    %eax,0x4(%esp)
    13e9:	8b 45 08             	mov    0x8(%ebp),%eax
    13ec:	89 04 24             	mov    %eax,(%esp)
    13ef:	e8 31 ff ff ff       	call   1325 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    13f4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    13f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    13fc:	79 d9                	jns    13d7 <printint+0x8a>
    putc(fd, buf[i]);
}
    13fe:	83 c4 30             	add    $0x30,%esp
    1401:	5b                   	pop    %ebx
    1402:	5e                   	pop    %esi
    1403:	5d                   	pop    %ebp
    1404:	c3                   	ret    

00001405 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1405:	55                   	push   %ebp
    1406:	89 e5                	mov    %esp,%ebp
    1408:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    140b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1412:	8d 45 0c             	lea    0xc(%ebp),%eax
    1415:	83 c0 04             	add    $0x4,%eax
    1418:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    141b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1422:	e9 7c 01 00 00       	jmp    15a3 <printf+0x19e>
    c = fmt[i] & 0xff;
    1427:	8b 55 0c             	mov    0xc(%ebp),%edx
    142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    142d:	01 d0                	add    %edx,%eax
    142f:	0f b6 00             	movzbl (%eax),%eax
    1432:	0f be c0             	movsbl %al,%eax
    1435:	25 ff 00 00 00       	and    $0xff,%eax
    143a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    143d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1441:	75 2c                	jne    146f <printf+0x6a>
      if(c == '%'){
    1443:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1447:	75 0c                	jne    1455 <printf+0x50>
        state = '%';
    1449:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1450:	e9 4a 01 00 00       	jmp    159f <printf+0x19a>
      } else {
        putc(fd, c);
    1455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1458:	0f be c0             	movsbl %al,%eax
    145b:	89 44 24 04          	mov    %eax,0x4(%esp)
    145f:	8b 45 08             	mov    0x8(%ebp),%eax
    1462:	89 04 24             	mov    %eax,(%esp)
    1465:	e8 bb fe ff ff       	call   1325 <putc>
    146a:	e9 30 01 00 00       	jmp    159f <printf+0x19a>
      }
    } else if(state == '%'){
    146f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1473:	0f 85 26 01 00 00    	jne    159f <printf+0x19a>
      if(c == 'd'){
    1479:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    147d:	75 2d                	jne    14ac <printf+0xa7>
        printint(fd, *ap, 10, 1);
    147f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1482:	8b 00                	mov    (%eax),%eax
    1484:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    148b:	00 
    148c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1493:	00 
    1494:	89 44 24 04          	mov    %eax,0x4(%esp)
    1498:	8b 45 08             	mov    0x8(%ebp),%eax
    149b:	89 04 24             	mov    %eax,(%esp)
    149e:	e8 aa fe ff ff       	call   134d <printint>
        ap++;
    14a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14a7:	e9 ec 00 00 00       	jmp    1598 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    14ac:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14b0:	74 06                	je     14b8 <printf+0xb3>
    14b2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14b6:	75 2d                	jne    14e5 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    14b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14bb:	8b 00                	mov    (%eax),%eax
    14bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    14c4:	00 
    14c5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    14cc:	00 
    14cd:	89 44 24 04          	mov    %eax,0x4(%esp)
    14d1:	8b 45 08             	mov    0x8(%ebp),%eax
    14d4:	89 04 24             	mov    %eax,(%esp)
    14d7:	e8 71 fe ff ff       	call   134d <printint>
        ap++;
    14dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e0:	e9 b3 00 00 00       	jmp    1598 <printf+0x193>
      } else if(c == 's'){
    14e5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14e9:	75 45                	jne    1530 <printf+0x12b>
        s = (char*)*ap;
    14eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14ee:	8b 00                	mov    (%eax),%eax
    14f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    14f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    14f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14fb:	75 09                	jne    1506 <printf+0x101>
          s = "(null)";
    14fd:	c7 45 f4 d1 17 00 00 	movl   $0x17d1,-0xc(%ebp)
        while(*s != 0){
    1504:	eb 1e                	jmp    1524 <printf+0x11f>
    1506:	eb 1c                	jmp    1524 <printf+0x11f>
          putc(fd, *s);
    1508:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150b:	0f b6 00             	movzbl (%eax),%eax
    150e:	0f be c0             	movsbl %al,%eax
    1511:	89 44 24 04          	mov    %eax,0x4(%esp)
    1515:	8b 45 08             	mov    0x8(%ebp),%eax
    1518:	89 04 24             	mov    %eax,(%esp)
    151b:	e8 05 fe ff ff       	call   1325 <putc>
          s++;
    1520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1524:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1527:	0f b6 00             	movzbl (%eax),%eax
    152a:	84 c0                	test   %al,%al
    152c:	75 da                	jne    1508 <printf+0x103>
    152e:	eb 68                	jmp    1598 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1530:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1534:	75 1d                	jne    1553 <printf+0x14e>
        putc(fd, *ap);
    1536:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1539:	8b 00                	mov    (%eax),%eax
    153b:	0f be c0             	movsbl %al,%eax
    153e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1542:	8b 45 08             	mov    0x8(%ebp),%eax
    1545:	89 04 24             	mov    %eax,(%esp)
    1548:	e8 d8 fd ff ff       	call   1325 <putc>
        ap++;
    154d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1551:	eb 45                	jmp    1598 <printf+0x193>
      } else if(c == '%'){
    1553:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1557:	75 17                	jne    1570 <printf+0x16b>
        putc(fd, c);
    1559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    155c:	0f be c0             	movsbl %al,%eax
    155f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1563:	8b 45 08             	mov    0x8(%ebp),%eax
    1566:	89 04 24             	mov    %eax,(%esp)
    1569:	e8 b7 fd ff ff       	call   1325 <putc>
    156e:	eb 28                	jmp    1598 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1570:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1577:	00 
    1578:	8b 45 08             	mov    0x8(%ebp),%eax
    157b:	89 04 24             	mov    %eax,(%esp)
    157e:	e8 a2 fd ff ff       	call   1325 <putc>
        putc(fd, c);
    1583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1586:	0f be c0             	movsbl %al,%eax
    1589:	89 44 24 04          	mov    %eax,0x4(%esp)
    158d:	8b 45 08             	mov    0x8(%ebp),%eax
    1590:	89 04 24             	mov    %eax,(%esp)
    1593:	e8 8d fd ff ff       	call   1325 <putc>
      }
      state = 0;
    1598:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    159f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15a3:	8b 55 0c             	mov    0xc(%ebp),%edx
    15a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15a9:	01 d0                	add    %edx,%eax
    15ab:	0f b6 00             	movzbl (%eax),%eax
    15ae:	84 c0                	test   %al,%al
    15b0:	0f 85 71 fe ff ff    	jne    1427 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15b6:	c9                   	leave  
    15b7:	c3                   	ret    

000015b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15b8:	55                   	push   %ebp
    15b9:	89 e5                	mov    %esp,%ebp
    15bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15be:	8b 45 08             	mov    0x8(%ebp),%eax
    15c1:	83 e8 08             	sub    $0x8,%eax
    15c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15c7:	a1 38 1a 00 00       	mov    0x1a38,%eax
    15cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15cf:	eb 24                	jmp    15f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15d4:	8b 00                	mov    (%eax),%eax
    15d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15d9:	77 12                	ja     15ed <free+0x35>
    15db:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15e1:	77 24                	ja     1607 <free+0x4f>
    15e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15e6:	8b 00                	mov    (%eax),%eax
    15e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15eb:	77 1a                	ja     1607 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f0:	8b 00                	mov    (%eax),%eax
    15f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15fb:	76 d4                	jbe    15d1 <free+0x19>
    15fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1600:	8b 00                	mov    (%eax),%eax
    1602:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1605:	76 ca                	jbe    15d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1607:	8b 45 f8             	mov    -0x8(%ebp),%eax
    160a:	8b 40 04             	mov    0x4(%eax),%eax
    160d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1614:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1617:	01 c2                	add    %eax,%edx
    1619:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161c:	8b 00                	mov    (%eax),%eax
    161e:	39 c2                	cmp    %eax,%edx
    1620:	75 24                	jne    1646 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1622:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1625:	8b 50 04             	mov    0x4(%eax),%edx
    1628:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162b:	8b 00                	mov    (%eax),%eax
    162d:	8b 40 04             	mov    0x4(%eax),%eax
    1630:	01 c2                	add    %eax,%edx
    1632:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1635:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1638:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163b:	8b 00                	mov    (%eax),%eax
    163d:	8b 10                	mov    (%eax),%edx
    163f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1642:	89 10                	mov    %edx,(%eax)
    1644:	eb 0a                	jmp    1650 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1646:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1649:	8b 10                	mov    (%eax),%edx
    164b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1650:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1653:	8b 40 04             	mov    0x4(%eax),%eax
    1656:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    165d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1660:	01 d0                	add    %edx,%eax
    1662:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1665:	75 20                	jne    1687 <free+0xcf>
    p->s.size += bp->s.size;
    1667:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166a:	8b 50 04             	mov    0x4(%eax),%edx
    166d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1670:	8b 40 04             	mov    0x4(%eax),%eax
    1673:	01 c2                	add    %eax,%edx
    1675:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1678:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    167b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167e:	8b 10                	mov    (%eax),%edx
    1680:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1683:	89 10                	mov    %edx,(%eax)
    1685:	eb 08                	jmp    168f <free+0xd7>
  } else
    p->s.ptr = bp;
    1687:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168a:	8b 55 f8             	mov    -0x8(%ebp),%edx
    168d:	89 10                	mov    %edx,(%eax)
  freep = p;
    168f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1692:	a3 38 1a 00 00       	mov    %eax,0x1a38
}
    1697:	c9                   	leave  
    1698:	c3                   	ret    

00001699 <morecore>:

static Header*
morecore(uint nu)
{
    1699:	55                   	push   %ebp
    169a:	89 e5                	mov    %esp,%ebp
    169c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    169f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16a6:	77 07                	ja     16af <morecore+0x16>
    nu = 4096;
    16a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16af:	8b 45 08             	mov    0x8(%ebp),%eax
    16b2:	c1 e0 03             	shl    $0x3,%eax
    16b5:	89 04 24             	mov    %eax,(%esp)
    16b8:	e8 50 fc ff ff       	call   130d <sbrk>
    16bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16c4:	75 07                	jne    16cd <morecore+0x34>
    return 0;
    16c6:	b8 00 00 00 00       	mov    $0x0,%eax
    16cb:	eb 22                	jmp    16ef <morecore+0x56>
  hp = (Header*)p;
    16cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16d6:	8b 55 08             	mov    0x8(%ebp),%edx
    16d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16df:	83 c0 08             	add    $0x8,%eax
    16e2:	89 04 24             	mov    %eax,(%esp)
    16e5:	e8 ce fe ff ff       	call   15b8 <free>
  return freep;
    16ea:	a1 38 1a 00 00       	mov    0x1a38,%eax
}
    16ef:	c9                   	leave  
    16f0:	c3                   	ret    

000016f1 <malloc>:

void*
malloc(uint nbytes)
{
    16f1:	55                   	push   %ebp
    16f2:	89 e5                	mov    %esp,%ebp
    16f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    16f7:	8b 45 08             	mov    0x8(%ebp),%eax
    16fa:	83 c0 07             	add    $0x7,%eax
    16fd:	c1 e8 03             	shr    $0x3,%eax
    1700:	83 c0 01             	add    $0x1,%eax
    1703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1706:	a1 38 1a 00 00       	mov    0x1a38,%eax
    170b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    170e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1712:	75 23                	jne    1737 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1714:	c7 45 f0 30 1a 00 00 	movl   $0x1a30,-0x10(%ebp)
    171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    171e:	a3 38 1a 00 00       	mov    %eax,0x1a38
    1723:	a1 38 1a 00 00       	mov    0x1a38,%eax
    1728:	a3 30 1a 00 00       	mov    %eax,0x1a30
    base.s.size = 0;
    172d:	c7 05 34 1a 00 00 00 	movl   $0x0,0x1a34
    1734:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1737:	8b 45 f0             	mov    -0x10(%ebp),%eax
    173a:	8b 00                	mov    (%eax),%eax
    173c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1742:	8b 40 04             	mov    0x4(%eax),%eax
    1745:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1748:	72 4d                	jb     1797 <malloc+0xa6>
      if(p->s.size == nunits)
    174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    174d:	8b 40 04             	mov    0x4(%eax),%eax
    1750:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1753:	75 0c                	jne    1761 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1755:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1758:	8b 10                	mov    (%eax),%edx
    175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    175d:	89 10                	mov    %edx,(%eax)
    175f:	eb 26                	jmp    1787 <malloc+0x96>
      else {
        p->s.size -= nunits;
    1761:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1764:	8b 40 04             	mov    0x4(%eax),%eax
    1767:	2b 45 ec             	sub    -0x14(%ebp),%eax
    176a:	89 c2                	mov    %eax,%edx
    176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1772:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1775:	8b 40 04             	mov    0x4(%eax),%eax
    1778:	c1 e0 03             	shl    $0x3,%eax
    177b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1781:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1784:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1787:	8b 45 f0             	mov    -0x10(%ebp),%eax
    178a:	a3 38 1a 00 00       	mov    %eax,0x1a38
      return (void*)(p + 1);
    178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1792:	83 c0 08             	add    $0x8,%eax
    1795:	eb 38                	jmp    17cf <malloc+0xde>
    }
    if(p == freep)
    1797:	a1 38 1a 00 00       	mov    0x1a38,%eax
    179c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    179f:	75 1b                	jne    17bc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    17a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    17a4:	89 04 24             	mov    %eax,(%esp)
    17a7:	e8 ed fe ff ff       	call   1699 <morecore>
    17ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17b3:	75 07                	jne    17bc <malloc+0xcb>
        return 0;
    17b5:	b8 00 00 00 00       	mov    $0x0,%eax
    17ba:	eb 13                	jmp    17cf <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c5:	8b 00                	mov    (%eax),%eax
    17c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17ca:	e9 70 ff ff ff       	jmp    173f <malloc+0x4e>
}
    17cf:	c9                   	leave  
    17d0:	c3                   	ret    
