#include "uthread.h"
#include "user.h"
#include "signal.h"

static struct uthread* threadTable[MAX_THREAD];
static int runningId;
static int currentThreads = 0;

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
	printf(1,"Entered uthread_create\n");
	//int espBackup,ebpBackup;
	// Find next available thread slot
	int current = findNextFreeThreadId();
	printf(1,"Next free thread id = %d\n",current);
	if (current == -1)
		return -1;
	printf(1,"threadTable[%d]->tid = %d\n",current,current);
	threadTable[current]->tid = current;
	printf(1,"threadTable[%d]->firstrun = %d\n",current,1);
	threadTable[current]->firstrun = 1;
	currentThreads++;
	threadTable[current]->entry = func;
	threadTable[current]->value = value;
	threadTable[current]->stack = malloc(STACK_SIZE);
	threadTable[current]->esp = (int)threadTable[current]->stack + (STACK_SIZE-4);
	threadTable[current]->ebp = threadTable[current]->esp;
	
	// Set state for new thread and return it's ID
	printf(1,"STATE CHANGED TO RUNNABLE\n");
	threadTable[current]->state = T_RUNNABLE;
	printf(1,"RETURNING %d\n",current);
	return current;
}

void uthread_exit(void)
{
	printf(1,"entered uthread_exit()\n");
	
	// Retrieve current thread
	struct uthread *self = threadTable[uthred_self()];
	
	// Free current thread's stack space
	free(self->stack);
	
	// Set state of thread as FREE
	self->state = T_FREE;
	
	// Update number of running threads
	currentThreads--;
	
	if (currentThreads == 0){
		printf(1,"currentThreads = 0 , FREEING ALL RESOURCES!\n");
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
	printf(1,"entered uthread_yield()\n");
	// Retrieve current thread
	struct uthread *self = threadTable[uthred_self()];
	printf(1,"current thread id is %d\n",self->tid);
	// Set state of current thread as RUNNABLE
	self->state = T_RUNNABLE;
	
	// Store stack pointers
	printf(1,"uthread_yield: stored ESP\n");
	STORE_ESP(self->esp);
	printf(1,"uthread_yield: stored EBP\n");
	STORE_EBP(self->ebp);
	// Pop context of next thread 	
	runningId = findNextRunnableThreadId();
	
	threadTable[runningId]->state = T_RUNNING;
	printf(1,"next thread id is %d\n",threadTable[runningId]->tid);
	printf(1,"loaded esp and ebp. next->esp = %x , next->ebp = %x\n",threadTable[runningId]->esp,threadTable[runningId]->ebp);
	
	alarm(THREAD_QUANTA);
	LOAD_EBP(threadTable[runningId]->ebp);
	LOAD_ESP(threadTable[runningId]->esp);
	if (threadTable[runningId]->firstrun){
		threadTable[runningId]->firstrun = 0;
		/*PUSH(threadTable[runningId]->entry);
		PUSH(threadTable[runningId]->value);
		CALL(wrapper);*/
		wrapper(threadTable[runningId]->entry,threadTable[runningId]->value);
	}
	return;
}

void wrapper(void (*entry)(void*),void *value) {
	printf(1,"Reached wrapper function. value = %d, entry = %x!\n",value,&entry);
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