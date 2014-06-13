#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"

char*
fmtname(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}

char* basename(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), '\0', DIRSIZ-strlen(p));
  return buf;
}

void find(char* path, int deref, char* name, char* type, int min_size, int max_size, int exact_size){
    int fd;
    struct dirent de;
    struct stat st;
    char* basenamed;
    char buf[512], *p;
    
    if (deref){
        fd = open(path, 0);
    }else{
        fd = open(path, O_NODEREF);
    }
    
    if (fd < 0){
        printf(2, "find: cannot open path: %s\n", path);
        return;
    }
    
    if(fstat(fd, &st) < 0){
        printf(2, "find: cannot stat path: %s\n", path);
        close(fd);
        return;
    }
    
    basenamed = basename(path);
    
    switch(st.type){
        case T_SYMLINK:
            if (strcmp(type,"s") == 0 || strcmp(type,"*") == 0){
                if (strcmp(name,"*") == 0 || strcmp(name,basenamed) == 0){
                    printf(1,"FOUND Link: %s\n",path);
                }
            }
            break;
        
        case T_FILE:
            if (strcmp(name,"*") != 0 && strcmp(name,fmtname(path)) != 0){
                break;
            }
            if (strcmp(type,"*") != 0 && strcmp(type,"f") != 0){
                break;
            }
            if (min_size > -1 && st.size < min_size){
                break;
            }
            if (max_size > -1 && st.size > max_size){
                break;
            }
            if (exact_size > -1 && st.size != exact_size){
                break;
            }
            printf(1,"FOUND File: %s\n",path);
            break;
            
        case T_DIR:
            if (strcmp(type,"d") == 0 || strcmp(type,"*") == 0){
                if (strcmp(name,"*") == 0 || strcmp(name,basenamed) == 0){
                    printf(1,"FOUND Directory: %s\n",path);
                }
            }
            strcpy(buf, path);
            p = buf+strlen(buf);
            *p++ = '/';
            while(read(fd, &de, sizeof(de)) == sizeof(de)){
              if(de.inum == 0 || strcmp(de.name,".")==0 || strcmp(de.name,"..")==0)
                continue;
              memmove(p, de.name, DIRSIZ);
              p[DIRSIZ] = 0;

              //printf(1,"DEBUG: Calling find with path: %s\n",buf);
              find(buf, deref, name, type, min_size, max_size, exact_size);
            }
            break;
    }
    
    close(fd);
    
}


int
main(int argc, char *argv[])
{
  
  if (argc < 2){
    printf(1,"find: Not enough arguments (path is required)\n");
    exit();
  }
  
  char* path = argv[1];
  
  /* Default values */
  int deref = 0;
  char* name = "*";
  char* type = "*";
  int min_size = -1;
  int max_size = -1;
  int exact_size = -1;
  int len = 0;
  
  int i;

  /* Parsing arguments */
  for(i=2; i<argc; i++){
    if (strcmp(argv[i],"-help") == 0){
        printf(1,"Usage: find <path> <options> <preds>\n");
        exit();
    }
    else if (strcmp(argv[i],"-follow") == 0){
        deref = 1;
    }
    else if (strcmp(argv[i],"-name") == 0){
        i = i + 1;
        if (i >= argc){
            printf(1,"Wrong usage. Name not specified after -name\n");
            exit();
        }
        name = argv[i];
    }
    else if (strcmp(argv[i],"-type") == 0){
        i = i + 1;
        if (i >= argc){
            printf(1,"Wrong usage. Type not specified after -type\n");
            exit();
        }
        type = argv[i];
    }
    else if (strcmp(argv[i],"-size") == 0){
        i = i + 1;
        if (i >= argc){
            printf(1,"Wrong usage. Size not specified after -size\n");
            exit();
        }
        len = strlen(argv[i]);
        if (argv[i][0] != '+' && argv[i][0] != '-'){
            exact_size = atoi(argv[i]);
        }else{
            char num[len];
            int j;
            for (j=1;j<len;j++)
                num[j-1] = argv[i][j];
            num[len] = '\0';
            len = atoi(num);
            if (argv[i][0] == '+'){
                min_size = len;
            }
            else{
                max_size = len;
            }
        }
        
    }
  }

  find(path, deref, name, type, min_size, max_size, exact_size);
  exit();
}
