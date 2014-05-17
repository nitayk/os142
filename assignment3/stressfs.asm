
_stressfs:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 e4 f0             	and    $0xfffffff0,%esp
    1006:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
    100c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
    1013:	73 74 72 65 
    1017:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
    101e:	73 73 66 73 
    1022:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
    1029:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
    102c:	c7 44 24 04 67 19 00 	movl   $0x1967,0x4(%esp)
    1033:	00 
    1034:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    103b:	e8 5b 05 00 00       	call   159b <printf>
  memset(data, 'a', sizeof(data));
    1040:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    1047:	00 
    1048:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
    104f:	00 
    1050:	8d 44 24 1e          	lea    0x1e(%esp),%eax
    1054:	89 04 24             	mov    %eax,(%esp)
    1057:	e8 12 02 00 00       	call   126e <memset>

  for(i = 0; i < 4; i++)
    105c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
    1063:	00 00 00 00 
    1067:	eb 13                	jmp    107c <main+0x7c>
    if(fork() > 0)
    1069:	e8 a5 03 00 00       	call   1413 <fork>
    106e:	85 c0                	test   %eax,%eax
    1070:	7e 02                	jle    1074 <main+0x74>
      break;
    1072:	eb 12                	jmp    1086 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
    1074:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
    107b:	01 
    107c:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
    1083:	03 
    1084:	7e e3                	jle    1069 <main+0x69>
    if(fork() > 0)
      break;

  printf(1, "write %d\n", i);
    1086:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
    108d:	89 44 24 08          	mov    %eax,0x8(%esp)
    1091:	c7 44 24 04 7a 19 00 	movl   $0x197a,0x4(%esp)
    1098:	00 
    1099:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10a0:	e8 f6 04 00 00       	call   159b <printf>

  path[8] += i;
    10a5:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
    10ac:	00 
    10ad:	89 c2                	mov    %eax,%edx
    10af:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
    10b6:	01 d0                	add    %edx,%eax
    10b8:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
    10bf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    10c6:	00 
    10c7:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
    10ce:	89 04 24             	mov    %eax,(%esp)
    10d1:	e8 85 03 00 00       	call   145b <open>
    10d6:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
    10dd:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
    10e4:	00 00 00 00 
    10e8:	eb 27                	jmp    1111 <main+0x111>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
    10ea:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    10f1:	00 
    10f2:	8d 44 24 1e          	lea    0x1e(%esp),%eax
    10f6:	89 44 24 04          	mov    %eax,0x4(%esp)
    10fa:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
    1101:	89 04 24             	mov    %eax,(%esp)
    1104:	e8 32 03 00 00       	call   143b <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
    1109:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
    1110:	01 
    1111:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
    1118:	13 
    1119:	7e cf                	jle    10ea <main+0xea>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
    111b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
    1122:	89 04 24             	mov    %eax,(%esp)
    1125:	e8 19 03 00 00       	call   1443 <close>

  printf(1, "read\n");
    112a:	c7 44 24 04 84 19 00 	movl   $0x1984,0x4(%esp)
    1131:	00 
    1132:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1139:	e8 5d 04 00 00       	call   159b <printf>

  fd = open(path, O_RDONLY);
    113e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1145:	00 
    1146:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
    114d:	89 04 24             	mov    %eax,(%esp)
    1150:	e8 06 03 00 00       	call   145b <open>
    1155:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
    115c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
    1163:	00 00 00 00 
    1167:	eb 27                	jmp    1190 <main+0x190>
    read(fd, data, sizeof(data));
    1169:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    1170:	00 
    1171:	8d 44 24 1e          	lea    0x1e(%esp),%eax
    1175:	89 44 24 04          	mov    %eax,0x4(%esp)
    1179:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
    1180:	89 04 24             	mov    %eax,(%esp)
    1183:	e8 ab 02 00 00       	call   1433 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
    1188:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
    118f:	01 
    1190:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
    1197:	13 
    1198:	7e cf                	jle    1169 <main+0x169>
    read(fd, data, sizeof(data));
  close(fd);
    119a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
    11a1:	89 04 24             	mov    %eax,(%esp)
    11a4:	e8 9a 02 00 00       	call   1443 <close>

  wait();
    11a9:	e8 75 02 00 00       	call   1423 <wait>
  
  exit();
    11ae:	e8 68 02 00 00       	call   141b <exit>

000011b3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    11b3:	55                   	push   %ebp
    11b4:	89 e5                	mov    %esp,%ebp
    11b6:	57                   	push   %edi
    11b7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    11b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
    11bb:	8b 55 10             	mov    0x10(%ebp),%edx
    11be:	8b 45 0c             	mov    0xc(%ebp),%eax
    11c1:	89 cb                	mov    %ecx,%ebx
    11c3:	89 df                	mov    %ebx,%edi
    11c5:	89 d1                	mov    %edx,%ecx
    11c7:	fc                   	cld    
    11c8:	f3 aa                	rep stos %al,%es:(%edi)
    11ca:	89 ca                	mov    %ecx,%edx
    11cc:	89 fb                	mov    %edi,%ebx
    11ce:	89 5d 08             	mov    %ebx,0x8(%ebp)
    11d1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    11d4:	5b                   	pop    %ebx
    11d5:	5f                   	pop    %edi
    11d6:	5d                   	pop    %ebp
    11d7:	c3                   	ret    

000011d8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    11d8:	55                   	push   %ebp
    11d9:	89 e5                	mov    %esp,%ebp
    11db:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    11de:	8b 45 08             	mov    0x8(%ebp),%eax
    11e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    11e4:	90                   	nop
    11e5:	8b 45 08             	mov    0x8(%ebp),%eax
    11e8:	8d 50 01             	lea    0x1(%eax),%edx
    11eb:	89 55 08             	mov    %edx,0x8(%ebp)
    11ee:	8b 55 0c             	mov    0xc(%ebp),%edx
    11f1:	8d 4a 01             	lea    0x1(%edx),%ecx
    11f4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    11f7:	0f b6 12             	movzbl (%edx),%edx
    11fa:	88 10                	mov    %dl,(%eax)
    11fc:	0f b6 00             	movzbl (%eax),%eax
    11ff:	84 c0                	test   %al,%al
    1201:	75 e2                	jne    11e5 <strcpy+0xd>
    ;
  return os;
    1203:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1206:	c9                   	leave  
    1207:	c3                   	ret    

00001208 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1208:	55                   	push   %ebp
    1209:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    120b:	eb 08                	jmp    1215 <strcmp+0xd>
    p++, q++;
    120d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1211:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1215:	8b 45 08             	mov    0x8(%ebp),%eax
    1218:	0f b6 00             	movzbl (%eax),%eax
    121b:	84 c0                	test   %al,%al
    121d:	74 10                	je     122f <strcmp+0x27>
    121f:	8b 45 08             	mov    0x8(%ebp),%eax
    1222:	0f b6 10             	movzbl (%eax),%edx
    1225:	8b 45 0c             	mov    0xc(%ebp),%eax
    1228:	0f b6 00             	movzbl (%eax),%eax
    122b:	38 c2                	cmp    %al,%dl
    122d:	74 de                	je     120d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    122f:	8b 45 08             	mov    0x8(%ebp),%eax
    1232:	0f b6 00             	movzbl (%eax),%eax
    1235:	0f b6 d0             	movzbl %al,%edx
    1238:	8b 45 0c             	mov    0xc(%ebp),%eax
    123b:	0f b6 00             	movzbl (%eax),%eax
    123e:	0f b6 c0             	movzbl %al,%eax
    1241:	29 c2                	sub    %eax,%edx
    1243:	89 d0                	mov    %edx,%eax
}
    1245:	5d                   	pop    %ebp
    1246:	c3                   	ret    

00001247 <strlen>:

uint
strlen(char *s)
{
    1247:	55                   	push   %ebp
    1248:	89 e5                	mov    %esp,%ebp
    124a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    124d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1254:	eb 04                	jmp    125a <strlen+0x13>
    1256:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    125a:	8b 55 fc             	mov    -0x4(%ebp),%edx
    125d:	8b 45 08             	mov    0x8(%ebp),%eax
    1260:	01 d0                	add    %edx,%eax
    1262:	0f b6 00             	movzbl (%eax),%eax
    1265:	84 c0                	test   %al,%al
    1267:	75 ed                	jne    1256 <strlen+0xf>
    ;
  return n;
    1269:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    126c:	c9                   	leave  
    126d:	c3                   	ret    

0000126e <memset>:

void*
memset(void *dst, int c, uint n)
{
    126e:	55                   	push   %ebp
    126f:	89 e5                	mov    %esp,%ebp
    1271:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    1274:	8b 45 10             	mov    0x10(%ebp),%eax
    1277:	89 44 24 08          	mov    %eax,0x8(%esp)
    127b:	8b 45 0c             	mov    0xc(%ebp),%eax
    127e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1282:	8b 45 08             	mov    0x8(%ebp),%eax
    1285:	89 04 24             	mov    %eax,(%esp)
    1288:	e8 26 ff ff ff       	call   11b3 <stosb>
  return dst;
    128d:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1290:	c9                   	leave  
    1291:	c3                   	ret    

00001292 <strchr>:

char*
strchr(const char *s, char c)
{
    1292:	55                   	push   %ebp
    1293:	89 e5                	mov    %esp,%ebp
    1295:	83 ec 04             	sub    $0x4,%esp
    1298:	8b 45 0c             	mov    0xc(%ebp),%eax
    129b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    129e:	eb 14                	jmp    12b4 <strchr+0x22>
    if(*s == c)
    12a0:	8b 45 08             	mov    0x8(%ebp),%eax
    12a3:	0f b6 00             	movzbl (%eax),%eax
    12a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
    12a9:	75 05                	jne    12b0 <strchr+0x1e>
      return (char*)s;
    12ab:	8b 45 08             	mov    0x8(%ebp),%eax
    12ae:	eb 13                	jmp    12c3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    12b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12b4:	8b 45 08             	mov    0x8(%ebp),%eax
    12b7:	0f b6 00             	movzbl (%eax),%eax
    12ba:	84 c0                	test   %al,%al
    12bc:	75 e2                	jne    12a0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    12be:	b8 00 00 00 00       	mov    $0x0,%eax
}
    12c3:	c9                   	leave  
    12c4:	c3                   	ret    

000012c5 <gets>:

char*
gets(char *buf, int max)
{
    12c5:	55                   	push   %ebp
    12c6:	89 e5                	mov    %esp,%ebp
    12c8:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    12cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    12d2:	eb 4c                	jmp    1320 <gets+0x5b>
    cc = read(0, &c, 1);
    12d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    12db:	00 
    12dc:	8d 45 ef             	lea    -0x11(%ebp),%eax
    12df:	89 44 24 04          	mov    %eax,0x4(%esp)
    12e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    12ea:	e8 44 01 00 00       	call   1433 <read>
    12ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    12f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    12f6:	7f 02                	jg     12fa <gets+0x35>
      break;
    12f8:	eb 31                	jmp    132b <gets+0x66>
    buf[i++] = c;
    12fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12fd:	8d 50 01             	lea    0x1(%eax),%edx
    1300:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1303:	89 c2                	mov    %eax,%edx
    1305:	8b 45 08             	mov    0x8(%ebp),%eax
    1308:	01 c2                	add    %eax,%edx
    130a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    130e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1310:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1314:	3c 0a                	cmp    $0xa,%al
    1316:	74 13                	je     132b <gets+0x66>
    1318:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    131c:	3c 0d                	cmp    $0xd,%al
    131e:	74 0b                	je     132b <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1320:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1323:	83 c0 01             	add    $0x1,%eax
    1326:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1329:	7c a9                	jl     12d4 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    132b:	8b 55 f4             	mov    -0xc(%ebp),%edx
    132e:	8b 45 08             	mov    0x8(%ebp),%eax
    1331:	01 d0                	add    %edx,%eax
    1333:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1336:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1339:	c9                   	leave  
    133a:	c3                   	ret    

0000133b <stat>:

int
stat(char *n, struct stat *st)
{
    133b:	55                   	push   %ebp
    133c:	89 e5                	mov    %esp,%ebp
    133e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1341:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1348:	00 
    1349:	8b 45 08             	mov    0x8(%ebp),%eax
    134c:	89 04 24             	mov    %eax,(%esp)
    134f:	e8 07 01 00 00       	call   145b <open>
    1354:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    135b:	79 07                	jns    1364 <stat+0x29>
    return -1;
    135d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1362:	eb 23                	jmp    1387 <stat+0x4c>
  r = fstat(fd, st);
    1364:	8b 45 0c             	mov    0xc(%ebp),%eax
    1367:	89 44 24 04          	mov    %eax,0x4(%esp)
    136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    136e:	89 04 24             	mov    %eax,(%esp)
    1371:	e8 fd 00 00 00       	call   1473 <fstat>
    1376:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1379:	8b 45 f4             	mov    -0xc(%ebp),%eax
    137c:	89 04 24             	mov    %eax,(%esp)
    137f:	e8 bf 00 00 00       	call   1443 <close>
  return r;
    1384:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1387:	c9                   	leave  
    1388:	c3                   	ret    

00001389 <atoi>:

int
atoi(const char *s)
{
    1389:	55                   	push   %ebp
    138a:	89 e5                	mov    %esp,%ebp
    138c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    138f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1396:	eb 25                	jmp    13bd <atoi+0x34>
    n = n*10 + *s++ - '0';
    1398:	8b 55 fc             	mov    -0x4(%ebp),%edx
    139b:	89 d0                	mov    %edx,%eax
    139d:	c1 e0 02             	shl    $0x2,%eax
    13a0:	01 d0                	add    %edx,%eax
    13a2:	01 c0                	add    %eax,%eax
    13a4:	89 c1                	mov    %eax,%ecx
    13a6:	8b 45 08             	mov    0x8(%ebp),%eax
    13a9:	8d 50 01             	lea    0x1(%eax),%edx
    13ac:	89 55 08             	mov    %edx,0x8(%ebp)
    13af:	0f b6 00             	movzbl (%eax),%eax
    13b2:	0f be c0             	movsbl %al,%eax
    13b5:	01 c8                	add    %ecx,%eax
    13b7:	83 e8 30             	sub    $0x30,%eax
    13ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    13bd:	8b 45 08             	mov    0x8(%ebp),%eax
    13c0:	0f b6 00             	movzbl (%eax),%eax
    13c3:	3c 2f                	cmp    $0x2f,%al
    13c5:	7e 0a                	jle    13d1 <atoi+0x48>
    13c7:	8b 45 08             	mov    0x8(%ebp),%eax
    13ca:	0f b6 00             	movzbl (%eax),%eax
    13cd:	3c 39                	cmp    $0x39,%al
    13cf:	7e c7                	jle    1398 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    13d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    13d4:	c9                   	leave  
    13d5:	c3                   	ret    

000013d6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    13d6:	55                   	push   %ebp
    13d7:	89 e5                	mov    %esp,%ebp
    13d9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    13dc:	8b 45 08             	mov    0x8(%ebp),%eax
    13df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    13e2:	8b 45 0c             	mov    0xc(%ebp),%eax
    13e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    13e8:	eb 17                	jmp    1401 <memmove+0x2b>
    *dst++ = *src++;
    13ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13ed:	8d 50 01             	lea    0x1(%eax),%edx
    13f0:	89 55 fc             	mov    %edx,-0x4(%ebp)
    13f3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13f6:	8d 4a 01             	lea    0x1(%edx),%ecx
    13f9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    13fc:	0f b6 12             	movzbl (%edx),%edx
    13ff:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1401:	8b 45 10             	mov    0x10(%ebp),%eax
    1404:	8d 50 ff             	lea    -0x1(%eax),%edx
    1407:	89 55 10             	mov    %edx,0x10(%ebp)
    140a:	85 c0                	test   %eax,%eax
    140c:	7f dc                	jg     13ea <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    140e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1411:	c9                   	leave  
    1412:	c3                   	ret    

00001413 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1413:	b8 01 00 00 00       	mov    $0x1,%eax
    1418:	cd 40                	int    $0x40
    141a:	c3                   	ret    

0000141b <exit>:
SYSCALL(exit)
    141b:	b8 02 00 00 00       	mov    $0x2,%eax
    1420:	cd 40                	int    $0x40
    1422:	c3                   	ret    

00001423 <wait>:
SYSCALL(wait)
    1423:	b8 03 00 00 00       	mov    $0x3,%eax
    1428:	cd 40                	int    $0x40
    142a:	c3                   	ret    

0000142b <pipe>:
SYSCALL(pipe)
    142b:	b8 04 00 00 00       	mov    $0x4,%eax
    1430:	cd 40                	int    $0x40
    1432:	c3                   	ret    

00001433 <read>:
SYSCALL(read)
    1433:	b8 05 00 00 00       	mov    $0x5,%eax
    1438:	cd 40                	int    $0x40
    143a:	c3                   	ret    

0000143b <write>:
SYSCALL(write)
    143b:	b8 10 00 00 00       	mov    $0x10,%eax
    1440:	cd 40                	int    $0x40
    1442:	c3                   	ret    

00001443 <close>:
SYSCALL(close)
    1443:	b8 15 00 00 00       	mov    $0x15,%eax
    1448:	cd 40                	int    $0x40
    144a:	c3                   	ret    

0000144b <kill>:
SYSCALL(kill)
    144b:	b8 06 00 00 00       	mov    $0x6,%eax
    1450:	cd 40                	int    $0x40
    1452:	c3                   	ret    

00001453 <exec>:
SYSCALL(exec)
    1453:	b8 07 00 00 00       	mov    $0x7,%eax
    1458:	cd 40                	int    $0x40
    145a:	c3                   	ret    

0000145b <open>:
SYSCALL(open)
    145b:	b8 0f 00 00 00       	mov    $0xf,%eax
    1460:	cd 40                	int    $0x40
    1462:	c3                   	ret    

00001463 <mknod>:
SYSCALL(mknod)
    1463:	b8 11 00 00 00       	mov    $0x11,%eax
    1468:	cd 40                	int    $0x40
    146a:	c3                   	ret    

0000146b <unlink>:
SYSCALL(unlink)
    146b:	b8 12 00 00 00       	mov    $0x12,%eax
    1470:	cd 40                	int    $0x40
    1472:	c3                   	ret    

00001473 <fstat>:
SYSCALL(fstat)
    1473:	b8 08 00 00 00       	mov    $0x8,%eax
    1478:	cd 40                	int    $0x40
    147a:	c3                   	ret    

0000147b <link>:
SYSCALL(link)
    147b:	b8 13 00 00 00       	mov    $0x13,%eax
    1480:	cd 40                	int    $0x40
    1482:	c3                   	ret    

00001483 <mkdir>:
SYSCALL(mkdir)
    1483:	b8 14 00 00 00       	mov    $0x14,%eax
    1488:	cd 40                	int    $0x40
    148a:	c3                   	ret    

0000148b <chdir>:
SYSCALL(chdir)
    148b:	b8 09 00 00 00       	mov    $0x9,%eax
    1490:	cd 40                	int    $0x40
    1492:	c3                   	ret    

00001493 <dup>:
SYSCALL(dup)
    1493:	b8 0a 00 00 00       	mov    $0xa,%eax
    1498:	cd 40                	int    $0x40
    149a:	c3                   	ret    

0000149b <getpid>:
SYSCALL(getpid)
    149b:	b8 0b 00 00 00       	mov    $0xb,%eax
    14a0:	cd 40                	int    $0x40
    14a2:	c3                   	ret    

000014a3 <sbrk>:
SYSCALL(sbrk)
    14a3:	b8 0c 00 00 00       	mov    $0xc,%eax
    14a8:	cd 40                	int    $0x40
    14aa:	c3                   	ret    

000014ab <sleep>:
SYSCALL(sleep)
    14ab:	b8 0d 00 00 00       	mov    $0xd,%eax
    14b0:	cd 40                	int    $0x40
    14b2:	c3                   	ret    

000014b3 <uptime>:
SYSCALL(uptime)
    14b3:	b8 0e 00 00 00       	mov    $0xe,%eax
    14b8:	cd 40                	int    $0x40
    14ba:	c3                   	ret    

000014bb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    14bb:	55                   	push   %ebp
    14bc:	89 e5                	mov    %esp,%ebp
    14be:	83 ec 18             	sub    $0x18,%esp
    14c1:	8b 45 0c             	mov    0xc(%ebp),%eax
    14c4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    14c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    14ce:	00 
    14cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
    14d2:	89 44 24 04          	mov    %eax,0x4(%esp)
    14d6:	8b 45 08             	mov    0x8(%ebp),%eax
    14d9:	89 04 24             	mov    %eax,(%esp)
    14dc:	e8 5a ff ff ff       	call   143b <write>
}
    14e1:	c9                   	leave  
    14e2:	c3                   	ret    

000014e3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    14e3:	55                   	push   %ebp
    14e4:	89 e5                	mov    %esp,%ebp
    14e6:	56                   	push   %esi
    14e7:	53                   	push   %ebx
    14e8:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    14eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    14f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    14f6:	74 17                	je     150f <printint+0x2c>
    14f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    14fc:	79 11                	jns    150f <printint+0x2c>
    neg = 1;
    14fe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1505:	8b 45 0c             	mov    0xc(%ebp),%eax
    1508:	f7 d8                	neg    %eax
    150a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    150d:	eb 06                	jmp    1515 <printint+0x32>
  } else {
    x = xx;
    150f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1512:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1515:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    151c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    151f:	8d 41 01             	lea    0x1(%ecx),%eax
    1522:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1525:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1528:	8b 45 ec             	mov    -0x14(%ebp),%eax
    152b:	ba 00 00 00 00       	mov    $0x0,%edx
    1530:	f7 f3                	div    %ebx
    1532:	89 d0                	mov    %edx,%eax
    1534:	0f b6 80 d8 1b 00 00 	movzbl 0x1bd8(%eax),%eax
    153b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    153f:	8b 75 10             	mov    0x10(%ebp),%esi
    1542:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1545:	ba 00 00 00 00       	mov    $0x0,%edx
    154a:	f7 f6                	div    %esi
    154c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    154f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1553:	75 c7                	jne    151c <printint+0x39>
  if(neg)
    1555:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1559:	74 10                	je     156b <printint+0x88>
    buf[i++] = '-';
    155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    155e:	8d 50 01             	lea    0x1(%eax),%edx
    1561:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1564:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1569:	eb 1f                	jmp    158a <printint+0xa7>
    156b:	eb 1d                	jmp    158a <printint+0xa7>
    putc(fd, buf[i]);
    156d:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1570:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1573:	01 d0                	add    %edx,%eax
    1575:	0f b6 00             	movzbl (%eax),%eax
    1578:	0f be c0             	movsbl %al,%eax
    157b:	89 44 24 04          	mov    %eax,0x4(%esp)
    157f:	8b 45 08             	mov    0x8(%ebp),%eax
    1582:	89 04 24             	mov    %eax,(%esp)
    1585:	e8 31 ff ff ff       	call   14bb <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    158a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    158e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1592:	79 d9                	jns    156d <printint+0x8a>
    putc(fd, buf[i]);
}
    1594:	83 c4 30             	add    $0x30,%esp
    1597:	5b                   	pop    %ebx
    1598:	5e                   	pop    %esi
    1599:	5d                   	pop    %ebp
    159a:	c3                   	ret    

0000159b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    159b:	55                   	push   %ebp
    159c:	89 e5                	mov    %esp,%ebp
    159e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    15a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    15a8:	8d 45 0c             	lea    0xc(%ebp),%eax
    15ab:	83 c0 04             	add    $0x4,%eax
    15ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    15b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    15b8:	e9 7c 01 00 00       	jmp    1739 <printf+0x19e>
    c = fmt[i] & 0xff;
    15bd:	8b 55 0c             	mov    0xc(%ebp),%edx
    15c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15c3:	01 d0                	add    %edx,%eax
    15c5:	0f b6 00             	movzbl (%eax),%eax
    15c8:	0f be c0             	movsbl %al,%eax
    15cb:	25 ff 00 00 00       	and    $0xff,%eax
    15d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    15d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    15d7:	75 2c                	jne    1605 <printf+0x6a>
      if(c == '%'){
    15d9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15dd:	75 0c                	jne    15eb <printf+0x50>
        state = '%';
    15df:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    15e6:	e9 4a 01 00 00       	jmp    1735 <printf+0x19a>
      } else {
        putc(fd, c);
    15eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15ee:	0f be c0             	movsbl %al,%eax
    15f1:	89 44 24 04          	mov    %eax,0x4(%esp)
    15f5:	8b 45 08             	mov    0x8(%ebp),%eax
    15f8:	89 04 24             	mov    %eax,(%esp)
    15fb:	e8 bb fe ff ff       	call   14bb <putc>
    1600:	e9 30 01 00 00       	jmp    1735 <printf+0x19a>
      }
    } else if(state == '%'){
    1605:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1609:	0f 85 26 01 00 00    	jne    1735 <printf+0x19a>
      if(c == 'd'){
    160f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1613:	75 2d                	jne    1642 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1615:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1618:	8b 00                	mov    (%eax),%eax
    161a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1621:	00 
    1622:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1629:	00 
    162a:	89 44 24 04          	mov    %eax,0x4(%esp)
    162e:	8b 45 08             	mov    0x8(%ebp),%eax
    1631:	89 04 24             	mov    %eax,(%esp)
    1634:	e8 aa fe ff ff       	call   14e3 <printint>
        ap++;
    1639:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    163d:	e9 ec 00 00 00       	jmp    172e <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    1642:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1646:	74 06                	je     164e <printf+0xb3>
    1648:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    164c:	75 2d                	jne    167b <printf+0xe0>
        printint(fd, *ap, 16, 0);
    164e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1651:	8b 00                	mov    (%eax),%eax
    1653:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    165a:	00 
    165b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1662:	00 
    1663:	89 44 24 04          	mov    %eax,0x4(%esp)
    1667:	8b 45 08             	mov    0x8(%ebp),%eax
    166a:	89 04 24             	mov    %eax,(%esp)
    166d:	e8 71 fe ff ff       	call   14e3 <printint>
        ap++;
    1672:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1676:	e9 b3 00 00 00       	jmp    172e <printf+0x193>
      } else if(c == 's'){
    167b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    167f:	75 45                	jne    16c6 <printf+0x12b>
        s = (char*)*ap;
    1681:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1684:	8b 00                	mov    (%eax),%eax
    1686:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1689:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    168d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1691:	75 09                	jne    169c <printf+0x101>
          s = "(null)";
    1693:	c7 45 f4 8a 19 00 00 	movl   $0x198a,-0xc(%ebp)
        while(*s != 0){
    169a:	eb 1e                	jmp    16ba <printf+0x11f>
    169c:	eb 1c                	jmp    16ba <printf+0x11f>
          putc(fd, *s);
    169e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16a1:	0f b6 00             	movzbl (%eax),%eax
    16a4:	0f be c0             	movsbl %al,%eax
    16a7:	89 44 24 04          	mov    %eax,0x4(%esp)
    16ab:	8b 45 08             	mov    0x8(%ebp),%eax
    16ae:	89 04 24             	mov    %eax,(%esp)
    16b1:	e8 05 fe ff ff       	call   14bb <putc>
          s++;
    16b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    16ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16bd:	0f b6 00             	movzbl (%eax),%eax
    16c0:	84 c0                	test   %al,%al
    16c2:	75 da                	jne    169e <printf+0x103>
    16c4:	eb 68                	jmp    172e <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    16c6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    16ca:	75 1d                	jne    16e9 <printf+0x14e>
        putc(fd, *ap);
    16cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16cf:	8b 00                	mov    (%eax),%eax
    16d1:	0f be c0             	movsbl %al,%eax
    16d4:	89 44 24 04          	mov    %eax,0x4(%esp)
    16d8:	8b 45 08             	mov    0x8(%ebp),%eax
    16db:	89 04 24             	mov    %eax,(%esp)
    16de:	e8 d8 fd ff ff       	call   14bb <putc>
        ap++;
    16e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    16e7:	eb 45                	jmp    172e <printf+0x193>
      } else if(c == '%'){
    16e9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    16ed:	75 17                	jne    1706 <printf+0x16b>
        putc(fd, c);
    16ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    16f2:	0f be c0             	movsbl %al,%eax
    16f5:	89 44 24 04          	mov    %eax,0x4(%esp)
    16f9:	8b 45 08             	mov    0x8(%ebp),%eax
    16fc:	89 04 24             	mov    %eax,(%esp)
    16ff:	e8 b7 fd ff ff       	call   14bb <putc>
    1704:	eb 28                	jmp    172e <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1706:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    170d:	00 
    170e:	8b 45 08             	mov    0x8(%ebp),%eax
    1711:	89 04 24             	mov    %eax,(%esp)
    1714:	e8 a2 fd ff ff       	call   14bb <putc>
        putc(fd, c);
    1719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    171c:	0f be c0             	movsbl %al,%eax
    171f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1723:	8b 45 08             	mov    0x8(%ebp),%eax
    1726:	89 04 24             	mov    %eax,(%esp)
    1729:	e8 8d fd ff ff       	call   14bb <putc>
      }
      state = 0;
    172e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1735:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1739:	8b 55 0c             	mov    0xc(%ebp),%edx
    173c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    173f:	01 d0                	add    %edx,%eax
    1741:	0f b6 00             	movzbl (%eax),%eax
    1744:	84 c0                	test   %al,%al
    1746:	0f 85 71 fe ff ff    	jne    15bd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    174c:	c9                   	leave  
    174d:	c3                   	ret    

0000174e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    174e:	55                   	push   %ebp
    174f:	89 e5                	mov    %esp,%ebp
    1751:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1754:	8b 45 08             	mov    0x8(%ebp),%eax
    1757:	83 e8 08             	sub    $0x8,%eax
    175a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    175d:	a1 f4 1b 00 00       	mov    0x1bf4,%eax
    1762:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1765:	eb 24                	jmp    178b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1767:	8b 45 fc             	mov    -0x4(%ebp),%eax
    176a:	8b 00                	mov    (%eax),%eax
    176c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    176f:	77 12                	ja     1783 <free+0x35>
    1771:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1774:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1777:	77 24                	ja     179d <free+0x4f>
    1779:	8b 45 fc             	mov    -0x4(%ebp),%eax
    177c:	8b 00                	mov    (%eax),%eax
    177e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1781:	77 1a                	ja     179d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1783:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1786:	8b 00                	mov    (%eax),%eax
    1788:	89 45 fc             	mov    %eax,-0x4(%ebp)
    178b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    178e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1791:	76 d4                	jbe    1767 <free+0x19>
    1793:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1796:	8b 00                	mov    (%eax),%eax
    1798:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    179b:	76 ca                	jbe    1767 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    179d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17a0:	8b 40 04             	mov    0x4(%eax),%eax
    17a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    17aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17ad:	01 c2                	add    %eax,%edx
    17af:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17b2:	8b 00                	mov    (%eax),%eax
    17b4:	39 c2                	cmp    %eax,%edx
    17b6:	75 24                	jne    17dc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    17b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17bb:	8b 50 04             	mov    0x4(%eax),%edx
    17be:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17c1:	8b 00                	mov    (%eax),%eax
    17c3:	8b 40 04             	mov    0x4(%eax),%eax
    17c6:	01 c2                	add    %eax,%edx
    17c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17cb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    17ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17d1:	8b 00                	mov    (%eax),%eax
    17d3:	8b 10                	mov    (%eax),%edx
    17d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17d8:	89 10                	mov    %edx,(%eax)
    17da:	eb 0a                	jmp    17e6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    17dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17df:	8b 10                	mov    (%eax),%edx
    17e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17e4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    17e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17e9:	8b 40 04             	mov    0x4(%eax),%eax
    17ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    17f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17f6:	01 d0                	add    %edx,%eax
    17f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17fb:	75 20                	jne    181d <free+0xcf>
    p->s.size += bp->s.size;
    17fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1800:	8b 50 04             	mov    0x4(%eax),%edx
    1803:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1806:	8b 40 04             	mov    0x4(%eax),%eax
    1809:	01 c2                	add    %eax,%edx
    180b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    180e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1811:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1814:	8b 10                	mov    (%eax),%edx
    1816:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1819:	89 10                	mov    %edx,(%eax)
    181b:	eb 08                	jmp    1825 <free+0xd7>
  } else
    p->s.ptr = bp;
    181d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1820:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1823:	89 10                	mov    %edx,(%eax)
  freep = p;
    1825:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1828:	a3 f4 1b 00 00       	mov    %eax,0x1bf4
}
    182d:	c9                   	leave  
    182e:	c3                   	ret    

0000182f <morecore>:

static Header*
morecore(uint nu)
{
    182f:	55                   	push   %ebp
    1830:	89 e5                	mov    %esp,%ebp
    1832:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1835:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    183c:	77 07                	ja     1845 <morecore+0x16>
    nu = 4096;
    183e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1845:	8b 45 08             	mov    0x8(%ebp),%eax
    1848:	c1 e0 03             	shl    $0x3,%eax
    184b:	89 04 24             	mov    %eax,(%esp)
    184e:	e8 50 fc ff ff       	call   14a3 <sbrk>
    1853:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1856:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    185a:	75 07                	jne    1863 <morecore+0x34>
    return 0;
    185c:	b8 00 00 00 00       	mov    $0x0,%eax
    1861:	eb 22                	jmp    1885 <morecore+0x56>
  hp = (Header*)p;
    1863:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1866:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1869:	8b 45 f0             	mov    -0x10(%ebp),%eax
    186c:	8b 55 08             	mov    0x8(%ebp),%edx
    186f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1872:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1875:	83 c0 08             	add    $0x8,%eax
    1878:	89 04 24             	mov    %eax,(%esp)
    187b:	e8 ce fe ff ff       	call   174e <free>
  return freep;
    1880:	a1 f4 1b 00 00       	mov    0x1bf4,%eax
}
    1885:	c9                   	leave  
    1886:	c3                   	ret    

00001887 <malloc>:

void*
malloc(uint nbytes)
{
    1887:	55                   	push   %ebp
    1888:	89 e5                	mov    %esp,%ebp
    188a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    188d:	8b 45 08             	mov    0x8(%ebp),%eax
    1890:	83 c0 07             	add    $0x7,%eax
    1893:	c1 e8 03             	shr    $0x3,%eax
    1896:	83 c0 01             	add    $0x1,%eax
    1899:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    189c:	a1 f4 1b 00 00       	mov    0x1bf4,%eax
    18a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    18a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    18a8:	75 23                	jne    18cd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    18aa:	c7 45 f0 ec 1b 00 00 	movl   $0x1bec,-0x10(%ebp)
    18b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18b4:	a3 f4 1b 00 00       	mov    %eax,0x1bf4
    18b9:	a1 f4 1b 00 00       	mov    0x1bf4,%eax
    18be:	a3 ec 1b 00 00       	mov    %eax,0x1bec
    base.s.size = 0;
    18c3:	c7 05 f0 1b 00 00 00 	movl   $0x0,0x1bf0
    18ca:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    18cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18d0:	8b 00                	mov    (%eax),%eax
    18d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    18d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18d8:	8b 40 04             	mov    0x4(%eax),%eax
    18db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    18de:	72 4d                	jb     192d <malloc+0xa6>
      if(p->s.size == nunits)
    18e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18e3:	8b 40 04             	mov    0x4(%eax),%eax
    18e6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    18e9:	75 0c                	jne    18f7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    18eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18ee:	8b 10                	mov    (%eax),%edx
    18f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18f3:	89 10                	mov    %edx,(%eax)
    18f5:	eb 26                	jmp    191d <malloc+0x96>
      else {
        p->s.size -= nunits;
    18f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18fa:	8b 40 04             	mov    0x4(%eax),%eax
    18fd:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1900:	89 c2                	mov    %eax,%edx
    1902:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1905:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1908:	8b 45 f4             	mov    -0xc(%ebp),%eax
    190b:	8b 40 04             	mov    0x4(%eax),%eax
    190e:	c1 e0 03             	shl    $0x3,%eax
    1911:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1914:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1917:	8b 55 ec             	mov    -0x14(%ebp),%edx
    191a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1920:	a3 f4 1b 00 00       	mov    %eax,0x1bf4
      return (void*)(p + 1);
    1925:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1928:	83 c0 08             	add    $0x8,%eax
    192b:	eb 38                	jmp    1965 <malloc+0xde>
    }
    if(p == freep)
    192d:	a1 f4 1b 00 00       	mov    0x1bf4,%eax
    1932:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1935:	75 1b                	jne    1952 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    1937:	8b 45 ec             	mov    -0x14(%ebp),%eax
    193a:	89 04 24             	mov    %eax,(%esp)
    193d:	e8 ed fe ff ff       	call   182f <morecore>
    1942:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1949:	75 07                	jne    1952 <malloc+0xcb>
        return 0;
    194b:	b8 00 00 00 00       	mov    $0x0,%eax
    1950:	eb 13                	jmp    1965 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1952:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1955:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1958:	8b 45 f4             	mov    -0xc(%ebp),%eax
    195b:	8b 00                	mov    (%eax),%eax
    195d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1960:	e9 70 ff ff ff       	jmp    18d5 <malloc+0x4e>
}
    1965:	c9                   	leave  
    1966:	c3                   	ret    
