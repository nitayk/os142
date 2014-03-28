
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 10 e6 10 80       	mov    $0x8010e610,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 1b 3b 10 80       	mov    $0x80103b1b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 f8 8c 10 	movl   $0x80108cf8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
80100049:	e8 00 55 00 00       	call   8010554e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 50 fb 10 80 44 	movl   $0x8010fb44,0x8010fb50
80100055:	fb 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 54 fb 10 80 44 	movl   $0x8010fb44,0x8010fb54
8010005f:	fb 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 54 e6 10 80 	movl   $0x8010e654,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 54 fb 10 80    	mov    0x8010fb54,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 44 fb 10 80 	movl   $0x8010fb44,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 54 fb 10 80       	mov    0x8010fb54,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 54 fb 10 80       	mov    %eax,0x8010fb54

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 44 fb 10 80 	cmpl   $0x8010fb44,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
801000bd:	e8 ad 54 00 00       	call   8010556f <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 54 fb 10 80       	mov    0x8010fb54,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
80100104:	e8 c8 54 00 00       	call   801055d1 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 20 e6 10 	movl   $0x8010e620,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 d3 50 00 00       	call   801051f7 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 44 fb 10 80 	cmpl   $0x8010fb44,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 50 fb 10 80       	mov    0x8010fb50,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
8010017c:	e8 50 54 00 00       	call   801055d1 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 44 fb 10 80 	cmpl   $0x8010fb44,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 ff 8c 10 80 	movl   $0x80108cff,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 f0 2c 00 00       	call   80102ec8 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 10 8d 10 80 	movl   $0x80108d10,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 b3 2c 00 00       	call   80102ec8 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
8010023c:	e8 2e 53 00 00       	call   8010556f <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 54 fb 10 80    	mov    0x8010fb54,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 44 fb 10 80 	movl   $0x8010fb44,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 54 fb 10 80       	mov    0x8010fb54,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 54 fb 10 80       	mov    %eax,0x8010fb54

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 c3 50 00 00       	call   80105365 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 20 e6 10 80 	movl   $0x8010e620,(%esp)
801002a9:	e8 23 53 00 00       	call   801055d1 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 ee 03 00 00       	call   80100783 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 74 d0 10 80       	mov    0x8010d074,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
801003bc:	e8 ae 51 00 00       	call   8010556f <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 1e 8d 10 80 	movl   $0x80108d1e,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 8c 03 00 00       	call   80100783 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 27 8d 10 80 	movl   $0x80108d27,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 ba 02 00 00       	call   80100783 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 9b 02 00 00       	call   80100783 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 8d 02 00 00       	call   80100783 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 82 02 00 00       	call   80100783 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
80100536:	e8 96 50 00 00       	call   801055d1 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 74 d0 10 80 00 	movl   $0x0,0x8010d074
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 2e 8d 10 80 	movl   $0x80108d2e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 3d 8d 10 80 	movl   $0x80108d3d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 89 50 00 00       	call   80105620 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 3f 8d 10 80 	movl   $0x80108d3f,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 30 d0 10 80 01 	movl   $0x1,0x8010d030
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:

static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 5c                	jmp    801006b4 <cgaputc+0xe7>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 4d                	jle    801006b4 <cgaputc+0xe7>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 47                	jmp    801006b4 <cgaputc+0xe7>
  }
  else if(c == KEY_LF) { 	// left & right arrows on Qemu console
8010066d:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100674:	75 0c                	jne    80100682 <cgaputc+0xb5>
       if(pos > 0) --pos;
80100676:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010067a:	7e 38                	jle    801006b4 <cgaputc+0xe7>
8010067c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100680:	eb 32                	jmp    801006b4 <cgaputc+0xe7>
  } else if(c == KEY_RT) {
80100682:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100689:	75 0c                	jne    80100697 <cgaputc+0xca>
      if(pos > 0)  ++pos;
8010068b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068f:	7e 23                	jle    801006b4 <cgaputc+0xe7>
80100691:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100695:	eb 1d                	jmp    801006b4 <cgaputc+0xe7>
   } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100697:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010069c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010069f:	01 d2                	add    %edx,%edx
801006a1:	01 c2                	add    %eax,%edx
801006a3:	8b 45 08             	mov    0x8(%ebp),%eax
801006a6:	66 25 ff 00          	and    $0xff,%ax
801006aa:	80 cc 07             	or     $0x7,%ah
801006ad:	66 89 02             	mov    %ax,(%edx)
801006b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
801006b4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bb:	7e 53                	jle    80100710 <cgaputc+0x143>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006bd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006c2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006c8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cd:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006d4:	00 
801006d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801006d9:	89 04 24             	mov    %eax,(%esp)
801006dc:	e8 b0 51 00 00       	call   80105891 <memmove>
    pos -= 80;
801006e1:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e5:	b8 80 07 00 00       	mov    $0x780,%eax
801006ea:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ed:	01 c0                	add    %eax,%eax
801006ef:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006f5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006f8:	01 c9                	add    %ecx,%ecx
801006fa:	01 ca                	add    %ecx,%edx
801006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100700:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100707:	00 
80100708:	89 14 24             	mov    %edx,(%esp)
8010070b:	e8 ae 50 00 00       	call   801057be <memset>
  }
  
  outb(CRTPORT, 14);
80100710:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100717:	00 
80100718:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010071f:	e8 b6 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100727:	c1 f8 08             	sar    $0x8,%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
8010073d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100744:	00 
80100745:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010074c:	e8 89 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100754:	0f b6 c0             	movzbl %al,%eax
80100757:	89 44 24 04          	mov    %eax,0x4(%esp)
8010075b:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100762:	e8 73 fb ff ff       	call   801002da <outb>
  if(c == BACKSPACE)
80100767:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076e:	75 11                	jne    80100781 <cgaputc+0x1b4>
      crt[pos] = ' ' | 0x0700;
80100770:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100775:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100778:	01 d2                	add    %edx,%edx
8010077a:	01 d0                	add    %edx,%eax
8010077c:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100781:	c9                   	leave  
80100782:	c3                   	ret    

80100783 <consputc>:

void
consputc(int c)
{
80100783:	55                   	push   %ebp
80100784:	89 e5                	mov    %esp,%ebp
80100786:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100789:	a1 30 d0 10 80       	mov    0x8010d030,%eax
8010078e:	85 c0                	test   %eax,%eax
80100790:	74 07                	je     80100799 <consputc+0x16>
    cli();
80100792:	e8 61 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100797:	eb fe                	jmp    80100797 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100799:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a0:	75 26                	jne    801007c8 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 af 6b 00 00       	call   8010735d <uartputc>
801007ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007b5:	e8 a3 6b 00 00       	call   8010735d <uartputc>
801007ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007c1:	e8 97 6b 00 00       	call   8010735d <uartputc>
801007c6:	eb 0b                	jmp    801007d3 <consputc+0x50>
  } else
    uartputc(c);
801007c8:	8b 45 08             	mov    0x8(%ebp),%eax
801007cb:	89 04 24             	mov    %eax,(%esp)
801007ce:	e8 8a 6b 00 00       	call   8010735d <uartputc>
  cgaputc(c);
801007d3:	8b 45 08             	mov    0x8(%ebp),%eax
801007d6:	89 04 24             	mov    %eax,(%esp)
801007d9:	e8 ef fd ff ff       	call   801005cd <cgaputc>
}
801007de:	c9                   	leave  
801007df:	c3                   	ret    

801007e0 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007e0:	55                   	push   %ebp
801007e1:	89 e5                	mov    %esp,%ebp
801007e3:	83 ec 28             	sub    $0x28,%esp
  int c,i;

  acquire(&input.lock);
801007e6:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
801007ed:	e8 7d 4d 00 00       	call   8010556f <acquire>
  while((c = getc()) >= 0){
801007f2:	e9 d2 05 00 00       	jmp    80100dc9 <consoleintr+0x5e9>
    switch(c){
801007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007fa:	83 f8 7f             	cmp    $0x7f,%eax
801007fd:	0f 84 ae 00 00 00    	je     801008b1 <consoleintr+0xd1>
80100803:	83 f8 7f             	cmp    $0x7f,%eax
80100806:	7f 18                	jg     80100820 <consoleintr+0x40>
80100808:	83 f8 10             	cmp    $0x10,%eax
8010080b:	74 50                	je     8010085d <consoleintr+0x7d>
8010080d:	83 f8 15             	cmp    $0x15,%eax
80100810:	74 70                	je     80100882 <consoleintr+0xa2>
80100812:	83 f8 08             	cmp    $0x8,%eax
80100815:	0f 84 96 00 00 00    	je     801008b1 <consoleintr+0xd1>
8010081b:	e9 db 03 00 00       	jmp    80100bfb <consoleintr+0x41b>
80100820:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100825:	0f 84 ef 02 00 00    	je     80100b1a <consoleintr+0x33a>
8010082b:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100830:	7f 10                	jg     80100842 <consoleintr+0x62>
80100832:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100837:	0f 84 e6 01 00 00    	je     80100a23 <consoleintr+0x243>
8010083d:	e9 b9 03 00 00       	jmp    80100bfb <consoleintr+0x41b>
80100842:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100847:	0f 84 5a 01 00 00    	je     801009a7 <consoleintr+0x1c7>
8010084d:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100852:	0f 84 86 01 00 00    	je     801009de <consoleintr+0x1fe>
80100858:	e9 9e 03 00 00       	jmp    80100bfb <consoleintr+0x41b>
    case C('P'):  // Process listing.
      procdump();
8010085d:	e8 a9 4b 00 00       	call   8010540b <procdump>
      break;
80100862:	e9 62 05 00 00       	jmp    80100dc9 <consoleintr+0x5e9>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100867:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
8010086c:	83 e8 01             	sub    $0x1,%eax
8010086f:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
        consputc(BACKSPACE);
80100874:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010087b:	e8 03 ff ff ff       	call   80100783 <consputc>
80100880:	eb 01                	jmp    80100883 <consoleintr+0xa3>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100882:	90                   	nop
80100883:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100889:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 26 05 00 00    	je     80100dbc <consoleintr+0x5dc>
80100896:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 94 fd 10 80 	movzbl -0x7fef026c(%eax),%eax
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 bb                	jne    80100867 <consoleintr+0x87>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008ac:	e9 0b 05 00 00       	jmp    80100dbc <consoleintr+0x5dc>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
801008b7:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 fb 04 00 00    	je     80100dbf <consoleintr+0x5df>
        input.e--;
801008c4:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
    	input.e -= arrows_counter;
801008d1:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
801008d7:	a1 78 d0 10 80       	mov    0x8010d078,%eax
801008dc:	89 d1                	mov    %edx,%ecx
801008de:	29 c1                	sub    %eax,%ecx
801008e0:	89 c8                	mov    %ecx,%eax
801008e2:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
    	for(i = 0; i < arrows_counter; ++i)
801008e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801008ee:	eb 2c                	jmp    8010091c <consoleintr+0x13c>
    	{
    	  input.buf[input.e] = input.buf[input.e+1];
801008f0:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
801008f5:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
801008fb:	83 c2 01             	add    $0x1,%edx
801008fe:	0f b6 92 94 fd 10 80 	movzbl -0x7fef026c(%edx),%edx
80100905:	88 90 94 fd 10 80    	mov    %dl,-0x7fef026c(%eax)
    	  ++input.e;
8010090b:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100910:	83 c0 01             	add    $0x1,%eax
80100913:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
    	input.e -= arrows_counter;
    	for(i = 0; i < arrows_counter; ++i)
80100918:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010091c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010091f:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100924:	39 c2                	cmp    %eax,%edx
80100926:	72 c8                	jb     801008f0 <consoleintr+0x110>
    	{
    	  input.buf[input.e] = input.buf[input.e+1];
    	  ++input.e;
    	}
    	input.buf[input.e] = '\0';  //null terminated
80100928:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
8010092d:	c6 80 94 fd 10 80 00 	movb   $0x0,-0x7fef026c(%eax)
        consputc(BACKSPACE);
80100934:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010093b:	e8 43 fe ff ff       	call   80100783 <consputc>

        for(i = 0; i <= arrows_counter; ++i)
80100940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100947:	eb 28                	jmp    80100971 <consoleintr+0x191>
        	consputc(input.buf[input.e - arrows_counter +i ]);
80100949:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
8010094f:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100954:	29 c2                	sub    %eax,%edx
80100956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100959:	01 d0                	add    %edx,%eax
8010095b:	0f b6 80 94 fd 10 80 	movzbl -0x7fef026c(%eax),%eax
80100962:	0f be c0             	movsbl %al,%eax
80100965:	89 04 24             	mov    %eax,(%esp)
80100968:	e8 16 fe ff ff       	call   80100783 <consputc>
    	  ++input.e;
    	}
    	input.buf[input.e] = '\0';  //null terminated
        consputc(BACKSPACE);

        for(i = 0; i <= arrows_counter; ++i)
8010096d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100971:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100974:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100979:	39 c2                	cmp    %eax,%edx
8010097b:	76 cc                	jbe    80100949 <consoleintr+0x169>
        	consputc(input.buf[input.e - arrows_counter +i ]);

        for(i = 0; i <= arrows_counter; ++i)
8010097d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100984:	eb 10                	jmp    80100996 <consoleintr+0x1b6>
        	cgaputc(KEY_LF);
80100986:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
8010098d:	e8 3b fc ff ff       	call   801005cd <cgaputc>
        consputc(BACKSPACE);

        for(i = 0; i <= arrows_counter; ++i)
        	consputc(input.buf[input.e - arrows_counter +i ]);

        for(i = 0; i <= arrows_counter; ++i)
80100992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100996:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100999:	a1 78 d0 10 80       	mov    0x8010d078,%eax
8010099e:	39 c2                	cmp    %eax,%edx
801009a0:	76 e4                	jbe    80100986 <consoleintr+0x1a6>
        	cgaputc(KEY_LF);
      }
      break;
801009a2:	e9 18 04 00 00       	jmp    80100dbf <consoleintr+0x5df>

    case KEY_LF:
      if(arrows_counter < input.e - input.r) {
801009a7:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
801009ad:	a1 14 fe 10 80       	mov    0x8010fe14,%eax
801009b2:	29 c2                	sub    %eax,%edx
801009b4:	a1 78 d0 10 80       	mov    0x8010d078,%eax
801009b9:	39 c2                	cmp    %eax,%edx
801009bb:	0f 86 01 04 00 00    	jbe    80100dc2 <consoleintr+0x5e2>
    	  arrows_counter++;
801009c1:	a1 78 d0 10 80       	mov    0x8010d078,%eax
801009c6:	83 c0 01             	add    $0x1,%eax
801009c9:	a3 78 d0 10 80       	mov    %eax,0x8010d078
    	  consputc(c);
801009ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009d1:	89 04 24             	mov    %eax,(%esp)
801009d4:	e8 aa fd ff ff       	call   80100783 <consputc>
      }
      break;
801009d9:	e9 e4 03 00 00       	jmp    80100dc2 <consoleintr+0x5e2>

    case KEY_RT:
    	if(arrows_counter > 0) {
801009de:	a1 78 d0 10 80       	mov    0x8010d078,%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	0f 84 da 03 00 00    	je     80100dc5 <consoleintr+0x5e5>
    		arrows_counter--;
801009eb:	a1 78 d0 10 80       	mov    0x8010d078,%eax
801009f0:	83 e8 01             	sub    $0x1,%eax
801009f3:	a3 78 d0 10 80       	mov    %eax,0x8010d078
    		consputc(c);
801009f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009fb:	89 04 24             	mov    %eax,(%esp)
801009fe:	e8 80 fd ff ff       	call   80100783 <consputc>
    	}
    	break;
80100a03:	e9 bd 03 00 00       	jmp    80100dc5 <consoleintr+0x5e5>

    case KEY_UP: // up arrow
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
    		input.e--;
80100a08:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100a0d:	83 e8 01             	sub    $0x1,%eax
80100a10:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
    	    consputc(BACKSPACE);
80100a15:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a1c:	e8 62 fd ff ff       	call   80100783 <consputc>
80100a21:	eb 01                	jmp    80100a24 <consoleintr+0x244>
    		consputc(c);
    	}
    	break;

    case KEY_UP: // up arrow
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
80100a23:	90                   	nop
80100a24:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100a2a:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 16                	je     80100a49 <consoleintr+0x269>
80100a33:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	83 e0 7f             	and    $0x7f,%eax
80100a3e:	0f b6 80 94 fd 10 80 	movzbl -0x7fef026c(%eax),%eax
80100a45:	3c 0a                	cmp    $0xa,%al
80100a47:	75 bf                	jne    80100a08 <consoleintr+0x228>
    		input.e--;
    	    consputc(BACKSPACE);
    	}

        for(i=0; i < strlen(history.commands[history.iter]); i++)
80100a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a50:	eb 41                	jmp    80100a93 <consoleintr+0x2b3>
        {
          input.buf[i] = history.commands[history.iter][i];
80100a52:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100a57:	c1 e0 07             	shl    $0x7,%eax
80100a5a:	03 45 f4             	add    -0xc(%ebp),%eax
80100a5d:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100a62:	0f b6 00             	movzbl (%eax),%eax
80100a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a68:	81 c2 90 fd 10 80    	add    $0x8010fd90,%edx
80100a6e:	88 42 04             	mov    %al,0x4(%edx)
          consputc(history.commands[history.iter][i]);
80100a71:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100a76:	c1 e0 07             	shl    $0x7,%eax
80100a79:	03 45 f4             	add    -0xc(%ebp),%eax
80100a7c:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100a81:	0f b6 00             	movzbl (%eax),%eax
80100a84:	0f be c0             	movsbl %al,%eax
80100a87:	89 04 24             	mov    %eax,(%esp)
80100a8a:	e8 f4 fc ff ff       	call   80100783 <consputc>
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
    		input.e--;
    	    consputc(BACKSPACE);
    	}

        for(i=0; i < strlen(history.commands[history.iter]); i++)
80100a8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a93:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100a98:	c1 e0 07             	shl    $0x7,%eax
80100a9b:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100aa0:	89 04 24             	mov    %eax,(%esp)
80100aa3:	e8 94 4f 00 00       	call   80105a3c <strlen>
80100aa8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100aab:	7f a5                	jg     80100a52 <consoleintr+0x272>
        {
          input.buf[i] = history.commands[history.iter][i];
          consputc(history.commands[history.iter][i]);
        }

        if (history.iter-1 == -1)
80100aad:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100ab2:	85 c0                	test   %eax,%eax
80100ab4:	75 0f                	jne    80100ac5 <consoleintr+0x2e5>
        	history.iter = history.num_of_curr_entries-1;
80100ab6:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100abb:	83 e8 01             	sub    $0x1,%eax
80100abe:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8
80100ac3:	eb 0d                	jmp    80100ad2 <consoleintr+0x2f2>
        else
        	history.iter--;
80100ac5:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100aca:	83 e8 01             	sub    $0x1,%eax
80100acd:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8

        input.buf[i] = '\0';
80100ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad5:	05 90 fd 10 80       	add    $0x8010fd90,%eax
80100ada:	c6 40 04 00          	movb   $0x0,0x4(%eax)
        input.e = i;
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
        input.r = input.w = 0;
80100ae6:	c7 05 18 fe 10 80 00 	movl   $0x0,0x8010fe18
80100aed:	00 00 00 
80100af0:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
80100af5:	a3 14 fe 10 80       	mov    %eax,0x8010fe14

    	break;
80100afa:	e9 ca 02 00 00       	jmp    80100dc9 <consoleintr+0x5e9>

    case KEY_DN: // down arrow
        	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
        		input.e--;
80100aff:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100b04:	83 e8 01             	sub    $0x1,%eax
80100b07:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
        	    consputc(BACKSPACE);
80100b0c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100b13:	e8 6b fc ff ff       	call   80100783 <consputc>
80100b18:	eb 01                	jmp    80100b1b <consoleintr+0x33b>
        input.r = input.w = 0;

    	break;

    case KEY_DN: // down arrow
        	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
80100b1a:	90                   	nop
80100b1b:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100b21:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
80100b26:	39 c2                	cmp    %eax,%edx
80100b28:	74 16                	je     80100b40 <consoleintr+0x360>
80100b2a:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100b2f:	83 e8 01             	sub    $0x1,%eax
80100b32:	83 e0 7f             	and    $0x7f,%eax
80100b35:	0f b6 80 94 fd 10 80 	movzbl -0x7fef026c(%eax),%eax
80100b3c:	3c 0a                	cmp    $0xa,%al
80100b3e:	75 bf                	jne    80100aff <consoleintr+0x31f>
        		input.e--;
        	    consputc(BACKSPACE);
        	}

        	if (history.iter+1 == history.num_of_curr_entries)
80100b40:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100b45:	8d 50 01             	lea    0x1(%eax),%edx
80100b48:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100b4d:	39 c2                	cmp    %eax,%edx
80100b4f:	75 0c                	jne    80100b5d <consoleintr+0x37d>
        		history.iter = 0;
80100b51:	c7 05 a8 c5 10 80 00 	movl   $0x0,0x8010c5a8
80100b58:	00 00 00 
80100b5b:	eb 0d                	jmp    80100b6a <consoleintr+0x38a>
        	else
        		history.iter++;
80100b5d:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100b62:	83 c0 01             	add    $0x1,%eax
80100b65:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8

            for(i=0; i < strlen(history.commands[history.iter]); i++)
80100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b71:	eb 41                	jmp    80100bb4 <consoleintr+0x3d4>
            {
              input.buf[i] = history.commands[history.iter][i];
80100b73:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100b78:	c1 e0 07             	shl    $0x7,%eax
80100b7b:	03 45 f4             	add    -0xc(%ebp),%eax
80100b7e:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100b83:	0f b6 00             	movzbl (%eax),%eax
80100b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b89:	81 c2 90 fd 10 80    	add    $0x8010fd90,%edx
80100b8f:	88 42 04             	mov    %al,0x4(%edx)
              consputc(history.commands[history.iter][i]);
80100b92:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100b97:	c1 e0 07             	shl    $0x7,%eax
80100b9a:	03 45 f4             	add    -0xc(%ebp),%eax
80100b9d:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100ba2:	0f b6 00             	movzbl (%eax),%eax
80100ba5:	0f be c0             	movsbl %al,%eax
80100ba8:	89 04 24             	mov    %eax,(%esp)
80100bab:	e8 d3 fb ff ff       	call   80100783 <consputc>
        	if (history.iter+1 == history.num_of_curr_entries)
        		history.iter = 0;
        	else
        		history.iter++;

            for(i=0; i < strlen(history.commands[history.iter]); i++)
80100bb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb4:	a1 a8 c5 10 80       	mov    0x8010c5a8,%eax
80100bb9:	c1 e0 07             	shl    $0x7,%eax
80100bbc:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100bc1:	89 04 24             	mov    %eax,(%esp)
80100bc4:	e8 73 4e 00 00       	call   80105a3c <strlen>
80100bc9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100bcc:	7f a5                	jg     80100b73 <consoleintr+0x393>
              input.buf[i] = history.commands[history.iter][i];
              consputc(history.commands[history.iter][i]);
            }


            input.buf[i] = '\0';
80100bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bd1:	05 90 fd 10 80       	add    $0x8010fd90,%eax
80100bd6:	c6 40 04 00          	movb   $0x0,0x4(%eax)
            input.e = i;
80100bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bdd:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
            input.r = input.w = 0;
80100be2:	c7 05 18 fe 10 80 00 	movl   $0x0,0x8010fe18
80100be9:	00 00 00 
80100bec:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
80100bf1:	a3 14 fe 10 80       	mov    %eax,0x8010fe14

        	break;
80100bf6:	e9 ce 01 00 00       	jmp    80100dc9 <consoleintr+0x5e9>

    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100bff:	0f 84 c3 01 00 00    	je     80100dc8 <consoleintr+0x5e8>
80100c05:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100c0b:	a1 14 fe 10 80       	mov    0x8010fe14,%eax
80100c10:	89 d1                	mov    %edx,%ecx
80100c12:	29 c1                	sub    %eax,%ecx
80100c14:	89 c8                	mov    %ecx,%eax
80100c16:	83 f8 7f             	cmp    $0x7f,%eax
80100c19:	0f 87 a9 01 00 00    	ja     80100dc8 <consoleintr+0x5e8>
    	  if(arrows_counter > 0 && c != '\n' && c != C('D') && input.e != input.r+INPUT_BUF) {
80100c1f:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100c24:	85 c0                	test   %eax,%eax
80100c26:	0f 84 0a 01 00 00    	je     80100d36 <consoleintr+0x556>
80100c2c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100c30:	0f 84 00 01 00 00    	je     80100d36 <consoleintr+0x556>
80100c36:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100c3a:	0f 84 f6 00 00 00    	je     80100d36 <consoleintr+0x556>
80100c40:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100c45:	8b 15 14 fe 10 80    	mov    0x8010fe14,%edx
80100c4b:	83 ea 80             	sub    $0xffffff80,%edx
80100c4e:	39 d0                	cmp    %edx,%eax
80100c50:	0f 84 e0 00 00 00    	je     80100d36 <consoleintr+0x556>
    		  e_pos = input.e;
80100c56:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100c5b:	a3 7c d0 10 80       	mov    %eax,0x8010d07c
    	  	  //shift characters left
    	  	  for(i = 0; i < arrows_counter; ++i) {
80100c60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100c67:	eb 2c                	jmp    80100c95 <consoleintr+0x4b5>
    	  	    input.buf[input.e] = input.buf[input.e-1];
80100c69:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100c6e:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100c74:	83 ea 01             	sub    $0x1,%edx
80100c77:	0f b6 92 94 fd 10 80 	movzbl -0x7fef026c(%edx),%edx
80100c7e:	88 90 94 fd 10 80    	mov    %dl,-0x7fef026c(%eax)
    	  	    --input.e;
80100c84:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100c89:	83 e8 01             	sub    $0x1,%eax
80100c8c:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
    	  if(arrows_counter > 0 && c != '\n' && c != C('D') && input.e != input.r+INPUT_BUF) {
    		  e_pos = input.e;
    	  	  //shift characters left
    	  	  for(i = 0; i < arrows_counter; ++i) {
80100c91:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100c98:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100c9d:	39 c2                	cmp    %eax,%edx
80100c9f:	72 c8                	jb     80100c69 <consoleintr+0x489>
    	  	    input.buf[input.e] = input.buf[input.e-1];
    	  	    --input.e;
    	  	  }

    	  	  input.buf[input.e % INPUT_BUF] = c;
80100ca1:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100ca6:	89 c2                	mov    %eax,%edx
80100ca8:	83 e2 7f             	and    $0x7f,%edx
80100cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cae:	88 82 94 fd 10 80    	mov    %al,-0x7fef026c(%edx)
    	  	  consputc(c);
80100cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cb7:	89 04 24             	mov    %eax,(%esp)
80100cba:	e8 c4 fa ff ff       	call   80100783 <consputc>

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100cbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100cc6:	eb 24                	jmp    80100cec <consoleintr+0x50c>
    	  		  consputc(input.buf[input.e+i+1]);
80100cc8:	8b 15 1c fe 10 80    	mov    0x8010fe1c,%edx
80100cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100cd1:	01 d0                	add    %edx,%eax
80100cd3:	83 c0 01             	add    $0x1,%eax
80100cd6:	0f b6 80 94 fd 10 80 	movzbl -0x7fef026c(%eax),%eax
80100cdd:	0f be c0             	movsbl %al,%eax
80100ce0:	89 04 24             	mov    %eax,(%esp)
80100ce3:	e8 9b fa ff ff       	call   80100783 <consputc>
    	  	  }

    	  	  input.buf[input.e % INPUT_BUF] = c;
    	  	  consputc(c);

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100ce8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100cec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100cef:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100cf4:	39 c2                	cmp    %eax,%edx
80100cf6:	72 d0                	jb     80100cc8 <consoleintr+0x4e8>
    	  		  consputc(input.buf[input.e+i+1]);
    	  	  }

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100cf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100cff:	eb 10                	jmp    80100d11 <consoleintr+0x531>
    	  		  cgaputc(KEY_LF);
80100d01:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100d08:	e8 c0 f8 ff ff       	call   801005cd <cgaputc>

    	  	  for(i = 0; i < arrows_counter; ++i) {
    	  		  consputc(input.buf[input.e+i+1]);
    	  	  }

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100d0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d14:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100d19:	39 c2                	cmp    %eax,%edx
80100d1b:	72 e4                	jb     80100d01 <consoleintr+0x521>
    	  		  cgaputc(KEY_LF);
    	  	  }

    	  	  e_pos++;
80100d1d:	a1 7c d0 10 80       	mov    0x8010d07c,%eax
80100d22:	83 c0 01             	add    $0x1,%eax
80100d25:	a3 7c d0 10 80       	mov    %eax,0x8010d07c
    	  	  input.e = e_pos;
80100d2a:	a1 7c d0 10 80       	mov    0x8010d07c,%eax
80100d2f:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
80100d34:	eb 1b                	jmp    80100d51 <consoleintr+0x571>
    	  	}
    	  	else {
    	  	  input.buf[input.e++ % INPUT_BUF] = c;
80100d36:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100d3b:	89 c1                	mov    %eax,%ecx
80100d3d:	83 e1 7f             	and    $0x7f,%ecx
80100d40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100d43:	88 91 94 fd 10 80    	mov    %dl,-0x7fef026c(%ecx)
80100d49:	83 c0 01             	add    $0x1,%eax
80100d4c:	a3 1c fe 10 80       	mov    %eax,0x8010fe1c
    	  	}

    	  	if(arrows_counter == 0 && c != '\n' && c != C('D'))
80100d51:	a1 78 d0 10 80       	mov    0x8010d078,%eax
80100d56:	85 c0                	test   %eax,%eax
80100d58:	75 17                	jne    80100d71 <consoleintr+0x591>
80100d5a:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d5e:	74 11                	je     80100d71 <consoleintr+0x591>
80100d60:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d64:	74 0b                	je     80100d71 <consoleintr+0x591>
    	  	  consputc(c);
80100d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d69:	89 04 24             	mov    %eax,(%esp)
80100d6c:	e8 12 fa ff ff       	call   80100783 <consputc>

    	    if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF) {
80100d71:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d75:	74 18                	je     80100d8f <consoleintr+0x5af>
80100d77:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d7b:	74 12                	je     80100d8f <consoleintr+0x5af>
80100d7d:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100d82:	8b 15 14 fe 10 80    	mov    0x8010fe14,%edx
80100d88:	83 ea 80             	sub    $0xffffff80,%edx
80100d8b:	39 d0                	cmp    %edx,%eax
80100d8d:	75 39                	jne    80100dc8 <consoleintr+0x5e8>
    	    	input.w = input.e;
80100d8f:	a1 1c fe 10 80       	mov    0x8010fe1c,%eax
80100d94:	a3 18 fe 10 80       	mov    %eax,0x8010fe18
    	    	arrows_counter = 0;
80100d99:	c7 05 78 d0 10 80 00 	movl   $0x0,0x8010d078
80100da0:	00 00 00 
    	    	wakeup(&input.r);
80100da3:	c7 04 24 14 fe 10 80 	movl   $0x8010fe14,(%esp)
80100daa:	e8 b6 45 00 00       	call   80105365 <wakeup>
    	    	consputc(c);
80100daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100db2:	89 04 24             	mov    %eax,(%esp)
80100db5:	e8 c9 f9 ff ff       	call   80100783 <consputc>
    	    }
      }
      break;
80100dba:	eb 0c                	jmp    80100dc8 <consoleintr+0x5e8>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100dbc:	90                   	nop
80100dbd:	eb 0a                	jmp    80100dc9 <consoleintr+0x5e9>
        	consputc(input.buf[input.e - arrows_counter +i ]);

        for(i = 0; i <= arrows_counter; ++i)
        	cgaputc(KEY_LF);
      }
      break;
80100dbf:	90                   	nop
80100dc0:	eb 07                	jmp    80100dc9 <consoleintr+0x5e9>
    case KEY_LF:
      if(arrows_counter < input.e - input.r) {
    	  arrows_counter++;
    	  consputc(c);
      }
      break;
80100dc2:	90                   	nop
80100dc3:	eb 04                	jmp    80100dc9 <consoleintr+0x5e9>
    case KEY_RT:
    	if(arrows_counter > 0) {
    		arrows_counter--;
    		consputc(c);
    	}
    	break;
80100dc5:	90                   	nop
80100dc6:	eb 01                	jmp    80100dc9 <consoleintr+0x5e9>
    	    	arrows_counter = 0;
    	    	wakeup(&input.r);
    	    	consputc(c);
    	    }
      }
      break;
80100dc8:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c,i;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100dcc:	ff d0                	call   *%eax
80100dce:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100dd1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100dd5:	0f 89 1c fa ff ff    	jns    801007f7 <consoleintr+0x17>
    	    }
      }
      break;
    }
  }
  release(&input.lock);
80100ddb:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
80100de2:	e8 ea 47 00 00       	call   801055d1 <release>
}
80100de7:	c9                   	leave  
80100de8:	c3                   	ret    

80100de9 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100de9:	55                   	push   %ebp
80100dea:	89 e5                	mov    %esp,%ebp
80100dec:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c,i;

  iunlock(ip);
80100def:	8b 45 08             	mov    0x8(%ebp),%eax
80100df2:	89 04 24             	mov    %eax,(%esp)
80100df5:	e8 d0 12 00 00       	call   801020ca <iunlock>
  target = n;
80100dfa:	8b 45 10             	mov    0x10(%ebp),%eax
80100dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  acquire(&input.lock);
80100e00:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
80100e07:	e8 63 47 00 00       	call   8010556f <acquire>
  while(n > 0){
80100e0c:	e9 95 01 00 00       	jmp    80100fa6 <consoleread+0x1bd>
	  while(input.r == input.w){
		  if(proc->killed){
80100e11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e17:	8b 40 24             	mov    0x24(%eax),%eax
80100e1a:	85 c0                	test   %eax,%eax
80100e1c:	74 21                	je     80100e3f <consoleread+0x56>
			release(&input.lock);
80100e1e:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
80100e25:	e8 a7 47 00 00       	call   801055d1 <release>
			ilock(ip);
80100e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80100e2d:	89 04 24             	mov    %eax,(%esp)
80100e30:	e8 47 11 00 00       	call   80101f7c <ilock>
			return -1;
80100e35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e3a:	e9 97 01 00 00       	jmp    80100fd6 <consoleread+0x1ed>
		  }
		  sleep(&input.r, &input.lock);
80100e3f:	c7 44 24 04 60 fd 10 	movl   $0x8010fd60,0x4(%esp)
80100e46:	80 
80100e47:	c7 04 24 14 fe 10 80 	movl   $0x8010fe14,(%esp)
80100e4e:	e8 a4 43 00 00       	call   801051f7 <sleep>
80100e53:	eb 01                	jmp    80100e56 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
	  while(input.r == input.w){
80100e55:	90                   	nop
80100e56:	8b 15 14 fe 10 80    	mov    0x8010fe14,%edx
80100e5c:	a1 18 fe 10 80       	mov    0x8010fe18,%eax
80100e61:	39 c2                	cmp    %eax,%edx
80100e63:	74 ac                	je     80100e11 <consoleread+0x28>
			ilock(ip);
			return -1;
		  }
		  sleep(&input.r, &input.lock);
	  }
	  c = input.buf[input.r++ % INPUT_BUF];
80100e65:	a1 14 fe 10 80       	mov    0x8010fe14,%eax
80100e6a:	89 c2                	mov    %eax,%edx
80100e6c:	83 e2 7f             	and    $0x7f,%edx
80100e6f:	0f b6 92 94 fd 10 80 	movzbl -0x7fef026c(%edx),%edx
80100e76:	0f be d2             	movsbl %dl,%edx
80100e79:	89 55 ec             	mov    %edx,-0x14(%ebp)
80100e7c:	83 c0 01             	add    $0x1,%eax
80100e7f:	a3 14 fe 10 80       	mov    %eax,0x8010fe14
	  if(c == C('D')){  // EOF
80100e84:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100e88:	75 1e                	jne    80100ea8 <consoleread+0xbf>
		  if(n < target){
80100e8a:	8b 45 10             	mov    0x10(%ebp),%eax
80100e8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100e90:	0f 83 1c 01 00 00    	jae    80100fb2 <consoleread+0x1c9>
			  // Save ^D for next time, to make sure
			  // caller gets a 0-byte result.
			  input.r--;
80100e96:	a1 14 fe 10 80       	mov    0x8010fe14,%eax
80100e9b:	83 e8 01             	sub    $0x1,%eax
80100e9e:	a3 14 fe 10 80       	mov    %eax,0x8010fe14
		  }
		  break;
80100ea3:	e9 0a 01 00 00       	jmp    80100fb2 <consoleread+0x1c9>
	  }
	  history.buf[history.c_buf++] = c;
80100ea8:	a1 ac c5 10 80       	mov    0x8010c5ac,%eax
80100ead:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100eb0:	88 90 b0 c5 10 80    	mov    %dl,-0x7fef3a50(%eax)
80100eb6:	83 c0 01             	add    $0x1,%eax
80100eb9:	a3 ac c5 10 80       	mov    %eax,0x8010c5ac
	  *dst++ = c;
80100ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ec1:	89 c2                	mov    %eax,%edx
80100ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec6:	88 10                	mov    %dl,(%eax)
80100ec8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	  n--;
80100ecc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
	  if(c == '\n') {
80100ed0:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ed4:	0f 85 cc 00 00 00    	jne    80100fa6 <consoleread+0x1bd>
		  if (1 != history.c_buf) {
80100eda:	a1 ac c5 10 80       	mov    0x8010c5ac,%eax
80100edf:	83 f8 01             	cmp    $0x1,%eax
80100ee2:	0f 84 ab 00 00 00    	je     80100f93 <consoleread+0x1aa>
			  // save history_buf in history_commands
			  for(i = 0; i < history.c_buf-1; i++)
80100ee8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100eef:	eb 23                	jmp    80100f14 <consoleread+0x12b>
				  history.commands[history.entry_point][i] = history.buf[i];
80100ef1:	8b 15 a0 c5 10 80    	mov    0x8010c5a0,%edx
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	05 b0 c5 10 80       	add    $0x8010c5b0,%eax
80100eff:	0f b6 00             	movzbl (%eax),%eax
80100f02:	c1 e2 07             	shl    $0x7,%edx
80100f05:	03 55 f4             	add    -0xc(%ebp),%edx
80100f08:	81 c2 30 c6 10 80    	add    $0x8010c630,%edx
80100f0e:	88 02                	mov    %al,(%edx)
	  *dst++ = c;
	  n--;
	  if(c == '\n') {
		  if (1 != history.c_buf) {
			  // save history_buf in history_commands
			  for(i = 0; i < history.c_buf-1; i++)
80100f10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f14:	a1 ac c5 10 80       	mov    0x8010c5ac,%eax
80100f19:	83 e8 01             	sub    $0x1,%eax
80100f1c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100f1f:	7f d0                	jg     80100ef1 <consoleread+0x108>
				  history.commands[history.entry_point][i] = history.buf[i];

			  history.commands[history.entry_point][i] = '\0';
80100f21:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100f26:	c1 e0 07             	shl    $0x7,%eax
80100f29:	03 45 f4             	add    -0xc(%ebp),%eax
80100f2c:	05 30 c6 10 80       	add    $0x8010c630,%eax
80100f31:	c6 00 00             	movb   $0x0,(%eax)
			  history.iter = history.entry_point;
80100f34:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100f39:	a3 a8 c5 10 80       	mov    %eax,0x8010c5a8
			  history.entry_point++;
80100f3e:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100f43:	83 c0 01             	add    $0x1,%eax
80100f46:	a3 a0 c5 10 80       	mov    %eax,0x8010c5a0
			  history.entry_point %= MAX_HISTORY_LENGTH;  // FIFO 18 19 0 1 2..
80100f4b:	8b 0d a0 c5 10 80    	mov    0x8010c5a0,%ecx
80100f51:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100f56:	89 c8                	mov    %ecx,%eax
80100f58:	f7 ea                	imul   %edx
80100f5a:	c1 fa 03             	sar    $0x3,%edx
80100f5d:	89 c8                	mov    %ecx,%eax
80100f5f:	c1 f8 1f             	sar    $0x1f,%eax
80100f62:	29 c2                	sub    %eax,%edx
80100f64:	89 d0                	mov    %edx,%eax
80100f66:	c1 e0 02             	shl    $0x2,%eax
80100f69:	01 d0                	add    %edx,%eax
80100f6b:	c1 e0 02             	shl    $0x2,%eax
80100f6e:	89 ca                	mov    %ecx,%edx
80100f70:	29 c2                	sub    %eax,%edx
80100f72:	89 15 a0 c5 10 80    	mov    %edx,0x8010c5a0

			  // updates number of current entries (when maxed out - will not change)
			  history.num_of_curr_entries = (history.num_of_curr_entries < MAX_HISTORY_LENGTH-1) ? history.entry_point : MAX_HISTORY_LENGTH;
80100f78:	a1 a4 c5 10 80       	mov    0x8010c5a4,%eax
80100f7d:	83 f8 12             	cmp    $0x12,%eax
80100f80:	7f 07                	jg     80100f89 <consoleread+0x1a0>
80100f82:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100f87:	eb 05                	jmp    80100f8e <consoleread+0x1a5>
80100f89:	b8 14 00 00 00       	mov    $0x14,%eax
80100f8e:	a3 a4 c5 10 80       	mov    %eax,0x8010c5a4
		  }
		  history.c_buf = 0;
80100f93:	c7 05 ac c5 10 80 00 	movl   $0x0,0x8010c5ac
80100f9a:	00 00 00 
		  history.buf[0] = '\0';
80100f9d:	c6 05 b0 c5 10 80 00 	movb   $0x0,0x8010c5b0
		  break;
80100fa4:	eb 0d                	jmp    80100fb3 <consoleread+0x1ca>
  int c,i;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100faa:	0f 8f a5 fe ff ff    	jg     80100e55 <consoleread+0x6c>
80100fb0:	eb 01                	jmp    80100fb3 <consoleread+0x1ca>
		  if(n < target){
			  // Save ^D for next time, to make sure
			  // caller gets a 0-byte result.
			  input.r--;
		  }
		  break;
80100fb2:	90                   	nop
		  history.c_buf = 0;
		  history.buf[0] = '\0';
		  break;
	  }
  }
  release(&input.lock);
80100fb3:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
80100fba:	e8 12 46 00 00       	call   801055d1 <release>
  ilock(ip);
80100fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc2:	89 04 24             	mov    %eax,(%esp)
80100fc5:	e8 b2 0f 00 00       	call   80101f7c <ilock>

  return target - n;
80100fca:	8b 45 10             	mov    0x10(%ebp),%eax
80100fcd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100fd0:	89 d1                	mov    %edx,%ecx
80100fd2:	29 c1                	sub    %eax,%ecx
80100fd4:	89 c8                	mov    %ecx,%eax
}
80100fd6:	c9                   	leave  
80100fd7:	c3                   	ret    

80100fd8 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100fd8:	55                   	push   %ebp
80100fd9:	89 e5                	mov    %esp,%ebp
80100fdb:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100fde:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe1:	89 04 24             	mov    %eax,(%esp)
80100fe4:	e8 e1 10 00 00       	call   801020ca <iunlock>
  acquire(&cons.lock);
80100fe9:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
80100ff0:	e8 7a 45 00 00       	call   8010556f <acquire>
  for(i = 0; i < n; i++)
80100ff5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ffc:	eb 1d                	jmp    8010101b <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101001:	03 45 0c             	add    0xc(%ebp),%eax
80101004:	0f b6 00             	movzbl (%eax),%eax
80101007:	0f be c0             	movsbl %al,%eax
8010100a:	25 ff 00 00 00       	and    $0xff,%eax
8010100f:	89 04 24             	mov    %eax,(%esp)
80101012:	e8 6c f7 ff ff       	call   80100783 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80101017:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101021:	7c db                	jl     80100ffe <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80101023:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
8010102a:	e8 a2 45 00 00       	call   801055d1 <release>
  ilock(ip);
8010102f:	8b 45 08             	mov    0x8(%ebp),%eax
80101032:	89 04 24             	mov    %eax,(%esp)
80101035:	e8 42 0f 00 00       	call   80101f7c <ilock>

  return n;
8010103a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010103d:	c9                   	leave  
8010103e:	c3                   	ret    

8010103f <consoleinit>:

void
consoleinit(void)
{
8010103f:	55                   	push   %ebp
80101040:	89 e5                	mov    %esp,%ebp
80101042:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80101045:	c7 44 24 04 43 8d 10 	movl   $0x80108d43,0x4(%esp)
8010104c:	80 
8010104d:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
80101054:	e8 f5 44 00 00       	call   8010554e <initlock>
  initlock(&input.lock, "input");
80101059:	c7 44 24 04 4b 8d 10 	movl   $0x80108d4b,0x4(%esp)
80101060:	80 
80101061:	c7 04 24 60 fd 10 80 	movl   $0x8010fd60,(%esp)
80101068:	e8 e1 44 00 00       	call   8010554e <initlock>

  devsw[CONSOLE].write = consolewrite;
8010106d:	c7 05 cc 07 11 80 d8 	movl   $0x80100fd8,0x801107cc
80101074:	0f 10 80 
  devsw[CONSOLE].read = consoleread;
80101077:	c7 05 c8 07 11 80 e9 	movl   $0x80100de9,0x801107c8
8010107e:	0d 10 80 
  cons.locking = 1;
80101081:	c7 05 74 d0 10 80 01 	movl   $0x1,0x8010d074
80101088:	00 00 00 

  picenable(IRQ_KBD);
8010108b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80101092:	e8 3e 31 00 00       	call   801041d5 <picenable>
  ioapicenable(IRQ_KBD, 0);
80101097:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010109e:	00 
8010109f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801010a6:	e8 df 1f 00 00       	call   8010308a <ioapicenable>
}
801010ab:	c9                   	leave  
801010ac:	c3                   	ret    
801010ad:	00 00                	add    %al,(%eax)
	...

801010b0 <exec>:
//static struct PATH* ev_path;


int
exec(char *path, char **argv)
{
801010b0:	55                   	push   %ebp
801010b1:	89 e5                	mov    %esp,%ebp
801010b3:	81 ec b8 01 00 00    	sub    $0x1b8,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  stop = 0;
801010b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
/*  if (first_visit == 1) {
	  ev_path->path_counter = 0 ;
	  first_visit = 0 ;
  }*/
  if((ip = namei(path)) == 0) {
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	89 04 24             	mov    %eax,(%esp)
801010c6:	e8 53 1a 00 00       	call   80102b1e <namei>
801010cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801010ce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010d2:	0f 85 9e 00 00 00    	jne    80101176 <exec+0xc6>
	  // assignment 1 - 1.1 - search in PATH if didn't found in working dir
	  for (i = 0 ; i < path_counter && !stop ; ++i) {
801010d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801010df:	eb 71                	jmp    80101152 <exec+0xa2>
	  	strcpy(full_path_cmd, search_paths[i]);
801010e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801010e4:	89 d0                	mov    %edx,%eax
801010e6:	c1 e0 07             	shl    $0x7,%eax
801010e9:	01 d0                	add    %edx,%eax
801010eb:	05 a0 d0 10 80       	add    $0x8010d0a0,%eax
801010f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801010f4:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
801010fa:	89 04 24             	mov    %eax,(%esp)
801010fd:	e8 50 04 00 00       	call   80101552 <strcpy>
	  	strcpy(full_path_cmd+strlen(search_paths[i]), path);
80101102:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101105:	89 d0                	mov    %edx,%eax
80101107:	c1 e0 07             	shl    $0x7,%eax
8010110a:	01 d0                	add    %edx,%eax
8010110c:	05 a0 d0 10 80       	add    $0x8010d0a0,%eax
80101111:	89 04 24             	mov    %eax,(%esp)
80101114:	e8 23 49 00 00       	call   80105a3c <strlen>
80101119:	8d 95 4c ff ff ff    	lea    -0xb4(%ebp),%edx
8010111f:	01 c2                	add    %eax,%edx
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	89 44 24 04          	mov    %eax,0x4(%esp)
80101128:	89 14 24             	mov    %edx,(%esp)
8010112b:	e8 22 04 00 00       	call   80101552 <strcpy>
	  	if((ip = namei(full_path_cmd)) != 0) {
80101130:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
80101136:	89 04 24             	mov    %eax,(%esp)
80101139:	e8 e0 19 00 00       	call   80102b1e <namei>
8010113e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101141:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101145:	74 07                	je     8010114e <exec+0x9e>
	  		stop = 1;
80101147:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
	  ev_path->path_counter = 0 ;
	  first_visit = 0 ;
  }*/
  if((ip = namei(path)) == 0) {
	  // assignment 1 - 1.1 - search in PATH if didn't found in working dir
	  for (i = 0 ; i < path_counter && !stop ; ++i) {
8010114e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80101152:	a1 80 d0 10 80       	mov    0x8010d080,%eax
80101157:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010115a:	7d 0a                	jge    80101166 <exec+0xb6>
8010115c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80101160:	0f 84 7b ff ff ff    	je     801010e1 <exec+0x31>
	  	strcpy(full_path_cmd+strlen(search_paths[i]), path);
	  	if((ip = namei(full_path_cmd)) != 0) {
	  		stop = 1;
	  	}
	  }
	  if (!stop)
80101166:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010116a:	75 0a                	jne    80101176 <exec+0xc6>
		  return -1;
8010116c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101171:	e9 da 03 00 00       	jmp    80101550 <exec+0x4a0>
  }


  ilock(ip);
80101176:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101179:	89 04 24             	mov    %eax,(%esp)
8010117c:	e8 fb 0d 00 00       	call   80101f7c <ilock>
  pgdir = 0;
80101181:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80101188:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
8010118f:	00 
80101190:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101197:	00 
80101198:	8d 85 88 fe ff ff    	lea    -0x178(%ebp),%eax
8010119e:	89 44 24 04          	mov    %eax,0x4(%esp)
801011a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011a5:	89 04 24             	mov    %eax,(%esp)
801011a8:	e8 c5 12 00 00       	call   80102472 <readi>
801011ad:	83 f8 33             	cmp    $0x33,%eax
801011b0:	0f 86 54 03 00 00    	jbe    8010150a <exec+0x45a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
801011b6:	8b 85 88 fe ff ff    	mov    -0x178(%ebp),%eax
801011bc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
801011c1:	0f 85 46 03 00 00    	jne    8010150d <exec+0x45d>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
801011c7:	c7 04 24 13 32 10 80 	movl   $0x80103213,(%esp)
801011ce:	e8 ce 72 00 00       	call   801084a1 <setupkvm>
801011d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
801011d6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
801011da:	0f 84 30 03 00 00    	je     80101510 <exec+0x460>
    goto bad;

  // Load program into memory.
  sz = 0;
801011e0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801011e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801011ee:	8b 85 a4 fe ff ff    	mov    -0x15c(%ebp),%eax
801011f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
801011f7:	e9 c5 00 00 00       	jmp    801012c1 <exec+0x211>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801011fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801011ff:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80101206:	00 
80101207:	89 44 24 08          	mov    %eax,0x8(%esp)
8010120b:	8d 85 68 fe ff ff    	lea    -0x198(%ebp),%eax
80101211:	89 44 24 04          	mov    %eax,0x4(%esp)
80101215:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101218:	89 04 24             	mov    %eax,(%esp)
8010121b:	e8 52 12 00 00       	call   80102472 <readi>
80101220:	83 f8 20             	cmp    $0x20,%eax
80101223:	0f 85 ea 02 00 00    	jne    80101513 <exec+0x463>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80101229:	8b 85 68 fe ff ff    	mov    -0x198(%ebp),%eax
8010122f:	83 f8 01             	cmp    $0x1,%eax
80101232:	75 7f                	jne    801012b3 <exec+0x203>
      continue;
    if(ph.memsz < ph.filesz)
80101234:	8b 95 7c fe ff ff    	mov    -0x184(%ebp),%edx
8010123a:	8b 85 78 fe ff ff    	mov    -0x188(%ebp),%eax
80101240:	39 c2                	cmp    %eax,%edx
80101242:	0f 82 ce 02 00 00    	jb     80101516 <exec+0x466>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80101248:	8b 95 70 fe ff ff    	mov    -0x190(%ebp),%edx
8010124e:	8b 85 7c fe ff ff    	mov    -0x184(%ebp),%eax
80101254:	01 d0                	add    %edx,%eax
80101256:	89 44 24 08          	mov    %eax,0x8(%esp)
8010125a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101261:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101264:	89 04 24             	mov    %eax,(%esp)
80101267:	e8 07 76 00 00       	call   80108873 <allocuvm>
8010126c:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010126f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80101273:	0f 84 a0 02 00 00    	je     80101519 <exec+0x469>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80101279:	8b 8d 78 fe ff ff    	mov    -0x188(%ebp),%ecx
8010127f:	8b 95 6c fe ff ff    	mov    -0x194(%ebp),%edx
80101285:	8b 85 70 fe ff ff    	mov    -0x190(%ebp),%eax
8010128b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010128f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101293:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101296:	89 54 24 08          	mov    %edx,0x8(%esp)
8010129a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010129e:	8b 45 d0             	mov    -0x30(%ebp),%eax
801012a1:	89 04 24             	mov    %eax,(%esp)
801012a4:	e8 db 74 00 00       	call   80108784 <loaduvm>
801012a9:	85 c0                	test   %eax,%eax
801012ab:	0f 88 6b 02 00 00    	js     8010151c <exec+0x46c>
801012b1:	eb 01                	jmp    801012b4 <exec+0x204>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
801012b3:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801012b4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801012b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012bb:	83 c0 20             	add    $0x20,%eax
801012be:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012c1:	0f b7 85 b4 fe ff ff 	movzwl -0x14c(%ebp),%eax
801012c8:	0f b7 c0             	movzwl %ax,%eax
801012cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ce:	0f 8f 28 ff ff ff    	jg     801011fc <exec+0x14c>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
801012d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801012d7:	89 04 24             	mov    %eax,(%esp)
801012da:	e8 21 0f 00 00       	call   80102200 <iunlockput>
  ip = 0;
801012df:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
801012e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012e9:	05 ff 0f 00 00       	add    $0xfff,%eax
801012ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801012f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
801012f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012f9:	05 00 20 00 00       	add    $0x2000,%eax
801012fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80101302:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101305:	89 44 24 04          	mov    %eax,0x4(%esp)
80101309:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010130c:	89 04 24             	mov    %eax,(%esp)
8010130f:	e8 5f 75 00 00       	call   80108873 <allocuvm>
80101314:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101317:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010131b:	0f 84 fe 01 00 00    	je     8010151f <exec+0x46f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101321:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101324:	2d 00 20 00 00       	sub    $0x2000,%eax
80101329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010132d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101330:	89 04 24             	mov    %eax,(%esp)
80101333:	e8 5f 77 00 00       	call   80108a97 <clearpteu>
  sp = sz;
80101338:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010133b:	89 45 d8             	mov    %eax,-0x28(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010133e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80101345:	e9 81 00 00 00       	jmp    801013cb <exec+0x31b>
    if(argc >= MAXARG)
8010134a:	83 7d e0 1f          	cmpl   $0x1f,-0x20(%ebp)
8010134e:	0f 87 ce 01 00 00    	ja     80101522 <exec+0x472>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101354:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101357:	c1 e0 02             	shl    $0x2,%eax
8010135a:	03 45 0c             	add    0xc(%ebp),%eax
8010135d:	8b 00                	mov    (%eax),%eax
8010135f:	89 04 24             	mov    %eax,(%esp)
80101362:	e8 d5 46 00 00       	call   80105a3c <strlen>
80101367:	f7 d0                	not    %eax
80101369:	03 45 d8             	add    -0x28(%ebp),%eax
8010136c:	83 e0 fc             	and    $0xfffffffc,%eax
8010136f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101372:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101375:	c1 e0 02             	shl    $0x2,%eax
80101378:	03 45 0c             	add    0xc(%ebp),%eax
8010137b:	8b 00                	mov    (%eax),%eax
8010137d:	89 04 24             	mov    %eax,(%esp)
80101380:	e8 b7 46 00 00       	call   80105a3c <strlen>
80101385:	83 c0 01             	add    $0x1,%eax
80101388:	89 c2                	mov    %eax,%edx
8010138a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010138d:	c1 e0 02             	shl    $0x2,%eax
80101390:	03 45 0c             	add    0xc(%ebp),%eax
80101393:	8b 00                	mov    (%eax),%eax
80101395:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101399:	89 44 24 08          	mov    %eax,0x8(%esp)
8010139d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801013a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801013a7:	89 04 24             	mov    %eax,(%esp)
801013aa:	e8 9c 78 00 00       	call   80108c4b <copyout>
801013af:	85 c0                	test   %eax,%eax
801013b1:	0f 88 6e 01 00 00    	js     80101525 <exec+0x475>
      goto bad;
    ustack[3+argc] = sp;
801013b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013ba:	8d 50 03             	lea    0x3(%eax),%edx
801013bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013c0:	89 84 95 bc fe ff ff 	mov    %eax,-0x144(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801013c7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801013cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013ce:	c1 e0 02             	shl    $0x2,%eax
801013d1:	03 45 0c             	add    0xc(%ebp),%eax
801013d4:	8b 00                	mov    (%eax),%eax
801013d6:	85 c0                	test   %eax,%eax
801013d8:	0f 85 6c ff ff ff    	jne    8010134a <exec+0x29a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801013de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013e1:	83 c0 03             	add    $0x3,%eax
801013e4:	c7 84 85 bc fe ff ff 	movl   $0x0,-0x144(%ebp,%eax,4)
801013eb:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801013ef:	c7 85 bc fe ff ff ff 	movl   $0xffffffff,-0x144(%ebp)
801013f6:	ff ff ff 
  ustack[1] = argc;
801013f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013fc:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101402:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101405:	83 c0 01             	add    $0x1,%eax
80101408:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010140f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101412:	29 d0                	sub    %edx,%eax
80101414:	89 85 c4 fe ff ff    	mov    %eax,-0x13c(%ebp)

  sp -= (3+argc+1) * 4;
8010141a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010141d:	83 c0 04             	add    $0x4,%eax
80101420:	c1 e0 02             	shl    $0x2,%eax
80101423:	29 45 d8             	sub    %eax,-0x28(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101426:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101429:	83 c0 04             	add    $0x4,%eax
8010142c:	c1 e0 02             	shl    $0x2,%eax
8010142f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101433:	8d 85 bc fe ff ff    	lea    -0x144(%ebp),%eax
80101439:	89 44 24 08          	mov    %eax,0x8(%esp)
8010143d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101440:	89 44 24 04          	mov    %eax,0x4(%esp)
80101444:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101447:	89 04 24             	mov    %eax,(%esp)
8010144a:	e8 fc 77 00 00       	call   80108c4b <copyout>
8010144f:	85 c0                	test   %eax,%eax
80101451:	0f 88 d1 00 00 00    	js     80101528 <exec+0x478>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101460:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101463:	eb 17                	jmp    8010147c <exec+0x3cc>
    if(*s == '/')
80101465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101468:	0f b6 00             	movzbl (%eax),%eax
8010146b:	3c 2f                	cmp    $0x2f,%al
8010146d:	75 09                	jne    80101478 <exec+0x3c8>
      last = s+1;
8010146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101472:	83 c0 01             	add    $0x1,%eax
80101475:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101478:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010147f:	0f b6 00             	movzbl (%eax),%eax
80101482:	84 c0                	test   %al,%al
80101484:	75 df                	jne    80101465 <exec+0x3b5>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101486:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010148c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010148f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101496:	00 
80101497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010149e:	89 14 24             	mov    %edx,(%esp)
801014a1:	e8 48 45 00 00       	call   801059ee <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801014a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014ac:	8b 40 04             	mov    0x4(%eax),%eax
801014af:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
801014b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014b8:	8b 55 d0             	mov    -0x30(%ebp),%edx
801014bb:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801014be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801014c7:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801014c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014cf:	8b 40 18             	mov    0x18(%eax),%eax
801014d2:	8b 95 a0 fe ff ff    	mov    -0x160(%ebp),%edx
801014d8:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801014db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014e1:	8b 40 18             	mov    0x18(%eax),%eax
801014e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
801014e7:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801014ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014f0:	89 04 24             	mov    %eax,(%esp)
801014f3:	e8 9a 70 00 00       	call   80108592 <switchuvm>
  freevm(oldpgdir);
801014f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801014fb:	89 04 24             	mov    %eax,(%esp)
801014fe:	e8 06 75 00 00       	call   80108a09 <freevm>
  return 0;
80101503:	b8 00 00 00 00       	mov    $0x0,%eax
80101508:	eb 46                	jmp    80101550 <exec+0x4a0>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010150a:	90                   	nop
8010150b:	eb 1c                	jmp    80101529 <exec+0x479>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010150d:	90                   	nop
8010150e:	eb 19                	jmp    80101529 <exec+0x479>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101510:	90                   	nop
80101511:	eb 16                	jmp    80101529 <exec+0x479>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101513:	90                   	nop
80101514:	eb 13                	jmp    80101529 <exec+0x479>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101516:	90                   	nop
80101517:	eb 10                	jmp    80101529 <exec+0x479>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101519:	90                   	nop
8010151a:	eb 0d                	jmp    80101529 <exec+0x479>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010151c:	90                   	nop
8010151d:	eb 0a                	jmp    80101529 <exec+0x479>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010151f:	90                   	nop
80101520:	eb 07                	jmp    80101529 <exec+0x479>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101522:	90                   	nop
80101523:	eb 04                	jmp    80101529 <exec+0x479>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101525:	90                   	nop
80101526:	eb 01                	jmp    80101529 <exec+0x479>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101528:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101529:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
8010152d:	74 0b                	je     8010153a <exec+0x48a>
    freevm(pgdir);
8010152f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101532:	89 04 24             	mov    %eax,(%esp)
80101535:	e8 cf 74 00 00       	call   80108a09 <freevm>
  if(ip)
8010153a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010153e:	74 0b                	je     8010154b <exec+0x49b>
    iunlockput(ip);
80101540:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101543:	89 04 24             	mov    %eax,(%esp)
80101546:	e8 b5 0c 00 00       	call   80102200 <iunlockput>
  return -1;
8010154b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101550:	c9                   	leave  
80101551:	c3                   	ret    

80101552 <strcpy>:

char*
strcpy(char *s, char *t)
{
80101552:	55                   	push   %ebp
80101553:	89 e5                	mov    %esp,%ebp
80101555:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101558:	8b 45 08             	mov    0x8(%ebp),%eax
8010155b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010155e:	90                   	nop
8010155f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101562:	0f b6 10             	movzbl (%eax),%edx
80101565:	8b 45 08             	mov    0x8(%ebp),%eax
80101568:	88 10                	mov    %dl,(%eax)
8010156a:	8b 45 08             	mov    0x8(%ebp),%eax
8010156d:	0f b6 00             	movzbl (%eax),%eax
80101570:	84 c0                	test   %al,%al
80101572:	0f 95 c0             	setne  %al
80101575:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80101579:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010157d:	84 c0                	test   %al,%al
8010157f:	75 de                	jne    8010155f <strcpy+0xd>
    ;
  return os;
80101581:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80101584:	c9                   	leave  
80101585:	c3                   	ret    

80101586 <add_path>:

int add_path(char* path) {
80101586:	55                   	push   %ebp
80101587:	89 e5                	mov    %esp,%ebp
80101589:	83 ec 10             	sub    $0x10,%esp
	int next_char = 0;
8010158c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	if (path_counter > MAX_PATH_ENTRIES) {
80101593:	a1 80 d0 10 80       	mov    0x8010d080,%eax
80101598:	83 f8 0a             	cmp    $0xa,%eax
8010159b:	7e 2e                	jle    801015cb <add_path+0x45>
		return path_counter;
8010159d:	a1 80 d0 10 80       	mov    0x8010d080,%eax
801015a2:	eb 6c                	jmp    80101610 <add_path+0x8a>
	}
	while(*path != 0 && *path != '\n' && *path != '\t' && *path != '\r' && *path != ' ') {
		search_paths[path_counter][next_char] = *path;
801015a4:	8b 15 80 d0 10 80    	mov    0x8010d080,%edx
801015aa:	8b 45 08             	mov    0x8(%ebp),%eax
801015ad:	0f b6 08             	movzbl (%eax),%ecx
801015b0:	89 d0                	mov    %edx,%eax
801015b2:	c1 e0 07             	shl    $0x7,%eax
801015b5:	01 d0                	add    %edx,%eax
801015b7:	03 45 fc             	add    -0x4(%ebp),%eax
801015ba:	05 a0 d0 10 80       	add    $0x8010d0a0,%eax
801015bf:	88 08                	mov    %cl,(%eax)
		next_char++;
801015c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		path++;
801015c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801015c9:	eb 01                	jmp    801015cc <add_path+0x46>
int add_path(char* path) {
	int next_char = 0;
	if (path_counter > MAX_PATH_ENTRIES) {
		return path_counter;
	}
	while(*path != 0 && *path != '\n' && *path != '\t' && *path != '\r' && *path != ' ') {
801015cb:	90                   	nop
801015cc:	8b 45 08             	mov    0x8(%ebp),%eax
801015cf:	0f b6 00             	movzbl (%eax),%eax
801015d2:	84 c0                	test   %al,%al
801015d4:	74 28                	je     801015fe <add_path+0x78>
801015d6:	8b 45 08             	mov    0x8(%ebp),%eax
801015d9:	0f b6 00             	movzbl (%eax),%eax
801015dc:	3c 0a                	cmp    $0xa,%al
801015de:	74 1e                	je     801015fe <add_path+0x78>
801015e0:	8b 45 08             	mov    0x8(%ebp),%eax
801015e3:	0f b6 00             	movzbl (%eax),%eax
801015e6:	3c 09                	cmp    $0x9,%al
801015e8:	74 14                	je     801015fe <add_path+0x78>
801015ea:	8b 45 08             	mov    0x8(%ebp),%eax
801015ed:	0f b6 00             	movzbl (%eax),%eax
801015f0:	3c 0d                	cmp    $0xd,%al
801015f2:	74 0a                	je     801015fe <add_path+0x78>
801015f4:	8b 45 08             	mov    0x8(%ebp),%eax
801015f7:	0f b6 00             	movzbl (%eax),%eax
801015fa:	3c 20                	cmp    $0x20,%al
801015fc:	75 a6                	jne    801015a4 <add_path+0x1e>
		search_paths[path_counter][next_char] = *path;
		next_char++;
		path++;
	}
	path_counter++;
801015fe:	a1 80 d0 10 80       	mov    0x8010d080,%eax
80101603:	83 c0 01             	add    $0x1,%eax
80101606:	a3 80 d0 10 80       	mov    %eax,0x8010d080
	return 0;
8010160b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101610:	c9                   	leave  
80101611:	c3                   	ret    
	...

80101614 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101614:	55                   	push   %ebp
80101615:	89 e5                	mov    %esp,%ebp
80101617:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010161a:	c7 44 24 04 51 8d 10 	movl   $0x80108d51,0x4(%esp)
80101621:	80 
80101622:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
80101629:	e8 20 3f 00 00       	call   8010554e <initlock>
}
8010162e:	c9                   	leave  
8010162f:	c3                   	ret    

80101630 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101630:	55                   	push   %ebp
80101631:	89 e5                	mov    %esp,%ebp
80101633:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101636:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
8010163d:	e8 2d 3f 00 00       	call   8010556f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101642:	c7 45 f4 54 fe 10 80 	movl   $0x8010fe54,-0xc(%ebp)
80101649:	eb 29                	jmp    80101674 <filealloc+0x44>
    if(f->ref == 0){
8010164b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164e:	8b 40 04             	mov    0x4(%eax),%eax
80101651:	85 c0                	test   %eax,%eax
80101653:	75 1b                	jne    80101670 <filealloc+0x40>
      f->ref = 1;
80101655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101658:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010165f:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
80101666:	e8 66 3f 00 00       	call   801055d1 <release>
      return f;
8010166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166e:	eb 1e                	jmp    8010168e <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101670:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101674:	81 7d f4 b4 07 11 80 	cmpl   $0x801107b4,-0xc(%ebp)
8010167b:	72 ce                	jb     8010164b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010167d:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
80101684:	e8 48 3f 00 00       	call   801055d1 <release>
  return 0;
80101689:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010168e:	c9                   	leave  
8010168f:	c3                   	ret    

80101690 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101690:	55                   	push   %ebp
80101691:	89 e5                	mov    %esp,%ebp
80101693:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101696:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
8010169d:	e8 cd 3e 00 00       	call   8010556f <acquire>
  if(f->ref < 1)
801016a2:	8b 45 08             	mov    0x8(%ebp),%eax
801016a5:	8b 40 04             	mov    0x4(%eax),%eax
801016a8:	85 c0                	test   %eax,%eax
801016aa:	7f 0c                	jg     801016b8 <filedup+0x28>
    panic("filedup");
801016ac:	c7 04 24 58 8d 10 80 	movl   $0x80108d58,(%esp)
801016b3:	e8 85 ee ff ff       	call   8010053d <panic>
  f->ref++;
801016b8:	8b 45 08             	mov    0x8(%ebp),%eax
801016bb:	8b 40 04             	mov    0x4(%eax),%eax
801016be:	8d 50 01             	lea    0x1(%eax),%edx
801016c1:	8b 45 08             	mov    0x8(%ebp),%eax
801016c4:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801016c7:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
801016ce:	e8 fe 3e 00 00       	call   801055d1 <release>
  return f;
801016d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801016d6:	c9                   	leave  
801016d7:	c3                   	ret    

801016d8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801016d8:	55                   	push   %ebp
801016d9:	89 e5                	mov    %esp,%ebp
801016db:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801016de:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
801016e5:	e8 85 3e 00 00       	call   8010556f <acquire>
  if(f->ref < 1)
801016ea:	8b 45 08             	mov    0x8(%ebp),%eax
801016ed:	8b 40 04             	mov    0x4(%eax),%eax
801016f0:	85 c0                	test   %eax,%eax
801016f2:	7f 0c                	jg     80101700 <fileclose+0x28>
    panic("fileclose");
801016f4:	c7 04 24 60 8d 10 80 	movl   $0x80108d60,(%esp)
801016fb:	e8 3d ee ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101700:	8b 45 08             	mov    0x8(%ebp),%eax
80101703:	8b 40 04             	mov    0x4(%eax),%eax
80101706:	8d 50 ff             	lea    -0x1(%eax),%edx
80101709:	8b 45 08             	mov    0x8(%ebp),%eax
8010170c:	89 50 04             	mov    %edx,0x4(%eax)
8010170f:	8b 45 08             	mov    0x8(%ebp),%eax
80101712:	8b 40 04             	mov    0x4(%eax),%eax
80101715:	85 c0                	test   %eax,%eax
80101717:	7e 11                	jle    8010172a <fileclose+0x52>
    release(&ftable.lock);
80101719:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
80101720:	e8 ac 3e 00 00       	call   801055d1 <release>
    return;
80101725:	e9 82 00 00 00       	jmp    801017ac <fileclose+0xd4>
  }
  ff = *f;
8010172a:	8b 45 08             	mov    0x8(%ebp),%eax
8010172d:	8b 10                	mov    (%eax),%edx
8010172f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101732:	8b 50 04             	mov    0x4(%eax),%edx
80101735:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101738:	8b 50 08             	mov    0x8(%eax),%edx
8010173b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010173e:	8b 50 0c             	mov    0xc(%eax),%edx
80101741:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101744:	8b 50 10             	mov    0x10(%eax),%edx
80101747:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010174a:	8b 40 14             	mov    0x14(%eax),%eax
8010174d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101750:	8b 45 08             	mov    0x8(%ebp),%eax
80101753:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010175a:	8b 45 08             	mov    0x8(%ebp),%eax
8010175d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101763:	c7 04 24 20 fe 10 80 	movl   $0x8010fe20,(%esp)
8010176a:	e8 62 3e 00 00       	call   801055d1 <release>
  
  if(ff.type == FD_PIPE)
8010176f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101772:	83 f8 01             	cmp    $0x1,%eax
80101775:	75 18                	jne    8010178f <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101777:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010177b:	0f be d0             	movsbl %al,%edx
8010177e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101781:	89 54 24 04          	mov    %edx,0x4(%esp)
80101785:	89 04 24             	mov    %eax,(%esp)
80101788:	e8 02 2d 00 00       	call   8010448f <pipeclose>
8010178d:	eb 1d                	jmp    801017ac <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010178f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101792:	83 f8 02             	cmp    $0x2,%eax
80101795:	75 15                	jne    801017ac <fileclose+0xd4>
    begin_trans();
80101797:	e8 95 21 00 00       	call   80103931 <begin_trans>
    iput(ff.ip);
8010179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179f:	89 04 24             	mov    %eax,(%esp)
801017a2:	e8 88 09 00 00       	call   8010212f <iput>
    commit_trans();
801017a7:	e8 ce 21 00 00       	call   8010397a <commit_trans>
  }
}
801017ac:	c9                   	leave  
801017ad:	c3                   	ret    

801017ae <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801017ae:	55                   	push   %ebp
801017af:	89 e5                	mov    %esp,%ebp
801017b1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801017b4:	8b 45 08             	mov    0x8(%ebp),%eax
801017b7:	8b 00                	mov    (%eax),%eax
801017b9:	83 f8 02             	cmp    $0x2,%eax
801017bc:	75 38                	jne    801017f6 <filestat+0x48>
    ilock(f->ip);
801017be:	8b 45 08             	mov    0x8(%ebp),%eax
801017c1:	8b 40 10             	mov    0x10(%eax),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 b0 07 00 00       	call   80101f7c <ilock>
    stati(f->ip, st);
801017cc:	8b 45 08             	mov    0x8(%ebp),%eax
801017cf:	8b 40 10             	mov    0x10(%eax),%eax
801017d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801017d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801017d9:	89 04 24             	mov    %eax,(%esp)
801017dc:	e8 4c 0c 00 00       	call   8010242d <stati>
    iunlock(f->ip);
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	8b 40 10             	mov    0x10(%eax),%eax
801017e7:	89 04 24             	mov    %eax,(%esp)
801017ea:	e8 db 08 00 00       	call   801020ca <iunlock>
    return 0;
801017ef:	b8 00 00 00 00       	mov    $0x0,%eax
801017f4:	eb 05                	jmp    801017fb <filestat+0x4d>
  }
  return -1;
801017f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801017fb:	c9                   	leave  
801017fc:	c3                   	ret    

801017fd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801017fd:	55                   	push   %ebp
801017fe:	89 e5                	mov    %esp,%ebp
80101800:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101803:	8b 45 08             	mov    0x8(%ebp),%eax
80101806:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010180a:	84 c0                	test   %al,%al
8010180c:	75 0a                	jne    80101818 <fileread+0x1b>
    return -1;
8010180e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101813:	e9 9f 00 00 00       	jmp    801018b7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101818:	8b 45 08             	mov    0x8(%ebp),%eax
8010181b:	8b 00                	mov    (%eax),%eax
8010181d:	83 f8 01             	cmp    $0x1,%eax
80101820:	75 1e                	jne    80101840 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101822:	8b 45 08             	mov    0x8(%ebp),%eax
80101825:	8b 40 0c             	mov    0xc(%eax),%eax
80101828:	8b 55 10             	mov    0x10(%ebp),%edx
8010182b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010182f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101832:	89 54 24 04          	mov    %edx,0x4(%esp)
80101836:	89 04 24             	mov    %eax,(%esp)
80101839:	e8 d3 2d 00 00       	call   80104611 <piperead>
8010183e:	eb 77                	jmp    801018b7 <fileread+0xba>
  if(f->type == FD_INODE){
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 00                	mov    (%eax),%eax
80101845:	83 f8 02             	cmp    $0x2,%eax
80101848:	75 61                	jne    801018ab <fileread+0xae>
    ilock(f->ip);
8010184a:	8b 45 08             	mov    0x8(%ebp),%eax
8010184d:	8b 40 10             	mov    0x10(%eax),%eax
80101850:	89 04 24             	mov    %eax,(%esp)
80101853:	e8 24 07 00 00       	call   80101f7c <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101858:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010185b:	8b 45 08             	mov    0x8(%ebp),%eax
8010185e:	8b 50 14             	mov    0x14(%eax),%edx
80101861:	8b 45 08             	mov    0x8(%ebp),%eax
80101864:	8b 40 10             	mov    0x10(%eax),%eax
80101867:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010186b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010186f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101872:	89 54 24 04          	mov    %edx,0x4(%esp)
80101876:	89 04 24             	mov    %eax,(%esp)
80101879:	e8 f4 0b 00 00       	call   80102472 <readi>
8010187e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101885:	7e 11                	jle    80101898 <fileread+0x9b>
      f->off += r;
80101887:	8b 45 08             	mov    0x8(%ebp),%eax
8010188a:	8b 50 14             	mov    0x14(%eax),%edx
8010188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101890:	01 c2                	add    %eax,%edx
80101892:	8b 45 08             	mov    0x8(%ebp),%eax
80101895:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101898:	8b 45 08             	mov    0x8(%ebp),%eax
8010189b:	8b 40 10             	mov    0x10(%eax),%eax
8010189e:	89 04 24             	mov    %eax,(%esp)
801018a1:	e8 24 08 00 00       	call   801020ca <iunlock>
    return r;
801018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a9:	eb 0c                	jmp    801018b7 <fileread+0xba>
  }
  panic("fileread");
801018ab:	c7 04 24 6a 8d 10 80 	movl   $0x80108d6a,(%esp)
801018b2:	e8 86 ec ff ff       	call   8010053d <panic>
}
801018b7:	c9                   	leave  
801018b8:	c3                   	ret    

801018b9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801018b9:	55                   	push   %ebp
801018ba:	89 e5                	mov    %esp,%ebp
801018bc:	53                   	push   %ebx
801018bd:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801018c0:	8b 45 08             	mov    0x8(%ebp),%eax
801018c3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801018c7:	84 c0                	test   %al,%al
801018c9:	75 0a                	jne    801018d5 <filewrite+0x1c>
    return -1;
801018cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018d0:	e9 23 01 00 00       	jmp    801019f8 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801018d5:	8b 45 08             	mov    0x8(%ebp),%eax
801018d8:	8b 00                	mov    (%eax),%eax
801018da:	83 f8 01             	cmp    $0x1,%eax
801018dd:	75 21                	jne    80101900 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801018df:	8b 45 08             	mov    0x8(%ebp),%eax
801018e2:	8b 40 0c             	mov    0xc(%eax),%eax
801018e5:	8b 55 10             	mov    0x10(%ebp),%edx
801018e8:	89 54 24 08          	mov    %edx,0x8(%esp)
801018ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801018ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801018f3:	89 04 24             	mov    %eax,(%esp)
801018f6:	e8 26 2c 00 00       	call   80104521 <pipewrite>
801018fb:	e9 f8 00 00 00       	jmp    801019f8 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101900:	8b 45 08             	mov    0x8(%ebp),%eax
80101903:	8b 00                	mov    (%eax),%eax
80101905:	83 f8 02             	cmp    $0x2,%eax
80101908:	0f 85 de 00 00 00    	jne    801019ec <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010190e:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010191c:	e9 a8 00 00 00       	jmp    801019c9 <filewrite+0x110>
      int n1 = n - i;
80101921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101924:	8b 55 10             	mov    0x10(%ebp),%edx
80101927:	89 d1                	mov    %edx,%ecx
80101929:	29 c1                	sub    %eax,%ecx
8010192b:	89 c8                	mov    %ecx,%eax
8010192d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101933:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101936:	7e 06                	jle    8010193e <filewrite+0x85>
        n1 = max;
80101938:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010193b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010193e:	e8 ee 1f 00 00       	call   80103931 <begin_trans>
      ilock(f->ip);
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	8b 40 10             	mov    0x10(%eax),%eax
80101949:	89 04 24             	mov    %eax,(%esp)
8010194c:	e8 2b 06 00 00       	call   80101f7c <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101951:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101954:	8b 45 08             	mov    0x8(%ebp),%eax
80101957:	8b 48 14             	mov    0x14(%eax),%ecx
8010195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195d:	89 c2                	mov    %eax,%edx
8010195f:	03 55 0c             	add    0xc(%ebp),%edx
80101962:	8b 45 08             	mov    0x8(%ebp),%eax
80101965:	8b 40 10             	mov    0x10(%eax),%eax
80101968:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010196c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101970:	89 54 24 04          	mov    %edx,0x4(%esp)
80101974:	89 04 24             	mov    %eax,(%esp)
80101977:	e8 61 0c 00 00       	call   801025dd <writei>
8010197c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010197f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101983:	7e 11                	jle    80101996 <filewrite+0xdd>
        f->off += r;
80101985:	8b 45 08             	mov    0x8(%ebp),%eax
80101988:	8b 50 14             	mov    0x14(%eax),%edx
8010198b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010198e:	01 c2                	add    %eax,%edx
80101990:	8b 45 08             	mov    0x8(%ebp),%eax
80101993:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	8b 40 10             	mov    0x10(%eax),%eax
8010199c:	89 04 24             	mov    %eax,(%esp)
8010199f:	e8 26 07 00 00       	call   801020ca <iunlock>
      commit_trans();
801019a4:	e8 d1 1f 00 00       	call   8010397a <commit_trans>

      if(r < 0)
801019a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801019ad:	78 28                	js     801019d7 <filewrite+0x11e>
        break;
      if(r != n1)
801019af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019b2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801019b5:	74 0c                	je     801019c3 <filewrite+0x10a>
        panic("short filewrite");
801019b7:	c7 04 24 73 8d 10 80 	movl   $0x80108d73,(%esp)
801019be:	e8 7a eb ff ff       	call   8010053d <panic>
      i += r;
801019c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019c6:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cc:	3b 45 10             	cmp    0x10(%ebp),%eax
801019cf:	0f 8c 4c ff ff ff    	jl     80101921 <filewrite+0x68>
801019d5:	eb 01                	jmp    801019d8 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801019d7:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019db:	3b 45 10             	cmp    0x10(%ebp),%eax
801019de:	75 05                	jne    801019e5 <filewrite+0x12c>
801019e0:	8b 45 10             	mov    0x10(%ebp),%eax
801019e3:	eb 05                	jmp    801019ea <filewrite+0x131>
801019e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019ea:	eb 0c                	jmp    801019f8 <filewrite+0x13f>
  }
  panic("filewrite");
801019ec:	c7 04 24 83 8d 10 80 	movl   $0x80108d83,(%esp)
801019f3:	e8 45 eb ff ff       	call   8010053d <panic>
}
801019f8:	83 c4 24             	add    $0x24,%esp
801019fb:	5b                   	pop    %ebx
801019fc:	5d                   	pop    %ebp
801019fd:	c3                   	ret    
	...

80101a00 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101a10:	00 
80101a11:	89 04 24             	mov    %eax,(%esp)
80101a14:	e8 8d e7 ff ff       	call   801001a6 <bread>
80101a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1f:	83 c0 18             	add    $0x18,%eax
80101a22:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101a29:	00 
80101a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a31:	89 04 24             	mov    %eax,(%esp)
80101a34:	e8 58 3e 00 00       	call   80105891 <memmove>
  brelse(bp);
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3c:	89 04 24             	mov    %eax,(%esp)
80101a3f:	e8 d3 e7 ff ff       	call   80100217 <brelse>
}
80101a44:	c9                   	leave  
80101a45:	c3                   	ret    

80101a46 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101a46:	55                   	push   %ebp
80101a47:	89 e5                	mov    %esp,%ebp
80101a49:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a56:	89 04 24             	mov    %eax,(%esp)
80101a59:	e8 48 e7 ff ff       	call   801001a6 <bread>
80101a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	83 c0 18             	add    $0x18,%eax
80101a67:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101a6e:	00 
80101a6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101a76:	00 
80101a77:	89 04 24             	mov    %eax,(%esp)
80101a7a:	e8 3f 3d 00 00       	call   801057be <memset>
  log_write(bp);
80101a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a82:	89 04 24             	mov    %eax,(%esp)
80101a85:	e8 48 1f 00 00       	call   801039d2 <log_write>
  brelse(bp);
80101a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8d:	89 04 24             	mov    %eax,(%esp)
80101a90:	e8 82 e7 ff ff       	call   80100217 <brelse>
}
80101a95:	c9                   	leave  
80101a96:	c3                   	ret    

80101a97 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101a97:	55                   	push   %ebp
80101a98:	89 e5                	mov    %esp,%ebp
80101a9a:	53                   	push   %ebx
80101a9b:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101a9e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101aab:	89 54 24 04          	mov    %edx,0x4(%esp)
80101aaf:	89 04 24             	mov    %eax,(%esp)
80101ab2:	e8 49 ff ff ff       	call   80101a00 <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101abe:	e9 11 01 00 00       	jmp    80101bd4 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101acc:	85 c0                	test   %eax,%eax
80101ace:	0f 48 c2             	cmovs  %edx,%eax
80101ad1:	c1 f8 0c             	sar    $0xc,%eax
80101ad4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101ad7:	c1 ea 03             	shr    $0x3,%edx
80101ada:	01 d0                	add    %edx,%eax
80101adc:	83 c0 03             	add    $0x3,%eax
80101adf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae6:	89 04 24             	mov    %eax,(%esp)
80101ae9:	e8 b8 e6 ff ff       	call   801001a6 <bread>
80101aee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101af1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101af8:	e9 a7 00 00 00       	jmp    80101ba4 <balloc+0x10d>
      m = 1 << (bi % 8);
80101afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b00:	89 c2                	mov    %eax,%edx
80101b02:	c1 fa 1f             	sar    $0x1f,%edx
80101b05:	c1 ea 1d             	shr    $0x1d,%edx
80101b08:	01 d0                	add    %edx,%eax
80101b0a:	83 e0 07             	and    $0x7,%eax
80101b0d:	29 d0                	sub    %edx,%eax
80101b0f:	ba 01 00 00 00       	mov    $0x1,%edx
80101b14:	89 d3                	mov    %edx,%ebx
80101b16:	89 c1                	mov    %eax,%ecx
80101b18:	d3 e3                	shl    %cl,%ebx
80101b1a:	89 d8                	mov    %ebx,%eax
80101b1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b22:	8d 50 07             	lea    0x7(%eax),%edx
80101b25:	85 c0                	test   %eax,%eax
80101b27:	0f 48 c2             	cmovs  %edx,%eax
80101b2a:	c1 f8 03             	sar    $0x3,%eax
80101b2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b30:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101b35:	0f b6 c0             	movzbl %al,%eax
80101b38:	23 45 e8             	and    -0x18(%ebp),%eax
80101b3b:	85 c0                	test   %eax,%eax
80101b3d:	75 61                	jne    80101ba0 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b42:	8d 50 07             	lea    0x7(%eax),%edx
80101b45:	85 c0                	test   %eax,%eax
80101b47:	0f 48 c2             	cmovs  %edx,%eax
80101b4a:	c1 f8 03             	sar    $0x3,%eax
80101b4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b50:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101b55:	89 d1                	mov    %edx,%ecx
80101b57:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101b5a:	09 ca                	or     %ecx,%edx
80101b5c:	89 d1                	mov    %edx,%ecx
80101b5e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b61:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b68:	89 04 24             	mov    %eax,(%esp)
80101b6b:	e8 62 1e 00 00       	call   801039d2 <log_write>
        brelse(bp);
80101b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b73:	89 04 24             	mov    %eax,(%esp)
80101b76:	e8 9c e6 ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b81:	01 c2                	add    %eax,%edx
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 b4 fe ff ff       	call   80101a46 <bzero>
        return b + bi;
80101b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b98:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101b9a:	83 c4 34             	add    $0x34,%esp
80101b9d:	5b                   	pop    %ebx
80101b9e:	5d                   	pop    %ebp
80101b9f:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101ba0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ba4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101bab:	7f 15                	jg     80101bc2 <balloc+0x12b>
80101bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb3:	01 d0                	add    %edx,%eax
80101bb5:	89 c2                	mov    %eax,%edx
80101bb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bba:	39 c2                	cmp    %eax,%edx
80101bbc:	0f 82 3b ff ff ff    	jb     80101afd <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bc5:	89 04 24             	mov    %eax,(%esp)
80101bc8:	e8 4a e6 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101bcd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101bd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bd7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bda:	39 c2                	cmp    %eax,%edx
80101bdc:	0f 82 e1 fe ff ff    	jb     80101ac3 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101be2:	c7 04 24 8d 8d 10 80 	movl   $0x80108d8d,(%esp)
80101be9:	e8 4f e9 ff ff       	call   8010053d <panic>

80101bee <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101bee:	55                   	push   %ebp
80101bef:	89 e5                	mov    %esp,%ebp
80101bf1:	53                   	push   %ebx
80101bf2:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101bf5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
80101bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bff:	89 04 24             	mov    %eax,(%esp)
80101c02:	e8 f9 fd ff ff       	call   80101a00 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c0a:	89 c2                	mov    %eax,%edx
80101c0c:	c1 ea 0c             	shr    $0xc,%edx
80101c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c12:	c1 e8 03             	shr    $0x3,%eax
80101c15:	01 d0                	add    %edx,%eax
80101c17:	8d 50 03             	lea    0x3(%eax),%edx
80101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c21:	89 04 24             	mov    %eax,(%esp)
80101c24:	e8 7d e5 ff ff       	call   801001a6 <bread>
80101c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c2f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3a:	89 c2                	mov    %eax,%edx
80101c3c:	c1 fa 1f             	sar    $0x1f,%edx
80101c3f:	c1 ea 1d             	shr    $0x1d,%edx
80101c42:	01 d0                	add    %edx,%eax
80101c44:	83 e0 07             	and    $0x7,%eax
80101c47:	29 d0                	sub    %edx,%eax
80101c49:	ba 01 00 00 00       	mov    $0x1,%edx
80101c4e:	89 d3                	mov    %edx,%ebx
80101c50:	89 c1                	mov    %eax,%ecx
80101c52:	d3 e3                	shl    %cl,%ebx
80101c54:	89 d8                	mov    %ebx,%eax
80101c56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5c:	8d 50 07             	lea    0x7(%eax),%edx
80101c5f:	85 c0                	test   %eax,%eax
80101c61:	0f 48 c2             	cmovs  %edx,%eax
80101c64:	c1 f8 03             	sar    $0x3,%eax
80101c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101c6f:	0f b6 c0             	movzbl %al,%eax
80101c72:	23 45 ec             	and    -0x14(%ebp),%eax
80101c75:	85 c0                	test   %eax,%eax
80101c77:	75 0c                	jne    80101c85 <bfree+0x97>
    panic("freeing free block");
80101c79:	c7 04 24 a3 8d 10 80 	movl   $0x80108da3,(%esp)
80101c80:	e8 b8 e8 ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c88:	8d 50 07             	lea    0x7(%eax),%edx
80101c8b:	85 c0                	test   %eax,%eax
80101c8d:	0f 48 c2             	cmovs  %edx,%eax
80101c90:	c1 f8 03             	sar    $0x3,%eax
80101c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c96:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101c9b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101c9e:	f7 d1                	not    %ecx
80101ca0:	21 ca                	and    %ecx,%edx
80101ca2:	89 d1                	mov    %edx,%ecx
80101ca4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cae:	89 04 24             	mov    %eax,(%esp)
80101cb1:	e8 1c 1d 00 00       	call   801039d2 <log_write>
  brelse(bp);
80101cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb9:	89 04 24             	mov    %eax,(%esp)
80101cbc:	e8 56 e5 ff ff       	call   80100217 <brelse>
}
80101cc1:	83 c4 34             	add    $0x34,%esp
80101cc4:	5b                   	pop    %ebx
80101cc5:	5d                   	pop    %ebp
80101cc6:	c3                   	ret    

80101cc7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101cc7:	55                   	push   %ebp
80101cc8:	89 e5                	mov    %esp,%ebp
80101cca:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101ccd:	c7 44 24 04 b6 8d 10 	movl   $0x80108db6,0x4(%esp)
80101cd4:	80 
80101cd5:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101cdc:	e8 6d 38 00 00       	call   8010554e <initlock>
}
80101ce1:	c9                   	leave  
80101ce2:	c3                   	ret    

80101ce3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101ce3:	55                   	push   %ebp
80101ce4:	89 e5                	mov    %esp,%ebp
80101ce6:	83 ec 48             	sub    $0x48,%esp
80101ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cec:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101cf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfa:	89 04 24             	mov    %eax,(%esp)
80101cfd:	e8 fe fc ff ff       	call   80101a00 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101d02:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101d09:	e9 98 00 00 00       	jmp    80101da6 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d11:	c1 e8 03             	shr    $0x3,%eax
80101d14:	83 c0 02             	add    $0x2,%eax
80101d17:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	89 04 24             	mov    %eax,(%esp)
80101d21:	e8 80 e4 ff ff       	call   801001a6 <bread>
80101d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2c:	8d 50 18             	lea    0x18(%eax),%edx
80101d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d32:	83 e0 07             	and    $0x7,%eax
80101d35:	c1 e0 06             	shl    $0x6,%eax
80101d38:	01 d0                	add    %edx,%eax
80101d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d40:	0f b7 00             	movzwl (%eax),%eax
80101d43:	66 85 c0             	test   %ax,%ax
80101d46:	75 4f                	jne    80101d97 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101d48:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101d4f:	00 
80101d50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101d57:	00 
80101d58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d5b:	89 04 24             	mov    %eax,(%esp)
80101d5e:	e8 5b 3a 00 00       	call   801057be <memset>
      dip->type = type;
80101d63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d66:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101d6a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d70:	89 04 24             	mov    %eax,(%esp)
80101d73:	e8 5a 1c 00 00       	call   801039d2 <log_write>
      brelse(bp);
80101d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d7b:	89 04 24             	mov    %eax,(%esp)
80101d7e:	e8 94 e4 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d86:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	89 04 24             	mov    %eax,(%esp)
80101d90:	e8 e3 00 00 00       	call   80101e78 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101d95:	c9                   	leave  
80101d96:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9a:	89 04 24             	mov    %eax,(%esp)
80101d9d:	e8 75 e4 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101da2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101dac:	39 c2                	cmp    %eax,%edx
80101dae:	0f 82 5a ff ff ff    	jb     80101d0e <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101db4:	c7 04 24 bd 8d 10 80 	movl   $0x80108dbd,(%esp)
80101dbb:	e8 7d e7 ff ff       	call   8010053d <panic>

80101dc0 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101dc0:	55                   	push   %ebp
80101dc1:	89 e5                	mov    %esp,%ebp
80101dc3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 40 04             	mov    0x4(%eax),%eax
80101dcc:	c1 e8 03             	shr    $0x3,%eax
80101dcf:	8d 50 02             	lea    0x2(%eax),%edx
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 00                	mov    (%eax),%eax
80101dd7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ddb:	89 04 24             	mov    %eax,(%esp)
80101dde:	e8 c3 e3 ff ff       	call   801001a6 <bread>
80101de3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de9:	8d 50 18             	lea    0x18(%eax),%edx
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	8b 40 04             	mov    0x4(%eax),%eax
80101df2:	83 e0 07             	and    $0x7,%eax
80101df5:	c1 e0 06             	shl    $0x6,%eax
80101df8:	01 d0                	add    %edx,%eax
80101dfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101e00:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e07:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e14:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e22:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101e26:	8b 45 08             	mov    0x8(%ebp),%eax
80101e29:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e30:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	8b 50 18             	mov    0x18(%eax),%edx
80101e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	8d 50 1c             	lea    0x1c(%eax),%edx
80101e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e49:	83 c0 0c             	add    $0xc,%eax
80101e4c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101e53:	00 
80101e54:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e58:	89 04 24             	mov    %eax,(%esp)
80101e5b:	e8 31 3a 00 00       	call   80105891 <memmove>
  log_write(bp);
80101e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e63:	89 04 24             	mov    %eax,(%esp)
80101e66:	e8 67 1b 00 00       	call   801039d2 <log_write>
  brelse(bp);
80101e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6e:	89 04 24             	mov    %eax,(%esp)
80101e71:	e8 a1 e3 ff ff       	call   80100217 <brelse>
}
80101e76:	c9                   	leave  
80101e77:	c3                   	ret    

80101e78 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101e78:	55                   	push   %ebp
80101e79:	89 e5                	mov    %esp,%ebp
80101e7b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101e7e:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101e85:	e8 e5 36 00 00       	call   8010556f <acquire>

  // Is the inode already cached?
  empty = 0;
80101e8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101e91:	c7 45 f4 54 08 11 80 	movl   $0x80110854,-0xc(%ebp)
80101e98:	eb 59                	jmp    80101ef3 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9d:	8b 40 08             	mov    0x8(%eax),%eax
80101ea0:	85 c0                	test   %eax,%eax
80101ea2:	7e 35                	jle    80101ed9 <iget+0x61>
80101ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea7:	8b 00                	mov    (%eax),%eax
80101ea9:	3b 45 08             	cmp    0x8(%ebp),%eax
80101eac:	75 2b                	jne    80101ed9 <iget+0x61>
80101eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb1:	8b 40 04             	mov    0x4(%eax),%eax
80101eb4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101eb7:	75 20                	jne    80101ed9 <iget+0x61>
      ip->ref++;
80101eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebc:	8b 40 08             	mov    0x8(%eax),%eax
80101ebf:	8d 50 01             	lea    0x1(%eax),%edx
80101ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec5:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101ec8:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101ecf:	e8 fd 36 00 00       	call   801055d1 <release>
      return ip;
80101ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed7:	eb 6f                	jmp    80101f48 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101ed9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101edd:	75 10                	jne    80101eef <iget+0x77>
80101edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee2:	8b 40 08             	mov    0x8(%eax),%eax
80101ee5:	85 c0                	test   %eax,%eax
80101ee7:	75 06                	jne    80101eef <iget+0x77>
      empty = ip;
80101ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eec:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101eef:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101ef3:	81 7d f4 f4 17 11 80 	cmpl   $0x801117f4,-0xc(%ebp)
80101efa:	72 9e                	jb     80101e9a <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101efc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101f00:	75 0c                	jne    80101f0e <iget+0x96>
    panic("iget: no inodes");
80101f02:	c7 04 24 cf 8d 10 80 	movl   $0x80108dcf,(%esp)
80101f09:	e8 2f e6 ff ff       	call   8010053d <panic>

  ip = empty;
80101f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f17:	8b 55 08             	mov    0x8(%ebp),%edx
80101f1a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f22:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f32:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101f39:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101f40:	e8 8c 36 00 00       	call   801055d1 <release>

  return ip;
80101f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101f48:	c9                   	leave  
80101f49:	c3                   	ret    

80101f4a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101f4a:	55                   	push   %ebp
80101f4b:	89 e5                	mov    %esp,%ebp
80101f4d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101f50:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101f57:	e8 13 36 00 00       	call   8010556f <acquire>
  ip->ref++;
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	8b 40 08             	mov    0x8(%eax),%eax
80101f62:	8d 50 01             	lea    0x1(%eax),%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f6b:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101f72:	e8 5a 36 00 00       	call   801055d1 <release>
  return ip;
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101f7a:	c9                   	leave  
80101f7b:	c3                   	ret    

80101f7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101f7c:	55                   	push   %ebp
80101f7d:	89 e5                	mov    %esp,%ebp
80101f7f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101f82:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101f86:	74 0a                	je     80101f92 <ilock+0x16>
80101f88:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8b:	8b 40 08             	mov    0x8(%eax),%eax
80101f8e:	85 c0                	test   %eax,%eax
80101f90:	7f 0c                	jg     80101f9e <ilock+0x22>
    panic("ilock");
80101f92:	c7 04 24 df 8d 10 80 	movl   $0x80108ddf,(%esp)
80101f99:	e8 9f e5 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101f9e:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101fa5:	e8 c5 35 00 00       	call   8010556f <acquire>
  while(ip->flags & I_BUSY)
80101faa:	eb 13                	jmp    80101fbf <ilock+0x43>
    sleep(ip, &icache.lock);
80101fac:	c7 44 24 04 20 08 11 	movl   $0x80110820,0x4(%esp)
80101fb3:	80 
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	89 04 24             	mov    %eax,(%esp)
80101fba:	e8 38 32 00 00       	call   801051f7 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	8b 40 0c             	mov    0xc(%eax),%eax
80101fc5:	83 e0 01             	and    $0x1,%eax
80101fc8:	84 c0                	test   %al,%al
80101fca:	75 e0                	jne    80101fac <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcf:	8b 40 0c             	mov    0xc(%eax),%eax
80101fd2:	89 c2                	mov    %eax,%edx
80101fd4:	83 ca 01             	or     $0x1,%edx
80101fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fda:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101fdd:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101fe4:	e8 e8 35 00 00       	call   801055d1 <release>

  if(!(ip->flags & I_VALID)){
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 40 0c             	mov    0xc(%eax),%eax
80101fef:	83 e0 02             	and    $0x2,%eax
80101ff2:	85 c0                	test   %eax,%eax
80101ff4:	0f 85 ce 00 00 00    	jne    801020c8 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffd:	8b 40 04             	mov    0x4(%eax),%eax
80102000:	c1 e8 03             	shr    $0x3,%eax
80102003:	8d 50 02             	lea    0x2(%eax),%edx
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	8b 00                	mov    (%eax),%eax
8010200b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010200f:	89 04 24             	mov    %eax,(%esp)
80102012:	e8 8f e1 ff ff       	call   801001a6 <bread>
80102017:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	8d 50 18             	lea    0x18(%eax),%edx
80102020:	8b 45 08             	mov    0x8(%ebp),%eax
80102023:	8b 40 04             	mov    0x4(%eax),%eax
80102026:	83 e0 07             	and    $0x7,%eax
80102029:	c1 e0 06             	shl    $0x6,%eax
8010202c:	01 d0                	add    %edx,%eax
8010202e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80102031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102034:	0f b7 10             	movzwl (%eax),%edx
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102041:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80102045:	8b 45 08             	mov    0x8(%ebp),%eax
80102048:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010204c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010204f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80102053:	8b 45 08             	mov    0x8(%ebp),%eax
80102056:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010205a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010205d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80102068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010206b:	8b 50 08             	mov    0x8(%eax),%edx
8010206e:	8b 45 08             	mov    0x8(%ebp),%eax
80102071:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102074:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102077:	8d 50 0c             	lea    0xc(%eax),%edx
8010207a:	8b 45 08             	mov    0x8(%ebp),%eax
8010207d:	83 c0 1c             	add    $0x1c,%eax
80102080:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80102087:	00 
80102088:	89 54 24 04          	mov    %edx,0x4(%esp)
8010208c:	89 04 24             	mov    %eax,(%esp)
8010208f:	e8 fd 37 00 00       	call   80105891 <memmove>
    brelse(bp);
80102094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102097:	89 04 24             	mov    %eax,(%esp)
8010209a:	e8 78 e1 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 0c             	mov    0xc(%eax),%eax
801020a5:	89 c2                	mov    %eax,%edx
801020a7:	83 ca 02             	or     $0x2,%edx
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801020b0:	8b 45 08             	mov    0x8(%ebp),%eax
801020b3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020b7:	66 85 c0             	test   %ax,%ax
801020ba:	75 0c                	jne    801020c8 <ilock+0x14c>
      panic("ilock: no type");
801020bc:	c7 04 24 e5 8d 10 80 	movl   $0x80108de5,(%esp)
801020c3:	e8 75 e4 ff ff       	call   8010053d <panic>
  }
}
801020c8:	c9                   	leave  
801020c9:	c3                   	ret    

801020ca <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801020ca:	55                   	push   %ebp
801020cb:	89 e5                	mov    %esp,%ebp
801020cd:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801020d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801020d4:	74 17                	je     801020ed <iunlock+0x23>
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	8b 40 0c             	mov    0xc(%eax),%eax
801020dc:	83 e0 01             	and    $0x1,%eax
801020df:	85 c0                	test   %eax,%eax
801020e1:	74 0a                	je     801020ed <iunlock+0x23>
801020e3:	8b 45 08             	mov    0x8(%ebp),%eax
801020e6:	8b 40 08             	mov    0x8(%eax),%eax
801020e9:	85 c0                	test   %eax,%eax
801020eb:	7f 0c                	jg     801020f9 <iunlock+0x2f>
    panic("iunlock");
801020ed:	c7 04 24 f4 8d 10 80 	movl   $0x80108df4,(%esp)
801020f4:	e8 44 e4 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801020f9:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80102100:	e8 6a 34 00 00       	call   8010556f <acquire>
  ip->flags &= ~I_BUSY;
80102105:	8b 45 08             	mov    0x8(%ebp),%eax
80102108:	8b 40 0c             	mov    0xc(%eax),%eax
8010210b:	89 c2                	mov    %eax,%edx
8010210d:	83 e2 fe             	and    $0xfffffffe,%edx
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	89 04 24             	mov    %eax,(%esp)
8010211c:	e8 44 32 00 00       	call   80105365 <wakeup>
  release(&icache.lock);
80102121:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80102128:	e8 a4 34 00 00       	call   801055d1 <release>
}
8010212d:	c9                   	leave  
8010212e:	c3                   	ret    

8010212f <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
8010212f:	55                   	push   %ebp
80102130:	89 e5                	mov    %esp,%ebp
80102132:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80102135:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
8010213c:	e8 2e 34 00 00       	call   8010556f <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80102141:	8b 45 08             	mov    0x8(%ebp),%eax
80102144:	8b 40 08             	mov    0x8(%eax),%eax
80102147:	83 f8 01             	cmp    $0x1,%eax
8010214a:	0f 85 93 00 00 00    	jne    801021e3 <iput+0xb4>
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 0c             	mov    0xc(%eax),%eax
80102156:	83 e0 02             	and    $0x2,%eax
80102159:	85 c0                	test   %eax,%eax
8010215b:	0f 84 82 00 00 00    	je     801021e3 <iput+0xb4>
80102161:	8b 45 08             	mov    0x8(%ebp),%eax
80102164:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102168:	66 85 c0             	test   %ax,%ax
8010216b:	75 76                	jne    801021e3 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
8010216d:	8b 45 08             	mov    0x8(%ebp),%eax
80102170:	8b 40 0c             	mov    0xc(%eax),%eax
80102173:	83 e0 01             	and    $0x1,%eax
80102176:	84 c0                	test   %al,%al
80102178:	74 0c                	je     80102186 <iput+0x57>
      panic("iput busy");
8010217a:	c7 04 24 fc 8d 10 80 	movl   $0x80108dfc,(%esp)
80102181:	e8 b7 e3 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80102186:	8b 45 08             	mov    0x8(%ebp),%eax
80102189:	8b 40 0c             	mov    0xc(%eax),%eax
8010218c:	89 c2                	mov    %eax,%edx
8010218e:	83 ca 01             	or     $0x1,%edx
80102191:	8b 45 08             	mov    0x8(%ebp),%eax
80102194:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80102197:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
8010219e:	e8 2e 34 00 00       	call   801055d1 <release>
    itrunc(ip);
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	89 04 24             	mov    %eax,(%esp)
801021a9:	e8 72 01 00 00       	call   80102320 <itrunc>
    ip->type = 0;
801021ae:	8b 45 08             	mov    0x8(%ebp),%eax
801021b1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
801021b7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ba:	89 04 24             	mov    %eax,(%esp)
801021bd:	e8 fe fb ff ff       	call   80101dc0 <iupdate>
    acquire(&icache.lock);
801021c2:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
801021c9:	e8 a1 33 00 00       	call   8010556f <acquire>
    ip->flags = 0;
801021ce:	8b 45 08             	mov    0x8(%ebp),%eax
801021d1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	89 04 24             	mov    %eax,(%esp)
801021de:	e8 82 31 00 00       	call   80105365 <wakeup>
  }
  ip->ref--;
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 40 08             	mov    0x8(%eax),%eax
801021e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801021ec:	8b 45 08             	mov    0x8(%ebp),%eax
801021ef:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801021f2:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
801021f9:	e8 d3 33 00 00       	call   801055d1 <release>
}
801021fe:	c9                   	leave  
801021ff:	c3                   	ret    

80102200 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80102200:	55                   	push   %ebp
80102201:	89 e5                	mov    %esp,%ebp
80102203:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80102206:	8b 45 08             	mov    0x8(%ebp),%eax
80102209:	89 04 24             	mov    %eax,(%esp)
8010220c:	e8 b9 fe ff ff       	call   801020ca <iunlock>
  iput(ip);
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	89 04 24             	mov    %eax,(%esp)
80102217:	e8 13 ff ff ff       	call   8010212f <iput>
}
8010221c:	c9                   	leave  
8010221d:	c3                   	ret    

8010221e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
8010221e:	55                   	push   %ebp
8010221f:	89 e5                	mov    %esp,%ebp
80102221:	53                   	push   %ebx
80102222:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80102225:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102229:	77 3e                	ja     80102269 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
8010222b:	8b 45 08             	mov    0x8(%ebp),%eax
8010222e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102231:	83 c2 04             	add    $0x4,%edx
80102234:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102238:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010223b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010223f:	75 20                	jne    80102261 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80102241:	8b 45 08             	mov    0x8(%ebp),%eax
80102244:	8b 00                	mov    (%eax),%eax
80102246:	89 04 24             	mov    %eax,(%esp)
80102249:	e8 49 f8 ff ff       	call   80101a97 <balloc>
8010224e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102251:	8b 45 08             	mov    0x8(%ebp),%eax
80102254:	8b 55 0c             	mov    0xc(%ebp),%edx
80102257:	8d 4a 04             	lea    0x4(%edx),%ecx
8010225a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010225d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80102261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102264:	e9 b1 00 00 00       	jmp    8010231a <bmap+0xfc>
  }
  bn -= NDIRECT;
80102269:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
8010226d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80102271:	0f 87 97 00 00 00    	ja     8010230e <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	8b 40 4c             	mov    0x4c(%eax),%eax
8010227d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102284:	75 19                	jne    8010229f <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80102286:	8b 45 08             	mov    0x8(%ebp),%eax
80102289:	8b 00                	mov    (%eax),%eax
8010228b:	89 04 24             	mov    %eax,(%esp)
8010228e:	e8 04 f8 ff ff       	call   80101a97 <balloc>
80102293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102296:	8b 45 08             	mov    0x8(%ebp),%eax
80102299:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010229c:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	8b 00                	mov    (%eax),%eax
801022a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801022ab:	89 04 24             	mov    %eax,(%esp)
801022ae:	e8 f3 de ff ff       	call   801001a6 <bread>
801022b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
801022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b9:	83 c0 18             	add    $0x18,%eax
801022bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
801022bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c2:	c1 e0 02             	shl    $0x2,%eax
801022c5:	03 45 ec             	add    -0x14(%ebp),%eax
801022c8:	8b 00                	mov    (%eax),%eax
801022ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022d1:	75 2b                	jne    801022fe <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
801022d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d6:	c1 e0 02             	shl    $0x2,%eax
801022d9:	89 c3                	mov    %eax,%ebx
801022db:	03 5d ec             	add    -0x14(%ebp),%ebx
801022de:	8b 45 08             	mov    0x8(%ebp),%eax
801022e1:	8b 00                	mov    (%eax),%eax
801022e3:	89 04 24             	mov    %eax,(%esp)
801022e6:	e8 ac f7 ff ff       	call   80101a97 <balloc>
801022eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f1:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
801022f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022f6:	89 04 24             	mov    %eax,(%esp)
801022f9:	e8 d4 16 00 00       	call   801039d2 <log_write>
    }
    brelse(bp);
801022fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102301:	89 04 24             	mov    %eax,(%esp)
80102304:	e8 0e df ff ff       	call   80100217 <brelse>
    return addr;
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	eb 0c                	jmp    8010231a <bmap+0xfc>
  }

  panic("bmap: out of range");
8010230e:	c7 04 24 06 8e 10 80 	movl   $0x80108e06,(%esp)
80102315:	e8 23 e2 ff ff       	call   8010053d <panic>
}
8010231a:	83 c4 24             	add    $0x24,%esp
8010231d:	5b                   	pop    %ebx
8010231e:	5d                   	pop    %ebp
8010231f:	c3                   	ret    

80102320 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80102326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010232d:	eb 44                	jmp    80102373 <itrunc+0x53>
    if(ip->addrs[i]){
8010232f:	8b 45 08             	mov    0x8(%ebp),%eax
80102332:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102335:	83 c2 04             	add    $0x4,%edx
80102338:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010233c:	85 c0                	test   %eax,%eax
8010233e:	74 2f                	je     8010236f <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80102340:	8b 45 08             	mov    0x8(%ebp),%eax
80102343:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102346:	83 c2 04             	add    $0x4,%edx
80102349:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
8010234d:	8b 45 08             	mov    0x8(%ebp),%eax
80102350:	8b 00                	mov    (%eax),%eax
80102352:	89 54 24 04          	mov    %edx,0x4(%esp)
80102356:	89 04 24             	mov    %eax,(%esp)
80102359:	e8 90 f8 ff ff       	call   80101bee <bfree>
      ip->addrs[i] = 0;
8010235e:	8b 45 08             	mov    0x8(%ebp),%eax
80102361:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102364:	83 c2 04             	add    $0x4,%edx
80102367:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010236e:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010236f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102373:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102377:	7e b6                	jle    8010232f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80102379:	8b 45 08             	mov    0x8(%ebp),%eax
8010237c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010237f:	85 c0                	test   %eax,%eax
80102381:	0f 84 8f 00 00 00    	je     80102416 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	8b 50 4c             	mov    0x4c(%eax),%edx
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	8b 00                	mov    (%eax),%eax
80102392:	89 54 24 04          	mov    %edx,0x4(%esp)
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 08 de ff ff       	call   801001a6 <bread>
8010239e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
801023a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023a4:	83 c0 18             	add    $0x18,%eax
801023a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801023aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801023b1:	eb 2f                	jmp    801023e2 <itrunc+0xc2>
      if(a[j])
801023b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b6:	c1 e0 02             	shl    $0x2,%eax
801023b9:	03 45 e8             	add    -0x18(%ebp),%eax
801023bc:	8b 00                	mov    (%eax),%eax
801023be:	85 c0                	test   %eax,%eax
801023c0:	74 1c                	je     801023de <itrunc+0xbe>
        bfree(ip->dev, a[j]);
801023c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c5:	c1 e0 02             	shl    $0x2,%eax
801023c8:	03 45 e8             	add    -0x18(%ebp),%eax
801023cb:	8b 10                	mov    (%eax),%edx
801023cd:	8b 45 08             	mov    0x8(%ebp),%eax
801023d0:	8b 00                	mov    (%eax),%eax
801023d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801023d6:	89 04 24             	mov    %eax,(%esp)
801023d9:	e8 10 f8 ff ff       	call   80101bee <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
801023de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801023e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e5:	83 f8 7f             	cmp    $0x7f,%eax
801023e8:	76 c9                	jbe    801023b3 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
801023ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023ed:	89 04 24             	mov    %eax,(%esp)
801023f0:	e8 22 de ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801023f5:	8b 45 08             	mov    0x8(%ebp),%eax
801023f8:	8b 50 4c             	mov    0x4c(%eax),%edx
801023fb:	8b 45 08             	mov    0x8(%ebp),%eax
801023fe:	8b 00                	mov    (%eax),%eax
80102400:	89 54 24 04          	mov    %edx,0x4(%esp)
80102404:	89 04 24             	mov    %eax,(%esp)
80102407:	e8 e2 f7 ff ff       	call   80101bee <bfree>
    ip->addrs[NDIRECT] = 0;
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102416:	8b 45 08             	mov    0x8(%ebp),%eax
80102419:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102420:	8b 45 08             	mov    0x8(%ebp),%eax
80102423:	89 04 24             	mov    %eax,(%esp)
80102426:	e8 95 f9 ff ff       	call   80101dc0 <iupdate>
}
8010242b:	c9                   	leave  
8010242c:	c3                   	ret    

8010242d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010242d:	55                   	push   %ebp
8010242e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	8b 00                	mov    (%eax),%eax
80102435:	89 c2                	mov    %eax,%edx
80102437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010243a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	8b 50 04             	mov    0x4(%eax),%edx
80102443:	8b 45 0c             	mov    0xc(%ebp),%eax
80102446:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102449:	8b 45 08             	mov    0x8(%ebp),%eax
8010244c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102450:	8b 45 0c             	mov    0xc(%ebp),%eax
80102453:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102456:	8b 45 08             	mov    0x8(%ebp),%eax
80102459:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010245d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102460:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102464:	8b 45 08             	mov    0x8(%ebp),%eax
80102467:	8b 50 18             	mov    0x18(%eax),%edx
8010246a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010246d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102470:	5d                   	pop    %ebp
80102471:	c3                   	ret    

80102472 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102472:	55                   	push   %ebp
80102473:	89 e5                	mov    %esp,%ebp
80102475:	53                   	push   %ebx
80102476:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102479:	8b 45 08             	mov    0x8(%ebp),%eax
8010247c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102480:	66 83 f8 03          	cmp    $0x3,%ax
80102484:	75 60                	jne    801024e6 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102486:	8b 45 08             	mov    0x8(%ebp),%eax
80102489:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010248d:	66 85 c0             	test   %ax,%ax
80102490:	78 20                	js     801024b2 <readi+0x40>
80102492:	8b 45 08             	mov    0x8(%ebp),%eax
80102495:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102499:	66 83 f8 09          	cmp    $0x9,%ax
8010249d:	7f 13                	jg     801024b2 <readi+0x40>
8010249f:	8b 45 08             	mov    0x8(%ebp),%eax
801024a2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024a6:	98                   	cwtl   
801024a7:	8b 04 c5 c0 07 11 80 	mov    -0x7feef840(,%eax,8),%eax
801024ae:	85 c0                	test   %eax,%eax
801024b0:	75 0a                	jne    801024bc <readi+0x4a>
      return -1;
801024b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024b7:	e9 1b 01 00 00       	jmp    801025d7 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024c3:	98                   	cwtl   
801024c4:	8b 14 c5 c0 07 11 80 	mov    -0x7feef840(,%eax,8),%edx
801024cb:	8b 45 14             	mov    0x14(%ebp),%eax
801024ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801024d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024d9:	8b 45 08             	mov    0x8(%ebp),%eax
801024dc:	89 04 24             	mov    %eax,(%esp)
801024df:	ff d2                	call   *%edx
801024e1:	e9 f1 00 00 00       	jmp    801025d7 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801024e6:	8b 45 08             	mov    0x8(%ebp),%eax
801024e9:	8b 40 18             	mov    0x18(%eax),%eax
801024ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801024ef:	72 0d                	jb     801024fe <readi+0x8c>
801024f1:	8b 45 14             	mov    0x14(%ebp),%eax
801024f4:	8b 55 10             	mov    0x10(%ebp),%edx
801024f7:	01 d0                	add    %edx,%eax
801024f9:	3b 45 10             	cmp    0x10(%ebp),%eax
801024fc:	73 0a                	jae    80102508 <readi+0x96>
    return -1;
801024fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102503:	e9 cf 00 00 00       	jmp    801025d7 <readi+0x165>
  if(off + n > ip->size)
80102508:	8b 45 14             	mov    0x14(%ebp),%eax
8010250b:	8b 55 10             	mov    0x10(%ebp),%edx
8010250e:	01 c2                	add    %eax,%edx
80102510:	8b 45 08             	mov    0x8(%ebp),%eax
80102513:	8b 40 18             	mov    0x18(%eax),%eax
80102516:	39 c2                	cmp    %eax,%edx
80102518:	76 0c                	jbe    80102526 <readi+0xb4>
    n = ip->size - off;
8010251a:	8b 45 08             	mov    0x8(%ebp),%eax
8010251d:	8b 40 18             	mov    0x18(%eax),%eax
80102520:	2b 45 10             	sub    0x10(%ebp),%eax
80102523:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010252d:	e9 96 00 00 00       	jmp    801025c8 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102532:	8b 45 10             	mov    0x10(%ebp),%eax
80102535:	c1 e8 09             	shr    $0x9,%eax
80102538:	89 44 24 04          	mov    %eax,0x4(%esp)
8010253c:	8b 45 08             	mov    0x8(%ebp),%eax
8010253f:	89 04 24             	mov    %eax,(%esp)
80102542:	e8 d7 fc ff ff       	call   8010221e <bmap>
80102547:	8b 55 08             	mov    0x8(%ebp),%edx
8010254a:	8b 12                	mov    (%edx),%edx
8010254c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102550:	89 14 24             	mov    %edx,(%esp)
80102553:	e8 4e dc ff ff       	call   801001a6 <bread>
80102558:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010255b:	8b 45 10             	mov    0x10(%ebp),%eax
8010255e:	89 c2                	mov    %eax,%edx
80102560:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102566:	b8 00 02 00 00       	mov    $0x200,%eax
8010256b:	89 c1                	mov    %eax,%ecx
8010256d:	29 d1                	sub    %edx,%ecx
8010256f:	89 ca                	mov    %ecx,%edx
80102571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102574:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102577:	89 cb                	mov    %ecx,%ebx
80102579:	29 c3                	sub    %eax,%ebx
8010257b:	89 d8                	mov    %ebx,%eax
8010257d:	39 c2                	cmp    %eax,%edx
8010257f:	0f 46 c2             	cmovbe %edx,%eax
80102582:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102588:	8d 50 18             	lea    0x18(%eax),%edx
8010258b:	8b 45 10             	mov    0x10(%ebp),%eax
8010258e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102593:	01 c2                	add    %eax,%edx
80102595:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102598:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259c:	89 54 24 04          	mov    %edx,0x4(%esp)
801025a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a3:	89 04 24             	mov    %eax,(%esp)
801025a6:	e8 e6 32 00 00       	call   80105891 <memmove>
    brelse(bp);
801025ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025ae:	89 04 24             	mov    %eax,(%esp)
801025b1:	e8 61 dc ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801025b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025b9:	01 45 f4             	add    %eax,-0xc(%ebp)
801025bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025bf:	01 45 10             	add    %eax,0x10(%ebp)
801025c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025c5:	01 45 0c             	add    %eax,0xc(%ebp)
801025c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cb:	3b 45 14             	cmp    0x14(%ebp),%eax
801025ce:	0f 82 5e ff ff ff    	jb     80102532 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801025d4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801025d7:	83 c4 24             	add    $0x24,%esp
801025da:	5b                   	pop    %ebx
801025db:	5d                   	pop    %ebp
801025dc:	c3                   	ret    

801025dd <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801025dd:	55                   	push   %ebp
801025de:	89 e5                	mov    %esp,%ebp
801025e0:	53                   	push   %ebx
801025e1:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801025e4:	8b 45 08             	mov    0x8(%ebp),%eax
801025e7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025eb:	66 83 f8 03          	cmp    $0x3,%ax
801025ef:	75 60                	jne    80102651 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801025f1:	8b 45 08             	mov    0x8(%ebp),%eax
801025f4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025f8:	66 85 c0             	test   %ax,%ax
801025fb:	78 20                	js     8010261d <writei+0x40>
801025fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102600:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102604:	66 83 f8 09          	cmp    $0x9,%ax
80102608:	7f 13                	jg     8010261d <writei+0x40>
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
8010260d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102611:	98                   	cwtl   
80102612:	8b 04 c5 c4 07 11 80 	mov    -0x7feef83c(,%eax,8),%eax
80102619:	85 c0                	test   %eax,%eax
8010261b:	75 0a                	jne    80102627 <writei+0x4a>
      return -1;
8010261d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102622:	e9 46 01 00 00       	jmp    8010276d <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102627:	8b 45 08             	mov    0x8(%ebp),%eax
8010262a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010262e:	98                   	cwtl   
8010262f:	8b 14 c5 c4 07 11 80 	mov    -0x7feef83c(,%eax,8),%edx
80102636:	8b 45 14             	mov    0x14(%ebp),%eax
80102639:	89 44 24 08          	mov    %eax,0x8(%esp)
8010263d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102640:	89 44 24 04          	mov    %eax,0x4(%esp)
80102644:	8b 45 08             	mov    0x8(%ebp),%eax
80102647:	89 04 24             	mov    %eax,(%esp)
8010264a:	ff d2                	call   *%edx
8010264c:	e9 1c 01 00 00       	jmp    8010276d <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102651:	8b 45 08             	mov    0x8(%ebp),%eax
80102654:	8b 40 18             	mov    0x18(%eax),%eax
80102657:	3b 45 10             	cmp    0x10(%ebp),%eax
8010265a:	72 0d                	jb     80102669 <writei+0x8c>
8010265c:	8b 45 14             	mov    0x14(%ebp),%eax
8010265f:	8b 55 10             	mov    0x10(%ebp),%edx
80102662:	01 d0                	add    %edx,%eax
80102664:	3b 45 10             	cmp    0x10(%ebp),%eax
80102667:	73 0a                	jae    80102673 <writei+0x96>
    return -1;
80102669:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010266e:	e9 fa 00 00 00       	jmp    8010276d <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80102673:	8b 45 14             	mov    0x14(%ebp),%eax
80102676:	8b 55 10             	mov    0x10(%ebp),%edx
80102679:	01 d0                	add    %edx,%eax
8010267b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102680:	76 0a                	jbe    8010268c <writei+0xaf>
    return -1;
80102682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102687:	e9 e1 00 00 00       	jmp    8010276d <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010268c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102693:	e9 a1 00 00 00       	jmp    80102739 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102698:	8b 45 10             	mov    0x10(%ebp),%eax
8010269b:	c1 e8 09             	shr    $0x9,%eax
8010269e:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a2:	8b 45 08             	mov    0x8(%ebp),%eax
801026a5:	89 04 24             	mov    %eax,(%esp)
801026a8:	e8 71 fb ff ff       	call   8010221e <bmap>
801026ad:	8b 55 08             	mov    0x8(%ebp),%edx
801026b0:	8b 12                	mov    (%edx),%edx
801026b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b6:	89 14 24             	mov    %edx,(%esp)
801026b9:	e8 e8 da ff ff       	call   801001a6 <bread>
801026be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801026c1:	8b 45 10             	mov    0x10(%ebp),%eax
801026c4:	89 c2                	mov    %eax,%edx
801026c6:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801026cc:	b8 00 02 00 00       	mov    $0x200,%eax
801026d1:	89 c1                	mov    %eax,%ecx
801026d3:	29 d1                	sub    %edx,%ecx
801026d5:	89 ca                	mov    %ecx,%edx
801026d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026da:	8b 4d 14             	mov    0x14(%ebp),%ecx
801026dd:	89 cb                	mov    %ecx,%ebx
801026df:	29 c3                	sub    %eax,%ebx
801026e1:	89 d8                	mov    %ebx,%eax
801026e3:	39 c2                	cmp    %eax,%edx
801026e5:	0f 46 c2             	cmovbe %edx,%eax
801026e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801026eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026ee:	8d 50 18             	lea    0x18(%eax),%edx
801026f1:	8b 45 10             	mov    0x10(%ebp),%eax
801026f4:	25 ff 01 00 00       	and    $0x1ff,%eax
801026f9:	01 c2                	add    %eax,%edx
801026fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80102702:	8b 45 0c             	mov    0xc(%ebp),%eax
80102705:	89 44 24 04          	mov    %eax,0x4(%esp)
80102709:	89 14 24             	mov    %edx,(%esp)
8010270c:	e8 80 31 00 00       	call   80105891 <memmove>
    log_write(bp);
80102711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102714:	89 04 24             	mov    %eax,(%esp)
80102717:	e8 b6 12 00 00       	call   801039d2 <log_write>
    brelse(bp);
8010271c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010271f:	89 04 24             	mov    %eax,(%esp)
80102722:	e8 f0 da ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010272a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010272d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102730:	01 45 10             	add    %eax,0x10(%ebp)
80102733:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102736:	01 45 0c             	add    %eax,0xc(%ebp)
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010273f:	0f 82 53 ff ff ff    	jb     80102698 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102745:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102749:	74 1f                	je     8010276a <writei+0x18d>
8010274b:	8b 45 08             	mov    0x8(%ebp),%eax
8010274e:	8b 40 18             	mov    0x18(%eax),%eax
80102751:	3b 45 10             	cmp    0x10(%ebp),%eax
80102754:	73 14                	jae    8010276a <writei+0x18d>
    ip->size = off;
80102756:	8b 45 08             	mov    0x8(%ebp),%eax
80102759:	8b 55 10             	mov    0x10(%ebp),%edx
8010275c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010275f:	8b 45 08             	mov    0x8(%ebp),%eax
80102762:	89 04 24             	mov    %eax,(%esp)
80102765:	e8 56 f6 ff ff       	call   80101dc0 <iupdate>
  }
  return n;
8010276a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010276d:	83 c4 24             	add    $0x24,%esp
80102770:	5b                   	pop    %ebx
80102771:	5d                   	pop    %ebp
80102772:	c3                   	ret    

80102773 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102773:	55                   	push   %ebp
80102774:	89 e5                	mov    %esp,%ebp
80102776:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102779:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102780:	00 
80102781:	8b 45 0c             	mov    0xc(%ebp),%eax
80102784:	89 44 24 04          	mov    %eax,0x4(%esp)
80102788:	8b 45 08             	mov    0x8(%ebp),%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 a2 31 00 00       	call   80105935 <strncmp>
}
80102793:	c9                   	leave  
80102794:	c3                   	ret    

80102795 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102795:	55                   	push   %ebp
80102796:	89 e5                	mov    %esp,%ebp
80102798:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010279b:	8b 45 08             	mov    0x8(%ebp),%eax
8010279e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027a2:	66 83 f8 01          	cmp    $0x1,%ax
801027a6:	74 0c                	je     801027b4 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801027a8:	c7 04 24 19 8e 10 80 	movl   $0x80108e19,(%esp)
801027af:	e8 89 dd ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801027b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027bb:	e9 87 00 00 00       	jmp    80102847 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801027c0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801027c7:	00 
801027c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801027cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801027d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801027d6:	8b 45 08             	mov    0x8(%ebp),%eax
801027d9:	89 04 24             	mov    %eax,(%esp)
801027dc:	e8 91 fc ff ff       	call   80102472 <readi>
801027e1:	83 f8 10             	cmp    $0x10,%eax
801027e4:	74 0c                	je     801027f2 <dirlookup+0x5d>
      panic("dirlink read");
801027e6:	c7 04 24 2b 8e 10 80 	movl   $0x80108e2b,(%esp)
801027ed:	e8 4b dd ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801027f2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801027f6:	66 85 c0             	test   %ax,%ax
801027f9:	74 47                	je     80102842 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801027fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801027fe:	83 c0 02             	add    $0x2,%eax
80102801:	89 44 24 04          	mov    %eax,0x4(%esp)
80102805:	8b 45 0c             	mov    0xc(%ebp),%eax
80102808:	89 04 24             	mov    %eax,(%esp)
8010280b:	e8 63 ff ff ff       	call   80102773 <namecmp>
80102810:	85 c0                	test   %eax,%eax
80102812:	75 2f                	jne    80102843 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102814:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102818:	74 08                	je     80102822 <dirlookup+0x8d>
        *poff = off;
8010281a:	8b 45 10             	mov    0x10(%ebp),%eax
8010281d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102820:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102822:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102826:	0f b7 c0             	movzwl %ax,%eax
80102829:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010282c:	8b 45 08             	mov    0x8(%ebp),%eax
8010282f:	8b 00                	mov    (%eax),%eax
80102831:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102834:	89 54 24 04          	mov    %edx,0x4(%esp)
80102838:	89 04 24             	mov    %eax,(%esp)
8010283b:	e8 38 f6 ff ff       	call   80101e78 <iget>
80102840:	eb 19                	jmp    8010285b <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102842:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102843:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102847:	8b 45 08             	mov    0x8(%ebp),%eax
8010284a:	8b 40 18             	mov    0x18(%eax),%eax
8010284d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102850:	0f 87 6a ff ff ff    	ja     801027c0 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102856:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010285b:	c9                   	leave  
8010285c:	c3                   	ret    

8010285d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010285d:	55                   	push   %ebp
8010285e:	89 e5                	mov    %esp,%ebp
80102860:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102863:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010286a:	00 
8010286b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010286e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102872:	8b 45 08             	mov    0x8(%ebp),%eax
80102875:	89 04 24             	mov    %eax,(%esp)
80102878:	e8 18 ff ff ff       	call   80102795 <dirlookup>
8010287d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102880:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102884:	74 15                	je     8010289b <dirlink+0x3e>
    iput(ip);
80102886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102889:	89 04 24             	mov    %eax,(%esp)
8010288c:	e8 9e f8 ff ff       	call   8010212f <iput>
    return -1;
80102891:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102896:	e9 b8 00 00 00       	jmp    80102953 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010289b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028a2:	eb 44                	jmp    801028e8 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801028a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801028ae:	00 
801028af:	89 44 24 08          	mov    %eax,0x8(%esp)
801028b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801028b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ba:	8b 45 08             	mov    0x8(%ebp),%eax
801028bd:	89 04 24             	mov    %eax,(%esp)
801028c0:	e8 ad fb ff ff       	call   80102472 <readi>
801028c5:	83 f8 10             	cmp    $0x10,%eax
801028c8:	74 0c                	je     801028d6 <dirlink+0x79>
      panic("dirlink read");
801028ca:	c7 04 24 2b 8e 10 80 	movl   $0x80108e2b,(%esp)
801028d1:	e8 67 dc ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801028d6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028da:	66 85 c0             	test   %ax,%ax
801028dd:	74 18                	je     801028f7 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801028df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e2:	83 c0 10             	add    $0x10,%eax
801028e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028eb:	8b 45 08             	mov    0x8(%ebp),%eax
801028ee:	8b 40 18             	mov    0x18(%eax),%eax
801028f1:	39 c2                	cmp    %eax,%edx
801028f3:	72 af                	jb     801028a4 <dirlink+0x47>
801028f5:	eb 01                	jmp    801028f8 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801028f7:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801028f8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801028ff:	00 
80102900:	8b 45 0c             	mov    0xc(%ebp),%eax
80102903:	89 44 24 04          	mov    %eax,0x4(%esp)
80102907:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010290a:	83 c0 02             	add    $0x2,%eax
8010290d:	89 04 24             	mov    %eax,(%esp)
80102910:	e8 78 30 00 00       	call   8010598d <strncpy>
  de.inum = inum;
80102915:	8b 45 10             	mov    0x10(%ebp),%eax
80102918:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010291c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102926:	00 
80102927:	89 44 24 08          	mov    %eax,0x8(%esp)
8010292b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010292e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102932:	8b 45 08             	mov    0x8(%ebp),%eax
80102935:	89 04 24             	mov    %eax,(%esp)
80102938:	e8 a0 fc ff ff       	call   801025dd <writei>
8010293d:	83 f8 10             	cmp    $0x10,%eax
80102940:	74 0c                	je     8010294e <dirlink+0xf1>
    panic("dirlink");
80102942:	c7 04 24 38 8e 10 80 	movl   $0x80108e38,(%esp)
80102949:	e8 ef db ff ff       	call   8010053d <panic>
  
  return 0;
8010294e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102953:	c9                   	leave  
80102954:	c3                   	ret    

80102955 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102955:	55                   	push   %ebp
80102956:	89 e5                	mov    %esp,%ebp
80102958:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010295b:	eb 04                	jmp    80102961 <skipelem+0xc>
    path++;
8010295d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102961:	8b 45 08             	mov    0x8(%ebp),%eax
80102964:	0f b6 00             	movzbl (%eax),%eax
80102967:	3c 2f                	cmp    $0x2f,%al
80102969:	74 f2                	je     8010295d <skipelem+0x8>
    path++;
  if(*path == 0)
8010296b:	8b 45 08             	mov    0x8(%ebp),%eax
8010296e:	0f b6 00             	movzbl (%eax),%eax
80102971:	84 c0                	test   %al,%al
80102973:	75 0a                	jne    8010297f <skipelem+0x2a>
    return 0;
80102975:	b8 00 00 00 00       	mov    $0x0,%eax
8010297a:	e9 86 00 00 00       	jmp    80102a05 <skipelem+0xb0>
  s = path;
8010297f:	8b 45 08             	mov    0x8(%ebp),%eax
80102982:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102985:	eb 04                	jmp    8010298b <skipelem+0x36>
    path++;
80102987:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010298b:	8b 45 08             	mov    0x8(%ebp),%eax
8010298e:	0f b6 00             	movzbl (%eax),%eax
80102991:	3c 2f                	cmp    $0x2f,%al
80102993:	74 0a                	je     8010299f <skipelem+0x4a>
80102995:	8b 45 08             	mov    0x8(%ebp),%eax
80102998:	0f b6 00             	movzbl (%eax),%eax
8010299b:	84 c0                	test   %al,%al
8010299d:	75 e8                	jne    80102987 <skipelem+0x32>
    path++;
  len = path - s;
8010299f:	8b 55 08             	mov    0x8(%ebp),%edx
801029a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a5:	89 d1                	mov    %edx,%ecx
801029a7:	29 c1                	sub    %eax,%ecx
801029a9:	89 c8                	mov    %ecx,%eax
801029ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801029ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801029b2:	7e 1c                	jle    801029d0 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801029b4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801029bb:	00 
801029bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c6:	89 04 24             	mov    %eax,(%esp)
801029c9:	e8 c3 2e 00 00       	call   80105891 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801029ce:	eb 28                	jmp    801029f8 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801029d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801029d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029da:	89 44 24 04          	mov    %eax,0x4(%esp)
801029de:	8b 45 0c             	mov    0xc(%ebp),%eax
801029e1:	89 04 24             	mov    %eax,(%esp)
801029e4:	e8 a8 2e 00 00       	call   80105891 <memmove>
    name[len] = 0;
801029e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029ec:	03 45 0c             	add    0xc(%ebp),%eax
801029ef:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801029f2:	eb 04                	jmp    801029f8 <skipelem+0xa3>
    path++;
801029f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801029f8:	8b 45 08             	mov    0x8(%ebp),%eax
801029fb:	0f b6 00             	movzbl (%eax),%eax
801029fe:	3c 2f                	cmp    $0x2f,%al
80102a00:	74 f2                	je     801029f4 <skipelem+0x9f>
    path++;
  return path;
80102a02:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102a05:	c9                   	leave  
80102a06:	c3                   	ret    

80102a07 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102a07:	55                   	push   %ebp
80102a08:	89 e5                	mov    %esp,%ebp
80102a0a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a10:	0f b6 00             	movzbl (%eax),%eax
80102a13:	3c 2f                	cmp    $0x2f,%al
80102a15:	75 1c                	jne    80102a33 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102a17:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a1e:	00 
80102a1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a26:	e8 4d f4 ff ff       	call   80101e78 <iget>
80102a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102a2e:	e9 af 00 00 00       	jmp    80102ae2 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102a33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102a39:	8b 40 68             	mov    0x68(%eax),%eax
80102a3c:	89 04 24             	mov    %eax,(%esp)
80102a3f:	e8 06 f5 ff ff       	call   80101f4a <idup>
80102a44:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102a47:	e9 96 00 00 00       	jmp    80102ae2 <namex+0xdb>
    ilock(ip);
80102a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4f:	89 04 24             	mov    %eax,(%esp)
80102a52:	e8 25 f5 ff ff       	call   80101f7c <ilock>
    if(ip->type != T_DIR){
80102a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a5e:	66 83 f8 01          	cmp    $0x1,%ax
80102a62:	74 15                	je     80102a79 <namex+0x72>
      iunlockput(ip);
80102a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 91 f7 ff ff       	call   80102200 <iunlockput>
      return 0;
80102a6f:	b8 00 00 00 00       	mov    $0x0,%eax
80102a74:	e9 a3 00 00 00       	jmp    80102b1c <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102a79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102a7d:	74 1d                	je     80102a9c <namex+0x95>
80102a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a82:	0f b6 00             	movzbl (%eax),%eax
80102a85:	84 c0                	test   %al,%al
80102a87:	75 13                	jne    80102a9c <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 36 f6 ff ff       	call   801020ca <iunlock>
      return ip;
80102a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a97:	e9 80 00 00 00       	jmp    80102b1c <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102a9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102aa3:	00 
80102aa4:	8b 45 10             	mov    0x10(%ebp),%eax
80102aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aae:	89 04 24             	mov    %eax,(%esp)
80102ab1:	e8 df fc ff ff       	call   80102795 <dirlookup>
80102ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102ab9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102abd:	75 12                	jne    80102ad1 <namex+0xca>
      iunlockput(ip);
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	89 04 24             	mov    %eax,(%esp)
80102ac5:	e8 36 f7 ff ff       	call   80102200 <iunlockput>
      return 0;
80102aca:	b8 00 00 00 00       	mov    $0x0,%eax
80102acf:	eb 4b                	jmp    80102b1c <namex+0x115>
    }
    iunlockput(ip);
80102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad4:	89 04 24             	mov    %eax,(%esp)
80102ad7:	e8 24 f7 ff ff       	call   80102200 <iunlockput>
    ip = next;
80102adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102ae2:	8b 45 10             	mov    0x10(%ebp),%eax
80102ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80102aec:	89 04 24             	mov    %eax,(%esp)
80102aef:	e8 61 fe ff ff       	call   80102955 <skipelem>
80102af4:	89 45 08             	mov    %eax,0x8(%ebp)
80102af7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102afb:	0f 85 4b ff ff ff    	jne    80102a4c <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102b05:	74 12                	je     80102b19 <namex+0x112>
    iput(ip);
80102b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0a:	89 04 24             	mov    %eax,(%esp)
80102b0d:	e8 1d f6 ff ff       	call   8010212f <iput>
    return 0;
80102b12:	b8 00 00 00 00       	mov    $0x0,%eax
80102b17:	eb 03                	jmp    80102b1c <namex+0x115>
  }
  return ip;
80102b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b1c:	c9                   	leave  
80102b1d:	c3                   	ret    

80102b1e <namei>:

struct inode*
namei(char *path)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
80102b21:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102b24:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102b27:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b32:	00 
80102b33:	8b 45 08             	mov    0x8(%ebp),%eax
80102b36:	89 04 24             	mov    %eax,(%esp)
80102b39:	e8 c9 fe ff ff       	call   80102a07 <namex>
}
80102b3e:	c9                   	leave  
80102b3f:	c3                   	ret    

80102b40 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102b40:	55                   	push   %ebp
80102b41:	89 e5                	mov    %esp,%ebp
80102b43:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102b46:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b49:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b54:	00 
80102b55:	8b 45 08             	mov    0x8(%ebp),%eax
80102b58:	89 04 24             	mov    %eax,(%esp)
80102b5b:	e8 a7 fe ff ff       	call   80102a07 <namex>
}
80102b60:	c9                   	leave  
80102b61:	c3                   	ret    
	...

80102b64 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b64:	55                   	push   %ebp
80102b65:	89 e5                	mov    %esp,%ebp
80102b67:	53                   	push   %ebx
80102b68:	83 ec 14             	sub    $0x14,%esp
80102b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b72:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b76:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b7a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b7e:	ec                   	in     (%dx),%al
80102b7f:	89 c3                	mov    %eax,%ebx
80102b81:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b84:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b88:	83 c4 14             	add    $0x14,%esp
80102b8b:	5b                   	pop    %ebx
80102b8c:	5d                   	pop    %ebp
80102b8d:	c3                   	ret    

80102b8e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102b8e:	55                   	push   %ebp
80102b8f:	89 e5                	mov    %esp,%ebp
80102b91:	57                   	push   %edi
80102b92:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102b93:	8b 55 08             	mov    0x8(%ebp),%edx
80102b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102b99:	8b 45 10             	mov    0x10(%ebp),%eax
80102b9c:	89 cb                	mov    %ecx,%ebx
80102b9e:	89 df                	mov    %ebx,%edi
80102ba0:	89 c1                	mov    %eax,%ecx
80102ba2:	fc                   	cld    
80102ba3:	f3 6d                	rep insl (%dx),%es:(%edi)
80102ba5:	89 c8                	mov    %ecx,%eax
80102ba7:	89 fb                	mov    %edi,%ebx
80102ba9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102bac:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102baf:	5b                   	pop    %ebx
80102bb0:	5f                   	pop    %edi
80102bb1:	5d                   	pop    %ebp
80102bb2:	c3                   	ret    

80102bb3 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102bb3:	55                   	push   %ebp
80102bb4:	89 e5                	mov    %esp,%ebp
80102bb6:	83 ec 08             	sub    $0x8,%esp
80102bb9:	8b 55 08             	mov    0x8(%ebp),%edx
80102bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bbf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102bc3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102bca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102bce:	ee                   	out    %al,(%dx)
}
80102bcf:	c9                   	leave  
80102bd0:	c3                   	ret    

80102bd1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102bd1:	55                   	push   %ebp
80102bd2:	89 e5                	mov    %esp,%ebp
80102bd4:	56                   	push   %esi
80102bd5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102bd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102bdc:	8b 45 10             	mov    0x10(%ebp),%eax
80102bdf:	89 cb                	mov    %ecx,%ebx
80102be1:	89 de                	mov    %ebx,%esi
80102be3:	89 c1                	mov    %eax,%ecx
80102be5:	fc                   	cld    
80102be6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102be8:	89 c8                	mov    %ecx,%eax
80102bea:	89 f3                	mov    %esi,%ebx
80102bec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102bef:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102bf2:	5b                   	pop    %ebx
80102bf3:	5e                   	pop    %esi
80102bf4:	5d                   	pop    %ebp
80102bf5:	c3                   	ret    

80102bf6 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102bf6:	55                   	push   %ebp
80102bf7:	89 e5                	mov    %esp,%ebp
80102bf9:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102bfc:	90                   	nop
80102bfd:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102c04:	e8 5b ff ff ff       	call   80102b64 <inb>
80102c09:	0f b6 c0             	movzbl %al,%eax
80102c0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102c0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c12:	25 c0 00 00 00       	and    $0xc0,%eax
80102c17:	83 f8 40             	cmp    $0x40,%eax
80102c1a:	75 e1                	jne    80102bfd <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102c1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c20:	74 11                	je     80102c33 <idewait+0x3d>
80102c22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c25:	83 e0 21             	and    $0x21,%eax
80102c28:	85 c0                	test   %eax,%eax
80102c2a:	74 07                	je     80102c33 <idewait+0x3d>
    return -1;
80102c2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c31:	eb 05                	jmp    80102c38 <idewait+0x42>
  return 0;
80102c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c38:	c9                   	leave  
80102c39:	c3                   	ret    

80102c3a <ideinit>:

void
ideinit(void)
{
80102c3a:	55                   	push   %ebp
80102c3b:	89 e5                	mov    %esp,%ebp
80102c3d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102c40:	c7 44 24 04 40 8e 10 	movl   $0x80108e40,0x4(%esp)
80102c47:	80 
80102c48:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102c4f:	e8 fa 28 00 00       	call   8010554e <initlock>
  picenable(IRQ_IDE);
80102c54:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102c5b:	e8 75 15 00 00       	call   801041d5 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102c60:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80102c65:	83 e8 01             	sub    $0x1,%eax
80102c68:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c6c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102c73:	e8 12 04 00 00       	call   8010308a <ioapicenable>
  idewait(0);
80102c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c7f:	e8 72 ff ff ff       	call   80102bf6 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102c84:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102c8b:	00 
80102c8c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102c93:	e8 1b ff ff ff       	call   80102bb3 <outb>
  for(i=0; i<1000; i++){
80102c98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c9f:	eb 20                	jmp    80102cc1 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102ca1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102ca8:	e8 b7 fe ff ff       	call   80102b64 <inb>
80102cad:	84 c0                	test   %al,%al
80102caf:	74 0c                	je     80102cbd <ideinit+0x83>
      havedisk1 = 1;
80102cb1:	c7 05 f8 d5 10 80 01 	movl   $0x1,0x8010d5f8
80102cb8:	00 00 00 
      break;
80102cbb:	eb 0d                	jmp    80102cca <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102cbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cc1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102cc8:	7e d7                	jle    80102ca1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102cca:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102cd1:	00 
80102cd2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102cd9:	e8 d5 fe ff ff       	call   80102bb3 <outb>
}
80102cde:	c9                   	leave  
80102cdf:	c3                   	ret    

80102ce0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102ce0:	55                   	push   %ebp
80102ce1:	89 e5                	mov    %esp,%ebp
80102ce3:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ce6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cea:	75 0c                	jne    80102cf8 <idestart+0x18>
    panic("idestart");
80102cec:	c7 04 24 44 8e 10 80 	movl   $0x80108e44,(%esp)
80102cf3:	e8 45 d8 ff ff       	call   8010053d <panic>

  idewait(0);
80102cf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102cff:	e8 f2 fe ff ff       	call   80102bf6 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102d04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d0b:	00 
80102d0c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102d13:	e8 9b fe ff ff       	call   80102bb3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102d18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d1f:	00 
80102d20:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102d27:	e8 87 fe ff ff       	call   80102bb3 <outb>
  outb(0x1f3, b->sector & 0xff);
80102d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d2f:	8b 40 08             	mov    0x8(%eax),%eax
80102d32:	0f b6 c0             	movzbl %al,%eax
80102d35:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d39:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102d40:	e8 6e fe ff ff       	call   80102bb3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102d45:	8b 45 08             	mov    0x8(%ebp),%eax
80102d48:	8b 40 08             	mov    0x8(%eax),%eax
80102d4b:	c1 e8 08             	shr    $0x8,%eax
80102d4e:	0f b6 c0             	movzbl %al,%eax
80102d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d55:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102d5c:	e8 52 fe ff ff       	call   80102bb3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102d61:	8b 45 08             	mov    0x8(%ebp),%eax
80102d64:	8b 40 08             	mov    0x8(%eax),%eax
80102d67:	c1 e8 10             	shr    $0x10,%eax
80102d6a:	0f b6 c0             	movzbl %al,%eax
80102d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d71:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102d78:	e8 36 fe ff ff       	call   80102bb3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d80:	8b 40 04             	mov    0x4(%eax),%eax
80102d83:	83 e0 01             	and    $0x1,%eax
80102d86:	89 c2                	mov    %eax,%edx
80102d88:	c1 e2 04             	shl    $0x4,%edx
80102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8e:	8b 40 08             	mov    0x8(%eax),%eax
80102d91:	c1 e8 18             	shr    $0x18,%eax
80102d94:	83 e0 0f             	and    $0xf,%eax
80102d97:	09 d0                	or     %edx,%eax
80102d99:	83 c8 e0             	or     $0xffffffe0,%eax
80102d9c:	0f b6 c0             	movzbl %al,%eax
80102d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102da3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102daa:	e8 04 fe ff ff       	call   80102bb3 <outb>
  if(b->flags & B_DIRTY){
80102daf:	8b 45 08             	mov    0x8(%ebp),%eax
80102db2:	8b 00                	mov    (%eax),%eax
80102db4:	83 e0 04             	and    $0x4,%eax
80102db7:	85 c0                	test   %eax,%eax
80102db9:	74 34                	je     80102def <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102dbb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102dc2:	00 
80102dc3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102dca:	e8 e4 fd ff ff       	call   80102bb3 <outb>
    outsl(0x1f0, b->data, 512/4);
80102dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd2:	83 c0 18             	add    $0x18,%eax
80102dd5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102ddc:	00 
80102ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102de1:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102de8:	e8 e4 fd ff ff       	call   80102bd1 <outsl>
80102ded:	eb 14                	jmp    80102e03 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102def:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102df6:	00 
80102df7:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102dfe:	e8 b0 fd ff ff       	call   80102bb3 <outb>
  }
}
80102e03:	c9                   	leave  
80102e04:	c3                   	ret    

80102e05 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102e05:	55                   	push   %ebp
80102e06:	89 e5                	mov    %esp,%ebp
80102e08:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102e0b:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102e12:	e8 58 27 00 00       	call   8010556f <acquire>
  if((b = idequeue) == 0){
80102e17:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80102e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102e1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e23:	75 11                	jne    80102e36 <ideintr+0x31>
    release(&idelock);
80102e25:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102e2c:	e8 a0 27 00 00       	call   801055d1 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102e31:	e9 90 00 00 00       	jmp    80102ec6 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e39:	8b 40 14             	mov    0x14(%eax),%eax
80102e3c:	a3 f4 d5 10 80       	mov    %eax,0x8010d5f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e44:	8b 00                	mov    (%eax),%eax
80102e46:	83 e0 04             	and    $0x4,%eax
80102e49:	85 c0                	test   %eax,%eax
80102e4b:	75 2e                	jne    80102e7b <ideintr+0x76>
80102e4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e54:	e8 9d fd ff ff       	call   80102bf6 <idewait>
80102e59:	85 c0                	test   %eax,%eax
80102e5b:	78 1e                	js     80102e7b <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e60:	83 c0 18             	add    $0x18,%eax
80102e63:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102e6a:	00 
80102e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e6f:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102e76:	e8 13 fd ff ff       	call   80102b8e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7e:	8b 00                	mov    (%eax),%eax
80102e80:	89 c2                	mov    %eax,%edx
80102e82:	83 ca 02             	or     $0x2,%edx
80102e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e88:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8d:	8b 00                	mov    (%eax),%eax
80102e8f:	89 c2                	mov    %eax,%edx
80102e91:	83 e2 fb             	and    $0xfffffffb,%edx
80102e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e97:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9c:	89 04 24             	mov    %eax,(%esp)
80102e9f:	e8 c1 24 00 00       	call   80105365 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ea4:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80102ea9:	85 c0                	test   %eax,%eax
80102eab:	74 0d                	je     80102eba <ideintr+0xb5>
    idestart(idequeue);
80102ead:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80102eb2:	89 04 24             	mov    %eax,(%esp)
80102eb5:	e8 26 fe ff ff       	call   80102ce0 <idestart>

  release(&idelock);
80102eba:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102ec1:	e8 0b 27 00 00       	call   801055d1 <release>
}
80102ec6:	c9                   	leave  
80102ec7:	c3                   	ret    

80102ec8 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ec8:	55                   	push   %ebp
80102ec9:	89 e5                	mov    %esp,%ebp
80102ecb:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102ece:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed1:	8b 00                	mov    (%eax),%eax
80102ed3:	83 e0 01             	and    $0x1,%eax
80102ed6:	85 c0                	test   %eax,%eax
80102ed8:	75 0c                	jne    80102ee6 <iderw+0x1e>
    panic("iderw: buf not busy");
80102eda:	c7 04 24 4d 8e 10 80 	movl   $0x80108e4d,(%esp)
80102ee1:	e8 57 d6 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee9:	8b 00                	mov    (%eax),%eax
80102eeb:	83 e0 06             	and    $0x6,%eax
80102eee:	83 f8 02             	cmp    $0x2,%eax
80102ef1:	75 0c                	jne    80102eff <iderw+0x37>
    panic("iderw: nothing to do");
80102ef3:	c7 04 24 61 8e 10 80 	movl   $0x80108e61,(%esp)
80102efa:	e8 3e d6 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102eff:	8b 45 08             	mov    0x8(%ebp),%eax
80102f02:	8b 40 04             	mov    0x4(%eax),%eax
80102f05:	85 c0                	test   %eax,%eax
80102f07:	74 15                	je     80102f1e <iderw+0x56>
80102f09:	a1 f8 d5 10 80       	mov    0x8010d5f8,%eax
80102f0e:	85 c0                	test   %eax,%eax
80102f10:	75 0c                	jne    80102f1e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102f12:	c7 04 24 76 8e 10 80 	movl   $0x80108e76,(%esp)
80102f19:	e8 1f d6 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102f1e:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102f25:	e8 45 26 00 00       	call   8010556f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102f34:	c7 45 f4 f4 d5 10 80 	movl   $0x8010d5f4,-0xc(%ebp)
80102f3b:	eb 0b                	jmp    80102f48 <iderw+0x80>
80102f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f40:	8b 00                	mov    (%eax),%eax
80102f42:	83 c0 14             	add    $0x14,%eax
80102f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f4b:	8b 00                	mov    (%eax),%eax
80102f4d:	85 c0                	test   %eax,%eax
80102f4f:	75 ec                	jne    80102f3d <iderw+0x75>
    ;
  *pp = b;
80102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f54:	8b 55 08             	mov    0x8(%ebp),%edx
80102f57:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102f59:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80102f5e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102f61:	75 22                	jne    80102f85 <iderw+0xbd>
    idestart(b);
80102f63:	8b 45 08             	mov    0x8(%ebp),%eax
80102f66:	89 04 24             	mov    %eax,(%esp)
80102f69:	e8 72 fd ff ff       	call   80102ce0 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102f6e:	eb 15                	jmp    80102f85 <iderw+0xbd>
    sleep(b, &idelock);
80102f70:	c7 44 24 04 c0 d5 10 	movl   $0x8010d5c0,0x4(%esp)
80102f77:	80 
80102f78:	8b 45 08             	mov    0x8(%ebp),%eax
80102f7b:	89 04 24             	mov    %eax,(%esp)
80102f7e:	e8 74 22 00 00       	call   801051f7 <sleep>
80102f83:	eb 01                	jmp    80102f86 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102f85:	90                   	nop
80102f86:	8b 45 08             	mov    0x8(%ebp),%eax
80102f89:	8b 00                	mov    (%eax),%eax
80102f8b:	83 e0 06             	and    $0x6,%eax
80102f8e:	83 f8 02             	cmp    $0x2,%eax
80102f91:	75 dd                	jne    80102f70 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102f93:	c7 04 24 c0 d5 10 80 	movl   $0x8010d5c0,(%esp)
80102f9a:	e8 32 26 00 00       	call   801055d1 <release>
}
80102f9f:	c9                   	leave  
80102fa0:	c3                   	ret    
80102fa1:	00 00                	add    %al,(%eax)
	...

80102fa4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102fa4:	55                   	push   %ebp
80102fa5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102fa7:	a1 f4 17 11 80       	mov    0x801117f4,%eax
80102fac:	8b 55 08             	mov    0x8(%ebp),%edx
80102faf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102fb1:	a1 f4 17 11 80       	mov    0x801117f4,%eax
80102fb6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102fb9:	5d                   	pop    %ebp
80102fba:	c3                   	ret    

80102fbb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102fbb:	55                   	push   %ebp
80102fbc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102fbe:	a1 f4 17 11 80       	mov    0x801117f4,%eax
80102fc3:	8b 55 08             	mov    0x8(%ebp),%edx
80102fc6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102fc8:	a1 f4 17 11 80       	mov    0x801117f4,%eax
80102fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fd0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102fd3:	5d                   	pop    %ebp
80102fd4:	c3                   	ret    

80102fd5 <ioapicinit>:

void
ioapicinit(void)
{
80102fd5:	55                   	push   %ebp
80102fd6:	89 e5                	mov    %esp,%ebp
80102fd8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102fdb:	a1 c4 18 11 80       	mov    0x801118c4,%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	0f 84 9f 00 00 00    	je     80103087 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102fe8:	c7 05 f4 17 11 80 00 	movl   $0xfec00000,0x801117f4
80102fef:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102ff2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ff9:	e8 a6 ff ff ff       	call   80102fa4 <ioapicread>
80102ffe:	c1 e8 10             	shr    $0x10,%eax
80103001:	25 ff 00 00 00       	and    $0xff,%eax
80103006:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80103009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103010:	e8 8f ff ff ff       	call   80102fa4 <ioapicread>
80103015:	c1 e8 18             	shr    $0x18,%eax
80103018:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010301b:	0f b6 05 c0 18 11 80 	movzbl 0x801118c0,%eax
80103022:	0f b6 c0             	movzbl %al,%eax
80103025:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103028:	74 0c                	je     80103036 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010302a:	c7 04 24 94 8e 10 80 	movl   $0x80108e94,(%esp)
80103031:	e8 6b d3 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103036:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010303d:	eb 3e                	jmp    8010307d <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010303f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103042:	83 c0 20             	add    $0x20,%eax
80103045:	0d 00 00 01 00       	or     $0x10000,%eax
8010304a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010304d:	83 c2 08             	add    $0x8,%edx
80103050:	01 d2                	add    %edx,%edx
80103052:	89 44 24 04          	mov    %eax,0x4(%esp)
80103056:	89 14 24             	mov    %edx,(%esp)
80103059:	e8 5d ff ff ff       	call   80102fbb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010305e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103061:	83 c0 08             	add    $0x8,%eax
80103064:	01 c0                	add    %eax,%eax
80103066:	83 c0 01             	add    $0x1,%eax
80103069:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103070:	00 
80103071:	89 04 24             	mov    %eax,(%esp)
80103074:	e8 42 ff ff ff       	call   80102fbb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103079:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010307d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103080:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103083:	7e ba                	jle    8010303f <ioapicinit+0x6a>
80103085:	eb 01                	jmp    80103088 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80103087:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80103088:	c9                   	leave  
80103089:	c3                   	ret    

8010308a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010308a:	55                   	push   %ebp
8010308b:	89 e5                	mov    %esp,%ebp
8010308d:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80103090:	a1 c4 18 11 80       	mov    0x801118c4,%eax
80103095:	85 c0                	test   %eax,%eax
80103097:	74 39                	je     801030d2 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80103099:	8b 45 08             	mov    0x8(%ebp),%eax
8010309c:	83 c0 20             	add    $0x20,%eax
8010309f:	8b 55 08             	mov    0x8(%ebp),%edx
801030a2:	83 c2 08             	add    $0x8,%edx
801030a5:	01 d2                	add    %edx,%edx
801030a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801030ab:	89 14 24             	mov    %edx,(%esp)
801030ae:	e8 08 ff ff ff       	call   80102fbb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801030b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030b6:	c1 e0 18             	shl    $0x18,%eax
801030b9:	8b 55 08             	mov    0x8(%ebp),%edx
801030bc:	83 c2 08             	add    $0x8,%edx
801030bf:	01 d2                	add    %edx,%edx
801030c1:	83 c2 01             	add    $0x1,%edx
801030c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801030c8:	89 14 24             	mov    %edx,(%esp)
801030cb:	e8 eb fe ff ff       	call   80102fbb <ioapicwrite>
801030d0:	eb 01                	jmp    801030d3 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801030d2:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801030d3:	c9                   	leave  
801030d4:	c3                   	ret    
801030d5:	00 00                	add    %al,(%eax)
	...

801030d8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801030d8:	55                   	push   %ebp
801030d9:	89 e5                	mov    %esp,%ebp
801030db:	8b 45 08             	mov    0x8(%ebp),%eax
801030de:	05 00 00 00 80       	add    $0x80000000,%eax
801030e3:	5d                   	pop    %ebp
801030e4:	c3                   	ret    

801030e5 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801030e5:	55                   	push   %ebp
801030e6:	89 e5                	mov    %esp,%ebp
801030e8:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801030eb:	c7 44 24 04 c6 8e 10 	movl   $0x80108ec6,0x4(%esp)
801030f2:	80 
801030f3:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
801030fa:	e8 4f 24 00 00       	call   8010554e <initlock>
  kmem.use_lock = 0;
801030ff:	c7 05 34 18 11 80 00 	movl   $0x0,0x80111834
80103106:	00 00 00 
  freerange(vstart, vend);
80103109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010310c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103110:	8b 45 08             	mov    0x8(%ebp),%eax
80103113:	89 04 24             	mov    %eax,(%esp)
80103116:	e8 26 00 00 00       	call   80103141 <freerange>
}
8010311b:	c9                   	leave  
8010311c:	c3                   	ret    

8010311d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010311d:	55                   	push   %ebp
8010311e:	89 e5                	mov    %esp,%ebp
80103120:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80103123:	8b 45 0c             	mov    0xc(%ebp),%eax
80103126:	89 44 24 04          	mov    %eax,0x4(%esp)
8010312a:	8b 45 08             	mov    0x8(%ebp),%eax
8010312d:	89 04 24             	mov    %eax,(%esp)
80103130:	e8 0c 00 00 00       	call   80103141 <freerange>
  kmem.use_lock = 1;
80103135:	c7 05 34 18 11 80 01 	movl   $0x1,0x80111834
8010313c:	00 00 00 
}
8010313f:	c9                   	leave  
80103140:	c3                   	ret    

80103141 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103141:	55                   	push   %ebp
80103142:	89 e5                	mov    %esp,%ebp
80103144:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103147:	8b 45 08             	mov    0x8(%ebp),%eax
8010314a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010314f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103154:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103157:	eb 12                	jmp    8010316b <freerange+0x2a>
    kfree(p);
80103159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010315c:	89 04 24             	mov    %eax,(%esp)
8010315f:	e8 16 00 00 00       	call   8010317a <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103164:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010316b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316e:	05 00 10 00 00       	add    $0x1000,%eax
80103173:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103176:	76 e1                	jbe    80103159 <freerange+0x18>
    kfree(p);
}
80103178:	c9                   	leave  
80103179:	c3                   	ret    

8010317a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010317a:	55                   	push   %ebp
8010317b:	89 e5                	mov    %esp,%ebp
8010317d:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80103180:	8b 45 08             	mov    0x8(%ebp),%eax
80103183:	25 ff 0f 00 00       	and    $0xfff,%eax
80103188:	85 c0                	test   %eax,%eax
8010318a:	75 1b                	jne    801031a7 <kfree+0x2d>
8010318c:	81 7d 08 bc 4f 11 80 	cmpl   $0x80114fbc,0x8(%ebp)
80103193:	72 12                	jb     801031a7 <kfree+0x2d>
80103195:	8b 45 08             	mov    0x8(%ebp),%eax
80103198:	89 04 24             	mov    %eax,(%esp)
8010319b:	e8 38 ff ff ff       	call   801030d8 <v2p>
801031a0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801031a5:	76 0c                	jbe    801031b3 <kfree+0x39>
    panic("kfree");
801031a7:	c7 04 24 cb 8e 10 80 	movl   $0x80108ecb,(%esp)
801031ae:	e8 8a d3 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801031b3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801031ba:	00 
801031bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801031c2:	00 
801031c3:	8b 45 08             	mov    0x8(%ebp),%eax
801031c6:	89 04 24             	mov    %eax,(%esp)
801031c9:	e8 f0 25 00 00       	call   801057be <memset>

  if(kmem.use_lock)
801031ce:	a1 34 18 11 80       	mov    0x80111834,%eax
801031d3:	85 c0                	test   %eax,%eax
801031d5:	74 0c                	je     801031e3 <kfree+0x69>
    acquire(&kmem.lock);
801031d7:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
801031de:	e8 8c 23 00 00       	call   8010556f <acquire>
  r = (struct run*)v;
801031e3:	8b 45 08             	mov    0x8(%ebp),%eax
801031e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801031e9:	8b 15 38 18 11 80    	mov    0x80111838,%edx
801031ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801031f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f7:	a3 38 18 11 80       	mov    %eax,0x80111838
  if(kmem.use_lock)
801031fc:	a1 34 18 11 80       	mov    0x80111834,%eax
80103201:	85 c0                	test   %eax,%eax
80103203:	74 0c                	je     80103211 <kfree+0x97>
    release(&kmem.lock);
80103205:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
8010320c:	e8 c0 23 00 00       	call   801055d1 <release>
}
80103211:	c9                   	leave  
80103212:	c3                   	ret    

80103213 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103213:	55                   	push   %ebp
80103214:	89 e5                	mov    %esp,%ebp
80103216:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80103219:	a1 34 18 11 80       	mov    0x80111834,%eax
8010321e:	85 c0                	test   %eax,%eax
80103220:	74 0c                	je     8010322e <kalloc+0x1b>
    acquire(&kmem.lock);
80103222:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
80103229:	e8 41 23 00 00       	call   8010556f <acquire>
  r = kmem.freelist;
8010322e:	a1 38 18 11 80       	mov    0x80111838,%eax
80103233:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010323a:	74 0a                	je     80103246 <kalloc+0x33>
    kmem.freelist = r->next;
8010323c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010323f:	8b 00                	mov    (%eax),%eax
80103241:	a3 38 18 11 80       	mov    %eax,0x80111838
  if(kmem.use_lock)
80103246:	a1 34 18 11 80       	mov    0x80111834,%eax
8010324b:	85 c0                	test   %eax,%eax
8010324d:	74 0c                	je     8010325b <kalloc+0x48>
    release(&kmem.lock);
8010324f:	c7 04 24 00 18 11 80 	movl   $0x80111800,(%esp)
80103256:	e8 76 23 00 00       	call   801055d1 <release>
  return (char*)r;
8010325b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010325e:	c9                   	leave  
8010325f:	c3                   	ret    

80103260 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103260:	55                   	push   %ebp
80103261:	89 e5                	mov    %esp,%ebp
80103263:	53                   	push   %ebx
80103264:	83 ec 14             	sub    $0x14,%esp
80103267:	8b 45 08             	mov    0x8(%ebp),%eax
8010326a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010326e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103272:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103276:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010327a:	ec                   	in     (%dx),%al
8010327b:	89 c3                	mov    %eax,%ebx
8010327d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103280:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103284:	83 c4 14             	add    $0x14,%esp
80103287:	5b                   	pop    %ebx
80103288:	5d                   	pop    %ebp
80103289:	c3                   	ret    

8010328a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010328a:	55                   	push   %ebp
8010328b:	89 e5                	mov    %esp,%ebp
8010328d:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103290:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103297:	e8 c4 ff ff ff       	call   80103260 <inb>
8010329c:	0f b6 c0             	movzbl %al,%eax
8010329f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801032a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032a5:	83 e0 01             	and    $0x1,%eax
801032a8:	85 c0                	test   %eax,%eax
801032aa:	75 0a                	jne    801032b6 <kbdgetc+0x2c>
    return -1;
801032ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801032b1:	e9 23 01 00 00       	jmp    801033d9 <kbdgetc+0x14f>
  data = inb(KBDATAP);
801032b6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
801032bd:	e8 9e ff ff ff       	call   80103260 <inb>
801032c2:	0f b6 c0             	movzbl %al,%eax
801032c5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801032c8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801032cf:	75 17                	jne    801032e8 <kbdgetc+0x5e>
    shift |= E0ESC;
801032d1:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
801032d6:	83 c8 40             	or     $0x40,%eax
801032d9:	a3 fc d5 10 80       	mov    %eax,0x8010d5fc
    return 0;
801032de:	b8 00 00 00 00       	mov    $0x0,%eax
801032e3:	e9 f1 00 00 00       	jmp    801033d9 <kbdgetc+0x14f>
  } else if(data & 0x80){
801032e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801032eb:	25 80 00 00 00       	and    $0x80,%eax
801032f0:	85 c0                	test   %eax,%eax
801032f2:	74 45                	je     80103339 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801032f4:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
801032f9:	83 e0 40             	and    $0x40,%eax
801032fc:	85 c0                	test   %eax,%eax
801032fe:	75 08                	jne    80103308 <kbdgetc+0x7e>
80103300:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103303:	83 e0 7f             	and    $0x7f,%eax
80103306:	eb 03                	jmp    8010330b <kbdgetc+0x81>
80103308:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010330b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010330e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103311:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103316:	0f b6 00             	movzbl (%eax),%eax
80103319:	83 c8 40             	or     $0x40,%eax
8010331c:	0f b6 c0             	movzbl %al,%eax
8010331f:	f7 d0                	not    %eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
80103328:	21 d0                	and    %edx,%eax
8010332a:	a3 fc d5 10 80       	mov    %eax,0x8010d5fc
    return 0;
8010332f:	b8 00 00 00 00       	mov    $0x0,%eax
80103334:	e9 a0 00 00 00       	jmp    801033d9 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80103339:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
8010333e:	83 e0 40             	and    $0x40,%eax
80103341:	85 c0                	test   %eax,%eax
80103343:	74 14                	je     80103359 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103345:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010334c:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
80103351:	83 e0 bf             	and    $0xffffffbf,%eax
80103354:	a3 fc d5 10 80       	mov    %eax,0x8010d5fc
  }

  shift |= shiftcode[data];
80103359:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010335c:	05 20 a0 10 80       	add    $0x8010a020,%eax
80103361:	0f b6 00             	movzbl (%eax),%eax
80103364:	0f b6 d0             	movzbl %al,%edx
80103367:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
8010336c:	09 d0                	or     %edx,%eax
8010336e:	a3 fc d5 10 80       	mov    %eax,0x8010d5fc
  shift ^= togglecode[data];
80103373:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103376:	05 20 a1 10 80       	add    $0x8010a120,%eax
8010337b:	0f b6 00             	movzbl (%eax),%eax
8010337e:	0f b6 d0             	movzbl %al,%edx
80103381:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
80103386:	31 d0                	xor    %edx,%eax
80103388:	a3 fc d5 10 80       	mov    %eax,0x8010d5fc
  c = charcode[shift & (CTL | SHIFT)][data];
8010338d:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
80103392:	83 e0 03             	and    $0x3,%eax
80103395:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
8010339c:	03 45 fc             	add    -0x4(%ebp),%eax
8010339f:	0f b6 00             	movzbl (%eax),%eax
801033a2:	0f b6 c0             	movzbl %al,%eax
801033a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801033a8:	a1 fc d5 10 80       	mov    0x8010d5fc,%eax
801033ad:	83 e0 08             	and    $0x8,%eax
801033b0:	85 c0                	test   %eax,%eax
801033b2:	74 22                	je     801033d6 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
801033b4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801033b8:	76 0c                	jbe    801033c6 <kbdgetc+0x13c>
801033ba:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801033be:	77 06                	ja     801033c6 <kbdgetc+0x13c>
      c += 'A' - 'a';
801033c0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801033c4:	eb 10                	jmp    801033d6 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
801033c6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801033ca:	76 0a                	jbe    801033d6 <kbdgetc+0x14c>
801033cc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801033d0:	77 04                	ja     801033d6 <kbdgetc+0x14c>
      c += 'a' - 'A';
801033d2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801033d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801033d9:	c9                   	leave  
801033da:	c3                   	ret    

801033db <kbdintr>:

void
kbdintr(void)
{
801033db:	55                   	push   %ebp
801033dc:	89 e5                	mov    %esp,%ebp
801033de:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801033e1:	c7 04 24 8a 32 10 80 	movl   $0x8010328a,(%esp)
801033e8:	e8 f3 d3 ff ff       	call   801007e0 <consoleintr>
}
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    
	...

801033f0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801033f0:	55                   	push   %ebp
801033f1:	89 e5                	mov    %esp,%ebp
801033f3:	83 ec 08             	sub    $0x8,%esp
801033f6:	8b 55 08             	mov    0x8(%ebp),%edx
801033f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801033fc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103400:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103403:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103407:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010340b:	ee                   	out    %al,(%dx)
}
8010340c:	c9                   	leave  
8010340d:	c3                   	ret    

8010340e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010340e:	55                   	push   %ebp
8010340f:	89 e5                	mov    %esp,%ebp
80103411:	53                   	push   %ebx
80103412:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103415:	9c                   	pushf  
80103416:	5b                   	pop    %ebx
80103417:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010341a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010341d:	83 c4 10             	add    $0x10,%esp
80103420:	5b                   	pop    %ebx
80103421:	5d                   	pop    %ebp
80103422:	c3                   	ret    

80103423 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103423:	55                   	push   %ebp
80103424:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103426:	a1 3c 18 11 80       	mov    0x8011183c,%eax
8010342b:	8b 55 08             	mov    0x8(%ebp),%edx
8010342e:	c1 e2 02             	shl    $0x2,%edx
80103431:	01 c2                	add    %eax,%edx
80103433:	8b 45 0c             	mov    0xc(%ebp),%eax
80103436:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103438:	a1 3c 18 11 80       	mov    0x8011183c,%eax
8010343d:	83 c0 20             	add    $0x20,%eax
80103440:	8b 00                	mov    (%eax),%eax
}
80103442:	5d                   	pop    %ebp
80103443:	c3                   	ret    

80103444 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103444:	55                   	push   %ebp
80103445:	89 e5                	mov    %esp,%ebp
80103447:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010344a:	a1 3c 18 11 80       	mov    0x8011183c,%eax
8010344f:	85 c0                	test   %eax,%eax
80103451:	0f 84 47 01 00 00    	je     8010359e <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103457:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010345e:	00 
8010345f:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103466:	e8 b8 ff ff ff       	call   80103423 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010346b:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103472:	00 
80103473:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010347a:	e8 a4 ff ff ff       	call   80103423 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010347f:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103486:	00 
80103487:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010348e:	e8 90 ff ff ff       	call   80103423 <lapicw>
  lapicw(TICR, 10000000); 
80103493:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
8010349a:	00 
8010349b:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801034a2:	e8 7c ff ff ff       	call   80103423 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801034a7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034ae:	00 
801034af:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801034b6:	e8 68 ff ff ff       	call   80103423 <lapicw>
  lapicw(LINT1, MASKED);
801034bb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034c2:	00 
801034c3:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801034ca:	e8 54 ff ff ff       	call   80103423 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801034cf:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801034d4:	83 c0 30             	add    $0x30,%eax
801034d7:	8b 00                	mov    (%eax),%eax
801034d9:	c1 e8 10             	shr    $0x10,%eax
801034dc:	25 ff 00 00 00       	and    $0xff,%eax
801034e1:	83 f8 03             	cmp    $0x3,%eax
801034e4:	76 14                	jbe    801034fa <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801034e6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034ed:	00 
801034ee:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801034f5:	e8 29 ff ff ff       	call   80103423 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801034fa:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103501:	00 
80103502:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103509:	e8 15 ff ff ff       	call   80103423 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010350e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103515:	00 
80103516:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010351d:	e8 01 ff ff ff       	call   80103423 <lapicw>
  lapicw(ESR, 0);
80103522:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103529:	00 
8010352a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103531:	e8 ed fe ff ff       	call   80103423 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103536:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010353d:	00 
8010353e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103545:	e8 d9 fe ff ff       	call   80103423 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010354a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103551:	00 
80103552:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103559:	e8 c5 fe ff ff       	call   80103423 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010355e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103565:	00 
80103566:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010356d:	e8 b1 fe ff ff       	call   80103423 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103572:	90                   	nop
80103573:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80103578:	05 00 03 00 00       	add    $0x300,%eax
8010357d:	8b 00                	mov    (%eax),%eax
8010357f:	25 00 10 00 00       	and    $0x1000,%eax
80103584:	85 c0                	test   %eax,%eax
80103586:	75 eb                	jne    80103573 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103588:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010358f:	00 
80103590:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103597:	e8 87 fe ff ff       	call   80103423 <lapicw>
8010359c:	eb 01                	jmp    8010359f <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
8010359e:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010359f:	c9                   	leave  
801035a0:	c3                   	ret    

801035a1 <cpunum>:

int
cpunum(void)
{
801035a1:	55                   	push   %ebp
801035a2:	89 e5                	mov    %esp,%ebp
801035a4:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801035a7:	e8 62 fe ff ff       	call   8010340e <readeflags>
801035ac:	25 00 02 00 00       	and    $0x200,%eax
801035b1:	85 c0                	test   %eax,%eax
801035b3:	74 29                	je     801035de <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801035b5:	a1 00 d6 10 80       	mov    0x8010d600,%eax
801035ba:	85 c0                	test   %eax,%eax
801035bc:	0f 94 c2             	sete   %dl
801035bf:	83 c0 01             	add    $0x1,%eax
801035c2:	a3 00 d6 10 80       	mov    %eax,0x8010d600
801035c7:	84 d2                	test   %dl,%dl
801035c9:	74 13                	je     801035de <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801035cb:	8b 45 04             	mov    0x4(%ebp),%eax
801035ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801035d2:	c7 04 24 d4 8e 10 80 	movl   $0x80108ed4,(%esp)
801035d9:	e8 c3 cd ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801035de:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801035e3:	85 c0                	test   %eax,%eax
801035e5:	74 0f                	je     801035f6 <cpunum+0x55>
    return lapic[ID]>>24;
801035e7:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801035ec:	83 c0 20             	add    $0x20,%eax
801035ef:	8b 00                	mov    (%eax),%eax
801035f1:	c1 e8 18             	shr    $0x18,%eax
801035f4:	eb 05                	jmp    801035fb <cpunum+0x5a>
  return 0;
801035f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801035fb:	c9                   	leave  
801035fc:	c3                   	ret    

801035fd <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801035fd:	55                   	push   %ebp
801035fe:	89 e5                	mov    %esp,%ebp
80103600:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103603:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80103608:	85 c0                	test   %eax,%eax
8010360a:	74 14                	je     80103620 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010360c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103613:	00 
80103614:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010361b:	e8 03 fe ff ff       	call   80103423 <lapicw>
}
80103620:	c9                   	leave  
80103621:	c3                   	ret    

80103622 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103622:	55                   	push   %ebp
80103623:	89 e5                	mov    %esp,%ebp
}
80103625:	5d                   	pop    %ebp
80103626:	c3                   	ret    

80103627 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103627:	55                   	push   %ebp
80103628:	89 e5                	mov    %esp,%ebp
8010362a:	83 ec 1c             	sub    $0x1c,%esp
8010362d:	8b 45 08             	mov    0x8(%ebp),%eax
80103630:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103633:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010363a:	00 
8010363b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103642:	e8 a9 fd ff ff       	call   801033f0 <outb>
  outb(IO_RTC+1, 0x0A);
80103647:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010364e:	00 
8010364f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103656:	e8 95 fd ff ff       	call   801033f0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010365b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103662:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103665:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010366a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010366d:	8d 50 02             	lea    0x2(%eax),%edx
80103670:	8b 45 0c             	mov    0xc(%ebp),%eax
80103673:	c1 e8 04             	shr    $0x4,%eax
80103676:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103679:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010367d:	c1 e0 18             	shl    $0x18,%eax
80103680:	89 44 24 04          	mov    %eax,0x4(%esp)
80103684:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010368b:	e8 93 fd ff ff       	call   80103423 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103690:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103697:	00 
80103698:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010369f:	e8 7f fd ff ff       	call   80103423 <lapicw>
  microdelay(200);
801036a4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801036ab:	e8 72 ff ff ff       	call   80103622 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801036b0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801036b7:	00 
801036b8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801036bf:	e8 5f fd ff ff       	call   80103423 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801036c4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801036cb:	e8 52 ff ff ff       	call   80103622 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801036d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801036d7:	eb 40                	jmp    80103719 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801036d9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801036dd:	c1 e0 18             	shl    $0x18,%eax
801036e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801036e4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801036eb:	e8 33 fd ff ff       	call   80103423 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801036f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801036f3:	c1 e8 0c             	shr    $0xc,%eax
801036f6:	80 cc 06             	or     $0x6,%ah
801036f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801036fd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103704:	e8 1a fd ff ff       	call   80103423 <lapicw>
    microdelay(200);
80103709:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103710:	e8 0d ff ff ff       	call   80103622 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103715:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103719:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010371d:	7e ba                	jle    801036d9 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010371f:	c9                   	leave  
80103720:	c3                   	ret    
80103721:	00 00                	add    %al,(%eax)
	...

80103724 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103724:	55                   	push   %ebp
80103725:	89 e5                	mov    %esp,%ebp
80103727:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010372a:	c7 44 24 04 00 8f 10 	movl   $0x80108f00,0x4(%esp)
80103731:	80 
80103732:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80103739:	e8 10 1e 00 00       	call   8010554e <initlock>
  readsb(ROOTDEV, &sb);
8010373e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103741:	89 44 24 04          	mov    %eax,0x4(%esp)
80103745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010374c:	e8 af e2 ff ff       	call   80101a00 <readsb>
  log.start = sb.size - sb.nlog;
80103751:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103757:	89 d1                	mov    %edx,%ecx
80103759:	29 c1                	sub    %eax,%ecx
8010375b:	89 c8                	mov    %ecx,%eax
8010375d:	a3 74 18 11 80       	mov    %eax,0x80111874
  log.size = sb.nlog;
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	a3 78 18 11 80       	mov    %eax,0x80111878
  log.dev = ROOTDEV;
8010376a:	c7 05 80 18 11 80 01 	movl   $0x1,0x80111880
80103771:	00 00 00 
  recover_from_log();
80103774:	e8 97 01 00 00       	call   80103910 <recover_from_log>
}
80103779:	c9                   	leave  
8010377a:	c3                   	ret    

8010377b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010377b:	55                   	push   %ebp
8010377c:	89 e5                	mov    %esp,%ebp
8010377e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103788:	e9 89 00 00 00       	jmp    80103816 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010378d:	a1 74 18 11 80       	mov    0x80111874,%eax
80103792:	03 45 f4             	add    -0xc(%ebp),%eax
80103795:	83 c0 01             	add    $0x1,%eax
80103798:	89 c2                	mov    %eax,%edx
8010379a:	a1 80 18 11 80       	mov    0x80111880,%eax
8010379f:	89 54 24 04          	mov    %edx,0x4(%esp)
801037a3:	89 04 24             	mov    %eax,(%esp)
801037a6:	e8 fb c9 ff ff       	call   801001a6 <bread>
801037ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801037ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b1:	83 c0 10             	add    $0x10,%eax
801037b4:	8b 04 85 48 18 11 80 	mov    -0x7feee7b8(,%eax,4),%eax
801037bb:	89 c2                	mov    %eax,%edx
801037bd:	a1 80 18 11 80       	mov    0x80111880,%eax
801037c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801037c6:	89 04 24             	mov    %eax,(%esp)
801037c9:	e8 d8 c9 ff ff       	call   801001a6 <bread>
801037ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801037d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d4:	8d 50 18             	lea    0x18(%eax),%edx
801037d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037da:	83 c0 18             	add    $0x18,%eax
801037dd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037e4:	00 
801037e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801037e9:	89 04 24             	mov    %eax,(%esp)
801037ec:	e8 a0 20 00 00       	call   80105891 <memmove>
    bwrite(dbuf);  // write dst to disk
801037f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037f4:	89 04 24             	mov    %eax,(%esp)
801037f7:	e8 e1 c9 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801037fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ff:	89 04 24             	mov    %eax,(%esp)
80103802:	e8 10 ca ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103807:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010380a:	89 04 24             	mov    %eax,(%esp)
8010380d:	e8 05 ca ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103812:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103816:	a1 84 18 11 80       	mov    0x80111884,%eax
8010381b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010381e:	0f 8f 69 ff ff ff    	jg     8010378d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103824:	c9                   	leave  
80103825:	c3                   	ret    

80103826 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103826:	55                   	push   %ebp
80103827:	89 e5                	mov    %esp,%ebp
80103829:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010382c:	a1 74 18 11 80       	mov    0x80111874,%eax
80103831:	89 c2                	mov    %eax,%edx
80103833:	a1 80 18 11 80       	mov    0x80111880,%eax
80103838:	89 54 24 04          	mov    %edx,0x4(%esp)
8010383c:	89 04 24             	mov    %eax,(%esp)
8010383f:	e8 62 c9 ff ff       	call   801001a6 <bread>
80103844:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010384a:	83 c0 18             	add    $0x18,%eax
8010384d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103850:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103853:	8b 00                	mov    (%eax),%eax
80103855:	a3 84 18 11 80       	mov    %eax,0x80111884
  for (i = 0; i < log.lh.n; i++) {
8010385a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103861:	eb 1b                	jmp    8010387e <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103866:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103869:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010386d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103870:	83 c2 10             	add    $0x10,%edx
80103873:	89 04 95 48 18 11 80 	mov    %eax,-0x7feee7b8(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010387a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010387e:	a1 84 18 11 80       	mov    0x80111884,%eax
80103883:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103886:	7f db                	jg     80103863 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388b:	89 04 24             	mov    %eax,(%esp)
8010388e:	e8 84 c9 ff ff       	call   80100217 <brelse>
}
80103893:	c9                   	leave  
80103894:	c3                   	ret    

80103895 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103895:	55                   	push   %ebp
80103896:	89 e5                	mov    %esp,%ebp
80103898:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010389b:	a1 74 18 11 80       	mov    0x80111874,%eax
801038a0:	89 c2                	mov    %eax,%edx
801038a2:	a1 80 18 11 80       	mov    0x80111880,%eax
801038a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801038ab:	89 04 24             	mov    %eax,(%esp)
801038ae:	e8 f3 c8 ff ff       	call   801001a6 <bread>
801038b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801038b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b9:	83 c0 18             	add    $0x18,%eax
801038bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801038bf:	8b 15 84 18 11 80    	mov    0x80111884,%edx
801038c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038c8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801038ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038d1:	eb 1b                	jmp    801038ee <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801038d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d6:	83 c0 10             	add    $0x10,%eax
801038d9:	8b 0c 85 48 18 11 80 	mov    -0x7feee7b8(,%eax,4),%ecx
801038e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038e6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801038ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038ee:	a1 84 18 11 80       	mov    0x80111884,%eax
801038f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038f6:	7f db                	jg     801038d3 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801038f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fb:	89 04 24             	mov    %eax,(%esp)
801038fe:	e8 da c8 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103906:	89 04 24             	mov    %eax,(%esp)
80103909:	e8 09 c9 ff ff       	call   80100217 <brelse>
}
8010390e:	c9                   	leave  
8010390f:	c3                   	ret    

80103910 <recover_from_log>:

static void
recover_from_log(void)
{
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103916:	e8 0b ff ff ff       	call   80103826 <read_head>
  install_trans(); // if committed, copy from log to disk
8010391b:	e8 5b fe ff ff       	call   8010377b <install_trans>
  log.lh.n = 0;
80103920:	c7 05 84 18 11 80 00 	movl   $0x0,0x80111884
80103927:	00 00 00 
  write_head(); // clear the log
8010392a:	e8 66 ff ff ff       	call   80103895 <write_head>
}
8010392f:	c9                   	leave  
80103930:	c3                   	ret    

80103931 <begin_trans>:

void
begin_trans(void)
{
80103931:	55                   	push   %ebp
80103932:	89 e5                	mov    %esp,%ebp
80103934:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103937:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
8010393e:	e8 2c 1c 00 00       	call   8010556f <acquire>
  while (log.busy) {
80103943:	eb 14                	jmp    80103959 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103945:	c7 44 24 04 40 18 11 	movl   $0x80111840,0x4(%esp)
8010394c:	80 
8010394d:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80103954:	e8 9e 18 00 00       	call   801051f7 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103959:	a1 7c 18 11 80       	mov    0x8011187c,%eax
8010395e:	85 c0                	test   %eax,%eax
80103960:	75 e3                	jne    80103945 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103962:	c7 05 7c 18 11 80 01 	movl   $0x1,0x8011187c
80103969:	00 00 00 
  release(&log.lock);
8010396c:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80103973:	e8 59 1c 00 00       	call   801055d1 <release>
}
80103978:	c9                   	leave  
80103979:	c3                   	ret    

8010397a <commit_trans>:

void
commit_trans(void)
{
8010397a:	55                   	push   %ebp
8010397b:	89 e5                	mov    %esp,%ebp
8010397d:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103980:	a1 84 18 11 80       	mov    0x80111884,%eax
80103985:	85 c0                	test   %eax,%eax
80103987:	7e 19                	jle    801039a2 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103989:	e8 07 ff ff ff       	call   80103895 <write_head>
    install_trans(); // Now install writes to home locations
8010398e:	e8 e8 fd ff ff       	call   8010377b <install_trans>
    log.lh.n = 0; 
80103993:	c7 05 84 18 11 80 00 	movl   $0x0,0x80111884
8010399a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010399d:	e8 f3 fe ff ff       	call   80103895 <write_head>
  }
  
  acquire(&log.lock);
801039a2:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
801039a9:	e8 c1 1b 00 00       	call   8010556f <acquire>
  log.busy = 0;
801039ae:	c7 05 7c 18 11 80 00 	movl   $0x0,0x8011187c
801039b5:	00 00 00 
  wakeup(&log);
801039b8:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
801039bf:	e8 a1 19 00 00       	call   80105365 <wakeup>
  release(&log.lock);
801039c4:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
801039cb:	e8 01 1c 00 00       	call   801055d1 <release>
}
801039d0:	c9                   	leave  
801039d1:	c3                   	ret    

801039d2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801039d2:	55                   	push   %ebp
801039d3:	89 e5                	mov    %esp,%ebp
801039d5:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039d8:	a1 84 18 11 80       	mov    0x80111884,%eax
801039dd:	83 f8 09             	cmp    $0x9,%eax
801039e0:	7f 12                	jg     801039f4 <log_write+0x22>
801039e2:	a1 84 18 11 80       	mov    0x80111884,%eax
801039e7:	8b 15 78 18 11 80    	mov    0x80111878,%edx
801039ed:	83 ea 01             	sub    $0x1,%edx
801039f0:	39 d0                	cmp    %edx,%eax
801039f2:	7c 0c                	jl     80103a00 <log_write+0x2e>
    panic("too big a transaction");
801039f4:	c7 04 24 04 8f 10 80 	movl   $0x80108f04,(%esp)
801039fb:	e8 3d cb ff ff       	call   8010053d <panic>
  if (!log.busy)
80103a00:	a1 7c 18 11 80       	mov    0x8011187c,%eax
80103a05:	85 c0                	test   %eax,%eax
80103a07:	75 0c                	jne    80103a15 <log_write+0x43>
    panic("write outside of trans");
80103a09:	c7 04 24 1a 8f 10 80 	movl   $0x80108f1a,(%esp)
80103a10:	e8 28 cb ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103a15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a1c:	eb 1d                	jmp    80103a3b <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a21:	83 c0 10             	add    $0x10,%eax
80103a24:	8b 04 85 48 18 11 80 	mov    -0x7feee7b8(,%eax,4),%eax
80103a2b:	89 c2                	mov    %eax,%edx
80103a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a30:	8b 40 08             	mov    0x8(%eax),%eax
80103a33:	39 c2                	cmp    %eax,%edx
80103a35:	74 10                	je     80103a47 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103a37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a3b:	a1 84 18 11 80       	mov    0x80111884,%eax
80103a40:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a43:	7f d9                	jg     80103a1e <log_write+0x4c>
80103a45:	eb 01                	jmp    80103a48 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103a47:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103a48:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4b:	8b 40 08             	mov    0x8(%eax),%eax
80103a4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a51:	83 c2 10             	add    $0x10,%edx
80103a54:	89 04 95 48 18 11 80 	mov    %eax,-0x7feee7b8(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103a5b:	a1 74 18 11 80       	mov    0x80111874,%eax
80103a60:	03 45 f4             	add    -0xc(%ebp),%eax
80103a63:	83 c0 01             	add    $0x1,%eax
80103a66:	89 c2                	mov    %eax,%edx
80103a68:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6b:	8b 40 04             	mov    0x4(%eax),%eax
80103a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a72:	89 04 24             	mov    %eax,(%esp)
80103a75:	e8 2c c7 ff ff       	call   801001a6 <bread>
80103a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a80:	8d 50 18             	lea    0x18(%eax),%edx
80103a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a86:	83 c0 18             	add    $0x18,%eax
80103a89:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103a90:	00 
80103a91:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a95:	89 04 24             	mov    %eax,(%esp)
80103a98:	e8 f4 1d 00 00       	call   80105891 <memmove>
  bwrite(lbuf);
80103a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa0:	89 04 24             	mov    %eax,(%esp)
80103aa3:	e8 35 c7 ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aab:	89 04 24             	mov    %eax,(%esp)
80103aae:	e8 64 c7 ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103ab3:	a1 84 18 11 80       	mov    0x80111884,%eax
80103ab8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103abb:	75 0d                	jne    80103aca <log_write+0xf8>
    log.lh.n++;
80103abd:	a1 84 18 11 80       	mov    0x80111884,%eax
80103ac2:	83 c0 01             	add    $0x1,%eax
80103ac5:	a3 84 18 11 80       	mov    %eax,0x80111884
  b->flags |= B_DIRTY; // XXX prevent eviction
80103aca:	8b 45 08             	mov    0x8(%ebp),%eax
80103acd:	8b 00                	mov    (%eax),%eax
80103acf:	89 c2                	mov    %eax,%edx
80103ad1:	83 ca 04             	or     $0x4,%edx
80103ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad7:	89 10                	mov    %edx,(%eax)
}
80103ad9:	c9                   	leave  
80103ada:	c3                   	ret    
	...

80103adc <v2p>:
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ae7:	5d                   	pop    %ebp
80103ae8:	c3                   	ret    

80103ae9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103ae9:	55                   	push   %ebp
80103aea:	89 e5                	mov    %esp,%ebp
80103aec:	8b 45 08             	mov    0x8(%ebp),%eax
80103aef:	05 00 00 00 80       	add    $0x80000000,%eax
80103af4:	5d                   	pop    %ebp
80103af5:	c3                   	ret    

80103af6 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103af6:	55                   	push   %ebp
80103af7:	89 e5                	mov    %esp,%ebp
80103af9:	53                   	push   %ebx
80103afa:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103afd:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b00:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b06:	89 c3                	mov    %eax,%ebx
80103b08:	89 d8                	mov    %ebx,%eax
80103b0a:	f0 87 02             	lock xchg %eax,(%edx)
80103b0d:	89 c3                	mov    %eax,%ebx
80103b0f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b15:	83 c4 10             	add    $0x10,%esp
80103b18:	5b                   	pop    %ebx
80103b19:	5d                   	pop    %ebp
80103b1a:	c3                   	ret    

80103b1b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103b1b:	55                   	push   %ebp
80103b1c:	89 e5                	mov    %esp,%ebp
80103b1e:	83 e4 f0             	and    $0xfffffff0,%esp
80103b21:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103b24:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103b2b:	80 
80103b2c:	c7 04 24 bc 4f 11 80 	movl   $0x80114fbc,(%esp)
80103b33:	e8 ad f5 ff ff       	call   801030e5 <kinit1>
  kvmalloc();      // kernel page table
80103b38:	e8 21 4a 00 00       	call   8010855e <kvmalloc>
  mpinit();        // collect info about this machine
80103b3d:	e8 63 04 00 00       	call   80103fa5 <mpinit>
  lapicinit(mpbcpu());
80103b42:	e8 2e 02 00 00       	call   80103d75 <mpbcpu>
80103b47:	89 04 24             	mov    %eax,(%esp)
80103b4a:	e8 f5 f8 ff ff       	call   80103444 <lapicinit>
  seginit();       // set up segments
80103b4f:	e8 ad 43 00 00       	call   80107f01 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103b54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103b5a:	0f b6 00             	movzbl (%eax),%eax
80103b5d:	0f b6 c0             	movzbl %al,%eax
80103b60:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b64:	c7 04 24 31 8f 10 80 	movl   $0x80108f31,(%esp)
80103b6b:	e8 31 c8 ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103b70:	e8 95 06 00 00       	call   8010420a <picinit>
  ioapicinit();    // another interrupt controller
80103b75:	e8 5b f4 ff ff       	call   80102fd5 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103b7a:	e8 c0 d4 ff ff       	call   8010103f <consoleinit>
  uartinit();      // serial port
80103b7f:	e8 c8 36 00 00       	call   8010724c <uartinit>
  pinit();         // process table
80103b84:	e8 96 0b 00 00       	call   8010471f <pinit>
  tvinit();        // trap vectors
80103b89:	e8 99 31 00 00       	call   80106d27 <tvinit>
  binit();         // buffer cache
80103b8e:	e8 a1 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b93:	e8 7c da ff ff       	call   80101614 <fileinit>
  iinit();         // inode cache
80103b98:	e8 2a e1 ff ff       	call   80101cc7 <iinit>
  ideinit();       // disk
80103b9d:	e8 98 f0 ff ff       	call   80102c3a <ideinit>
  if(!ismp)
80103ba2:	a1 c4 18 11 80       	mov    0x801118c4,%eax
80103ba7:	85 c0                	test   %eax,%eax
80103ba9:	75 05                	jne    80103bb0 <main+0x95>
    timerinit();   // uniprocessor timer
80103bab:	e8 ba 30 00 00       	call   80106c6a <timerinit>
  startothers();   // start other processors
80103bb0:	e8 87 00 00 00       	call   80103c3c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103bb5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103bbc:	8e 
80103bbd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103bc4:	e8 54 f5 ff ff       	call   8010311d <kinit2>
  userinit();      // first user process
80103bc9:	e8 ea 0c 00 00       	call   801048b8 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103bce:	e8 22 00 00 00       	call   80103bf5 <mpmain>

80103bd3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103bd3:	55                   	push   %ebp
80103bd4:	89 e5                	mov    %esp,%ebp
80103bd6:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103bd9:	e8 97 49 00 00       	call   80108575 <switchkvm>
  seginit();
80103bde:	e8 1e 43 00 00       	call   80107f01 <seginit>
  lapicinit(cpunum());
80103be3:	e8 b9 f9 ff ff       	call   801035a1 <cpunum>
80103be8:	89 04 24             	mov    %eax,(%esp)
80103beb:	e8 54 f8 ff ff       	call   80103444 <lapicinit>
  mpmain();
80103bf0:	e8 00 00 00 00       	call   80103bf5 <mpmain>

80103bf5 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103bf5:	55                   	push   %ebp
80103bf6:	89 e5                	mov    %esp,%ebp
80103bf8:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103bfb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c01:	0f b6 00             	movzbl (%eax),%eax
80103c04:	0f b6 c0             	movzbl %al,%eax
80103c07:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c0b:	c7 04 24 48 8f 10 80 	movl   $0x80108f48,(%esp)
80103c12:	e8 8a c7 ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103c17:	e8 7f 32 00 00       	call   80106e9b <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103c1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c22:	05 a8 00 00 00       	add    $0xa8,%eax
80103c27:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c2e:	00 
80103c2f:	89 04 24             	mov    %eax,(%esp)
80103c32:	e8 bf fe ff ff       	call   80103af6 <xchg>
  scheduler();     // start running processes
80103c37:	e8 e8 13 00 00       	call   80105024 <scheduler>

80103c3c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	53                   	push   %ebx
80103c40:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103c43:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103c4a:	e8 9a fe ff ff       	call   80103ae9 <p2v>
80103c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c52:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c57:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c5b:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
80103c62:	80 
80103c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c66:	89 04 24             	mov    %eax,(%esp)
80103c69:	e8 23 1c 00 00       	call   80105891 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c6e:	c7 45 f4 e0 18 11 80 	movl   $0x801118e0,-0xc(%ebp)
80103c75:	e9 86 00 00 00       	jmp    80103d00 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103c7a:	e8 22 f9 ff ff       	call   801035a1 <cpunum>
80103c7f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c85:	05 e0 18 11 80       	add    $0x801118e0,%eax
80103c8a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c8d:	74 69                	je     80103cf8 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103c8f:	e8 7f f5 ff ff       	call   80103213 <kalloc>
80103c94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9a:	83 e8 04             	sub    $0x4,%eax
80103c9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ca0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103ca6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cab:	83 e8 08             	sub    $0x8,%eax
80103cae:	c7 00 d3 3b 10 80    	movl   $0x80103bd3,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb7:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103cba:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103cc1:	e8 16 fe ff ff       	call   80103adc <v2p>
80103cc6:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ccb:	89 04 24             	mov    %eax,(%esp)
80103cce:	e8 09 fe ff ff       	call   80103adc <v2p>
80103cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd6:	0f b6 12             	movzbl (%edx),%edx
80103cd9:	0f b6 d2             	movzbl %dl,%edx
80103cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ce0:	89 14 24             	mov    %edx,(%esp)
80103ce3:	e8 3f f9 ff ff       	call   80103627 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103ce8:	90                   	nop
80103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cec:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103cf2:	85 c0                	test   %eax,%eax
80103cf4:	74 f3                	je     80103ce9 <startothers+0xad>
80103cf6:	eb 01                	jmp    80103cf9 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103cf8:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103cf9:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103d00:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80103d05:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d0b:	05 e0 18 11 80       	add    $0x801118e0,%eax
80103d10:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d13:	0f 87 61 ff ff ff    	ja     80103c7a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d19:	83 c4 24             	add    $0x24,%esp
80103d1c:	5b                   	pop    %ebx
80103d1d:	5d                   	pop    %ebp
80103d1e:	c3                   	ret    
	...

80103d20 <p2v>:
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	8b 45 08             	mov    0x8(%ebp),%eax
80103d26:	05 00 00 00 80       	add    $0x80000000,%eax
80103d2b:	5d                   	pop    %ebp
80103d2c:	c3                   	ret    

80103d2d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d2d:	55                   	push   %ebp
80103d2e:	89 e5                	mov    %esp,%ebp
80103d30:	53                   	push   %ebx
80103d31:	83 ec 14             	sub    $0x14,%esp
80103d34:	8b 45 08             	mov    0x8(%ebp),%eax
80103d37:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d3b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103d3f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103d43:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103d47:	ec                   	in     (%dx),%al
80103d48:	89 c3                	mov    %eax,%ebx
80103d4a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103d4d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103d51:	83 c4 14             	add    $0x14,%esp
80103d54:	5b                   	pop    %ebx
80103d55:	5d                   	pop    %ebp
80103d56:	c3                   	ret    

80103d57 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d57:	55                   	push   %ebp
80103d58:	89 e5                	mov    %esp,%ebp
80103d5a:	83 ec 08             	sub    $0x8,%esp
80103d5d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d63:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d67:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d6a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d6e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d72:	ee                   	out    %al,(%dx)
}
80103d73:	c9                   	leave  
80103d74:	c3                   	ret    

80103d75 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103d75:	55                   	push   %ebp
80103d76:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103d78:	a1 04 d6 10 80       	mov    0x8010d604,%eax
80103d7d:	89 c2                	mov    %eax,%edx
80103d7f:	b8 e0 18 11 80       	mov    $0x801118e0,%eax
80103d84:	89 d1                	mov    %edx,%ecx
80103d86:	29 c1                	sub    %eax,%ecx
80103d88:	89 c8                	mov    %ecx,%eax
80103d8a:	c1 f8 02             	sar    $0x2,%eax
80103d8d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103d93:	5d                   	pop    %ebp
80103d94:	c3                   	ret    

80103d95 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103d95:	55                   	push   %ebp
80103d96:	89 e5                	mov    %esp,%ebp
80103d98:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103d9b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103da2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103da9:	eb 13                	jmp    80103dbe <sum+0x29>
    sum += addr[i];
80103dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dae:	03 45 08             	add    0x8(%ebp),%eax
80103db1:	0f b6 00             	movzbl (%eax),%eax
80103db4:	0f b6 c0             	movzbl %al,%eax
80103db7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103dba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103dbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103dc4:	7c e5                	jl     80103dab <sum+0x16>
    sum += addr[i];
  return sum;
80103dc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103dc9:	c9                   	leave  
80103dca:	c3                   	ret    

80103dcb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103dcb:	55                   	push   %ebp
80103dcc:	89 e5                	mov    %esp,%ebp
80103dce:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	89 04 24             	mov    %eax,(%esp)
80103dd7:	e8 44 ff ff ff       	call   80103d20 <p2v>
80103ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103de2:	03 45 f0             	add    -0x10(%ebp),%eax
80103de5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dee:	eb 3f                	jmp    80103e2f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103df0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103df7:	00 
80103df8:	c7 44 24 04 5c 8f 10 	movl   $0x80108f5c,0x4(%esp)
80103dff:	80 
80103e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e03:	89 04 24             	mov    %eax,(%esp)
80103e06:	e8 2a 1a 00 00       	call   80105835 <memcmp>
80103e0b:	85 c0                	test   %eax,%eax
80103e0d:	75 1c                	jne    80103e2b <mpsearch1+0x60>
80103e0f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103e16:	00 
80103e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1a:	89 04 24             	mov    %eax,(%esp)
80103e1d:	e8 73 ff ff ff       	call   80103d95 <sum>
80103e22:	84 c0                	test   %al,%al
80103e24:	75 05                	jne    80103e2b <mpsearch1+0x60>
      return (struct mp*)p;
80103e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e29:	eb 11                	jmp    80103e3c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e2b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e32:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e35:	72 b9                	jb     80103df0 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e3c:	c9                   	leave  
80103e3d:	c3                   	ret    

80103e3e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e3e:	55                   	push   %ebp
80103e3f:	89 e5                	mov    %esp,%ebp
80103e41:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e44:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e4e:	83 c0 0f             	add    $0xf,%eax
80103e51:	0f b6 00             	movzbl (%eax),%eax
80103e54:	0f b6 c0             	movzbl %al,%eax
80103e57:	89 c2                	mov    %eax,%edx
80103e59:	c1 e2 08             	shl    $0x8,%edx
80103e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5f:	83 c0 0e             	add    $0xe,%eax
80103e62:	0f b6 00             	movzbl (%eax),%eax
80103e65:	0f b6 c0             	movzbl %al,%eax
80103e68:	09 d0                	or     %edx,%eax
80103e6a:	c1 e0 04             	shl    $0x4,%eax
80103e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e74:	74 21                	je     80103e97 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103e76:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e7d:	00 
80103e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e81:	89 04 24             	mov    %eax,(%esp)
80103e84:	e8 42 ff ff ff       	call   80103dcb <mpsearch1>
80103e89:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e8c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e90:	74 50                	je     80103ee2 <mpsearch+0xa4>
      return mp;
80103e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e95:	eb 5f                	jmp    80103ef6 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9a:	83 c0 14             	add    $0x14,%eax
80103e9d:	0f b6 00             	movzbl (%eax),%eax
80103ea0:	0f b6 c0             	movzbl %al,%eax
80103ea3:	89 c2                	mov    %eax,%edx
80103ea5:	c1 e2 08             	shl    $0x8,%edx
80103ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eab:	83 c0 13             	add    $0x13,%eax
80103eae:	0f b6 00             	movzbl (%eax),%eax
80103eb1:	0f b6 c0             	movzbl %al,%eax
80103eb4:	09 d0                	or     %edx,%eax
80103eb6:	c1 e0 0a             	shl    $0xa,%eax
80103eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ebf:	2d 00 04 00 00       	sub    $0x400,%eax
80103ec4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ecb:	00 
80103ecc:	89 04 24             	mov    %eax,(%esp)
80103ecf:	e8 f7 fe ff ff       	call   80103dcb <mpsearch1>
80103ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ed7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103edb:	74 05                	je     80103ee2 <mpsearch+0xa4>
      return mp;
80103edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee0:	eb 14                	jmp    80103ef6 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ee2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ee9:	00 
80103eea:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ef1:	e8 d5 fe ff ff       	call   80103dcb <mpsearch1>
}
80103ef6:	c9                   	leave  
80103ef7:	c3                   	ret    

80103ef8 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ef8:	55                   	push   %ebp
80103ef9:	89 e5                	mov    %esp,%ebp
80103efb:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103efe:	e8 3b ff ff ff       	call   80103e3e <mpsearch>
80103f03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f0a:	74 0a                	je     80103f16 <mpconfig+0x1e>
80103f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0f:	8b 40 04             	mov    0x4(%eax),%eax
80103f12:	85 c0                	test   %eax,%eax
80103f14:	75 0a                	jne    80103f20 <mpconfig+0x28>
    return 0;
80103f16:	b8 00 00 00 00       	mov    $0x0,%eax
80103f1b:	e9 83 00 00 00       	jmp    80103fa3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f23:	8b 40 04             	mov    0x4(%eax),%eax
80103f26:	89 04 24             	mov    %eax,(%esp)
80103f29:	e8 f2 fd ff ff       	call   80103d20 <p2v>
80103f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f31:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103f38:	00 
80103f39:	c7 44 24 04 61 8f 10 	movl   $0x80108f61,0x4(%esp)
80103f40:	80 
80103f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f44:	89 04 24             	mov    %eax,(%esp)
80103f47:	e8 e9 18 00 00       	call   80105835 <memcmp>
80103f4c:	85 c0                	test   %eax,%eax
80103f4e:	74 07                	je     80103f57 <mpconfig+0x5f>
    return 0;
80103f50:	b8 00 00 00 00       	mov    $0x0,%eax
80103f55:	eb 4c                	jmp    80103fa3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f5a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f5e:	3c 01                	cmp    $0x1,%al
80103f60:	74 12                	je     80103f74 <mpconfig+0x7c>
80103f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f65:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f69:	3c 04                	cmp    $0x4,%al
80103f6b:	74 07                	je     80103f74 <mpconfig+0x7c>
    return 0;
80103f6d:	b8 00 00 00 00       	mov    $0x0,%eax
80103f72:	eb 2f                	jmp    80103fa3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f77:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103f7b:	0f b7 c0             	movzwl %ax,%eax
80103f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f85:	89 04 24             	mov    %eax,(%esp)
80103f88:	e8 08 fe ff ff       	call   80103d95 <sum>
80103f8d:	84 c0                	test   %al,%al
80103f8f:	74 07                	je     80103f98 <mpconfig+0xa0>
    return 0;
80103f91:	b8 00 00 00 00       	mov    $0x0,%eax
80103f96:	eb 0b                	jmp    80103fa3 <mpconfig+0xab>
  *pmp = mp;
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f9e:	89 10                	mov    %edx,(%eax)
  return conf;
80103fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103fa3:	c9                   	leave  
80103fa4:	c3                   	ret    

80103fa5 <mpinit>:

void
mpinit(void)
{
80103fa5:	55                   	push   %ebp
80103fa6:	89 e5                	mov    %esp,%ebp
80103fa8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103fab:	c7 05 04 d6 10 80 e0 	movl   $0x801118e0,0x8010d604
80103fb2:	18 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103fb5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103fb8:	89 04 24             	mov    %eax,(%esp)
80103fbb:	e8 38 ff ff ff       	call   80103ef8 <mpconfig>
80103fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103fc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fc7:	0f 84 9c 01 00 00    	je     80104169 <mpinit+0x1c4>
    return;
  ismp = 1;
80103fcd:	c7 05 c4 18 11 80 01 	movl   $0x1,0x801118c4
80103fd4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fda:	8b 40 24             	mov    0x24(%eax),%eax
80103fdd:	a3 3c 18 11 80       	mov    %eax,0x8011183c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fe5:	83 c0 2c             	add    $0x2c,%eax
80103fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fee:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ff2:	0f b7 c0             	movzwl %ax,%eax
80103ff5:	03 45 f0             	add    -0x10(%ebp),%eax
80103ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ffb:	e9 f4 00 00 00       	jmp    801040f4 <mpinit+0x14f>
    switch(*p){
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	0f b6 00             	movzbl (%eax),%eax
80104006:	0f b6 c0             	movzbl %al,%eax
80104009:	83 f8 04             	cmp    $0x4,%eax
8010400c:	0f 87 bf 00 00 00    	ja     801040d1 <mpinit+0x12c>
80104012:	8b 04 85 a4 8f 10 80 	mov    -0x7fef705c(,%eax,4),%eax
80104019:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010401b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104021:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104024:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104028:	0f b6 d0             	movzbl %al,%edx
8010402b:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80104030:	39 c2                	cmp    %eax,%edx
80104032:	74 2d                	je     80104061 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104034:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104037:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010403b:	0f b6 d0             	movzbl %al,%edx
8010403e:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80104043:	89 54 24 08          	mov    %edx,0x8(%esp)
80104047:	89 44 24 04          	mov    %eax,0x4(%esp)
8010404b:	c7 04 24 66 8f 10 80 	movl   $0x80108f66,(%esp)
80104052:	e8 4a c3 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80104057:	c7 05 c4 18 11 80 00 	movl   $0x0,0x801118c4
8010405e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104061:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104064:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104068:	0f b6 c0             	movzbl %al,%eax
8010406b:	83 e0 02             	and    $0x2,%eax
8010406e:	85 c0                	test   %eax,%eax
80104070:	74 15                	je     80104087 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80104072:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80104077:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010407d:	05 e0 18 11 80       	add    $0x801118e0,%eax
80104082:	a3 04 d6 10 80       	mov    %eax,0x8010d604
      cpus[ncpu].id = ncpu;
80104087:	8b 15 c0 1e 11 80    	mov    0x80111ec0,%edx
8010408d:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
80104092:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104098:	81 c2 e0 18 11 80    	add    $0x801118e0,%edx
8010409e:	88 02                	mov    %al,(%edx)
      ncpu++;
801040a0:	a1 c0 1e 11 80       	mov    0x80111ec0,%eax
801040a5:	83 c0 01             	add    $0x1,%eax
801040a8:	a3 c0 1e 11 80       	mov    %eax,0x80111ec0
      p += sizeof(struct mpproc);
801040ad:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801040b1:	eb 41                	jmp    801040f4 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801040b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801040bc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040c0:	a2 c0 18 11 80       	mov    %al,0x801118c0
      p += sizeof(struct mpioapic);
801040c5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040c9:	eb 29                	jmp    801040f4 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801040cb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040cf:	eb 23                	jmp    801040f4 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	0f b6 00             	movzbl (%eax),%eax
801040d7:	0f b6 c0             	movzbl %al,%eax
801040da:	89 44 24 04          	mov    %eax,0x4(%esp)
801040de:	c7 04 24 84 8f 10 80 	movl   $0x80108f84,(%esp)
801040e5:	e8 b7 c2 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801040ea:	c7 05 c4 18 11 80 00 	movl   $0x0,0x801118c4
801040f1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801040fa:	0f 82 00 ff ff ff    	jb     80104000 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104100:	a1 c4 18 11 80       	mov    0x801118c4,%eax
80104105:	85 c0                	test   %eax,%eax
80104107:	75 1d                	jne    80104126 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104109:	c7 05 c0 1e 11 80 01 	movl   $0x1,0x80111ec0
80104110:	00 00 00 
    lapic = 0;
80104113:	c7 05 3c 18 11 80 00 	movl   $0x0,0x8011183c
8010411a:	00 00 00 
    ioapicid = 0;
8010411d:	c6 05 c0 18 11 80 00 	movb   $0x0,0x801118c0
    return;
80104124:	eb 44                	jmp    8010416a <mpinit+0x1c5>
  }

  if(mp->imcrp){
80104126:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104129:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010412d:	84 c0                	test   %al,%al
8010412f:	74 39                	je     8010416a <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104131:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104138:	00 
80104139:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104140:	e8 12 fc ff ff       	call   80103d57 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104145:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010414c:	e8 dc fb ff ff       	call   80103d2d <inb>
80104151:	83 c8 01             	or     $0x1,%eax
80104154:	0f b6 c0             	movzbl %al,%eax
80104157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010415b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104162:	e8 f0 fb ff ff       	call   80103d57 <outb>
80104167:	eb 01                	jmp    8010416a <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104169:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010416a:	c9                   	leave  
8010416b:	c3                   	ret    

8010416c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010416c:	55                   	push   %ebp
8010416d:	89 e5                	mov    %esp,%ebp
8010416f:	83 ec 08             	sub    $0x8,%esp
80104172:	8b 55 08             	mov    0x8(%ebp),%edx
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010417c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010417f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104183:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104187:	ee                   	out    %al,(%dx)
}
80104188:	c9                   	leave  
80104189:	c3                   	ret    

8010418a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010418a:	55                   	push   %ebp
8010418b:	89 e5                	mov    %esp,%ebp
8010418d:	83 ec 0c             	sub    $0xc,%esp
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104197:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010419b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
801041a1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041a5:	0f b6 c0             	movzbl %al,%eax
801041a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ac:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801041b3:	e8 b4 ff ff ff       	call   8010416c <outb>
  outb(IO_PIC2+1, mask >> 8);
801041b8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041bc:	66 c1 e8 08          	shr    $0x8,%ax
801041c0:	0f b6 c0             	movzbl %al,%eax
801041c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801041c7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801041ce:	e8 99 ff ff ff       	call   8010416c <outb>
}
801041d3:	c9                   	leave  
801041d4:	c3                   	ret    

801041d5 <picenable>:

void
picenable(int irq)
{
801041d5:	55                   	push   %ebp
801041d6:	89 e5                	mov    %esp,%ebp
801041d8:	53                   	push   %ebx
801041d9:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
801041dc:	8b 45 08             	mov    0x8(%ebp),%eax
801041df:	ba 01 00 00 00       	mov    $0x1,%edx
801041e4:	89 d3                	mov    %edx,%ebx
801041e6:	89 c1                	mov    %eax,%ecx
801041e8:	d3 e3                	shl    %cl,%ebx
801041ea:	89 d8                	mov    %ebx,%eax
801041ec:	89 c2                	mov    %eax,%edx
801041ee:	f7 d2                	not    %edx
801041f0:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801041f7:	21 d0                	and    %edx,%eax
801041f9:	0f b7 c0             	movzwl %ax,%eax
801041fc:	89 04 24             	mov    %eax,(%esp)
801041ff:	e8 86 ff ff ff       	call   8010418a <picsetmask>
}
80104204:	83 c4 04             	add    $0x4,%esp
80104207:	5b                   	pop    %ebx
80104208:	5d                   	pop    %ebp
80104209:	c3                   	ret    

8010420a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010420a:	55                   	push   %ebp
8010420b:	89 e5                	mov    %esp,%ebp
8010420d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104210:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104217:	00 
80104218:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010421f:	e8 48 ff ff ff       	call   8010416c <outb>
  outb(IO_PIC2+1, 0xFF);
80104224:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010422b:	00 
8010422c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104233:	e8 34 ff ff ff       	call   8010416c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104238:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010423f:	00 
80104240:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104247:	e8 20 ff ff ff       	call   8010416c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010424c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104253:	00 
80104254:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010425b:	e8 0c ff ff ff       	call   8010416c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104260:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104267:	00 
80104268:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010426f:	e8 f8 fe ff ff       	call   8010416c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104274:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010427b:	00 
8010427c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104283:	e8 e4 fe ff ff       	call   8010416c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104288:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010428f:	00 
80104290:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104297:	e8 d0 fe ff ff       	call   8010416c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010429c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
801042a3:	00 
801042a4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042ab:	e8 bc fe ff ff       	call   8010416c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801042b0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801042b7:	00 
801042b8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042bf:	e8 a8 fe ff ff       	call   8010416c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801042c4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801042cb:	00 
801042cc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042d3:	e8 94 fe ff ff       	call   8010416c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801042d8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801042df:	00 
801042e0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801042e7:	e8 80 fe ff ff       	call   8010416c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801042ec:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801042f3:	00 
801042f4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801042fb:	e8 6c fe ff ff       	call   8010416c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104300:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104307:	00 
80104308:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010430f:	e8 58 fe ff ff       	call   8010416c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104314:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010431b:	00 
8010431c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104323:	e8 44 fe ff ff       	call   8010416c <outb>

  if(irqmask != 0xFFFF)
80104328:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010432f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104333:	74 12                	je     80104347 <picinit+0x13d>
    picsetmask(irqmask);
80104335:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
8010433c:	0f b7 c0             	movzwl %ax,%eax
8010433f:	89 04 24             	mov    %eax,(%esp)
80104342:	e8 43 fe ff ff       	call   8010418a <picsetmask>
}
80104347:	c9                   	leave  
80104348:	c3                   	ret    
80104349:	00 00                	add    %al,(%eax)
	...

8010434c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010434c:	55                   	push   %ebp
8010434d:	89 e5                	mov    %esp,%ebp
8010434f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104359:	8b 45 0c             	mov    0xc(%ebp),%eax
8010435c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104362:	8b 45 0c             	mov    0xc(%ebp),%eax
80104365:	8b 10                	mov    (%eax),%edx
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010436c:	e8 bf d2 ff ff       	call   80101630 <filealloc>
80104371:	8b 55 08             	mov    0x8(%ebp),%edx
80104374:	89 02                	mov    %eax,(%edx)
80104376:	8b 45 08             	mov    0x8(%ebp),%eax
80104379:	8b 00                	mov    (%eax),%eax
8010437b:	85 c0                	test   %eax,%eax
8010437d:	0f 84 c8 00 00 00    	je     8010444b <pipealloc+0xff>
80104383:	e8 a8 d2 ff ff       	call   80101630 <filealloc>
80104388:	8b 55 0c             	mov    0xc(%ebp),%edx
8010438b:	89 02                	mov    %eax,(%edx)
8010438d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104390:	8b 00                	mov    (%eax),%eax
80104392:	85 c0                	test   %eax,%eax
80104394:	0f 84 b1 00 00 00    	je     8010444b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010439a:	e8 74 ee ff ff       	call   80103213 <kalloc>
8010439f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043a6:	0f 84 9e 00 00 00    	je     8010444a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
801043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043af:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801043b6:	00 00 00 
  p->writeopen = 1;
801043b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bc:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801043c3:	00 00 00 
  p->nwrite = 0;
801043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801043d0:	00 00 00 
  p->nread = 0;
801043d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801043dd:	00 00 00 
  initlock(&p->lock, "pipe");
801043e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e3:	c7 44 24 04 b8 8f 10 	movl   $0x80108fb8,0x4(%esp)
801043ea:	80 
801043eb:	89 04 24             	mov    %eax,(%esp)
801043ee:	e8 5b 11 00 00       	call   8010554e <initlock>
  (*f0)->type = FD_PIPE;
801043f3:	8b 45 08             	mov    0x8(%ebp),%eax
801043f6:	8b 00                	mov    (%eax),%eax
801043f8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801043fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104401:	8b 00                	mov    (%eax),%eax
80104403:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104407:	8b 45 08             	mov    0x8(%ebp),%eax
8010440a:	8b 00                	mov    (%eax),%eax
8010440c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104410:	8b 45 08             	mov    0x8(%ebp),%eax
80104413:	8b 00                	mov    (%eax),%eax
80104415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104418:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010441b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010441e:	8b 00                	mov    (%eax),%eax
80104420:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104426:	8b 45 0c             	mov    0xc(%ebp),%eax
80104429:	8b 00                	mov    (%eax),%eax
8010442b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010442f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104432:	8b 00                	mov    (%eax),%eax
80104434:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010443b:	8b 00                	mov    (%eax),%eax
8010443d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104440:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104443:	b8 00 00 00 00       	mov    $0x0,%eax
80104448:	eb 43                	jmp    8010448d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010444a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010444b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010444f:	74 0b                	je     8010445c <pipealloc+0x110>
    kfree((char*)p);
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	89 04 24             	mov    %eax,(%esp)
80104457:	e8 1e ed ff ff       	call   8010317a <kfree>
  if(*f0)
8010445c:	8b 45 08             	mov    0x8(%ebp),%eax
8010445f:	8b 00                	mov    (%eax),%eax
80104461:	85 c0                	test   %eax,%eax
80104463:	74 0d                	je     80104472 <pipealloc+0x126>
    fileclose(*f0);
80104465:	8b 45 08             	mov    0x8(%ebp),%eax
80104468:	8b 00                	mov    (%eax),%eax
8010446a:	89 04 24             	mov    %eax,(%esp)
8010446d:	e8 66 d2 ff ff       	call   801016d8 <fileclose>
  if(*f1)
80104472:	8b 45 0c             	mov    0xc(%ebp),%eax
80104475:	8b 00                	mov    (%eax),%eax
80104477:	85 c0                	test   %eax,%eax
80104479:	74 0d                	je     80104488 <pipealloc+0x13c>
    fileclose(*f1);
8010447b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010447e:	8b 00                	mov    (%eax),%eax
80104480:	89 04 24             	mov    %eax,(%esp)
80104483:	e8 50 d2 ff ff       	call   801016d8 <fileclose>
  return -1;
80104488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010448d:	c9                   	leave  
8010448e:	c3                   	ret    

8010448f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010448f:	55                   	push   %ebp
80104490:	89 e5                	mov    %esp,%ebp
80104492:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104495:	8b 45 08             	mov    0x8(%ebp),%eax
80104498:	89 04 24             	mov    %eax,(%esp)
8010449b:	e8 cf 10 00 00       	call   8010556f <acquire>
  if(writable){
801044a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044a4:	74 1f                	je     801044c5 <pipeclose+0x36>
    p->writeopen = 0;
801044a6:	8b 45 08             	mov    0x8(%ebp),%eax
801044a9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801044b0:	00 00 00 
    wakeup(&p->nread);
801044b3:	8b 45 08             	mov    0x8(%ebp),%eax
801044b6:	05 34 02 00 00       	add    $0x234,%eax
801044bb:	89 04 24             	mov    %eax,(%esp)
801044be:	e8 a2 0e 00 00       	call   80105365 <wakeup>
801044c3:	eb 1d                	jmp    801044e2 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801044cf:	00 00 00 
    wakeup(&p->nwrite);
801044d2:	8b 45 08             	mov    0x8(%ebp),%eax
801044d5:	05 38 02 00 00       	add    $0x238,%eax
801044da:	89 04 24             	mov    %eax,(%esp)
801044dd:	e8 83 0e 00 00       	call   80105365 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801044e2:	8b 45 08             	mov    0x8(%ebp),%eax
801044e5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801044eb:	85 c0                	test   %eax,%eax
801044ed:	75 25                	jne    80104514 <pipeclose+0x85>
801044ef:	8b 45 08             	mov    0x8(%ebp),%eax
801044f2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801044f8:	85 c0                	test   %eax,%eax
801044fa:	75 18                	jne    80104514 <pipeclose+0x85>
    release(&p->lock);
801044fc:	8b 45 08             	mov    0x8(%ebp),%eax
801044ff:	89 04 24             	mov    %eax,(%esp)
80104502:	e8 ca 10 00 00       	call   801055d1 <release>
    kfree((char*)p);
80104507:	8b 45 08             	mov    0x8(%ebp),%eax
8010450a:	89 04 24             	mov    %eax,(%esp)
8010450d:	e8 68 ec ff ff       	call   8010317a <kfree>
80104512:	eb 0b                	jmp    8010451f <pipeclose+0x90>
  } else
    release(&p->lock);
80104514:	8b 45 08             	mov    0x8(%ebp),%eax
80104517:	89 04 24             	mov    %eax,(%esp)
8010451a:	e8 b2 10 00 00       	call   801055d1 <release>
}
8010451f:	c9                   	leave  
80104520:	c3                   	ret    

80104521 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104521:	55                   	push   %ebp
80104522:	89 e5                	mov    %esp,%ebp
80104524:	53                   	push   %ebx
80104525:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104528:	8b 45 08             	mov    0x8(%ebp),%eax
8010452b:	89 04 24             	mov    %eax,(%esp)
8010452e:	e8 3c 10 00 00       	call   8010556f <acquire>
  for(i = 0; i < n; i++){
80104533:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010453a:	e9 a6 00 00 00       	jmp    801045e5 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010453f:	8b 45 08             	mov    0x8(%ebp),%eax
80104542:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104548:	85 c0                	test   %eax,%eax
8010454a:	74 0d                	je     80104559 <pipewrite+0x38>
8010454c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104552:	8b 40 24             	mov    0x24(%eax),%eax
80104555:	85 c0                	test   %eax,%eax
80104557:	74 15                	je     8010456e <pipewrite+0x4d>
        release(&p->lock);
80104559:	8b 45 08             	mov    0x8(%ebp),%eax
8010455c:	89 04 24             	mov    %eax,(%esp)
8010455f:	e8 6d 10 00 00       	call   801055d1 <release>
        return -1;
80104564:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104569:	e9 9d 00 00 00       	jmp    8010460b <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010456e:	8b 45 08             	mov    0x8(%ebp),%eax
80104571:	05 34 02 00 00       	add    $0x234,%eax
80104576:	89 04 24             	mov    %eax,(%esp)
80104579:	e8 e7 0d 00 00       	call   80105365 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010457e:	8b 45 08             	mov    0x8(%ebp),%eax
80104581:	8b 55 08             	mov    0x8(%ebp),%edx
80104584:	81 c2 38 02 00 00    	add    $0x238,%edx
8010458a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010458e:	89 14 24             	mov    %edx,(%esp)
80104591:	e8 61 0c 00 00       	call   801051f7 <sleep>
80104596:	eb 01                	jmp    80104599 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104598:	90                   	nop
80104599:	8b 45 08             	mov    0x8(%ebp),%eax
8010459c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801045a2:	8b 45 08             	mov    0x8(%ebp),%eax
801045a5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801045ab:	05 00 02 00 00       	add    $0x200,%eax
801045b0:	39 c2                	cmp    %eax,%edx
801045b2:	74 8b                	je     8010453f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801045b4:	8b 45 08             	mov    0x8(%ebp),%eax
801045b7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801045bd:	89 c3                	mov    %eax,%ebx
801045bf:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801045c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c8:	03 55 0c             	add    0xc(%ebp),%edx
801045cb:	0f b6 0a             	movzbl (%edx),%ecx
801045ce:	8b 55 08             	mov    0x8(%ebp),%edx
801045d1:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
801045d5:	8d 50 01             	lea    0x1(%eax),%edx
801045d8:	8b 45 08             	mov    0x8(%ebp),%eax
801045db:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801045e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801045e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e8:	3b 45 10             	cmp    0x10(%ebp),%eax
801045eb:	7c ab                	jl     80104598 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801045ed:	8b 45 08             	mov    0x8(%ebp),%eax
801045f0:	05 34 02 00 00       	add    $0x234,%eax
801045f5:	89 04 24             	mov    %eax,(%esp)
801045f8:	e8 68 0d 00 00       	call   80105365 <wakeup>
  release(&p->lock);
801045fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104600:	89 04 24             	mov    %eax,(%esp)
80104603:	e8 c9 0f 00 00       	call   801055d1 <release>
  return n;
80104608:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010460b:	83 c4 24             	add    $0x24,%esp
8010460e:	5b                   	pop    %ebx
8010460f:	5d                   	pop    %ebp
80104610:	c3                   	ret    

80104611 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104611:	55                   	push   %ebp
80104612:	89 e5                	mov    %esp,%ebp
80104614:	53                   	push   %ebx
80104615:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104618:	8b 45 08             	mov    0x8(%ebp),%eax
8010461b:	89 04 24             	mov    %eax,(%esp)
8010461e:	e8 4c 0f 00 00       	call   8010556f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104623:	eb 3a                	jmp    8010465f <piperead+0x4e>
    if(proc->killed){
80104625:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010462b:	8b 40 24             	mov    0x24(%eax),%eax
8010462e:	85 c0                	test   %eax,%eax
80104630:	74 15                	je     80104647 <piperead+0x36>
      release(&p->lock);
80104632:	8b 45 08             	mov    0x8(%ebp),%eax
80104635:	89 04 24             	mov    %eax,(%esp)
80104638:	e8 94 0f 00 00       	call   801055d1 <release>
      return -1;
8010463d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104642:	e9 b6 00 00 00       	jmp    801046fd <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104647:	8b 45 08             	mov    0x8(%ebp),%eax
8010464a:	8b 55 08             	mov    0x8(%ebp),%edx
8010464d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104653:	89 44 24 04          	mov    %eax,0x4(%esp)
80104657:	89 14 24             	mov    %edx,(%esp)
8010465a:	e8 98 0b 00 00       	call   801051f7 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010465f:	8b 45 08             	mov    0x8(%ebp),%eax
80104662:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104668:	8b 45 08             	mov    0x8(%ebp),%eax
8010466b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104671:	39 c2                	cmp    %eax,%edx
80104673:	75 0d                	jne    80104682 <piperead+0x71>
80104675:	8b 45 08             	mov    0x8(%ebp),%eax
80104678:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010467e:	85 c0                	test   %eax,%eax
80104680:	75 a3                	jne    80104625 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104689:	eb 49                	jmp    801046d4 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010468b:	8b 45 08             	mov    0x8(%ebp),%eax
8010468e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104694:	8b 45 08             	mov    0x8(%ebp),%eax
80104697:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010469d:	39 c2                	cmp    %eax,%edx
8010469f:	74 3d                	je     801046de <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	89 c2                	mov    %eax,%edx
801046a6:	03 55 0c             	add    0xc(%ebp),%edx
801046a9:	8b 45 08             	mov    0x8(%ebp),%eax
801046ac:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801046b2:	89 c3                	mov    %eax,%ebx
801046b4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801046ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046bd:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
801046c2:	88 0a                	mov    %cl,(%edx)
801046c4:	8d 50 01             	lea    0x1(%eax),%edx
801046c7:	8b 45 08             	mov    0x8(%ebp),%eax
801046ca:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801046d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	3b 45 10             	cmp    0x10(%ebp),%eax
801046da:	7c af                	jl     8010468b <piperead+0x7a>
801046dc:	eb 01                	jmp    801046df <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801046de:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801046df:	8b 45 08             	mov    0x8(%ebp),%eax
801046e2:	05 38 02 00 00       	add    $0x238,%eax
801046e7:	89 04 24             	mov    %eax,(%esp)
801046ea:	e8 76 0c 00 00       	call   80105365 <wakeup>
  release(&p->lock);
801046ef:	8b 45 08             	mov    0x8(%ebp),%eax
801046f2:	89 04 24             	mov    %eax,(%esp)
801046f5:	e8 d7 0e 00 00       	call   801055d1 <release>
  return i;
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046fd:	83 c4 24             	add    $0x24,%esp
80104700:	5b                   	pop    %ebx
80104701:	5d                   	pop    %ebp
80104702:	c3                   	ret    
	...

80104704 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104704:	55                   	push   %ebp
80104705:	89 e5                	mov    %esp,%ebp
80104707:	53                   	push   %ebx
80104708:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010470b:	9c                   	pushf  
8010470c:	5b                   	pop    %ebx
8010470d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104710:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104713:	83 c4 10             	add    $0x10,%esp
80104716:	5b                   	pop    %ebx
80104717:	5d                   	pop    %ebp
80104718:	c3                   	ret    

80104719 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104719:	55                   	push   %ebp
8010471a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010471c:	fb                   	sti    
}
8010471d:	5d                   	pop    %ebp
8010471e:	c3                   	ret    

8010471f <pinit>:
      release(&ptable.lock); 
} */

void
pinit(void)
{
8010471f:	55                   	push   %ebp
80104720:	89 e5                	mov    %esp,%ebp
80104722:	83 ec 18             	sub    $0x18,%esp
  ptable.FRR_COUNTER = 0;
80104725:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
8010472c:	00 00 00 
  initlock(&ptable.lock, "ptable");
8010472f:	c7 44 24 04 bd 8f 10 	movl   $0x80108fbd,0x4(%esp)
80104736:	80 
80104737:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
8010473e:	e8 0b 0e 00 00       	call   8010554e <initlock>
}
80104743:	c9                   	leave  
80104744:	c3                   	ret    

80104745 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104745:	55                   	push   %ebp
80104746:	89 e5                	mov    %esp,%ebp
80104748:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;  
  acquire(&ptable.lock);
8010474b:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104752:	e8 18 0e 00 00       	call   8010556f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104757:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
8010475e:	eb 11                	jmp    80104771 <allocproc+0x2c>
    if(p->state == UNUSED)
80104760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104763:	8b 40 0c             	mov    0xc(%eax),%eax
80104766:	85 c0                	test   %eax,%eax
80104768:	74 26                	je     80104790 <allocproc+0x4b>
allocproc(void)
{
  struct proc *p;
  char *sp;  
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010476a:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104771:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
80104778:	72 e6                	jb     80104760 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010477a:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104781:	e8 4b 0e 00 00       	call   801055d1 <release>
  return 0;
80104786:	b8 00 00 00 00       	mov    $0x0,%eax
8010478b:	e9 26 01 00 00       	jmp    801048b6 <allocproc+0x171>
  struct proc *p;
  char *sp;  
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104790:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010479b:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801047a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a3:	89 42 10             	mov    %eax,0x10(%edx)
801047a6:	83 c0 01             	add    $0x1,%eax
801047a9:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  p->priority = MEDIUM;
801047ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b1:	c7 80 9c 00 00 00 02 	movl   $0x2,0x9c(%eax)
801047b8:	00 00 00 
  p->queuenum = ptable.FRR_COUNTER++;
801047bb:	a1 14 47 11 80       	mov    0x80114714,%eax
801047c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047c3:	89 82 98 00 00 00    	mov    %eax,0x98(%edx)
801047c9:	83 c0 01             	add    $0x1,%eax
801047cc:	a3 14 47 11 80       	mov    %eax,0x80114714
  p->iotime = 0;
801047d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d4:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
801047db:	00 00 00 
  p->wtime = 0;
801047de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e1:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801047e8:	00 00 00 
  p->rtime = 0;
801047eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ee:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
801047f5:	00 00 00 
  p->etime = 0;
801047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fb:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104802:	00 00 00 
  p->sleeptime = 0;
80104805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104808:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010480f:	00 00 00 
  release(&ptable.lock);
80104812:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104819:	e8 b3 0d 00 00       	call   801055d1 <release>
  
  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010481e:	e8 f0 e9 ff ff       	call   80103213 <kalloc>
80104823:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104826:	89 42 08             	mov    %eax,0x8(%edx)
80104829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482c:	8b 40 08             	mov    0x8(%eax),%eax
8010482f:	85 c0                	test   %eax,%eax
80104831:	75 11                	jne    80104844 <allocproc+0xff>
    p->state = UNUSED;
80104833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104836:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010483d:	b8 00 00 00 00       	mov    $0x0,%eax
80104842:	eb 72                	jmp    801048b6 <allocproc+0x171>
  }
  sp = p->kstack + KSTACKSIZE;
80104844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104847:	8b 40 08             	mov    0x8(%eax),%eax
8010484a:	05 00 10 00 00       	add    $0x1000,%eax
8010484f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104852:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104859:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010485c:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010485f:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104863:	ba dc 6c 10 80       	mov    $0x80106cdc,%edx
80104868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010486d:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104874:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104877:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010487a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104880:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104887:	00 
80104888:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010488f:	00 
80104890:	89 04 24             	mov    %eax,(%esp)
80104893:	e8 26 0f 00 00       	call   801057be <memset>
  p->context->eip = (uint)forkret;
80104898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010489e:	ba cb 51 10 80       	mov    $0x801051cb,%edx
801048a3:	89 50 10             	mov    %edx,0x10(%eax)
  
  // S
  //acquire(&tickslock);
  p->ctime = ticks; 
801048a6:	a1 60 4f 11 80       	mov    0x80114f60,%eax
801048ab:	89 c2                	mov    %eax,%edx
801048ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b0:	89 50 7c             	mov    %edx,0x7c(%eax)
  //release(&tickslock);
  
  return p;
801048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801048b6:	c9                   	leave  
801048b7:	c3                   	ret    

801048b8 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801048b8:	55                   	push   %ebp
801048b9:	89 e5                	mov    %esp,%ebp
801048bb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801048be:	e8 82 fe ff ff       	call   80104745 <allocproc>
801048c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	a3 08 d6 10 80       	mov    %eax,0x8010d608
  if((p->pgdir = setupkvm(kalloc)) == 0)
801048ce:	c7 04 24 13 32 10 80 	movl   $0x80103213,(%esp)
801048d5:	e8 c7 3b 00 00       	call   801084a1 <setupkvm>
801048da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048dd:	89 42 04             	mov    %eax,0x4(%edx)
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 40 04             	mov    0x4(%eax),%eax
801048e6:	85 c0                	test   %eax,%eax
801048e8:	75 0c                	jne    801048f6 <userinit+0x3e>
    panic("userinit: out of memory?");
801048ea:	c7 04 24 c4 8f 10 80 	movl   $0x80108fc4,(%esp)
801048f1:	e8 47 bc ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801048f6:	ba 2c 00 00 00       	mov    $0x2c,%edx
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	8b 40 04             	mov    0x4(%eax),%eax
80104901:	89 54 24 08          	mov    %edx,0x8(%esp)
80104905:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
8010490c:	80 
8010490d:	89 04 24             	mov    %eax,(%esp)
80104910:	e8 e4 3d 00 00       	call   801086f9 <inituvm>
  p->sz = PGSIZE;
80104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104918:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010491e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104921:	8b 40 18             	mov    0x18(%eax),%eax
80104924:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010492b:	00 
8010492c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104933:	00 
80104934:	89 04 24             	mov    %eax,(%esp)
80104937:	e8 82 0e 00 00       	call   801057be <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 18             	mov    0x18(%eax),%eax
80104942:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494b:	8b 40 18             	mov    0x18(%eax),%eax
8010494e:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104957:	8b 40 18             	mov    0x18(%eax),%eax
8010495a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010495d:	8b 52 18             	mov    0x18(%edx),%edx
80104960:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104964:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496b:	8b 40 18             	mov    0x18(%eax),%eax
8010496e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104971:	8b 52 18             	mov    0x18(%edx),%edx
80104974:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104978:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010497c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497f:	8b 40 18             	mov    0x18(%eax),%eax
80104982:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498c:	8b 40 18             	mov    0x18(%eax),%eax
8010498f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104999:	8b 40 18             	mov    0x18(%eax),%eax
8010499c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801049a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a6:	83 c0 6c             	add    $0x6c,%eax
801049a9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801049b0:	00 
801049b1:	c7 44 24 04 dd 8f 10 	movl   $0x80108fdd,0x4(%esp)
801049b8:	80 
801049b9:	89 04 24             	mov    %eax,(%esp)
801049bc:	e8 2d 10 00 00       	call   801059ee <safestrcpy>
  p->cwd = namei("/");
801049c1:	c7 04 24 e6 8f 10 80 	movl   $0x80108fe6,(%esp)
801049c8:	e8 51 e1 ff ff       	call   80102b1e <namei>
801049cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d0:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801049d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801049dd:	c9                   	leave  
801049de:	c3                   	ret    

801049df <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801049df:	55                   	push   %ebp
801049e0:	89 e5                	mov    %esp,%ebp
801049e2:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801049e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049eb:	8b 00                	mov    (%eax),%eax
801049ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801049f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049f4:	7e 34                	jle    80104a2a <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
801049f9:	89 c2                	mov    %eax,%edx
801049fb:	03 55 f4             	add    -0xc(%ebp),%edx
801049fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a04:	8b 40 04             	mov    0x4(%eax),%eax
80104a07:	89 54 24 08          	mov    %edx,0x8(%esp)
80104a0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a12:	89 04 24             	mov    %eax,(%esp)
80104a15:	e8 59 3e 00 00       	call   80108873 <allocuvm>
80104a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a21:	75 41                	jne    80104a64 <growproc+0x85>
      return -1;
80104a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a28:	eb 58                	jmp    80104a82 <growproc+0xa3>
  } else if(n < 0){
80104a2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a2e:	79 34                	jns    80104a64 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a30:	8b 45 08             	mov    0x8(%ebp),%eax
80104a33:	89 c2                	mov    %eax,%edx
80104a35:	03 55 f4             	add    -0xc(%ebp),%edx
80104a38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3e:	8b 40 04             	mov    0x4(%eax),%eax
80104a41:	89 54 24 08          	mov    %edx,0x8(%esp)
80104a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a48:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a4c:	89 04 24             	mov    %eax,(%esp)
80104a4f:	e8 f9 3e 00 00       	call   8010894d <deallocuvm>
80104a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a5b:	75 07                	jne    80104a64 <growproc+0x85>
      return -1;
80104a5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a62:	eb 1e                	jmp    80104a82 <growproc+0xa3>
  }
  proc->sz = sz;
80104a64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a6d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104a6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a75:	89 04 24             	mov    %eax,(%esp)
80104a78:	e8 15 3b 00 00       	call   80108592 <switchuvm>
  return 0;
80104a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a82:	c9                   	leave  
80104a83:	c3                   	ret    

80104a84 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104a84:	55                   	push   %ebp
80104a85:	89 e5                	mov    %esp,%ebp
80104a87:	57                   	push   %edi
80104a88:	56                   	push   %esi
80104a89:	53                   	push   %ebx
80104a8a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104a8d:	e8 b3 fc ff ff       	call   80104745 <allocproc>
80104a92:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104a95:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a99:	75 0a                	jne    80104aa5 <fork+0x21>
    return -1;
80104a9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa0:	e9 3a 01 00 00       	jmp    80104bdf <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104aa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aab:	8b 10                	mov    (%eax),%edx
80104aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab3:	8b 40 04             	mov    0x4(%eax),%eax
80104ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80104aba:	89 04 24             	mov    %eax,(%esp)
80104abd:	e8 1b 40 00 00       	call   80108add <copyuvm>
80104ac2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104ac5:	89 42 04             	mov    %eax,0x4(%edx)
80104ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104acb:	8b 40 04             	mov    0x4(%eax),%eax
80104ace:	85 c0                	test   %eax,%eax
80104ad0:	75 2c                	jne    80104afe <fork+0x7a>
    kfree(np->kstack);
80104ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ad5:	8b 40 08             	mov    0x8(%eax),%eax
80104ad8:	89 04 24             	mov    %eax,(%esp)
80104adb:	e8 9a e6 ff ff       	call   8010317a <kfree>
    np->kstack = 0;
80104ae0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ae3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104aea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af9:	e9 e1 00 00 00       	jmp    80104bdf <fork+0x15b>
  }
  np->sz = proc->sz;
80104afe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b04:	8b 10                	mov    (%eax),%edx
80104b06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b09:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104b0b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b15:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b1b:	8b 50 18             	mov    0x18(%eax),%edx
80104b1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b24:	8b 40 18             	mov    0x18(%eax),%eax
80104b27:	89 c3                	mov    %eax,%ebx
80104b29:	b8 13 00 00 00       	mov    $0x13,%eax
80104b2e:	89 d7                	mov    %edx,%edi
80104b30:	89 de                	mov    %ebx,%esi
80104b32:	89 c1                	mov    %eax,%ecx
80104b34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104b36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b39:	8b 40 18             	mov    0x18(%eax),%eax
80104b3c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104b43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104b4a:	eb 3d                	jmp    80104b89 <fork+0x105>
    if(proc->ofile[i])
80104b4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b55:	83 c2 08             	add    $0x8,%edx
80104b58:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	74 25                	je     80104b85 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b69:	83 c2 08             	add    $0x8,%edx
80104b6c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b70:	89 04 24             	mov    %eax,(%esp)
80104b73:	e8 18 cb ff ff       	call   80101690 <filedup>
80104b78:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104b7b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104b7e:	83 c1 08             	add    $0x8,%ecx
80104b81:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104b85:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104b89:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104b8d:	7e bd                	jle    80104b4c <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104b8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b95:	8b 40 68             	mov    0x68(%eax),%eax
80104b98:	89 04 24             	mov    %eax,(%esp)
80104b9b:	e8 aa d3 ff ff       	call   80101f4a <idup>
80104ba0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104ba3:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104ba6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ba9:	8b 40 10             	mov    0x10(%eax),%eax
80104bac:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104baf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bb2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104bb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbf:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc5:	83 c0 6c             	add    $0x6c,%eax
80104bc8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104bcf:	00 
80104bd0:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bd4:	89 04 24             	mov    %eax,(%esp)
80104bd7:	e8 12 0e 00 00       	call   801059ee <safestrcpy>
  return pid;
80104bdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104bdf:	83 c4 2c             	add    $0x2c,%esp
80104be2:	5b                   	pop    %ebx
80104be3:	5e                   	pop    %esi
80104be4:	5f                   	pop    %edi
80104be5:	5d                   	pop    %ebp
80104be6:	c3                   	ret    

80104be7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104be7:	55                   	push   %ebp
80104be8:	89 e5                	mov    %esp,%ebp
80104bea:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104bed:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bf4:	a1 08 d6 10 80       	mov    0x8010d608,%eax
80104bf9:	39 c2                	cmp    %eax,%edx
80104bfb:	75 0c                	jne    80104c09 <exit+0x22>
    panic("init exiting");
80104bfd:	c7 04 24 e8 8f 10 80 	movl   $0x80108fe8,(%esp)
80104c04:	e8 34 b9 ff ff       	call   8010053d <panic>
  
     
  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104c09:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104c10:	eb 44                	jmp    80104c56 <exit+0x6f>
    if(proc->ofile[fd]){
80104c12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c18:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c1b:	83 c2 08             	add    $0x8,%edx
80104c1e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c22:	85 c0                	test   %eax,%eax
80104c24:	74 2c                	je     80104c52 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104c26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c2f:	83 c2 08             	add    $0x8,%edx
80104c32:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c36:	89 04 24             	mov    %eax,(%esp)
80104c39:	e8 9a ca ff ff       	call   801016d8 <fileclose>
      proc->ofile[fd] = 0;
80104c3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c44:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c47:	83 c2 08             	add    $0x8,%edx
80104c4a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104c51:	00 
  if(proc == initproc)
    panic("init exiting");
  
     
  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104c52:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104c56:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104c5a:	7e b6                	jle    80104c12 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104c5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c62:	8b 40 68             	mov    0x68(%eax),%eax
80104c65:	89 04 24             	mov    %eax,(%esp)
80104c68:	e8 c2 d4 ff ff       	call   8010212f <iput>
  proc->cwd = 0;
80104c6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c73:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104c7a:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104c81:	e8 e9 08 00 00       	call   8010556f <acquire>
  
  // Set end time of process
  //acquire(&tickslock);
  proc->etime = ticks;
80104c86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c8c:	8b 15 60 4f 11 80    	mov    0x80114f60,%edx
80104c92:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  //release(&tickslock);
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104c98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c9e:	8b 40 14             	mov    0x14(%eax),%eax
80104ca1:	89 04 24             	mov    %eax,(%esp)
80104ca4:	e8 05 06 00 00       	call   801052ae <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca9:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
80104cb0:	eb 3b                	jmp    80104ced <exit+0x106>
    if(p->parent == proc){
80104cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb5:	8b 50 14             	mov    0x14(%eax),%edx
80104cb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cbe:	39 c2                	cmp    %eax,%edx
80104cc0:	75 24                	jne    80104ce6 <exit+0xff>
      p->parent = initproc;
80104cc2:	8b 15 08 d6 10 80    	mov    0x8010d608,%edx
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd1:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd4:	83 f8 05             	cmp    $0x5,%eax
80104cd7:	75 0d                	jne    80104ce6 <exit+0xff>
        wakeup1(initproc);
80104cd9:	a1 08 d6 10 80       	mov    0x8010d608,%eax
80104cde:	89 04 24             	mov    %eax,(%esp)
80104ce1:	e8 c8 05 00 00       	call   801052ae <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce6:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104ced:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
80104cf4:	72 bc                	jb     80104cb2 <exit+0xcb>
    }
  }

    
  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104cf6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cfc:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104d03:	e8 c5 03 00 00       	call   801050cd <sched>
  panic("zombie exit");
80104d08:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
80104d0f:	e8 29 b8 ff ff       	call   8010053d <panic>

80104d14 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104d1a:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104d21:	e8 49 08 00 00       	call   8010556f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104d26:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2d:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
80104d34:	e9 9d 00 00 00       	jmp    80104dd6 <wait+0xc2>
      if(p->parent != proc)
80104d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3c:	8b 50 14             	mov    0x14(%eax),%edx
80104d3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d45:	39 c2                	cmp    %eax,%edx
80104d47:	0f 85 81 00 00 00    	jne    80104dce <wait+0xba>
        continue;
      havekids = 1;
80104d4d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d57:	8b 40 0c             	mov    0xc(%eax),%eax
80104d5a:	83 f8 05             	cmp    $0x5,%eax
80104d5d:	75 70                	jne    80104dcf <wait+0xbb>
        // Found one.
        pid = p->pid;
80104d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d62:	8b 40 10             	mov    0x10(%eax),%eax
80104d65:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6b:	8b 40 08             	mov    0x8(%eax),%eax
80104d6e:	89 04 24             	mov    %eax,(%esp)
80104d71:	e8 04 e4 ff ff       	call   8010317a <kfree>
        p->kstack = 0;
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d83:	8b 40 04             	mov    0x4(%eax),%eax
80104d86:	89 04 24             	mov    %eax,(%esp)
80104d89:	e8 7b 3c 00 00       	call   80108a09 <freevm>
        p->state = UNUSED;
80104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104daf:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db6:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104dbd:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104dc4:	e8 08 08 00 00       	call   801055d1 <release>
        return pid;
80104dc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dcc:	eb 56                	jmp    80104e24 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104dce:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dcf:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104dd6:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
80104ddd:	0f 82 56 ff ff ff    	jb     80104d39 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104de3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104de7:	74 0d                	je     80104df6 <wait+0xe2>
80104de9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104def:	8b 40 24             	mov    0x24(%eax),%eax
80104df2:	85 c0                	test   %eax,%eax
80104df4:	74 13                	je     80104e09 <wait+0xf5>
      release(&ptable.lock);
80104df6:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104dfd:	e8 cf 07 00 00       	call   801055d1 <release>
      return -1;
80104e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e07:	eb 1b                	jmp    80104e24 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104e09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e0f:	c7 44 24 04 e0 1e 11 	movl   $0x80111ee0,0x4(%esp)
80104e16:	80 
80104e17:	89 04 24             	mov    %eax,(%esp)
80104e1a:	e8 d8 03 00 00       	call   801051f7 <sleep>
  }
80104e1f:	e9 02 ff ff ff       	jmp    80104d26 <wait+0x12>
}
80104e24:	c9                   	leave  
80104e25:	c3                   	ret    

80104e26 <wait2>:

int
wait2(int *wtime, int *rtime, int *iotime)
{
80104e26:	55                   	push   %ebp
80104e27:	89 e5                	mov    %esp,%ebp
80104e29:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104e2c:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104e33:	e8 37 07 00 00       	call   8010556f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104e38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e3f:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
80104e46:	e9 e9 00 00 00       	jmp    80104f34 <wait2+0x10e>
      if(p->parent != proc)
80104e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4e:	8b 50 14             	mov    0x14(%eax),%edx
80104e51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e57:	39 c2                	cmp    %eax,%edx
80104e59:	0f 85 cd 00 00 00    	jne    80104f2c <wait2+0x106>
        continue;
      havekids = 1;
80104e5f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e69:	8b 40 0c             	mov    0xc(%eax),%eax
80104e6c:	83 f8 05             	cmp    $0x5,%eax
80104e6f:	0f 85 b8 00 00 00    	jne    80104f2d <wait2+0x107>
        // Found one.
        pid = p->pid;
80104e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e78:	8b 40 10             	mov    0x10(%eax),%eax
80104e7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e81:	8b 40 08             	mov    0x8(%eax),%eax
80104e84:	89 04 24             	mov    %eax,(%esp)
80104e87:	e8 ee e2 ff ff       	call   8010317a <kfree>
        p->kstack = 0;
80104e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e99:	8b 40 04             	mov    0x4(%eax),%eax
80104e9c:	89 04 24             	mov    %eax,(%esp)
80104e9f:	e8 65 3b 00 00       	call   80108a09 <freevm>
        p->state = UNUSED;
80104ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        
	// Update RTIME and IOTIME, calc WTIME
	*rtime = p->rtime;
80104ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104edf:	89 10                	mov    %edx,(%eax)
	*iotime = p->iotime;
80104ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee4:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104eea:	8b 45 10             	mov    0x10(%ebp),%eax
80104eed:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime - p->iotime;
80104eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef2:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efb:	8b 40 7c             	mov    0x7c(%eax),%eax
80104efe:	29 c2                	sub    %eax,%edx
80104f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f03:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104f09:	29 c2                	sub    %eax,%edx
80104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0e:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104f14:	29 c2                	sub    %eax,%edx
80104f16:	8b 45 08             	mov    0x8(%ebp),%eax
80104f19:	89 10                	mov    %edx,(%eax)
	
	release(&ptable.lock);
80104f1b:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104f22:	e8 aa 06 00 00       	call   801055d1 <release>
        return pid;
80104f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f2a:	eb 56                	jmp    80104f82 <wait2+0x15c>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104f2c:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f2d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104f34:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
80104f3b:	0f 82 0a ff ff ff    	jb     80104e4b <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104f41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f45:	74 0d                	je     80104f54 <wait2+0x12e>
80104f47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f4d:	8b 40 24             	mov    0x24(%eax),%eax
80104f50:	85 c0                	test   %eax,%eax
80104f52:	74 13                	je     80104f67 <wait2+0x141>
      release(&ptable.lock);
80104f54:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80104f5b:	e8 71 06 00 00       	call   801055d1 <release>
      return -1;
80104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f65:	eb 1b                	jmp    80104f82 <wait2+0x15c>
    }
        
    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104f67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f6d:	c7 44 24 04 e0 1e 11 	movl   $0x80111ee0,0x4(%esp)
80104f74:	80 
80104f75:	89 04 24             	mov    %eax,(%esp)
80104f78:	e8 7a 02 00 00       	call   801051f7 <sleep>
  }
80104f7d:	e9 b6 fe ff ff       	jmp    80104e38 <wait2+0x12>
}
80104f82:	c9                   	leave  
80104f83:	c3                   	ret    

80104f84 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104f84:	55                   	push   %ebp
80104f85:	89 e5                	mov    %esp,%ebp
80104f87:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104f8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f90:	8b 40 18             	mov    0x18(%eax),%eax
80104f93:	8b 40 44             	mov    0x44(%eax),%eax
80104f96:	89 c2                	mov    %eax,%edx
80104f98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9e:	8b 40 04             	mov    0x4(%eax),%eax
80104fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fa5:	89 04 24             	mov    %eax,(%esp)
80104fa8:	e8 41 3c 00 00       	call   80108bee <uva2ka>
80104fad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104fb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb6:	8b 40 18             	mov    0x18(%eax),%eax
80104fb9:	8b 40 44             	mov    0x44(%eax),%eax
80104fbc:	25 ff 0f 00 00       	and    $0xfff,%eax
80104fc1:	85 c0                	test   %eax,%eax
80104fc3:	75 0c                	jne    80104fd1 <register_handler+0x4d>
    panic("esp_offset == 0");
80104fc5:	c7 04 24 01 90 10 80 	movl   $0x80109001,(%esp)
80104fcc:	e8 6c b5 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104fd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd7:	8b 40 18             	mov    0x18(%eax),%eax
80104fda:	8b 40 44             	mov    0x44(%eax),%eax
80104fdd:	83 e8 04             	sub    $0x4,%eax
80104fe0:	25 ff 0f 00 00       	and    $0xfff,%eax
80104fe5:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104fe8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fef:	8b 52 18             	mov    0x18(%edx),%edx
80104ff2:	8b 52 38             	mov    0x38(%edx),%edx
80104ff5:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104ff7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ffd:	8b 40 18             	mov    0x18(%eax),%eax
80105000:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105007:	8b 52 18             	mov    0x18(%edx),%edx
8010500a:	8b 52 44             	mov    0x44(%edx),%edx
8010500d:	83 ea 04             	sub    $0x4,%edx
80105010:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80105013:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105019:	8b 40 18             	mov    0x18(%eax),%eax
8010501c:	8b 55 08             	mov    0x8(%ebp),%edx
8010501f:	89 50 38             	mov    %edx,0x38(%eax)
}
80105022:	c9                   	leave  
80105023:	c3                   	ret    

80105024 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105024:	55                   	push   %ebp
80105025:	89 e5                	mov    %esp,%ebp
80105027:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010502a:	e8 ea f6 ff ff       	call   80104719 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010502f:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80105036:	e8 34 05 00 00       	call   8010556f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010503b:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
80105042:	eb 6f                	jmp    801050b3 <scheduler+0x8f>
      if(p->state != RUNNABLE)
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	8b 40 0c             	mov    0xc(%eax),%eax
8010504a:	83 f8 03             	cmp    $0x3,%eax
8010504d:	75 5c                	jne    801050ab <scheduler+0x87>
      #endif // 3Q
	
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010504f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105052:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505b:	89 04 24             	mov    %eax,(%esp)
8010505e:	e8 2f 35 00 00       	call   80108592 <switchuvm>
      p->state = RUNNING;
80105063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105066:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      p->quanta = 1;
8010506d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105070:	c7 80 94 00 00 00 01 	movl   $0x1,0x94(%eax)
80105077:	00 00 00 
      swtch(&cpu->scheduler, proc->context);
8010507a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105080:	8b 40 1c             	mov    0x1c(%eax),%eax
80105083:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010508a:	83 c2 04             	add    $0x4,%edx
8010508d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105091:	89 14 24             	mov    %edx,(%esp)
80105094:	e8 cb 09 00 00       	call   80105a64 <swtch>
      switchkvm();
80105099:	e8 d7 34 00 00       	call   80108575 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010509e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801050a5:	00 00 00 00 
801050a9:	eb 01                	jmp    801050ac <scheduler+0x88>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801050ab:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ac:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801050b3:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
801050ba:	72 88                	jb     80105044 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801050bc:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801050c3:	e8 09 05 00 00       	call   801055d1 <release>

  }
801050c8:	e9 5d ff ff ff       	jmp    8010502a <scheduler+0x6>

801050cd <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801050cd:	55                   	push   %ebp
801050ce:	89 e5                	mov    %esp,%ebp
801050d0:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801050d3:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801050da:	e8 ae 05 00 00       	call   8010568d <holding>
801050df:	85 c0                	test   %eax,%eax
801050e1:	75 0c                	jne    801050ef <sched+0x22>
    panic("sched ptable.lock");
801050e3:	c7 04 24 11 90 10 80 	movl   $0x80109011,(%esp)
801050ea:	e8 4e b4 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
801050ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050f5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050fb:	83 f8 01             	cmp    $0x1,%eax
801050fe:	74 0c                	je     8010510c <sched+0x3f>
    panic("sched locks");
80105100:	c7 04 24 23 90 10 80 	movl   $0x80109023,(%esp)
80105107:	e8 31 b4 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
8010510c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105112:	8b 40 0c             	mov    0xc(%eax),%eax
80105115:	83 f8 04             	cmp    $0x4,%eax
80105118:	75 0c                	jne    80105126 <sched+0x59>
    panic("sched running");
8010511a:	c7 04 24 2f 90 10 80 	movl   $0x8010902f,(%esp)
80105121:	e8 17 b4 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80105126:	e8 d9 f5 ff ff       	call   80104704 <readeflags>
8010512b:	25 00 02 00 00       	and    $0x200,%eax
80105130:	85 c0                	test   %eax,%eax
80105132:	74 0c                	je     80105140 <sched+0x73>
    panic("sched interruptible");
80105134:	c7 04 24 3d 90 10 80 	movl   $0x8010903d,(%esp)
8010513b:	e8 fd b3 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80105140:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105146:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010514c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010514f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105155:	8b 40 04             	mov    0x4(%eax),%eax
80105158:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010515f:	83 c2 1c             	add    $0x1c,%edx
80105162:	89 44 24 04          	mov    %eax,0x4(%esp)
80105166:	89 14 24             	mov    %edx,(%esp)
80105169:	e8 f6 08 00 00       	call   80105a64 <swtch>
  cpu->intena = intena;
8010516e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105174:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105177:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010517d:	c9                   	leave  
8010517e:	c3                   	ret    

8010517f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010517f:	55                   	push   %ebp
80105180:	89 e5                	mov    %esp,%ebp
80105182:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105185:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
8010518c:	e8 de 03 00 00       	call   8010556f <acquire>
  proc->state = RUNNABLE;
80105191:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105197:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  proc->queuenum = ptable.FRR_COUNTER++;
8010519e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801051a5:	a1 14 47 11 80       	mov    0x80114714,%eax
801051aa:	89 82 98 00 00 00    	mov    %eax,0x98(%edx)
801051b0:	83 c0 01             	add    $0x1,%eax
801051b3:	a3 14 47 11 80       	mov    %eax,0x80114714
  sched();
801051b8:	e8 10 ff ff ff       	call   801050cd <sched>
  release(&ptable.lock);
801051bd:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801051c4:	e8 08 04 00 00       	call   801055d1 <release>
}
801051c9:	c9                   	leave  
801051ca:	c3                   	ret    

801051cb <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801051cb:	55                   	push   %ebp
801051cc:	89 e5                	mov    %esp,%ebp
801051ce:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801051d1:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801051d8:	e8 f4 03 00 00       	call   801055d1 <release>

  if (first) {
801051dd:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801051e2:	85 c0                	test   %eax,%eax
801051e4:	74 0f                	je     801051f5 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801051e6:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801051ed:	00 00 00 
    initlog();
801051f0:	e8 2f e5 ff ff       	call   80103724 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801051f5:	c9                   	leave  
801051f6:	c3                   	ret    

801051f7 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801051f7:	55                   	push   %ebp
801051f8:	89 e5                	mov    %esp,%ebp
801051fa:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801051fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105203:	85 c0                	test   %eax,%eax
80105205:	75 0c                	jne    80105213 <sleep+0x1c>
    panic("sleep");
80105207:	c7 04 24 51 90 10 80 	movl   $0x80109051,(%esp)
8010520e:	e8 2a b3 ff ff       	call   8010053d <panic>

  if(lk == 0)
80105213:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105217:	75 0c                	jne    80105225 <sleep+0x2e>
    panic("sleep without lk");
80105219:	c7 04 24 57 90 10 80 	movl   $0x80109057,(%esp)
80105220:	e8 18 b3 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105225:	81 7d 0c e0 1e 11 80 	cmpl   $0x80111ee0,0xc(%ebp)
8010522c:	74 17                	je     80105245 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010522e:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80105235:	e8 35 03 00 00       	call   8010556f <acquire>
    release(lk);
8010523a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010523d:	89 04 24             	mov    %eax,(%esp)
80105240:	e8 8c 03 00 00       	call   801055d1 <release>
  }

  // Go to sleep.
  if (proc)
80105245:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010524b:	85 c0                	test   %eax,%eax
8010524d:	74 12                	je     80105261 <sleep+0x6a>
    proc->sleeptime = ticks;
8010524f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105255:	8b 15 60 4f 11 80    	mov    0x80114f60,%edx
8010525b:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  proc->chan = chan;
80105261:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105267:	8b 55 08             	mov    0x8(%ebp),%edx
8010526a:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010526d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105273:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010527a:	e8 4e fe ff ff       	call   801050cd <sched>

  // Tidy up.
  proc->chan = 0;
8010527f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105285:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010528c:	81 7d 0c e0 1e 11 80 	cmpl   $0x80111ee0,0xc(%ebp)
80105293:	74 17                	je     801052ac <sleep+0xb5>
    release(&ptable.lock);
80105295:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
8010529c:	e8 30 03 00 00       	call   801055d1 <release>
    acquire(lk);
801052a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a4:	89 04 24             	mov    %eax,(%esp)
801052a7:	e8 c3 02 00 00       	call   8010556f <acquire>
  }
}
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    

801052ae <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801052ae:	55                   	push   %ebp
801052af:	89 e5                	mov    %esp,%ebp
801052b1:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801052b4:	c7 45 fc 14 1f 11 80 	movl   $0x80111f14,-0x4(%ebp)
801052bb:	e9 96 00 00 00       	jmp    80105356 <wakeup1+0xa8>
    if(p->state == SLEEPING && p->chan == chan){
801052c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052c3:	8b 40 0c             	mov    0xc(%eax),%eax
801052c6:	83 f8 02             	cmp    $0x2,%eax
801052c9:	0f 85 80 00 00 00    	jne    8010534f <wakeup1+0xa1>
801052cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d2:	8b 40 20             	mov    0x20(%eax),%eax
801052d5:	3b 45 08             	cmp    0x8(%ebp),%eax
801052d8:	75 75                	jne    8010534f <wakeup1+0xa1>
      p->state = RUNNABLE;
801052da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052dd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      if (p->priority == LOW)
801052e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e7:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
801052ed:	83 f8 03             	cmp    $0x3,%eax
801052f0:	75 0f                	jne    80105301 <wakeup1+0x53>
	p->priority = MEDIUM;
801052f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f5:	c7 80 9c 00 00 00 02 	movl   $0x2,0x9c(%eax)
801052fc:	00 00 00 
801052ff:	eb 0d                	jmp    8010530e <wakeup1+0x60>
      else
	p->priority = HIGH;
80105301:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105304:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
8010530b:	00 00 00 
      p->queuenum = ptable.FRR_COUNTER++;
8010530e:	a1 14 47 11 80       	mov    0x80114714,%eax
80105313:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105316:	89 82 98 00 00 00    	mov    %eax,0x98(%edx)
8010531c:	83 c0 01             	add    $0x1,%eax
8010531f:	a3 14 47 11 80       	mov    %eax,0x80114714
      int tmp = ticks;
80105324:	a1 60 4f 11 80       	mov    0x80114f60,%eax
80105329:	89 45 f8             	mov    %eax,-0x8(%ebp)
      tmp = tmp - p->sleeptime;
8010532c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105335:	29 45 f8             	sub    %eax,-0x8(%ebp)
      p->iotime = p->iotime + tmp;
80105338:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105341:	89 c2                	mov    %eax,%edx
80105343:	03 55 f8             	add    -0x8(%ebp),%edx
80105346:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105349:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010534f:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80105356:	81 7d fc 14 47 11 80 	cmpl   $0x80114714,-0x4(%ebp)
8010535d:	0f 82 5d ff ff ff    	jb     801052c0 <wakeup1+0x12>
      p->queuenum = ptable.FRR_COUNTER++;
      int tmp = ticks;
      tmp = tmp - p->sleeptime;
      p->iotime = p->iotime + tmp;
    }
}
80105363:	c9                   	leave  
80105364:	c3                   	ret    

80105365 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105365:	55                   	push   %ebp
80105366:	89 e5                	mov    %esp,%ebp
80105368:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010536b:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80105372:	e8 f8 01 00 00       	call   8010556f <acquire>
  wakeup1(chan);
80105377:	8b 45 08             	mov    0x8(%ebp),%eax
8010537a:	89 04 24             	mov    %eax,(%esp)
8010537d:	e8 2c ff ff ff       	call   801052ae <wakeup1>
  release(&ptable.lock);
80105382:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
80105389:	e8 43 02 00 00       	call   801055d1 <release>
}
8010538e:	c9                   	leave  
8010538f:	c3                   	ret    

80105390 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105390:	55                   	push   %ebp
80105391:	89 e5                	mov    %esp,%ebp
80105393:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105396:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
8010539d:	e8 cd 01 00 00       	call   8010556f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053a2:	c7 45 f4 14 1f 11 80 	movl   $0x80111f14,-0xc(%ebp)
801053a9:	eb 44                	jmp    801053ef <kill+0x5f>
    if(p->pid == pid){
801053ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ae:	8b 40 10             	mov    0x10(%eax),%eax
801053b1:	3b 45 08             	cmp    0x8(%ebp),%eax
801053b4:	75 32                	jne    801053e8 <kill+0x58>
      p->killed = 1;
801053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801053c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c3:	8b 40 0c             	mov    0xc(%eax),%eax
801053c6:	83 f8 02             	cmp    $0x2,%eax
801053c9:	75 0a                	jne    801053d5 <kill+0x45>
        p->state = RUNNABLE;
801053cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ce:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801053d5:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801053dc:	e8 f0 01 00 00       	call   801055d1 <release>
      return 0;
801053e1:	b8 00 00 00 00       	mov    $0x0,%eax
801053e6:	eb 21                	jmp    80105409 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801053e8:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
801053ef:	81 7d f4 14 47 11 80 	cmpl   $0x80114714,-0xc(%ebp)
801053f6:	72 b3                	jb     801053ab <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801053f8:	c7 04 24 e0 1e 11 80 	movl   $0x80111ee0,(%esp)
801053ff:	e8 cd 01 00 00       	call   801055d1 <release>
  return -1;
80105404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105409:	c9                   	leave  
8010540a:	c3                   	ret    

8010540b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010540b:	55                   	push   %ebp
8010540c:	89 e5                	mov    %esp,%ebp
8010540e:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105411:	c7 45 f0 14 1f 11 80 	movl   $0x80111f14,-0x10(%ebp)
80105418:	e9 db 00 00 00       	jmp    801054f8 <procdump+0xed>
    if(p->state == UNUSED)
8010541d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105420:	8b 40 0c             	mov    0xc(%eax),%eax
80105423:	85 c0                	test   %eax,%eax
80105425:	0f 84 c5 00 00 00    	je     801054f0 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010542b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542e:	8b 40 0c             	mov    0xc(%eax),%eax
80105431:	83 f8 05             	cmp    $0x5,%eax
80105434:	77 23                	ja     80105459 <procdump+0x4e>
80105436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105439:	8b 40 0c             	mov    0xc(%eax),%eax
8010543c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105443:	85 c0                	test   %eax,%eax
80105445:	74 12                	je     80105459 <procdump+0x4e>
      state = states[p->state];
80105447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544a:	8b 40 0c             	mov    0xc(%eax),%eax
8010544d:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105454:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105457:	eb 07                	jmp    80105460 <procdump+0x55>
    else
      state = "???";
80105459:	c7 45 ec 68 90 10 80 	movl   $0x80109068,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105463:	8d 50 6c             	lea    0x6c(%eax),%edx
80105466:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105469:	8b 40 10             	mov    0x10(%eax),%eax
8010546c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105470:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105473:	89 54 24 08          	mov    %edx,0x8(%esp)
80105477:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547b:	c7 04 24 6c 90 10 80 	movl   $0x8010906c,(%esp)
80105482:	e8 1a af ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010548a:	8b 40 0c             	mov    0xc(%eax),%eax
8010548d:	83 f8 02             	cmp    $0x2,%eax
80105490:	75 50                	jne    801054e2 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105495:	8b 40 1c             	mov    0x1c(%eax),%eax
80105498:	8b 40 0c             	mov    0xc(%eax),%eax
8010549b:	83 c0 08             	add    $0x8,%eax
8010549e:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801054a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801054a5:	89 04 24             	mov    %eax,(%esp)
801054a8:	e8 73 01 00 00       	call   80105620 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801054ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054b4:	eb 1b                	jmp    801054d1 <procdump+0xc6>
        cprintf(" %p", pc[i]);
801054b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801054bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801054c1:	c7 04 24 75 90 10 80 	movl   $0x80109075,(%esp)
801054c8:	e8 d4 ae ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801054cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054d1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801054d5:	7f 0b                	jg     801054e2 <procdump+0xd7>
801054d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054da:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801054de:	85 c0                	test   %eax,%eax
801054e0:	75 d4                	jne    801054b6 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801054e2:	c7 04 24 79 90 10 80 	movl   $0x80109079,(%esp)
801054e9:	e8 b3 ae ff ff       	call   801003a1 <cprintf>
801054ee:	eb 01                	jmp    801054f1 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801054f0:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054f1:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801054f8:	81 7d f0 14 47 11 80 	cmpl   $0x80114714,-0x10(%ebp)
801054ff:	0f 82 18 ff ff ff    	jb     8010541d <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105505:	c9                   	leave  
80105506:	c3                   	ret    
	...

80105508 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105508:	55                   	push   %ebp
80105509:	89 e5                	mov    %esp,%ebp
8010550b:	53                   	push   %ebx
8010550c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010550f:	9c                   	pushf  
80105510:	5b                   	pop    %ebx
80105511:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105514:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105517:	83 c4 10             	add    $0x10,%esp
8010551a:	5b                   	pop    %ebx
8010551b:	5d                   	pop    %ebp
8010551c:	c3                   	ret    

8010551d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010551d:	55                   	push   %ebp
8010551e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105520:	fa                   	cli    
}
80105521:	5d                   	pop    %ebp
80105522:	c3                   	ret    

80105523 <sti>:

static inline void
sti(void)
{
80105523:	55                   	push   %ebp
80105524:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105526:	fb                   	sti    
}
80105527:	5d                   	pop    %ebp
80105528:	c3                   	ret    

80105529 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105529:	55                   	push   %ebp
8010552a:	89 e5                	mov    %esp,%ebp
8010552c:	53                   	push   %ebx
8010552d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105530:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105533:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105536:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105539:	89 c3                	mov    %eax,%ebx
8010553b:	89 d8                	mov    %ebx,%eax
8010553d:	f0 87 02             	lock xchg %eax,(%edx)
80105540:	89 c3                	mov    %eax,%ebx
80105542:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105545:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105548:	83 c4 10             	add    $0x10,%esp
8010554b:	5b                   	pop    %ebx
8010554c:	5d                   	pop    %ebp
8010554d:	c3                   	ret    

8010554e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010554e:	55                   	push   %ebp
8010554f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105551:	8b 45 08             	mov    0x8(%ebp),%eax
80105554:	8b 55 0c             	mov    0xc(%ebp),%edx
80105557:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105563:	8b 45 08             	mov    0x8(%ebp),%eax
80105566:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010556d:	5d                   	pop    %ebp
8010556e:	c3                   	ret    

8010556f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010556f:	55                   	push   %ebp
80105570:	89 e5                	mov    %esp,%ebp
80105572:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105575:	e8 3d 01 00 00       	call   801056b7 <pushcli>
  if(holding(lk))
8010557a:	8b 45 08             	mov    0x8(%ebp),%eax
8010557d:	89 04 24             	mov    %eax,(%esp)
80105580:	e8 08 01 00 00       	call   8010568d <holding>
80105585:	85 c0                	test   %eax,%eax
80105587:	74 0c                	je     80105595 <acquire+0x26>
    panic("acquire");
80105589:	c7 04 24 a5 90 10 80 	movl   $0x801090a5,(%esp)
80105590:	e8 a8 af ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105595:	90                   	nop
80105596:	8b 45 08             	mov    0x8(%ebp),%eax
80105599:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801055a0:	00 
801055a1:	89 04 24             	mov    %eax,(%esp)
801055a4:	e8 80 ff ff ff       	call   80105529 <xchg>
801055a9:	85 c0                	test   %eax,%eax
801055ab:	75 e9                	jne    80105596 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801055ad:	8b 45 08             	mov    0x8(%ebp),%eax
801055b0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801055b7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801055ba:	8b 45 08             	mov    0x8(%ebp),%eax
801055bd:	83 c0 0c             	add    $0xc,%eax
801055c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801055c4:	8d 45 08             	lea    0x8(%ebp),%eax
801055c7:	89 04 24             	mov    %eax,(%esp)
801055ca:	e8 51 00 00 00       	call   80105620 <getcallerpcs>
}
801055cf:	c9                   	leave  
801055d0:	c3                   	ret    

801055d1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801055d1:	55                   	push   %ebp
801055d2:	89 e5                	mov    %esp,%ebp
801055d4:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801055d7:	8b 45 08             	mov    0x8(%ebp),%eax
801055da:	89 04 24             	mov    %eax,(%esp)
801055dd:	e8 ab 00 00 00       	call   8010568d <holding>
801055e2:	85 c0                	test   %eax,%eax
801055e4:	75 0c                	jne    801055f2 <release+0x21>
    panic("release");
801055e6:	c7 04 24 ad 90 10 80 	movl   $0x801090ad,(%esp)
801055ed:	e8 4b af ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
801055f2:	8b 45 08             	mov    0x8(%ebp),%eax
801055f5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801055fc:	8b 45 08             	mov    0x8(%ebp),%eax
801055ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105610:	00 
80105611:	89 04 24             	mov    %eax,(%esp)
80105614:	e8 10 ff ff ff       	call   80105529 <xchg>

  popcli();
80105619:	e8 e1 00 00 00       	call   801056ff <popcli>
}
8010561e:	c9                   	leave  
8010561f:	c3                   	ret    

80105620 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105620:	55                   	push   %ebp
80105621:	89 e5                	mov    %esp,%ebp
80105623:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105626:	8b 45 08             	mov    0x8(%ebp),%eax
80105629:	83 e8 08             	sub    $0x8,%eax
8010562c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010562f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105636:	eb 32                	jmp    8010566a <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105638:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010563c:	74 47                	je     80105685 <getcallerpcs+0x65>
8010563e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105645:	76 3e                	jbe    80105685 <getcallerpcs+0x65>
80105647:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010564b:	74 38                	je     80105685 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010564d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105650:	c1 e0 02             	shl    $0x2,%eax
80105653:	03 45 0c             	add    0xc(%ebp),%eax
80105656:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105659:	8b 52 04             	mov    0x4(%edx),%edx
8010565c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010565e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105661:	8b 00                	mov    (%eax),%eax
80105663:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105666:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010566a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010566e:	7e c8                	jle    80105638 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105670:	eb 13                	jmp    80105685 <getcallerpcs+0x65>
    pcs[i] = 0;
80105672:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105675:	c1 e0 02             	shl    $0x2,%eax
80105678:	03 45 0c             	add    0xc(%ebp),%eax
8010567b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105681:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105685:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105689:	7e e7                	jle    80105672 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010568b:	c9                   	leave  
8010568c:	c3                   	ret    

8010568d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010568d:	55                   	push   %ebp
8010568e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105690:	8b 45 08             	mov    0x8(%ebp),%eax
80105693:	8b 00                	mov    (%eax),%eax
80105695:	85 c0                	test   %eax,%eax
80105697:	74 17                	je     801056b0 <holding+0x23>
80105699:	8b 45 08             	mov    0x8(%ebp),%eax
8010569c:	8b 50 08             	mov    0x8(%eax),%edx
8010569f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056a5:	39 c2                	cmp    %eax,%edx
801056a7:	75 07                	jne    801056b0 <holding+0x23>
801056a9:	b8 01 00 00 00       	mov    $0x1,%eax
801056ae:	eb 05                	jmp    801056b5 <holding+0x28>
801056b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b5:	5d                   	pop    %ebp
801056b6:	c3                   	ret    

801056b7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801056bd:	e8 46 fe ff ff       	call   80105508 <readeflags>
801056c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801056c5:	e8 53 fe ff ff       	call   8010551d <cli>
  if(cpu->ncli++ == 0)
801056ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056d0:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801056d6:	85 d2                	test   %edx,%edx
801056d8:	0f 94 c1             	sete   %cl
801056db:	83 c2 01             	add    $0x1,%edx
801056de:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801056e4:	84 c9                	test   %cl,%cl
801056e6:	74 15                	je     801056fd <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
801056e8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056f1:	81 e2 00 02 00 00    	and    $0x200,%edx
801056f7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801056fd:	c9                   	leave  
801056fe:	c3                   	ret    

801056ff <popcli>:

void
popcli(void)
{
801056ff:	55                   	push   %ebp
80105700:	89 e5                	mov    %esp,%ebp
80105702:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105705:	e8 fe fd ff ff       	call   80105508 <readeflags>
8010570a:	25 00 02 00 00       	and    $0x200,%eax
8010570f:	85 c0                	test   %eax,%eax
80105711:	74 0c                	je     8010571f <popcli+0x20>
    panic("popcli - interruptible");
80105713:	c7 04 24 b5 90 10 80 	movl   $0x801090b5,(%esp)
8010571a:	e8 1e ae ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010571f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105725:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010572b:	83 ea 01             	sub    $0x1,%edx
8010572e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105734:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010573a:	85 c0                	test   %eax,%eax
8010573c:	79 0c                	jns    8010574a <popcli+0x4b>
    panic("popcli");
8010573e:	c7 04 24 cc 90 10 80 	movl   $0x801090cc,(%esp)
80105745:	e8 f3 ad ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010574a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105750:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105756:	85 c0                	test   %eax,%eax
80105758:	75 15                	jne    8010576f <popcli+0x70>
8010575a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105760:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105766:	85 c0                	test   %eax,%eax
80105768:	74 05                	je     8010576f <popcli+0x70>
    sti();
8010576a:	e8 b4 fd ff ff       	call   80105523 <sti>
}
8010576f:	c9                   	leave  
80105770:	c3                   	ret    
80105771:	00 00                	add    %al,(%eax)
	...

80105774 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105774:	55                   	push   %ebp
80105775:	89 e5                	mov    %esp,%ebp
80105777:	57                   	push   %edi
80105778:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105779:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010577c:	8b 55 10             	mov    0x10(%ebp),%edx
8010577f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105782:	89 cb                	mov    %ecx,%ebx
80105784:	89 df                	mov    %ebx,%edi
80105786:	89 d1                	mov    %edx,%ecx
80105788:	fc                   	cld    
80105789:	f3 aa                	rep stos %al,%es:(%edi)
8010578b:	89 ca                	mov    %ecx,%edx
8010578d:	89 fb                	mov    %edi,%ebx
8010578f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105792:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105795:	5b                   	pop    %ebx
80105796:	5f                   	pop    %edi
80105797:	5d                   	pop    %ebp
80105798:	c3                   	ret    

80105799 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105799:	55                   	push   %ebp
8010579a:	89 e5                	mov    %esp,%ebp
8010579c:	57                   	push   %edi
8010579d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010579e:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057a1:	8b 55 10             	mov    0x10(%ebp),%edx
801057a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a7:	89 cb                	mov    %ecx,%ebx
801057a9:	89 df                	mov    %ebx,%edi
801057ab:	89 d1                	mov    %edx,%ecx
801057ad:	fc                   	cld    
801057ae:	f3 ab                	rep stos %eax,%es:(%edi)
801057b0:	89 ca                	mov    %ecx,%edx
801057b2:	89 fb                	mov    %edi,%ebx
801057b4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801057b7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801057ba:	5b                   	pop    %ebx
801057bb:	5f                   	pop    %edi
801057bc:	5d                   	pop    %ebp
801057bd:	c3                   	ret    

801057be <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801057be:	55                   	push   %ebp
801057bf:	89 e5                	mov    %esp,%ebp
801057c1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801057c4:	8b 45 08             	mov    0x8(%ebp),%eax
801057c7:	83 e0 03             	and    $0x3,%eax
801057ca:	85 c0                	test   %eax,%eax
801057cc:	75 49                	jne    80105817 <memset+0x59>
801057ce:	8b 45 10             	mov    0x10(%ebp),%eax
801057d1:	83 e0 03             	and    $0x3,%eax
801057d4:	85 c0                	test   %eax,%eax
801057d6:	75 3f                	jne    80105817 <memset+0x59>
    c &= 0xFF;
801057d8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801057df:	8b 45 10             	mov    0x10(%ebp),%eax
801057e2:	c1 e8 02             	shr    $0x2,%eax
801057e5:	89 c2                	mov    %eax,%edx
801057e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ea:	89 c1                	mov    %eax,%ecx
801057ec:	c1 e1 18             	shl    $0x18,%ecx
801057ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f2:	c1 e0 10             	shl    $0x10,%eax
801057f5:	09 c1                	or     %eax,%ecx
801057f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057fa:	c1 e0 08             	shl    $0x8,%eax
801057fd:	09 c8                	or     %ecx,%eax
801057ff:	0b 45 0c             	or     0xc(%ebp),%eax
80105802:	89 54 24 08          	mov    %edx,0x8(%esp)
80105806:	89 44 24 04          	mov    %eax,0x4(%esp)
8010580a:	8b 45 08             	mov    0x8(%ebp),%eax
8010580d:	89 04 24             	mov    %eax,(%esp)
80105810:	e8 84 ff ff ff       	call   80105799 <stosl>
80105815:	eb 19                	jmp    80105830 <memset+0x72>
  } else
    stosb(dst, c, n);
80105817:	8b 45 10             	mov    0x10(%ebp),%eax
8010581a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010581e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105821:	89 44 24 04          	mov    %eax,0x4(%esp)
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	89 04 24             	mov    %eax,(%esp)
8010582b:	e8 44 ff ff ff       	call   80105774 <stosb>
  return dst;
80105830:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105833:	c9                   	leave  
80105834:	c3                   	ret    

80105835 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105835:	55                   	push   %ebp
80105836:	89 e5                	mov    %esp,%ebp
80105838:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010583b:	8b 45 08             	mov    0x8(%ebp),%eax
8010583e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105841:	8b 45 0c             	mov    0xc(%ebp),%eax
80105844:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105847:	eb 32                	jmp    8010587b <memcmp+0x46>
    if(*s1 != *s2)
80105849:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584c:	0f b6 10             	movzbl (%eax),%edx
8010584f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105852:	0f b6 00             	movzbl (%eax),%eax
80105855:	38 c2                	cmp    %al,%dl
80105857:	74 1a                	je     80105873 <memcmp+0x3e>
      return *s1 - *s2;
80105859:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010585c:	0f b6 00             	movzbl (%eax),%eax
8010585f:	0f b6 d0             	movzbl %al,%edx
80105862:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105865:	0f b6 00             	movzbl (%eax),%eax
80105868:	0f b6 c0             	movzbl %al,%eax
8010586b:	89 d1                	mov    %edx,%ecx
8010586d:	29 c1                	sub    %eax,%ecx
8010586f:	89 c8                	mov    %ecx,%eax
80105871:	eb 1c                	jmp    8010588f <memcmp+0x5a>
    s1++, s2++;
80105873:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105877:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010587b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010587f:	0f 95 c0             	setne  %al
80105882:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105886:	84 c0                	test   %al,%al
80105888:	75 bf                	jne    80105849 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010588a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010588f:	c9                   	leave  
80105890:	c3                   	ret    

80105891 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105891:	55                   	push   %ebp
80105892:	89 e5                	mov    %esp,%ebp
80105894:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105897:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010589d:	8b 45 08             	mov    0x8(%ebp),%eax
801058a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801058a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058a9:	73 54                	jae    801058ff <memmove+0x6e>
801058ab:	8b 45 10             	mov    0x10(%ebp),%eax
801058ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058b1:	01 d0                	add    %edx,%eax
801058b3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058b6:	76 47                	jbe    801058ff <memmove+0x6e>
    s += n;
801058b8:	8b 45 10             	mov    0x10(%ebp),%eax
801058bb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801058be:	8b 45 10             	mov    0x10(%ebp),%eax
801058c1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801058c4:	eb 13                	jmp    801058d9 <memmove+0x48>
      *--d = *--s;
801058c6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801058ca:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801058ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d1:	0f b6 10             	movzbl (%eax),%edx
801058d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058d7:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801058d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058dd:	0f 95 c0             	setne  %al
801058e0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058e4:	84 c0                	test   %al,%al
801058e6:	75 de                	jne    801058c6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801058e8:	eb 25                	jmp    8010590f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801058ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058ed:	0f b6 10             	movzbl (%eax),%edx
801058f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058f3:	88 10                	mov    %dl,(%eax)
801058f5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058fd:	eb 01                	jmp    80105900 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801058ff:	90                   	nop
80105900:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105904:	0f 95 c0             	setne  %al
80105907:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010590b:	84 c0                	test   %al,%al
8010590d:	75 db                	jne    801058ea <memmove+0x59>
      *d++ = *s++;

  return dst;
8010590f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105912:	c9                   	leave  
80105913:	c3                   	ret    

80105914 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105914:	55                   	push   %ebp
80105915:	89 e5                	mov    %esp,%ebp
80105917:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010591a:	8b 45 10             	mov    0x10(%ebp),%eax
8010591d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105921:	8b 45 0c             	mov    0xc(%ebp),%eax
80105924:	89 44 24 04          	mov    %eax,0x4(%esp)
80105928:	8b 45 08             	mov    0x8(%ebp),%eax
8010592b:	89 04 24             	mov    %eax,(%esp)
8010592e:	e8 5e ff ff ff       	call   80105891 <memmove>
}
80105933:	c9                   	leave  
80105934:	c3                   	ret    

80105935 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105935:	55                   	push   %ebp
80105936:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105938:	eb 0c                	jmp    80105946 <strncmp+0x11>
    n--, p++, q++;
8010593a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010593e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105942:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105946:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010594a:	74 1a                	je     80105966 <strncmp+0x31>
8010594c:	8b 45 08             	mov    0x8(%ebp),%eax
8010594f:	0f b6 00             	movzbl (%eax),%eax
80105952:	84 c0                	test   %al,%al
80105954:	74 10                	je     80105966 <strncmp+0x31>
80105956:	8b 45 08             	mov    0x8(%ebp),%eax
80105959:	0f b6 10             	movzbl (%eax),%edx
8010595c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595f:	0f b6 00             	movzbl (%eax),%eax
80105962:	38 c2                	cmp    %al,%dl
80105964:	74 d4                	je     8010593a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105966:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010596a:	75 07                	jne    80105973 <strncmp+0x3e>
    return 0;
8010596c:	b8 00 00 00 00       	mov    $0x0,%eax
80105971:	eb 18                	jmp    8010598b <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105973:	8b 45 08             	mov    0x8(%ebp),%eax
80105976:	0f b6 00             	movzbl (%eax),%eax
80105979:	0f b6 d0             	movzbl %al,%edx
8010597c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010597f:	0f b6 00             	movzbl (%eax),%eax
80105982:	0f b6 c0             	movzbl %al,%eax
80105985:	89 d1                	mov    %edx,%ecx
80105987:	29 c1                	sub    %eax,%ecx
80105989:	89 c8                	mov    %ecx,%eax
}
8010598b:	5d                   	pop    %ebp
8010598c:	c3                   	ret    

8010598d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010598d:	55                   	push   %ebp
8010598e:	89 e5                	mov    %esp,%ebp
80105990:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105993:	8b 45 08             	mov    0x8(%ebp),%eax
80105996:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105999:	90                   	nop
8010599a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010599e:	0f 9f c0             	setg   %al
801059a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801059a5:	84 c0                	test   %al,%al
801059a7:	74 30                	je     801059d9 <strncpy+0x4c>
801059a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ac:	0f b6 10             	movzbl (%eax),%edx
801059af:	8b 45 08             	mov    0x8(%ebp),%eax
801059b2:	88 10                	mov    %dl,(%eax)
801059b4:	8b 45 08             	mov    0x8(%ebp),%eax
801059b7:	0f b6 00             	movzbl (%eax),%eax
801059ba:	84 c0                	test   %al,%al
801059bc:	0f 95 c0             	setne  %al
801059bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801059c3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801059c7:	84 c0                	test   %al,%al
801059c9:	75 cf                	jne    8010599a <strncpy+0xd>
    ;
  while(n-- > 0)
801059cb:	eb 0c                	jmp    801059d9 <strncpy+0x4c>
    *s++ = 0;
801059cd:	8b 45 08             	mov    0x8(%ebp),%eax
801059d0:	c6 00 00             	movb   $0x0,(%eax)
801059d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801059d7:	eb 01                	jmp    801059da <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801059d9:	90                   	nop
801059da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059de:	0f 9f c0             	setg   %al
801059e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801059e5:	84 c0                	test   %al,%al
801059e7:	75 e4                	jne    801059cd <strncpy+0x40>
    *s++ = 0;
  return os;
801059e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059ec:	c9                   	leave  
801059ed:	c3                   	ret    

801059ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801059ee:	55                   	push   %ebp
801059ef:	89 e5                	mov    %esp,%ebp
801059f1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801059f4:	8b 45 08             	mov    0x8(%ebp),%eax
801059f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801059fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059fe:	7f 05                	jg     80105a05 <safestrcpy+0x17>
    return os;
80105a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a03:	eb 35                	jmp    80105a3a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105a05:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105a09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a0d:	7e 22                	jle    80105a31 <safestrcpy+0x43>
80105a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a12:	0f b6 10             	movzbl (%eax),%edx
80105a15:	8b 45 08             	mov    0x8(%ebp),%eax
80105a18:	88 10                	mov    %dl,(%eax)
80105a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a1d:	0f b6 00             	movzbl (%eax),%eax
80105a20:	84 c0                	test   %al,%al
80105a22:	0f 95 c0             	setne  %al
80105a25:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105a29:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105a2d:	84 c0                	test   %al,%al
80105a2f:	75 d4                	jne    80105a05 <safestrcpy+0x17>
    ;
  *s = 0;
80105a31:	8b 45 08             	mov    0x8(%ebp),%eax
80105a34:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105a37:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a3a:	c9                   	leave  
80105a3b:	c3                   	ret    

80105a3c <strlen>:

int
strlen(const char *s)
{
80105a3c:	55                   	push   %ebp
80105a3d:	89 e5                	mov    %esp,%ebp
80105a3f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105a42:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a49:	eb 04                	jmp    80105a4f <strlen+0x13>
80105a4b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a52:	03 45 08             	add    0x8(%ebp),%eax
80105a55:	0f b6 00             	movzbl (%eax),%eax
80105a58:	84 c0                	test   %al,%al
80105a5a:	75 ef                	jne    80105a4b <strlen+0xf>
    ;
  return n;
80105a5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a5f:	c9                   	leave  
80105a60:	c3                   	ret    
80105a61:	00 00                	add    %al,(%eax)
	...

80105a64 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105a64:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105a68:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105a6c:	55                   	push   %ebp
  pushl %ebx
80105a6d:	53                   	push   %ebx
  pushl %esi
80105a6e:	56                   	push   %esi
  pushl %edi
80105a6f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105a70:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105a72:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105a74:	5f                   	pop    %edi
  popl %esi
80105a75:	5e                   	pop    %esi
  popl %ebx
80105a76:	5b                   	pop    %ebx
  popl %ebp
80105a77:	5d                   	pop    %ebp
  ret
80105a78:	c3                   	ret    
80105a79:	00 00                	add    %al,(%eax)
	...

80105a7c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105a7c:	55                   	push   %ebp
80105a7d:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
80105a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a82:	8b 00                	mov    (%eax),%eax
80105a84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105a87:	76 0f                	jbe    80105a98 <fetchint+0x1c>
80105a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a8c:	8d 50 04             	lea    0x4(%eax),%edx
80105a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a92:	8b 00                	mov    (%eax),%eax
80105a94:	39 c2                	cmp    %eax,%edx
80105a96:	76 07                	jbe    80105a9f <fetchint+0x23>
    return -1;
80105a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9d:	eb 0f                	jmp    80105aae <fetchint+0x32>
  *ip = *(int*)(addr);
80105a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aa2:	8b 10                	mov    (%eax),%edx
80105aa4:	8b 45 10             	mov    0x10(%ebp),%eax
80105aa7:	89 10                	mov    %edx,(%eax)
  return 0;
80105aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aae:	5d                   	pop    %ebp
80105aaf:	c3                   	ret    

80105ab0 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab9:	8b 00                	mov    (%eax),%eax
80105abb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105abe:	77 07                	ja     80105ac7 <fetchstr+0x17>
    return -1;
80105ac0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac5:	eb 45                	jmp    80105b0c <fetchstr+0x5c>
  *pp = (char*)addr;
80105ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
80105aca:	8b 45 10             	mov    0x10(%ebp),%eax
80105acd:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
80105acf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad2:	8b 00                	mov    (%eax),%eax
80105ad4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105ad7:	8b 45 10             	mov    0x10(%ebp),%eax
80105ada:	8b 00                	mov    (%eax),%eax
80105adc:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105adf:	eb 1e                	jmp    80105aff <fetchstr+0x4f>
    if(*s == 0)
80105ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ae4:	0f b6 00             	movzbl (%eax),%eax
80105ae7:	84 c0                	test   %al,%al
80105ae9:	75 10                	jne    80105afb <fetchstr+0x4b>
      return s - *pp;
80105aeb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105aee:	8b 45 10             	mov    0x10(%ebp),%eax
80105af1:	8b 00                	mov    (%eax),%eax
80105af3:	89 d1                	mov    %edx,%ecx
80105af5:	29 c1                	sub    %eax,%ecx
80105af7:	89 c8                	mov    %ecx,%eax
80105af9:	eb 11                	jmp    80105b0c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
80105afb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b02:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b05:	72 da                	jb     80105ae1 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105b07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b0c:	c9                   	leave  
80105b0d:	c3                   	ret    

80105b0e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105b0e:	55                   	push   %ebp
80105b0f:	89 e5                	mov    %esp,%ebp
80105b11:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105b14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b1a:	8b 40 18             	mov    0x18(%eax),%eax
80105b1d:	8b 50 44             	mov    0x44(%eax),%edx
80105b20:	8b 45 08             	mov    0x8(%ebp),%eax
80105b23:	c1 e0 02             	shl    $0x2,%eax
80105b26:	01 d0                	add    %edx,%eax
80105b28:	8d 48 04             	lea    0x4(%eax),%ecx
80105b2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b31:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b34:	89 54 24 08          	mov    %edx,0x8(%esp)
80105b38:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105b3c:	89 04 24             	mov    %eax,(%esp)
80105b3f:	e8 38 ff ff ff       	call   80105a7c <fetchint>
}
80105b44:	c9                   	leave  
80105b45:	c3                   	ret    

80105b46 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105b46:	55                   	push   %ebp
80105b47:	89 e5                	mov    %esp,%ebp
80105b49:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105b4c:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b53:	8b 45 08             	mov    0x8(%ebp),%eax
80105b56:	89 04 24             	mov    %eax,(%esp)
80105b59:	e8 b0 ff ff ff       	call   80105b0e <argint>
80105b5e:	85 c0                	test   %eax,%eax
80105b60:	79 07                	jns    80105b69 <argptr+0x23>
    return -1;
80105b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b67:	eb 3d                	jmp    80105ba6 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105b69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b6c:	89 c2                	mov    %eax,%edx
80105b6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b74:	8b 00                	mov    (%eax),%eax
80105b76:	39 c2                	cmp    %eax,%edx
80105b78:	73 16                	jae    80105b90 <argptr+0x4a>
80105b7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b7d:	89 c2                	mov    %eax,%edx
80105b7f:	8b 45 10             	mov    0x10(%ebp),%eax
80105b82:	01 c2                	add    %eax,%edx
80105b84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b8a:	8b 00                	mov    (%eax),%eax
80105b8c:	39 c2                	cmp    %eax,%edx
80105b8e:	76 07                	jbe    80105b97 <argptr+0x51>
    return -1;
80105b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b95:	eb 0f                	jmp    80105ba6 <argptr+0x60>
  *pp = (char*)i;
80105b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b9a:	89 c2                	mov    %eax,%edx
80105b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b9f:	89 10                	mov    %edx,(%eax)
  return 0;
80105ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba6:	c9                   	leave  
80105ba7:	c3                   	ret    

80105ba8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105ba8:	55                   	push   %ebp
80105ba9:	89 e5                	mov    %esp,%ebp
80105bab:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105bae:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb8:	89 04 24             	mov    %eax,(%esp)
80105bbb:	e8 4e ff ff ff       	call   80105b0e <argint>
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	79 07                	jns    80105bcb <argstr+0x23>
    return -1;
80105bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc9:	eb 1e                	jmp    80105be9 <argstr+0x41>
  return fetchstr(proc, addr, pp);
80105bcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bce:	89 c2                	mov    %eax,%edx
80105bd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105bd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bdd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be1:	89 04 24             	mov    %eax,(%esp)
80105be4:	e8 c7 fe ff ff       	call   80105ab0 <fetchstr>
}
80105be9:	c9                   	leave  
80105bea:	c3                   	ret    

80105beb <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105beb:	55                   	push   %ebp
80105bec:	89 e5                	mov    %esp,%ebp
80105bee:	53                   	push   %ebx
80105bef:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105bf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bf8:	8b 40 18             	mov    0x18(%eax),%eax
80105bfb:	8b 40 1c             	mov    0x1c(%eax),%eax
80105bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105c01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c05:	78 2e                	js     80105c35 <syscall+0x4a>
80105c07:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105c0b:	7f 28                	jg     80105c35 <syscall+0x4a>
80105c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c10:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c17:	85 c0                	test   %eax,%eax
80105c19:	74 1a                	je     80105c35 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105c1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c21:	8b 58 18             	mov    0x18(%eax),%ebx
80105c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c27:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c2e:	ff d0                	call   *%eax
80105c30:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105c33:	eb 73                	jmp    80105ca8 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105c35:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105c39:	7e 30                	jle    80105c6b <syscall+0x80>
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	83 f8 17             	cmp    $0x17,%eax
80105c41:	77 28                	ja     80105c6b <syscall+0x80>
80105c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c46:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c4d:	85 c0                	test   %eax,%eax
80105c4f:	74 1a                	je     80105c6b <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105c51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c57:	8b 58 18             	mov    0x18(%eax),%ebx
80105c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5d:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c64:	ff d0                	call   *%eax
80105c66:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105c69:	eb 3d                	jmp    80105ca8 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105c6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c71:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105c74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105c7a:	8b 40 10             	mov    0x10(%eax),%eax
80105c7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c80:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105c84:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8c:	c7 04 24 d3 90 10 80 	movl   $0x801090d3,(%esp)
80105c93:	e8 09 a7 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105c98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c9e:	8b 40 18             	mov    0x18(%eax),%eax
80105ca1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ca8:	83 c4 24             	add    $0x24,%esp
80105cab:	5b                   	pop    %ebx
80105cac:	5d                   	pop    %ebp
80105cad:	c3                   	ret    
	...

80105cb0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105cb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc0:	89 04 24             	mov    %eax,(%esp)
80105cc3:	e8 46 fe ff ff       	call   80105b0e <argint>
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	79 07                	jns    80105cd3 <argfd+0x23>
    return -1;
80105ccc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd1:	eb 50                	jmp    80105d23 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd6:	85 c0                	test   %eax,%eax
80105cd8:	78 21                	js     80105cfb <argfd+0x4b>
80105cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cdd:	83 f8 0f             	cmp    $0xf,%eax
80105ce0:	7f 19                	jg     80105cfb <argfd+0x4b>
80105ce2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ce8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ceb:	83 c2 08             	add    $0x8,%edx
80105cee:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf9:	75 07                	jne    80105d02 <argfd+0x52>
    return -1;
80105cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d00:	eb 21                	jmp    80105d23 <argfd+0x73>
  if(pfd)
80105d02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105d06:	74 08                	je     80105d10 <argfd+0x60>
    *pfd = fd;
80105d08:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d0e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105d10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d14:	74 08                	je     80105d1e <argfd+0x6e>
    *pf = f;
80105d16:	8b 45 10             	mov    0x10(%ebp),%eax
80105d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d1c:	89 10                	mov    %edx,(%eax)
  return 0;
80105d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d23:	c9                   	leave  
80105d24:	c3                   	ret    

80105d25 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105d25:	55                   	push   %ebp
80105d26:	89 e5                	mov    %esp,%ebp
80105d28:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105d2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105d32:	eb 30                	jmp    80105d64 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105d34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d3a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d3d:	83 c2 08             	add    $0x8,%edx
80105d40:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105d44:	85 c0                	test   %eax,%eax
80105d46:	75 18                	jne    80105d60 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105d48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d4e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d51:	8d 4a 08             	lea    0x8(%edx),%ecx
80105d54:	8b 55 08             	mov    0x8(%ebp),%edx
80105d57:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105d5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d5e:	eb 0f                	jmp    80105d6f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105d60:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d64:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105d68:	7e ca                	jle    80105d34 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d6f:	c9                   	leave  
80105d70:	c3                   	ret    

80105d71 <sys_dup>:

int
sys_dup(void)
{
80105d71:	55                   	push   %ebp
80105d72:	89 e5                	mov    %esp,%ebp
80105d74:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105d77:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d85:	00 
80105d86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d8d:	e8 1e ff ff ff       	call   80105cb0 <argfd>
80105d92:	85 c0                	test   %eax,%eax
80105d94:	79 07                	jns    80105d9d <sys_dup+0x2c>
    return -1;
80105d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9b:	eb 29                	jmp    80105dc6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da0:	89 04 24             	mov    %eax,(%esp)
80105da3:	e8 7d ff ff ff       	call   80105d25 <fdalloc>
80105da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105daf:	79 07                	jns    80105db8 <sys_dup+0x47>
    return -1;
80105db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db6:	eb 0e                	jmp    80105dc6 <sys_dup+0x55>
  filedup(f);
80105db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbb:	89 04 24             	mov    %eax,(%esp)
80105dbe:	e8 cd b8 ff ff       	call   80101690 <filedup>
  return fd;
80105dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105dc6:	c9                   	leave  
80105dc7:	c3                   	ret    

80105dc8 <sys_read>:

int
sys_read(void)
{
80105dc8:	55                   	push   %ebp
80105dc9:	89 e5                	mov    %esp,%ebp
80105dcb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105dce:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ddc:	00 
80105ddd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105de4:	e8 c7 fe ff ff       	call   80105cb0 <argfd>
80105de9:	85 c0                	test   %eax,%eax
80105deb:	78 35                	js     80105e22 <sys_read+0x5a>
80105ded:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105df4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105dfb:	e8 0e fd ff ff       	call   80105b0e <argint>
80105e00:	85 c0                	test   %eax,%eax
80105e02:	78 1e                	js     80105e22 <sys_read+0x5a>
80105e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e07:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e0b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e19:	e8 28 fd ff ff       	call   80105b46 <argptr>
80105e1e:	85 c0                	test   %eax,%eax
80105e20:	79 07                	jns    80105e29 <sys_read+0x61>
    return -1;
80105e22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e27:	eb 19                	jmp    80105e42 <sys_read+0x7a>
  return fileread(f, p, n);
80105e29:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105e2c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e36:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e3a:	89 04 24             	mov    %eax,(%esp)
80105e3d:	e8 bb b9 ff ff       	call   801017fd <fileread>
}
80105e42:	c9                   	leave  
80105e43:	c3                   	ret    

80105e44 <sys_write>:

int
sys_write(void)
{
80105e44:	55                   	push   %ebp
80105e45:	89 e5                	mov    %esp,%ebp
80105e47:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105e4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e58:	00 
80105e59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e60:	e8 4b fe ff ff       	call   80105cb0 <argfd>
80105e65:	85 c0                	test   %eax,%eax
80105e67:	78 35                	js     80105e9e <sys_write+0x5a>
80105e69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e70:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105e77:	e8 92 fc ff ff       	call   80105b0e <argint>
80105e7c:	85 c0                	test   %eax,%eax
80105e7e:	78 1e                	js     80105e9e <sys_write+0x5a>
80105e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e95:	e8 ac fc ff ff       	call   80105b46 <argptr>
80105e9a:	85 c0                	test   %eax,%eax
80105e9c:	79 07                	jns    80105ea5 <sys_write+0x61>
    return -1;
80105e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea3:	eb 19                	jmp    80105ebe <sys_write+0x7a>
  return filewrite(f, p, n);
80105ea5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ea8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105eb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 fb b9 ff ff       	call   801018b9 <filewrite>
}
80105ebe:	c9                   	leave  
80105ebf:	c3                   	ret    

80105ec0 <sys_close>:

int
sys_close(void)
{
80105ec0:	55                   	push   %ebp
80105ec1:	89 e5                	mov    %esp,%ebp
80105ec3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105ec6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ec9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105edb:	e8 d0 fd ff ff       	call   80105cb0 <argfd>
80105ee0:	85 c0                	test   %eax,%eax
80105ee2:	79 07                	jns    80105eeb <sys_close+0x2b>
    return -1;
80105ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee9:	eb 24                	jmp    80105f0f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105eeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ef1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ef4:	83 c2 08             	add    $0x8,%edx
80105ef7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105efe:	00 
  fileclose(f);
80105eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f02:	89 04 24             	mov    %eax,(%esp)
80105f05:	e8 ce b7 ff ff       	call   801016d8 <fileclose>
  return 0;
80105f0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f0f:	c9                   	leave  
80105f10:	c3                   	ret    

80105f11 <sys_fstat>:

int
sys_fstat(void)
{
80105f11:	55                   	push   %ebp
80105f12:	89 e5                	mov    %esp,%ebp
80105f14:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f1a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f25:	00 
80105f26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f2d:	e8 7e fd ff ff       	call   80105cb0 <argfd>
80105f32:	85 c0                	test   %eax,%eax
80105f34:	78 1f                	js     80105f55 <sys_fstat+0x44>
80105f36:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105f3d:	00 
80105f3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f41:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f4c:	e8 f5 fb ff ff       	call   80105b46 <argptr>
80105f51:	85 c0                	test   %eax,%eax
80105f53:	79 07                	jns    80105f5c <sys_fstat+0x4b>
    return -1;
80105f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5a:	eb 12                	jmp    80105f6e <sys_fstat+0x5d>
  return filestat(f, st);
80105f5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f62:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f66:	89 04 24             	mov    %eax,(%esp)
80105f69:	e8 40 b8 ff ff       	call   801017ae <filestat>
}
80105f6e:	c9                   	leave  
80105f6f:	c3                   	ret    

80105f70 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105f76:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105f79:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f84:	e8 1f fc ff ff       	call   80105ba8 <argstr>
80105f89:	85 c0                	test   %eax,%eax
80105f8b:	78 17                	js     80105fa4 <sys_link+0x34>
80105f8d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105f90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f9b:	e8 08 fc ff ff       	call   80105ba8 <argstr>
80105fa0:	85 c0                	test   %eax,%eax
80105fa2:	79 0a                	jns    80105fae <sys_link+0x3e>
    return -1;
80105fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa9:	e9 3c 01 00 00       	jmp    801060ea <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105fae:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105fb1:	89 04 24             	mov    %eax,(%esp)
80105fb4:	e8 65 cb ff ff       	call   80102b1e <namei>
80105fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc0:	75 0a                	jne    80105fcc <sys_link+0x5c>
    return -1;
80105fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc7:	e9 1e 01 00 00       	jmp    801060ea <sys_link+0x17a>

  begin_trans();
80105fcc:	e8 60 d9 ff ff       	call   80103931 <begin_trans>

  ilock(ip);
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	89 04 24             	mov    %eax,(%esp)
80105fd7:	e8 a0 bf ff ff       	call   80101f7c <ilock>
  if(ip->type == T_DIR){
80105fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fe3:	66 83 f8 01          	cmp    $0x1,%ax
80105fe7:	75 1a                	jne    80106003 <sys_link+0x93>
    iunlockput(ip);
80105fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fec:	89 04 24             	mov    %eax,(%esp)
80105fef:	e8 0c c2 ff ff       	call   80102200 <iunlockput>
    commit_trans();
80105ff4:	e8 81 d9 ff ff       	call   8010397a <commit_trans>
    return -1;
80105ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ffe:	e9 e7 00 00 00       	jmp    801060ea <sys_link+0x17a>
  }

  ip->nlink++;
80106003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106006:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010600a:	8d 50 01             	lea    0x1(%eax),%edx
8010600d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106010:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106017:	89 04 24             	mov    %eax,(%esp)
8010601a:	e8 a1 bd ff ff       	call   80101dc0 <iupdate>
  iunlock(ip);
8010601f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106022:	89 04 24             	mov    %eax,(%esp)
80106025:	e8 a0 c0 ff ff       	call   801020ca <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010602a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010602d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106030:	89 54 24 04          	mov    %edx,0x4(%esp)
80106034:	89 04 24             	mov    %eax,(%esp)
80106037:	e8 04 cb ff ff       	call   80102b40 <nameiparent>
8010603c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010603f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106043:	74 68                	je     801060ad <sys_link+0x13d>
    goto bad;
  ilock(dp);
80106045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106048:	89 04 24             	mov    %eax,(%esp)
8010604b:	e8 2c bf ff ff       	call   80101f7c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106053:	8b 10                	mov    (%eax),%edx
80106055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106058:	8b 00                	mov    (%eax),%eax
8010605a:	39 c2                	cmp    %eax,%edx
8010605c:	75 20                	jne    8010607e <sys_link+0x10e>
8010605e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106061:	8b 40 04             	mov    0x4(%eax),%eax
80106064:	89 44 24 08          	mov    %eax,0x8(%esp)
80106068:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010606b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106072:	89 04 24             	mov    %eax,(%esp)
80106075:	e8 e3 c7 ff ff       	call   8010285d <dirlink>
8010607a:	85 c0                	test   %eax,%eax
8010607c:	79 0d                	jns    8010608b <sys_link+0x11b>
    iunlockput(dp);
8010607e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106081:	89 04 24             	mov    %eax,(%esp)
80106084:	e8 77 c1 ff ff       	call   80102200 <iunlockput>
    goto bad;
80106089:	eb 23                	jmp    801060ae <sys_link+0x13e>
  }
  iunlockput(dp);
8010608b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608e:	89 04 24             	mov    %eax,(%esp)
80106091:	e8 6a c1 ff ff       	call   80102200 <iunlockput>
  iput(ip);
80106096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106099:	89 04 24             	mov    %eax,(%esp)
8010609c:	e8 8e c0 ff ff       	call   8010212f <iput>

  commit_trans();
801060a1:	e8 d4 d8 ff ff       	call   8010397a <commit_trans>

  return 0;
801060a6:	b8 00 00 00 00       	mov    $0x0,%eax
801060ab:	eb 3d                	jmp    801060ea <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801060ad:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
801060ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b1:	89 04 24             	mov    %eax,(%esp)
801060b4:	e8 c3 be ff ff       	call   80101f7c <ilock>
  ip->nlink--;
801060b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060c0:	8d 50 ff             	lea    -0x1(%eax),%edx
801060c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cd:	89 04 24             	mov    %eax,(%esp)
801060d0:	e8 eb bc ff ff       	call   80101dc0 <iupdate>
  iunlockput(ip);
801060d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d8:	89 04 24             	mov    %eax,(%esp)
801060db:	e8 20 c1 ff ff       	call   80102200 <iunlockput>
  commit_trans();
801060e0:	e8 95 d8 ff ff       	call   8010397a <commit_trans>
  return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ea:	c9                   	leave  
801060eb:	c3                   	ret    

801060ec <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801060ec:	55                   	push   %ebp
801060ed:	89 e5                	mov    %esp,%ebp
801060ef:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060f2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801060f9:	eb 4b                	jmp    80106146 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fe:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106105:	00 
80106106:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010610d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106111:	8b 45 08             	mov    0x8(%ebp),%eax
80106114:	89 04 24             	mov    %eax,(%esp)
80106117:	e8 56 c3 ff ff       	call   80102472 <readi>
8010611c:	83 f8 10             	cmp    $0x10,%eax
8010611f:	74 0c                	je     8010612d <isdirempty+0x41>
      panic("isdirempty: readi");
80106121:	c7 04 24 ef 90 10 80 	movl   $0x801090ef,(%esp)
80106128:	e8 10 a4 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
8010612d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106131:	66 85 c0             	test   %ax,%ax
80106134:	74 07                	je     8010613d <isdirempty+0x51>
      return 0;
80106136:	b8 00 00 00 00       	mov    $0x0,%eax
8010613b:	eb 1b                	jmp    80106158 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010613d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106140:	83 c0 10             	add    $0x10,%eax
80106143:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106146:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106149:	8b 45 08             	mov    0x8(%ebp),%eax
8010614c:	8b 40 18             	mov    0x18(%eax),%eax
8010614f:	39 c2                	cmp    %eax,%edx
80106151:	72 a8                	jb     801060fb <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106153:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106158:	c9                   	leave  
80106159:	c3                   	ret    

8010615a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010615a:	55                   	push   %ebp
8010615b:	89 e5                	mov    %esp,%ebp
8010615d:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106160:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106163:	89 44 24 04          	mov    %eax,0x4(%esp)
80106167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010616e:	e8 35 fa ff ff       	call   80105ba8 <argstr>
80106173:	85 c0                	test   %eax,%eax
80106175:	79 0a                	jns    80106181 <sys_unlink+0x27>
    return -1;
80106177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617c:	e9 aa 01 00 00       	jmp    8010632b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80106181:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106184:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106187:	89 54 24 04          	mov    %edx,0x4(%esp)
8010618b:	89 04 24             	mov    %eax,(%esp)
8010618e:	e8 ad c9 ff ff       	call   80102b40 <nameiparent>
80106193:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106196:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010619a:	75 0a                	jne    801061a6 <sys_unlink+0x4c>
    return -1;
8010619c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a1:	e9 85 01 00 00       	jmp    8010632b <sys_unlink+0x1d1>

  begin_trans();
801061a6:	e8 86 d7 ff ff       	call   80103931 <begin_trans>

  ilock(dp);
801061ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ae:	89 04 24             	mov    %eax,(%esp)
801061b1:	e8 c6 bd ff ff       	call   80101f7c <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801061b6:	c7 44 24 04 01 91 10 	movl   $0x80109101,0x4(%esp)
801061bd:	80 
801061be:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801061c1:	89 04 24             	mov    %eax,(%esp)
801061c4:	e8 aa c5 ff ff       	call   80102773 <namecmp>
801061c9:	85 c0                	test   %eax,%eax
801061cb:	0f 84 45 01 00 00    	je     80106316 <sys_unlink+0x1bc>
801061d1:	c7 44 24 04 03 91 10 	movl   $0x80109103,0x4(%esp)
801061d8:	80 
801061d9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801061dc:	89 04 24             	mov    %eax,(%esp)
801061df:	e8 8f c5 ff ff       	call   80102773 <namecmp>
801061e4:	85 c0                	test   %eax,%eax
801061e6:	0f 84 2a 01 00 00    	je     80106316 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801061ec:	8d 45 c8             	lea    -0x38(%ebp),%eax
801061ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801061f3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801061f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801061fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fd:	89 04 24             	mov    %eax,(%esp)
80106200:	e8 90 c5 ff ff       	call   80102795 <dirlookup>
80106205:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620c:	0f 84 03 01 00 00    	je     80106315 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80106212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106215:	89 04 24             	mov    %eax,(%esp)
80106218:	e8 5f bd ff ff       	call   80101f7c <ilock>

  if(ip->nlink < 1)
8010621d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106220:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106224:	66 85 c0             	test   %ax,%ax
80106227:	7f 0c                	jg     80106235 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80106229:	c7 04 24 06 91 10 80 	movl   $0x80109106,(%esp)
80106230:	e8 08 a3 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106235:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106238:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010623c:	66 83 f8 01          	cmp    $0x1,%ax
80106240:	75 1f                	jne    80106261 <sys_unlink+0x107>
80106242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106245:	89 04 24             	mov    %eax,(%esp)
80106248:	e8 9f fe ff ff       	call   801060ec <isdirempty>
8010624d:	85 c0                	test   %eax,%eax
8010624f:	75 10                	jne    80106261 <sys_unlink+0x107>
    iunlockput(ip);
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	89 04 24             	mov    %eax,(%esp)
80106257:	e8 a4 bf ff ff       	call   80102200 <iunlockput>
    goto bad;
8010625c:	e9 b5 00 00 00       	jmp    80106316 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80106261:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106268:	00 
80106269:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106270:	00 
80106271:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106274:	89 04 24             	mov    %eax,(%esp)
80106277:	e8 42 f5 ff ff       	call   801057be <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010627c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010627f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106286:	00 
80106287:	89 44 24 08          	mov    %eax,0x8(%esp)
8010628b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010628e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106295:	89 04 24             	mov    %eax,(%esp)
80106298:	e8 40 c3 ff ff       	call   801025dd <writei>
8010629d:	83 f8 10             	cmp    $0x10,%eax
801062a0:	74 0c                	je     801062ae <sys_unlink+0x154>
    panic("unlink: writei");
801062a2:	c7 04 24 18 91 10 80 	movl   $0x80109118,(%esp)
801062a9:	e8 8f a2 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
801062ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062b5:	66 83 f8 01          	cmp    $0x1,%ax
801062b9:	75 1c                	jne    801062d7 <sys_unlink+0x17d>
    dp->nlink--;
801062bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062be:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062c2:	8d 50 ff             	lea    -0x1(%eax),%edx
801062c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801062cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cf:	89 04 24             	mov    %eax,(%esp)
801062d2:	e8 e9 ba ff ff       	call   80101dc0 <iupdate>
  }
  iunlockput(dp);
801062d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062da:	89 04 24             	mov    %eax,(%esp)
801062dd:	e8 1e bf ff ff       	call   80102200 <iunlockput>

  ip->nlink--;
801062e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801062ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ef:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801062f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f6:	89 04 24             	mov    %eax,(%esp)
801062f9:	e8 c2 ba ff ff       	call   80101dc0 <iupdate>
  iunlockput(ip);
801062fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106301:	89 04 24             	mov    %eax,(%esp)
80106304:	e8 f7 be ff ff       	call   80102200 <iunlockput>

  commit_trans();
80106309:	e8 6c d6 ff ff       	call   8010397a <commit_trans>

  return 0;
8010630e:	b8 00 00 00 00       	mov    $0x0,%eax
80106313:	eb 16                	jmp    8010632b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106315:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80106316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106319:	89 04 24             	mov    %eax,(%esp)
8010631c:	e8 df be ff ff       	call   80102200 <iunlockput>
  commit_trans();
80106321:	e8 54 d6 ff ff       	call   8010397a <commit_trans>
  return -1;
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010632b:	c9                   	leave  
8010632c:	c3                   	ret    

8010632d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010632d:	55                   	push   %ebp
8010632e:	89 e5                	mov    %esp,%ebp
80106330:	83 ec 48             	sub    $0x48,%esp
80106333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106336:	8b 55 10             	mov    0x10(%ebp),%edx
80106339:	8b 45 14             	mov    0x14(%ebp),%eax
8010633c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106340:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106344:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106348:	8d 45 de             	lea    -0x22(%ebp),%eax
8010634b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634f:	8b 45 08             	mov    0x8(%ebp),%eax
80106352:	89 04 24             	mov    %eax,(%esp)
80106355:	e8 e6 c7 ff ff       	call   80102b40 <nameiparent>
8010635a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010635d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106361:	75 0a                	jne    8010636d <create+0x40>
    return 0;
80106363:	b8 00 00 00 00       	mov    $0x0,%eax
80106368:	e9 7e 01 00 00       	jmp    801064eb <create+0x1be>
  ilock(dp);
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	89 04 24             	mov    %eax,(%esp)
80106373:	e8 04 bc ff ff       	call   80101f7c <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106378:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010637b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010637f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106382:	89 44 24 04          	mov    %eax,0x4(%esp)
80106386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106389:	89 04 24             	mov    %eax,(%esp)
8010638c:	e8 04 c4 ff ff       	call   80102795 <dirlookup>
80106391:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106394:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106398:	74 47                	je     801063e1 <create+0xb4>
    iunlockput(dp);
8010639a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639d:	89 04 24             	mov    %eax,(%esp)
801063a0:	e8 5b be ff ff       	call   80102200 <iunlockput>
    ilock(ip);
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	89 04 24             	mov    %eax,(%esp)
801063ab:	e8 cc bb ff ff       	call   80101f7c <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801063b0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801063b5:	75 15                	jne    801063cc <create+0x9f>
801063b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063be:	66 83 f8 02          	cmp    $0x2,%ax
801063c2:	75 08                	jne    801063cc <create+0x9f>
      return ip;
801063c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c7:	e9 1f 01 00 00       	jmp    801064eb <create+0x1be>
    iunlockput(ip);
801063cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cf:	89 04 24             	mov    %eax,(%esp)
801063d2:	e8 29 be ff ff       	call   80102200 <iunlockput>
    return 0;
801063d7:	b8 00 00 00 00       	mov    $0x0,%eax
801063dc:	e9 0a 01 00 00       	jmp    801064eb <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801063e1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801063e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e8:	8b 00                	mov    (%eax),%eax
801063ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801063ee:	89 04 24             	mov    %eax,(%esp)
801063f1:	e8 ed b8 ff ff       	call   80101ce3 <ialloc>
801063f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063fd:	75 0c                	jne    8010640b <create+0xde>
    panic("create: ialloc");
801063ff:	c7 04 24 27 91 10 80 	movl   $0x80109127,(%esp)
80106406:	e8 32 a1 ff ff       	call   8010053d <panic>

  ilock(ip);
8010640b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640e:	89 04 24             	mov    %eax,(%esp)
80106411:	e8 66 bb ff ff       	call   80101f7c <ilock>
  ip->major = major;
80106416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106419:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010641d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106424:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106428:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010642c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106438:	89 04 24             	mov    %eax,(%esp)
8010643b:	e8 80 b9 ff ff       	call   80101dc0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106440:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106445:	75 6a                	jne    801064b1 <create+0x184>
    dp->nlink++;  // for ".."
80106447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010644e:	8d 50 01             	lea    0x1(%eax),%edx
80106451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106454:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645b:	89 04 24             	mov    %eax,(%esp)
8010645e:	e8 5d b9 ff ff       	call   80101dc0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106463:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106466:	8b 40 04             	mov    0x4(%eax),%eax
80106469:	89 44 24 08          	mov    %eax,0x8(%esp)
8010646d:	c7 44 24 04 01 91 10 	movl   $0x80109101,0x4(%esp)
80106474:	80 
80106475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106478:	89 04 24             	mov    %eax,(%esp)
8010647b:	e8 dd c3 ff ff       	call   8010285d <dirlink>
80106480:	85 c0                	test   %eax,%eax
80106482:	78 21                	js     801064a5 <create+0x178>
80106484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106487:	8b 40 04             	mov    0x4(%eax),%eax
8010648a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010648e:	c7 44 24 04 03 91 10 	movl   $0x80109103,0x4(%esp)
80106495:	80 
80106496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106499:	89 04 24             	mov    %eax,(%esp)
8010649c:	e8 bc c3 ff ff       	call   8010285d <dirlink>
801064a1:	85 c0                	test   %eax,%eax
801064a3:	79 0c                	jns    801064b1 <create+0x184>
      panic("create dots");
801064a5:	c7 04 24 36 91 10 80 	movl   $0x80109136,(%esp)
801064ac:	e8 8c a0 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801064b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b4:	8b 40 04             	mov    0x4(%eax),%eax
801064b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801064bb:	8d 45 de             	lea    -0x22(%ebp),%eax
801064be:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c5:	89 04 24             	mov    %eax,(%esp)
801064c8:	e8 90 c3 ff ff       	call   8010285d <dirlink>
801064cd:	85 c0                	test   %eax,%eax
801064cf:	79 0c                	jns    801064dd <create+0x1b0>
    panic("create: dirlink");
801064d1:	c7 04 24 42 91 10 80 	movl   $0x80109142,(%esp)
801064d8:	e8 60 a0 ff ff       	call   8010053d <panic>

  iunlockput(dp);
801064dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e0:	89 04 24             	mov    %eax,(%esp)
801064e3:	e8 18 bd ff ff       	call   80102200 <iunlockput>

  return ip;
801064e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801064eb:	c9                   	leave  
801064ec:	c3                   	ret    

801064ed <sys_open>:

int
sys_open(void)
{
801064ed:	55                   	push   %ebp
801064ee:	89 e5                	mov    %esp,%ebp
801064f0:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801064f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106501:	e8 a2 f6 ff ff       	call   80105ba8 <argstr>
80106506:	85 c0                	test   %eax,%eax
80106508:	78 17                	js     80106521 <sys_open+0x34>
8010650a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010650d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106511:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106518:	e8 f1 f5 ff ff       	call   80105b0e <argint>
8010651d:	85 c0                	test   %eax,%eax
8010651f:	79 0a                	jns    8010652b <sys_open+0x3e>
    return -1;
80106521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106526:	e9 46 01 00 00       	jmp    80106671 <sys_open+0x184>
  if(omode & O_CREATE){
8010652b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010652e:	25 00 02 00 00       	and    $0x200,%eax
80106533:	85 c0                	test   %eax,%eax
80106535:	74 40                	je     80106577 <sys_open+0x8a>
    begin_trans();
80106537:	e8 f5 d3 ff ff       	call   80103931 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
8010653c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010653f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106546:	00 
80106547:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010654e:	00 
8010654f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106556:	00 
80106557:	89 04 24             	mov    %eax,(%esp)
8010655a:	e8 ce fd ff ff       	call   8010632d <create>
8010655f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80106562:	e8 13 d4 ff ff       	call   8010397a <commit_trans>
    if(ip == 0)
80106567:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010656b:	75 5c                	jne    801065c9 <sys_open+0xdc>
      return -1;
8010656d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106572:	e9 fa 00 00 00       	jmp    80106671 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80106577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010657a:	89 04 24             	mov    %eax,(%esp)
8010657d:	e8 9c c5 ff ff       	call   80102b1e <namei>
80106582:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106589:	75 0a                	jne    80106595 <sys_open+0xa8>
      return -1;
8010658b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106590:	e9 dc 00 00 00       	jmp    80106671 <sys_open+0x184>
    ilock(ip);
80106595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106598:	89 04 24             	mov    %eax,(%esp)
8010659b:	e8 dc b9 ff ff       	call   80101f7c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801065a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065a7:	66 83 f8 01          	cmp    $0x1,%ax
801065ab:	75 1c                	jne    801065c9 <sys_open+0xdc>
801065ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b0:	85 c0                	test   %eax,%eax
801065b2:	74 15                	je     801065c9 <sys_open+0xdc>
      iunlockput(ip);
801065b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b7:	89 04 24             	mov    %eax,(%esp)
801065ba:	e8 41 bc ff ff       	call   80102200 <iunlockput>
      return -1;
801065bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c4:	e9 a8 00 00 00       	jmp    80106671 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801065c9:	e8 62 b0 ff ff       	call   80101630 <filealloc>
801065ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065d5:	74 14                	je     801065eb <sys_open+0xfe>
801065d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065da:	89 04 24             	mov    %eax,(%esp)
801065dd:	e8 43 f7 ff ff       	call   80105d25 <fdalloc>
801065e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801065e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801065e9:	79 23                	jns    8010660e <sys_open+0x121>
    if(f)
801065eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ef:	74 0b                	je     801065fc <sys_open+0x10f>
      fileclose(f);
801065f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f4:	89 04 24             	mov    %eax,(%esp)
801065f7:	e8 dc b0 ff ff       	call   801016d8 <fileclose>
    iunlockput(ip);
801065fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ff:	89 04 24             	mov    %eax,(%esp)
80106602:	e8 f9 bb ff ff       	call   80102200 <iunlockput>
    return -1;
80106607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660c:	eb 63                	jmp    80106671 <sys_open+0x184>
  }
  iunlock(ip);
8010660e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106611:	89 04 24             	mov    %eax,(%esp)
80106614:	e8 b1 ba ff ff       	call   801020ca <iunlock>

  f->type = FD_INODE;
80106619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010661c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106628:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010662b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010662e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106638:	83 e0 01             	and    $0x1,%eax
8010663b:	85 c0                	test   %eax,%eax
8010663d:	0f 94 c2             	sete   %dl
80106640:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106643:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106646:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106649:	83 e0 01             	and    $0x1,%eax
8010664c:	84 c0                	test   %al,%al
8010664e:	75 0a                	jne    8010665a <sys_open+0x16d>
80106650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106653:	83 e0 02             	and    $0x2,%eax
80106656:	85 c0                	test   %eax,%eax
80106658:	74 07                	je     80106661 <sys_open+0x174>
8010665a:	b8 01 00 00 00       	mov    $0x1,%eax
8010665f:	eb 05                	jmp    80106666 <sys_open+0x179>
80106661:	b8 00 00 00 00       	mov    $0x0,%eax
80106666:	89 c2                	mov    %eax,%edx
80106668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010666e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106671:	c9                   	leave  
80106672:	c3                   	ret    

80106673 <sys_mkdir>:

int
sys_mkdir(void)
{
80106673:	55                   	push   %ebp
80106674:	89 e5                	mov    %esp,%ebp
80106676:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80106679:	e8 b3 d2 ff ff       	call   80103931 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010667e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106681:	89 44 24 04          	mov    %eax,0x4(%esp)
80106685:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010668c:	e8 17 f5 ff ff       	call   80105ba8 <argstr>
80106691:	85 c0                	test   %eax,%eax
80106693:	78 2c                	js     801066c1 <sys_mkdir+0x4e>
80106695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106698:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010669f:	00 
801066a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801066a7:	00 
801066a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801066af:	00 
801066b0:	89 04 24             	mov    %eax,(%esp)
801066b3:	e8 75 fc ff ff       	call   8010632d <create>
801066b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066bf:	75 0c                	jne    801066cd <sys_mkdir+0x5a>
    commit_trans();
801066c1:	e8 b4 d2 ff ff       	call   8010397a <commit_trans>
    return -1;
801066c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cb:	eb 15                	jmp    801066e2 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801066cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d0:	89 04 24             	mov    %eax,(%esp)
801066d3:	e8 28 bb ff ff       	call   80102200 <iunlockput>
  commit_trans();
801066d8:	e8 9d d2 ff ff       	call   8010397a <commit_trans>
  return 0;
801066dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066e2:	c9                   	leave  
801066e3:	c3                   	ret    

801066e4 <sys_mknod>:

int
sys_mknod(void)
{
801066e4:	55                   	push   %ebp
801066e5:	89 e5                	mov    %esp,%ebp
801066e7:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
801066ea:	e8 42 d2 ff ff       	call   80103931 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
801066ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066fd:	e8 a6 f4 ff ff       	call   80105ba8 <argstr>
80106702:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106709:	78 5e                	js     80106769 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010670b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010670e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106712:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106719:	e8 f0 f3 ff ff       	call   80105b0e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010671e:	85 c0                	test   %eax,%eax
80106720:	78 47                	js     80106769 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106722:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106725:	89 44 24 04          	mov    %eax,0x4(%esp)
80106729:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106730:	e8 d9 f3 ff ff       	call   80105b0e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106735:	85 c0                	test   %eax,%eax
80106737:	78 30                	js     80106769 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010673c:	0f bf c8             	movswl %ax,%ecx
8010673f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106742:	0f bf d0             	movswl %ax,%edx
80106745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106748:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010674c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106750:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106757:	00 
80106758:	89 04 24             	mov    %eax,(%esp)
8010675b:	e8 cd fb ff ff       	call   8010632d <create>
80106760:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106763:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106767:	75 0c                	jne    80106775 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80106769:	e8 0c d2 ff ff       	call   8010397a <commit_trans>
    return -1;
8010676e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106773:	eb 15                	jmp    8010678a <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106778:	89 04 24             	mov    %eax,(%esp)
8010677b:	e8 80 ba ff ff       	call   80102200 <iunlockput>
  commit_trans();
80106780:	e8 f5 d1 ff ff       	call   8010397a <commit_trans>
  return 0;
80106785:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010678a:	c9                   	leave  
8010678b:	c3                   	ret    

8010678c <sys_chdir>:

int
sys_chdir(void)
{
8010678c:	55                   	push   %ebp
8010678d:	89 e5                	mov    %esp,%ebp
8010678f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80106792:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106795:	89 44 24 04          	mov    %eax,0x4(%esp)
80106799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067a0:	e8 03 f4 ff ff       	call   80105ba8 <argstr>
801067a5:	85 c0                	test   %eax,%eax
801067a7:	78 14                	js     801067bd <sys_chdir+0x31>
801067a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ac:	89 04 24             	mov    %eax,(%esp)
801067af:	e8 6a c3 ff ff       	call   80102b1e <namei>
801067b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067bb:	75 07                	jne    801067c4 <sys_chdir+0x38>
    return -1;
801067bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c2:	eb 57                	jmp    8010681b <sys_chdir+0x8f>
  ilock(ip);
801067c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c7:	89 04 24             	mov    %eax,(%esp)
801067ca:	e8 ad b7 ff ff       	call   80101f7c <ilock>
  if(ip->type != T_DIR){
801067cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067d6:	66 83 f8 01          	cmp    $0x1,%ax
801067da:	74 12                	je     801067ee <sys_chdir+0x62>
    iunlockput(ip);
801067dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067df:	89 04 24             	mov    %eax,(%esp)
801067e2:	e8 19 ba ff ff       	call   80102200 <iunlockput>
    return -1;
801067e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ec:	eb 2d                	jmp    8010681b <sys_chdir+0x8f>
  }
  iunlock(ip);
801067ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f1:	89 04 24             	mov    %eax,(%esp)
801067f4:	e8 d1 b8 ff ff       	call   801020ca <iunlock>
  iput(proc->cwd);
801067f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067ff:	8b 40 68             	mov    0x68(%eax),%eax
80106802:	89 04 24             	mov    %eax,(%esp)
80106805:	e8 25 b9 ff ff       	call   8010212f <iput>
  proc->cwd = ip;
8010680a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106810:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106813:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106816:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010681b:	c9                   	leave  
8010681c:	c3                   	ret    

8010681d <sys_exec>:

int
sys_exec(void)
{
8010681d:	55                   	push   %ebp
8010681e:	89 e5                	mov    %esp,%ebp
80106820:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106826:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106829:	89 44 24 04          	mov    %eax,0x4(%esp)
8010682d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106834:	e8 6f f3 ff ff       	call   80105ba8 <argstr>
80106839:	85 c0                	test   %eax,%eax
8010683b:	78 1a                	js     80106857 <sys_exec+0x3a>
8010683d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106843:	89 44 24 04          	mov    %eax,0x4(%esp)
80106847:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010684e:	e8 bb f2 ff ff       	call   80105b0e <argint>
80106853:	85 c0                	test   %eax,%eax
80106855:	79 0a                	jns    80106861 <sys_exec+0x44>
    return -1;
80106857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685c:	e9 e2 00 00 00       	jmp    80106943 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
80106861:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106868:	00 
80106869:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106870:	00 
80106871:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106877:	89 04 24             	mov    %eax,(%esp)
8010687a:	e8 3f ef ff ff       	call   801057be <memset>
  for(i=0;; i++){
8010687f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106889:	83 f8 1f             	cmp    $0x1f,%eax
8010688c:	76 0a                	jbe    80106898 <sys_exec+0x7b>
      return -1;
8010688e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106893:	e9 ab 00 00 00       	jmp    80106943 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80106898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689b:	c1 e0 02             	shl    $0x2,%eax
8010689e:	89 c2                	mov    %eax,%edx
801068a0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801068a6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801068a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068af:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801068b5:	89 54 24 08          	mov    %edx,0x8(%esp)
801068b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801068bd:	89 04 24             	mov    %eax,(%esp)
801068c0:	e8 b7 f1 ff ff       	call   80105a7c <fetchint>
801068c5:	85 c0                	test   %eax,%eax
801068c7:	79 07                	jns    801068d0 <sys_exec+0xb3>
      return -1;
801068c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ce:	eb 73                	jmp    80106943 <sys_exec+0x126>
    if(uarg == 0){
801068d0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068d6:	85 c0                	test   %eax,%eax
801068d8:	75 26                	jne    80106900 <sys_exec+0xe3>
      argv[i] = 0;
801068da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068dd:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801068e4:	00 00 00 00 
      break;
801068e8:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801068e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ec:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801068f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801068f6:	89 04 24             	mov    %eax,(%esp)
801068f9:	e8 b2 a7 ff ff       	call   801010b0 <exec>
801068fe:	eb 43                	jmp    80106943 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106903:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010690a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106910:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106913:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010691f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106923:	89 54 24 04          	mov    %edx,0x4(%esp)
80106927:	89 04 24             	mov    %eax,(%esp)
8010692a:	e8 81 f1 ff ff       	call   80105ab0 <fetchstr>
8010692f:	85 c0                	test   %eax,%eax
80106931:	79 07                	jns    8010693a <sys_exec+0x11d>
      return -1;
80106933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106938:	eb 09                	jmp    80106943 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010693a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010693e:	e9 43 ff ff ff       	jmp    80106886 <sys_exec+0x69>
  return exec(path, argv);
}
80106943:	c9                   	leave  
80106944:	c3                   	ret    

80106945 <sys_pipe>:

int
sys_pipe(void)
{
80106945:	55                   	push   %ebp
80106946:	89 e5                	mov    %esp,%ebp
80106948:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010694b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106952:	00 
80106953:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106956:	89 44 24 04          	mov    %eax,0x4(%esp)
8010695a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106961:	e8 e0 f1 ff ff       	call   80105b46 <argptr>
80106966:	85 c0                	test   %eax,%eax
80106968:	79 0a                	jns    80106974 <sys_pipe+0x2f>
    return -1;
8010696a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010696f:	e9 9b 00 00 00       	jmp    80106a0f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106974:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106977:	89 44 24 04          	mov    %eax,0x4(%esp)
8010697b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010697e:	89 04 24             	mov    %eax,(%esp)
80106981:	e8 c6 d9 ff ff       	call   8010434c <pipealloc>
80106986:	85 c0                	test   %eax,%eax
80106988:	79 07                	jns    80106991 <sys_pipe+0x4c>
    return -1;
8010698a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698f:	eb 7e                	jmp    80106a0f <sys_pipe+0xca>
  fd0 = -1;
80106991:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106998:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010699b:	89 04 24             	mov    %eax,(%esp)
8010699e:	e8 82 f3 ff ff       	call   80105d25 <fdalloc>
801069a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069aa:	78 14                	js     801069c0 <sys_pipe+0x7b>
801069ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069af:	89 04 24             	mov    %eax,(%esp)
801069b2:	e8 6e f3 ff ff       	call   80105d25 <fdalloc>
801069b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069be:	79 37                	jns    801069f7 <sys_pipe+0xb2>
    if(fd0 >= 0)
801069c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069c4:	78 14                	js     801069da <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801069c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069cf:	83 c2 08             	add    $0x8,%edx
801069d2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801069d9:	00 
    fileclose(rf);
801069da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069dd:	89 04 24             	mov    %eax,(%esp)
801069e0:	e8 f3 ac ff ff       	call   801016d8 <fileclose>
    fileclose(wf);
801069e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069e8:	89 04 24             	mov    %eax,(%esp)
801069eb:	e8 e8 ac ff ff       	call   801016d8 <fileclose>
    return -1;
801069f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f5:	eb 18                	jmp    80106a0f <sys_pipe+0xca>
  }
  fd[0] = fd0;
801069f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069fd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801069ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a02:	8d 50 04             	lea    0x4(%eax),%edx
80106a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a08:	89 02                	mov    %eax,(%edx)
  return 0;
80106a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a0f:	c9                   	leave  
80106a10:	c3                   	ret    
80106a11:	00 00                	add    %al,(%eax)
	...

80106a14 <sys_fork>:
#include "proc.h"


int
sys_fork(void)
{
80106a14:	55                   	push   %ebp
80106a15:	89 e5                	mov    %esp,%ebp
80106a17:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106a1a:	e8 65 e0 ff ff       	call   80104a84 <fork>
}
80106a1f:	c9                   	leave  
80106a20:	c3                   	ret    

80106a21 <sys_exit>:

int
sys_exit(void)
{
80106a21:	55                   	push   %ebp
80106a22:	89 e5                	mov    %esp,%ebp
80106a24:	83 ec 08             	sub    $0x8,%esp
  exit();
80106a27:	e8 bb e1 ff ff       	call   80104be7 <exit>
  return 0;  // not reached
80106a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a31:	c9                   	leave  
80106a32:	c3                   	ret    

80106a33 <sys_wait>:

int
sys_wait(void)
{
80106a33:	55                   	push   %ebp
80106a34:	89 e5                	mov    %esp,%ebp
80106a36:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106a39:	e8 d6 e2 ff ff       	call   80104d14 <wait>
}
80106a3e:	c9                   	leave  
80106a3f:	c3                   	ret    

80106a40 <sys_wait2>:

int
sys_wait2(void)
{
80106a40:	55                   	push   %ebp
80106a41:	89 e5                	mov    %esp,%ebp
80106a43:	83 ec 28             	sub    $0x28,%esp
  int *wtime, *rtime, *iotime; 
  if (argptr(0, (void*)&wtime, sizeof(wtime)) <0) return -1;
80106a46:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106a4d:	00 
80106a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a51:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a5c:	e8 e5 f0 ff ff       	call   80105b46 <argptr>
80106a61:	85 c0                	test   %eax,%eax
80106a63:	79 07                	jns    80106a6c <sys_wait2+0x2c>
80106a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6a:	eb 65                	jmp    80106ad1 <sys_wait2+0x91>
  if (argptr(1, (void*)&rtime, sizeof(rtime)) <0) return -1;
80106a6c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106a73:	00 
80106a74:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a77:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a82:	e8 bf f0 ff ff       	call   80105b46 <argptr>
80106a87:	85 c0                	test   %eax,%eax
80106a89:	79 07                	jns    80106a92 <sys_wait2+0x52>
80106a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a90:	eb 3f                	jmp    80106ad1 <sys_wait2+0x91>
  if (argptr(2, (void*)&iotime, sizeof(iotime)) <0) return -1;
80106a92:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106a99:	00 
80106a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106aa8:	e8 99 f0 ff ff       	call   80105b46 <argptr>
80106aad:	85 c0                	test   %eax,%eax
80106aaf:	79 07                	jns    80106ab8 <sys_wait2+0x78>
80106ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab6:	eb 19                	jmp    80106ad1 <sys_wait2+0x91>
  return wait2(wtime, rtime, iotime);
80106ab8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106abb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ac9:	89 04 24             	mov    %eax,(%esp)
80106acc:	e8 55 e3 ff ff       	call   80104e26 <wait2>
}
80106ad1:	c9                   	leave  
80106ad2:	c3                   	ret    

80106ad3 <sys_kill>:

int
sys_kill(void)
{
80106ad3:	55                   	push   %ebp
80106ad4:	89 e5                	mov    %esp,%ebp
80106ad6:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106adc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ae7:	e8 22 f0 ff ff       	call   80105b0e <argint>
80106aec:	85 c0                	test   %eax,%eax
80106aee:	79 07                	jns    80106af7 <sys_kill+0x24>
    return -1;
80106af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af5:	eb 0b                	jmp    80106b02 <sys_kill+0x2f>
  return kill(pid);
80106af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afa:	89 04 24             	mov    %eax,(%esp)
80106afd:	e8 8e e8 ff ff       	call   80105390 <kill>
}
80106b02:	c9                   	leave  
80106b03:	c3                   	ret    

80106b04 <sys_getpid>:

int
sys_getpid(void)
{
80106b04:	55                   	push   %ebp
80106b05:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106b07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b0d:	8b 40 10             	mov    0x10(%eax),%eax
}
80106b10:	5d                   	pop    %ebp
80106b11:	c3                   	ret    

80106b12 <sys_sbrk>:

int
sys_sbrk(void)
{
80106b12:	55                   	push   %ebp
80106b13:	89 e5                	mov    %esp,%ebp
80106b15:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106b18:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b26:	e8 e3 ef ff ff       	call   80105b0e <argint>
80106b2b:	85 c0                	test   %eax,%eax
80106b2d:	79 07                	jns    80106b36 <sys_sbrk+0x24>
    return -1;
80106b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b34:	eb 24                	jmp    80106b5a <sys_sbrk+0x48>
  addr = proc->sz;
80106b36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b3c:	8b 00                	mov    (%eax),%eax
80106b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b44:	89 04 24             	mov    %eax,(%esp)
80106b47:	e8 93 de ff ff       	call   801049df <growproc>
80106b4c:	85 c0                	test   %eax,%eax
80106b4e:	79 07                	jns    80106b57 <sys_sbrk+0x45>
    return -1;
80106b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b55:	eb 03                	jmp    80106b5a <sys_sbrk+0x48>
  return addr;
80106b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b5a:	c9                   	leave  
80106b5b:	c3                   	ret    

80106b5c <sys_sleep>:

int
sys_sleep(void)
{
80106b5c:	55                   	push   %ebp
80106b5d:	89 e5                	mov    %esp,%ebp
80106b5f:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106b62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b65:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b70:	e8 99 ef ff ff       	call   80105b0e <argint>
80106b75:	85 c0                	test   %eax,%eax
80106b77:	79 07                	jns    80106b80 <sys_sleep+0x24>
    return -1;
80106b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b7e:	eb 6c                	jmp    80106bec <sys_sleep+0x90>
  acquire(&tickslock);
80106b80:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106b87:	e8 e3 e9 ff ff       	call   8010556f <acquire>
  ticks0 = ticks;
80106b8c:	a1 60 4f 11 80       	mov    0x80114f60,%eax
80106b91:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106b94:	eb 34                	jmp    80106bca <sys_sleep+0x6e>
    if(proc->killed){
80106b96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b9c:	8b 40 24             	mov    0x24(%eax),%eax
80106b9f:	85 c0                	test   %eax,%eax
80106ba1:	74 13                	je     80106bb6 <sys_sleep+0x5a>
      release(&tickslock);
80106ba3:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106baa:	e8 22 ea ff ff       	call   801055d1 <release>
      return -1;
80106baf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bb4:	eb 36                	jmp    80106bec <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106bb6:	c7 44 24 04 20 47 11 	movl   $0x80114720,0x4(%esp)
80106bbd:	80 
80106bbe:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80106bc5:	e8 2d e6 ff ff       	call   801051f7 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106bca:	a1 60 4f 11 80       	mov    0x80114f60,%eax
80106bcf:	89 c2                	mov    %eax,%edx
80106bd1:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bd7:	39 c2                	cmp    %eax,%edx
80106bd9:	72 bb                	jb     80106b96 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106bdb:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106be2:	e8 ea e9 ff ff       	call   801055d1 <release>
  return 0;
80106be7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bec:	c9                   	leave  
80106bed:	c3                   	ret    

80106bee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106bee:	55                   	push   %ebp
80106bef:	89 e5                	mov    %esp,%ebp
80106bf1:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106bf4:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106bfb:	e8 6f e9 ff ff       	call   8010556f <acquire>
  xticks = ticks;
80106c00:	a1 60 4f 11 80       	mov    0x80114f60,%eax
80106c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106c08:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106c0f:	e8 bd e9 ff ff       	call   801055d1 <release>
  return xticks;
80106c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c17:	c9                   	leave  
80106c18:	c3                   	ret    

80106c19 <sys_add_path>:

// assignment1 - 1.2 - returning to the "real" implementation in sh.c
int
sys_add_path(void) {
80106c19:	55                   	push   %ebp
80106c1a:	89 e5                	mov    %esp,%ebp
80106c1c:	83 ec 28             	sub    $0x28,%esp
          char *path;
          if(argstr(0, &path) < 0)
80106c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c22:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c2d:	e8 76 ef ff ff       	call   80105ba8 <argstr>
80106c32:	85 c0                	test   %eax,%eax
80106c34:	79 07                	jns    80106c3d <sys_add_path+0x24>
            return -1;
80106c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c3b:	eb 0b                	jmp    80106c48 <sys_add_path+0x2f>
          return add_path(path);
80106c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c40:	89 04 24             	mov    %eax,(%esp)
80106c43:	e8 3e a9 ff ff       	call   80101586 <add_path>

}
80106c48:	c9                   	leave  
80106c49:	c3                   	ret    
	...

80106c4c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c4c:	55                   	push   %ebp
80106c4d:	89 e5                	mov    %esp,%ebp
80106c4f:	83 ec 08             	sub    $0x8,%esp
80106c52:	8b 55 08             	mov    0x8(%ebp),%edx
80106c55:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c58:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c5c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c5f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c63:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c67:	ee                   	out    %al,(%dx)
}
80106c68:	c9                   	leave  
80106c69:	c3                   	ret    

80106c6a <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106c6a:	55                   	push   %ebp
80106c6b:	89 e5                	mov    %esp,%ebp
80106c6d:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106c70:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106c77:	00 
80106c78:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106c7f:	e8 c8 ff ff ff       	call   80106c4c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106c84:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106c8b:	00 
80106c8c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106c93:	e8 b4 ff ff ff       	call   80106c4c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106c98:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106c9f:	00 
80106ca0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106ca7:	e8 a0 ff ff ff       	call   80106c4c <outb>
  picenable(IRQ_TIMER);
80106cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cb3:	e8 1d d5 ff ff       	call   801041d5 <picenable>
}
80106cb8:	c9                   	leave  
80106cb9:	c3                   	ret    
	...

80106cbc <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106cbc:	1e                   	push   %ds
  pushl %es
80106cbd:	06                   	push   %es
  pushl %fs
80106cbe:	0f a0                	push   %fs
  pushl %gs
80106cc0:	0f a8                	push   %gs
  pushal
80106cc2:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106cc3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106cc7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106cc9:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106ccb:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106ccf:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106cd1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106cd3:	54                   	push   %esp
  call trap
80106cd4:	e8 de 01 00 00       	call   80106eb7 <trap>
  addl $4, %esp
80106cd9:	83 c4 04             	add    $0x4,%esp

80106cdc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106cdc:	61                   	popa   
  popl %gs
80106cdd:	0f a9                	pop    %gs
  popl %fs
80106cdf:	0f a1                	pop    %fs
  popl %es
80106ce1:	07                   	pop    %es
  popl %ds
80106ce2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ce3:	83 c4 08             	add    $0x8,%esp
  iret
80106ce6:	cf                   	iret   
	...

80106ce8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106ce8:	55                   	push   %ebp
80106ce9:	89 e5                	mov    %esp,%ebp
80106ceb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cf1:	83 e8 01             	sub    $0x1,%eax
80106cf4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cfb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106cff:	8b 45 08             	mov    0x8(%ebp),%eax
80106d02:	c1 e8 10             	shr    $0x10,%eax
80106d05:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106d09:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106d0c:	0f 01 18             	lidtl  (%eax)
}
80106d0f:	c9                   	leave  
80106d10:	c3                   	ret    

80106d11 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106d11:	55                   	push   %ebp
80106d12:	89 e5                	mov    %esp,%ebp
80106d14:	53                   	push   %ebx
80106d15:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106d18:	0f 20 d3             	mov    %cr2,%ebx
80106d1b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106d1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106d21:	83 c4 10             	add    $0x10,%esp
80106d24:	5b                   	pop    %ebx
80106d25:	5d                   	pop    %ebp
80106d26:	c3                   	ret    

80106d27 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106d27:	55                   	push   %ebp
80106d28:	89 e5                	mov    %esp,%ebp
80106d2a:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106d2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d34:	e9 c3 00 00 00       	jmp    80106dfc <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d3c:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106d43:	89 c2                	mov    %eax,%edx
80106d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d48:	66 89 14 c5 60 47 11 	mov    %dx,-0x7feeb8a0(,%eax,8)
80106d4f:	80 
80106d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d53:	66 c7 04 c5 62 47 11 	movw   $0x8,-0x7feeb89e(,%eax,8)
80106d5a:	80 08 00 
80106d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d60:	0f b6 14 c5 64 47 11 	movzbl -0x7feeb89c(,%eax,8),%edx
80106d67:	80 
80106d68:	83 e2 e0             	and    $0xffffffe0,%edx
80106d6b:	88 14 c5 64 47 11 80 	mov    %dl,-0x7feeb89c(,%eax,8)
80106d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d75:	0f b6 14 c5 64 47 11 	movzbl -0x7feeb89c(,%eax,8),%edx
80106d7c:	80 
80106d7d:	83 e2 1f             	and    $0x1f,%edx
80106d80:	88 14 c5 64 47 11 80 	mov    %dl,-0x7feeb89c(,%eax,8)
80106d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d8a:	0f b6 14 c5 65 47 11 	movzbl -0x7feeb89b(,%eax,8),%edx
80106d91:	80 
80106d92:	83 e2 f0             	and    $0xfffffff0,%edx
80106d95:	83 ca 0e             	or     $0xe,%edx
80106d98:	88 14 c5 65 47 11 80 	mov    %dl,-0x7feeb89b(,%eax,8)
80106d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106da2:	0f b6 14 c5 65 47 11 	movzbl -0x7feeb89b(,%eax,8),%edx
80106da9:	80 
80106daa:	83 e2 ef             	and    $0xffffffef,%edx
80106dad:	88 14 c5 65 47 11 80 	mov    %dl,-0x7feeb89b(,%eax,8)
80106db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db7:	0f b6 14 c5 65 47 11 	movzbl -0x7feeb89b(,%eax,8),%edx
80106dbe:	80 
80106dbf:	83 e2 9f             	and    $0xffffff9f,%edx
80106dc2:	88 14 c5 65 47 11 80 	mov    %dl,-0x7feeb89b(,%eax,8)
80106dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dcc:	0f b6 14 c5 65 47 11 	movzbl -0x7feeb89b(,%eax,8),%edx
80106dd3:	80 
80106dd4:	83 ca 80             	or     $0xffffff80,%edx
80106dd7:	88 14 c5 65 47 11 80 	mov    %dl,-0x7feeb89b(,%eax,8)
80106dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106de1:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106de8:	c1 e8 10             	shr    $0x10,%eax
80106deb:	89 c2                	mov    %eax,%edx
80106ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df0:	66 89 14 c5 66 47 11 	mov    %dx,-0x7feeb89a(,%eax,8)
80106df7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106df8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dfc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106e03:	0f 8e 30 ff ff ff    	jle    80106d39 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106e09:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106e0e:	66 a3 60 49 11 80    	mov    %ax,0x80114960
80106e14:	66 c7 05 62 49 11 80 	movw   $0x8,0x80114962
80106e1b:	08 00 
80106e1d:	0f b6 05 64 49 11 80 	movzbl 0x80114964,%eax
80106e24:	83 e0 e0             	and    $0xffffffe0,%eax
80106e27:	a2 64 49 11 80       	mov    %al,0x80114964
80106e2c:	0f b6 05 64 49 11 80 	movzbl 0x80114964,%eax
80106e33:	83 e0 1f             	and    $0x1f,%eax
80106e36:	a2 64 49 11 80       	mov    %al,0x80114964
80106e3b:	0f b6 05 65 49 11 80 	movzbl 0x80114965,%eax
80106e42:	83 c8 0f             	or     $0xf,%eax
80106e45:	a2 65 49 11 80       	mov    %al,0x80114965
80106e4a:	0f b6 05 65 49 11 80 	movzbl 0x80114965,%eax
80106e51:	83 e0 ef             	and    $0xffffffef,%eax
80106e54:	a2 65 49 11 80       	mov    %al,0x80114965
80106e59:	0f b6 05 65 49 11 80 	movzbl 0x80114965,%eax
80106e60:	83 c8 60             	or     $0x60,%eax
80106e63:	a2 65 49 11 80       	mov    %al,0x80114965
80106e68:	0f b6 05 65 49 11 80 	movzbl 0x80114965,%eax
80106e6f:	83 c8 80             	or     $0xffffff80,%eax
80106e72:	a2 65 49 11 80       	mov    %al,0x80114965
80106e77:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106e7c:	c1 e8 10             	shr    $0x10,%eax
80106e7f:	66 a3 66 49 11 80    	mov    %ax,0x80114966
  
  initlock(&tickslock, "time");
80106e85:	c7 44 24 04 54 91 10 	movl   $0x80109154,0x4(%esp)
80106e8c:	80 
80106e8d:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106e94:	e8 b5 e6 ff ff       	call   8010554e <initlock>
}
80106e99:	c9                   	leave  
80106e9a:	c3                   	ret    

80106e9b <idtinit>:

void
idtinit(void)
{
80106e9b:	55                   	push   %ebp
80106e9c:	89 e5                	mov    %esp,%ebp
80106e9e:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ea1:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106ea8:	00 
80106ea9:	c7 04 24 60 47 11 80 	movl   $0x80114760,(%esp)
80106eb0:	e8 33 fe ff ff       	call   80106ce8 <lidt>
}
80106eb5:	c9                   	leave  
80106eb6:	c3                   	ret    

80106eb7 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106eb7:	55                   	push   %ebp
80106eb8:	89 e5                	mov    %esp,%ebp
80106eba:	57                   	push   %edi
80106ebb:	56                   	push   %esi
80106ebc:	53                   	push   %ebx
80106ebd:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
80106ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec3:	8b 40 30             	mov    0x30(%eax),%eax
80106ec6:	83 f8 40             	cmp    $0x40,%eax
80106ec9:	75 3e                	jne    80106f09 <trap+0x52>
    if(proc->killed)
80106ecb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed1:	8b 40 24             	mov    0x24(%eax),%eax
80106ed4:	85 c0                	test   %eax,%eax
80106ed6:	74 05                	je     80106edd <trap+0x26>
      exit();
80106ed8:	e8 0a dd ff ff       	call   80104be7 <exit>
    proc->tf = tf;
80106edd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ee3:	8b 55 08             	mov    0x8(%ebp),%edx
80106ee6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ee9:	e8 fd ec ff ff       	call   80105beb <syscall>
    if(proc->killed)
80106eee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef4:	8b 40 24             	mov    0x24(%eax),%eax
80106ef7:	85 c0                	test   %eax,%eax
80106ef9:	0f 84 f9 02 00 00    	je     801071f8 <trap+0x341>
      exit();
80106eff:	e8 e3 dc ff ff       	call   80104be7 <exit>
    return;
80106f04:	e9 ef 02 00 00       	jmp    801071f8 <trap+0x341>
  }

  switch(tf->trapno){
80106f09:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0c:	8b 40 30             	mov    0x30(%eax),%eax
80106f0f:	83 e8 20             	sub    $0x20,%eax
80106f12:	83 f8 1f             	cmp    $0x1f,%eax
80106f15:	0f 87 10 01 00 00    	ja     8010702b <trap+0x174>
80106f1b:	8b 04 85 fc 91 10 80 	mov    -0x7fef6e04(,%eax,4),%eax
80106f22:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106f24:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f2a:	0f b6 00             	movzbl (%eax),%eax
80106f2d:	84 c0                	test   %al,%al
80106f2f:	0f 85 81 00 00 00    	jne    80106fb6 <trap+0xff>
      acquire(&tickslock);
80106f35:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106f3c:	e8 2e e6 ff ff       	call   8010556f <acquire>
      ticks++;
80106f41:	a1 60 4f 11 80       	mov    0x80114f60,%eax
80106f46:	83 c0 01             	add    $0x1,%eax
80106f49:	a3 60 4f 11 80       	mov    %eax,0x80114f60
      if (proc && proc->state == RUNNING){
80106f4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f54:	85 c0                	test   %eax,%eax
80106f56:	74 46                	je     80106f9e <trap+0xe7>
80106f58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f5e:	8b 40 0c             	mov    0xc(%eax),%eax
80106f61:	83 f8 04             	cmp    $0x4,%eax
80106f64:	75 38                	jne    80106f9e <trap+0xe7>
	proc->rtime = proc->rtime + 1;
80106f66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f6c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106f73:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80106f79:	83 c2 01             	add    $0x1,%edx
80106f7c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
	proc->quanta = proc->quanta + 1;
80106f82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f88:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106f8f:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
80106f95:	83 c2 01             	add    $0x1,%edx
80106f98:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      }
      wakeup(&ticks);
80106f9e:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80106fa5:	e8 bb e3 ff ff       	call   80105365 <wakeup>
      release(&tickslock);
80106faa:	c7 04 24 20 47 11 80 	movl   $0x80114720,(%esp)
80106fb1:	e8 1b e6 ff ff       	call   801055d1 <release>
    }
    lapiceoi();
80106fb6:	e8 42 c6 ff ff       	call   801035fd <lapiceoi>
    break;
80106fbb:	e9 41 01 00 00       	jmp    80107101 <trap+0x24a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106fc0:	e8 40 be ff ff       	call   80102e05 <ideintr>
    lapiceoi();
80106fc5:	e8 33 c6 ff ff       	call   801035fd <lapiceoi>
    break;
80106fca:	e9 32 01 00 00       	jmp    80107101 <trap+0x24a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106fcf:	e8 07 c4 ff ff       	call   801033db <kbdintr>
    lapiceoi();
80106fd4:	e8 24 c6 ff ff       	call   801035fd <lapiceoi>
    break;
80106fd9:	e9 23 01 00 00       	jmp    80107101 <trap+0x24a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106fde:	e8 1d 04 00 00       	call   80107400 <uartintr>
    lapiceoi();
80106fe3:	e8 15 c6 ff ff       	call   801035fd <lapiceoi>
    break;
80106fe8:	e9 14 01 00 00       	jmp    80107101 <trap+0x24a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106fed:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ff0:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ff6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ffa:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106ffd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107003:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107006:	0f b6 c0             	movzbl %al,%eax
80107009:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010700d:	89 54 24 08          	mov    %edx,0x8(%esp)
80107011:	89 44 24 04          	mov    %eax,0x4(%esp)
80107015:	c7 04 24 5c 91 10 80 	movl   $0x8010915c,(%esp)
8010701c:	e8 80 93 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107021:	e8 d7 c5 ff ff       	call   801035fd <lapiceoi>
    break;
80107026:	e9 d6 00 00 00       	jmp    80107101 <trap+0x24a>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010702b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107031:	85 c0                	test   %eax,%eax
80107033:	74 11                	je     80107046 <trap+0x18f>
80107035:	8b 45 08             	mov    0x8(%ebp),%eax
80107038:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010703c:	0f b7 c0             	movzwl %ax,%eax
8010703f:	83 e0 03             	and    $0x3,%eax
80107042:	85 c0                	test   %eax,%eax
80107044:	75 46                	jne    8010708c <trap+0x1d5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107046:	e8 c6 fc ff ff       	call   80106d11 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
8010704b:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010704e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107051:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107058:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010705b:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010705e:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107061:	8b 52 30             	mov    0x30(%edx),%edx
80107064:	89 44 24 10          	mov    %eax,0x10(%esp)
80107068:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010706c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107070:	89 54 24 04          	mov    %edx,0x4(%esp)
80107074:	c7 04 24 80 91 10 80 	movl   $0x80109180,(%esp)
8010707b:	e8 21 93 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107080:	c7 04 24 b2 91 10 80 	movl   $0x801091b2,(%esp)
80107087:	e8 b1 94 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010708c:	e8 80 fc ff ff       	call   80106d11 <rcr2>
80107091:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107093:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107096:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107099:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010709f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801070a2:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801070a5:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801070a8:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801070ab:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801070ae:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801070b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070b7:	83 c0 6c             	add    $0x6c,%eax
801070ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801070bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801070c3:	8b 40 10             	mov    0x10(%eax),%eax
801070c6:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801070ca:	89 7c 24 18          	mov    %edi,0x18(%esp)
801070ce:	89 74 24 14          	mov    %esi,0x14(%esp)
801070d2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801070d6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801070da:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801070dd:	89 54 24 08          	mov    %edx,0x8(%esp)
801070e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801070e5:	c7 04 24 b8 91 10 80 	movl   $0x801091b8,(%esp)
801070ec:	e8 b0 92 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801070f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070f7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801070fe:	eb 01                	jmp    80107101 <trap+0x24a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107100:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107107:	85 c0                	test   %eax,%eax
80107109:	74 24                	je     8010712f <trap+0x278>
8010710b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107111:	8b 40 24             	mov    0x24(%eax),%eax
80107114:	85 c0                	test   %eax,%eax
80107116:	74 17                	je     8010712f <trap+0x278>
80107118:	8b 45 08             	mov    0x8(%ebp),%eax
8010711b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010711f:	0f b7 c0             	movzwl %ax,%eax
80107122:	83 e0 03             	and    $0x3,%eax
80107125:	83 f8 03             	cmp    $0x3,%eax
80107128:	75 05                	jne    8010712f <trap+0x278>
    exit();
8010712a:	e8 b8 da ff ff       	call   80104be7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  #ifndef _FCFS
  if(proc && proc->state == RUNNING && proc->quanta % QUANTA == 0 && tf->trapno == T_IRQ0+IRQ_TIMER){
8010712f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107135:	85 c0                	test   %eax,%eax
80107137:	0f 84 8b 00 00 00    	je     801071c8 <trap+0x311>
8010713d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107143:	8b 40 0c             	mov    0xc(%eax),%eax
80107146:	83 f8 04             	cmp    $0x4,%eax
80107149:	75 7d                	jne    801071c8 <trap+0x311>
8010714b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107151:	8b 88 94 00 00 00    	mov    0x94(%eax),%ecx
80107157:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010715c:	89 c8                	mov    %ecx,%eax
8010715e:	f7 ea                	imul   %edx
80107160:	d1 fa                	sar    %edx
80107162:	89 c8                	mov    %ecx,%eax
80107164:	c1 f8 1f             	sar    $0x1f,%eax
80107167:	29 c2                	sub    %eax,%edx
80107169:	89 d0                	mov    %edx,%eax
8010716b:	c1 e0 02             	shl    $0x2,%eax
8010716e:	01 d0                	add    %edx,%eax
80107170:	89 ca                	mov    %ecx,%edx
80107172:	29 c2                	sub    %eax,%edx
80107174:	85 d2                	test   %edx,%edx
80107176:	75 50                	jne    801071c8 <trap+0x311>
80107178:	8b 45 08             	mov    0x8(%ebp),%eax
8010717b:	8b 40 30             	mov    0x30(%eax),%eax
8010717e:	83 f8 20             	cmp    $0x20,%eax
80107181:	75 45                	jne    801071c8 <trap+0x311>
    int check = 1;
80107183:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    #ifdef _3Q
    if (proc->priority == LOW)
      check = 0;
    #endif
    if (check){
8010718a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010718e:	74 38                	je     801071c8 <trap+0x311>
      if (proc->priority == HIGH)
80107190:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107196:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
8010719c:	83 f8 01             	cmp    $0x1,%eax
8010719f:	75 12                	jne    801071b3 <trap+0x2fc>
	proc->priority = MEDIUM;
801071a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071a7:	c7 80 9c 00 00 00 02 	movl   $0x2,0x9c(%eax)
801071ae:	00 00 00 
801071b1:	eb 10                	jmp    801071c3 <trap+0x30c>
      else
	proc->priority = LOW;
801071b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071b9:	c7 80 9c 00 00 00 03 	movl   $0x3,0x9c(%eax)
801071c0:	00 00 00 
      yield();
801071c3:	e8 b7 df ff ff       	call   8010517f <yield>
    }
  }
  #endif

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801071c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071ce:	85 c0                	test   %eax,%eax
801071d0:	74 27                	je     801071f9 <trap+0x342>
801071d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071d8:	8b 40 24             	mov    0x24(%eax),%eax
801071db:	85 c0                	test   %eax,%eax
801071dd:	74 1a                	je     801071f9 <trap+0x342>
801071df:	8b 45 08             	mov    0x8(%ebp),%eax
801071e2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801071e6:	0f b7 c0             	movzwl %ax,%eax
801071e9:	83 e0 03             	and    $0x3,%eax
801071ec:	83 f8 03             	cmp    $0x3,%eax
801071ef:	75 08                	jne    801071f9 <trap+0x342>
    exit();
801071f1:	e8 f1 d9 ff ff       	call   80104be7 <exit>
801071f6:	eb 01                	jmp    801071f9 <trap+0x342>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801071f8:	90                   	nop
  #endif

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801071f9:	83 c4 4c             	add    $0x4c,%esp
801071fc:	5b                   	pop    %ebx
801071fd:	5e                   	pop    %esi
801071fe:	5f                   	pop    %edi
801071ff:	5d                   	pop    %ebp
80107200:	c3                   	ret    
80107201:	00 00                	add    %al,(%eax)
	...

80107204 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107204:	55                   	push   %ebp
80107205:	89 e5                	mov    %esp,%ebp
80107207:	53                   	push   %ebx
80107208:	83 ec 14             	sub    $0x14,%esp
8010720b:	8b 45 08             	mov    0x8(%ebp),%eax
8010720e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107212:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80107216:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010721a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010721e:	ec                   	in     (%dx),%al
8010721f:	89 c3                	mov    %eax,%ebx
80107221:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80107224:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80107228:	83 c4 14             	add    $0x14,%esp
8010722b:	5b                   	pop    %ebx
8010722c:	5d                   	pop    %ebp
8010722d:	c3                   	ret    

8010722e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010722e:	55                   	push   %ebp
8010722f:	89 e5                	mov    %esp,%ebp
80107231:	83 ec 08             	sub    $0x8,%esp
80107234:	8b 55 08             	mov    0x8(%ebp),%edx
80107237:	8b 45 0c             	mov    0xc(%ebp),%eax
8010723a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010723e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107241:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107245:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107249:	ee                   	out    %al,(%dx)
}
8010724a:	c9                   	leave  
8010724b:	c3                   	ret    

8010724c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010724c:	55                   	push   %ebp
8010724d:	89 e5                	mov    %esp,%ebp
8010724f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107259:	00 
8010725a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107261:	e8 c8 ff ff ff       	call   8010722e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107266:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
8010726d:	00 
8010726e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107275:	e8 b4 ff ff ff       	call   8010722e <outb>
  outb(COM1+0, 115200/9600);
8010727a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107281:	00 
80107282:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107289:	e8 a0 ff ff ff       	call   8010722e <outb>
  outb(COM1+1, 0);
8010728e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107295:	00 
80107296:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010729d:	e8 8c ff ff ff       	call   8010722e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801072a2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801072a9:	00 
801072aa:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801072b1:	e8 78 ff ff ff       	call   8010722e <outb>
  outb(COM1+4, 0);
801072b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801072bd:	00 
801072be:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801072c5:	e8 64 ff ff ff       	call   8010722e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801072ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801072d1:	00 
801072d2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801072d9:	e8 50 ff ff ff       	call   8010722e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801072de:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801072e5:	e8 1a ff ff ff       	call   80107204 <inb>
801072ea:	3c ff                	cmp    $0xff,%al
801072ec:	74 6c                	je     8010735a <uartinit+0x10e>
    return;
  uart = 1;
801072ee:	c7 05 0c d6 10 80 01 	movl   $0x1,0x8010d60c
801072f5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801072f8:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801072ff:	e8 00 ff ff ff       	call   80107204 <inb>
  inb(COM1+0);
80107304:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010730b:	e8 f4 fe ff ff       	call   80107204 <inb>
  picenable(IRQ_COM1);
80107310:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107317:	e8 b9 ce ff ff       	call   801041d5 <picenable>
  ioapicenable(IRQ_COM1, 0);
8010731c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107323:	00 
80107324:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010732b:	e8 5a bd ff ff       	call   8010308a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107330:	c7 45 f4 7c 92 10 80 	movl   $0x8010927c,-0xc(%ebp)
80107337:	eb 15                	jmp    8010734e <uartinit+0x102>
    uartputc(*p);
80107339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733c:	0f b6 00             	movzbl (%eax),%eax
8010733f:	0f be c0             	movsbl %al,%eax
80107342:	89 04 24             	mov    %eax,(%esp)
80107345:	e8 13 00 00 00       	call   8010735d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010734a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010734e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107351:	0f b6 00             	movzbl (%eax),%eax
80107354:	84 c0                	test   %al,%al
80107356:	75 e1                	jne    80107339 <uartinit+0xed>
80107358:	eb 01                	jmp    8010735b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010735a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010735b:	c9                   	leave  
8010735c:	c3                   	ret    

8010735d <uartputc>:

void
uartputc(int c)
{
8010735d:	55                   	push   %ebp
8010735e:	89 e5                	mov    %esp,%ebp
80107360:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107363:	a1 0c d6 10 80       	mov    0x8010d60c,%eax
80107368:	85 c0                	test   %eax,%eax
8010736a:	74 4d                	je     801073b9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010736c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107373:	eb 10                	jmp    80107385 <uartputc+0x28>
    microdelay(10);
80107375:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010737c:	e8 a1 c2 ff ff       	call   80103622 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107381:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107385:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107389:	7f 16                	jg     801073a1 <uartputc+0x44>
8010738b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107392:	e8 6d fe ff ff       	call   80107204 <inb>
80107397:	0f b6 c0             	movzbl %al,%eax
8010739a:	83 e0 20             	and    $0x20,%eax
8010739d:	85 c0                	test   %eax,%eax
8010739f:	74 d4                	je     80107375 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801073a1:	8b 45 08             	mov    0x8(%ebp),%eax
801073a4:	0f b6 c0             	movzbl %al,%eax
801073a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801073ab:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801073b2:	e8 77 fe ff ff       	call   8010722e <outb>
801073b7:	eb 01                	jmp    801073ba <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801073b9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801073ba:	c9                   	leave  
801073bb:	c3                   	ret    

801073bc <uartgetc>:

static int
uartgetc(void)
{
801073bc:	55                   	push   %ebp
801073bd:	89 e5                	mov    %esp,%ebp
801073bf:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801073c2:	a1 0c d6 10 80       	mov    0x8010d60c,%eax
801073c7:	85 c0                	test   %eax,%eax
801073c9:	75 07                	jne    801073d2 <uartgetc+0x16>
    return -1;
801073cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073d0:	eb 2c                	jmp    801073fe <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801073d2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801073d9:	e8 26 fe ff ff       	call   80107204 <inb>
801073de:	0f b6 c0             	movzbl %al,%eax
801073e1:	83 e0 01             	and    $0x1,%eax
801073e4:	85 c0                	test   %eax,%eax
801073e6:	75 07                	jne    801073ef <uartgetc+0x33>
    return -1;
801073e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ed:	eb 0f                	jmp    801073fe <uartgetc+0x42>
  return inb(COM1+0);
801073ef:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801073f6:	e8 09 fe ff ff       	call   80107204 <inb>
801073fb:	0f b6 c0             	movzbl %al,%eax
}
801073fe:	c9                   	leave  
801073ff:	c3                   	ret    

80107400 <uartintr>:

void
uartintr(void)
{
80107400:	55                   	push   %ebp
80107401:	89 e5                	mov    %esp,%ebp
80107403:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107406:	c7 04 24 bc 73 10 80 	movl   $0x801073bc,(%esp)
8010740d:	e8 ce 93 ff ff       	call   801007e0 <consoleintr>
}
80107412:	c9                   	leave  
80107413:	c3                   	ret    

80107414 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $0
80107416:	6a 00                	push   $0x0
  jmp alltraps
80107418:	e9 9f f8 ff ff       	jmp    80106cbc <alltraps>

8010741d <vector1>:
.globl vector1
vector1:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $1
8010741f:	6a 01                	push   $0x1
  jmp alltraps
80107421:	e9 96 f8 ff ff       	jmp    80106cbc <alltraps>

80107426 <vector2>:
.globl vector2
vector2:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $2
80107428:	6a 02                	push   $0x2
  jmp alltraps
8010742a:	e9 8d f8 ff ff       	jmp    80106cbc <alltraps>

8010742f <vector3>:
.globl vector3
vector3:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $3
80107431:	6a 03                	push   $0x3
  jmp alltraps
80107433:	e9 84 f8 ff ff       	jmp    80106cbc <alltraps>

80107438 <vector4>:
.globl vector4
vector4:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $4
8010743a:	6a 04                	push   $0x4
  jmp alltraps
8010743c:	e9 7b f8 ff ff       	jmp    80106cbc <alltraps>

80107441 <vector5>:
.globl vector5
vector5:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $5
80107443:	6a 05                	push   $0x5
  jmp alltraps
80107445:	e9 72 f8 ff ff       	jmp    80106cbc <alltraps>

8010744a <vector6>:
.globl vector6
vector6:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $6
8010744c:	6a 06                	push   $0x6
  jmp alltraps
8010744e:	e9 69 f8 ff ff       	jmp    80106cbc <alltraps>

80107453 <vector7>:
.globl vector7
vector7:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $7
80107455:	6a 07                	push   $0x7
  jmp alltraps
80107457:	e9 60 f8 ff ff       	jmp    80106cbc <alltraps>

8010745c <vector8>:
.globl vector8
vector8:
  pushl $8
8010745c:	6a 08                	push   $0x8
  jmp alltraps
8010745e:	e9 59 f8 ff ff       	jmp    80106cbc <alltraps>

80107463 <vector9>:
.globl vector9
vector9:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $9
80107465:	6a 09                	push   $0x9
  jmp alltraps
80107467:	e9 50 f8 ff ff       	jmp    80106cbc <alltraps>

8010746c <vector10>:
.globl vector10
vector10:
  pushl $10
8010746c:	6a 0a                	push   $0xa
  jmp alltraps
8010746e:	e9 49 f8 ff ff       	jmp    80106cbc <alltraps>

80107473 <vector11>:
.globl vector11
vector11:
  pushl $11
80107473:	6a 0b                	push   $0xb
  jmp alltraps
80107475:	e9 42 f8 ff ff       	jmp    80106cbc <alltraps>

8010747a <vector12>:
.globl vector12
vector12:
  pushl $12
8010747a:	6a 0c                	push   $0xc
  jmp alltraps
8010747c:	e9 3b f8 ff ff       	jmp    80106cbc <alltraps>

80107481 <vector13>:
.globl vector13
vector13:
  pushl $13
80107481:	6a 0d                	push   $0xd
  jmp alltraps
80107483:	e9 34 f8 ff ff       	jmp    80106cbc <alltraps>

80107488 <vector14>:
.globl vector14
vector14:
  pushl $14
80107488:	6a 0e                	push   $0xe
  jmp alltraps
8010748a:	e9 2d f8 ff ff       	jmp    80106cbc <alltraps>

8010748f <vector15>:
.globl vector15
vector15:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $15
80107491:	6a 0f                	push   $0xf
  jmp alltraps
80107493:	e9 24 f8 ff ff       	jmp    80106cbc <alltraps>

80107498 <vector16>:
.globl vector16
vector16:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $16
8010749a:	6a 10                	push   $0x10
  jmp alltraps
8010749c:	e9 1b f8 ff ff       	jmp    80106cbc <alltraps>

801074a1 <vector17>:
.globl vector17
vector17:
  pushl $17
801074a1:	6a 11                	push   $0x11
  jmp alltraps
801074a3:	e9 14 f8 ff ff       	jmp    80106cbc <alltraps>

801074a8 <vector18>:
.globl vector18
vector18:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $18
801074aa:	6a 12                	push   $0x12
  jmp alltraps
801074ac:	e9 0b f8 ff ff       	jmp    80106cbc <alltraps>

801074b1 <vector19>:
.globl vector19
vector19:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $19
801074b3:	6a 13                	push   $0x13
  jmp alltraps
801074b5:	e9 02 f8 ff ff       	jmp    80106cbc <alltraps>

801074ba <vector20>:
.globl vector20
vector20:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $20
801074bc:	6a 14                	push   $0x14
  jmp alltraps
801074be:	e9 f9 f7 ff ff       	jmp    80106cbc <alltraps>

801074c3 <vector21>:
.globl vector21
vector21:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $21
801074c5:	6a 15                	push   $0x15
  jmp alltraps
801074c7:	e9 f0 f7 ff ff       	jmp    80106cbc <alltraps>

801074cc <vector22>:
.globl vector22
vector22:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $22
801074ce:	6a 16                	push   $0x16
  jmp alltraps
801074d0:	e9 e7 f7 ff ff       	jmp    80106cbc <alltraps>

801074d5 <vector23>:
.globl vector23
vector23:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $23
801074d7:	6a 17                	push   $0x17
  jmp alltraps
801074d9:	e9 de f7 ff ff       	jmp    80106cbc <alltraps>

801074de <vector24>:
.globl vector24
vector24:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $24
801074e0:	6a 18                	push   $0x18
  jmp alltraps
801074e2:	e9 d5 f7 ff ff       	jmp    80106cbc <alltraps>

801074e7 <vector25>:
.globl vector25
vector25:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $25
801074e9:	6a 19                	push   $0x19
  jmp alltraps
801074eb:	e9 cc f7 ff ff       	jmp    80106cbc <alltraps>

801074f0 <vector26>:
.globl vector26
vector26:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $26
801074f2:	6a 1a                	push   $0x1a
  jmp alltraps
801074f4:	e9 c3 f7 ff ff       	jmp    80106cbc <alltraps>

801074f9 <vector27>:
.globl vector27
vector27:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $27
801074fb:	6a 1b                	push   $0x1b
  jmp alltraps
801074fd:	e9 ba f7 ff ff       	jmp    80106cbc <alltraps>

80107502 <vector28>:
.globl vector28
vector28:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $28
80107504:	6a 1c                	push   $0x1c
  jmp alltraps
80107506:	e9 b1 f7 ff ff       	jmp    80106cbc <alltraps>

8010750b <vector29>:
.globl vector29
vector29:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $29
8010750d:	6a 1d                	push   $0x1d
  jmp alltraps
8010750f:	e9 a8 f7 ff ff       	jmp    80106cbc <alltraps>

80107514 <vector30>:
.globl vector30
vector30:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $30
80107516:	6a 1e                	push   $0x1e
  jmp alltraps
80107518:	e9 9f f7 ff ff       	jmp    80106cbc <alltraps>

8010751d <vector31>:
.globl vector31
vector31:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $31
8010751f:	6a 1f                	push   $0x1f
  jmp alltraps
80107521:	e9 96 f7 ff ff       	jmp    80106cbc <alltraps>

80107526 <vector32>:
.globl vector32
vector32:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $32
80107528:	6a 20                	push   $0x20
  jmp alltraps
8010752a:	e9 8d f7 ff ff       	jmp    80106cbc <alltraps>

8010752f <vector33>:
.globl vector33
vector33:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $33
80107531:	6a 21                	push   $0x21
  jmp alltraps
80107533:	e9 84 f7 ff ff       	jmp    80106cbc <alltraps>

80107538 <vector34>:
.globl vector34
vector34:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $34
8010753a:	6a 22                	push   $0x22
  jmp alltraps
8010753c:	e9 7b f7 ff ff       	jmp    80106cbc <alltraps>

80107541 <vector35>:
.globl vector35
vector35:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $35
80107543:	6a 23                	push   $0x23
  jmp alltraps
80107545:	e9 72 f7 ff ff       	jmp    80106cbc <alltraps>

8010754a <vector36>:
.globl vector36
vector36:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $36
8010754c:	6a 24                	push   $0x24
  jmp alltraps
8010754e:	e9 69 f7 ff ff       	jmp    80106cbc <alltraps>

80107553 <vector37>:
.globl vector37
vector37:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $37
80107555:	6a 25                	push   $0x25
  jmp alltraps
80107557:	e9 60 f7 ff ff       	jmp    80106cbc <alltraps>

8010755c <vector38>:
.globl vector38
vector38:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $38
8010755e:	6a 26                	push   $0x26
  jmp alltraps
80107560:	e9 57 f7 ff ff       	jmp    80106cbc <alltraps>

80107565 <vector39>:
.globl vector39
vector39:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $39
80107567:	6a 27                	push   $0x27
  jmp alltraps
80107569:	e9 4e f7 ff ff       	jmp    80106cbc <alltraps>

8010756e <vector40>:
.globl vector40
vector40:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $40
80107570:	6a 28                	push   $0x28
  jmp alltraps
80107572:	e9 45 f7 ff ff       	jmp    80106cbc <alltraps>

80107577 <vector41>:
.globl vector41
vector41:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $41
80107579:	6a 29                	push   $0x29
  jmp alltraps
8010757b:	e9 3c f7 ff ff       	jmp    80106cbc <alltraps>

80107580 <vector42>:
.globl vector42
vector42:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $42
80107582:	6a 2a                	push   $0x2a
  jmp alltraps
80107584:	e9 33 f7 ff ff       	jmp    80106cbc <alltraps>

80107589 <vector43>:
.globl vector43
vector43:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $43
8010758b:	6a 2b                	push   $0x2b
  jmp alltraps
8010758d:	e9 2a f7 ff ff       	jmp    80106cbc <alltraps>

80107592 <vector44>:
.globl vector44
vector44:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $44
80107594:	6a 2c                	push   $0x2c
  jmp alltraps
80107596:	e9 21 f7 ff ff       	jmp    80106cbc <alltraps>

8010759b <vector45>:
.globl vector45
vector45:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $45
8010759d:	6a 2d                	push   $0x2d
  jmp alltraps
8010759f:	e9 18 f7 ff ff       	jmp    80106cbc <alltraps>

801075a4 <vector46>:
.globl vector46
vector46:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $46
801075a6:	6a 2e                	push   $0x2e
  jmp alltraps
801075a8:	e9 0f f7 ff ff       	jmp    80106cbc <alltraps>

801075ad <vector47>:
.globl vector47
vector47:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $47
801075af:	6a 2f                	push   $0x2f
  jmp alltraps
801075b1:	e9 06 f7 ff ff       	jmp    80106cbc <alltraps>

801075b6 <vector48>:
.globl vector48
vector48:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $48
801075b8:	6a 30                	push   $0x30
  jmp alltraps
801075ba:	e9 fd f6 ff ff       	jmp    80106cbc <alltraps>

801075bf <vector49>:
.globl vector49
vector49:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $49
801075c1:	6a 31                	push   $0x31
  jmp alltraps
801075c3:	e9 f4 f6 ff ff       	jmp    80106cbc <alltraps>

801075c8 <vector50>:
.globl vector50
vector50:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $50
801075ca:	6a 32                	push   $0x32
  jmp alltraps
801075cc:	e9 eb f6 ff ff       	jmp    80106cbc <alltraps>

801075d1 <vector51>:
.globl vector51
vector51:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $51
801075d3:	6a 33                	push   $0x33
  jmp alltraps
801075d5:	e9 e2 f6 ff ff       	jmp    80106cbc <alltraps>

801075da <vector52>:
.globl vector52
vector52:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $52
801075dc:	6a 34                	push   $0x34
  jmp alltraps
801075de:	e9 d9 f6 ff ff       	jmp    80106cbc <alltraps>

801075e3 <vector53>:
.globl vector53
vector53:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $53
801075e5:	6a 35                	push   $0x35
  jmp alltraps
801075e7:	e9 d0 f6 ff ff       	jmp    80106cbc <alltraps>

801075ec <vector54>:
.globl vector54
vector54:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $54
801075ee:	6a 36                	push   $0x36
  jmp alltraps
801075f0:	e9 c7 f6 ff ff       	jmp    80106cbc <alltraps>

801075f5 <vector55>:
.globl vector55
vector55:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $55
801075f7:	6a 37                	push   $0x37
  jmp alltraps
801075f9:	e9 be f6 ff ff       	jmp    80106cbc <alltraps>

801075fe <vector56>:
.globl vector56
vector56:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $56
80107600:	6a 38                	push   $0x38
  jmp alltraps
80107602:	e9 b5 f6 ff ff       	jmp    80106cbc <alltraps>

80107607 <vector57>:
.globl vector57
vector57:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $57
80107609:	6a 39                	push   $0x39
  jmp alltraps
8010760b:	e9 ac f6 ff ff       	jmp    80106cbc <alltraps>

80107610 <vector58>:
.globl vector58
vector58:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $58
80107612:	6a 3a                	push   $0x3a
  jmp alltraps
80107614:	e9 a3 f6 ff ff       	jmp    80106cbc <alltraps>

80107619 <vector59>:
.globl vector59
vector59:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $59
8010761b:	6a 3b                	push   $0x3b
  jmp alltraps
8010761d:	e9 9a f6 ff ff       	jmp    80106cbc <alltraps>

80107622 <vector60>:
.globl vector60
vector60:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $60
80107624:	6a 3c                	push   $0x3c
  jmp alltraps
80107626:	e9 91 f6 ff ff       	jmp    80106cbc <alltraps>

8010762b <vector61>:
.globl vector61
vector61:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $61
8010762d:	6a 3d                	push   $0x3d
  jmp alltraps
8010762f:	e9 88 f6 ff ff       	jmp    80106cbc <alltraps>

80107634 <vector62>:
.globl vector62
vector62:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $62
80107636:	6a 3e                	push   $0x3e
  jmp alltraps
80107638:	e9 7f f6 ff ff       	jmp    80106cbc <alltraps>

8010763d <vector63>:
.globl vector63
vector63:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $63
8010763f:	6a 3f                	push   $0x3f
  jmp alltraps
80107641:	e9 76 f6 ff ff       	jmp    80106cbc <alltraps>

80107646 <vector64>:
.globl vector64
vector64:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $64
80107648:	6a 40                	push   $0x40
  jmp alltraps
8010764a:	e9 6d f6 ff ff       	jmp    80106cbc <alltraps>

8010764f <vector65>:
.globl vector65
vector65:
  pushl $0
8010764f:	6a 00                	push   $0x0
  pushl $65
80107651:	6a 41                	push   $0x41
  jmp alltraps
80107653:	e9 64 f6 ff ff       	jmp    80106cbc <alltraps>

80107658 <vector66>:
.globl vector66
vector66:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $66
8010765a:	6a 42                	push   $0x42
  jmp alltraps
8010765c:	e9 5b f6 ff ff       	jmp    80106cbc <alltraps>

80107661 <vector67>:
.globl vector67
vector67:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $67
80107663:	6a 43                	push   $0x43
  jmp alltraps
80107665:	e9 52 f6 ff ff       	jmp    80106cbc <alltraps>

8010766a <vector68>:
.globl vector68
vector68:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $68
8010766c:	6a 44                	push   $0x44
  jmp alltraps
8010766e:	e9 49 f6 ff ff       	jmp    80106cbc <alltraps>

80107673 <vector69>:
.globl vector69
vector69:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $69
80107675:	6a 45                	push   $0x45
  jmp alltraps
80107677:	e9 40 f6 ff ff       	jmp    80106cbc <alltraps>

8010767c <vector70>:
.globl vector70
vector70:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $70
8010767e:	6a 46                	push   $0x46
  jmp alltraps
80107680:	e9 37 f6 ff ff       	jmp    80106cbc <alltraps>

80107685 <vector71>:
.globl vector71
vector71:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $71
80107687:	6a 47                	push   $0x47
  jmp alltraps
80107689:	e9 2e f6 ff ff       	jmp    80106cbc <alltraps>

8010768e <vector72>:
.globl vector72
vector72:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $72
80107690:	6a 48                	push   $0x48
  jmp alltraps
80107692:	e9 25 f6 ff ff       	jmp    80106cbc <alltraps>

80107697 <vector73>:
.globl vector73
vector73:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $73
80107699:	6a 49                	push   $0x49
  jmp alltraps
8010769b:	e9 1c f6 ff ff       	jmp    80106cbc <alltraps>

801076a0 <vector74>:
.globl vector74
vector74:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $74
801076a2:	6a 4a                	push   $0x4a
  jmp alltraps
801076a4:	e9 13 f6 ff ff       	jmp    80106cbc <alltraps>

801076a9 <vector75>:
.globl vector75
vector75:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $75
801076ab:	6a 4b                	push   $0x4b
  jmp alltraps
801076ad:	e9 0a f6 ff ff       	jmp    80106cbc <alltraps>

801076b2 <vector76>:
.globl vector76
vector76:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $76
801076b4:	6a 4c                	push   $0x4c
  jmp alltraps
801076b6:	e9 01 f6 ff ff       	jmp    80106cbc <alltraps>

801076bb <vector77>:
.globl vector77
vector77:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $77
801076bd:	6a 4d                	push   $0x4d
  jmp alltraps
801076bf:	e9 f8 f5 ff ff       	jmp    80106cbc <alltraps>

801076c4 <vector78>:
.globl vector78
vector78:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $78
801076c6:	6a 4e                	push   $0x4e
  jmp alltraps
801076c8:	e9 ef f5 ff ff       	jmp    80106cbc <alltraps>

801076cd <vector79>:
.globl vector79
vector79:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $79
801076cf:	6a 4f                	push   $0x4f
  jmp alltraps
801076d1:	e9 e6 f5 ff ff       	jmp    80106cbc <alltraps>

801076d6 <vector80>:
.globl vector80
vector80:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $80
801076d8:	6a 50                	push   $0x50
  jmp alltraps
801076da:	e9 dd f5 ff ff       	jmp    80106cbc <alltraps>

801076df <vector81>:
.globl vector81
vector81:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $81
801076e1:	6a 51                	push   $0x51
  jmp alltraps
801076e3:	e9 d4 f5 ff ff       	jmp    80106cbc <alltraps>

801076e8 <vector82>:
.globl vector82
vector82:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $82
801076ea:	6a 52                	push   $0x52
  jmp alltraps
801076ec:	e9 cb f5 ff ff       	jmp    80106cbc <alltraps>

801076f1 <vector83>:
.globl vector83
vector83:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $83
801076f3:	6a 53                	push   $0x53
  jmp alltraps
801076f5:	e9 c2 f5 ff ff       	jmp    80106cbc <alltraps>

801076fa <vector84>:
.globl vector84
vector84:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $84
801076fc:	6a 54                	push   $0x54
  jmp alltraps
801076fe:	e9 b9 f5 ff ff       	jmp    80106cbc <alltraps>

80107703 <vector85>:
.globl vector85
vector85:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $85
80107705:	6a 55                	push   $0x55
  jmp alltraps
80107707:	e9 b0 f5 ff ff       	jmp    80106cbc <alltraps>

8010770c <vector86>:
.globl vector86
vector86:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $86
8010770e:	6a 56                	push   $0x56
  jmp alltraps
80107710:	e9 a7 f5 ff ff       	jmp    80106cbc <alltraps>

80107715 <vector87>:
.globl vector87
vector87:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $87
80107717:	6a 57                	push   $0x57
  jmp alltraps
80107719:	e9 9e f5 ff ff       	jmp    80106cbc <alltraps>

8010771e <vector88>:
.globl vector88
vector88:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $88
80107720:	6a 58                	push   $0x58
  jmp alltraps
80107722:	e9 95 f5 ff ff       	jmp    80106cbc <alltraps>

80107727 <vector89>:
.globl vector89
vector89:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $89
80107729:	6a 59                	push   $0x59
  jmp alltraps
8010772b:	e9 8c f5 ff ff       	jmp    80106cbc <alltraps>

80107730 <vector90>:
.globl vector90
vector90:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $90
80107732:	6a 5a                	push   $0x5a
  jmp alltraps
80107734:	e9 83 f5 ff ff       	jmp    80106cbc <alltraps>

80107739 <vector91>:
.globl vector91
vector91:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $91
8010773b:	6a 5b                	push   $0x5b
  jmp alltraps
8010773d:	e9 7a f5 ff ff       	jmp    80106cbc <alltraps>

80107742 <vector92>:
.globl vector92
vector92:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $92
80107744:	6a 5c                	push   $0x5c
  jmp alltraps
80107746:	e9 71 f5 ff ff       	jmp    80106cbc <alltraps>

8010774b <vector93>:
.globl vector93
vector93:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $93
8010774d:	6a 5d                	push   $0x5d
  jmp alltraps
8010774f:	e9 68 f5 ff ff       	jmp    80106cbc <alltraps>

80107754 <vector94>:
.globl vector94
vector94:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $94
80107756:	6a 5e                	push   $0x5e
  jmp alltraps
80107758:	e9 5f f5 ff ff       	jmp    80106cbc <alltraps>

8010775d <vector95>:
.globl vector95
vector95:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $95
8010775f:	6a 5f                	push   $0x5f
  jmp alltraps
80107761:	e9 56 f5 ff ff       	jmp    80106cbc <alltraps>

80107766 <vector96>:
.globl vector96
vector96:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $96
80107768:	6a 60                	push   $0x60
  jmp alltraps
8010776a:	e9 4d f5 ff ff       	jmp    80106cbc <alltraps>

8010776f <vector97>:
.globl vector97
vector97:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $97
80107771:	6a 61                	push   $0x61
  jmp alltraps
80107773:	e9 44 f5 ff ff       	jmp    80106cbc <alltraps>

80107778 <vector98>:
.globl vector98
vector98:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $98
8010777a:	6a 62                	push   $0x62
  jmp alltraps
8010777c:	e9 3b f5 ff ff       	jmp    80106cbc <alltraps>

80107781 <vector99>:
.globl vector99
vector99:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $99
80107783:	6a 63                	push   $0x63
  jmp alltraps
80107785:	e9 32 f5 ff ff       	jmp    80106cbc <alltraps>

8010778a <vector100>:
.globl vector100
vector100:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $100
8010778c:	6a 64                	push   $0x64
  jmp alltraps
8010778e:	e9 29 f5 ff ff       	jmp    80106cbc <alltraps>

80107793 <vector101>:
.globl vector101
vector101:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $101
80107795:	6a 65                	push   $0x65
  jmp alltraps
80107797:	e9 20 f5 ff ff       	jmp    80106cbc <alltraps>

8010779c <vector102>:
.globl vector102
vector102:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $102
8010779e:	6a 66                	push   $0x66
  jmp alltraps
801077a0:	e9 17 f5 ff ff       	jmp    80106cbc <alltraps>

801077a5 <vector103>:
.globl vector103
vector103:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $103
801077a7:	6a 67                	push   $0x67
  jmp alltraps
801077a9:	e9 0e f5 ff ff       	jmp    80106cbc <alltraps>

801077ae <vector104>:
.globl vector104
vector104:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $104
801077b0:	6a 68                	push   $0x68
  jmp alltraps
801077b2:	e9 05 f5 ff ff       	jmp    80106cbc <alltraps>

801077b7 <vector105>:
.globl vector105
vector105:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $105
801077b9:	6a 69                	push   $0x69
  jmp alltraps
801077bb:	e9 fc f4 ff ff       	jmp    80106cbc <alltraps>

801077c0 <vector106>:
.globl vector106
vector106:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $106
801077c2:	6a 6a                	push   $0x6a
  jmp alltraps
801077c4:	e9 f3 f4 ff ff       	jmp    80106cbc <alltraps>

801077c9 <vector107>:
.globl vector107
vector107:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $107
801077cb:	6a 6b                	push   $0x6b
  jmp alltraps
801077cd:	e9 ea f4 ff ff       	jmp    80106cbc <alltraps>

801077d2 <vector108>:
.globl vector108
vector108:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $108
801077d4:	6a 6c                	push   $0x6c
  jmp alltraps
801077d6:	e9 e1 f4 ff ff       	jmp    80106cbc <alltraps>

801077db <vector109>:
.globl vector109
vector109:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $109
801077dd:	6a 6d                	push   $0x6d
  jmp alltraps
801077df:	e9 d8 f4 ff ff       	jmp    80106cbc <alltraps>

801077e4 <vector110>:
.globl vector110
vector110:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $110
801077e6:	6a 6e                	push   $0x6e
  jmp alltraps
801077e8:	e9 cf f4 ff ff       	jmp    80106cbc <alltraps>

801077ed <vector111>:
.globl vector111
vector111:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $111
801077ef:	6a 6f                	push   $0x6f
  jmp alltraps
801077f1:	e9 c6 f4 ff ff       	jmp    80106cbc <alltraps>

801077f6 <vector112>:
.globl vector112
vector112:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $112
801077f8:	6a 70                	push   $0x70
  jmp alltraps
801077fa:	e9 bd f4 ff ff       	jmp    80106cbc <alltraps>

801077ff <vector113>:
.globl vector113
vector113:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $113
80107801:	6a 71                	push   $0x71
  jmp alltraps
80107803:	e9 b4 f4 ff ff       	jmp    80106cbc <alltraps>

80107808 <vector114>:
.globl vector114
vector114:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $114
8010780a:	6a 72                	push   $0x72
  jmp alltraps
8010780c:	e9 ab f4 ff ff       	jmp    80106cbc <alltraps>

80107811 <vector115>:
.globl vector115
vector115:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $115
80107813:	6a 73                	push   $0x73
  jmp alltraps
80107815:	e9 a2 f4 ff ff       	jmp    80106cbc <alltraps>

8010781a <vector116>:
.globl vector116
vector116:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $116
8010781c:	6a 74                	push   $0x74
  jmp alltraps
8010781e:	e9 99 f4 ff ff       	jmp    80106cbc <alltraps>

80107823 <vector117>:
.globl vector117
vector117:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $117
80107825:	6a 75                	push   $0x75
  jmp alltraps
80107827:	e9 90 f4 ff ff       	jmp    80106cbc <alltraps>

8010782c <vector118>:
.globl vector118
vector118:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $118
8010782e:	6a 76                	push   $0x76
  jmp alltraps
80107830:	e9 87 f4 ff ff       	jmp    80106cbc <alltraps>

80107835 <vector119>:
.globl vector119
vector119:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $119
80107837:	6a 77                	push   $0x77
  jmp alltraps
80107839:	e9 7e f4 ff ff       	jmp    80106cbc <alltraps>

8010783e <vector120>:
.globl vector120
vector120:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $120
80107840:	6a 78                	push   $0x78
  jmp alltraps
80107842:	e9 75 f4 ff ff       	jmp    80106cbc <alltraps>

80107847 <vector121>:
.globl vector121
vector121:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $121
80107849:	6a 79                	push   $0x79
  jmp alltraps
8010784b:	e9 6c f4 ff ff       	jmp    80106cbc <alltraps>

80107850 <vector122>:
.globl vector122
vector122:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $122
80107852:	6a 7a                	push   $0x7a
  jmp alltraps
80107854:	e9 63 f4 ff ff       	jmp    80106cbc <alltraps>

80107859 <vector123>:
.globl vector123
vector123:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $123
8010785b:	6a 7b                	push   $0x7b
  jmp alltraps
8010785d:	e9 5a f4 ff ff       	jmp    80106cbc <alltraps>

80107862 <vector124>:
.globl vector124
vector124:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $124
80107864:	6a 7c                	push   $0x7c
  jmp alltraps
80107866:	e9 51 f4 ff ff       	jmp    80106cbc <alltraps>

8010786b <vector125>:
.globl vector125
vector125:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $125
8010786d:	6a 7d                	push   $0x7d
  jmp alltraps
8010786f:	e9 48 f4 ff ff       	jmp    80106cbc <alltraps>

80107874 <vector126>:
.globl vector126
vector126:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $126
80107876:	6a 7e                	push   $0x7e
  jmp alltraps
80107878:	e9 3f f4 ff ff       	jmp    80106cbc <alltraps>

8010787d <vector127>:
.globl vector127
vector127:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $127
8010787f:	6a 7f                	push   $0x7f
  jmp alltraps
80107881:	e9 36 f4 ff ff       	jmp    80106cbc <alltraps>

80107886 <vector128>:
.globl vector128
vector128:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $128
80107888:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010788d:	e9 2a f4 ff ff       	jmp    80106cbc <alltraps>

80107892 <vector129>:
.globl vector129
vector129:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $129
80107894:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107899:	e9 1e f4 ff ff       	jmp    80106cbc <alltraps>

8010789e <vector130>:
.globl vector130
vector130:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $130
801078a0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801078a5:	e9 12 f4 ff ff       	jmp    80106cbc <alltraps>

801078aa <vector131>:
.globl vector131
vector131:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $131
801078ac:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801078b1:	e9 06 f4 ff ff       	jmp    80106cbc <alltraps>

801078b6 <vector132>:
.globl vector132
vector132:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $132
801078b8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801078bd:	e9 fa f3 ff ff       	jmp    80106cbc <alltraps>

801078c2 <vector133>:
.globl vector133
vector133:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $133
801078c4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801078c9:	e9 ee f3 ff ff       	jmp    80106cbc <alltraps>

801078ce <vector134>:
.globl vector134
vector134:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $134
801078d0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801078d5:	e9 e2 f3 ff ff       	jmp    80106cbc <alltraps>

801078da <vector135>:
.globl vector135
vector135:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $135
801078dc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801078e1:	e9 d6 f3 ff ff       	jmp    80106cbc <alltraps>

801078e6 <vector136>:
.globl vector136
vector136:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $136
801078e8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801078ed:	e9 ca f3 ff ff       	jmp    80106cbc <alltraps>

801078f2 <vector137>:
.globl vector137
vector137:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $137
801078f4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801078f9:	e9 be f3 ff ff       	jmp    80106cbc <alltraps>

801078fe <vector138>:
.globl vector138
vector138:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $138
80107900:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107905:	e9 b2 f3 ff ff       	jmp    80106cbc <alltraps>

8010790a <vector139>:
.globl vector139
vector139:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $139
8010790c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107911:	e9 a6 f3 ff ff       	jmp    80106cbc <alltraps>

80107916 <vector140>:
.globl vector140
vector140:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $140
80107918:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010791d:	e9 9a f3 ff ff       	jmp    80106cbc <alltraps>

80107922 <vector141>:
.globl vector141
vector141:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $141
80107924:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107929:	e9 8e f3 ff ff       	jmp    80106cbc <alltraps>

8010792e <vector142>:
.globl vector142
vector142:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $142
80107930:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107935:	e9 82 f3 ff ff       	jmp    80106cbc <alltraps>

8010793a <vector143>:
.globl vector143
vector143:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $143
8010793c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107941:	e9 76 f3 ff ff       	jmp    80106cbc <alltraps>

80107946 <vector144>:
.globl vector144
vector144:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $144
80107948:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010794d:	e9 6a f3 ff ff       	jmp    80106cbc <alltraps>

80107952 <vector145>:
.globl vector145
vector145:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $145
80107954:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107959:	e9 5e f3 ff ff       	jmp    80106cbc <alltraps>

8010795e <vector146>:
.globl vector146
vector146:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $146
80107960:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107965:	e9 52 f3 ff ff       	jmp    80106cbc <alltraps>

8010796a <vector147>:
.globl vector147
vector147:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $147
8010796c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107971:	e9 46 f3 ff ff       	jmp    80106cbc <alltraps>

80107976 <vector148>:
.globl vector148
vector148:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $148
80107978:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010797d:	e9 3a f3 ff ff       	jmp    80106cbc <alltraps>

80107982 <vector149>:
.globl vector149
vector149:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $149
80107984:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107989:	e9 2e f3 ff ff       	jmp    80106cbc <alltraps>

8010798e <vector150>:
.globl vector150
vector150:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $150
80107990:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107995:	e9 22 f3 ff ff       	jmp    80106cbc <alltraps>

8010799a <vector151>:
.globl vector151
vector151:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $151
8010799c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801079a1:	e9 16 f3 ff ff       	jmp    80106cbc <alltraps>

801079a6 <vector152>:
.globl vector152
vector152:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $152
801079a8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801079ad:	e9 0a f3 ff ff       	jmp    80106cbc <alltraps>

801079b2 <vector153>:
.globl vector153
vector153:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $153
801079b4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801079b9:	e9 fe f2 ff ff       	jmp    80106cbc <alltraps>

801079be <vector154>:
.globl vector154
vector154:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $154
801079c0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801079c5:	e9 f2 f2 ff ff       	jmp    80106cbc <alltraps>

801079ca <vector155>:
.globl vector155
vector155:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $155
801079cc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801079d1:	e9 e6 f2 ff ff       	jmp    80106cbc <alltraps>

801079d6 <vector156>:
.globl vector156
vector156:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $156
801079d8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801079dd:	e9 da f2 ff ff       	jmp    80106cbc <alltraps>

801079e2 <vector157>:
.globl vector157
vector157:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $157
801079e4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801079e9:	e9 ce f2 ff ff       	jmp    80106cbc <alltraps>

801079ee <vector158>:
.globl vector158
vector158:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $158
801079f0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801079f5:	e9 c2 f2 ff ff       	jmp    80106cbc <alltraps>

801079fa <vector159>:
.globl vector159
vector159:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $159
801079fc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107a01:	e9 b6 f2 ff ff       	jmp    80106cbc <alltraps>

80107a06 <vector160>:
.globl vector160
vector160:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $160
80107a08:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107a0d:	e9 aa f2 ff ff       	jmp    80106cbc <alltraps>

80107a12 <vector161>:
.globl vector161
vector161:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $161
80107a14:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107a19:	e9 9e f2 ff ff       	jmp    80106cbc <alltraps>

80107a1e <vector162>:
.globl vector162
vector162:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $162
80107a20:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107a25:	e9 92 f2 ff ff       	jmp    80106cbc <alltraps>

80107a2a <vector163>:
.globl vector163
vector163:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $163
80107a2c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107a31:	e9 86 f2 ff ff       	jmp    80106cbc <alltraps>

80107a36 <vector164>:
.globl vector164
vector164:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $164
80107a38:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107a3d:	e9 7a f2 ff ff       	jmp    80106cbc <alltraps>

80107a42 <vector165>:
.globl vector165
vector165:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $165
80107a44:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107a49:	e9 6e f2 ff ff       	jmp    80106cbc <alltraps>

80107a4e <vector166>:
.globl vector166
vector166:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $166
80107a50:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107a55:	e9 62 f2 ff ff       	jmp    80106cbc <alltraps>

80107a5a <vector167>:
.globl vector167
vector167:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $167
80107a5c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107a61:	e9 56 f2 ff ff       	jmp    80106cbc <alltraps>

80107a66 <vector168>:
.globl vector168
vector168:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $168
80107a68:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107a6d:	e9 4a f2 ff ff       	jmp    80106cbc <alltraps>

80107a72 <vector169>:
.globl vector169
vector169:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $169
80107a74:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107a79:	e9 3e f2 ff ff       	jmp    80106cbc <alltraps>

80107a7e <vector170>:
.globl vector170
vector170:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $170
80107a80:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107a85:	e9 32 f2 ff ff       	jmp    80106cbc <alltraps>

80107a8a <vector171>:
.globl vector171
vector171:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $171
80107a8c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107a91:	e9 26 f2 ff ff       	jmp    80106cbc <alltraps>

80107a96 <vector172>:
.globl vector172
vector172:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $172
80107a98:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107a9d:	e9 1a f2 ff ff       	jmp    80106cbc <alltraps>

80107aa2 <vector173>:
.globl vector173
vector173:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $173
80107aa4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107aa9:	e9 0e f2 ff ff       	jmp    80106cbc <alltraps>

80107aae <vector174>:
.globl vector174
vector174:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $174
80107ab0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107ab5:	e9 02 f2 ff ff       	jmp    80106cbc <alltraps>

80107aba <vector175>:
.globl vector175
vector175:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $175
80107abc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107ac1:	e9 f6 f1 ff ff       	jmp    80106cbc <alltraps>

80107ac6 <vector176>:
.globl vector176
vector176:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $176
80107ac8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107acd:	e9 ea f1 ff ff       	jmp    80106cbc <alltraps>

80107ad2 <vector177>:
.globl vector177
vector177:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $177
80107ad4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107ad9:	e9 de f1 ff ff       	jmp    80106cbc <alltraps>

80107ade <vector178>:
.globl vector178
vector178:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $178
80107ae0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107ae5:	e9 d2 f1 ff ff       	jmp    80106cbc <alltraps>

80107aea <vector179>:
.globl vector179
vector179:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $179
80107aec:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107af1:	e9 c6 f1 ff ff       	jmp    80106cbc <alltraps>

80107af6 <vector180>:
.globl vector180
vector180:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $180
80107af8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107afd:	e9 ba f1 ff ff       	jmp    80106cbc <alltraps>

80107b02 <vector181>:
.globl vector181
vector181:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $181
80107b04:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107b09:	e9 ae f1 ff ff       	jmp    80106cbc <alltraps>

80107b0e <vector182>:
.globl vector182
vector182:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $182
80107b10:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107b15:	e9 a2 f1 ff ff       	jmp    80106cbc <alltraps>

80107b1a <vector183>:
.globl vector183
vector183:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $183
80107b1c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107b21:	e9 96 f1 ff ff       	jmp    80106cbc <alltraps>

80107b26 <vector184>:
.globl vector184
vector184:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $184
80107b28:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107b2d:	e9 8a f1 ff ff       	jmp    80106cbc <alltraps>

80107b32 <vector185>:
.globl vector185
vector185:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $185
80107b34:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107b39:	e9 7e f1 ff ff       	jmp    80106cbc <alltraps>

80107b3e <vector186>:
.globl vector186
vector186:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $186
80107b40:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107b45:	e9 72 f1 ff ff       	jmp    80106cbc <alltraps>

80107b4a <vector187>:
.globl vector187
vector187:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $187
80107b4c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107b51:	e9 66 f1 ff ff       	jmp    80106cbc <alltraps>

80107b56 <vector188>:
.globl vector188
vector188:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $188
80107b58:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107b5d:	e9 5a f1 ff ff       	jmp    80106cbc <alltraps>

80107b62 <vector189>:
.globl vector189
vector189:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $189
80107b64:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107b69:	e9 4e f1 ff ff       	jmp    80106cbc <alltraps>

80107b6e <vector190>:
.globl vector190
vector190:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $190
80107b70:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107b75:	e9 42 f1 ff ff       	jmp    80106cbc <alltraps>

80107b7a <vector191>:
.globl vector191
vector191:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $191
80107b7c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107b81:	e9 36 f1 ff ff       	jmp    80106cbc <alltraps>

80107b86 <vector192>:
.globl vector192
vector192:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $192
80107b88:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107b8d:	e9 2a f1 ff ff       	jmp    80106cbc <alltraps>

80107b92 <vector193>:
.globl vector193
vector193:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $193
80107b94:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107b99:	e9 1e f1 ff ff       	jmp    80106cbc <alltraps>

80107b9e <vector194>:
.globl vector194
vector194:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $194
80107ba0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107ba5:	e9 12 f1 ff ff       	jmp    80106cbc <alltraps>

80107baa <vector195>:
.globl vector195
vector195:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $195
80107bac:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107bb1:	e9 06 f1 ff ff       	jmp    80106cbc <alltraps>

80107bb6 <vector196>:
.globl vector196
vector196:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $196
80107bb8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107bbd:	e9 fa f0 ff ff       	jmp    80106cbc <alltraps>

80107bc2 <vector197>:
.globl vector197
vector197:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $197
80107bc4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107bc9:	e9 ee f0 ff ff       	jmp    80106cbc <alltraps>

80107bce <vector198>:
.globl vector198
vector198:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $198
80107bd0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107bd5:	e9 e2 f0 ff ff       	jmp    80106cbc <alltraps>

80107bda <vector199>:
.globl vector199
vector199:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $199
80107bdc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107be1:	e9 d6 f0 ff ff       	jmp    80106cbc <alltraps>

80107be6 <vector200>:
.globl vector200
vector200:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $200
80107be8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107bed:	e9 ca f0 ff ff       	jmp    80106cbc <alltraps>

80107bf2 <vector201>:
.globl vector201
vector201:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $201
80107bf4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107bf9:	e9 be f0 ff ff       	jmp    80106cbc <alltraps>

80107bfe <vector202>:
.globl vector202
vector202:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $202
80107c00:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107c05:	e9 b2 f0 ff ff       	jmp    80106cbc <alltraps>

80107c0a <vector203>:
.globl vector203
vector203:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $203
80107c0c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107c11:	e9 a6 f0 ff ff       	jmp    80106cbc <alltraps>

80107c16 <vector204>:
.globl vector204
vector204:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $204
80107c18:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107c1d:	e9 9a f0 ff ff       	jmp    80106cbc <alltraps>

80107c22 <vector205>:
.globl vector205
vector205:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $205
80107c24:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107c29:	e9 8e f0 ff ff       	jmp    80106cbc <alltraps>

80107c2e <vector206>:
.globl vector206
vector206:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $206
80107c30:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107c35:	e9 82 f0 ff ff       	jmp    80106cbc <alltraps>

80107c3a <vector207>:
.globl vector207
vector207:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $207
80107c3c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107c41:	e9 76 f0 ff ff       	jmp    80106cbc <alltraps>

80107c46 <vector208>:
.globl vector208
vector208:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $208
80107c48:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107c4d:	e9 6a f0 ff ff       	jmp    80106cbc <alltraps>

80107c52 <vector209>:
.globl vector209
vector209:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $209
80107c54:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107c59:	e9 5e f0 ff ff       	jmp    80106cbc <alltraps>

80107c5e <vector210>:
.globl vector210
vector210:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $210
80107c60:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107c65:	e9 52 f0 ff ff       	jmp    80106cbc <alltraps>

80107c6a <vector211>:
.globl vector211
vector211:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $211
80107c6c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107c71:	e9 46 f0 ff ff       	jmp    80106cbc <alltraps>

80107c76 <vector212>:
.globl vector212
vector212:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $212
80107c78:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107c7d:	e9 3a f0 ff ff       	jmp    80106cbc <alltraps>

80107c82 <vector213>:
.globl vector213
vector213:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $213
80107c84:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107c89:	e9 2e f0 ff ff       	jmp    80106cbc <alltraps>

80107c8e <vector214>:
.globl vector214
vector214:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $214
80107c90:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107c95:	e9 22 f0 ff ff       	jmp    80106cbc <alltraps>

80107c9a <vector215>:
.globl vector215
vector215:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $215
80107c9c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107ca1:	e9 16 f0 ff ff       	jmp    80106cbc <alltraps>

80107ca6 <vector216>:
.globl vector216
vector216:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $216
80107ca8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107cad:	e9 0a f0 ff ff       	jmp    80106cbc <alltraps>

80107cb2 <vector217>:
.globl vector217
vector217:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $217
80107cb4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107cb9:	e9 fe ef ff ff       	jmp    80106cbc <alltraps>

80107cbe <vector218>:
.globl vector218
vector218:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $218
80107cc0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107cc5:	e9 f2 ef ff ff       	jmp    80106cbc <alltraps>

80107cca <vector219>:
.globl vector219
vector219:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $219
80107ccc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107cd1:	e9 e6 ef ff ff       	jmp    80106cbc <alltraps>

80107cd6 <vector220>:
.globl vector220
vector220:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $220
80107cd8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107cdd:	e9 da ef ff ff       	jmp    80106cbc <alltraps>

80107ce2 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $221
80107ce4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107ce9:	e9 ce ef ff ff       	jmp    80106cbc <alltraps>

80107cee <vector222>:
.globl vector222
vector222:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $222
80107cf0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107cf5:	e9 c2 ef ff ff       	jmp    80106cbc <alltraps>

80107cfa <vector223>:
.globl vector223
vector223:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $223
80107cfc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107d01:	e9 b6 ef ff ff       	jmp    80106cbc <alltraps>

80107d06 <vector224>:
.globl vector224
vector224:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $224
80107d08:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107d0d:	e9 aa ef ff ff       	jmp    80106cbc <alltraps>

80107d12 <vector225>:
.globl vector225
vector225:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $225
80107d14:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107d19:	e9 9e ef ff ff       	jmp    80106cbc <alltraps>

80107d1e <vector226>:
.globl vector226
vector226:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $226
80107d20:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107d25:	e9 92 ef ff ff       	jmp    80106cbc <alltraps>

80107d2a <vector227>:
.globl vector227
vector227:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $227
80107d2c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107d31:	e9 86 ef ff ff       	jmp    80106cbc <alltraps>

80107d36 <vector228>:
.globl vector228
vector228:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $228
80107d38:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107d3d:	e9 7a ef ff ff       	jmp    80106cbc <alltraps>

80107d42 <vector229>:
.globl vector229
vector229:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $229
80107d44:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107d49:	e9 6e ef ff ff       	jmp    80106cbc <alltraps>

80107d4e <vector230>:
.globl vector230
vector230:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $230
80107d50:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107d55:	e9 62 ef ff ff       	jmp    80106cbc <alltraps>

80107d5a <vector231>:
.globl vector231
vector231:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $231
80107d5c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107d61:	e9 56 ef ff ff       	jmp    80106cbc <alltraps>

80107d66 <vector232>:
.globl vector232
vector232:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $232
80107d68:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107d6d:	e9 4a ef ff ff       	jmp    80106cbc <alltraps>

80107d72 <vector233>:
.globl vector233
vector233:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $233
80107d74:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107d79:	e9 3e ef ff ff       	jmp    80106cbc <alltraps>

80107d7e <vector234>:
.globl vector234
vector234:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $234
80107d80:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107d85:	e9 32 ef ff ff       	jmp    80106cbc <alltraps>

80107d8a <vector235>:
.globl vector235
vector235:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $235
80107d8c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107d91:	e9 26 ef ff ff       	jmp    80106cbc <alltraps>

80107d96 <vector236>:
.globl vector236
vector236:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $236
80107d98:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107d9d:	e9 1a ef ff ff       	jmp    80106cbc <alltraps>

80107da2 <vector237>:
.globl vector237
vector237:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $237
80107da4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107da9:	e9 0e ef ff ff       	jmp    80106cbc <alltraps>

80107dae <vector238>:
.globl vector238
vector238:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $238
80107db0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107db5:	e9 02 ef ff ff       	jmp    80106cbc <alltraps>

80107dba <vector239>:
.globl vector239
vector239:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $239
80107dbc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107dc1:	e9 f6 ee ff ff       	jmp    80106cbc <alltraps>

80107dc6 <vector240>:
.globl vector240
vector240:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $240
80107dc8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107dcd:	e9 ea ee ff ff       	jmp    80106cbc <alltraps>

80107dd2 <vector241>:
.globl vector241
vector241:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $241
80107dd4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107dd9:	e9 de ee ff ff       	jmp    80106cbc <alltraps>

80107dde <vector242>:
.globl vector242
vector242:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $242
80107de0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107de5:	e9 d2 ee ff ff       	jmp    80106cbc <alltraps>

80107dea <vector243>:
.globl vector243
vector243:
  pushl $0
80107dea:	6a 00                	push   $0x0
  pushl $243
80107dec:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107df1:	e9 c6 ee ff ff       	jmp    80106cbc <alltraps>

80107df6 <vector244>:
.globl vector244
vector244:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $244
80107df8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107dfd:	e9 ba ee ff ff       	jmp    80106cbc <alltraps>

80107e02 <vector245>:
.globl vector245
vector245:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $245
80107e04:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107e09:	e9 ae ee ff ff       	jmp    80106cbc <alltraps>

80107e0e <vector246>:
.globl vector246
vector246:
  pushl $0
80107e0e:	6a 00                	push   $0x0
  pushl $246
80107e10:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107e15:	e9 a2 ee ff ff       	jmp    80106cbc <alltraps>

80107e1a <vector247>:
.globl vector247
vector247:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $247
80107e1c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107e21:	e9 96 ee ff ff       	jmp    80106cbc <alltraps>

80107e26 <vector248>:
.globl vector248
vector248:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $248
80107e28:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107e2d:	e9 8a ee ff ff       	jmp    80106cbc <alltraps>

80107e32 <vector249>:
.globl vector249
vector249:
  pushl $0
80107e32:	6a 00                	push   $0x0
  pushl $249
80107e34:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107e39:	e9 7e ee ff ff       	jmp    80106cbc <alltraps>

80107e3e <vector250>:
.globl vector250
vector250:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $250
80107e40:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107e45:	e9 72 ee ff ff       	jmp    80106cbc <alltraps>

80107e4a <vector251>:
.globl vector251
vector251:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $251
80107e4c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107e51:	e9 66 ee ff ff       	jmp    80106cbc <alltraps>

80107e56 <vector252>:
.globl vector252
vector252:
  pushl $0
80107e56:	6a 00                	push   $0x0
  pushl $252
80107e58:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107e5d:	e9 5a ee ff ff       	jmp    80106cbc <alltraps>

80107e62 <vector253>:
.globl vector253
vector253:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $253
80107e64:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107e69:	e9 4e ee ff ff       	jmp    80106cbc <alltraps>

80107e6e <vector254>:
.globl vector254
vector254:
  pushl $0
80107e6e:	6a 00                	push   $0x0
  pushl $254
80107e70:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107e75:	e9 42 ee ff ff       	jmp    80106cbc <alltraps>

80107e7a <vector255>:
.globl vector255
vector255:
  pushl $0
80107e7a:	6a 00                	push   $0x0
  pushl $255
80107e7c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107e81:	e9 36 ee ff ff       	jmp    80106cbc <alltraps>
	...

80107e88 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107e88:	55                   	push   %ebp
80107e89:	89 e5                	mov    %esp,%ebp
80107e8b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e91:	83 e8 01             	sub    $0x1,%eax
80107e94:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107e98:	8b 45 08             	mov    0x8(%ebp),%eax
80107e9b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea2:	c1 e8 10             	shr    $0x10,%eax
80107ea5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107ea9:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107eac:	0f 01 10             	lgdtl  (%eax)
}
80107eaf:	c9                   	leave  
80107eb0:	c3                   	ret    

80107eb1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107eb1:	55                   	push   %ebp
80107eb2:	89 e5                	mov    %esp,%ebp
80107eb4:	83 ec 04             	sub    $0x4,%esp
80107eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80107eba:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ebe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ec2:	0f 00 d8             	ltr    %ax
}
80107ec5:	c9                   	leave  
80107ec6:	c3                   	ret    

80107ec7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107ec7:	55                   	push   %ebp
80107ec8:	89 e5                	mov    %esp,%ebp
80107eca:	83 ec 04             	sub    $0x4,%esp
80107ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107ed4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ed8:	8e e8                	mov    %eax,%gs
}
80107eda:	c9                   	leave  
80107edb:	c3                   	ret    

80107edc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107edc:	55                   	push   %ebp
80107edd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107edf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ee2:	0f 22 d8             	mov    %eax,%cr3
}
80107ee5:	5d                   	pop    %ebp
80107ee6:	c3                   	ret    

80107ee7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107ee7:	55                   	push   %ebp
80107ee8:	89 e5                	mov    %esp,%ebp
80107eea:	8b 45 08             	mov    0x8(%ebp),%eax
80107eed:	05 00 00 00 80       	add    $0x80000000,%eax
80107ef2:	5d                   	pop    %ebp
80107ef3:	c3                   	ret    

80107ef4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107ef4:	55                   	push   %ebp
80107ef5:	89 e5                	mov    %esp,%ebp
80107ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80107efa:	05 00 00 00 80       	add    $0x80000000,%eax
80107eff:	5d                   	pop    %ebp
80107f00:	c3                   	ret    

80107f01 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107f01:	55                   	push   %ebp
80107f02:	89 e5                	mov    %esp,%ebp
80107f04:	53                   	push   %ebx
80107f05:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107f08:	e8 94 b6 ff ff       	call   801035a1 <cpunum>
80107f0d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107f13:	05 e0 18 11 80       	add    $0x801118e0,%eax
80107f18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f27:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f30:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f37:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f3b:	83 e2 f0             	and    $0xfffffff0,%edx
80107f3e:	83 ca 0a             	or     $0xa,%edx
80107f41:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f47:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f4b:	83 ca 10             	or     $0x10,%edx
80107f4e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f54:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f58:	83 e2 9f             	and    $0xffffff9f,%edx
80107f5b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f61:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107f65:	83 ca 80             	or     $0xffffff80,%edx
80107f68:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f72:	83 ca 0f             	or     $0xf,%edx
80107f75:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f7f:	83 e2 ef             	and    $0xffffffef,%edx
80107f82:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f8c:	83 e2 df             	and    $0xffffffdf,%edx
80107f8f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f95:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107f99:	83 ca 40             	or     $0x40,%edx
80107f9c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107fa6:	83 ca 80             	or     $0xffffff80,%edx
80107fa9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107fbd:	ff ff 
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107fc9:	00 00 
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107fdf:	83 e2 f0             	and    $0xfffffff0,%edx
80107fe2:	83 ca 02             	or     $0x2,%edx
80107fe5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ff5:	83 ca 10             	or     $0x10,%edx
80107ff8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108001:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108008:	83 e2 9f             	and    $0xffffff9f,%edx
8010800b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108014:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010801b:	83 ca 80             	or     $0xffffff80,%edx
8010801e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108027:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010802e:	83 ca 0f             	or     $0xf,%edx
80108031:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108041:	83 e2 ef             	and    $0xffffffef,%edx
80108044:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108054:	83 e2 df             	and    $0xffffffdf,%edx
80108057:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108060:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108067:	83 ca 40             	or     $0x40,%edx
8010806a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108073:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010807a:	83 ca 80             	or     $0xffffff80,%edx
8010807d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108086:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010808d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108090:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108097:	ff ff 
80108099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801080a3:	00 00 
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801080af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080b9:	83 e2 f0             	and    $0xfffffff0,%edx
801080bc:	83 ca 0a             	or     $0xa,%edx
801080bf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080cf:	83 ca 10             	or     $0x10,%edx
801080d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080db:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080e2:	83 ca 60             	or     $0x60,%edx
801080e5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ee:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080f5:	83 ca 80             	or     $0xffffff80,%edx
801080f8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108101:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108108:	83 ca 0f             	or     $0xf,%edx
8010810b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010811b:	83 e2 ef             	and    $0xffffffef,%edx
8010811e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108127:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010812e:	83 e2 df             	and    $0xffffffdf,%edx
80108131:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108141:	83 ca 40             	or     $0x40,%edx
80108144:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010814a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108154:	83 ca 80             	or     $0xffffff80,%edx
80108157:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010815d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108160:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108171:	ff ff 
80108173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108176:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010817d:	00 00 
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108193:	83 e2 f0             	and    $0xfffffff0,%edx
80108196:	83 ca 02             	or     $0x2,%edx
80108199:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010819f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081a9:	83 ca 10             	or     $0x10,%edx
801081ac:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801081b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081bc:	83 ca 60             	or     $0x60,%edx
801081bf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801081c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081cf:	83 ca 80             	or     $0xffffff80,%edx
801081d2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801081d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081db:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801081e2:	83 ca 0f             	or     $0xf,%edx
801081e5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801081eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ee:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801081f5:	83 e2 ef             	and    $0xffffffef,%edx
801081f8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108208:	83 e2 df             	and    $0xffffffdf,%edx
8010820b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108214:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010821b:	83 ca 40             	or     $0x40,%edx
8010821e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108227:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010822e:	83 ca 80             	or     $0xffffff80,%edx
80108231:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108244:	05 b4 00 00 00       	add    $0xb4,%eax
80108249:	89 c3                	mov    %eax,%ebx
8010824b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824e:	05 b4 00 00 00       	add    $0xb4,%eax
80108253:	c1 e8 10             	shr    $0x10,%eax
80108256:	89 c1                	mov    %eax,%ecx
80108258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825b:	05 b4 00 00 00       	add    $0xb4,%eax
80108260:	c1 e8 18             	shr    $0x18,%eax
80108263:	89 c2                	mov    %eax,%edx
80108265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108268:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010826f:	00 00 
80108271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108274:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010827b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80108284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108287:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010828e:	83 e1 f0             	and    $0xfffffff0,%ecx
80108291:	83 c9 02             	or     $0x2,%ecx
80108294:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010829a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801082a4:	83 c9 10             	or     $0x10,%ecx
801082a7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801082ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801082b7:	83 e1 9f             	and    $0xffffff9f,%ecx
801082ba:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801082c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801082ca:	83 c9 80             	or     $0xffffff80,%ecx
801082cd:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801082d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801082dd:	83 e1 f0             	and    $0xfffffff0,%ecx
801082e0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801082e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801082f0:	83 e1 ef             	and    $0xffffffef,%ecx
801082f3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801082f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fc:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108303:	83 e1 df             	and    $0xffffffdf,%ecx
80108306:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010830c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108316:	83 c9 40             	or     $0x40,%ecx
80108319:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010831f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108322:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108329:	83 c9 80             	or     $0xffffff80,%ecx
8010832c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108335:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	83 c0 70             	add    $0x70,%eax
80108341:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108348:	00 
80108349:	89 04 24             	mov    %eax,(%esp)
8010834c:	e8 37 fb ff ff       	call   80107e88 <lgdt>
  loadgs(SEG_KCPU << 3);
80108351:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108358:	e8 6a fb ff ff       	call   80107ec7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010835d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108360:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108366:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010836d:	00 00 00 00 
}
80108371:	83 c4 24             	add    $0x24,%esp
80108374:	5b                   	pop    %ebx
80108375:	5d                   	pop    %ebp
80108376:	c3                   	ret    

80108377 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108377:	55                   	push   %ebp
80108378:	89 e5                	mov    %esp,%ebp
8010837a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010837d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108380:	c1 e8 16             	shr    $0x16,%eax
80108383:	c1 e0 02             	shl    $0x2,%eax
80108386:	03 45 08             	add    0x8(%ebp),%eax
80108389:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010838c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010838f:	8b 00                	mov    (%eax),%eax
80108391:	83 e0 01             	and    $0x1,%eax
80108394:	84 c0                	test   %al,%al
80108396:	74 17                	je     801083af <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839b:	8b 00                	mov    (%eax),%eax
8010839d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a2:	89 04 24             	mov    %eax,(%esp)
801083a5:	e8 4a fb ff ff       	call   80107ef4 <p2v>
801083aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083ad:	eb 4b                	jmp    801083fa <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801083af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801083b3:	74 0e                	je     801083c3 <walkpgdir+0x4c>
801083b5:	e8 59 ae ff ff       	call   80103213 <kalloc>
801083ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083c1:	75 07                	jne    801083ca <walkpgdir+0x53>
      return 0;
801083c3:	b8 00 00 00 00       	mov    $0x0,%eax
801083c8:	eb 41                	jmp    8010840b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801083ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083d1:	00 
801083d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083d9:	00 
801083da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dd:	89 04 24             	mov    %eax,(%esp)
801083e0:	e8 d9 d3 ff ff       	call   801057be <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801083e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e8:	89 04 24             	mov    %eax,(%esp)
801083eb:	e8 f7 fa ff ff       	call   80107ee7 <v2p>
801083f0:	89 c2                	mov    %eax,%edx
801083f2:	83 ca 07             	or     $0x7,%edx
801083f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801083fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801083fd:	c1 e8 0c             	shr    $0xc,%eax
80108400:	25 ff 03 00 00       	and    $0x3ff,%eax
80108405:	c1 e0 02             	shl    $0x2,%eax
80108408:	03 45 f4             	add    -0xc(%ebp),%eax
}
8010840b:	c9                   	leave  
8010840c:	c3                   	ret    

8010840d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010840d:	55                   	push   %ebp
8010840e:	89 e5                	mov    %esp,%ebp
80108410:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108413:	8b 45 0c             	mov    0xc(%ebp),%eax
80108416:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010841e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108421:	03 45 10             	add    0x10(%ebp),%eax
80108424:	83 e8 01             	sub    $0x1,%eax
80108427:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010842c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010842f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108436:	00 
80108437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010843e:	8b 45 08             	mov    0x8(%ebp),%eax
80108441:	89 04 24             	mov    %eax,(%esp)
80108444:	e8 2e ff ff ff       	call   80108377 <walkpgdir>
80108449:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010844c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108450:	75 07                	jne    80108459 <mappages+0x4c>
      return -1;
80108452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108457:	eb 46                	jmp    8010849f <mappages+0x92>
    if(*pte & PTE_P)
80108459:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010845c:	8b 00                	mov    (%eax),%eax
8010845e:	83 e0 01             	and    $0x1,%eax
80108461:	84 c0                	test   %al,%al
80108463:	74 0c                	je     80108471 <mappages+0x64>
      panic("remap");
80108465:	c7 04 24 84 92 10 80 	movl   $0x80109284,(%esp)
8010846c:	e8 cc 80 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108471:	8b 45 18             	mov    0x18(%ebp),%eax
80108474:	0b 45 14             	or     0x14(%ebp),%eax
80108477:	89 c2                	mov    %eax,%edx
80108479:	83 ca 01             	or     $0x1,%edx
8010847c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108484:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108487:	74 10                	je     80108499 <mappages+0x8c>
      break;
    a += PGSIZE;
80108489:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108490:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108497:	eb 96                	jmp    8010842f <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108499:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010849a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010849f:	c9                   	leave  
801084a0:	c3                   	ret    

801084a1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
801084a1:	55                   	push   %ebp
801084a2:	89 e5                	mov    %esp,%ebp
801084a4:	53                   	push   %ebx
801084a5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801084a8:	e8 66 ad ff ff       	call   80103213 <kalloc>
801084ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084b4:	75 0a                	jne    801084c0 <setupkvm+0x1f>
    return 0;
801084b6:	b8 00 00 00 00       	mov    $0x0,%eax
801084bb:	e9 98 00 00 00       	jmp    80108558 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801084c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084c7:	00 
801084c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084cf:	00 
801084d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084d3:	89 04 24             	mov    %eax,(%esp)
801084d6:	e8 e3 d2 ff ff       	call   801057be <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801084db:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801084e2:	e8 0d fa ff ff       	call   80107ef4 <p2v>
801084e7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801084ec:	76 0c                	jbe    801084fa <setupkvm+0x59>
    panic("PHYSTOP too high");
801084ee:	c7 04 24 8a 92 10 80 	movl   $0x8010928a,(%esp)
801084f5:	e8 43 80 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801084fa:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108501:	eb 49                	jmp    8010854c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108503:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108506:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010850c:	8b 50 04             	mov    0x4(%eax),%edx
8010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108512:	8b 58 08             	mov    0x8(%eax),%ebx
80108515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108518:	8b 40 04             	mov    0x4(%eax),%eax
8010851b:	29 c3                	sub    %eax,%ebx
8010851d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108520:	8b 00                	mov    (%eax),%eax
80108522:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108526:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010852a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010852e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108535:	89 04 24             	mov    %eax,(%esp)
80108538:	e8 d0 fe ff ff       	call   8010840d <mappages>
8010853d:	85 c0                	test   %eax,%eax
8010853f:	79 07                	jns    80108548 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108541:	b8 00 00 00 00       	mov    $0x0,%eax
80108546:	eb 10                	jmp    80108558 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108548:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010854c:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108553:	72 ae                	jb     80108503 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108555:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108558:	83 c4 34             	add    $0x34,%esp
8010855b:	5b                   	pop    %ebx
8010855c:	5d                   	pop    %ebp
8010855d:	c3                   	ret    

8010855e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010855e:	55                   	push   %ebp
8010855f:	89 e5                	mov    %esp,%ebp
80108561:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108564:	e8 38 ff ff ff       	call   801084a1 <setupkvm>
80108569:	a3 b8 4f 11 80       	mov    %eax,0x80114fb8
  switchkvm();
8010856e:	e8 02 00 00 00       	call   80108575 <switchkvm>
}
80108573:	c9                   	leave  
80108574:	c3                   	ret    

80108575 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108575:	55                   	push   %ebp
80108576:	89 e5                	mov    %esp,%ebp
80108578:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010857b:	a1 b8 4f 11 80       	mov    0x80114fb8,%eax
80108580:	89 04 24             	mov    %eax,(%esp)
80108583:	e8 5f f9 ff ff       	call   80107ee7 <v2p>
80108588:	89 04 24             	mov    %eax,(%esp)
8010858b:	e8 4c f9 ff ff       	call   80107edc <lcr3>
}
80108590:	c9                   	leave  
80108591:	c3                   	ret    

80108592 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108592:	55                   	push   %ebp
80108593:	89 e5                	mov    %esp,%ebp
80108595:	53                   	push   %ebx
80108596:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108599:	e8 19 d1 ff ff       	call   801056b7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010859e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085a4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801085ab:	83 c2 08             	add    $0x8,%edx
801085ae:	89 d3                	mov    %edx,%ebx
801085b0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801085b7:	83 c2 08             	add    $0x8,%edx
801085ba:	c1 ea 10             	shr    $0x10,%edx
801085bd:	89 d1                	mov    %edx,%ecx
801085bf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801085c6:	83 c2 08             	add    $0x8,%edx
801085c9:	c1 ea 18             	shr    $0x18,%edx
801085cc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801085d3:	67 00 
801085d5:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801085dc:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801085e2:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801085e9:	83 e1 f0             	and    $0xfffffff0,%ecx
801085ec:	83 c9 09             	or     $0x9,%ecx
801085ef:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801085f5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801085fc:	83 c9 10             	or     $0x10,%ecx
801085ff:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108605:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010860c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010860f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108615:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010861c:	83 c9 80             	or     $0xffffff80,%ecx
8010861f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108625:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010862c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010862f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108635:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010863c:	83 e1 ef             	and    $0xffffffef,%ecx
8010863f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108645:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010864c:	83 e1 df             	and    $0xffffffdf,%ecx
8010864f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108655:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010865c:	83 c9 40             	or     $0x40,%ecx
8010865f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108665:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010866c:	83 e1 7f             	and    $0x7f,%ecx
8010866f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108675:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010867b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108681:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108688:	83 e2 ef             	and    $0xffffffef,%edx
8010868b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108691:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108697:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010869d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801086a3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801086aa:	8b 52 08             	mov    0x8(%edx),%edx
801086ad:	81 c2 00 10 00 00    	add    $0x1000,%edx
801086b3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801086b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801086bd:	e8 ef f7 ff ff       	call   80107eb1 <ltr>
  if(p->pgdir == 0)
801086c2:	8b 45 08             	mov    0x8(%ebp),%eax
801086c5:	8b 40 04             	mov    0x4(%eax),%eax
801086c8:	85 c0                	test   %eax,%eax
801086ca:	75 0c                	jne    801086d8 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801086cc:	c7 04 24 9b 92 10 80 	movl   $0x8010929b,(%esp)
801086d3:	e8 65 7e ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801086d8:	8b 45 08             	mov    0x8(%ebp),%eax
801086db:	8b 40 04             	mov    0x4(%eax),%eax
801086de:	89 04 24             	mov    %eax,(%esp)
801086e1:	e8 01 f8 ff ff       	call   80107ee7 <v2p>
801086e6:	89 04 24             	mov    %eax,(%esp)
801086e9:	e8 ee f7 ff ff       	call   80107edc <lcr3>
  popcli();
801086ee:	e8 0c d0 ff ff       	call   801056ff <popcli>
}
801086f3:	83 c4 14             	add    $0x14,%esp
801086f6:	5b                   	pop    %ebx
801086f7:	5d                   	pop    %ebp
801086f8:	c3                   	ret    

801086f9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801086f9:	55                   	push   %ebp
801086fa:	89 e5                	mov    %esp,%ebp
801086fc:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801086ff:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108706:	76 0c                	jbe    80108714 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108708:	c7 04 24 af 92 10 80 	movl   $0x801092af,(%esp)
8010870f:	e8 29 7e ff ff       	call   8010053d <panic>
  mem = kalloc();
80108714:	e8 fa aa ff ff       	call   80103213 <kalloc>
80108719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010871c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108723:	00 
80108724:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010872b:	00 
8010872c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872f:	89 04 24             	mov    %eax,(%esp)
80108732:	e8 87 d0 ff ff       	call   801057be <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	89 04 24             	mov    %eax,(%esp)
8010873d:	e8 a5 f7 ff ff       	call   80107ee7 <v2p>
80108742:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108749:	00 
8010874a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010874e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108755:	00 
80108756:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010875d:	00 
8010875e:	8b 45 08             	mov    0x8(%ebp),%eax
80108761:	89 04 24             	mov    %eax,(%esp)
80108764:	e8 a4 fc ff ff       	call   8010840d <mappages>
  memmove(mem, init, sz);
80108769:	8b 45 10             	mov    0x10(%ebp),%eax
8010876c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108770:	8b 45 0c             	mov    0xc(%ebp),%eax
80108773:	89 44 24 04          	mov    %eax,0x4(%esp)
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	89 04 24             	mov    %eax,(%esp)
8010877d:	e8 0f d1 ff ff       	call   80105891 <memmove>
}
80108782:	c9                   	leave  
80108783:	c3                   	ret    

80108784 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108784:	55                   	push   %ebp
80108785:	89 e5                	mov    %esp,%ebp
80108787:	53                   	push   %ebx
80108788:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010878b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010878e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108793:	85 c0                	test   %eax,%eax
80108795:	74 0c                	je     801087a3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108797:	c7 04 24 cc 92 10 80 	movl   $0x801092cc,(%esp)
8010879e:	e8 9a 7d ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801087a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087aa:	e9 ad 00 00 00       	jmp    8010885c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801087af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b2:	8b 55 0c             	mov    0xc(%ebp),%edx
801087b5:	01 d0                	add    %edx,%eax
801087b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087be:	00 
801087bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801087c3:	8b 45 08             	mov    0x8(%ebp),%eax
801087c6:	89 04 24             	mov    %eax,(%esp)
801087c9:	e8 a9 fb ff ff       	call   80108377 <walkpgdir>
801087ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087d5:	75 0c                	jne    801087e3 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801087d7:	c7 04 24 ef 92 10 80 	movl   $0x801092ef,(%esp)
801087de:	e8 5a 7d ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801087e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e6:	8b 00                	mov    (%eax),%eax
801087e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801087f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f3:	8b 55 18             	mov    0x18(%ebp),%edx
801087f6:	89 d1                	mov    %edx,%ecx
801087f8:	29 c1                	sub    %eax,%ecx
801087fa:	89 c8                	mov    %ecx,%eax
801087fc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108801:	77 11                	ja     80108814 <loaduvm+0x90>
      n = sz - i;
80108803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108806:	8b 55 18             	mov    0x18(%ebp),%edx
80108809:	89 d1                	mov    %edx,%ecx
8010880b:	29 c1                	sub    %eax,%ecx
8010880d:	89 c8                	mov    %ecx,%eax
8010880f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108812:	eb 07                	jmp    8010881b <loaduvm+0x97>
    else
      n = PGSIZE;
80108814:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010881b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881e:	8b 55 14             	mov    0x14(%ebp),%edx
80108821:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108824:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108827:	89 04 24             	mov    %eax,(%esp)
8010882a:	e8 c5 f6 ff ff       	call   80107ef4 <p2v>
8010882f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108832:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108836:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010883a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010883e:	8b 45 10             	mov    0x10(%ebp),%eax
80108841:	89 04 24             	mov    %eax,(%esp)
80108844:	e8 29 9c ff ff       	call   80102472 <readi>
80108849:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010884c:	74 07                	je     80108855 <loaduvm+0xd1>
      return -1;
8010884e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108853:	eb 18                	jmp    8010886d <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108855:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108862:	0f 82 47 ff ff ff    	jb     801087af <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108868:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010886d:	83 c4 24             	add    $0x24,%esp
80108870:	5b                   	pop    %ebx
80108871:	5d                   	pop    %ebp
80108872:	c3                   	ret    

80108873 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108873:	55                   	push   %ebp
80108874:	89 e5                	mov    %esp,%ebp
80108876:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108879:	8b 45 10             	mov    0x10(%ebp),%eax
8010887c:	85 c0                	test   %eax,%eax
8010887e:	79 0a                	jns    8010888a <allocuvm+0x17>
    return 0;
80108880:	b8 00 00 00 00       	mov    $0x0,%eax
80108885:	e9 c1 00 00 00       	jmp    8010894b <allocuvm+0xd8>
  if(newsz < oldsz)
8010888a:	8b 45 10             	mov    0x10(%ebp),%eax
8010888d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108890:	73 08                	jae    8010889a <allocuvm+0x27>
    return oldsz;
80108892:	8b 45 0c             	mov    0xc(%ebp),%eax
80108895:	e9 b1 00 00 00       	jmp    8010894b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010889a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010889d:	05 ff 0f 00 00       	add    $0xfff,%eax
801088a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801088aa:	e9 8d 00 00 00       	jmp    8010893c <allocuvm+0xc9>
    mem = kalloc();
801088af:	e8 5f a9 ff ff       	call   80103213 <kalloc>
801088b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801088b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088bb:	75 2c                	jne    801088e9 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801088bd:	c7 04 24 0d 93 10 80 	movl   $0x8010930d,(%esp)
801088c4:	e8 d8 7a ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801088c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801088cc:	89 44 24 08          	mov    %eax,0x8(%esp)
801088d0:	8b 45 10             	mov    0x10(%ebp),%eax
801088d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801088d7:	8b 45 08             	mov    0x8(%ebp),%eax
801088da:	89 04 24             	mov    %eax,(%esp)
801088dd:	e8 6b 00 00 00       	call   8010894d <deallocuvm>
      return 0;
801088e2:	b8 00 00 00 00       	mov    $0x0,%eax
801088e7:	eb 62                	jmp    8010894b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801088e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088f0:	00 
801088f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088f8:	00 
801088f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088fc:	89 04 24             	mov    %eax,(%esp)
801088ff:	e8 ba ce ff ff       	call   801057be <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108907:	89 04 24             	mov    %eax,(%esp)
8010890a:	e8 d8 f5 ff ff       	call   80107ee7 <v2p>
8010890f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108912:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108919:	00 
8010891a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010891e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108925:	00 
80108926:	89 54 24 04          	mov    %edx,0x4(%esp)
8010892a:	8b 45 08             	mov    0x8(%ebp),%eax
8010892d:	89 04 24             	mov    %eax,(%esp)
80108930:	e8 d8 fa ff ff       	call   8010840d <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108935:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010893c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108942:	0f 82 67 ff ff ff    	jb     801088af <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108948:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010894b:	c9                   	leave  
8010894c:	c3                   	ret    

8010894d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010894d:	55                   	push   %ebp
8010894e:	89 e5                	mov    %esp,%ebp
80108950:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108953:	8b 45 10             	mov    0x10(%ebp),%eax
80108956:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108959:	72 08                	jb     80108963 <deallocuvm+0x16>
    return oldsz;
8010895b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895e:	e9 a4 00 00 00       	jmp    80108a07 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108963:	8b 45 10             	mov    0x10(%ebp),%eax
80108966:	05 ff 0f 00 00       	add    $0xfff,%eax
8010896b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108970:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108973:	e9 80 00 00 00       	jmp    801089f8 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108982:	00 
80108983:	89 44 24 04          	mov    %eax,0x4(%esp)
80108987:	8b 45 08             	mov    0x8(%ebp),%eax
8010898a:	89 04 24             	mov    %eax,(%esp)
8010898d:	e8 e5 f9 ff ff       	call   80108377 <walkpgdir>
80108992:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108995:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108999:	75 09                	jne    801089a4 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010899b:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801089a2:	eb 4d                	jmp    801089f1 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801089a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a7:	8b 00                	mov    (%eax),%eax
801089a9:	83 e0 01             	and    $0x1,%eax
801089ac:	84 c0                	test   %al,%al
801089ae:	74 41                	je     801089f1 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801089b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b3:	8b 00                	mov    (%eax),%eax
801089b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801089bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089c1:	75 0c                	jne    801089cf <deallocuvm+0x82>
        panic("kfree");
801089c3:	c7 04 24 25 93 10 80 	movl   $0x80109325,(%esp)
801089ca:	e8 6e 7b ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801089cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089d2:	89 04 24             	mov    %eax,(%esp)
801089d5:	e8 1a f5 ff ff       	call   80107ef4 <p2v>
801089da:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801089dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089e0:	89 04 24             	mov    %eax,(%esp)
801089e3:	e8 92 a7 ff ff       	call   8010317a <kfree>
      *pte = 0;
801089e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801089f1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089fe:	0f 82 74 ff ff ff    	jb     80108978 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108a04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108a07:	c9                   	leave  
80108a08:	c3                   	ret    

80108a09 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108a09:	55                   	push   %ebp
80108a0a:	89 e5                	mov    %esp,%ebp
80108a0c:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108a0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108a13:	75 0c                	jne    80108a21 <freevm+0x18>
    panic("freevm: no pgdir");
80108a15:	c7 04 24 2b 93 10 80 	movl   $0x8010932b,(%esp)
80108a1c:	e8 1c 7b ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108a21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a28:	00 
80108a29:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108a30:	80 
80108a31:	8b 45 08             	mov    0x8(%ebp),%eax
80108a34:	89 04 24             	mov    %eax,(%esp)
80108a37:	e8 11 ff ff ff       	call   8010894d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a43:	eb 3c                	jmp    80108a81 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a48:	c1 e0 02             	shl    $0x2,%eax
80108a4b:	03 45 08             	add    0x8(%ebp),%eax
80108a4e:	8b 00                	mov    (%eax),%eax
80108a50:	83 e0 01             	and    $0x1,%eax
80108a53:	84 c0                	test   %al,%al
80108a55:	74 26                	je     80108a7d <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5a:	c1 e0 02             	shl    $0x2,%eax
80108a5d:	03 45 08             	add    0x8(%ebp),%eax
80108a60:	8b 00                	mov    (%eax),%eax
80108a62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a67:	89 04 24             	mov    %eax,(%esp)
80108a6a:	e8 85 f4 ff ff       	call   80107ef4 <p2v>
80108a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a75:	89 04 24             	mov    %eax,(%esp)
80108a78:	e8 fd a6 ff ff       	call   8010317a <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108a7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a81:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108a88:	76 bb                	jbe    80108a45 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a8d:	89 04 24             	mov    %eax,(%esp)
80108a90:	e8 e5 a6 ff ff       	call   8010317a <kfree>
}
80108a95:	c9                   	leave  
80108a96:	c3                   	ret    

80108a97 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108a97:	55                   	push   %ebp
80108a98:	89 e5                	mov    %esp,%ebp
80108a9a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108aa4:	00 
80108aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
80108aac:	8b 45 08             	mov    0x8(%ebp),%eax
80108aaf:	89 04 24             	mov    %eax,(%esp)
80108ab2:	e8 c0 f8 ff ff       	call   80108377 <walkpgdir>
80108ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108abe:	75 0c                	jne    80108acc <clearpteu+0x35>
    panic("clearpteu");
80108ac0:	c7 04 24 3c 93 10 80 	movl   $0x8010933c,(%esp)
80108ac7:	e8 71 7a ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acf:	8b 00                	mov    (%eax),%eax
80108ad1:	89 c2                	mov    %eax,%edx
80108ad3:	83 e2 fb             	and    $0xfffffffb,%edx
80108ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad9:	89 10                	mov    %edx,(%eax)
}
80108adb:	c9                   	leave  
80108adc:	c3                   	ret    

80108add <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108add:	55                   	push   %ebp
80108ade:	89 e5                	mov    %esp,%ebp
80108ae0:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108ae3:	e8 b9 f9 ff ff       	call   801084a1 <setupkvm>
80108ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108aeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108aef:	75 0a                	jne    80108afb <copyuvm+0x1e>
    return 0;
80108af1:	b8 00 00 00 00       	mov    $0x0,%eax
80108af6:	e9 f1 00 00 00       	jmp    80108bec <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80108afb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b02:	e9 c0 00 00 00       	jmp    80108bc7 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b11:	00 
80108b12:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b16:	8b 45 08             	mov    0x8(%ebp),%eax
80108b19:	89 04 24             	mov    %eax,(%esp)
80108b1c:	e8 56 f8 ff ff       	call   80108377 <walkpgdir>
80108b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b28:	75 0c                	jne    80108b36 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108b2a:	c7 04 24 46 93 10 80 	movl   $0x80109346,(%esp)
80108b31:	e8 07 7a ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108b36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b39:	8b 00                	mov    (%eax),%eax
80108b3b:	83 e0 01             	and    $0x1,%eax
80108b3e:	85 c0                	test   %eax,%eax
80108b40:	75 0c                	jne    80108b4e <copyuvm+0x71>
      panic("copyuvm: page not present");
80108b42:	c7 04 24 60 93 10 80 	movl   $0x80109360,(%esp)
80108b49:	e8 ef 79 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108b4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b51:	8b 00                	mov    (%eax),%eax
80108b53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b58:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108b5b:	e8 b3 a6 ff ff       	call   80103213 <kalloc>
80108b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108b63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b67:	74 6f                	je     80108bd8 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108b69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b6c:	89 04 24             	mov    %eax,(%esp)
80108b6f:	e8 80 f3 ff ff       	call   80107ef4 <p2v>
80108b74:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b7b:	00 
80108b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b83:	89 04 24             	mov    %eax,(%esp)
80108b86:	e8 06 cd ff ff       	call   80105891 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b8e:	89 04 24             	mov    %eax,(%esp)
80108b91:	e8 51 f3 ff ff       	call   80107ee7 <v2p>
80108b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b99:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ba0:	00 
80108ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108ba5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108bac:	00 
80108bad:	89 54 24 04          	mov    %edx,0x4(%esp)
80108bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb4:	89 04 24             	mov    %eax,(%esp)
80108bb7:	e8 51 f8 ff ff       	call   8010840d <mappages>
80108bbc:	85 c0                	test   %eax,%eax
80108bbe:	78 1b                	js     80108bdb <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108bc0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bca:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108bcd:	0f 82 34 ff ff ff    	jb     80108b07 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd6:	eb 14                	jmp    80108bec <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108bd8:	90                   	nop
80108bd9:	eb 01                	jmp    80108bdc <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108bdb:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bdf:	89 04 24             	mov    %eax,(%esp)
80108be2:	e8 22 fe ff ff       	call   80108a09 <freevm>
  return 0;
80108be7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bec:	c9                   	leave  
80108bed:	c3                   	ret    

80108bee <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108bee:	55                   	push   %ebp
80108bef:	89 e5                	mov    %esp,%ebp
80108bf1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108bf4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bfb:	00 
80108bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c03:	8b 45 08             	mov    0x8(%ebp),%eax
80108c06:	89 04 24             	mov    %eax,(%esp)
80108c09:	e8 69 f7 ff ff       	call   80108377 <walkpgdir>
80108c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c14:	8b 00                	mov    (%eax),%eax
80108c16:	83 e0 01             	and    $0x1,%eax
80108c19:	85 c0                	test   %eax,%eax
80108c1b:	75 07                	jne    80108c24 <uva2ka+0x36>
    return 0;
80108c1d:	b8 00 00 00 00       	mov    $0x0,%eax
80108c22:	eb 25                	jmp    80108c49 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c27:	8b 00                	mov    (%eax),%eax
80108c29:	83 e0 04             	and    $0x4,%eax
80108c2c:	85 c0                	test   %eax,%eax
80108c2e:	75 07                	jne    80108c37 <uva2ka+0x49>
    return 0;
80108c30:	b8 00 00 00 00       	mov    $0x0,%eax
80108c35:	eb 12                	jmp    80108c49 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3a:	8b 00                	mov    (%eax),%eax
80108c3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c41:	89 04 24             	mov    %eax,(%esp)
80108c44:	e8 ab f2 ff ff       	call   80107ef4 <p2v>
}
80108c49:	c9                   	leave  
80108c4a:	c3                   	ret    

80108c4b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108c4b:	55                   	push   %ebp
80108c4c:	89 e5                	mov    %esp,%ebp
80108c4e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108c51:	8b 45 10             	mov    0x10(%ebp),%eax
80108c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108c57:	e9 8b 00 00 00       	jmp    80108ce7 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c64:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c71:	89 04 24             	mov    %eax,(%esp)
80108c74:	e8 75 ff ff ff       	call   80108bee <uva2ka>
80108c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108c7c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108c80:	75 07                	jne    80108c89 <copyout+0x3e>
      return -1;
80108c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c87:	eb 6d                	jmp    80108cf6 <copyout+0xab>
    n = PGSIZE - (va - va0);
80108c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108c8f:	89 d1                	mov    %edx,%ecx
80108c91:	29 c1                	sub    %eax,%ecx
80108c93:	89 c8                	mov    %ecx,%eax
80108c95:	05 00 10 00 00       	add    $0x1000,%eax
80108c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca0:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ca3:	76 06                	jbe    80108cab <copyout+0x60>
      n = len;
80108ca5:	8b 45 14             	mov    0x14(%ebp),%eax
80108ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cae:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cb1:	89 d1                	mov    %edx,%ecx
80108cb3:	29 c1                	sub    %eax,%ecx
80108cb5:	89 c8                	mov    %ecx,%eax
80108cb7:	03 45 e8             	add    -0x18(%ebp),%eax
80108cba:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108cbd:	89 54 24 08          	mov    %edx,0x8(%esp)
80108cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cc4:	89 54 24 04          	mov    %edx,0x4(%esp)
80108cc8:	89 04 24             	mov    %eax,(%esp)
80108ccb:	e8 c1 cb ff ff       	call   80105891 <memmove>
    len -= n;
80108cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cdf:	05 00 10 00 00       	add    $0x1000,%eax
80108ce4:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108ce7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108ceb:	0f 85 6b ff ff ff    	jne    80108c5c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cf6:	c9                   	leave  
80108cf7:	c3                   	ret    
