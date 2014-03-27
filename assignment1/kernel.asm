
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 10 d6 10 80       	mov    $0x8010d610,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 2b 3b 10 80       	mov    $0x80103b2b,%eax
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
8010003a:	c7 44 24 04 f4 88 10 	movl   $0x801088f4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100049:	e8 58 52 00 00       	call   801052a6 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 50 eb 10 80 44 	movl   $0x8010eb44,0x8010eb50
80100055:	eb 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 54 eb 10 80 44 	movl   $0x8010eb44,0x8010eb54
8010005f:	eb 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 54 d6 10 80 	movl   $0x8010d654,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 54 eb 10 80    	mov    0x8010eb54,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 44 eb 10 80 	movl   $0x8010eb44,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 54 eb 10 80       	mov    0x8010eb54,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 54 eb 10 80       	mov    %eax,0x8010eb54

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 44 eb 10 80 	cmpl   $0x8010eb44,-0xc(%ebp)
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
801000b6:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
801000bd:	e8 05 52 00 00       	call   801052c7 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 54 eb 10 80       	mov    0x8010eb54,%eax
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
801000fd:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100104:	e8 20 52 00 00       	call   80105329 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 20 d6 10 	movl   $0x8010d620,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 c5 4e 00 00       	call   80104fe9 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 44 eb 10 80 	cmpl   $0x8010eb44,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 50 eb 10 80       	mov    0x8010eb50,%eax
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
80100175:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
8010017c:	e8 a8 51 00 00       	call   80105329 <release>
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
8010018f:	81 7d f4 44 eb 10 80 	cmpl   $0x8010eb44,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
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
801001d3:	e8 00 2d 00 00       	call   80102ed8 <iderw>
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
801001ef:	c7 04 24 0c 89 10 80 	movl   $0x8010890c,(%esp)
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
80100210:	e8 c3 2c 00 00       	call   80102ed8 <iderw>
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
80100229:	c7 04 24 13 89 10 80 	movl   $0x80108913,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
8010023c:	e8 86 50 00 00       	call   801052c7 <acquire>

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
8010025f:	8b 15 54 eb 10 80    	mov    0x8010eb54,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 44 eb 10 80 	movl   $0x8010eb44,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 54 eb 10 80       	mov    0x8010eb54,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 54 eb 10 80       	mov    %eax,0x8010eb54

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
8010029d:	e8 20 4e 00 00       	call   801050c2 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
801002a9:	e8 7b 50 00 00       	call   80105329 <release>
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
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
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
801003a7:	a1 74 c0 10 80       	mov    0x8010c074,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 40 c0 10 80 	movl   $0x8010c040,(%esp)
801003bc:	e8 06 4f 00 00       	call   801052c7 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 1a 89 10 80 	movl   $0x8010891a,(%esp)
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
801004af:	c7 45 ec 23 89 10 80 	movl   $0x80108923,-0x14(%ebp)
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
8010052f:	c7 04 24 40 c0 10 80 	movl   $0x8010c040,(%esp)
80100536:	e8 ee 4d 00 00       	call   80105329 <release>
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
80100548:	c7 05 74 c0 10 80 00 	movl   $0x0,0x8010c074
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 2a 89 10 80 	movl   $0x8010892a,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 39 89 10 80 	movl   $0x80108939,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 e1 4d 00 00       	call   80105378 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
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
801005c1:	c7 05 30 c0 10 80 01 	movl   $0x1,0x8010c030
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
80100697:	a1 00 90 10 80       	mov    0x80109000,%eax
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
801006bd:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006c8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cd:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006d4:	00 
801006d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801006d9:	89 04 24             	mov    %eax,(%esp)
801006dc:	e8 08 4f 00 00       	call   801055e9 <memmove>
    pos -= 80;
801006e1:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e5:	b8 80 07 00 00       	mov    $0x780,%eax
801006ea:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ed:	01 c0                	add    %eax,%eax
801006ef:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006f5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006f8:	01 c9                	add    %ecx,%ecx
801006fa:	01 ca                	add    %ecx,%edx
801006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100700:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100707:	00 
80100708:	89 14 24             	mov    %edx,(%esp)
8010070b:	e8 06 4e 00 00       	call   80105516 <memset>
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
80100770:	a1 00 90 10 80       	mov    0x80109000,%eax
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
80100789:	a1 30 c0 10 80       	mov    0x8010c030,%eax
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
801007a9:	e8 ab 67 00 00       	call   80106f59 <uartputc>
801007ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007b5:	e8 9f 67 00 00       	call   80106f59 <uartputc>
801007ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007c1:	e8 93 67 00 00       	call   80106f59 <uartputc>
801007c6:	eb 0b                	jmp    801007d3 <consputc+0x50>
  } else
    uartputc(c);
801007c8:	8b 45 08             	mov    0x8(%ebp),%eax
801007cb:	89 04 24             	mov    %eax,(%esp)
801007ce:	e8 86 67 00 00       	call   80106f59 <uartputc>
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
801007e6:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
801007ed:	e8 d5 4a 00 00       	call   801052c7 <acquire>
  while((c = getc()) >= 0){
801007f2:	e9 e3 05 00 00       	jmp    80100dda <consoleintr+0x5fa>
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
8010081b:	e9 ec 03 00 00       	jmp    80100c0c <consoleintr+0x42c>
80100820:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100825:	0f 84 00 03 00 00    	je     80100b2b <consoleintr+0x34b>
8010082b:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100830:	7f 10                	jg     80100842 <consoleintr+0x62>
80100832:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100837:	0f 84 cb 01 00 00    	je     80100a08 <consoleintr+0x228>
8010083d:	e9 ca 03 00 00       	jmp    80100c0c <consoleintr+0x42c>
80100842:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100847:	0f 84 5a 01 00 00    	je     801009a7 <consoleintr+0x1c7>
8010084d:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100852:	0f 84 86 01 00 00    	je     801009de <consoleintr+0x1fe>
80100858:	e9 af 03 00 00       	jmp    80100c0c <consoleintr+0x42c>
    case C('P'):  // Process listing.
      procdump();
8010085d:	e8 03 49 00 00       	call   80105165 <procdump>
      break;
80100862:	e9 73 05 00 00       	jmp    80100dda <consoleintr+0x5fa>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100867:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
8010086c:	83 e8 01             	sub    $0x1,%eax
8010086f:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
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
80100883:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100889:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 37 05 00 00    	je     80100dcd <consoleintr+0x5ed>
80100896:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 94 ed 10 80 	movzbl -0x7fef126c(%eax),%eax
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 bb                	jne    80100867 <consoleintr+0x87>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008ac:	e9 1c 05 00 00       	jmp    80100dcd <consoleintr+0x5ed>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
801008b7:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 0c 05 00 00    	je     80100dd0 <consoleintr+0x5f0>
        input.e--;
801008c4:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    	input.e -= arrows_counter;
801008d1:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
801008d7:	a1 78 c0 10 80       	mov    0x8010c078,%eax
801008dc:	89 d1                	mov    %edx,%ecx
801008de:	29 c1                	sub    %eax,%ecx
801008e0:	89 c8                	mov    %ecx,%eax
801008e2:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    	for(i = 0; i < arrows_counter; ++i)
801008e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801008ee:	eb 2c                	jmp    8010091c <consoleintr+0x13c>
    	{
    	  input.buf[input.e] = input.buf[input.e+1];
801008f0:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
801008f5:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
801008fb:	83 c2 01             	add    $0x1,%edx
801008fe:	0f b6 92 94 ed 10 80 	movzbl -0x7fef126c(%edx),%edx
80100905:	88 90 94 ed 10 80    	mov    %dl,-0x7fef126c(%eax)
    	  ++input.e;
8010090b:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100910:	83 c0 01             	add    $0x1,%eax
80100913:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
    	input.e -= arrows_counter;
    	for(i = 0; i < arrows_counter; ++i)
80100918:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010091c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010091f:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100924:	39 c2                	cmp    %eax,%edx
80100926:	72 c8                	jb     801008f0 <consoleintr+0x110>
    	{
    	  input.buf[input.e] = input.buf[input.e+1];
    	  ++input.e;
    	}
    	input.buf[input.e] = '\0';  //null terminated
80100928:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
8010092d:	c6 80 94 ed 10 80 00 	movb   $0x0,-0x7fef126c(%eax)
        consputc(BACKSPACE);
80100934:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010093b:	e8 43 fe ff ff       	call   80100783 <consputc>

        for(i = 0; i <= arrows_counter; ++i)
80100940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100947:	eb 28                	jmp    80100971 <consoleintr+0x191>
        	consputc(input.buf[input.e - arrows_counter +i ]);
80100949:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
8010094f:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100954:	29 c2                	sub    %eax,%edx
80100956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100959:	01 d0                	add    %edx,%eax
8010095b:	0f b6 80 94 ed 10 80 	movzbl -0x7fef126c(%eax),%eax
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
80100974:	a1 78 c0 10 80       	mov    0x8010c078,%eax
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
80100999:	a1 78 c0 10 80       	mov    0x8010c078,%eax
8010099e:	39 c2                	cmp    %eax,%edx
801009a0:	76 e4                	jbe    80100986 <consoleintr+0x1a6>
        	cgaputc(KEY_LF);
      }
      break;
801009a2:	e9 29 04 00 00       	jmp    80100dd0 <consoleintr+0x5f0>

    case KEY_LF:
      if(arrows_counter < input.e - input.r) {
801009a7:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
801009ad:	a1 14 ee 10 80       	mov    0x8010ee14,%eax
801009b2:	29 c2                	sub    %eax,%edx
801009b4:	a1 78 c0 10 80       	mov    0x8010c078,%eax
801009b9:	39 c2                	cmp    %eax,%edx
801009bb:	0f 86 12 04 00 00    	jbe    80100dd3 <consoleintr+0x5f3>
    	  arrows_counter++;
801009c1:	a1 78 c0 10 80       	mov    0x8010c078,%eax
801009c6:	83 c0 01             	add    $0x1,%eax
801009c9:	a3 78 c0 10 80       	mov    %eax,0x8010c078
    	  consputc(c);
801009ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009d1:	89 04 24             	mov    %eax,(%esp)
801009d4:	e8 aa fd ff ff       	call   80100783 <consputc>
      }
      break;
801009d9:	e9 f5 03 00 00       	jmp    80100dd3 <consoleintr+0x5f3>

    case KEY_RT:
    	if(arrows_counter > 0) {
801009de:	a1 78 c0 10 80       	mov    0x8010c078,%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	0f 84 eb 03 00 00    	je     80100dd6 <consoleintr+0x5f6>
    		arrows_counter--;
801009eb:	a1 78 c0 10 80       	mov    0x8010c078,%eax
801009f0:	83 e8 01             	sub    $0x1,%eax
801009f3:	a3 78 c0 10 80       	mov    %eax,0x8010c078
    		consputc(c);
801009f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009fb:	89 04 24             	mov    %eax,(%esp)
801009fe:	e8 80 fd ff ff       	call   80100783 <consputc>
    	}
    	break;
80100a03:	e9 ce 03 00 00       	jmp    80100dd6 <consoleintr+0x5f6>

    case KEY_UP: // up arrow
    	input.e += arrows_counter;
80100a08:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100a0e:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100a13:	01 d0                	add    %edx,%eax
80100a15:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
80100a1a:	eb 19                	jmp    80100a35 <consoleintr+0x255>
    		input.e--;
80100a1c:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100a21:	83 e8 01             	sub    $0x1,%eax
80100a24:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    	    consputc(BACKSPACE);
80100a29:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a30:	e8 4e fd ff ff       	call   80100783 <consputc>
    	}
    	break;

    case KEY_UP: // up arrow
    	input.e += arrows_counter;
    	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
80100a35:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100a3b:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
80100a40:	39 c2                	cmp    %eax,%edx
80100a42:	74 16                	je     80100a5a <consoleintr+0x27a>
80100a44:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100a49:	83 e8 01             	sub    $0x1,%eax
80100a4c:	83 e0 7f             	and    $0x7f,%eax
80100a4f:	0f b6 80 94 ed 10 80 	movzbl -0x7fef126c(%eax),%eax
80100a56:	3c 0a                	cmp    $0xa,%al
80100a58:	75 c2                	jne    80100a1c <consoleintr+0x23c>
    		input.e--;
    	    consputc(BACKSPACE);
    	}

        for(i=0; i < strlen(history.commands[history.iter]); i++)
80100a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a61:	eb 41                	jmp    80100aa4 <consoleintr+0x2c4>
        {
          input.buf[i] = history.commands[history.iter][i];
80100a63:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100a68:	c1 e0 07             	shl    $0x7,%eax
80100a6b:	03 45 f4             	add    -0xc(%ebp),%eax
80100a6e:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100a73:	0f b6 00             	movzbl (%eax),%eax
80100a76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a79:	81 c2 90 ed 10 80    	add    $0x8010ed90,%edx
80100a7f:	88 42 04             	mov    %al,0x4(%edx)
          consputc(history.commands[history.iter][i]);
80100a82:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100a87:	c1 e0 07             	shl    $0x7,%eax
80100a8a:	03 45 f4             	add    -0xc(%ebp),%eax
80100a8d:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100a92:	0f b6 00             	movzbl (%eax),%eax
80100a95:	0f be c0             	movsbl %al,%eax
80100a98:	89 04 24             	mov    %eax,(%esp)
80100a9b:	e8 e3 fc ff ff       	call   80100783 <consputc>
    	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
    		input.e--;
    	    consputc(BACKSPACE);
    	}

        for(i=0; i < strlen(history.commands[history.iter]); i++)
80100aa0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aa4:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100aa9:	c1 e0 07             	shl    $0x7,%eax
80100aac:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 db 4c 00 00       	call   80105794 <strlen>
80100ab9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100abc:	7f a5                	jg     80100a63 <consoleintr+0x283>
        {
          input.buf[i] = history.commands[history.iter][i];
          consputc(history.commands[history.iter][i]);
        }

        if (history.iter-1 == -1)
80100abe:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100ac3:	85 c0                	test   %eax,%eax
80100ac5:	75 0f                	jne    80100ad6 <consoleintr+0x2f6>
        	history.iter = history.num_of_curr_entries-1;
80100ac7:	a1 a4 b5 10 80       	mov    0x8010b5a4,%eax
80100acc:	83 e8 01             	sub    $0x1,%eax
80100acf:	a3 a8 b5 10 80       	mov    %eax,0x8010b5a8
80100ad4:	eb 0d                	jmp    80100ae3 <consoleintr+0x303>
        else
        	history.iter--;
80100ad6:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100adb:	83 e8 01             	sub    $0x1,%eax
80100ade:	a3 a8 b5 10 80       	mov    %eax,0x8010b5a8

        input.buf[i] = '\0';
80100ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae6:	05 90 ed 10 80       	add    $0x8010ed90,%eax
80100aeb:	c6 40 04 00          	movb   $0x0,0x4(%eax)
        input.e = i;
80100aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af2:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
        input.r = input.w = 0;
80100af7:	c7 05 18 ee 10 80 00 	movl   $0x0,0x8010ee18
80100afe:	00 00 00 
80100b01:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
80100b06:	a3 14 ee 10 80       	mov    %eax,0x8010ee14

    	break;
80100b0b:	e9 ca 02 00 00       	jmp    80100dda <consoleintr+0x5fa>

    case KEY_DN: // down arrow
        	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
        		input.e--;
80100b10:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100b15:	83 e8 01             	sub    $0x1,%eax
80100b18:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
        	    consputc(BACKSPACE);
80100b1d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100b24:	e8 5a fc ff ff       	call   80100783 <consputc>
80100b29:	eb 01                	jmp    80100b2c <consoleintr+0x34c>
        input.r = input.w = 0;

    	break;

    case KEY_DN: // down arrow
        	while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n') {
80100b2b:	90                   	nop
80100b2c:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100b32:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
80100b37:	39 c2                	cmp    %eax,%edx
80100b39:	74 16                	je     80100b51 <consoleintr+0x371>
80100b3b:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100b40:	83 e8 01             	sub    $0x1,%eax
80100b43:	83 e0 7f             	and    $0x7f,%eax
80100b46:	0f b6 80 94 ed 10 80 	movzbl -0x7fef126c(%eax),%eax
80100b4d:	3c 0a                	cmp    $0xa,%al
80100b4f:	75 bf                	jne    80100b10 <consoleintr+0x330>
        		input.e--;
        	    consputc(BACKSPACE);
        	}

        	if (history.iter+1 == history.num_of_curr_entries)
80100b51:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100b56:	8d 50 01             	lea    0x1(%eax),%edx
80100b59:	a1 a4 b5 10 80       	mov    0x8010b5a4,%eax
80100b5e:	39 c2                	cmp    %eax,%edx
80100b60:	75 0c                	jne    80100b6e <consoleintr+0x38e>
        		history.iter = 0;
80100b62:	c7 05 a8 b5 10 80 00 	movl   $0x0,0x8010b5a8
80100b69:	00 00 00 
80100b6c:	eb 0d                	jmp    80100b7b <consoleintr+0x39b>
        	else
        		history.iter++;
80100b6e:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100b73:	83 c0 01             	add    $0x1,%eax
80100b76:	a3 a8 b5 10 80       	mov    %eax,0x8010b5a8

            for(i=0; i < strlen(history.commands[history.iter]); i++)
80100b7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b82:	eb 41                	jmp    80100bc5 <consoleintr+0x3e5>
            {
              input.buf[i] = history.commands[history.iter][i];
80100b84:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100b89:	c1 e0 07             	shl    $0x7,%eax
80100b8c:	03 45 f4             	add    -0xc(%ebp),%eax
80100b8f:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100b94:	0f b6 00             	movzbl (%eax),%eax
80100b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b9a:	81 c2 90 ed 10 80    	add    $0x8010ed90,%edx
80100ba0:	88 42 04             	mov    %al,0x4(%edx)
              consputc(history.commands[history.iter][i]);
80100ba3:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100ba8:	c1 e0 07             	shl    $0x7,%eax
80100bab:	03 45 f4             	add    -0xc(%ebp),%eax
80100bae:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100bb3:	0f b6 00             	movzbl (%eax),%eax
80100bb6:	0f be c0             	movsbl %al,%eax
80100bb9:	89 04 24             	mov    %eax,(%esp)
80100bbc:	e8 c2 fb ff ff       	call   80100783 <consputc>
        	if (history.iter+1 == history.num_of_curr_entries)
        		history.iter = 0;
        	else
        		history.iter++;

            for(i=0; i < strlen(history.commands[history.iter]); i++)
80100bc1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bc5:	a1 a8 b5 10 80       	mov    0x8010b5a8,%eax
80100bca:	c1 e0 07             	shl    $0x7,%eax
80100bcd:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100bd2:	89 04 24             	mov    %eax,(%esp)
80100bd5:	e8 ba 4b 00 00       	call   80105794 <strlen>
80100bda:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100bdd:	7f a5                	jg     80100b84 <consoleintr+0x3a4>
              input.buf[i] = history.commands[history.iter][i];
              consputc(history.commands[history.iter][i]);
            }


            input.buf[i] = '\0';
80100bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100be2:	05 90 ed 10 80       	add    $0x8010ed90,%eax
80100be7:	c6 40 04 00          	movb   $0x0,0x4(%eax)
            input.e = i;
80100beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bee:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
            input.r = input.w = 0;
80100bf3:	c7 05 18 ee 10 80 00 	movl   $0x0,0x8010ee18
80100bfa:	00 00 00 
80100bfd:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
80100c02:	a3 14 ee 10 80       	mov    %eax,0x8010ee14

        	break;
80100c07:	e9 ce 01 00 00       	jmp    80100dda <consoleintr+0x5fa>

    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100c0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100c10:	0f 84 c3 01 00 00    	je     80100dd9 <consoleintr+0x5f9>
80100c16:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100c1c:	a1 14 ee 10 80       	mov    0x8010ee14,%eax
80100c21:	89 d1                	mov    %edx,%ecx
80100c23:	29 c1                	sub    %eax,%ecx
80100c25:	89 c8                	mov    %ecx,%eax
80100c27:	83 f8 7f             	cmp    $0x7f,%eax
80100c2a:	0f 87 a9 01 00 00    	ja     80100dd9 <consoleintr+0x5f9>
    	  if(arrows_counter > 0 && c != '\n' && c != C('D') && input.e != input.r+INPUT_BUF) {
80100c30:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100c35:	85 c0                	test   %eax,%eax
80100c37:	0f 84 0a 01 00 00    	je     80100d47 <consoleintr+0x567>
80100c3d:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100c41:	0f 84 00 01 00 00    	je     80100d47 <consoleintr+0x567>
80100c47:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100c4b:	0f 84 f6 00 00 00    	je     80100d47 <consoleintr+0x567>
80100c51:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100c56:	8b 15 14 ee 10 80    	mov    0x8010ee14,%edx
80100c5c:	83 ea 80             	sub    $0xffffff80,%edx
80100c5f:	39 d0                	cmp    %edx,%eax
80100c61:	0f 84 e0 00 00 00    	je     80100d47 <consoleintr+0x567>
    		  e_pos = input.e;
80100c67:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100c6c:	a3 7c c0 10 80       	mov    %eax,0x8010c07c
    	  	  //shift characters left
    	  	  for(i = 0; i < arrows_counter; ++i) {
80100c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100c78:	eb 2c                	jmp    80100ca6 <consoleintr+0x4c6>
    	  	    input.buf[input.e] = input.buf[input.e-1];
80100c7a:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100c7f:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100c85:	83 ea 01             	sub    $0x1,%edx
80100c88:	0f b6 92 94 ed 10 80 	movzbl -0x7fef126c(%edx),%edx
80100c8f:	88 90 94 ed 10 80    	mov    %dl,-0x7fef126c(%eax)
    	  	    --input.e;
80100c95:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100c9a:	83 e8 01             	sub    $0x1,%eax
80100c9d:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
    	  if(arrows_counter > 0 && c != '\n' && c != C('D') && input.e != input.r+INPUT_BUF) {
    		  e_pos = input.e;
    	  	  //shift characters left
    	  	  for(i = 0; i < arrows_counter; ++i) {
80100ca2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ca9:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100cae:	39 c2                	cmp    %eax,%edx
80100cb0:	72 c8                	jb     80100c7a <consoleintr+0x49a>
    	  	    input.buf[input.e] = input.buf[input.e-1];
    	  	    --input.e;
    	  	  }

    	  	  input.buf[input.e % INPUT_BUF] = c;
80100cb2:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100cb7:	89 c2                	mov    %eax,%edx
80100cb9:	83 e2 7f             	and    $0x7f,%edx
80100cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cbf:	88 82 94 ed 10 80    	mov    %al,-0x7fef126c(%edx)
    	  	  consputc(c);
80100cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cc8:	89 04 24             	mov    %eax,(%esp)
80100ccb:	e8 b3 fa ff ff       	call   80100783 <consputc>

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100cd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100cd7:	eb 24                	jmp    80100cfd <consoleintr+0x51d>
    	  		  consputc(input.buf[input.e+i+1]);
80100cd9:	8b 15 1c ee 10 80    	mov    0x8010ee1c,%edx
80100cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ce2:	01 d0                	add    %edx,%eax
80100ce4:	83 c0 01             	add    $0x1,%eax
80100ce7:	0f b6 80 94 ed 10 80 	movzbl -0x7fef126c(%eax),%eax
80100cee:	0f be c0             	movsbl %al,%eax
80100cf1:	89 04 24             	mov    %eax,(%esp)
80100cf4:	e8 8a fa ff ff       	call   80100783 <consputc>
    	  	  }

    	  	  input.buf[input.e % INPUT_BUF] = c;
    	  	  consputc(c);

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100cf9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100cfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d00:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100d05:	39 c2                	cmp    %eax,%edx
80100d07:	72 d0                	jb     80100cd9 <consoleintr+0x4f9>
    	  		  consputc(input.buf[input.e+i+1]);
    	  	  }

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100d09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d10:	eb 10                	jmp    80100d22 <consoleintr+0x542>
    	  		  cgaputc(KEY_LF);
80100d12:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100d19:	e8 af f8 ff ff       	call   801005cd <cgaputc>

    	  	  for(i = 0; i < arrows_counter; ++i) {
    	  		  consputc(input.buf[input.e+i+1]);
    	  	  }

    	  	  for(i = 0; i < arrows_counter; ++i) {
80100d1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d25:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100d2a:	39 c2                	cmp    %eax,%edx
80100d2c:	72 e4                	jb     80100d12 <consoleintr+0x532>
    	  		  cgaputc(KEY_LF);
    	  	  }

    	  	  e_pos++;
80100d2e:	a1 7c c0 10 80       	mov    0x8010c07c,%eax
80100d33:	83 c0 01             	add    $0x1,%eax
80100d36:	a3 7c c0 10 80       	mov    %eax,0x8010c07c
    	  	  input.e = e_pos;
80100d3b:	a1 7c c0 10 80       	mov    0x8010c07c,%eax
80100d40:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
80100d45:	eb 1b                	jmp    80100d62 <consoleintr+0x582>
    	  	}
    	  	else {
    	  	  input.buf[input.e++ % INPUT_BUF] = c;
80100d47:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100d4c:	89 c1                	mov    %eax,%ecx
80100d4e:	83 e1 7f             	and    $0x7f,%ecx
80100d51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100d54:	88 91 94 ed 10 80    	mov    %dl,-0x7fef126c(%ecx)
80100d5a:	83 c0 01             	add    $0x1,%eax
80100d5d:	a3 1c ee 10 80       	mov    %eax,0x8010ee1c
    	  	}

    	  	if(arrows_counter == 0 && c != '\n' && c != C('D'))
80100d62:	a1 78 c0 10 80       	mov    0x8010c078,%eax
80100d67:	85 c0                	test   %eax,%eax
80100d69:	75 17                	jne    80100d82 <consoleintr+0x5a2>
80100d6b:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d6f:	74 11                	je     80100d82 <consoleintr+0x5a2>
80100d71:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d75:	74 0b                	je     80100d82 <consoleintr+0x5a2>
    	  	  consputc(c);
80100d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d7a:	89 04 24             	mov    %eax,(%esp)
80100d7d:	e8 01 fa ff ff       	call   80100783 <consputc>

    	    if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF) {
80100d82:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d86:	74 18                	je     80100da0 <consoleintr+0x5c0>
80100d88:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d8c:	74 12                	je     80100da0 <consoleintr+0x5c0>
80100d8e:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100d93:	8b 15 14 ee 10 80    	mov    0x8010ee14,%edx
80100d99:	83 ea 80             	sub    $0xffffff80,%edx
80100d9c:	39 d0                	cmp    %edx,%eax
80100d9e:	75 39                	jne    80100dd9 <consoleintr+0x5f9>
    	    	input.w = input.e;
80100da0:	a1 1c ee 10 80       	mov    0x8010ee1c,%eax
80100da5:	a3 18 ee 10 80       	mov    %eax,0x8010ee18
    	    	arrows_counter = 0;
80100daa:	c7 05 78 c0 10 80 00 	movl   $0x0,0x8010c078
80100db1:	00 00 00 
    	    	wakeup(&input.r);
80100db4:	c7 04 24 14 ee 10 80 	movl   $0x8010ee14,(%esp)
80100dbb:	e8 02 43 00 00       	call   801050c2 <wakeup>
    	    	consputc(c);
80100dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100dc3:	89 04 24             	mov    %eax,(%esp)
80100dc6:	e8 b8 f9 ff ff       	call   80100783 <consputc>
    	    }
      }
      break;
80100dcb:	eb 0c                	jmp    80100dd9 <consoleintr+0x5f9>
    case C('U'):  // Kill line.
      while(input.e != input.w && input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100dcd:	90                   	nop
80100dce:	eb 0a                	jmp    80100dda <consoleintr+0x5fa>
        	consputc(input.buf[input.e - arrows_counter +i ]);

        for(i = 0; i <= arrows_counter; ++i)
        	cgaputc(KEY_LF);
      }
      break;
80100dd0:	90                   	nop
80100dd1:	eb 07                	jmp    80100dda <consoleintr+0x5fa>
    case KEY_LF:
      if(arrows_counter < input.e - input.r) {
    	  arrows_counter++;
    	  consputc(c);
      }
      break;
80100dd3:	90                   	nop
80100dd4:	eb 04                	jmp    80100dda <consoleintr+0x5fa>
    case KEY_RT:
    	if(arrows_counter > 0) {
    		arrows_counter--;
    		consputc(c);
    	}
    	break;
80100dd6:	90                   	nop
80100dd7:	eb 01                	jmp    80100dda <consoleintr+0x5fa>
    	    	arrows_counter = 0;
    	    	wakeup(&input.r);
    	    	consputc(c);
    	    }
      }
      break;
80100dd9:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c,i;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100dda:	8b 45 08             	mov    0x8(%ebp),%eax
80100ddd:	ff d0                	call   *%eax
80100ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100de2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100de6:	0f 89 0b fa ff ff    	jns    801007f7 <consoleintr+0x17>
    	    }
      }
      break;
    }
  }
  release(&input.lock);
80100dec:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
80100df3:	e8 31 45 00 00       	call   80105329 <release>
}
80100df8:	c9                   	leave  
80100df9:	c3                   	ret    

80100dfa <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100dfa:	55                   	push   %ebp
80100dfb:	89 e5                	mov    %esp,%ebp
80100dfd:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c,i;

  iunlock(ip);
80100e00:	8b 45 08             	mov    0x8(%ebp),%eax
80100e03:	89 04 24             	mov    %eax,(%esp)
80100e06:	e8 cf 12 00 00       	call   801020da <iunlock>
  target = n;
80100e0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  acquire(&input.lock);
80100e11:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
80100e18:	e8 aa 44 00 00       	call   801052c7 <acquire>
  while(n > 0){
80100e1d:	e9 95 01 00 00       	jmp    80100fb7 <consoleread+0x1bd>
	  while(input.r == input.w){
		  if(proc->killed){
80100e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e28:	8b 40 24             	mov    0x24(%eax),%eax
80100e2b:	85 c0                	test   %eax,%eax
80100e2d:	74 21                	je     80100e50 <consoleread+0x56>
			release(&input.lock);
80100e2f:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
80100e36:	e8 ee 44 00 00       	call   80105329 <release>
			ilock(ip);
80100e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e3e:	89 04 24             	mov    %eax,(%esp)
80100e41:	e8 46 11 00 00       	call   80101f8c <ilock>
			return -1;
80100e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e4b:	e9 97 01 00 00       	jmp    80100fe7 <consoleread+0x1ed>
		  }
		  sleep(&input.r, &input.lock);
80100e50:	c7 44 24 04 60 ed 10 	movl   $0x8010ed60,0x4(%esp)
80100e57:	80 
80100e58:	c7 04 24 14 ee 10 80 	movl   $0x8010ee14,(%esp)
80100e5f:	e8 85 41 00 00       	call   80104fe9 <sleep>
80100e64:	eb 01                	jmp    80100e67 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
	  while(input.r == input.w){
80100e66:	90                   	nop
80100e67:	8b 15 14 ee 10 80    	mov    0x8010ee14,%edx
80100e6d:	a1 18 ee 10 80       	mov    0x8010ee18,%eax
80100e72:	39 c2                	cmp    %eax,%edx
80100e74:	74 ac                	je     80100e22 <consoleread+0x28>
			ilock(ip);
			return -1;
		  }
		  sleep(&input.r, &input.lock);
	  }
	  c = input.buf[input.r++ % INPUT_BUF];
80100e76:	a1 14 ee 10 80       	mov    0x8010ee14,%eax
80100e7b:	89 c2                	mov    %eax,%edx
80100e7d:	83 e2 7f             	and    $0x7f,%edx
80100e80:	0f b6 92 94 ed 10 80 	movzbl -0x7fef126c(%edx),%edx
80100e87:	0f be d2             	movsbl %dl,%edx
80100e8a:	89 55 ec             	mov    %edx,-0x14(%ebp)
80100e8d:	83 c0 01             	add    $0x1,%eax
80100e90:	a3 14 ee 10 80       	mov    %eax,0x8010ee14
	  if(c == C('D')){  // EOF
80100e95:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100e99:	75 1e                	jne    80100eb9 <consoleread+0xbf>
		  if(n < target){
80100e9b:	8b 45 10             	mov    0x10(%ebp),%eax
80100e9e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100ea1:	0f 83 1c 01 00 00    	jae    80100fc3 <consoleread+0x1c9>
			  // Save ^D for next time, to make sure
			  // caller gets a 0-byte result.
			  input.r--;
80100ea7:	a1 14 ee 10 80       	mov    0x8010ee14,%eax
80100eac:	83 e8 01             	sub    $0x1,%eax
80100eaf:	a3 14 ee 10 80       	mov    %eax,0x8010ee14
		  }
		  break;
80100eb4:	e9 0a 01 00 00       	jmp    80100fc3 <consoleread+0x1c9>
	  }
	  history.buf[history.c_buf++] = c;
80100eb9:	a1 ac b5 10 80       	mov    0x8010b5ac,%eax
80100ebe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100ec1:	88 90 b0 b5 10 80    	mov    %dl,-0x7fef4a50(%eax)
80100ec7:	83 c0 01             	add    $0x1,%eax
80100eca:	a3 ac b5 10 80       	mov    %eax,0x8010b5ac
	  *dst++ = c;
80100ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ed2:	89 c2                	mov    %eax,%edx
80100ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed7:	88 10                	mov    %dl,(%eax)
80100ed9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	  n--;
80100edd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
	  if(c == '\n') {
80100ee1:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ee5:	0f 85 cc 00 00 00    	jne    80100fb7 <consoleread+0x1bd>
		  if (1 != history.c_buf) {
80100eeb:	a1 ac b5 10 80       	mov    0x8010b5ac,%eax
80100ef0:	83 f8 01             	cmp    $0x1,%eax
80100ef3:	0f 84 ab 00 00 00    	je     80100fa4 <consoleread+0x1aa>
			  // save history_buf in history_commands
			  for(i = 0; i < history.c_buf-1; i++)
80100ef9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100f00:	eb 23                	jmp    80100f25 <consoleread+0x12b>
				  history.commands[history.entry_point][i] = history.buf[i];
80100f02:	8b 15 a0 b5 10 80    	mov    0x8010b5a0,%edx
80100f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f0b:	05 b0 b5 10 80       	add    $0x8010b5b0,%eax
80100f10:	0f b6 00             	movzbl (%eax),%eax
80100f13:	c1 e2 07             	shl    $0x7,%edx
80100f16:	03 55 f4             	add    -0xc(%ebp),%edx
80100f19:	81 c2 30 b6 10 80    	add    $0x8010b630,%edx
80100f1f:	88 02                	mov    %al,(%edx)
	  *dst++ = c;
	  n--;
	  if(c == '\n') {
		  if (1 != history.c_buf) {
			  // save history_buf in history_commands
			  for(i = 0; i < history.c_buf-1; i++)
80100f21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f25:	a1 ac b5 10 80       	mov    0x8010b5ac,%eax
80100f2a:	83 e8 01             	sub    $0x1,%eax
80100f2d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100f30:	7f d0                	jg     80100f02 <consoleread+0x108>
				  history.commands[history.entry_point][i] = history.buf[i];

			  history.commands[history.entry_point][i] = '\0';
80100f32:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100f37:	c1 e0 07             	shl    $0x7,%eax
80100f3a:	03 45 f4             	add    -0xc(%ebp),%eax
80100f3d:	05 30 b6 10 80       	add    $0x8010b630,%eax
80100f42:	c6 00 00             	movb   $0x0,(%eax)
			  history.iter = history.entry_point;
80100f45:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100f4a:	a3 a8 b5 10 80       	mov    %eax,0x8010b5a8
			  history.entry_point++;
80100f4f:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100f54:	83 c0 01             	add    $0x1,%eax
80100f57:	a3 a0 b5 10 80       	mov    %eax,0x8010b5a0
			  history.entry_point %= MAX_HISTORY_LENGTH;  // FIFO 18 19 0 1 2..
80100f5c:	8b 0d a0 b5 10 80    	mov    0x8010b5a0,%ecx
80100f62:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100f67:	89 c8                	mov    %ecx,%eax
80100f69:	f7 ea                	imul   %edx
80100f6b:	c1 fa 03             	sar    $0x3,%edx
80100f6e:	89 c8                	mov    %ecx,%eax
80100f70:	c1 f8 1f             	sar    $0x1f,%eax
80100f73:	29 c2                	sub    %eax,%edx
80100f75:	89 d0                	mov    %edx,%eax
80100f77:	c1 e0 02             	shl    $0x2,%eax
80100f7a:	01 d0                	add    %edx,%eax
80100f7c:	c1 e0 02             	shl    $0x2,%eax
80100f7f:	89 ca                	mov    %ecx,%edx
80100f81:	29 c2                	sub    %eax,%edx
80100f83:	89 15 a0 b5 10 80    	mov    %edx,0x8010b5a0

			  // updates number of current entries (when maxed out - will not change)
			  history.num_of_curr_entries = (history.num_of_curr_entries < MAX_HISTORY_LENGTH-1) ? history.entry_point : MAX_HISTORY_LENGTH;
80100f89:	a1 a4 b5 10 80       	mov    0x8010b5a4,%eax
80100f8e:	83 f8 12             	cmp    $0x12,%eax
80100f91:	7f 07                	jg     80100f9a <consoleread+0x1a0>
80100f93:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100f98:	eb 05                	jmp    80100f9f <consoleread+0x1a5>
80100f9a:	b8 14 00 00 00       	mov    $0x14,%eax
80100f9f:	a3 a4 b5 10 80       	mov    %eax,0x8010b5a4
		  }
		  history.c_buf = 0;
80100fa4:	c7 05 ac b5 10 80 00 	movl   $0x0,0x8010b5ac
80100fab:	00 00 00 
		  history.buf[0] = '\0';
80100fae:	c6 05 b0 b5 10 80 00 	movb   $0x0,0x8010b5b0
		  break;
80100fb5:	eb 0d                	jmp    80100fc4 <consoleread+0x1ca>
  int c,i;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100fb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100fbb:	0f 8f a5 fe ff ff    	jg     80100e66 <consoleread+0x6c>
80100fc1:	eb 01                	jmp    80100fc4 <consoleread+0x1ca>
		  if(n < target){
			  // Save ^D for next time, to make sure
			  // caller gets a 0-byte result.
			  input.r--;
		  }
		  break;
80100fc3:	90                   	nop
		  history.c_buf = 0;
		  history.buf[0] = '\0';
		  break;
	  }
  }
  release(&input.lock);
80100fc4:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
80100fcb:	e8 59 43 00 00       	call   80105329 <release>
  ilock(ip);
80100fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd3:	89 04 24             	mov    %eax,(%esp)
80100fd6:	e8 b1 0f 00 00       	call   80101f8c <ilock>

  return target - n;
80100fdb:	8b 45 10             	mov    0x10(%ebp),%eax
80100fde:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100fe1:	89 d1                	mov    %edx,%ecx
80100fe3:	29 c1                	sub    %eax,%ecx
80100fe5:	89 c8                	mov    %ecx,%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100fef:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff2:	89 04 24             	mov    %eax,(%esp)
80100ff5:	e8 e0 10 00 00       	call   801020da <iunlock>
  acquire(&cons.lock);
80100ffa:	c7 04 24 40 c0 10 80 	movl   $0x8010c040,(%esp)
80101001:	e8 c1 42 00 00       	call   801052c7 <acquire>
  for(i = 0; i < n; i++)
80101006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010100d:	eb 1d                	jmp    8010102c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
8010100f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101012:	03 45 0c             	add    0xc(%ebp),%eax
80101015:	0f b6 00             	movzbl (%eax),%eax
80101018:	0f be c0             	movsbl %al,%eax
8010101b:	25 ff 00 00 00       	and    $0xff,%eax
80101020:	89 04 24             	mov    %eax,(%esp)
80101023:	e8 5b f7 ff ff       	call   80100783 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80101028:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010102c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101032:	7c db                	jl     8010100f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80101034:	c7 04 24 40 c0 10 80 	movl   $0x8010c040,(%esp)
8010103b:	e8 e9 42 00 00       	call   80105329 <release>
  ilock(ip);
80101040:	8b 45 08             	mov    0x8(%ebp),%eax
80101043:	89 04 24             	mov    %eax,(%esp)
80101046:	e8 41 0f 00 00       	call   80101f8c <ilock>

  return n;
8010104b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010104e:	c9                   	leave  
8010104f:	c3                   	ret    

80101050 <consoleinit>:

void
consoleinit(void)
{
80101050:	55                   	push   %ebp
80101051:	89 e5                	mov    %esp,%ebp
80101053:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80101056:	c7 44 24 04 3f 89 10 	movl   $0x8010893f,0x4(%esp)
8010105d:	80 
8010105e:	c7 04 24 40 c0 10 80 	movl   $0x8010c040,(%esp)
80101065:	e8 3c 42 00 00       	call   801052a6 <initlock>
  initlock(&input.lock, "input");
8010106a:	c7 44 24 04 47 89 10 	movl   $0x80108947,0x4(%esp)
80101071:	80 
80101072:	c7 04 24 60 ed 10 80 	movl   $0x8010ed60,(%esp)
80101079:	e8 28 42 00 00       	call   801052a6 <initlock>

  devsw[CONSOLE].write = consolewrite;
8010107e:	c7 05 cc f7 10 80 e9 	movl   $0x80100fe9,0x8010f7cc
80101085:	0f 10 80 
  devsw[CONSOLE].read = consoleread;
80101088:	c7 05 c8 f7 10 80 fa 	movl   $0x80100dfa,0x8010f7c8
8010108f:	0d 10 80 
  cons.locking = 1;
80101092:	c7 05 74 c0 10 80 01 	movl   $0x1,0x8010c074
80101099:	00 00 00 

  picenable(IRQ_KBD);
8010109c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801010a3:	e8 3d 31 00 00       	call   801041e5 <picenable>
  ioapicenable(IRQ_KBD, 0);
801010a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801010af:	00 
801010b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801010b7:	e8 de 1f 00 00       	call   8010309a <ioapicenable>
}
801010bc:	c9                   	leave  
801010bd:	c3                   	ret    
	...

801010c0 <exec>:
//static struct PATH* ev_path;


int
exec(char *path, char **argv)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	81 ec b8 01 00 00    	sub    $0x1b8,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  stop = 0;
801010c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
/*  if (first_visit == 1) {
	  ev_path->path_counter = 0 ;
	  first_visit = 0 ;
  }*/
  if((ip = namei(path)) == 0) {
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	89 04 24             	mov    %eax,(%esp)
801010d6:	e8 53 1a 00 00       	call   80102b2e <namei>
801010db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801010de:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010e2:	0f 85 9e 00 00 00    	jne    80101186 <exec+0xc6>
	  // assignment 1 - 1.1 - search in PATH if didn't found in working dir
	  for (i = 0 ; i < path_counter && !stop ; ++i) {
801010e8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801010ef:	eb 71                	jmp    80101162 <exec+0xa2>
	  	strcpy(full_path_cmd, search_paths[i]);
801010f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801010f4:	89 d0                	mov    %edx,%eax
801010f6:	c1 e0 07             	shl    $0x7,%eax
801010f9:	01 d0                	add    %edx,%eax
801010fb:	05 a0 c0 10 80       	add    $0x8010c0a0,%eax
80101100:	89 44 24 04          	mov    %eax,0x4(%esp)
80101104:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
8010110a:	89 04 24             	mov    %eax,(%esp)
8010110d:	e8 50 04 00 00       	call   80101562 <strcpy>
	  	strcpy(full_path_cmd+strlen(search_paths[i]), path);
80101112:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101115:	89 d0                	mov    %edx,%eax
80101117:	c1 e0 07             	shl    $0x7,%eax
8010111a:	01 d0                	add    %edx,%eax
8010111c:	05 a0 c0 10 80       	add    $0x8010c0a0,%eax
80101121:	89 04 24             	mov    %eax,(%esp)
80101124:	e8 6b 46 00 00       	call   80105794 <strlen>
80101129:	8d 95 4c ff ff ff    	lea    -0xb4(%ebp),%edx
8010112f:	01 c2                	add    %eax,%edx
80101131:	8b 45 08             	mov    0x8(%ebp),%eax
80101134:	89 44 24 04          	mov    %eax,0x4(%esp)
80101138:	89 14 24             	mov    %edx,(%esp)
8010113b:	e8 22 04 00 00       	call   80101562 <strcpy>
	  	if((ip = namei(full_path_cmd)) != 0) {
80101140:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 e0 19 00 00       	call   80102b2e <namei>
8010114e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101151:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101155:	74 07                	je     8010115e <exec+0x9e>
	  		stop = 1;
80101157:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
	  ev_path->path_counter = 0 ;
	  first_visit = 0 ;
  }*/
  if((ip = namei(path)) == 0) {
	  // assignment 1 - 1.1 - search in PATH if didn't found in working dir
	  for (i = 0 ; i < path_counter && !stop ; ++i) {
8010115e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80101162:	a1 80 c0 10 80       	mov    0x8010c080,%eax
80101167:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010116a:	7d 0a                	jge    80101176 <exec+0xb6>
8010116c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80101170:	0f 84 7b ff ff ff    	je     801010f1 <exec+0x31>
	  	strcpy(full_path_cmd+strlen(search_paths[i]), path);
	  	if((ip = namei(full_path_cmd)) != 0) {
	  		stop = 1;
	  	}
	  }
	  if (!stop)
80101176:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010117a:	75 0a                	jne    80101186 <exec+0xc6>
		  return -1;
8010117c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101181:	e9 da 03 00 00       	jmp    80101560 <exec+0x4a0>
  }


  ilock(ip);
80101186:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101189:	89 04 24             	mov    %eax,(%esp)
8010118c:	e8 fb 0d 00 00       	call   80101f8c <ilock>
  pgdir = 0;
80101191:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80101198:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
8010119f:	00 
801011a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801011a7:	00 
801011a8:	8d 85 88 fe ff ff    	lea    -0x178(%ebp),%eax
801011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801011b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011b5:	89 04 24             	mov    %eax,(%esp)
801011b8:	e8 c5 12 00 00       	call   80102482 <readi>
801011bd:	83 f8 33             	cmp    $0x33,%eax
801011c0:	0f 86 54 03 00 00    	jbe    8010151a <exec+0x45a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
801011c6:	8b 85 88 fe ff ff    	mov    -0x178(%ebp),%eax
801011cc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
801011d1:	0f 85 46 03 00 00    	jne    8010151d <exec+0x45d>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
801011d7:	c7 04 24 23 32 10 80 	movl   $0x80103223,(%esp)
801011de:	e8 ba 6e 00 00       	call   8010809d <setupkvm>
801011e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
801011e6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
801011ea:	0f 84 30 03 00 00    	je     80101520 <exec+0x460>
    goto bad;

  // Load program into memory.
  sz = 0;
801011f0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801011f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801011fe:	8b 85 a4 fe ff ff    	mov    -0x15c(%ebp),%eax
80101204:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101207:	e9 c5 00 00 00       	jmp    801012d1 <exec+0x211>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
8010120c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010120f:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80101216:	00 
80101217:	89 44 24 08          	mov    %eax,0x8(%esp)
8010121b:	8d 85 68 fe ff ff    	lea    -0x198(%ebp),%eax
80101221:	89 44 24 04          	mov    %eax,0x4(%esp)
80101225:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101228:	89 04 24             	mov    %eax,(%esp)
8010122b:	e8 52 12 00 00       	call   80102482 <readi>
80101230:	83 f8 20             	cmp    $0x20,%eax
80101233:	0f 85 ea 02 00 00    	jne    80101523 <exec+0x463>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80101239:	8b 85 68 fe ff ff    	mov    -0x198(%ebp),%eax
8010123f:	83 f8 01             	cmp    $0x1,%eax
80101242:	75 7f                	jne    801012c3 <exec+0x203>
      continue;
    if(ph.memsz < ph.filesz)
80101244:	8b 95 7c fe ff ff    	mov    -0x184(%ebp),%edx
8010124a:	8b 85 78 fe ff ff    	mov    -0x188(%ebp),%eax
80101250:	39 c2                	cmp    %eax,%edx
80101252:	0f 82 ce 02 00 00    	jb     80101526 <exec+0x466>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80101258:	8b 95 70 fe ff ff    	mov    -0x190(%ebp),%edx
8010125e:	8b 85 7c fe ff ff    	mov    -0x184(%ebp),%eax
80101264:	01 d0                	add    %edx,%eax
80101266:	89 44 24 08          	mov    %eax,0x8(%esp)
8010126a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010126d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101271:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101274:	89 04 24             	mov    %eax,(%esp)
80101277:	e8 f3 71 00 00       	call   8010846f <allocuvm>
8010127c:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010127f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80101283:	0f 84 a0 02 00 00    	je     80101529 <exec+0x469>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80101289:	8b 8d 78 fe ff ff    	mov    -0x188(%ebp),%ecx
8010128f:	8b 95 6c fe ff ff    	mov    -0x194(%ebp),%edx
80101295:	8b 85 70 fe ff ff    	mov    -0x190(%ebp),%eax
8010129b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010129f:	89 54 24 0c          	mov    %edx,0xc(%esp)
801012a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801012a6:	89 54 24 08          	mov    %edx,0x8(%esp)
801012aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801012ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
801012b1:	89 04 24             	mov    %eax,(%esp)
801012b4:	e8 c7 70 00 00       	call   80108380 <loaduvm>
801012b9:	85 c0                	test   %eax,%eax
801012bb:	0f 88 6b 02 00 00    	js     8010152c <exec+0x46c>
801012c1:	eb 01                	jmp    801012c4 <exec+0x204>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
801012c3:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801012c4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801012c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012cb:	83 c0 20             	add    $0x20,%eax
801012ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012d1:	0f b7 85 b4 fe ff ff 	movzwl -0x14c(%ebp),%eax
801012d8:	0f b7 c0             	movzwl %ax,%eax
801012db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012de:	0f 8f 28 ff ff ff    	jg     8010120c <exec+0x14c>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
801012e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801012e7:	89 04 24             	mov    %eax,(%esp)
801012ea:	e8 21 0f 00 00       	call   80102210 <iunlockput>
  ip = 0;
801012ef:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
801012f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012f9:	05 ff 0f 00 00       	add    $0xfff,%eax
801012fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101303:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80101306:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101309:	05 00 20 00 00       	add    $0x2000,%eax
8010130e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101312:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101315:	89 44 24 04          	mov    %eax,0x4(%esp)
80101319:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010131c:	89 04 24             	mov    %eax,(%esp)
8010131f:	e8 4b 71 00 00       	call   8010846f <allocuvm>
80101324:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101327:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010132b:	0f 84 fe 01 00 00    	je     8010152f <exec+0x46f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101331:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101334:	2d 00 20 00 00       	sub    $0x2000,%eax
80101339:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101340:	89 04 24             	mov    %eax,(%esp)
80101343:	e8 4b 73 00 00       	call   80108693 <clearpteu>
  sp = sz;
80101348:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010134b:	89 45 d8             	mov    %eax,-0x28(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010134e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80101355:	e9 81 00 00 00       	jmp    801013db <exec+0x31b>
    if(argc >= MAXARG)
8010135a:	83 7d e0 1f          	cmpl   $0x1f,-0x20(%ebp)
8010135e:	0f 87 ce 01 00 00    	ja     80101532 <exec+0x472>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101364:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101367:	c1 e0 02             	shl    $0x2,%eax
8010136a:	03 45 0c             	add    0xc(%ebp),%eax
8010136d:	8b 00                	mov    (%eax),%eax
8010136f:	89 04 24             	mov    %eax,(%esp)
80101372:	e8 1d 44 00 00       	call   80105794 <strlen>
80101377:	f7 d0                	not    %eax
80101379:	03 45 d8             	add    -0x28(%ebp),%eax
8010137c:	83 e0 fc             	and    $0xfffffffc,%eax
8010137f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101382:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101385:	c1 e0 02             	shl    $0x2,%eax
80101388:	03 45 0c             	add    0xc(%ebp),%eax
8010138b:	8b 00                	mov    (%eax),%eax
8010138d:	89 04 24             	mov    %eax,(%esp)
80101390:	e8 ff 43 00 00       	call   80105794 <strlen>
80101395:	83 c0 01             	add    $0x1,%eax
80101398:	89 c2                	mov    %eax,%edx
8010139a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010139d:	c1 e0 02             	shl    $0x2,%eax
801013a0:	03 45 0c             	add    0xc(%ebp),%eax
801013a3:	8b 00                	mov    (%eax),%eax
801013a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801013a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801013ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801013b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801013b7:	89 04 24             	mov    %eax,(%esp)
801013ba:	e8 88 74 00 00       	call   80108847 <copyout>
801013bf:	85 c0                	test   %eax,%eax
801013c1:	0f 88 6e 01 00 00    	js     80101535 <exec+0x475>
      goto bad;
    ustack[3+argc] = sp;
801013c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013ca:	8d 50 03             	lea    0x3(%eax),%edx
801013cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013d0:	89 84 95 bc fe ff ff 	mov    %eax,-0x144(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801013d7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801013db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013de:	c1 e0 02             	shl    $0x2,%eax
801013e1:	03 45 0c             	add    0xc(%ebp),%eax
801013e4:	8b 00                	mov    (%eax),%eax
801013e6:	85 c0                	test   %eax,%eax
801013e8:	0f 85 6c ff ff ff    	jne    8010135a <exec+0x29a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801013ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013f1:	83 c0 03             	add    $0x3,%eax
801013f4:	c7 84 85 bc fe ff ff 	movl   $0x0,-0x144(%ebp,%eax,4)
801013fb:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801013ff:	c7 85 bc fe ff ff ff 	movl   $0xffffffff,-0x144(%ebp)
80101406:	ff ff ff 
  ustack[1] = argc;
80101409:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010140c:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101412:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101415:	83 c0 01             	add    $0x1,%eax
80101418:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010141f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101422:	29 d0                	sub    %edx,%eax
80101424:	89 85 c4 fe ff ff    	mov    %eax,-0x13c(%ebp)

  sp -= (3+argc+1) * 4;
8010142a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010142d:	83 c0 04             	add    $0x4,%eax
80101430:	c1 e0 02             	shl    $0x2,%eax
80101433:	29 45 d8             	sub    %eax,-0x28(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101436:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101439:	83 c0 04             	add    $0x4,%eax
8010143c:	c1 e0 02             	shl    $0x2,%eax
8010143f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101443:	8d 85 bc fe ff ff    	lea    -0x144(%ebp),%eax
80101449:	89 44 24 08          	mov    %eax,0x8(%esp)
8010144d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101450:	89 44 24 04          	mov    %eax,0x4(%esp)
80101454:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101457:	89 04 24             	mov    %eax,(%esp)
8010145a:	e8 e8 73 00 00       	call   80108847 <copyout>
8010145f:	85 c0                	test   %eax,%eax
80101461:	0f 88 d1 00 00 00    	js     80101538 <exec+0x478>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101467:	8b 45 08             	mov    0x8(%ebp),%eax
8010146a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010146d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101470:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101473:	eb 17                	jmp    8010148c <exec+0x3cc>
    if(*s == '/')
80101475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101478:	0f b6 00             	movzbl (%eax),%eax
8010147b:	3c 2f                	cmp    $0x2f,%al
8010147d:	75 09                	jne    80101488 <exec+0x3c8>
      last = s+1;
8010147f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101482:	83 c0 01             	add    $0x1,%eax
80101485:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101488:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148f:	0f b6 00             	movzbl (%eax),%eax
80101492:	84 c0                	test   %al,%al
80101494:	75 df                	jne    80101475 <exec+0x3b5>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101496:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010149c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010149f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801014a6:	00 
801014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ae:	89 14 24             	mov    %edx,(%esp)
801014b1:	e8 90 42 00 00       	call   80105746 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801014b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014bc:	8b 40 04             	mov    0x4(%eax),%eax
801014bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
801014c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014c8:	8b 55 d0             	mov    -0x30(%ebp),%edx
801014cb:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801014ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801014d7:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801014d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014df:	8b 40 18             	mov    0x18(%eax),%eax
801014e2:	8b 95 a0 fe ff ff    	mov    -0x160(%ebp),%edx
801014e8:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801014eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801014f1:	8b 40 18             	mov    0x18(%eax),%eax
801014f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
801014f7:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801014fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101500:	89 04 24             	mov    %eax,(%esp)
80101503:	e8 86 6c 00 00       	call   8010818e <switchuvm>
  freevm(oldpgdir);
80101508:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010150b:	89 04 24             	mov    %eax,(%esp)
8010150e:	e8 f2 70 00 00       	call   80108605 <freevm>
  return 0;
80101513:	b8 00 00 00 00       	mov    $0x0,%eax
80101518:	eb 46                	jmp    80101560 <exec+0x4a0>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010151a:	90                   	nop
8010151b:	eb 1c                	jmp    80101539 <exec+0x479>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010151d:	90                   	nop
8010151e:	eb 19                	jmp    80101539 <exec+0x479>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101520:	90                   	nop
80101521:	eb 16                	jmp    80101539 <exec+0x479>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101523:	90                   	nop
80101524:	eb 13                	jmp    80101539 <exec+0x479>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101526:	90                   	nop
80101527:	eb 10                	jmp    80101539 <exec+0x479>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101529:	90                   	nop
8010152a:	eb 0d                	jmp    80101539 <exec+0x479>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010152c:	90                   	nop
8010152d:	eb 0a                	jmp    80101539 <exec+0x479>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010152f:	90                   	nop
80101530:	eb 07                	jmp    80101539 <exec+0x479>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101532:	90                   	nop
80101533:	eb 04                	jmp    80101539 <exec+0x479>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101535:	90                   	nop
80101536:	eb 01                	jmp    80101539 <exec+0x479>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101538:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101539:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
8010153d:	74 0b                	je     8010154a <exec+0x48a>
    freevm(pgdir);
8010153f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 bb 70 00 00       	call   80108605 <freevm>
  if(ip)
8010154a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010154e:	74 0b                	je     8010155b <exec+0x49b>
    iunlockput(ip);
80101550:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101553:	89 04 24             	mov    %eax,(%esp)
80101556:	e8 b5 0c 00 00       	call   80102210 <iunlockput>
  return -1;
8010155b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101560:	c9                   	leave  
80101561:	c3                   	ret    

80101562 <strcpy>:

char*
strcpy(char *s, char *t)
{
80101562:	55                   	push   %ebp
80101563:	89 e5                	mov    %esp,%ebp
80101565:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101568:	8b 45 08             	mov    0x8(%ebp),%eax
8010156b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010156e:	90                   	nop
8010156f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101572:	0f b6 10             	movzbl (%eax),%edx
80101575:	8b 45 08             	mov    0x8(%ebp),%eax
80101578:	88 10                	mov    %dl,(%eax)
8010157a:	8b 45 08             	mov    0x8(%ebp),%eax
8010157d:	0f b6 00             	movzbl (%eax),%eax
80101580:	84 c0                	test   %al,%al
80101582:	0f 95 c0             	setne  %al
80101585:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80101589:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010158d:	84 c0                	test   %al,%al
8010158f:	75 de                	jne    8010156f <strcpy+0xd>
    ;
  return os;
80101591:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80101594:	c9                   	leave  
80101595:	c3                   	ret    

80101596 <add_path>:

int add_path(char* path) {
80101596:	55                   	push   %ebp
80101597:	89 e5                	mov    %esp,%ebp
80101599:	83 ec 10             	sub    $0x10,%esp
	int next_char = 0;
8010159c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	if (path_counter > MAX_PATH_ENTRIES) {
801015a3:	a1 80 c0 10 80       	mov    0x8010c080,%eax
801015a8:	83 f8 0a             	cmp    $0xa,%eax
801015ab:	7e 2e                	jle    801015db <add_path+0x45>
		return path_counter;
801015ad:	a1 80 c0 10 80       	mov    0x8010c080,%eax
801015b2:	eb 6c                	jmp    80101620 <add_path+0x8a>
	}
	while(*path != 0 && *path != '\n' && *path != '\t' && *path != '\r' && *path != ' ') {
		search_paths[path_counter][next_char] = *path;
801015b4:	8b 15 80 c0 10 80    	mov    0x8010c080,%edx
801015ba:	8b 45 08             	mov    0x8(%ebp),%eax
801015bd:	0f b6 08             	movzbl (%eax),%ecx
801015c0:	89 d0                	mov    %edx,%eax
801015c2:	c1 e0 07             	shl    $0x7,%eax
801015c5:	01 d0                	add    %edx,%eax
801015c7:	03 45 fc             	add    -0x4(%ebp),%eax
801015ca:	05 a0 c0 10 80       	add    $0x8010c0a0,%eax
801015cf:	88 08                	mov    %cl,(%eax)
		next_char++;
801015d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		path++;
801015d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801015d9:	eb 01                	jmp    801015dc <add_path+0x46>
int add_path(char* path) {
	int next_char = 0;
	if (path_counter > MAX_PATH_ENTRIES) {
		return path_counter;
	}
	while(*path != 0 && *path != '\n' && *path != '\t' && *path != '\r' && *path != ' ') {
801015db:	90                   	nop
801015dc:	8b 45 08             	mov    0x8(%ebp),%eax
801015df:	0f b6 00             	movzbl (%eax),%eax
801015e2:	84 c0                	test   %al,%al
801015e4:	74 28                	je     8010160e <add_path+0x78>
801015e6:	8b 45 08             	mov    0x8(%ebp),%eax
801015e9:	0f b6 00             	movzbl (%eax),%eax
801015ec:	3c 0a                	cmp    $0xa,%al
801015ee:	74 1e                	je     8010160e <add_path+0x78>
801015f0:	8b 45 08             	mov    0x8(%ebp),%eax
801015f3:	0f b6 00             	movzbl (%eax),%eax
801015f6:	3c 09                	cmp    $0x9,%al
801015f8:	74 14                	je     8010160e <add_path+0x78>
801015fa:	8b 45 08             	mov    0x8(%ebp),%eax
801015fd:	0f b6 00             	movzbl (%eax),%eax
80101600:	3c 0d                	cmp    $0xd,%al
80101602:	74 0a                	je     8010160e <add_path+0x78>
80101604:	8b 45 08             	mov    0x8(%ebp),%eax
80101607:	0f b6 00             	movzbl (%eax),%eax
8010160a:	3c 20                	cmp    $0x20,%al
8010160c:	75 a6                	jne    801015b4 <add_path+0x1e>
		search_paths[path_counter][next_char] = *path;
		next_char++;
		path++;
	}
	path_counter++;
8010160e:	a1 80 c0 10 80       	mov    0x8010c080,%eax
80101613:	83 c0 01             	add    $0x1,%eax
80101616:	a3 80 c0 10 80       	mov    %eax,0x8010c080
	return 0;
8010161b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101620:	c9                   	leave  
80101621:	c3                   	ret    
	...

80101624 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101624:	55                   	push   %ebp
80101625:	89 e5                	mov    %esp,%ebp
80101627:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010162a:	c7 44 24 04 4d 89 10 	movl   $0x8010894d,0x4(%esp)
80101631:	80 
80101632:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
80101639:	e8 68 3c 00 00       	call   801052a6 <initlock>
}
8010163e:	c9                   	leave  
8010163f:	c3                   	ret    

80101640 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101646:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
8010164d:	e8 75 3c 00 00       	call   801052c7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101652:	c7 45 f4 54 ee 10 80 	movl   $0x8010ee54,-0xc(%ebp)
80101659:	eb 29                	jmp    80101684 <filealloc+0x44>
    if(f->ref == 0){
8010165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165e:	8b 40 04             	mov    0x4(%eax),%eax
80101661:	85 c0                	test   %eax,%eax
80101663:	75 1b                	jne    80101680 <filealloc+0x40>
      f->ref = 1;
80101665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101668:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010166f:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
80101676:	e8 ae 3c 00 00       	call   80105329 <release>
      return f;
8010167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167e:	eb 1e                	jmp    8010169e <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101680:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101684:	81 7d f4 b4 f7 10 80 	cmpl   $0x8010f7b4,-0xc(%ebp)
8010168b:	72 ce                	jb     8010165b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010168d:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
80101694:	e8 90 3c 00 00       	call   80105329 <release>
  return 0;
80101699:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010169e:	c9                   	leave  
8010169f:	c3                   	ret    

801016a0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801016a0:	55                   	push   %ebp
801016a1:	89 e5                	mov    %esp,%ebp
801016a3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801016a6:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
801016ad:	e8 15 3c 00 00       	call   801052c7 <acquire>
  if(f->ref < 1)
801016b2:	8b 45 08             	mov    0x8(%ebp),%eax
801016b5:	8b 40 04             	mov    0x4(%eax),%eax
801016b8:	85 c0                	test   %eax,%eax
801016ba:	7f 0c                	jg     801016c8 <filedup+0x28>
    panic("filedup");
801016bc:	c7 04 24 54 89 10 80 	movl   $0x80108954,(%esp)
801016c3:	e8 75 ee ff ff       	call   8010053d <panic>
  f->ref++;
801016c8:	8b 45 08             	mov    0x8(%ebp),%eax
801016cb:	8b 40 04             	mov    0x4(%eax),%eax
801016ce:	8d 50 01             	lea    0x1(%eax),%edx
801016d1:	8b 45 08             	mov    0x8(%ebp),%eax
801016d4:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801016d7:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
801016de:	e8 46 3c 00 00       	call   80105329 <release>
  return f;
801016e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801016e6:	c9                   	leave  
801016e7:	c3                   	ret    

801016e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801016e8:	55                   	push   %ebp
801016e9:	89 e5                	mov    %esp,%ebp
801016eb:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801016ee:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
801016f5:	e8 cd 3b 00 00       	call   801052c7 <acquire>
  if(f->ref < 1)
801016fa:	8b 45 08             	mov    0x8(%ebp),%eax
801016fd:	8b 40 04             	mov    0x4(%eax),%eax
80101700:	85 c0                	test   %eax,%eax
80101702:	7f 0c                	jg     80101710 <fileclose+0x28>
    panic("fileclose");
80101704:	c7 04 24 5c 89 10 80 	movl   $0x8010895c,(%esp)
8010170b:	e8 2d ee ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101710:	8b 45 08             	mov    0x8(%ebp),%eax
80101713:	8b 40 04             	mov    0x4(%eax),%eax
80101716:	8d 50 ff             	lea    -0x1(%eax),%edx
80101719:	8b 45 08             	mov    0x8(%ebp),%eax
8010171c:	89 50 04             	mov    %edx,0x4(%eax)
8010171f:	8b 45 08             	mov    0x8(%ebp),%eax
80101722:	8b 40 04             	mov    0x4(%eax),%eax
80101725:	85 c0                	test   %eax,%eax
80101727:	7e 11                	jle    8010173a <fileclose+0x52>
    release(&ftable.lock);
80101729:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
80101730:	e8 f4 3b 00 00       	call   80105329 <release>
    return;
80101735:	e9 82 00 00 00       	jmp    801017bc <fileclose+0xd4>
  }
  ff = *f;
8010173a:	8b 45 08             	mov    0x8(%ebp),%eax
8010173d:	8b 10                	mov    (%eax),%edx
8010173f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101742:	8b 50 04             	mov    0x4(%eax),%edx
80101745:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101748:	8b 50 08             	mov    0x8(%eax),%edx
8010174b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010174e:	8b 50 0c             	mov    0xc(%eax),%edx
80101751:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101754:	8b 50 10             	mov    0x10(%eax),%edx
80101757:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010175a:	8b 40 14             	mov    0x14(%eax),%eax
8010175d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101760:	8b 45 08             	mov    0x8(%ebp),%eax
80101763:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010176a:	8b 45 08             	mov    0x8(%ebp),%eax
8010176d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101773:	c7 04 24 20 ee 10 80 	movl   $0x8010ee20,(%esp)
8010177a:	e8 aa 3b 00 00       	call   80105329 <release>
  
  if(ff.type == FD_PIPE)
8010177f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101782:	83 f8 01             	cmp    $0x1,%eax
80101785:	75 18                	jne    8010179f <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101787:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010178b:	0f be d0             	movsbl %al,%edx
8010178e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101791:	89 54 24 04          	mov    %edx,0x4(%esp)
80101795:	89 04 24             	mov    %eax,(%esp)
80101798:	e8 02 2d 00 00       	call   8010449f <pipeclose>
8010179d:	eb 1d                	jmp    801017bc <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010179f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801017a2:	83 f8 02             	cmp    $0x2,%eax
801017a5:	75 15                	jne    801017bc <fileclose+0xd4>
    begin_trans();
801017a7:	e8 95 21 00 00       	call   80103941 <begin_trans>
    iput(ff.ip);
801017ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017af:	89 04 24             	mov    %eax,(%esp)
801017b2:	e8 88 09 00 00       	call   8010213f <iput>
    commit_trans();
801017b7:	e8 ce 21 00 00       	call   8010398a <commit_trans>
  }
}
801017bc:	c9                   	leave  
801017bd:	c3                   	ret    

801017be <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801017be:	55                   	push   %ebp
801017bf:	89 e5                	mov    %esp,%ebp
801017c1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801017c4:	8b 45 08             	mov    0x8(%ebp),%eax
801017c7:	8b 00                	mov    (%eax),%eax
801017c9:	83 f8 02             	cmp    $0x2,%eax
801017cc:	75 38                	jne    80101806 <filestat+0x48>
    ilock(f->ip);
801017ce:	8b 45 08             	mov    0x8(%ebp),%eax
801017d1:	8b 40 10             	mov    0x10(%eax),%eax
801017d4:	89 04 24             	mov    %eax,(%esp)
801017d7:	e8 b0 07 00 00       	call   80101f8c <ilock>
    stati(f->ip, st);
801017dc:	8b 45 08             	mov    0x8(%ebp),%eax
801017df:	8b 40 10             	mov    0x10(%eax),%eax
801017e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801017e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801017e9:	89 04 24             	mov    %eax,(%esp)
801017ec:	e8 4c 0c 00 00       	call   8010243d <stati>
    iunlock(f->ip);
801017f1:	8b 45 08             	mov    0x8(%ebp),%eax
801017f4:	8b 40 10             	mov    0x10(%eax),%eax
801017f7:	89 04 24             	mov    %eax,(%esp)
801017fa:	e8 db 08 00 00       	call   801020da <iunlock>
    return 0;
801017ff:	b8 00 00 00 00       	mov    $0x0,%eax
80101804:	eb 05                	jmp    8010180b <filestat+0x4d>
  }
  return -1;
80101806:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010181a:	84 c0                	test   %al,%al
8010181c:	75 0a                	jne    80101828 <fileread+0x1b>
    return -1;
8010181e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101823:	e9 9f 00 00 00       	jmp    801018c7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
8010182b:	8b 00                	mov    (%eax),%eax
8010182d:	83 f8 01             	cmp    $0x1,%eax
80101830:	75 1e                	jne    80101850 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101832:	8b 45 08             	mov    0x8(%ebp),%eax
80101835:	8b 40 0c             	mov    0xc(%eax),%eax
80101838:	8b 55 10             	mov    0x10(%ebp),%edx
8010183b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010183f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101842:	89 54 24 04          	mov    %edx,0x4(%esp)
80101846:	89 04 24             	mov    %eax,(%esp)
80101849:	e8 d3 2d 00 00       	call   80104621 <piperead>
8010184e:	eb 77                	jmp    801018c7 <fileread+0xba>
  if(f->type == FD_INODE){
80101850:	8b 45 08             	mov    0x8(%ebp),%eax
80101853:	8b 00                	mov    (%eax),%eax
80101855:	83 f8 02             	cmp    $0x2,%eax
80101858:	75 61                	jne    801018bb <fileread+0xae>
    ilock(f->ip);
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	8b 40 10             	mov    0x10(%eax),%eax
80101860:	89 04 24             	mov    %eax,(%esp)
80101863:	e8 24 07 00 00       	call   80101f8c <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101868:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010186b:	8b 45 08             	mov    0x8(%ebp),%eax
8010186e:	8b 50 14             	mov    0x14(%eax),%edx
80101871:	8b 45 08             	mov    0x8(%ebp),%eax
80101874:	8b 40 10             	mov    0x10(%eax),%eax
80101877:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010187b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010187f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101882:	89 54 24 04          	mov    %edx,0x4(%esp)
80101886:	89 04 24             	mov    %eax,(%esp)
80101889:	e8 f4 0b 00 00       	call   80102482 <readi>
8010188e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101891:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101895:	7e 11                	jle    801018a8 <fileread+0x9b>
      f->off += r;
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	8b 50 14             	mov    0x14(%eax),%edx
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a0:	01 c2                	add    %eax,%edx
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801018a8:	8b 45 08             	mov    0x8(%ebp),%eax
801018ab:	8b 40 10             	mov    0x10(%eax),%eax
801018ae:	89 04 24             	mov    %eax,(%esp)
801018b1:	e8 24 08 00 00       	call   801020da <iunlock>
    return r;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	eb 0c                	jmp    801018c7 <fileread+0xba>
  }
  panic("fileread");
801018bb:	c7 04 24 66 89 10 80 	movl   $0x80108966,(%esp)
801018c2:	e8 76 ec ff ff       	call   8010053d <panic>
}
801018c7:	c9                   	leave  
801018c8:	c3                   	ret    

801018c9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801018c9:	55                   	push   %ebp
801018ca:	89 e5                	mov    %esp,%ebp
801018cc:	53                   	push   %ebx
801018cd:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801018d0:	8b 45 08             	mov    0x8(%ebp),%eax
801018d3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801018d7:	84 c0                	test   %al,%al
801018d9:	75 0a                	jne    801018e5 <filewrite+0x1c>
    return -1;
801018db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018e0:	e9 23 01 00 00       	jmp    80101a08 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801018e5:	8b 45 08             	mov    0x8(%ebp),%eax
801018e8:	8b 00                	mov    (%eax),%eax
801018ea:	83 f8 01             	cmp    $0x1,%eax
801018ed:	75 21                	jne    80101910 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801018ef:	8b 45 08             	mov    0x8(%ebp),%eax
801018f2:	8b 40 0c             	mov    0xc(%eax),%eax
801018f5:	8b 55 10             	mov    0x10(%ebp),%edx
801018f8:	89 54 24 08          	mov    %edx,0x8(%esp)
801018fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801018ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101903:	89 04 24             	mov    %eax,(%esp)
80101906:	e8 26 2c 00 00       	call   80104531 <pipewrite>
8010190b:	e9 f8 00 00 00       	jmp    80101a08 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	8b 00                	mov    (%eax),%eax
80101915:	83 f8 02             	cmp    $0x2,%eax
80101918:	0f 85 de 00 00 00    	jne    801019fc <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010191e:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010192c:	e9 a8 00 00 00       	jmp    801019d9 <filewrite+0x110>
      int n1 = n - i;
80101931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101934:	8b 55 10             	mov    0x10(%ebp),%edx
80101937:	89 d1                	mov    %edx,%ecx
80101939:	29 c1                	sub    %eax,%ecx
8010193b:	89 c8                	mov    %ecx,%eax
8010193d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101943:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101946:	7e 06                	jle    8010194e <filewrite+0x85>
        n1 = max;
80101948:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010194b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010194e:	e8 ee 1f 00 00       	call   80103941 <begin_trans>
      ilock(f->ip);
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 40 10             	mov    0x10(%eax),%eax
80101959:	89 04 24             	mov    %eax,(%esp)
8010195c:	e8 2b 06 00 00       	call   80101f8c <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101961:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	8b 48 14             	mov    0x14(%eax),%ecx
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	89 c2                	mov    %eax,%edx
8010196f:	03 55 0c             	add    0xc(%ebp),%edx
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	8b 40 10             	mov    0x10(%eax),%eax
80101978:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010197c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101980:	89 54 24 04          	mov    %edx,0x4(%esp)
80101984:	89 04 24             	mov    %eax,(%esp)
80101987:	e8 61 0c 00 00       	call   801025ed <writei>
8010198c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010198f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101993:	7e 11                	jle    801019a6 <filewrite+0xdd>
        f->off += r;
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	8b 50 14             	mov    0x14(%eax),%edx
8010199b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010199e:	01 c2                	add    %eax,%edx
801019a0:	8b 45 08             	mov    0x8(%ebp),%eax
801019a3:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801019a6:	8b 45 08             	mov    0x8(%ebp),%eax
801019a9:	8b 40 10             	mov    0x10(%eax),%eax
801019ac:	89 04 24             	mov    %eax,(%esp)
801019af:	e8 26 07 00 00       	call   801020da <iunlock>
      commit_trans();
801019b4:	e8 d1 1f 00 00       	call   8010398a <commit_trans>

      if(r < 0)
801019b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801019bd:	78 28                	js     801019e7 <filewrite+0x11e>
        break;
      if(r != n1)
801019bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019c2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801019c5:	74 0c                	je     801019d3 <filewrite+0x10a>
        panic("short filewrite");
801019c7:	c7 04 24 6f 89 10 80 	movl   $0x8010896f,(%esp)
801019ce:	e8 6a eb ff ff       	call   8010053d <panic>
      i += r;
801019d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019d6:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801019d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019dc:	3b 45 10             	cmp    0x10(%ebp),%eax
801019df:	0f 8c 4c ff ff ff    	jl     80101931 <filewrite+0x68>
801019e5:	eb 01                	jmp    801019e8 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801019e7:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019eb:	3b 45 10             	cmp    0x10(%ebp),%eax
801019ee:	75 05                	jne    801019f5 <filewrite+0x12c>
801019f0:	8b 45 10             	mov    0x10(%ebp),%eax
801019f3:	eb 05                	jmp    801019fa <filewrite+0x131>
801019f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019fa:	eb 0c                	jmp    80101a08 <filewrite+0x13f>
  }
  panic("filewrite");
801019fc:	c7 04 24 7f 89 10 80 	movl   $0x8010897f,(%esp)
80101a03:	e8 35 eb ff ff       	call   8010053d <panic>
}
80101a08:	83 c4 24             	add    $0x24,%esp
80101a0b:	5b                   	pop    %ebx
80101a0c:	5d                   	pop    %ebp
80101a0d:	c3                   	ret    
	...

80101a10 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101a10:	55                   	push   %ebp
80101a11:	89 e5                	mov    %esp,%ebp
80101a13:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101a16:	8b 45 08             	mov    0x8(%ebp),%eax
80101a19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101a20:	00 
80101a21:	89 04 24             	mov    %eax,(%esp)
80101a24:	e8 7d e7 ff ff       	call   801001a6 <bread>
80101a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	83 c0 18             	add    $0x18,%eax
80101a32:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101a39:	00 
80101a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a41:	89 04 24             	mov    %eax,(%esp)
80101a44:	e8 a0 3b 00 00       	call   801055e9 <memmove>
  brelse(bp);
80101a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4c:	89 04 24             	mov    %eax,(%esp)
80101a4f:	e8 c3 e7 ff ff       	call   80100217 <brelse>
}
80101a54:	c9                   	leave  
80101a55:	c3                   	ret    

80101a56 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101a56:	55                   	push   %ebp
80101a57:	89 e5                	mov    %esp,%ebp
80101a59:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a66:	89 04 24             	mov    %eax,(%esp)
80101a69:	e8 38 e7 ff ff       	call   801001a6 <bread>
80101a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a74:	83 c0 18             	add    $0x18,%eax
80101a77:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101a7e:	00 
80101a7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101a86:	00 
80101a87:	89 04 24             	mov    %eax,(%esp)
80101a8a:	e8 87 3a 00 00       	call   80105516 <memset>
  log_write(bp);
80101a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 48 1f 00 00       	call   801039e2 <log_write>
  brelse(bp);
80101a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9d:	89 04 24             	mov    %eax,(%esp)
80101aa0:	e8 72 e7 ff ff       	call   80100217 <brelse>
}
80101aa5:	c9                   	leave  
80101aa6:	c3                   	ret    

80101aa7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101aa7:	55                   	push   %ebp
80101aa8:	89 e5                	mov    %esp,%ebp
80101aaa:	53                   	push   %ebx
80101aab:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101aae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101abb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101abf:	89 04 24             	mov    %eax,(%esp)
80101ac2:	e8 49 ff ff ff       	call   80101a10 <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101ac7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ace:	e9 11 01 00 00       	jmp    80101be4 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101adc:	85 c0                	test   %eax,%eax
80101ade:	0f 48 c2             	cmovs  %edx,%eax
80101ae1:	c1 f8 0c             	sar    $0xc,%eax
80101ae4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101ae7:	c1 ea 03             	shr    $0x3,%edx
80101aea:	01 d0                	add    %edx,%eax
80101aec:	83 c0 03             	add    $0x3,%eax
80101aef:	89 44 24 04          	mov    %eax,0x4(%esp)
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	89 04 24             	mov    %eax,(%esp)
80101af9:	e8 a8 e6 ff ff       	call   801001a6 <bread>
80101afe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101b01:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101b08:	e9 a7 00 00 00       	jmp    80101bb4 <balloc+0x10d>
      m = 1 << (bi % 8);
80101b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b10:	89 c2                	mov    %eax,%edx
80101b12:	c1 fa 1f             	sar    $0x1f,%edx
80101b15:	c1 ea 1d             	shr    $0x1d,%edx
80101b18:	01 d0                	add    %edx,%eax
80101b1a:	83 e0 07             	and    $0x7,%eax
80101b1d:	29 d0                	sub    %edx,%eax
80101b1f:	ba 01 00 00 00       	mov    $0x1,%edx
80101b24:	89 d3                	mov    %edx,%ebx
80101b26:	89 c1                	mov    %eax,%ecx
80101b28:	d3 e3                	shl    %cl,%ebx
80101b2a:	89 d8                	mov    %ebx,%eax
80101b2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b32:	8d 50 07             	lea    0x7(%eax),%edx
80101b35:	85 c0                	test   %eax,%eax
80101b37:	0f 48 c2             	cmovs  %edx,%eax
80101b3a:	c1 f8 03             	sar    $0x3,%eax
80101b3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b40:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101b45:	0f b6 c0             	movzbl %al,%eax
80101b48:	23 45 e8             	and    -0x18(%ebp),%eax
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	75 61                	jne    80101bb0 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b52:	8d 50 07             	lea    0x7(%eax),%edx
80101b55:	85 c0                	test   %eax,%eax
80101b57:	0f 48 c2             	cmovs  %edx,%eax
80101b5a:	c1 f8 03             	sar    $0x3,%eax
80101b5d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b60:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101b65:	89 d1                	mov    %edx,%ecx
80101b67:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101b6a:	09 ca                	or     %ecx,%edx
80101b6c:	89 d1                	mov    %edx,%ecx
80101b6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b71:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101b75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b78:	89 04 24             	mov    %eax,(%esp)
80101b7b:	e8 62 1e 00 00       	call   801039e2 <log_write>
        brelse(bp);
80101b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b83:	89 04 24             	mov    %eax,(%esp)
80101b86:	e8 8c e6 ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b91:	01 c2                	add    %eax,%edx
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b9a:	89 04 24             	mov    %eax,(%esp)
80101b9d:	e8 b4 fe ff ff       	call   80101a56 <bzero>
        return b + bi;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba8:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101baa:	83 c4 34             	add    $0x34,%esp
80101bad:	5b                   	pop    %ebx
80101bae:	5d                   	pop    %ebp
80101baf:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101bb0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101bb4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101bbb:	7f 15                	jg     80101bd2 <balloc+0x12b>
80101bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bc3:	01 d0                	add    %edx,%eax
80101bc5:	89 c2                	mov    %eax,%edx
80101bc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bca:	39 c2                	cmp    %eax,%edx
80101bcc:	0f 82 3b ff ff ff    	jb     80101b0d <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101bd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bd5:	89 04 24             	mov    %eax,(%esp)
80101bd8:	e8 3a e6 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101bdd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101be7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bea:	39 c2                	cmp    %eax,%edx
80101bec:	0f 82 e1 fe ff ff    	jb     80101ad3 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101bf2:	c7 04 24 89 89 10 80 	movl   $0x80108989,(%esp)
80101bf9:	e8 3f e9 ff ff       	call   8010053d <panic>

80101bfe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101bfe:	55                   	push   %ebp
80101bff:	89 e5                	mov    %esp,%ebp
80101c01:	53                   	push   %ebx
80101c02:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101c05:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101c08:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	89 04 24             	mov    %eax,(%esp)
80101c12:	e8 f9 fd ff ff       	call   80101a10 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101c17:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c1a:	89 c2                	mov    %eax,%edx
80101c1c:	c1 ea 0c             	shr    $0xc,%edx
80101c1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c22:	c1 e8 03             	shr    $0x3,%eax
80101c25:	01 d0                	add    %edx,%eax
80101c27:	8d 50 03             	lea    0x3(%eax),%edx
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c31:	89 04 24             	mov    %eax,(%esp)
80101c34:	e8 6d e5 ff ff       	call   801001a6 <bread>
80101c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c4a:	89 c2                	mov    %eax,%edx
80101c4c:	c1 fa 1f             	sar    $0x1f,%edx
80101c4f:	c1 ea 1d             	shr    $0x1d,%edx
80101c52:	01 d0                	add    %edx,%eax
80101c54:	83 e0 07             	and    $0x7,%eax
80101c57:	29 d0                	sub    %edx,%eax
80101c59:	ba 01 00 00 00       	mov    $0x1,%edx
80101c5e:	89 d3                	mov    %edx,%ebx
80101c60:	89 c1                	mov    %eax,%ecx
80101c62:	d3 e3                	shl    %cl,%ebx
80101c64:	89 d8                	mov    %ebx,%eax
80101c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6c:	8d 50 07             	lea    0x7(%eax),%edx
80101c6f:	85 c0                	test   %eax,%eax
80101c71:	0f 48 c2             	cmovs  %edx,%eax
80101c74:	c1 f8 03             	sar    $0x3,%eax
80101c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101c7f:	0f b6 c0             	movzbl %al,%eax
80101c82:	23 45 ec             	and    -0x14(%ebp),%eax
80101c85:	85 c0                	test   %eax,%eax
80101c87:	75 0c                	jne    80101c95 <bfree+0x97>
    panic("freeing free block");
80101c89:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
80101c90:	e8 a8 e8 ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c98:	8d 50 07             	lea    0x7(%eax),%edx
80101c9b:	85 c0                	test   %eax,%eax
80101c9d:	0f 48 c2             	cmovs  %edx,%eax
80101ca0:	c1 f8 03             	sar    $0x3,%eax
80101ca3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101cab:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101cae:	f7 d1                	not    %ecx
80101cb0:	21 ca                	and    %ecx,%edx
80101cb2:	89 d1                	mov    %edx,%ecx
80101cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cbe:	89 04 24             	mov    %eax,(%esp)
80101cc1:	e8 1c 1d 00 00       	call   801039e2 <log_write>
  brelse(bp);
80101cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc9:	89 04 24             	mov    %eax,(%esp)
80101ccc:	e8 46 e5 ff ff       	call   80100217 <brelse>
}
80101cd1:	83 c4 34             	add    $0x34,%esp
80101cd4:	5b                   	pop    %ebx
80101cd5:	5d                   	pop    %ebp
80101cd6:	c3                   	ret    

80101cd7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101cd7:	55                   	push   %ebp
80101cd8:	89 e5                	mov    %esp,%ebp
80101cda:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101cdd:	c7 44 24 04 b2 89 10 	movl   $0x801089b2,0x4(%esp)
80101ce4:	80 
80101ce5:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101cec:	e8 b5 35 00 00       	call   801052a6 <initlock>
}
80101cf1:	c9                   	leave  
80101cf2:	c3                   	ret    

80101cf3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101cf3:	55                   	push   %ebp
80101cf4:	89 e5                	mov    %esp,%ebp
80101cf6:	83 ec 48             	sub    $0x48,%esp
80101cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfc:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101d00:	8b 45 08             	mov    0x8(%ebp),%eax
80101d03:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101d06:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d0a:	89 04 24             	mov    %eax,(%esp)
80101d0d:	e8 fe fc ff ff       	call   80101a10 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101d12:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101d19:	e9 98 00 00 00       	jmp    80101db6 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d21:	c1 e8 03             	shr    $0x3,%eax
80101d24:	83 c0 02             	add    $0x2,%eax
80101d27:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2e:	89 04 24             	mov    %eax,(%esp)
80101d31:	e8 70 e4 ff ff       	call   801001a6 <bread>
80101d36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d3c:	8d 50 18             	lea    0x18(%eax),%edx
80101d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d42:	83 e0 07             	and    $0x7,%eax
80101d45:	c1 e0 06             	shl    $0x6,%eax
80101d48:	01 d0                	add    %edx,%eax
80101d4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101d4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d50:	0f b7 00             	movzwl (%eax),%eax
80101d53:	66 85 c0             	test   %ax,%ax
80101d56:	75 4f                	jne    80101da7 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101d58:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101d5f:	00 
80101d60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101d67:	00 
80101d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d6b:	89 04 24             	mov    %eax,(%esp)
80101d6e:	e8 a3 37 00 00       	call   80105516 <memset>
      dip->type = type;
80101d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d76:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101d7a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d80:	89 04 24             	mov    %eax,(%esp)
80101d83:	e8 5a 1c 00 00       	call   801039e2 <log_write>
      brelse(bp);
80101d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8b:	89 04 24             	mov    %eax,(%esp)
80101d8e:	e8 84 e4 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d96:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9d:	89 04 24             	mov    %eax,(%esp)
80101da0:	e8 e3 00 00 00       	call   80101e88 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101da5:	c9                   	leave  
80101da6:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101daa:	89 04 24             	mov    %eax,(%esp)
80101dad:	e8 65 e4 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101db2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101dbc:	39 c2                	cmp    %eax,%edx
80101dbe:	0f 82 5a ff ff ff    	jb     80101d1e <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101dc4:	c7 04 24 b9 89 10 80 	movl   $0x801089b9,(%esp)
80101dcb:	e8 6d e7 ff ff       	call   8010053d <panic>

80101dd0 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101dd0:	55                   	push   %ebp
80101dd1:	89 e5                	mov    %esp,%ebp
80101dd3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 40 04             	mov    0x4(%eax),%eax
80101ddc:	c1 e8 03             	shr    $0x3,%eax
80101ddf:	8d 50 02             	lea    0x2(%eax),%edx
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 00                	mov    (%eax),%eax
80101de7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101deb:	89 04 24             	mov    %eax,(%esp)
80101dee:	e8 b3 e3 ff ff       	call   801001a6 <bread>
80101df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df9:	8d 50 18             	lea    0x18(%eax),%edx
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 40 04             	mov    0x4(%eax),%eax
80101e02:	83 e0 07             	and    $0x7,%eax
80101e05:	c1 e0 06             	shl    $0x6,%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e17:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e24:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e32:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101e36:	8b 45 08             	mov    0x8(%ebp),%eax
80101e39:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e40:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	8b 50 18             	mov    0x18(%eax),%edx
80101e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e4d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8d 50 1c             	lea    0x1c(%eax),%edx
80101e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e59:	83 c0 0c             	add    $0xc,%eax
80101e5c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101e63:	00 
80101e64:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e68:	89 04 24             	mov    %eax,(%esp)
80101e6b:	e8 79 37 00 00       	call   801055e9 <memmove>
  log_write(bp);
80101e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e73:	89 04 24             	mov    %eax,(%esp)
80101e76:	e8 67 1b 00 00       	call   801039e2 <log_write>
  brelse(bp);
80101e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7e:	89 04 24             	mov    %eax,(%esp)
80101e81:	e8 91 e3 ff ff       	call   80100217 <brelse>
}
80101e86:	c9                   	leave  
80101e87:	c3                   	ret    

80101e88 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101e88:	55                   	push   %ebp
80101e89:	89 e5                	mov    %esp,%ebp
80101e8b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101e8e:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101e95:	e8 2d 34 00 00       	call   801052c7 <acquire>

  // Is the inode already cached?
  empty = 0;
80101e9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ea1:	c7 45 f4 54 f8 10 80 	movl   $0x8010f854,-0xc(%ebp)
80101ea8:	eb 59                	jmp    80101f03 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ead:	8b 40 08             	mov    0x8(%eax),%eax
80101eb0:	85 c0                	test   %eax,%eax
80101eb2:	7e 35                	jle    80101ee9 <iget+0x61>
80101eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb7:	8b 00                	mov    (%eax),%eax
80101eb9:	3b 45 08             	cmp    0x8(%ebp),%eax
80101ebc:	75 2b                	jne    80101ee9 <iget+0x61>
80101ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec1:	8b 40 04             	mov    0x4(%eax),%eax
80101ec4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101ec7:	75 20                	jne    80101ee9 <iget+0x61>
      ip->ref++;
80101ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ecc:	8b 40 08             	mov    0x8(%eax),%eax
80101ecf:	8d 50 01             	lea    0x1(%eax),%edx
80101ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed5:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101ed8:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101edf:	e8 45 34 00 00       	call   80105329 <release>
      return ip;
80101ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee7:	eb 6f                	jmp    80101f58 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101ee9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101eed:	75 10                	jne    80101eff <iget+0x77>
80101eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef2:	8b 40 08             	mov    0x8(%eax),%eax
80101ef5:	85 c0                	test   %eax,%eax
80101ef7:	75 06                	jne    80101eff <iget+0x77>
      empty = ip;
80101ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101efc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101eff:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101f03:	81 7d f4 f4 07 11 80 	cmpl   $0x801107f4,-0xc(%ebp)
80101f0a:	72 9e                	jb     80101eaa <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101f0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101f10:	75 0c                	jne    80101f1e <iget+0x96>
    panic("iget: no inodes");
80101f12:	c7 04 24 cb 89 10 80 	movl   $0x801089cb,(%esp)
80101f19:	e8 1f e6 ff ff       	call   8010053d <panic>

  ip = empty;
80101f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f27:	8b 55 08             	mov    0x8(%ebp),%edx
80101f2a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f32:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f42:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101f49:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101f50:	e8 d4 33 00 00       	call   80105329 <release>

  return ip;
80101f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101f58:	c9                   	leave  
80101f59:	c3                   	ret    

80101f5a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101f5a:	55                   	push   %ebp
80101f5b:	89 e5                	mov    %esp,%ebp
80101f5d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101f60:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101f67:	e8 5b 33 00 00       	call   801052c7 <acquire>
  ip->ref++;
80101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6f:	8b 40 08             	mov    0x8(%eax),%eax
80101f72:	8d 50 01             	lea    0x1(%eax),%edx
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f7b:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101f82:	e8 a2 33 00 00       	call   80105329 <release>
  return ip;
80101f87:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101f8a:	c9                   	leave  
80101f8b:	c3                   	ret    

80101f8c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101f8c:	55                   	push   %ebp
80101f8d:	89 e5                	mov    %esp,%ebp
80101f8f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101f92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101f96:	74 0a                	je     80101fa2 <ilock+0x16>
80101f98:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9b:	8b 40 08             	mov    0x8(%eax),%eax
80101f9e:	85 c0                	test   %eax,%eax
80101fa0:	7f 0c                	jg     80101fae <ilock+0x22>
    panic("ilock");
80101fa2:	c7 04 24 db 89 10 80 	movl   $0x801089db,(%esp)
80101fa9:	e8 8f e5 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101fae:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101fb5:	e8 0d 33 00 00       	call   801052c7 <acquire>
  while(ip->flags & I_BUSY)
80101fba:	eb 13                	jmp    80101fcf <ilock+0x43>
    sleep(ip, &icache.lock);
80101fbc:	c7 44 24 04 20 f8 10 	movl   $0x8010f820,0x4(%esp)
80101fc3:	80 
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	89 04 24             	mov    %eax,(%esp)
80101fca:	e8 1a 30 00 00       	call   80104fe9 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd2:	8b 40 0c             	mov    0xc(%eax),%eax
80101fd5:	83 e0 01             	and    $0x1,%eax
80101fd8:	84 c0                	test   %al,%al
80101fda:	75 e0                	jne    80101fbc <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	8b 40 0c             	mov    0xc(%eax),%eax
80101fe2:	89 c2                	mov    %eax,%edx
80101fe4:	83 ca 01             	or     $0x1,%edx
80101fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fea:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101fed:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80101ff4:	e8 30 33 00 00       	call   80105329 <release>

  if(!(ip->flags & I_VALID)){
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	8b 40 0c             	mov    0xc(%eax),%eax
80101fff:	83 e0 02             	and    $0x2,%eax
80102002:	85 c0                	test   %eax,%eax
80102004:	0f 85 ce 00 00 00    	jne    801020d8 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010200a:	8b 45 08             	mov    0x8(%ebp),%eax
8010200d:	8b 40 04             	mov    0x4(%eax),%eax
80102010:	c1 e8 03             	shr    $0x3,%eax
80102013:	8d 50 02             	lea    0x2(%eax),%edx
80102016:	8b 45 08             	mov    0x8(%ebp),%eax
80102019:	8b 00                	mov    (%eax),%eax
8010201b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010201f:	89 04 24             	mov    %eax,(%esp)
80102022:	e8 7f e1 ff ff       	call   801001a6 <bread>
80102027:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010202d:	8d 50 18             	lea    0x18(%eax),%edx
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	8b 40 04             	mov    0x4(%eax),%eax
80102036:	83 e0 07             	and    $0x7,%eax
80102039:	c1 e0 06             	shl    $0x6,%eax
8010203c:	01 d0                	add    %edx,%eax
8010203e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80102041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102044:	0f b7 10             	movzwl (%eax),%edx
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010204e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102051:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80102055:	8b 45 08             	mov    0x8(%ebp),%eax
80102058:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010205c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010205f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80102063:	8b 45 08             	mov    0x8(%ebp),%eax
80102066:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010206a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010206d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80102078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207b:	8b 50 08             	mov    0x8(%eax),%edx
8010207e:	8b 45 08             	mov    0x8(%ebp),%eax
80102081:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102087:	8d 50 0c             	lea    0xc(%eax),%edx
8010208a:	8b 45 08             	mov    0x8(%ebp),%eax
8010208d:	83 c0 1c             	add    $0x1c,%eax
80102090:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80102097:	00 
80102098:	89 54 24 04          	mov    %edx,0x4(%esp)
8010209c:	89 04 24             	mov    %eax,(%esp)
8010209f:	e8 45 35 00 00       	call   801055e9 <memmove>
    brelse(bp);
801020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a7:	89 04 24             	mov    %eax,(%esp)
801020aa:	e8 68 e1 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801020af:	8b 45 08             	mov    0x8(%ebp),%eax
801020b2:	8b 40 0c             	mov    0xc(%eax),%eax
801020b5:	89 c2                	mov    %eax,%edx
801020b7:	83 ca 02             	or     $0x2,%edx
801020ba:	8b 45 08             	mov    0x8(%ebp),%eax
801020bd:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020c7:	66 85 c0             	test   %ax,%ax
801020ca:	75 0c                	jne    801020d8 <ilock+0x14c>
      panic("ilock: no type");
801020cc:	c7 04 24 e1 89 10 80 	movl   $0x801089e1,(%esp)
801020d3:	e8 65 e4 ff ff       	call   8010053d <panic>
  }
}
801020d8:	c9                   	leave  
801020d9:	c3                   	ret    

801020da <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801020da:	55                   	push   %ebp
801020db:	89 e5                	mov    %esp,%ebp
801020dd:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801020e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801020e4:	74 17                	je     801020fd <iunlock+0x23>
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	8b 40 0c             	mov    0xc(%eax),%eax
801020ec:	83 e0 01             	and    $0x1,%eax
801020ef:	85 c0                	test   %eax,%eax
801020f1:	74 0a                	je     801020fd <iunlock+0x23>
801020f3:	8b 45 08             	mov    0x8(%ebp),%eax
801020f6:	8b 40 08             	mov    0x8(%eax),%eax
801020f9:	85 c0                	test   %eax,%eax
801020fb:	7f 0c                	jg     80102109 <iunlock+0x2f>
    panic("iunlock");
801020fd:	c7 04 24 f0 89 10 80 	movl   $0x801089f0,(%esp)
80102104:	e8 34 e4 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80102109:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80102110:	e8 b2 31 00 00       	call   801052c7 <acquire>
  ip->flags &= ~I_BUSY;
80102115:	8b 45 08             	mov    0x8(%ebp),%eax
80102118:	8b 40 0c             	mov    0xc(%eax),%eax
8010211b:	89 c2                	mov    %eax,%edx
8010211d:	83 e2 fe             	and    $0xfffffffe,%edx
80102120:	8b 45 08             	mov    0x8(%ebp),%eax
80102123:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80102126:	8b 45 08             	mov    0x8(%ebp),%eax
80102129:	89 04 24             	mov    %eax,(%esp)
8010212c:	e8 91 2f 00 00       	call   801050c2 <wakeup>
  release(&icache.lock);
80102131:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80102138:	e8 ec 31 00 00       	call   80105329 <release>
}
8010213d:	c9                   	leave  
8010213e:	c3                   	ret    

8010213f <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
8010213f:	55                   	push   %ebp
80102140:	89 e5                	mov    %esp,%ebp
80102142:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80102145:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
8010214c:	e8 76 31 00 00       	call   801052c7 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80102151:	8b 45 08             	mov    0x8(%ebp),%eax
80102154:	8b 40 08             	mov    0x8(%eax),%eax
80102157:	83 f8 01             	cmp    $0x1,%eax
8010215a:	0f 85 93 00 00 00    	jne    801021f3 <iput+0xb4>
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	8b 40 0c             	mov    0xc(%eax),%eax
80102166:	83 e0 02             	and    $0x2,%eax
80102169:	85 c0                	test   %eax,%eax
8010216b:	0f 84 82 00 00 00    	je     801021f3 <iput+0xb4>
80102171:	8b 45 08             	mov    0x8(%ebp),%eax
80102174:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102178:	66 85 c0             	test   %ax,%ax
8010217b:	75 76                	jne    801021f3 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
8010217d:	8b 45 08             	mov    0x8(%ebp),%eax
80102180:	8b 40 0c             	mov    0xc(%eax),%eax
80102183:	83 e0 01             	and    $0x1,%eax
80102186:	84 c0                	test   %al,%al
80102188:	74 0c                	je     80102196 <iput+0x57>
      panic("iput busy");
8010218a:	c7 04 24 f8 89 10 80 	movl   $0x801089f8,(%esp)
80102191:	e8 a7 e3 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	8b 40 0c             	mov    0xc(%eax),%eax
8010219c:	89 c2                	mov    %eax,%edx
8010219e:	83 ca 01             	or     $0x1,%edx
801021a1:	8b 45 08             	mov    0x8(%ebp),%eax
801021a4:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
801021a7:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
801021ae:	e8 76 31 00 00       	call   80105329 <release>
    itrunc(ip);
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	89 04 24             	mov    %eax,(%esp)
801021b9:	e8 72 01 00 00       	call   80102330 <itrunc>
    ip->type = 0;
801021be:	8b 45 08             	mov    0x8(%ebp),%eax
801021c1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
801021c7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ca:	89 04 24             	mov    %eax,(%esp)
801021cd:	e8 fe fb ff ff       	call   80101dd0 <iupdate>
    acquire(&icache.lock);
801021d2:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
801021d9:	e8 e9 30 00 00       	call   801052c7 <acquire>
    ip->flags = 0;
801021de:	8b 45 08             	mov    0x8(%ebp),%eax
801021e1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
801021e8:	8b 45 08             	mov    0x8(%ebp),%eax
801021eb:	89 04 24             	mov    %eax,(%esp)
801021ee:	e8 cf 2e 00 00       	call   801050c2 <wakeup>
  }
  ip->ref--;
801021f3:	8b 45 08             	mov    0x8(%ebp),%eax
801021f6:	8b 40 08             	mov    0x8(%eax),%eax
801021f9:	8d 50 ff             	lea    -0x1(%eax),%edx
801021fc:	8b 45 08             	mov    0x8(%ebp),%eax
801021ff:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102202:	c7 04 24 20 f8 10 80 	movl   $0x8010f820,(%esp)
80102209:	e8 1b 31 00 00       	call   80105329 <release>
}
8010220e:	c9                   	leave  
8010220f:	c3                   	ret    

80102210 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80102210:	55                   	push   %ebp
80102211:	89 e5                	mov    %esp,%ebp
80102213:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80102216:	8b 45 08             	mov    0x8(%ebp),%eax
80102219:	89 04 24             	mov    %eax,(%esp)
8010221c:	e8 b9 fe ff ff       	call   801020da <iunlock>
  iput(ip);
80102221:	8b 45 08             	mov    0x8(%ebp),%eax
80102224:	89 04 24             	mov    %eax,(%esp)
80102227:	e8 13 ff ff ff       	call   8010213f <iput>
}
8010222c:	c9                   	leave  
8010222d:	c3                   	ret    

8010222e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
8010222e:	55                   	push   %ebp
8010222f:	89 e5                	mov    %esp,%ebp
80102231:	53                   	push   %ebx
80102232:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80102235:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80102239:	77 3e                	ja     80102279 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
8010223b:	8b 45 08             	mov    0x8(%ebp),%eax
8010223e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102241:	83 c2 04             	add    $0x4,%edx
80102244:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102248:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010224b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010224f:	75 20                	jne    80102271 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80102251:	8b 45 08             	mov    0x8(%ebp),%eax
80102254:	8b 00                	mov    (%eax),%eax
80102256:	89 04 24             	mov    %eax,(%esp)
80102259:	e8 49 f8 ff ff       	call   80101aa7 <balloc>
8010225e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102261:	8b 45 08             	mov    0x8(%ebp),%eax
80102264:	8b 55 0c             	mov    0xc(%ebp),%edx
80102267:	8d 4a 04             	lea    0x4(%edx),%ecx
8010226a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010226d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80102271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102274:	e9 b1 00 00 00       	jmp    8010232a <bmap+0xfc>
  }
  bn -= NDIRECT;
80102279:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
8010227d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80102281:	0f 87 97 00 00 00    	ja     8010231e <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	8b 40 4c             	mov    0x4c(%eax),%eax
8010228d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102294:	75 19                	jne    801022af <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80102296:	8b 45 08             	mov    0x8(%ebp),%eax
80102299:	8b 00                	mov    (%eax),%eax
8010229b:	89 04 24             	mov    %eax,(%esp)
8010229e:	e8 04 f8 ff ff       	call   80101aa7 <balloc>
801022a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022a6:	8b 45 08             	mov    0x8(%ebp),%eax
801022a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022ac:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
801022af:	8b 45 08             	mov    0x8(%ebp),%eax
801022b2:	8b 00                	mov    (%eax),%eax
801022b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801022bb:	89 04 24             	mov    %eax,(%esp)
801022be:	e8 e3 de ff ff       	call   801001a6 <bread>
801022c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
801022c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022c9:	83 c0 18             	add    $0x18,%eax
801022cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
801022cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d2:	c1 e0 02             	shl    $0x2,%eax
801022d5:	03 45 ec             	add    -0x14(%ebp),%eax
801022d8:	8b 00                	mov    (%eax),%eax
801022da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022e1:	75 2b                	jne    8010230e <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
801022e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801022e6:	c1 e0 02             	shl    $0x2,%eax
801022e9:	89 c3                	mov    %eax,%ebx
801022eb:	03 5d ec             	add    -0x14(%ebp),%ebx
801022ee:	8b 45 08             	mov    0x8(%ebp),%eax
801022f1:	8b 00                	mov    (%eax),%eax
801022f3:	89 04 24             	mov    %eax,(%esp)
801022f6:	e8 ac f7 ff ff       	call   80101aa7 <balloc>
801022fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102301:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80102303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102306:	89 04 24             	mov    %eax,(%esp)
80102309:	e8 d4 16 00 00       	call   801039e2 <log_write>
    }
    brelse(bp);
8010230e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102311:	89 04 24             	mov    %eax,(%esp)
80102314:	e8 fe de ff ff       	call   80100217 <brelse>
    return addr;
80102319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231c:	eb 0c                	jmp    8010232a <bmap+0xfc>
  }

  panic("bmap: out of range");
8010231e:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
80102325:	e8 13 e2 ff ff       	call   8010053d <panic>
}
8010232a:	83 c4 24             	add    $0x24,%esp
8010232d:	5b                   	pop    %ebx
8010232e:	5d                   	pop    %ebp
8010232f:	c3                   	ret    

80102330 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80102330:	55                   	push   %ebp
80102331:	89 e5                	mov    %esp,%ebp
80102333:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80102336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010233d:	eb 44                	jmp    80102383 <itrunc+0x53>
    if(ip->addrs[i]){
8010233f:	8b 45 08             	mov    0x8(%ebp),%eax
80102342:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102345:	83 c2 04             	add    $0x4,%edx
80102348:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010234c:	85 c0                	test   %eax,%eax
8010234e:	74 2f                	je     8010237f <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102356:	83 c2 04             	add    $0x4,%edx
80102359:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
8010235d:	8b 45 08             	mov    0x8(%ebp),%eax
80102360:	8b 00                	mov    (%eax),%eax
80102362:	89 54 24 04          	mov    %edx,0x4(%esp)
80102366:	89 04 24             	mov    %eax,(%esp)
80102369:	e8 90 f8 ff ff       	call   80101bfe <bfree>
      ip->addrs[i] = 0;
8010236e:	8b 45 08             	mov    0x8(%ebp),%eax
80102371:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102374:	83 c2 04             	add    $0x4,%edx
80102377:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010237e:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010237f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102383:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102387:	7e b6                	jle    8010233f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80102389:	8b 45 08             	mov    0x8(%ebp),%eax
8010238c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010238f:	85 c0                	test   %eax,%eax
80102391:	0f 84 8f 00 00 00    	je     80102426 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	8b 50 4c             	mov    0x4c(%eax),%edx
8010239d:	8b 45 08             	mov    0x8(%ebp),%eax
801023a0:	8b 00                	mov    (%eax),%eax
801023a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 f8 dd ff ff       	call   801001a6 <bread>
801023ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
801023b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023b4:	83 c0 18             	add    $0x18,%eax
801023b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801023ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801023c1:	eb 2f                	jmp    801023f2 <itrunc+0xc2>
      if(a[j])
801023c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c6:	c1 e0 02             	shl    $0x2,%eax
801023c9:	03 45 e8             	add    -0x18(%ebp),%eax
801023cc:	8b 00                	mov    (%eax),%eax
801023ce:	85 c0                	test   %eax,%eax
801023d0:	74 1c                	je     801023ee <itrunc+0xbe>
        bfree(ip->dev, a[j]);
801023d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d5:	c1 e0 02             	shl    $0x2,%eax
801023d8:	03 45 e8             	add    -0x18(%ebp),%eax
801023db:	8b 10                	mov    (%eax),%edx
801023dd:	8b 45 08             	mov    0x8(%ebp),%eax
801023e0:	8b 00                	mov    (%eax),%eax
801023e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801023e6:	89 04 24             	mov    %eax,(%esp)
801023e9:	e8 10 f8 ff ff       	call   80101bfe <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
801023ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801023f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f5:	83 f8 7f             	cmp    $0x7f,%eax
801023f8:	76 c9                	jbe    801023c3 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
801023fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023fd:	89 04 24             	mov    %eax,(%esp)
80102400:	e8 12 de ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	8b 50 4c             	mov    0x4c(%eax),%edx
8010240b:	8b 45 08             	mov    0x8(%ebp),%eax
8010240e:	8b 00                	mov    (%eax),%eax
80102410:	89 54 24 04          	mov    %edx,0x4(%esp)
80102414:	89 04 24             	mov    %eax,(%esp)
80102417:	e8 e2 f7 ff ff       	call   80101bfe <bfree>
    ip->addrs[NDIRECT] = 0;
8010241c:	8b 45 08             	mov    0x8(%ebp),%eax
8010241f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102426:	8b 45 08             	mov    0x8(%ebp),%eax
80102429:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	89 04 24             	mov    %eax,(%esp)
80102436:	e8 95 f9 ff ff       	call   80101dd0 <iupdate>
}
8010243b:	c9                   	leave  
8010243c:	c3                   	ret    

8010243d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010243d:	55                   	push   %ebp
8010243e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	8b 00                	mov    (%eax),%eax
80102445:	89 c2                	mov    %eax,%edx
80102447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010244a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010244d:	8b 45 08             	mov    0x8(%ebp),%eax
80102450:	8b 50 04             	mov    0x4(%eax),%edx
80102453:	8b 45 0c             	mov    0xc(%ebp),%eax
80102456:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102459:	8b 45 08             	mov    0x8(%ebp),%eax
8010245c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102460:	8b 45 0c             	mov    0xc(%ebp),%eax
80102463:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102466:	8b 45 08             	mov    0x8(%ebp),%eax
80102469:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010246d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102470:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102474:	8b 45 08             	mov    0x8(%ebp),%eax
80102477:	8b 50 18             	mov    0x18(%eax),%edx
8010247a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010247d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102480:	5d                   	pop    %ebp
80102481:	c3                   	ret    

80102482 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102482:	55                   	push   %ebp
80102483:	89 e5                	mov    %esp,%ebp
80102485:	53                   	push   %ebx
80102486:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102490:	66 83 f8 03          	cmp    $0x3,%ax
80102494:	75 60                	jne    801024f6 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102496:	8b 45 08             	mov    0x8(%ebp),%eax
80102499:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010249d:	66 85 c0             	test   %ax,%ax
801024a0:	78 20                	js     801024c2 <readi+0x40>
801024a2:	8b 45 08             	mov    0x8(%ebp),%eax
801024a5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024a9:	66 83 f8 09          	cmp    $0x9,%ax
801024ad:	7f 13                	jg     801024c2 <readi+0x40>
801024af:	8b 45 08             	mov    0x8(%ebp),%eax
801024b2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024b6:	98                   	cwtl   
801024b7:	8b 04 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%eax
801024be:	85 c0                	test   %eax,%eax
801024c0:	75 0a                	jne    801024cc <readi+0x4a>
      return -1;
801024c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024c7:	e9 1b 01 00 00       	jmp    801025e7 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801024cc:	8b 45 08             	mov    0x8(%ebp),%eax
801024cf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801024d3:	98                   	cwtl   
801024d4:	8b 14 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%edx
801024db:	8b 45 14             	mov    0x14(%ebp),%eax
801024de:	89 44 24 08          	mov    %eax,0x8(%esp)
801024e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ec:	89 04 24             	mov    %eax,(%esp)
801024ef:	ff d2                	call   *%edx
801024f1:	e9 f1 00 00 00       	jmp    801025e7 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801024f6:	8b 45 08             	mov    0x8(%ebp),%eax
801024f9:	8b 40 18             	mov    0x18(%eax),%eax
801024fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801024ff:	72 0d                	jb     8010250e <readi+0x8c>
80102501:	8b 45 14             	mov    0x14(%ebp),%eax
80102504:	8b 55 10             	mov    0x10(%ebp),%edx
80102507:	01 d0                	add    %edx,%eax
80102509:	3b 45 10             	cmp    0x10(%ebp),%eax
8010250c:	73 0a                	jae    80102518 <readi+0x96>
    return -1;
8010250e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102513:	e9 cf 00 00 00       	jmp    801025e7 <readi+0x165>
  if(off + n > ip->size)
80102518:	8b 45 14             	mov    0x14(%ebp),%eax
8010251b:	8b 55 10             	mov    0x10(%ebp),%edx
8010251e:	01 c2                	add    %eax,%edx
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	8b 40 18             	mov    0x18(%eax),%eax
80102526:	39 c2                	cmp    %eax,%edx
80102528:	76 0c                	jbe    80102536 <readi+0xb4>
    n = ip->size - off;
8010252a:	8b 45 08             	mov    0x8(%ebp),%eax
8010252d:	8b 40 18             	mov    0x18(%eax),%eax
80102530:	2b 45 10             	sub    0x10(%ebp),%eax
80102533:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102536:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010253d:	e9 96 00 00 00       	jmp    801025d8 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102542:	8b 45 10             	mov    0x10(%ebp),%eax
80102545:	c1 e8 09             	shr    $0x9,%eax
80102548:	89 44 24 04          	mov    %eax,0x4(%esp)
8010254c:	8b 45 08             	mov    0x8(%ebp),%eax
8010254f:	89 04 24             	mov    %eax,(%esp)
80102552:	e8 d7 fc ff ff       	call   8010222e <bmap>
80102557:	8b 55 08             	mov    0x8(%ebp),%edx
8010255a:	8b 12                	mov    (%edx),%edx
8010255c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102560:	89 14 24             	mov    %edx,(%esp)
80102563:	e8 3e dc ff ff       	call   801001a6 <bread>
80102568:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010256b:	8b 45 10             	mov    0x10(%ebp),%eax
8010256e:	89 c2                	mov    %eax,%edx
80102570:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102576:	b8 00 02 00 00       	mov    $0x200,%eax
8010257b:	89 c1                	mov    %eax,%ecx
8010257d:	29 d1                	sub    %edx,%ecx
8010257f:	89 ca                	mov    %ecx,%edx
80102581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102584:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102587:	89 cb                	mov    %ecx,%ebx
80102589:	29 c3                	sub    %eax,%ebx
8010258b:	89 d8                	mov    %ebx,%eax
8010258d:	39 c2                	cmp    %eax,%edx
8010258f:	0f 46 c2             	cmovbe %edx,%eax
80102592:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102598:	8d 50 18             	lea    0x18(%eax),%edx
8010259b:	8b 45 10             	mov    0x10(%ebp),%eax
8010259e:	25 ff 01 00 00       	and    $0x1ff,%eax
801025a3:	01 c2                	add    %eax,%edx
801025a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025a8:	89 44 24 08          	mov    %eax,0x8(%esp)
801025ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801025b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b3:	89 04 24             	mov    %eax,(%esp)
801025b6:	e8 2e 30 00 00       	call   801055e9 <memmove>
    brelse(bp);
801025bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025be:	89 04 24             	mov    %eax,(%esp)
801025c1:	e8 51 dc ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801025c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025c9:	01 45 f4             	add    %eax,-0xc(%ebp)
801025cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025cf:	01 45 10             	add    %eax,0x10(%ebp)
801025d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025d5:	01 45 0c             	add    %eax,0xc(%ebp)
801025d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025db:	3b 45 14             	cmp    0x14(%ebp),%eax
801025de:	0f 82 5e ff ff ff    	jb     80102542 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801025e4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801025e7:	83 c4 24             	add    $0x24,%esp
801025ea:	5b                   	pop    %ebx
801025eb:	5d                   	pop    %ebp
801025ec:	c3                   	ret    

801025ed <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801025ed:	55                   	push   %ebp
801025ee:	89 e5                	mov    %esp,%ebp
801025f0:	53                   	push   %ebx
801025f1:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801025f4:	8b 45 08             	mov    0x8(%ebp),%eax
801025f7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025fb:	66 83 f8 03          	cmp    $0x3,%ax
801025ff:	75 60                	jne    80102661 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102601:	8b 45 08             	mov    0x8(%ebp),%eax
80102604:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102608:	66 85 c0             	test   %ax,%ax
8010260b:	78 20                	js     8010262d <writei+0x40>
8010260d:	8b 45 08             	mov    0x8(%ebp),%eax
80102610:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102614:	66 83 f8 09          	cmp    $0x9,%ax
80102618:	7f 13                	jg     8010262d <writei+0x40>
8010261a:	8b 45 08             	mov    0x8(%ebp),%eax
8010261d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102621:	98                   	cwtl   
80102622:	8b 04 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%eax
80102629:	85 c0                	test   %eax,%eax
8010262b:	75 0a                	jne    80102637 <writei+0x4a>
      return -1;
8010262d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102632:	e9 46 01 00 00       	jmp    8010277d <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102637:	8b 45 08             	mov    0x8(%ebp),%eax
8010263a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010263e:	98                   	cwtl   
8010263f:	8b 14 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%edx
80102646:	8b 45 14             	mov    0x14(%ebp),%eax
80102649:	89 44 24 08          	mov    %eax,0x8(%esp)
8010264d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102650:	89 44 24 04          	mov    %eax,0x4(%esp)
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	89 04 24             	mov    %eax,(%esp)
8010265a:	ff d2                	call   *%edx
8010265c:	e9 1c 01 00 00       	jmp    8010277d <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	8b 40 18             	mov    0x18(%eax),%eax
80102667:	3b 45 10             	cmp    0x10(%ebp),%eax
8010266a:	72 0d                	jb     80102679 <writei+0x8c>
8010266c:	8b 45 14             	mov    0x14(%ebp),%eax
8010266f:	8b 55 10             	mov    0x10(%ebp),%edx
80102672:	01 d0                	add    %edx,%eax
80102674:	3b 45 10             	cmp    0x10(%ebp),%eax
80102677:	73 0a                	jae    80102683 <writei+0x96>
    return -1;
80102679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010267e:	e9 fa 00 00 00       	jmp    8010277d <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80102683:	8b 45 14             	mov    0x14(%ebp),%eax
80102686:	8b 55 10             	mov    0x10(%ebp),%edx
80102689:	01 d0                	add    %edx,%eax
8010268b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102690:	76 0a                	jbe    8010269c <writei+0xaf>
    return -1;
80102692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102697:	e9 e1 00 00 00       	jmp    8010277d <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010269c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a3:	e9 a1 00 00 00       	jmp    80102749 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801026a8:	8b 45 10             	mov    0x10(%ebp),%eax
801026ab:	c1 e8 09             	shr    $0x9,%eax
801026ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b2:	8b 45 08             	mov    0x8(%ebp),%eax
801026b5:	89 04 24             	mov    %eax,(%esp)
801026b8:	e8 71 fb ff ff       	call   8010222e <bmap>
801026bd:	8b 55 08             	mov    0x8(%ebp),%edx
801026c0:	8b 12                	mov    (%edx),%edx
801026c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c6:	89 14 24             	mov    %edx,(%esp)
801026c9:	e8 d8 da ff ff       	call   801001a6 <bread>
801026ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801026d1:	8b 45 10             	mov    0x10(%ebp),%eax
801026d4:	89 c2                	mov    %eax,%edx
801026d6:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801026dc:	b8 00 02 00 00       	mov    $0x200,%eax
801026e1:	89 c1                	mov    %eax,%ecx
801026e3:	29 d1                	sub    %edx,%ecx
801026e5:	89 ca                	mov    %ecx,%edx
801026e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ea:	8b 4d 14             	mov    0x14(%ebp),%ecx
801026ed:	89 cb                	mov    %ecx,%ebx
801026ef:	29 c3                	sub    %eax,%ebx
801026f1:	89 d8                	mov    %ebx,%eax
801026f3:	39 c2                	cmp    %eax,%edx
801026f5:	0f 46 c2             	cmovbe %edx,%eax
801026f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801026fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026fe:	8d 50 18             	lea    0x18(%eax),%edx
80102701:	8b 45 10             	mov    0x10(%ebp),%eax
80102704:	25 ff 01 00 00       	and    $0x1ff,%eax
80102709:	01 c2                	add    %eax,%edx
8010270b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010270e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102712:	8b 45 0c             	mov    0xc(%ebp),%eax
80102715:	89 44 24 04          	mov    %eax,0x4(%esp)
80102719:	89 14 24             	mov    %edx,(%esp)
8010271c:	e8 c8 2e 00 00       	call   801055e9 <memmove>
    log_write(bp);
80102721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102724:	89 04 24             	mov    %eax,(%esp)
80102727:	e8 b6 12 00 00       	call   801039e2 <log_write>
    brelse(bp);
8010272c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010272f:	89 04 24             	mov    %eax,(%esp)
80102732:	e8 e0 da ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010273a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010273d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102740:	01 45 10             	add    %eax,0x10(%ebp)
80102743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102746:	01 45 0c             	add    %eax,0xc(%ebp)
80102749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010274f:	0f 82 53 ff ff ff    	jb     801026a8 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102755:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102759:	74 1f                	je     8010277a <writei+0x18d>
8010275b:	8b 45 08             	mov    0x8(%ebp),%eax
8010275e:	8b 40 18             	mov    0x18(%eax),%eax
80102761:	3b 45 10             	cmp    0x10(%ebp),%eax
80102764:	73 14                	jae    8010277a <writei+0x18d>
    ip->size = off;
80102766:	8b 45 08             	mov    0x8(%ebp),%eax
80102769:	8b 55 10             	mov    0x10(%ebp),%edx
8010276c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010276f:	8b 45 08             	mov    0x8(%ebp),%eax
80102772:	89 04 24             	mov    %eax,(%esp)
80102775:	e8 56 f6 ff ff       	call   80101dd0 <iupdate>
  }
  return n;
8010277a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010277d:	83 c4 24             	add    $0x24,%esp
80102780:	5b                   	pop    %ebx
80102781:	5d                   	pop    %ebp
80102782:	c3                   	ret    

80102783 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102783:	55                   	push   %ebp
80102784:	89 e5                	mov    %esp,%ebp
80102786:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102789:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102790:	00 
80102791:	8b 45 0c             	mov    0xc(%ebp),%eax
80102794:	89 44 24 04          	mov    %eax,0x4(%esp)
80102798:	8b 45 08             	mov    0x8(%ebp),%eax
8010279b:	89 04 24             	mov    %eax,(%esp)
8010279e:	e8 ea 2e 00 00       	call   8010568d <strncmp>
}
801027a3:	c9                   	leave  
801027a4:	c3                   	ret    

801027a5 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801027a5:	55                   	push   %ebp
801027a6:	89 e5                	mov    %esp,%ebp
801027a8:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801027ab:	8b 45 08             	mov    0x8(%ebp),%eax
801027ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027b2:	66 83 f8 01          	cmp    $0x1,%ax
801027b6:	74 0c                	je     801027c4 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801027b8:	c7 04 24 15 8a 10 80 	movl   $0x80108a15,(%esp)
801027bf:	e8 79 dd ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801027c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027cb:	e9 87 00 00 00       	jmp    80102857 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801027d0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801027d7:	00 
801027d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027db:	89 44 24 08          	mov    %eax,0x8(%esp)
801027df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801027e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801027e6:	8b 45 08             	mov    0x8(%ebp),%eax
801027e9:	89 04 24             	mov    %eax,(%esp)
801027ec:	e8 91 fc ff ff       	call   80102482 <readi>
801027f1:	83 f8 10             	cmp    $0x10,%eax
801027f4:	74 0c                	je     80102802 <dirlookup+0x5d>
      panic("dirlink read");
801027f6:	c7 04 24 27 8a 10 80 	movl   $0x80108a27,(%esp)
801027fd:	e8 3b dd ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102802:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102806:	66 85 c0             	test   %ax,%ax
80102809:	74 47                	je     80102852 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010280b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010280e:	83 c0 02             	add    $0x2,%eax
80102811:	89 44 24 04          	mov    %eax,0x4(%esp)
80102815:	8b 45 0c             	mov    0xc(%ebp),%eax
80102818:	89 04 24             	mov    %eax,(%esp)
8010281b:	e8 63 ff ff ff       	call   80102783 <namecmp>
80102820:	85 c0                	test   %eax,%eax
80102822:	75 2f                	jne    80102853 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102824:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102828:	74 08                	je     80102832 <dirlookup+0x8d>
        *poff = off;
8010282a:	8b 45 10             	mov    0x10(%ebp),%eax
8010282d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102830:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102832:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102836:	0f b7 c0             	movzwl %ax,%eax
80102839:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	8b 00                	mov    (%eax),%eax
80102841:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102844:	89 54 24 04          	mov    %edx,0x4(%esp)
80102848:	89 04 24             	mov    %eax,(%esp)
8010284b:	e8 38 f6 ff ff       	call   80101e88 <iget>
80102850:	eb 19                	jmp    8010286b <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102852:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102853:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102857:	8b 45 08             	mov    0x8(%ebp),%eax
8010285a:	8b 40 18             	mov    0x18(%eax),%eax
8010285d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102860:	0f 87 6a ff ff ff    	ja     801027d0 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102866:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010286b:	c9                   	leave  
8010286c:	c3                   	ret    

8010286d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010286d:	55                   	push   %ebp
8010286e:	89 e5                	mov    %esp,%ebp
80102870:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102873:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010287a:	00 
8010287b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010287e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	89 04 24             	mov    %eax,(%esp)
80102888:	e8 18 ff ff ff       	call   801027a5 <dirlookup>
8010288d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102894:	74 15                	je     801028ab <dirlink+0x3e>
    iput(ip);
80102896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102899:	89 04 24             	mov    %eax,(%esp)
8010289c:	e8 9e f8 ff ff       	call   8010213f <iput>
    return -1;
801028a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028a6:	e9 b8 00 00 00       	jmp    80102963 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801028ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028b2:	eb 44                	jmp    801028f8 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801028b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801028be:	00 
801028bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801028c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801028c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ca:	8b 45 08             	mov    0x8(%ebp),%eax
801028cd:	89 04 24             	mov    %eax,(%esp)
801028d0:	e8 ad fb ff ff       	call   80102482 <readi>
801028d5:	83 f8 10             	cmp    $0x10,%eax
801028d8:	74 0c                	je     801028e6 <dirlink+0x79>
      panic("dirlink read");
801028da:	c7 04 24 27 8a 10 80 	movl   $0x80108a27,(%esp)
801028e1:	e8 57 dc ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801028e6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028ea:	66 85 c0             	test   %ax,%ax
801028ed:	74 18                	je     80102907 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801028ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f2:	83 c0 10             	add    $0x10,%eax
801028f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028fb:	8b 45 08             	mov    0x8(%ebp),%eax
801028fe:	8b 40 18             	mov    0x18(%eax),%eax
80102901:	39 c2                	cmp    %eax,%edx
80102903:	72 af                	jb     801028b4 <dirlink+0x47>
80102905:	eb 01                	jmp    80102908 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102907:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102908:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010290f:	00 
80102910:	8b 45 0c             	mov    0xc(%ebp),%eax
80102913:	89 44 24 04          	mov    %eax,0x4(%esp)
80102917:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010291a:	83 c0 02             	add    $0x2,%eax
8010291d:	89 04 24             	mov    %eax,(%esp)
80102920:	e8 c0 2d 00 00       	call   801056e5 <strncpy>
  de.inum = inum;
80102925:	8b 45 10             	mov    0x10(%ebp),%eax
80102928:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010292c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010292f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102936:	00 
80102937:	89 44 24 08          	mov    %eax,0x8(%esp)
8010293b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010293e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102942:	8b 45 08             	mov    0x8(%ebp),%eax
80102945:	89 04 24             	mov    %eax,(%esp)
80102948:	e8 a0 fc ff ff       	call   801025ed <writei>
8010294d:	83 f8 10             	cmp    $0x10,%eax
80102950:	74 0c                	je     8010295e <dirlink+0xf1>
    panic("dirlink");
80102952:	c7 04 24 34 8a 10 80 	movl   $0x80108a34,(%esp)
80102959:	e8 df db ff ff       	call   8010053d <panic>
  
  return 0;
8010295e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102963:	c9                   	leave  
80102964:	c3                   	ret    

80102965 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102965:	55                   	push   %ebp
80102966:	89 e5                	mov    %esp,%ebp
80102968:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010296b:	eb 04                	jmp    80102971 <skipelem+0xc>
    path++;
8010296d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102971:	8b 45 08             	mov    0x8(%ebp),%eax
80102974:	0f b6 00             	movzbl (%eax),%eax
80102977:	3c 2f                	cmp    $0x2f,%al
80102979:	74 f2                	je     8010296d <skipelem+0x8>
    path++;
  if(*path == 0)
8010297b:	8b 45 08             	mov    0x8(%ebp),%eax
8010297e:	0f b6 00             	movzbl (%eax),%eax
80102981:	84 c0                	test   %al,%al
80102983:	75 0a                	jne    8010298f <skipelem+0x2a>
    return 0;
80102985:	b8 00 00 00 00       	mov    $0x0,%eax
8010298a:	e9 86 00 00 00       	jmp    80102a15 <skipelem+0xb0>
  s = path;
8010298f:	8b 45 08             	mov    0x8(%ebp),%eax
80102992:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102995:	eb 04                	jmp    8010299b <skipelem+0x36>
    path++;
80102997:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010299b:	8b 45 08             	mov    0x8(%ebp),%eax
8010299e:	0f b6 00             	movzbl (%eax),%eax
801029a1:	3c 2f                	cmp    $0x2f,%al
801029a3:	74 0a                	je     801029af <skipelem+0x4a>
801029a5:	8b 45 08             	mov    0x8(%ebp),%eax
801029a8:	0f b6 00             	movzbl (%eax),%eax
801029ab:	84 c0                	test   %al,%al
801029ad:	75 e8                	jne    80102997 <skipelem+0x32>
    path++;
  len = path - s;
801029af:	8b 55 08             	mov    0x8(%ebp),%edx
801029b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b5:	89 d1                	mov    %edx,%ecx
801029b7:	29 c1                	sub    %eax,%ecx
801029b9:	89 c8                	mov    %ecx,%eax
801029bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801029be:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801029c2:	7e 1c                	jle    801029e0 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801029c4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801029cb:	00 
801029cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d6:	89 04 24             	mov    %eax,(%esp)
801029d9:	e8 0b 2c 00 00       	call   801055e9 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801029de:	eb 28                	jmp    80102a08 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801029e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801029e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f1:	89 04 24             	mov    %eax,(%esp)
801029f4:	e8 f0 2b 00 00       	call   801055e9 <memmove>
    name[len] = 0;
801029f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029fc:	03 45 0c             	add    0xc(%ebp),%eax
801029ff:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102a02:	eb 04                	jmp    80102a08 <skipelem+0xa3>
    path++;
80102a04:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102a08:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0b:	0f b6 00             	movzbl (%eax),%eax
80102a0e:	3c 2f                	cmp    $0x2f,%al
80102a10:	74 f2                	je     80102a04 <skipelem+0x9f>
    path++;
  return path;
80102a12:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102a15:	c9                   	leave  
80102a16:	c3                   	ret    

80102a17 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102a17:	55                   	push   %ebp
80102a18:	89 e5                	mov    %esp,%ebp
80102a1a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a20:	0f b6 00             	movzbl (%eax),%eax
80102a23:	3c 2f                	cmp    $0x2f,%al
80102a25:	75 1c                	jne    80102a43 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102a27:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a2e:	00 
80102a2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a36:	e8 4d f4 ff ff       	call   80101e88 <iget>
80102a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102a3e:	e9 af 00 00 00       	jmp    80102af2 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102a43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102a49:	8b 40 68             	mov    0x68(%eax),%eax
80102a4c:	89 04 24             	mov    %eax,(%esp)
80102a4f:	e8 06 f5 ff ff       	call   80101f5a <idup>
80102a54:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102a57:	e9 96 00 00 00       	jmp    80102af2 <namex+0xdb>
    ilock(ip);
80102a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5f:	89 04 24             	mov    %eax,(%esp)
80102a62:	e8 25 f5 ff ff       	call   80101f8c <ilock>
    if(ip->type != T_DIR){
80102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102a6e:	66 83 f8 01          	cmp    $0x1,%ax
80102a72:	74 15                	je     80102a89 <namex+0x72>
      iunlockput(ip);
80102a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a77:	89 04 24             	mov    %eax,(%esp)
80102a7a:	e8 91 f7 ff ff       	call   80102210 <iunlockput>
      return 0;
80102a7f:	b8 00 00 00 00       	mov    $0x0,%eax
80102a84:	e9 a3 00 00 00       	jmp    80102b2c <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102a8d:	74 1d                	je     80102aac <namex+0x95>
80102a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a92:	0f b6 00             	movzbl (%eax),%eax
80102a95:	84 c0                	test   %al,%al
80102a97:	75 13                	jne    80102aac <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9c:	89 04 24             	mov    %eax,(%esp)
80102a9f:	e8 36 f6 ff ff       	call   801020da <iunlock>
      return ip;
80102aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa7:	e9 80 00 00 00       	jmp    80102b2c <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102aac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102ab3:	00 
80102ab4:	8b 45 10             	mov    0x10(%ebp),%eax
80102ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 df fc ff ff       	call   801027a5 <dirlookup>
80102ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102ac9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102acd:	75 12                	jne    80102ae1 <namex+0xca>
      iunlockput(ip);
80102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad2:	89 04 24             	mov    %eax,(%esp)
80102ad5:	e8 36 f7 ff ff       	call   80102210 <iunlockput>
      return 0;
80102ada:	b8 00 00 00 00       	mov    $0x0,%eax
80102adf:	eb 4b                	jmp    80102b2c <namex+0x115>
    }
    iunlockput(ip);
80102ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae4:	89 04 24             	mov    %eax,(%esp)
80102ae7:	e8 24 f7 ff ff       	call   80102210 <iunlockput>
    ip = next;
80102aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102af2:	8b 45 10             	mov    0x10(%ebp),%eax
80102af5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102af9:	8b 45 08             	mov    0x8(%ebp),%eax
80102afc:	89 04 24             	mov    %eax,(%esp)
80102aff:	e8 61 fe ff ff       	call   80102965 <skipelem>
80102b04:	89 45 08             	mov    %eax,0x8(%ebp)
80102b07:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102b0b:	0f 85 4b ff ff ff    	jne    80102a5c <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102b11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102b15:	74 12                	je     80102b29 <namex+0x112>
    iput(ip);
80102b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1a:	89 04 24             	mov    %eax,(%esp)
80102b1d:	e8 1d f6 ff ff       	call   8010213f <iput>
    return 0;
80102b22:	b8 00 00 00 00       	mov    $0x0,%eax
80102b27:	eb 03                	jmp    80102b2c <namex+0x115>
  }
  return ip;
80102b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b2c:	c9                   	leave  
80102b2d:	c3                   	ret    

80102b2e <namei>:

struct inode*
namei(char *path)
{
80102b2e:	55                   	push   %ebp
80102b2f:	89 e5                	mov    %esp,%ebp
80102b31:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102b34:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102b37:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b42:	00 
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	89 04 24             	mov    %eax,(%esp)
80102b49:	e8 c9 fe ff ff       	call   80102a17 <namex>
}
80102b4e:	c9                   	leave  
80102b4f:	c3                   	ret    

80102b50 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102b50:	55                   	push   %ebp
80102b51:	89 e5                	mov    %esp,%ebp
80102b53:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102b56:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b59:	89 44 24 08          	mov    %eax,0x8(%esp)
80102b5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b64:	00 
80102b65:	8b 45 08             	mov    0x8(%ebp),%eax
80102b68:	89 04 24             	mov    %eax,(%esp)
80102b6b:	e8 a7 fe ff ff       	call   80102a17 <namex>
}
80102b70:	c9                   	leave  
80102b71:	c3                   	ret    
	...

80102b74 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b74:	55                   	push   %ebp
80102b75:	89 e5                	mov    %esp,%ebp
80102b77:	53                   	push   %ebx
80102b78:	83 ec 14             	sub    $0x14,%esp
80102b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b82:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b86:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b8a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b8e:	ec                   	in     (%dx),%al
80102b8f:	89 c3                	mov    %eax,%ebx
80102b91:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b94:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b98:	83 c4 14             	add    $0x14,%esp
80102b9b:	5b                   	pop    %ebx
80102b9c:	5d                   	pop    %ebp
80102b9d:	c3                   	ret    

80102b9e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	57                   	push   %edi
80102ba2:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102ba3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ba9:	8b 45 10             	mov    0x10(%ebp),%eax
80102bac:	89 cb                	mov    %ecx,%ebx
80102bae:	89 df                	mov    %ebx,%edi
80102bb0:	89 c1                	mov    %eax,%ecx
80102bb2:	fc                   	cld    
80102bb3:	f3 6d                	rep insl (%dx),%es:(%edi)
80102bb5:	89 c8                	mov    %ecx,%eax
80102bb7:	89 fb                	mov    %edi,%ebx
80102bb9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102bbc:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102bbf:	5b                   	pop    %ebx
80102bc0:	5f                   	pop    %edi
80102bc1:	5d                   	pop    %ebp
80102bc2:	c3                   	ret    

80102bc3 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102bc3:	55                   	push   %ebp
80102bc4:	89 e5                	mov    %esp,%ebp
80102bc6:	83 ec 08             	sub    $0x8,%esp
80102bc9:	8b 55 08             	mov    0x8(%ebp),%edx
80102bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bcf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102bd3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102bda:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102bde:	ee                   	out    %al,(%dx)
}
80102bdf:	c9                   	leave  
80102be0:	c3                   	ret    

80102be1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102be1:	55                   	push   %ebp
80102be2:	89 e5                	mov    %esp,%ebp
80102be4:	56                   	push   %esi
80102be5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102be6:	8b 55 08             	mov    0x8(%ebp),%edx
80102be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102bec:	8b 45 10             	mov    0x10(%ebp),%eax
80102bef:	89 cb                	mov    %ecx,%ebx
80102bf1:	89 de                	mov    %ebx,%esi
80102bf3:	89 c1                	mov    %eax,%ecx
80102bf5:	fc                   	cld    
80102bf6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102bf8:	89 c8                	mov    %ecx,%eax
80102bfa:	89 f3                	mov    %esi,%ebx
80102bfc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102bff:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102c02:	5b                   	pop    %ebx
80102c03:	5e                   	pop    %esi
80102c04:	5d                   	pop    %ebp
80102c05:	c3                   	ret    

80102c06 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102c0c:	90                   	nop
80102c0d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102c14:	e8 5b ff ff ff       	call   80102b74 <inb>
80102c19:	0f b6 c0             	movzbl %al,%eax
80102c1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102c1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c22:	25 c0 00 00 00       	and    $0xc0,%eax
80102c27:	83 f8 40             	cmp    $0x40,%eax
80102c2a:	75 e1                	jne    80102c0d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102c2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102c30:	74 11                	je     80102c43 <idewait+0x3d>
80102c32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c35:	83 e0 21             	and    $0x21,%eax
80102c38:	85 c0                	test   %eax,%eax
80102c3a:	74 07                	je     80102c43 <idewait+0x3d>
    return -1;
80102c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c41:	eb 05                	jmp    80102c48 <idewait+0x42>
  return 0;
80102c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102c48:	c9                   	leave  
80102c49:	c3                   	ret    

80102c4a <ideinit>:

void
ideinit(void)
{
80102c4a:	55                   	push   %ebp
80102c4b:	89 e5                	mov    %esp,%ebp
80102c4d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102c50:	c7 44 24 04 3c 8a 10 	movl   $0x80108a3c,0x4(%esp)
80102c57:	80 
80102c58:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102c5f:	e8 42 26 00 00       	call   801052a6 <initlock>
  picenable(IRQ_IDE);
80102c64:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102c6b:	e8 75 15 00 00       	call   801041e5 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102c70:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
80102c75:	83 e8 01             	sub    $0x1,%eax
80102c78:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c7c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102c83:	e8 12 04 00 00       	call   8010309a <ioapicenable>
  idewait(0);
80102c88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c8f:	e8 72 ff ff ff       	call   80102c06 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102c94:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102c9b:	00 
80102c9c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102ca3:	e8 1b ff ff ff       	call   80102bc3 <outb>
  for(i=0; i<1000; i++){
80102ca8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102caf:	eb 20                	jmp    80102cd1 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102cb1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102cb8:	e8 b7 fe ff ff       	call   80102b74 <inb>
80102cbd:	84 c0                	test   %al,%al
80102cbf:	74 0c                	je     80102ccd <ideinit+0x83>
      havedisk1 = 1;
80102cc1:	c7 05 f8 c5 10 80 01 	movl   $0x1,0x8010c5f8
80102cc8:	00 00 00 
      break;
80102ccb:	eb 0d                	jmp    80102cda <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102ccd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102cd8:	7e d7                	jle    80102cb1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102cda:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102ce1:	00 
80102ce2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102ce9:	e8 d5 fe ff ff       	call   80102bc3 <outb>
}
80102cee:	c9                   	leave  
80102cef:	c3                   	ret    

80102cf0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102cf0:	55                   	push   %ebp
80102cf1:	89 e5                	mov    %esp,%ebp
80102cf3:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102cf6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cfa:	75 0c                	jne    80102d08 <idestart+0x18>
    panic("idestart");
80102cfc:	c7 04 24 40 8a 10 80 	movl   $0x80108a40,(%esp)
80102d03:	e8 35 d8 ff ff       	call   8010053d <panic>

  idewait(0);
80102d08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102d0f:	e8 f2 fe ff ff       	call   80102c06 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102d14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d1b:	00 
80102d1c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102d23:	e8 9b fe ff ff       	call   80102bc3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102d28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d2f:	00 
80102d30:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102d37:	e8 87 fe ff ff       	call   80102bc3 <outb>
  outb(0x1f3, b->sector & 0xff);
80102d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3f:	8b 40 08             	mov    0x8(%eax),%eax
80102d42:	0f b6 c0             	movzbl %al,%eax
80102d45:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d49:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102d50:	e8 6e fe ff ff       	call   80102bc3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	8b 40 08             	mov    0x8(%eax),%eax
80102d5b:	c1 e8 08             	shr    $0x8,%eax
80102d5e:	0f b6 c0             	movzbl %al,%eax
80102d61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d65:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102d6c:	e8 52 fe ff ff       	call   80102bc3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102d71:	8b 45 08             	mov    0x8(%ebp),%eax
80102d74:	8b 40 08             	mov    0x8(%eax),%eax
80102d77:	c1 e8 10             	shr    $0x10,%eax
80102d7a:	0f b6 c0             	movzbl %al,%eax
80102d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d81:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102d88:	e8 36 fe ff ff       	call   80102bc3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d90:	8b 40 04             	mov    0x4(%eax),%eax
80102d93:	83 e0 01             	and    $0x1,%eax
80102d96:	89 c2                	mov    %eax,%edx
80102d98:	c1 e2 04             	shl    $0x4,%edx
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	8b 40 08             	mov    0x8(%eax),%eax
80102da1:	c1 e8 18             	shr    $0x18,%eax
80102da4:	83 e0 0f             	and    $0xf,%eax
80102da7:	09 d0                	or     %edx,%eax
80102da9:	83 c8 e0             	or     $0xffffffe0,%eax
80102dac:	0f b6 c0             	movzbl %al,%eax
80102daf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102db3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102dba:	e8 04 fe ff ff       	call   80102bc3 <outb>
  if(b->flags & B_DIRTY){
80102dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc2:	8b 00                	mov    (%eax),%eax
80102dc4:	83 e0 04             	and    $0x4,%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	74 34                	je     80102dff <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102dcb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102dd2:	00 
80102dd3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102dda:	e8 e4 fd ff ff       	call   80102bc3 <outb>
    outsl(0x1f0, b->data, 512/4);
80102ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80102de2:	83 c0 18             	add    $0x18,%eax
80102de5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102dec:	00 
80102ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80102df1:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102df8:	e8 e4 fd ff ff       	call   80102be1 <outsl>
80102dfd:	eb 14                	jmp    80102e13 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102dff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102e06:	00 
80102e07:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102e0e:	e8 b0 fd ff ff       	call   80102bc3 <outb>
  }
}
80102e13:	c9                   	leave  
80102e14:	c3                   	ret    

80102e15 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102e15:	55                   	push   %ebp
80102e16:	89 e5                	mov    %esp,%ebp
80102e18:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102e1b:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102e22:	e8 a0 24 00 00       	call   801052c7 <acquire>
  if((b = idequeue) == 0){
80102e27:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80102e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102e2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e33:	75 11                	jne    80102e46 <ideintr+0x31>
    release(&idelock);
80102e35:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102e3c:	e8 e8 24 00 00       	call   80105329 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102e41:	e9 90 00 00 00       	jmp    80102ed6 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e49:	8b 40 14             	mov    0x14(%eax),%eax
80102e4c:	a3 f4 c5 10 80       	mov    %eax,0x8010c5f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e54:	8b 00                	mov    (%eax),%eax
80102e56:	83 e0 04             	and    $0x4,%eax
80102e59:	85 c0                	test   %eax,%eax
80102e5b:	75 2e                	jne    80102e8b <ideintr+0x76>
80102e5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e64:	e8 9d fd ff ff       	call   80102c06 <idewait>
80102e69:	85 c0                	test   %eax,%eax
80102e6b:	78 1e                	js     80102e8b <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e70:	83 c0 18             	add    $0x18,%eax
80102e73:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102e7a:	00 
80102e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e7f:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102e86:	e8 13 fd ff ff       	call   80102b9e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8e:	8b 00                	mov    (%eax),%eax
80102e90:	89 c2                	mov    %eax,%edx
80102e92:	83 ca 02             	or     $0x2,%edx
80102e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e98:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9d:	8b 00                	mov    (%eax),%eax
80102e9f:	89 c2                	mov    %eax,%edx
80102ea1:	83 e2 fb             	and    $0xfffffffb,%edx
80102ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eac:	89 04 24             	mov    %eax,(%esp)
80102eaf:	e8 0e 22 00 00       	call   801050c2 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102eb4:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80102eb9:	85 c0                	test   %eax,%eax
80102ebb:	74 0d                	je     80102eca <ideintr+0xb5>
    idestart(idequeue);
80102ebd:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80102ec2:	89 04 24             	mov    %eax,(%esp)
80102ec5:	e8 26 fe ff ff       	call   80102cf0 <idestart>

  release(&idelock);
80102eca:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102ed1:	e8 53 24 00 00       	call   80105329 <release>
}
80102ed6:	c9                   	leave  
80102ed7:	c3                   	ret    

80102ed8 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ed8:	55                   	push   %ebp
80102ed9:	89 e5                	mov    %esp,%ebp
80102edb:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102ede:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee1:	8b 00                	mov    (%eax),%eax
80102ee3:	83 e0 01             	and    $0x1,%eax
80102ee6:	85 c0                	test   %eax,%eax
80102ee8:	75 0c                	jne    80102ef6 <iderw+0x1e>
    panic("iderw: buf not busy");
80102eea:	c7 04 24 49 8a 10 80 	movl   $0x80108a49,(%esp)
80102ef1:	e8 47 d6 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef9:	8b 00                	mov    (%eax),%eax
80102efb:	83 e0 06             	and    $0x6,%eax
80102efe:	83 f8 02             	cmp    $0x2,%eax
80102f01:	75 0c                	jne    80102f0f <iderw+0x37>
    panic("iderw: nothing to do");
80102f03:	c7 04 24 5d 8a 10 80 	movl   $0x80108a5d,(%esp)
80102f0a:	e8 2e d6 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f12:	8b 40 04             	mov    0x4(%eax),%eax
80102f15:	85 c0                	test   %eax,%eax
80102f17:	74 15                	je     80102f2e <iderw+0x56>
80102f19:	a1 f8 c5 10 80       	mov    0x8010c5f8,%eax
80102f1e:	85 c0                	test   %eax,%eax
80102f20:	75 0c                	jne    80102f2e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102f22:	c7 04 24 72 8a 10 80 	movl   $0x80108a72,(%esp)
80102f29:	e8 0f d6 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102f2e:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102f35:	e8 8d 23 00 00       	call   801052c7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f3d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102f44:	c7 45 f4 f4 c5 10 80 	movl   $0x8010c5f4,-0xc(%ebp)
80102f4b:	eb 0b                	jmp    80102f58 <iderw+0x80>
80102f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f50:	8b 00                	mov    (%eax),%eax
80102f52:	83 c0 14             	add    $0x14,%eax
80102f55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f5b:	8b 00                	mov    (%eax),%eax
80102f5d:	85 c0                	test   %eax,%eax
80102f5f:	75 ec                	jne    80102f4d <iderw+0x75>
    ;
  *pp = b;
80102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f64:	8b 55 08             	mov    0x8(%ebp),%edx
80102f67:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102f69:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80102f6e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102f71:	75 22                	jne    80102f95 <iderw+0xbd>
    idestart(b);
80102f73:	8b 45 08             	mov    0x8(%ebp),%eax
80102f76:	89 04 24             	mov    %eax,(%esp)
80102f79:	e8 72 fd ff ff       	call   80102cf0 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102f7e:	eb 15                	jmp    80102f95 <iderw+0xbd>
    sleep(b, &idelock);
80102f80:	c7 44 24 04 c0 c5 10 	movl   $0x8010c5c0,0x4(%esp)
80102f87:	80 
80102f88:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8b:	89 04 24             	mov    %eax,(%esp)
80102f8e:	e8 56 20 00 00       	call   80104fe9 <sleep>
80102f93:	eb 01                	jmp    80102f96 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102f95:	90                   	nop
80102f96:	8b 45 08             	mov    0x8(%ebp),%eax
80102f99:	8b 00                	mov    (%eax),%eax
80102f9b:	83 e0 06             	and    $0x6,%eax
80102f9e:	83 f8 02             	cmp    $0x2,%eax
80102fa1:	75 dd                	jne    80102f80 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102fa3:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80102faa:	e8 7a 23 00 00       	call   80105329 <release>
}
80102faf:	c9                   	leave  
80102fb0:	c3                   	ret    
80102fb1:	00 00                	add    %al,(%eax)
	...

80102fb4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102fb4:	55                   	push   %ebp
80102fb5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102fb7:	a1 f4 07 11 80       	mov    0x801107f4,%eax
80102fbc:	8b 55 08             	mov    0x8(%ebp),%edx
80102fbf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102fc1:	a1 f4 07 11 80       	mov    0x801107f4,%eax
80102fc6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102fc9:	5d                   	pop    %ebp
80102fca:	c3                   	ret    

80102fcb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102fcb:	55                   	push   %ebp
80102fcc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102fce:	a1 f4 07 11 80       	mov    0x801107f4,%eax
80102fd3:	8b 55 08             	mov    0x8(%ebp),%edx
80102fd6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102fd8:	a1 f4 07 11 80       	mov    0x801107f4,%eax
80102fdd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fe0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102fe3:	5d                   	pop    %ebp
80102fe4:	c3                   	ret    

80102fe5 <ioapicinit>:

void
ioapicinit(void)
{
80102fe5:	55                   	push   %ebp
80102fe6:	89 e5                	mov    %esp,%ebp
80102fe8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102feb:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80102ff0:	85 c0                	test   %eax,%eax
80102ff2:	0f 84 9f 00 00 00    	je     80103097 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ff8:	c7 05 f4 07 11 80 00 	movl   $0xfec00000,0x801107f4
80102fff:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103002:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103009:	e8 a6 ff ff ff       	call   80102fb4 <ioapicread>
8010300e:	c1 e8 10             	shr    $0x10,%eax
80103011:	25 ff 00 00 00       	and    $0xff,%eax
80103016:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80103019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103020:	e8 8f ff ff ff       	call   80102fb4 <ioapicread>
80103025:	c1 e8 18             	shr    $0x18,%eax
80103028:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010302b:	0f b6 05 c0 08 11 80 	movzbl 0x801108c0,%eax
80103032:	0f b6 c0             	movzbl %al,%eax
80103035:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103038:	74 0c                	je     80103046 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010303a:	c7 04 24 90 8a 10 80 	movl   $0x80108a90,(%esp)
80103041:	e8 5b d3 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103046:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010304d:	eb 3e                	jmp    8010308d <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010304f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103052:	83 c0 20             	add    $0x20,%eax
80103055:	0d 00 00 01 00       	or     $0x10000,%eax
8010305a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010305d:	83 c2 08             	add    $0x8,%edx
80103060:	01 d2                	add    %edx,%edx
80103062:	89 44 24 04          	mov    %eax,0x4(%esp)
80103066:	89 14 24             	mov    %edx,(%esp)
80103069:	e8 5d ff ff ff       	call   80102fcb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010306e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103071:	83 c0 08             	add    $0x8,%eax
80103074:	01 c0                	add    %eax,%eax
80103076:	83 c0 01             	add    $0x1,%eax
80103079:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103080:	00 
80103081:	89 04 24             	mov    %eax,(%esp)
80103084:	e8 42 ff ff ff       	call   80102fcb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103089:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010308d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103090:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103093:	7e ba                	jle    8010304f <ioapicinit+0x6a>
80103095:	eb 01                	jmp    80103098 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80103097:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80103098:	c9                   	leave  
80103099:	c3                   	ret    

8010309a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010309a:	55                   	push   %ebp
8010309b:	89 e5                	mov    %esp,%ebp
8010309d:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801030a0:	a1 c4 08 11 80       	mov    0x801108c4,%eax
801030a5:	85 c0                	test   %eax,%eax
801030a7:	74 39                	je     801030e2 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801030a9:	8b 45 08             	mov    0x8(%ebp),%eax
801030ac:	83 c0 20             	add    $0x20,%eax
801030af:	8b 55 08             	mov    0x8(%ebp),%edx
801030b2:	83 c2 08             	add    $0x8,%edx
801030b5:	01 d2                	add    %edx,%edx
801030b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801030bb:	89 14 24             	mov    %edx,(%esp)
801030be:	e8 08 ff ff ff       	call   80102fcb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801030c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030c6:	c1 e0 18             	shl    $0x18,%eax
801030c9:	8b 55 08             	mov    0x8(%ebp),%edx
801030cc:	83 c2 08             	add    $0x8,%edx
801030cf:	01 d2                	add    %edx,%edx
801030d1:	83 c2 01             	add    $0x1,%edx
801030d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801030d8:	89 14 24             	mov    %edx,(%esp)
801030db:	e8 eb fe ff ff       	call   80102fcb <ioapicwrite>
801030e0:	eb 01                	jmp    801030e3 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801030e2:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801030e3:	c9                   	leave  
801030e4:	c3                   	ret    
801030e5:	00 00                	add    %al,(%eax)
	...

801030e8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801030e8:	55                   	push   %ebp
801030e9:	89 e5                	mov    %esp,%ebp
801030eb:	8b 45 08             	mov    0x8(%ebp),%eax
801030ee:	05 00 00 00 80       	add    $0x80000000,%eax
801030f3:	5d                   	pop    %ebp
801030f4:	c3                   	ret    

801030f5 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801030f5:	55                   	push   %ebp
801030f6:	89 e5                	mov    %esp,%ebp
801030f8:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801030fb:	c7 44 24 04 c2 8a 10 	movl   $0x80108ac2,0x4(%esp)
80103102:	80 
80103103:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
8010310a:	e8 97 21 00 00       	call   801052a6 <initlock>
  kmem.use_lock = 0;
8010310f:	c7 05 34 08 11 80 00 	movl   $0x0,0x80110834
80103116:	00 00 00 
  freerange(vstart, vend);
80103119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010311c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103120:	8b 45 08             	mov    0x8(%ebp),%eax
80103123:	89 04 24             	mov    %eax,(%esp)
80103126:	e8 26 00 00 00       	call   80103151 <freerange>
}
8010312b:	c9                   	leave  
8010312c:	c3                   	ret    

8010312d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010312d:	55                   	push   %ebp
8010312e:	89 e5                	mov    %esp,%ebp
80103130:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80103133:	8b 45 0c             	mov    0xc(%ebp),%eax
80103136:	89 44 24 04          	mov    %eax,0x4(%esp)
8010313a:	8b 45 08             	mov    0x8(%ebp),%eax
8010313d:	89 04 24             	mov    %eax,(%esp)
80103140:	e8 0c 00 00 00       	call   80103151 <freerange>
  kmem.use_lock = 1;
80103145:	c7 05 34 08 11 80 01 	movl   $0x1,0x80110834
8010314c:	00 00 00 
}
8010314f:	c9                   	leave  
80103150:	c3                   	ret    

80103151 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103151:	55                   	push   %ebp
80103152:	89 e5                	mov    %esp,%ebp
80103154:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103157:	8b 45 08             	mov    0x8(%ebp),%eax
8010315a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010315f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80103164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103167:	eb 12                	jmp    8010317b <freerange+0x2a>
    kfree(p);
80103169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316c:	89 04 24             	mov    %eax,(%esp)
8010316f:	e8 16 00 00 00       	call   8010318a <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103174:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010317b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010317e:	05 00 10 00 00       	add    $0x1000,%eax
80103183:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103186:	76 e1                	jbe    80103169 <freerange+0x18>
    kfree(p);
}
80103188:	c9                   	leave  
80103189:	c3                   	ret    

8010318a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010318a:	55                   	push   %ebp
8010318b:	89 e5                	mov    %esp,%ebp
8010318d:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80103190:	8b 45 08             	mov    0x8(%ebp),%eax
80103193:	25 ff 0f 00 00       	and    $0xfff,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	75 1b                	jne    801031b7 <kfree+0x2d>
8010319c:	81 7d 08 bc 36 11 80 	cmpl   $0x801136bc,0x8(%ebp)
801031a3:	72 12                	jb     801031b7 <kfree+0x2d>
801031a5:	8b 45 08             	mov    0x8(%ebp),%eax
801031a8:	89 04 24             	mov    %eax,(%esp)
801031ab:	e8 38 ff ff ff       	call   801030e8 <v2p>
801031b0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801031b5:	76 0c                	jbe    801031c3 <kfree+0x39>
    panic("kfree");
801031b7:	c7 04 24 c7 8a 10 80 	movl   $0x80108ac7,(%esp)
801031be:	e8 7a d3 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801031c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801031ca:	00 
801031cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801031d2:	00 
801031d3:	8b 45 08             	mov    0x8(%ebp),%eax
801031d6:	89 04 24             	mov    %eax,(%esp)
801031d9:	e8 38 23 00 00       	call   80105516 <memset>

  if(kmem.use_lock)
801031de:	a1 34 08 11 80       	mov    0x80110834,%eax
801031e3:	85 c0                	test   %eax,%eax
801031e5:	74 0c                	je     801031f3 <kfree+0x69>
    acquire(&kmem.lock);
801031e7:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
801031ee:	e8 d4 20 00 00       	call   801052c7 <acquire>
  r = (struct run*)v;
801031f3:	8b 45 08             	mov    0x8(%ebp),%eax
801031f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801031f9:	8b 15 38 08 11 80    	mov    0x80110838,%edx
801031ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103202:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103207:	a3 38 08 11 80       	mov    %eax,0x80110838
  if(kmem.use_lock)
8010320c:	a1 34 08 11 80       	mov    0x80110834,%eax
80103211:	85 c0                	test   %eax,%eax
80103213:	74 0c                	je     80103221 <kfree+0x97>
    release(&kmem.lock);
80103215:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
8010321c:	e8 08 21 00 00       	call   80105329 <release>
}
80103221:	c9                   	leave  
80103222:	c3                   	ret    

80103223 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103223:	55                   	push   %ebp
80103224:	89 e5                	mov    %esp,%ebp
80103226:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80103229:	a1 34 08 11 80       	mov    0x80110834,%eax
8010322e:	85 c0                	test   %eax,%eax
80103230:	74 0c                	je     8010323e <kalloc+0x1b>
    acquire(&kmem.lock);
80103232:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
80103239:	e8 89 20 00 00       	call   801052c7 <acquire>
  r = kmem.freelist;
8010323e:	a1 38 08 11 80       	mov    0x80110838,%eax
80103243:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103246:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010324a:	74 0a                	je     80103256 <kalloc+0x33>
    kmem.freelist = r->next;
8010324c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010324f:	8b 00                	mov    (%eax),%eax
80103251:	a3 38 08 11 80       	mov    %eax,0x80110838
  if(kmem.use_lock)
80103256:	a1 34 08 11 80       	mov    0x80110834,%eax
8010325b:	85 c0                	test   %eax,%eax
8010325d:	74 0c                	je     8010326b <kalloc+0x48>
    release(&kmem.lock);
8010325f:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
80103266:	e8 be 20 00 00       	call   80105329 <release>
  return (char*)r;
8010326b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010326e:	c9                   	leave  
8010326f:	c3                   	ret    

80103270 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103270:	55                   	push   %ebp
80103271:	89 e5                	mov    %esp,%ebp
80103273:	53                   	push   %ebx
80103274:	83 ec 14             	sub    $0x14,%esp
80103277:	8b 45 08             	mov    0x8(%ebp),%eax
8010327a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010327e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103282:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103286:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010328a:	ec                   	in     (%dx),%al
8010328b:	89 c3                	mov    %eax,%ebx
8010328d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103290:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103294:	83 c4 14             	add    $0x14,%esp
80103297:	5b                   	pop    %ebx
80103298:	5d                   	pop    %ebp
80103299:	c3                   	ret    

8010329a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010329a:	55                   	push   %ebp
8010329b:	89 e5                	mov    %esp,%ebp
8010329d:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801032a0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801032a7:	e8 c4 ff ff ff       	call   80103270 <inb>
801032ac:	0f b6 c0             	movzbl %al,%eax
801032af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801032b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b5:	83 e0 01             	and    $0x1,%eax
801032b8:	85 c0                	test   %eax,%eax
801032ba:	75 0a                	jne    801032c6 <kbdgetc+0x2c>
    return -1;
801032bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801032c1:	e9 23 01 00 00       	jmp    801033e9 <kbdgetc+0x14f>
  data = inb(KBDATAP);
801032c6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
801032cd:	e8 9e ff ff ff       	call   80103270 <inb>
801032d2:	0f b6 c0             	movzbl %al,%eax
801032d5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801032d8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801032df:	75 17                	jne    801032f8 <kbdgetc+0x5e>
    shift |= E0ESC;
801032e1:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
801032e6:	83 c8 40             	or     $0x40,%eax
801032e9:	a3 fc c5 10 80       	mov    %eax,0x8010c5fc
    return 0;
801032ee:	b8 00 00 00 00       	mov    $0x0,%eax
801032f3:	e9 f1 00 00 00       	jmp    801033e9 <kbdgetc+0x14f>
  } else if(data & 0x80){
801032f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801032fb:	25 80 00 00 00       	and    $0x80,%eax
80103300:	85 c0                	test   %eax,%eax
80103302:	74 45                	je     80103349 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103304:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
80103309:	83 e0 40             	and    $0x40,%eax
8010330c:	85 c0                	test   %eax,%eax
8010330e:	75 08                	jne    80103318 <kbdgetc+0x7e>
80103310:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103313:	83 e0 7f             	and    $0x7f,%eax
80103316:	eb 03                	jmp    8010331b <kbdgetc+0x81>
80103318:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010331b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010331e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103321:	05 20 90 10 80       	add    $0x80109020,%eax
80103326:	0f b6 00             	movzbl (%eax),%eax
80103329:	83 c8 40             	or     $0x40,%eax
8010332c:	0f b6 c0             	movzbl %al,%eax
8010332f:	f7 d0                	not    %eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
80103338:	21 d0                	and    %edx,%eax
8010333a:	a3 fc c5 10 80       	mov    %eax,0x8010c5fc
    return 0;
8010333f:	b8 00 00 00 00       	mov    $0x0,%eax
80103344:	e9 a0 00 00 00       	jmp    801033e9 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80103349:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
8010334e:	83 e0 40             	and    $0x40,%eax
80103351:	85 c0                	test   %eax,%eax
80103353:	74 14                	je     80103369 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103355:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010335c:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
80103361:	83 e0 bf             	and    $0xffffffbf,%eax
80103364:	a3 fc c5 10 80       	mov    %eax,0x8010c5fc
  }

  shift |= shiftcode[data];
80103369:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010336c:	05 20 90 10 80       	add    $0x80109020,%eax
80103371:	0f b6 00             	movzbl (%eax),%eax
80103374:	0f b6 d0             	movzbl %al,%edx
80103377:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
8010337c:	09 d0                	or     %edx,%eax
8010337e:	a3 fc c5 10 80       	mov    %eax,0x8010c5fc
  shift ^= togglecode[data];
80103383:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103386:	05 20 91 10 80       	add    $0x80109120,%eax
8010338b:	0f b6 00             	movzbl (%eax),%eax
8010338e:	0f b6 d0             	movzbl %al,%edx
80103391:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
80103396:	31 d0                	xor    %edx,%eax
80103398:	a3 fc c5 10 80       	mov    %eax,0x8010c5fc
  c = charcode[shift & (CTL | SHIFT)][data];
8010339d:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
801033a2:	83 e0 03             	and    $0x3,%eax
801033a5:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
801033ac:	03 45 fc             	add    -0x4(%ebp),%eax
801033af:	0f b6 00             	movzbl (%eax),%eax
801033b2:	0f b6 c0             	movzbl %al,%eax
801033b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801033b8:	a1 fc c5 10 80       	mov    0x8010c5fc,%eax
801033bd:	83 e0 08             	and    $0x8,%eax
801033c0:	85 c0                	test   %eax,%eax
801033c2:	74 22                	je     801033e6 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
801033c4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801033c8:	76 0c                	jbe    801033d6 <kbdgetc+0x13c>
801033ca:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801033ce:	77 06                	ja     801033d6 <kbdgetc+0x13c>
      c += 'A' - 'a';
801033d0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801033d4:	eb 10                	jmp    801033e6 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
801033d6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801033da:	76 0a                	jbe    801033e6 <kbdgetc+0x14c>
801033dc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801033e0:	77 04                	ja     801033e6 <kbdgetc+0x14c>
      c += 'a' - 'A';
801033e2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801033e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801033e9:	c9                   	leave  
801033ea:	c3                   	ret    

801033eb <kbdintr>:

void
kbdintr(void)
{
801033eb:	55                   	push   %ebp
801033ec:	89 e5                	mov    %esp,%ebp
801033ee:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801033f1:	c7 04 24 9a 32 10 80 	movl   $0x8010329a,(%esp)
801033f8:	e8 e3 d3 ff ff       	call   801007e0 <consoleintr>
}
801033fd:	c9                   	leave  
801033fe:	c3                   	ret    
	...

80103400 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	83 ec 08             	sub    $0x8,%esp
80103406:	8b 55 08             	mov    0x8(%ebp),%edx
80103409:	8b 45 0c             	mov    0xc(%ebp),%eax
8010340c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103410:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103413:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103417:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010341b:	ee                   	out    %al,(%dx)
}
8010341c:	c9                   	leave  
8010341d:	c3                   	ret    

8010341e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010341e:	55                   	push   %ebp
8010341f:	89 e5                	mov    %esp,%ebp
80103421:	53                   	push   %ebx
80103422:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103425:	9c                   	pushf  
80103426:	5b                   	pop    %ebx
80103427:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010342a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010342d:	83 c4 10             	add    $0x10,%esp
80103430:	5b                   	pop    %ebx
80103431:	5d                   	pop    %ebp
80103432:	c3                   	ret    

80103433 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103433:	55                   	push   %ebp
80103434:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103436:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010343b:	8b 55 08             	mov    0x8(%ebp),%edx
8010343e:	c1 e2 02             	shl    $0x2,%edx
80103441:	01 c2                	add    %eax,%edx
80103443:	8b 45 0c             	mov    0xc(%ebp),%eax
80103446:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103448:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010344d:	83 c0 20             	add    $0x20,%eax
80103450:	8b 00                	mov    (%eax),%eax
}
80103452:	5d                   	pop    %ebp
80103453:	c3                   	ret    

80103454 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103454:	55                   	push   %ebp
80103455:	89 e5                	mov    %esp,%ebp
80103457:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010345a:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010345f:	85 c0                	test   %eax,%eax
80103461:	0f 84 47 01 00 00    	je     801035ae <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103467:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010346e:	00 
8010346f:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103476:	e8 b8 ff ff ff       	call   80103433 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010347b:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103482:	00 
80103483:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010348a:	e8 a4 ff ff ff       	call   80103433 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010348f:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103496:	00 
80103497:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010349e:	e8 90 ff ff ff       	call   80103433 <lapicw>
  lapicw(TICR, 10000000); 
801034a3:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801034aa:	00 
801034ab:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801034b2:	e8 7c ff ff ff       	call   80103433 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801034b7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034be:	00 
801034bf:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801034c6:	e8 68 ff ff ff       	call   80103433 <lapicw>
  lapicw(LINT1, MASKED);
801034cb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034d2:	00 
801034d3:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801034da:	e8 54 ff ff ff       	call   80103433 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801034df:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801034e4:	83 c0 30             	add    $0x30,%eax
801034e7:	8b 00                	mov    (%eax),%eax
801034e9:	c1 e8 10             	shr    $0x10,%eax
801034ec:	25 ff 00 00 00       	and    $0xff,%eax
801034f1:	83 f8 03             	cmp    $0x3,%eax
801034f4:	76 14                	jbe    8010350a <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801034f6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801034fd:	00 
801034fe:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103505:	e8 29 ff ff ff       	call   80103433 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010350a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103511:	00 
80103512:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103519:	e8 15 ff ff ff       	call   80103433 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010351e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103525:	00 
80103526:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010352d:	e8 01 ff ff ff       	call   80103433 <lapicw>
  lapicw(ESR, 0);
80103532:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103539:	00 
8010353a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103541:	e8 ed fe ff ff       	call   80103433 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103546:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010354d:	00 
8010354e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103555:	e8 d9 fe ff ff       	call   80103433 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010355a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103561:	00 
80103562:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103569:	e8 c5 fe ff ff       	call   80103433 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010356e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103575:	00 
80103576:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010357d:	e8 b1 fe ff ff       	call   80103433 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103582:	90                   	nop
80103583:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80103588:	05 00 03 00 00       	add    $0x300,%eax
8010358d:	8b 00                	mov    (%eax),%eax
8010358f:	25 00 10 00 00       	and    $0x1000,%eax
80103594:	85 c0                	test   %eax,%eax
80103596:	75 eb                	jne    80103583 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010359f:	00 
801035a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801035a7:	e8 87 fe ff ff       	call   80103433 <lapicw>
801035ac:	eb 01                	jmp    801035af <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801035ae:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801035af:	c9                   	leave  
801035b0:	c3                   	ret    

801035b1 <cpunum>:

int
cpunum(void)
{
801035b1:	55                   	push   %ebp
801035b2:	89 e5                	mov    %esp,%ebp
801035b4:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801035b7:	e8 62 fe ff ff       	call   8010341e <readeflags>
801035bc:	25 00 02 00 00       	and    $0x200,%eax
801035c1:	85 c0                	test   %eax,%eax
801035c3:	74 29                	je     801035ee <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801035c5:	a1 00 c6 10 80       	mov    0x8010c600,%eax
801035ca:	85 c0                	test   %eax,%eax
801035cc:	0f 94 c2             	sete   %dl
801035cf:	83 c0 01             	add    $0x1,%eax
801035d2:	a3 00 c6 10 80       	mov    %eax,0x8010c600
801035d7:	84 d2                	test   %dl,%dl
801035d9:	74 13                	je     801035ee <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801035db:	8b 45 04             	mov    0x4(%ebp),%eax
801035de:	89 44 24 04          	mov    %eax,0x4(%esp)
801035e2:	c7 04 24 d0 8a 10 80 	movl   $0x80108ad0,(%esp)
801035e9:	e8 b3 cd ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801035ee:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801035f3:	85 c0                	test   %eax,%eax
801035f5:	74 0f                	je     80103606 <cpunum+0x55>
    return lapic[ID]>>24;
801035f7:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801035fc:	83 c0 20             	add    $0x20,%eax
801035ff:	8b 00                	mov    (%eax),%eax
80103601:	c1 e8 18             	shr    $0x18,%eax
80103604:	eb 05                	jmp    8010360b <cpunum+0x5a>
  return 0;
80103606:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010360b:	c9                   	leave  
8010360c:	c3                   	ret    

8010360d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010360d:	55                   	push   %ebp
8010360e:	89 e5                	mov    %esp,%ebp
80103610:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103613:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80103618:	85 c0                	test   %eax,%eax
8010361a:	74 14                	je     80103630 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010361c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103623:	00 
80103624:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010362b:	e8 03 fe ff ff       	call   80103433 <lapicw>
}
80103630:	c9                   	leave  
80103631:	c3                   	ret    

80103632 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103632:	55                   	push   %ebp
80103633:	89 e5                	mov    %esp,%ebp
}
80103635:	5d                   	pop    %ebp
80103636:	c3                   	ret    

80103637 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103637:	55                   	push   %ebp
80103638:	89 e5                	mov    %esp,%ebp
8010363a:	83 ec 1c             	sub    $0x1c,%esp
8010363d:	8b 45 08             	mov    0x8(%ebp),%eax
80103640:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103643:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010364a:	00 
8010364b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103652:	e8 a9 fd ff ff       	call   80103400 <outb>
  outb(IO_RTC+1, 0x0A);
80103657:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010365e:	00 
8010365f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103666:	e8 95 fd ff ff       	call   80103400 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010366b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103672:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103675:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010367a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010367d:	8d 50 02             	lea    0x2(%eax),%edx
80103680:	8b 45 0c             	mov    0xc(%ebp),%eax
80103683:	c1 e8 04             	shr    $0x4,%eax
80103686:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103689:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010368d:	c1 e0 18             	shl    $0x18,%eax
80103690:	89 44 24 04          	mov    %eax,0x4(%esp)
80103694:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010369b:	e8 93 fd ff ff       	call   80103433 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801036a0:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801036a7:	00 
801036a8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801036af:	e8 7f fd ff ff       	call   80103433 <lapicw>
  microdelay(200);
801036b4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801036bb:	e8 72 ff ff ff       	call   80103632 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801036c0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801036c7:	00 
801036c8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801036cf:	e8 5f fd ff ff       	call   80103433 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801036d4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801036db:	e8 52 ff ff ff       	call   80103632 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801036e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801036e7:	eb 40                	jmp    80103729 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801036e9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801036ed:	c1 e0 18             	shl    $0x18,%eax
801036f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801036f4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801036fb:	e8 33 fd ff ff       	call   80103433 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103700:	8b 45 0c             	mov    0xc(%ebp),%eax
80103703:	c1 e8 0c             	shr    $0xc,%eax
80103706:	80 cc 06             	or     $0x6,%ah
80103709:	89 44 24 04          	mov    %eax,0x4(%esp)
8010370d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103714:	e8 1a fd ff ff       	call   80103433 <lapicw>
    microdelay(200);
80103719:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103720:	e8 0d ff ff ff       	call   80103632 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103725:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103729:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010372d:	7e ba                	jle    801036e9 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010372f:	c9                   	leave  
80103730:	c3                   	ret    
80103731:	00 00                	add    %al,(%eax)
	...

80103734 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103734:	55                   	push   %ebp
80103735:	89 e5                	mov    %esp,%ebp
80103737:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010373a:	c7 44 24 04 fc 8a 10 	movl   $0x80108afc,0x4(%esp)
80103741:	80 
80103742:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80103749:	e8 58 1b 00 00       	call   801052a6 <initlock>
  readsb(ROOTDEV, &sb);
8010374e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103751:	89 44 24 04          	mov    %eax,0x4(%esp)
80103755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010375c:	e8 af e2 ff ff       	call   80101a10 <readsb>
  log.start = sb.size - sb.nlog;
80103761:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103767:	89 d1                	mov    %edx,%ecx
80103769:	29 c1                	sub    %eax,%ecx
8010376b:	89 c8                	mov    %ecx,%eax
8010376d:	a3 74 08 11 80       	mov    %eax,0x80110874
  log.size = sb.nlog;
80103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103775:	a3 78 08 11 80       	mov    %eax,0x80110878
  log.dev = ROOTDEV;
8010377a:	c7 05 80 08 11 80 01 	movl   $0x1,0x80110880
80103781:	00 00 00 
  recover_from_log();
80103784:	e8 97 01 00 00       	call   80103920 <recover_from_log>
}
80103789:	c9                   	leave  
8010378a:	c3                   	ret    

8010378b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010378b:	55                   	push   %ebp
8010378c:	89 e5                	mov    %esp,%ebp
8010378e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103791:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103798:	e9 89 00 00 00       	jmp    80103826 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010379d:	a1 74 08 11 80       	mov    0x80110874,%eax
801037a2:	03 45 f4             	add    -0xc(%ebp),%eax
801037a5:	83 c0 01             	add    $0x1,%eax
801037a8:	89 c2                	mov    %eax,%edx
801037aa:	a1 80 08 11 80       	mov    0x80110880,%eax
801037af:	89 54 24 04          	mov    %edx,0x4(%esp)
801037b3:	89 04 24             	mov    %eax,(%esp)
801037b6:	e8 eb c9 ff ff       	call   801001a6 <bread>
801037bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801037be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c1:	83 c0 10             	add    $0x10,%eax
801037c4:	8b 04 85 48 08 11 80 	mov    -0x7feef7b8(,%eax,4),%eax
801037cb:	89 c2                	mov    %eax,%edx
801037cd:	a1 80 08 11 80       	mov    0x80110880,%eax
801037d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801037d6:	89 04 24             	mov    %eax,(%esp)
801037d9:	e8 c8 c9 ff ff       	call   801001a6 <bread>
801037de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801037e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037e4:	8d 50 18             	lea    0x18(%eax),%edx
801037e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037ea:	83 c0 18             	add    $0x18,%eax
801037ed:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037f4:	00 
801037f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801037f9:	89 04 24             	mov    %eax,(%esp)
801037fc:	e8 e8 1d 00 00       	call   801055e9 <memmove>
    bwrite(dbuf);  // write dst to disk
80103801:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103804:	89 04 24             	mov    %eax,(%esp)
80103807:	e8 d1 c9 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010380c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010380f:	89 04 24             	mov    %eax,(%esp)
80103812:	e8 00 ca ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103817:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010381a:	89 04 24             	mov    %eax,(%esp)
8010381d:	e8 f5 c9 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103822:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103826:	a1 84 08 11 80       	mov    0x80110884,%eax
8010382b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382e:	0f 8f 69 ff ff ff    	jg     8010379d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103834:	c9                   	leave  
80103835:	c3                   	ret    

80103836 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103836:	55                   	push   %ebp
80103837:	89 e5                	mov    %esp,%ebp
80103839:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010383c:	a1 74 08 11 80       	mov    0x80110874,%eax
80103841:	89 c2                	mov    %eax,%edx
80103843:	a1 80 08 11 80       	mov    0x80110880,%eax
80103848:	89 54 24 04          	mov    %edx,0x4(%esp)
8010384c:	89 04 24             	mov    %eax,(%esp)
8010384f:	e8 52 c9 ff ff       	call   801001a6 <bread>
80103854:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385a:	83 c0 18             	add    $0x18,%eax
8010385d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103863:	8b 00                	mov    (%eax),%eax
80103865:	a3 84 08 11 80       	mov    %eax,0x80110884
  for (i = 0; i < log.lh.n; i++) {
8010386a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103871:	eb 1b                	jmp    8010388e <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103873:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103876:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103879:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010387d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103880:	83 c2 10             	add    $0x10,%edx
80103883:	89 04 95 48 08 11 80 	mov    %eax,-0x7feef7b8(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010388a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010388e:	a1 84 08 11 80       	mov    0x80110884,%eax
80103893:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103896:	7f db                	jg     80103873 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389b:	89 04 24             	mov    %eax,(%esp)
8010389e:	e8 74 c9 ff ff       	call   80100217 <brelse>
}
801038a3:	c9                   	leave  
801038a4:	c3                   	ret    

801038a5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801038a5:	55                   	push   %ebp
801038a6:	89 e5                	mov    %esp,%ebp
801038a8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801038ab:	a1 74 08 11 80       	mov    0x80110874,%eax
801038b0:	89 c2                	mov    %eax,%edx
801038b2:	a1 80 08 11 80       	mov    0x80110880,%eax
801038b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801038bb:	89 04 24             	mov    %eax,(%esp)
801038be:	e8 e3 c8 ff ff       	call   801001a6 <bread>
801038c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801038c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c9:	83 c0 18             	add    $0x18,%eax
801038cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801038cf:	8b 15 84 08 11 80    	mov    0x80110884,%edx
801038d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038d8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801038da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038e1:	eb 1b                	jmp    801038fe <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801038e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e6:	83 c0 10             	add    $0x10,%eax
801038e9:	8b 0c 85 48 08 11 80 	mov    -0x7feef7b8(,%eax,4),%ecx
801038f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038f6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801038fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038fe:	a1 84 08 11 80       	mov    0x80110884,%eax
80103903:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103906:	7f db                	jg     801038e3 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	89 04 24             	mov    %eax,(%esp)
8010390e:	e8 ca c8 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103913:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103916:	89 04 24             	mov    %eax,(%esp)
80103919:	e8 f9 c8 ff ff       	call   80100217 <brelse>
}
8010391e:	c9                   	leave  
8010391f:	c3                   	ret    

80103920 <recover_from_log>:

static void
recover_from_log(void)
{
80103920:	55                   	push   %ebp
80103921:	89 e5                	mov    %esp,%ebp
80103923:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103926:	e8 0b ff ff ff       	call   80103836 <read_head>
  install_trans(); // if committed, copy from log to disk
8010392b:	e8 5b fe ff ff       	call   8010378b <install_trans>
  log.lh.n = 0;
80103930:	c7 05 84 08 11 80 00 	movl   $0x0,0x80110884
80103937:	00 00 00 
  write_head(); // clear the log
8010393a:	e8 66 ff ff ff       	call   801038a5 <write_head>
}
8010393f:	c9                   	leave  
80103940:	c3                   	ret    

80103941 <begin_trans>:

void
begin_trans(void)
{
80103941:	55                   	push   %ebp
80103942:	89 e5                	mov    %esp,%ebp
80103944:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103947:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010394e:	e8 74 19 00 00       	call   801052c7 <acquire>
  while (log.busy) {
80103953:	eb 14                	jmp    80103969 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103955:	c7 44 24 04 40 08 11 	movl   $0x80110840,0x4(%esp)
8010395c:	80 
8010395d:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80103964:	e8 80 16 00 00       	call   80104fe9 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103969:	a1 7c 08 11 80       	mov    0x8011087c,%eax
8010396e:	85 c0                	test   %eax,%eax
80103970:	75 e3                	jne    80103955 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103972:	c7 05 7c 08 11 80 01 	movl   $0x1,0x8011087c
80103979:	00 00 00 
  release(&log.lock);
8010397c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80103983:	e8 a1 19 00 00       	call   80105329 <release>
}
80103988:	c9                   	leave  
80103989:	c3                   	ret    

8010398a <commit_trans>:

void
commit_trans(void)
{
8010398a:	55                   	push   %ebp
8010398b:	89 e5                	mov    %esp,%ebp
8010398d:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103990:	a1 84 08 11 80       	mov    0x80110884,%eax
80103995:	85 c0                	test   %eax,%eax
80103997:	7e 19                	jle    801039b2 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103999:	e8 07 ff ff ff       	call   801038a5 <write_head>
    install_trans(); // Now install writes to home locations
8010399e:	e8 e8 fd ff ff       	call   8010378b <install_trans>
    log.lh.n = 0; 
801039a3:	c7 05 84 08 11 80 00 	movl   $0x0,0x80110884
801039aa:	00 00 00 
    write_head();    // Erase the transaction from the log
801039ad:	e8 f3 fe ff ff       	call   801038a5 <write_head>
  }
  
  acquire(&log.lock);
801039b2:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801039b9:	e8 09 19 00 00       	call   801052c7 <acquire>
  log.busy = 0;
801039be:	c7 05 7c 08 11 80 00 	movl   $0x0,0x8011087c
801039c5:	00 00 00 
  wakeup(&log);
801039c8:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801039cf:	e8 ee 16 00 00       	call   801050c2 <wakeup>
  release(&log.lock);
801039d4:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801039db:	e8 49 19 00 00       	call   80105329 <release>
}
801039e0:	c9                   	leave  
801039e1:	c3                   	ret    

801039e2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801039e2:	55                   	push   %ebp
801039e3:	89 e5                	mov    %esp,%ebp
801039e5:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039e8:	a1 84 08 11 80       	mov    0x80110884,%eax
801039ed:	83 f8 09             	cmp    $0x9,%eax
801039f0:	7f 12                	jg     80103a04 <log_write+0x22>
801039f2:	a1 84 08 11 80       	mov    0x80110884,%eax
801039f7:	8b 15 78 08 11 80    	mov    0x80110878,%edx
801039fd:	83 ea 01             	sub    $0x1,%edx
80103a00:	39 d0                	cmp    %edx,%eax
80103a02:	7c 0c                	jl     80103a10 <log_write+0x2e>
    panic("too big a transaction");
80103a04:	c7 04 24 00 8b 10 80 	movl   $0x80108b00,(%esp)
80103a0b:	e8 2d cb ff ff       	call   8010053d <panic>
  if (!log.busy)
80103a10:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80103a15:	85 c0                	test   %eax,%eax
80103a17:	75 0c                	jne    80103a25 <log_write+0x43>
    panic("write outside of trans");
80103a19:	c7 04 24 16 8b 10 80 	movl   $0x80108b16,(%esp)
80103a20:	e8 18 cb ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103a25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a2c:	eb 1d                	jmp    80103a4b <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a31:	83 c0 10             	add    $0x10,%eax
80103a34:	8b 04 85 48 08 11 80 	mov    -0x7feef7b8(,%eax,4),%eax
80103a3b:	89 c2                	mov    %eax,%edx
80103a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a40:	8b 40 08             	mov    0x8(%eax),%eax
80103a43:	39 c2                	cmp    %eax,%edx
80103a45:	74 10                	je     80103a57 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103a47:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a4b:	a1 84 08 11 80       	mov    0x80110884,%eax
80103a50:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a53:	7f d9                	jg     80103a2e <log_write+0x4c>
80103a55:	eb 01                	jmp    80103a58 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103a57:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103a58:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5b:	8b 40 08             	mov    0x8(%eax),%eax
80103a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a61:	83 c2 10             	add    $0x10,%edx
80103a64:	89 04 95 48 08 11 80 	mov    %eax,-0x7feef7b8(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103a6b:	a1 74 08 11 80       	mov    0x80110874,%eax
80103a70:	03 45 f4             	add    -0xc(%ebp),%eax
80103a73:	83 c0 01             	add    $0x1,%eax
80103a76:	89 c2                	mov    %eax,%edx
80103a78:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7b:	8b 40 04             	mov    0x4(%eax),%eax
80103a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a82:	89 04 24             	mov    %eax,(%esp)
80103a85:	e8 1c c7 ff ff       	call   801001a6 <bread>
80103a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a90:	8d 50 18             	lea    0x18(%eax),%edx
80103a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a96:	83 c0 18             	add    $0x18,%eax
80103a99:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103aa0:	00 
80103aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
80103aa5:	89 04 24             	mov    %eax,(%esp)
80103aa8:	e8 3c 1b 00 00       	call   801055e9 <memmove>
  bwrite(lbuf);
80103aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab0:	89 04 24             	mov    %eax,(%esp)
80103ab3:	e8 25 c7 ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abb:	89 04 24             	mov    %eax,(%esp)
80103abe:	e8 54 c7 ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103ac3:	a1 84 08 11 80       	mov    0x80110884,%eax
80103ac8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103acb:	75 0d                	jne    80103ada <log_write+0xf8>
    log.lh.n++;
80103acd:	a1 84 08 11 80       	mov    0x80110884,%eax
80103ad2:	83 c0 01             	add    $0x1,%eax
80103ad5:	a3 84 08 11 80       	mov    %eax,0x80110884
  b->flags |= B_DIRTY; // XXX prevent eviction
80103ada:	8b 45 08             	mov    0x8(%ebp),%eax
80103add:	8b 00                	mov    (%eax),%eax
80103adf:	89 c2                	mov    %eax,%edx
80103ae1:	83 ca 04             	or     $0x4,%edx
80103ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae7:	89 10                	mov    %edx,(%eax)
}
80103ae9:	c9                   	leave  
80103aea:	c3                   	ret    
	...

80103aec <v2p>:
80103aec:	55                   	push   %ebp
80103aed:	89 e5                	mov    %esp,%ebp
80103aef:	8b 45 08             	mov    0x8(%ebp),%eax
80103af2:	05 00 00 00 80       	add    $0x80000000,%eax
80103af7:	5d                   	pop    %ebp
80103af8:	c3                   	ret    

80103af9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103af9:	55                   	push   %ebp
80103afa:	89 e5                	mov    %esp,%ebp
80103afc:	8b 45 08             	mov    0x8(%ebp),%eax
80103aff:	05 00 00 00 80       	add    $0x80000000,%eax
80103b04:	5d                   	pop    %ebp
80103b05:	c3                   	ret    

80103b06 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103b06:	55                   	push   %ebp
80103b07:	89 e5                	mov    %esp,%ebp
80103b09:	53                   	push   %ebx
80103b0a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103b0d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b10:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103b13:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b16:	89 c3                	mov    %eax,%ebx
80103b18:	89 d8                	mov    %ebx,%eax
80103b1a:	f0 87 02             	lock xchg %eax,(%edx)
80103b1d:	89 c3                	mov    %eax,%ebx
80103b1f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103b22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b25:	83 c4 10             	add    $0x10,%esp
80103b28:	5b                   	pop    %ebx
80103b29:	5d                   	pop    %ebp
80103b2a:	c3                   	ret    

80103b2b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103b2b:	55                   	push   %ebp
80103b2c:	89 e5                	mov    %esp,%ebp
80103b2e:	83 e4 f0             	and    $0xfffffff0,%esp
80103b31:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103b34:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103b3b:	80 
80103b3c:	c7 04 24 bc 36 11 80 	movl   $0x801136bc,(%esp)
80103b43:	e8 ad f5 ff ff       	call   801030f5 <kinit1>
  kvmalloc();      // kernel page table
80103b48:	e8 0d 46 00 00       	call   8010815a <kvmalloc>
  mpinit();        // collect info about this machine
80103b4d:	e8 63 04 00 00       	call   80103fb5 <mpinit>
  lapicinit(mpbcpu());
80103b52:	e8 2e 02 00 00       	call   80103d85 <mpbcpu>
80103b57:	89 04 24             	mov    %eax,(%esp)
80103b5a:	e8 f5 f8 ff ff       	call   80103454 <lapicinit>
  seginit();       // set up segments
80103b5f:	e8 99 3f 00 00       	call   80107afd <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103b64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103b6a:	0f b6 00             	movzbl (%eax),%eax
80103b6d:	0f b6 c0             	movzbl %al,%eax
80103b70:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b74:	c7 04 24 2d 8b 10 80 	movl   $0x80108b2d,(%esp)
80103b7b:	e8 21 c8 ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103b80:	e8 95 06 00 00       	call   8010421a <picinit>
  ioapicinit();    // another interrupt controller
80103b85:	e8 5b f4 ff ff       	call   80102fe5 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103b8a:	e8 c1 d4 ff ff       	call   80101050 <consoleinit>
  uartinit();      // serial port
80103b8f:	e8 b4 32 00 00       	call   80106e48 <uartinit>
  pinit();         // process table
80103b94:	e8 96 0b 00 00       	call   8010472f <pinit>
  tvinit();        // trap vectors
80103b99:	e8 4d 2e 00 00       	call   801069eb <tvinit>
  binit();         // buffer cache
80103b9e:	e8 91 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103ba3:	e8 7c da ff ff       	call   80101624 <fileinit>
  iinit();         // inode cache
80103ba8:	e8 2a e1 ff ff       	call   80101cd7 <iinit>
  ideinit();       // disk
80103bad:	e8 98 f0 ff ff       	call   80102c4a <ideinit>
  if(!ismp)
80103bb2:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80103bb7:	85 c0                	test   %eax,%eax
80103bb9:	75 05                	jne    80103bc0 <main+0x95>
    timerinit();   // uniprocessor timer
80103bbb:	e8 6e 2d 00 00       	call   8010692e <timerinit>
  startothers();   // start other processors
80103bc0:	e8 87 00 00 00       	call   80103c4c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103bc5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103bcc:	8e 
80103bcd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103bd4:	e8 54 f5 ff ff       	call   8010312d <kinit2>
  userinit();      // first user process
80103bd9:	e8 6c 0c 00 00       	call   8010484a <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103bde:	e8 22 00 00 00       	call   80103c05 <mpmain>

80103be3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103be3:	55                   	push   %ebp
80103be4:	89 e5                	mov    %esp,%ebp
80103be6:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103be9:	e8 83 45 00 00       	call   80108171 <switchkvm>
  seginit();
80103bee:	e8 0a 3f 00 00       	call   80107afd <seginit>
  lapicinit(cpunum());
80103bf3:	e8 b9 f9 ff ff       	call   801035b1 <cpunum>
80103bf8:	89 04 24             	mov    %eax,(%esp)
80103bfb:	e8 54 f8 ff ff       	call   80103454 <lapicinit>
  mpmain();
80103c00:	e8 00 00 00 00       	call   80103c05 <mpmain>

80103c05 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103c05:	55                   	push   %ebp
80103c06:	89 e5                	mov    %esp,%ebp
80103c08:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103c0b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c11:	0f b6 00             	movzbl (%eax),%eax
80103c14:	0f b6 c0             	movzbl %al,%eax
80103c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c1b:	c7 04 24 44 8b 10 80 	movl   $0x80108b44,(%esp)
80103c22:	e8 7a c7 ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103c27:	e8 33 2f 00 00       	call   80106b5f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103c2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c32:	05 a8 00 00 00       	add    $0xa8,%eax
80103c37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c3e:	00 
80103c3f:	89 04 24             	mov    %eax,(%esp)
80103c42:	e8 bf fe ff ff       	call   80103b06 <xchg>
  scheduler();     // start running processes
80103c47:	e8 f4 11 00 00       	call   80104e40 <scheduler>

80103c4c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c4c:	55                   	push   %ebp
80103c4d:	89 e5                	mov    %esp,%ebp
80103c4f:	53                   	push   %ebx
80103c50:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103c53:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103c5a:	e8 9a fe ff ff       	call   80103af9 <p2v>
80103c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c62:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c67:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c6b:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103c72:	80 
80103c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c76:	89 04 24             	mov    %eax,(%esp)
80103c79:	e8 6b 19 00 00       	call   801055e9 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c7e:	c7 45 f4 e0 08 11 80 	movl   $0x801108e0,-0xc(%ebp)
80103c85:	e9 86 00 00 00       	jmp    80103d10 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103c8a:	e8 22 f9 ff ff       	call   801035b1 <cpunum>
80103c8f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c95:	05 e0 08 11 80       	add    $0x801108e0,%eax
80103c9a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c9d:	74 69                	je     80103d08 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103c9f:	e8 7f f5 ff ff       	call   80103223 <kalloc>
80103ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103caa:	83 e8 04             	sub    $0x4,%eax
80103cad:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103cb0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103cb6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	83 e8 08             	sub    $0x8,%eax
80103cbe:	c7 00 e3 3b 10 80    	movl   $0x80103be3,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc7:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103cca:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103cd1:	e8 16 fe ff ff       	call   80103aec <v2p>
80103cd6:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdb:	89 04 24             	mov    %eax,(%esp)
80103cde:	e8 09 fe ff ff       	call   80103aec <v2p>
80103ce3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce6:	0f b6 12             	movzbl (%edx),%edx
80103ce9:	0f b6 d2             	movzbl %dl,%edx
80103cec:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cf0:	89 14 24             	mov    %edx,(%esp)
80103cf3:	e8 3f f9 ff ff       	call   80103637 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103cf8:	90                   	nop
80103cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103d02:	85 c0                	test   %eax,%eax
80103d04:	74 f3                	je     80103cf9 <startothers+0xad>
80103d06:	eb 01                	jmp    80103d09 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103d08:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103d09:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103d10:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
80103d15:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d1b:	05 e0 08 11 80       	add    $0x801108e0,%eax
80103d20:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d23:	0f 87 61 ff ff ff    	ja     80103c8a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d29:	83 c4 24             	add    $0x24,%esp
80103d2c:	5b                   	pop    %ebx
80103d2d:	5d                   	pop    %ebp
80103d2e:	c3                   	ret    
	...

80103d30 <p2v>:
80103d30:	55                   	push   %ebp
80103d31:	89 e5                	mov    %esp,%ebp
80103d33:	8b 45 08             	mov    0x8(%ebp),%eax
80103d36:	05 00 00 00 80       	add    $0x80000000,%eax
80103d3b:	5d                   	pop    %ebp
80103d3c:	c3                   	ret    

80103d3d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d3d:	55                   	push   %ebp
80103d3e:	89 e5                	mov    %esp,%ebp
80103d40:	53                   	push   %ebx
80103d41:	83 ec 14             	sub    $0x14,%esp
80103d44:	8b 45 08             	mov    0x8(%ebp),%eax
80103d47:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d4b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103d4f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103d53:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103d57:	ec                   	in     (%dx),%al
80103d58:	89 c3                	mov    %eax,%ebx
80103d5a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103d5d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103d61:	83 c4 14             	add    $0x14,%esp
80103d64:	5b                   	pop    %ebx
80103d65:	5d                   	pop    %ebp
80103d66:	c3                   	ret    

80103d67 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d67:	55                   	push   %ebp
80103d68:	89 e5                	mov    %esp,%ebp
80103d6a:	83 ec 08             	sub    $0x8,%esp
80103d6d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d73:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d77:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d7a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d7e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d82:	ee                   	out    %al,(%dx)
}
80103d83:	c9                   	leave  
80103d84:	c3                   	ret    

80103d85 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103d85:	55                   	push   %ebp
80103d86:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103d88:	a1 04 c6 10 80       	mov    0x8010c604,%eax
80103d8d:	89 c2                	mov    %eax,%edx
80103d8f:	b8 e0 08 11 80       	mov    $0x801108e0,%eax
80103d94:	89 d1                	mov    %edx,%ecx
80103d96:	29 c1                	sub    %eax,%ecx
80103d98:	89 c8                	mov    %ecx,%eax
80103d9a:	c1 f8 02             	sar    $0x2,%eax
80103d9d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103da3:	5d                   	pop    %ebp
80103da4:	c3                   	ret    

80103da5 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103da5:	55                   	push   %ebp
80103da6:	89 e5                	mov    %esp,%ebp
80103da8:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103dab:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103db2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103db9:	eb 13                	jmp    80103dce <sum+0x29>
    sum += addr[i];
80103dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dbe:	03 45 08             	add    0x8(%ebp),%eax
80103dc1:	0f b6 00             	movzbl (%eax),%eax
80103dc4:	0f b6 c0             	movzbl %al,%eax
80103dc7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103dca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103dce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dd1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103dd4:	7c e5                	jl     80103dbb <sum+0x16>
    sum += addr[i];
  return sum;
80103dd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103dd9:	c9                   	leave  
80103dda:	c3                   	ret    

80103ddb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ddb:	55                   	push   %ebp
80103ddc:	89 e5                	mov    %esp,%ebp
80103dde:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103de1:	8b 45 08             	mov    0x8(%ebp),%eax
80103de4:	89 04 24             	mov    %eax,(%esp)
80103de7:	e8 44 ff ff ff       	call   80103d30 <p2v>
80103dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103def:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df2:	03 45 f0             	add    -0x10(%ebp),%eax
80103df5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dfe:	eb 3f                	jmp    80103e3f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103e00:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e07:	00 
80103e08:	c7 44 24 04 58 8b 10 	movl   $0x80108b58,0x4(%esp)
80103e0f:	80 
80103e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e13:	89 04 24             	mov    %eax,(%esp)
80103e16:	e8 72 17 00 00       	call   8010558d <memcmp>
80103e1b:	85 c0                	test   %eax,%eax
80103e1d:	75 1c                	jne    80103e3b <mpsearch1+0x60>
80103e1f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103e26:	00 
80103e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2a:	89 04 24             	mov    %eax,(%esp)
80103e2d:	e8 73 ff ff ff       	call   80103da5 <sum>
80103e32:	84 c0                	test   %al,%al
80103e34:	75 05                	jne    80103e3b <mpsearch1+0x60>
      return (struct mp*)p;
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	eb 11                	jmp    80103e4c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e3b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e42:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e45:	72 b9                	jb     80103e00 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e4c:	c9                   	leave  
80103e4d:	c3                   	ret    

80103e4e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e4e:	55                   	push   %ebp
80103e4f:	89 e5                	mov    %esp,%ebp
80103e51:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e54:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5e:	83 c0 0f             	add    $0xf,%eax
80103e61:	0f b6 00             	movzbl (%eax),%eax
80103e64:	0f b6 c0             	movzbl %al,%eax
80103e67:	89 c2                	mov    %eax,%edx
80103e69:	c1 e2 08             	shl    $0x8,%edx
80103e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6f:	83 c0 0e             	add    $0xe,%eax
80103e72:	0f b6 00             	movzbl (%eax),%eax
80103e75:	0f b6 c0             	movzbl %al,%eax
80103e78:	09 d0                	or     %edx,%eax
80103e7a:	c1 e0 04             	shl    $0x4,%eax
80103e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e84:	74 21                	je     80103ea7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103e86:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e8d:	00 
80103e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e91:	89 04 24             	mov    %eax,(%esp)
80103e94:	e8 42 ff ff ff       	call   80103ddb <mpsearch1>
80103e99:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e9c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ea0:	74 50                	je     80103ef2 <mpsearch+0xa4>
      return mp;
80103ea2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ea5:	eb 5f                	jmp    80103f06 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eaa:	83 c0 14             	add    $0x14,%eax
80103ead:	0f b6 00             	movzbl (%eax),%eax
80103eb0:	0f b6 c0             	movzbl %al,%eax
80103eb3:	89 c2                	mov    %eax,%edx
80103eb5:	c1 e2 08             	shl    $0x8,%edx
80103eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ebb:	83 c0 13             	add    $0x13,%eax
80103ebe:	0f b6 00             	movzbl (%eax),%eax
80103ec1:	0f b6 c0             	movzbl %al,%eax
80103ec4:	09 d0                	or     %edx,%eax
80103ec6:	c1 e0 0a             	shl    $0xa,%eax
80103ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ecf:	2d 00 04 00 00       	sub    $0x400,%eax
80103ed4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103edb:	00 
80103edc:	89 04 24             	mov    %eax,(%esp)
80103edf:	e8 f7 fe ff ff       	call   80103ddb <mpsearch1>
80103ee4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ee7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eeb:	74 05                	je     80103ef2 <mpsearch+0xa4>
      return mp;
80103eed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef0:	eb 14                	jmp    80103f06 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ef2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ef9:	00 
80103efa:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103f01:	e8 d5 fe ff ff       	call   80103ddb <mpsearch1>
}
80103f06:	c9                   	leave  
80103f07:	c3                   	ret    

80103f08 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103f08:	55                   	push   %ebp
80103f09:	89 e5                	mov    %esp,%ebp
80103f0b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103f0e:	e8 3b ff ff ff       	call   80103e4e <mpsearch>
80103f13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1a:	74 0a                	je     80103f26 <mpconfig+0x1e>
80103f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1f:	8b 40 04             	mov    0x4(%eax),%eax
80103f22:	85 c0                	test   %eax,%eax
80103f24:	75 0a                	jne    80103f30 <mpconfig+0x28>
    return 0;
80103f26:	b8 00 00 00 00       	mov    $0x0,%eax
80103f2b:	e9 83 00 00 00       	jmp    80103fb3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f33:	8b 40 04             	mov    0x4(%eax),%eax
80103f36:	89 04 24             	mov    %eax,(%esp)
80103f39:	e8 f2 fd ff ff       	call   80103d30 <p2v>
80103f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f41:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103f48:	00 
80103f49:	c7 44 24 04 5d 8b 10 	movl   $0x80108b5d,0x4(%esp)
80103f50:	80 
80103f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f54:	89 04 24             	mov    %eax,(%esp)
80103f57:	e8 31 16 00 00       	call   8010558d <memcmp>
80103f5c:	85 c0                	test   %eax,%eax
80103f5e:	74 07                	je     80103f67 <mpconfig+0x5f>
    return 0;
80103f60:	b8 00 00 00 00       	mov    $0x0,%eax
80103f65:	eb 4c                	jmp    80103fb3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f6a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f6e:	3c 01                	cmp    $0x1,%al
80103f70:	74 12                	je     80103f84 <mpconfig+0x7c>
80103f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f75:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103f79:	3c 04                	cmp    $0x4,%al
80103f7b:	74 07                	je     80103f84 <mpconfig+0x7c>
    return 0;
80103f7d:	b8 00 00 00 00       	mov    $0x0,%eax
80103f82:	eb 2f                	jmp    80103fb3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f87:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103f8b:	0f b7 c0             	movzwl %ax,%eax
80103f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f95:	89 04 24             	mov    %eax,(%esp)
80103f98:	e8 08 fe ff ff       	call   80103da5 <sum>
80103f9d:	84 c0                	test   %al,%al
80103f9f:	74 07                	je     80103fa8 <mpconfig+0xa0>
    return 0;
80103fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80103fa6:	eb 0b                	jmp    80103fb3 <mpconfig+0xab>
  *pmp = mp;
80103fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fae:	89 10                	mov    %edx,(%eax)
  return conf;
80103fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103fb3:	c9                   	leave  
80103fb4:	c3                   	ret    

80103fb5 <mpinit>:

void
mpinit(void)
{
80103fb5:	55                   	push   %ebp
80103fb6:	89 e5                	mov    %esp,%ebp
80103fb8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103fbb:	c7 05 04 c6 10 80 e0 	movl   $0x801108e0,0x8010c604
80103fc2:	08 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103fc5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103fc8:	89 04 24             	mov    %eax,(%esp)
80103fcb:	e8 38 ff ff ff       	call   80103f08 <mpconfig>
80103fd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103fd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fd7:	0f 84 9c 01 00 00    	je     80104179 <mpinit+0x1c4>
    return;
  ismp = 1;
80103fdd:	c7 05 c4 08 11 80 01 	movl   $0x1,0x801108c4
80103fe4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fea:	8b 40 24             	mov    0x24(%eax),%eax
80103fed:	a3 3c 08 11 80       	mov    %eax,0x8011083c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ff5:	83 c0 2c             	add    $0x2c,%eax
80103ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ffe:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104002:	0f b7 c0             	movzwl %ax,%eax
80104005:	03 45 f0             	add    -0x10(%ebp),%eax
80104008:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010400b:	e9 f4 00 00 00       	jmp    80104104 <mpinit+0x14f>
    switch(*p){
80104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104013:	0f b6 00             	movzbl (%eax),%eax
80104016:	0f b6 c0             	movzbl %al,%eax
80104019:	83 f8 04             	cmp    $0x4,%eax
8010401c:	0f 87 bf 00 00 00    	ja     801040e1 <mpinit+0x12c>
80104022:	8b 04 85 a0 8b 10 80 	mov    -0x7fef7460(,%eax,4),%eax
80104029:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010402b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104031:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104034:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104038:	0f b6 d0             	movzbl %al,%edx
8010403b:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
80104040:	39 c2                	cmp    %eax,%edx
80104042:	74 2d                	je     80104071 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104044:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104047:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010404b:	0f b6 d0             	movzbl %al,%edx
8010404e:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
80104053:	89 54 24 08          	mov    %edx,0x8(%esp)
80104057:	89 44 24 04          	mov    %eax,0x4(%esp)
8010405b:	c7 04 24 62 8b 10 80 	movl   $0x80108b62,(%esp)
80104062:	e8 3a c3 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80104067:	c7 05 c4 08 11 80 00 	movl   $0x0,0x801108c4
8010406e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104071:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104074:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104078:	0f b6 c0             	movzbl %al,%eax
8010407b:	83 e0 02             	and    $0x2,%eax
8010407e:	85 c0                	test   %eax,%eax
80104080:	74 15                	je     80104097 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80104082:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
80104087:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010408d:	05 e0 08 11 80       	add    $0x801108e0,%eax
80104092:	a3 04 c6 10 80       	mov    %eax,0x8010c604
      cpus[ncpu].id = ncpu;
80104097:	8b 15 c0 0e 11 80    	mov    0x80110ec0,%edx
8010409d:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
801040a2:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
801040a8:	81 c2 e0 08 11 80    	add    $0x801108e0,%edx
801040ae:	88 02                	mov    %al,(%edx)
      ncpu++;
801040b0:	a1 c0 0e 11 80       	mov    0x80110ec0,%eax
801040b5:	83 c0 01             	add    $0x1,%eax
801040b8:	a3 c0 0e 11 80       	mov    %eax,0x80110ec0
      p += sizeof(struct mpproc);
801040bd:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801040c1:	eb 41                	jmp    80104104 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801040c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801040c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801040cc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801040d0:	a2 c0 08 11 80       	mov    %al,0x801108c0
      p += sizeof(struct mpioapic);
801040d5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040d9:	eb 29                	jmp    80104104 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801040db:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801040df:	eb 23                	jmp    80104104 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	0f b6 00             	movzbl (%eax),%eax
801040e7:	0f b6 c0             	movzbl %al,%eax
801040ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801040ee:	c7 04 24 80 8b 10 80 	movl   $0x80108b80,(%esp)
801040f5:	e8 a7 c2 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801040fa:	c7 05 c4 08 11 80 00 	movl   $0x0,0x801108c4
80104101:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010410a:	0f 82 00 ff ff ff    	jb     80104010 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104110:	a1 c4 08 11 80       	mov    0x801108c4,%eax
80104115:	85 c0                	test   %eax,%eax
80104117:	75 1d                	jne    80104136 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104119:	c7 05 c0 0e 11 80 01 	movl   $0x1,0x80110ec0
80104120:	00 00 00 
    lapic = 0;
80104123:	c7 05 3c 08 11 80 00 	movl   $0x0,0x8011083c
8010412a:	00 00 00 
    ioapicid = 0;
8010412d:	c6 05 c0 08 11 80 00 	movb   $0x0,0x801108c0
    return;
80104134:	eb 44                	jmp    8010417a <mpinit+0x1c5>
  }

  if(mp->imcrp){
80104136:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104139:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010413d:	84 c0                	test   %al,%al
8010413f:	74 39                	je     8010417a <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104141:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104148:	00 
80104149:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104150:	e8 12 fc ff ff       	call   80103d67 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104155:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010415c:	e8 dc fb ff ff       	call   80103d3d <inb>
80104161:	83 c8 01             	or     $0x1,%eax
80104164:	0f b6 c0             	movzbl %al,%eax
80104167:	89 44 24 04          	mov    %eax,0x4(%esp)
8010416b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104172:	e8 f0 fb ff ff       	call   80103d67 <outb>
80104177:	eb 01                	jmp    8010417a <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104179:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010417a:	c9                   	leave  
8010417b:	c3                   	ret    

8010417c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010417c:	55                   	push   %ebp
8010417d:	89 e5                	mov    %esp,%ebp
8010417f:	83 ec 08             	sub    $0x8,%esp
80104182:	8b 55 08             	mov    0x8(%ebp),%edx
80104185:	8b 45 0c             	mov    0xc(%ebp),%eax
80104188:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010418c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010418f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104193:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104197:	ee                   	out    %al,(%dx)
}
80104198:	c9                   	leave  
80104199:	c3                   	ret    

8010419a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
8010419a:	55                   	push   %ebp
8010419b:	89 e5                	mov    %esp,%ebp
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	8b 45 08             	mov    0x8(%ebp),%eax
801041a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801041a7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041ab:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
801041b1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041b5:	0f b6 c0             	movzbl %al,%eax
801041b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801041bc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801041c3:	e8 b4 ff ff ff       	call   8010417c <outb>
  outb(IO_PIC2+1, mask >> 8);
801041c8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801041cc:	66 c1 e8 08          	shr    $0x8,%ax
801041d0:	0f b6 c0             	movzbl %al,%eax
801041d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801041d7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801041de:	e8 99 ff ff ff       	call   8010417c <outb>
}
801041e3:	c9                   	leave  
801041e4:	c3                   	ret    

801041e5 <picenable>:

void
picenable(int irq)
{
801041e5:	55                   	push   %ebp
801041e6:	89 e5                	mov    %esp,%ebp
801041e8:	53                   	push   %ebx
801041e9:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
801041ec:	8b 45 08             	mov    0x8(%ebp),%eax
801041ef:	ba 01 00 00 00       	mov    $0x1,%edx
801041f4:	89 d3                	mov    %edx,%ebx
801041f6:	89 c1                	mov    %eax,%ecx
801041f8:	d3 e3                	shl    %cl,%ebx
801041fa:	89 d8                	mov    %ebx,%eax
801041fc:	89 c2                	mov    %eax,%edx
801041fe:	f7 d2                	not    %edx
80104200:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104207:	21 d0                	and    %edx,%eax
80104209:	0f b7 c0             	movzwl %ax,%eax
8010420c:	89 04 24             	mov    %eax,(%esp)
8010420f:	e8 86 ff ff ff       	call   8010419a <picsetmask>
}
80104214:	83 c4 04             	add    $0x4,%esp
80104217:	5b                   	pop    %ebx
80104218:	5d                   	pop    %ebp
80104219:	c3                   	ret    

8010421a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010421a:	55                   	push   %ebp
8010421b:	89 e5                	mov    %esp,%ebp
8010421d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104220:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104227:	00 
80104228:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010422f:	e8 48 ff ff ff       	call   8010417c <outb>
  outb(IO_PIC2+1, 0xFF);
80104234:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
8010423b:	00 
8010423c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104243:	e8 34 ff ff ff       	call   8010417c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104248:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010424f:	00 
80104250:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104257:	e8 20 ff ff ff       	call   8010417c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010425c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104263:	00 
80104264:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010426b:	e8 0c ff ff ff       	call   8010417c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104270:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104277:	00 
80104278:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010427f:	e8 f8 fe ff ff       	call   8010417c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104284:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010428b:	00 
8010428c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104293:	e8 e4 fe ff ff       	call   8010417c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104298:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010429f:	00 
801042a0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801042a7:	e8 d0 fe ff ff       	call   8010417c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
801042ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
801042b3:	00 
801042b4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042bb:	e8 bc fe ff ff       	call   8010417c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
801042c0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801042c7:	00 
801042c8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042cf:	e8 a8 fe ff ff       	call   8010417c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
801042d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801042db:	00 
801042dc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801042e3:	e8 94 fe ff ff       	call   8010417c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801042e8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801042ef:	00 
801042f0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801042f7:	e8 80 fe ff ff       	call   8010417c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801042fc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104303:	00 
80104304:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010430b:	e8 6c fe ff ff       	call   8010417c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104310:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104317:	00 
80104318:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010431f:	e8 58 fe ff ff       	call   8010417c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104324:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010432b:	00 
8010432c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104333:	e8 44 fe ff ff       	call   8010417c <outb>

  if(irqmask != 0xFFFF)
80104338:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010433f:	66 83 f8 ff          	cmp    $0xffff,%ax
80104343:	74 12                	je     80104357 <picinit+0x13d>
    picsetmask(irqmask);
80104345:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010434c:	0f b7 c0             	movzwl %ax,%eax
8010434f:	89 04 24             	mov    %eax,(%esp)
80104352:	e8 43 fe ff ff       	call   8010419a <picsetmask>
}
80104357:	c9                   	leave  
80104358:	c3                   	ret    
80104359:	00 00                	add    %al,(%eax)
	...

8010435c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010435c:	55                   	push   %ebp
8010435d:	89 e5                	mov    %esp,%ebp
8010435f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104369:	8b 45 0c             	mov    0xc(%ebp),%eax
8010436c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104372:	8b 45 0c             	mov    0xc(%ebp),%eax
80104375:	8b 10                	mov    (%eax),%edx
80104377:	8b 45 08             	mov    0x8(%ebp),%eax
8010437a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010437c:	e8 bf d2 ff ff       	call   80101640 <filealloc>
80104381:	8b 55 08             	mov    0x8(%ebp),%edx
80104384:	89 02                	mov    %eax,(%edx)
80104386:	8b 45 08             	mov    0x8(%ebp),%eax
80104389:	8b 00                	mov    (%eax),%eax
8010438b:	85 c0                	test   %eax,%eax
8010438d:	0f 84 c8 00 00 00    	je     8010445b <pipealloc+0xff>
80104393:	e8 a8 d2 ff ff       	call   80101640 <filealloc>
80104398:	8b 55 0c             	mov    0xc(%ebp),%edx
8010439b:	89 02                	mov    %eax,(%edx)
8010439d:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a0:	8b 00                	mov    (%eax),%eax
801043a2:	85 c0                	test   %eax,%eax
801043a4:	0f 84 b1 00 00 00    	je     8010445b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801043aa:	e8 74 ee ff ff       	call   80103223 <kalloc>
801043af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043b6:	0f 84 9e 00 00 00    	je     8010445a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
801043bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bf:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801043c6:	00 00 00 
  p->writeopen = 1;
801043c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cc:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801043d3:	00 00 00 
  p->nwrite = 0;
801043d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801043e0:	00 00 00 
  p->nread = 0;
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801043ed:	00 00 00 
  initlock(&p->lock, "pipe");
801043f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f3:	c7 44 24 04 b4 8b 10 	movl   $0x80108bb4,0x4(%esp)
801043fa:	80 
801043fb:	89 04 24             	mov    %eax,(%esp)
801043fe:	e8 a3 0e 00 00       	call   801052a6 <initlock>
  (*f0)->type = FD_PIPE;
80104403:	8b 45 08             	mov    0x8(%ebp),%eax
80104406:	8b 00                	mov    (%eax),%eax
80104408:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010440e:	8b 45 08             	mov    0x8(%ebp),%eax
80104411:	8b 00                	mov    (%eax),%eax
80104413:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104417:	8b 45 08             	mov    0x8(%ebp),%eax
8010441a:	8b 00                	mov    (%eax),%eax
8010441c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104420:	8b 45 08             	mov    0x8(%ebp),%eax
80104423:	8b 00                	mov    (%eax),%eax
80104425:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104428:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010442b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010442e:	8b 00                	mov    (%eax),%eax
80104430:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104436:	8b 45 0c             	mov    0xc(%ebp),%eax
80104439:	8b 00                	mov    (%eax),%eax
8010443b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010443f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104442:	8b 00                	mov    (%eax),%eax
80104444:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104448:	8b 45 0c             	mov    0xc(%ebp),%eax
8010444b:	8b 00                	mov    (%eax),%eax
8010444d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104450:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104453:	b8 00 00 00 00       	mov    $0x0,%eax
80104458:	eb 43                	jmp    8010449d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010445a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010445b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010445f:	74 0b                	je     8010446c <pipealloc+0x110>
    kfree((char*)p);
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	89 04 24             	mov    %eax,(%esp)
80104467:	e8 1e ed ff ff       	call   8010318a <kfree>
  if(*f0)
8010446c:	8b 45 08             	mov    0x8(%ebp),%eax
8010446f:	8b 00                	mov    (%eax),%eax
80104471:	85 c0                	test   %eax,%eax
80104473:	74 0d                	je     80104482 <pipealloc+0x126>
    fileclose(*f0);
80104475:	8b 45 08             	mov    0x8(%ebp),%eax
80104478:	8b 00                	mov    (%eax),%eax
8010447a:	89 04 24             	mov    %eax,(%esp)
8010447d:	e8 66 d2 ff ff       	call   801016e8 <fileclose>
  if(*f1)
80104482:	8b 45 0c             	mov    0xc(%ebp),%eax
80104485:	8b 00                	mov    (%eax),%eax
80104487:	85 c0                	test   %eax,%eax
80104489:	74 0d                	je     80104498 <pipealloc+0x13c>
    fileclose(*f1);
8010448b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010448e:	8b 00                	mov    (%eax),%eax
80104490:	89 04 24             	mov    %eax,(%esp)
80104493:	e8 50 d2 ff ff       	call   801016e8 <fileclose>
  return -1;
80104498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010449d:	c9                   	leave  
8010449e:	c3                   	ret    

8010449f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010449f:	55                   	push   %ebp
801044a0:	89 e5                	mov    %esp,%ebp
801044a2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801044a5:	8b 45 08             	mov    0x8(%ebp),%eax
801044a8:	89 04 24             	mov    %eax,(%esp)
801044ab:	e8 17 0e 00 00       	call   801052c7 <acquire>
  if(writable){
801044b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b4:	74 1f                	je     801044d5 <pipeclose+0x36>
    p->writeopen = 0;
801044b6:	8b 45 08             	mov    0x8(%ebp),%eax
801044b9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801044c0:	00 00 00 
    wakeup(&p->nread);
801044c3:	8b 45 08             	mov    0x8(%ebp),%eax
801044c6:	05 34 02 00 00       	add    $0x234,%eax
801044cb:	89 04 24             	mov    %eax,(%esp)
801044ce:	e8 ef 0b 00 00       	call   801050c2 <wakeup>
801044d3:	eb 1d                	jmp    801044f2 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801044d5:	8b 45 08             	mov    0x8(%ebp),%eax
801044d8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801044df:	00 00 00 
    wakeup(&p->nwrite);
801044e2:	8b 45 08             	mov    0x8(%ebp),%eax
801044e5:	05 38 02 00 00       	add    $0x238,%eax
801044ea:	89 04 24             	mov    %eax,(%esp)
801044ed:	e8 d0 0b 00 00       	call   801050c2 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801044f2:	8b 45 08             	mov    0x8(%ebp),%eax
801044f5:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801044fb:	85 c0                	test   %eax,%eax
801044fd:	75 25                	jne    80104524 <pipeclose+0x85>
801044ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104502:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104508:	85 c0                	test   %eax,%eax
8010450a:	75 18                	jne    80104524 <pipeclose+0x85>
    release(&p->lock);
8010450c:	8b 45 08             	mov    0x8(%ebp),%eax
8010450f:	89 04 24             	mov    %eax,(%esp)
80104512:	e8 12 0e 00 00       	call   80105329 <release>
    kfree((char*)p);
80104517:	8b 45 08             	mov    0x8(%ebp),%eax
8010451a:	89 04 24             	mov    %eax,(%esp)
8010451d:	e8 68 ec ff ff       	call   8010318a <kfree>
80104522:	eb 0b                	jmp    8010452f <pipeclose+0x90>
  } else
    release(&p->lock);
80104524:	8b 45 08             	mov    0x8(%ebp),%eax
80104527:	89 04 24             	mov    %eax,(%esp)
8010452a:	e8 fa 0d 00 00       	call   80105329 <release>
}
8010452f:	c9                   	leave  
80104530:	c3                   	ret    

80104531 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104531:	55                   	push   %ebp
80104532:	89 e5                	mov    %esp,%ebp
80104534:	53                   	push   %ebx
80104535:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104538:	8b 45 08             	mov    0x8(%ebp),%eax
8010453b:	89 04 24             	mov    %eax,(%esp)
8010453e:	e8 84 0d 00 00       	call   801052c7 <acquire>
  for(i = 0; i < n; i++){
80104543:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010454a:	e9 a6 00 00 00       	jmp    801045f5 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010454f:	8b 45 08             	mov    0x8(%ebp),%eax
80104552:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104558:	85 c0                	test   %eax,%eax
8010455a:	74 0d                	je     80104569 <pipewrite+0x38>
8010455c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104562:	8b 40 24             	mov    0x24(%eax),%eax
80104565:	85 c0                	test   %eax,%eax
80104567:	74 15                	je     8010457e <pipewrite+0x4d>
        release(&p->lock);
80104569:	8b 45 08             	mov    0x8(%ebp),%eax
8010456c:	89 04 24             	mov    %eax,(%esp)
8010456f:	e8 b5 0d 00 00       	call   80105329 <release>
        return -1;
80104574:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104579:	e9 9d 00 00 00       	jmp    8010461b <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010457e:	8b 45 08             	mov    0x8(%ebp),%eax
80104581:	05 34 02 00 00       	add    $0x234,%eax
80104586:	89 04 24             	mov    %eax,(%esp)
80104589:	e8 34 0b 00 00       	call   801050c2 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010458e:	8b 45 08             	mov    0x8(%ebp),%eax
80104591:	8b 55 08             	mov    0x8(%ebp),%edx
80104594:	81 c2 38 02 00 00    	add    $0x238,%edx
8010459a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010459e:	89 14 24             	mov    %edx,(%esp)
801045a1:	e8 43 0a 00 00       	call   80104fe9 <sleep>
801045a6:	eb 01                	jmp    801045a9 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801045a8:	90                   	nop
801045a9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ac:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801045b2:	8b 45 08             	mov    0x8(%ebp),%eax
801045b5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801045bb:	05 00 02 00 00       	add    $0x200,%eax
801045c0:	39 c2                	cmp    %eax,%edx
801045c2:	74 8b                	je     8010454f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801045c4:	8b 45 08             	mov    0x8(%ebp),%eax
801045c7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801045cd:	89 c3                	mov    %eax,%ebx
801045cf:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801045d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d8:	03 55 0c             	add    0xc(%ebp),%edx
801045db:	0f b6 0a             	movzbl (%edx),%ecx
801045de:	8b 55 08             	mov    0x8(%ebp),%edx
801045e1:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
801045e5:	8d 50 01             	lea    0x1(%eax),%edx
801045e8:	8b 45 08             	mov    0x8(%ebp),%eax
801045eb:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801045f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	3b 45 10             	cmp    0x10(%ebp),%eax
801045fb:	7c ab                	jl     801045a8 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801045fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104600:	05 34 02 00 00       	add    $0x234,%eax
80104605:	89 04 24             	mov    %eax,(%esp)
80104608:	e8 b5 0a 00 00       	call   801050c2 <wakeup>
  release(&p->lock);
8010460d:	8b 45 08             	mov    0x8(%ebp),%eax
80104610:	89 04 24             	mov    %eax,(%esp)
80104613:	e8 11 0d 00 00       	call   80105329 <release>
  return n;
80104618:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010461b:	83 c4 24             	add    $0x24,%esp
8010461e:	5b                   	pop    %ebx
8010461f:	5d                   	pop    %ebp
80104620:	c3                   	ret    

80104621 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104621:	55                   	push   %ebp
80104622:	89 e5                	mov    %esp,%ebp
80104624:	53                   	push   %ebx
80104625:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104628:	8b 45 08             	mov    0x8(%ebp),%eax
8010462b:	89 04 24             	mov    %eax,(%esp)
8010462e:	e8 94 0c 00 00       	call   801052c7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104633:	eb 3a                	jmp    8010466f <piperead+0x4e>
    if(proc->killed){
80104635:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463b:	8b 40 24             	mov    0x24(%eax),%eax
8010463e:	85 c0                	test   %eax,%eax
80104640:	74 15                	je     80104657 <piperead+0x36>
      release(&p->lock);
80104642:	8b 45 08             	mov    0x8(%ebp),%eax
80104645:	89 04 24             	mov    %eax,(%esp)
80104648:	e8 dc 0c 00 00       	call   80105329 <release>
      return -1;
8010464d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104652:	e9 b6 00 00 00       	jmp    8010470d <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104657:	8b 45 08             	mov    0x8(%ebp),%eax
8010465a:	8b 55 08             	mov    0x8(%ebp),%edx
8010465d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104663:	89 44 24 04          	mov    %eax,0x4(%esp)
80104667:	89 14 24             	mov    %edx,(%esp)
8010466a:	e8 7a 09 00 00       	call   80104fe9 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010466f:	8b 45 08             	mov    0x8(%ebp),%eax
80104672:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104678:	8b 45 08             	mov    0x8(%ebp),%eax
8010467b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104681:	39 c2                	cmp    %eax,%edx
80104683:	75 0d                	jne    80104692 <piperead+0x71>
80104685:	8b 45 08             	mov    0x8(%ebp),%eax
80104688:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010468e:	85 c0                	test   %eax,%eax
80104690:	75 a3                	jne    80104635 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104692:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104699:	eb 49                	jmp    801046e4 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010469b:	8b 45 08             	mov    0x8(%ebp),%eax
8010469e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801046a4:	8b 45 08             	mov    0x8(%ebp),%eax
801046a7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801046ad:	39 c2                	cmp    %eax,%edx
801046af:	74 3d                	je     801046ee <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801046b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b4:	89 c2                	mov    %eax,%edx
801046b6:	03 55 0c             	add    0xc(%ebp),%edx
801046b9:	8b 45 08             	mov    0x8(%ebp),%eax
801046bc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801046c2:	89 c3                	mov    %eax,%ebx
801046c4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801046ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046cd:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
801046d2:	88 0a                	mov    %cl,(%edx)
801046d4:	8d 50 01             	lea    0x1(%eax),%edx
801046d7:	8b 45 08             	mov    0x8(%ebp),%eax
801046da:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801046e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e7:	3b 45 10             	cmp    0x10(%ebp),%eax
801046ea:	7c af                	jl     8010469b <piperead+0x7a>
801046ec:	eb 01                	jmp    801046ef <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801046ee:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801046ef:	8b 45 08             	mov    0x8(%ebp),%eax
801046f2:	05 38 02 00 00       	add    $0x238,%eax
801046f7:	89 04 24             	mov    %eax,(%esp)
801046fa:	e8 c3 09 00 00       	call   801050c2 <wakeup>
  release(&p->lock);
801046ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104702:	89 04 24             	mov    %eax,(%esp)
80104705:	e8 1f 0c 00 00       	call   80105329 <release>
  return i;
8010470a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010470d:	83 c4 24             	add    $0x24,%esp
80104710:	5b                   	pop    %ebx
80104711:	5d                   	pop    %ebp
80104712:	c3                   	ret    
	...

80104714 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104714:	55                   	push   %ebp
80104715:	89 e5                	mov    %esp,%ebp
80104717:	53                   	push   %ebx
80104718:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010471b:	9c                   	pushf  
8010471c:	5b                   	pop    %ebx
8010471d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104720:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104723:	83 c4 10             	add    $0x10,%esp
80104726:	5b                   	pop    %ebx
80104727:	5d                   	pop    %ebp
80104728:	c3                   	ret    

80104729 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010472c:	fb                   	sti    
}
8010472d:	5d                   	pop    %ebp
8010472e:	c3                   	ret    

8010472f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010472f:	55                   	push   %ebp
80104730:	89 e5                	mov    %esp,%ebp
80104732:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104735:	c7 44 24 04 b9 8b 10 	movl   $0x80108bb9,0x4(%esp)
8010473c:	80 
8010473d:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104744:	e8 5d 0b 00 00       	call   801052a6 <initlock>
}
80104749:	c9                   	leave  
8010474a:	c3                   	ret    

8010474b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010474b:	55                   	push   %ebp
8010474c:	89 e5                	mov    %esp,%ebp
8010474e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104751:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104758:	e8 6a 0b 00 00       	call   801052c7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010475d:	c7 45 f4 14 0f 11 80 	movl   $0x80110f14,-0xc(%ebp)
80104764:	eb 0e                	jmp    80104774 <allocproc+0x29>
    if(p->state == UNUSED)
80104766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104769:	8b 40 0c             	mov    0xc(%eax),%eax
8010476c:	85 c0                	test   %eax,%eax
8010476e:	74 23                	je     80104793 <allocproc+0x48>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104770:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104774:	81 7d f4 14 2e 11 80 	cmpl   $0x80112e14,-0xc(%ebp)
8010477b:	72 e9                	jb     80104766 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010477d:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104784:	e8 a0 0b 00 00       	call   80105329 <release>
  return 0;
80104789:	b8 00 00 00 00       	mov    $0x0,%eax
8010478e:	e9 b5 00 00 00       	jmp    80104848 <allocproc+0xfd>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104793:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104797:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010479e:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801047a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a6:	89 42 10             	mov    %eax,0x10(%edx)
801047a9:	83 c0 01             	add    $0x1,%eax
801047ac:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801047b1:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
801047b8:	e8 6c 0b 00 00       	call   80105329 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801047bd:	e8 61 ea ff ff       	call   80103223 <kalloc>
801047c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047c5:	89 42 08             	mov    %eax,0x8(%edx)
801047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cb:	8b 40 08             	mov    0x8(%eax),%eax
801047ce:	85 c0                	test   %eax,%eax
801047d0:	75 11                	jne    801047e3 <allocproc+0x98>
    p->state = UNUSED;
801047d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801047dc:	b8 00 00 00 00       	mov    $0x0,%eax
801047e1:	eb 65                	jmp    80104848 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
801047e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e6:	8b 40 08             	mov    0x8(%eax),%eax
801047e9:	05 00 10 00 00       	add    $0x1000,%eax
801047ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801047f1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801047f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fb:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801047fe:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104802:	ba a0 69 10 80       	mov    $0x801069a0,%edx
80104807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010480a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010480c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104813:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104816:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010481f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104826:	00 
80104827:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010482e:	00 
8010482f:	89 04 24             	mov    %eax,(%esp)
80104832:	e8 df 0c 00 00       	call   80105516 <memset>
  p->context->eip = (uint)forkret;
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010483d:	ba bd 4f 10 80       	mov    $0x80104fbd,%edx
80104842:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104848:	c9                   	leave  
80104849:	c3                   	ret    

8010484a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010484a:	55                   	push   %ebp
8010484b:	89 e5                	mov    %esp,%ebp
8010484d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104850:	e8 f6 fe ff ff       	call   8010474b <allocproc>
80104855:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485b:	a3 08 c6 10 80       	mov    %eax,0x8010c608
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104860:	c7 04 24 23 32 10 80 	movl   $0x80103223,(%esp)
80104867:	e8 31 38 00 00       	call   8010809d <setupkvm>
8010486c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010486f:	89 42 04             	mov    %eax,0x4(%edx)
80104872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104875:	8b 40 04             	mov    0x4(%eax),%eax
80104878:	85 c0                	test   %eax,%eax
8010487a:	75 0c                	jne    80104888 <userinit+0x3e>
    panic("userinit: out of memory?");
8010487c:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
80104883:	e8 b5 bc ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104888:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	8b 40 04             	mov    0x4(%eax),%eax
80104893:	89 54 24 08          	mov    %edx,0x8(%esp)
80104897:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
8010489e:	80 
8010489f:	89 04 24             	mov    %eax,(%esp)
801048a2:	e8 4e 3a 00 00       	call   801082f5 <inituvm>
  p->sz = PGSIZE;
801048a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048aa:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	8b 40 18             	mov    0x18(%eax),%eax
801048b6:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801048bd:	00 
801048be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801048c5:	00 
801048c6:	89 04 24             	mov    %eax,(%esp)
801048c9:	e8 48 0c 00 00       	call   80105516 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801048ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d1:	8b 40 18             	mov    0x18(%eax),%eax
801048d4:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801048da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dd:	8b 40 18             	mov    0x18(%eax),%eax
801048e0:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 40 18             	mov    0x18(%eax),%eax
801048ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ef:	8b 52 18             	mov    0x18(%edx),%edx
801048f2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801048f6:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801048fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fd:	8b 40 18             	mov    0x18(%eax),%eax
80104900:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104903:	8b 52 18             	mov    0x18(%edx),%edx
80104906:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010490a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010490e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104911:	8b 40 18             	mov    0x18(%eax),%eax
80104914:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010491b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491e:	8b 40 18             	mov    0x18(%eax),%eax
80104921:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492b:	8b 40 18             	mov    0x18(%eax),%eax
8010492e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104938:	83 c0 6c             	add    $0x6c,%eax
8010493b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104942:	00 
80104943:	c7 44 24 04 d9 8b 10 	movl   $0x80108bd9,0x4(%esp)
8010494a:	80 
8010494b:	89 04 24             	mov    %eax,(%esp)
8010494e:	e8 f3 0d 00 00       	call   80105746 <safestrcpy>
  p->cwd = namei("/");
80104953:	c7 04 24 e2 8b 10 80 	movl   $0x80108be2,(%esp)
8010495a:	e8 cf e1 ff ff       	call   80102b2e <namei>
8010495f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104962:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104968:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010496f:	c9                   	leave  
80104970:	c3                   	ret    

80104971 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104971:	55                   	push   %ebp
80104972:	89 e5                	mov    %esp,%ebp
80104974:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497d:	8b 00                	mov    (%eax),%eax
8010497f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104982:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104986:	7e 34                	jle    801049bc <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104988:	8b 45 08             	mov    0x8(%ebp),%eax
8010498b:	89 c2                	mov    %eax,%edx
8010498d:	03 55 f4             	add    -0xc(%ebp),%edx
80104990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104996:	8b 40 04             	mov    0x4(%eax),%eax
80104999:	89 54 24 08          	mov    %edx,0x8(%esp)
8010499d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801049a4:	89 04 24             	mov    %eax,(%esp)
801049a7:	e8 c3 3a 00 00       	call   8010846f <allocuvm>
801049ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049b3:	75 41                	jne    801049f6 <growproc+0x85>
      return -1;
801049b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ba:	eb 58                	jmp    80104a14 <growproc+0xa3>
  } else if(n < 0){
801049bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049c0:	79 34                	jns    801049f6 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801049c2:	8b 45 08             	mov    0x8(%ebp),%eax
801049c5:	89 c2                	mov    %eax,%edx
801049c7:	03 55 f4             	add    -0xc(%ebp),%edx
801049ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d0:	8b 40 04             	mov    0x4(%eax),%eax
801049d3:	89 54 24 08          	mov    %edx,0x8(%esp)
801049d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049da:	89 54 24 04          	mov    %edx,0x4(%esp)
801049de:	89 04 24             	mov    %eax,(%esp)
801049e1:	e8 63 3b 00 00       	call   80108549 <deallocuvm>
801049e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049ed:	75 07                	jne    801049f6 <growproc+0x85>
      return -1;
801049ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f4:	eb 1e                	jmp    80104a14 <growproc+0xa3>
  }
  proc->sz = sz;
801049f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ff:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a07:	89 04 24             	mov    %eax,(%esp)
80104a0a:	e8 7f 37 00 00       	call   8010818e <switchuvm>
  return 0;
80104a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a14:	c9                   	leave  
80104a15:	c3                   	ret    

80104a16 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104a16:	55                   	push   %ebp
80104a17:	89 e5                	mov    %esp,%ebp
80104a19:	57                   	push   %edi
80104a1a:	56                   	push   %esi
80104a1b:	53                   	push   %ebx
80104a1c:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104a1f:	e8 27 fd ff ff       	call   8010474b <allocproc>
80104a24:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104a27:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a2b:	75 0a                	jne    80104a37 <fork+0x21>
    return -1;
80104a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a32:	e9 3a 01 00 00       	jmp    80104b71 <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104a37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3d:	8b 10                	mov    (%eax),%edx
80104a3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a45:	8b 40 04             	mov    0x4(%eax),%eax
80104a48:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a4c:	89 04 24             	mov    %eax,(%esp)
80104a4f:	e8 85 3c 00 00       	call   801086d9 <copyuvm>
80104a54:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a57:	89 42 04             	mov    %eax,0x4(%edx)
80104a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a5d:	8b 40 04             	mov    0x4(%eax),%eax
80104a60:	85 c0                	test   %eax,%eax
80104a62:	75 2c                	jne    80104a90 <fork+0x7a>
    kfree(np->kstack);
80104a64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a67:	8b 40 08             	mov    0x8(%eax),%eax
80104a6a:	89 04 24             	mov    %eax,(%esp)
80104a6d:	e8 18 e7 ff ff       	call   8010318a <kfree>
    np->kstack = 0;
80104a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104a7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a7f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a8b:	e9 e1 00 00 00       	jmp    80104b71 <fork+0x15b>
  }
  np->sz = proc->sz;
80104a90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a96:	8b 10                	mov    (%eax),%edx
80104a98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a9b:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104a9d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104aa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aa7:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104aaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aad:	8b 50 18             	mov    0x18(%eax),%edx
80104ab0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab6:	8b 40 18             	mov    0x18(%eax),%eax
80104ab9:	89 c3                	mov    %eax,%ebx
80104abb:	b8 13 00 00 00       	mov    $0x13,%eax
80104ac0:	89 d7                	mov    %edx,%edi
80104ac2:	89 de                	mov    %ebx,%esi
80104ac4:	89 c1                	mov    %eax,%ecx
80104ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104acb:	8b 40 18             	mov    0x18(%eax),%eax
80104ace:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104ad5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104adc:	eb 3d                	jmp    80104b1b <fork+0x105>
    if(proc->ofile[i])
80104ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ae7:	83 c2 08             	add    $0x8,%edx
80104aea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aee:	85 c0                	test   %eax,%eax
80104af0:	74 25                	je     80104b17 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104af2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104afb:	83 c2 08             	add    $0x8,%edx
80104afe:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b02:	89 04 24             	mov    %eax,(%esp)
80104b05:	e8 96 cb ff ff       	call   801016a0 <filedup>
80104b0a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104b0d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104b10:	83 c1 08             	add    $0x8,%ecx
80104b13:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104b17:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104b1b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104b1f:	7e bd                	jle    80104ade <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104b21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b27:	8b 40 68             	mov    0x68(%eax),%eax
80104b2a:	89 04 24             	mov    %eax,(%esp)
80104b2d:	e8 28 d4 ff ff       	call   80101f5a <idup>
80104b32:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104b35:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104b38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b3b:	8b 40 10             	mov    0x10(%eax),%eax
80104b3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104b41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b44:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104b4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b51:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b57:	83 c0 6c             	add    $0x6c,%eax
80104b5a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104b61:	00 
80104b62:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b66:	89 04 24             	mov    %eax,(%esp)
80104b69:	e8 d8 0b 00 00       	call   80105746 <safestrcpy>
  return pid;
80104b6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104b71:	83 c4 2c             	add    $0x2c,%esp
80104b74:	5b                   	pop    %ebx
80104b75:	5e                   	pop    %esi
80104b76:	5f                   	pop    %edi
80104b77:	5d                   	pop    %ebp
80104b78:	c3                   	ret    

80104b79 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104b79:	55                   	push   %ebp
80104b7a:	89 e5                	mov    %esp,%ebp
80104b7c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104b7f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b86:	a1 08 c6 10 80       	mov    0x8010c608,%eax
80104b8b:	39 c2                	cmp    %eax,%edx
80104b8d:	75 0c                	jne    80104b9b <exit+0x22>
    panic("init exiting");
80104b8f:	c7 04 24 e4 8b 10 80 	movl   $0x80108be4,(%esp)
80104b96:	e8 a2 b9 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b9b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ba2:	eb 44                	jmp    80104be8 <exit+0x6f>
    if(proc->ofile[fd]){
80104ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bad:	83 c2 08             	add    $0x8,%edx
80104bb0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bb4:	85 c0                	test   %eax,%eax
80104bb6:	74 2c                	je     80104be4 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104bb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bc1:	83 c2 08             	add    $0x8,%edx
80104bc4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bc8:	89 04 24             	mov    %eax,(%esp)
80104bcb:	e8 18 cb ff ff       	call   801016e8 <fileclose>
      proc->ofile[fd] = 0;
80104bd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bd9:	83 c2 08             	add    $0x8,%edx
80104bdc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104be3:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104be4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104be8:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104bec:	7e b6                	jle    80104ba4 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104bee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf4:	8b 40 68             	mov    0x68(%eax),%eax
80104bf7:	89 04 24             	mov    %eax,(%esp)
80104bfa:	e8 40 d5 ff ff       	call   8010213f <iput>
  proc->cwd = 0;
80104bff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c05:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104c0c:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104c13:	e8 af 06 00 00       	call   801052c7 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104c18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c1e:	8b 40 14             	mov    0x14(%eax),%eax
80104c21:	89 04 24             	mov    %eax,(%esp)
80104c24:	e8 5b 04 00 00       	call   80105084 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c29:	c7 45 f4 14 0f 11 80 	movl   $0x80110f14,-0xc(%ebp)
80104c30:	eb 38                	jmp    80104c6a <exit+0xf1>
    if(p->parent == proc){
80104c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c35:	8b 50 14             	mov    0x14(%eax),%edx
80104c38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3e:	39 c2                	cmp    %eax,%edx
80104c40:	75 24                	jne    80104c66 <exit+0xed>
      p->parent = initproc;
80104c42:	8b 15 08 c6 10 80    	mov    0x8010c608,%edx
80104c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c51:	8b 40 0c             	mov    0xc(%eax),%eax
80104c54:	83 f8 05             	cmp    $0x5,%eax
80104c57:	75 0d                	jne    80104c66 <exit+0xed>
        wakeup1(initproc);
80104c59:	a1 08 c6 10 80       	mov    0x8010c608,%eax
80104c5e:	89 04 24             	mov    %eax,(%esp)
80104c61:	e8 1e 04 00 00       	call   80105084 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c66:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c6a:	81 7d f4 14 2e 11 80 	cmpl   $0x80112e14,-0xc(%ebp)
80104c71:	72 bf                	jb     80104c32 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104c73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c79:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104c80:	e8 54 02 00 00       	call   80104ed9 <sched>
  panic("zombie exit");
80104c85:	c7 04 24 f1 8b 10 80 	movl   $0x80108bf1,(%esp)
80104c8c:	e8 ac b8 ff ff       	call   8010053d <panic>

80104c91 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104c91:	55                   	push   %ebp
80104c92:	89 e5                	mov    %esp,%ebp
80104c94:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104c97:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104c9e:	e8 24 06 00 00       	call   801052c7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104ca3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104caa:	c7 45 f4 14 0f 11 80 	movl   $0x80110f14,-0xc(%ebp)
80104cb1:	e9 9a 00 00 00       	jmp    80104d50 <wait+0xbf>
      if(p->parent != proc)
80104cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb9:	8b 50 14             	mov    0x14(%eax),%edx
80104cbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc2:	39 c2                	cmp    %eax,%edx
80104cc4:	0f 85 81 00 00 00    	jne    80104d4b <wait+0xba>
        continue;
      havekids = 1;
80104cca:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd4:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd7:	83 f8 05             	cmp    $0x5,%eax
80104cda:	75 70                	jne    80104d4c <wait+0xbb>
        // Found one.
        pid = p->pid;
80104cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdf:	8b 40 10             	mov    0x10(%eax),%eax
80104ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce8:	8b 40 08             	mov    0x8(%eax),%eax
80104ceb:	89 04 24             	mov    %eax,(%esp)
80104cee:	e8 97 e4 ff ff       	call   8010318a <kfree>
        p->kstack = 0;
80104cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d00:	8b 40 04             	mov    0x4(%eax),%eax
80104d03:	89 04 24             	mov    %eax,(%esp)
80104d06:	e8 fa 38 00 00       	call   80108605 <freevm>
        p->state = UNUSED;
80104d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d18:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d22:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104d3a:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104d41:	e8 e3 05 00 00       	call   80105329 <release>
        return pid;
80104d46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d49:	eb 53                	jmp    80104d9e <wait+0x10d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104d4b:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d4c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104d50:	81 7d f4 14 2e 11 80 	cmpl   $0x80112e14,-0xc(%ebp)
80104d57:	0f 82 59 ff ff ff    	jb     80104cb6 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104d5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d61:	74 0d                	je     80104d70 <wait+0xdf>
80104d63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d69:	8b 40 24             	mov    0x24(%eax),%eax
80104d6c:	85 c0                	test   %eax,%eax
80104d6e:	74 13                	je     80104d83 <wait+0xf2>
      release(&ptable.lock);
80104d70:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104d77:	e8 ad 05 00 00       	call   80105329 <release>
      return -1;
80104d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d81:	eb 1b                	jmp    80104d9e <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104d83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d89:	c7 44 24 04 e0 0e 11 	movl   $0x80110ee0,0x4(%esp)
80104d90:	80 
80104d91:	89 04 24             	mov    %eax,(%esp)
80104d94:	e8 50 02 00 00       	call   80104fe9 <sleep>
  }
80104d99:	e9 05 ff ff ff       	jmp    80104ca3 <wait+0x12>
}
80104d9e:	c9                   	leave  
80104d9f:	c3                   	ret    

80104da0 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104da0:	55                   	push   %ebp
80104da1:	89 e5                	mov    %esp,%ebp
80104da3:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104da6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dac:	8b 40 18             	mov    0x18(%eax),%eax
80104daf:	8b 40 44             	mov    0x44(%eax),%eax
80104db2:	89 c2                	mov    %eax,%edx
80104db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dba:	8b 40 04             	mov    0x4(%eax),%eax
80104dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dc1:	89 04 24             	mov    %eax,(%esp)
80104dc4:	e8 21 3a 00 00       	call   801087ea <uva2ka>
80104dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104dcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd2:	8b 40 18             	mov    0x18(%eax),%eax
80104dd5:	8b 40 44             	mov    0x44(%eax),%eax
80104dd8:	25 ff 0f 00 00       	and    $0xfff,%eax
80104ddd:	85 c0                	test   %eax,%eax
80104ddf:	75 0c                	jne    80104ded <register_handler+0x4d>
    panic("esp_offset == 0");
80104de1:	c7 04 24 fd 8b 10 80 	movl   $0x80108bfd,(%esp)
80104de8:	e8 50 b7 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104ded:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df3:	8b 40 18             	mov    0x18(%eax),%eax
80104df6:	8b 40 44             	mov    0x44(%eax),%eax
80104df9:	83 e8 04             	sub    $0x4,%eax
80104dfc:	25 ff 0f 00 00       	and    $0xfff,%eax
80104e01:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104e04:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e0b:	8b 52 18             	mov    0x18(%edx),%edx
80104e0e:	8b 52 38             	mov    0x38(%edx),%edx
80104e11:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104e13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e19:	8b 40 18             	mov    0x18(%eax),%eax
80104e1c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e23:	8b 52 18             	mov    0x18(%edx),%edx
80104e26:	8b 52 44             	mov    0x44(%edx),%edx
80104e29:	83 ea 04             	sub    $0x4,%edx
80104e2c:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104e2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e35:	8b 40 18             	mov    0x18(%eax),%eax
80104e38:	8b 55 08             	mov    0x8(%ebp),%edx
80104e3b:	89 50 38             	mov    %edx,0x38(%eax)
}
80104e3e:	c9                   	leave  
80104e3f:	c3                   	ret    

80104e40 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e46:	e8 de f8 ff ff       	call   80104729 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e4b:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104e52:	e8 70 04 00 00       	call   801052c7 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e57:	c7 45 f4 14 0f 11 80 	movl   $0x80110f14,-0xc(%ebp)
80104e5e:	eb 5f                	jmp    80104ebf <scheduler+0x7f>
      if(p->state != RUNNABLE)
80104e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e63:	8b 40 0c             	mov    0xc(%eax),%eax
80104e66:	83 f8 03             	cmp    $0x3,%eax
80104e69:	75 4f                	jne    80104eba <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6e:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e77:	89 04 24             	mov    %eax,(%esp)
80104e7a:	e8 0f 33 00 00       	call   8010818e <switchuvm>
      p->state = RUNNING;
80104e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e82:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104e89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e92:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e99:	83 c2 04             	add    $0x4,%edx
80104e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ea0:	89 14 24             	mov    %edx,(%esp)
80104ea3:	e8 14 09 00 00       	call   801057bc <swtch>
      switchkvm();
80104ea8:	e8 c4 32 00 00       	call   80108171 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104ead:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104eb4:	00 00 00 00 
80104eb8:	eb 01                	jmp    80104ebb <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104eba:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ebb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ebf:	81 7d f4 14 2e 11 80 	cmpl   $0x80112e14,-0xc(%ebp)
80104ec6:	72 98                	jb     80104e60 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ec8:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104ecf:	e8 55 04 00 00       	call   80105329 <release>

  }
80104ed4:	e9 6d ff ff ff       	jmp    80104e46 <scheduler+0x6>

80104ed9 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104edf:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104ee6:	e8 fa 04 00 00       	call   801053e5 <holding>
80104eeb:	85 c0                	test   %eax,%eax
80104eed:	75 0c                	jne    80104efb <sched+0x22>
    panic("sched ptable.lock");
80104eef:	c7 04 24 0d 8c 10 80 	movl   $0x80108c0d,(%esp)
80104ef6:	e8 42 b6 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104efb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f01:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f07:	83 f8 01             	cmp    $0x1,%eax
80104f0a:	74 0c                	je     80104f18 <sched+0x3f>
    panic("sched locks");
80104f0c:	c7 04 24 1f 8c 10 80 	movl   $0x80108c1f,(%esp)
80104f13:	e8 25 b6 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104f18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f1e:	8b 40 0c             	mov    0xc(%eax),%eax
80104f21:	83 f8 04             	cmp    $0x4,%eax
80104f24:	75 0c                	jne    80104f32 <sched+0x59>
    panic("sched running");
80104f26:	c7 04 24 2b 8c 10 80 	movl   $0x80108c2b,(%esp)
80104f2d:	e8 0b b6 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104f32:	e8 dd f7 ff ff       	call   80104714 <readeflags>
80104f37:	25 00 02 00 00       	and    $0x200,%eax
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	74 0c                	je     80104f4c <sched+0x73>
    panic("sched interruptible");
80104f40:	c7 04 24 39 8c 10 80 	movl   $0x80108c39,(%esp)
80104f47:	e8 f1 b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104f4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f52:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104f5b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f61:	8b 40 04             	mov    0x4(%eax),%eax
80104f64:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f6b:	83 c2 1c             	add    $0x1c,%edx
80104f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f72:	89 14 24             	mov    %edx,(%esp)
80104f75:	e8 42 08 00 00       	call   801057bc <swtch>
  cpu->intena = intena;
80104f7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f83:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f89:	c9                   	leave  
80104f8a:	c3                   	ret    

80104f8b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104f8b:	55                   	push   %ebp
80104f8c:	89 e5                	mov    %esp,%ebp
80104f8e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104f91:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104f98:	e8 2a 03 00 00       	call   801052c7 <acquire>
  proc->state = RUNNABLE;
80104f9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104faa:	e8 2a ff ff ff       	call   80104ed9 <sched>
  release(&ptable.lock);
80104faf:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104fb6:	e8 6e 03 00 00       	call   80105329 <release>
}
80104fbb:	c9                   	leave  
80104fbc:	c3                   	ret    

80104fbd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104fbd:	55                   	push   %ebp
80104fbe:	89 e5                	mov    %esp,%ebp
80104fc0:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104fc3:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80104fca:	e8 5a 03 00 00       	call   80105329 <release>

  if (first) {
80104fcf:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	74 0f                	je     80104fe7 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104fd8:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104fdf:	00 00 00 
    initlog();
80104fe2:	e8 4d e7 ff ff       	call   80103734 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104fef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff5:	85 c0                	test   %eax,%eax
80104ff7:	75 0c                	jne    80105005 <sleep+0x1c>
    panic("sleep");
80104ff9:	c7 04 24 4d 8c 10 80 	movl   $0x80108c4d,(%esp)
80105000:	e8 38 b5 ff ff       	call   8010053d <panic>

  if(lk == 0)
80105005:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105009:	75 0c                	jne    80105017 <sleep+0x2e>
    panic("sleep without lk");
8010500b:	c7 04 24 53 8c 10 80 	movl   $0x80108c53,(%esp)
80105012:	e8 26 b5 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105017:	81 7d 0c e0 0e 11 80 	cmpl   $0x80110ee0,0xc(%ebp)
8010501e:	74 17                	je     80105037 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105020:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80105027:	e8 9b 02 00 00       	call   801052c7 <acquire>
    release(lk);
8010502c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010502f:	89 04 24             	mov    %eax,(%esp)
80105032:	e8 f2 02 00 00       	call   80105329 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80105037:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503d:	8b 55 08             	mov    0x8(%ebp),%edx
80105040:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105043:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105049:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105050:	e8 84 fe ff ff       	call   80104ed9 <sched>

  // Tidy up.
  proc->chan = 0;
80105055:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105062:	81 7d 0c e0 0e 11 80 	cmpl   $0x80110ee0,0xc(%ebp)
80105069:	74 17                	je     80105082 <sleep+0x99>
    release(&ptable.lock);
8010506b:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80105072:	e8 b2 02 00 00       	call   80105329 <release>
    acquire(lk);
80105077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010507a:	89 04 24             	mov    %eax,(%esp)
8010507d:	e8 45 02 00 00       	call   801052c7 <acquire>
  }
}
80105082:	c9                   	leave  
80105083:	c3                   	ret    

80105084 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105084:	55                   	push   %ebp
80105085:	89 e5                	mov    %esp,%ebp
80105087:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010508a:	c7 45 fc 14 0f 11 80 	movl   $0x80110f14,-0x4(%ebp)
80105091:	eb 24                	jmp    801050b7 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105093:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105096:	8b 40 0c             	mov    0xc(%eax),%eax
80105099:	83 f8 02             	cmp    $0x2,%eax
8010509c:	75 15                	jne    801050b3 <wakeup1+0x2f>
8010509e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a1:	8b 40 20             	mov    0x20(%eax),%eax
801050a4:	3b 45 08             	cmp    0x8(%ebp),%eax
801050a7:	75 0a                	jne    801050b3 <wakeup1+0x2f>
      p->state = RUNNABLE;
801050a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ac:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050b3:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801050b7:	81 7d fc 14 2e 11 80 	cmpl   $0x80112e14,-0x4(%ebp)
801050be:	72 d3                	jb     80105093 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801050c0:	c9                   	leave  
801050c1:	c3                   	ret    

801050c2 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801050c2:	55                   	push   %ebp
801050c3:	89 e5                	mov    %esp,%ebp
801050c5:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801050c8:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
801050cf:	e8 f3 01 00 00       	call   801052c7 <acquire>
  wakeup1(chan);
801050d4:	8b 45 08             	mov    0x8(%ebp),%eax
801050d7:	89 04 24             	mov    %eax,(%esp)
801050da:	e8 a5 ff ff ff       	call   80105084 <wakeup1>
  release(&ptable.lock);
801050df:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
801050e6:	e8 3e 02 00 00       	call   80105329 <release>
}
801050eb:	c9                   	leave  
801050ec:	c3                   	ret    

801050ed <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801050ed:	55                   	push   %ebp
801050ee:	89 e5                	mov    %esp,%ebp
801050f0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801050f3:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
801050fa:	e8 c8 01 00 00       	call   801052c7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ff:	c7 45 f4 14 0f 11 80 	movl   $0x80110f14,-0xc(%ebp)
80105106:	eb 41                	jmp    80105149 <kill+0x5c>
    if(p->pid == pid){
80105108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510b:	8b 40 10             	mov    0x10(%eax),%eax
8010510e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105111:	75 32                	jne    80105145 <kill+0x58>
      p->killed = 1;
80105113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105116:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010511d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105120:	8b 40 0c             	mov    0xc(%eax),%eax
80105123:	83 f8 02             	cmp    $0x2,%eax
80105126:	75 0a                	jne    80105132 <kill+0x45>
        p->state = RUNNABLE;
80105128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105132:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80105139:	e8 eb 01 00 00       	call   80105329 <release>
      return 0;
8010513e:	b8 00 00 00 00       	mov    $0x0,%eax
80105143:	eb 1e                	jmp    80105163 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105145:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105149:	81 7d f4 14 2e 11 80 	cmpl   $0x80112e14,-0xc(%ebp)
80105150:	72 b6                	jb     80105108 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105152:	c7 04 24 e0 0e 11 80 	movl   $0x80110ee0,(%esp)
80105159:	e8 cb 01 00 00       	call   80105329 <release>
  return -1;
8010515e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105163:	c9                   	leave  
80105164:	c3                   	ret    

80105165 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010516b:	c7 45 f0 14 0f 11 80 	movl   $0x80110f14,-0x10(%ebp)
80105172:	e9 d8 00 00 00       	jmp    8010524f <procdump+0xea>
    if(p->state == UNUSED)
80105177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517a:	8b 40 0c             	mov    0xc(%eax),%eax
8010517d:	85 c0                	test   %eax,%eax
8010517f:	0f 84 c5 00 00 00    	je     8010524a <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105188:	8b 40 0c             	mov    0xc(%eax),%eax
8010518b:	83 f8 05             	cmp    $0x5,%eax
8010518e:	77 23                	ja     801051b3 <procdump+0x4e>
80105190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105193:	8b 40 0c             	mov    0xc(%eax),%eax
80105196:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
8010519d:	85 c0                	test   %eax,%eax
8010519f:	74 12                	je     801051b3 <procdump+0x4e>
      state = states[p->state];
801051a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a4:	8b 40 0c             	mov    0xc(%eax),%eax
801051a7:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801051ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051b1:	eb 07                	jmp    801051ba <procdump+0x55>
    else
      state = "???";
801051b3:	c7 45 ec 64 8c 10 80 	movl   $0x80108c64,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801051ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051bd:	8d 50 6c             	lea    0x6c(%eax),%edx
801051c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c3:	8b 40 10             	mov    0x10(%eax),%eax
801051c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801051ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051cd:	89 54 24 08          	mov    %edx,0x8(%esp)
801051d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801051d5:	c7 04 24 68 8c 10 80 	movl   $0x80108c68,(%esp)
801051dc:	e8 c0 b1 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
801051e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e4:	8b 40 0c             	mov    0xc(%eax),%eax
801051e7:	83 f8 02             	cmp    $0x2,%eax
801051ea:	75 50                	jne    8010523c <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801051ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ef:	8b 40 1c             	mov    0x1c(%eax),%eax
801051f2:	8b 40 0c             	mov    0xc(%eax),%eax
801051f5:	83 c0 08             	add    $0x8,%eax
801051f8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801051fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801051ff:	89 04 24             	mov    %eax,(%esp)
80105202:	e8 71 01 00 00       	call   80105378 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105207:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010520e:	eb 1b                	jmp    8010522b <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105217:	89 44 24 04          	mov    %eax,0x4(%esp)
8010521b:	c7 04 24 71 8c 10 80 	movl   $0x80108c71,(%esp)
80105222:	e8 7a b1 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105227:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010522b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010522f:	7f 0b                	jg     8010523c <procdump+0xd7>
80105231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105234:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105238:	85 c0                	test   %eax,%eax
8010523a:	75 d4                	jne    80105210 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010523c:	c7 04 24 75 8c 10 80 	movl   $0x80108c75,(%esp)
80105243:	e8 59 b1 ff ff       	call   801003a1 <cprintf>
80105248:	eb 01                	jmp    8010524b <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010524a:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010524b:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010524f:	81 7d f0 14 2e 11 80 	cmpl   $0x80112e14,-0x10(%ebp)
80105256:	0f 82 1b ff ff ff    	jb     80105177 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010525c:	c9                   	leave  
8010525d:	c3                   	ret    
	...

80105260 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105260:	55                   	push   %ebp
80105261:	89 e5                	mov    %esp,%ebp
80105263:	53                   	push   %ebx
80105264:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105267:	9c                   	pushf  
80105268:	5b                   	pop    %ebx
80105269:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010526c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010526f:	83 c4 10             	add    $0x10,%esp
80105272:	5b                   	pop    %ebx
80105273:	5d                   	pop    %ebp
80105274:	c3                   	ret    

80105275 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105278:	fa                   	cli    
}
80105279:	5d                   	pop    %ebp
8010527a:	c3                   	ret    

8010527b <sti>:

static inline void
sti(void)
{
8010527b:	55                   	push   %ebp
8010527c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010527e:	fb                   	sti    
}
8010527f:	5d                   	pop    %ebp
80105280:	c3                   	ret    

80105281 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105281:	55                   	push   %ebp
80105282:	89 e5                	mov    %esp,%ebp
80105284:	53                   	push   %ebx
80105285:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105288:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010528b:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010528e:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105291:	89 c3                	mov    %eax,%ebx
80105293:	89 d8                	mov    %ebx,%eax
80105295:	f0 87 02             	lock xchg %eax,(%edx)
80105298:	89 c3                	mov    %eax,%ebx
8010529a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010529d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	5b                   	pop    %ebx
801052a4:	5d                   	pop    %ebp
801052a5:	c3                   	ret    

801052a6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052a6:	55                   	push   %ebp
801052a7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052a9:	8b 45 08             	mov    0x8(%ebp),%eax
801052ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801052af:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052b2:	8b 45 08             	mov    0x8(%ebp),%eax
801052b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052bb:	8b 45 08             	mov    0x8(%ebp),%eax
801052be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052c5:	5d                   	pop    %ebp
801052c6:	c3                   	ret    

801052c7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052c7:	55                   	push   %ebp
801052c8:	89 e5                	mov    %esp,%ebp
801052ca:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052cd:	e8 3d 01 00 00       	call   8010540f <pushcli>
  if(holding(lk))
801052d2:	8b 45 08             	mov    0x8(%ebp),%eax
801052d5:	89 04 24             	mov    %eax,(%esp)
801052d8:	e8 08 01 00 00       	call   801053e5 <holding>
801052dd:	85 c0                	test   %eax,%eax
801052df:	74 0c                	je     801052ed <acquire+0x26>
    panic("acquire");
801052e1:	c7 04 24 a1 8c 10 80 	movl   $0x80108ca1,(%esp)
801052e8:	e8 50 b2 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801052ed:	90                   	nop
801052ee:	8b 45 08             	mov    0x8(%ebp),%eax
801052f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801052f8:	00 
801052f9:	89 04 24             	mov    %eax,(%esp)
801052fc:	e8 80 ff ff ff       	call   80105281 <xchg>
80105301:	85 c0                	test   %eax,%eax
80105303:	75 e9                	jne    801052ee <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105305:	8b 45 08             	mov    0x8(%ebp),%eax
80105308:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010530f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105312:	8b 45 08             	mov    0x8(%ebp),%eax
80105315:	83 c0 0c             	add    $0xc,%eax
80105318:	89 44 24 04          	mov    %eax,0x4(%esp)
8010531c:	8d 45 08             	lea    0x8(%ebp),%eax
8010531f:	89 04 24             	mov    %eax,(%esp)
80105322:	e8 51 00 00 00       	call   80105378 <getcallerpcs>
}
80105327:	c9                   	leave  
80105328:	c3                   	ret    

80105329 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
8010532c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010532f:	8b 45 08             	mov    0x8(%ebp),%eax
80105332:	89 04 24             	mov    %eax,(%esp)
80105335:	e8 ab 00 00 00       	call   801053e5 <holding>
8010533a:	85 c0                	test   %eax,%eax
8010533c:	75 0c                	jne    8010534a <release+0x21>
    panic("release");
8010533e:	c7 04 24 a9 8c 10 80 	movl   $0x80108ca9,(%esp)
80105345:	e8 f3 b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105354:	8b 45 08             	mov    0x8(%ebp),%eax
80105357:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010535e:	8b 45 08             	mov    0x8(%ebp),%eax
80105361:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105368:	00 
80105369:	89 04 24             	mov    %eax,(%esp)
8010536c:	e8 10 ff ff ff       	call   80105281 <xchg>

  popcli();
80105371:	e8 e1 00 00 00       	call   80105457 <popcli>
}
80105376:	c9                   	leave  
80105377:	c3                   	ret    

80105378 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105378:	55                   	push   %ebp
80105379:	89 e5                	mov    %esp,%ebp
8010537b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010537e:	8b 45 08             	mov    0x8(%ebp),%eax
80105381:	83 e8 08             	sub    $0x8,%eax
80105384:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105387:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010538e:	eb 32                	jmp    801053c2 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105390:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105394:	74 47                	je     801053dd <getcallerpcs+0x65>
80105396:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010539d:	76 3e                	jbe    801053dd <getcallerpcs+0x65>
8010539f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053a3:	74 38                	je     801053dd <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a8:	c1 e0 02             	shl    $0x2,%eax
801053ab:	03 45 0c             	add    0xc(%ebp),%eax
801053ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053b1:	8b 52 04             	mov    0x4(%edx),%edx
801053b4:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801053b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b9:	8b 00                	mov    (%eax),%eax
801053bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801053be:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053c2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053c6:	7e c8                	jle    80105390 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053c8:	eb 13                	jmp    801053dd <getcallerpcs+0x65>
    pcs[i] = 0;
801053ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053cd:	c1 e0 02             	shl    $0x2,%eax
801053d0:	03 45 0c             	add    0xc(%ebp),%eax
801053d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053d9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053dd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053e1:	7e e7                	jle    801053ca <getcallerpcs+0x52>
    pcs[i] = 0;
}
801053e3:	c9                   	leave  
801053e4:	c3                   	ret    

801053e5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053e5:	55                   	push   %ebp
801053e6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801053e8:	8b 45 08             	mov    0x8(%ebp),%eax
801053eb:	8b 00                	mov    (%eax),%eax
801053ed:	85 c0                	test   %eax,%eax
801053ef:	74 17                	je     80105408 <holding+0x23>
801053f1:	8b 45 08             	mov    0x8(%ebp),%eax
801053f4:	8b 50 08             	mov    0x8(%eax),%edx
801053f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053fd:	39 c2                	cmp    %eax,%edx
801053ff:	75 07                	jne    80105408 <holding+0x23>
80105401:	b8 01 00 00 00       	mov    $0x1,%eax
80105406:	eb 05                	jmp    8010540d <holding+0x28>
80105408:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010540d:	5d                   	pop    %ebp
8010540e:	c3                   	ret    

8010540f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010540f:	55                   	push   %ebp
80105410:	89 e5                	mov    %esp,%ebp
80105412:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105415:	e8 46 fe ff ff       	call   80105260 <readeflags>
8010541a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010541d:	e8 53 fe ff ff       	call   80105275 <cli>
  if(cpu->ncli++ == 0)
80105422:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105428:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010542e:	85 d2                	test   %edx,%edx
80105430:	0f 94 c1             	sete   %cl
80105433:	83 c2 01             	add    $0x1,%edx
80105436:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010543c:	84 c9                	test   %cl,%cl
8010543e:	74 15                	je     80105455 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105440:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105446:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105449:	81 e2 00 02 00 00    	and    $0x200,%edx
8010544f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105455:	c9                   	leave  
80105456:	c3                   	ret    

80105457 <popcli>:

void
popcli(void)
{
80105457:	55                   	push   %ebp
80105458:	89 e5                	mov    %esp,%ebp
8010545a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010545d:	e8 fe fd ff ff       	call   80105260 <readeflags>
80105462:	25 00 02 00 00       	and    $0x200,%eax
80105467:	85 c0                	test   %eax,%eax
80105469:	74 0c                	je     80105477 <popcli+0x20>
    panic("popcli - interruptible");
8010546b:	c7 04 24 b1 8c 10 80 	movl   $0x80108cb1,(%esp)
80105472:	e8 c6 b0 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105477:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010547d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105483:	83 ea 01             	sub    $0x1,%edx
80105486:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010548c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105492:	85 c0                	test   %eax,%eax
80105494:	79 0c                	jns    801054a2 <popcli+0x4b>
    panic("popcli");
80105496:	c7 04 24 c8 8c 10 80 	movl   $0x80108cc8,(%esp)
8010549d:	e8 9b b0 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801054a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054a8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054ae:	85 c0                	test   %eax,%eax
801054b0:	75 15                	jne    801054c7 <popcli+0x70>
801054b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054b8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801054be:	85 c0                	test   %eax,%eax
801054c0:	74 05                	je     801054c7 <popcli+0x70>
    sti();
801054c2:	e8 b4 fd ff ff       	call   8010527b <sti>
}
801054c7:	c9                   	leave  
801054c8:	c3                   	ret    
801054c9:	00 00                	add    %al,(%eax)
	...

801054cc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801054cc:	55                   	push   %ebp
801054cd:	89 e5                	mov    %esp,%ebp
801054cf:	57                   	push   %edi
801054d0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054d4:	8b 55 10             	mov    0x10(%ebp),%edx
801054d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054da:	89 cb                	mov    %ecx,%ebx
801054dc:	89 df                	mov    %ebx,%edi
801054de:	89 d1                	mov    %edx,%ecx
801054e0:	fc                   	cld    
801054e1:	f3 aa                	rep stos %al,%es:(%edi)
801054e3:	89 ca                	mov    %ecx,%edx
801054e5:	89 fb                	mov    %edi,%ebx
801054e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054ea:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054ed:	5b                   	pop    %ebx
801054ee:	5f                   	pop    %edi
801054ef:	5d                   	pop    %ebp
801054f0:	c3                   	ret    

801054f1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801054f1:	55                   	push   %ebp
801054f2:	89 e5                	mov    %esp,%ebp
801054f4:	57                   	push   %edi
801054f5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054f9:	8b 55 10             	mov    0x10(%ebp),%edx
801054fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ff:	89 cb                	mov    %ecx,%ebx
80105501:	89 df                	mov    %ebx,%edi
80105503:	89 d1                	mov    %edx,%ecx
80105505:	fc                   	cld    
80105506:	f3 ab                	rep stos %eax,%es:(%edi)
80105508:	89 ca                	mov    %ecx,%edx
8010550a:	89 fb                	mov    %edi,%ebx
8010550c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010550f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105512:	5b                   	pop    %ebx
80105513:	5f                   	pop    %edi
80105514:	5d                   	pop    %ebp
80105515:	c3                   	ret    

80105516 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010551c:	8b 45 08             	mov    0x8(%ebp),%eax
8010551f:	83 e0 03             	and    $0x3,%eax
80105522:	85 c0                	test   %eax,%eax
80105524:	75 49                	jne    8010556f <memset+0x59>
80105526:	8b 45 10             	mov    0x10(%ebp),%eax
80105529:	83 e0 03             	and    $0x3,%eax
8010552c:	85 c0                	test   %eax,%eax
8010552e:	75 3f                	jne    8010556f <memset+0x59>
    c &= 0xFF;
80105530:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105537:	8b 45 10             	mov    0x10(%ebp),%eax
8010553a:	c1 e8 02             	shr    $0x2,%eax
8010553d:	89 c2                	mov    %eax,%edx
8010553f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105542:	89 c1                	mov    %eax,%ecx
80105544:	c1 e1 18             	shl    $0x18,%ecx
80105547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554a:	c1 e0 10             	shl    $0x10,%eax
8010554d:	09 c1                	or     %eax,%ecx
8010554f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105552:	c1 e0 08             	shl    $0x8,%eax
80105555:	09 c8                	or     %ecx,%eax
80105557:	0b 45 0c             	or     0xc(%ebp),%eax
8010555a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010555e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105562:	8b 45 08             	mov    0x8(%ebp),%eax
80105565:	89 04 24             	mov    %eax,(%esp)
80105568:	e8 84 ff ff ff       	call   801054f1 <stosl>
8010556d:	eb 19                	jmp    80105588 <memset+0x72>
  } else
    stosb(dst, c, n);
8010556f:	8b 45 10             	mov    0x10(%ebp),%eax
80105572:	89 44 24 08          	mov    %eax,0x8(%esp)
80105576:	8b 45 0c             	mov    0xc(%ebp),%eax
80105579:	89 44 24 04          	mov    %eax,0x4(%esp)
8010557d:	8b 45 08             	mov    0x8(%ebp),%eax
80105580:	89 04 24             	mov    %eax,(%esp)
80105583:	e8 44 ff ff ff       	call   801054cc <stosb>
  return dst;
80105588:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010558b:	c9                   	leave  
8010558c:	c3                   	ret    

8010558d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010558d:	55                   	push   %ebp
8010558e:	89 e5                	mov    %esp,%ebp
80105590:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105593:	8b 45 08             	mov    0x8(%ebp),%eax
80105596:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105599:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010559f:	eb 32                	jmp    801055d3 <memcmp+0x46>
    if(*s1 != *s2)
801055a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a4:	0f b6 10             	movzbl (%eax),%edx
801055a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055aa:	0f b6 00             	movzbl (%eax),%eax
801055ad:	38 c2                	cmp    %al,%dl
801055af:	74 1a                	je     801055cb <memcmp+0x3e>
      return *s1 - *s2;
801055b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b4:	0f b6 00             	movzbl (%eax),%eax
801055b7:	0f b6 d0             	movzbl %al,%edx
801055ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055bd:	0f b6 00             	movzbl (%eax),%eax
801055c0:	0f b6 c0             	movzbl %al,%eax
801055c3:	89 d1                	mov    %edx,%ecx
801055c5:	29 c1                	sub    %eax,%ecx
801055c7:	89 c8                	mov    %ecx,%eax
801055c9:	eb 1c                	jmp    801055e7 <memcmp+0x5a>
    s1++, s2++;
801055cb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055cf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055d7:	0f 95 c0             	setne  %al
801055da:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055de:	84 c0                	test   %al,%al
801055e0:	75 bf                	jne    801055a1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801055e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055e7:	c9                   	leave  
801055e8:	c3                   	ret    

801055e9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055e9:	55                   	push   %ebp
801055ea:	89 e5                	mov    %esp,%ebp
801055ec:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055f5:	8b 45 08             	mov    0x8(%ebp),%eax
801055f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105601:	73 54                	jae    80105657 <memmove+0x6e>
80105603:	8b 45 10             	mov    0x10(%ebp),%eax
80105606:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105609:	01 d0                	add    %edx,%eax
8010560b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010560e:	76 47                	jbe    80105657 <memmove+0x6e>
    s += n;
80105610:	8b 45 10             	mov    0x10(%ebp),%eax
80105613:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105616:	8b 45 10             	mov    0x10(%ebp),%eax
80105619:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010561c:	eb 13                	jmp    80105631 <memmove+0x48>
      *--d = *--s;
8010561e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105622:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105629:	0f b6 10             	movzbl (%eax),%edx
8010562c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010562f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105631:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105635:	0f 95 c0             	setne  %al
80105638:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010563c:	84 c0                	test   %al,%al
8010563e:	75 de                	jne    8010561e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105640:	eb 25                	jmp    80105667 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105642:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105645:	0f b6 10             	movzbl (%eax),%edx
80105648:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010564b:	88 10                	mov    %dl,(%eax)
8010564d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105651:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105655:	eb 01                	jmp    80105658 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105657:	90                   	nop
80105658:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010565c:	0f 95 c0             	setne  %al
8010565f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105663:	84 c0                	test   %al,%al
80105665:	75 db                	jne    80105642 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105667:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010566a:	c9                   	leave  
8010566b:	c3                   	ret    

8010566c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010566c:	55                   	push   %ebp
8010566d:	89 e5                	mov    %esp,%ebp
8010566f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105672:	8b 45 10             	mov    0x10(%ebp),%eax
80105675:	89 44 24 08          	mov    %eax,0x8(%esp)
80105679:	8b 45 0c             	mov    0xc(%ebp),%eax
8010567c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105680:	8b 45 08             	mov    0x8(%ebp),%eax
80105683:	89 04 24             	mov    %eax,(%esp)
80105686:	e8 5e ff ff ff       	call   801055e9 <memmove>
}
8010568b:	c9                   	leave  
8010568c:	c3                   	ret    

8010568d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010568d:	55                   	push   %ebp
8010568e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105690:	eb 0c                	jmp    8010569e <strncmp+0x11>
    n--, p++, q++;
80105692:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105696:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010569a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010569e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056a2:	74 1a                	je     801056be <strncmp+0x31>
801056a4:	8b 45 08             	mov    0x8(%ebp),%eax
801056a7:	0f b6 00             	movzbl (%eax),%eax
801056aa:	84 c0                	test   %al,%al
801056ac:	74 10                	je     801056be <strncmp+0x31>
801056ae:	8b 45 08             	mov    0x8(%ebp),%eax
801056b1:	0f b6 10             	movzbl (%eax),%edx
801056b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b7:	0f b6 00             	movzbl (%eax),%eax
801056ba:	38 c2                	cmp    %al,%dl
801056bc:	74 d4                	je     80105692 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801056be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056c2:	75 07                	jne    801056cb <strncmp+0x3e>
    return 0;
801056c4:	b8 00 00 00 00       	mov    $0x0,%eax
801056c9:	eb 18                	jmp    801056e3 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801056cb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ce:	0f b6 00             	movzbl (%eax),%eax
801056d1:	0f b6 d0             	movzbl %al,%edx
801056d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d7:	0f b6 00             	movzbl (%eax),%eax
801056da:	0f b6 c0             	movzbl %al,%eax
801056dd:	89 d1                	mov    %edx,%ecx
801056df:	29 c1                	sub    %eax,%ecx
801056e1:	89 c8                	mov    %ecx,%eax
}
801056e3:	5d                   	pop    %ebp
801056e4:	c3                   	ret    

801056e5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056e5:	55                   	push   %ebp
801056e6:	89 e5                	mov    %esp,%ebp
801056e8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801056eb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056f1:	90                   	nop
801056f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056f6:	0f 9f c0             	setg   %al
801056f9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056fd:	84 c0                	test   %al,%al
801056ff:	74 30                	je     80105731 <strncpy+0x4c>
80105701:	8b 45 0c             	mov    0xc(%ebp),%eax
80105704:	0f b6 10             	movzbl (%eax),%edx
80105707:	8b 45 08             	mov    0x8(%ebp),%eax
8010570a:	88 10                	mov    %dl,(%eax)
8010570c:	8b 45 08             	mov    0x8(%ebp),%eax
8010570f:	0f b6 00             	movzbl (%eax),%eax
80105712:	84 c0                	test   %al,%al
80105714:	0f 95 c0             	setne  %al
80105717:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010571b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010571f:	84 c0                	test   %al,%al
80105721:	75 cf                	jne    801056f2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105723:	eb 0c                	jmp    80105731 <strncpy+0x4c>
    *s++ = 0;
80105725:	8b 45 08             	mov    0x8(%ebp),%eax
80105728:	c6 00 00             	movb   $0x0,(%eax)
8010572b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010572f:	eb 01                	jmp    80105732 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105731:	90                   	nop
80105732:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105736:	0f 9f c0             	setg   %al
80105739:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010573d:	84 c0                	test   %al,%al
8010573f:	75 e4                	jne    80105725 <strncpy+0x40>
    *s++ = 0;
  return os;
80105741:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105744:	c9                   	leave  
80105745:	c3                   	ret    

80105746 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105746:	55                   	push   %ebp
80105747:	89 e5                	mov    %esp,%ebp
80105749:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010574c:	8b 45 08             	mov    0x8(%ebp),%eax
8010574f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105752:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105756:	7f 05                	jg     8010575d <safestrcpy+0x17>
    return os;
80105758:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010575b:	eb 35                	jmp    80105792 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010575d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105761:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105765:	7e 22                	jle    80105789 <safestrcpy+0x43>
80105767:	8b 45 0c             	mov    0xc(%ebp),%eax
8010576a:	0f b6 10             	movzbl (%eax),%edx
8010576d:	8b 45 08             	mov    0x8(%ebp),%eax
80105770:	88 10                	mov    %dl,(%eax)
80105772:	8b 45 08             	mov    0x8(%ebp),%eax
80105775:	0f b6 00             	movzbl (%eax),%eax
80105778:	84 c0                	test   %al,%al
8010577a:	0f 95 c0             	setne  %al
8010577d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105781:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105785:	84 c0                	test   %al,%al
80105787:	75 d4                	jne    8010575d <safestrcpy+0x17>
    ;
  *s = 0;
80105789:	8b 45 08             	mov    0x8(%ebp),%eax
8010578c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010578f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105792:	c9                   	leave  
80105793:	c3                   	ret    

80105794 <strlen>:

int
strlen(const char *s)
{
80105794:	55                   	push   %ebp
80105795:	89 e5                	mov    %esp,%ebp
80105797:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010579a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057a1:	eb 04                	jmp    801057a7 <strlen+0x13>
801057a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057aa:	03 45 08             	add    0x8(%ebp),%eax
801057ad:	0f b6 00             	movzbl (%eax),%eax
801057b0:	84 c0                	test   %al,%al
801057b2:	75 ef                	jne    801057a3 <strlen+0xf>
    ;
  return n;
801057b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b7:	c9                   	leave  
801057b8:	c3                   	ret    
801057b9:	00 00                	add    %al,(%eax)
	...

801057bc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057bc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057c0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801057c4:	55                   	push   %ebp
  pushl %ebx
801057c5:	53                   	push   %ebx
  pushl %esi
801057c6:	56                   	push   %esi
  pushl %edi
801057c7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057c8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057ca:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801057cc:	5f                   	pop    %edi
  popl %esi
801057cd:	5e                   	pop    %esi
  popl %ebx
801057ce:	5b                   	pop    %ebx
  popl %ebp
801057cf:	5d                   	pop    %ebp
  ret
801057d0:	c3                   	ret    
801057d1:	00 00                	add    %al,(%eax)
	...

801057d4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801057d4:	55                   	push   %ebp
801057d5:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801057d7:	8b 45 08             	mov    0x8(%ebp),%eax
801057da:	8b 00                	mov    (%eax),%eax
801057dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801057df:	76 0f                	jbe    801057f0 <fetchint+0x1c>
801057e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e4:	8d 50 04             	lea    0x4(%eax),%edx
801057e7:	8b 45 08             	mov    0x8(%ebp),%eax
801057ea:	8b 00                	mov    (%eax),%eax
801057ec:	39 c2                	cmp    %eax,%edx
801057ee:	76 07                	jbe    801057f7 <fetchint+0x23>
    return -1;
801057f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f5:	eb 0f                	jmp    80105806 <fetchint+0x32>
  *ip = *(int*)(addr);
801057f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057fa:	8b 10                	mov    (%eax),%edx
801057fc:	8b 45 10             	mov    0x10(%ebp),%eax
801057ff:	89 10                	mov    %edx,(%eax)
  return 0;
80105801:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105806:	5d                   	pop    %ebp
80105807:	c3                   	ret    

80105808 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105808:	55                   	push   %ebp
80105809:	89 e5                	mov    %esp,%ebp
8010580b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
8010580e:	8b 45 08             	mov    0x8(%ebp),%eax
80105811:	8b 00                	mov    (%eax),%eax
80105813:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105816:	77 07                	ja     8010581f <fetchstr+0x17>
    return -1;
80105818:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581d:	eb 45                	jmp    80105864 <fetchstr+0x5c>
  *pp = (char*)addr;
8010581f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105822:	8b 45 10             	mov    0x10(%ebp),%eax
80105825:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
80105827:	8b 45 08             	mov    0x8(%ebp),%eax
8010582a:	8b 00                	mov    (%eax),%eax
8010582c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010582f:	8b 45 10             	mov    0x10(%ebp),%eax
80105832:	8b 00                	mov    (%eax),%eax
80105834:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105837:	eb 1e                	jmp    80105857 <fetchstr+0x4f>
    if(*s == 0)
80105839:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583c:	0f b6 00             	movzbl (%eax),%eax
8010583f:	84 c0                	test   %al,%al
80105841:	75 10                	jne    80105853 <fetchstr+0x4b>
      return s - *pp;
80105843:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105846:	8b 45 10             	mov    0x10(%ebp),%eax
80105849:	8b 00                	mov    (%eax),%eax
8010584b:	89 d1                	mov    %edx,%ecx
8010584d:	29 c1                	sub    %eax,%ecx
8010584f:	89 c8                	mov    %ecx,%eax
80105851:	eb 11                	jmp    80105864 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
80105853:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105857:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010585a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010585d:	72 da                	jb     80105839 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
8010585f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105864:	c9                   	leave  
80105865:	c3                   	ret    

80105866 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105866:	55                   	push   %ebp
80105867:	89 e5                	mov    %esp,%ebp
80105869:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
8010586c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105872:	8b 40 18             	mov    0x18(%eax),%eax
80105875:	8b 50 44             	mov    0x44(%eax),%edx
80105878:	8b 45 08             	mov    0x8(%ebp),%eax
8010587b:	c1 e0 02             	shl    $0x2,%eax
8010587e:	01 d0                	add    %edx,%eax
80105880:	8d 48 04             	lea    0x4(%eax),%ecx
80105883:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105889:	8b 55 0c             	mov    0xc(%ebp),%edx
8010588c:	89 54 24 08          	mov    %edx,0x8(%esp)
80105890:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105894:	89 04 24             	mov    %eax,(%esp)
80105897:	e8 38 ff ff ff       	call   801057d4 <fetchint>
}
8010589c:	c9                   	leave  
8010589d:	c3                   	ret    

8010589e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010589e:	55                   	push   %ebp
8010589f:	89 e5                	mov    %esp,%ebp
801058a1:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801058a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
801058a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ab:	8b 45 08             	mov    0x8(%ebp),%eax
801058ae:	89 04 24             	mov    %eax,(%esp)
801058b1:	e8 b0 ff ff ff       	call   80105866 <argint>
801058b6:	85 c0                	test   %eax,%eax
801058b8:	79 07                	jns    801058c1 <argptr+0x23>
    return -1;
801058ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bf:	eb 3d                	jmp    801058fe <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801058c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058c4:	89 c2                	mov    %eax,%edx
801058c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058cc:	8b 00                	mov    (%eax),%eax
801058ce:	39 c2                	cmp    %eax,%edx
801058d0:	73 16                	jae    801058e8 <argptr+0x4a>
801058d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d5:	89 c2                	mov    %eax,%edx
801058d7:	8b 45 10             	mov    0x10(%ebp),%eax
801058da:	01 c2                	add    %eax,%edx
801058dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e2:	8b 00                	mov    (%eax),%eax
801058e4:	39 c2                	cmp    %eax,%edx
801058e6:	76 07                	jbe    801058ef <argptr+0x51>
    return -1;
801058e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ed:	eb 0f                	jmp    801058fe <argptr+0x60>
  *pp = (char*)i;
801058ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058f2:	89 c2                	mov    %eax,%edx
801058f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f7:	89 10                	mov    %edx,(%eax)
  return 0;
801058f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058fe:	c9                   	leave  
801058ff:	c3                   	ret    

80105900 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105906:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590d:	8b 45 08             	mov    0x8(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 4e ff ff ff       	call   80105866 <argint>
80105918:	85 c0                	test   %eax,%eax
8010591a:	79 07                	jns    80105923 <argstr+0x23>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	eb 1e                	jmp    80105941 <argstr+0x41>
  return fetchstr(proc, addr, pp);
80105923:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105926:	89 c2                	mov    %eax,%edx
80105928:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010592e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105931:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105935:	89 54 24 04          	mov    %edx,0x4(%esp)
80105939:	89 04 24             	mov    %eax,(%esp)
8010593c:	e8 c7 fe ff ff       	call   80105808 <fetchstr>
}
80105941:	c9                   	leave  
80105942:	c3                   	ret    

80105943 <syscall>:
[SYS_add_path]   sys_add_path,
};

void
syscall(void)
{
80105943:	55                   	push   %ebp
80105944:	89 e5                	mov    %esp,%ebp
80105946:	53                   	push   %ebx
80105947:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010594a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105950:	8b 40 18             	mov    0x18(%eax),%eax
80105953:	8b 40 1c             	mov    0x1c(%eax),%eax
80105956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105959:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010595d:	78 2e                	js     8010598d <syscall+0x4a>
8010595f:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105963:	7f 28                	jg     8010598d <syscall+0x4a>
80105965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105968:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010596f:	85 c0                	test   %eax,%eax
80105971:	74 1a                	je     8010598d <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105973:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105979:	8b 58 18             	mov    0x18(%eax),%ebx
8010597c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105986:	ff d0                	call   *%eax
80105988:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010598b:	eb 73                	jmp    80105a00 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010598d:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105991:	7e 30                	jle    801059c3 <syscall+0x80>
80105993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105996:	83 f8 16             	cmp    $0x16,%eax
80105999:	77 28                	ja     801059c3 <syscall+0x80>
8010599b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599e:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801059a5:	85 c0                	test   %eax,%eax
801059a7:	74 1a                	je     801059c3 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801059a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059af:	8b 58 18             	mov    0x18(%eax),%ebx
801059b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b5:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801059bc:	ff d0                	call   *%eax
801059be:	89 43 1c             	mov    %eax,0x1c(%ebx)
801059c1:	eb 3d                	jmp    80105a00 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801059c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059c9:	8d 48 6c             	lea    0x6c(%eax),%ecx
801059cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801059d2:	8b 40 10             	mov    0x10(%eax),%eax
801059d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801059dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e4:	c7 04 24 cf 8c 10 80 	movl   $0x80108ccf,(%esp)
801059eb:	e8 b1 a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801059f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059f6:	8b 40 18             	mov    0x18(%eax),%eax
801059f9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a00:	83 c4 24             	add    $0x24,%esp
80105a03:	5b                   	pop    %ebx
80105a04:	5d                   	pop    %ebp
80105a05:	c3                   	ret    
	...

80105a08 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a08:	55                   	push   %ebp
80105a09:	89 e5                	mov    %esp,%ebp
80105a0b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a11:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a15:	8b 45 08             	mov    0x8(%ebp),%eax
80105a18:	89 04 24             	mov    %eax,(%esp)
80105a1b:	e8 46 fe ff ff       	call   80105866 <argint>
80105a20:	85 c0                	test   %eax,%eax
80105a22:	79 07                	jns    80105a2b <argfd+0x23>
    return -1;
80105a24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a29:	eb 50                	jmp    80105a7b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2e:	85 c0                	test   %eax,%eax
80105a30:	78 21                	js     80105a53 <argfd+0x4b>
80105a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a35:	83 f8 0f             	cmp    $0xf,%eax
80105a38:	7f 19                	jg     80105a53 <argfd+0x4b>
80105a3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a43:	83 c2 08             	add    $0x8,%edx
80105a46:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a51:	75 07                	jne    80105a5a <argfd+0x52>
    return -1;
80105a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a58:	eb 21                	jmp    80105a7b <argfd+0x73>
  if(pfd)
80105a5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a5e:	74 08                	je     80105a68 <argfd+0x60>
    *pfd = fd;
80105a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a66:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a6c:	74 08                	je     80105a76 <argfd+0x6e>
    *pf = f;
80105a6e:	8b 45 10             	mov    0x10(%ebp),%eax
80105a71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a74:	89 10                	mov    %edx,(%eax)
  return 0;
80105a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a7b:	c9                   	leave  
80105a7c:	c3                   	ret    

80105a7d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a7d:	55                   	push   %ebp
80105a7e:	89 e5                	mov    %esp,%ebp
80105a80:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a8a:	eb 30                	jmp    80105abc <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105a8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a95:	83 c2 08             	add    $0x8,%edx
80105a98:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a9c:	85 c0                	test   %eax,%eax
80105a9e:	75 18                	jne    80105ab8 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105aa0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aa6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105aa9:	8d 4a 08             	lea    0x8(%edx),%ecx
80105aac:	8b 55 08             	mov    0x8(%ebp),%edx
80105aaf:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ab3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ab6:	eb 0f                	jmp    80105ac7 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105ab8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105abc:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105ac0:	7e ca                	jle    80105a8c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ac7:	c9                   	leave  
80105ac8:	c3                   	ret    

80105ac9 <sys_dup>:

int
sys_dup(void)
{
80105ac9:	55                   	push   %ebp
80105aca:	89 e5                	mov    %esp,%ebp
80105acc:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105acf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105add:	00 
80105ade:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ae5:	e8 1e ff ff ff       	call   80105a08 <argfd>
80105aea:	85 c0                	test   %eax,%eax
80105aec:	79 07                	jns    80105af5 <sys_dup+0x2c>
    return -1;
80105aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af3:	eb 29                	jmp    80105b1e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af8:	89 04 24             	mov    %eax,(%esp)
80105afb:	e8 7d ff ff ff       	call   80105a7d <fdalloc>
80105b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b07:	79 07                	jns    80105b10 <sys_dup+0x47>
    return -1;
80105b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0e:	eb 0e                	jmp    80105b1e <sys_dup+0x55>
  filedup(f);
80105b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b13:	89 04 24             	mov    %eax,(%esp)
80105b16:	e8 85 bb ff ff       	call   801016a0 <filedup>
  return fd;
80105b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b1e:	c9                   	leave  
80105b1f:	c3                   	ret    

80105b20 <sys_read>:

int
sys_read(void)
{
80105b20:	55                   	push   %ebp
80105b21:	89 e5                	mov    %esp,%ebp
80105b23:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b29:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b34:	00 
80105b35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b3c:	e8 c7 fe ff ff       	call   80105a08 <argfd>
80105b41:	85 c0                	test   %eax,%eax
80105b43:	78 35                	js     80105b7a <sys_read+0x5a>
80105b45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b4c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b53:	e8 0e fd ff ff       	call   80105866 <argint>
80105b58:	85 c0                	test   %eax,%eax
80105b5a:	78 1e                	js     80105b7a <sys_read+0x5a>
80105b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b63:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b66:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b71:	e8 28 fd ff ff       	call   8010589e <argptr>
80105b76:	85 c0                	test   %eax,%eax
80105b78:	79 07                	jns    80105b81 <sys_read+0x61>
    return -1;
80105b7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7f:	eb 19                	jmp    80105b9a <sys_read+0x7a>
  return fileread(f, p, n);
80105b81:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b84:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b92:	89 04 24             	mov    %eax,(%esp)
80105b95:	e8 73 bc ff ff       	call   8010180d <fileread>
}
80105b9a:	c9                   	leave  
80105b9b:	c3                   	ret    

80105b9c <sys_write>:

int
sys_write(void)
{
80105b9c:	55                   	push   %ebp
80105b9d:	89 e5                	mov    %esp,%ebp
80105b9f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ba9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bb0:	00 
80105bb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bb8:	e8 4b fe ff ff       	call   80105a08 <argfd>
80105bbd:	85 c0                	test   %eax,%eax
80105bbf:	78 35                	js     80105bf6 <sys_write+0x5a>
80105bc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bc8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bcf:	e8 92 fc ff ff       	call   80105866 <argint>
80105bd4:	85 c0                	test   %eax,%eax
80105bd6:	78 1e                	js     80105bf6 <sys_write+0x5a>
80105bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bdf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105be2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bed:	e8 ac fc ff ff       	call   8010589e <argptr>
80105bf2:	85 c0                	test   %eax,%eax
80105bf4:	79 07                	jns    80105bfd <sys_write+0x61>
    return -1;
80105bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfb:	eb 19                	jmp    80105c16 <sys_write+0x7a>
  return filewrite(f, p, n);
80105bfd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c00:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c0e:	89 04 24             	mov    %eax,(%esp)
80105c11:	e8 b3 bc ff ff       	call   801018c9 <filewrite>
}
80105c16:	c9                   	leave  
80105c17:	c3                   	ret    

80105c18 <sys_close>:

int
sys_close(void)
{
80105c18:	55                   	push   %ebp
80105c19:	89 e5                	mov    %esp,%ebp
80105c1b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105c1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c21:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c25:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c33:	e8 d0 fd ff ff       	call   80105a08 <argfd>
80105c38:	85 c0                	test   %eax,%eax
80105c3a:	79 07                	jns    80105c43 <sys_close+0x2b>
    return -1;
80105c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c41:	eb 24                	jmp    80105c67 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105c43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c4c:	83 c2 08             	add    $0x8,%edx
80105c4f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c56:	00 
  fileclose(f);
80105c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5a:	89 04 24             	mov    %eax,(%esp)
80105c5d:	e8 86 ba ff ff       	call   801016e8 <fileclose>
  return 0;
80105c62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c67:	c9                   	leave  
80105c68:	c3                   	ret    

80105c69 <sys_fstat>:

int
sys_fstat(void)
{
80105c69:	55                   	push   %ebp
80105c6a:	89 e5                	mov    %esp,%ebp
80105c6c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c72:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c7d:	00 
80105c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c85:	e8 7e fd ff ff       	call   80105a08 <argfd>
80105c8a:	85 c0                	test   %eax,%eax
80105c8c:	78 1f                	js     80105cad <sys_fstat+0x44>
80105c8e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105c95:	00 
80105c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c99:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ca4:	e8 f5 fb ff ff       	call   8010589e <argptr>
80105ca9:	85 c0                	test   %eax,%eax
80105cab:	79 07                	jns    80105cb4 <sys_fstat+0x4b>
    return -1;
80105cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb2:	eb 12                	jmp    80105cc6 <sys_fstat+0x5d>
  return filestat(f, st);
80105cb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cba:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cbe:	89 04 24             	mov    %eax,(%esp)
80105cc1:	e8 f8 ba ff ff       	call   801017be <filestat>
}
80105cc6:	c9                   	leave  
80105cc7:	c3                   	ret    

80105cc8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cc8:	55                   	push   %ebp
80105cc9:	89 e5                	mov    %esp,%ebp
80105ccb:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cce:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cdc:	e8 1f fc ff ff       	call   80105900 <argstr>
80105ce1:	85 c0                	test   %eax,%eax
80105ce3:	78 17                	js     80105cfc <sys_link+0x34>
80105ce5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cf3:	e8 08 fc ff ff       	call   80105900 <argstr>
80105cf8:	85 c0                	test   %eax,%eax
80105cfa:	79 0a                	jns    80105d06 <sys_link+0x3e>
    return -1;
80105cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d01:	e9 3c 01 00 00       	jmp    80105e42 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105d06:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d09:	89 04 24             	mov    %eax,(%esp)
80105d0c:	e8 1d ce ff ff       	call   80102b2e <namei>
80105d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d18:	75 0a                	jne    80105d24 <sys_link+0x5c>
    return -1;
80105d1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1f:	e9 1e 01 00 00       	jmp    80105e42 <sys_link+0x17a>

  begin_trans();
80105d24:	e8 18 dc ff ff       	call   80103941 <begin_trans>

  ilock(ip);
80105d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2c:	89 04 24             	mov    %eax,(%esp)
80105d2f:	e8 58 c2 ff ff       	call   80101f8c <ilock>
  if(ip->type == T_DIR){
80105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d37:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d3b:	66 83 f8 01          	cmp    $0x1,%ax
80105d3f:	75 1a                	jne    80105d5b <sys_link+0x93>
    iunlockput(ip);
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	89 04 24             	mov    %eax,(%esp)
80105d47:	e8 c4 c4 ff ff       	call   80102210 <iunlockput>
    commit_trans();
80105d4c:	e8 39 dc ff ff       	call   8010398a <commit_trans>
    return -1;
80105d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d56:	e9 e7 00 00 00       	jmp    80105e42 <sys_link+0x17a>
  }

  ip->nlink++;
80105d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d62:	8d 50 01             	lea    0x1(%eax),%edx
80105d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d68:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6f:	89 04 24             	mov    %eax,(%esp)
80105d72:	e8 59 c0 ff ff       	call   80101dd0 <iupdate>
  iunlock(ip);
80105d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7a:	89 04 24             	mov    %eax,(%esp)
80105d7d:	e8 58 c3 ff ff       	call   801020da <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105d82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d85:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d88:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d8c:	89 04 24             	mov    %eax,(%esp)
80105d8f:	e8 bc cd ff ff       	call   80102b50 <nameiparent>
80105d94:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9b:	74 68                	je     80105e05 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da0:	89 04 24             	mov    %eax,(%esp)
80105da3:	e8 e4 c1 ff ff       	call   80101f8c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dab:	8b 10                	mov    (%eax),%edx
80105dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db0:	8b 00                	mov    (%eax),%eax
80105db2:	39 c2                	cmp    %eax,%edx
80105db4:	75 20                	jne    80105dd6 <sys_link+0x10e>
80105db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db9:	8b 40 04             	mov    0x4(%eax),%eax
80105dbc:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dc0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dca:	89 04 24             	mov    %eax,(%esp)
80105dcd:	e8 9b ca ff ff       	call   8010286d <dirlink>
80105dd2:	85 c0                	test   %eax,%eax
80105dd4:	79 0d                	jns    80105de3 <sys_link+0x11b>
    iunlockput(dp);
80105dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd9:	89 04 24             	mov    %eax,(%esp)
80105ddc:	e8 2f c4 ff ff       	call   80102210 <iunlockput>
    goto bad;
80105de1:	eb 23                	jmp    80105e06 <sys_link+0x13e>
  }
  iunlockput(dp);
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	89 04 24             	mov    %eax,(%esp)
80105de9:	e8 22 c4 ff ff       	call   80102210 <iunlockput>
  iput(ip);
80105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df1:	89 04 24             	mov    %eax,(%esp)
80105df4:	e8 46 c3 ff ff       	call   8010213f <iput>

  commit_trans();
80105df9:	e8 8c db ff ff       	call   8010398a <commit_trans>

  return 0;
80105dfe:	b8 00 00 00 00       	mov    $0x0,%eax
80105e03:	eb 3d                	jmp    80105e42 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105e05:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	89 04 24             	mov    %eax,(%esp)
80105e0c:	e8 7b c1 ff ff       	call   80101f8c <ilock>
  ip->nlink--;
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e18:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e25:	89 04 24             	mov    %eax,(%esp)
80105e28:	e8 a3 bf ff ff       	call   80101dd0 <iupdate>
  iunlockput(ip);
80105e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e30:	89 04 24             	mov    %eax,(%esp)
80105e33:	e8 d8 c3 ff ff       	call   80102210 <iunlockput>
  commit_trans();
80105e38:	e8 4d db ff ff       	call   8010398a <commit_trans>
  return -1;
80105e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e42:	c9                   	leave  
80105e43:	c3                   	ret    

80105e44 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e44:	55                   	push   %ebp
80105e45:	89 e5                	mov    %esp,%ebp
80105e47:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e4a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e51:	eb 4b                	jmp    80105e9e <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e56:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e5d:	00 
80105e5e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e65:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e69:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6c:	89 04 24             	mov    %eax,(%esp)
80105e6f:	e8 0e c6 ff ff       	call   80102482 <readi>
80105e74:	83 f8 10             	cmp    $0x10,%eax
80105e77:	74 0c                	je     80105e85 <isdirempty+0x41>
      panic("isdirempty: readi");
80105e79:	c7 04 24 eb 8c 10 80 	movl   $0x80108ceb,(%esp)
80105e80:	e8 b8 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105e85:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e89:	66 85 c0             	test   %ax,%ax
80105e8c:	74 07                	je     80105e95 <isdirempty+0x51>
      return 0;
80105e8e:	b8 00 00 00 00       	mov    $0x0,%eax
80105e93:	eb 1b                	jmp    80105eb0 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e98:	83 c0 10             	add    $0x10,%eax
80105e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea4:	8b 40 18             	mov    0x18(%eax),%eax
80105ea7:	39 c2                	cmp    %eax,%edx
80105ea9:	72 a8                	jb     80105e53 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105eab:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105eb0:	c9                   	leave  
80105eb1:	c3                   	ret    

80105eb2 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105eb2:	55                   	push   %ebp
80105eb3:	89 e5                	mov    %esp,%ebp
80105eb5:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105eb8:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ec6:	e8 35 fa ff ff       	call   80105900 <argstr>
80105ecb:	85 c0                	test   %eax,%eax
80105ecd:	79 0a                	jns    80105ed9 <sys_unlink+0x27>
    return -1;
80105ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed4:	e9 aa 01 00 00       	jmp    80106083 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105ed9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105edc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105edf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ee3:	89 04 24             	mov    %eax,(%esp)
80105ee6:	e8 65 cc ff ff       	call   80102b50 <nameiparent>
80105eeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ef2:	75 0a                	jne    80105efe <sys_unlink+0x4c>
    return -1;
80105ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef9:	e9 85 01 00 00       	jmp    80106083 <sys_unlink+0x1d1>

  begin_trans();
80105efe:	e8 3e da ff ff       	call   80103941 <begin_trans>

  ilock(dp);
80105f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f06:	89 04 24             	mov    %eax,(%esp)
80105f09:	e8 7e c0 ff ff       	call   80101f8c <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f0e:	c7 44 24 04 fd 8c 10 	movl   $0x80108cfd,0x4(%esp)
80105f15:	80 
80105f16:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f19:	89 04 24             	mov    %eax,(%esp)
80105f1c:	e8 62 c8 ff ff       	call   80102783 <namecmp>
80105f21:	85 c0                	test   %eax,%eax
80105f23:	0f 84 45 01 00 00    	je     8010606e <sys_unlink+0x1bc>
80105f29:	c7 44 24 04 ff 8c 10 	movl   $0x80108cff,0x4(%esp)
80105f30:	80 
80105f31:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f34:	89 04 24             	mov    %eax,(%esp)
80105f37:	e8 47 c8 ff ff       	call   80102783 <namecmp>
80105f3c:	85 c0                	test   %eax,%eax
80105f3e:	0f 84 2a 01 00 00    	je     8010606e <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f44:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f4b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f55:	89 04 24             	mov    %eax,(%esp)
80105f58:	e8 48 c8 ff ff       	call   801027a5 <dirlookup>
80105f5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f64:	0f 84 03 01 00 00    	je     8010606d <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6d:	89 04 24             	mov    %eax,(%esp)
80105f70:	e8 17 c0 ff ff       	call   80101f8c <ilock>

  if(ip->nlink < 1)
80105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f78:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f7c:	66 85 c0             	test   %ax,%ax
80105f7f:	7f 0c                	jg     80105f8d <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105f81:	c7 04 24 02 8d 10 80 	movl   $0x80108d02,(%esp)
80105f88:	e8 b0 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f90:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f94:	66 83 f8 01          	cmp    $0x1,%ax
80105f98:	75 1f                	jne    80105fb9 <sys_unlink+0x107>
80105f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9d:	89 04 24             	mov    %eax,(%esp)
80105fa0:	e8 9f fe ff ff       	call   80105e44 <isdirempty>
80105fa5:	85 c0                	test   %eax,%eax
80105fa7:	75 10                	jne    80105fb9 <sys_unlink+0x107>
    iunlockput(ip);
80105fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fac:	89 04 24             	mov    %eax,(%esp)
80105faf:	e8 5c c2 ff ff       	call   80102210 <iunlockput>
    goto bad;
80105fb4:	e9 b5 00 00 00       	jmp    8010606e <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105fb9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105fc0:	00 
80105fc1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fc8:	00 
80105fc9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fcc:	89 04 24             	mov    %eax,(%esp)
80105fcf:	e8 42 f5 ff ff       	call   80105516 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fd4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fd7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105fde:	00 
80105fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fe3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fed:	89 04 24             	mov    %eax,(%esp)
80105ff0:	e8 f8 c5 ff ff       	call   801025ed <writei>
80105ff5:	83 f8 10             	cmp    $0x10,%eax
80105ff8:	74 0c                	je     80106006 <sys_unlink+0x154>
    panic("unlink: writei");
80105ffa:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80106001:	e8 37 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80106006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106009:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010600d:	66 83 f8 01          	cmp    $0x1,%ax
80106011:	75 1c                	jne    8010602f <sys_unlink+0x17d>
    dp->nlink--;
80106013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106016:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010601a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106020:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106027:	89 04 24             	mov    %eax,(%esp)
8010602a:	e8 a1 bd ff ff       	call   80101dd0 <iupdate>
  }
  iunlockput(dp);
8010602f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106032:	89 04 24             	mov    %eax,(%esp)
80106035:	e8 d6 c1 ff ff       	call   80102210 <iunlockput>

  ip->nlink--;
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106041:	8d 50 ff             	lea    -0x1(%eax),%edx
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010604b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604e:	89 04 24             	mov    %eax,(%esp)
80106051:	e8 7a bd ff ff       	call   80101dd0 <iupdate>
  iunlockput(ip);
80106056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106059:	89 04 24             	mov    %eax,(%esp)
8010605c:	e8 af c1 ff ff       	call   80102210 <iunlockput>

  commit_trans();
80106061:	e8 24 d9 ff ff       	call   8010398a <commit_trans>

  return 0;
80106066:	b8 00 00 00 00       	mov    $0x0,%eax
8010606b:	eb 16                	jmp    80106083 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010606d:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
8010606e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106071:	89 04 24             	mov    %eax,(%esp)
80106074:	e8 97 c1 ff ff       	call   80102210 <iunlockput>
  commit_trans();
80106079:	e8 0c d9 ff ff       	call   8010398a <commit_trans>
  return -1;
8010607e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106083:	c9                   	leave  
80106084:	c3                   	ret    

80106085 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106085:	55                   	push   %ebp
80106086:	89 e5                	mov    %esp,%ebp
80106088:	83 ec 48             	sub    $0x48,%esp
8010608b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010608e:	8b 55 10             	mov    0x10(%ebp),%edx
80106091:	8b 45 14             	mov    0x14(%ebp),%eax
80106094:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106098:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010609c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060a0:	8d 45 de             	lea    -0x22(%ebp),%eax
801060a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801060a7:	8b 45 08             	mov    0x8(%ebp),%eax
801060aa:	89 04 24             	mov    %eax,(%esp)
801060ad:	e8 9e ca ff ff       	call   80102b50 <nameiparent>
801060b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060b9:	75 0a                	jne    801060c5 <create+0x40>
    return 0;
801060bb:	b8 00 00 00 00       	mov    $0x0,%eax
801060c0:	e9 7e 01 00 00       	jmp    80106243 <create+0x1be>
  ilock(dp);
801060c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 bc be ff ff       	call   80101f8c <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801060d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801060d7:	8d 45 de             	lea    -0x22(%ebp),%eax
801060da:	89 44 24 04          	mov    %eax,0x4(%esp)
801060de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e1:	89 04 24             	mov    %eax,(%esp)
801060e4:	e8 bc c6 ff ff       	call   801027a5 <dirlookup>
801060e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060f0:	74 47                	je     80106139 <create+0xb4>
    iunlockput(dp);
801060f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f5:	89 04 24             	mov    %eax,(%esp)
801060f8:	e8 13 c1 ff ff       	call   80102210 <iunlockput>
    ilock(ip);
801060fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106100:	89 04 24             	mov    %eax,(%esp)
80106103:	e8 84 be ff ff       	call   80101f8c <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106108:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010610d:	75 15                	jne    80106124 <create+0x9f>
8010610f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106112:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106116:	66 83 f8 02          	cmp    $0x2,%ax
8010611a:	75 08                	jne    80106124 <create+0x9f>
      return ip;
8010611c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611f:	e9 1f 01 00 00       	jmp    80106243 <create+0x1be>
    iunlockput(ip);
80106124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106127:	89 04 24             	mov    %eax,(%esp)
8010612a:	e8 e1 c0 ff ff       	call   80102210 <iunlockput>
    return 0;
8010612f:	b8 00 00 00 00       	mov    $0x0,%eax
80106134:	e9 0a 01 00 00       	jmp    80106243 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106139:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010613d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106140:	8b 00                	mov    (%eax),%eax
80106142:	89 54 24 04          	mov    %edx,0x4(%esp)
80106146:	89 04 24             	mov    %eax,(%esp)
80106149:	e8 a5 bb ff ff       	call   80101cf3 <ialloc>
8010614e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106151:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106155:	75 0c                	jne    80106163 <create+0xde>
    panic("create: ialloc");
80106157:	c7 04 24 23 8d 10 80 	movl   $0x80108d23,(%esp)
8010615e:	e8 da a3 ff ff       	call   8010053d <panic>

  ilock(ip);
80106163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 1e be ff ff       	call   80101f8c <ilock>
  ip->major = major;
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106175:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106180:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106187:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010618d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106190:	89 04 24             	mov    %eax,(%esp)
80106193:	e8 38 bc ff ff       	call   80101dd0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106198:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010619d:	75 6a                	jne    80106209 <create+0x184>
    dp->nlink++;  // for ".."
8010619f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801061a6:	8d 50 01             	lea    0x1(%eax),%edx
801061a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ac:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801061b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b3:	89 04 24             	mov    %eax,(%esp)
801061b6:	e8 15 bc ff ff       	call   80101dd0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061be:	8b 40 04             	mov    0x4(%eax),%eax
801061c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801061c5:	c7 44 24 04 fd 8c 10 	movl   $0x80108cfd,0x4(%esp)
801061cc:	80 
801061cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d0:	89 04 24             	mov    %eax,(%esp)
801061d3:	e8 95 c6 ff ff       	call   8010286d <dirlink>
801061d8:	85 c0                	test   %eax,%eax
801061da:	78 21                	js     801061fd <create+0x178>
801061dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061df:	8b 40 04             	mov    0x4(%eax),%eax
801061e2:	89 44 24 08          	mov    %eax,0x8(%esp)
801061e6:	c7 44 24 04 ff 8c 10 	movl   $0x80108cff,0x4(%esp)
801061ed:	80 
801061ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f1:	89 04 24             	mov    %eax,(%esp)
801061f4:	e8 74 c6 ff ff       	call   8010286d <dirlink>
801061f9:	85 c0                	test   %eax,%eax
801061fb:	79 0c                	jns    80106209 <create+0x184>
      panic("create dots");
801061fd:	c7 04 24 32 8d 10 80 	movl   $0x80108d32,(%esp)
80106204:	e8 34 a3 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620c:	8b 40 04             	mov    0x4(%eax),%eax
8010620f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106213:	8d 45 de             	lea    -0x22(%ebp),%eax
80106216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010621a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621d:	89 04 24             	mov    %eax,(%esp)
80106220:	e8 48 c6 ff ff       	call   8010286d <dirlink>
80106225:	85 c0                	test   %eax,%eax
80106227:	79 0c                	jns    80106235 <create+0x1b0>
    panic("create: dirlink");
80106229:	c7 04 24 3e 8d 10 80 	movl   $0x80108d3e,(%esp)
80106230:	e8 08 a3 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106238:	89 04 24             	mov    %eax,(%esp)
8010623b:	e8 d0 bf ff ff       	call   80102210 <iunlockput>

  return ip;
80106240:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106243:	c9                   	leave  
80106244:	c3                   	ret    

80106245 <sys_open>:

int
sys_open(void)
{
80106245:	55                   	push   %ebp
80106246:	89 e5                	mov    %esp,%ebp
80106248:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010624b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010624e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106252:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106259:	e8 a2 f6 ff ff       	call   80105900 <argstr>
8010625e:	85 c0                	test   %eax,%eax
80106260:	78 17                	js     80106279 <sys_open+0x34>
80106262:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106265:	89 44 24 04          	mov    %eax,0x4(%esp)
80106269:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106270:	e8 f1 f5 ff ff       	call   80105866 <argint>
80106275:	85 c0                	test   %eax,%eax
80106277:	79 0a                	jns    80106283 <sys_open+0x3e>
    return -1;
80106279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627e:	e9 46 01 00 00       	jmp    801063c9 <sys_open+0x184>
  if(omode & O_CREATE){
80106283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106286:	25 00 02 00 00       	and    $0x200,%eax
8010628b:	85 c0                	test   %eax,%eax
8010628d:	74 40                	je     801062cf <sys_open+0x8a>
    begin_trans();
8010628f:	e8 ad d6 ff ff       	call   80103941 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80106294:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106297:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010629e:	00 
8010629f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062a6:	00 
801062a7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801062ae:	00 
801062af:	89 04 24             	mov    %eax,(%esp)
801062b2:	e8 ce fd ff ff       	call   80106085 <create>
801062b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801062ba:	e8 cb d6 ff ff       	call   8010398a <commit_trans>
    if(ip == 0)
801062bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062c3:	75 5c                	jne    80106321 <sys_open+0xdc>
      return -1;
801062c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ca:	e9 fa 00 00 00       	jmp    801063c9 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801062cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062d2:	89 04 24             	mov    %eax,(%esp)
801062d5:	e8 54 c8 ff ff       	call   80102b2e <namei>
801062da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e1:	75 0a                	jne    801062ed <sys_open+0xa8>
      return -1;
801062e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e8:	e9 dc 00 00 00       	jmp    801063c9 <sys_open+0x184>
    ilock(ip);
801062ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f0:	89 04 24             	mov    %eax,(%esp)
801062f3:	e8 94 bc ff ff       	call   80101f8c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801062f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062ff:	66 83 f8 01          	cmp    $0x1,%ax
80106303:	75 1c                	jne    80106321 <sys_open+0xdc>
80106305:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106308:	85 c0                	test   %eax,%eax
8010630a:	74 15                	je     80106321 <sys_open+0xdc>
      iunlockput(ip);
8010630c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630f:	89 04 24             	mov    %eax,(%esp)
80106312:	e8 f9 be ff ff       	call   80102210 <iunlockput>
      return -1;
80106317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631c:	e9 a8 00 00 00       	jmp    801063c9 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106321:	e8 1a b3 ff ff       	call   80101640 <filealloc>
80106326:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106329:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010632d:	74 14                	je     80106343 <sys_open+0xfe>
8010632f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106332:	89 04 24             	mov    %eax,(%esp)
80106335:	e8 43 f7 ff ff       	call   80105a7d <fdalloc>
8010633a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010633d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106341:	79 23                	jns    80106366 <sys_open+0x121>
    if(f)
80106343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106347:	74 0b                	je     80106354 <sys_open+0x10f>
      fileclose(f);
80106349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634c:	89 04 24             	mov    %eax,(%esp)
8010634f:	e8 94 b3 ff ff       	call   801016e8 <fileclose>
    iunlockput(ip);
80106354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 b1 be ff ff       	call   80102210 <iunlockput>
    return -1;
8010635f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106364:	eb 63                	jmp    801063c9 <sys_open+0x184>
  }
  iunlock(ip);
80106366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106369:	89 04 24             	mov    %eax,(%esp)
8010636c:	e8 69 bd ff ff       	call   801020da <iunlock>

  f->type = FD_INODE;
80106371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106374:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010637a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106380:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106383:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106386:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010638d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106390:	83 e0 01             	and    $0x1,%eax
80106393:	85 c0                	test   %eax,%eax
80106395:	0f 94 c2             	sete   %dl
80106398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010639e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063a1:	83 e0 01             	and    $0x1,%eax
801063a4:	84 c0                	test   %al,%al
801063a6:	75 0a                	jne    801063b2 <sys_open+0x16d>
801063a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ab:	83 e0 02             	and    $0x2,%eax
801063ae:	85 c0                	test   %eax,%eax
801063b0:	74 07                	je     801063b9 <sys_open+0x174>
801063b2:	b8 01 00 00 00       	mov    $0x1,%eax
801063b7:	eb 05                	jmp    801063be <sys_open+0x179>
801063b9:	b8 00 00 00 00       	mov    $0x0,%eax
801063be:	89 c2                	mov    %eax,%edx
801063c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801063c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063c9:	c9                   	leave  
801063ca:	c3                   	ret    

801063cb <sys_mkdir>:

int
sys_mkdir(void)
{
801063cb:	55                   	push   %ebp
801063cc:	89 e5                	mov    %esp,%ebp
801063ce:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801063d1:	e8 6b d5 ff ff       	call   80103941 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801063dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e4:	e8 17 f5 ff ff       	call   80105900 <argstr>
801063e9:	85 c0                	test   %eax,%eax
801063eb:	78 2c                	js     80106419 <sys_mkdir+0x4e>
801063ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063f7:	00 
801063f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063ff:	00 
80106400:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106407:	00 
80106408:	89 04 24             	mov    %eax,(%esp)
8010640b:	e8 75 fc ff ff       	call   80106085 <create>
80106410:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106413:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106417:	75 0c                	jne    80106425 <sys_mkdir+0x5a>
    commit_trans();
80106419:	e8 6c d5 ff ff       	call   8010398a <commit_trans>
    return -1;
8010641e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106423:	eb 15                	jmp    8010643a <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106428:	89 04 24             	mov    %eax,(%esp)
8010642b:	e8 e0 bd ff ff       	call   80102210 <iunlockput>
  commit_trans();
80106430:	e8 55 d5 ff ff       	call   8010398a <commit_trans>
  return 0;
80106435:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010643a:	c9                   	leave  
8010643b:	c3                   	ret    

8010643c <sys_mknod>:

int
sys_mknod(void)
{
8010643c:	55                   	push   %ebp
8010643d:	89 e5                	mov    %esp,%ebp
8010643f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80106442:	e8 fa d4 ff ff       	call   80103941 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80106447:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010644a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106455:	e8 a6 f4 ff ff       	call   80105900 <argstr>
8010645a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010645d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106461:	78 5e                	js     801064c1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106463:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106466:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106471:	e8 f0 f3 ff ff       	call   80105866 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80106476:	85 c0                	test   %eax,%eax
80106478:	78 47                	js     801064c1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010647a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010647d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106481:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106488:	e8 d9 f3 ff ff       	call   80105866 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010648d:	85 c0                	test   %eax,%eax
8010648f:	78 30                	js     801064c1 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106494:	0f bf c8             	movswl %ax,%ecx
80106497:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010649a:	0f bf d0             	movswl %ax,%edx
8010649d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801064a0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801064a4:	89 54 24 08          	mov    %edx,0x8(%esp)
801064a8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801064af:	00 
801064b0:	89 04 24             	mov    %eax,(%esp)
801064b3:	e8 cd fb ff ff       	call   80106085 <create>
801064b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064bf:	75 0c                	jne    801064cd <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801064c1:	e8 c4 d4 ff ff       	call   8010398a <commit_trans>
    return -1;
801064c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cb:	eb 15                	jmp    801064e2 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801064cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d0:	89 04 24             	mov    %eax,(%esp)
801064d3:	e8 38 bd ff ff       	call   80102210 <iunlockput>
  commit_trans();
801064d8:	e8 ad d4 ff ff       	call   8010398a <commit_trans>
  return 0;
801064dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e2:	c9                   	leave  
801064e3:	c3                   	ret    

801064e4 <sys_chdir>:

int
sys_chdir(void)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
801064e7:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801064ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801064f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f8:	e8 03 f4 ff ff       	call   80105900 <argstr>
801064fd:	85 c0                	test   %eax,%eax
801064ff:	78 14                	js     80106515 <sys_chdir+0x31>
80106501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106504:	89 04 24             	mov    %eax,(%esp)
80106507:	e8 22 c6 ff ff       	call   80102b2e <namei>
8010650c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010650f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106513:	75 07                	jne    8010651c <sys_chdir+0x38>
    return -1;
80106515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651a:	eb 57                	jmp    80106573 <sys_chdir+0x8f>
  ilock(ip);
8010651c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651f:	89 04 24             	mov    %eax,(%esp)
80106522:	e8 65 ba ff ff       	call   80101f8c <ilock>
  if(ip->type != T_DIR){
80106527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010652e:	66 83 f8 01          	cmp    $0x1,%ax
80106532:	74 12                	je     80106546 <sys_chdir+0x62>
    iunlockput(ip);
80106534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106537:	89 04 24             	mov    %eax,(%esp)
8010653a:	e8 d1 bc ff ff       	call   80102210 <iunlockput>
    return -1;
8010653f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106544:	eb 2d                	jmp    80106573 <sys_chdir+0x8f>
  }
  iunlock(ip);
80106546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106549:	89 04 24             	mov    %eax,(%esp)
8010654c:	e8 89 bb ff ff       	call   801020da <iunlock>
  iput(proc->cwd);
80106551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106557:	8b 40 68             	mov    0x68(%eax),%eax
8010655a:	89 04 24             	mov    %eax,(%esp)
8010655d:	e8 dd bb ff ff       	call   8010213f <iput>
  proc->cwd = ip;
80106562:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106568:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010656b:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010656e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106573:	c9                   	leave  
80106574:	c3                   	ret    

80106575 <sys_exec>:

int
sys_exec(void)
{
80106575:	55                   	push   %ebp
80106576:	89 e5                	mov    %esp,%ebp
80106578:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010657e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106581:	89 44 24 04          	mov    %eax,0x4(%esp)
80106585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010658c:	e8 6f f3 ff ff       	call   80105900 <argstr>
80106591:	85 c0                	test   %eax,%eax
80106593:	78 1a                	js     801065af <sys_exec+0x3a>
80106595:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010659b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010659f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065a6:	e8 bb f2 ff ff       	call   80105866 <argint>
801065ab:	85 c0                	test   %eax,%eax
801065ad:	79 0a                	jns    801065b9 <sys_exec+0x44>
    return -1;
801065af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b4:	e9 e2 00 00 00       	jmp    8010669b <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801065b9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801065c0:	00 
801065c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065c8:	00 
801065c9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065cf:	89 04 24             	mov    %eax,(%esp)
801065d2:	e8 3f ef ff ff       	call   80105516 <memset>
  for(i=0;; i++){
801065d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e1:	83 f8 1f             	cmp    $0x1f,%eax
801065e4:	76 0a                	jbe    801065f0 <sys_exec+0x7b>
      return -1;
801065e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065eb:	e9 ab 00 00 00       	jmp    8010669b <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801065f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f3:	c1 e0 02             	shl    $0x2,%eax
801065f6:	89 c2                	mov    %eax,%edx
801065f8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065fe:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80106601:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106607:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
8010660d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106611:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106615:	89 04 24             	mov    %eax,(%esp)
80106618:	e8 b7 f1 ff ff       	call   801057d4 <fetchint>
8010661d:	85 c0                	test   %eax,%eax
8010661f:	79 07                	jns    80106628 <sys_exec+0xb3>
      return -1;
80106621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106626:	eb 73                	jmp    8010669b <sys_exec+0x126>
    if(uarg == 0){
80106628:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010662e:	85 c0                	test   %eax,%eax
80106630:	75 26                	jne    80106658 <sys_exec+0xe3>
      argv[i] = 0;
80106632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106635:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010663c:	00 00 00 00 
      break;
80106640:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106644:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010664a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010664e:	89 04 24             	mov    %eax,(%esp)
80106651:	e8 6a aa ff ff       	call   801010c0 <exec>
80106656:	eb 43                	jmp    8010669b <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106662:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106668:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010666b:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106671:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106677:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010667b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010667f:	89 04 24             	mov    %eax,(%esp)
80106682:	e8 81 f1 ff ff       	call   80105808 <fetchstr>
80106687:	85 c0                	test   %eax,%eax
80106689:	79 07                	jns    80106692 <sys_exec+0x11d>
      return -1;
8010668b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106690:	eb 09                	jmp    8010669b <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106692:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
80106696:	e9 43 ff ff ff       	jmp    801065de <sys_exec+0x69>
  return exec(path, argv);
}
8010669b:	c9                   	leave  
8010669c:	c3                   	ret    

8010669d <sys_pipe>:

int
sys_pipe(void)
{
8010669d:	55                   	push   %ebp
8010669e:	89 e5                	mov    %esp,%ebp
801066a0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066a3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801066aa:	00 
801066ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066b9:	e8 e0 f1 ff ff       	call   8010589e <argptr>
801066be:	85 c0                	test   %eax,%eax
801066c0:	79 0a                	jns    801066cc <sys_pipe+0x2f>
    return -1;
801066c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c7:	e9 9b 00 00 00       	jmp    80106767 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801066cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066d6:	89 04 24             	mov    %eax,(%esp)
801066d9:	e8 7e dc ff ff       	call   8010435c <pipealloc>
801066de:	85 c0                	test   %eax,%eax
801066e0:	79 07                	jns    801066e9 <sys_pipe+0x4c>
    return -1;
801066e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e7:	eb 7e                	jmp    80106767 <sys_pipe+0xca>
  fd0 = -1;
801066e9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066f3:	89 04 24             	mov    %eax,(%esp)
801066f6:	e8 82 f3 ff ff       	call   80105a7d <fdalloc>
801066fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106702:	78 14                	js     80106718 <sys_pipe+0x7b>
80106704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106707:	89 04 24             	mov    %eax,(%esp)
8010670a:	e8 6e f3 ff ff       	call   80105a7d <fdalloc>
8010670f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106712:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106716:	79 37                	jns    8010674f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010671c:	78 14                	js     80106732 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010671e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106724:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106727:	83 c2 08             	add    $0x8,%edx
8010672a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106731:	00 
    fileclose(rf);
80106732:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106735:	89 04 24             	mov    %eax,(%esp)
80106738:	e8 ab af ff ff       	call   801016e8 <fileclose>
    fileclose(wf);
8010673d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106740:	89 04 24             	mov    %eax,(%esp)
80106743:	e8 a0 af ff ff       	call   801016e8 <fileclose>
    return -1;
80106748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674d:	eb 18                	jmp    80106767 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010674f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106752:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106755:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106757:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010675a:	8d 50 04             	lea    0x4(%eax),%edx
8010675d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106760:	89 02                	mov    %eax,(%edx)
  return 0;
80106762:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106767:	c9                   	leave  
80106768:	c3                   	ret    
80106769:	00 00                	add    %al,(%eax)
	...

8010676c <sys_fork>:

int add_path(char*);

int
sys_fork(void)
{
8010676c:	55                   	push   %ebp
8010676d:	89 e5                	mov    %esp,%ebp
8010676f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106772:	e8 9f e2 ff ff       	call   80104a16 <fork>
}
80106777:	c9                   	leave  
80106778:	c3                   	ret    

80106779 <sys_exit>:

int
sys_exit(void)
{
80106779:	55                   	push   %ebp
8010677a:	89 e5                	mov    %esp,%ebp
8010677c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010677f:	e8 f5 e3 ff ff       	call   80104b79 <exit>
  return 0;  // not reached
80106784:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106789:	c9                   	leave  
8010678a:	c3                   	ret    

8010678b <sys_wait>:

int
sys_wait(void)
{
8010678b:	55                   	push   %ebp
8010678c:	89 e5                	mov    %esp,%ebp
8010678e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106791:	e8 fb e4 ff ff       	call   80104c91 <wait>
}
80106796:	c9                   	leave  
80106797:	c3                   	ret    

80106798 <sys_kill>:

int
sys_kill(void)
{
80106798:	55                   	push   %ebp
80106799:	89 e5                	mov    %esp,%ebp
8010679b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010679e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067ac:	e8 b5 f0 ff ff       	call   80105866 <argint>
801067b1:	85 c0                	test   %eax,%eax
801067b3:	79 07                	jns    801067bc <sys_kill+0x24>
    return -1;
801067b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ba:	eb 0b                	jmp    801067c7 <sys_kill+0x2f>
  return kill(pid);
801067bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bf:	89 04 24             	mov    %eax,(%esp)
801067c2:	e8 26 e9 ff ff       	call   801050ed <kill>
}
801067c7:	c9                   	leave  
801067c8:	c3                   	ret    

801067c9 <sys_getpid>:

int
sys_getpid(void)
{
801067c9:	55                   	push   %ebp
801067ca:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801067cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067d2:	8b 40 10             	mov    0x10(%eax),%eax
}
801067d5:	5d                   	pop    %ebp
801067d6:	c3                   	ret    

801067d7 <sys_sbrk>:

int
sys_sbrk(void)
{
801067d7:	55                   	push   %ebp
801067d8:	89 e5                	mov    %esp,%ebp
801067da:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801067dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801067e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067eb:	e8 76 f0 ff ff       	call   80105866 <argint>
801067f0:	85 c0                	test   %eax,%eax
801067f2:	79 07                	jns    801067fb <sys_sbrk+0x24>
    return -1;
801067f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f9:	eb 24                	jmp    8010681f <sys_sbrk+0x48>
  addr = proc->sz;
801067fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106801:	8b 00                	mov    (%eax),%eax
80106803:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106809:	89 04 24             	mov    %eax,(%esp)
8010680c:	e8 60 e1 ff ff       	call   80104971 <growproc>
80106811:	85 c0                	test   %eax,%eax
80106813:	79 07                	jns    8010681c <sys_sbrk+0x45>
    return -1;
80106815:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010681a:	eb 03                	jmp    8010681f <sys_sbrk+0x48>
  return addr;
8010681c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010681f:	c9                   	leave  
80106820:	c3                   	ret    

80106821 <sys_sleep>:

int
sys_sleep(void)
{
80106821:	55                   	push   %ebp
80106822:	89 e5                	mov    %esp,%ebp
80106824:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106827:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010682a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010682e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106835:	e8 2c f0 ff ff       	call   80105866 <argint>
8010683a:	85 c0                	test   %eax,%eax
8010683c:	79 07                	jns    80106845 <sys_sleep+0x24>
    return -1;
8010683e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106843:	eb 6c                	jmp    801068b1 <sys_sleep+0x90>
  acquire(&tickslock);
80106845:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
8010684c:	e8 76 ea ff ff       	call   801052c7 <acquire>
  ticks0 = ticks;
80106851:	a1 60 36 11 80       	mov    0x80113660,%eax
80106856:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106859:	eb 34                	jmp    8010688f <sys_sleep+0x6e>
    if(proc->killed){
8010685b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106861:	8b 40 24             	mov    0x24(%eax),%eax
80106864:	85 c0                	test   %eax,%eax
80106866:	74 13                	je     8010687b <sys_sleep+0x5a>
      release(&tickslock);
80106868:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
8010686f:	e8 b5 ea ff ff       	call   80105329 <release>
      return -1;
80106874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106879:	eb 36                	jmp    801068b1 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010687b:	c7 44 24 04 20 2e 11 	movl   $0x80112e20,0x4(%esp)
80106882:	80 
80106883:	c7 04 24 60 36 11 80 	movl   $0x80113660,(%esp)
8010688a:	e8 5a e7 ff ff       	call   80104fe9 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010688f:	a1 60 36 11 80       	mov    0x80113660,%eax
80106894:	89 c2                	mov    %eax,%edx
80106896:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010689c:	39 c2                	cmp    %eax,%edx
8010689e:	72 bb                	jb     8010685b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801068a0:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
801068a7:	e8 7d ea ff ff       	call   80105329 <release>
  return 0;
801068ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068b1:	c9                   	leave  
801068b2:	c3                   	ret    

801068b3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801068b3:	55                   	push   %ebp
801068b4:	89 e5                	mov    %esp,%ebp
801068b6:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801068b9:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
801068c0:	e8 02 ea ff ff       	call   801052c7 <acquire>
  xticks = ticks;
801068c5:	a1 60 36 11 80       	mov    0x80113660,%eax
801068ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801068cd:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
801068d4:	e8 50 ea ff ff       	call   80105329 <release>
  return xticks;
801068d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068dc:	c9                   	leave  
801068dd:	c3                   	ret    

801068de <sys_add_path>:

// assignment1 - 1.2 - returning to the "real" implementation in sh.c
int
sys_add_path(void) {
801068de:	55                   	push   %ebp
801068df:	89 e5                	mov    %esp,%ebp
801068e1:	83 ec 28             	sub    $0x28,%esp
	  char *path;
	  if(argstr(0, &path) < 0)
801068e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801068eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068f2:	e8 09 f0 ff ff       	call   80105900 <argstr>
801068f7:	85 c0                	test   %eax,%eax
801068f9:	79 07                	jns    80106902 <sys_add_path+0x24>
	    return -1;
801068fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106900:	eb 0b                	jmp    8010690d <sys_add_path+0x2f>
	  return add_path(path);
80106902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106905:	89 04 24             	mov    %eax,(%esp)
80106908:	e8 89 ac ff ff       	call   80101596 <add_path>

}
8010690d:	c9                   	leave  
8010690e:	c3                   	ret    
	...

80106910 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106910:	55                   	push   %ebp
80106911:	89 e5                	mov    %esp,%ebp
80106913:	83 ec 08             	sub    $0x8,%esp
80106916:	8b 55 08             	mov    0x8(%ebp),%edx
80106919:	8b 45 0c             	mov    0xc(%ebp),%eax
8010691c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106920:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106923:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106927:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010692b:	ee                   	out    %al,(%dx)
}
8010692c:	c9                   	leave  
8010692d:	c3                   	ret    

8010692e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010692e:	55                   	push   %ebp
8010692f:	89 e5                	mov    %esp,%ebp
80106931:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106934:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010693b:	00 
8010693c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106943:	e8 c8 ff ff ff       	call   80106910 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106948:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010694f:	00 
80106950:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106957:	e8 b4 ff ff ff       	call   80106910 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010695c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106963:	00 
80106964:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010696b:	e8 a0 ff ff ff       	call   80106910 <outb>
  picenable(IRQ_TIMER);
80106970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106977:	e8 69 d8 ff ff       	call   801041e5 <picenable>
}
8010697c:	c9                   	leave  
8010697d:	c3                   	ret    
	...

80106980 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106980:	1e                   	push   %ds
  pushl %es
80106981:	06                   	push   %es
  pushl %fs
80106982:	0f a0                	push   %fs
  pushl %gs
80106984:	0f a8                	push   %gs
  pushal
80106986:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106987:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010698b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010698d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010698f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106993:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106995:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106997:	54                   	push   %esp
  call trap
80106998:	e8 de 01 00 00       	call   80106b7b <trap>
  addl $4, %esp
8010699d:	83 c4 04             	add    $0x4,%esp

801069a0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801069a0:	61                   	popa   
  popl %gs
801069a1:	0f a9                	pop    %gs
  popl %fs
801069a3:	0f a1                	pop    %fs
  popl %es
801069a5:	07                   	pop    %es
  popl %ds
801069a6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801069a7:	83 c4 08             	add    $0x8,%esp
  iret
801069aa:	cf                   	iret   
	...

801069ac <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801069ac:	55                   	push   %ebp
801069ad:	89 e5                	mov    %esp,%ebp
801069af:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801069b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801069b5:	83 e8 01             	sub    $0x1,%eax
801069b8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801069bc:	8b 45 08             	mov    0x8(%ebp),%eax
801069bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801069c3:	8b 45 08             	mov    0x8(%ebp),%eax
801069c6:	c1 e8 10             	shr    $0x10,%eax
801069c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801069cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801069d0:	0f 01 18             	lidtl  (%eax)
}
801069d3:	c9                   	leave  
801069d4:	c3                   	ret    

801069d5 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801069d5:	55                   	push   %ebp
801069d6:	89 e5                	mov    %esp,%ebp
801069d8:	53                   	push   %ebx
801069d9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801069dc:	0f 20 d3             	mov    %cr2,%ebx
801069df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801069e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801069e5:	83 c4 10             	add    $0x10,%esp
801069e8:	5b                   	pop    %ebx
801069e9:	5d                   	pop    %ebp
801069ea:	c3                   	ret    

801069eb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801069eb:	55                   	push   %ebp
801069ec:	89 e5                	mov    %esp,%ebp
801069ee:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801069f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069f8:	e9 c3 00 00 00       	jmp    80106ac0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801069fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a00:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106a07:	89 c2                	mov    %eax,%edx
80106a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0c:	66 89 14 c5 60 2e 11 	mov    %dx,-0x7feed1a0(,%eax,8)
80106a13:	80 
80106a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a17:	66 c7 04 c5 62 2e 11 	movw   $0x8,-0x7feed19e(,%eax,8)
80106a1e:	80 08 00 
80106a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a24:	0f b6 14 c5 64 2e 11 	movzbl -0x7feed19c(,%eax,8),%edx
80106a2b:	80 
80106a2c:	83 e2 e0             	and    $0xffffffe0,%edx
80106a2f:	88 14 c5 64 2e 11 80 	mov    %dl,-0x7feed19c(,%eax,8)
80106a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a39:	0f b6 14 c5 64 2e 11 	movzbl -0x7feed19c(,%eax,8),%edx
80106a40:	80 
80106a41:	83 e2 1f             	and    $0x1f,%edx
80106a44:	88 14 c5 64 2e 11 80 	mov    %dl,-0x7feed19c(,%eax,8)
80106a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4e:	0f b6 14 c5 65 2e 11 	movzbl -0x7feed19b(,%eax,8),%edx
80106a55:	80 
80106a56:	83 e2 f0             	and    $0xfffffff0,%edx
80106a59:	83 ca 0e             	or     $0xe,%edx
80106a5c:	88 14 c5 65 2e 11 80 	mov    %dl,-0x7feed19b(,%eax,8)
80106a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a66:	0f b6 14 c5 65 2e 11 	movzbl -0x7feed19b(,%eax,8),%edx
80106a6d:	80 
80106a6e:	83 e2 ef             	and    $0xffffffef,%edx
80106a71:	88 14 c5 65 2e 11 80 	mov    %dl,-0x7feed19b(,%eax,8)
80106a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7b:	0f b6 14 c5 65 2e 11 	movzbl -0x7feed19b(,%eax,8),%edx
80106a82:	80 
80106a83:	83 e2 9f             	and    $0xffffff9f,%edx
80106a86:	88 14 c5 65 2e 11 80 	mov    %dl,-0x7feed19b(,%eax,8)
80106a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a90:	0f b6 14 c5 65 2e 11 	movzbl -0x7feed19b(,%eax,8),%edx
80106a97:	80 
80106a98:	83 ca 80             	or     $0xffffff80,%edx
80106a9b:	88 14 c5 65 2e 11 80 	mov    %dl,-0x7feed19b(,%eax,8)
80106aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa5:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106aac:	c1 e8 10             	shr    $0x10,%eax
80106aaf:	89 c2                	mov    %eax,%edx
80106ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab4:	66 89 14 c5 66 2e 11 	mov    %dx,-0x7feed19a(,%eax,8)
80106abb:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106abc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ac0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106ac7:	0f 8e 30 ff ff ff    	jle    801069fd <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106acd:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106ad2:	66 a3 60 30 11 80    	mov    %ax,0x80113060
80106ad8:	66 c7 05 62 30 11 80 	movw   $0x8,0x80113062
80106adf:	08 00 
80106ae1:	0f b6 05 64 30 11 80 	movzbl 0x80113064,%eax
80106ae8:	83 e0 e0             	and    $0xffffffe0,%eax
80106aeb:	a2 64 30 11 80       	mov    %al,0x80113064
80106af0:	0f b6 05 64 30 11 80 	movzbl 0x80113064,%eax
80106af7:	83 e0 1f             	and    $0x1f,%eax
80106afa:	a2 64 30 11 80       	mov    %al,0x80113064
80106aff:	0f b6 05 65 30 11 80 	movzbl 0x80113065,%eax
80106b06:	83 c8 0f             	or     $0xf,%eax
80106b09:	a2 65 30 11 80       	mov    %al,0x80113065
80106b0e:	0f b6 05 65 30 11 80 	movzbl 0x80113065,%eax
80106b15:	83 e0 ef             	and    $0xffffffef,%eax
80106b18:	a2 65 30 11 80       	mov    %al,0x80113065
80106b1d:	0f b6 05 65 30 11 80 	movzbl 0x80113065,%eax
80106b24:	83 c8 60             	or     $0x60,%eax
80106b27:	a2 65 30 11 80       	mov    %al,0x80113065
80106b2c:	0f b6 05 65 30 11 80 	movzbl 0x80113065,%eax
80106b33:	83 c8 80             	or     $0xffffff80,%eax
80106b36:	a2 65 30 11 80       	mov    %al,0x80113065
80106b3b:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106b40:	c1 e8 10             	shr    $0x10,%eax
80106b43:	66 a3 66 30 11 80    	mov    %ax,0x80113066
  
  initlock(&tickslock, "time");
80106b49:	c7 44 24 04 50 8d 10 	movl   $0x80108d50,0x4(%esp)
80106b50:	80 
80106b51:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
80106b58:	e8 49 e7 ff ff       	call   801052a6 <initlock>
}
80106b5d:	c9                   	leave  
80106b5e:	c3                   	ret    

80106b5f <idtinit>:

void
idtinit(void)
{
80106b5f:	55                   	push   %ebp
80106b60:	89 e5                	mov    %esp,%ebp
80106b62:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106b65:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106b6c:	00 
80106b6d:	c7 04 24 60 2e 11 80 	movl   $0x80112e60,(%esp)
80106b74:	e8 33 fe ff ff       	call   801069ac <lidt>
}
80106b79:	c9                   	leave  
80106b7a:	c3                   	ret    

80106b7b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106b7b:	55                   	push   %ebp
80106b7c:	89 e5                	mov    %esp,%ebp
80106b7e:	57                   	push   %edi
80106b7f:	56                   	push   %esi
80106b80:	53                   	push   %ebx
80106b81:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106b84:	8b 45 08             	mov    0x8(%ebp),%eax
80106b87:	8b 40 30             	mov    0x30(%eax),%eax
80106b8a:	83 f8 40             	cmp    $0x40,%eax
80106b8d:	75 3e                	jne    80106bcd <trap+0x52>
    if(proc->killed)
80106b8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b95:	8b 40 24             	mov    0x24(%eax),%eax
80106b98:	85 c0                	test   %eax,%eax
80106b9a:	74 05                	je     80106ba1 <trap+0x26>
      exit();
80106b9c:	e8 d8 df ff ff       	call   80104b79 <exit>
    proc->tf = tf;
80106ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba7:	8b 55 08             	mov    0x8(%ebp),%edx
80106baa:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106bad:	e8 91 ed ff ff       	call   80105943 <syscall>
    if(proc->killed)
80106bb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb8:	8b 40 24             	mov    0x24(%eax),%eax
80106bbb:	85 c0                	test   %eax,%eax
80106bbd:	0f 84 34 02 00 00    	je     80106df7 <trap+0x27c>
      exit();
80106bc3:	e8 b1 df ff ff       	call   80104b79 <exit>
    return;
80106bc8:	e9 2a 02 00 00       	jmp    80106df7 <trap+0x27c>
  }

  switch(tf->trapno){
80106bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd0:	8b 40 30             	mov    0x30(%eax),%eax
80106bd3:	83 e8 20             	sub    $0x20,%eax
80106bd6:	83 f8 1f             	cmp    $0x1f,%eax
80106bd9:	0f 87 bc 00 00 00    	ja     80106c9b <trap+0x120>
80106bdf:	8b 04 85 f8 8d 10 80 	mov    -0x7fef7208(,%eax,4),%eax
80106be6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106be8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bee:	0f b6 00             	movzbl (%eax),%eax
80106bf1:	84 c0                	test   %al,%al
80106bf3:	75 31                	jne    80106c26 <trap+0xab>
      acquire(&tickslock);
80106bf5:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
80106bfc:	e8 c6 e6 ff ff       	call   801052c7 <acquire>
      ticks++;
80106c01:	a1 60 36 11 80       	mov    0x80113660,%eax
80106c06:	83 c0 01             	add    $0x1,%eax
80106c09:	a3 60 36 11 80       	mov    %eax,0x80113660
      wakeup(&ticks);
80106c0e:	c7 04 24 60 36 11 80 	movl   $0x80113660,(%esp)
80106c15:	e8 a8 e4 ff ff       	call   801050c2 <wakeup>
      release(&tickslock);
80106c1a:	c7 04 24 20 2e 11 80 	movl   $0x80112e20,(%esp)
80106c21:	e8 03 e7 ff ff       	call   80105329 <release>
    }
    lapiceoi();
80106c26:	e8 e2 c9 ff ff       	call   8010360d <lapiceoi>
    break;
80106c2b:	e9 41 01 00 00       	jmp    80106d71 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c30:	e8 e0 c1 ff ff       	call   80102e15 <ideintr>
    lapiceoi();
80106c35:	e8 d3 c9 ff ff       	call   8010360d <lapiceoi>
    break;
80106c3a:	e9 32 01 00 00       	jmp    80106d71 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106c3f:	e8 a7 c7 ff ff       	call   801033eb <kbdintr>
    lapiceoi();
80106c44:	e8 c4 c9 ff ff       	call   8010360d <lapiceoi>
    break;
80106c49:	e9 23 01 00 00       	jmp    80106d71 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106c4e:	e8 a9 03 00 00       	call   80106ffc <uartintr>
    lapiceoi();
80106c53:	e8 b5 c9 ff ff       	call   8010360d <lapiceoi>
    break;
80106c58:	e9 14 01 00 00       	jmp    80106d71 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106c5d:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c60:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106c63:	8b 45 08             	mov    0x8(%ebp),%eax
80106c66:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c6a:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106c6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c73:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c76:	0f b6 c0             	movzbl %al,%eax
80106c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c7d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c81:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c85:	c7 04 24 58 8d 10 80 	movl   $0x80108d58,(%esp)
80106c8c:	e8 10 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c91:	e8 77 c9 ff ff       	call   8010360d <lapiceoi>
    break;
80106c96:	e9 d6 00 00 00       	jmp    80106d71 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca1:	85 c0                	test   %eax,%eax
80106ca3:	74 11                	je     80106cb6 <trap+0x13b>
80106ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cac:	0f b7 c0             	movzwl %ax,%eax
80106caf:	83 e0 03             	and    $0x3,%eax
80106cb2:	85 c0                	test   %eax,%eax
80106cb4:	75 46                	jne    80106cfc <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cb6:	e8 1a fd ff ff       	call   801069d5 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106cbb:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cbe:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106cc1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106cc8:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ccb:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106cce:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cd1:	8b 52 30             	mov    0x30(%edx),%edx
80106cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
80106cd8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106cdc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ce0:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ce4:	c7 04 24 7c 8d 10 80 	movl   $0x80108d7c,(%esp)
80106ceb:	e8 b1 96 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106cf0:	c7 04 24 ae 8d 10 80 	movl   $0x80108dae,(%esp)
80106cf7:	e8 41 98 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cfc:	e8 d4 fc ff ff       	call   801069d5 <rcr2>
80106d01:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d03:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d06:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d0f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d12:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d15:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d18:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d1b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d1e:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d27:	83 c0 6c             	add    $0x6c,%eax
80106d2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106d2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d33:	8b 40 10             	mov    0x10(%eax),%eax
80106d36:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106d3a:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106d3e:	89 74 24 14          	mov    %esi,0x14(%esp)
80106d42:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106d46:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106d4d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d55:	c7 04 24 b4 8d 10 80 	movl   $0x80108db4,(%esp)
80106d5c:	e8 40 96 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106d61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d67:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d6e:	eb 01                	jmp    80106d71 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106d70:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d77:	85 c0                	test   %eax,%eax
80106d79:	74 24                	je     80106d9f <trap+0x224>
80106d7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d81:	8b 40 24             	mov    0x24(%eax),%eax
80106d84:	85 c0                	test   %eax,%eax
80106d86:	74 17                	je     80106d9f <trap+0x224>
80106d88:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d8f:	0f b7 c0             	movzwl %ax,%eax
80106d92:	83 e0 03             	and    $0x3,%eax
80106d95:	83 f8 03             	cmp    $0x3,%eax
80106d98:	75 05                	jne    80106d9f <trap+0x224>
    exit();
80106d9a:	e8 da dd ff ff       	call   80104b79 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106d9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106da5:	85 c0                	test   %eax,%eax
80106da7:	74 1e                	je     80106dc7 <trap+0x24c>
80106da9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106daf:	8b 40 0c             	mov    0xc(%eax),%eax
80106db2:	83 f8 04             	cmp    $0x4,%eax
80106db5:	75 10                	jne    80106dc7 <trap+0x24c>
80106db7:	8b 45 08             	mov    0x8(%ebp),%eax
80106dba:	8b 40 30             	mov    0x30(%eax),%eax
80106dbd:	83 f8 20             	cmp    $0x20,%eax
80106dc0:	75 05                	jne    80106dc7 <trap+0x24c>
    yield();
80106dc2:	e8 c4 e1 ff ff       	call   80104f8b <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106dc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dcd:	85 c0                	test   %eax,%eax
80106dcf:	74 27                	je     80106df8 <trap+0x27d>
80106dd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dd7:	8b 40 24             	mov    0x24(%eax),%eax
80106dda:	85 c0                	test   %eax,%eax
80106ddc:	74 1a                	je     80106df8 <trap+0x27d>
80106dde:	8b 45 08             	mov    0x8(%ebp),%eax
80106de1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106de5:	0f b7 c0             	movzwl %ax,%eax
80106de8:	83 e0 03             	and    $0x3,%eax
80106deb:	83 f8 03             	cmp    $0x3,%eax
80106dee:	75 08                	jne    80106df8 <trap+0x27d>
    exit();
80106df0:	e8 84 dd ff ff       	call   80104b79 <exit>
80106df5:	eb 01                	jmp    80106df8 <trap+0x27d>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106df7:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106df8:	83 c4 3c             	add    $0x3c,%esp
80106dfb:	5b                   	pop    %ebx
80106dfc:	5e                   	pop    %esi
80106dfd:	5f                   	pop    %edi
80106dfe:	5d                   	pop    %ebp
80106dff:	c3                   	ret    

80106e00 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106e00:	55                   	push   %ebp
80106e01:	89 e5                	mov    %esp,%ebp
80106e03:	53                   	push   %ebx
80106e04:	83 ec 14             	sub    $0x14,%esp
80106e07:	8b 45 08             	mov    0x8(%ebp),%eax
80106e0a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e0e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106e12:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106e16:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106e1a:	ec                   	in     (%dx),%al
80106e1b:	89 c3                	mov    %eax,%ebx
80106e1d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106e20:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106e24:	83 c4 14             	add    $0x14,%esp
80106e27:	5b                   	pop    %ebx
80106e28:	5d                   	pop    %ebp
80106e29:	c3                   	ret    

80106e2a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106e2a:	55                   	push   %ebp
80106e2b:	89 e5                	mov    %esp,%ebp
80106e2d:	83 ec 08             	sub    $0x8,%esp
80106e30:	8b 55 08             	mov    0x8(%ebp),%edx
80106e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e36:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106e3a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e3d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e41:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e45:	ee                   	out    %al,(%dx)
}
80106e46:	c9                   	leave  
80106e47:	c3                   	ret    

80106e48 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e48:	55                   	push   %ebp
80106e49:	89 e5                	mov    %esp,%ebp
80106e4b:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e55:	00 
80106e56:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e5d:	e8 c8 ff ff ff       	call   80106e2a <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e62:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106e69:	00 
80106e6a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e71:	e8 b4 ff ff ff       	call   80106e2a <outb>
  outb(COM1+0, 115200/9600);
80106e76:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106e7d:	00 
80106e7e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e85:	e8 a0 ff ff ff       	call   80106e2a <outb>
  outb(COM1+1, 0);
80106e8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e91:	00 
80106e92:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e99:	e8 8c ff ff ff       	call   80106e2a <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e9e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106ea5:	00 
80106ea6:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ead:	e8 78 ff ff ff       	call   80106e2a <outb>
  outb(COM1+4, 0);
80106eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106eb9:	00 
80106eba:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ec1:	e8 64 ff ff ff       	call   80106e2a <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ec6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106ecd:	00 
80106ece:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ed5:	e8 50 ff ff ff       	call   80106e2a <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106eda:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ee1:	e8 1a ff ff ff       	call   80106e00 <inb>
80106ee6:	3c ff                	cmp    $0xff,%al
80106ee8:	74 6c                	je     80106f56 <uartinit+0x10e>
    return;
  uart = 1;
80106eea:	c7 05 0c c6 10 80 01 	movl   $0x1,0x8010c60c
80106ef1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ef4:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106efb:	e8 00 ff ff ff       	call   80106e00 <inb>
  inb(COM1+0);
80106f00:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f07:	e8 f4 fe ff ff       	call   80106e00 <inb>
  picenable(IRQ_COM1);
80106f0c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106f13:	e8 cd d2 ff ff       	call   801041e5 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f1f:	00 
80106f20:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106f27:	e8 6e c1 ff ff       	call   8010309a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f2c:	c7 45 f4 78 8e 10 80 	movl   $0x80108e78,-0xc(%ebp)
80106f33:	eb 15                	jmp    80106f4a <uartinit+0x102>
    uartputc(*p);
80106f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f38:	0f b6 00             	movzbl (%eax),%eax
80106f3b:	0f be c0             	movsbl %al,%eax
80106f3e:	89 04 24             	mov    %eax,(%esp)
80106f41:	e8 13 00 00 00       	call   80106f59 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f4d:	0f b6 00             	movzbl (%eax),%eax
80106f50:	84 c0                	test   %al,%al
80106f52:	75 e1                	jne    80106f35 <uartinit+0xed>
80106f54:	eb 01                	jmp    80106f57 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106f56:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106f57:	c9                   	leave  
80106f58:	c3                   	ret    

80106f59 <uartputc>:

void
uartputc(int c)
{
80106f59:	55                   	push   %ebp
80106f5a:	89 e5                	mov    %esp,%ebp
80106f5c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106f5f:	a1 0c c6 10 80       	mov    0x8010c60c,%eax
80106f64:	85 c0                	test   %eax,%eax
80106f66:	74 4d                	je     80106fb5 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f6f:	eb 10                	jmp    80106f81 <uartputc+0x28>
    microdelay(10);
80106f71:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106f78:	e8 b5 c6 ff ff       	call   80103632 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f81:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f85:	7f 16                	jg     80106f9d <uartputc+0x44>
80106f87:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f8e:	e8 6d fe ff ff       	call   80106e00 <inb>
80106f93:	0f b6 c0             	movzbl %al,%eax
80106f96:	83 e0 20             	and    $0x20,%eax
80106f99:	85 c0                	test   %eax,%eax
80106f9b:	74 d4                	je     80106f71 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106fa0:	0f b6 c0             	movzbl %al,%eax
80106fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fae:	e8 77 fe ff ff       	call   80106e2a <outb>
80106fb3:	eb 01                	jmp    80106fb6 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106fb5:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106fb6:	c9                   	leave  
80106fb7:	c3                   	ret    

80106fb8 <uartgetc>:

static int
uartgetc(void)
{
80106fb8:	55                   	push   %ebp
80106fb9:	89 e5                	mov    %esp,%ebp
80106fbb:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106fbe:	a1 0c c6 10 80       	mov    0x8010c60c,%eax
80106fc3:	85 c0                	test   %eax,%eax
80106fc5:	75 07                	jne    80106fce <uartgetc+0x16>
    return -1;
80106fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fcc:	eb 2c                	jmp    80106ffa <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106fce:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106fd5:	e8 26 fe ff ff       	call   80106e00 <inb>
80106fda:	0f b6 c0             	movzbl %al,%eax
80106fdd:	83 e0 01             	and    $0x1,%eax
80106fe0:	85 c0                	test   %eax,%eax
80106fe2:	75 07                	jne    80106feb <uartgetc+0x33>
    return -1;
80106fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fe9:	eb 0f                	jmp    80106ffa <uartgetc+0x42>
  return inb(COM1+0);
80106feb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ff2:	e8 09 fe ff ff       	call   80106e00 <inb>
80106ff7:	0f b6 c0             	movzbl %al,%eax
}
80106ffa:	c9                   	leave  
80106ffb:	c3                   	ret    

80106ffc <uartintr>:

void
uartintr(void)
{
80106ffc:	55                   	push   %ebp
80106ffd:	89 e5                	mov    %esp,%ebp
80106fff:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107002:	c7 04 24 b8 6f 10 80 	movl   $0x80106fb8,(%esp)
80107009:	e8 d2 97 ff ff       	call   801007e0 <consoleintr>
}
8010700e:	c9                   	leave  
8010700f:	c3                   	ret    

80107010 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $0
80107012:	6a 00                	push   $0x0
  jmp alltraps
80107014:	e9 67 f9 ff ff       	jmp    80106980 <alltraps>

80107019 <vector1>:
.globl vector1
vector1:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $1
8010701b:	6a 01                	push   $0x1
  jmp alltraps
8010701d:	e9 5e f9 ff ff       	jmp    80106980 <alltraps>

80107022 <vector2>:
.globl vector2
vector2:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $2
80107024:	6a 02                	push   $0x2
  jmp alltraps
80107026:	e9 55 f9 ff ff       	jmp    80106980 <alltraps>

8010702b <vector3>:
.globl vector3
vector3:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $3
8010702d:	6a 03                	push   $0x3
  jmp alltraps
8010702f:	e9 4c f9 ff ff       	jmp    80106980 <alltraps>

80107034 <vector4>:
.globl vector4
vector4:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $4
80107036:	6a 04                	push   $0x4
  jmp alltraps
80107038:	e9 43 f9 ff ff       	jmp    80106980 <alltraps>

8010703d <vector5>:
.globl vector5
vector5:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $5
8010703f:	6a 05                	push   $0x5
  jmp alltraps
80107041:	e9 3a f9 ff ff       	jmp    80106980 <alltraps>

80107046 <vector6>:
.globl vector6
vector6:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $6
80107048:	6a 06                	push   $0x6
  jmp alltraps
8010704a:	e9 31 f9 ff ff       	jmp    80106980 <alltraps>

8010704f <vector7>:
.globl vector7
vector7:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $7
80107051:	6a 07                	push   $0x7
  jmp alltraps
80107053:	e9 28 f9 ff ff       	jmp    80106980 <alltraps>

80107058 <vector8>:
.globl vector8
vector8:
  pushl $8
80107058:	6a 08                	push   $0x8
  jmp alltraps
8010705a:	e9 21 f9 ff ff       	jmp    80106980 <alltraps>

8010705f <vector9>:
.globl vector9
vector9:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $9
80107061:	6a 09                	push   $0x9
  jmp alltraps
80107063:	e9 18 f9 ff ff       	jmp    80106980 <alltraps>

80107068 <vector10>:
.globl vector10
vector10:
  pushl $10
80107068:	6a 0a                	push   $0xa
  jmp alltraps
8010706a:	e9 11 f9 ff ff       	jmp    80106980 <alltraps>

8010706f <vector11>:
.globl vector11
vector11:
  pushl $11
8010706f:	6a 0b                	push   $0xb
  jmp alltraps
80107071:	e9 0a f9 ff ff       	jmp    80106980 <alltraps>

80107076 <vector12>:
.globl vector12
vector12:
  pushl $12
80107076:	6a 0c                	push   $0xc
  jmp alltraps
80107078:	e9 03 f9 ff ff       	jmp    80106980 <alltraps>

8010707d <vector13>:
.globl vector13
vector13:
  pushl $13
8010707d:	6a 0d                	push   $0xd
  jmp alltraps
8010707f:	e9 fc f8 ff ff       	jmp    80106980 <alltraps>

80107084 <vector14>:
.globl vector14
vector14:
  pushl $14
80107084:	6a 0e                	push   $0xe
  jmp alltraps
80107086:	e9 f5 f8 ff ff       	jmp    80106980 <alltraps>

8010708b <vector15>:
.globl vector15
vector15:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $15
8010708d:	6a 0f                	push   $0xf
  jmp alltraps
8010708f:	e9 ec f8 ff ff       	jmp    80106980 <alltraps>

80107094 <vector16>:
.globl vector16
vector16:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $16
80107096:	6a 10                	push   $0x10
  jmp alltraps
80107098:	e9 e3 f8 ff ff       	jmp    80106980 <alltraps>

8010709d <vector17>:
.globl vector17
vector17:
  pushl $17
8010709d:	6a 11                	push   $0x11
  jmp alltraps
8010709f:	e9 dc f8 ff ff       	jmp    80106980 <alltraps>

801070a4 <vector18>:
.globl vector18
vector18:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $18
801070a6:	6a 12                	push   $0x12
  jmp alltraps
801070a8:	e9 d3 f8 ff ff       	jmp    80106980 <alltraps>

801070ad <vector19>:
.globl vector19
vector19:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $19
801070af:	6a 13                	push   $0x13
  jmp alltraps
801070b1:	e9 ca f8 ff ff       	jmp    80106980 <alltraps>

801070b6 <vector20>:
.globl vector20
vector20:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $20
801070b8:	6a 14                	push   $0x14
  jmp alltraps
801070ba:	e9 c1 f8 ff ff       	jmp    80106980 <alltraps>

801070bf <vector21>:
.globl vector21
vector21:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $21
801070c1:	6a 15                	push   $0x15
  jmp alltraps
801070c3:	e9 b8 f8 ff ff       	jmp    80106980 <alltraps>

801070c8 <vector22>:
.globl vector22
vector22:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $22
801070ca:	6a 16                	push   $0x16
  jmp alltraps
801070cc:	e9 af f8 ff ff       	jmp    80106980 <alltraps>

801070d1 <vector23>:
.globl vector23
vector23:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $23
801070d3:	6a 17                	push   $0x17
  jmp alltraps
801070d5:	e9 a6 f8 ff ff       	jmp    80106980 <alltraps>

801070da <vector24>:
.globl vector24
vector24:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $24
801070dc:	6a 18                	push   $0x18
  jmp alltraps
801070de:	e9 9d f8 ff ff       	jmp    80106980 <alltraps>

801070e3 <vector25>:
.globl vector25
vector25:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $25
801070e5:	6a 19                	push   $0x19
  jmp alltraps
801070e7:	e9 94 f8 ff ff       	jmp    80106980 <alltraps>

801070ec <vector26>:
.globl vector26
vector26:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $26
801070ee:	6a 1a                	push   $0x1a
  jmp alltraps
801070f0:	e9 8b f8 ff ff       	jmp    80106980 <alltraps>

801070f5 <vector27>:
.globl vector27
vector27:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $27
801070f7:	6a 1b                	push   $0x1b
  jmp alltraps
801070f9:	e9 82 f8 ff ff       	jmp    80106980 <alltraps>

801070fe <vector28>:
.globl vector28
vector28:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $28
80107100:	6a 1c                	push   $0x1c
  jmp alltraps
80107102:	e9 79 f8 ff ff       	jmp    80106980 <alltraps>

80107107 <vector29>:
.globl vector29
vector29:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $29
80107109:	6a 1d                	push   $0x1d
  jmp alltraps
8010710b:	e9 70 f8 ff ff       	jmp    80106980 <alltraps>

80107110 <vector30>:
.globl vector30
vector30:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $30
80107112:	6a 1e                	push   $0x1e
  jmp alltraps
80107114:	e9 67 f8 ff ff       	jmp    80106980 <alltraps>

80107119 <vector31>:
.globl vector31
vector31:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $31
8010711b:	6a 1f                	push   $0x1f
  jmp alltraps
8010711d:	e9 5e f8 ff ff       	jmp    80106980 <alltraps>

80107122 <vector32>:
.globl vector32
vector32:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $32
80107124:	6a 20                	push   $0x20
  jmp alltraps
80107126:	e9 55 f8 ff ff       	jmp    80106980 <alltraps>

8010712b <vector33>:
.globl vector33
vector33:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $33
8010712d:	6a 21                	push   $0x21
  jmp alltraps
8010712f:	e9 4c f8 ff ff       	jmp    80106980 <alltraps>

80107134 <vector34>:
.globl vector34
vector34:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $34
80107136:	6a 22                	push   $0x22
  jmp alltraps
80107138:	e9 43 f8 ff ff       	jmp    80106980 <alltraps>

8010713d <vector35>:
.globl vector35
vector35:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $35
8010713f:	6a 23                	push   $0x23
  jmp alltraps
80107141:	e9 3a f8 ff ff       	jmp    80106980 <alltraps>

80107146 <vector36>:
.globl vector36
vector36:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $36
80107148:	6a 24                	push   $0x24
  jmp alltraps
8010714a:	e9 31 f8 ff ff       	jmp    80106980 <alltraps>

8010714f <vector37>:
.globl vector37
vector37:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $37
80107151:	6a 25                	push   $0x25
  jmp alltraps
80107153:	e9 28 f8 ff ff       	jmp    80106980 <alltraps>

80107158 <vector38>:
.globl vector38
vector38:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $38
8010715a:	6a 26                	push   $0x26
  jmp alltraps
8010715c:	e9 1f f8 ff ff       	jmp    80106980 <alltraps>

80107161 <vector39>:
.globl vector39
vector39:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $39
80107163:	6a 27                	push   $0x27
  jmp alltraps
80107165:	e9 16 f8 ff ff       	jmp    80106980 <alltraps>

8010716a <vector40>:
.globl vector40
vector40:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $40
8010716c:	6a 28                	push   $0x28
  jmp alltraps
8010716e:	e9 0d f8 ff ff       	jmp    80106980 <alltraps>

80107173 <vector41>:
.globl vector41
vector41:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $41
80107175:	6a 29                	push   $0x29
  jmp alltraps
80107177:	e9 04 f8 ff ff       	jmp    80106980 <alltraps>

8010717c <vector42>:
.globl vector42
vector42:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $42
8010717e:	6a 2a                	push   $0x2a
  jmp alltraps
80107180:	e9 fb f7 ff ff       	jmp    80106980 <alltraps>

80107185 <vector43>:
.globl vector43
vector43:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $43
80107187:	6a 2b                	push   $0x2b
  jmp alltraps
80107189:	e9 f2 f7 ff ff       	jmp    80106980 <alltraps>

8010718e <vector44>:
.globl vector44
vector44:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $44
80107190:	6a 2c                	push   $0x2c
  jmp alltraps
80107192:	e9 e9 f7 ff ff       	jmp    80106980 <alltraps>

80107197 <vector45>:
.globl vector45
vector45:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $45
80107199:	6a 2d                	push   $0x2d
  jmp alltraps
8010719b:	e9 e0 f7 ff ff       	jmp    80106980 <alltraps>

801071a0 <vector46>:
.globl vector46
vector46:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $46
801071a2:	6a 2e                	push   $0x2e
  jmp alltraps
801071a4:	e9 d7 f7 ff ff       	jmp    80106980 <alltraps>

801071a9 <vector47>:
.globl vector47
vector47:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $47
801071ab:	6a 2f                	push   $0x2f
  jmp alltraps
801071ad:	e9 ce f7 ff ff       	jmp    80106980 <alltraps>

801071b2 <vector48>:
.globl vector48
vector48:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $48
801071b4:	6a 30                	push   $0x30
  jmp alltraps
801071b6:	e9 c5 f7 ff ff       	jmp    80106980 <alltraps>

801071bb <vector49>:
.globl vector49
vector49:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $49
801071bd:	6a 31                	push   $0x31
  jmp alltraps
801071bf:	e9 bc f7 ff ff       	jmp    80106980 <alltraps>

801071c4 <vector50>:
.globl vector50
vector50:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $50
801071c6:	6a 32                	push   $0x32
  jmp alltraps
801071c8:	e9 b3 f7 ff ff       	jmp    80106980 <alltraps>

801071cd <vector51>:
.globl vector51
vector51:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $51
801071cf:	6a 33                	push   $0x33
  jmp alltraps
801071d1:	e9 aa f7 ff ff       	jmp    80106980 <alltraps>

801071d6 <vector52>:
.globl vector52
vector52:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $52
801071d8:	6a 34                	push   $0x34
  jmp alltraps
801071da:	e9 a1 f7 ff ff       	jmp    80106980 <alltraps>

801071df <vector53>:
.globl vector53
vector53:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $53
801071e1:	6a 35                	push   $0x35
  jmp alltraps
801071e3:	e9 98 f7 ff ff       	jmp    80106980 <alltraps>

801071e8 <vector54>:
.globl vector54
vector54:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $54
801071ea:	6a 36                	push   $0x36
  jmp alltraps
801071ec:	e9 8f f7 ff ff       	jmp    80106980 <alltraps>

801071f1 <vector55>:
.globl vector55
vector55:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $55
801071f3:	6a 37                	push   $0x37
  jmp alltraps
801071f5:	e9 86 f7 ff ff       	jmp    80106980 <alltraps>

801071fa <vector56>:
.globl vector56
vector56:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $56
801071fc:	6a 38                	push   $0x38
  jmp alltraps
801071fe:	e9 7d f7 ff ff       	jmp    80106980 <alltraps>

80107203 <vector57>:
.globl vector57
vector57:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $57
80107205:	6a 39                	push   $0x39
  jmp alltraps
80107207:	e9 74 f7 ff ff       	jmp    80106980 <alltraps>

8010720c <vector58>:
.globl vector58
vector58:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $58
8010720e:	6a 3a                	push   $0x3a
  jmp alltraps
80107210:	e9 6b f7 ff ff       	jmp    80106980 <alltraps>

80107215 <vector59>:
.globl vector59
vector59:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $59
80107217:	6a 3b                	push   $0x3b
  jmp alltraps
80107219:	e9 62 f7 ff ff       	jmp    80106980 <alltraps>

8010721e <vector60>:
.globl vector60
vector60:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $60
80107220:	6a 3c                	push   $0x3c
  jmp alltraps
80107222:	e9 59 f7 ff ff       	jmp    80106980 <alltraps>

80107227 <vector61>:
.globl vector61
vector61:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $61
80107229:	6a 3d                	push   $0x3d
  jmp alltraps
8010722b:	e9 50 f7 ff ff       	jmp    80106980 <alltraps>

80107230 <vector62>:
.globl vector62
vector62:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $62
80107232:	6a 3e                	push   $0x3e
  jmp alltraps
80107234:	e9 47 f7 ff ff       	jmp    80106980 <alltraps>

80107239 <vector63>:
.globl vector63
vector63:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $63
8010723b:	6a 3f                	push   $0x3f
  jmp alltraps
8010723d:	e9 3e f7 ff ff       	jmp    80106980 <alltraps>

80107242 <vector64>:
.globl vector64
vector64:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $64
80107244:	6a 40                	push   $0x40
  jmp alltraps
80107246:	e9 35 f7 ff ff       	jmp    80106980 <alltraps>

8010724b <vector65>:
.globl vector65
vector65:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $65
8010724d:	6a 41                	push   $0x41
  jmp alltraps
8010724f:	e9 2c f7 ff ff       	jmp    80106980 <alltraps>

80107254 <vector66>:
.globl vector66
vector66:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $66
80107256:	6a 42                	push   $0x42
  jmp alltraps
80107258:	e9 23 f7 ff ff       	jmp    80106980 <alltraps>

8010725d <vector67>:
.globl vector67
vector67:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $67
8010725f:	6a 43                	push   $0x43
  jmp alltraps
80107261:	e9 1a f7 ff ff       	jmp    80106980 <alltraps>

80107266 <vector68>:
.globl vector68
vector68:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $68
80107268:	6a 44                	push   $0x44
  jmp alltraps
8010726a:	e9 11 f7 ff ff       	jmp    80106980 <alltraps>

8010726f <vector69>:
.globl vector69
vector69:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $69
80107271:	6a 45                	push   $0x45
  jmp alltraps
80107273:	e9 08 f7 ff ff       	jmp    80106980 <alltraps>

80107278 <vector70>:
.globl vector70
vector70:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $70
8010727a:	6a 46                	push   $0x46
  jmp alltraps
8010727c:	e9 ff f6 ff ff       	jmp    80106980 <alltraps>

80107281 <vector71>:
.globl vector71
vector71:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $71
80107283:	6a 47                	push   $0x47
  jmp alltraps
80107285:	e9 f6 f6 ff ff       	jmp    80106980 <alltraps>

8010728a <vector72>:
.globl vector72
vector72:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $72
8010728c:	6a 48                	push   $0x48
  jmp alltraps
8010728e:	e9 ed f6 ff ff       	jmp    80106980 <alltraps>

80107293 <vector73>:
.globl vector73
vector73:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $73
80107295:	6a 49                	push   $0x49
  jmp alltraps
80107297:	e9 e4 f6 ff ff       	jmp    80106980 <alltraps>

8010729c <vector74>:
.globl vector74
vector74:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $74
8010729e:	6a 4a                	push   $0x4a
  jmp alltraps
801072a0:	e9 db f6 ff ff       	jmp    80106980 <alltraps>

801072a5 <vector75>:
.globl vector75
vector75:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $75
801072a7:	6a 4b                	push   $0x4b
  jmp alltraps
801072a9:	e9 d2 f6 ff ff       	jmp    80106980 <alltraps>

801072ae <vector76>:
.globl vector76
vector76:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $76
801072b0:	6a 4c                	push   $0x4c
  jmp alltraps
801072b2:	e9 c9 f6 ff ff       	jmp    80106980 <alltraps>

801072b7 <vector77>:
.globl vector77
vector77:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $77
801072b9:	6a 4d                	push   $0x4d
  jmp alltraps
801072bb:	e9 c0 f6 ff ff       	jmp    80106980 <alltraps>

801072c0 <vector78>:
.globl vector78
vector78:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $78
801072c2:	6a 4e                	push   $0x4e
  jmp alltraps
801072c4:	e9 b7 f6 ff ff       	jmp    80106980 <alltraps>

801072c9 <vector79>:
.globl vector79
vector79:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $79
801072cb:	6a 4f                	push   $0x4f
  jmp alltraps
801072cd:	e9 ae f6 ff ff       	jmp    80106980 <alltraps>

801072d2 <vector80>:
.globl vector80
vector80:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $80
801072d4:	6a 50                	push   $0x50
  jmp alltraps
801072d6:	e9 a5 f6 ff ff       	jmp    80106980 <alltraps>

801072db <vector81>:
.globl vector81
vector81:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $81
801072dd:	6a 51                	push   $0x51
  jmp alltraps
801072df:	e9 9c f6 ff ff       	jmp    80106980 <alltraps>

801072e4 <vector82>:
.globl vector82
vector82:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $82
801072e6:	6a 52                	push   $0x52
  jmp alltraps
801072e8:	e9 93 f6 ff ff       	jmp    80106980 <alltraps>

801072ed <vector83>:
.globl vector83
vector83:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $83
801072ef:	6a 53                	push   $0x53
  jmp alltraps
801072f1:	e9 8a f6 ff ff       	jmp    80106980 <alltraps>

801072f6 <vector84>:
.globl vector84
vector84:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $84
801072f8:	6a 54                	push   $0x54
  jmp alltraps
801072fa:	e9 81 f6 ff ff       	jmp    80106980 <alltraps>

801072ff <vector85>:
.globl vector85
vector85:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $85
80107301:	6a 55                	push   $0x55
  jmp alltraps
80107303:	e9 78 f6 ff ff       	jmp    80106980 <alltraps>

80107308 <vector86>:
.globl vector86
vector86:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $86
8010730a:	6a 56                	push   $0x56
  jmp alltraps
8010730c:	e9 6f f6 ff ff       	jmp    80106980 <alltraps>

80107311 <vector87>:
.globl vector87
vector87:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $87
80107313:	6a 57                	push   $0x57
  jmp alltraps
80107315:	e9 66 f6 ff ff       	jmp    80106980 <alltraps>

8010731a <vector88>:
.globl vector88
vector88:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $88
8010731c:	6a 58                	push   $0x58
  jmp alltraps
8010731e:	e9 5d f6 ff ff       	jmp    80106980 <alltraps>

80107323 <vector89>:
.globl vector89
vector89:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $89
80107325:	6a 59                	push   $0x59
  jmp alltraps
80107327:	e9 54 f6 ff ff       	jmp    80106980 <alltraps>

8010732c <vector90>:
.globl vector90
vector90:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $90
8010732e:	6a 5a                	push   $0x5a
  jmp alltraps
80107330:	e9 4b f6 ff ff       	jmp    80106980 <alltraps>

80107335 <vector91>:
.globl vector91
vector91:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $91
80107337:	6a 5b                	push   $0x5b
  jmp alltraps
80107339:	e9 42 f6 ff ff       	jmp    80106980 <alltraps>

8010733e <vector92>:
.globl vector92
vector92:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $92
80107340:	6a 5c                	push   $0x5c
  jmp alltraps
80107342:	e9 39 f6 ff ff       	jmp    80106980 <alltraps>

80107347 <vector93>:
.globl vector93
vector93:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $93
80107349:	6a 5d                	push   $0x5d
  jmp alltraps
8010734b:	e9 30 f6 ff ff       	jmp    80106980 <alltraps>

80107350 <vector94>:
.globl vector94
vector94:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $94
80107352:	6a 5e                	push   $0x5e
  jmp alltraps
80107354:	e9 27 f6 ff ff       	jmp    80106980 <alltraps>

80107359 <vector95>:
.globl vector95
vector95:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $95
8010735b:	6a 5f                	push   $0x5f
  jmp alltraps
8010735d:	e9 1e f6 ff ff       	jmp    80106980 <alltraps>

80107362 <vector96>:
.globl vector96
vector96:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $96
80107364:	6a 60                	push   $0x60
  jmp alltraps
80107366:	e9 15 f6 ff ff       	jmp    80106980 <alltraps>

8010736b <vector97>:
.globl vector97
vector97:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $97
8010736d:	6a 61                	push   $0x61
  jmp alltraps
8010736f:	e9 0c f6 ff ff       	jmp    80106980 <alltraps>

80107374 <vector98>:
.globl vector98
vector98:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $98
80107376:	6a 62                	push   $0x62
  jmp alltraps
80107378:	e9 03 f6 ff ff       	jmp    80106980 <alltraps>

8010737d <vector99>:
.globl vector99
vector99:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $99
8010737f:	6a 63                	push   $0x63
  jmp alltraps
80107381:	e9 fa f5 ff ff       	jmp    80106980 <alltraps>

80107386 <vector100>:
.globl vector100
vector100:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $100
80107388:	6a 64                	push   $0x64
  jmp alltraps
8010738a:	e9 f1 f5 ff ff       	jmp    80106980 <alltraps>

8010738f <vector101>:
.globl vector101
vector101:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $101
80107391:	6a 65                	push   $0x65
  jmp alltraps
80107393:	e9 e8 f5 ff ff       	jmp    80106980 <alltraps>

80107398 <vector102>:
.globl vector102
vector102:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $102
8010739a:	6a 66                	push   $0x66
  jmp alltraps
8010739c:	e9 df f5 ff ff       	jmp    80106980 <alltraps>

801073a1 <vector103>:
.globl vector103
vector103:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $103
801073a3:	6a 67                	push   $0x67
  jmp alltraps
801073a5:	e9 d6 f5 ff ff       	jmp    80106980 <alltraps>

801073aa <vector104>:
.globl vector104
vector104:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $104
801073ac:	6a 68                	push   $0x68
  jmp alltraps
801073ae:	e9 cd f5 ff ff       	jmp    80106980 <alltraps>

801073b3 <vector105>:
.globl vector105
vector105:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $105
801073b5:	6a 69                	push   $0x69
  jmp alltraps
801073b7:	e9 c4 f5 ff ff       	jmp    80106980 <alltraps>

801073bc <vector106>:
.globl vector106
vector106:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $106
801073be:	6a 6a                	push   $0x6a
  jmp alltraps
801073c0:	e9 bb f5 ff ff       	jmp    80106980 <alltraps>

801073c5 <vector107>:
.globl vector107
vector107:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $107
801073c7:	6a 6b                	push   $0x6b
  jmp alltraps
801073c9:	e9 b2 f5 ff ff       	jmp    80106980 <alltraps>

801073ce <vector108>:
.globl vector108
vector108:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $108
801073d0:	6a 6c                	push   $0x6c
  jmp alltraps
801073d2:	e9 a9 f5 ff ff       	jmp    80106980 <alltraps>

801073d7 <vector109>:
.globl vector109
vector109:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $109
801073d9:	6a 6d                	push   $0x6d
  jmp alltraps
801073db:	e9 a0 f5 ff ff       	jmp    80106980 <alltraps>

801073e0 <vector110>:
.globl vector110
vector110:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $110
801073e2:	6a 6e                	push   $0x6e
  jmp alltraps
801073e4:	e9 97 f5 ff ff       	jmp    80106980 <alltraps>

801073e9 <vector111>:
.globl vector111
vector111:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $111
801073eb:	6a 6f                	push   $0x6f
  jmp alltraps
801073ed:	e9 8e f5 ff ff       	jmp    80106980 <alltraps>

801073f2 <vector112>:
.globl vector112
vector112:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $112
801073f4:	6a 70                	push   $0x70
  jmp alltraps
801073f6:	e9 85 f5 ff ff       	jmp    80106980 <alltraps>

801073fb <vector113>:
.globl vector113
vector113:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $113
801073fd:	6a 71                	push   $0x71
  jmp alltraps
801073ff:	e9 7c f5 ff ff       	jmp    80106980 <alltraps>

80107404 <vector114>:
.globl vector114
vector114:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $114
80107406:	6a 72                	push   $0x72
  jmp alltraps
80107408:	e9 73 f5 ff ff       	jmp    80106980 <alltraps>

8010740d <vector115>:
.globl vector115
vector115:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $115
8010740f:	6a 73                	push   $0x73
  jmp alltraps
80107411:	e9 6a f5 ff ff       	jmp    80106980 <alltraps>

80107416 <vector116>:
.globl vector116
vector116:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $116
80107418:	6a 74                	push   $0x74
  jmp alltraps
8010741a:	e9 61 f5 ff ff       	jmp    80106980 <alltraps>

8010741f <vector117>:
.globl vector117
vector117:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $117
80107421:	6a 75                	push   $0x75
  jmp alltraps
80107423:	e9 58 f5 ff ff       	jmp    80106980 <alltraps>

80107428 <vector118>:
.globl vector118
vector118:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $118
8010742a:	6a 76                	push   $0x76
  jmp alltraps
8010742c:	e9 4f f5 ff ff       	jmp    80106980 <alltraps>

80107431 <vector119>:
.globl vector119
vector119:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $119
80107433:	6a 77                	push   $0x77
  jmp alltraps
80107435:	e9 46 f5 ff ff       	jmp    80106980 <alltraps>

8010743a <vector120>:
.globl vector120
vector120:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $120
8010743c:	6a 78                	push   $0x78
  jmp alltraps
8010743e:	e9 3d f5 ff ff       	jmp    80106980 <alltraps>

80107443 <vector121>:
.globl vector121
vector121:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $121
80107445:	6a 79                	push   $0x79
  jmp alltraps
80107447:	e9 34 f5 ff ff       	jmp    80106980 <alltraps>

8010744c <vector122>:
.globl vector122
vector122:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $122
8010744e:	6a 7a                	push   $0x7a
  jmp alltraps
80107450:	e9 2b f5 ff ff       	jmp    80106980 <alltraps>

80107455 <vector123>:
.globl vector123
vector123:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $123
80107457:	6a 7b                	push   $0x7b
  jmp alltraps
80107459:	e9 22 f5 ff ff       	jmp    80106980 <alltraps>

8010745e <vector124>:
.globl vector124
vector124:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $124
80107460:	6a 7c                	push   $0x7c
  jmp alltraps
80107462:	e9 19 f5 ff ff       	jmp    80106980 <alltraps>

80107467 <vector125>:
.globl vector125
vector125:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $125
80107469:	6a 7d                	push   $0x7d
  jmp alltraps
8010746b:	e9 10 f5 ff ff       	jmp    80106980 <alltraps>

80107470 <vector126>:
.globl vector126
vector126:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $126
80107472:	6a 7e                	push   $0x7e
  jmp alltraps
80107474:	e9 07 f5 ff ff       	jmp    80106980 <alltraps>

80107479 <vector127>:
.globl vector127
vector127:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $127
8010747b:	6a 7f                	push   $0x7f
  jmp alltraps
8010747d:	e9 fe f4 ff ff       	jmp    80106980 <alltraps>

80107482 <vector128>:
.globl vector128
vector128:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $128
80107484:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107489:	e9 f2 f4 ff ff       	jmp    80106980 <alltraps>

8010748e <vector129>:
.globl vector129
vector129:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $129
80107490:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107495:	e9 e6 f4 ff ff       	jmp    80106980 <alltraps>

8010749a <vector130>:
.globl vector130
vector130:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $130
8010749c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801074a1:	e9 da f4 ff ff       	jmp    80106980 <alltraps>

801074a6 <vector131>:
.globl vector131
vector131:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $131
801074a8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801074ad:	e9 ce f4 ff ff       	jmp    80106980 <alltraps>

801074b2 <vector132>:
.globl vector132
vector132:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $132
801074b4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074b9:	e9 c2 f4 ff ff       	jmp    80106980 <alltraps>

801074be <vector133>:
.globl vector133
vector133:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $133
801074c0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074c5:	e9 b6 f4 ff ff       	jmp    80106980 <alltraps>

801074ca <vector134>:
.globl vector134
vector134:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $134
801074cc:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801074d1:	e9 aa f4 ff ff       	jmp    80106980 <alltraps>

801074d6 <vector135>:
.globl vector135
vector135:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $135
801074d8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801074dd:	e9 9e f4 ff ff       	jmp    80106980 <alltraps>

801074e2 <vector136>:
.globl vector136
vector136:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $136
801074e4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801074e9:	e9 92 f4 ff ff       	jmp    80106980 <alltraps>

801074ee <vector137>:
.globl vector137
vector137:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $137
801074f0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801074f5:	e9 86 f4 ff ff       	jmp    80106980 <alltraps>

801074fa <vector138>:
.globl vector138
vector138:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $138
801074fc:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107501:	e9 7a f4 ff ff       	jmp    80106980 <alltraps>

80107506 <vector139>:
.globl vector139
vector139:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $139
80107508:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010750d:	e9 6e f4 ff ff       	jmp    80106980 <alltraps>

80107512 <vector140>:
.globl vector140
vector140:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $140
80107514:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107519:	e9 62 f4 ff ff       	jmp    80106980 <alltraps>

8010751e <vector141>:
.globl vector141
vector141:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $141
80107520:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107525:	e9 56 f4 ff ff       	jmp    80106980 <alltraps>

8010752a <vector142>:
.globl vector142
vector142:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $142
8010752c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107531:	e9 4a f4 ff ff       	jmp    80106980 <alltraps>

80107536 <vector143>:
.globl vector143
vector143:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $143
80107538:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010753d:	e9 3e f4 ff ff       	jmp    80106980 <alltraps>

80107542 <vector144>:
.globl vector144
vector144:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $144
80107544:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107549:	e9 32 f4 ff ff       	jmp    80106980 <alltraps>

8010754e <vector145>:
.globl vector145
vector145:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $145
80107550:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107555:	e9 26 f4 ff ff       	jmp    80106980 <alltraps>

8010755a <vector146>:
.globl vector146
vector146:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $146
8010755c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107561:	e9 1a f4 ff ff       	jmp    80106980 <alltraps>

80107566 <vector147>:
.globl vector147
vector147:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $147
80107568:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010756d:	e9 0e f4 ff ff       	jmp    80106980 <alltraps>

80107572 <vector148>:
.globl vector148
vector148:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $148
80107574:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107579:	e9 02 f4 ff ff       	jmp    80106980 <alltraps>

8010757e <vector149>:
.globl vector149
vector149:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $149
80107580:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107585:	e9 f6 f3 ff ff       	jmp    80106980 <alltraps>

8010758a <vector150>:
.globl vector150
vector150:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $150
8010758c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107591:	e9 ea f3 ff ff       	jmp    80106980 <alltraps>

80107596 <vector151>:
.globl vector151
vector151:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $151
80107598:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010759d:	e9 de f3 ff ff       	jmp    80106980 <alltraps>

801075a2 <vector152>:
.globl vector152
vector152:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $152
801075a4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801075a9:	e9 d2 f3 ff ff       	jmp    80106980 <alltraps>

801075ae <vector153>:
.globl vector153
vector153:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $153
801075b0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801075b5:	e9 c6 f3 ff ff       	jmp    80106980 <alltraps>

801075ba <vector154>:
.globl vector154
vector154:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $154
801075bc:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075c1:	e9 ba f3 ff ff       	jmp    80106980 <alltraps>

801075c6 <vector155>:
.globl vector155
vector155:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $155
801075c8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801075cd:	e9 ae f3 ff ff       	jmp    80106980 <alltraps>

801075d2 <vector156>:
.globl vector156
vector156:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $156
801075d4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801075d9:	e9 a2 f3 ff ff       	jmp    80106980 <alltraps>

801075de <vector157>:
.globl vector157
vector157:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $157
801075e0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801075e5:	e9 96 f3 ff ff       	jmp    80106980 <alltraps>

801075ea <vector158>:
.globl vector158
vector158:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $158
801075ec:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801075f1:	e9 8a f3 ff ff       	jmp    80106980 <alltraps>

801075f6 <vector159>:
.globl vector159
vector159:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $159
801075f8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075fd:	e9 7e f3 ff ff       	jmp    80106980 <alltraps>

80107602 <vector160>:
.globl vector160
vector160:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $160
80107604:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107609:	e9 72 f3 ff ff       	jmp    80106980 <alltraps>

8010760e <vector161>:
.globl vector161
vector161:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $161
80107610:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107615:	e9 66 f3 ff ff       	jmp    80106980 <alltraps>

8010761a <vector162>:
.globl vector162
vector162:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $162
8010761c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107621:	e9 5a f3 ff ff       	jmp    80106980 <alltraps>

80107626 <vector163>:
.globl vector163
vector163:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $163
80107628:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010762d:	e9 4e f3 ff ff       	jmp    80106980 <alltraps>

80107632 <vector164>:
.globl vector164
vector164:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $164
80107634:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107639:	e9 42 f3 ff ff       	jmp    80106980 <alltraps>

8010763e <vector165>:
.globl vector165
vector165:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $165
80107640:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107645:	e9 36 f3 ff ff       	jmp    80106980 <alltraps>

8010764a <vector166>:
.globl vector166
vector166:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $166
8010764c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107651:	e9 2a f3 ff ff       	jmp    80106980 <alltraps>

80107656 <vector167>:
.globl vector167
vector167:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $167
80107658:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010765d:	e9 1e f3 ff ff       	jmp    80106980 <alltraps>

80107662 <vector168>:
.globl vector168
vector168:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $168
80107664:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107669:	e9 12 f3 ff ff       	jmp    80106980 <alltraps>

8010766e <vector169>:
.globl vector169
vector169:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $169
80107670:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107675:	e9 06 f3 ff ff       	jmp    80106980 <alltraps>

8010767a <vector170>:
.globl vector170
vector170:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $170
8010767c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107681:	e9 fa f2 ff ff       	jmp    80106980 <alltraps>

80107686 <vector171>:
.globl vector171
vector171:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $171
80107688:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010768d:	e9 ee f2 ff ff       	jmp    80106980 <alltraps>

80107692 <vector172>:
.globl vector172
vector172:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $172
80107694:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107699:	e9 e2 f2 ff ff       	jmp    80106980 <alltraps>

8010769e <vector173>:
.globl vector173
vector173:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $173
801076a0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801076a5:	e9 d6 f2 ff ff       	jmp    80106980 <alltraps>

801076aa <vector174>:
.globl vector174
vector174:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $174
801076ac:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801076b1:	e9 ca f2 ff ff       	jmp    80106980 <alltraps>

801076b6 <vector175>:
.globl vector175
vector175:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $175
801076b8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076bd:	e9 be f2 ff ff       	jmp    80106980 <alltraps>

801076c2 <vector176>:
.globl vector176
vector176:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $176
801076c4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076c9:	e9 b2 f2 ff ff       	jmp    80106980 <alltraps>

801076ce <vector177>:
.globl vector177
vector177:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $177
801076d0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801076d5:	e9 a6 f2 ff ff       	jmp    80106980 <alltraps>

801076da <vector178>:
.globl vector178
vector178:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $178
801076dc:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801076e1:	e9 9a f2 ff ff       	jmp    80106980 <alltraps>

801076e6 <vector179>:
.globl vector179
vector179:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $179
801076e8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801076ed:	e9 8e f2 ff ff       	jmp    80106980 <alltraps>

801076f2 <vector180>:
.globl vector180
vector180:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $180
801076f4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801076f9:	e9 82 f2 ff ff       	jmp    80106980 <alltraps>

801076fe <vector181>:
.globl vector181
vector181:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $181
80107700:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107705:	e9 76 f2 ff ff       	jmp    80106980 <alltraps>

8010770a <vector182>:
.globl vector182
vector182:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $182
8010770c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107711:	e9 6a f2 ff ff       	jmp    80106980 <alltraps>

80107716 <vector183>:
.globl vector183
vector183:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $183
80107718:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010771d:	e9 5e f2 ff ff       	jmp    80106980 <alltraps>

80107722 <vector184>:
.globl vector184
vector184:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $184
80107724:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107729:	e9 52 f2 ff ff       	jmp    80106980 <alltraps>

8010772e <vector185>:
.globl vector185
vector185:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $185
80107730:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107735:	e9 46 f2 ff ff       	jmp    80106980 <alltraps>

8010773a <vector186>:
.globl vector186
vector186:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $186
8010773c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107741:	e9 3a f2 ff ff       	jmp    80106980 <alltraps>

80107746 <vector187>:
.globl vector187
vector187:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $187
80107748:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010774d:	e9 2e f2 ff ff       	jmp    80106980 <alltraps>

80107752 <vector188>:
.globl vector188
vector188:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $188
80107754:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107759:	e9 22 f2 ff ff       	jmp    80106980 <alltraps>

8010775e <vector189>:
.globl vector189
vector189:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $189
80107760:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107765:	e9 16 f2 ff ff       	jmp    80106980 <alltraps>

8010776a <vector190>:
.globl vector190
vector190:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $190
8010776c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107771:	e9 0a f2 ff ff       	jmp    80106980 <alltraps>

80107776 <vector191>:
.globl vector191
vector191:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $191
80107778:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010777d:	e9 fe f1 ff ff       	jmp    80106980 <alltraps>

80107782 <vector192>:
.globl vector192
vector192:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $192
80107784:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107789:	e9 f2 f1 ff ff       	jmp    80106980 <alltraps>

8010778e <vector193>:
.globl vector193
vector193:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $193
80107790:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107795:	e9 e6 f1 ff ff       	jmp    80106980 <alltraps>

8010779a <vector194>:
.globl vector194
vector194:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $194
8010779c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801077a1:	e9 da f1 ff ff       	jmp    80106980 <alltraps>

801077a6 <vector195>:
.globl vector195
vector195:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $195
801077a8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801077ad:	e9 ce f1 ff ff       	jmp    80106980 <alltraps>

801077b2 <vector196>:
.globl vector196
vector196:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $196
801077b4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077b9:	e9 c2 f1 ff ff       	jmp    80106980 <alltraps>

801077be <vector197>:
.globl vector197
vector197:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $197
801077c0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077c5:	e9 b6 f1 ff ff       	jmp    80106980 <alltraps>

801077ca <vector198>:
.globl vector198
vector198:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $198
801077cc:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801077d1:	e9 aa f1 ff ff       	jmp    80106980 <alltraps>

801077d6 <vector199>:
.globl vector199
vector199:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $199
801077d8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801077dd:	e9 9e f1 ff ff       	jmp    80106980 <alltraps>

801077e2 <vector200>:
.globl vector200
vector200:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $200
801077e4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801077e9:	e9 92 f1 ff ff       	jmp    80106980 <alltraps>

801077ee <vector201>:
.globl vector201
vector201:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $201
801077f0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801077f5:	e9 86 f1 ff ff       	jmp    80106980 <alltraps>

801077fa <vector202>:
.globl vector202
vector202:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $202
801077fc:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107801:	e9 7a f1 ff ff       	jmp    80106980 <alltraps>

80107806 <vector203>:
.globl vector203
vector203:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $203
80107808:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010780d:	e9 6e f1 ff ff       	jmp    80106980 <alltraps>

80107812 <vector204>:
.globl vector204
vector204:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $204
80107814:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107819:	e9 62 f1 ff ff       	jmp    80106980 <alltraps>

8010781e <vector205>:
.globl vector205
vector205:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $205
80107820:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107825:	e9 56 f1 ff ff       	jmp    80106980 <alltraps>

8010782a <vector206>:
.globl vector206
vector206:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $206
8010782c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107831:	e9 4a f1 ff ff       	jmp    80106980 <alltraps>

80107836 <vector207>:
.globl vector207
vector207:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $207
80107838:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010783d:	e9 3e f1 ff ff       	jmp    80106980 <alltraps>

80107842 <vector208>:
.globl vector208
vector208:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $208
80107844:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107849:	e9 32 f1 ff ff       	jmp    80106980 <alltraps>

8010784e <vector209>:
.globl vector209
vector209:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $209
80107850:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107855:	e9 26 f1 ff ff       	jmp    80106980 <alltraps>

8010785a <vector210>:
.globl vector210
vector210:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $210
8010785c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107861:	e9 1a f1 ff ff       	jmp    80106980 <alltraps>

80107866 <vector211>:
.globl vector211
vector211:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $211
80107868:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010786d:	e9 0e f1 ff ff       	jmp    80106980 <alltraps>

80107872 <vector212>:
.globl vector212
vector212:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $212
80107874:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107879:	e9 02 f1 ff ff       	jmp    80106980 <alltraps>

8010787e <vector213>:
.globl vector213
vector213:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $213
80107880:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107885:	e9 f6 f0 ff ff       	jmp    80106980 <alltraps>

8010788a <vector214>:
.globl vector214
vector214:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $214
8010788c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107891:	e9 ea f0 ff ff       	jmp    80106980 <alltraps>

80107896 <vector215>:
.globl vector215
vector215:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $215
80107898:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010789d:	e9 de f0 ff ff       	jmp    80106980 <alltraps>

801078a2 <vector216>:
.globl vector216
vector216:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $216
801078a4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801078a9:	e9 d2 f0 ff ff       	jmp    80106980 <alltraps>

801078ae <vector217>:
.globl vector217
vector217:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $217
801078b0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801078b5:	e9 c6 f0 ff ff       	jmp    80106980 <alltraps>

801078ba <vector218>:
.globl vector218
vector218:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $218
801078bc:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078c1:	e9 ba f0 ff ff       	jmp    80106980 <alltraps>

801078c6 <vector219>:
.globl vector219
vector219:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $219
801078c8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801078cd:	e9 ae f0 ff ff       	jmp    80106980 <alltraps>

801078d2 <vector220>:
.globl vector220
vector220:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $220
801078d4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801078d9:	e9 a2 f0 ff ff       	jmp    80106980 <alltraps>

801078de <vector221>:
.globl vector221
vector221:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $221
801078e0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801078e5:	e9 96 f0 ff ff       	jmp    80106980 <alltraps>

801078ea <vector222>:
.globl vector222
vector222:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $222
801078ec:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801078f1:	e9 8a f0 ff ff       	jmp    80106980 <alltraps>

801078f6 <vector223>:
.globl vector223
vector223:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $223
801078f8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078fd:	e9 7e f0 ff ff       	jmp    80106980 <alltraps>

80107902 <vector224>:
.globl vector224
vector224:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $224
80107904:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107909:	e9 72 f0 ff ff       	jmp    80106980 <alltraps>

8010790e <vector225>:
.globl vector225
vector225:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $225
80107910:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107915:	e9 66 f0 ff ff       	jmp    80106980 <alltraps>

8010791a <vector226>:
.globl vector226
vector226:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $226
8010791c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107921:	e9 5a f0 ff ff       	jmp    80106980 <alltraps>

80107926 <vector227>:
.globl vector227
vector227:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $227
80107928:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010792d:	e9 4e f0 ff ff       	jmp    80106980 <alltraps>

80107932 <vector228>:
.globl vector228
vector228:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $228
80107934:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107939:	e9 42 f0 ff ff       	jmp    80106980 <alltraps>

8010793e <vector229>:
.globl vector229
vector229:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $229
80107940:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107945:	e9 36 f0 ff ff       	jmp    80106980 <alltraps>

8010794a <vector230>:
.globl vector230
vector230:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $230
8010794c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107951:	e9 2a f0 ff ff       	jmp    80106980 <alltraps>

80107956 <vector231>:
.globl vector231
vector231:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $231
80107958:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010795d:	e9 1e f0 ff ff       	jmp    80106980 <alltraps>

80107962 <vector232>:
.globl vector232
vector232:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $232
80107964:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107969:	e9 12 f0 ff ff       	jmp    80106980 <alltraps>

8010796e <vector233>:
.globl vector233
vector233:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $233
80107970:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107975:	e9 06 f0 ff ff       	jmp    80106980 <alltraps>

8010797a <vector234>:
.globl vector234
vector234:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $234
8010797c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107981:	e9 fa ef ff ff       	jmp    80106980 <alltraps>

80107986 <vector235>:
.globl vector235
vector235:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $235
80107988:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010798d:	e9 ee ef ff ff       	jmp    80106980 <alltraps>

80107992 <vector236>:
.globl vector236
vector236:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $236
80107994:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107999:	e9 e2 ef ff ff       	jmp    80106980 <alltraps>

8010799e <vector237>:
.globl vector237
vector237:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $237
801079a0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801079a5:	e9 d6 ef ff ff       	jmp    80106980 <alltraps>

801079aa <vector238>:
.globl vector238
vector238:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $238
801079ac:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801079b1:	e9 ca ef ff ff       	jmp    80106980 <alltraps>

801079b6 <vector239>:
.globl vector239
vector239:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $239
801079b8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079bd:	e9 be ef ff ff       	jmp    80106980 <alltraps>

801079c2 <vector240>:
.globl vector240
vector240:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $240
801079c4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079c9:	e9 b2 ef ff ff       	jmp    80106980 <alltraps>

801079ce <vector241>:
.globl vector241
vector241:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $241
801079d0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801079d5:	e9 a6 ef ff ff       	jmp    80106980 <alltraps>

801079da <vector242>:
.globl vector242
vector242:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $242
801079dc:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801079e1:	e9 9a ef ff ff       	jmp    80106980 <alltraps>

801079e6 <vector243>:
.globl vector243
vector243:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $243
801079e8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801079ed:	e9 8e ef ff ff       	jmp    80106980 <alltraps>

801079f2 <vector244>:
.globl vector244
vector244:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $244
801079f4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801079f9:	e9 82 ef ff ff       	jmp    80106980 <alltraps>

801079fe <vector245>:
.globl vector245
vector245:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $245
80107a00:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a05:	e9 76 ef ff ff       	jmp    80106980 <alltraps>

80107a0a <vector246>:
.globl vector246
vector246:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $246
80107a0c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a11:	e9 6a ef ff ff       	jmp    80106980 <alltraps>

80107a16 <vector247>:
.globl vector247
vector247:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $247
80107a18:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a1d:	e9 5e ef ff ff       	jmp    80106980 <alltraps>

80107a22 <vector248>:
.globl vector248
vector248:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $248
80107a24:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a29:	e9 52 ef ff ff       	jmp    80106980 <alltraps>

80107a2e <vector249>:
.globl vector249
vector249:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $249
80107a30:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a35:	e9 46 ef ff ff       	jmp    80106980 <alltraps>

80107a3a <vector250>:
.globl vector250
vector250:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $250
80107a3c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a41:	e9 3a ef ff ff       	jmp    80106980 <alltraps>

80107a46 <vector251>:
.globl vector251
vector251:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $251
80107a48:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a4d:	e9 2e ef ff ff       	jmp    80106980 <alltraps>

80107a52 <vector252>:
.globl vector252
vector252:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $252
80107a54:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a59:	e9 22 ef ff ff       	jmp    80106980 <alltraps>

80107a5e <vector253>:
.globl vector253
vector253:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $253
80107a60:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a65:	e9 16 ef ff ff       	jmp    80106980 <alltraps>

80107a6a <vector254>:
.globl vector254
vector254:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $254
80107a6c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a71:	e9 0a ef ff ff       	jmp    80106980 <alltraps>

80107a76 <vector255>:
.globl vector255
vector255:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $255
80107a78:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a7d:	e9 fe ee ff ff       	jmp    80106980 <alltraps>
	...

80107a84 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a84:	55                   	push   %ebp
80107a85:	89 e5                	mov    %esp,%ebp
80107a87:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a8d:	83 e8 01             	sub    $0x1,%eax
80107a90:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a94:	8b 45 08             	mov    0x8(%ebp),%eax
80107a97:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9e:	c1 e8 10             	shr    $0x10,%eax
80107aa1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107aa5:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107aa8:	0f 01 10             	lgdtl  (%eax)
}
80107aab:	c9                   	leave  
80107aac:	c3                   	ret    

80107aad <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107aad:	55                   	push   %ebp
80107aae:	89 e5                	mov    %esp,%ebp
80107ab0:	83 ec 04             	sub    $0x4,%esp
80107ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107aba:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107abe:	0f 00 d8             	ltr    %ax
}
80107ac1:	c9                   	leave  
80107ac2:	c3                   	ret    

80107ac3 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107ac3:	55                   	push   %ebp
80107ac4:	89 e5                	mov    %esp,%ebp
80107ac6:	83 ec 04             	sub    $0x4,%esp
80107ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80107acc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107ad0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ad4:	8e e8                	mov    %eax,%gs
}
80107ad6:	c9                   	leave  
80107ad7:	c3                   	ret    

80107ad8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107ad8:	55                   	push   %ebp
80107ad9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107adb:	8b 45 08             	mov    0x8(%ebp),%eax
80107ade:	0f 22 d8             	mov    %eax,%cr3
}
80107ae1:	5d                   	pop    %ebp
80107ae2:	c3                   	ret    

80107ae3 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107ae3:	55                   	push   %ebp
80107ae4:	89 e5                	mov    %esp,%ebp
80107ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae9:	05 00 00 00 80       	add    $0x80000000,%eax
80107aee:	5d                   	pop    %ebp
80107aef:	c3                   	ret    

80107af0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107af0:	55                   	push   %ebp
80107af1:	89 e5                	mov    %esp,%ebp
80107af3:	8b 45 08             	mov    0x8(%ebp),%eax
80107af6:	05 00 00 00 80       	add    $0x80000000,%eax
80107afb:	5d                   	pop    %ebp
80107afc:	c3                   	ret    

80107afd <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107afd:	55                   	push   %ebp
80107afe:	89 e5                	mov    %esp,%ebp
80107b00:	53                   	push   %ebx
80107b01:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107b04:	e8 a8 ba ff ff       	call   801035b1 <cpunum>
80107b09:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107b0f:	05 e0 08 11 80       	add    $0x801108e0,%eax
80107b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b33:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b37:	83 e2 f0             	and    $0xfffffff0,%edx
80107b3a:	83 ca 0a             	or     $0xa,%edx
80107b3d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b47:	83 ca 10             	or     $0x10,%edx
80107b4a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b50:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b54:	83 e2 9f             	and    $0xffffff9f,%edx
80107b57:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b61:	83 ca 80             	or     $0xffffff80,%edx
80107b64:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b6e:	83 ca 0f             	or     $0xf,%edx
80107b71:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b77:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b7b:	83 e2 ef             	and    $0xffffffef,%edx
80107b7e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b84:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b88:	83 e2 df             	and    $0xffffffdf,%edx
80107b8b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b95:	83 ca 40             	or     $0x40,%edx
80107b98:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ba2:	83 ca 80             	or     $0xffffff80,%edx
80107ba5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bab:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107bb9:	ff ff 
80107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbe:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107bc5:	00 00 
80107bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bca:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bdb:	83 e2 f0             	and    $0xfffffff0,%edx
80107bde:	83 ca 02             	or     $0x2,%edx
80107be1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bea:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bf1:	83 ca 10             	or     $0x10,%edx
80107bf4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c04:	83 e2 9f             	and    $0xffffff9f,%edx
80107c07:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c10:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c17:	83 ca 80             	or     $0xffffff80,%edx
80107c1a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c23:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c2a:	83 ca 0f             	or     $0xf,%edx
80107c2d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c36:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c3d:	83 e2 ef             	and    $0xffffffef,%edx
80107c40:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c49:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c50:	83 e2 df             	and    $0xffffffdf,%edx
80107c53:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c63:	83 ca 40             	or     $0x40,%edx
80107c66:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c76:	83 ca 80             	or     $0xffffff80,%edx
80107c79:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c93:	ff ff 
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c9f:	00 00 
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cb5:	83 e2 f0             	and    $0xfffffff0,%edx
80107cb8:	83 ca 0a             	or     $0xa,%edx
80107cbb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ccb:	83 ca 10             	or     $0x10,%edx
80107cce:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cde:	83 ca 60             	or     $0x60,%edx
80107ce1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cea:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cf1:	83 ca 80             	or     $0xffffff80,%edx
80107cf4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d04:	83 ca 0f             	or     $0xf,%edx
80107d07:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d10:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d17:	83 e2 ef             	and    $0xffffffef,%edx
80107d1a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d2a:	83 e2 df             	and    $0xffffffdf,%edx
80107d2d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d36:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d3d:	83 ca 40             	or     $0x40,%edx
80107d40:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d49:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d50:	83 ca 80             	or     $0xffffff80,%edx
80107d53:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d66:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d6d:	ff ff 
80107d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d72:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107d79:	00 00 
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d8f:	83 e2 f0             	and    $0xfffffff0,%edx
80107d92:	83 ca 02             	or     $0x2,%edx
80107d95:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107da5:	83 ca 10             	or     $0x10,%edx
80107da8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107db8:	83 ca 60             	or     $0x60,%edx
80107dbb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107dcb:	83 ca 80             	or     $0xffffff80,%edx
80107dce:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dde:	83 ca 0f             	or     $0xf,%edx
80107de1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dea:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107df1:	83 e2 ef             	and    $0xffffffef,%edx
80107df4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e04:	83 e2 df             	and    $0xffffffdf,%edx
80107e07:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e10:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e17:	83 ca 40             	or     $0x40,%edx
80107e1a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e23:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e2a:	83 ca 80             	or     $0xffffff80,%edx
80107e2d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e36:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e40:	05 b4 00 00 00       	add    $0xb4,%eax
80107e45:	89 c3                	mov    %eax,%ebx
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	05 b4 00 00 00       	add    $0xb4,%eax
80107e4f:	c1 e8 10             	shr    $0x10,%eax
80107e52:	89 c1                	mov    %eax,%ecx
80107e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e57:	05 b4 00 00 00       	add    $0xb4,%eax
80107e5c:	c1 e8 18             	shr    $0x18,%eax
80107e5f:	89 c2                	mov    %eax,%edx
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e6b:	00 00 
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e8a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e8d:	83 c9 02             	or     $0x2,%ecx
80107e90:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ea0:	83 c9 10             	or     $0x10,%ecx
80107ea3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107eb3:	83 e1 9f             	and    $0xffffff9f,%ecx
80107eb6:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ec6:	83 c9 80             	or     $0xffffff80,%ecx
80107ec9:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ed9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107edc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eec:	83 e1 ef             	and    $0xffffffef,%ecx
80107eef:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eff:	83 e1 df             	and    $0xffffffdf,%ecx
80107f02:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f12:	83 c9 40             	or     $0x40,%ecx
80107f15:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f25:	83 c9 80             	or     $0xffffff80,%ecx
80107f28:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f31:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3a:	83 c0 70             	add    $0x70,%eax
80107f3d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107f44:	00 
80107f45:	89 04 24             	mov    %eax,(%esp)
80107f48:	e8 37 fb ff ff       	call   80107a84 <lgdt>
  loadgs(SEG_KCPU << 3);
80107f4d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107f54:	e8 6a fb ff ff       	call   80107ac3 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f62:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f69:	00 00 00 00 
}
80107f6d:	83 c4 24             	add    $0x24,%esp
80107f70:	5b                   	pop    %ebx
80107f71:	5d                   	pop    %ebp
80107f72:	c3                   	ret    

80107f73 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f73:	55                   	push   %ebp
80107f74:	89 e5                	mov    %esp,%ebp
80107f76:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f79:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f7c:	c1 e8 16             	shr    $0x16,%eax
80107f7f:	c1 e0 02             	shl    $0x2,%eax
80107f82:	03 45 08             	add    0x8(%ebp),%eax
80107f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8b:	8b 00                	mov    (%eax),%eax
80107f8d:	83 e0 01             	and    $0x1,%eax
80107f90:	84 c0                	test   %al,%al
80107f92:	74 17                	je     80107fab <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f97:	8b 00                	mov    (%eax),%eax
80107f99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f9e:	89 04 24             	mov    %eax,(%esp)
80107fa1:	e8 4a fb ff ff       	call   80107af0 <p2v>
80107fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fa9:	eb 4b                	jmp    80107ff6 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107faf:	74 0e                	je     80107fbf <walkpgdir+0x4c>
80107fb1:	e8 6d b2 ff ff       	call   80103223 <kalloc>
80107fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fbd:	75 07                	jne    80107fc6 <walkpgdir+0x53>
      return 0;
80107fbf:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc4:	eb 41                	jmp    80108007 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fcd:	00 
80107fce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fd5:	00 
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	89 04 24             	mov    %eax,(%esp)
80107fdc:	e8 35 d5 ff ff       	call   80105516 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe4:	89 04 24             	mov    %eax,(%esp)
80107fe7:	e8 f7 fa ff ff       	call   80107ae3 <v2p>
80107fec:	89 c2                	mov    %eax,%edx
80107fee:	83 ca 07             	or     $0x7,%edx
80107ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff9:	c1 e8 0c             	shr    $0xc,%eax
80107ffc:	25 ff 03 00 00       	and    $0x3ff,%eax
80108001:	c1 e0 02             	shl    $0x2,%eax
80108004:	03 45 f4             	add    -0xc(%ebp),%eax
}
80108007:	c9                   	leave  
80108008:	c3                   	ret    

80108009 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108009:	55                   	push   %ebp
8010800a:	89 e5                	mov    %esp,%ebp
8010800c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010800f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108012:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108017:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010801a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801d:	03 45 10             	add    0x10(%ebp),%eax
80108020:	83 e8 01             	sub    $0x1,%eax
80108023:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108028:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010802b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108032:	00 
80108033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108036:	89 44 24 04          	mov    %eax,0x4(%esp)
8010803a:	8b 45 08             	mov    0x8(%ebp),%eax
8010803d:	89 04 24             	mov    %eax,(%esp)
80108040:	e8 2e ff ff ff       	call   80107f73 <walkpgdir>
80108045:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108048:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010804c:	75 07                	jne    80108055 <mappages+0x4c>
      return -1;
8010804e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108053:	eb 46                	jmp    8010809b <mappages+0x92>
    if(*pte & PTE_P)
80108055:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108058:	8b 00                	mov    (%eax),%eax
8010805a:	83 e0 01             	and    $0x1,%eax
8010805d:	84 c0                	test   %al,%al
8010805f:	74 0c                	je     8010806d <mappages+0x64>
      panic("remap");
80108061:	c7 04 24 80 8e 10 80 	movl   $0x80108e80,(%esp)
80108068:	e8 d0 84 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
8010806d:	8b 45 18             	mov    0x18(%ebp),%eax
80108070:	0b 45 14             	or     0x14(%ebp),%eax
80108073:	89 c2                	mov    %eax,%edx
80108075:	83 ca 01             	or     $0x1,%edx
80108078:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807b:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108080:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108083:	74 10                	je     80108095 <mappages+0x8c>
      break;
    a += PGSIZE;
80108085:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010808c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108093:	eb 96                	jmp    8010802b <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108095:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108096:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010809b:	c9                   	leave  
8010809c:	c3                   	ret    

8010809d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
8010809d:	55                   	push   %ebp
8010809e:	89 e5                	mov    %esp,%ebp
801080a0:	53                   	push   %ebx
801080a1:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080a4:	e8 7a b1 ff ff       	call   80103223 <kalloc>
801080a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080b0:	75 0a                	jne    801080bc <setupkvm+0x1f>
    return 0;
801080b2:	b8 00 00 00 00       	mov    $0x0,%eax
801080b7:	e9 98 00 00 00       	jmp    80108154 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801080bc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080c3:	00 
801080c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080cb:	00 
801080cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cf:	89 04 24             	mov    %eax,(%esp)
801080d2:	e8 3f d4 ff ff       	call   80105516 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801080d7:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801080de:	e8 0d fa ff ff       	call   80107af0 <p2v>
801080e3:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801080e8:	76 0c                	jbe    801080f6 <setupkvm+0x59>
    panic("PHYSTOP too high");
801080ea:	c7 04 24 86 8e 10 80 	movl   $0x80108e86,(%esp)
801080f1:	e8 47 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080f6:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
801080fd:	eb 49                	jmp    80108148 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801080ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108102:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108108:	8b 50 04             	mov    0x4(%eax),%edx
8010810b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810e:	8b 58 08             	mov    0x8(%eax),%ebx
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	8b 40 04             	mov    0x4(%eax),%eax
80108117:	29 c3                	sub    %eax,%ebx
80108119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811c:	8b 00                	mov    (%eax),%eax
8010811e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108122:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108126:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010812a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010812e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108131:	89 04 24             	mov    %eax,(%esp)
80108134:	e8 d0 fe ff ff       	call   80108009 <mappages>
80108139:	85 c0                	test   %eax,%eax
8010813b:	79 07                	jns    80108144 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010813d:	b8 00 00 00 00       	mov    $0x0,%eax
80108142:	eb 10                	jmp    80108154 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108144:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108148:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
8010814f:	72 ae                	jb     801080ff <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108151:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108154:	83 c4 34             	add    $0x34,%esp
80108157:	5b                   	pop    %ebx
80108158:	5d                   	pop    %ebp
80108159:	c3                   	ret    

8010815a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010815a:	55                   	push   %ebp
8010815b:	89 e5                	mov    %esp,%ebp
8010815d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108160:	e8 38 ff ff ff       	call   8010809d <setupkvm>
80108165:	a3 b8 36 11 80       	mov    %eax,0x801136b8
  switchkvm();
8010816a:	e8 02 00 00 00       	call   80108171 <switchkvm>
}
8010816f:	c9                   	leave  
80108170:	c3                   	ret    

80108171 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108171:	55                   	push   %ebp
80108172:	89 e5                	mov    %esp,%ebp
80108174:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108177:	a1 b8 36 11 80       	mov    0x801136b8,%eax
8010817c:	89 04 24             	mov    %eax,(%esp)
8010817f:	e8 5f f9 ff ff       	call   80107ae3 <v2p>
80108184:	89 04 24             	mov    %eax,(%esp)
80108187:	e8 4c f9 ff ff       	call   80107ad8 <lcr3>
}
8010818c:	c9                   	leave  
8010818d:	c3                   	ret    

8010818e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010818e:	55                   	push   %ebp
8010818f:	89 e5                	mov    %esp,%ebp
80108191:	53                   	push   %ebx
80108192:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108195:	e8 75 d2 ff ff       	call   8010540f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010819a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081a0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081a7:	83 c2 08             	add    $0x8,%edx
801081aa:	89 d3                	mov    %edx,%ebx
801081ac:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081b3:	83 c2 08             	add    $0x8,%edx
801081b6:	c1 ea 10             	shr    $0x10,%edx
801081b9:	89 d1                	mov    %edx,%ecx
801081bb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081c2:	83 c2 08             	add    $0x8,%edx
801081c5:	c1 ea 18             	shr    $0x18,%edx
801081c8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801081cf:	67 00 
801081d1:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801081d8:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801081de:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081e5:	83 e1 f0             	and    $0xfffffff0,%ecx
801081e8:	83 c9 09             	or     $0x9,%ecx
801081eb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081f1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081f8:	83 c9 10             	or     $0x10,%ecx
801081fb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108201:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108208:	83 e1 9f             	and    $0xffffff9f,%ecx
8010820b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108211:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108218:	83 c9 80             	or     $0xffffff80,%ecx
8010821b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108221:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108228:	83 e1 f0             	and    $0xfffffff0,%ecx
8010822b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108231:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108238:	83 e1 ef             	and    $0xffffffef,%ecx
8010823b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108241:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108248:	83 e1 df             	and    $0xffffffdf,%ecx
8010824b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108251:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108258:	83 c9 40             	or     $0x40,%ecx
8010825b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108261:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108268:	83 e1 7f             	and    $0x7f,%ecx
8010826b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108271:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108277:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010827d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108284:	83 e2 ef             	and    $0xffffffef,%edx
80108287:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010828d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108293:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108299:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010829f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801082a6:	8b 52 08             	mov    0x8(%edx),%edx
801082a9:	81 c2 00 10 00 00    	add    $0x1000,%edx
801082af:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801082b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801082b9:	e8 ef f7 ff ff       	call   80107aad <ltr>
  if(p->pgdir == 0)
801082be:	8b 45 08             	mov    0x8(%ebp),%eax
801082c1:	8b 40 04             	mov    0x4(%eax),%eax
801082c4:	85 c0                	test   %eax,%eax
801082c6:	75 0c                	jne    801082d4 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801082c8:	c7 04 24 97 8e 10 80 	movl   $0x80108e97,(%esp)
801082cf:	e8 69 82 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801082d4:	8b 45 08             	mov    0x8(%ebp),%eax
801082d7:	8b 40 04             	mov    0x4(%eax),%eax
801082da:	89 04 24             	mov    %eax,(%esp)
801082dd:	e8 01 f8 ff ff       	call   80107ae3 <v2p>
801082e2:	89 04 24             	mov    %eax,(%esp)
801082e5:	e8 ee f7 ff ff       	call   80107ad8 <lcr3>
  popcli();
801082ea:	e8 68 d1 ff ff       	call   80105457 <popcli>
}
801082ef:	83 c4 14             	add    $0x14,%esp
801082f2:	5b                   	pop    %ebx
801082f3:	5d                   	pop    %ebp
801082f4:	c3                   	ret    

801082f5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801082f5:	55                   	push   %ebp
801082f6:	89 e5                	mov    %esp,%ebp
801082f8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801082fb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108302:	76 0c                	jbe    80108310 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108304:	c7 04 24 ab 8e 10 80 	movl   $0x80108eab,(%esp)
8010830b:	e8 2d 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108310:	e8 0e af ff ff       	call   80103223 <kalloc>
80108315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108318:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010831f:	00 
80108320:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108327:	00 
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	89 04 24             	mov    %eax,(%esp)
8010832e:	e8 e3 d1 ff ff       	call   80105516 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108336:	89 04 24             	mov    %eax,(%esp)
80108339:	e8 a5 f7 ff ff       	call   80107ae3 <v2p>
8010833e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108345:	00 
80108346:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010834a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108351:	00 
80108352:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108359:	00 
8010835a:	8b 45 08             	mov    0x8(%ebp),%eax
8010835d:	89 04 24             	mov    %eax,(%esp)
80108360:	e8 a4 fc ff ff       	call   80108009 <mappages>
  memmove(mem, init, sz);
80108365:	8b 45 10             	mov    0x10(%ebp),%eax
80108368:	89 44 24 08          	mov    %eax,0x8(%esp)
8010836c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010836f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108376:	89 04 24             	mov    %eax,(%esp)
80108379:	e8 6b d2 ff ff       	call   801055e9 <memmove>
}
8010837e:	c9                   	leave  
8010837f:	c3                   	ret    

80108380 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108380:	55                   	push   %ebp
80108381:	89 e5                	mov    %esp,%ebp
80108383:	53                   	push   %ebx
80108384:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010838a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010838f:	85 c0                	test   %eax,%eax
80108391:	74 0c                	je     8010839f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108393:	c7 04 24 c8 8e 10 80 	movl   $0x80108ec8,(%esp)
8010839a:	e8 9e 81 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010839f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083a6:	e9 ad 00 00 00       	jmp    80108458 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801083b1:	01 d0                	add    %edx,%eax
801083b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083ba:	00 
801083bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801083bf:	8b 45 08             	mov    0x8(%ebp),%eax
801083c2:	89 04 24             	mov    %eax,(%esp)
801083c5:	e8 a9 fb ff ff       	call   80107f73 <walkpgdir>
801083ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083d1:	75 0c                	jne    801083df <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801083d3:	c7 04 24 eb 8e 10 80 	movl   $0x80108eeb,(%esp)
801083da:	e8 5e 81 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801083df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e2:	8b 00                	mov    (%eax),%eax
801083e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	8b 55 18             	mov    0x18(%ebp),%edx
801083f2:	89 d1                	mov    %edx,%ecx
801083f4:	29 c1                	sub    %eax,%ecx
801083f6:	89 c8                	mov    %ecx,%eax
801083f8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083fd:	77 11                	ja     80108410 <loaduvm+0x90>
      n = sz - i;
801083ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108402:	8b 55 18             	mov    0x18(%ebp),%edx
80108405:	89 d1                	mov    %edx,%ecx
80108407:	29 c1                	sub    %eax,%ecx
80108409:	89 c8                	mov    %ecx,%eax
8010840b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010840e:	eb 07                	jmp    80108417 <loaduvm+0x97>
    else
      n = PGSIZE;
80108410:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841a:	8b 55 14             	mov    0x14(%ebp),%edx
8010841d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108420:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108423:	89 04 24             	mov    %eax,(%esp)
80108426:	e8 c5 f6 ff ff       	call   80107af0 <p2v>
8010842b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010842e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108432:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108436:	89 44 24 04          	mov    %eax,0x4(%esp)
8010843a:	8b 45 10             	mov    0x10(%ebp),%eax
8010843d:	89 04 24             	mov    %eax,(%esp)
80108440:	e8 3d a0 ff ff       	call   80102482 <readi>
80108445:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108448:	74 07                	je     80108451 <loaduvm+0xd1>
      return -1;
8010844a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010844f:	eb 18                	jmp    80108469 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108451:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010845e:	0f 82 47 ff ff ff    	jb     801083ab <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108464:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108469:	83 c4 24             	add    $0x24,%esp
8010846c:	5b                   	pop    %ebx
8010846d:	5d                   	pop    %ebp
8010846e:	c3                   	ret    

8010846f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010846f:	55                   	push   %ebp
80108470:	89 e5                	mov    %esp,%ebp
80108472:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108475:	8b 45 10             	mov    0x10(%ebp),%eax
80108478:	85 c0                	test   %eax,%eax
8010847a:	79 0a                	jns    80108486 <allocuvm+0x17>
    return 0;
8010847c:	b8 00 00 00 00       	mov    $0x0,%eax
80108481:	e9 c1 00 00 00       	jmp    80108547 <allocuvm+0xd8>
  if(newsz < oldsz)
80108486:	8b 45 10             	mov    0x10(%ebp),%eax
80108489:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010848c:	73 08                	jae    80108496 <allocuvm+0x27>
    return oldsz;
8010848e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108491:	e9 b1 00 00 00       	jmp    80108547 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108496:	8b 45 0c             	mov    0xc(%ebp),%eax
80108499:	05 ff 0f 00 00       	add    $0xfff,%eax
8010849e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084a6:	e9 8d 00 00 00       	jmp    80108538 <allocuvm+0xc9>
    mem = kalloc();
801084ab:	e8 73 ad ff ff       	call   80103223 <kalloc>
801084b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084b7:	75 2c                	jne    801084e5 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801084b9:	c7 04 24 09 8f 10 80 	movl   $0x80108f09,(%esp)
801084c0:	e8 dc 7e ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801084c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c8:	89 44 24 08          	mov    %eax,0x8(%esp)
801084cc:	8b 45 10             	mov    0x10(%ebp),%eax
801084cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801084d3:	8b 45 08             	mov    0x8(%ebp),%eax
801084d6:	89 04 24             	mov    %eax,(%esp)
801084d9:	e8 6b 00 00 00       	call   80108549 <deallocuvm>
      return 0;
801084de:	b8 00 00 00 00       	mov    $0x0,%eax
801084e3:	eb 62                	jmp    80108547 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801084e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084ec:	00 
801084ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084f4:	00 
801084f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f8:	89 04 24             	mov    %eax,(%esp)
801084fb:	e8 16 d0 ff ff       	call   80105516 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108503:	89 04 24             	mov    %eax,(%esp)
80108506:	e8 d8 f5 ff ff       	call   80107ae3 <v2p>
8010850b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010850e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108515:	00 
80108516:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010851a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108521:	00 
80108522:	89 54 24 04          	mov    %edx,0x4(%esp)
80108526:	8b 45 08             	mov    0x8(%ebp),%eax
80108529:	89 04 24             	mov    %eax,(%esp)
8010852c:	e8 d8 fa ff ff       	call   80108009 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108531:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010853e:	0f 82 67 ff ff ff    	jb     801084ab <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108544:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108547:	c9                   	leave  
80108548:	c3                   	ret    

80108549 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108549:	55                   	push   %ebp
8010854a:	89 e5                	mov    %esp,%ebp
8010854c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010854f:	8b 45 10             	mov    0x10(%ebp),%eax
80108552:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108555:	72 08                	jb     8010855f <deallocuvm+0x16>
    return oldsz;
80108557:	8b 45 0c             	mov    0xc(%ebp),%eax
8010855a:	e9 a4 00 00 00       	jmp    80108603 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010855f:	8b 45 10             	mov    0x10(%ebp),%eax
80108562:	05 ff 0f 00 00       	add    $0xfff,%eax
80108567:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010856c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010856f:	e9 80 00 00 00       	jmp    801085f4 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010857e:	00 
8010857f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108583:	8b 45 08             	mov    0x8(%ebp),%eax
80108586:	89 04 24             	mov    %eax,(%esp)
80108589:	e8 e5 f9 ff ff       	call   80107f73 <walkpgdir>
8010858e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108591:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108595:	75 09                	jne    801085a0 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108597:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010859e:	eb 4d                	jmp    801085ed <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801085a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085a3:	8b 00                	mov    (%eax),%eax
801085a5:	83 e0 01             	and    $0x1,%eax
801085a8:	84 c0                	test   %al,%al
801085aa:	74 41                	je     801085ed <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801085ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085af:	8b 00                	mov    (%eax),%eax
801085b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085bd:	75 0c                	jne    801085cb <deallocuvm+0x82>
        panic("kfree");
801085bf:	c7 04 24 21 8f 10 80 	movl   $0x80108f21,(%esp)
801085c6:	e8 72 7f ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801085cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ce:	89 04 24             	mov    %eax,(%esp)
801085d1:	e8 1a f5 ff ff       	call   80107af0 <p2v>
801085d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085dc:	89 04 24             	mov    %eax,(%esp)
801085df:	e8 a6 ab ff ff       	call   8010318a <kfree>
      *pte = 0;
801085e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801085ed:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085fa:	0f 82 74 ff ff ff    	jb     80108574 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108600:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108603:	c9                   	leave  
80108604:	c3                   	ret    

80108605 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108605:	55                   	push   %ebp
80108606:	89 e5                	mov    %esp,%ebp
80108608:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010860b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010860f:	75 0c                	jne    8010861d <freevm+0x18>
    panic("freevm: no pgdir");
80108611:	c7 04 24 27 8f 10 80 	movl   $0x80108f27,(%esp)
80108618:	e8 20 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010861d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108624:	00 
80108625:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010862c:	80 
8010862d:	8b 45 08             	mov    0x8(%ebp),%eax
80108630:	89 04 24             	mov    %eax,(%esp)
80108633:	e8 11 ff ff ff       	call   80108549 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108638:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010863f:	eb 3c                	jmp    8010867d <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108644:	c1 e0 02             	shl    $0x2,%eax
80108647:	03 45 08             	add    0x8(%ebp),%eax
8010864a:	8b 00                	mov    (%eax),%eax
8010864c:	83 e0 01             	and    $0x1,%eax
8010864f:	84 c0                	test   %al,%al
80108651:	74 26                	je     80108679 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	c1 e0 02             	shl    $0x2,%eax
80108659:	03 45 08             	add    0x8(%ebp),%eax
8010865c:	8b 00                	mov    (%eax),%eax
8010865e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108663:	89 04 24             	mov    %eax,(%esp)
80108666:	e8 85 f4 ff ff       	call   80107af0 <p2v>
8010866b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010866e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108671:	89 04 24             	mov    %eax,(%esp)
80108674:	e8 11 ab ff ff       	call   8010318a <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108679:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010867d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108684:	76 bb                	jbe    80108641 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108686:	8b 45 08             	mov    0x8(%ebp),%eax
80108689:	89 04 24             	mov    %eax,(%esp)
8010868c:	e8 f9 aa ff ff       	call   8010318a <kfree>
}
80108691:	c9                   	leave  
80108692:	c3                   	ret    

80108693 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108693:	55                   	push   %ebp
80108694:	89 e5                	mov    %esp,%ebp
80108696:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108699:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086a0:	00 
801086a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a8:	8b 45 08             	mov    0x8(%ebp),%eax
801086ab:	89 04 24             	mov    %eax,(%esp)
801086ae:	e8 c0 f8 ff ff       	call   80107f73 <walkpgdir>
801086b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086ba:	75 0c                	jne    801086c8 <clearpteu+0x35>
    panic("clearpteu");
801086bc:	c7 04 24 38 8f 10 80 	movl   $0x80108f38,(%esp)
801086c3:	e8 75 7e ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801086c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cb:	8b 00                	mov    (%eax),%eax
801086cd:	89 c2                	mov    %eax,%edx
801086cf:	83 e2 fb             	and    $0xfffffffb,%edx
801086d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d5:	89 10                	mov    %edx,(%eax)
}
801086d7:	c9                   	leave  
801086d8:	c3                   	ret    

801086d9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086d9:	55                   	push   %ebp
801086da:	89 e5                	mov    %esp,%ebp
801086dc:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
801086df:	e8 b9 f9 ff ff       	call   8010809d <setupkvm>
801086e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086eb:	75 0a                	jne    801086f7 <copyuvm+0x1e>
    return 0;
801086ed:	b8 00 00 00 00       	mov    $0x0,%eax
801086f2:	e9 f1 00 00 00       	jmp    801087e8 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801086f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086fe:	e9 c0 00 00 00       	jmp    801087c3 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108706:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010870d:	00 
8010870e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108712:	8b 45 08             	mov    0x8(%ebp),%eax
80108715:	89 04 24             	mov    %eax,(%esp)
80108718:	e8 56 f8 ff ff       	call   80107f73 <walkpgdir>
8010871d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108720:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108724:	75 0c                	jne    80108732 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108726:	c7 04 24 42 8f 10 80 	movl   $0x80108f42,(%esp)
8010872d:	e8 0b 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108732:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108735:	8b 00                	mov    (%eax),%eax
80108737:	83 e0 01             	and    $0x1,%eax
8010873a:	85 c0                	test   %eax,%eax
8010873c:	75 0c                	jne    8010874a <copyuvm+0x71>
      panic("copyuvm: page not present");
8010873e:	c7 04 24 5c 8f 10 80 	movl   $0x80108f5c,(%esp)
80108745:	e8 f3 7d ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010874a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874d:	8b 00                	mov    (%eax),%eax
8010874f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108754:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108757:	e8 c7 aa ff ff       	call   80103223 <kalloc>
8010875c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010875f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108763:	74 6f                	je     801087d4 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108765:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108768:	89 04 24             	mov    %eax,(%esp)
8010876b:	e8 80 f3 ff ff       	call   80107af0 <p2v>
80108770:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108777:	00 
80108778:	89 44 24 04          	mov    %eax,0x4(%esp)
8010877c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010877f:	89 04 24             	mov    %eax,(%esp)
80108782:	e8 62 ce ff ff       	call   801055e9 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010878a:	89 04 24             	mov    %eax,(%esp)
8010878d:	e8 51 f3 ff ff       	call   80107ae3 <v2p>
80108792:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108795:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010879c:	00 
8010879d:	89 44 24 0c          	mov    %eax,0xc(%esp)
801087a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087a8:	00 
801087a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801087ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b0:	89 04 24             	mov    %eax,(%esp)
801087b3:	e8 51 f8 ff ff       	call   80108009 <mappages>
801087b8:	85 c0                	test   %eax,%eax
801087ba:	78 1b                	js     801087d7 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801087bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087c9:	0f 82 34 ff ff ff    	jb     80108703 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
801087cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d2:	eb 14                	jmp    801087e8 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801087d4:	90                   	nop
801087d5:	eb 01                	jmp    801087d8 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
801087d7:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801087d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087db:	89 04 24             	mov    %eax,(%esp)
801087de:	e8 22 fe ff ff       	call   80108605 <freevm>
  return 0;
801087e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087e8:	c9                   	leave  
801087e9:	c3                   	ret    

801087ea <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801087ea:	55                   	push   %ebp
801087eb:	89 e5                	mov    %esp,%ebp
801087ed:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087f7:	00 
801087f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801087fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108802:	89 04 24             	mov    %eax,(%esp)
80108805:	e8 69 f7 ff ff       	call   80107f73 <walkpgdir>
8010880a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010880d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108810:	8b 00                	mov    (%eax),%eax
80108812:	83 e0 01             	and    $0x1,%eax
80108815:	85 c0                	test   %eax,%eax
80108817:	75 07                	jne    80108820 <uva2ka+0x36>
    return 0;
80108819:	b8 00 00 00 00       	mov    $0x0,%eax
8010881e:	eb 25                	jmp    80108845 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108823:	8b 00                	mov    (%eax),%eax
80108825:	83 e0 04             	and    $0x4,%eax
80108828:	85 c0                	test   %eax,%eax
8010882a:	75 07                	jne    80108833 <uva2ka+0x49>
    return 0;
8010882c:	b8 00 00 00 00       	mov    $0x0,%eax
80108831:	eb 12                	jmp    80108845 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108836:	8b 00                	mov    (%eax),%eax
80108838:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010883d:	89 04 24             	mov    %eax,(%esp)
80108840:	e8 ab f2 ff ff       	call   80107af0 <p2v>
}
80108845:	c9                   	leave  
80108846:	c3                   	ret    

80108847 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108847:	55                   	push   %ebp
80108848:	89 e5                	mov    %esp,%ebp
8010884a:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010884d:	8b 45 10             	mov    0x10(%ebp),%eax
80108850:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108853:	e9 8b 00 00 00       	jmp    801088e3 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108858:	8b 45 0c             	mov    0xc(%ebp),%eax
8010885b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108860:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108866:	89 44 24 04          	mov    %eax,0x4(%esp)
8010886a:	8b 45 08             	mov    0x8(%ebp),%eax
8010886d:	89 04 24             	mov    %eax,(%esp)
80108870:	e8 75 ff ff ff       	call   801087ea <uva2ka>
80108875:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108878:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010887c:	75 07                	jne    80108885 <copyout+0x3e>
      return -1;
8010887e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108883:	eb 6d                	jmp    801088f2 <copyout+0xab>
    n = PGSIZE - (va - va0);
80108885:	8b 45 0c             	mov    0xc(%ebp),%eax
80108888:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010888b:	89 d1                	mov    %edx,%ecx
8010888d:	29 c1                	sub    %eax,%ecx
8010888f:	89 c8                	mov    %ecx,%eax
80108891:	05 00 10 00 00       	add    $0x1000,%eax
80108896:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010889c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010889f:	76 06                	jbe    801088a7 <copyout+0x60>
      n = len;
801088a1:	8b 45 14             	mov    0x14(%ebp),%eax
801088a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801088ad:	89 d1                	mov    %edx,%ecx
801088af:	29 c1                	sub    %eax,%ecx
801088b1:	89 c8                	mov    %ecx,%eax
801088b3:	03 45 e8             	add    -0x18(%ebp),%eax
801088b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088b9:	89 54 24 08          	mov    %edx,0x8(%esp)
801088bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801088c4:	89 04 24             	mov    %eax,(%esp)
801088c7:	e8 1d cd ff ff       	call   801055e9 <memmove>
    len -= n;
801088cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088cf:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d5:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088db:	05 00 10 00 00       	add    $0x1000,%eax
801088e0:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801088e3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088e7:	0f 85 6b ff ff ff    	jne    80108858 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801088ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088f2:	c9                   	leave  
801088f3:	c3                   	ret    