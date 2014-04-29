#define STACK_SIZE  4096
#define MAX_UTHREADS  64
#define UTHREAD_QUANTA 8
#include "types.h"

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
typedef struct uthread_table uthread_table;

struct uthread {
	int				tid;
	uint 	       	esp;        		/* current stack pointer */
	uint 	       	ebp;				/* current base pointer */
	uint 	       	eax;        /* current stack pointer */
	uint 	       	ebx;        /* current base pointer */
	uint 	       	ecx;        /* current stack pointer */
	uint 	       	edx;        /* current base pointer */
	uint 	       	esi;        /* current stack pointer */
	uint 	       	edi;        /* current base pointer */
	void		   *stack;	    		/* the thread's stack */
	uthread_state   state;     			/* running, runnable, sleeping, free */
	int				firstrun;   		/* holds 1 if thread didnt run yet, 0 otherwise */
	void		   (*entry)(void *);	/* entry function for uthread */
	void           *value;				/* argument for entry function */
	int 			waitingFor;   /*tid of a thread we joined */
};

struct uthread_table{
	 uthread_p threads[MAX_UTHREADS];
     uthread_p runningThread;
	 int threadCount;

};

uthread_table threadTable;



void uthread_init(void);
int  uthread_create(void (*func)(void *), void* value);
void wrapper(void);
void uthread_exit(void);
void uthread_yield(void);
int  uthread_self(void);
int  uthread_join(int tid);
void uthread_sleep(void);
void uthread_wakeup(int tid);

/*  Task 3 */
struct binary_semaphore {
	int				value;					
	int				waiting[MAX_UTHREADS];
	int				counter;
};

void binary_semaphore_init(struct binary_semaphore* semaphore, int value);
void binary_semaphore_down(struct binary_semaphore* semaphore);  
void binary_semaphore_up(struct binary_semaphore* semaphore);
void printQueue(struct binary_semaphore* semaphore);


/*
typedef struct binary_semaphore BSemaphore;
typedef struct uthread_queue *utQueue;
struct binary_semaphore{
	volatile uint  			    lock;  
	int 				isFree ;  // 1 means free, 0 means locked
	utQueue 			head ;  //first uthread in waiting queue
	int 				waiting ;  // number of uthreads waiting

};

struct uthread_queue{
	int 				   utid ;
	utQueue   			   next ;
};
//assignemnt2 task3 API
void binary_semaphore_init(struct binary_semaphore* semaphore, int value);
void binary_semaphore_down(struct binary_semaphore* semaphore);
void binary_semaphore_up(struct binary_semaphore* semaphore);

void uthread_enqueue(BSemaphore* s);
void uthread_dequeue(BSemaphore* s);
*/