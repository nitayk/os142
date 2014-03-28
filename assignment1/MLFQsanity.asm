
_MLFQsanity:     file format elf32-i386


Disassembly of section .text:

00000000 <waste_time_function>:
#include "user.h"

#define NUM_OF_CHILDRENS 20
#define NUM_OF_CHILD_LOOPS 500

int waste_time_function() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 20             	sub    $0x20,%esp
	int sum = 0;
   6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	double i,j,k = 0.0;
   d:	d9 ee                	fldz   
   f:	dd 5d e0             	fstpl  -0x20(%ebp)
	for (i =0 ; i < 1750 ; i++) {
  12:	d9 ee                	fldz   
  14:	dd 5d f0             	fstpl  -0x10(%ebp)
  17:	eb 56                	jmp    6f <waste_time_function+0x6f>
		for (j = 0 ; j < i ; j++) {
  19:	d9 ee                	fldz   
  1b:	dd 5d e8             	fstpl  -0x18(%ebp)
  1e:	eb 32                	jmp    52 <waste_time_function+0x52>
			for (k = 0 ; k < j ; k++) {
  20:	d9 ee                	fldz   
  22:	dd 5d e0             	fstpl  -0x20(%ebp)
  25:	eb 0e                	jmp    35 <waste_time_function+0x35>
				sum += 1;
  27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int waste_time_function() {
	int sum = 0;
	double i,j,k = 0.0;
	for (i =0 ; i < 1750 ; i++) {
		for (j = 0 ; j < i ; j++) {
			for (k = 0 ; k < j ; k++) {
  2b:	dd 45 e0             	fldl   -0x20(%ebp)
  2e:	d9 e8                	fld1   
  30:	de c1                	faddp  %st,%st(1)
  32:	dd 5d e0             	fstpl  -0x20(%ebp)
  35:	dd 45 e8             	fldl   -0x18(%ebp)
  38:	dd 45 e0             	fldl   -0x20(%ebp)
  3b:	d9 c9                	fxch   %st(1)
  3d:	df e9                	fucomip %st(1),%st
  3f:	dd d8                	fstp   %st(0)
  41:	0f 97 c0             	seta   %al
  44:	84 c0                	test   %al,%al
  46:	75 df                	jne    27 <waste_time_function+0x27>

int waste_time_function() {
	int sum = 0;
	double i,j,k = 0.0;
	for (i =0 ; i < 1750 ; i++) {
		for (j = 0 ; j < i ; j++) {
  48:	dd 45 e8             	fldl   -0x18(%ebp)
  4b:	d9 e8                	fld1   
  4d:	de c1                	faddp  %st,%st(1)
  4f:	dd 5d e8             	fstpl  -0x18(%ebp)
  52:	dd 45 f0             	fldl   -0x10(%ebp)
  55:	dd 45 e8             	fldl   -0x18(%ebp)
  58:	d9 c9                	fxch   %st(1)
  5a:	df e9                	fucomip %st(1),%st
  5c:	dd d8                	fstp   %st(0)
  5e:	0f 97 c0             	seta   %al
  61:	84 c0                	test   %al,%al
  63:	75 bb                	jne    20 <waste_time_function+0x20>
#define NUM_OF_CHILD_LOOPS 500

int waste_time_function() {
	int sum = 0;
	double i,j,k = 0.0;
	for (i =0 ; i < 1750 ; i++) {
  65:	dd 45 f0             	fldl   -0x10(%ebp)
  68:	d9 e8                	fld1   
  6a:	de c1                	faddp  %st,%st(1)
  6c:	dd 5d f0             	fstpl  -0x10(%ebp)
  6f:	dd 05 a8 0f 00 00    	fldl   0xfa8
  75:	dd 45 f0             	fldl   -0x10(%ebp)
  78:	d9 c9                	fxch   %st(1)
  7a:	df e9                	fucomip %st(1),%st
  7c:	dd d8                	fstp   %st(0)
  7e:	0f 97 c0             	seta   %al
  81:	84 c0                	test   %al,%al
  83:	75 94                	jne    19 <waste_time_function+0x19>
			for (k = 0 ; k < j ; k++) {
				sum += 1;
			}
		}
	}
	return sum;
  85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  88:	c9                   	leave  
  89:	c3                   	ret    

0000008a <main>:

int main(int argc, char *argv[])
{
  8a:	55                   	push   %ebp
  8b:	89 e5                	mov    %esp,%ebp
  8d:	56                   	push   %esi
  8e:	53                   	push   %ebx
  8f:	83 e4 f0             	and    $0xfffffff0,%esp
  92:	81 ec b0 01 00 00    	sub    $0x1b0,%esp
	int i,j,index,wTime,rTime,ioTime,cid,avg_wTime,avg_rTime,avg_turnAround,flag = 0;
  98:	c7 84 24 90 01 00 00 	movl   $0x0,0x190(%esp)
  9f:	00 00 00 00 
	int low_avg_wTime,low_avg_rTime,low_avg_turnAround,high_avg_wTime,high_avg_rTime,high_avg_turnAround;
	int fork_id = 1;
  a3:	c7 84 24 74 01 00 00 	movl   $0x1,0x174(%esp)
  aa:	01 00 00 00 
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
  ae:	c7 84 24 ac 01 00 00 	movl   $0x0,0x1ac(%esp)
  b5:	00 00 00 00 
  b9:	eb 40                	jmp    fb <main+0x71>
		for (j=0 ; j < 4 ; j++)
  bb:	c7 84 24 a8 01 00 00 	movl   $0x0,0x1a8(%esp)
  c2:	00 00 00 00 
  c6:	eb 21                	jmp    e9 <main+0x5f>
			c_array[i][j] = 0;
  c8:	8b 84 24 ac 01 00 00 	mov    0x1ac(%esp),%eax
  cf:	c1 e0 02             	shl    $0x2,%eax
  d2:	03 84 24 a8 01 00 00 	add    0x1a8(%esp),%eax
  d9:	c7 44 84 28 00 00 00 	movl   $0x0,0x28(%esp,%eax,4)
  e0:	00 
	int i,j,index,wTime,rTime,ioTime,cid,avg_wTime,avg_rTime,avg_turnAround,flag = 0;
	int low_avg_wTime,low_avg_rTime,low_avg_turnAround,high_avg_wTime,high_avg_rTime,high_avg_turnAround;
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
		for (j=0 ; j < 4 ; j++)
  e1:	83 84 24 a8 01 00 00 	addl   $0x1,0x1a8(%esp)
  e8:	01 
  e9:	83 bc 24 a8 01 00 00 	cmpl   $0x3,0x1a8(%esp)
  f0:	03 
  f1:	7e d5                	jle    c8 <main+0x3e>
{
	int i,j,index,wTime,rTime,ioTime,cid,avg_wTime,avg_rTime,avg_turnAround,flag = 0;
	int low_avg_wTime,low_avg_rTime,low_avg_turnAround,high_avg_wTime,high_avg_rTime,high_avg_turnAround;
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
  f3:	83 84 24 ac 01 00 00 	addl   $0x1,0x1ac(%esp)
  fa:	01 
  fb:	83 bc 24 ac 01 00 00 	cmpl   $0x13,0x1ac(%esp)
 102:	13 
 103:	7e b6                	jle    bb <main+0x31>
		for (j=0 ; j < 4 ; j++)
			c_array[i][j] = 0;
	for (cid=0 ; cid < NUM_OF_CHILDRENS; cid++) {
 105:	c7 84 24 a0 01 00 00 	movl   $0x0,0x1a0(%esp)
 10c:	00 00 00 00 
 110:	e9 ba 00 00 00       	jmp    1cf <main+0x145>
		fork_id = fork();
 115:	e8 ba 07 00 00       	call   8d4 <fork>
 11a:	89 84 24 74 01 00 00 	mov    %eax,0x174(%esp)
		if (fork_id == 0) {   // child section
 121:	83 bc 24 74 01 00 00 	cmpl   $0x0,0x174(%esp)
 128:	00 
 129:	75 7a                	jne    1a5 <main+0x11b>
			if ( cid % 2 == 0) {
 12b:	8b 84 24 a0 01 00 00 	mov    0x1a0(%esp),%eax
 132:	83 e0 01             	and    $0x1,%eax
 135:	85 c0                	test   %eax,%eax
 137:	75 07                	jne    140 <main+0xb6>
				waste_time_function();
 139:	e8 c2 fe ff ff       	call   0 <waste_time_function>
 13e:	eb 1f                	jmp    15f <main+0xd5>
			} else
				printf(2,"cid <%d> is Activating I/O System Call\n",cid);
 140:	8b 84 24 a0 01 00 00 	mov    0x1a0(%esp),%eax
 147:	89 44 24 08          	mov    %eax,0x8(%esp)
 14b:	c7 44 24 04 28 0e 00 	movl   $0xe28,0x4(%esp)
 152:	00 
 153:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 15a:	e8 04 09 00 00       	call   a63 <printf>
			for (i = 0 ; i < NUM_OF_CHILD_LOOPS ; i++) {
 15f:	c7 84 24 ac 01 00 00 	movl   $0x0,0x1ac(%esp)
 166:	00 00 00 00 
 16a:	eb 27                	jmp    193 <main+0x109>
				printf(2,"cid <%d>\n",cid);
 16c:	8b 84 24 a0 01 00 00 	mov    0x1a0(%esp),%eax
 173:	89 44 24 08          	mov    %eax,0x8(%esp)
 177:	c7 44 24 04 50 0e 00 	movl   $0xe50,0x4(%esp)
 17e:	00 
 17f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 186:	e8 d8 08 00 00       	call   a63 <printf>
		if (fork_id == 0) {   // child section
			if ( cid % 2 == 0) {
				waste_time_function();
			} else
				printf(2,"cid <%d> is Activating I/O System Call\n",cid);
			for (i = 0 ; i < NUM_OF_CHILD_LOOPS ; i++) {
 18b:	83 84 24 ac 01 00 00 	addl   $0x1,0x1ac(%esp)
 192:	01 
 193:	81 bc 24 ac 01 00 00 	cmpl   $0x1f3,0x1ac(%esp)
 19a:	f3 01 00 00 
 19e:	7e cc                	jle    16c <main+0xe2>
				printf(2,"cid <%d>\n",cid);
			}
			exit();			// end of child section
 1a0:	e8 37 07 00 00       	call   8dc <exit>
		} else 				// father section starts here
			c_array[cid][0] = fork_id;		// position in array is by CID
 1a5:	8b 84 24 a0 01 00 00 	mov    0x1a0(%esp),%eax
 1ac:	c1 e0 04             	shl    $0x4,%eax
 1af:	8d 94 24 b0 01 00 00 	lea    0x1b0(%esp),%edx
 1b6:	01 d0                	add    %edx,%eax
 1b8:	8d 90 78 fe ff ff    	lea    -0x188(%eax),%edx
 1be:	8b 84 24 74 01 00 00 	mov    0x174(%esp),%eax
 1c5:	89 02                	mov    %eax,(%edx)
	int fork_id = 1;
	int c_array[NUM_OF_CHILDRENS][4];
	for (i=0 ; i < NUM_OF_CHILDRENS ; i++)	// init array
		for (j=0 ; j < 4 ; j++)
			c_array[i][j] = 0;
	for (cid=0 ; cid < NUM_OF_CHILDRENS; cid++) {
 1c7:	83 84 24 a0 01 00 00 	addl   $0x1,0x1a0(%esp)
 1ce:	01 
 1cf:	83 bc 24 a0 01 00 00 	cmpl   $0x13,0x1a0(%esp)
 1d6:	13 
 1d7:	0f 8e 38 ff ff ff    	jle    115 <main+0x8b>
			exit();			// end of child section
		} else 				// father section starts here
			c_array[cid][0] = fork_id;		// position in array is by CID
	}

	while ((fork_id = wait2(&wTime,&rTime,&ioTime)) > 0) {	// update data for all the childrens
 1dd:	e9 e4 00 00 00       	jmp    2c6 <main+0x23c>
		flag = 0;
 1e2:	c7 84 24 90 01 00 00 	movl   $0x0,0x190(%esp)
 1e9:	00 00 00 00 
		for (index = 0 ; index < NUM_OF_CHILDRENS && !flag ; index++) {
 1ed:	c7 84 24 a4 01 00 00 	movl   $0x0,0x1a4(%esp)
 1f4:	00 00 00 00 
 1f8:	e9 b1 00 00 00       	jmp    2ae <main+0x224>
			if (c_array[index][0] == fork_id) {
 1fd:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 204:	c1 e0 04             	shl    $0x4,%eax
 207:	8d 8c 24 b0 01 00 00 	lea    0x1b0(%esp),%ecx
 20e:	01 c8                	add    %ecx,%eax
 210:	2d 88 01 00 00       	sub    $0x188,%eax
 215:	8b 00                	mov    (%eax),%eax
 217:	3b 84 24 74 01 00 00 	cmp    0x174(%esp),%eax
 21e:	0f 85 82 00 00 00    	jne    2a6 <main+0x21c>
				c_array[index][1] = wTime;	// waiting time
 224:	8b 84 24 70 01 00 00 	mov    0x170(%esp),%eax
 22b:	8b 94 24 a4 01 00 00 	mov    0x1a4(%esp),%edx
 232:	c1 e2 04             	shl    $0x4,%edx
 235:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 23c:	01 f2                	add    %esi,%edx
 23e:	81 ea 84 01 00 00    	sub    $0x184,%edx
 244:	89 02                	mov    %eax,(%edx)
				c_array[index][2] = rTime;	// run time
 246:	8b 84 24 6c 01 00 00 	mov    0x16c(%esp),%eax
 24d:	8b 94 24 a4 01 00 00 	mov    0x1a4(%esp),%edx
 254:	c1 e2 04             	shl    $0x4,%edx
 257:	8d 8c 24 b0 01 00 00 	lea    0x1b0(%esp),%ecx
 25e:	01 ca                	add    %ecx,%edx
 260:	81 ea 80 01 00 00    	sub    $0x180,%edx
 266:	89 02                	mov    %eax,(%edx)
				c_array[index][3] = wTime+wTime+rTime; // turnaround time -> end time - creation time
 268:	8b 94 24 70 01 00 00 	mov    0x170(%esp),%edx
 26f:	8b 84 24 70 01 00 00 	mov    0x170(%esp),%eax
 276:	01 c2                	add    %eax,%edx
 278:	8b 84 24 6c 01 00 00 	mov    0x16c(%esp),%eax
 27f:	01 c2                	add    %eax,%edx
 281:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 288:	c1 e0 04             	shl    $0x4,%eax
 28b:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 292:	01 f0                	add    %esi,%eax
 294:	2d 7c 01 00 00       	sub    $0x17c,%eax
 299:	89 10                	mov    %edx,(%eax)
				flag = 1;
 29b:	c7 84 24 90 01 00 00 	movl   $0x1,0x190(%esp)
 2a2:	01 00 00 00 
			c_array[cid][0] = fork_id;		// position in array is by CID
	}

	while ((fork_id = wait2(&wTime,&rTime,&ioTime)) > 0) {	// update data for all the childrens
		flag = 0;
		for (index = 0 ; index < NUM_OF_CHILDRENS && !flag ; index++) {
 2a6:	83 84 24 a4 01 00 00 	addl   $0x1,0x1a4(%esp)
 2ad:	01 
 2ae:	83 bc 24 a4 01 00 00 	cmpl   $0x13,0x1a4(%esp)
 2b5:	13 
 2b6:	7f 0e                	jg     2c6 <main+0x23c>
 2b8:	83 bc 24 90 01 00 00 	cmpl   $0x0,0x190(%esp)
 2bf:	00 
 2c0:	0f 84 37 ff ff ff    	je     1fd <main+0x173>
			exit();			// end of child section
		} else 				// father section starts here
			c_array[cid][0] = fork_id;		// position in array is by CID
	}

	while ((fork_id = wait2(&wTime,&rTime,&ioTime)) > 0) {	// update data for all the childrens
 2c6:	8d 84 24 68 01 00 00 	lea    0x168(%esp),%eax
 2cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 2d1:	8d 84 24 6c 01 00 00 	lea    0x16c(%esp),%eax
 2d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 2dc:	8d 84 24 70 01 00 00 	lea    0x170(%esp),%eax
 2e3:	89 04 24             	mov    %eax,(%esp)
 2e6:	e8 01 06 00 00       	call   8ec <wait2>
 2eb:	89 84 24 74 01 00 00 	mov    %eax,0x174(%esp)
 2f2:	83 bc 24 74 01 00 00 	cmpl   $0x0,0x174(%esp)
 2f9:	00 
 2fa:	0f 8f e2 fe ff ff    	jg     1e2 <main+0x158>
				flag = 1;
			}
		}
	}

	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++) {
 300:	c7 84 24 a4 01 00 00 	movl   $0x0,0x1a4(%esp)
 307:	00 00 00 00 
 30b:	e9 41 01 00 00       	jmp    451 <main+0x3c7>
		avg_wTime += c_array[index][1];
 310:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 317:	c1 e0 04             	shl    $0x4,%eax
 31a:	8d 94 24 b0 01 00 00 	lea    0x1b0(%esp),%edx
 321:	01 d0                	add    %edx,%eax
 323:	2d 84 01 00 00       	sub    $0x184,%eax
 328:	8b 00                	mov    (%eax),%eax
 32a:	01 84 24 9c 01 00 00 	add    %eax,0x19c(%esp)
		avg_rTime += c_array[index][2];
 331:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 338:	c1 e0 04             	shl    $0x4,%eax
 33b:	8d 8c 24 b0 01 00 00 	lea    0x1b0(%esp),%ecx
 342:	01 c8                	add    %ecx,%eax
 344:	2d 80 01 00 00       	sub    $0x180,%eax
 349:	8b 00                	mov    (%eax),%eax
 34b:	01 84 24 98 01 00 00 	add    %eax,0x198(%esp)
		avg_turnAround += c_array[index][3];
 352:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 359:	c1 e0 04             	shl    $0x4,%eax
 35c:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 363:	01 f0                	add    %esi,%eax
 365:	2d 7c 01 00 00       	sub    $0x17c,%eax
 36a:	8b 00                	mov    (%eax),%eax
 36c:	01 84 24 94 01 00 00 	add    %eax,0x194(%esp)
		if (index % 2 == 0) {
 373:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 37a:	83 e0 01             	and    $0x1,%eax
 37d:	85 c0                	test   %eax,%eax
 37f:	75 65                	jne    3e6 <main+0x35c>
			low_avg_wTime += c_array[index][1];
 381:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 388:	c1 e0 04             	shl    $0x4,%eax
 38b:	8d 94 24 b0 01 00 00 	lea    0x1b0(%esp),%edx
 392:	01 d0                	add    %edx,%eax
 394:	2d 84 01 00 00       	sub    $0x184,%eax
 399:	8b 00                	mov    (%eax),%eax
 39b:	01 84 24 8c 01 00 00 	add    %eax,0x18c(%esp)
			low_avg_rTime += c_array[index][2];
 3a2:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 3a9:	c1 e0 04             	shl    $0x4,%eax
 3ac:	8d 8c 24 b0 01 00 00 	lea    0x1b0(%esp),%ecx
 3b3:	01 c8                	add    %ecx,%eax
 3b5:	2d 80 01 00 00       	sub    $0x180,%eax
 3ba:	8b 00                	mov    (%eax),%eax
 3bc:	01 84 24 88 01 00 00 	add    %eax,0x188(%esp)
			low_avg_turnAround += c_array[index][3];
 3c3:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 3ca:	c1 e0 04             	shl    $0x4,%eax
 3cd:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 3d4:	01 f0                	add    %esi,%eax
 3d6:	2d 7c 01 00 00       	sub    $0x17c,%eax
 3db:	8b 00                	mov    (%eax),%eax
 3dd:	01 84 24 84 01 00 00 	add    %eax,0x184(%esp)
 3e4:	eb 63                	jmp    449 <main+0x3bf>
		} else {
			high_avg_wTime += c_array[index][1];
 3e6:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 3ed:	c1 e0 04             	shl    $0x4,%eax
 3f0:	8d 94 24 b0 01 00 00 	lea    0x1b0(%esp),%edx
 3f7:	01 d0                	add    %edx,%eax
 3f9:	2d 84 01 00 00       	sub    $0x184,%eax
 3fe:	8b 00                	mov    (%eax),%eax
 400:	01 84 24 80 01 00 00 	add    %eax,0x180(%esp)
			high_avg_rTime += c_array[index][2];
 407:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 40e:	c1 e0 04             	shl    $0x4,%eax
 411:	8d 8c 24 b0 01 00 00 	lea    0x1b0(%esp),%ecx
 418:	01 c8                	add    %ecx,%eax
 41a:	2d 80 01 00 00       	sub    $0x180,%eax
 41f:	8b 00                	mov    (%eax),%eax
 421:	01 84 24 7c 01 00 00 	add    %eax,0x17c(%esp)
			high_avg_turnAround += c_array[index][3];
 428:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 42f:	c1 e0 04             	shl    $0x4,%eax
 432:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 439:	01 f0                	add    %esi,%eax
 43b:	2d 7c 01 00 00       	sub    $0x17c,%eax
 440:	8b 00                	mov    (%eax),%eax
 442:	01 84 24 78 01 00 00 	add    %eax,0x178(%esp)
				flag = 1;
			}
		}
	}

	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++) {
 449:	83 84 24 a4 01 00 00 	addl   $0x1,0x1a4(%esp)
 450:	01 
 451:	83 bc 24 a4 01 00 00 	cmpl   $0x13,0x1a4(%esp)
 458:	13 
 459:	0f 8e b1 fe ff ff    	jle    310 <main+0x286>
			high_avg_rTime += c_array[index][2];
			high_avg_turnAround += c_array[index][3];
		}
	}

	printf(2,"Average waiting time <%d> , Average run time <%d> , Average turnaround time <%d>\n",avg_wTime/NUM_OF_CHILDRENS,avg_rTime/NUM_OF_CHILDRENS,avg_turnAround/NUM_OF_CHILDRENS);
 45f:	8b 8c 24 94 01 00 00 	mov    0x194(%esp),%ecx
 466:	ba 67 66 66 66       	mov    $0x66666667,%edx
 46b:	89 c8                	mov    %ecx,%eax
 46d:	f7 ea                	imul   %edx
 46f:	c1 fa 03             	sar    $0x3,%edx
 472:	89 c8                	mov    %ecx,%eax
 474:	c1 f8 1f             	sar    $0x1f,%eax
 477:	89 d6                	mov    %edx,%esi
 479:	29 c6                	sub    %eax,%esi
 47b:	8b 8c 24 98 01 00 00 	mov    0x198(%esp),%ecx
 482:	ba 67 66 66 66       	mov    $0x66666667,%edx
 487:	89 c8                	mov    %ecx,%eax
 489:	f7 ea                	imul   %edx
 48b:	c1 fa 03             	sar    $0x3,%edx
 48e:	89 c8                	mov    %ecx,%eax
 490:	c1 f8 1f             	sar    $0x1f,%eax
 493:	89 d3                	mov    %edx,%ebx
 495:	29 c3                	sub    %eax,%ebx
 497:	8b 8c 24 9c 01 00 00 	mov    0x19c(%esp),%ecx
 49e:	ba 67 66 66 66       	mov    $0x66666667,%edx
 4a3:	89 c8                	mov    %ecx,%eax
 4a5:	f7 ea                	imul   %edx
 4a7:	c1 fa 03             	sar    $0x3,%edx
 4aa:	89 c8                	mov    %ecx,%eax
 4ac:	c1 f8 1f             	sar    $0x1f,%eax
 4af:	89 d1                	mov    %edx,%ecx
 4b1:	29 c1                	sub    %eax,%ecx
 4b3:	89 c8                	mov    %ecx,%eax
 4b5:	89 74 24 10          	mov    %esi,0x10(%esp)
 4b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 4bd:	89 44 24 08          	mov    %eax,0x8(%esp)
 4c1:	c7 44 24 04 5c 0e 00 	movl   $0xe5c,0x4(%esp)
 4c8:	00 
 4c9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 4d0:	e8 8e 05 00 00       	call   a63 <printf>
	printf(2,"Average Low Priority Queue: waiting time <%d> , run time <%d> , turnaround time <%d>\n",low_avg_wTime/(NUM_OF_CHILDRENS/2),low_avg_rTime/(NUM_OF_CHILDRENS/2),low_avg_turnAround/(NUM_OF_CHILDRENS/2));
 4d5:	8b 8c 24 84 01 00 00 	mov    0x184(%esp),%ecx
 4dc:	ba 67 66 66 66       	mov    $0x66666667,%edx
 4e1:	89 c8                	mov    %ecx,%eax
 4e3:	f7 ea                	imul   %edx
 4e5:	c1 fa 02             	sar    $0x2,%edx
 4e8:	89 c8                	mov    %ecx,%eax
 4ea:	c1 f8 1f             	sar    $0x1f,%eax
 4ed:	89 d6                	mov    %edx,%esi
 4ef:	29 c6                	sub    %eax,%esi
 4f1:	8b 8c 24 88 01 00 00 	mov    0x188(%esp),%ecx
 4f8:	ba 67 66 66 66       	mov    $0x66666667,%edx
 4fd:	89 c8                	mov    %ecx,%eax
 4ff:	f7 ea                	imul   %edx
 501:	c1 fa 02             	sar    $0x2,%edx
 504:	89 c8                	mov    %ecx,%eax
 506:	c1 f8 1f             	sar    $0x1f,%eax
 509:	89 d3                	mov    %edx,%ebx
 50b:	29 c3                	sub    %eax,%ebx
 50d:	8b 8c 24 8c 01 00 00 	mov    0x18c(%esp),%ecx
 514:	ba 67 66 66 66       	mov    $0x66666667,%edx
 519:	89 c8                	mov    %ecx,%eax
 51b:	f7 ea                	imul   %edx
 51d:	c1 fa 02             	sar    $0x2,%edx
 520:	89 c8                	mov    %ecx,%eax
 522:	c1 f8 1f             	sar    $0x1f,%eax
 525:	89 d1                	mov    %edx,%ecx
 527:	29 c1                	sub    %eax,%ecx
 529:	89 c8                	mov    %ecx,%eax
 52b:	89 74 24 10          	mov    %esi,0x10(%esp)
 52f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 533:	89 44 24 08          	mov    %eax,0x8(%esp)
 537:	c7 44 24 04 b0 0e 00 	movl   $0xeb0,0x4(%esp)
 53e:	00 
 53f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 546:	e8 18 05 00 00       	call   a63 <printf>
	printf(2,"Average High Priority Queue: waiting time <%d> , run time <%d> , turnaround time <%d>\n",high_avg_wTime/(NUM_OF_CHILDRENS/2),high_avg_rTime/(NUM_OF_CHILDRENS/2),high_avg_turnAround/(NUM_OF_CHILDRENS/2));
 54b:	8b 8c 24 78 01 00 00 	mov    0x178(%esp),%ecx
 552:	ba 67 66 66 66       	mov    $0x66666667,%edx
 557:	89 c8                	mov    %ecx,%eax
 559:	f7 ea                	imul   %edx
 55b:	c1 fa 02             	sar    $0x2,%edx
 55e:	89 c8                	mov    %ecx,%eax
 560:	c1 f8 1f             	sar    $0x1f,%eax
 563:	89 d6                	mov    %edx,%esi
 565:	29 c6                	sub    %eax,%esi
 567:	8b 8c 24 7c 01 00 00 	mov    0x17c(%esp),%ecx
 56e:	ba 67 66 66 66       	mov    $0x66666667,%edx
 573:	89 c8                	mov    %ecx,%eax
 575:	f7 ea                	imul   %edx
 577:	c1 fa 02             	sar    $0x2,%edx
 57a:	89 c8                	mov    %ecx,%eax
 57c:	c1 f8 1f             	sar    $0x1f,%eax
 57f:	89 d3                	mov    %edx,%ebx
 581:	29 c3                	sub    %eax,%ebx
 583:	8b 8c 24 80 01 00 00 	mov    0x180(%esp),%ecx
 58a:	ba 67 66 66 66       	mov    $0x66666667,%edx
 58f:	89 c8                	mov    %ecx,%eax
 591:	f7 ea                	imul   %edx
 593:	c1 fa 02             	sar    $0x2,%edx
 596:	89 c8                	mov    %ecx,%eax
 598:	c1 f8 1f             	sar    $0x1f,%eax
 59b:	89 d1                	mov    %edx,%ecx
 59d:	29 c1                	sub    %eax,%ecx
 59f:	89 c8                	mov    %ecx,%eax
 5a1:	89 74 24 10          	mov    %esi,0x10(%esp)
 5a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 5a9:	89 44 24 08          	mov    %eax,0x8(%esp)
 5ad:	c7 44 24 04 08 0f 00 	movl   $0xf08,0x4(%esp)
 5b4:	00 
 5b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 5bc:	e8 a2 04 00 00       	call   a63 <printf>
	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++)
 5c1:	c7 84 24 a4 01 00 00 	movl   $0x0,0x1a4(%esp)
 5c8:	00 00 00 00 
 5cc:	e9 94 00 00 00       	jmp    665 <main+0x5db>
		printf(2,"Child <%d>: Waiting time %d , Running time %d , Turnaround time %d\n",c_array[index][0],c_array[index][1],c_array[index][2],c_array[index][3]);
 5d1:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 5d8:	c1 e0 04             	shl    $0x4,%eax
 5db:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 5e2:	01 f0                	add    %esi,%eax
 5e4:	2d 7c 01 00 00       	sub    $0x17c,%eax
 5e9:	8b 18                	mov    (%eax),%ebx
 5eb:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 5f2:	c1 e0 04             	shl    $0x4,%eax
 5f5:	8d 94 24 b0 01 00 00 	lea    0x1b0(%esp),%edx
 5fc:	01 d0                	add    %edx,%eax
 5fe:	2d 80 01 00 00       	sub    $0x180,%eax
 603:	8b 08                	mov    (%eax),%ecx
 605:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 60c:	c1 e0 04             	shl    $0x4,%eax
 60f:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 616:	01 f0                	add    %esi,%eax
 618:	2d 84 01 00 00       	sub    $0x184,%eax
 61d:	8b 10                	mov    (%eax),%edx
 61f:	8b 84 24 a4 01 00 00 	mov    0x1a4(%esp),%eax
 626:	c1 e0 04             	shl    $0x4,%eax
 629:	8d b4 24 b0 01 00 00 	lea    0x1b0(%esp),%esi
 630:	01 f0                	add    %esi,%eax
 632:	2d 88 01 00 00       	sub    $0x188,%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 63d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 641:	89 54 24 0c          	mov    %edx,0xc(%esp)
 645:	89 44 24 08          	mov    %eax,0x8(%esp)
 649:	c7 44 24 04 60 0f 00 	movl   $0xf60,0x4(%esp)
 650:	00 
 651:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 658:	e8 06 04 00 00       	call   a63 <printf>
	}

	printf(2,"Average waiting time <%d> , Average run time <%d> , Average turnaround time <%d>\n",avg_wTime/NUM_OF_CHILDRENS,avg_rTime/NUM_OF_CHILDRENS,avg_turnAround/NUM_OF_CHILDRENS);
	printf(2,"Average Low Priority Queue: waiting time <%d> , run time <%d> , turnaround time <%d>\n",low_avg_wTime/(NUM_OF_CHILDRENS/2),low_avg_rTime/(NUM_OF_CHILDRENS/2),low_avg_turnAround/(NUM_OF_CHILDRENS/2));
	printf(2,"Average High Priority Queue: waiting time <%d> , run time <%d> , turnaround time <%d>\n",high_avg_wTime/(NUM_OF_CHILDRENS/2),high_avg_rTime/(NUM_OF_CHILDRENS/2),high_avg_turnAround/(NUM_OF_CHILDRENS/2));
	for (index = 0 ; index < NUM_OF_CHILDRENS ; index++)
 65d:	83 84 24 a4 01 00 00 	addl   $0x1,0x1a4(%esp)
 664:	01 
 665:	83 bc 24 a4 01 00 00 	cmpl   $0x13,0x1a4(%esp)
 66c:	13 
 66d:	0f 8e 5e ff ff ff    	jle    5d1 <main+0x547>
		printf(2,"Child <%d>: Waiting time %d , Running time %d , Turnaround time %d\n",c_array[index][0],c_array[index][1],c_array[index][2],c_array[index][3]);
	exit();
 673:	e8 64 02 00 00       	call   8dc <exit>

00000678 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	57                   	push   %edi
 67c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 67d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 680:	8b 55 10             	mov    0x10(%ebp),%edx
 683:	8b 45 0c             	mov    0xc(%ebp),%eax
 686:	89 cb                	mov    %ecx,%ebx
 688:	89 df                	mov    %ebx,%edi
 68a:	89 d1                	mov    %edx,%ecx
 68c:	fc                   	cld    
 68d:	f3 aa                	rep stos %al,%es:(%edi)
 68f:	89 ca                	mov    %ecx,%edx
 691:	89 fb                	mov    %edi,%ebx
 693:	89 5d 08             	mov    %ebx,0x8(%ebp)
 696:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 699:	5b                   	pop    %ebx
 69a:	5f                   	pop    %edi
 69b:	5d                   	pop    %ebp
 69c:	c3                   	ret    

0000069d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 69d:	55                   	push   %ebp
 69e:	89 e5                	mov    %esp,%ebp
 6a0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 6a3:	8b 45 08             	mov    0x8(%ebp),%eax
 6a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 6a9:	90                   	nop
 6aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ad:	0f b6 10             	movzbl (%eax),%edx
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
 6b3:	88 10                	mov    %dl,(%eax)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	0f b6 00             	movzbl (%eax),%eax
 6bb:	84 c0                	test   %al,%al
 6bd:	0f 95 c0             	setne  %al
 6c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 6c8:	84 c0                	test   %al,%al
 6ca:	75 de                	jne    6aa <strcpy+0xd>
    ;
  return os;
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6cf:	c9                   	leave  
 6d0:	c3                   	ret    

000006d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6d1:	55                   	push   %ebp
 6d2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 6d4:	eb 08                	jmp    6de <strcmp+0xd>
    p++, q++;
 6d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6da:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 6de:	8b 45 08             	mov    0x8(%ebp),%eax
 6e1:	0f b6 00             	movzbl (%eax),%eax
 6e4:	84 c0                	test   %al,%al
 6e6:	74 10                	je     6f8 <strcmp+0x27>
 6e8:	8b 45 08             	mov    0x8(%ebp),%eax
 6eb:	0f b6 10             	movzbl (%eax),%edx
 6ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f1:	0f b6 00             	movzbl (%eax),%eax
 6f4:	38 c2                	cmp    %al,%dl
 6f6:	74 de                	je     6d6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 6f8:	8b 45 08             	mov    0x8(%ebp),%eax
 6fb:	0f b6 00             	movzbl (%eax),%eax
 6fe:	0f b6 d0             	movzbl %al,%edx
 701:	8b 45 0c             	mov    0xc(%ebp),%eax
 704:	0f b6 00             	movzbl (%eax),%eax
 707:	0f b6 c0             	movzbl %al,%eax
 70a:	89 d1                	mov    %edx,%ecx
 70c:	29 c1                	sub    %eax,%ecx
 70e:	89 c8                	mov    %ecx,%eax
}
 710:	5d                   	pop    %ebp
 711:	c3                   	ret    

00000712 <strlen>:

uint
strlen(char *s)
{
 712:	55                   	push   %ebp
 713:	89 e5                	mov    %esp,%ebp
 715:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 718:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 71f:	eb 04                	jmp    725 <strlen+0x13>
 721:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	03 45 08             	add    0x8(%ebp),%eax
 72b:	0f b6 00             	movzbl (%eax),%eax
 72e:	84 c0                	test   %al,%al
 730:	75 ef                	jne    721 <strlen+0xf>
    ;
  return n;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 735:	c9                   	leave  
 736:	c3                   	ret    

00000737 <memset>:

void*
memset(void *dst, int c, uint n)
{
 737:	55                   	push   %ebp
 738:	89 e5                	mov    %esp,%ebp
 73a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 73d:	8b 45 10             	mov    0x10(%ebp),%eax
 740:	89 44 24 08          	mov    %eax,0x8(%esp)
 744:	8b 45 0c             	mov    0xc(%ebp),%eax
 747:	89 44 24 04          	mov    %eax,0x4(%esp)
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	89 04 24             	mov    %eax,(%esp)
 751:	e8 22 ff ff ff       	call   678 <stosb>
  return dst;
 756:	8b 45 08             	mov    0x8(%ebp),%eax
}
 759:	c9                   	leave  
 75a:	c3                   	ret    

0000075b <strchr>:

char*
strchr(const char *s, char c)
{
 75b:	55                   	push   %ebp
 75c:	89 e5                	mov    %esp,%ebp
 75e:	83 ec 04             	sub    $0x4,%esp
 761:	8b 45 0c             	mov    0xc(%ebp),%eax
 764:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 767:	eb 14                	jmp    77d <strchr+0x22>
    if(*s == c)
 769:	8b 45 08             	mov    0x8(%ebp),%eax
 76c:	0f b6 00             	movzbl (%eax),%eax
 76f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 772:	75 05                	jne    779 <strchr+0x1e>
      return (char*)s;
 774:	8b 45 08             	mov    0x8(%ebp),%eax
 777:	eb 13                	jmp    78c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 779:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 77d:	8b 45 08             	mov    0x8(%ebp),%eax
 780:	0f b6 00             	movzbl (%eax),%eax
 783:	84 c0                	test   %al,%al
 785:	75 e2                	jne    769 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 787:	b8 00 00 00 00       	mov    $0x0,%eax
}
 78c:	c9                   	leave  
 78d:	c3                   	ret    

0000078e <gets>:

char*
gets(char *buf, int max)
{
 78e:	55                   	push   %ebp
 78f:	89 e5                	mov    %esp,%ebp
 791:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 794:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 79b:	eb 44                	jmp    7e1 <gets+0x53>
    cc = read(0, &c, 1);
 79d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7a4:	00 
 7a5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 7a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7b3:	e8 4c 01 00 00       	call   904 <read>
 7b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 7bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7bf:	7e 2d                	jle    7ee <gets+0x60>
      break;
    buf[i++] = c;
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	03 45 08             	add    0x8(%ebp),%eax
 7c7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 7cb:	88 10                	mov    %dl,(%eax)
 7cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 7d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 7d5:	3c 0a                	cmp    $0xa,%al
 7d7:	74 16                	je     7ef <gets+0x61>
 7d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 7dd:	3c 0d                	cmp    $0xd,%al
 7df:	74 0e                	je     7ef <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	83 c0 01             	add    $0x1,%eax
 7e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 7ea:	7c b1                	jl     79d <gets+0xf>
 7ec:	eb 01                	jmp    7ef <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 7ee:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	03 45 08             	add    0x8(%ebp),%eax
 7f5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 7f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7fb:	c9                   	leave  
 7fc:	c3                   	ret    

000007fd <stat>:

int
stat(char *n, struct stat *st)
{
 7fd:	55                   	push   %ebp
 7fe:	89 e5                	mov    %esp,%ebp
 800:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 803:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 80a:	00 
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	89 04 24             	mov    %eax,(%esp)
 811:	e8 16 01 00 00       	call   92c <open>
 816:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 819:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 81d:	79 07                	jns    826 <stat+0x29>
    return -1;
 81f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 824:	eb 23                	jmp    849 <stat+0x4c>
  r = fstat(fd, st);
 826:	8b 45 0c             	mov    0xc(%ebp),%eax
 829:	89 44 24 04          	mov    %eax,0x4(%esp)
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	89 04 24             	mov    %eax,(%esp)
 833:	e8 0c 01 00 00       	call   944 <fstat>
 838:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	89 04 24             	mov    %eax,(%esp)
 841:	e8 ce 00 00 00       	call   914 <close>
  return r;
 846:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 849:	c9                   	leave  
 84a:	c3                   	ret    

0000084b <atoi>:

int
atoi(const char *s)
{
 84b:	55                   	push   %ebp
 84c:	89 e5                	mov    %esp,%ebp
 84e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 851:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 858:	eb 23                	jmp    87d <atoi+0x32>
    n = n*10 + *s++ - '0';
 85a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 85d:	89 d0                	mov    %edx,%eax
 85f:	c1 e0 02             	shl    $0x2,%eax
 862:	01 d0                	add    %edx,%eax
 864:	01 c0                	add    %eax,%eax
 866:	89 c2                	mov    %eax,%edx
 868:	8b 45 08             	mov    0x8(%ebp),%eax
 86b:	0f b6 00             	movzbl (%eax),%eax
 86e:	0f be c0             	movsbl %al,%eax
 871:	01 d0                	add    %edx,%eax
 873:	83 e8 30             	sub    $0x30,%eax
 876:	89 45 fc             	mov    %eax,-0x4(%ebp)
 879:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 87d:	8b 45 08             	mov    0x8(%ebp),%eax
 880:	0f b6 00             	movzbl (%eax),%eax
 883:	3c 2f                	cmp    $0x2f,%al
 885:	7e 0a                	jle    891 <atoi+0x46>
 887:	8b 45 08             	mov    0x8(%ebp),%eax
 88a:	0f b6 00             	movzbl (%eax),%eax
 88d:	3c 39                	cmp    $0x39,%al
 88f:	7e c9                	jle    85a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 894:	c9                   	leave  
 895:	c3                   	ret    

00000896 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 896:	55                   	push   %ebp
 897:	89 e5                	mov    %esp,%ebp
 899:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 89c:	8b 45 08             	mov    0x8(%ebp),%eax
 89f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 8a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8a8:	eb 13                	jmp    8bd <memmove+0x27>
    *dst++ = *src++;
 8aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ad:	0f b6 10             	movzbl (%eax),%edx
 8b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b3:	88 10                	mov    %dl,(%eax)
 8b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 8b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 8bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 8c1:	0f 9f c0             	setg   %al
 8c4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 8c8:	84 c0                	test   %al,%al
 8ca:	75 de                	jne    8aa <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 8cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 8cf:	c9                   	leave  
 8d0:	c3                   	ret    
 8d1:	90                   	nop
 8d2:	90                   	nop
 8d3:	90                   	nop

000008d4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 8d4:	b8 01 00 00 00       	mov    $0x1,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <exit>:
SYSCALL(exit)
 8dc:	b8 02 00 00 00       	mov    $0x2,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <wait>:
SYSCALL(wait)
 8e4:	b8 03 00 00 00       	mov    $0x3,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <wait2>:
SYSCALL(wait2)
 8ec:	b8 16 00 00 00       	mov    $0x16,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <add_path>:
SYSCALL(add_path)
 8f4:	b8 17 00 00 00       	mov    $0x17,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <pipe>:
SYSCALL(pipe)
 8fc:	b8 04 00 00 00       	mov    $0x4,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <read>:
SYSCALL(read)
 904:	b8 05 00 00 00       	mov    $0x5,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <write>:
SYSCALL(write)
 90c:	b8 10 00 00 00       	mov    $0x10,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <close>:
SYSCALL(close)
 914:	b8 15 00 00 00       	mov    $0x15,%eax
 919:	cd 40                	int    $0x40
 91b:	c3                   	ret    

0000091c <kill>:
SYSCALL(kill)
 91c:	b8 06 00 00 00       	mov    $0x6,%eax
 921:	cd 40                	int    $0x40
 923:	c3                   	ret    

00000924 <exec>:
SYSCALL(exec)
 924:	b8 07 00 00 00       	mov    $0x7,%eax
 929:	cd 40                	int    $0x40
 92b:	c3                   	ret    

0000092c <open>:
SYSCALL(open)
 92c:	b8 0f 00 00 00       	mov    $0xf,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <mknod>:
SYSCALL(mknod)
 934:	b8 11 00 00 00       	mov    $0x11,%eax
 939:	cd 40                	int    $0x40
 93b:	c3                   	ret    

0000093c <unlink>:
SYSCALL(unlink)
 93c:	b8 12 00 00 00       	mov    $0x12,%eax
 941:	cd 40                	int    $0x40
 943:	c3                   	ret    

00000944 <fstat>:
SYSCALL(fstat)
 944:	b8 08 00 00 00       	mov    $0x8,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <link>:
SYSCALL(link)
 94c:	b8 13 00 00 00       	mov    $0x13,%eax
 951:	cd 40                	int    $0x40
 953:	c3                   	ret    

00000954 <mkdir>:
SYSCALL(mkdir)
 954:	b8 14 00 00 00       	mov    $0x14,%eax
 959:	cd 40                	int    $0x40
 95b:	c3                   	ret    

0000095c <chdir>:
SYSCALL(chdir)
 95c:	b8 09 00 00 00       	mov    $0x9,%eax
 961:	cd 40                	int    $0x40
 963:	c3                   	ret    

00000964 <dup>:
SYSCALL(dup)
 964:	b8 0a 00 00 00       	mov    $0xa,%eax
 969:	cd 40                	int    $0x40
 96b:	c3                   	ret    

0000096c <getpid>:
SYSCALL(getpid)
 96c:	b8 0b 00 00 00       	mov    $0xb,%eax
 971:	cd 40                	int    $0x40
 973:	c3                   	ret    

00000974 <sbrk>:
SYSCALL(sbrk)
 974:	b8 0c 00 00 00       	mov    $0xc,%eax
 979:	cd 40                	int    $0x40
 97b:	c3                   	ret    

0000097c <sleep>:
SYSCALL(sleep)
 97c:	b8 0d 00 00 00       	mov    $0xd,%eax
 981:	cd 40                	int    $0x40
 983:	c3                   	ret    

00000984 <uptime>:
SYSCALL(uptime)
 984:	b8 0e 00 00 00       	mov    $0xe,%eax
 989:	cd 40                	int    $0x40
 98b:	c3                   	ret    

0000098c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 98c:	55                   	push   %ebp
 98d:	89 e5                	mov    %esp,%ebp
 98f:	83 ec 28             	sub    $0x28,%esp
 992:	8b 45 0c             	mov    0xc(%ebp),%eax
 995:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 998:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 99f:	00 
 9a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 9a7:	8b 45 08             	mov    0x8(%ebp),%eax
 9aa:	89 04 24             	mov    %eax,(%esp)
 9ad:	e8 5a ff ff ff       	call   90c <write>
}
 9b2:	c9                   	leave  
 9b3:	c3                   	ret    

000009b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9b4:	55                   	push   %ebp
 9b5:	89 e5                	mov    %esp,%ebp
 9b7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 9ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 9c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 9c5:	74 17                	je     9de <printint+0x2a>
 9c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 9cb:	79 11                	jns    9de <printint+0x2a>
    neg = 1;
 9cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 9d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 9d7:	f7 d8                	neg    %eax
 9d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9dc:	eb 06                	jmp    9e4 <printint+0x30>
  } else {
    x = xx;
 9de:	8b 45 0c             	mov    0xc(%ebp),%eax
 9e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 9e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 9eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 9ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9f1:	ba 00 00 00 00       	mov    $0x0,%edx
 9f6:	f7 f1                	div    %ecx
 9f8:	89 d0                	mov    %edx,%eax
 9fa:	0f b6 90 18 12 00 00 	movzbl 0x1218(%eax),%edx
 a01:	8d 45 dc             	lea    -0x24(%ebp),%eax
 a04:	03 45 f4             	add    -0xc(%ebp),%eax
 a07:	88 10                	mov    %dl,(%eax)
 a09:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 a0d:	8b 55 10             	mov    0x10(%ebp),%edx
 a10:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a16:	ba 00 00 00 00       	mov    $0x0,%edx
 a1b:	f7 75 d4             	divl   -0x2c(%ebp)
 a1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a25:	75 c4                	jne    9eb <printint+0x37>
  if(neg)
 a27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a2b:	74 2a                	je     a57 <printint+0xa3>
    buf[i++] = '-';
 a2d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 a30:	03 45 f4             	add    -0xc(%ebp),%eax
 a33:	c6 00 2d             	movb   $0x2d,(%eax)
 a36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 a3a:	eb 1b                	jmp    a57 <printint+0xa3>
    putc(fd, buf[i]);
 a3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 a3f:	03 45 f4             	add    -0xc(%ebp),%eax
 a42:	0f b6 00             	movzbl (%eax),%eax
 a45:	0f be c0             	movsbl %al,%eax
 a48:	89 44 24 04          	mov    %eax,0x4(%esp)
 a4c:	8b 45 08             	mov    0x8(%ebp),%eax
 a4f:	89 04 24             	mov    %eax,(%esp)
 a52:	e8 35 ff ff ff       	call   98c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 a57:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 a5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a5f:	79 db                	jns    a3c <printint+0x88>
    putc(fd, buf[i]);
}
 a61:	c9                   	leave  
 a62:	c3                   	ret    

00000a63 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 a63:	55                   	push   %ebp
 a64:	89 e5                	mov    %esp,%ebp
 a66:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 a69:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 a70:	8d 45 0c             	lea    0xc(%ebp),%eax
 a73:	83 c0 04             	add    $0x4,%eax
 a76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a80:	e9 7d 01 00 00       	jmp    c02 <printf+0x19f>
    c = fmt[i] & 0xff;
 a85:	8b 55 0c             	mov    0xc(%ebp),%edx
 a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8b:	01 d0                	add    %edx,%eax
 a8d:	0f b6 00             	movzbl (%eax),%eax
 a90:	0f be c0             	movsbl %al,%eax
 a93:	25 ff 00 00 00       	and    $0xff,%eax
 a98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a9f:	75 2c                	jne    acd <printf+0x6a>
      if(c == '%'){
 aa1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 aa5:	75 0c                	jne    ab3 <printf+0x50>
        state = '%';
 aa7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 aae:	e9 4b 01 00 00       	jmp    bfe <printf+0x19b>
      } else {
        putc(fd, c);
 ab3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 ab6:	0f be c0             	movsbl %al,%eax
 ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
 abd:	8b 45 08             	mov    0x8(%ebp),%eax
 ac0:	89 04 24             	mov    %eax,(%esp)
 ac3:	e8 c4 fe ff ff       	call   98c <putc>
 ac8:	e9 31 01 00 00       	jmp    bfe <printf+0x19b>
      }
    } else if(state == '%'){
 acd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 ad1:	0f 85 27 01 00 00    	jne    bfe <printf+0x19b>
      if(c == 'd'){
 ad7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 adb:	75 2d                	jne    b0a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 add:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ae0:	8b 00                	mov    (%eax),%eax
 ae2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 ae9:	00 
 aea:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 af1:	00 
 af2:	89 44 24 04          	mov    %eax,0x4(%esp)
 af6:	8b 45 08             	mov    0x8(%ebp),%eax
 af9:	89 04 24             	mov    %eax,(%esp)
 afc:	e8 b3 fe ff ff       	call   9b4 <printint>
        ap++;
 b01:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b05:	e9 ed 00 00 00       	jmp    bf7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 b0a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b0e:	74 06                	je     b16 <printf+0xb3>
 b10:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b14:	75 2d                	jne    b43 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 b16:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b19:	8b 00                	mov    (%eax),%eax
 b1b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b22:	00 
 b23:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 b2a:	00 
 b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
 b2f:	8b 45 08             	mov    0x8(%ebp),%eax
 b32:	89 04 24             	mov    %eax,(%esp)
 b35:	e8 7a fe ff ff       	call   9b4 <printint>
        ap++;
 b3a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b3e:	e9 b4 00 00 00       	jmp    bf7 <printf+0x194>
      } else if(c == 's'){
 b43:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b47:	75 46                	jne    b8f <printf+0x12c>
        s = (char*)*ap;
 b49:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b4c:	8b 00                	mov    (%eax),%eax
 b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 b51:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b59:	75 27                	jne    b82 <printf+0x11f>
          s = "(null)";
 b5b:	c7 45 f4 b0 0f 00 00 	movl   $0xfb0,-0xc(%ebp)
        while(*s != 0){
 b62:	eb 1e                	jmp    b82 <printf+0x11f>
          putc(fd, *s);
 b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b67:	0f b6 00             	movzbl (%eax),%eax
 b6a:	0f be c0             	movsbl %al,%eax
 b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
 b71:	8b 45 08             	mov    0x8(%ebp),%eax
 b74:	89 04 24             	mov    %eax,(%esp)
 b77:	e8 10 fe ff ff       	call   98c <putc>
          s++;
 b7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 b80:	eb 01                	jmp    b83 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 b82:	90                   	nop
 b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b86:	0f b6 00             	movzbl (%eax),%eax
 b89:	84 c0                	test   %al,%al
 b8b:	75 d7                	jne    b64 <printf+0x101>
 b8d:	eb 68                	jmp    bf7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b8f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b93:	75 1d                	jne    bb2 <printf+0x14f>
        putc(fd, *ap);
 b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b98:	8b 00                	mov    (%eax),%eax
 b9a:	0f be c0             	movsbl %al,%eax
 b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
 ba1:	8b 45 08             	mov    0x8(%ebp),%eax
 ba4:	89 04 24             	mov    %eax,(%esp)
 ba7:	e8 e0 fd ff ff       	call   98c <putc>
        ap++;
 bac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bb0:	eb 45                	jmp    bf7 <printf+0x194>
      } else if(c == '%'){
 bb2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 bb6:	75 17                	jne    bcf <printf+0x16c>
        putc(fd, c);
 bb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bbb:	0f be c0             	movsbl %al,%eax
 bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
 bc2:	8b 45 08             	mov    0x8(%ebp),%eax
 bc5:	89 04 24             	mov    %eax,(%esp)
 bc8:	e8 bf fd ff ff       	call   98c <putc>
 bcd:	eb 28                	jmp    bf7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bcf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 bd6:	00 
 bd7:	8b 45 08             	mov    0x8(%ebp),%eax
 bda:	89 04 24             	mov    %eax,(%esp)
 bdd:	e8 aa fd ff ff       	call   98c <putc>
        putc(fd, c);
 be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 be5:	0f be c0             	movsbl %al,%eax
 be8:	89 44 24 04          	mov    %eax,0x4(%esp)
 bec:	8b 45 08             	mov    0x8(%ebp),%eax
 bef:	89 04 24             	mov    %eax,(%esp)
 bf2:	e8 95 fd ff ff       	call   98c <putc>
      }
      state = 0;
 bf7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 bfe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 c02:	8b 55 0c             	mov    0xc(%ebp),%edx
 c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c08:	01 d0                	add    %edx,%eax
 c0a:	0f b6 00             	movzbl (%eax),%eax
 c0d:	84 c0                	test   %al,%al
 c0f:	0f 85 70 fe ff ff    	jne    a85 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 c15:	c9                   	leave  
 c16:	c3                   	ret    
 c17:	90                   	nop

00000c18 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c18:	55                   	push   %ebp
 c19:	89 e5                	mov    %esp,%ebp
 c1b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c1e:	8b 45 08             	mov    0x8(%ebp),%eax
 c21:	83 e8 08             	sub    $0x8,%eax
 c24:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c27:	a1 34 12 00 00       	mov    0x1234,%eax
 c2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c2f:	eb 24                	jmp    c55 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c34:	8b 00                	mov    (%eax),%eax
 c36:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c39:	77 12                	ja     c4d <free+0x35>
 c3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c3e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c41:	77 24                	ja     c67 <free+0x4f>
 c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c46:	8b 00                	mov    (%eax),%eax
 c48:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c4b:	77 1a                	ja     c67 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c50:	8b 00                	mov    (%eax),%eax
 c52:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c55:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c58:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c5b:	76 d4                	jbe    c31 <free+0x19>
 c5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c60:	8b 00                	mov    (%eax),%eax
 c62:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c65:	76 ca                	jbe    c31 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 c67:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c6a:	8b 40 04             	mov    0x4(%eax),%eax
 c6d:	c1 e0 03             	shl    $0x3,%eax
 c70:	89 c2                	mov    %eax,%edx
 c72:	03 55 f8             	add    -0x8(%ebp),%edx
 c75:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c78:	8b 00                	mov    (%eax),%eax
 c7a:	39 c2                	cmp    %eax,%edx
 c7c:	75 24                	jne    ca2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 c7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c81:	8b 50 04             	mov    0x4(%eax),%edx
 c84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c87:	8b 00                	mov    (%eax),%eax
 c89:	8b 40 04             	mov    0x4(%eax),%eax
 c8c:	01 c2                	add    %eax,%edx
 c8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c91:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c97:	8b 00                	mov    (%eax),%eax
 c99:	8b 10                	mov    (%eax),%edx
 c9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c9e:	89 10                	mov    %edx,(%eax)
 ca0:	eb 0a                	jmp    cac <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 ca2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ca5:	8b 10                	mov    (%eax),%edx
 ca7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 caa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 cac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 caf:	8b 40 04             	mov    0x4(%eax),%eax
 cb2:	c1 e0 03             	shl    $0x3,%eax
 cb5:	03 45 fc             	add    -0x4(%ebp),%eax
 cb8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cbb:	75 20                	jne    cdd <free+0xc5>
    p->s.size += bp->s.size;
 cbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cc0:	8b 50 04             	mov    0x4(%eax),%edx
 cc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cc6:	8b 40 04             	mov    0x4(%eax),%eax
 cc9:	01 c2                	add    %eax,%edx
 ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cce:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 cd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cd4:	8b 10                	mov    (%eax),%edx
 cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd9:	89 10                	mov    %edx,(%eax)
 cdb:	eb 08                	jmp    ce5 <free+0xcd>
  } else
    p->s.ptr = bp;
 cdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ce3:	89 10                	mov    %edx,(%eax)
  freep = p;
 ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce8:	a3 34 12 00 00       	mov    %eax,0x1234
}
 ced:	c9                   	leave  
 cee:	c3                   	ret    

00000cef <morecore>:

static Header*
morecore(uint nu)
{
 cef:	55                   	push   %ebp
 cf0:	89 e5                	mov    %esp,%ebp
 cf2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 cf5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 cfc:	77 07                	ja     d05 <morecore+0x16>
    nu = 4096;
 cfe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d05:	8b 45 08             	mov    0x8(%ebp),%eax
 d08:	c1 e0 03             	shl    $0x3,%eax
 d0b:	89 04 24             	mov    %eax,(%esp)
 d0e:	e8 61 fc ff ff       	call   974 <sbrk>
 d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d16:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d1a:	75 07                	jne    d23 <morecore+0x34>
    return 0;
 d1c:	b8 00 00 00 00       	mov    $0x0,%eax
 d21:	eb 22                	jmp    d45 <morecore+0x56>
  hp = (Header*)p;
 d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2c:	8b 55 08             	mov    0x8(%ebp),%edx
 d2f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d35:	83 c0 08             	add    $0x8,%eax
 d38:	89 04 24             	mov    %eax,(%esp)
 d3b:	e8 d8 fe ff ff       	call   c18 <free>
  return freep;
 d40:	a1 34 12 00 00       	mov    0x1234,%eax
}
 d45:	c9                   	leave  
 d46:	c3                   	ret    

00000d47 <malloc>:

void*
malloc(uint nbytes)
{
 d47:	55                   	push   %ebp
 d48:	89 e5                	mov    %esp,%ebp
 d4a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d4d:	8b 45 08             	mov    0x8(%ebp),%eax
 d50:	83 c0 07             	add    $0x7,%eax
 d53:	c1 e8 03             	shr    $0x3,%eax
 d56:	83 c0 01             	add    $0x1,%eax
 d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d5c:	a1 34 12 00 00       	mov    0x1234,%eax
 d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d68:	75 23                	jne    d8d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 d6a:	c7 45 f0 2c 12 00 00 	movl   $0x122c,-0x10(%ebp)
 d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d74:	a3 34 12 00 00       	mov    %eax,0x1234
 d79:	a1 34 12 00 00       	mov    0x1234,%eax
 d7e:	a3 2c 12 00 00       	mov    %eax,0x122c
    base.s.size = 0;
 d83:	c7 05 30 12 00 00 00 	movl   $0x0,0x1230
 d8a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d90:	8b 00                	mov    (%eax),%eax
 d92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d98:	8b 40 04             	mov    0x4(%eax),%eax
 d9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d9e:	72 4d                	jb     ded <malloc+0xa6>
      if(p->s.size == nunits)
 da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 da3:	8b 40 04             	mov    0x4(%eax),%eax
 da6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 da9:	75 0c                	jne    db7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dae:	8b 10                	mov    (%eax),%edx
 db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 db3:	89 10                	mov    %edx,(%eax)
 db5:	eb 26                	jmp    ddd <malloc+0x96>
      else {
        p->s.size -= nunits;
 db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dba:	8b 40 04             	mov    0x4(%eax),%eax
 dbd:	89 c2                	mov    %eax,%edx
 dbf:	2b 55 ec             	sub    -0x14(%ebp),%edx
 dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dc5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dcb:	8b 40 04             	mov    0x4(%eax),%eax
 dce:	c1 e0 03             	shl    $0x3,%eax
 dd1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 dda:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 de0:	a3 34 12 00 00       	mov    %eax,0x1234
      return (void*)(p + 1);
 de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 de8:	83 c0 08             	add    $0x8,%eax
 deb:	eb 38                	jmp    e25 <malloc+0xde>
    }
    if(p == freep)
 ded:	a1 34 12 00 00       	mov    0x1234,%eax
 df2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 df5:	75 1b                	jne    e12 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 dfa:	89 04 24             	mov    %eax,(%esp)
 dfd:	e8 ed fe ff ff       	call   cef <morecore>
 e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e09:	75 07                	jne    e12 <malloc+0xcb>
        return 0;
 e0b:	b8 00 00 00 00       	mov    $0x0,%eax
 e10:	eb 13                	jmp    e25 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e15:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e1b:	8b 00                	mov    (%eax),%eax
 e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 e20:	e9 70 ff ff ff       	jmp    d95 <malloc+0x4e>
}
 e25:	c9                   	leave  
 e26:	c3                   	ret    
