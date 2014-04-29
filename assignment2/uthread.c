#include "uthread.h"
#include "user.h"
#include "signal.h"
#include "x86.h"

extern void alarm(int ticks);

int findNextFreeThreadId(void)
{
	int i;
	for (i=0; i < MAX_UTHREADS; i++){
		//if (threadTable.threads[i]->state == T_FREE)
			//return threadTable.threads[i]->tid;
		if (threadTable.threads[i] == 0)
			return i;
			
	}
	return -1;
}

uthread_p findNextRunnableThread()
{
	int i = (threadTable.runningThread->tid + 1) % MAX_UTHREADS;
	for (;; i = (i + 1) % MAX_UTHREADS)
	{
		if (threadTable.threads[i]->state == T_RUNNABLE)
			return threadTable.threads[i];
	}
}

void uthread_init(void)
{
	// Initialize thread table
	int i;
	for (i=1; i < MAX_UTHREADS; i++){
		/*threadTable.threads[i] = (uthread_p)malloc(sizeof(struct uthread));
		threadTable.threads[i]->state = T_FREE;
		threadTable.threads[i]->tid = i;*/
		threadTable.threads[i] = 0;
	}
	
	threadTable.threads[0] = (uthread_p)malloc(sizeof(uthread_t));
	// Initialize main thread
	STORE_ESP(threadTable.threads[0]->esp);
	STORE_EBP(threadTable.threads[0]->ebp);
	
	threadTable.threads[0]->state = T_RUNNING;
	threadTable.runningThread = threadTable.threads[0];
	threadTable.threadCount = 1;
	
	signal(SIGALRM, uthread_yield);
	alarm(UTHREAD_QUANTA);
}

int  uthread_create(void (*func)(void *), void* value)
{
	alarm(0);
	//int espBackup,ebpBackup;
	// Find next available thread slot
	int current = findNextFreeThreadId();
	if (current == -1)
		return -1;
	
	threadTable.threads[current] = (uthread_p)malloc(sizeof(uthread_t));
	threadTable.threads[current]->tid = current;
	threadTable.threads[current]->firstrun = 1;
	threadTable.threadCount++;
	threadTable.threads[current]->entry = func;
	threadTable.threads[current]->value = value;
	threadTable.threads[current]->stack = (void*)malloc(STACK_SIZE);
	threadTable.threads[current]->esp = (int)threadTable.threads[current]->stack + (STACK_SIZE-4);
	threadTable.threads[current]->ebp = threadTable.threads[current]->esp;
	
	// DEBUG PRINT
	//printf(1,"*** new thread tid = %d entry = %x esp = %x ebp = %x\n",threadTable.threads[current]->tid,threadTable.threads[current]->entry,threadTable.threads[current]->esp,threadTable.threads[current]->ebp);
	
	// Set state for new thread and return it's ID
	threadTable.threads[current]->state = T_RUNNABLE;
	alarm(UTHREAD_QUANTA);
	return current;
}

void uthread_exit(void)
{
	// DEBUG PRINT
	//printf(1,"*** thread %d exiting ***\n",threadTable.runningThread->tid);
	
	
	// Free current thread's stack space
	if (threadTable.runningThread->tid)
		free(threadTable.runningThread->stack);
		
	threadTable.threads[threadTable.runningThread->tid] = 0;
	
	free(threadTable.runningThread);
	
	// Set state of thread as FREE
	//threadTable.runningThread->state = T_FREE;
	
	// Update number of running threads
	threadTable.threadCount--;
	
	// DEBUG PRINT
	//printf(1,"threadTable.threadCount = %d\n",threadTable.threadCount);
	
	if (threadTable.threadCount == 0){
		// DEBUG PRINT
		// printf(1,"threadTable.threadCount = 0 , FREEING ALL RESOURCES!\n");
		//int i=0;
		//for (i=0;i<MAX_UTHREADS;i++)
			//free(threadTable.threads[i]);
		exit();
	}
		
	// If we still got threads left, yield
	threadTable.runningThread = findNextRunnableThread();
	
	threadTable.runningThread->state = T_RUNNING;
	alarm(UTHREAD_QUANTA);
	LOAD_ESP(threadTable.runningThread->esp);
	LOAD_EBP(threadTable.runningThread->ebp);
	
	if (threadTable.runningThread->firstrun){
		threadTable.runningThread->firstrun = 0;
		wrapper();
	}
	

}

void uthread_yield(void)
{
	// DEBUG PRINT
	//printf(1,"entered uthread_yield()\n");

	STORE_ESP(threadTable.runningThread->esp);
	STORE_EBP(threadTable.runningThread->ebp);
	
	// DEBUG PRINT
	//printf(1,"current thread id is %d\n",threadTable.runningThread->tid);

	if (threadTable.runningThread->state == T_RUNNING)
		threadTable.runningThread->state = T_RUNNABLE;
	

	// Pop context of next thread 	
	threadTable.runningThread = findNextRunnableThread();
	threadTable.runningThread->state = T_RUNNING;
	// DEBUG PRINT
	//printf(1,"next thread id is %d\n",threadTable.runningThread->tid);
	//printf(1,"next->entry = %x , next->esp = %x , next->ebp = %x\n",threadTable.runningThread->entry,threadTable.runningThread->esp,threadTable.runningThread->ebp);
	
	alarm(UTHREAD_QUANTA);
	LOAD_ESP(threadTable.runningThread->esp);
	LOAD_EBP(threadTable.runningThread->ebp);
	if (threadTable.runningThread->firstrun){
		// DEBUG PRINT
		// printf(1,"FIRST RUN OF THREAD %d\n",threadTable.runningThread->tid);
		threadTable.runningThread->firstrun = 0;
		CALL(wrapper);
		asm("ret");
	}
	return;
}

void wrapper(void) {
	threadTable.runningThread->entry(threadTable.runningThread->value);
	uthread_exit();
}

int uthread_self(void)
{
	return threadTable.runningThread->tid;
}

int uthread_join(int tid)
{
	if (tid > MAX_UTHREADS)
		return -1;
	//while (threadTable.threads[tid]->state != T_FREE){}
	while (threadTable.threads[tid]) {}
	return 0;
}

void uthread_sleep(void)
{
	
	// Store stack pointers
	STORE_ESP(threadTable.runningThread->esp);
	STORE_EBP(threadTable.runningThread->ebp);
	
	threadTable.runningThread->state = T_SLEEPING;
	printf(1,"thread %d is now sleeping\n",threadTable.runningThread->tid);
	
	// Pop context of next thread 	
	threadTable.runningThread = findNextRunnableThread();
	threadTable.runningThread->state = T_RUNNING;
	// DEBUG PRINT
	// printf(1,"next thread id is %d\n",threadTable.runningThread->tid);
	// printf(1,"loaded esp and ebp. next->esp = %x , next->ebp = %x\n",threadTable.runningThread->esp,threadTable.runningThread->ebp);
	
	alarm(UTHREAD_QUANTA);
	LOAD_EBP(threadTable.runningThread->ebp);
	LOAD_ESP(threadTable.runningThread->esp);
	if (threadTable.runningThread->firstrun){
		// DEBUG PRINT
		// printf(1,"FIRST RUN OF THREAD %d\n",threadTable.runningThread->tid);
		threadTable.runningThread->firstrun = 0;
		CALL(wrapper);
		asm("ret");
	}
	return;	
}
void uthread_wakeup(int tid)
{
	threadTable.threads[tid]->state = T_RUNNABLE;
	// DEBUG PRINT
	// printf(1,"woke up thread %d and it is now runnable\n",threadTable.threads[tid]->tid);
}

/*
void binary_semaphore_init(struct binary_semaphore* semaphore, int value){
  semaphore->lock = 0;
  semaphore->isFree=value;
  semaphore->head = 0;
  semaphore->waiting = 0;
}

//assignment2 task3.2
void binary_semaphore_down(struct binary_semaphore* semaphore){
  while(xchg(&semaphore->lock, 1) != 0); //aquire
  if(!semaphore->isFree){
    uthread_enqueue(semaphore); //realised iside
  }
    
  else{
    semaphore->isFree=0; //the semaphore is locked, no other thread can enter critical section
    xchg(&semaphore->lock, 0);//release
  }
  
}

//assignment2 task3.3
void binary_semaphore_up(struct binary_semaphore* semaphore){
  
  while(xchg(&semaphore->lock, 1) != 0); //aquire
  if(semaphore->waiting)
    uthread_dequeue(semaphore);
  else
    semaphore->isFree=1; //the semaphore is free, a waiting thread can enter critical section
  xchg(&semaphore->lock, 0);//release
}



//uthread queue API
void uthread_enqueue(BSemaphore *s){
  utQueue q = s->head;
  utQueue pq =0;   //previous queue;
  while(q){   //find the last link on queue
    pq=q;
    q= q->next;
  }
  q = malloc(sizeof(struct uthread_queue));
  q->utid = uthread_self() ; // the new uthread in queue is the current running thread
  q->next = 0; // this is the last uthread in queue
  if(pq)
    pq->next = q;  //the prev link now point to the new uthread in queue
  else
    s->head = q;
  s->waiting++;
  (threadTable.threads[q->utid])->state = T_SLEEPING;
  xchg(&s->lock, 0);//release
  uthread_yield() ; //go to sleep
}

void uthread_dequeue(BSemaphore *s){
  s->waiting--;
  utQueue q = s->head;  //take the first uthread in queue
  s->head = q->next;    // change the first uthread in queue to be the second one
  (threadTable.threads[q->utid])->state = T_RUNNABLE; //wake up the uthread
}

*/

void printQueue(struct binary_semaphore* semaphore)
{
	printf(1,"*** WAITING QUEUE ***\n");
	int i;
	for (i=0;i<MAX_UTHREADS;i++){
			printf(1,"%d ",semaphore->waiting[i]);
	}
	printf(1,"\n*** WAITING QUEUE ***\n");	
}

void binary_semaphore_init(struct binary_semaphore* semaphore, int value)
{
	
	
	semaphore->value = value;
	
	
	semaphore->counter = 0;
	int i;
	for (i=0;i<MAX_UTHREADS;i++){
		semaphore->waiting[i] = -1;
	}
}

void binary_semaphore_down(struct binary_semaphore* semaphore)
{
	alarm(0);
	if (semaphore->value ==0){
		semaphore->waiting[threadTable.runningThread->tid] = semaphore->counter++;
		//printf(1,"*** thread %d going to sleep ***\n",threadTable.runningThread->tid);
		threadTable.runningThread->state = T_SLEEPING; // TESTING
		uthread_yield(); // TESTING
	}
	semaphore->waiting[threadTable.runningThread->tid] = -1;
	semaphore->value = 0;
	alarm(UTHREAD_QUANTA);
}

void binary_semaphore_up(struct binary_semaphore* semaphore)
{
	alarm(0);
	
	if (semaphore->value == 0){
		
		int i;
		int minNum = semaphore->counter;
		int minIndex = -1;
		for (i=0;i<MAX_UTHREADS;i++){
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
	
	alarm(UTHREAD_QUANTA);
	
}