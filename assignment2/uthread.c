#include "uthread.h"
#include "user.h"
#include "signal.h"

static struct uthread* threadTable[MAX_THREAD];
static int runningId;
static int currentThreads = 0;
static struct uthread* self;

int findNextFreeThreadId(void)
{
	int i;
	for (i=0; i < MAX_THREAD; i++){
		if (threadTable[i]->state == T_FREE)
			return threadTable[i]->tid;
	}
	return -1;
}

int findNextRunnableThreadId()
{
	int i = (runningId + 1) % MAX_THREAD;
	for (;; i = (i + 1) % MAX_THREAD)
	{
		if (threadTable[i]->state == T_RUNNABLE)
			return i;
	}
}

void uthread_init(void)
{
	// Initialize thread table
	int i;
	for (i=0; i < MAX_THREAD; i++){
		threadTable[i] = malloc(sizeof(struct uthread));
		threadTable[i]->state = T_FREE;
		threadTable[i] ->tid = i;
	}
	
	
	// Initialize main thread
	STORE_ESP(threadTable[0]->esp);
	STORE_EBP(threadTable[0]->ebp);
	
	threadTable[0]->state = T_RUNNING;
	runningId = 0;
	currentThreads++;
	
	signal(SIGALRM, &uthread_yield);
	alarm(THREAD_QUANTA);
}

int  uthread_create(void (*func)(void *), void* value)
{
	//int espBackup,ebpBackup;
	// Find next available thread slot
	int current = findNextFreeThreadId();
	if (current == -1)
		return -1;
	threadTable[current]->tid = current;
	threadTable[current]->firstrun = 1;
	currentThreads++;
	threadTable[current]->entry = func;
	threadTable[current]->value = value;
	threadTable[current]->stack = malloc(STACK_SIZE);
	threadTable[current]->esp = (int)threadTable[current]->stack + (STACK_SIZE-4);
	threadTable[current]->ebp = threadTable[current]->esp;
	
	/* DEBUG PRINT
	printf(1,"*** new thread tid = %d entry = %x esp = %x ebp = %x\n",threadTable[current]->tid,threadTable[current]->entry,threadTable[current]->esp,threadTable[current]->ebp); */
	
	// Set state for new thread and return it's ID
	threadTable[current]->state = T_RUNNABLE;
	return current;
}

void uthread_exit(void)
{
	/* DEBUG PRINT
	printf(1,"entered uthread_exit()\n"); */
	
	// Retrieve current thread
	self = threadTable[uthred_self()];
	
	// Free current thread's stack space
	if (self->tid)
		free(self->stack);
	
	// Set state of thread as FREE
	self->state = T_FREE;
	
	// Update number of running threads
	currentThreads--;
	
	// DEBUG PRINT
	//printf(1,"currentThreads = %d\n",currentThreads);
	
	if (currentThreads == 0){
		// DEBUG PRINT
		// printf(1,"currentThreads = 0 , FREEING ALL RESOURCES!\n");
		int i=0;
		for (i=0;i<MAX_THREAD;i++)
			free(threadTable[i]);
		exit();
	}
		
	// If we still got threads left, yield
	runningId = findNextRunnableThreadId();
	
	threadTable[runningId]->state = T_RUNNING;
	alarm(THREAD_QUANTA);
	LOAD_EBP(threadTable[runningId]->ebp);
	LOAD_ESP(threadTable[runningId]->esp);
	
	if (threadTable[runningId]->firstrun){
		threadTable[runningId]->firstrun = 0;
		wrapper(threadTable[runningId]->entry,threadTable[runningId]->value);
	}
	
	return;

}

void uthread_yield(void)
{
	// DEBUG PRINT
	//printf(1,"entered uthread_yield()\n");
	// Retrieve current thread
	self = threadTable[uthred_self()];
	// DEBUG PRINT
	//printf(1,"current thread id is %d\n",self->tid);
	// Set state of current thread as RUNNABLE
	self->state = T_RUNNABLE;
	
	// Store stack pointers
	STORE_ESP(self->esp);
	STORE_EBP(self->ebp);
	
	// Pop context of next thread 	
	runningId = findNextRunnableThreadId();
	threadTable[runningId]->state = T_RUNNING;
	// DEBUG PRINT
	// printf(1,"next thread id is %d\n",threadTable[runningId]->tid);
	// printf(1,"next->entry = %x , next->esp = %x , next->ebp = %x\n",threadTable[runningId]->entry,threadTable[runningId]->esp,threadTable[runningId]->ebp);
	
	alarm(THREAD_QUANTA);
	LOAD_EBP(threadTable[runningId]->ebp);
	LOAD_ESP(threadTable[runningId]->esp);
	if (threadTable[runningId]->firstrun){
		// DEBUG PRINT
		// printf(1,"FIRST RUN OF THREAD %d\n",threadTable[runningId]->tid);
		threadTable[runningId]->firstrun = 0;
		wrapper(threadTable[runningId]->entry,threadTable[runningId]->value);
	}
	return;
}

void wrapper(void (*entry)(void*),void *value) {
	// DEBUG PRINT
	// printf(1,"Reached wrapper function. value = %d, entry = %x!\n",value,&entry);
	entry(value);
	uthread_exit();
}

int  uthred_self(void)
{
	return runningId;
}

int  uthred_join(int tid)
{
	if (tid > MAX_THREAD)
		return -1;
	while (threadTable[tid]->state != T_FREE){}
	return 0;
}

void uthread_sleep(void)
{
	threadTable[runningId]->state = T_SLEEPING;
	printf(1,"thread %d is now sleeping\n",threadTable[runningId]->tid);
	
	self = threadTable[uthred_self()];
	
	// Store stack pointers
	STORE_ESP(self->esp);
	STORE_EBP(self->ebp);
	
	// Pop context of next thread 	
	runningId = findNextRunnableThreadId();
	threadTable[runningId]->state = T_RUNNING;
	// DEBUG PRINT
	// printf(1,"next thread id is %d\n",threadTable[runningId]->tid);
	// printf(1,"loaded esp and ebp. next->esp = %x , next->ebp = %x\n",threadTable[runningId]->esp,threadTable[runningId]->ebp);
	
	alarm(THREAD_QUANTA);
	LOAD_EBP(threadTable[runningId]->ebp);
	LOAD_ESP(threadTable[runningId]->esp);
	if (threadTable[runningId]->firstrun){
		threadTable[runningId]->firstrun = 0;
		wrapper(threadTable[runningId]->entry,threadTable[runningId]->value);
	}
	return;	
}
void uthread_wakeup(int tid)
{
	threadTable[tid]->state = T_RUNNABLE;
	// DEBUG PRINT
	// printf(1,"woke up thread %d and it is now runnable\n",threadTable[tid]->tid);
}

void printQueue(struct binary_semaphore* semaphore)
{
	printf(1,"*** WAITING QUEUE ***\n");
	int i;
	for (i=0;i<MAX_THREAD;i++){
			printf(1,"%d ",semaphore->waiting[i]);
	}
	printf(1,"\n*** WAITING QUEUE ***\n");	
}

void binary_semaphore_init(struct binary_semaphore* semaphore, int value)
{
	
	/* set initial value */
	semaphore->value = value;
	
	/* initialize internal queue */
	semaphore->counter = 0;
	int i;
	for (i=0;i<MAX_THREAD;i++){
		semaphore->waiting[i] = -1;
	}
}

void binary_semaphore_down(struct binary_semaphore* semaphore)
{
	alarm(0);
	if (semaphore->value ==0){
		semaphore->waiting[runningId] = semaphore->counter++;
		uthread_sleep();
	}
	semaphore->waiting[runningId] = -1;
	semaphore->value = 0;
	alarm(THREAD_QUANTA);
}

void binary_semaphore_up(struct binary_semaphore* semaphore)
{
	alarm(0);
	
	if (semaphore->value == 0){
		/* find next one in queue */		
		int i;
		int minNum = semaphore->counter;
		int minIndex = -1;
		for (i=0;i<MAX_THREAD;i++){
			if (semaphore->waiting[i] != -1 && semaphore->waiting[i] < minNum){
				minIndex = i;
				minNum = semaphore->waiting[i];
			}
		}
		semaphore->value = 1;
		//printQueue(semaphore);
		if (minIndex != -1){
			uthread_wakeup(minIndex);
		}
		
	}
	
	alarm(THREAD_QUANTA);
	
}