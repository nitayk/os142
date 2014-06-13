
_find:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "fs.h"
#include "fcntl.h"

char*
fmtname(char *path)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	53                   	push   %ebx
       4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
       7:	8b 45 08             	mov    0x8(%ebp),%eax
       a:	89 04 24             	mov    %eax,(%esp)
       d:	e8 e1 08 00 00       	call   8f3 <strlen>
      12:	8b 55 08             	mov    0x8(%ebp),%edx
      15:	01 d0                	add    %edx,%eax
      17:	89 45 f4             	mov    %eax,-0xc(%ebp)
      1a:	eb 04                	jmp    20 <fmtname+0x20>
      1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      20:	8b 45 f4             	mov    -0xc(%ebp),%eax
      23:	3b 45 08             	cmp    0x8(%ebp),%eax
      26:	72 0a                	jb     32 <fmtname+0x32>
      28:	8b 45 f4             	mov    -0xc(%ebp),%eax
      2b:	0f b6 00             	movzbl (%eax),%eax
      2e:	3c 2f                	cmp    $0x2f,%al
      30:	75 ea                	jne    1c <fmtname+0x1c>
    ;
  p++;
      32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	89 04 24             	mov    %eax,(%esp)
      3c:	e8 b2 08 00 00       	call   8f3 <strlen>
      41:	83 f8 0d             	cmp    $0xd,%eax
      44:	76 05                	jbe    4b <fmtname+0x4b>
    return p;
      46:	8b 45 f4             	mov    -0xc(%ebp),%eax
      49:	eb 5f                	jmp    aa <fmtname+0xaa>
  memmove(buf, p, strlen(p));
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	89 04 24             	mov    %eax,(%esp)
      51:	e8 9d 08 00 00       	call   8f3 <strlen>
      56:	89 44 24 08          	mov    %eax,0x8(%esp)
      5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
      5d:	89 44 24 04          	mov    %eax,0x4(%esp)
      61:	c7 04 24 94 14 00 00 	movl   $0x1494,(%esp)
      68:	e8 15 0a 00 00       	call   a82 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
      6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      70:	89 04 24             	mov    %eax,(%esp)
      73:	e8 7b 08 00 00       	call   8f3 <strlen>
      78:	ba 0e 00 00 00       	mov    $0xe,%edx
      7d:	89 d3                	mov    %edx,%ebx
      7f:	29 c3                	sub    %eax,%ebx
      81:	8b 45 f4             	mov    -0xc(%ebp),%eax
      84:	89 04 24             	mov    %eax,(%esp)
      87:	e8 67 08 00 00       	call   8f3 <strlen>
      8c:	05 94 14 00 00       	add    $0x1494,%eax
      91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
      95:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
      9c:	00 
      9d:	89 04 24             	mov    %eax,(%esp)
      a0:	e8 75 08 00 00       	call   91a <memset>
  return buf;
      a5:	b8 94 14 00 00       	mov    $0x1494,%eax
}
      aa:	83 c4 24             	add    $0x24,%esp
      ad:	5b                   	pop    %ebx
      ae:	5d                   	pop    %ebp
      af:	c3                   	ret    

000000b0 <basename>:

char* basename(char *path)
{
      b0:	55                   	push   %ebp
      b1:	89 e5                	mov    %esp,%ebp
      b3:	53                   	push   %ebx
      b4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
      b7:	8b 45 08             	mov    0x8(%ebp),%eax
      ba:	89 04 24             	mov    %eax,(%esp)
      bd:	e8 31 08 00 00       	call   8f3 <strlen>
      c2:	8b 55 08             	mov    0x8(%ebp),%edx
      c5:	01 d0                	add    %edx,%eax
      c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      ca:	eb 04                	jmp    d0 <basename+0x20>
      cc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
      d3:	3b 45 08             	cmp    0x8(%ebp),%eax
      d6:	72 0a                	jb     e2 <basename+0x32>
      d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
      db:	0f b6 00             	movzbl (%eax),%eax
      de:	3c 2f                	cmp    $0x2f,%al
      e0:	75 ea                	jne    cc <basename+0x1c>
    ;
  p++;
      e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
      e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
      e9:	89 04 24             	mov    %eax,(%esp)
      ec:	e8 02 08 00 00       	call   8f3 <strlen>
      f1:	83 f8 0d             	cmp    $0xd,%eax
      f4:	76 05                	jbe    fb <basename+0x4b>
    return p;
      f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
      f9:	eb 5f                	jmp    15a <basename+0xaa>
  memmove(buf, p, strlen(p));
      fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
      fe:	89 04 24             	mov    %eax,(%esp)
     101:	e8 ed 07 00 00       	call   8f3 <strlen>
     106:	89 44 24 08          	mov    %eax,0x8(%esp)
     10a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     10d:	89 44 24 04          	mov    %eax,0x4(%esp)
     111:	c7 04 24 a3 14 00 00 	movl   $0x14a3,(%esp)
     118:	e8 65 09 00 00       	call   a82 <memmove>
  memset(buf+strlen(p), '\0', DIRSIZ-strlen(p));
     11d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     120:	89 04 24             	mov    %eax,(%esp)
     123:	e8 cb 07 00 00       	call   8f3 <strlen>
     128:	ba 0e 00 00 00       	mov    $0xe,%edx
     12d:	89 d3                	mov    %edx,%ebx
     12f:	29 c3                	sub    %eax,%ebx
     131:	8b 45 f4             	mov    -0xc(%ebp),%eax
     134:	89 04 24             	mov    %eax,(%esp)
     137:	e8 b7 07 00 00       	call   8f3 <strlen>
     13c:	05 a3 14 00 00       	add    $0x14a3,%eax
     141:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     145:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     14c:	00 
     14d:	89 04 24             	mov    %eax,(%esp)
     150:	e8 c5 07 00 00       	call   91a <memset>
  return buf;
     155:	b8 a3 14 00 00       	mov    $0x14a3,%eax
}
     15a:	83 c4 24             	add    $0x24,%esp
     15d:	5b                   	pop    %ebx
     15e:	5d                   	pop    %ebp
     15f:	c3                   	ret    

00000160 <find>:

void find(char* path, int deref, char* name, char* type, int min_size, int max_size, int exact_size){
     160:	55                   	push   %ebp
     161:	89 e5                	mov    %esp,%ebp
     163:	81 ec 58 02 00 00    	sub    $0x258,%esp
    struct dirent de;
    struct stat st;
    char* basenamed;
    char buf[512], *p;
    
    if (deref){
     169:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     16d:	74 18                	je     187 <find+0x27>
        fd = open(path, 0);
     16f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     176:	00 
     177:	8b 45 08             	mov    0x8(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 85 09 00 00       	call   b07 <open>
     182:	89 45 f4             	mov    %eax,-0xc(%ebp)
     185:	eb 16                	jmp    19d <find+0x3d>
    }else{
        fd = open(path, O_NODEREF);
     187:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
     18e:	00 
     18f:	8b 45 08             	mov    0x8(%ebp),%eax
     192:	89 04 24             	mov    %eax,(%esp)
     195:	e8 6d 09 00 00       	call   b07 <open>
     19a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    
    if (fd < 0){
     19d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     1a1:	79 20                	jns    1c3 <find+0x63>
        printf(2, "find: cannot open path: %s\n", path);
     1a3:	8b 45 08             	mov    0x8(%ebp),%eax
     1a6:	89 44 24 08          	mov    %eax,0x8(%esp)
     1aa:	c7 44 24 04 3c 10 00 	movl   $0x103c,0x4(%esp)
     1b1:	00 
     1b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1b9:	e8 b1 0a 00 00       	call   c6f <printf>
        return;
     1be:	e9 3d 03 00 00       	jmp    500 <find+0x3a0>
    }
    
    if(fstat(fd, &st) < 0){
     1c3:	8d 45 c8             	lea    -0x38(%ebp),%eax
     1c6:	89 44 24 04          	mov    %eax,0x4(%esp)
     1ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1cd:	89 04 24             	mov    %eax,(%esp)
     1d0:	e8 4a 09 00 00       	call   b1f <fstat>
     1d5:	85 c0                	test   %eax,%eax
     1d7:	79 2b                	jns    204 <find+0xa4>
        printf(2, "find: cannot stat path: %s\n", path);
     1d9:	8b 45 08             	mov    0x8(%ebp),%eax
     1dc:	89 44 24 08          	mov    %eax,0x8(%esp)
     1e0:	c7 44 24 04 58 10 00 	movl   $0x1058,0x4(%esp)
     1e7:	00 
     1e8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1ef:	e8 7b 0a 00 00       	call   c6f <printf>
        close(fd);
     1f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1f7:	89 04 24             	mov    %eax,(%esp)
     1fa:	e8 f0 08 00 00       	call   aef <close>
        return;
     1ff:	e9 fc 02 00 00       	jmp    500 <find+0x3a0>
    }
    
    basenamed = basename(path);
     204:	8b 45 08             	mov    0x8(%ebp),%eax
     207:	89 04 24             	mov    %eax,(%esp)
     20a:	e8 a1 fe ff ff       	call   b0 <basename>
     20f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    switch(st.type){
     212:	0f b7 45 c8          	movzwl -0x38(%ebp),%eax
     216:	98                   	cwtl   
     217:	83 f8 02             	cmp    $0x2,%eax
     21a:	0f 84 93 00 00 00    	je     2b3 <find+0x153>
     220:	83 f8 04             	cmp    $0x4,%eax
     223:	74 0e                	je     233 <find+0xd3>
     225:	83 f8 01             	cmp    $0x1,%eax
     228:	0f 84 51 01 00 00    	je     37f <find+0x21f>
     22e:	e9 c2 02 00 00       	jmp    4f5 <find+0x395>
        case T_SYMLINK:
            if (strcmp(type,"s") == 0 || strcmp(type,"*") == 0){
     233:	c7 44 24 04 74 10 00 	movl   $0x1074,0x4(%esp)
     23a:	00 
     23b:	8b 45 14             	mov    0x14(%ebp),%eax
     23e:	89 04 24             	mov    %eax,(%esp)
     241:	e8 6e 06 00 00       	call   8b4 <strcmp>
     246:	85 c0                	test   %eax,%eax
     248:	74 17                	je     261 <find+0x101>
     24a:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     251:	00 
     252:	8b 45 14             	mov    0x14(%ebp),%eax
     255:	89 04 24             	mov    %eax,(%esp)
     258:	e8 57 06 00 00       	call   8b4 <strcmp>
     25d:	85 c0                	test   %eax,%eax
     25f:	75 4d                	jne    2ae <find+0x14e>
                if (strcmp(name,"*") == 0 || strcmp(name,basenamed) == 0){
     261:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     268:	00 
     269:	8b 45 10             	mov    0x10(%ebp),%eax
     26c:	89 04 24             	mov    %eax,(%esp)
     26f:	e8 40 06 00 00       	call   8b4 <strcmp>
     274:	85 c0                	test   %eax,%eax
     276:	74 16                	je     28e <find+0x12e>
     278:	8b 45 f0             	mov    -0x10(%ebp),%eax
     27b:	89 44 24 04          	mov    %eax,0x4(%esp)
     27f:	8b 45 10             	mov    0x10(%ebp),%eax
     282:	89 04 24             	mov    %eax,(%esp)
     285:	e8 2a 06 00 00       	call   8b4 <strcmp>
     28a:	85 c0                	test   %eax,%eax
     28c:	75 20                	jne    2ae <find+0x14e>
                    printf(1,"FOUND Link: %s\n",path);
     28e:	8b 45 08             	mov    0x8(%ebp),%eax
     291:	89 44 24 08          	mov    %eax,0x8(%esp)
     295:	c7 44 24 04 78 10 00 	movl   $0x1078,0x4(%esp)
     29c:	00 
     29d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2a4:	e8 c6 09 00 00       	call   c6f <printf>
                }
            }
            break;
     2a9:	e9 47 02 00 00       	jmp    4f5 <find+0x395>
     2ae:	e9 42 02 00 00       	jmp    4f5 <find+0x395>
        
        case T_FILE:
            if (strcmp(name,"*") != 0 && strcmp(name,fmtname(path)) != 0){
     2b3:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     2ba:	00 
     2bb:	8b 45 10             	mov    0x10(%ebp),%eax
     2be:	89 04 24             	mov    %eax,(%esp)
     2c1:	e8 ee 05 00 00       	call   8b4 <strcmp>
     2c6:	85 c0                	test   %eax,%eax
     2c8:	74 23                	je     2ed <find+0x18d>
     2ca:	8b 45 08             	mov    0x8(%ebp),%eax
     2cd:	89 04 24             	mov    %eax,(%esp)
     2d0:	e8 2b fd ff ff       	call   0 <fmtname>
     2d5:	89 44 24 04          	mov    %eax,0x4(%esp)
     2d9:	8b 45 10             	mov    0x10(%ebp),%eax
     2dc:	89 04 24             	mov    %eax,(%esp)
     2df:	e8 d0 05 00 00       	call   8b4 <strcmp>
     2e4:	85 c0                	test   %eax,%eax
     2e6:	74 05                	je     2ed <find+0x18d>
                break;
     2e8:	e9 08 02 00 00       	jmp    4f5 <find+0x395>
            }
            if (strcmp(type,"*") != 0 && strcmp(type,"f") != 0){
     2ed:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     2f4:	00 
     2f5:	8b 45 14             	mov    0x14(%ebp),%eax
     2f8:	89 04 24             	mov    %eax,(%esp)
     2fb:	e8 b4 05 00 00       	call   8b4 <strcmp>
     300:	85 c0                	test   %eax,%eax
     302:	74 1c                	je     320 <find+0x1c0>
     304:	c7 44 24 04 88 10 00 	movl   $0x1088,0x4(%esp)
     30b:	00 
     30c:	8b 45 14             	mov    0x14(%ebp),%eax
     30f:	89 04 24             	mov    %eax,(%esp)
     312:	e8 9d 05 00 00       	call   8b4 <strcmp>
     317:	85 c0                	test   %eax,%eax
     319:	74 05                	je     320 <find+0x1c0>
                break;
     31b:	e9 d5 01 00 00       	jmp    4f5 <find+0x395>
            }
            if (min_size > -1 && st.size < min_size){
     320:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
     324:	78 0f                	js     335 <find+0x1d5>
     326:	8b 55 d8             	mov    -0x28(%ebp),%edx
     329:	8b 45 18             	mov    0x18(%ebp),%eax
     32c:	39 c2                	cmp    %eax,%edx
     32e:	73 05                	jae    335 <find+0x1d5>
                break;
     330:	e9 c0 01 00 00       	jmp    4f5 <find+0x395>
            }
            if (max_size > -1 && st.size > max_size){
     335:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
     339:	78 0f                	js     34a <find+0x1ea>
     33b:	8b 55 d8             	mov    -0x28(%ebp),%edx
     33e:	8b 45 1c             	mov    0x1c(%ebp),%eax
     341:	39 c2                	cmp    %eax,%edx
     343:	76 05                	jbe    34a <find+0x1ea>
                break;
     345:	e9 ab 01 00 00       	jmp    4f5 <find+0x395>
            }
            if (exact_size > -1 && st.size != exact_size){
     34a:	83 7d 20 00          	cmpl   $0x0,0x20(%ebp)
     34e:	78 0f                	js     35f <find+0x1ff>
     350:	8b 55 d8             	mov    -0x28(%ebp),%edx
     353:	8b 45 20             	mov    0x20(%ebp),%eax
     356:	39 c2                	cmp    %eax,%edx
     358:	74 05                	je     35f <find+0x1ff>
                break;
     35a:	e9 96 01 00 00       	jmp    4f5 <find+0x395>
            }
            printf(1,"FOUND File: %s\n",path);
     35f:	8b 45 08             	mov    0x8(%ebp),%eax
     362:	89 44 24 08          	mov    %eax,0x8(%esp)
     366:	c7 44 24 04 8a 10 00 	movl   $0x108a,0x4(%esp)
     36d:	00 
     36e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     375:	e8 f5 08 00 00       	call   c6f <printf>
            break;
     37a:	e9 76 01 00 00       	jmp    4f5 <find+0x395>
            
        case T_DIR:
            if (strcmp(type,"d") == 0 || strcmp(type,"*") == 0){
     37f:	c7 44 24 04 9a 10 00 	movl   $0x109a,0x4(%esp)
     386:	00 
     387:	8b 45 14             	mov    0x14(%ebp),%eax
     38a:	89 04 24             	mov    %eax,(%esp)
     38d:	e8 22 05 00 00       	call   8b4 <strcmp>
     392:	85 c0                	test   %eax,%eax
     394:	74 17                	je     3ad <find+0x24d>
     396:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     39d:	00 
     39e:	8b 45 14             	mov    0x14(%ebp),%eax
     3a1:	89 04 24             	mov    %eax,(%esp)
     3a4:	e8 0b 05 00 00       	call   8b4 <strcmp>
     3a9:	85 c0                	test   %eax,%eax
     3ab:	75 48                	jne    3f5 <find+0x295>
                if (strcmp(name,"*") == 0 || strcmp(name,basenamed) == 0){
     3ad:	c7 44 24 04 76 10 00 	movl   $0x1076,0x4(%esp)
     3b4:	00 
     3b5:	8b 45 10             	mov    0x10(%ebp),%eax
     3b8:	89 04 24             	mov    %eax,(%esp)
     3bb:	e8 f4 04 00 00       	call   8b4 <strcmp>
     3c0:	85 c0                	test   %eax,%eax
     3c2:	74 16                	je     3da <find+0x27a>
     3c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3c7:	89 44 24 04          	mov    %eax,0x4(%esp)
     3cb:	8b 45 10             	mov    0x10(%ebp),%eax
     3ce:	89 04 24             	mov    %eax,(%esp)
     3d1:	e8 de 04 00 00       	call   8b4 <strcmp>
     3d6:	85 c0                	test   %eax,%eax
     3d8:	75 1b                	jne    3f5 <find+0x295>
                    printf(1,"FOUND Directory: %s\n",path);
     3da:	8b 45 08             	mov    0x8(%ebp),%eax
     3dd:	89 44 24 08          	mov    %eax,0x8(%esp)
     3e1:	c7 44 24 04 9c 10 00 	movl   $0x109c,0x4(%esp)
     3e8:	00 
     3e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3f0:	e8 7a 08 00 00       	call   c6f <printf>
                }
            }
            strcpy(buf, path);
     3f5:	8b 45 08             	mov    0x8(%ebp),%eax
     3f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     3fc:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     402:	89 04 24             	mov    %eax,(%esp)
     405:	e8 7a 04 00 00       	call   884 <strcpy>
            p = buf+strlen(buf);
     40a:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     410:	89 04 24             	mov    %eax,(%esp)
     413:	e8 db 04 00 00       	call   8f3 <strlen>
     418:	8d 95 c8 fd ff ff    	lea    -0x238(%ebp),%edx
     41e:	01 d0                	add    %edx,%eax
     420:	89 45 ec             	mov    %eax,-0x14(%ebp)
            *p++ = '/';
     423:	8b 45 ec             	mov    -0x14(%ebp),%eax
     426:	8d 50 01             	lea    0x1(%eax),%edx
     429:	89 55 ec             	mov    %edx,-0x14(%ebp)
     42c:	c6 00 2f             	movb   $0x2f,(%eax)
            while(read(fd, &de, sizeof(de)) == sizeof(de)){
     42f:	e9 9d 00 00 00       	jmp    4d1 <find+0x371>
              if(de.inum == 0 || strcmp(de.name,".")==0 || strcmp(de.name,"..")==0)
     434:	0f b7 45 dc          	movzwl -0x24(%ebp),%eax
     438:	66 85 c0             	test   %ax,%ax
     43b:	74 34                	je     471 <find+0x311>
     43d:	c7 44 24 04 b1 10 00 	movl   $0x10b1,0x4(%esp)
     444:	00 
     445:	8d 45 dc             	lea    -0x24(%ebp),%eax
     448:	83 c0 02             	add    $0x2,%eax
     44b:	89 04 24             	mov    %eax,(%esp)
     44e:	e8 61 04 00 00       	call   8b4 <strcmp>
     453:	85 c0                	test   %eax,%eax
     455:	74 1a                	je     471 <find+0x311>
     457:	c7 44 24 04 b3 10 00 	movl   $0x10b3,0x4(%esp)
     45e:	00 
     45f:	8d 45 dc             	lea    -0x24(%ebp),%eax
     462:	83 c0 02             	add    $0x2,%eax
     465:	89 04 24             	mov    %eax,(%esp)
     468:	e8 47 04 00 00       	call   8b4 <strcmp>
     46d:	85 c0                	test   %eax,%eax
     46f:	75 02                	jne    473 <find+0x313>
                continue;
     471:	eb 5e                	jmp    4d1 <find+0x371>
              memmove(p, de.name, DIRSIZ);
     473:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
     47a:	00 
     47b:	8d 45 dc             	lea    -0x24(%ebp),%eax
     47e:	83 c0 02             	add    $0x2,%eax
     481:	89 44 24 04          	mov    %eax,0x4(%esp)
     485:	8b 45 ec             	mov    -0x14(%ebp),%eax
     488:	89 04 24             	mov    %eax,(%esp)
     48b:	e8 f2 05 00 00       	call   a82 <memmove>
              p[DIRSIZ] = 0;
     490:	8b 45 ec             	mov    -0x14(%ebp),%eax
     493:	83 c0 0e             	add    $0xe,%eax
     496:	c6 00 00             	movb   $0x0,(%eax)

              //printf(1,"DEBUG: Calling find with path: %s\n",buf);
              find(buf, deref, name, type, min_size, max_size, exact_size);
     499:	8b 45 20             	mov    0x20(%ebp),%eax
     49c:	89 44 24 18          	mov    %eax,0x18(%esp)
     4a0:	8b 45 1c             	mov    0x1c(%ebp),%eax
     4a3:	89 44 24 14          	mov    %eax,0x14(%esp)
     4a7:	8b 45 18             	mov    0x18(%ebp),%eax
     4aa:	89 44 24 10          	mov    %eax,0x10(%esp)
     4ae:	8b 45 14             	mov    0x14(%ebp),%eax
     4b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
     4b5:	8b 45 10             	mov    0x10(%ebp),%eax
     4b8:	89 44 24 08          	mov    %eax,0x8(%esp)
     4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
     4bf:	89 44 24 04          	mov    %eax,0x4(%esp)
     4c3:	8d 85 c8 fd ff ff    	lea    -0x238(%ebp),%eax
     4c9:	89 04 24             	mov    %eax,(%esp)
     4cc:	e8 8f fc ff ff       	call   160 <find>
                }
            }
            strcpy(buf, path);
            p = buf+strlen(buf);
            *p++ = '/';
            while(read(fd, &de, sizeof(de)) == sizeof(de)){
     4d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     4d8:	00 
     4d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
     4dc:	89 44 24 04          	mov    %eax,0x4(%esp)
     4e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4e3:	89 04 24             	mov    %eax,(%esp)
     4e6:	e8 f4 05 00 00       	call   adf <read>
     4eb:	83 f8 10             	cmp    $0x10,%eax
     4ee:	0f 84 40 ff ff ff    	je     434 <find+0x2d4>
              p[DIRSIZ] = 0;

              //printf(1,"DEBUG: Calling find with path: %s\n",buf);
              find(buf, deref, name, type, min_size, max_size, exact_size);
            }
            break;
     4f4:	90                   	nop
    }
    
    close(fd);
     4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f8:	89 04 24             	mov    %eax,(%esp)
     4fb:	e8 ef 05 00 00       	call   aef <close>
    
}
     500:	c9                   	leave  
     501:	c3                   	ret    

00000502 <main>:


int
main(int argc, char *argv[])
{
     502:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     506:	83 e4 f0             	and    $0xfffffff0,%esp
     509:	ff 71 fc             	pushl  -0x4(%ecx)
     50c:	55                   	push   %ebp
     50d:	89 e5                	mov    %esp,%ebp
     50f:	57                   	push   %edi
     510:	56                   	push   %esi
     511:	53                   	push   %ebx
     512:	51                   	push   %ecx
     513:	83 ec 58             	sub    $0x58,%esp
     516:	89 cb                	mov    %ecx,%ebx
  
  if (argc < 2){
     518:	83 3b 01             	cmpl   $0x1,(%ebx)
     51b:	7f 19                	jg     536 <main+0x34>
    printf(1,"find: Not enough arguments (path is required)\n");
     51d:	c7 44 24 04 b8 10 00 	movl   $0x10b8,0x4(%esp)
     524:	00 
     525:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     52c:	e8 3e 07 00 00       	call   c6f <printf>
    exit();
     531:	e8 91 05 00 00       	call   ac7 <exit>
  }
  
  char* path = argv[1];
     536:	8b 43 04             	mov    0x4(%ebx),%eax
     539:	8b 40 04             	mov    0x4(%eax),%eax
     53c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  
  /* Default values */
  int deref = 0;
     53f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  char* name = "*";
     546:	c7 45 e0 76 10 00 00 	movl   $0x1076,-0x20(%ebp)
  char* type = "*";
     54d:	c7 45 dc 76 10 00 00 	movl   $0x1076,-0x24(%ebp)
  int min_size = -1;
     554:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  int max_size = -1;
     55b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  int exact_size = -1;
     562:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  int len = 0;
     569:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  
  int i;

  /* Parsing arguments */
  for(i=2; i<argc; i++){
     570:	c7 45 cc 02 00 00 00 	movl   $0x2,-0x34(%ebp)
     577:	e9 9e 02 00 00       	jmp    81a <main+0x318>
    if (strcmp(argv[i],"-help") == 0){
     57c:	8b 45 cc             	mov    -0x34(%ebp),%eax
     57f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     586:	8b 43 04             	mov    0x4(%ebx),%eax
     589:	01 d0                	add    %edx,%eax
     58b:	8b 00                	mov    (%eax),%eax
     58d:	c7 44 24 04 e7 10 00 	movl   $0x10e7,0x4(%esp)
     594:	00 
     595:	89 04 24             	mov    %eax,(%esp)
     598:	e8 17 03 00 00       	call   8b4 <strcmp>
     59d:	85 c0                	test   %eax,%eax
     59f:	75 19                	jne    5ba <main+0xb8>
        printf(1,"Usage: find <path> <options> <preds>\n");
     5a1:	c7 44 24 04 f0 10 00 	movl   $0x10f0,0x4(%esp)
     5a8:	00 
     5a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     5b0:	e8 ba 06 00 00       	call   c6f <printf>
        exit();
     5b5:	e8 0d 05 00 00       	call   ac7 <exit>
    }
    else if (strcmp(argv[i],"-follow") == 0){
     5ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
     5bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     5c4:	8b 43 04             	mov    0x4(%ebx),%eax
     5c7:	01 d0                	add    %edx,%eax
     5c9:	8b 00                	mov    (%eax),%eax
     5cb:	c7 44 24 04 16 11 00 	movl   $0x1116,0x4(%esp)
     5d2:	00 
     5d3:	89 04 24             	mov    %eax,(%esp)
     5d6:	e8 d9 02 00 00       	call   8b4 <strcmp>
     5db:	85 c0                	test   %eax,%eax
     5dd:	75 0c                	jne    5eb <main+0xe9>
        deref = 1;
     5df:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
     5e6:	e9 2b 02 00 00       	jmp    816 <main+0x314>
    }
    else if (strcmp(argv[i],"-name") == 0){
     5eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
     5ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     5f5:	8b 43 04             	mov    0x4(%ebx),%eax
     5f8:	01 d0                	add    %edx,%eax
     5fa:	8b 00                	mov    (%eax),%eax
     5fc:	c7 44 24 04 1e 11 00 	movl   $0x111e,0x4(%esp)
     603:	00 
     604:	89 04 24             	mov    %eax,(%esp)
     607:	e8 a8 02 00 00       	call   8b4 <strcmp>
     60c:	85 c0                	test   %eax,%eax
     60e:	75 3d                	jne    64d <main+0x14b>
        i = i + 1;
     610:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
        if (i >= argc){
     614:	8b 45 cc             	mov    -0x34(%ebp),%eax
     617:	3b 03                	cmp    (%ebx),%eax
     619:	7c 19                	jl     634 <main+0x132>
            printf(1,"Wrong usage. Name not specified after -name\n");
     61b:	c7 44 24 04 24 11 00 	movl   $0x1124,0x4(%esp)
     622:	00 
     623:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     62a:	e8 40 06 00 00       	call   c6f <printf>
            exit();
     62f:	e8 93 04 00 00       	call   ac7 <exit>
        }
        name = argv[i];
     634:	8b 45 cc             	mov    -0x34(%ebp),%eax
     637:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     63e:	8b 43 04             	mov    0x4(%ebx),%eax
     641:	01 d0                	add    %edx,%eax
     643:	8b 00                	mov    (%eax),%eax
     645:	89 45 e0             	mov    %eax,-0x20(%ebp)
     648:	e9 c9 01 00 00       	jmp    816 <main+0x314>
    }
    else if (strcmp(argv[i],"-type") == 0){
     64d:	8b 45 cc             	mov    -0x34(%ebp),%eax
     650:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     657:	8b 43 04             	mov    0x4(%ebx),%eax
     65a:	01 d0                	add    %edx,%eax
     65c:	8b 00                	mov    (%eax),%eax
     65e:	c7 44 24 04 51 11 00 	movl   $0x1151,0x4(%esp)
     665:	00 
     666:	89 04 24             	mov    %eax,(%esp)
     669:	e8 46 02 00 00       	call   8b4 <strcmp>
     66e:	85 c0                	test   %eax,%eax
     670:	75 3d                	jne    6af <main+0x1ad>
        i = i + 1;
     672:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
        if (i >= argc){
     676:	8b 45 cc             	mov    -0x34(%ebp),%eax
     679:	3b 03                	cmp    (%ebx),%eax
     67b:	7c 19                	jl     696 <main+0x194>
            printf(1,"Wrong usage. Type not specified after -type\n");
     67d:	c7 44 24 04 58 11 00 	movl   $0x1158,0x4(%esp)
     684:	00 
     685:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     68c:	e8 de 05 00 00       	call   c6f <printf>
            exit();
     691:	e8 31 04 00 00       	call   ac7 <exit>
        }
        type = argv[i];
     696:	8b 45 cc             	mov    -0x34(%ebp),%eax
     699:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     6a0:	8b 43 04             	mov    0x4(%ebx),%eax
     6a3:	01 d0                	add    %edx,%eax
     6a5:	8b 00                	mov    (%eax),%eax
     6a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
     6aa:	e9 67 01 00 00       	jmp    816 <main+0x314>
    }
    else if (strcmp(argv[i],"-size") == 0){
     6af:	8b 45 cc             	mov    -0x34(%ebp),%eax
     6b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     6b9:	8b 43 04             	mov    0x4(%ebx),%eax
     6bc:	01 d0                	add    %edx,%eax
     6be:	8b 00                	mov    (%eax),%eax
     6c0:	c7 44 24 04 85 11 00 	movl   $0x1185,0x4(%esp)
     6c7:	00 
     6c8:	89 04 24             	mov    %eax,(%esp)
     6cb:	e8 e4 01 00 00       	call   8b4 <strcmp>
     6d0:	85 c0                	test   %eax,%eax
     6d2:	0f 85 3e 01 00 00    	jne    816 <main+0x314>
        i = i + 1;
     6d8:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
        if (i >= argc){
     6dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
     6df:	3b 03                	cmp    (%ebx),%eax
     6e1:	7c 19                	jl     6fc <main+0x1fa>
            printf(1,"Wrong usage. Size not specified after -size\n");
     6e3:	c7 44 24 04 8c 11 00 	movl   $0x118c,0x4(%esp)
     6ea:	00 
     6eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6f2:	e8 78 05 00 00       	call   c6f <printf>
            exit();
     6f7:	e8 cb 03 00 00       	call   ac7 <exit>
        }
        len = strlen(argv[i]);
     6fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
     6ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     706:	8b 43 04             	mov    0x4(%ebx),%eax
     709:	01 d0                	add    %edx,%eax
     70b:	8b 00                	mov    (%eax),%eax
     70d:	89 04 24             	mov    %eax,(%esp)
     710:	e8 de 01 00 00       	call   8f3 <strlen>
     715:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (argv[i][0] != '+' && argv[i][0] != '-'){
     718:	8b 45 cc             	mov    -0x34(%ebp),%eax
     71b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     722:	8b 43 04             	mov    0x4(%ebx),%eax
     725:	01 d0                	add    %edx,%eax
     727:	8b 00                	mov    (%eax),%eax
     729:	0f b6 00             	movzbl (%eax),%eax
     72c:	3c 2b                	cmp    $0x2b,%al
     72e:	74 39                	je     769 <main+0x267>
     730:	8b 45 cc             	mov    -0x34(%ebp),%eax
     733:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     73a:	8b 43 04             	mov    0x4(%ebx),%eax
     73d:	01 d0                	add    %edx,%eax
     73f:	8b 00                	mov    (%eax),%eax
     741:	0f b6 00             	movzbl (%eax),%eax
     744:	3c 2d                	cmp    $0x2d,%al
     746:	74 21                	je     769 <main+0x267>
            exact_size = atoi(argv[i]);
     748:	8b 45 cc             	mov    -0x34(%ebp),%eax
     74b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     752:	8b 43 04             	mov    0x4(%ebx),%eax
     755:	01 d0                	add    %edx,%eax
     757:	8b 00                	mov    (%eax),%eax
     759:	89 04 24             	mov    %eax,(%esp)
     75c:	e8 d4 02 00 00       	call   a35 <atoi>
     761:	89 45 d0             	mov    %eax,-0x30(%ebp)
     764:	e9 ad 00 00 00       	jmp    816 <main+0x314>
     769:	89 e0                	mov    %esp,%eax
     76b:	89 c6                	mov    %eax,%esi
        }else{
            char num[len];
     76d:	8b 45 c0             	mov    -0x40(%ebp),%eax
     770:	8d 50 ff             	lea    -0x1(%eax),%edx
     773:	89 55 bc             	mov    %edx,-0x44(%ebp)
     776:	ba 10 00 00 00       	mov    $0x10,%edx
     77b:	83 ea 01             	sub    $0x1,%edx
     77e:	01 d0                	add    %edx,%eax
     780:	bf 10 00 00 00       	mov    $0x10,%edi
     785:	ba 00 00 00 00       	mov    $0x0,%edx
     78a:	f7 f7                	div    %edi
     78c:	6b c0 10             	imul   $0x10,%eax,%eax
     78f:	29 c4                	sub    %eax,%esp
     791:	8d 44 24 1c          	lea    0x1c(%esp),%eax
     795:	83 c0 00             	add    $0x0,%eax
     798:	89 45 b8             	mov    %eax,-0x48(%ebp)
            int j;
            for (j=1;j<len;j++)
     79b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
     7a2:	eb 29                	jmp    7cd <main+0x2cb>
                num[j-1] = argv[i][j];
     7a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
     7a7:	8d 48 ff             	lea    -0x1(%eax),%ecx
     7aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
     7ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     7b4:	8b 43 04             	mov    0x4(%ebx),%eax
     7b7:	01 d0                	add    %edx,%eax
     7b9:	8b 10                	mov    (%eax),%edx
     7bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
     7be:	01 d0                	add    %edx,%eax
     7c0:	0f b6 10             	movzbl (%eax),%edx
     7c3:	8b 45 b8             	mov    -0x48(%ebp),%eax
     7c6:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        if (argv[i][0] != '+' && argv[i][0] != '-'){
            exact_size = atoi(argv[i]);
        }else{
            char num[len];
            int j;
            for (j=1;j<len;j++)
     7c9:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
     7cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
     7d0:	3b 45 c0             	cmp    -0x40(%ebp),%eax
     7d3:	7c cf                	jl     7a4 <main+0x2a2>
                num[j-1] = argv[i][j];
            num[len] = '\0';
     7d5:	8b 55 b8             	mov    -0x48(%ebp),%edx
     7d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
     7db:	01 d0                	add    %edx,%eax
     7dd:	c6 00 00             	movb   $0x0,(%eax)
            len = atoi(num);
     7e0:	8b 45 b8             	mov    -0x48(%ebp),%eax
     7e3:	89 04 24             	mov    %eax,(%esp)
     7e6:	e8 4a 02 00 00       	call   a35 <atoi>
     7eb:	89 45 c0             	mov    %eax,-0x40(%ebp)
            if (argv[i][0] == '+'){
     7ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
     7f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     7f8:	8b 43 04             	mov    0x4(%ebx),%eax
     7fb:	01 d0                	add    %edx,%eax
     7fd:	8b 00                	mov    (%eax),%eax
     7ff:	0f b6 00             	movzbl (%eax),%eax
     802:	3c 2b                	cmp    $0x2b,%al
     804:	75 08                	jne    80e <main+0x30c>
                min_size = len;
     806:	8b 45 c0             	mov    -0x40(%ebp),%eax
     809:	89 45 d8             	mov    %eax,-0x28(%ebp)
     80c:	eb 06                	jmp    814 <main+0x312>
            }
            else{
                max_size = len;
     80e:	8b 45 c0             	mov    -0x40(%ebp),%eax
     811:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     814:	89 f4                	mov    %esi,%esp
  int len = 0;
  
  int i;

  /* Parsing arguments */
  for(i=2; i<argc; i++){
     816:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
     81a:	8b 45 cc             	mov    -0x34(%ebp),%eax
     81d:	3b 03                	cmp    (%ebx),%eax
     81f:	0f 8c 57 fd ff ff    	jl     57c <main+0x7a>
        }
        
    }
  }

  find(path, deref, name, type, min_size, max_size, exact_size);
     825:	8b 45 d0             	mov    -0x30(%ebp),%eax
     828:	89 44 24 18          	mov    %eax,0x18(%esp)
     82c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     82f:	89 44 24 14          	mov    %eax,0x14(%esp)
     833:	8b 45 d8             	mov    -0x28(%ebp),%eax
     836:	89 44 24 10          	mov    %eax,0x10(%esp)
     83a:	8b 45 dc             	mov    -0x24(%ebp),%eax
     83d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     841:	8b 45 e0             	mov    -0x20(%ebp),%eax
     844:	89 44 24 08          	mov    %eax,0x8(%esp)
     848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     84b:	89 44 24 04          	mov    %eax,0x4(%esp)
     84f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     852:	89 04 24             	mov    %eax,(%esp)
     855:	e8 06 f9 ff ff       	call   160 <find>
  exit();
     85a:	e8 68 02 00 00       	call   ac7 <exit>

0000085f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     85f:	55                   	push   %ebp
     860:	89 e5                	mov    %esp,%ebp
     862:	57                   	push   %edi
     863:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     864:	8b 4d 08             	mov    0x8(%ebp),%ecx
     867:	8b 55 10             	mov    0x10(%ebp),%edx
     86a:	8b 45 0c             	mov    0xc(%ebp),%eax
     86d:	89 cb                	mov    %ecx,%ebx
     86f:	89 df                	mov    %ebx,%edi
     871:	89 d1                	mov    %edx,%ecx
     873:	fc                   	cld    
     874:	f3 aa                	rep stos %al,%es:(%edi)
     876:	89 ca                	mov    %ecx,%edx
     878:	89 fb                	mov    %edi,%ebx
     87a:	89 5d 08             	mov    %ebx,0x8(%ebp)
     87d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     880:	5b                   	pop    %ebx
     881:	5f                   	pop    %edi
     882:	5d                   	pop    %ebp
     883:	c3                   	ret    

00000884 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     884:	55                   	push   %ebp
     885:	89 e5                	mov    %esp,%ebp
     887:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     88a:	8b 45 08             	mov    0x8(%ebp),%eax
     88d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     890:	90                   	nop
     891:	8b 45 08             	mov    0x8(%ebp),%eax
     894:	8d 50 01             	lea    0x1(%eax),%edx
     897:	89 55 08             	mov    %edx,0x8(%ebp)
     89a:	8b 55 0c             	mov    0xc(%ebp),%edx
     89d:	8d 4a 01             	lea    0x1(%edx),%ecx
     8a0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     8a3:	0f b6 12             	movzbl (%edx),%edx
     8a6:	88 10                	mov    %dl,(%eax)
     8a8:	0f b6 00             	movzbl (%eax),%eax
     8ab:	84 c0                	test   %al,%al
     8ad:	75 e2                	jne    891 <strcpy+0xd>
    ;
  return os;
     8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     8b2:	c9                   	leave  
     8b3:	c3                   	ret    

000008b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     8b4:	55                   	push   %ebp
     8b5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     8b7:	eb 08                	jmp    8c1 <strcmp+0xd>
    p++, q++;
     8b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     8bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     8c1:	8b 45 08             	mov    0x8(%ebp),%eax
     8c4:	0f b6 00             	movzbl (%eax),%eax
     8c7:	84 c0                	test   %al,%al
     8c9:	74 10                	je     8db <strcmp+0x27>
     8cb:	8b 45 08             	mov    0x8(%ebp),%eax
     8ce:	0f b6 10             	movzbl (%eax),%edx
     8d1:	8b 45 0c             	mov    0xc(%ebp),%eax
     8d4:	0f b6 00             	movzbl (%eax),%eax
     8d7:	38 c2                	cmp    %al,%dl
     8d9:	74 de                	je     8b9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     8db:	8b 45 08             	mov    0x8(%ebp),%eax
     8de:	0f b6 00             	movzbl (%eax),%eax
     8e1:	0f b6 d0             	movzbl %al,%edx
     8e4:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e7:	0f b6 00             	movzbl (%eax),%eax
     8ea:	0f b6 c0             	movzbl %al,%eax
     8ed:	29 c2                	sub    %eax,%edx
     8ef:	89 d0                	mov    %edx,%eax
}
     8f1:	5d                   	pop    %ebp
     8f2:	c3                   	ret    

000008f3 <strlen>:

uint
strlen(char *s)
{
     8f3:	55                   	push   %ebp
     8f4:	89 e5                	mov    %esp,%ebp
     8f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     8f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     900:	eb 04                	jmp    906 <strlen+0x13>
     902:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     906:	8b 55 fc             	mov    -0x4(%ebp),%edx
     909:	8b 45 08             	mov    0x8(%ebp),%eax
     90c:	01 d0                	add    %edx,%eax
     90e:	0f b6 00             	movzbl (%eax),%eax
     911:	84 c0                	test   %al,%al
     913:	75 ed                	jne    902 <strlen+0xf>
    ;
  return n;
     915:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     918:	c9                   	leave  
     919:	c3                   	ret    

0000091a <memset>:

void*
memset(void *dst, int c, uint n)
{
     91a:	55                   	push   %ebp
     91b:	89 e5                	mov    %esp,%ebp
     91d:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     920:	8b 45 10             	mov    0x10(%ebp),%eax
     923:	89 44 24 08          	mov    %eax,0x8(%esp)
     927:	8b 45 0c             	mov    0xc(%ebp),%eax
     92a:	89 44 24 04          	mov    %eax,0x4(%esp)
     92e:	8b 45 08             	mov    0x8(%ebp),%eax
     931:	89 04 24             	mov    %eax,(%esp)
     934:	e8 26 ff ff ff       	call   85f <stosb>
  return dst;
     939:	8b 45 08             	mov    0x8(%ebp),%eax
}
     93c:	c9                   	leave  
     93d:	c3                   	ret    

0000093e <strchr>:

char*
strchr(const char *s, char c)
{
     93e:	55                   	push   %ebp
     93f:	89 e5                	mov    %esp,%ebp
     941:	83 ec 04             	sub    $0x4,%esp
     944:	8b 45 0c             	mov    0xc(%ebp),%eax
     947:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     94a:	eb 14                	jmp    960 <strchr+0x22>
    if(*s == c)
     94c:	8b 45 08             	mov    0x8(%ebp),%eax
     94f:	0f b6 00             	movzbl (%eax),%eax
     952:	3a 45 fc             	cmp    -0x4(%ebp),%al
     955:	75 05                	jne    95c <strchr+0x1e>
      return (char*)s;
     957:	8b 45 08             	mov    0x8(%ebp),%eax
     95a:	eb 13                	jmp    96f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     95c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     960:	8b 45 08             	mov    0x8(%ebp),%eax
     963:	0f b6 00             	movzbl (%eax),%eax
     966:	84 c0                	test   %al,%al
     968:	75 e2                	jne    94c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     96a:	b8 00 00 00 00       	mov    $0x0,%eax
}
     96f:	c9                   	leave  
     970:	c3                   	ret    

00000971 <gets>:

char*
gets(char *buf, int max)
{
     971:	55                   	push   %ebp
     972:	89 e5                	mov    %esp,%ebp
     974:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     977:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     97e:	eb 4c                	jmp    9cc <gets+0x5b>
    cc = read(0, &c, 1);
     980:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     987:	00 
     988:	8d 45 ef             	lea    -0x11(%ebp),%eax
     98b:	89 44 24 04          	mov    %eax,0x4(%esp)
     98f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     996:	e8 44 01 00 00       	call   adf <read>
     99b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     99e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     9a2:	7f 02                	jg     9a6 <gets+0x35>
      break;
     9a4:	eb 31                	jmp    9d7 <gets+0x66>
    buf[i++] = c;
     9a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9a9:	8d 50 01             	lea    0x1(%eax),%edx
     9ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9af:	89 c2                	mov    %eax,%edx
     9b1:	8b 45 08             	mov    0x8(%ebp),%eax
     9b4:	01 c2                	add    %eax,%edx
     9b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     9bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9c0:	3c 0a                	cmp    $0xa,%al
     9c2:	74 13                	je     9d7 <gets+0x66>
     9c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     9c8:	3c 0d                	cmp    $0xd,%al
     9ca:	74 0b                	je     9d7 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9cf:	83 c0 01             	add    $0x1,%eax
     9d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9d5:	7c a9                	jl     980 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     9d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9da:	8b 45 08             	mov    0x8(%ebp),%eax
     9dd:	01 d0                	add    %edx,%eax
     9df:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     9e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9e5:	c9                   	leave  
     9e6:	c3                   	ret    

000009e7 <stat>:

int
stat(char *n, struct stat *st)
{
     9e7:	55                   	push   %ebp
     9e8:	89 e5                	mov    %esp,%ebp
     9ea:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     9ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     9f4:	00 
     9f5:	8b 45 08             	mov    0x8(%ebp),%eax
     9f8:	89 04 24             	mov    %eax,(%esp)
     9fb:	e8 07 01 00 00       	call   b07 <open>
     a00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     a03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     a07:	79 07                	jns    a10 <stat+0x29>
    return -1;
     a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     a0e:	eb 23                	jmp    a33 <stat+0x4c>
  r = fstat(fd, st);
     a10:	8b 45 0c             	mov    0xc(%ebp),%eax
     a13:	89 44 24 04          	mov    %eax,0x4(%esp)
     a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a1a:	89 04 24             	mov    %eax,(%esp)
     a1d:	e8 fd 00 00 00       	call   b1f <fstat>
     a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a28:	89 04 24             	mov    %eax,(%esp)
     a2b:	e8 bf 00 00 00       	call   aef <close>
  return r;
     a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     a33:	c9                   	leave  
     a34:	c3                   	ret    

00000a35 <atoi>:

int
atoi(const char *s)
{
     a35:	55                   	push   %ebp
     a36:	89 e5                	mov    %esp,%ebp
     a38:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     a3b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     a42:	eb 25                	jmp    a69 <atoi+0x34>
    n = n*10 + *s++ - '0';
     a44:	8b 55 fc             	mov    -0x4(%ebp),%edx
     a47:	89 d0                	mov    %edx,%eax
     a49:	c1 e0 02             	shl    $0x2,%eax
     a4c:	01 d0                	add    %edx,%eax
     a4e:	01 c0                	add    %eax,%eax
     a50:	89 c1                	mov    %eax,%ecx
     a52:	8b 45 08             	mov    0x8(%ebp),%eax
     a55:	8d 50 01             	lea    0x1(%eax),%edx
     a58:	89 55 08             	mov    %edx,0x8(%ebp)
     a5b:	0f b6 00             	movzbl (%eax),%eax
     a5e:	0f be c0             	movsbl %al,%eax
     a61:	01 c8                	add    %ecx,%eax
     a63:	83 e8 30             	sub    $0x30,%eax
     a66:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a69:	8b 45 08             	mov    0x8(%ebp),%eax
     a6c:	0f b6 00             	movzbl (%eax),%eax
     a6f:	3c 2f                	cmp    $0x2f,%al
     a71:	7e 0a                	jle    a7d <atoi+0x48>
     a73:	8b 45 08             	mov    0x8(%ebp),%eax
     a76:	0f b6 00             	movzbl (%eax),%eax
     a79:	3c 39                	cmp    $0x39,%al
     a7b:	7e c7                	jle    a44 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     a80:	c9                   	leave  
     a81:	c3                   	ret    

00000a82 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     a82:	55                   	push   %ebp
     a83:	89 e5                	mov    %esp,%ebp
     a85:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     a88:	8b 45 08             	mov    0x8(%ebp),%eax
     a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
     a91:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     a94:	eb 17                	jmp    aad <memmove+0x2b>
    *dst++ = *src++;
     a96:	8b 45 fc             	mov    -0x4(%ebp),%eax
     a99:	8d 50 01             	lea    0x1(%eax),%edx
     a9c:	89 55 fc             	mov    %edx,-0x4(%ebp)
     a9f:	8b 55 f8             	mov    -0x8(%ebp),%edx
     aa2:	8d 4a 01             	lea    0x1(%edx),%ecx
     aa5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     aa8:	0f b6 12             	movzbl (%edx),%edx
     aab:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     aad:	8b 45 10             	mov    0x10(%ebp),%eax
     ab0:	8d 50 ff             	lea    -0x1(%eax),%edx
     ab3:	89 55 10             	mov    %edx,0x10(%ebp)
     ab6:	85 c0                	test   %eax,%eax
     ab8:	7f dc                	jg     a96 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     aba:	8b 45 08             	mov    0x8(%ebp),%eax
}
     abd:	c9                   	leave  
     abe:	c3                   	ret    

00000abf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     abf:	b8 01 00 00 00       	mov    $0x1,%eax
     ac4:	cd 40                	int    $0x40
     ac6:	c3                   	ret    

00000ac7 <exit>:
SYSCALL(exit)
     ac7:	b8 02 00 00 00       	mov    $0x2,%eax
     acc:	cd 40                	int    $0x40
     ace:	c3                   	ret    

00000acf <wait>:
SYSCALL(wait)
     acf:	b8 03 00 00 00       	mov    $0x3,%eax
     ad4:	cd 40                	int    $0x40
     ad6:	c3                   	ret    

00000ad7 <pipe>:
SYSCALL(pipe)
     ad7:	b8 04 00 00 00       	mov    $0x4,%eax
     adc:	cd 40                	int    $0x40
     ade:	c3                   	ret    

00000adf <read>:
SYSCALL(read)
     adf:	b8 05 00 00 00       	mov    $0x5,%eax
     ae4:	cd 40                	int    $0x40
     ae6:	c3                   	ret    

00000ae7 <write>:
SYSCALL(write)
     ae7:	b8 10 00 00 00       	mov    $0x10,%eax
     aec:	cd 40                	int    $0x40
     aee:	c3                   	ret    

00000aef <close>:
SYSCALL(close)
     aef:	b8 15 00 00 00       	mov    $0x15,%eax
     af4:	cd 40                	int    $0x40
     af6:	c3                   	ret    

00000af7 <kill>:
SYSCALL(kill)
     af7:	b8 06 00 00 00       	mov    $0x6,%eax
     afc:	cd 40                	int    $0x40
     afe:	c3                   	ret    

00000aff <exec>:
SYSCALL(exec)
     aff:	b8 07 00 00 00       	mov    $0x7,%eax
     b04:	cd 40                	int    $0x40
     b06:	c3                   	ret    

00000b07 <open>:
SYSCALL(open)
     b07:	b8 0f 00 00 00       	mov    $0xf,%eax
     b0c:	cd 40                	int    $0x40
     b0e:	c3                   	ret    

00000b0f <mknod>:
SYSCALL(mknod)
     b0f:	b8 11 00 00 00       	mov    $0x11,%eax
     b14:	cd 40                	int    $0x40
     b16:	c3                   	ret    

00000b17 <unlink>:
SYSCALL(unlink)
     b17:	b8 12 00 00 00       	mov    $0x12,%eax
     b1c:	cd 40                	int    $0x40
     b1e:	c3                   	ret    

00000b1f <fstat>:
SYSCALL(fstat)
     b1f:	b8 08 00 00 00       	mov    $0x8,%eax
     b24:	cd 40                	int    $0x40
     b26:	c3                   	ret    

00000b27 <link>:
SYSCALL(link)
     b27:	b8 13 00 00 00       	mov    $0x13,%eax
     b2c:	cd 40                	int    $0x40
     b2e:	c3                   	ret    

00000b2f <mkdir>:
SYSCALL(mkdir)
     b2f:	b8 14 00 00 00       	mov    $0x14,%eax
     b34:	cd 40                	int    $0x40
     b36:	c3                   	ret    

00000b37 <chdir>:
SYSCALL(chdir)
     b37:	b8 09 00 00 00       	mov    $0x9,%eax
     b3c:	cd 40                	int    $0x40
     b3e:	c3                   	ret    

00000b3f <dup>:
SYSCALL(dup)
     b3f:	b8 0a 00 00 00       	mov    $0xa,%eax
     b44:	cd 40                	int    $0x40
     b46:	c3                   	ret    

00000b47 <getpid>:
SYSCALL(getpid)
     b47:	b8 0b 00 00 00       	mov    $0xb,%eax
     b4c:	cd 40                	int    $0x40
     b4e:	c3                   	ret    

00000b4f <sbrk>:
SYSCALL(sbrk)
     b4f:	b8 0c 00 00 00       	mov    $0xc,%eax
     b54:	cd 40                	int    $0x40
     b56:	c3                   	ret    

00000b57 <sleep>:
SYSCALL(sleep)
     b57:	b8 0d 00 00 00       	mov    $0xd,%eax
     b5c:	cd 40                	int    $0x40
     b5e:	c3                   	ret    

00000b5f <uptime>:
SYSCALL(uptime)
     b5f:	b8 0e 00 00 00       	mov    $0xe,%eax
     b64:	cd 40                	int    $0x40
     b66:	c3                   	ret    

00000b67 <symlink>:
SYSCALL(symlink)
     b67:	b8 16 00 00 00       	mov    $0x16,%eax
     b6c:	cd 40                	int    $0x40
     b6e:	c3                   	ret    

00000b6f <readlink>:
SYSCALL(readlink)
     b6f:	b8 17 00 00 00       	mov    $0x17,%eax
     b74:	cd 40                	int    $0x40
     b76:	c3                   	ret    

00000b77 <fprot>:
SYSCALL(fprot)
     b77:	b8 18 00 00 00       	mov    $0x18,%eax
     b7c:	cd 40                	int    $0x40
     b7e:	c3                   	ret    

00000b7f <funprot>:
SYSCALL(funprot)
     b7f:	b8 19 00 00 00       	mov    $0x19,%eax
     b84:	cd 40                	int    $0x40
     b86:	c3                   	ret    

00000b87 <funlock>:
SYSCALL(funlock)
     b87:	b8 1a 00 00 00       	mov    $0x1a,%eax
     b8c:	cd 40                	int    $0x40
     b8e:	c3                   	ret    

00000b8f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     b8f:	55                   	push   %ebp
     b90:	89 e5                	mov    %esp,%ebp
     b92:	83 ec 18             	sub    $0x18,%esp
     b95:	8b 45 0c             	mov    0xc(%ebp),%eax
     b98:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     b9b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     ba2:	00 
     ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
     ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
     baa:	8b 45 08             	mov    0x8(%ebp),%eax
     bad:	89 04 24             	mov    %eax,(%esp)
     bb0:	e8 32 ff ff ff       	call   ae7 <write>
}
     bb5:	c9                   	leave  
     bb6:	c3                   	ret    

00000bb7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     bb7:	55                   	push   %ebp
     bb8:	89 e5                	mov    %esp,%ebp
     bba:	56                   	push   %esi
     bbb:	53                   	push   %ebx
     bbc:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     bbf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     bc6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     bca:	74 17                	je     be3 <printint+0x2c>
     bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     bd0:	79 11                	jns    be3 <printint+0x2c>
    neg = 1;
     bd2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
     bdc:	f7 d8                	neg    %eax
     bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
     be1:	eb 06                	jmp    be9 <printint+0x32>
  } else {
    x = xx;
     be3:	8b 45 0c             	mov    0xc(%ebp),%eax
     be6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     be9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     bf0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bf3:	8d 41 01             	lea    0x1(%ecx),%eax
     bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
     bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
     bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bff:	ba 00 00 00 00       	mov    $0x0,%edx
     c04:	f7 f3                	div    %ebx
     c06:	89 d0                	mov    %edx,%eax
     c08:	0f b6 80 80 14 00 00 	movzbl 0x1480(%eax),%eax
     c0f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
     c13:	8b 75 10             	mov    0x10(%ebp),%esi
     c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c19:	ba 00 00 00 00       	mov    $0x0,%edx
     c1e:	f7 f6                	div    %esi
     c20:	89 45 ec             	mov    %eax,-0x14(%ebp)
     c23:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     c27:	75 c7                	jne    bf0 <printint+0x39>
  if(neg)
     c29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     c2d:	74 10                	je     c3f <printint+0x88>
    buf[i++] = '-';
     c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c32:	8d 50 01             	lea    0x1(%eax),%edx
     c35:	89 55 f4             	mov    %edx,-0xc(%ebp)
     c38:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
     c3d:	eb 1f                	jmp    c5e <printint+0xa7>
     c3f:	eb 1d                	jmp    c5e <printint+0xa7>
    putc(fd, buf[i]);
     c41:	8d 55 dc             	lea    -0x24(%ebp),%edx
     c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c47:	01 d0                	add    %edx,%eax
     c49:	0f b6 00             	movzbl (%eax),%eax
     c4c:	0f be c0             	movsbl %al,%eax
     c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
     c53:	8b 45 08             	mov    0x8(%ebp),%eax
     c56:	89 04 24             	mov    %eax,(%esp)
     c59:	e8 31 ff ff ff       	call   b8f <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
     c5e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
     c62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     c66:	79 d9                	jns    c41 <printint+0x8a>
    putc(fd, buf[i]);
}
     c68:	83 c4 30             	add    $0x30,%esp
     c6b:	5b                   	pop    %ebx
     c6c:	5e                   	pop    %esi
     c6d:	5d                   	pop    %ebp
     c6e:	c3                   	ret    

00000c6f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
     c6f:	55                   	push   %ebp
     c70:	89 e5                	mov    %esp,%ebp
     c72:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
     c75:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
     c7c:	8d 45 0c             	lea    0xc(%ebp),%eax
     c7f:	83 c0 04             	add    $0x4,%eax
     c82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
     c85:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     c8c:	e9 7c 01 00 00       	jmp    e0d <printf+0x19e>
    c = fmt[i] & 0xff;
     c91:	8b 55 0c             	mov    0xc(%ebp),%edx
     c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c97:	01 d0                	add    %edx,%eax
     c99:	0f b6 00             	movzbl (%eax),%eax
     c9c:	0f be c0             	movsbl %al,%eax
     c9f:	25 ff 00 00 00       	and    $0xff,%eax
     ca4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
     ca7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     cab:	75 2c                	jne    cd9 <printf+0x6a>
      if(c == '%'){
     cad:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     cb1:	75 0c                	jne    cbf <printf+0x50>
        state = '%';
     cb3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
     cba:	e9 4a 01 00 00       	jmp    e09 <printf+0x19a>
      } else {
        putc(fd, c);
     cbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cc2:	0f be c0             	movsbl %al,%eax
     cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
     cc9:	8b 45 08             	mov    0x8(%ebp),%eax
     ccc:	89 04 24             	mov    %eax,(%esp)
     ccf:	e8 bb fe ff ff       	call   b8f <putc>
     cd4:	e9 30 01 00 00       	jmp    e09 <printf+0x19a>
      }
    } else if(state == '%'){
     cd9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
     cdd:	0f 85 26 01 00 00    	jne    e09 <printf+0x19a>
      if(c == 'd'){
     ce3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
     ce7:	75 2d                	jne    d16 <printf+0xa7>
        printint(fd, *ap, 10, 1);
     ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cec:	8b 00                	mov    (%eax),%eax
     cee:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
     cf5:	00 
     cf6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     cfd:	00 
     cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
     d02:	8b 45 08             	mov    0x8(%ebp),%eax
     d05:	89 04 24             	mov    %eax,(%esp)
     d08:	e8 aa fe ff ff       	call   bb7 <printint>
        ap++;
     d0d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     d11:	e9 ec 00 00 00       	jmp    e02 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
     d16:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
     d1a:	74 06                	je     d22 <printf+0xb3>
     d1c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
     d20:	75 2d                	jne    d4f <printf+0xe0>
        printint(fd, *ap, 16, 0);
     d22:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d25:	8b 00                	mov    (%eax),%eax
     d27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d2e:	00 
     d2f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
     d36:	00 
     d37:	89 44 24 04          	mov    %eax,0x4(%esp)
     d3b:	8b 45 08             	mov    0x8(%ebp),%eax
     d3e:	89 04 24             	mov    %eax,(%esp)
     d41:	e8 71 fe ff ff       	call   bb7 <printint>
        ap++;
     d46:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     d4a:	e9 b3 00 00 00       	jmp    e02 <printf+0x193>
      } else if(c == 's'){
     d4f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
     d53:	75 45                	jne    d9a <printf+0x12b>
        s = (char*)*ap;
     d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d58:	8b 00                	mov    (%eax),%eax
     d5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
     d5d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
     d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     d65:	75 09                	jne    d70 <printf+0x101>
          s = "(null)";
     d67:	c7 45 f4 b9 11 00 00 	movl   $0x11b9,-0xc(%ebp)
        while(*s != 0){
     d6e:	eb 1e                	jmp    d8e <printf+0x11f>
     d70:	eb 1c                	jmp    d8e <printf+0x11f>
          putc(fd, *s);
     d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d75:	0f b6 00             	movzbl (%eax),%eax
     d78:	0f be c0             	movsbl %al,%eax
     d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
     d7f:	8b 45 08             	mov    0x8(%ebp),%eax
     d82:	89 04 24             	mov    %eax,(%esp)
     d85:	e8 05 fe ff ff       	call   b8f <putc>
          s++;
     d8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
     d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d91:	0f b6 00             	movzbl (%eax),%eax
     d94:	84 c0                	test   %al,%al
     d96:	75 da                	jne    d72 <printf+0x103>
     d98:	eb 68                	jmp    e02 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     d9a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
     d9e:	75 1d                	jne    dbd <printf+0x14e>
        putc(fd, *ap);
     da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
     da3:	8b 00                	mov    (%eax),%eax
     da5:	0f be c0             	movsbl %al,%eax
     da8:	89 44 24 04          	mov    %eax,0x4(%esp)
     dac:	8b 45 08             	mov    0x8(%ebp),%eax
     daf:	89 04 24             	mov    %eax,(%esp)
     db2:	e8 d8 fd ff ff       	call   b8f <putc>
        ap++;
     db7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
     dbb:	eb 45                	jmp    e02 <printf+0x193>
      } else if(c == '%'){
     dbd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
     dc1:	75 17                	jne    dda <printf+0x16b>
        putc(fd, c);
     dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     dc6:	0f be c0             	movsbl %al,%eax
     dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
     dcd:	8b 45 08             	mov    0x8(%ebp),%eax
     dd0:	89 04 24             	mov    %eax,(%esp)
     dd3:	e8 b7 fd ff ff       	call   b8f <putc>
     dd8:	eb 28                	jmp    e02 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     dda:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
     de1:	00 
     de2:	8b 45 08             	mov    0x8(%ebp),%eax
     de5:	89 04 24             	mov    %eax,(%esp)
     de8:	e8 a2 fd ff ff       	call   b8f <putc>
        putc(fd, c);
     ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     df0:	0f be c0             	movsbl %al,%eax
     df3:	89 44 24 04          	mov    %eax,0x4(%esp)
     df7:	8b 45 08             	mov    0x8(%ebp),%eax
     dfa:	89 04 24             	mov    %eax,(%esp)
     dfd:	e8 8d fd ff ff       	call   b8f <putc>
      }
      state = 0;
     e02:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     e09:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
     e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e13:	01 d0                	add    %edx,%eax
     e15:	0f b6 00             	movzbl (%eax),%eax
     e18:	84 c0                	test   %al,%al
     e1a:	0f 85 71 fe ff ff    	jne    c91 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
     e20:	c9                   	leave  
     e21:	c3                   	ret    

00000e22 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     e22:	55                   	push   %ebp
     e23:	89 e5                	mov    %esp,%ebp
     e25:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
     e28:	8b 45 08             	mov    0x8(%ebp),%eax
     e2b:	83 e8 08             	sub    $0x8,%eax
     e2e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     e31:	a1 bc 14 00 00       	mov    0x14bc,%eax
     e36:	89 45 fc             	mov    %eax,-0x4(%ebp)
     e39:	eb 24                	jmp    e5f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     e3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e3e:	8b 00                	mov    (%eax),%eax
     e40:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e43:	77 12                	ja     e57 <free+0x35>
     e45:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e48:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e4b:	77 24                	ja     e71 <free+0x4f>
     e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e50:	8b 00                	mov    (%eax),%eax
     e52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     e55:	77 1a                	ja     e71 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e5a:	8b 00                	mov    (%eax),%eax
     e5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
     e5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e62:	3b 45 fc             	cmp    -0x4(%ebp),%eax
     e65:	76 d4                	jbe    e3b <free+0x19>
     e67:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e6a:	8b 00                	mov    (%eax),%eax
     e6c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     e6f:	76 ca                	jbe    e3b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
     e71:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e74:	8b 40 04             	mov    0x4(%eax),%eax
     e77:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     e7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e81:	01 c2                	add    %eax,%edx
     e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e86:	8b 00                	mov    (%eax),%eax
     e88:	39 c2                	cmp    %eax,%edx
     e8a:	75 24                	jne    eb0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
     e8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e8f:	8b 50 04             	mov    0x4(%eax),%edx
     e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e95:	8b 00                	mov    (%eax),%eax
     e97:	8b 40 04             	mov    0x4(%eax),%eax
     e9a:	01 c2                	add    %eax,%edx
     e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
     e9f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
     ea2:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ea5:	8b 00                	mov    (%eax),%eax
     ea7:	8b 10                	mov    (%eax),%edx
     ea9:	8b 45 f8             	mov    -0x8(%ebp),%eax
     eac:	89 10                	mov    %edx,(%eax)
     eae:	eb 0a                	jmp    eba <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
     eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eb3:	8b 10                	mov    (%eax),%edx
     eb5:	8b 45 f8             	mov    -0x8(%ebp),%eax
     eb8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
     eba:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ebd:	8b 40 04             	mov    0x4(%eax),%eax
     ec0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eca:	01 d0                	add    %edx,%eax
     ecc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
     ecf:	75 20                	jne    ef1 <free+0xcf>
    p->s.size += bp->s.size;
     ed1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ed4:	8b 50 04             	mov    0x4(%eax),%edx
     ed7:	8b 45 f8             	mov    -0x8(%ebp),%eax
     eda:	8b 40 04             	mov    0x4(%eax),%eax
     edd:	01 c2                	add    %eax,%edx
     edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ee2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
     ee5:	8b 45 f8             	mov    -0x8(%ebp),%eax
     ee8:	8b 10                	mov    (%eax),%edx
     eea:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eed:	89 10                	mov    %edx,(%eax)
     eef:	eb 08                	jmp    ef9 <free+0xd7>
  } else
    p->s.ptr = bp;
     ef1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     ef4:	8b 55 f8             	mov    -0x8(%ebp),%edx
     ef7:	89 10                	mov    %edx,(%eax)
  freep = p;
     ef9:	8b 45 fc             	mov    -0x4(%ebp),%eax
     efc:	a3 bc 14 00 00       	mov    %eax,0x14bc
}
     f01:	c9                   	leave  
     f02:	c3                   	ret    

00000f03 <morecore>:

static Header*
morecore(uint nu)
{
     f03:	55                   	push   %ebp
     f04:	89 e5                	mov    %esp,%ebp
     f06:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
     f09:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
     f10:	77 07                	ja     f19 <morecore+0x16>
    nu = 4096;
     f12:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
     f19:	8b 45 08             	mov    0x8(%ebp),%eax
     f1c:	c1 e0 03             	shl    $0x3,%eax
     f1f:	89 04 24             	mov    %eax,(%esp)
     f22:	e8 28 fc ff ff       	call   b4f <sbrk>
     f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
     f2a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     f2e:	75 07                	jne    f37 <morecore+0x34>
    return 0;
     f30:	b8 00 00 00 00       	mov    $0x0,%eax
     f35:	eb 22                	jmp    f59 <morecore+0x56>
  hp = (Header*)p;
     f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
     f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f40:	8b 55 08             	mov    0x8(%ebp),%edx
     f43:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
     f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f49:	83 c0 08             	add    $0x8,%eax
     f4c:	89 04 24             	mov    %eax,(%esp)
     f4f:	e8 ce fe ff ff       	call   e22 <free>
  return freep;
     f54:	a1 bc 14 00 00       	mov    0x14bc,%eax
}
     f59:	c9                   	leave  
     f5a:	c3                   	ret    

00000f5b <malloc>:

void*
malloc(uint nbytes)
{
     f5b:	55                   	push   %ebp
     f5c:	89 e5                	mov    %esp,%ebp
     f5e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     f61:	8b 45 08             	mov    0x8(%ebp),%eax
     f64:	83 c0 07             	add    $0x7,%eax
     f67:	c1 e8 03             	shr    $0x3,%eax
     f6a:	83 c0 01             	add    $0x1,%eax
     f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
     f70:	a1 bc 14 00 00       	mov    0x14bc,%eax
     f75:	89 45 f0             	mov    %eax,-0x10(%ebp)
     f78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     f7c:	75 23                	jne    fa1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
     f7e:	c7 45 f0 b4 14 00 00 	movl   $0x14b4,-0x10(%ebp)
     f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f88:	a3 bc 14 00 00       	mov    %eax,0x14bc
     f8d:	a1 bc 14 00 00       	mov    0x14bc,%eax
     f92:	a3 b4 14 00 00       	mov    %eax,0x14b4
    base.s.size = 0;
     f97:	c7 05 b8 14 00 00 00 	movl   $0x0,0x14b8
     f9e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fa4:	8b 00                	mov    (%eax),%eax
     fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
     fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fac:	8b 40 04             	mov    0x4(%eax),%eax
     faf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     fb2:	72 4d                	jb     1001 <malloc+0xa6>
      if(p->s.size == nunits)
     fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fb7:	8b 40 04             	mov    0x4(%eax),%eax
     fba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     fbd:	75 0c                	jne    fcb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
     fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fc2:	8b 10                	mov    (%eax),%edx
     fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fc7:	89 10                	mov    %edx,(%eax)
     fc9:	eb 26                	jmp    ff1 <malloc+0x96>
      else {
        p->s.size -= nunits;
     fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fce:	8b 40 04             	mov    0x4(%eax),%eax
     fd1:	2b 45 ec             	sub    -0x14(%ebp),%eax
     fd4:	89 c2                	mov    %eax,%edx
     fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fd9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
     fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     fdf:	8b 40 04             	mov    0x4(%eax),%eax
     fe2:	c1 e0 03             	shl    $0x3,%eax
     fe5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
     fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
     fee:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
     ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ff4:	a3 bc 14 00 00       	mov    %eax,0x14bc
      return (void*)(p + 1);
     ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ffc:	83 c0 08             	add    $0x8,%eax
     fff:	eb 38                	jmp    1039 <malloc+0xde>
    }
    if(p == freep)
    1001:	a1 bc 14 00 00       	mov    0x14bc,%eax
    1006:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1009:	75 1b                	jne    1026 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    100b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    100e:	89 04 24             	mov    %eax,(%esp)
    1011:	e8 ed fe ff ff       	call   f03 <morecore>
    1016:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1019:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    101d:	75 07                	jne    1026 <malloc+0xcb>
        return 0;
    101f:	b8 00 00 00 00       	mov    $0x0,%eax
    1024:	eb 13                	jmp    1039 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1026:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1029:	89 45 f0             	mov    %eax,-0x10(%ebp)
    102c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    102f:	8b 00                	mov    (%eax),%eax
    1031:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1034:	e9 70 ff ff ff       	jmp    fa9 <malloc+0x4e>
}
    1039:	c9                   	leave  
    103a:	c3                   	ret    
