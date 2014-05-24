
_wc:     file format elf32-i386


Disassembly of section .text:

00001000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
    1006:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    100d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1010:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1013:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1016:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
    1019:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1020:	eb 68                	jmp    108a <wc+0x8a>
    for(i=0; i<n; i++){
    1022:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1029:	eb 57                	jmp    1082 <wc+0x82>
      c++;
    102b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
    102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1032:	05 80 2c 00 00       	add    $0x2c80,%eax
    1037:	0f b6 00             	movzbl (%eax),%eax
    103a:	3c 0a                	cmp    $0xa,%al
    103c:	75 04                	jne    1042 <wc+0x42>
        l++;
    103e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
    1042:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1045:	05 80 2c 00 00       	add    $0x2c80,%eax
    104a:	0f b6 00             	movzbl (%eax),%eax
    104d:	0f be c0             	movsbl %al,%eax
    1050:	89 44 24 04          	mov    %eax,0x4(%esp)
    1054:	c7 04 24 8d 19 00 00 	movl   $0x198d,(%esp)
    105b:	e8 58 02 00 00       	call   12b8 <strchr>
    1060:	85 c0                	test   %eax,%eax
    1062:	74 09                	je     106d <wc+0x6d>
        inword = 0;
    1064:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    106b:	eb 11                	jmp    107e <wc+0x7e>
      else if(!inword){
    106d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1071:	75 0b                	jne    107e <wc+0x7e>
        w++;
    1073:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
    1077:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
    107e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1082:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1085:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    1088:	7c a1                	jl     102b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    108a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    1091:	00 
    1092:	c7 44 24 04 80 2c 00 	movl   $0x2c80,0x4(%esp)
    1099:	00 
    109a:	8b 45 08             	mov    0x8(%ebp),%eax
    109d:	89 04 24             	mov    %eax,(%esp)
    10a0:	e8 b4 03 00 00       	call   1459 <read>
    10a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    10a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    10ac:	0f 8f 70 ff ff ff    	jg     1022 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
    10b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    10b6:	79 19                	jns    10d1 <wc+0xd1>
    printf(1, "wc: read error\n");
    10b8:	c7 44 24 04 93 19 00 	movl   $0x1993,0x4(%esp)
    10bf:	00 
    10c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10c7:	e8 f5 04 00 00       	call   15c1 <printf>
    exit();
    10cc:	e8 70 03 00 00       	call   1441 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
    10d1:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d4:	89 44 24 14          	mov    %eax,0x14(%esp)
    10d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10db:	89 44 24 10          	mov    %eax,0x10(%esp)
    10df:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
    10e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10e9:	89 44 24 08          	mov    %eax,0x8(%esp)
    10ed:	c7 44 24 04 a3 19 00 	movl   $0x19a3,0x4(%esp)
    10f4:	00 
    10f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10fc:	e8 c0 04 00 00       	call   15c1 <printf>
}
    1101:	c9                   	leave  
    1102:	c3                   	ret    

00001103 <main>:

int
main(int argc, char *argv[])
{
    1103:	55                   	push   %ebp
    1104:	89 e5                	mov    %esp,%ebp
    1106:	83 e4 f0             	and    $0xfffffff0,%esp
    1109:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
    110c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
    1110:	7f 19                	jg     112b <main+0x28>
    wc(0, "");
    1112:	c7 44 24 04 b0 19 00 	movl   $0x19b0,0x4(%esp)
    1119:	00 
    111a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1121:	e8 da fe ff ff       	call   1000 <wc>
    exit();
    1126:	e8 16 03 00 00       	call   1441 <exit>
  }

  for(i = 1; i < argc; i++){
    112b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
    1132:	00 
    1133:	e9 8f 00 00 00       	jmp    11c7 <main+0xc4>
    if((fd = open(argv[i], 0)) < 0){
    1138:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    113c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1143:	8b 45 0c             	mov    0xc(%ebp),%eax
    1146:	01 d0                	add    %edx,%eax
    1148:	8b 00                	mov    (%eax),%eax
    114a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1151:	00 
    1152:	89 04 24             	mov    %eax,(%esp)
    1155:	e8 27 03 00 00       	call   1481 <open>
    115a:	89 44 24 18          	mov    %eax,0x18(%esp)
    115e:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
    1163:	79 2f                	jns    1194 <main+0x91>
      printf(1, "cat: cannot open %s\n", argv[i]);
    1165:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1169:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1170:	8b 45 0c             	mov    0xc(%ebp),%eax
    1173:	01 d0                	add    %edx,%eax
    1175:	8b 00                	mov    (%eax),%eax
    1177:	89 44 24 08          	mov    %eax,0x8(%esp)
    117b:	c7 44 24 04 b1 19 00 	movl   $0x19b1,0x4(%esp)
    1182:	00 
    1183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    118a:	e8 32 04 00 00       	call   15c1 <printf>
      exit();
    118f:	e8 ad 02 00 00       	call   1441 <exit>
    }
    wc(fd, argv[i]);
    1194:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    1198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    119f:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a2:	01 d0                	add    %edx,%eax
    11a4:	8b 00                	mov    (%eax),%eax
    11a6:	89 44 24 04          	mov    %eax,0x4(%esp)
    11aa:	8b 44 24 18          	mov    0x18(%esp),%eax
    11ae:	89 04 24             	mov    %eax,(%esp)
    11b1:	e8 4a fe ff ff       	call   1000 <wc>
    close(fd);
    11b6:	8b 44 24 18          	mov    0x18(%esp),%eax
    11ba:	89 04 24             	mov    %eax,(%esp)
    11bd:	e8 a7 02 00 00       	call   1469 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
    11c2:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
    11c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
    11cb:	3b 45 08             	cmp    0x8(%ebp),%eax
    11ce:	0f 8c 64 ff ff ff    	jl     1138 <main+0x35>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
    11d4:	e8 68 02 00 00       	call   1441 <exit>

000011d9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    11d9:	55                   	push   %ebp
    11da:	89 e5                	mov    %esp,%ebp
    11dc:	57                   	push   %edi
    11dd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    11de:	8b 4d 08             	mov    0x8(%ebp),%ecx
    11e1:	8b 55 10             	mov    0x10(%ebp),%edx
    11e4:	8b 45 0c             	mov    0xc(%ebp),%eax
    11e7:	89 cb                	mov    %ecx,%ebx
    11e9:	89 df                	mov    %ebx,%edi
    11eb:	89 d1                	mov    %edx,%ecx
    11ed:	fc                   	cld    
    11ee:	f3 aa                	rep stos %al,%es:(%edi)
    11f0:	89 ca                	mov    %ecx,%edx
    11f2:	89 fb                	mov    %edi,%ebx
    11f4:	89 5d 08             	mov    %ebx,0x8(%ebp)
    11f7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    11fa:	5b                   	pop    %ebx
    11fb:	5f                   	pop    %edi
    11fc:	5d                   	pop    %ebp
    11fd:	c3                   	ret    

000011fe <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    11fe:	55                   	push   %ebp
    11ff:	89 e5                	mov    %esp,%ebp
    1201:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1204:	8b 45 08             	mov    0x8(%ebp),%eax
    1207:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    120a:	90                   	nop
    120b:	8b 45 08             	mov    0x8(%ebp),%eax
    120e:	8d 50 01             	lea    0x1(%eax),%edx
    1211:	89 55 08             	mov    %edx,0x8(%ebp)
    1214:	8b 55 0c             	mov    0xc(%ebp),%edx
    1217:	8d 4a 01             	lea    0x1(%edx),%ecx
    121a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    121d:	0f b6 12             	movzbl (%edx),%edx
    1220:	88 10                	mov    %dl,(%eax)
    1222:	0f b6 00             	movzbl (%eax),%eax
    1225:	84 c0                	test   %al,%al
    1227:	75 e2                	jne    120b <strcpy+0xd>
    ;
  return os;
    1229:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    122c:	c9                   	leave  
    122d:	c3                   	ret    

0000122e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    122e:	55                   	push   %ebp
    122f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1231:	eb 08                	jmp    123b <strcmp+0xd>
    p++, q++;
    1233:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1237:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    123b:	8b 45 08             	mov    0x8(%ebp),%eax
    123e:	0f b6 00             	movzbl (%eax),%eax
    1241:	84 c0                	test   %al,%al
    1243:	74 10                	je     1255 <strcmp+0x27>
    1245:	8b 45 08             	mov    0x8(%ebp),%eax
    1248:	0f b6 10             	movzbl (%eax),%edx
    124b:	8b 45 0c             	mov    0xc(%ebp),%eax
    124e:	0f b6 00             	movzbl (%eax),%eax
    1251:	38 c2                	cmp    %al,%dl
    1253:	74 de                	je     1233 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1255:	8b 45 08             	mov    0x8(%ebp),%eax
    1258:	0f b6 00             	movzbl (%eax),%eax
    125b:	0f b6 d0             	movzbl %al,%edx
    125e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1261:	0f b6 00             	movzbl (%eax),%eax
    1264:	0f b6 c0             	movzbl %al,%eax
    1267:	29 c2                	sub    %eax,%edx
    1269:	89 d0                	mov    %edx,%eax
}
    126b:	5d                   	pop    %ebp
    126c:	c3                   	ret    

0000126d <strlen>:

uint
strlen(char *s)
{
    126d:	55                   	push   %ebp
    126e:	89 e5                	mov    %esp,%ebp
    1270:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1273:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    127a:	eb 04                	jmp    1280 <strlen+0x13>
    127c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1280:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1283:	8b 45 08             	mov    0x8(%ebp),%eax
    1286:	01 d0                	add    %edx,%eax
    1288:	0f b6 00             	movzbl (%eax),%eax
    128b:	84 c0                	test   %al,%al
    128d:	75 ed                	jne    127c <strlen+0xf>
    ;
  return n;
    128f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1292:	c9                   	leave  
    1293:	c3                   	ret    

00001294 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1294:	55                   	push   %ebp
    1295:	89 e5                	mov    %esp,%ebp
    1297:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    129a:	8b 45 10             	mov    0x10(%ebp),%eax
    129d:	89 44 24 08          	mov    %eax,0x8(%esp)
    12a1:	8b 45 0c             	mov    0xc(%ebp),%eax
    12a4:	89 44 24 04          	mov    %eax,0x4(%esp)
    12a8:	8b 45 08             	mov    0x8(%ebp),%eax
    12ab:	89 04 24             	mov    %eax,(%esp)
    12ae:	e8 26 ff ff ff       	call   11d9 <stosb>
  return dst;
    12b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12b6:	c9                   	leave  
    12b7:	c3                   	ret    

000012b8 <strchr>:

char*
strchr(const char *s, char c)
{
    12b8:	55                   	push   %ebp
    12b9:	89 e5                	mov    %esp,%ebp
    12bb:	83 ec 04             	sub    $0x4,%esp
    12be:	8b 45 0c             	mov    0xc(%ebp),%eax
    12c1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    12c4:	eb 14                	jmp    12da <strchr+0x22>
    if(*s == c)
    12c6:	8b 45 08             	mov    0x8(%ebp),%eax
    12c9:	0f b6 00             	movzbl (%eax),%eax
    12cc:	3a 45 fc             	cmp    -0x4(%ebp),%al
    12cf:	75 05                	jne    12d6 <strchr+0x1e>
      return (char*)s;
    12d1:	8b 45 08             	mov    0x8(%ebp),%eax
    12d4:	eb 13                	jmp    12e9 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    12d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12da:	8b 45 08             	mov    0x8(%ebp),%eax
    12dd:	0f b6 00             	movzbl (%eax),%eax
    12e0:	84 c0                	test   %al,%al
    12e2:	75 e2                	jne    12c6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    12e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
    12e9:	c9                   	leave  
    12ea:	c3                   	ret    

000012eb <gets>:

char*
gets(char *buf, int max)
{
    12eb:	55                   	push   %ebp
    12ec:	89 e5                	mov    %esp,%ebp
    12ee:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    12f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    12f8:	eb 4c                	jmp    1346 <gets+0x5b>
    cc = read(0, &c, 1);
    12fa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1301:	00 
    1302:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1305:	89 44 24 04          	mov    %eax,0x4(%esp)
    1309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1310:	e8 44 01 00 00       	call   1459 <read>
    1315:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1318:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    131c:	7f 02                	jg     1320 <gets+0x35>
      break;
    131e:	eb 31                	jmp    1351 <gets+0x66>
    buf[i++] = c;
    1320:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1323:	8d 50 01             	lea    0x1(%eax),%edx
    1326:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1329:	89 c2                	mov    %eax,%edx
    132b:	8b 45 08             	mov    0x8(%ebp),%eax
    132e:	01 c2                	add    %eax,%edx
    1330:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1334:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1336:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    133a:	3c 0a                	cmp    $0xa,%al
    133c:	74 13                	je     1351 <gets+0x66>
    133e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1342:	3c 0d                	cmp    $0xd,%al
    1344:	74 0b                	je     1351 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1346:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1349:	83 c0 01             	add    $0x1,%eax
    134c:	3b 45 0c             	cmp    0xc(%ebp),%eax
    134f:	7c a9                	jl     12fa <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1351:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1354:	8b 45 08             	mov    0x8(%ebp),%eax
    1357:	01 d0                	add    %edx,%eax
    1359:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    135c:	8b 45 08             	mov    0x8(%ebp),%eax
}
    135f:	c9                   	leave  
    1360:	c3                   	ret    

00001361 <stat>:

int
stat(char *n, struct stat *st)
{
    1361:	55                   	push   %ebp
    1362:	89 e5                	mov    %esp,%ebp
    1364:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1367:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    136e:	00 
    136f:	8b 45 08             	mov    0x8(%ebp),%eax
    1372:	89 04 24             	mov    %eax,(%esp)
    1375:	e8 07 01 00 00       	call   1481 <open>
    137a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    137d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1381:	79 07                	jns    138a <stat+0x29>
    return -1;
    1383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1388:	eb 23                	jmp    13ad <stat+0x4c>
  r = fstat(fd, st);
    138a:	8b 45 0c             	mov    0xc(%ebp),%eax
    138d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1391:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1394:	89 04 24             	mov    %eax,(%esp)
    1397:	e8 fd 00 00 00       	call   1499 <fstat>
    139c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13a2:	89 04 24             	mov    %eax,(%esp)
    13a5:	e8 bf 00 00 00       	call   1469 <close>
  return r;
    13aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    13ad:	c9                   	leave  
    13ae:	c3                   	ret    

000013af <atoi>:

int
atoi(const char *s)
{
    13af:	55                   	push   %ebp
    13b0:	89 e5                	mov    %esp,%ebp
    13b2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    13b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    13bc:	eb 25                	jmp    13e3 <atoi+0x34>
    n = n*10 + *s++ - '0';
    13be:	8b 55 fc             	mov    -0x4(%ebp),%edx
    13c1:	89 d0                	mov    %edx,%eax
    13c3:	c1 e0 02             	shl    $0x2,%eax
    13c6:	01 d0                	add    %edx,%eax
    13c8:	01 c0                	add    %eax,%eax
    13ca:	89 c1                	mov    %eax,%ecx
    13cc:	8b 45 08             	mov    0x8(%ebp),%eax
    13cf:	8d 50 01             	lea    0x1(%eax),%edx
    13d2:	89 55 08             	mov    %edx,0x8(%ebp)
    13d5:	0f b6 00             	movzbl (%eax),%eax
    13d8:	0f be c0             	movsbl %al,%eax
    13db:	01 c8                	add    %ecx,%eax
    13dd:	83 e8 30             	sub    $0x30,%eax
    13e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    13e3:	8b 45 08             	mov    0x8(%ebp),%eax
    13e6:	0f b6 00             	movzbl (%eax),%eax
    13e9:	3c 2f                	cmp    $0x2f,%al
    13eb:	7e 0a                	jle    13f7 <atoi+0x48>
    13ed:	8b 45 08             	mov    0x8(%ebp),%eax
    13f0:	0f b6 00             	movzbl (%eax),%eax
    13f3:	3c 39                	cmp    $0x39,%al
    13f5:	7e c7                	jle    13be <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    13f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    13fa:	c9                   	leave  
    13fb:	c3                   	ret    

000013fc <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    13fc:	55                   	push   %ebp
    13fd:	89 e5                	mov    %esp,%ebp
    13ff:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1402:	8b 45 08             	mov    0x8(%ebp),%eax
    1405:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1408:	8b 45 0c             	mov    0xc(%ebp),%eax
    140b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    140e:	eb 17                	jmp    1427 <memmove+0x2b>
    *dst++ = *src++;
    1410:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1413:	8d 50 01             	lea    0x1(%eax),%edx
    1416:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1419:	8b 55 f8             	mov    -0x8(%ebp),%edx
    141c:	8d 4a 01             	lea    0x1(%edx),%ecx
    141f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1422:	0f b6 12             	movzbl (%edx),%edx
    1425:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1427:	8b 45 10             	mov    0x10(%ebp),%eax
    142a:	8d 50 ff             	lea    -0x1(%eax),%edx
    142d:	89 55 10             	mov    %edx,0x10(%ebp)
    1430:	85 c0                	test   %eax,%eax
    1432:	7f dc                	jg     1410 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1434:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1437:	c9                   	leave  
    1438:	c3                   	ret    

00001439 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1439:	b8 01 00 00 00       	mov    $0x1,%eax
    143e:	cd 40                	int    $0x40
    1440:	c3                   	ret    

00001441 <exit>:
SYSCALL(exit)
    1441:	b8 02 00 00 00       	mov    $0x2,%eax
    1446:	cd 40                	int    $0x40
    1448:	c3                   	ret    

00001449 <wait>:
SYSCALL(wait)
    1449:	b8 03 00 00 00       	mov    $0x3,%eax
    144e:	cd 40                	int    $0x40
    1450:	c3                   	ret    

00001451 <pipe>:
SYSCALL(pipe)
    1451:	b8 04 00 00 00       	mov    $0x4,%eax
    1456:	cd 40                	int    $0x40
    1458:	c3                   	ret    

00001459 <read>:
SYSCALL(read)
    1459:	b8 05 00 00 00       	mov    $0x5,%eax
    145e:	cd 40                	int    $0x40
    1460:	c3                   	ret    

00001461 <write>:
SYSCALL(write)
    1461:	b8 10 00 00 00       	mov    $0x10,%eax
    1466:	cd 40                	int    $0x40
    1468:	c3                   	ret    

00001469 <close>:
SYSCALL(close)
    1469:	b8 15 00 00 00       	mov    $0x15,%eax
    146e:	cd 40                	int    $0x40
    1470:	c3                   	ret    

00001471 <kill>:
SYSCALL(kill)
    1471:	b8 06 00 00 00       	mov    $0x6,%eax
    1476:	cd 40                	int    $0x40
    1478:	c3                   	ret    

00001479 <exec>:
SYSCALL(exec)
    1479:	b8 07 00 00 00       	mov    $0x7,%eax
    147e:	cd 40                	int    $0x40
    1480:	c3                   	ret    

00001481 <open>:
SYSCALL(open)
    1481:	b8 0f 00 00 00       	mov    $0xf,%eax
    1486:	cd 40                	int    $0x40
    1488:	c3                   	ret    

00001489 <mknod>:
SYSCALL(mknod)
    1489:	b8 11 00 00 00       	mov    $0x11,%eax
    148e:	cd 40                	int    $0x40
    1490:	c3                   	ret    

00001491 <unlink>:
SYSCALL(unlink)
    1491:	b8 12 00 00 00       	mov    $0x12,%eax
    1496:	cd 40                	int    $0x40
    1498:	c3                   	ret    

00001499 <fstat>:
SYSCALL(fstat)
    1499:	b8 08 00 00 00       	mov    $0x8,%eax
    149e:	cd 40                	int    $0x40
    14a0:	c3                   	ret    

000014a1 <link>:
SYSCALL(link)
    14a1:	b8 13 00 00 00       	mov    $0x13,%eax
    14a6:	cd 40                	int    $0x40
    14a8:	c3                   	ret    

000014a9 <mkdir>:
SYSCALL(mkdir)
    14a9:	b8 14 00 00 00       	mov    $0x14,%eax
    14ae:	cd 40                	int    $0x40
    14b0:	c3                   	ret    

000014b1 <chdir>:
SYSCALL(chdir)
    14b1:	b8 09 00 00 00       	mov    $0x9,%eax
    14b6:	cd 40                	int    $0x40
    14b8:	c3                   	ret    

000014b9 <dup>:
SYSCALL(dup)
    14b9:	b8 0a 00 00 00       	mov    $0xa,%eax
    14be:	cd 40                	int    $0x40
    14c0:	c3                   	ret    

000014c1 <getpid>:
SYSCALL(getpid)
    14c1:	b8 0b 00 00 00       	mov    $0xb,%eax
    14c6:	cd 40                	int    $0x40
    14c8:	c3                   	ret    

000014c9 <sbrk>:
SYSCALL(sbrk)
    14c9:	b8 0c 00 00 00       	mov    $0xc,%eax
    14ce:	cd 40                	int    $0x40
    14d0:	c3                   	ret    

000014d1 <sleep>:
SYSCALL(sleep)
    14d1:	b8 0d 00 00 00       	mov    $0xd,%eax
    14d6:	cd 40                	int    $0x40
    14d8:	c3                   	ret    

000014d9 <uptime>:
SYSCALL(uptime)
    14d9:	b8 0e 00 00 00       	mov    $0xe,%eax
    14de:	cd 40                	int    $0x40
    14e0:	c3                   	ret    

000014e1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    14e1:	55                   	push   %ebp
    14e2:	89 e5                	mov    %esp,%ebp
    14e4:	83 ec 18             	sub    $0x18,%esp
    14e7:	8b 45 0c             	mov    0xc(%ebp),%eax
    14ea:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    14ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    14f4:	00 
    14f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
    14f8:	89 44 24 04          	mov    %eax,0x4(%esp)
    14fc:	8b 45 08             	mov    0x8(%ebp),%eax
    14ff:	89 04 24             	mov    %eax,(%esp)
    1502:	e8 5a ff ff ff       	call   1461 <write>
}
    1507:	c9                   	leave  
    1508:	c3                   	ret    

00001509 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1509:	55                   	push   %ebp
    150a:	89 e5                	mov    %esp,%ebp
    150c:	56                   	push   %esi
    150d:	53                   	push   %ebx
    150e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1511:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1518:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    151c:	74 17                	je     1535 <printint+0x2c>
    151e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1522:	79 11                	jns    1535 <printint+0x2c>
    neg = 1;
    1524:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    152b:	8b 45 0c             	mov    0xc(%ebp),%eax
    152e:	f7 d8                	neg    %eax
    1530:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1533:	eb 06                	jmp    153b <printint+0x32>
  } else {
    x = xx;
    1535:	8b 45 0c             	mov    0xc(%ebp),%eax
    1538:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    153b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1542:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1545:	8d 41 01             	lea    0x1(%ecx),%eax
    1548:	89 45 f4             	mov    %eax,-0xc(%ebp)
    154b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    154e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1551:	ba 00 00 00 00       	mov    $0x0,%edx
    1556:	f7 f3                	div    %ebx
    1558:	89 d0                	mov    %edx,%eax
    155a:	0f b6 80 34 2c 00 00 	movzbl 0x2c34(%eax),%eax
    1561:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1565:	8b 75 10             	mov    0x10(%ebp),%esi
    1568:	8b 45 ec             	mov    -0x14(%ebp),%eax
    156b:	ba 00 00 00 00       	mov    $0x0,%edx
    1570:	f7 f6                	div    %esi
    1572:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1575:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1579:	75 c7                	jne    1542 <printint+0x39>
  if(neg)
    157b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    157f:	74 10                	je     1591 <printint+0x88>
    buf[i++] = '-';
    1581:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1584:	8d 50 01             	lea    0x1(%eax),%edx
    1587:	89 55 f4             	mov    %edx,-0xc(%ebp)
    158a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    158f:	eb 1f                	jmp    15b0 <printint+0xa7>
    1591:	eb 1d                	jmp    15b0 <printint+0xa7>
    putc(fd, buf[i]);
    1593:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1596:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1599:	01 d0                	add    %edx,%eax
    159b:	0f b6 00             	movzbl (%eax),%eax
    159e:	0f be c0             	movsbl %al,%eax
    15a1:	89 44 24 04          	mov    %eax,0x4(%esp)
    15a5:	8b 45 08             	mov    0x8(%ebp),%eax
    15a8:	89 04 24             	mov    %eax,(%esp)
    15ab:	e8 31 ff ff ff       	call   14e1 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    15b0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    15b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15b8:	79 d9                	jns    1593 <printint+0x8a>
    putc(fd, buf[i]);
}
    15ba:	83 c4 30             	add    $0x30,%esp
    15bd:	5b                   	pop    %ebx
    15be:	5e                   	pop    %esi
    15bf:	5d                   	pop    %ebp
    15c0:	c3                   	ret    

000015c1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    15c1:	55                   	push   %ebp
    15c2:	89 e5                	mov    %esp,%ebp
    15c4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    15c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    15ce:	8d 45 0c             	lea    0xc(%ebp),%eax
    15d1:	83 c0 04             	add    $0x4,%eax
    15d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    15d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    15de:	e9 7c 01 00 00       	jmp    175f <printf+0x19e>
    c = fmt[i] & 0xff;
    15e3:	8b 55 0c             	mov    0xc(%ebp),%edx
    15e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15e9:	01 d0                	add    %edx,%eax
    15eb:	0f b6 00             	movzbl (%eax),%eax
    15ee:	0f be c0             	movsbl %al,%eax
    15f1:	25 ff 00 00 00       	and    $0xff,%eax
    15f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    15f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    15fd:	75 2c                	jne    162b <printf+0x6a>
      if(c == '%'){
    15ff:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1603:	75 0c                	jne    1611 <printf+0x50>
        state = '%';
    1605:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    160c:	e9 4a 01 00 00       	jmp    175b <printf+0x19a>
      } else {
        putc(fd, c);
    1611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1614:	0f be c0             	movsbl %al,%eax
    1617:	89 44 24 04          	mov    %eax,0x4(%esp)
    161b:	8b 45 08             	mov    0x8(%ebp),%eax
    161e:	89 04 24             	mov    %eax,(%esp)
    1621:	e8 bb fe ff ff       	call   14e1 <putc>
    1626:	e9 30 01 00 00       	jmp    175b <printf+0x19a>
      }
    } else if(state == '%'){
    162b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    162f:	0f 85 26 01 00 00    	jne    175b <printf+0x19a>
      if(c == 'd'){
    1635:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1639:	75 2d                	jne    1668 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    163b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    163e:	8b 00                	mov    (%eax),%eax
    1640:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1647:	00 
    1648:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    164f:	00 
    1650:	89 44 24 04          	mov    %eax,0x4(%esp)
    1654:	8b 45 08             	mov    0x8(%ebp),%eax
    1657:	89 04 24             	mov    %eax,(%esp)
    165a:	e8 aa fe ff ff       	call   1509 <printint>
        ap++;
    165f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1663:	e9 ec 00 00 00       	jmp    1754 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    1668:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    166c:	74 06                	je     1674 <printf+0xb3>
    166e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1672:	75 2d                	jne    16a1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    1674:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1677:	8b 00                	mov    (%eax),%eax
    1679:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1680:	00 
    1681:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1688:	00 
    1689:	89 44 24 04          	mov    %eax,0x4(%esp)
    168d:	8b 45 08             	mov    0x8(%ebp),%eax
    1690:	89 04 24             	mov    %eax,(%esp)
    1693:	e8 71 fe ff ff       	call   1509 <printint>
        ap++;
    1698:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    169c:	e9 b3 00 00 00       	jmp    1754 <printf+0x193>
      } else if(c == 's'){
    16a1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    16a5:	75 45                	jne    16ec <printf+0x12b>
        s = (char*)*ap;
    16a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16aa:	8b 00                	mov    (%eax),%eax
    16ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    16af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    16b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    16b7:	75 09                	jne    16c2 <printf+0x101>
          s = "(null)";
    16b9:	c7 45 f4 c6 19 00 00 	movl   $0x19c6,-0xc(%ebp)
        while(*s != 0){
    16c0:	eb 1e                	jmp    16e0 <printf+0x11f>
    16c2:	eb 1c                	jmp    16e0 <printf+0x11f>
          putc(fd, *s);
    16c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16c7:	0f b6 00             	movzbl (%eax),%eax
    16ca:	0f be c0             	movsbl %al,%eax
    16cd:	89 44 24 04          	mov    %eax,0x4(%esp)
    16d1:	8b 45 08             	mov    0x8(%ebp),%eax
    16d4:	89 04 24             	mov    %eax,(%esp)
    16d7:	e8 05 fe ff ff       	call   14e1 <putc>
          s++;
    16dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    16e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16e3:	0f b6 00             	movzbl (%eax),%eax
    16e6:	84 c0                	test   %al,%al
    16e8:	75 da                	jne    16c4 <printf+0x103>
    16ea:	eb 68                	jmp    1754 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    16ec:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    16f0:	75 1d                	jne    170f <printf+0x14e>
        putc(fd, *ap);
    16f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16f5:	8b 00                	mov    (%eax),%eax
    16f7:	0f be c0             	movsbl %al,%eax
    16fa:	89 44 24 04          	mov    %eax,0x4(%esp)
    16fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1701:	89 04 24             	mov    %eax,(%esp)
    1704:	e8 d8 fd ff ff       	call   14e1 <putc>
        ap++;
    1709:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    170d:	eb 45                	jmp    1754 <printf+0x193>
      } else if(c == '%'){
    170f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1713:	75 17                	jne    172c <printf+0x16b>
        putc(fd, c);
    1715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1718:	0f be c0             	movsbl %al,%eax
    171b:	89 44 24 04          	mov    %eax,0x4(%esp)
    171f:	8b 45 08             	mov    0x8(%ebp),%eax
    1722:	89 04 24             	mov    %eax,(%esp)
    1725:	e8 b7 fd ff ff       	call   14e1 <putc>
    172a:	eb 28                	jmp    1754 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    172c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1733:	00 
    1734:	8b 45 08             	mov    0x8(%ebp),%eax
    1737:	89 04 24             	mov    %eax,(%esp)
    173a:	e8 a2 fd ff ff       	call   14e1 <putc>
        putc(fd, c);
    173f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1742:	0f be c0             	movsbl %al,%eax
    1745:	89 44 24 04          	mov    %eax,0x4(%esp)
    1749:	8b 45 08             	mov    0x8(%ebp),%eax
    174c:	89 04 24             	mov    %eax,(%esp)
    174f:	e8 8d fd ff ff       	call   14e1 <putc>
      }
      state = 0;
    1754:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    175b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    175f:	8b 55 0c             	mov    0xc(%ebp),%edx
    1762:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1765:	01 d0                	add    %edx,%eax
    1767:	0f b6 00             	movzbl (%eax),%eax
    176a:	84 c0                	test   %al,%al
    176c:	0f 85 71 fe ff ff    	jne    15e3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1772:	c9                   	leave  
    1773:	c3                   	ret    

00001774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1774:	55                   	push   %ebp
    1775:	89 e5                	mov    %esp,%ebp
    1777:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    177a:	8b 45 08             	mov    0x8(%ebp),%eax
    177d:	83 e8 08             	sub    $0x8,%eax
    1780:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1783:	a1 68 2c 00 00       	mov    0x2c68,%eax
    1788:	89 45 fc             	mov    %eax,-0x4(%ebp)
    178b:	eb 24                	jmp    17b1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    178d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1790:	8b 00                	mov    (%eax),%eax
    1792:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1795:	77 12                	ja     17a9 <free+0x35>
    1797:	8b 45 f8             	mov    -0x8(%ebp),%eax
    179a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    179d:	77 24                	ja     17c3 <free+0x4f>
    179f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17a2:	8b 00                	mov    (%eax),%eax
    17a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17a7:	77 1a                	ja     17c3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    17a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17ac:	8b 00                	mov    (%eax),%eax
    17ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    17b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17b4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    17b7:	76 d4                	jbe    178d <free+0x19>
    17b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17bc:	8b 00                	mov    (%eax),%eax
    17be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17c1:	76 ca                	jbe    178d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    17c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17c6:	8b 40 04             	mov    0x4(%eax),%eax
    17c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    17d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17d3:	01 c2                	add    %eax,%edx
    17d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17d8:	8b 00                	mov    (%eax),%eax
    17da:	39 c2                	cmp    %eax,%edx
    17dc:	75 24                	jne    1802 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    17de:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17e1:	8b 50 04             	mov    0x4(%eax),%edx
    17e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17e7:	8b 00                	mov    (%eax),%eax
    17e9:	8b 40 04             	mov    0x4(%eax),%eax
    17ec:	01 c2                	add    %eax,%edx
    17ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17f1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    17f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17f7:	8b 00                	mov    (%eax),%eax
    17f9:	8b 10                	mov    (%eax),%edx
    17fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17fe:	89 10                	mov    %edx,(%eax)
    1800:	eb 0a                	jmp    180c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1802:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1805:	8b 10                	mov    (%eax),%edx
    1807:	8b 45 f8             	mov    -0x8(%ebp),%eax
    180a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    180c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    180f:	8b 40 04             	mov    0x4(%eax),%eax
    1812:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1819:	8b 45 fc             	mov    -0x4(%ebp),%eax
    181c:	01 d0                	add    %edx,%eax
    181e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1821:	75 20                	jne    1843 <free+0xcf>
    p->s.size += bp->s.size;
    1823:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1826:	8b 50 04             	mov    0x4(%eax),%edx
    1829:	8b 45 f8             	mov    -0x8(%ebp),%eax
    182c:	8b 40 04             	mov    0x4(%eax),%eax
    182f:	01 c2                	add    %eax,%edx
    1831:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1834:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1837:	8b 45 f8             	mov    -0x8(%ebp),%eax
    183a:	8b 10                	mov    (%eax),%edx
    183c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    183f:	89 10                	mov    %edx,(%eax)
    1841:	eb 08                	jmp    184b <free+0xd7>
  } else
    p->s.ptr = bp;
    1843:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1846:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1849:	89 10                	mov    %edx,(%eax)
  freep = p;
    184b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    184e:	a3 68 2c 00 00       	mov    %eax,0x2c68
}
    1853:	c9                   	leave  
    1854:	c3                   	ret    

00001855 <morecore>:

static Header*
morecore(uint nu)
{
    1855:	55                   	push   %ebp
    1856:	89 e5                	mov    %esp,%ebp
    1858:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    185b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1862:	77 07                	ja     186b <morecore+0x16>
    nu = 4096;
    1864:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    186b:	8b 45 08             	mov    0x8(%ebp),%eax
    186e:	c1 e0 03             	shl    $0x3,%eax
    1871:	89 04 24             	mov    %eax,(%esp)
    1874:	e8 50 fc ff ff       	call   14c9 <sbrk>
    1879:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    187c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1880:	75 07                	jne    1889 <morecore+0x34>
    return 0;
    1882:	b8 00 00 00 00       	mov    $0x0,%eax
    1887:	eb 22                	jmp    18ab <morecore+0x56>
  hp = (Header*)p;
    1889:	8b 45 f4             	mov    -0xc(%ebp),%eax
    188c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1892:	8b 55 08             	mov    0x8(%ebp),%edx
    1895:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1898:	8b 45 f0             	mov    -0x10(%ebp),%eax
    189b:	83 c0 08             	add    $0x8,%eax
    189e:	89 04 24             	mov    %eax,(%esp)
    18a1:	e8 ce fe ff ff       	call   1774 <free>
  return freep;
    18a6:	a1 68 2c 00 00       	mov    0x2c68,%eax
}
    18ab:	c9                   	leave  
    18ac:	c3                   	ret    

000018ad <malloc>:

void*
malloc(uint nbytes)
{
    18ad:	55                   	push   %ebp
    18ae:	89 e5                	mov    %esp,%ebp
    18b0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    18b3:	8b 45 08             	mov    0x8(%ebp),%eax
    18b6:	83 c0 07             	add    $0x7,%eax
    18b9:	c1 e8 03             	shr    $0x3,%eax
    18bc:	83 c0 01             	add    $0x1,%eax
    18bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    18c2:	a1 68 2c 00 00       	mov    0x2c68,%eax
    18c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    18ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    18ce:	75 23                	jne    18f3 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    18d0:	c7 45 f0 60 2c 00 00 	movl   $0x2c60,-0x10(%ebp)
    18d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18da:	a3 68 2c 00 00       	mov    %eax,0x2c68
    18df:	a1 68 2c 00 00       	mov    0x2c68,%eax
    18e4:	a3 60 2c 00 00       	mov    %eax,0x2c60
    base.s.size = 0;
    18e9:	c7 05 64 2c 00 00 00 	movl   $0x0,0x2c64
    18f0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    18f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18f6:	8b 00                	mov    (%eax),%eax
    18f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    18fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18fe:	8b 40 04             	mov    0x4(%eax),%eax
    1901:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1904:	72 4d                	jb     1953 <malloc+0xa6>
      if(p->s.size == nunits)
    1906:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1909:	8b 40 04             	mov    0x4(%eax),%eax
    190c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    190f:	75 0c                	jne    191d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1911:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1914:	8b 10                	mov    (%eax),%edx
    1916:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1919:	89 10                	mov    %edx,(%eax)
    191b:	eb 26                	jmp    1943 <malloc+0x96>
      else {
        p->s.size -= nunits;
    191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1920:	8b 40 04             	mov    0x4(%eax),%eax
    1923:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1926:	89 c2                	mov    %eax,%edx
    1928:	8b 45 f4             	mov    -0xc(%ebp),%eax
    192b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1931:	8b 40 04             	mov    0x4(%eax),%eax
    1934:	c1 e0 03             	shl    $0x3,%eax
    1937:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    193d:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1940:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1943:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1946:	a3 68 2c 00 00       	mov    %eax,0x2c68
      return (void*)(p + 1);
    194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    194e:	83 c0 08             	add    $0x8,%eax
    1951:	eb 38                	jmp    198b <malloc+0xde>
    }
    if(p == freep)
    1953:	a1 68 2c 00 00       	mov    0x2c68,%eax
    1958:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    195b:	75 1b                	jne    1978 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    195d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1960:	89 04 24             	mov    %eax,(%esp)
    1963:	e8 ed fe ff ff       	call   1855 <morecore>
    1968:	89 45 f4             	mov    %eax,-0xc(%ebp)
    196b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    196f:	75 07                	jne    1978 <malloc+0xcb>
        return 0;
    1971:	b8 00 00 00 00       	mov    $0x0,%eax
    1976:	eb 13                	jmp    198b <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1978:	8b 45 f4             	mov    -0xc(%ebp),%eax
    197b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1981:	8b 00                	mov    (%eax),%eax
    1983:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1986:	e9 70 ff ff ff       	jmp    18fb <malloc+0x4e>
}
    198b:	c9                   	leave  
    198c:	c3                   	ret    
