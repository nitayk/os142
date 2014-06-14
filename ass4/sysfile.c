//
// File-system system calls.
// Mostly argument checking, since we don't trust
// user code, and calls into file.c and fs.c.
//

#include "types.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "mmu.h"
#include "proc.h"
#include "fs.h"
#include "file.h"
#include "fcntl.h"
#include "x86.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
}

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}

int
sys_dup(void)
{
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;

  if (check_protected(f->ip,1) == -1)
  	  return -1;

  filedup(f);
  return fd;
}

int
sys_read(void)
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;

  if (check_protected(f->ip,1) == -1)
  	  return -1;

  return fileread(f, p, n);
}

int
sys_write(void)
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;

  if (check_protected(f->ip,1) == -1)
  	  return -1;

  return filewrite(f, p, n);
}

int
sys_close(void)
{
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
    return -1;
  proc->ofile[fd] = 0;
  fileclose(f);
  return 0;
}

int
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
    return -1;

   if (check_protected(f->ip,1) == -1)
   	  return -1;

  return filestat(f, st);
}

static struct inode* create(char *path, short type, short major, short minor);

int //task1.b
sys_readlink(void) {
	char *path, *pathbuffer;
	//size_t bufsize;
    
    //if(argstr(0, &pathname) < 0 || argstr(1, &buf) < 0 || argint(2, bufsize) < 0)
	if(argstr(0, &path) < 0 || argstr(1, &pathbuffer) < 0)
        return -1;

	// namex(char *path, int nameiparent, char *name, uint l_counter, struct inode *last_pos, int noderef)

    char name[DIRSIZ];
    int index = 0;
    pathbuffer[0] = '\0';
    if (namex(path,0, name, 0, 0, 0, pathbuffer, &index, MAXPATH) == 0)
		return -1;
    
	return index;
}

int //task1.b
sys_symlink(void)
{
	 char *old, *new;
	 struct inode *ip;

	  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
	    return -1;

	  begin_trans();
	  if((ip = create(new, T_SYMLINK, 0, 0)) == 0){
	    commit_trans();
	    return -1;
	  }
	  ip->type = T_SYMLINK;
	  iupdate(ip);			// update on-disk data

	  writei(ip, old, 0, strlen(old));		// write the old path into the inode of the new one

	  iunlockput(ip);
	  commit_trans();
	  return 0;
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
    return -1;
  if((ip = namei(old,0)) == 0)
    return -1;

  begin_trans();

  ilock(ip);
  if(ip->type == T_DIR){
    iunlockput(ip);
    commit_trans();
    return -1;
  }

  if (check_protected(ip,0) == -1) {
  	  commit_trans();
	  return -1;
  }

  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  iput(ip);

  commit_trans();

  return 0;

bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  commit_trans();
  return -1;
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
}

//PAGEBREAK!
int
sys_unlink(void)
{
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
    return -1;

  begin_trans();

  ilock(dp);

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if (check_protected(ip,0) == -1)  // no outer locking
  	  goto bad;

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);

  commit_trans();

  return 0;

bad:
  iunlockput(dp);
  commit_trans();
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    return 0;
  ilock(dp);

  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  ip->nlink = 1;
  ip->file_state[0] = 'U';    // task2, init. to Unprotected
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
    iupdate(dp);
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}

int
sys_open(void)
{
  char *path;
  int fd, omode, noderef;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0){
    //cprintf("DEBUG: #1\n");
    return -1;
    }
  if(omode & O_CREATE){
    begin_trans();
    ip = create(path, T_FILE, 0, 0);
    commit_trans();
    if(ip == 0){
      //cprintf("DEBUG: #2\n");
      return -1;
      }
  } else {
    noderef = omode & O_NODEREF;
    if((ip = namei(path,noderef)) == 0){
      //cprintf("DEBUG: #3\n");
      return -1;
      }
    ilock(ip);
    if(ip->type == T_DIR && omode != O_RDONLY && omode != O_NODEREF){
      iunlockput(ip);
      //cprintf("DEBUG: #4\n");
      return -1;
    }
  }

  // task2, check if file protected
  if (check_protected(ip,0) == -1)	// no outer lock mode
  	  return -1;

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    //cprintf("DEBUG: #5\n");
    return -1;
  }
  iunlock(ip);

  f->type = FD_INODE;
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}

int
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  begin_trans();
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    commit_trans();
    return -1;
  }
  iunlockput(ip);
  commit_trans();
  return 0;
}

int
sys_mknod(void)
{
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
    return -1;
  }
  iunlockput(ip);
  commit_trans();
  return 0;
}

int
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path,0)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
}

int
sys_exec(void)
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }

  if((ip = namei(path,0)) == 0)  // task2 - find i-node
       return -1;

  if (check_protected(ip,1) == -1)
  	  return -1;

return exec(path, argv);
}

int
sys_pipe(void)
{
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;

  if (check_protected(rf->ip,1) == -1)
	  return -1;

  if (check_protected(wf->ip,1) == -1)
	  return -1;

  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}

int				// task2, check if protected
check_protected(struct inode *ip, uint mode) {	// mode 0 - no outer locking , mode 1 - normal
	if (mode != 0)
		ilock(ip);
	if ((ip->type == T_FILE) && (ip->file_state[0] == 'P')&& (get_flt_value(ip->inum))) {
		iunlock(ip);
		return -1;
	}
	if (mode != 0)
		iunlock(ip);
	return 0;
}

int
sys_funprot(void) {
    char *pathName;
    char *password;
    struct inode *ip;

   if(argstr(0, &pathName) < 0 || argstr(1, &password) < 0)
      return -1;

    if((ip = namei(pathName,0)) == 0)
      return -1;

    ilock(ip);
    if((ip->type == T_FILE) && (ip->file_state[0] == 'P') && (get_flt_value(ip->inum))) {
    	if (strlen(password) != strlen(ip->password)) {
    		iunlock(ip);
    		return -1;
    	} else {
    		if (strncmp(ip->password, password, strlen(password)) != 0) {
    		  iunlock(ip);
    		  return -1;
    		} else {	// pass matched - making the file Unprotected
    			ip->file_state[0] = 'U';
    			update_file_for_all_procs(0, ip->inum); // updates all process that the file is Unprotected
    			iunlock(ip);
    		}
    	}
   } else
      iunlock(ip);
    return 0;
}

int
sys_fprot(void) {
    char *pathName;
    char *password;
    int len;
    struct inode *ip;

    if(argstr(0, &pathName) < 0 || argstr(1, &password) < 0)
      return -1;

    if((ip = namei(pathName,0)) == 0)  // get file i-node
      return -1;

    ilock(ip);
    // fails if its not a FILE or FILE  is open or FILE is already Protected
    if(ip->type != T_FILE || search_for_open_file(ip->inum) || ip->file_state[0] == 'P' ) {
      iunlock(ip);
      return -1;
    }

    len = strlen(password);
    if(len > 9 ) {	// check pass length
      iunlock(ip);
      return -1;
    } else {		// save the new password to the i-node
    	ip->file_state[0] = 'P';
    	strncpy(ip->password, password, len);
    	update_file_for_all_procs(1,ip->inum);
    	iunlock(ip);
    	return 0;
    }
}

int
sys_funlock(void) {
    char *pathName;
    char *password;
    struct inode *ip;

    if(argstr(0, &pathName) < 0 || argstr(1, &password) < 0)
      return -1;

    if((ip = namei(pathName,0)) == 0)
      return -1;

    ilock(ip);
    if((ip->type == T_FILE) && (ip->file_state[0] == 'P'))  {
    	if (strlen(password)!= strlen(ip->password)) {
    		iunlock(ip);
    		return -1;
    	} else {
    		if (strncmp(ip->password, password, strlen(password)) != 0) {
    			iunlock(ip);
    			return -1;
    		} else {
    			disable_lock_for_proc(ip->inum);
    			iunlock(ip);
    		}
    	}
   } else
	   iunlock(ip);
  return 0;
}
