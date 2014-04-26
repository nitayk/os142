#define THREAD_QUANTA 5
#define STACK_SIZE  4096
#define MAX_THREAD  64

/********************************
	Macors which inline assembly
 ********************************/
 
// Saves the value of esp to var
#define STORE_ESP(var) 	asm("movl %%esp, %0;" : "=r" ( var ))

// Loads the contents of var into esp
#define LOAD_ESP(var) 	asm("movl %0, %%esp;" : : "r" ( var ))

// Saves the value of ebp to var
#define STORE_EBP(var) 	asm("movl %%ebp, %0;" : "=r" ( var ))

// Loads the contents of var into ebp
#define LOAD_EBP(var) 	asm("movl %0, %%ebp;" : : "r" ( var ))

// Calls the function func
#define CALL(addr)		asm("call *%0;" : : "r" ( addr ))

// Pushes the contents of var to the stack
#define PUSH(var)		asm("movl %0, %%edi; push %%edi;" : : "r" ( var ))

// POPS from the stack and jumps there
#define RET				asm("ret;")

// PUSH ALL
#define PUSHAL			asm("pushal;")


// POP ALL
#define POPAL			asm("popal;")

/* Possible states of a thread; */
typedef enum  {T_FREE, T_RUNNING, T_RUNNABLE, T_SLEEPING} uthread_state;

typedef struct uthread uthread_t, *uthread_p;

struct uthread {
	int				tid;
	int 	       	esp;        		/* current stack pointer */
	int 	       	ebp;				/* current base pointer */
	char		   *stack;	    		/* the thread's stack */
	uthread_state   state;     			/* running, runnable, sleeping, free */
	int				firstrun;   		/* holds 1 if thread didnt run yet, 0 otherwise */
	void		   (*entry)(void *);	/* entry function for uthread */
	void           *value;				/* argument for entry function */
};

struct binary_semaphore {
	int				value;					/* holds 1 if resource available, else 0 */
	int				waiting[MAX_THREAD];	/* waiting[i] = queue number for thread whose tid = i */
	int				counter;				/* holds next queue number */
};

void uthread_init(void);
int  uthread_create(void (*func)(void *), void* value);
void wrapper(void (*entry)(void *),void* value);
void uthread_exit(void);
void uthread_yield(void);
int  uthred_self(void);
int  uthred_join(int tid);
void uthread_sleep(void);
void uthread_wakeup(int tid);
void binary_semaphore_init(struct binary_semaphore* semaphore, int value);
void binary_semaphore_down(struct binary_semaphore* semaphore);  
void binary_semaphore_up(struct binary_semaphore* semaphore);
void printQueue(struct binary_semaphore* semaphore);