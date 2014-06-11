
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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 fe 35 10 80       	mov    $0x801035fe,%eax
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
8010003a:	c7 44 24 04 44 83 10 	movl   $0x80108344,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 fa 4c 00 00       	call   80104d48 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
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
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 a7 4c 00 00       	call   80104d69 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
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
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 c2 4c 00 00       	call   80104dcb <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 7b 49 00 00       	call   80104a9f <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
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
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 4a 4c 00 00       	call   80104dcb <release>
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
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 4b 83 10 80 	movl   $0x8010834b,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
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
801001d3:	e8 02 28 00 00       	call   801029da <iderw>
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
801001ef:	c7 04 24 5c 83 10 80 	movl   $0x8010835c,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 c5 27 00 00       	call   801029da <iderw>
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
80100229:	c7 04 24 63 83 10 80 	movl   $0x80108363,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 28 4b 00 00       	call   80104d69 <acquire>

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
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 d6 48 00 00       	call   80104b78 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 1d 4b 00 00       	call   80104dcb <release>
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
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bb:	e8 a9 49 00 00       	call   80104d69 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 6a 83 10 80 	movl   $0x8010836a,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 73 83 10 80 	movl   $0x80108373,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
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
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100533:	e8 93 48 00 00       	call   80104dcb <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 7a 83 10 80 	movl   $0x8010837a,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 89 83 10 80 	movl   $0x80108389,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 86 48 00 00       	call   80104e1a <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 8b 83 10 80 	movl   $0x8010838b,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 d5 49 00 00       	call   8010508c <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 d7 48 00 00       	call   80104fbd <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 1b 62 00 00       	call   80106996 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 0f 62 00 00       	call   80106996 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 03 62 00 00       	call   80106996 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 f6 61 00 00       	call   80106996 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801007ba:	e8 aa 45 00 00       	call   80104d69 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 2c 44 00 00       	call   80104c1b <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100816:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100840:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010087c:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c de 10 80    	mov    %edx,0x8010de5c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008d5:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008e7:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
801008ec:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
801008f3:	e8 80 42 00 00       	call   80104b78 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100914:	e8 b2 44 00 00       	call   80104dcb <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 70 10 00 00       	call   8010199c <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100939:	e8 2b 44 00 00       	call   80104d69 <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100959:	e8 6d 44 00 00       	call   80104dcb <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 e5 0e 00 00       	call   8010184e <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100982:	e8 18 41 00 00       	call   80104a9f <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
8010098d:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 de 10 80       	mov    0x8010de54,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 de 10 80    	mov    %edx,0x8010de54
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801009fe:	e8 c8 43 00 00       	call   80104dcb <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 40 0e 00 00       	call   8010184e <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 71 0f 00 00       	call   8010199c <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 32 43 00 00       	call   80104d69 <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a6c:	e8 5a 43 00 00       	call   80104dcb <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 d2 0d 00 00       	call   8010184e <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 8f 83 10 	movl   $0x8010838f,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 ad 42 00 00       	call   80104d48 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 97 83 10 	movl   $0x80108397,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100aaa:	e8 99 42 00 00       	call   80104d48 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c e8 10 80 1a 	movl   $0x80100a1a,0x8010e80c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 e8 10 80 1b 	movl   $0x8010091b,0x8010e808
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 d2 31 00 00       	call   80103cab <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 a9 20 00 00       	call   80102b96 <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100af8:	8b 45 08             	mov    0x8(%ebp),%eax
80100afb:	89 04 24             	mov    %eax,(%esp)
80100afe:	e8 3c 1b 00 00       	call   8010263f <namei>
80100b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b06:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0a:	75 0a                	jne    80100b16 <exec+0x27>
    return -1;
80100b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b11:	e9 e5 03 00 00       	jmp    80100efb <exec+0x40c>
  ilock(ip);
80100b16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b19:	89 04 24             	mov    %eax,(%esp)
80100b1c:	e8 2d 0d 00 00       	call   8010184e <ilock>
  pgdir = 0;
80100b21:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b28:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b2f:	00 
80100b30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b37:	00 
80100b38:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b45:	89 04 24             	mov    %eax,(%esp)
80100b48:	e8 54 14 00 00       	call   80101fa1 <readi>
80100b4d:	83 f8 33             	cmp    $0x33,%eax
80100b50:	77 05                	ja     80100b57 <exec+0x68>
    goto bad;
80100b52:	e9 7d 03 00 00       	jmp    80100ed4 <exec+0x3e5>
  if(elf.magic != ELF_MAGIC)
80100b57:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b5d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b62:	74 05                	je     80100b69 <exec+0x7a>
    goto bad;
80100b64:	e9 6b 03 00 00       	jmp    80100ed4 <exec+0x3e5>

  if((pgdir = setupkvm(kalloc)) == 0)
80100b69:	c7 04 24 1b 2d 10 80 	movl   $0x80102d1b,(%esp)
80100b70:	e8 72 6f 00 00       	call   80107ae7 <setupkvm>
80100b75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b78:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7c:	75 05                	jne    80100b83 <exec+0x94>
    goto bad;
80100b7e:	e9 51 03 00 00       	jmp    80100ed4 <exec+0x3e5>

  // Load program into memory.
  sz = 0;
80100b83:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b91:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b97:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9a:	e9 cb 00 00 00       	jmp    80100c6a <exec+0x17b>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100b9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba2:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100ba9:	00 
80100baa:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bae:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bb8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbb:	89 04 24             	mov    %eax,(%esp)
80100bbe:	e8 de 13 00 00       	call   80101fa1 <readi>
80100bc3:	83 f8 20             	cmp    $0x20,%eax
80100bc6:	74 05                	je     80100bcd <exec+0xde>
      goto bad;
80100bc8:	e9 07 03 00 00       	jmp    80100ed4 <exec+0x3e5>
    if(ph.type != ELF_PROG_LOAD)
80100bcd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd3:	83 f8 01             	cmp    $0x1,%eax
80100bd6:	74 05                	je     80100bdd <exec+0xee>
      continue;
80100bd8:	e9 80 00 00 00       	jmp    80100c5d <exec+0x16e>
    if(ph.memsz < ph.filesz)
80100bdd:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be3:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100be9:	39 c2                	cmp    %eax,%edx
80100beb:	73 05                	jae    80100bf2 <exec+0x103>
      goto bad;
80100bed:	e9 e2 02 00 00       	jmp    80100ed4 <exec+0x3e5>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf2:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bf8:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100bfe:	01 d0                	add    %edx,%eax
80100c00:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c07:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c0e:	89 04 24             	mov    %eax,(%esp)
80100c11:	e8 9f 72 00 00       	call   80107eb5 <allocuvm>
80100c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c1d:	75 05                	jne    80100c24 <exec+0x135>
      goto bad;
80100c1f:	e9 b0 02 00 00       	jmp    80100ed4 <exec+0x3e5>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c24:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c30:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c36:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c3e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c41:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c45:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4c:	89 04 24             	mov    %eax,(%esp)
80100c4f:	e8 76 71 00 00       	call   80107dca <loaduvm>
80100c54:	85 c0                	test   %eax,%eax
80100c56:	79 05                	jns    80100c5d <exec+0x16e>
      goto bad;
80100c58:	e9 77 02 00 00       	jmp    80100ed4 <exec+0x3e5>
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c5d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c64:	83 c0 20             	add    $0x20,%eax
80100c67:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6a:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c71:	0f b7 c0             	movzwl %ax,%eax
80100c74:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c77:	0f 8f 22 ff ff ff    	jg     80100b9f <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c80:	89 04 24             	mov    %eax,(%esp)
80100c83:	e8 4a 0e 00 00       	call   80101ad2 <iunlockput>
  ip = 0;
80100c88:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c92:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ca2:	05 00 20 00 00       	add    $0x2000,%eax
80100ca7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cae:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cb5:	89 04 24             	mov    %eax,(%esp)
80100cb8:	e8 f8 71 00 00       	call   80107eb5 <allocuvm>
80100cbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc4:	75 05                	jne    80100ccb <exec+0x1dc>
    goto bad;
80100cc6:	e9 09 02 00 00       	jmp    80100ed4 <exec+0x3e5>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ccb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cce:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cda:	89 04 24             	mov    %eax,(%esp)
80100cdd:	e8 03 74 00 00       	call   801080e5 <clearpteu>
  sp = sz;
80100ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ce8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cef:	e9 9a 00 00 00       	jmp    80100d8e <exec+0x29f>
    if(argc >= MAXARG)
80100cf4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cf8:	76 05                	jbe    80100cff <exec+0x210>
      goto bad;
80100cfa:	e9 d5 01 00 00       	jmp    80100ed4 <exec+0x3e5>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d09:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d0c:	01 d0                	add    %edx,%eax
80100d0e:	8b 00                	mov    (%eax),%eax
80100d10:	89 04 24             	mov    %eax,(%esp)
80100d13:	e8 0f 45 00 00       	call   80105227 <strlen>
80100d18:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d1b:	29 c2                	sub    %eax,%edx
80100d1d:	89 d0                	mov    %edx,%eax
80100d1f:	83 e8 01             	sub    $0x1,%eax
80100d22:	83 e0 fc             	and    $0xfffffffc,%eax
80100d25:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d35:	01 d0                	add    %edx,%eax
80100d37:	8b 00                	mov    (%eax),%eax
80100d39:	89 04 24             	mov    %eax,(%esp)
80100d3c:	e8 e6 44 00 00       	call   80105227 <strlen>
80100d41:	83 c0 01             	add    $0x1,%eax
80100d44:	89 c2                	mov    %eax,%edx
80100d46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d49:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d50:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d53:	01 c8                	add    %ecx,%eax
80100d55:	8b 00                	mov    (%eax),%eax
80100d57:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d69:	89 04 24             	mov    %eax,(%esp)
80100d6c:	e8 28 75 00 00       	call   80108299 <copyout>
80100d71:	85 c0                	test   %eax,%eax
80100d73:	79 05                	jns    80100d7a <exec+0x28b>
      goto bad;
80100d75:	e9 5a 01 00 00       	jmp    80100ed4 <exec+0x3e5>
    ustack[3+argc] = sp;
80100d7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d7d:	8d 50 03             	lea    0x3(%eax),%edx
80100d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d83:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d8a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9b:	01 d0                	add    %edx,%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	85 c0                	test   %eax,%eax
80100da1:	0f 85 4d ff ff ff    	jne    80100cf4 <exec+0x205>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daa:	83 c0 03             	add    $0x3,%eax
80100dad:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100db4:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100db8:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dbf:	ff ff ff 
  ustack[1] = argc;
80100dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc5:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dce:	83 c0 01             	add    $0x1,%eax
80100dd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	29 d0                	sub    %edx,%eax
80100ddd:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de6:	83 c0 04             	add    $0x4,%eax
80100de9:	c1 e0 02             	shl    $0x2,%eax
80100dec:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df2:	83 c0 04             	add    $0x4,%eax
80100df5:	c1 e0 02             	shl    $0x2,%eax
80100df8:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100dfc:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e02:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e09:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e10:	89 04 24             	mov    %eax,(%esp)
80100e13:	e8 81 74 00 00       	call   80108299 <copyout>
80100e18:	85 c0                	test   %eax,%eax
80100e1a:	79 05                	jns    80100e21 <exec+0x332>
    goto bad;
80100e1c:	e9 b3 00 00 00       	jmp    80100ed4 <exec+0x3e5>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e21:	8b 45 08             	mov    0x8(%ebp),%eax
80100e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e2d:	eb 17                	jmp    80100e46 <exec+0x357>
    if(*s == '/')
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	0f b6 00             	movzbl (%eax),%eax
80100e35:	3c 2f                	cmp    $0x2f,%al
80100e37:	75 09                	jne    80100e42 <exec+0x353>
      last = s+1;
80100e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3c:	83 c0 01             	add    $0x1,%eax
80100e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e49:	0f b6 00             	movzbl (%eax),%eax
80100e4c:	84 c0                	test   %al,%al
80100e4e:	75 df                	jne    80100e2f <exec+0x340>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e56:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e59:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e60:	00 
80100e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e64:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e68:	89 14 24             	mov    %edx,(%esp)
80100e6b:	e8 6d 43 00 00       	call   801051dd <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e76:	8b 40 04             	mov    0x4(%eax),%eax
80100e79:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e82:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e85:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e91:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 18             	mov    0x18(%eax),%eax
80100e9c:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ea2:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eab:	8b 40 18             	mov    0x18(%eax),%eax
80100eae:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb1:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	89 04 24             	mov    %eax,(%esp)
80100ebd:	e8 16 6d 00 00       	call   80107bd8 <switchuvm>
  freevm(oldpgdir);
80100ec2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ec5:	89 04 24             	mov    %eax,(%esp)
80100ec8:	e8 7e 71 00 00       	call   8010804b <freevm>
  return 0;
80100ecd:	b8 00 00 00 00       	mov    $0x0,%eax
80100ed2:	eb 27                	jmp    80100efb <exec+0x40c>

 bad:
  if(pgdir)
80100ed4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ed8:	74 0b                	je     80100ee5 <exec+0x3f6>
    freevm(pgdir);
80100eda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 66 71 00 00       	call   8010804b <freevm>
  if(ip)
80100ee5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ee9:	74 0b                	je     80100ef6 <exec+0x407>
    iunlockput(ip);
80100eeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100eee:	89 04 24             	mov    %eax,(%esp)
80100ef1:	e8 dc 0b 00 00       	call   80101ad2 <iunlockput>
  return -1;
80100ef6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100efb:	c9                   	leave  
80100efc:	c3                   	ret    

80100efd <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100efd:	55                   	push   %ebp
80100efe:	89 e5                	mov    %esp,%ebp
80100f00:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f03:	c7 44 24 04 9d 83 10 	movl   $0x8010839d,0x4(%esp)
80100f0a:	80 
80100f0b:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f12:	e8 31 3e 00 00       	call   80104d48 <initlock>
}
80100f17:	c9                   	leave  
80100f18:	c3                   	ret    

80100f19 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f19:	55                   	push   %ebp
80100f1a:	89 e5                	mov    %esp,%ebp
80100f1c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f1f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f26:	e8 3e 3e 00 00       	call   80104d69 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f2b:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f32:	eb 29                	jmp    80100f5d <filealloc+0x44>
    if(f->ref == 0){
80100f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f37:	8b 40 04             	mov    0x4(%eax),%eax
80100f3a:	85 c0                	test   %eax,%eax
80100f3c:	75 1b                	jne    80100f59 <filealloc+0x40>
      f->ref = 1;
80100f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f41:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f48:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f4f:	e8 77 3e 00 00       	call   80104dcb <release>
      return f;
80100f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f57:	eb 1e                	jmp    80100f77 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f59:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f5d:	81 7d f4 f4 e7 10 80 	cmpl   $0x8010e7f4,-0xc(%ebp)
80100f64:	72 ce                	jb     80100f34 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f66:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f6d:	e8 59 3e 00 00       	call   80104dcb <release>
  return 0;
80100f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f77:	c9                   	leave  
80100f78:	c3                   	ret    

80100f79 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f79:	55                   	push   %ebp
80100f7a:	89 e5                	mov    %esp,%ebp
80100f7c:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f7f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f86:	e8 de 3d 00 00       	call   80104d69 <acquire>
  if(f->ref < 1)
80100f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f8e:	8b 40 04             	mov    0x4(%eax),%eax
80100f91:	85 c0                	test   %eax,%eax
80100f93:	7f 0c                	jg     80100fa1 <filedup+0x28>
    panic("filedup");
80100f95:	c7 04 24 a4 83 10 80 	movl   $0x801083a4,(%esp)
80100f9c:	e8 99 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa4:	8b 40 04             	mov    0x4(%eax),%eax
80100fa7:	8d 50 01             	lea    0x1(%eax),%edx
80100faa:	8b 45 08             	mov    0x8(%ebp),%eax
80100fad:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fb0:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fb7:	e8 0f 3e 00 00       	call   80104dcb <release>
  return f;
80100fbc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fbf:	c9                   	leave  
80100fc0:	c3                   	ret    

80100fc1 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fc7:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fce:	e8 96 3d 00 00       	call   80104d69 <acquire>
  if(f->ref < 1)
80100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd6:	8b 40 04             	mov    0x4(%eax),%eax
80100fd9:	85 c0                	test   %eax,%eax
80100fdb:	7f 0c                	jg     80100fe9 <fileclose+0x28>
    panic("fileclose");
80100fdd:	c7 04 24 ac 83 10 80 	movl   $0x801083ac,(%esp)
80100fe4:	e8 51 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fec:	8b 40 04             	mov    0x4(%eax),%eax
80100fef:	8d 50 ff             	lea    -0x1(%eax),%edx
80100ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff5:	89 50 04             	mov    %edx,0x4(%eax)
80100ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffb:	8b 40 04             	mov    0x4(%eax),%eax
80100ffe:	85 c0                	test   %eax,%eax
80101000:	7e 11                	jle    80101013 <fileclose+0x52>
    release(&ftable.lock);
80101002:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101009:	e8 bd 3d 00 00       	call   80104dcb <release>
8010100e:	e9 82 00 00 00       	jmp    80101095 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101013:	8b 45 08             	mov    0x8(%ebp),%eax
80101016:	8b 10                	mov    (%eax),%edx
80101018:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010101b:	8b 50 04             	mov    0x4(%eax),%edx
8010101e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101021:	8b 50 08             	mov    0x8(%eax),%edx
80101024:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101027:	8b 50 0c             	mov    0xc(%eax),%edx
8010102a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010102d:	8b 50 10             	mov    0x10(%eax),%edx
80101030:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101033:	8b 40 14             	mov    0x14(%eax),%eax
80101036:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101039:	8b 45 08             	mov    0x8(%ebp),%eax
8010103c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010104c:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101053:	e8 73 3d 00 00       	call   80104dcb <release>
  
  if(ff.type == FD_PIPE)
80101058:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010105b:	83 f8 01             	cmp    $0x1,%eax
8010105e:	75 18                	jne    80101078 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101060:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101064:	0f be d0             	movsbl %al,%edx
80101067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010106a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010106e:	89 04 24             	mov    %eax,(%esp)
80101071:	e8 e5 2e 00 00       	call   80103f5b <pipeclose>
80101076:	eb 1d                	jmp    80101095 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101078:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010107b:	83 f8 02             	cmp    $0x2,%eax
8010107e:	75 15                	jne    80101095 <fileclose+0xd4>
    begin_trans();
80101080:	e8 99 23 00 00       	call   8010341e <begin_trans>
    iput(ff.ip);
80101085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101088:	89 04 24             	mov    %eax,(%esp)
8010108b:	e8 71 09 00 00       	call   80101a01 <iput>
    commit_trans();
80101090:	e8 d2 23 00 00       	call   80103467 <commit_trans>
  }
}
80101095:	c9                   	leave  
80101096:	c3                   	ret    

80101097 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101097:	55                   	push   %ebp
80101098:	89 e5                	mov    %esp,%ebp
8010109a:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010109d:	8b 45 08             	mov    0x8(%ebp),%eax
801010a0:	8b 00                	mov    (%eax),%eax
801010a2:	83 f8 02             	cmp    $0x2,%eax
801010a5:	75 38                	jne    801010df <filestat+0x48>
    ilock(f->ip);
801010a7:	8b 45 08             	mov    0x8(%ebp),%eax
801010aa:	8b 40 10             	mov    0x10(%eax),%eax
801010ad:	89 04 24             	mov    %eax,(%esp)
801010b0:	e8 99 07 00 00       	call   8010184e <ilock>
    stati(f->ip, st);
801010b5:	8b 45 08             	mov    0x8(%ebp),%eax
801010b8:	8b 40 10             	mov    0x10(%eax),%eax
801010bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801010be:	89 54 24 04          	mov    %edx,0x4(%esp)
801010c2:	89 04 24             	mov    %eax,(%esp)
801010c5:	e8 92 0e 00 00       	call   80101f5c <stati>
    iunlock(f->ip);
801010ca:	8b 45 08             	mov    0x8(%ebp),%eax
801010cd:	8b 40 10             	mov    0x10(%eax),%eax
801010d0:	89 04 24             	mov    %eax,(%esp)
801010d3:	e8 c4 08 00 00       	call   8010199c <iunlock>
    return 0;
801010d8:	b8 00 00 00 00       	mov    $0x0,%eax
801010dd:	eb 05                	jmp    801010e4 <filestat+0x4d>
  }
  return -1;
801010df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010e4:	c9                   	leave  
801010e5:	c3                   	ret    

801010e6 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010f3:	84 c0                	test   %al,%al
801010f5:	75 0a                	jne    80101101 <fileread+0x1b>
    return -1;
801010f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010fc:	e9 9f 00 00 00       	jmp    801011a0 <fileread+0xba>
  if(f->type == FD_PIPE)
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	8b 00                	mov    (%eax),%eax
80101106:	83 f8 01             	cmp    $0x1,%eax
80101109:	75 1e                	jne    80101129 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010110b:	8b 45 08             	mov    0x8(%ebp),%eax
8010110e:	8b 40 0c             	mov    0xc(%eax),%eax
80101111:	8b 55 10             	mov    0x10(%ebp),%edx
80101114:	89 54 24 08          	mov    %edx,0x8(%esp)
80101118:	8b 55 0c             	mov    0xc(%ebp),%edx
8010111b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010111f:	89 04 24             	mov    %eax,(%esp)
80101122:	e8 b5 2f 00 00       	call   801040dc <piperead>
80101127:	eb 77                	jmp    801011a0 <fileread+0xba>
  if(f->type == FD_INODE){
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 00                	mov    (%eax),%eax
8010112e:	83 f8 02             	cmp    $0x2,%eax
80101131:	75 61                	jne    80101194 <fileread+0xae>
    ilock(f->ip);
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 10             	mov    0x10(%eax),%eax
80101139:	89 04 24             	mov    %eax,(%esp)
8010113c:	e8 0d 07 00 00       	call   8010184e <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101141:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101144:	8b 45 08             	mov    0x8(%ebp),%eax
80101147:	8b 50 14             	mov    0x14(%eax),%edx
8010114a:	8b 45 08             	mov    0x8(%ebp),%eax
8010114d:	8b 40 10             	mov    0x10(%eax),%eax
80101150:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101154:	89 54 24 08          	mov    %edx,0x8(%esp)
80101158:	8b 55 0c             	mov    0xc(%ebp),%edx
8010115b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010115f:	89 04 24             	mov    %eax,(%esp)
80101162:	e8 3a 0e 00 00       	call   80101fa1 <readi>
80101167:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010116a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010116e:	7e 11                	jle    80101181 <fileread+0x9b>
      f->off += r;
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 50 14             	mov    0x14(%eax),%edx
80101176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101179:	01 c2                	add    %eax,%edx
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	8b 40 10             	mov    0x10(%eax),%eax
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 0d 08 00 00       	call   8010199c <iunlock>
    return r;
8010118f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101192:	eb 0c                	jmp    801011a0 <fileread+0xba>
  }
  panic("fileread");
80101194:	c7 04 24 b6 83 10 80 	movl   $0x801083b6,(%esp)
8010119b:	e8 9a f3 ff ff       	call   8010053a <panic>
}
801011a0:	c9                   	leave  
801011a1:	c3                   	ret    

801011a2 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011a2:	55                   	push   %ebp
801011a3:	89 e5                	mov    %esp,%ebp
801011a5:	53                   	push   %ebx
801011a6:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011b0:	84 c0                	test   %al,%al
801011b2:	75 0a                	jne    801011be <filewrite+0x1c>
    return -1;
801011b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011b9:	e9 20 01 00 00       	jmp    801012de <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	8b 00                	mov    (%eax),%eax
801011c3:	83 f8 01             	cmp    $0x1,%eax
801011c6:	75 21                	jne    801011e9 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	8b 40 0c             	mov    0xc(%eax),%eax
801011ce:	8b 55 10             	mov    0x10(%ebp),%edx
801011d1:	89 54 24 08          	mov    %edx,0x8(%esp)
801011d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801011d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801011dc:	89 04 24             	mov    %eax,(%esp)
801011df:	e8 09 2e 00 00       	call   80103fed <pipewrite>
801011e4:	e9 f5 00 00 00       	jmp    801012de <filewrite+0x13c>
  if(f->type == FD_INODE){
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 00                	mov    (%eax),%eax
801011ee:	83 f8 02             	cmp    $0x2,%eax
801011f1:	0f 85 db 00 00 00    	jne    801012d2 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011f7:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801011fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101205:	e9 a8 00 00 00       	jmp    801012b2 <filewrite+0x110>
      int n1 = n - i;
8010120a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010120d:	8b 55 10             	mov    0x10(%ebp),%edx
80101210:	29 c2                	sub    %eax,%edx
80101212:	89 d0                	mov    %edx,%eax
80101214:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010121a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010121d:	7e 06                	jle    80101225 <filewrite+0x83>
        n1 = max;
8010121f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101222:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101225:	e8 f4 21 00 00       	call   8010341e <begin_trans>
      ilock(f->ip);
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 40 10             	mov    0x10(%eax),%eax
80101230:	89 04 24             	mov    %eax,(%esp)
80101233:	e8 16 06 00 00       	call   8010184e <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101238:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 50 14             	mov    0x14(%eax),%edx
80101241:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101244:	8b 45 0c             	mov    0xc(%ebp),%eax
80101247:	01 c3                	add    %eax,%ebx
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 40 10             	mov    0x10(%eax),%eax
8010124f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101253:	89 54 24 08          	mov    %edx,0x8(%esp)
80101257:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010125b:	89 04 24             	mov    %eax,(%esp)
8010125e:	e8 a2 0e 00 00       	call   80102105 <writei>
80101263:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101266:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010126a:	7e 11                	jle    8010127d <filewrite+0xdb>
        f->off += r;
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 50 14             	mov    0x14(%eax),%edx
80101272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101275:	01 c2                	add    %eax,%edx
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	89 04 24             	mov    %eax,(%esp)
80101286:	e8 11 07 00 00       	call   8010199c <iunlock>
      commit_trans();
8010128b:	e8 d7 21 00 00       	call   80103467 <commit_trans>

      if(r < 0)
80101290:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101294:	79 02                	jns    80101298 <filewrite+0xf6>
        break;
80101296:	eb 26                	jmp    801012be <filewrite+0x11c>
      if(r != n1)
80101298:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010129e:	74 0c                	je     801012ac <filewrite+0x10a>
        panic("short filewrite");
801012a0:	c7 04 24 bf 83 10 80 	movl   $0x801083bf,(%esp)
801012a7:	e8 8e f2 ff ff       	call   8010053a <panic>
      i += r;
801012ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012af:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801012b8:	0f 8c 4c ff ff ff    	jl     8010120a <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c1:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c4:	75 05                	jne    801012cb <filewrite+0x129>
801012c6:	8b 45 10             	mov    0x10(%ebp),%eax
801012c9:	eb 05                	jmp    801012d0 <filewrite+0x12e>
801012cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d0:	eb 0c                	jmp    801012de <filewrite+0x13c>
  }
  panic("filewrite");
801012d2:	c7 04 24 cf 83 10 80 	movl   $0x801083cf,(%esp)
801012d9:	e8 5c f2 ff ff       	call   8010053a <panic>
}
801012de:	83 c4 24             	add    $0x24,%esp
801012e1:	5b                   	pop    %ebx
801012e2:	5d                   	pop    %ebp
801012e3:	c3                   	ret    

801012e4 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012e4:	55                   	push   %ebp
801012e5:	89 e5                	mov    %esp,%ebp
801012e7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012ea:	8b 45 08             	mov    0x8(%ebp),%eax
801012ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012f4:	00 
801012f5:	89 04 24             	mov    %eax,(%esp)
801012f8:	e8 a9 ee ff ff       	call   801001a6 <bread>
801012fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101303:	83 c0 18             	add    $0x18,%eax
80101306:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010130d:	00 
8010130e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101312:	8b 45 0c             	mov    0xc(%ebp),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 6f 3d 00 00       	call   8010508c <memmove>
  brelse(bp);
8010131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101320:	89 04 24             	mov    %eax,(%esp)
80101323:	e8 ef ee ff ff       	call   80100217 <brelse>
}
80101328:	c9                   	leave  
80101329:	c3                   	ret    

8010132a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010132a:	55                   	push   %ebp
8010132b:	89 e5                	mov    %esp,%ebp
8010132d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101330:	8b 55 0c             	mov    0xc(%ebp),%edx
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133a:	89 04 24             	mov    %eax,(%esp)
8010133d:	e8 64 ee ff ff       	call   801001a6 <bread>
80101342:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	83 c0 18             	add    $0x18,%eax
8010134b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101352:	00 
80101353:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010135a:	00 
8010135b:	89 04 24             	mov    %eax,(%esp)
8010135e:	e8 5a 3c 00 00       	call   80104fbd <memset>
  log_write(bp);
80101363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 51 21 00 00       	call   801034bf <log_write>
  brelse(bp);
8010136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101371:	89 04 24             	mov    %eax,(%esp)
80101374:	e8 9e ee ff ff       	call   80100217 <brelse>
}
80101379:	c9                   	leave  
8010137a:	c3                   	ret    

8010137b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010137b:	55                   	push   %ebp
8010137c:	89 e5                	mov    %esp,%ebp
8010137e:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101381:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101388:	8b 45 08             	mov    0x8(%ebp),%eax
8010138b:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010138e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101392:	89 04 24             	mov    %eax,(%esp)
80101395:	e8 4a ff ff ff       	call   801012e4 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010139a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013a1:	e9 07 01 00 00       	jmp    801014ad <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013af:	85 c0                	test   %eax,%eax
801013b1:	0f 48 c2             	cmovs  %edx,%eax
801013b4:	c1 f8 0c             	sar    $0xc,%eax
801013b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013ba:	c1 ea 02             	shr    $0x2,%edx
801013bd:	01 d0                	add    %edx,%eax
801013bf:	83 c0 03             	add    $0x3,%eax
801013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801013c6:	8b 45 08             	mov    0x8(%ebp),%eax
801013c9:	89 04 24             	mov    %eax,(%esp)
801013cc:	e8 d5 ed ff ff       	call   801001a6 <bread>
801013d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013db:	e9 9d 00 00 00       	jmp    8010147d <balloc+0x102>
      m = 1 << (bi % 8);
801013e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013e3:	99                   	cltd   
801013e4:	c1 ea 1d             	shr    $0x1d,%edx
801013e7:	01 d0                	add    %edx,%eax
801013e9:	83 e0 07             	and    $0x7,%eax
801013ec:	29 d0                	sub    %edx,%eax
801013ee:	ba 01 00 00 00       	mov    $0x1,%edx
801013f3:	89 c1                	mov    %eax,%ecx
801013f5:	d3 e2                	shl    %cl,%edx
801013f7:	89 d0                	mov    %edx,%eax
801013f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ff:	8d 50 07             	lea    0x7(%eax),%edx
80101402:	85 c0                	test   %eax,%eax
80101404:	0f 48 c2             	cmovs  %edx,%eax
80101407:	c1 f8 03             	sar    $0x3,%eax
8010140a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010140d:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101412:	0f b6 c0             	movzbl %al,%eax
80101415:	23 45 e8             	and    -0x18(%ebp),%eax
80101418:	85 c0                	test   %eax,%eax
8010141a:	75 5d                	jne    80101479 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
8010141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141f:	8d 50 07             	lea    0x7(%eax),%edx
80101422:	85 c0                	test   %eax,%eax
80101424:	0f 48 c2             	cmovs  %edx,%eax
80101427:	c1 f8 03             	sar    $0x3,%eax
8010142a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010142d:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101432:	89 d1                	mov    %edx,%ecx
80101434:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101437:	09 ca                	or     %ecx,%edx
80101439:	89 d1                	mov    %edx,%ecx
8010143b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143e:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101442:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101445:	89 04 24             	mov    %eax,(%esp)
80101448:	e8 72 20 00 00       	call   801034bf <log_write>
        brelse(bp);
8010144d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101450:	89 04 24             	mov    %eax,(%esp)
80101453:	e8 bf ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010145b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010145e:	01 c2                	add    %eax,%edx
80101460:	8b 45 08             	mov    0x8(%ebp),%eax
80101463:	89 54 24 04          	mov    %edx,0x4(%esp)
80101467:	89 04 24             	mov    %eax,(%esp)
8010146a:	e8 bb fe ff ff       	call   8010132a <bzero>
        return b + bi;
8010146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101472:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101475:	01 d0                	add    %edx,%eax
80101477:	eb 4e                	jmp    801014c7 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101479:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010147d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101484:	7f 15                	jg     8010149b <balloc+0x120>
80101486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101489:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010148c:	01 d0                	add    %edx,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101493:	39 c2                	cmp    %eax,%edx
80101495:	0f 82 45 ff ff ff    	jb     801013e0 <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010149b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149e:	89 04 24             	mov    %eax,(%esp)
801014a1:	e8 71 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014b3:	39 c2                	cmp    %eax,%edx
801014b5:	0f 82 eb fe ff ff    	jb     801013a6 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014bb:	c7 04 24 d9 83 10 80 	movl   $0x801083d9,(%esp)
801014c2:	e8 73 f0 ff ff       	call   8010053a <panic>
}
801014c7:	c9                   	leave  
801014c8:	c3                   	ret    

801014c9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014c9:	55                   	push   %ebp
801014ca:	89 e5                	mov    %esp,%ebp
801014cc:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014cf:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801014d6:	8b 45 08             	mov    0x8(%ebp),%eax
801014d9:	89 04 24             	mov    %eax,(%esp)
801014dc:	e8 03 fe ff ff       	call   801012e4 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801014e4:	c1 e8 0c             	shr    $0xc,%eax
801014e7:	89 c2                	mov    %eax,%edx
801014e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014ec:	c1 e8 02             	shr    $0x2,%eax
801014ef:	01 d0                	add    %edx,%eax
801014f1:	8d 50 03             	lea    0x3(%eax),%edx
801014f4:	8b 45 08             	mov    0x8(%ebp),%eax
801014f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801014fb:	89 04 24             	mov    %eax,(%esp)
801014fe:	e8 a3 ec ff ff       	call   801001a6 <bread>
80101503:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101506:	8b 45 0c             	mov    0xc(%ebp),%eax
80101509:	25 ff 0f 00 00       	and    $0xfff,%eax
8010150e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101514:	99                   	cltd   
80101515:	c1 ea 1d             	shr    $0x1d,%edx
80101518:	01 d0                	add    %edx,%eax
8010151a:	83 e0 07             	and    $0x7,%eax
8010151d:	29 d0                	sub    %edx,%eax
8010151f:	ba 01 00 00 00       	mov    $0x1,%edx
80101524:	89 c1                	mov    %eax,%ecx
80101526:	d3 e2                	shl    %cl,%edx
80101528:	89 d0                	mov    %edx,%eax
8010152a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101530:	8d 50 07             	lea    0x7(%eax),%edx
80101533:	85 c0                	test   %eax,%eax
80101535:	0f 48 c2             	cmovs  %edx,%eax
80101538:	c1 f8 03             	sar    $0x3,%eax
8010153b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153e:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101543:	0f b6 c0             	movzbl %al,%eax
80101546:	23 45 ec             	and    -0x14(%ebp),%eax
80101549:	85 c0                	test   %eax,%eax
8010154b:	75 0c                	jne    80101559 <bfree+0x90>
    panic("freeing free block");
8010154d:	c7 04 24 ef 83 10 80 	movl   $0x801083ef,(%esp)
80101554:	e8 e1 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101559:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155c:	8d 50 07             	lea    0x7(%eax),%edx
8010155f:	85 c0                	test   %eax,%eax
80101561:	0f 48 c2             	cmovs  %edx,%eax
80101564:	c1 f8 03             	sar    $0x3,%eax
80101567:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010156a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010156f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101572:	f7 d1                	not    %ecx
80101574:	21 ca                	and    %ecx,%edx
80101576:	89 d1                	mov    %edx,%ecx
80101578:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010157f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101582:	89 04 24             	mov    %eax,(%esp)
80101585:	e8 35 1f 00 00       	call   801034bf <log_write>
  brelse(bp);
8010158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158d:	89 04 24             	mov    %eax,(%esp)
80101590:	e8 82 ec ff ff       	call   80100217 <brelse>
}
80101595:	c9                   	leave  
80101596:	c3                   	ret    

80101597 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101597:	55                   	push   %ebp
80101598:	89 e5                	mov    %esp,%ebp
8010159a:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
8010159d:	c7 44 24 04 02 84 10 	movl   $0x80108402,0x4(%esp)
801015a4:	80 
801015a5:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015ac:	e8 97 37 00 00       	call   80104d48 <initlock>
}
801015b1:	c9                   	leave  
801015b2:	c3                   	ret    

801015b3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015b3:	55                   	push   %ebp
801015b4:	89 e5                	mov    %esp,%ebp
801015b6:	83 ec 38             	sub    $0x38,%esp
801015b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015bc:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015c0:	8b 45 08             	mov    0x8(%ebp),%eax
801015c3:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801015ca:	89 04 24             	mov    %eax,(%esp)
801015cd:	e8 12 fd ff ff       	call   801012e4 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015d2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015d9:	e9 98 00 00 00       	jmp    80101676 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e1:	c1 e8 02             	shr    $0x2,%eax
801015e4:	83 c0 02             	add    $0x2,%eax
801015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801015eb:	8b 45 08             	mov    0x8(%ebp),%eax
801015ee:	89 04 24             	mov    %eax,(%esp)
801015f1:	e8 b0 eb ff ff       	call   801001a6 <bread>
801015f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fc:	8d 50 18             	lea    0x18(%eax),%edx
801015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101602:	83 e0 03             	and    $0x3,%eax
80101605:	c1 e0 07             	shl    $0x7,%eax
80101608:	01 d0                	add    %edx,%eax
8010160a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010160d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101610:	0f b7 00             	movzwl (%eax),%eax
80101613:	66 85 c0             	test   %ax,%ax
80101616:	75 4f                	jne    80101667 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101618:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010161f:	00 
80101620:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101627:	00 
80101628:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162b:	89 04 24             	mov    %eax,(%esp)
8010162e:	e8 8a 39 00 00       	call   80104fbd <memset>
      dip->type = type;
80101633:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101636:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010163a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101640:	89 04 24             	mov    %eax,(%esp)
80101643:	e8 77 1e 00 00       	call   801034bf <log_write>
      brelse(bp);
80101648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164b:	89 04 24             	mov    %eax,(%esp)
8010164e:	e8 c4 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101656:	89 44 24 04          	mov    %eax,0x4(%esp)
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	89 04 24             	mov    %eax,(%esp)
80101660:	e8 e5 00 00 00       	call   8010174a <iget>
80101665:	eb 29                	jmp    80101690 <ialloc+0xdd>
    }
    brelse(bp);
80101667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 a5 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101672:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101676:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010167c:	39 c2                	cmp    %eax,%edx
8010167e:	0f 82 5a ff ff ff    	jb     801015de <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101684:	c7 04 24 09 84 10 80 	movl   $0x80108409,(%esp)
8010168b:	e8 aa ee ff ff       	call   8010053a <panic>
}
80101690:	c9                   	leave  
80101691:	c3                   	ret    

80101692 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101692:	55                   	push   %ebp
80101693:	89 e5                	mov    %esp,%ebp
80101695:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101698:	8b 45 08             	mov    0x8(%ebp),%eax
8010169b:	8b 40 04             	mov    0x4(%eax),%eax
8010169e:	c1 e8 02             	shr    $0x2,%eax
801016a1:	8d 50 02             	lea    0x2(%eax),%edx
801016a4:	8b 45 08             	mov    0x8(%ebp),%eax
801016a7:	8b 00                	mov    (%eax),%eax
801016a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ad:	89 04 24             	mov    %eax,(%esp)
801016b0:	e8 f1 ea ff ff       	call   801001a6 <bread>
801016b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016bb:	8d 50 18             	lea    0x18(%eax),%edx
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 40 04             	mov    0x4(%eax),%eax
801016c4:	83 e0 03             	and    $0x3,%eax
801016c7:	c1 e0 07             	shl    $0x7,%eax
801016ca:	01 d0                	add    %edx,%eax
801016cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016cf:	8b 45 08             	mov    0x8(%ebp),%eax
801016d2:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e6:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016ea:	8b 45 08             	mov    0x8(%ebp),%eax
801016ed:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f4:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801016f8:	8b 45 08             	mov    0x8(%ebp),%eax
801016fb:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101702:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101706:	8b 45 08             	mov    0x8(%ebp),%eax
80101709:	8b 50 18             	mov    0x18(%eax),%edx
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101712:	8b 45 08             	mov    0x8(%ebp),%eax
80101715:	8d 50 1c             	lea    0x1c(%eax),%edx
80101718:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171b:	83 c0 0c             	add    $0xc,%eax
8010171e:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
80101725:	00 
80101726:	89 54 24 04          	mov    %edx,0x4(%esp)
8010172a:	89 04 24             	mov    %eax,(%esp)
8010172d:	e8 5a 39 00 00       	call   8010508c <memmove>
  log_write(bp);
80101732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101735:	89 04 24             	mov    %eax,(%esp)
80101738:	e8 82 1d 00 00       	call   801034bf <log_write>
  brelse(bp);
8010173d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101740:	89 04 24             	mov    %eax,(%esp)
80101743:	e8 cf ea ff ff       	call   80100217 <brelse>
}
80101748:	c9                   	leave  
80101749:	c3                   	ret    

8010174a <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010174a:	55                   	push   %ebp
8010174b:	89 e5                	mov    %esp,%ebp
8010174d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101750:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101757:	e8 0d 36 00 00       	call   80104d69 <acquire>

  // Is the inode already cached?
  empty = 0;
8010175c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101763:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
8010176a:	eb 59                	jmp    801017c5 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176f:	8b 40 08             	mov    0x8(%eax),%eax
80101772:	85 c0                	test   %eax,%eax
80101774:	7e 35                	jle    801017ab <iget+0x61>
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	8b 00                	mov    (%eax),%eax
8010177b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010177e:	75 2b                	jne    801017ab <iget+0x61>
80101780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101783:	8b 40 04             	mov    0x4(%eax),%eax
80101786:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101789:	75 20                	jne    801017ab <iget+0x61>
      ip->ref++;
8010178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178e:	8b 40 08             	mov    0x8(%eax),%eax
80101791:	8d 50 01             	lea    0x1(%eax),%edx
80101794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101797:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010179a:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801017a1:	e8 25 36 00 00       	call   80104dcb <release>
      return ip;
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	eb 6f                	jmp    8010181a <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017af:	75 10                	jne    801017c1 <iget+0x77>
801017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b4:	8b 40 08             	mov    0x8(%eax),%eax
801017b7:	85 c0                	test   %eax,%eax
801017b9:	75 06                	jne    801017c1 <iget+0x77>
      empty = ip;
801017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017be:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017c1:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
801017c5:	81 7d f4 fc f8 10 80 	cmpl   $0x8010f8fc,-0xc(%ebp)
801017cc:	72 9e                	jb     8010176c <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017d2:	75 0c                	jne    801017e0 <iget+0x96>
    panic("iget: no inodes");
801017d4:	c7 04 24 1b 84 10 80 	movl   $0x8010841b,(%esp)
801017db:	e8 5a ed ff ff       	call   8010053a <panic>

  ip = empty;
801017e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e9:	8b 55 08             	mov    0x8(%ebp),%edx
801017ec:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f1:	8b 55 0c             	mov    0xc(%ebp),%edx
801017f4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101804:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010180b:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101812:	e8 b4 35 00 00       	call   80104dcb <release>

  return ip;
80101817:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010181a:	c9                   	leave  
8010181b:	c3                   	ret    

8010181c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010181c:	55                   	push   %ebp
8010181d:	89 e5                	mov    %esp,%ebp
8010181f:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101822:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101829:	e8 3b 35 00 00       	call   80104d69 <acquire>
  ip->ref++;
8010182e:	8b 45 08             	mov    0x8(%ebp),%eax
80101831:	8b 40 08             	mov    0x8(%eax),%eax
80101834:	8d 50 01             	lea    0x1(%eax),%edx
80101837:	8b 45 08             	mov    0x8(%ebp),%eax
8010183a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010183d:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101844:	e8 82 35 00 00       	call   80104dcb <release>
  return ip;
80101849:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010184c:	c9                   	leave  
8010184d:	c3                   	ret    

8010184e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010184e:	55                   	push   %ebp
8010184f:	89 e5                	mov    %esp,%ebp
80101851:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101854:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101858:	74 0a                	je     80101864 <ilock+0x16>
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	8b 40 08             	mov    0x8(%eax),%eax
80101860:	85 c0                	test   %eax,%eax
80101862:	7f 0c                	jg     80101870 <ilock+0x22>
    panic("ilock");
80101864:	c7 04 24 2b 84 10 80 	movl   $0x8010842b,(%esp)
8010186b:	e8 ca ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101870:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101877:	e8 ed 34 00 00       	call   80104d69 <acquire>
  while(ip->flags & I_BUSY)
8010187c:	eb 13                	jmp    80101891 <ilock+0x43>
    sleep(ip, &icache.lock);
8010187e:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
80101885:	80 
80101886:	8b 45 08             	mov    0x8(%ebp),%eax
80101889:	89 04 24             	mov    %eax,(%esp)
8010188c:	e8 0e 32 00 00       	call   80104a9f <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101891:	8b 45 08             	mov    0x8(%ebp),%eax
80101894:	8b 40 0c             	mov    0xc(%eax),%eax
80101897:	83 e0 01             	and    $0x1,%eax
8010189a:	85 c0                	test   %eax,%eax
8010189c:	75 e0                	jne    8010187e <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	8b 40 0c             	mov    0xc(%eax),%eax
801018a4:	83 c8 01             	or     $0x1,%eax
801018a7:	89 c2                	mov    %eax,%edx
801018a9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ac:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018af:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018b6:	e8 10 35 00 00       	call   80104dcb <release>

  if(!(ip->flags & I_VALID)){
801018bb:	8b 45 08             	mov    0x8(%ebp),%eax
801018be:	8b 40 0c             	mov    0xc(%eax),%eax
801018c1:	83 e0 02             	and    $0x2,%eax
801018c4:	85 c0                	test   %eax,%eax
801018c6:	0f 85 ce 00 00 00    	jne    8010199a <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018cc:	8b 45 08             	mov    0x8(%ebp),%eax
801018cf:	8b 40 04             	mov    0x4(%eax),%eax
801018d2:	c1 e8 02             	shr    $0x2,%eax
801018d5:	8d 50 02             	lea    0x2(%eax),%edx
801018d8:	8b 45 08             	mov    0x8(%ebp),%eax
801018db:	8b 00                	mov    (%eax),%eax
801018dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801018e1:	89 04 24             	mov    %eax,(%esp)
801018e4:	e8 bd e8 ff ff       	call   801001a6 <bread>
801018e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ef:	8d 50 18             	lea    0x18(%eax),%edx
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 40 04             	mov    0x4(%eax),%eax
801018f8:	83 e0 03             	and    $0x3,%eax
801018fb:	c1 e0 07             	shl    $0x7,%eax
801018fe:	01 d0                	add    %edx,%eax
80101900:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101906:	0f b7 10             	movzwl (%eax),%edx
80101909:	8b 45 08             	mov    0x8(%ebp),%eax
8010190c:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101913:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101921:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101925:	8b 45 08             	mov    0x8(%ebp),%eax
80101928:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010192c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
8010193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193d:	8b 50 08             	mov    0x8(%eax),%edx
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101949:	8d 50 0c             	lea    0xc(%eax),%edx
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	83 c0 1c             	add    $0x1c,%eax
80101952:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
80101959:	00 
8010195a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010195e:	89 04 24             	mov    %eax,(%esp)
80101961:	e8 26 37 00 00       	call   8010508c <memmove>
    brelse(bp);
80101966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101969:	89 04 24             	mov    %eax,(%esp)
8010196c:	e8 a6 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	8b 40 0c             	mov    0xc(%eax),%eax
80101977:	83 c8 02             	or     $0x2,%eax
8010197a:	89 c2                	mov    %eax,%edx
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101982:	8b 45 08             	mov    0x8(%ebp),%eax
80101985:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101989:	66 85 c0             	test   %ax,%ax
8010198c:	75 0c                	jne    8010199a <ilock+0x14c>
      panic("ilock: no type");
8010198e:	c7 04 24 31 84 10 80 	movl   $0x80108431,(%esp)
80101995:	e8 a0 eb ff ff       	call   8010053a <panic>
  }
}
8010199a:	c9                   	leave  
8010199b:	c3                   	ret    

8010199c <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
8010199c:	55                   	push   %ebp
8010199d:	89 e5                	mov    %esp,%ebp
8010199f:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019a6:	74 17                	je     801019bf <iunlock+0x23>
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	8b 40 0c             	mov    0xc(%eax),%eax
801019ae:	83 e0 01             	and    $0x1,%eax
801019b1:	85 c0                	test   %eax,%eax
801019b3:	74 0a                	je     801019bf <iunlock+0x23>
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	8b 40 08             	mov    0x8(%eax),%eax
801019bb:	85 c0                	test   %eax,%eax
801019bd:	7f 0c                	jg     801019cb <iunlock+0x2f>
    panic("iunlock");
801019bf:	c7 04 24 40 84 10 80 	movl   $0x80108440,(%esp)
801019c6:	e8 6f eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019cb:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019d2:	e8 92 33 00 00       	call   80104d69 <acquire>
  ip->flags &= ~I_BUSY;
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	8b 40 0c             	mov    0xc(%eax),%eax
801019dd:	83 e0 fe             	and    $0xfffffffe,%eax
801019e0:	89 c2                	mov    %eax,%edx
801019e2:	8b 45 08             	mov    0x8(%ebp),%eax
801019e5:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	89 04 24             	mov    %eax,(%esp)
801019ee:	e8 85 31 00 00       	call   80104b78 <wakeup>
  release(&icache.lock);
801019f3:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019fa:	e8 cc 33 00 00       	call   80104dcb <release>
}
801019ff:	c9                   	leave  
80101a00:	c3                   	ret    

80101a01 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a01:	55                   	push   %ebp
80101a02:	89 e5                	mov    %esp,%ebp
80101a04:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a07:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a0e:	e8 56 33 00 00       	call   80104d69 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a13:	8b 45 08             	mov    0x8(%ebp),%eax
80101a16:	8b 40 08             	mov    0x8(%eax),%eax
80101a19:	83 f8 01             	cmp    $0x1,%eax
80101a1c:	0f 85 93 00 00 00    	jne    80101ab5 <iput+0xb4>
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 40 0c             	mov    0xc(%eax),%eax
80101a28:	83 e0 02             	and    $0x2,%eax
80101a2b:	85 c0                	test   %eax,%eax
80101a2d:	0f 84 82 00 00 00    	je     80101ab5 <iput+0xb4>
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a3a:	66 85 c0             	test   %ax,%ax
80101a3d:	75 76                	jne    80101ab5 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 40 0c             	mov    0xc(%eax),%eax
80101a45:	83 e0 01             	and    $0x1,%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	74 0c                	je     80101a58 <iput+0x57>
      panic("iput busy");
80101a4c:	c7 04 24 48 84 10 80 	movl   $0x80108448,(%esp)
80101a53:	e8 e2 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5e:	83 c8 01             	or     $0x1,%eax
80101a61:	89 c2                	mov    %eax,%edx
80101a63:	8b 45 08             	mov    0x8(%ebp),%eax
80101a66:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a69:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a70:	e8 56 33 00 00       	call   80104dcb <release>
    itrunc(ip);
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	89 04 24             	mov    %eax,(%esp)
80101a7b:	e8 95 02 00 00       	call   80101d15 <itrunc>
    ip->type = 0;
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 04 24             	mov    %eax,(%esp)
80101a8f:	e8 fe fb ff ff       	call   80101692 <iupdate>
    acquire(&icache.lock);
80101a94:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a9b:	e8 c9 32 00 00       	call   80104d69 <acquire>
    ip->flags = 0;
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	89 04 24             	mov    %eax,(%esp)
80101ab0:	e8 c3 30 00 00       	call   80104b78 <wakeup>
  }
  ip->ref--;
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 08             	mov    0x8(%eax),%eax
80101abb:	8d 50 ff             	lea    -0x1(%eax),%edx
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ac4:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101acb:	e8 fb 32 00 00       	call   80104dcb <release>
}
80101ad0:	c9                   	leave  
80101ad1:	c3                   	ret    

80101ad2 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ad2:	55                   	push   %ebp
80101ad3:	89 e5                	mov    %esp,%ebp
80101ad5:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 04 24             	mov    %eax,(%esp)
80101ade:	e8 b9 fe ff ff       	call   8010199c <iunlock>
  iput(ip);
80101ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae6:	89 04 24             	mov    %eax,(%esp)
80101ae9:	e8 13 ff ff ff       	call   80101a01 <iput>
}
80101aee:	c9                   	leave  
80101aef:	c3                   	ret    

80101af0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101af0:	55                   	push   %ebp
80101af1:	89 e5                	mov    %esp,%ebp
80101af3:	53                   	push   %ebx
80101af4:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){		// search the direct links.
80101af7:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101afb:	77 3e                	ja     80101b3b <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b03:	83 c2 04             	add    $0x4,%edx
80101b06:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b11:	75 20                	jne    80101b33 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	8b 00                	mov    (%eax),%eax
80101b18:	89 04 24             	mov    %eax,(%esp)
80101b1b:	e8 5b f8 ff ff       	call   8010137b <balloc>
80101b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b29:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b2f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b36:	e9 d4 01 00 00       	jmp    80101d0f <bmap+0x21f>
  }
  bn -= NDIRECT;
80101b3b:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){		// search the indirect
80101b3f:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b43:	0f 87 a5 00 00 00    	ja     80101bee <bmap+0xfe>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b56:	75 19                	jne    80101b71 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8b 00                	mov    (%eax),%eax
80101b5d:	89 04 24             	mov    %eax,(%esp)
80101b60:	e8 16 f8 ff ff       	call   8010137b <balloc>
80101b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b6e:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	8b 00                	mov    (%eax),%eax
80101b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b79:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b7d:	89 04 24             	mov    %eax,(%esp)
80101b80:	e8 21 e6 ff ff       	call   801001a6 <bread>
80101b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8b:	83 c0 18             	add    $0x18,%eax
80101b8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b91:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b9e:	01 d0                	add    %edx,%eax
80101ba0:	8b 00                	mov    (%eax),%eax
80101ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ba9:	75 30                	jne    80101bdb <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bb8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbe:	8b 00                	mov    (%eax),%eax
80101bc0:	89 04 24             	mov    %eax,(%esp)
80101bc3:	e8 b3 f7 ff ff       	call   8010137b <balloc>
80101bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bce:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd3:	89 04 24             	mov    %eax,(%esp)
80101bd6:	e8 e4 18 00 00       	call   801034bf <log_write>
    }
    brelse(bp);
80101bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bde:	89 04 24             	mov    %eax,(%esp)
80101be1:	e8 31 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be9:	e9 21 01 00 00       	jmp    80101d0f <bmap+0x21f>
  }

  bn -= 128;
80101bee:	83 45 0c 80          	addl   $0xffffff80,0xc(%ebp)

  if(bn < DNINDIRECT){		// search the doubly-indirect
80101bf2:	81 7d 0c ff 3f 00 00 	cmpl   $0x3fff,0xc(%ebp)
80101bf9:	0f 87 04 01 00 00    	ja     80101d03 <bmap+0x213>
    // Load doubly-indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT+1]) == 0) {
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	8b 40 50             	mov    0x50(%eax),%eax
80101c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c0c:	75 19                	jne    80101c27 <bmap+0x137>
      ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	8b 00                	mov    (%eax),%eax
80101c13:	89 04 24             	mov    %eax,(%esp)
80101c16:	e8 60 f7 ff ff       	call   8010137b <balloc>
80101c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c24:	89 50 50             	mov    %edx,0x50(%eax)
    }
    bp = bread(ip->dev, addr);
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 00                	mov    (%eax),%eax
80101c2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c33:	89 04 24             	mov    %eax,(%esp)
80101c36:	e8 6b e5 ff ff       	call   801001a6 <bread>
80101c3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c41:	83 c0 18             	add    $0x18,%eax
80101c44:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn/128]) == 0){
80101c47:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c4a:	c1 e8 07             	shr    $0x7,%eax
80101c4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c57:	01 d0                	add    %edx,%eax
80101c59:	8b 00                	mov    (%eax),%eax
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c62:	75 28                	jne    80101c8c <bmap+0x19c>
    	a[bn/128] = addr = balloc(ip->dev);
80101c64:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c67:	c1 e8 07             	shr    $0x7,%eax
80101c6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c74:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 04 24             	mov    %eax,(%esp)
80101c7f:	e8 f7 f6 ff ff       	call   8010137b <balloc>
80101c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8a:	89 03                	mov    %eax,(%ebx)
    }
    bp = bread(ip->dev, addr);
80101c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8f:	8b 00                	mov    (%eax),%eax
80101c91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c94:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c98:	89 04 24             	mov    %eax,(%esp)
80101c9b:	e8 06 e5 ff ff       	call   801001a6 <bread>
80101ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((addr = a[bn%128]) == 0){
80101ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ca6:	83 e0 7f             	and    $0x7f,%eax
80101ca9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cb3:	01 d0                	add    %edx,%eax
80101cb5:	8b 00                	mov    (%eax),%eax
80101cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cbe:	75 33                	jne    80101cf3 <bmap+0x203>
      a[bn%128] = addr = balloc(ip->dev);
80101cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cc3:	83 e0 7f             	and    $0x7f,%eax
80101cc6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cd0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd6:	8b 00                	mov    (%eax),%eax
80101cd8:	89 04 24             	mov    %eax,(%esp)
80101cdb:	e8 9b f6 ff ff       	call   8010137b <balloc>
80101ce0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce6:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ceb:	89 04 24             	mov    %eax,(%esp)
80101cee:	e8 cc 17 00 00       	call   801034bf <log_write>
    }
    brelse(bp);
80101cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf6:	89 04 24             	mov    %eax,(%esp)
80101cf9:	e8 19 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d01:	eb 0c                	jmp    80101d0f <bmap+0x21f>
  }

  panic("bmap: out of range");
80101d03:	c7 04 24 52 84 10 80 	movl   $0x80108452,(%esp)
80101d0a:	e8 2b e8 ff ff       	call   8010053a <panic>
}
80101d0f:	83 c4 24             	add    $0x24,%esp
80101d12:	5b                   	pop    %ebx
80101d13:	5d                   	pop    %ebp
80101d14:	c3                   	ret    

80101d15 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d15:	55                   	push   %ebp
80101d16:	89 e5                	mov    %esp,%ebp
80101d18:	83 ec 38             	sub    $0x38,%esp
  int i, j;
  struct buf *bp;
  uint *a,*b;

  for(i = 0; i < NDIRECT; i++){
80101d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d22:	eb 44                	jmp    80101d68 <itrunc+0x53>
    if(ip->addrs[i]){
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d2a:	83 c2 04             	add    $0x4,%edx
80101d2d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d31:	85 c0                	test   %eax,%eax
80101d33:	74 2f                	je     80101d64 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3b:	83 c2 04             	add    $0x4,%edx
80101d3e:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4b:	89 04 24             	mov    %eax,(%esp)
80101d4e:	e8 76 f7 ff ff       	call   801014c9 <bfree>
      ip->addrs[i] = 0;
80101d53:	8b 45 08             	mov    0x8(%ebp),%eax
80101d56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d59:	83 c2 04             	add    $0x4,%edx
80101d5c:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d63:	00 
{
  int i, j;
  struct buf *bp;
  uint *a,*b;

  for(i = 0; i < NDIRECT; i++){
80101d64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d68:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d6c:	7e b6                	jle    80101d24 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d74:	85 c0                	test   %eax,%eax
80101d76:	0f 84 9b 00 00 00    	je     80101e17 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7f:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d82:	8b 45 08             	mov    0x8(%ebp),%eax
80101d85:	8b 00                	mov    (%eax),%eax
80101d87:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d8b:	89 04 24             	mov    %eax,(%esp)
80101d8e:	e8 13 e4 ff ff       	call   801001a6 <bread>
80101d93:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d99:	83 c0 18             	add    $0x18,%eax
80101d9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101da6:	eb 3b                	jmp    80101de3 <itrunc+0xce>
      if(a[j])
80101da8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101db5:	01 d0                	add    %edx,%eax
80101db7:	8b 00                	mov    (%eax),%eax
80101db9:	85 c0                	test   %eax,%eax
80101dbb:	74 22                	je     80101ddf <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dca:	01 d0                	add    %edx,%eax
80101dcc:	8b 10                	mov    (%eax),%edx
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	8b 00                	mov    (%eax),%eax
80101dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dd7:	89 04 24             	mov    %eax,(%esp)
80101dda:	e8 ea f6 ff ff       	call   801014c9 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ddf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de6:	83 f8 7f             	cmp    $0x7f,%eax
80101de9:	76 bd                	jbe    80101da8 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dee:	89 04 24             	mov    %eax,(%esp)
80101df1:	e8 21 e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 50 4c             	mov    0x4c(%eax),%edx
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 00                	mov    (%eax),%eax
80101e01:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e05:	89 04 24             	mov    %eax,(%esp)
80101e08:	e8 bc f6 ff ff       	call   801014c9 <bfree>
    ip->addrs[NDIRECT] = 0;
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  //task1.a - doubly-indirect
  if(ip->addrs[NDIRECT+1]){
80101e17:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1a:	8b 40 50             	mov    0x50(%eax),%eax
80101e1d:	85 c0                	test   %eax,%eax
80101e1f:	0f 84 20 01 00 00    	je     80101f45 <itrunc+0x230>
     bp = bread(ip->dev, ip->addrs[NDIRECT+1]);
80101e25:	8b 45 08             	mov    0x8(%ebp),%eax
80101e28:	8b 50 50             	mov    0x50(%eax),%edx
80101e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2e:	8b 00                	mov    (%eax),%eax
80101e30:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e34:	89 04 24             	mov    %eax,(%esp)
80101e37:	e8 6a e3 ff ff       	call   801001a6 <bread>
80101e3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
     a = (uint*)bp->data;
80101e3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e42:	83 c0 18             	add    $0x18,%eax
80101e45:	89 45 e8             	mov    %eax,-0x18(%ebp)
     for(j = 0; j < NINDIRECT; j++){
80101e48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e4f:	e9 b9 00 00 00       	jmp    80101f0d <itrunc+0x1f8>
       if(a[j]) {
80101e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e57:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e61:	01 d0                	add    %edx,%eax
80101e63:	8b 00                	mov    (%eax),%eax
80101e65:	85 c0                	test   %eax,%eax
80101e67:	0f 84 9c 00 00 00    	je     80101f09 <itrunc+0x1f4>
    	   bp = bread(ip->dev, a[j]);
80101e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e7a:	01 d0                	add    %edx,%eax
80101e7c:	8b 10                	mov    (%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e87:	89 04 24             	mov    %eax,(%esp)
80101e8a:	e8 17 e3 ff ff       	call   801001a6 <bread>
80101e8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    	   b = (uint*)bp->data;
80101e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e95:	83 c0 18             	add    $0x18,%eax
80101e98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	   for(i = 0; i < NINDIRECT; i++) {
80101e9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea2:	eb 3b                	jmp    80101edf <itrunc+0x1ca>
    		   if (b[i])
80101ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101eb1:	01 d0                	add    %edx,%eax
80101eb3:	8b 00                	mov    (%eax),%eax
80101eb5:	85 c0                	test   %eax,%eax
80101eb7:	74 22                	je     80101edb <itrunc+0x1c6>
    			   bfree(ip->dev, b[i]);
80101eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ec6:	01 d0                	add    %edx,%eax
80101ec8:	8b 10                	mov    (%eax),%edx
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	8b 00                	mov    (%eax),%eax
80101ecf:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed3:	89 04 24             	mov    %eax,(%esp)
80101ed6:	e8 ee f5 ff ff       	call   801014c9 <bfree>
     a = (uint*)bp->data;
     for(j = 0; j < NINDIRECT; j++){
       if(a[j]) {
    	   bp = bread(ip->dev, a[j]);
    	   b = (uint*)bp->data;
    	   for(i = 0; i < NINDIRECT; i++) {
80101edb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee2:	83 f8 7f             	cmp    $0x7f,%eax
80101ee5:	76 bd                	jbe    80101ea4 <itrunc+0x18f>
    		   if (b[i])
    			   bfree(ip->dev, b[i]);
    	   }
    	   bfree(ip->dev, a[j]);
80101ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ef4:	01 d0                	add    %edx,%eax
80101ef6:	8b 10                	mov    (%eax),%edx
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	8b 00                	mov    (%eax),%eax
80101efd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f01:	89 04 24             	mov    %eax,(%esp)
80101f04:	e8 c0 f5 ff ff       	call   801014c9 <bfree>

  //task1.a - doubly-indirect
  if(ip->addrs[NDIRECT+1]){
     bp = bread(ip->dev, ip->addrs[NDIRECT+1]);
     a = (uint*)bp->data;
     for(j = 0; j < NINDIRECT; j++){
80101f09:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f10:	83 f8 7f             	cmp    $0x7f,%eax
80101f13:	0f 86 3b ff ff ff    	jbe    80101e54 <itrunc+0x13f>
    			   bfree(ip->dev, b[i]);
    	   }
    	   bfree(ip->dev, a[j]);
       }
     }
     brelse(bp);
80101f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f1c:	89 04 24             	mov    %eax,(%esp)
80101f1f:	e8 f3 e2 ff ff       	call   80100217 <brelse>
     bfree(ip->dev, ip->addrs[NDIRECT]);
80101f24:	8b 45 08             	mov    0x8(%ebp),%eax
80101f27:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2d:	8b 00                	mov    (%eax),%eax
80101f2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f33:	89 04 24             	mov    %eax,(%esp)
80101f36:	e8 8e f5 ff ff       	call   801014c9 <bfree>
     ip->addrs[NDIRECT+1] = 0;
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
   }

  ip->size = 0;
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	89 04 24             	mov    %eax,(%esp)
80101f55:	e8 38 f7 ff ff       	call   80101692 <iupdate>
}
80101f5a:	c9                   	leave  
80101f5b:	c3                   	ret    

80101f5c <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f5c:	55                   	push   %ebp
80101f5d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f62:	8b 00                	mov    (%eax),%eax
80101f64:	89 c2                	mov    %eax,%edx
80101f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f69:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6f:	8b 50 04             	mov    0x4(%eax),%edx
80101f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f75:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f82:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f85:	8b 45 08             	mov    0x8(%ebp),%eax
80101f88:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f8f:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	8b 50 18             	mov    0x18(%eax),%edx
80101f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f9c:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f9f:	5d                   	pop    %ebp
80101fa0:	c3                   	ret    

80101fa1 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fa1:	55                   	push   %ebp
80101fa2:	89 e5                	mov    %esp,%ebp
80101fa4:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fae:	66 83 f8 03          	cmp    $0x3,%ax
80101fb2:	75 60                	jne    80102014 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fbb:	66 85 c0             	test   %ax,%ax
80101fbe:	78 20                	js     80101fe0 <readi+0x3f>
80101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc7:	66 83 f8 09          	cmp    $0x9,%ax
80101fcb:	7f 13                	jg     80101fe0 <readi+0x3f>
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd4:	98                   	cwtl   
80101fd5:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101fdc:	85 c0                	test   %eax,%eax
80101fde:	75 0a                	jne    80101fea <readi+0x49>
      return -1;
80101fe0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fe5:	e9 19 01 00 00       	jmp    80102103 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101fea:	8b 45 08             	mov    0x8(%ebp),%eax
80101fed:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ff1:	98                   	cwtl   
80101ff2:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101ff9:	8b 55 14             	mov    0x14(%ebp),%edx
80101ffc:	89 54 24 08          	mov    %edx,0x8(%esp)
80102000:	8b 55 0c             	mov    0xc(%ebp),%edx
80102003:	89 54 24 04          	mov    %edx,0x4(%esp)
80102007:	8b 55 08             	mov    0x8(%ebp),%edx
8010200a:	89 14 24             	mov    %edx,(%esp)
8010200d:	ff d0                	call   *%eax
8010200f:	e9 ef 00 00 00       	jmp    80102103 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80102014:	8b 45 08             	mov    0x8(%ebp),%eax
80102017:	8b 40 18             	mov    0x18(%eax),%eax
8010201a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010201d:	72 0d                	jb     8010202c <readi+0x8b>
8010201f:	8b 45 14             	mov    0x14(%ebp),%eax
80102022:	8b 55 10             	mov    0x10(%ebp),%edx
80102025:	01 d0                	add    %edx,%eax
80102027:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202a:	73 0a                	jae    80102036 <readi+0x95>
    return -1;
8010202c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102031:	e9 cd 00 00 00       	jmp    80102103 <readi+0x162>
  if(off + n > ip->size)
80102036:	8b 45 14             	mov    0x14(%ebp),%eax
80102039:	8b 55 10             	mov    0x10(%ebp),%edx
8010203c:	01 c2                	add    %eax,%edx
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	8b 40 18             	mov    0x18(%eax),%eax
80102044:	39 c2                	cmp    %eax,%edx
80102046:	76 0c                	jbe    80102054 <readi+0xb3>
    n = ip->size - off;
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	8b 40 18             	mov    0x18(%eax),%eax
8010204e:	2b 45 10             	sub    0x10(%ebp),%eax
80102051:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102054:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010205b:	e9 94 00 00 00       	jmp    801020f4 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102060:	8b 45 10             	mov    0x10(%ebp),%eax
80102063:	c1 e8 09             	shr    $0x9,%eax
80102066:	89 44 24 04          	mov    %eax,0x4(%esp)
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	89 04 24             	mov    %eax,(%esp)
80102070:	e8 7b fa ff ff       	call   80101af0 <bmap>
80102075:	8b 55 08             	mov    0x8(%ebp),%edx
80102078:	8b 12                	mov    (%edx),%edx
8010207a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010207e:	89 14 24             	mov    %edx,(%esp)
80102081:	e8 20 e1 ff ff       	call   801001a6 <bread>
80102086:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102089:	8b 45 10             	mov    0x10(%ebp),%eax
8010208c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102091:	89 c2                	mov    %eax,%edx
80102093:	b8 00 02 00 00       	mov    $0x200,%eax
80102098:	29 d0                	sub    %edx,%eax
8010209a:	89 c2                	mov    %eax,%edx
8010209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010209f:	8b 4d 14             	mov    0x14(%ebp),%ecx
801020a2:	29 c1                	sub    %eax,%ecx
801020a4:	89 c8                	mov    %ecx,%eax
801020a6:	39 c2                	cmp    %eax,%edx
801020a8:	0f 46 c2             	cmovbe %edx,%eax
801020ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020ae:	8b 45 10             	mov    0x10(%ebp),%eax
801020b1:	25 ff 01 00 00       	and    $0x1ff,%eax
801020b6:	8d 50 10             	lea    0x10(%eax),%edx
801020b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020bc:	01 d0                	add    %edx,%eax
801020be:	8d 50 08             	lea    0x8(%eax),%edx
801020c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801020c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801020cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801020cf:	89 04 24             	mov    %eax,(%esp)
801020d2:	e8 b5 2f 00 00       	call   8010508c <memmove>
    brelse(bp);
801020d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020da:	89 04 24             	mov    %eax,(%esp)
801020dd:	e8 35 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e5:	01 45 f4             	add    %eax,-0xc(%ebp)
801020e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020eb:	01 45 10             	add    %eax,0x10(%ebp)
801020ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f1:	01 45 0c             	add    %eax,0xc(%ebp)
801020f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020f7:	3b 45 14             	cmp    0x14(%ebp),%eax
801020fa:	0f 82 60 ff ff ff    	jb     80102060 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102100:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102103:	c9                   	leave  
80102104:	c3                   	ret    

80102105 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102105:	55                   	push   %ebp
80102106:	89 e5                	mov    %esp,%ebp
80102108:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010210b:	8b 45 08             	mov    0x8(%ebp),%eax
8010210e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102112:	66 83 f8 03          	cmp    $0x3,%ax
80102116:	75 60                	jne    80102178 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010211f:	66 85 c0             	test   %ax,%ax
80102122:	78 20                	js     80102144 <writei+0x3f>
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010212b:	66 83 f8 09          	cmp    $0x9,%ax
8010212f:	7f 13                	jg     80102144 <writei+0x3f>
80102131:	8b 45 08             	mov    0x8(%ebp),%eax
80102134:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102138:	98                   	cwtl   
80102139:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80102140:	85 c0                	test   %eax,%eax
80102142:	75 0a                	jne    8010214e <writei+0x49>
      return -1;
80102144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102149:	e9 44 01 00 00       	jmp    80102292 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
8010214e:	8b 45 08             	mov    0x8(%ebp),%eax
80102151:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102155:	98                   	cwtl   
80102156:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
8010215d:	8b 55 14             	mov    0x14(%ebp),%edx
80102160:	89 54 24 08          	mov    %edx,0x8(%esp)
80102164:	8b 55 0c             	mov    0xc(%ebp),%edx
80102167:	89 54 24 04          	mov    %edx,0x4(%esp)
8010216b:	8b 55 08             	mov    0x8(%ebp),%edx
8010216e:	89 14 24             	mov    %edx,(%esp)
80102171:	ff d0                	call   *%eax
80102173:	e9 1a 01 00 00       	jmp    80102292 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80102178:	8b 45 08             	mov    0x8(%ebp),%eax
8010217b:	8b 40 18             	mov    0x18(%eax),%eax
8010217e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102181:	72 0d                	jb     80102190 <writei+0x8b>
80102183:	8b 45 14             	mov    0x14(%ebp),%eax
80102186:	8b 55 10             	mov    0x10(%ebp),%edx
80102189:	01 d0                	add    %edx,%eax
8010218b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010218e:	73 0a                	jae    8010219a <writei+0x95>
    return -1;
80102190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102195:	e9 f8 00 00 00       	jmp    80102292 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010219a:	8b 45 14             	mov    0x14(%ebp),%eax
8010219d:	8b 55 10             	mov    0x10(%ebp),%edx
801021a0:	01 d0                	add    %edx,%eax
801021a2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021a7:	76 0a                	jbe    801021b3 <writei+0xae>
    return -1;
801021a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ae:	e9 df 00 00 00       	jmp    80102292 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ba:	e9 9f 00 00 00       	jmp    8010225e <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021bf:	8b 45 10             	mov    0x10(%ebp),%eax
801021c2:	c1 e8 09             	shr    $0x9,%eax
801021c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c9:	8b 45 08             	mov    0x8(%ebp),%eax
801021cc:	89 04 24             	mov    %eax,(%esp)
801021cf:	e8 1c f9 ff ff       	call   80101af0 <bmap>
801021d4:	8b 55 08             	mov    0x8(%ebp),%edx
801021d7:	8b 12                	mov    (%edx),%edx
801021d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801021dd:	89 14 24             	mov    %edx,(%esp)
801021e0:	e8 c1 df ff ff       	call   801001a6 <bread>
801021e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021e8:	8b 45 10             	mov    0x10(%ebp),%eax
801021eb:	25 ff 01 00 00       	and    $0x1ff,%eax
801021f0:	89 c2                	mov    %eax,%edx
801021f2:	b8 00 02 00 00       	mov    $0x200,%eax
801021f7:	29 d0                	sub    %edx,%eax
801021f9:	89 c2                	mov    %eax,%edx
801021fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021fe:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102201:	29 c1                	sub    %eax,%ecx
80102203:	89 c8                	mov    %ecx,%eax
80102205:	39 c2                	cmp    %eax,%edx
80102207:	0f 46 c2             	cmovbe %edx,%eax
8010220a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010220d:	8b 45 10             	mov    0x10(%ebp),%eax
80102210:	25 ff 01 00 00       	and    $0x1ff,%eax
80102215:	8d 50 10             	lea    0x10(%eax),%edx
80102218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010221b:	01 d0                	add    %edx,%eax
8010221d:	8d 50 08             	lea    0x8(%eax),%edx
80102220:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102223:	89 44 24 08          	mov    %eax,0x8(%esp)
80102227:	8b 45 0c             	mov    0xc(%ebp),%eax
8010222a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010222e:	89 14 24             	mov    %edx,(%esp)
80102231:	e8 56 2e 00 00       	call   8010508c <memmove>
    log_write(bp);
80102236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102239:	89 04 24             	mov    %eax,(%esp)
8010223c:	e8 7e 12 00 00       	call   801034bf <log_write>
    brelse(bp);
80102241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102244:	89 04 24             	mov    %eax,(%esp)
80102247:	e8 cb df ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010224c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010224f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102252:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102255:	01 45 10             	add    %eax,0x10(%ebp)
80102258:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010225b:	01 45 0c             	add    %eax,0xc(%ebp)
8010225e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102261:	3b 45 14             	cmp    0x14(%ebp),%eax
80102264:	0f 82 55 ff ff ff    	jb     801021bf <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010226a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010226e:	74 1f                	je     8010228f <writei+0x18a>
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 18             	mov    0x18(%eax),%eax
80102276:	3b 45 10             	cmp    0x10(%ebp),%eax
80102279:	73 14                	jae    8010228f <writei+0x18a>
    ip->size = off;
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	8b 55 10             	mov    0x10(%ebp),%edx
80102281:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102284:	8b 45 08             	mov    0x8(%ebp),%eax
80102287:	89 04 24             	mov    %eax,(%esp)
8010228a:	e8 03 f4 ff ff       	call   80101692 <iupdate>
  }
  return n;
8010228f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102292:	c9                   	leave  
80102293:	c3                   	ret    

80102294 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102294:	55                   	push   %ebp
80102295:	89 e5                	mov    %esp,%ebp
80102297:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010229a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a1:	00 
801022a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a9:	8b 45 08             	mov    0x8(%ebp),%eax
801022ac:	89 04 24             	mov    %eax,(%esp)
801022af:	e8 7b 2e 00 00       	call   8010512f <strncmp>
}
801022b4:	c9                   	leave  
801022b5:	c3                   	ret    

801022b6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022b6:	55                   	push   %ebp
801022b7:	89 e5                	mov    %esp,%ebp
801022b9:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022bc:	8b 45 08             	mov    0x8(%ebp),%eax
801022bf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801022c3:	66 83 f8 01          	cmp    $0x1,%ax
801022c7:	74 0c                	je     801022d5 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801022c9:	c7 04 24 65 84 10 80 	movl   $0x80108465,(%esp)
801022d0:	e8 65 e2 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022dc:	e9 88 00 00 00       	jmp    80102369 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022e8:	00 
801022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801022f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
801022fa:	89 04 24             	mov    %eax,(%esp)
801022fd:	e8 9f fc ff ff       	call   80101fa1 <readi>
80102302:	83 f8 10             	cmp    $0x10,%eax
80102305:	74 0c                	je     80102313 <dirlookup+0x5d>
      panic("dirlink read");
80102307:	c7 04 24 77 84 10 80 	movl   $0x80108477,(%esp)
8010230e:	e8 27 e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102313:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102317:	66 85 c0             	test   %ax,%ax
8010231a:	75 02                	jne    8010231e <dirlookup+0x68>
      continue;
8010231c:	eb 47                	jmp    80102365 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
8010231e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102321:	83 c0 02             	add    $0x2,%eax
80102324:	89 44 24 04          	mov    %eax,0x4(%esp)
80102328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232b:	89 04 24             	mov    %eax,(%esp)
8010232e:	e8 61 ff ff ff       	call   80102294 <namecmp>
80102333:	85 c0                	test   %eax,%eax
80102335:	75 2e                	jne    80102365 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
80102337:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010233b:	74 08                	je     80102345 <dirlookup+0x8f>
        *poff = off;
8010233d:	8b 45 10             	mov    0x10(%ebp),%eax
80102340:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102343:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102345:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102349:	0f b7 c0             	movzwl %ax,%eax
8010234c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010234f:	8b 45 08             	mov    0x8(%ebp),%eax
80102352:	8b 00                	mov    (%eax),%eax
80102354:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102357:	89 54 24 04          	mov    %edx,0x4(%esp)
8010235b:	89 04 24             	mov    %eax,(%esp)
8010235e:	e8 e7 f3 ff ff       	call   8010174a <iget>
80102363:	eb 18                	jmp    8010237d <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102365:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102369:	8b 45 08             	mov    0x8(%ebp),%eax
8010236c:	8b 40 18             	mov    0x18(%eax),%eax
8010236f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102372:	0f 87 69 ff ff ff    	ja     801022e1 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102378:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010237d:	c9                   	leave  
8010237e:	c3                   	ret    

8010237f <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010237f:	55                   	push   %ebp
80102380:	89 e5                	mov    %esp,%ebp
80102382:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102385:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238c:	00 
8010238d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102390:	89 44 24 04          	mov    %eax,0x4(%esp)
80102394:	8b 45 08             	mov    0x8(%ebp),%eax
80102397:	89 04 24             	mov    %eax,(%esp)
8010239a:	e8 17 ff ff ff       	call   801022b6 <dirlookup>
8010239f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a6:	74 15                	je     801023bd <dirlink+0x3e>
    iput(ip);
801023a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ab:	89 04 24             	mov    %eax,(%esp)
801023ae:	e8 4e f6 ff ff       	call   80101a01 <iput>
    return -1;
801023b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023b8:	e9 b7 00 00 00       	jmp    80102474 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023c4:	eb 46                	jmp    8010240c <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023d0:	00 
801023d1:	89 44 24 08          	mov    %eax,0x8(%esp)
801023d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023dc:	8b 45 08             	mov    0x8(%ebp),%eax
801023df:	89 04 24             	mov    %eax,(%esp)
801023e2:	e8 ba fb ff ff       	call   80101fa1 <readi>
801023e7:	83 f8 10             	cmp    $0x10,%eax
801023ea:	74 0c                	je     801023f8 <dirlink+0x79>
      panic("dirlink read");
801023ec:	c7 04 24 77 84 10 80 	movl   $0x80108477,(%esp)
801023f3:	e8 42 e1 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801023f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023fc:	66 85 c0             	test   %ax,%ax
801023ff:	75 02                	jne    80102403 <dirlink+0x84>
      break;
80102401:	eb 16                	jmp    80102419 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102406:	83 c0 10             	add    $0x10,%eax
80102409:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010240c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010240f:	8b 45 08             	mov    0x8(%ebp),%eax
80102412:	8b 40 18             	mov    0x18(%eax),%eax
80102415:	39 c2                	cmp    %eax,%edx
80102417:	72 ad                	jb     801023c6 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102419:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102420:	00 
80102421:	8b 45 0c             	mov    0xc(%ebp),%eax
80102424:	89 44 24 04          	mov    %eax,0x4(%esp)
80102428:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010242b:	83 c0 02             	add    $0x2,%eax
8010242e:	89 04 24             	mov    %eax,(%esp)
80102431:	e8 4f 2d 00 00       	call   80105185 <strncpy>
  de.inum = inum;
80102436:	8b 45 10             	mov    0x10(%ebp),%eax
80102439:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010243d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102440:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102447:	00 
80102448:	89 44 24 08          	mov    %eax,0x8(%esp)
8010244c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010244f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	89 04 24             	mov    %eax,(%esp)
80102459:	e8 a7 fc ff ff       	call   80102105 <writei>
8010245e:	83 f8 10             	cmp    $0x10,%eax
80102461:	74 0c                	je     8010246f <dirlink+0xf0>
    panic("dirlink");
80102463:	c7 04 24 84 84 10 80 	movl   $0x80108484,(%esp)
8010246a:	e8 cb e0 ff ff       	call   8010053a <panic>
  
  return 0;
8010246f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102474:	c9                   	leave  
80102475:	c3                   	ret    

80102476 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102476:	55                   	push   %ebp
80102477:	89 e5                	mov    %esp,%ebp
80102479:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010247c:	eb 04                	jmp    80102482 <skipelem+0xc>
    path++;
8010247e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	3c 2f                	cmp    $0x2f,%al
8010248a:	74 f2                	je     8010247e <skipelem+0x8>
    path++;
  if(*path == 0)
8010248c:	8b 45 08             	mov    0x8(%ebp),%eax
8010248f:	0f b6 00             	movzbl (%eax),%eax
80102492:	84 c0                	test   %al,%al
80102494:	75 0a                	jne    801024a0 <skipelem+0x2a>
    return 0;
80102496:	b8 00 00 00 00       	mov    $0x0,%eax
8010249b:	e9 86 00 00 00       	jmp    80102526 <skipelem+0xb0>
  s = path;
801024a0:	8b 45 08             	mov    0x8(%ebp),%eax
801024a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024a6:	eb 04                	jmp    801024ac <skipelem+0x36>
    path++;
801024a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801024ac:	8b 45 08             	mov    0x8(%ebp),%eax
801024af:	0f b6 00             	movzbl (%eax),%eax
801024b2:	3c 2f                	cmp    $0x2f,%al
801024b4:	74 0a                	je     801024c0 <skipelem+0x4a>
801024b6:	8b 45 08             	mov    0x8(%ebp),%eax
801024b9:	0f b6 00             	movzbl (%eax),%eax
801024bc:	84 c0                	test   %al,%al
801024be:	75 e8                	jne    801024a8 <skipelem+0x32>
    path++;
  len = path - s;
801024c0:	8b 55 08             	mov    0x8(%ebp),%edx
801024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c6:	29 c2                	sub    %eax,%edx
801024c8:	89 d0                	mov    %edx,%eax
801024ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024cd:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024d1:	7e 1c                	jle    801024ef <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801024d3:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024da:	00 
801024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024de:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024e5:	89 04 24             	mov    %eax,(%esp)
801024e8:	e8 9f 2b 00 00       	call   8010508c <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024ed:	eb 2a                	jmp    80102519 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801024ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f2:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102500:	89 04 24             	mov    %eax,(%esp)
80102503:	e8 84 2b 00 00       	call   8010508c <memmove>
    name[len] = 0;
80102508:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010250b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010250e:	01 d0                	add    %edx,%eax
80102510:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102513:	eb 04                	jmp    80102519 <skipelem+0xa3>
    path++;
80102515:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102519:	8b 45 08             	mov    0x8(%ebp),%eax
8010251c:	0f b6 00             	movzbl (%eax),%eax
8010251f:	3c 2f                	cmp    $0x2f,%al
80102521:	74 f2                	je     80102515 <skipelem+0x9f>
    path++;
  return path;
80102523:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010252e:	8b 45 08             	mov    0x8(%ebp),%eax
80102531:	0f b6 00             	movzbl (%eax),%eax
80102534:	3c 2f                	cmp    $0x2f,%al
80102536:	75 1c                	jne    80102554 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102538:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010253f:	00 
80102540:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102547:	e8 fe f1 ff ff       	call   8010174a <iget>
8010254c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010254f:	e9 af 00 00 00       	jmp    80102603 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102554:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010255a:	8b 40 68             	mov    0x68(%eax),%eax
8010255d:	89 04 24             	mov    %eax,(%esp)
80102560:	e8 b7 f2 ff ff       	call   8010181c <idup>
80102565:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102568:	e9 96 00 00 00       	jmp    80102603 <namex+0xdb>
    ilock(ip);
8010256d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102570:	89 04 24             	mov    %eax,(%esp)
80102573:	e8 d6 f2 ff ff       	call   8010184e <ilock>
    if(ip->type != T_DIR){
80102578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010257f:	66 83 f8 01          	cmp    $0x1,%ax
80102583:	74 15                	je     8010259a <namex+0x72>
      iunlockput(ip);
80102585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102588:	89 04 24             	mov    %eax,(%esp)
8010258b:	e8 42 f5 ff ff       	call   80101ad2 <iunlockput>
      return 0;
80102590:	b8 00 00 00 00       	mov    $0x0,%eax
80102595:	e9 a3 00 00 00       	jmp    8010263d <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010259a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010259e:	74 1d                	je     801025bd <namex+0x95>
801025a0:	8b 45 08             	mov    0x8(%ebp),%eax
801025a3:	0f b6 00             	movzbl (%eax),%eax
801025a6:	84 c0                	test   %al,%al
801025a8:	75 13                	jne    801025bd <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801025aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ad:	89 04 24             	mov    %eax,(%esp)
801025b0:	e8 e7 f3 ff ff       	call   8010199c <iunlock>
      return ip;
801025b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b8:	e9 80 00 00 00       	jmp    8010263d <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801025c4:	00 
801025c5:	8b 45 10             	mov    0x10(%ebp),%eax
801025c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801025cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cf:	89 04 24             	mov    %eax,(%esp)
801025d2:	e8 df fc ff ff       	call   801022b6 <dirlookup>
801025d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025de:	75 12                	jne    801025f2 <namex+0xca>
      iunlockput(ip);
801025e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e3:	89 04 24             	mov    %eax,(%esp)
801025e6:	e8 e7 f4 ff ff       	call   80101ad2 <iunlockput>
      return 0;
801025eb:	b8 00 00 00 00       	mov    $0x0,%eax
801025f0:	eb 4b                	jmp    8010263d <namex+0x115>
    }
    iunlockput(ip);
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f5:	89 04 24             	mov    %eax,(%esp)
801025f8:	e8 d5 f4 ff ff       	call   80101ad2 <iunlockput>
    ip = next;
801025fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102600:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102603:	8b 45 10             	mov    0x10(%ebp),%eax
80102606:	89 44 24 04          	mov    %eax,0x4(%esp)
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
8010260d:	89 04 24             	mov    %eax,(%esp)
80102610:	e8 61 fe ff ff       	call   80102476 <skipelem>
80102615:	89 45 08             	mov    %eax,0x8(%ebp)
80102618:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010261c:	0f 85 4b ff ff ff    	jne    8010256d <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102622:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102626:	74 12                	je     8010263a <namex+0x112>
    iput(ip);
80102628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262b:	89 04 24             	mov    %eax,(%esp)
8010262e:	e8 ce f3 ff ff       	call   80101a01 <iput>
    return 0;
80102633:	b8 00 00 00 00       	mov    $0x0,%eax
80102638:	eb 03                	jmp    8010263d <namex+0x115>
  }
  return ip;
8010263a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    

8010263f <namei>:

struct inode*
namei(char *path)
{
8010263f:	55                   	push   %ebp
80102640:	89 e5                	mov    %esp,%ebp
80102642:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102645:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102648:	89 44 24 08          	mov    %eax,0x8(%esp)
8010264c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102653:	00 
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	89 04 24             	mov    %eax,(%esp)
8010265a:	e8 c9 fe ff ff       	call   80102528 <namex>
}
8010265f:	c9                   	leave  
80102660:	c3                   	ret    

80102661 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102667:	8b 45 0c             	mov    0xc(%ebp),%eax
8010266a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010266e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102675:	00 
80102676:	8b 45 08             	mov    0x8(%ebp),%eax
80102679:	89 04 24             	mov    %eax,(%esp)
8010267c:	e8 a7 fe ff ff       	call   80102528 <namex>
}
80102681:	c9                   	leave  
80102682:	c3                   	ret    

80102683 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102683:	55                   	push   %ebp
80102684:	89 e5                	mov    %esp,%ebp
80102686:	83 ec 14             	sub    $0x14,%esp
80102689:	8b 45 08             	mov    0x8(%ebp),%eax
8010268c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102690:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102694:	89 c2                	mov    %eax,%edx
80102696:	ec                   	in     (%dx),%al
80102697:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010269a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010269e:	c9                   	leave  
8010269f:	c3                   	ret    

801026a0 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801026a0:	55                   	push   %ebp
801026a1:	89 e5                	mov    %esp,%ebp
801026a3:	57                   	push   %edi
801026a4:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026a5:	8b 55 08             	mov    0x8(%ebp),%edx
801026a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026ab:	8b 45 10             	mov    0x10(%ebp),%eax
801026ae:	89 cb                	mov    %ecx,%ebx
801026b0:	89 df                	mov    %ebx,%edi
801026b2:	89 c1                	mov    %eax,%ecx
801026b4:	fc                   	cld    
801026b5:	f3 6d                	rep insl (%dx),%es:(%edi)
801026b7:	89 c8                	mov    %ecx,%eax
801026b9:	89 fb                	mov    %edi,%ebx
801026bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026be:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801026c1:	5b                   	pop    %ebx
801026c2:	5f                   	pop    %edi
801026c3:	5d                   	pop    %ebp
801026c4:	c3                   	ret    

801026c5 <outb>:

static inline void
outb(ushort port, uchar data)
{
801026c5:	55                   	push   %ebp
801026c6:	89 e5                	mov    %esp,%ebp
801026c8:	83 ec 08             	sub    $0x8,%esp
801026cb:	8b 55 08             	mov    0x8(%ebp),%edx
801026ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801026d1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801026d5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801026d8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801026dc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801026e0:	ee                   	out    %al,(%dx)
}
801026e1:	c9                   	leave  
801026e2:	c3                   	ret    

801026e3 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801026e3:	55                   	push   %ebp
801026e4:	89 e5                	mov    %esp,%ebp
801026e6:	56                   	push   %esi
801026e7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026e8:	8b 55 08             	mov    0x8(%ebp),%edx
801026eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026ee:	8b 45 10             	mov    0x10(%ebp),%eax
801026f1:	89 cb                	mov    %ecx,%ebx
801026f3:	89 de                	mov    %ebx,%esi
801026f5:	89 c1                	mov    %eax,%ecx
801026f7:	fc                   	cld    
801026f8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026fa:	89 c8                	mov    %ecx,%eax
801026fc:	89 f3                	mov    %esi,%ebx
801026fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102701:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102704:	5b                   	pop    %ebx
80102705:	5e                   	pop    %esi
80102706:	5d                   	pop    %ebp
80102707:	c3                   	ret    

80102708 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102708:	55                   	push   %ebp
80102709:	89 e5                	mov    %esp,%ebp
8010270b:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010270e:	90                   	nop
8010270f:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102716:	e8 68 ff ff ff       	call   80102683 <inb>
8010271b:	0f b6 c0             	movzbl %al,%eax
8010271e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102721:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102724:	25 c0 00 00 00       	and    $0xc0,%eax
80102729:	83 f8 40             	cmp    $0x40,%eax
8010272c:	75 e1                	jne    8010270f <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010272e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102732:	74 11                	je     80102745 <idewait+0x3d>
80102734:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102737:	83 e0 21             	and    $0x21,%eax
8010273a:	85 c0                	test   %eax,%eax
8010273c:	74 07                	je     80102745 <idewait+0x3d>
    return -1;
8010273e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102743:	eb 05                	jmp    8010274a <idewait+0x42>
  return 0;
80102745:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010274a:	c9                   	leave  
8010274b:	c3                   	ret    

8010274c <ideinit>:

void
ideinit(void)
{
8010274c:	55                   	push   %ebp
8010274d:	89 e5                	mov    %esp,%ebp
8010274f:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102752:	c7 44 24 04 8c 84 10 	movl   $0x8010848c,0x4(%esp)
80102759:	80 
8010275a:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102761:	e8 e2 25 00 00       	call   80104d48 <initlock>
  picenable(IRQ_IDE);
80102766:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010276d:	e8 39 15 00 00       	call   80103cab <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102772:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80102777:	83 e8 01             	sub    $0x1,%eax
8010277a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010277e:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102785:	e8 0c 04 00 00       	call   80102b96 <ioapicenable>
  idewait(0);
8010278a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102791:	e8 72 ff ff ff       	call   80102708 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102796:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010279d:	00 
8010279e:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027a5:	e8 1b ff ff ff       	call   801026c5 <outb>
  for(i=0; i<1000; i++){
801027aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027b1:	eb 20                	jmp    801027d3 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801027b3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027ba:	e8 c4 fe ff ff       	call   80102683 <inb>
801027bf:	84 c0                	test   %al,%al
801027c1:	74 0c                	je     801027cf <ideinit+0x83>
      havedisk1 = 1;
801027c3:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801027ca:	00 00 00 
      break;
801027cd:	eb 0d                	jmp    801027dc <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801027cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801027d3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801027da:	7e d7                	jle    801027b3 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801027dc:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801027e3:	00 
801027e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027eb:	e8 d5 fe ff ff       	call   801026c5 <outb>
}
801027f0:	c9                   	leave  
801027f1:	c3                   	ret    

801027f2 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027f2:	55                   	push   %ebp
801027f3:	89 e5                	mov    %esp,%ebp
801027f5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027fc:	75 0c                	jne    8010280a <idestart+0x18>
    panic("idestart");
801027fe:	c7 04 24 90 84 10 80 	movl   $0x80108490,(%esp)
80102805:	e8 30 dd ff ff       	call   8010053a <panic>

  idewait(0);
8010280a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102811:	e8 f2 fe ff ff       	call   80102708 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102816:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010281d:	00 
8010281e:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102825:	e8 9b fe ff ff       	call   801026c5 <outb>
  outb(0x1f2, 1);  // number of sectors
8010282a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102831:	00 
80102832:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102839:	e8 87 fe ff ff       	call   801026c5 <outb>
  outb(0x1f3, b->sector & 0xff);
8010283e:	8b 45 08             	mov    0x8(%ebp),%eax
80102841:	8b 40 08             	mov    0x8(%eax),%eax
80102844:	0f b6 c0             	movzbl %al,%eax
80102847:	89 44 24 04          	mov    %eax,0x4(%esp)
8010284b:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102852:	e8 6e fe ff ff       	call   801026c5 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102857:	8b 45 08             	mov    0x8(%ebp),%eax
8010285a:	8b 40 08             	mov    0x8(%eax),%eax
8010285d:	c1 e8 08             	shr    $0x8,%eax
80102860:	0f b6 c0             	movzbl %al,%eax
80102863:	89 44 24 04          	mov    %eax,0x4(%esp)
80102867:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010286e:	e8 52 fe ff ff       	call   801026c5 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102873:	8b 45 08             	mov    0x8(%ebp),%eax
80102876:	8b 40 08             	mov    0x8(%eax),%eax
80102879:	c1 e8 10             	shr    $0x10,%eax
8010287c:	0f b6 c0             	movzbl %al,%eax
8010287f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102883:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010288a:	e8 36 fe ff ff       	call   801026c5 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
8010288f:	8b 45 08             	mov    0x8(%ebp),%eax
80102892:	8b 40 04             	mov    0x4(%eax),%eax
80102895:	83 e0 01             	and    $0x1,%eax
80102898:	c1 e0 04             	shl    $0x4,%eax
8010289b:	89 c2                	mov    %eax,%edx
8010289d:	8b 45 08             	mov    0x8(%ebp),%eax
801028a0:	8b 40 08             	mov    0x8(%eax),%eax
801028a3:	c1 e8 18             	shr    $0x18,%eax
801028a6:	83 e0 0f             	and    $0xf,%eax
801028a9:	09 d0                	or     %edx,%eax
801028ab:	83 c8 e0             	or     $0xffffffe0,%eax
801028ae:	0f b6 c0             	movzbl %al,%eax
801028b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801028b5:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028bc:	e8 04 fe ff ff       	call   801026c5 <outb>
  if(b->flags & B_DIRTY){
801028c1:	8b 45 08             	mov    0x8(%ebp),%eax
801028c4:	8b 00                	mov    (%eax),%eax
801028c6:	83 e0 04             	and    $0x4,%eax
801028c9:	85 c0                	test   %eax,%eax
801028cb:	74 34                	je     80102901 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801028cd:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801028d4:	00 
801028d5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028dc:	e8 e4 fd ff ff       	call   801026c5 <outb>
    outsl(0x1f0, b->data, 512/4);
801028e1:	8b 45 08             	mov    0x8(%ebp),%eax
801028e4:	83 c0 18             	add    $0x18,%eax
801028e7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028ee:	00 
801028ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801028f3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028fa:	e8 e4 fd ff ff       	call   801026e3 <outsl>
801028ff:	eb 14                	jmp    80102915 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102901:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102908:	00 
80102909:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102910:	e8 b0 fd ff ff       	call   801026c5 <outb>
  }
}
80102915:	c9                   	leave  
80102916:	c3                   	ret    

80102917 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102917:	55                   	push   %ebp
80102918:	89 e5                	mov    %esp,%ebp
8010291a:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010291d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102924:	e8 40 24 00 00       	call   80104d69 <acquire>
  if((b = idequeue) == 0){
80102929:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010292e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102931:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102935:	75 11                	jne    80102948 <ideintr+0x31>
    release(&idelock);
80102937:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010293e:	e8 88 24 00 00       	call   80104dcb <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102943:	e9 90 00 00 00       	jmp    801029d8 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294b:	8b 40 14             	mov    0x14(%eax),%eax
8010294e:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	8b 00                	mov    (%eax),%eax
80102958:	83 e0 04             	and    $0x4,%eax
8010295b:	85 c0                	test   %eax,%eax
8010295d:	75 2e                	jne    8010298d <ideintr+0x76>
8010295f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102966:	e8 9d fd ff ff       	call   80102708 <idewait>
8010296b:	85 c0                	test   %eax,%eax
8010296d:	78 1e                	js     8010298d <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
8010296f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102972:	83 c0 18             	add    $0x18,%eax
80102975:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010297c:	00 
8010297d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102981:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102988:	e8 13 fd ff ff       	call   801026a0 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102990:	8b 00                	mov    (%eax),%eax
80102992:	83 c8 02             	or     $0x2,%eax
80102995:	89 c2                	mov    %eax,%edx
80102997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299a:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010299c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299f:	8b 00                	mov    (%eax),%eax
801029a1:	83 e0 fb             	and    $0xfffffffb,%eax
801029a4:	89 c2                	mov    %eax,%edx
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ae:	89 04 24             	mov    %eax,(%esp)
801029b1:	e8 c2 21 00 00       	call   80104b78 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801029b6:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029bb:	85 c0                	test   %eax,%eax
801029bd:	74 0d                	je     801029cc <ideintr+0xb5>
    idestart(idequeue);
801029bf:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029c4:	89 04 24             	mov    %eax,(%esp)
801029c7:	e8 26 fe ff ff       	call   801027f2 <idestart>

  release(&idelock);
801029cc:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029d3:	e8 f3 23 00 00       	call   80104dcb <release>
}
801029d8:	c9                   	leave  
801029d9:	c3                   	ret    

801029da <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029da:	55                   	push   %ebp
801029db:	89 e5                	mov    %esp,%ebp
801029dd:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029e0:	8b 45 08             	mov    0x8(%ebp),%eax
801029e3:	8b 00                	mov    (%eax),%eax
801029e5:	83 e0 01             	and    $0x1,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	75 0c                	jne    801029f8 <iderw+0x1e>
    panic("iderw: buf not busy");
801029ec:	c7 04 24 99 84 10 80 	movl   $0x80108499,(%esp)
801029f3:	e8 42 db ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029f8:	8b 45 08             	mov    0x8(%ebp),%eax
801029fb:	8b 00                	mov    (%eax),%eax
801029fd:	83 e0 06             	and    $0x6,%eax
80102a00:	83 f8 02             	cmp    $0x2,%eax
80102a03:	75 0c                	jne    80102a11 <iderw+0x37>
    panic("iderw: nothing to do");
80102a05:	c7 04 24 ad 84 10 80 	movl   $0x801084ad,(%esp)
80102a0c:	e8 29 db ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80102a11:	8b 45 08             	mov    0x8(%ebp),%eax
80102a14:	8b 40 04             	mov    0x4(%eax),%eax
80102a17:	85 c0                	test   %eax,%eax
80102a19:	74 15                	je     80102a30 <iderw+0x56>
80102a1b:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102a20:	85 c0                	test   %eax,%eax
80102a22:	75 0c                	jne    80102a30 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102a24:	c7 04 24 c2 84 10 80 	movl   $0x801084c2,(%esp)
80102a2b:	e8 0a db ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102a30:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a37:	e8 2d 23 00 00       	call   80104d69 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102a46:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102a4d:	eb 0b                	jmp    80102a5a <iderw+0x80>
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	8b 00                	mov    (%eax),%eax
80102a54:	83 c0 14             	add    $0x14,%eax
80102a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5d:	8b 00                	mov    (%eax),%eax
80102a5f:	85 c0                	test   %eax,%eax
80102a61:	75 ec                	jne    80102a4f <iderw+0x75>
    ;
  *pp = b;
80102a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a66:	8b 55 08             	mov    0x8(%ebp),%edx
80102a69:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a6b:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a70:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a73:	75 0d                	jne    80102a82 <iderw+0xa8>
    idestart(b);
80102a75:	8b 45 08             	mov    0x8(%ebp),%eax
80102a78:	89 04 24             	mov    %eax,(%esp)
80102a7b:	e8 72 fd ff ff       	call   801027f2 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a80:	eb 15                	jmp    80102a97 <iderw+0xbd>
80102a82:	eb 13                	jmp    80102a97 <iderw+0xbd>
    sleep(b, &idelock);
80102a84:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102a8b:	80 
80102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8f:	89 04 24             	mov    %eax,(%esp)
80102a92:	e8 08 20 00 00       	call   80104a9f <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a97:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9a:	8b 00                	mov    (%eax),%eax
80102a9c:	83 e0 06             	and    $0x6,%eax
80102a9f:	83 f8 02             	cmp    $0x2,%eax
80102aa2:	75 e0                	jne    80102a84 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102aa4:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102aab:	e8 1b 23 00 00       	call   80104dcb <release>
}
80102ab0:	c9                   	leave  
80102ab1:	c3                   	ret    

80102ab2 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ab2:	55                   	push   %ebp
80102ab3:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ab5:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102aba:	8b 55 08             	mov    0x8(%ebp),%edx
80102abd:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102abf:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102ac4:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ac7:	5d                   	pop    %ebp
80102ac8:	c3                   	ret    

80102ac9 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ac9:	55                   	push   %ebp
80102aca:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102acc:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102ad1:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad4:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ad6:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102adb:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ade:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ae1:	5d                   	pop    %ebp
80102ae2:	c3                   	ret    

80102ae3 <ioapicinit>:

void
ioapicinit(void)
{
80102ae3:	55                   	push   %ebp
80102ae4:	89 e5                	mov    %esp,%ebp
80102ae6:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102ae9:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80102aee:	85 c0                	test   %eax,%eax
80102af0:	75 05                	jne    80102af7 <ioapicinit+0x14>
    return;
80102af2:	e9 9d 00 00 00       	jmp    80102b94 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102af7:	c7 05 fc f8 10 80 00 	movl   $0xfec00000,0x8010f8fc
80102afe:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b01:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b08:	e8 a5 ff ff ff       	call   80102ab2 <ioapicread>
80102b0d:	c1 e8 10             	shr    $0x10,%eax
80102b10:	25 ff 00 00 00       	and    $0xff,%eax
80102b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102b1f:	e8 8e ff ff ff       	call   80102ab2 <ioapicread>
80102b24:	c1 e8 18             	shr    $0x18,%eax
80102b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b2a:	0f b6 05 c0 f9 10 80 	movzbl 0x8010f9c0,%eax
80102b31:	0f b6 c0             	movzbl %al,%eax
80102b34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b37:	74 0c                	je     80102b45 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b39:	c7 04 24 e0 84 10 80 	movl   $0x801084e0,(%esp)
80102b40:	e8 5b d8 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b4c:	eb 3e                	jmp    80102b8c <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b51:	83 c0 20             	add    $0x20,%eax
80102b54:	0d 00 00 01 00       	or     $0x10000,%eax
80102b59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102b5c:	83 c2 08             	add    $0x8,%edx
80102b5f:	01 d2                	add    %edx,%edx
80102b61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b65:	89 14 24             	mov    %edx,(%esp)
80102b68:	e8 5c ff ff ff       	call   80102ac9 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b70:	83 c0 08             	add    $0x8,%eax
80102b73:	01 c0                	add    %eax,%eax
80102b75:	83 c0 01             	add    $0x1,%eax
80102b78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b7f:	00 
80102b80:	89 04 24             	mov    %eax,(%esp)
80102b83:	e8 41 ff ff ff       	call   80102ac9 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b92:	7e ba                	jle    80102b4e <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b94:	c9                   	leave  
80102b95:	c3                   	ret    

80102b96 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b96:	55                   	push   %ebp
80102b97:	89 e5                	mov    %esp,%ebp
80102b99:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102b9c:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80102ba1:	85 c0                	test   %eax,%eax
80102ba3:	75 02                	jne    80102ba7 <ioapicenable+0x11>
    return;
80102ba5:	eb 37                	jmp    80102bde <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80102baa:	83 c0 20             	add    $0x20,%eax
80102bad:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb0:	83 c2 08             	add    $0x8,%edx
80102bb3:	01 d2                	add    %edx,%edx
80102bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bb9:	89 14 24             	mov    %edx,(%esp)
80102bbc:	e8 08 ff ff ff       	call   80102ac9 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bc4:	c1 e0 18             	shl    $0x18,%eax
80102bc7:	8b 55 08             	mov    0x8(%ebp),%edx
80102bca:	83 c2 08             	add    $0x8,%edx
80102bcd:	01 d2                	add    %edx,%edx
80102bcf:	83 c2 01             	add    $0x1,%edx
80102bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bd6:	89 14 24             	mov    %edx,(%esp)
80102bd9:	e8 eb fe ff ff       	call   80102ac9 <ioapicwrite>
}
80102bde:	c9                   	leave  
80102bdf:	c3                   	ret    

80102be0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102be0:	55                   	push   %ebp
80102be1:	89 e5                	mov    %esp,%ebp
80102be3:	8b 45 08             	mov    0x8(%ebp),%eax
80102be6:	05 00 00 00 80       	add    $0x80000000,%eax
80102beb:	5d                   	pop    %ebp
80102bec:	c3                   	ret    

80102bed <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bed:	55                   	push   %ebp
80102bee:	89 e5                	mov    %esp,%ebp
80102bf0:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102bf3:	c7 44 24 04 12 85 10 	movl   $0x80108512,0x4(%esp)
80102bfa:	80 
80102bfb:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102c02:	e8 41 21 00 00       	call   80104d48 <initlock>
  kmem.use_lock = 0;
80102c07:	c7 05 34 f9 10 80 00 	movl   $0x0,0x8010f934
80102c0e:	00 00 00 
  freerange(vstart, vend);
80102c11:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c14:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c18:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1b:	89 04 24             	mov    %eax,(%esp)
80102c1e:	e8 26 00 00 00       	call   80102c49 <freerange>
}
80102c23:	c9                   	leave  
80102c24:	c3                   	ret    

80102c25 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c25:	55                   	push   %ebp
80102c26:	89 e5                	mov    %esp,%ebp
80102c28:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c32:	8b 45 08             	mov    0x8(%ebp),%eax
80102c35:	89 04 24             	mov    %eax,(%esp)
80102c38:	e8 0c 00 00 00       	call   80102c49 <freerange>
  kmem.use_lock = 1;
80102c3d:	c7 05 34 f9 10 80 01 	movl   $0x1,0x8010f934
80102c44:	00 00 00 
}
80102c47:	c9                   	leave  
80102c48:	c3                   	ret    

80102c49 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c49:	55                   	push   %ebp
80102c4a:	89 e5                	mov    %esp,%ebp
80102c4c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c5f:	eb 12                	jmp    80102c73 <freerange+0x2a>
    kfree(p);
80102c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c64:	89 04 24             	mov    %eax,(%esp)
80102c67:	e8 16 00 00 00       	call   80102c82 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c6c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c76:	05 00 10 00 00       	add    $0x1000,%eax
80102c7b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c7e:	76 e1                	jbe    80102c61 <freerange+0x18>
    kfree(p);
}
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c82:	55                   	push   %ebp
80102c83:	89 e5                	mov    %esp,%ebp
80102c85:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c88:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c90:	85 c0                	test   %eax,%eax
80102c92:	75 1b                	jne    80102caf <kfree+0x2d>
80102c94:	81 7d 08 bc 27 11 80 	cmpl   $0x801127bc,0x8(%ebp)
80102c9b:	72 12                	jb     80102caf <kfree+0x2d>
80102c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca0:	89 04 24             	mov    %eax,(%esp)
80102ca3:	e8 38 ff ff ff       	call   80102be0 <v2p>
80102ca8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102cad:	76 0c                	jbe    80102cbb <kfree+0x39>
    panic("kfree");
80102caf:	c7 04 24 17 85 10 80 	movl   $0x80108517,(%esp)
80102cb6:	e8 7f d8 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cbb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102cc2:	00 
80102cc3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102cca:	00 
80102ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cce:	89 04 24             	mov    %eax,(%esp)
80102cd1:	e8 e7 22 00 00       	call   80104fbd <memset>

  if(kmem.use_lock)
80102cd6:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102cdb:	85 c0                	test   %eax,%eax
80102cdd:	74 0c                	je     80102ceb <kfree+0x69>
    acquire(&kmem.lock);
80102cdf:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102ce6:	e8 7e 20 00 00       	call   80104d69 <acquire>
  r = (struct run*)v;
80102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cf1:	8b 15 38 f9 10 80    	mov    0x8010f938,%edx
80102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cfa:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cff:	a3 38 f9 10 80       	mov    %eax,0x8010f938
  if(kmem.use_lock)
80102d04:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102d09:	85 c0                	test   %eax,%eax
80102d0b:	74 0c                	je     80102d19 <kfree+0x97>
    release(&kmem.lock);
80102d0d:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102d14:	e8 b2 20 00 00       	call   80104dcb <release>
}
80102d19:	c9                   	leave  
80102d1a:	c3                   	ret    

80102d1b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d1b:	55                   	push   %ebp
80102d1c:	89 e5                	mov    %esp,%ebp
80102d1e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102d21:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102d26:	85 c0                	test   %eax,%eax
80102d28:	74 0c                	je     80102d36 <kalloc+0x1b>
    acquire(&kmem.lock);
80102d2a:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102d31:	e8 33 20 00 00       	call   80104d69 <acquire>
  r = kmem.freelist;
80102d36:	a1 38 f9 10 80       	mov    0x8010f938,%eax
80102d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d42:	74 0a                	je     80102d4e <kalloc+0x33>
    kmem.freelist = r->next;
80102d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d47:	8b 00                	mov    (%eax),%eax
80102d49:	a3 38 f9 10 80       	mov    %eax,0x8010f938
  if(kmem.use_lock)
80102d4e:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102d53:	85 c0                	test   %eax,%eax
80102d55:	74 0c                	je     80102d63 <kalloc+0x48>
    release(&kmem.lock);
80102d57:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102d5e:	e8 68 20 00 00       	call   80104dcb <release>
  return (char*)r;
80102d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d66:	c9                   	leave  
80102d67:	c3                   	ret    

80102d68 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d68:	55                   	push   %ebp
80102d69:	89 e5                	mov    %esp,%ebp
80102d6b:	83 ec 14             	sub    $0x14,%esp
80102d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d71:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d75:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d79:	89 c2                	mov    %eax,%edx
80102d7b:	ec                   	in     (%dx),%al
80102d7c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d7f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d83:	c9                   	leave  
80102d84:	c3                   	ret    

80102d85 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d85:	55                   	push   %ebp
80102d86:	89 e5                	mov    %esp,%ebp
80102d88:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d8b:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102d92:	e8 d1 ff ff ff       	call   80102d68 <inb>
80102d97:	0f b6 c0             	movzbl %al,%eax
80102d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da0:	83 e0 01             	and    $0x1,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	75 0a                	jne    80102db1 <kbdgetc+0x2c>
    return -1;
80102da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dac:	e9 25 01 00 00       	jmp    80102ed6 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102db1:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102db8:	e8 ab ff ff ff       	call   80102d68 <inb>
80102dbd:	0f b6 c0             	movzbl %al,%eax
80102dc0:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102dc3:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dca:	75 17                	jne    80102de3 <kbdgetc+0x5e>
    shift |= E0ESC;
80102dcc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dd1:	83 c8 40             	or     $0x40,%eax
80102dd4:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102dd9:	b8 00 00 00 00       	mov    $0x0,%eax
80102dde:	e9 f3 00 00 00       	jmp    80102ed6 <kbdgetc+0x151>
  } else if(data & 0x80){
80102de3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de6:	25 80 00 00 00       	and    $0x80,%eax
80102deb:	85 c0                	test   %eax,%eax
80102ded:	74 45                	je     80102e34 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102def:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102df4:	83 e0 40             	and    $0x40,%eax
80102df7:	85 c0                	test   %eax,%eax
80102df9:	75 08                	jne    80102e03 <kbdgetc+0x7e>
80102dfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dfe:	83 e0 7f             	and    $0x7f,%eax
80102e01:	eb 03                	jmp    80102e06 <kbdgetc+0x81>
80102e03:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e06:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0c:	05 20 90 10 80       	add    $0x80109020,%eax
80102e11:	0f b6 00             	movzbl (%eax),%eax
80102e14:	83 c8 40             	or     $0x40,%eax
80102e17:	0f b6 c0             	movzbl %al,%eax
80102e1a:	f7 d0                	not    %eax
80102e1c:	89 c2                	mov    %eax,%edx
80102e1e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e23:	21 d0                	and    %edx,%eax
80102e25:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102e2a:	b8 00 00 00 00       	mov    $0x0,%eax
80102e2f:	e9 a2 00 00 00       	jmp    80102ed6 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102e34:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e39:	83 e0 40             	and    $0x40,%eax
80102e3c:	85 c0                	test   %eax,%eax
80102e3e:	74 14                	je     80102e54 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e40:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e47:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e4c:	83 e0 bf             	and    $0xffffffbf,%eax
80102e4f:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102e54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e57:	05 20 90 10 80       	add    $0x80109020,%eax
80102e5c:	0f b6 00             	movzbl (%eax),%eax
80102e5f:	0f b6 d0             	movzbl %al,%edx
80102e62:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e67:	09 d0                	or     %edx,%eax
80102e69:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102e6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e71:	05 20 91 10 80       	add    $0x80109120,%eax
80102e76:	0f b6 00             	movzbl (%eax),%eax
80102e79:	0f b6 d0             	movzbl %al,%edx
80102e7c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e81:	31 d0                	xor    %edx,%eax
80102e83:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e88:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e8d:	83 e0 03             	and    $0x3,%eax
80102e90:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e9a:	01 d0                	add    %edx,%eax
80102e9c:	0f b6 00             	movzbl (%eax),%eax
80102e9f:	0f b6 c0             	movzbl %al,%eax
80102ea2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ea5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102eaa:	83 e0 08             	and    $0x8,%eax
80102ead:	85 c0                	test   %eax,%eax
80102eaf:	74 22                	je     80102ed3 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102eb1:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102eb5:	76 0c                	jbe    80102ec3 <kbdgetc+0x13e>
80102eb7:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ebb:	77 06                	ja     80102ec3 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102ebd:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ec1:	eb 10                	jmp    80102ed3 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ec3:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ec7:	76 0a                	jbe    80102ed3 <kbdgetc+0x14e>
80102ec9:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ecd:	77 04                	ja     80102ed3 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ecf:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ed3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ed6:	c9                   	leave  
80102ed7:	c3                   	ret    

80102ed8 <kbdintr>:

void
kbdintr(void)
{
80102ed8:	55                   	push   %ebp
80102ed9:	89 e5                	mov    %esp,%ebp
80102edb:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ede:	c7 04 24 85 2d 10 80 	movl   $0x80102d85,(%esp)
80102ee5:	e8 c3 d8 ff ff       	call   801007ad <consoleintr>
}
80102eea:	c9                   	leave  
80102eeb:	c3                   	ret    

80102eec <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102eec:	55                   	push   %ebp
80102eed:	89 e5                	mov    %esp,%ebp
80102eef:	83 ec 08             	sub    $0x8,%esp
80102ef2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ef8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102efc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102eff:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f03:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f07:	ee                   	out    %al,(%dx)
}
80102f08:	c9                   	leave  
80102f09:	c3                   	ret    

80102f0a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f0a:	55                   	push   %ebp
80102f0b:	89 e5                	mov    %esp,%ebp
80102f0d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f10:	9c                   	pushf  
80102f11:	58                   	pop    %eax
80102f12:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f18:	c9                   	leave  
80102f19:	c3                   	ret    

80102f1a <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f1a:	55                   	push   %ebp
80102f1b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f1d:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80102f22:	8b 55 08             	mov    0x8(%ebp),%edx
80102f25:	c1 e2 02             	shl    $0x2,%edx
80102f28:	01 c2                	add    %eax,%edx
80102f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f2d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f2f:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80102f34:	83 c0 20             	add    $0x20,%eax
80102f37:	8b 00                	mov    (%eax),%eax
}
80102f39:	5d                   	pop    %ebp
80102f3a:	c3                   	ret    

80102f3b <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80102f3b:	55                   	push   %ebp
80102f3c:	89 e5                	mov    %esp,%ebp
80102f3e:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102f41:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80102f46:	85 c0                	test   %eax,%eax
80102f48:	75 05                	jne    80102f4f <lapicinit+0x14>
    return;
80102f4a:	e9 43 01 00 00       	jmp    80103092 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f4f:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102f56:	00 
80102f57:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102f5e:	e8 b7 ff ff ff       	call   80102f1a <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f63:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102f72:	e8 a3 ff ff ff       	call   80102f1a <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f77:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102f7e:	00 
80102f7f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f86:	e8 8f ff ff ff       	call   80102f1a <lapicw>
  lapicw(TICR, 10000000); 
80102f8b:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102f92:	00 
80102f93:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102f9a:	e8 7b ff ff ff       	call   80102f1a <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f9f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fa6:	00 
80102fa7:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102fae:	e8 67 ff ff ff       	call   80102f1a <lapicw>
  lapicw(LINT1, MASKED);
80102fb3:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fba:	00 
80102fbb:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102fc2:	e8 53 ff ff ff       	call   80102f1a <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fc7:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80102fcc:	83 c0 30             	add    $0x30,%eax
80102fcf:	8b 00                	mov    (%eax),%eax
80102fd1:	c1 e8 10             	shr    $0x10,%eax
80102fd4:	0f b6 c0             	movzbl %al,%eax
80102fd7:	83 f8 03             	cmp    $0x3,%eax
80102fda:	76 14                	jbe    80102ff0 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102fdc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fe3:	00 
80102fe4:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102feb:	e8 2a ff ff ff       	call   80102f1a <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ff0:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ff7:	00 
80102ff8:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102fff:	e8 16 ff ff ff       	call   80102f1a <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103004:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010300b:	00 
8010300c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103013:	e8 02 ff ff ff       	call   80102f1a <lapicw>
  lapicw(ESR, 0);
80103018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010301f:	00 
80103020:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103027:	e8 ee fe ff ff       	call   80102f1a <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010302c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103033:	00 
80103034:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010303b:	e8 da fe ff ff       	call   80102f1a <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103047:	00 
80103048:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010304f:	e8 c6 fe ff ff       	call   80102f1a <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103054:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010305b:	00 
8010305c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103063:	e8 b2 fe ff ff       	call   80102f1a <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103068:	90                   	nop
80103069:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
8010306e:	05 00 03 00 00       	add    $0x300,%eax
80103073:	8b 00                	mov    (%eax),%eax
80103075:	25 00 10 00 00       	and    $0x1000,%eax
8010307a:	85 c0                	test   %eax,%eax
8010307c:	75 eb                	jne    80103069 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010307e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103085:	00 
80103086:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010308d:	e8 88 fe ff ff       	call   80102f1a <lapicw>
}
80103092:	c9                   	leave  
80103093:	c3                   	ret    

80103094 <cpunum>:

int
cpunum(void)
{
80103094:	55                   	push   %ebp
80103095:	89 e5                	mov    %esp,%ebp
80103097:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010309a:	e8 6b fe ff ff       	call   80102f0a <readeflags>
8010309f:	25 00 02 00 00       	and    $0x200,%eax
801030a4:	85 c0                	test   %eax,%eax
801030a6:	74 25                	je     801030cd <cpunum+0x39>
    static int n;
    if(n++ == 0)
801030a8:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801030ad:	8d 50 01             	lea    0x1(%eax),%edx
801030b0:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
801030b6:	85 c0                	test   %eax,%eax
801030b8:	75 13                	jne    801030cd <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
801030ba:	8b 45 04             	mov    0x4(%ebp),%eax
801030bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801030c1:	c7 04 24 20 85 10 80 	movl   $0x80108520,(%esp)
801030c8:	e8 d3 d2 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801030cd:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
801030d2:	85 c0                	test   %eax,%eax
801030d4:	74 0f                	je     801030e5 <cpunum+0x51>
    return lapic[ID]>>24;
801030d6:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
801030db:	83 c0 20             	add    $0x20,%eax
801030de:	8b 00                	mov    (%eax),%eax
801030e0:	c1 e8 18             	shr    $0x18,%eax
801030e3:	eb 05                	jmp    801030ea <cpunum+0x56>
  return 0;
801030e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030ea:	c9                   	leave  
801030eb:	c3                   	ret    

801030ec <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030ec:	55                   	push   %ebp
801030ed:	89 e5                	mov    %esp,%ebp
801030ef:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801030f2:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 14                	je     8010310f <lapiceoi+0x23>
    lapicw(EOI, 0);
801030fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103102:	00 
80103103:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010310a:	e8 0b fe ff ff       	call   80102f1a <lapicw>
}
8010310f:	c9                   	leave  
80103110:	c3                   	ret    

80103111 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103111:	55                   	push   %ebp
80103112:	89 e5                	mov    %esp,%ebp
}
80103114:	5d                   	pop    %ebp
80103115:	c3                   	ret    

80103116 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103116:	55                   	push   %ebp
80103117:	89 e5                	mov    %esp,%ebp
80103119:	83 ec 1c             	sub    $0x1c,%esp
8010311c:	8b 45 08             	mov    0x8(%ebp),%eax
8010311f:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103122:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103129:	00 
8010312a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103131:	e8 b6 fd ff ff       	call   80102eec <outb>
  outb(IO_RTC+1, 0x0A);
80103136:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010313d:	00 
8010313e:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103145:	e8 a2 fd ff ff       	call   80102eec <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010314a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103151:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103154:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103159:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010315c:	8d 50 02             	lea    0x2(%eax),%edx
8010315f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103162:	c1 e8 04             	shr    $0x4,%eax
80103165:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103168:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010316c:	c1 e0 18             	shl    $0x18,%eax
8010316f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103173:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010317a:	e8 9b fd ff ff       	call   80102f1a <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010317f:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103186:	00 
80103187:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010318e:	e8 87 fd ff ff       	call   80102f1a <lapicw>
  microdelay(200);
80103193:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010319a:	e8 72 ff ff ff       	call   80103111 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010319f:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801031a6:	00 
801031a7:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ae:	e8 67 fd ff ff       	call   80102f1a <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031b3:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801031ba:	e8 52 ff ff ff       	call   80103111 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031c6:	eb 40                	jmp    80103208 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801031c8:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031cc:	c1 e0 18             	shl    $0x18,%eax
801031cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801031d3:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031da:	e8 3b fd ff ff       	call   80102f1a <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801031df:	8b 45 0c             	mov    0xc(%ebp),%eax
801031e2:	c1 e8 0c             	shr    $0xc,%eax
801031e5:	80 cc 06             	or     $0x6,%ah
801031e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031f3:	e8 22 fd ff ff       	call   80102f1a <lapicw>
    microdelay(200);
801031f8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031ff:	e8 0d ff ff ff       	call   80103111 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103204:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103208:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010320c:	7e ba                	jle    801031c8 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010320e:	c9                   	leave  
8010320f:	c3                   	ret    

80103210 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103210:	55                   	push   %ebp
80103211:	89 e5                	mov    %esp,%ebp
80103213:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103216:	c7 44 24 04 4c 85 10 	movl   $0x8010854c,0x4(%esp)
8010321d:	80 
8010321e:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103225:	e8 1e 1b 00 00       	call   80104d48 <initlock>
  readsb(ROOTDEV, &sb);
8010322a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010322d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103231:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103238:	e8 a7 e0 ff ff       	call   801012e4 <readsb>
  log.start = sb.size - sb.nlog;
8010323d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103243:	29 c2                	sub    %eax,%edx
80103245:	89 d0                	mov    %edx,%eax
80103247:	a3 74 f9 10 80       	mov    %eax,0x8010f974
  log.size = sb.nlog;
8010324c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010324f:	a3 78 f9 10 80       	mov    %eax,0x8010f978
  log.dev = ROOTDEV;
80103254:	c7 05 80 f9 10 80 01 	movl   $0x1,0x8010f980
8010325b:	00 00 00 
  recover_from_log();
8010325e:	e8 9a 01 00 00       	call   801033fd <recover_from_log>
}
80103263:	c9                   	leave  
80103264:	c3                   	ret    

80103265 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103265:	55                   	push   %ebp
80103266:	89 e5                	mov    %esp,%ebp
80103268:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010326b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103272:	e9 8c 00 00 00       	jmp    80103303 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103277:	8b 15 74 f9 10 80    	mov    0x8010f974,%edx
8010327d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103280:	01 d0                	add    %edx,%eax
80103282:	83 c0 01             	add    $0x1,%eax
80103285:	89 c2                	mov    %eax,%edx
80103287:	a1 80 f9 10 80       	mov    0x8010f980,%eax
8010328c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103290:	89 04 24             	mov    %eax,(%esp)
80103293:	e8 0e cf ff ff       	call   801001a6 <bread>
80103298:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010329b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329e:	83 c0 10             	add    $0x10,%eax
801032a1:	8b 04 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%eax
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	a1 80 f9 10 80       	mov    0x8010f980,%eax
801032af:	89 54 24 04          	mov    %edx,0x4(%esp)
801032b3:	89 04 24             	mov    %eax,(%esp)
801032b6:	e8 eb ce ff ff       	call   801001a6 <bread>
801032bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032c1:	8d 50 18             	lea    0x18(%eax),%edx
801032c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032c7:	83 c0 18             	add    $0x18,%eax
801032ca:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032d1:	00 
801032d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d6:	89 04 24             	mov    %eax,(%esp)
801032d9:	e8 ae 1d 00 00       	call   8010508c <memmove>
    bwrite(dbuf);  // write dst to disk
801032de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e1:	89 04 24             	mov    %eax,(%esp)
801032e4:	e8 f4 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032ec:	89 04 24             	mov    %eax,(%esp)
801032ef:	e8 23 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f7:	89 04 24             	mov    %eax,(%esp)
801032fa:	e8 18 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103303:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103308:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010330b:	0f 8f 66 ff ff ff    	jg     80103277 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103311:	c9                   	leave  
80103312:	c3                   	ret    

80103313 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103313:	55                   	push   %ebp
80103314:	89 e5                	mov    %esp,%ebp
80103316:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103319:	a1 74 f9 10 80       	mov    0x8010f974,%eax
8010331e:	89 c2                	mov    %eax,%edx
80103320:	a1 80 f9 10 80       	mov    0x8010f980,%eax
80103325:	89 54 24 04          	mov    %edx,0x4(%esp)
80103329:	89 04 24             	mov    %eax,(%esp)
8010332c:	e8 75 ce ff ff       	call   801001a6 <bread>
80103331:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103337:	83 c0 18             	add    $0x18,%eax
8010333a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010333d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103340:	8b 00                	mov    (%eax),%eax
80103342:	a3 84 f9 10 80       	mov    %eax,0x8010f984
  for (i = 0; i < log.lh.n; i++) {
80103347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010334e:	eb 1b                	jmp    8010336b <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103350:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103353:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103356:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010335a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010335d:	83 c2 10             	add    $0x10,%edx
80103360:	89 04 95 48 f9 10 80 	mov    %eax,-0x7fef06b8(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103367:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336b:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103370:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103373:	7f db                	jg     80103350 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103378:	89 04 24             	mov    %eax,(%esp)
8010337b:	e8 97 ce ff ff       	call   80100217 <brelse>
}
80103380:	c9                   	leave  
80103381:	c3                   	ret    

80103382 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103382:	55                   	push   %ebp
80103383:	89 e5                	mov    %esp,%ebp
80103385:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103388:	a1 74 f9 10 80       	mov    0x8010f974,%eax
8010338d:	89 c2                	mov    %eax,%edx
8010338f:	a1 80 f9 10 80       	mov    0x8010f980,%eax
80103394:	89 54 24 04          	mov    %edx,0x4(%esp)
80103398:	89 04 24             	mov    %eax,(%esp)
8010339b:	e8 06 ce ff ff       	call   801001a6 <bread>
801033a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a6:	83 c0 18             	add    $0x18,%eax
801033a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ac:	8b 15 84 f9 10 80    	mov    0x8010f984,%edx
801033b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033be:	eb 1b                	jmp    801033db <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c3:	83 c0 10             	add    $0x10,%eax
801033c6:	8b 0c 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%ecx
801033cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033d3:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033db:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801033e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e3:	7f db                	jg     801033c0 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e8:	89 04 24             	mov    %eax,(%esp)
801033eb:	e8 ed cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f3:	89 04 24             	mov    %eax,(%esp)
801033f6:	e8 1c ce ff ff       	call   80100217 <brelse>
}
801033fb:	c9                   	leave  
801033fc:	c3                   	ret    

801033fd <recover_from_log>:

static void
recover_from_log(void)
{
801033fd:	55                   	push   %ebp
801033fe:	89 e5                	mov    %esp,%ebp
80103400:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103403:	e8 0b ff ff ff       	call   80103313 <read_head>
  install_trans(); // if committed, copy from log to disk
80103408:	e8 58 fe ff ff       	call   80103265 <install_trans>
  log.lh.n = 0;
8010340d:	c7 05 84 f9 10 80 00 	movl   $0x0,0x8010f984
80103414:	00 00 00 
  write_head(); // clear the log
80103417:	e8 66 ff ff ff       	call   80103382 <write_head>
}
8010341c:	c9                   	leave  
8010341d:	c3                   	ret    

8010341e <begin_trans>:

void
begin_trans(void)
{
8010341e:	55                   	push   %ebp
8010341f:	89 e5                	mov    %esp,%ebp
80103421:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103424:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
8010342b:	e8 39 19 00 00       	call   80104d69 <acquire>
  while (log.busy) {
80103430:	eb 14                	jmp    80103446 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103432:	c7 44 24 04 40 f9 10 	movl   $0x8010f940,0x4(%esp)
80103439:	80 
8010343a:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103441:	e8 59 16 00 00       	call   80104a9f <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103446:	a1 7c f9 10 80       	mov    0x8010f97c,%eax
8010344b:	85 c0                	test   %eax,%eax
8010344d:	75 e3                	jne    80103432 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010344f:	c7 05 7c f9 10 80 01 	movl   $0x1,0x8010f97c
80103456:	00 00 00 
  release(&log.lock);
80103459:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103460:	e8 66 19 00 00       	call   80104dcb <release>
}
80103465:	c9                   	leave  
80103466:	c3                   	ret    

80103467 <commit_trans>:

void
commit_trans(void)
{
80103467:	55                   	push   %ebp
80103468:	89 e5                	mov    %esp,%ebp
8010346a:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
8010346d:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103472:	85 c0                	test   %eax,%eax
80103474:	7e 19                	jle    8010348f <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103476:	e8 07 ff ff ff       	call   80103382 <write_head>
    install_trans(); // Now install writes to home locations
8010347b:	e8 e5 fd ff ff       	call   80103265 <install_trans>
    log.lh.n = 0; 
80103480:	c7 05 84 f9 10 80 00 	movl   $0x0,0x8010f984
80103487:	00 00 00 
    write_head();    // Erase the transaction from the log
8010348a:	e8 f3 fe ff ff       	call   80103382 <write_head>
  }
  
  acquire(&log.lock);
8010348f:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103496:	e8 ce 18 00 00       	call   80104d69 <acquire>
  log.busy = 0;
8010349b:	c7 05 7c f9 10 80 00 	movl   $0x0,0x8010f97c
801034a2:	00 00 00 
  wakeup(&log);
801034a5:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801034ac:	e8 c7 16 00 00       	call   80104b78 <wakeup>
  release(&log.lock);
801034b1:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801034b8:	e8 0e 19 00 00       	call   80104dcb <release>
}
801034bd:	c9                   	leave  
801034be:	c3                   	ret    

801034bf <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
801034c2:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801034c5:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801034ca:	83 f8 09             	cmp    $0x9,%eax
801034cd:	7f 12                	jg     801034e1 <log_write+0x22>
801034cf:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801034d4:	8b 15 78 f9 10 80    	mov    0x8010f978,%edx
801034da:	83 ea 01             	sub    $0x1,%edx
801034dd:	39 d0                	cmp    %edx,%eax
801034df:	7c 0c                	jl     801034ed <log_write+0x2e>
    panic("too big a transaction");
801034e1:	c7 04 24 50 85 10 80 	movl   $0x80108550,(%esp)
801034e8:	e8 4d d0 ff ff       	call   8010053a <panic>
  if (!log.busy)
801034ed:	a1 7c f9 10 80       	mov    0x8010f97c,%eax
801034f2:	85 c0                	test   %eax,%eax
801034f4:	75 0c                	jne    80103502 <log_write+0x43>
    panic("write outside of trans");
801034f6:	c7 04 24 66 85 10 80 	movl   $0x80108566,(%esp)
801034fd:	e8 38 d0 ff ff       	call   8010053a <panic>

  for (i = 0; i < log.lh.n; i++) {
80103502:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103509:	eb 1f                	jmp    8010352a <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010350b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010350e:	83 c0 10             	add    $0x10,%eax
80103511:	8b 04 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%eax
80103518:	89 c2                	mov    %eax,%edx
8010351a:	8b 45 08             	mov    0x8(%ebp),%eax
8010351d:	8b 40 08             	mov    0x8(%eax),%eax
80103520:	39 c2                	cmp    %eax,%edx
80103522:	75 02                	jne    80103526 <log_write+0x67>
      break;
80103524:	eb 0e                	jmp    80103534 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352a:	a1 84 f9 10 80       	mov    0x8010f984,%eax
8010352f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103532:	7f d7                	jg     8010350b <log_write+0x4c>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
  }
  log.lh.sector[i] = b->sector;
80103534:	8b 45 08             	mov    0x8(%ebp),%eax
80103537:	8b 40 08             	mov    0x8(%eax),%eax
8010353a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010353d:	83 c2 10             	add    $0x10,%edx
80103540:	89 04 95 48 f9 10 80 	mov    %eax,-0x7fef06b8(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103547:	8b 15 74 f9 10 80    	mov    0x8010f974,%edx
8010354d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103550:	01 d0                	add    %edx,%eax
80103552:	83 c0 01             	add    $0x1,%eax
80103555:	89 c2                	mov    %eax,%edx
80103557:	8b 45 08             	mov    0x8(%ebp),%eax
8010355a:	8b 40 04             	mov    0x4(%eax),%eax
8010355d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103561:	89 04 24             	mov    %eax,(%esp)
80103564:	e8 3d cc ff ff       	call   801001a6 <bread>
80103569:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
8010356c:	8b 45 08             	mov    0x8(%ebp),%eax
8010356f:	8d 50 18             	lea    0x18(%eax),%edx
80103572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103575:	83 c0 18             	add    $0x18,%eax
80103578:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010357f:	00 
80103580:	89 54 24 04          	mov    %edx,0x4(%esp)
80103584:	89 04 24             	mov    %eax,(%esp)
80103587:	e8 00 1b 00 00       	call   8010508c <memmove>
  bwrite(lbuf);
8010358c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010358f:	89 04 24             	mov    %eax,(%esp)
80103592:	e8 46 cc ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010359a:	89 04 24             	mov    %eax,(%esp)
8010359d:	e8 75 cc ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801035a2:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801035a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035aa:	75 0d                	jne    801035b9 <log_write+0xfa>
    log.lh.n++;
801035ac:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801035b1:	83 c0 01             	add    $0x1,%eax
801035b4:	a3 84 f9 10 80       	mov    %eax,0x8010f984
  b->flags |= B_DIRTY; // XXX prevent eviction
801035b9:	8b 45 08             	mov    0x8(%ebp),%eax
801035bc:	8b 00                	mov    (%eax),%eax
801035be:	83 c8 04             	or     $0x4,%eax
801035c1:	89 c2                	mov    %eax,%edx
801035c3:	8b 45 08             	mov    0x8(%ebp),%eax
801035c6:	89 10                	mov    %edx,(%eax)
}
801035c8:	c9                   	leave  
801035c9:	c3                   	ret    

801035ca <v2p>:
801035ca:	55                   	push   %ebp
801035cb:	89 e5                	mov    %esp,%ebp
801035cd:	8b 45 08             	mov    0x8(%ebp),%eax
801035d0:	05 00 00 00 80       	add    $0x80000000,%eax
801035d5:	5d                   	pop    %ebp
801035d6:	c3                   	ret    

801035d7 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801035d7:	55                   	push   %ebp
801035d8:	89 e5                	mov    %esp,%ebp
801035da:	8b 45 08             	mov    0x8(%ebp),%eax
801035dd:	05 00 00 00 80       	add    $0x80000000,%eax
801035e2:	5d                   	pop    %ebp
801035e3:	c3                   	ret    

801035e4 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801035e4:	55                   	push   %ebp
801035e5:	89 e5                	mov    %esp,%ebp
801035e7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801035ea:	8b 55 08             	mov    0x8(%ebp),%edx
801035ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801035f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801035f3:	f0 87 02             	lock xchg %eax,(%edx)
801035f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801035f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801035fc:	c9                   	leave  
801035fd:	c3                   	ret    

801035fe <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801035fe:	55                   	push   %ebp
801035ff:	89 e5                	mov    %esp,%ebp
80103601:	83 e4 f0             	and    $0xfffffff0,%esp
80103604:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103607:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010360e:	80 
8010360f:	c7 04 24 bc 27 11 80 	movl   $0x801127bc,(%esp)
80103616:	e8 d2 f5 ff ff       	call   80102bed <kinit1>
  kvmalloc();      // kernel page table
8010361b:	e8 84 45 00 00       	call   80107ba4 <kvmalloc>
  mpinit();        // collect info about this machine
80103620:	e8 56 04 00 00       	call   80103a7b <mpinit>
  lapicinit(mpbcpu());
80103625:	e8 1f 02 00 00       	call   80103849 <mpbcpu>
8010362a:	89 04 24             	mov    %eax,(%esp)
8010362d:	e8 09 f9 ff ff       	call   80102f3b <lapicinit>
  seginit();       // set up segments
80103632:	e8 00 3f 00 00       	call   80107537 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103637:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010363d:	0f b6 00             	movzbl (%eax),%eax
80103640:	0f b6 c0             	movzbl %al,%eax
80103643:	89 44 24 04          	mov    %eax,0x4(%esp)
80103647:	c7 04 24 7d 85 10 80 	movl   $0x8010857d,(%esp)
8010364e:	e8 4d cd ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103653:	e8 81 06 00 00       	call   80103cd9 <picinit>
  ioapicinit();    // another interrupt controller
80103658:	e8 86 f4 ff ff       	call   80102ae3 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010365d:	e8 1f d4 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103662:	e8 1f 32 00 00       	call   80106886 <uartinit>
  pinit();         // process table
80103667:	e8 77 0b 00 00       	call   801041e3 <pinit>
  tvinit();        // trap vectors
8010366c:	e8 c7 2d 00 00       	call   80106438 <tvinit>
  binit();         // buffer cache
80103671:	e8 be c9 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103676:	e8 82 d8 ff ff       	call   80100efd <fileinit>
  iinit();         // inode cache
8010367b:	e8 17 df ff ff       	call   80101597 <iinit>
  ideinit();       // disk
80103680:	e8 c7 f0 ff ff       	call   8010274c <ideinit>
  if(!ismp)
80103685:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
8010368a:	85 c0                	test   %eax,%eax
8010368c:	75 05                	jne    80103693 <main+0x95>
    timerinit();   // uniprocessor timer
8010368e:	e8 f0 2c 00 00       	call   80106383 <timerinit>
  startothers();   // start other processors
80103693:	e8 87 00 00 00       	call   8010371f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103698:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010369f:	8e 
801036a0:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801036a7:	e8 79 f5 ff ff       	call   80102c25 <kinit2>
  userinit();      // first user process
801036ac:	e8 4d 0c 00 00       	call   801042fe <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801036b1:	e8 22 00 00 00       	call   801036d8 <mpmain>

801036b6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801036b6:	55                   	push   %ebp
801036b7:	89 e5                	mov    %esp,%ebp
801036b9:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801036bc:	e8 fa 44 00 00       	call   80107bbb <switchkvm>
  seginit();
801036c1:	e8 71 3e 00 00       	call   80107537 <seginit>
  lapicinit(cpunum());
801036c6:	e8 c9 f9 ff ff       	call   80103094 <cpunum>
801036cb:	89 04 24             	mov    %eax,(%esp)
801036ce:	e8 68 f8 ff ff       	call   80102f3b <lapicinit>
  mpmain();
801036d3:	e8 00 00 00 00       	call   801036d8 <mpmain>

801036d8 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801036d8:	55                   	push   %ebp
801036d9:	89 e5                	mov    %esp,%ebp
801036db:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801036de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801036e4:	0f b6 00             	movzbl (%eax),%eax
801036e7:	0f b6 c0             	movzbl %al,%eax
801036ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801036ee:	c7 04 24 94 85 10 80 	movl   $0x80108594,(%esp)
801036f5:	e8 a6 cc ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801036fa:	e8 ad 2e 00 00       	call   801065ac <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801036ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103705:	05 a8 00 00 00       	add    $0xa8,%eax
8010370a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103711:	00 
80103712:	89 04 24             	mov    %eax,(%esp)
80103715:	e8 ca fe ff ff       	call   801035e4 <xchg>
  scheduler();     // start running processes
8010371a:	e8 d8 11 00 00       	call   801048f7 <scheduler>

8010371f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	53                   	push   %ebx
80103723:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103726:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010372d:	e8 a5 fe ff ff       	call   801035d7 <p2v>
80103732:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103735:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010373a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010373e:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103745:	80 
80103746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103749:	89 04 24             	mov    %eax,(%esp)
8010374c:	e8 3b 19 00 00       	call   8010508c <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103751:	c7 45 f4 e0 f9 10 80 	movl   $0x8010f9e0,-0xc(%ebp)
80103758:	e9 85 00 00 00       	jmp    801037e2 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
8010375d:	e8 32 f9 ff ff       	call   80103094 <cpunum>
80103762:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103768:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
8010376d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103770:	75 02                	jne    80103774 <startothers+0x55>
      continue;
80103772:	eb 67                	jmp    801037db <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103774:	e8 a2 f5 ff ff       	call   80102d1b <kalloc>
80103779:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010377c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010377f:	83 e8 04             	sub    $0x4,%eax
80103782:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103785:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010378b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010378d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103790:	83 e8 08             	sub    $0x8,%eax
80103793:	c7 00 b6 36 10 80    	movl   $0x801036b6,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010379c:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010379f:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801037a6:	e8 1f fe ff ff       	call   801035ca <v2p>
801037ab:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801037ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b0:	89 04 24             	mov    %eax,(%esp)
801037b3:	e8 12 fe ff ff       	call   801035ca <v2p>
801037b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037bb:	0f b6 12             	movzbl (%edx),%edx
801037be:	0f b6 d2             	movzbl %dl,%edx
801037c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801037c5:	89 14 24             	mov    %edx,(%esp)
801037c8:	e8 49 f9 ff ff       	call   80103116 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801037cd:	90                   	nop
801037ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801037d7:	85 c0                	test   %eax,%eax
801037d9:	74 f3                	je     801037ce <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801037db:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801037e2:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
801037e7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801037ed:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
801037f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037f5:	0f 87 62 ff ff ff    	ja     8010375d <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801037fb:	83 c4 24             	add    $0x24,%esp
801037fe:	5b                   	pop    %ebx
801037ff:	5d                   	pop    %ebp
80103800:	c3                   	ret    

80103801 <p2v>:
80103801:	55                   	push   %ebp
80103802:	89 e5                	mov    %esp,%ebp
80103804:	8b 45 08             	mov    0x8(%ebp),%eax
80103807:	05 00 00 00 80       	add    $0x80000000,%eax
8010380c:	5d                   	pop    %ebp
8010380d:	c3                   	ret    

8010380e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010380e:	55                   	push   %ebp
8010380f:	89 e5                	mov    %esp,%ebp
80103811:	83 ec 14             	sub    $0x14,%esp
80103814:	8b 45 08             	mov    0x8(%ebp),%eax
80103817:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010381b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010381f:	89 c2                	mov    %eax,%edx
80103821:	ec                   	in     (%dx),%al
80103822:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103825:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103829:	c9                   	leave  
8010382a:	c3                   	ret    

8010382b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010382b:	55                   	push   %ebp
8010382c:	89 e5                	mov    %esp,%ebp
8010382e:	83 ec 08             	sub    $0x8,%esp
80103831:	8b 55 08             	mov    0x8(%ebp),%edx
80103834:	8b 45 0c             	mov    0xc(%ebp),%eax
80103837:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010383b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010383e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103842:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103846:	ee                   	out    %al,(%dx)
}
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103849:	55                   	push   %ebp
8010384a:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010384c:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103851:	89 c2                	mov    %eax,%edx
80103853:	b8 e0 f9 10 80       	mov    $0x8010f9e0,%eax
80103858:	29 c2                	sub    %eax,%edx
8010385a:	89 d0                	mov    %edx,%eax
8010385c:	c1 f8 02             	sar    $0x2,%eax
8010385f:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103865:	5d                   	pop    %ebp
80103866:	c3                   	ret    

80103867 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103867:	55                   	push   %ebp
80103868:	89 e5                	mov    %esp,%ebp
8010386a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010386d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103874:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010387b:	eb 15                	jmp    80103892 <sum+0x2b>
    sum += addr[i];
8010387d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103880:	8b 45 08             	mov    0x8(%ebp),%eax
80103883:	01 d0                	add    %edx,%eax
80103885:	0f b6 00             	movzbl (%eax),%eax
80103888:	0f b6 c0             	movzbl %al,%eax
8010388b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010388e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103895:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103898:	7c e3                	jl     8010387d <sum+0x16>
    sum += addr[i];
  return sum;
8010389a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010389d:	c9                   	leave  
8010389e:	c3                   	ret    

8010389f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010389f:	55                   	push   %ebp
801038a0:	89 e5                	mov    %esp,%ebp
801038a2:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801038a5:	8b 45 08             	mov    0x8(%ebp),%eax
801038a8:	89 04 24             	mov    %eax,(%esp)
801038ab:	e8 51 ff ff ff       	call   80103801 <p2v>
801038b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801038b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801038b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b9:	01 d0                	add    %edx,%eax
801038bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801038be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038c4:	eb 3f                	jmp    80103905 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801038c6:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801038cd:	00 
801038ce:	c7 44 24 04 a8 85 10 	movl   $0x801085a8,0x4(%esp)
801038d5:	80 
801038d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d9:	89 04 24             	mov    %eax,(%esp)
801038dc:	e8 53 17 00 00       	call   80105034 <memcmp>
801038e1:	85 c0                	test   %eax,%eax
801038e3:	75 1c                	jne    80103901 <mpsearch1+0x62>
801038e5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801038ec:	00 
801038ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f0:	89 04 24             	mov    %eax,(%esp)
801038f3:	e8 6f ff ff ff       	call   80103867 <sum>
801038f8:	84 c0                	test   %al,%al
801038fa:	75 05                	jne    80103901 <mpsearch1+0x62>
      return (struct mp*)p;
801038fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ff:	eb 11                	jmp    80103912 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103901:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010390b:	72 b9                	jb     801038c6 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
8010390d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103912:	c9                   	leave  
80103913:	c3                   	ret    

80103914 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103914:	55                   	push   %ebp
80103915:	89 e5                	mov    %esp,%ebp
80103917:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
8010391a:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103924:	83 c0 0f             	add    $0xf,%eax
80103927:	0f b6 00             	movzbl (%eax),%eax
8010392a:	0f b6 c0             	movzbl %al,%eax
8010392d:	c1 e0 08             	shl    $0x8,%eax
80103930:	89 c2                	mov    %eax,%edx
80103932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103935:	83 c0 0e             	add    $0xe,%eax
80103938:	0f b6 00             	movzbl (%eax),%eax
8010393b:	0f b6 c0             	movzbl %al,%eax
8010393e:	09 d0                	or     %edx,%eax
80103940:	c1 e0 04             	shl    $0x4,%eax
80103943:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103946:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010394a:	74 21                	je     8010396d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010394c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103953:	00 
80103954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103957:	89 04 24             	mov    %eax,(%esp)
8010395a:	e8 40 ff ff ff       	call   8010389f <mpsearch1>
8010395f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103962:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103966:	74 50                	je     801039b8 <mpsearch+0xa4>
      return mp;
80103968:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010396b:	eb 5f                	jmp    801039cc <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010396d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103970:	83 c0 14             	add    $0x14,%eax
80103973:	0f b6 00             	movzbl (%eax),%eax
80103976:	0f b6 c0             	movzbl %al,%eax
80103979:	c1 e0 08             	shl    $0x8,%eax
8010397c:	89 c2                	mov    %eax,%edx
8010397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103981:	83 c0 13             	add    $0x13,%eax
80103984:	0f b6 00             	movzbl (%eax),%eax
80103987:	0f b6 c0             	movzbl %al,%eax
8010398a:	09 d0                	or     %edx,%eax
8010398c:	c1 e0 0a             	shl    $0xa,%eax
8010398f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103995:	2d 00 04 00 00       	sub    $0x400,%eax
8010399a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801039a1:	00 
801039a2:	89 04 24             	mov    %eax,(%esp)
801039a5:	e8 f5 fe ff ff       	call   8010389f <mpsearch1>
801039aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
801039ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801039b1:	74 05                	je     801039b8 <mpsearch+0xa4>
      return mp;
801039b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039b6:	eb 14                	jmp    801039cc <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801039b8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801039bf:	00 
801039c0:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801039c7:	e8 d3 fe ff ff       	call   8010389f <mpsearch1>
}
801039cc:	c9                   	leave  
801039cd:	c3                   	ret    

801039ce <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801039ce:	55                   	push   %ebp
801039cf:	89 e5                	mov    %esp,%ebp
801039d1:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801039d4:	e8 3b ff ff ff       	call   80103914 <mpsearch>
801039d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039e0:	74 0a                	je     801039ec <mpconfig+0x1e>
801039e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e5:	8b 40 04             	mov    0x4(%eax),%eax
801039e8:	85 c0                	test   %eax,%eax
801039ea:	75 0a                	jne    801039f6 <mpconfig+0x28>
    return 0;
801039ec:	b8 00 00 00 00       	mov    $0x0,%eax
801039f1:	e9 83 00 00 00       	jmp    80103a79 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f9:	8b 40 04             	mov    0x4(%eax),%eax
801039fc:	89 04 24             	mov    %eax,(%esp)
801039ff:	e8 fd fd ff ff       	call   80103801 <p2v>
80103a04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103a07:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a0e:	00 
80103a0f:	c7 44 24 04 ad 85 10 	movl   $0x801085ad,0x4(%esp)
80103a16:	80 
80103a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1a:	89 04 24             	mov    %eax,(%esp)
80103a1d:	e8 12 16 00 00       	call   80105034 <memcmp>
80103a22:	85 c0                	test   %eax,%eax
80103a24:	74 07                	je     80103a2d <mpconfig+0x5f>
    return 0;
80103a26:	b8 00 00 00 00       	mov    $0x0,%eax
80103a2b:	eb 4c                	jmp    80103a79 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a30:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103a34:	3c 01                	cmp    $0x1,%al
80103a36:	74 12                	je     80103a4a <mpconfig+0x7c>
80103a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a3b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103a3f:	3c 04                	cmp    $0x4,%al
80103a41:	74 07                	je     80103a4a <mpconfig+0x7c>
    return 0;
80103a43:	b8 00 00 00 00       	mov    $0x0,%eax
80103a48:	eb 2f                	jmp    80103a79 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103a51:	0f b7 c0             	movzwl %ax,%eax
80103a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a5b:	89 04 24             	mov    %eax,(%esp)
80103a5e:	e8 04 fe ff ff       	call   80103867 <sum>
80103a63:	84 c0                	test   %al,%al
80103a65:	74 07                	je     80103a6e <mpconfig+0xa0>
    return 0;
80103a67:	b8 00 00 00 00       	mov    $0x0,%eax
80103a6c:	eb 0b                	jmp    80103a79 <mpconfig+0xab>
  *pmp = mp;
80103a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a74:	89 10                	mov    %edx,(%eax)
  return conf;
80103a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a79:	c9                   	leave  
80103a7a:	c3                   	ret    

80103a7b <mpinit>:

void
mpinit(void)
{
80103a7b:	55                   	push   %ebp
80103a7c:	89 e5                	mov    %esp,%ebp
80103a7e:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103a81:	c7 05 44 b6 10 80 e0 	movl   $0x8010f9e0,0x8010b644
80103a88:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103a8b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103a8e:	89 04 24             	mov    %eax,(%esp)
80103a91:	e8 38 ff ff ff       	call   801039ce <mpconfig>
80103a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a9d:	75 05                	jne    80103aa4 <mpinit+0x29>
    return;
80103a9f:	e9 9c 01 00 00       	jmp    80103c40 <mpinit+0x1c5>
  ismp = 1;
80103aa4:	c7 05 c4 f9 10 80 01 	movl   $0x1,0x8010f9c4
80103aab:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab1:	8b 40 24             	mov    0x24(%eax),%eax
80103ab4:	a3 3c f9 10 80       	mov    %eax,0x8010f93c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abc:	83 c0 2c             	add    $0x2c,%eax
80103abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ac9:	0f b7 d0             	movzwl %ax,%edx
80103acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103acf:	01 d0                	add    %edx,%eax
80103ad1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ad4:	e9 f4 00 00 00       	jmp    80103bcd <mpinit+0x152>
    switch(*p){
80103ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adc:	0f b6 00             	movzbl (%eax),%eax
80103adf:	0f b6 c0             	movzbl %al,%eax
80103ae2:	83 f8 04             	cmp    $0x4,%eax
80103ae5:	0f 87 bf 00 00 00    	ja     80103baa <mpinit+0x12f>
80103aeb:	8b 04 85 f0 85 10 80 	mov    -0x7fef7a10(,%eax,4),%eax
80103af2:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103afd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103b01:	0f b6 d0             	movzbl %al,%edx
80103b04:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103b09:	39 c2                	cmp    %eax,%edx
80103b0b:	74 2d                	je     80103b3a <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103b0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103b14:	0f b6 d0             	movzbl %al,%edx
80103b17:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103b1c:	89 54 24 08          	mov    %edx,0x8(%esp)
80103b20:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b24:	c7 04 24 b2 85 10 80 	movl   $0x801085b2,(%esp)
80103b2b:	e8 70 c8 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103b30:	c7 05 c4 f9 10 80 00 	movl   $0x0,0x8010f9c4
80103b37:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103b3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b3d:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103b41:	0f b6 c0             	movzbl %al,%eax
80103b44:	83 e0 02             	and    $0x2,%eax
80103b47:	85 c0                	test   %eax,%eax
80103b49:	74 15                	je     80103b60 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103b4b:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103b50:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b56:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
80103b5b:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103b60:	8b 15 c0 ff 10 80    	mov    0x8010ffc0,%edx
80103b66:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103b6b:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103b71:	81 c2 e0 f9 10 80    	add    $0x8010f9e0,%edx
80103b77:	88 02                	mov    %al,(%edx)
      ncpu++;
80103b79:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103b7e:	83 c0 01             	add    $0x1,%eax
80103b81:	a3 c0 ff 10 80       	mov    %eax,0x8010ffc0
      p += sizeof(struct mpproc);
80103b86:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103b8a:	eb 41                	jmp    80103bcd <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103b92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103b95:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103b99:	a2 c0 f9 10 80       	mov    %al,0x8010f9c0
      p += sizeof(struct mpioapic);
80103b9e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ba2:	eb 29                	jmp    80103bcd <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ba4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ba8:	eb 23                	jmp    80103bcd <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bad:	0f b6 00             	movzbl (%eax),%eax
80103bb0:	0f b6 c0             	movzbl %al,%eax
80103bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bb7:	c7 04 24 d0 85 10 80 	movl   $0x801085d0,(%esp)
80103bbe:	e8 dd c7 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103bc3:	c7 05 c4 f9 10 80 00 	movl   $0x0,0x8010f9c4
80103bca:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bd3:	0f 82 00 ff ff ff    	jb     80103ad9 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103bd9:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80103bde:	85 c0                	test   %eax,%eax
80103be0:	75 1d                	jne    80103bff <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103be2:	c7 05 c0 ff 10 80 01 	movl   $0x1,0x8010ffc0
80103be9:	00 00 00 
    lapic = 0;
80103bec:	c7 05 3c f9 10 80 00 	movl   $0x0,0x8010f93c
80103bf3:	00 00 00 
    ioapicid = 0;
80103bf6:	c6 05 c0 f9 10 80 00 	movb   $0x0,0x8010f9c0
    return;
80103bfd:	eb 41                	jmp    80103c40 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103bff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c02:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103c06:	84 c0                	test   %al,%al
80103c08:	74 36                	je     80103c40 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103c0a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103c11:	00 
80103c12:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103c19:	e8 0d fc ff ff       	call   8010382b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103c1e:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c25:	e8 e4 fb ff ff       	call   8010380e <inb>
80103c2a:	83 c8 01             	or     $0x1,%eax
80103c2d:	0f b6 c0             	movzbl %al,%eax
80103c30:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c34:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c3b:	e8 eb fb ff ff       	call   8010382b <outb>
  }
}
80103c40:	c9                   	leave  
80103c41:	c3                   	ret    

80103c42 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103c42:	55                   	push   %ebp
80103c43:	89 e5                	mov    %esp,%ebp
80103c45:	83 ec 08             	sub    $0x8,%esp
80103c48:	8b 55 08             	mov    0x8(%ebp),%edx
80103c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c4e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103c52:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c55:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c59:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c5d:	ee                   	out    %al,(%dx)
}
80103c5e:	c9                   	leave  
80103c5f:	c3                   	ret    

80103c60 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103c60:	55                   	push   %ebp
80103c61:	89 e5                	mov    %esp,%ebp
80103c63:	83 ec 0c             	sub    $0xc,%esp
80103c66:	8b 45 08             	mov    0x8(%ebp),%eax
80103c69:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103c6d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103c71:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103c77:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103c7b:	0f b6 c0             	movzbl %al,%eax
80103c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c82:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103c89:	e8 b4 ff ff ff       	call   80103c42 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103c8e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103c92:	66 c1 e8 08          	shr    $0x8,%ax
80103c96:	0f b6 c0             	movzbl %al,%eax
80103c99:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c9d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ca4:	e8 99 ff ff ff       	call   80103c42 <outb>
}
80103ca9:	c9                   	leave  
80103caa:	c3                   	ret    

80103cab <picenable>:

void
picenable(int irq)
{
80103cab:	55                   	push   %ebp
80103cac:	89 e5                	mov    %esp,%ebp
80103cae:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb4:	ba 01 00 00 00       	mov    $0x1,%edx
80103cb9:	89 c1                	mov    %eax,%ecx
80103cbb:	d3 e2                	shl    %cl,%edx
80103cbd:	89 d0                	mov    %edx,%eax
80103cbf:	f7 d0                	not    %eax
80103cc1:	89 c2                	mov    %eax,%edx
80103cc3:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103cca:	21 d0                	and    %edx,%eax
80103ccc:	0f b7 c0             	movzwl %ax,%eax
80103ccf:	89 04 24             	mov    %eax,(%esp)
80103cd2:	e8 89 ff ff ff       	call   80103c60 <picsetmask>
}
80103cd7:	c9                   	leave  
80103cd8:	c3                   	ret    

80103cd9 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103cd9:	55                   	push   %ebp
80103cda:	89 e5                	mov    %esp,%ebp
80103cdc:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103cdf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ce6:	00 
80103ce7:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103cee:	e8 4f ff ff ff       	call   80103c42 <outb>
  outb(IO_PIC2+1, 0xFF);
80103cf3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cfa:	00 
80103cfb:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d02:	e8 3b ff ff ff       	call   80103c42 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103d07:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103d0e:	00 
80103d0f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103d16:	e8 27 ff ff ff       	call   80103c42 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103d1b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103d22:	00 
80103d23:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d2a:	e8 13 ff ff ff       	call   80103c42 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103d2f:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103d36:	00 
80103d37:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d3e:	e8 ff fe ff ff       	call   80103c42 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103d43:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103d4a:	00 
80103d4b:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d52:	e8 eb fe ff ff       	call   80103c42 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103d57:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103d5e:	00 
80103d5f:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103d66:	e8 d7 fe ff ff       	call   80103c42 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103d6b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103d72:	00 
80103d73:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d7a:	e8 c3 fe ff ff       	call   80103c42 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103d7f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103d86:	00 
80103d87:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d8e:	e8 af fe ff ff       	call   80103c42 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103d93:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103d9a:	00 
80103d9b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103da2:	e8 9b fe ff ff       	call   80103c42 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103da7:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103dae:	00 
80103daf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103db6:	e8 87 fe ff ff       	call   80103c42 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103dbb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103dc2:	00 
80103dc3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103dca:	e8 73 fe ff ff       	call   80103c42 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103dcf:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103dd6:	00 
80103dd7:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103dde:	e8 5f fe ff ff       	call   80103c42 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103de3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103dea:	00 
80103deb:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103df2:	e8 4b fe ff ff       	call   80103c42 <outb>

  if(irqmask != 0xFFFF)
80103df7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103dfe:	66 83 f8 ff          	cmp    $0xffff,%ax
80103e02:	74 12                	je     80103e16 <picinit+0x13d>
    picsetmask(irqmask);
80103e04:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e0b:	0f b7 c0             	movzwl %ax,%eax
80103e0e:	89 04 24             	mov    %eax,(%esp)
80103e11:	e8 4a fe ff ff       	call   80103c60 <picsetmask>
}
80103e16:	c9                   	leave  
80103e17:	c3                   	ret    

80103e18 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103e1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e31:	8b 10                	mov    (%eax),%edx
80103e33:	8b 45 08             	mov    0x8(%ebp),%eax
80103e36:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e38:	e8 dc d0 ff ff       	call   80100f19 <filealloc>
80103e3d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e40:	89 02                	mov    %eax,(%edx)
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	8b 00                	mov    (%eax),%eax
80103e47:	85 c0                	test   %eax,%eax
80103e49:	0f 84 c8 00 00 00    	je     80103f17 <pipealloc+0xff>
80103e4f:	e8 c5 d0 ff ff       	call   80100f19 <filealloc>
80103e54:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e57:	89 02                	mov    %eax,(%edx)
80103e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5c:	8b 00                	mov    (%eax),%eax
80103e5e:	85 c0                	test   %eax,%eax
80103e60:	0f 84 b1 00 00 00    	je     80103f17 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e66:	e8 b0 ee ff ff       	call   80102d1b <kalloc>
80103e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e72:	75 05                	jne    80103e79 <pipealloc+0x61>
    goto bad;
80103e74:	e9 9e 00 00 00       	jmp    80103f17 <pipealloc+0xff>
  p->readopen = 1;
80103e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e83:	00 00 00 
  p->writeopen = 1;
80103e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e89:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e90:	00 00 00 
  p->nwrite = 0;
80103e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e96:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e9d:	00 00 00 
  p->nread = 0;
80103ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103eaa:	00 00 00 
  initlock(&p->lock, "pipe");
80103ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb0:	c7 44 24 04 04 86 10 	movl   $0x80108604,0x4(%esp)
80103eb7:	80 
80103eb8:	89 04 24             	mov    %eax,(%esp)
80103ebb:	e8 88 0e 00 00       	call   80104d48 <initlock>
  (*f0)->type = FD_PIPE;
80103ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec3:	8b 00                	mov    (%eax),%eax
80103ec5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ece:	8b 00                	mov    (%eax),%eax
80103ed0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed7:	8b 00                	mov    (%eax),%eax
80103ed9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103edd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee0:	8b 00                	mov    (%eax),%eax
80103ee2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ee5:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eeb:	8b 00                	mov    (%eax),%eax
80103eed:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef6:	8b 00                	mov    (%eax),%eax
80103ef8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103efc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eff:	8b 00                	mov    (%eax),%eax
80103f01:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f08:	8b 00                	mov    (%eax),%eax
80103f0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f0d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f10:	b8 00 00 00 00       	mov    $0x0,%eax
80103f15:	eb 42                	jmp    80103f59 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103f17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1b:	74 0b                	je     80103f28 <pipealloc+0x110>
    kfree((char*)p);
80103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f20:	89 04 24             	mov    %eax,(%esp)
80103f23:	e8 5a ed ff ff       	call   80102c82 <kfree>
  if(*f0)
80103f28:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2b:	8b 00                	mov    (%eax),%eax
80103f2d:	85 c0                	test   %eax,%eax
80103f2f:	74 0d                	je     80103f3e <pipealloc+0x126>
    fileclose(*f0);
80103f31:	8b 45 08             	mov    0x8(%ebp),%eax
80103f34:	8b 00                	mov    (%eax),%eax
80103f36:	89 04 24             	mov    %eax,(%esp)
80103f39:	e8 83 d0 ff ff       	call   80100fc1 <fileclose>
  if(*f1)
80103f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f41:	8b 00                	mov    (%eax),%eax
80103f43:	85 c0                	test   %eax,%eax
80103f45:	74 0d                	je     80103f54 <pipealloc+0x13c>
    fileclose(*f1);
80103f47:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4a:	8b 00                	mov    (%eax),%eax
80103f4c:	89 04 24             	mov    %eax,(%esp)
80103f4f:	e8 6d d0 ff ff       	call   80100fc1 <fileclose>
  return -1;
80103f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f59:	c9                   	leave  
80103f5a:	c3                   	ret    

80103f5b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f5b:	55                   	push   %ebp
80103f5c:	89 e5                	mov    %esp,%ebp
80103f5e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103f61:	8b 45 08             	mov    0x8(%ebp),%eax
80103f64:	89 04 24             	mov    %eax,(%esp)
80103f67:	e8 fd 0d 00 00       	call   80104d69 <acquire>
  if(writable){
80103f6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f70:	74 1f                	je     80103f91 <pipeclose+0x36>
    p->writeopen = 0;
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f7c:	00 00 00 
    wakeup(&p->nread);
80103f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f82:	05 34 02 00 00       	add    $0x234,%eax
80103f87:	89 04 24             	mov    %eax,(%esp)
80103f8a:	e8 e9 0b 00 00       	call   80104b78 <wakeup>
80103f8f:	eb 1d                	jmp    80103fae <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103f91:	8b 45 08             	mov    0x8(%ebp),%eax
80103f94:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f9b:	00 00 00 
    wakeup(&p->nwrite);
80103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa1:	05 38 02 00 00       	add    $0x238,%eax
80103fa6:	89 04 24             	mov    %eax,(%esp)
80103fa9:	e8 ca 0b 00 00       	call   80104b78 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103fae:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fb7:	85 c0                	test   %eax,%eax
80103fb9:	75 25                	jne    80103fe0 <pipeclose+0x85>
80103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbe:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fc4:	85 c0                	test   %eax,%eax
80103fc6:	75 18                	jne    80103fe0 <pipeclose+0x85>
    release(&p->lock);
80103fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcb:	89 04 24             	mov    %eax,(%esp)
80103fce:	e8 f8 0d 00 00       	call   80104dcb <release>
    kfree((char*)p);
80103fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd6:	89 04 24             	mov    %eax,(%esp)
80103fd9:	e8 a4 ec ff ff       	call   80102c82 <kfree>
80103fde:	eb 0b                	jmp    80103feb <pipeclose+0x90>
  } else
    release(&p->lock);
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	89 04 24             	mov    %eax,(%esp)
80103fe6:	e8 e0 0d 00 00       	call   80104dcb <release>
}
80103feb:	c9                   	leave  
80103fec:	c3                   	ret    

80103fed <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fed:	55                   	push   %ebp
80103fee:	89 e5                	mov    %esp,%ebp
80103ff0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff6:	89 04 24             	mov    %eax,(%esp)
80103ff9:	e8 6b 0d 00 00       	call   80104d69 <acquire>
  for(i = 0; i < n; i++){
80103ffe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104005:	e9 a6 00 00 00       	jmp    801040b0 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010400a:	eb 57                	jmp    80104063 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
8010400c:	8b 45 08             	mov    0x8(%ebp),%eax
8010400f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104015:	85 c0                	test   %eax,%eax
80104017:	74 0d                	je     80104026 <pipewrite+0x39>
80104019:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010401f:	8b 40 24             	mov    0x24(%eax),%eax
80104022:	85 c0                	test   %eax,%eax
80104024:	74 15                	je     8010403b <pipewrite+0x4e>
        release(&p->lock);
80104026:	8b 45 08             	mov    0x8(%ebp),%eax
80104029:	89 04 24             	mov    %eax,(%esp)
8010402c:	e8 9a 0d 00 00       	call   80104dcb <release>
        return -1;
80104031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104036:	e9 9f 00 00 00       	jmp    801040da <pipewrite+0xed>
      }
      wakeup(&p->nread);
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	05 34 02 00 00       	add    $0x234,%eax
80104043:	89 04 24             	mov    %eax,(%esp)
80104046:	e8 2d 0b 00 00       	call   80104b78 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010404b:	8b 45 08             	mov    0x8(%ebp),%eax
8010404e:	8b 55 08             	mov    0x8(%ebp),%edx
80104051:	81 c2 38 02 00 00    	add    $0x238,%edx
80104057:	89 44 24 04          	mov    %eax,0x4(%esp)
8010405b:	89 14 24             	mov    %edx,(%esp)
8010405e:	e8 3c 0a 00 00       	call   80104a9f <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104063:	8b 45 08             	mov    0x8(%ebp),%eax
80104066:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104075:	05 00 02 00 00       	add    $0x200,%eax
8010407a:	39 c2                	cmp    %eax,%edx
8010407c:	74 8e                	je     8010400c <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104087:	8d 48 01             	lea    0x1(%eax),%ecx
8010408a:	8b 55 08             	mov    0x8(%ebp),%edx
8010408d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104093:	25 ff 01 00 00       	and    $0x1ff,%eax
80104098:	89 c1                	mov    %eax,%ecx
8010409a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409d:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a0:	01 d0                	add    %edx,%eax
801040a2:	0f b6 10             	movzbl (%eax),%edx
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801040ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801040b6:	0f 8c 4e ff ff ff    	jl     8010400a <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040bc:	8b 45 08             	mov    0x8(%ebp),%eax
801040bf:	05 34 02 00 00       	add    $0x234,%eax
801040c4:	89 04 24             	mov    %eax,(%esp)
801040c7:	e8 ac 0a 00 00       	call   80104b78 <wakeup>
  release(&p->lock);
801040cc:	8b 45 08             	mov    0x8(%ebp),%eax
801040cf:	89 04 24             	mov    %eax,(%esp)
801040d2:	e8 f4 0c 00 00       	call   80104dcb <release>
  return n;
801040d7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040da:	c9                   	leave  
801040db:	c3                   	ret    

801040dc <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	53                   	push   %ebx
801040e0:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801040e3:	8b 45 08             	mov    0x8(%ebp),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 7b 0c 00 00       	call   80104d69 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040ee:	eb 3a                	jmp    8010412a <piperead+0x4e>
    if(proc->killed){
801040f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801040f6:	8b 40 24             	mov    0x24(%eax),%eax
801040f9:	85 c0                	test   %eax,%eax
801040fb:	74 15                	je     80104112 <piperead+0x36>
      release(&p->lock);
801040fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104100:	89 04 24             	mov    %eax,(%esp)
80104103:	e8 c3 0c 00 00       	call   80104dcb <release>
      return -1;
80104108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410d:	e9 b5 00 00 00       	jmp    801041c7 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104112:	8b 45 08             	mov    0x8(%ebp),%eax
80104115:	8b 55 08             	mov    0x8(%ebp),%edx
80104118:	81 c2 34 02 00 00    	add    $0x234,%edx
8010411e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104122:	89 14 24             	mov    %edx,(%esp)
80104125:	e8 75 09 00 00       	call   80104a9f <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010413c:	39 c2                	cmp    %eax,%edx
8010413e:	75 0d                	jne    8010414d <piperead+0x71>
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	75 a3                	jne    801040f0 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010414d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104154:	eb 4b                	jmp    801041a1 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104168:	39 c2                	cmp    %eax,%edx
8010416a:	75 02                	jne    8010416e <piperead+0x92>
      break;
8010416c:	eb 3b                	jmp    801041a9 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010416e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104171:	8b 45 0c             	mov    0xc(%ebp),%eax
80104174:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104177:	8b 45 08             	mov    0x8(%ebp),%eax
8010417a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104180:	8d 48 01             	lea    0x1(%eax),%ecx
80104183:	8b 55 08             	mov    0x8(%ebp),%edx
80104186:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010418c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104191:	89 c2                	mov    %eax,%edx
80104193:	8b 45 08             	mov    0x8(%ebp),%eax
80104196:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010419b:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010419d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801041a7:	7c ad                	jl     80104156 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	05 38 02 00 00       	add    $0x238,%eax
801041b1:	89 04 24             	mov    %eax,(%esp)
801041b4:	e8 bf 09 00 00       	call   80104b78 <wakeup>
  release(&p->lock);
801041b9:	8b 45 08             	mov    0x8(%ebp),%eax
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 07 0c 00 00       	call   80104dcb <release>
  return i;
801041c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041c7:	83 c4 24             	add    $0x24,%esp
801041ca:	5b                   	pop    %ebx
801041cb:	5d                   	pop    %ebp
801041cc:	c3                   	ret    

801041cd <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801041cd:	55                   	push   %ebp
801041ce:	89 e5                	mov    %esp,%ebp
801041d0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041d3:	9c                   	pushf  
801041d4:	58                   	pop    %eax
801041d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041db:	c9                   	leave  
801041dc:	c3                   	ret    

801041dd <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801041dd:	55                   	push   %ebp
801041de:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041e0:	fb                   	sti    
}
801041e1:	5d                   	pop    %ebp
801041e2:	c3                   	ret    

801041e3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801041e3:	55                   	push   %ebp
801041e4:	89 e5                	mov    %esp,%ebp
801041e6:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801041e9:	c7 44 24 04 09 86 10 	movl   $0x80108609,0x4(%esp)
801041f0:	80 
801041f1:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
801041f8:	e8 4b 0b 00 00       	call   80104d48 <initlock>
}
801041fd:	c9                   	leave  
801041fe:	c3                   	ret    

801041ff <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801041ff:	55                   	push   %ebp
80104200:	89 e5                	mov    %esp,%ebp
80104202:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104205:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010420c:	e8 58 0b 00 00       	call   80104d69 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104211:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104218:	eb 50                	jmp    8010426a <allocproc+0x6b>
    if(p->state == UNUSED)
8010421a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421d:	8b 40 0c             	mov    0xc(%eax),%eax
80104220:	85 c0                	test   %eax,%eax
80104222:	75 42                	jne    80104266 <allocproc+0x67>
      goto found;
80104224:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010422f:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104234:	8d 50 01             	lea    0x1(%eax),%edx
80104237:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
8010423d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104240:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104243:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010424a:	e8 7c 0b 00 00       	call   80104dcb <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010424f:	e8 c7 ea ff ff       	call   80102d1b <kalloc>
80104254:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104257:	89 42 08             	mov    %eax,0x8(%edx)
8010425a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425d:	8b 40 08             	mov    0x8(%eax),%eax
80104260:	85 c0                	test   %eax,%eax
80104262:	75 33                	jne    80104297 <allocproc+0x98>
80104264:	eb 20                	jmp    80104286 <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104266:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010426a:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104271:	72 a7                	jb     8010421a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104273:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010427a:	e8 4c 0b 00 00       	call   80104dcb <release>
  return 0;
8010427f:	b8 00 00 00 00       	mov    $0x0,%eax
80104284:	eb 76                	jmp    801042fc <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104289:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104290:	b8 00 00 00 00       	mov    $0x0,%eax
80104295:	eb 65                	jmp    801042fc <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429a:	8b 40 08             	mov    0x8(%eax),%eax
8010429d:	05 00 10 00 00       	add    $0x1000,%eax
801042a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801042a5:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801042a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042af:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801042b2:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801042b6:	ba f3 63 10 80       	mov    $0x801063f3,%edx
801042bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042be:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801042c0:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801042c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042ca:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	8b 40 1c             	mov    0x1c(%eax),%eax
801042d3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801042da:	00 
801042db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042e2:	00 
801042e3:	89 04 24             	mov    %eax,(%esp)
801042e6:	e8 d2 0c 00 00       	call   80104fbd <memset>
  p->context->eip = (uint)forkret;
801042eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f1:	ba 73 4a 10 80       	mov    $0x80104a73,%edx
801042f6:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042fc:	c9                   	leave  
801042fd:	c3                   	ret    

801042fe <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801042fe:	55                   	push   %ebp
801042ff:	89 e5                	mov    %esp,%ebp
80104301:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104304:	e8 f6 fe ff ff       	call   801041ff <allocproc>
80104309:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104314:	c7 04 24 1b 2d 10 80 	movl   $0x80102d1b,(%esp)
8010431b:	e8 c7 37 00 00       	call   80107ae7 <setupkvm>
80104320:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104323:	89 42 04             	mov    %eax,0x4(%edx)
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104329:	8b 40 04             	mov    0x4(%eax),%eax
8010432c:	85 c0                	test   %eax,%eax
8010432e:	75 0c                	jne    8010433c <userinit+0x3e>
    panic("userinit: out of memory?");
80104330:	c7 04 24 10 86 10 80 	movl   $0x80108610,(%esp)
80104337:	e8 fe c1 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010433c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104344:	8b 40 04             	mov    0x4(%eax),%eax
80104347:	89 54 24 08          	mov    %edx,0x8(%esp)
8010434b:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104352:	80 
80104353:	89 04 24             	mov    %eax,(%esp)
80104356:	e8 e4 39 00 00       	call   80107d3f <inituvm>
  p->sz = PGSIZE;
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104367:	8b 40 18             	mov    0x18(%eax),%eax
8010436a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104371:	00 
80104372:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104379:	00 
8010437a:	89 04 24             	mov    %eax,(%esp)
8010437d:	e8 3b 0c 00 00       	call   80104fbd <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	8b 40 18             	mov    0x18(%eax),%eax
80104388:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010438e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104391:	8b 40 18             	mov    0x18(%eax),%eax
80104394:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439d:	8b 40 18             	mov    0x18(%eax),%eax
801043a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a3:	8b 52 18             	mov    0x18(%edx),%edx
801043a6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801043aa:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	8b 40 18             	mov    0x18(%eax),%eax
801043b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b7:	8b 52 18             	mov    0x18(%edx),%edx
801043ba:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801043be:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801043c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c5:	8b 40 18             	mov    0x18(%eax),%eax
801043c8:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 18             	mov    0x18(%eax),%eax
801043d5:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801043dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043df:	8b 40 18             	mov    0x18(%eax),%eax
801043e2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ec:	83 c0 6c             	add    $0x6c,%eax
801043ef:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801043f6:	00 
801043f7:	c7 44 24 04 29 86 10 	movl   $0x80108629,0x4(%esp)
801043fe:	80 
801043ff:	89 04 24             	mov    %eax,(%esp)
80104402:	e8 d6 0d 00 00       	call   801051dd <safestrcpy>
  p->cwd = namei("/");
80104407:	c7 04 24 32 86 10 80 	movl   $0x80108632,(%esp)
8010440e:	e8 2c e2 ff ff       	call   8010263f <namei>
80104413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104416:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104423:	c9                   	leave  
80104424:	c3                   	ret    

80104425 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104425:	55                   	push   %ebp
80104426:	89 e5                	mov    %esp,%ebp
80104428:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010442b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104431:	8b 00                	mov    (%eax),%eax
80104433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104436:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010443a:	7e 34                	jle    80104470 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010443c:	8b 55 08             	mov    0x8(%ebp),%edx
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104442:	01 c2                	add    %eax,%edx
80104444:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010444a:	8b 40 04             	mov    0x4(%eax),%eax
8010444d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104451:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104454:	89 54 24 04          	mov    %edx,0x4(%esp)
80104458:	89 04 24             	mov    %eax,(%esp)
8010445b:	e8 55 3a 00 00       	call   80107eb5 <allocuvm>
80104460:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104467:	75 41                	jne    801044aa <growproc+0x85>
      return -1;
80104469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446e:	eb 58                	jmp    801044c8 <growproc+0xa3>
  } else if(n < 0){
80104470:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104474:	79 34                	jns    801044aa <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104476:	8b 55 08             	mov    0x8(%ebp),%edx
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	01 c2                	add    %eax,%edx
8010447e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104484:	8b 40 04             	mov    0x4(%eax),%eax
80104487:	89 54 24 08          	mov    %edx,0x8(%esp)
8010448b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104492:	89 04 24             	mov    %eax,(%esp)
80104495:	e8 f5 3a 00 00       	call   80107f8f <deallocuvm>
8010449a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010449d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044a1:	75 07                	jne    801044aa <growproc+0x85>
      return -1;
801044a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044a8:	eb 1e                	jmp    801044c8 <growproc+0xa3>
  }
  proc->sz = sz;
801044aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b3:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801044b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044bb:	89 04 24             	mov    %eax,(%esp)
801044be:	e8 15 37 00 00       	call   80107bd8 <switchuvm>
  return 0;
801044c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044c8:	c9                   	leave  
801044c9:	c3                   	ret    

801044ca <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801044ca:	55                   	push   %ebp
801044cb:	89 e5                	mov    %esp,%ebp
801044cd:	57                   	push   %edi
801044ce:	56                   	push   %esi
801044cf:	53                   	push   %ebx
801044d0:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801044d3:	e8 27 fd ff ff       	call   801041ff <allocproc>
801044d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801044db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801044df:	75 0a                	jne    801044eb <fork+0x21>
    return -1;
801044e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e6:	e9 3a 01 00 00       	jmp    80104625 <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801044eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f1:	8b 10                	mov    (%eax),%edx
801044f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f9:	8b 40 04             	mov    0x4(%eax),%eax
801044fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80104500:	89 04 24             	mov    %eax,(%esp)
80104503:	e8 23 3c 00 00       	call   8010812b <copyuvm>
80104508:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010450b:	89 42 04             	mov    %eax,0x4(%edx)
8010450e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104511:	8b 40 04             	mov    0x4(%eax),%eax
80104514:	85 c0                	test   %eax,%eax
80104516:	75 2c                	jne    80104544 <fork+0x7a>
    kfree(np->kstack);
80104518:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010451b:	8b 40 08             	mov    0x8(%eax),%eax
8010451e:	89 04 24             	mov    %eax,(%esp)
80104521:	e8 5c e7 ff ff       	call   80102c82 <kfree>
    np->kstack = 0;
80104526:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104529:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104530:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104533:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010453a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010453f:	e9 e1 00 00 00       	jmp    80104625 <fork+0x15b>
  }
  np->sz = proc->sz;
80104544:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010454a:	8b 10                	mov    (%eax),%edx
8010454c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010454f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104551:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104558:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010455b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010455e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104561:	8b 50 18             	mov    0x18(%eax),%edx
80104564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010456a:	8b 40 18             	mov    0x18(%eax),%eax
8010456d:	89 c3                	mov    %eax,%ebx
8010456f:	b8 13 00 00 00       	mov    $0x13,%eax
80104574:	89 d7                	mov    %edx,%edi
80104576:	89 de                	mov    %ebx,%esi
80104578:	89 c1                	mov    %eax,%ecx
8010457a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010457c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010457f:	8b 40 18             	mov    0x18(%eax),%eax
80104582:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104589:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104590:	eb 3d                	jmp    801045cf <fork+0x105>
    if(proc->ofile[i])
80104592:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010459b:	83 c2 08             	add    $0x8,%edx
8010459e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045a2:	85 c0                	test   %eax,%eax
801045a4:	74 25                	je     801045cb <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801045a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801045af:	83 c2 08             	add    $0x8,%edx
801045b2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045b6:	89 04 24             	mov    %eax,(%esp)
801045b9:	e8 bb c9 ff ff       	call   80100f79 <filedup>
801045be:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801045c4:	83 c1 08             	add    $0x8,%ecx
801045c7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801045cb:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801045cf:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801045d3:	7e bd                	jle    80104592 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801045d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045db:	8b 40 68             	mov    0x68(%eax),%eax
801045de:	89 04 24             	mov    %eax,(%esp)
801045e1:	e8 36 d2 ff ff       	call   8010181c <idup>
801045e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045e9:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801045ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045ef:	8b 40 10             	mov    0x10(%eax),%eax
801045f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801045f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045f8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
801045ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104605:	8d 50 6c             	lea    0x6c(%eax),%edx
80104608:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010460b:	83 c0 6c             	add    $0x6c,%eax
8010460e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104615:	00 
80104616:	89 54 24 04          	mov    %edx,0x4(%esp)
8010461a:	89 04 24             	mov    %eax,(%esp)
8010461d:	e8 bb 0b 00 00       	call   801051dd <safestrcpy>
  return pid;
80104622:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104625:	83 c4 2c             	add    $0x2c,%esp
80104628:	5b                   	pop    %ebx
80104629:	5e                   	pop    %esi
8010462a:	5f                   	pop    %edi
8010462b:	5d                   	pop    %ebp
8010462c:	c3                   	ret    

8010462d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010462d:	55                   	push   %ebp
8010462e:	89 e5                	mov    %esp,%ebp
80104630:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104633:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010463a:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010463f:	39 c2                	cmp    %eax,%edx
80104641:	75 0c                	jne    8010464f <exit+0x22>
    panic("init exiting");
80104643:	c7 04 24 34 86 10 80 	movl   $0x80108634,(%esp)
8010464a:	e8 eb be ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010464f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104656:	eb 44                	jmp    8010469c <exit+0x6f>
    if(proc->ofile[fd]){
80104658:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104661:	83 c2 08             	add    $0x8,%edx
80104664:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104668:	85 c0                	test   %eax,%eax
8010466a:	74 2c                	je     80104698 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010466c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104672:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104675:	83 c2 08             	add    $0x8,%edx
80104678:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010467c:	89 04 24             	mov    %eax,(%esp)
8010467f:	e8 3d c9 ff ff       	call   80100fc1 <fileclose>
      proc->ofile[fd] = 0;
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010468d:	83 c2 08             	add    $0x8,%edx
80104690:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104697:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104698:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010469c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801046a0:	7e b6                	jle    80104658 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801046a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a8:	8b 40 68             	mov    0x68(%eax),%eax
801046ab:	89 04 24             	mov    %eax,(%esp)
801046ae:	e8 4e d3 ff ff       	call   80101a01 <iput>
  proc->cwd = 0;
801046b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801046c0:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
801046c7:	e8 9d 06 00 00       	call   80104d69 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801046cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d2:	8b 40 14             	mov    0x14(%eax),%eax
801046d5:	89 04 24             	mov    %eax,(%esp)
801046d8:	e8 5d 04 00 00       	call   80104b3a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046dd:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
801046e4:	eb 38                	jmp    8010471e <exit+0xf1>
    if(p->parent == proc){
801046e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e9:	8b 50 14             	mov    0x14(%eax),%edx
801046ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f2:	39 c2                	cmp    %eax,%edx
801046f4:	75 24                	jne    8010471a <exit+0xed>
      p->parent = initproc;
801046f6:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104705:	8b 40 0c             	mov    0xc(%eax),%eax
80104708:	83 f8 05             	cmp    $0x5,%eax
8010470b:	75 0d                	jne    8010471a <exit+0xed>
        wakeup1(initproc);
8010470d:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104712:	89 04 24             	mov    %eax,(%esp)
80104715:	e8 20 04 00 00       	call   80104b3a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010471a:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010471e:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104725:	72 bf                	jb     801046e6 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104727:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104734:	e8 56 02 00 00       	call   8010498f <sched>
  panic("zombie exit");
80104739:	c7 04 24 41 86 10 80 	movl   $0x80108641,(%esp)
80104740:	e8 f5 bd ff ff       	call   8010053a <panic>

80104745 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104745:	55                   	push   %ebp
80104746:	89 e5                	mov    %esp,%ebp
80104748:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010474b:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104752:	e8 12 06 00 00       	call   80104d69 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104757:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010475e:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104765:	e9 9a 00 00 00       	jmp    80104804 <wait+0xbf>
      if(p->parent != proc)
8010476a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476d:	8b 50 14             	mov    0x14(%eax),%edx
80104770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104776:	39 c2                	cmp    %eax,%edx
80104778:	74 05                	je     8010477f <wait+0x3a>
        continue;
8010477a:	e9 81 00 00 00       	jmp    80104800 <wait+0xbb>
      havekids = 1;
8010477f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104789:	8b 40 0c             	mov    0xc(%eax),%eax
8010478c:	83 f8 05             	cmp    $0x5,%eax
8010478f:	75 6f                	jne    80104800 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	8b 40 10             	mov    0x10(%eax),%eax
80104797:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479d:	8b 40 08             	mov    0x8(%eax),%eax
801047a0:	89 04 24             	mov    %eax,(%esp)
801047a3:	e8 da e4 ff ff       	call   80102c82 <kfree>
        p->kstack = 0;
801047a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801047b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b5:	8b 40 04             	mov    0x4(%eax),%eax
801047b8:	89 04 24             	mov    %eax,(%esp)
801047bb:	e8 8b 38 00 00       	call   8010804b <freevm>
        p->state = UNUSED;
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801047ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801047d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801047de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801047ef:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
801047f6:	e8 d0 05 00 00       	call   80104dcb <release>
        return pid;
801047fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047fe:	eb 52                	jmp    80104852 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104800:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104804:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
8010480b:	0f 82 59 ff ff ff    	jb     8010476a <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104811:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104815:	74 0d                	je     80104824 <wait+0xdf>
80104817:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481d:	8b 40 24             	mov    0x24(%eax),%eax
80104820:	85 c0                	test   %eax,%eax
80104822:	74 13                	je     80104837 <wait+0xf2>
      release(&ptable.lock);
80104824:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010482b:	e8 9b 05 00 00       	call   80104dcb <release>
      return -1;
80104830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104835:	eb 1b                	jmp    80104852 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104837:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483d:	c7 44 24 04 e0 ff 10 	movl   $0x8010ffe0,0x4(%esp)
80104844:	80 
80104845:	89 04 24             	mov    %eax,(%esp)
80104848:	e8 52 02 00 00       	call   80104a9f <sleep>
  }
8010484d:	e9 05 ff ff ff       	jmp    80104757 <wait+0x12>
}
80104852:	c9                   	leave  
80104853:	c3                   	ret    

80104854 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104854:	55                   	push   %ebp
80104855:	89 e5                	mov    %esp,%ebp
80104857:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
8010485a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104860:	8b 40 18             	mov    0x18(%eax),%eax
80104863:	8b 40 44             	mov    0x44(%eax),%eax
80104866:	89 c2                	mov    %eax,%edx
80104868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486e:	8b 40 04             	mov    0x4(%eax),%eax
80104871:	89 54 24 04          	mov    %edx,0x4(%esp)
80104875:	89 04 24             	mov    %eax,(%esp)
80104878:	e8 bf 39 00 00       	call   8010823c <uva2ka>
8010487d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104880:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104886:	8b 40 18             	mov    0x18(%eax),%eax
80104889:	8b 40 44             	mov    0x44(%eax),%eax
8010488c:	25 ff 0f 00 00       	and    $0xfff,%eax
80104891:	85 c0                	test   %eax,%eax
80104893:	75 0c                	jne    801048a1 <register_handler+0x4d>
    panic("esp_offset == 0");
80104895:	c7 04 24 4d 86 10 80 	movl   $0x8010864d,(%esp)
8010489c:	e8 99 bc ff ff       	call   8010053a <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
801048a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a7:	8b 40 18             	mov    0x18(%eax),%eax
801048aa:	8b 40 44             	mov    0x44(%eax),%eax
801048ad:	83 e8 04             	sub    $0x4,%eax
801048b0:	25 ff 0f 00 00       	and    $0xfff,%eax
801048b5:	89 c2                	mov    %eax,%edx
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	01 c2                	add    %eax,%edx
          = proc->tf->eip;
801048bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c2:	8b 40 18             	mov    0x18(%eax),%eax
801048c5:	8b 40 38             	mov    0x38(%eax),%eax
801048c8:	89 02                	mov    %eax,(%edx)
  proc->tf->esp -= 4;
801048ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d0:	8b 40 18             	mov    0x18(%eax),%eax
801048d3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048da:	8b 52 18             	mov    0x18(%edx),%edx
801048dd:	8b 52 44             	mov    0x44(%edx),%edx
801048e0:	83 ea 04             	sub    $0x4,%edx
801048e3:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	8b 40 18             	mov    0x18(%eax),%eax
801048ef:	8b 55 08             	mov    0x8(%ebp),%edx
801048f2:	89 50 38             	mov    %edx,0x38(%eax)
}
801048f5:	c9                   	leave  
801048f6:	c3                   	ret    

801048f7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801048f7:	55                   	push   %ebp
801048f8:	89 e5                	mov    %esp,%ebp
801048fa:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801048fd:	e8 db f8 ff ff       	call   801041dd <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104902:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104909:	e8 5b 04 00 00       	call   80104d69 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010490e:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104915:	eb 5e                	jmp    80104975 <scheduler+0x7e>
      if(p->state != RUNNABLE)
80104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491a:	8b 40 0c             	mov    0xc(%eax),%eax
8010491d:	83 f8 03             	cmp    $0x3,%eax
80104920:	74 02                	je     80104924 <scheduler+0x2d>
        continue;
80104922:	eb 4d                	jmp    80104971 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010492d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104930:	89 04 24             	mov    %eax,(%esp)
80104933:	e8 a0 32 00 00       	call   80107bd8 <switchuvm>
      p->state = RUNNING;
80104938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 40 1c             	mov    0x1c(%eax),%eax
8010494b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104952:	83 c2 04             	add    $0x4,%edx
80104955:	89 44 24 04          	mov    %eax,0x4(%esp)
80104959:	89 14 24             	mov    %edx,(%esp)
8010495c:	e8 ed 08 00 00       	call   8010524e <swtch>
      switchkvm();
80104961:	e8 55 32 00 00       	call   80107bbb <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104966:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010496d:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104971:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104975:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
8010497c:	72 99                	jb     80104917 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010497e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104985:	e8 41 04 00 00       	call   80104dcb <release>

  }
8010498a:	e9 6e ff ff ff       	jmp    801048fd <scheduler+0x6>

8010498f <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010498f:	55                   	push   %ebp
80104990:	89 e5                	mov    %esp,%ebp
80104992:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104995:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010499c:	e8 f2 04 00 00       	call   80104e93 <holding>
801049a1:	85 c0                	test   %eax,%eax
801049a3:	75 0c                	jne    801049b1 <sched+0x22>
    panic("sched ptable.lock");
801049a5:	c7 04 24 5d 86 10 80 	movl   $0x8010865d,(%esp)
801049ac:	e8 89 bb ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
801049b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801049b7:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801049bd:	83 f8 01             	cmp    $0x1,%eax
801049c0:	74 0c                	je     801049ce <sched+0x3f>
    panic("sched locks");
801049c2:	c7 04 24 6f 86 10 80 	movl   $0x8010866f,(%esp)
801049c9:	e8 6c bb ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
801049ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d4:	8b 40 0c             	mov    0xc(%eax),%eax
801049d7:	83 f8 04             	cmp    $0x4,%eax
801049da:	75 0c                	jne    801049e8 <sched+0x59>
    panic("sched running");
801049dc:	c7 04 24 7b 86 10 80 	movl   $0x8010867b,(%esp)
801049e3:	e8 52 bb ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
801049e8:	e8 e0 f7 ff ff       	call   801041cd <readeflags>
801049ed:	25 00 02 00 00       	and    $0x200,%eax
801049f2:	85 c0                	test   %eax,%eax
801049f4:	74 0c                	je     80104a02 <sched+0x73>
    panic("sched interruptible");
801049f6:	c7 04 24 89 86 10 80 	movl   $0x80108689,(%esp)
801049fd:	e8 38 bb ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104a02:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a08:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104a11:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a17:	8b 40 04             	mov    0x4(%eax),%eax
80104a1a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a21:	83 c2 1c             	add    $0x1c,%edx
80104a24:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a28:	89 14 24             	mov    %edx,(%esp)
80104a2b:	e8 1e 08 00 00       	call   8010524e <swtch>
  cpu->intena = intena;
80104a30:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a39:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104a3f:	c9                   	leave  
80104a40:	c3                   	ret    

80104a41 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a41:	55                   	push   %ebp
80104a42:	89 e5                	mov    %esp,%ebp
80104a44:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a47:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104a4e:	e8 16 03 00 00       	call   80104d69 <acquire>
  proc->state = RUNNABLE;
80104a53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a59:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a60:	e8 2a ff ff ff       	call   8010498f <sched>
  release(&ptable.lock);
80104a65:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104a6c:	e8 5a 03 00 00       	call   80104dcb <release>
}
80104a71:	c9                   	leave  
80104a72:	c3                   	ret    

80104a73 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a73:	55                   	push   %ebp
80104a74:	89 e5                	mov    %esp,%ebp
80104a76:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a79:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104a80:	e8 46 03 00 00       	call   80104dcb <release>

  if (first) {
80104a85:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	74 0f                	je     80104a9d <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104a8e:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104a95:	00 00 00 
    initlog();
80104a98:	e8 73 e7 ff ff       	call   80103210 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104a9d:	c9                   	leave  
80104a9e:	c3                   	ret    

80104a9f <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a9f:	55                   	push   %ebp
80104aa0:	89 e5                	mov    %esp,%ebp
80104aa2:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104aa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aab:	85 c0                	test   %eax,%eax
80104aad:	75 0c                	jne    80104abb <sleep+0x1c>
    panic("sleep");
80104aaf:	c7 04 24 9d 86 10 80 	movl   $0x8010869d,(%esp)
80104ab6:	e8 7f ba ff ff       	call   8010053a <panic>

  if(lk == 0)
80104abb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104abf:	75 0c                	jne    80104acd <sleep+0x2e>
    panic("sleep without lk");
80104ac1:	c7 04 24 a3 86 10 80 	movl   $0x801086a3,(%esp)
80104ac8:	e8 6d ba ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104acd:	81 7d 0c e0 ff 10 80 	cmpl   $0x8010ffe0,0xc(%ebp)
80104ad4:	74 17                	je     80104aed <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ad6:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104add:	e8 87 02 00 00       	call   80104d69 <acquire>
    release(lk);
80104ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae5:	89 04 24             	mov    %eax,(%esp)
80104ae8:	e8 de 02 00 00       	call   80104dcb <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104aed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af3:	8b 55 08             	mov    0x8(%ebp),%edx
80104af6:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104af9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aff:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104b06:	e8 84 fe ff ff       	call   8010498f <sched>

  // Tidy up.
  proc->chan = 0;
80104b0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b11:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b18:	81 7d 0c e0 ff 10 80 	cmpl   $0x8010ffe0,0xc(%ebp)
80104b1f:	74 17                	je     80104b38 <sleep+0x99>
    release(&ptable.lock);
80104b21:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104b28:	e8 9e 02 00 00       	call   80104dcb <release>
    acquire(lk);
80104b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b30:	89 04 24             	mov    %eax,(%esp)
80104b33:	e8 31 02 00 00       	call   80104d69 <acquire>
  }
}
80104b38:	c9                   	leave  
80104b39:	c3                   	ret    

80104b3a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b3a:	55                   	push   %ebp
80104b3b:	89 e5                	mov    %esp,%ebp
80104b3d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b40:	c7 45 fc 14 00 11 80 	movl   $0x80110014,-0x4(%ebp)
80104b47:	eb 24                	jmp    80104b6d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104b49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104b4f:	83 f8 02             	cmp    $0x2,%eax
80104b52:	75 15                	jne    80104b69 <wakeup1+0x2f>
80104b54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b57:	8b 40 20             	mov    0x20(%eax),%eax
80104b5a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b5d:	75 0a                	jne    80104b69 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b62:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b69:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104b6d:	81 7d fc 14 1f 11 80 	cmpl   $0x80111f14,-0x4(%ebp)
80104b74:	72 d3                	jb     80104b49 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104b76:	c9                   	leave  
80104b77:	c3                   	ret    

80104b78 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
80104b7b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104b7e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104b85:	e8 df 01 00 00       	call   80104d69 <acquire>
  wakeup1(chan);
80104b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8d:	89 04 24             	mov    %eax,(%esp)
80104b90:	e8 a5 ff ff ff       	call   80104b3a <wakeup1>
  release(&ptable.lock);
80104b95:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104b9c:	e8 2a 02 00 00       	call   80104dcb <release>
}
80104ba1:	c9                   	leave  
80104ba2:	c3                   	ret    

80104ba3 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ba3:	55                   	push   %ebp
80104ba4:	89 e5                	mov    %esp,%ebp
80104ba6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ba9:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104bb0:	e8 b4 01 00 00       	call   80104d69 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb5:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104bbc:	eb 41                	jmp    80104bff <kill+0x5c>
    if(p->pid == pid){
80104bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc1:	8b 40 10             	mov    0x10(%eax),%eax
80104bc4:	3b 45 08             	cmp    0x8(%ebp),%eax
80104bc7:	75 32                	jne    80104bfb <kill+0x58>
      p->killed = 1;
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd6:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd9:	83 f8 02             	cmp    $0x2,%eax
80104bdc:	75 0a                	jne    80104be8 <kill+0x45>
        p->state = RUNNABLE;
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104be8:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104bef:	e8 d7 01 00 00       	call   80104dcb <release>
      return 0;
80104bf4:	b8 00 00 00 00       	mov    $0x0,%eax
80104bf9:	eb 1e                	jmp    80104c19 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bfb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bff:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104c06:	72 b6                	jb     80104bbe <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104c08:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104c0f:	e8 b7 01 00 00       	call   80104dcb <release>
  return -1;
80104c14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c19:	c9                   	leave  
80104c1a:	c3                   	ret    

80104c1b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c1b:	55                   	push   %ebp
80104c1c:	89 e5                	mov    %esp,%ebp
80104c1e:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c21:	c7 45 f0 14 00 11 80 	movl   $0x80110014,-0x10(%ebp)
80104c28:	e9 d6 00 00 00       	jmp    80104d03 <procdump+0xe8>
    if(p->state == UNUSED)
80104c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c30:	8b 40 0c             	mov    0xc(%eax),%eax
80104c33:	85 c0                	test   %eax,%eax
80104c35:	75 05                	jne    80104c3c <procdump+0x21>
      continue;
80104c37:	e9 c3 00 00 00       	jmp    80104cff <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104c42:	83 f8 05             	cmp    $0x5,%eax
80104c45:	77 23                	ja     80104c6a <procdump+0x4f>
80104c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c4a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c4d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104c54:	85 c0                	test   %eax,%eax
80104c56:	74 12                	je     80104c6a <procdump+0x4f>
      state = states[p->state];
80104c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5e:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104c65:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c68:	eb 07                	jmp    80104c71 <procdump+0x56>
    else
      state = "???";
80104c6a:	c7 45 ec b4 86 10 80 	movl   $0x801086b4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c74:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7a:	8b 40 10             	mov    0x10(%eax),%eax
80104c7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104c81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c84:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c88:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c8c:	c7 04 24 b8 86 10 80 	movl   $0x801086b8,(%esp)
80104c93:	e8 08 b7 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c9b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c9e:	83 f8 02             	cmp    $0x2,%eax
80104ca1:	75 50                	jne    80104cf3 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ca9:	8b 40 0c             	mov    0xc(%eax),%eax
80104cac:	83 c0 08             	add    $0x8,%eax
80104caf:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104cb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80104cb6:	89 04 24             	mov    %eax,(%esp)
80104cb9:	e8 5c 01 00 00       	call   80104e1a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104cbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cc5:	eb 1b                	jmp    80104ce2 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cca:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cce:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd2:	c7 04 24 c1 86 10 80 	movl   $0x801086c1,(%esp)
80104cd9:	e8 c2 b6 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104cde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ce2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ce6:	7f 0b                	jg     80104cf3 <procdump+0xd8>
80104ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ceb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cef:	85 c0                	test   %eax,%eax
80104cf1:	75 d4                	jne    80104cc7 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104cf3:	c7 04 24 c5 86 10 80 	movl   $0x801086c5,(%esp)
80104cfa:	e8 a1 b6 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cff:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104d03:	81 7d f0 14 1f 11 80 	cmpl   $0x80111f14,-0x10(%ebp)
80104d0a:	0f 82 1d ff ff ff    	jb     80104c2d <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d10:	c9                   	leave  
80104d11:	c3                   	ret    

80104d12 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d12:	55                   	push   %ebp
80104d13:	89 e5                	mov    %esp,%ebp
80104d15:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d18:	9c                   	pushf  
80104d19:	58                   	pop    %eax
80104d1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d20:	c9                   	leave  
80104d21:	c3                   	ret    

80104d22 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d22:	55                   	push   %ebp
80104d23:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d25:	fa                   	cli    
}
80104d26:	5d                   	pop    %ebp
80104d27:	c3                   	ret    

80104d28 <sti>:

static inline void
sti(void)
{
80104d28:	55                   	push   %ebp
80104d29:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d2b:	fb                   	sti    
}
80104d2c:	5d                   	pop    %ebp
80104d2d:	c3                   	ret    

80104d2e <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
80104d31:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d34:	8b 55 08             	mov    0x8(%ebp),%edx
80104d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d3d:	f0 87 02             	lock xchg %eax,(%edx)
80104d40:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104d43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d46:	c9                   	leave  
80104d47:	c3                   	ret    

80104d48 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d51:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d54:	8b 45 08             	mov    0x8(%ebp),%eax
80104d57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d60:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d67:	5d                   	pop    %ebp
80104d68:	c3                   	ret    

80104d69 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d69:	55                   	push   %ebp
80104d6a:	89 e5                	mov    %esp,%ebp
80104d6c:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d6f:	e8 49 01 00 00       	call   80104ebd <pushcli>
  if(holding(lk))
80104d74:	8b 45 08             	mov    0x8(%ebp),%eax
80104d77:	89 04 24             	mov    %eax,(%esp)
80104d7a:	e8 14 01 00 00       	call   80104e93 <holding>
80104d7f:	85 c0                	test   %eax,%eax
80104d81:	74 0c                	je     80104d8f <acquire+0x26>
    panic("acquire");
80104d83:	c7 04 24 f1 86 10 80 	movl   $0x801086f1,(%esp)
80104d8a:	e8 ab b7 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104d8f:	90                   	nop
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
80104d93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104d9a:	00 
80104d9b:	89 04 24             	mov    %eax,(%esp)
80104d9e:	e8 8b ff ff ff       	call   80104d2e <xchg>
80104da3:	85 c0                	test   %eax,%eax
80104da5:	75 e9                	jne    80104d90 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104da7:	8b 45 08             	mov    0x8(%ebp),%eax
80104daa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104db1:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104db4:	8b 45 08             	mov    0x8(%ebp),%eax
80104db7:	83 c0 0c             	add    $0xc,%eax
80104dba:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dbe:	8d 45 08             	lea    0x8(%ebp),%eax
80104dc1:	89 04 24             	mov    %eax,(%esp)
80104dc4:	e8 51 00 00 00       	call   80104e1a <getcallerpcs>
}
80104dc9:	c9                   	leave  
80104dca:	c3                   	ret    

80104dcb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104dcb:	55                   	push   %ebp
80104dcc:	89 e5                	mov    %esp,%ebp
80104dce:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd4:	89 04 24             	mov    %eax,(%esp)
80104dd7:	e8 b7 00 00 00       	call   80104e93 <holding>
80104ddc:	85 c0                	test   %eax,%eax
80104dde:	75 0c                	jne    80104dec <release+0x21>
    panic("release");
80104de0:	c7 04 24 f9 86 10 80 	movl   $0x801086f9,(%esp)
80104de7:	e8 4e b7 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104dec:	8b 45 08             	mov    0x8(%ebp),%eax
80104def:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104df6:	8b 45 08             	mov    0x8(%ebp),%eax
80104df9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104e00:	8b 45 08             	mov    0x8(%ebp),%eax
80104e03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104e0a:	00 
80104e0b:	89 04 24             	mov    %eax,(%esp)
80104e0e:	e8 1b ff ff ff       	call   80104d2e <xchg>

  popcli();
80104e13:	e8 e9 00 00 00       	call   80104f01 <popcli>
}
80104e18:	c9                   	leave  
80104e19:	c3                   	ret    

80104e1a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e1a:	55                   	push   %ebp
80104e1b:	89 e5                	mov    %esp,%ebp
80104e1d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
80104e23:	83 e8 08             	sub    $0x8,%eax
80104e26:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e29:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e30:	eb 38                	jmp    80104e6a <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e32:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e36:	74 38                	je     80104e70 <getcallerpcs+0x56>
80104e38:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e3f:	76 2f                	jbe    80104e70 <getcallerpcs+0x56>
80104e41:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e45:	74 29                	je     80104e70 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e54:	01 c2                	add    %eax,%edx
80104e56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e59:	8b 40 04             	mov    0x4(%eax),%eax
80104e5c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e61:	8b 00                	mov    (%eax),%eax
80104e63:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104e66:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e6a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e6e:	7e c2                	jle    80104e32 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e70:	eb 19                	jmp    80104e8b <getcallerpcs+0x71>
    pcs[i] = 0;
80104e72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7f:	01 d0                	add    %edx,%eax
80104e81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e87:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e8b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e8f:	7e e1                	jle    80104e72 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104e91:	c9                   	leave  
80104e92:	c3                   	ret    

80104e93 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e93:	55                   	push   %ebp
80104e94:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104e96:	8b 45 08             	mov    0x8(%ebp),%eax
80104e99:	8b 00                	mov    (%eax),%eax
80104e9b:	85 c0                	test   %eax,%eax
80104e9d:	74 17                	je     80104eb6 <holding+0x23>
80104e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea2:	8b 50 08             	mov    0x8(%eax),%edx
80104ea5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104eab:	39 c2                	cmp    %eax,%edx
80104ead:	75 07                	jne    80104eb6 <holding+0x23>
80104eaf:	b8 01 00 00 00       	mov    $0x1,%eax
80104eb4:	eb 05                	jmp    80104ebb <holding+0x28>
80104eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ebb:	5d                   	pop    %ebp
80104ebc:	c3                   	ret    

80104ebd <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104ebd:	55                   	push   %ebp
80104ebe:	89 e5                	mov    %esp,%ebp
80104ec0:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104ec3:	e8 4a fe ff ff       	call   80104d12 <readeflags>
80104ec8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104ecb:	e8 52 fe ff ff       	call   80104d22 <cli>
  if(cpu->ncli++ == 0)
80104ed0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ed7:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104edd:	8d 48 01             	lea    0x1(%eax),%ecx
80104ee0:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80104ee6:	85 c0                	test   %eax,%eax
80104ee8:	75 15                	jne    80104eff <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104eea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ef0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ef3:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ef9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104eff:	c9                   	leave  
80104f00:	c3                   	ret    

80104f01 <popcli>:

void
popcli(void)
{
80104f01:	55                   	push   %ebp
80104f02:	89 e5                	mov    %esp,%ebp
80104f04:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f07:	e8 06 fe ff ff       	call   80104d12 <readeflags>
80104f0c:	25 00 02 00 00       	and    $0x200,%eax
80104f11:	85 c0                	test   %eax,%eax
80104f13:	74 0c                	je     80104f21 <popcli+0x20>
    panic("popcli - interruptible");
80104f15:	c7 04 24 01 87 10 80 	movl   $0x80108701,(%esp)
80104f1c:	e8 19 b6 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80104f21:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f27:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104f2d:	83 ea 01             	sub    $0x1,%edx
80104f30:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104f36:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	79 0c                	jns    80104f4c <popcli+0x4b>
    panic("popcli");
80104f40:	c7 04 24 18 87 10 80 	movl   $0x80108718,(%esp)
80104f47:	e8 ee b5 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104f4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f52:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f58:	85 c0                	test   %eax,%eax
80104f5a:	75 15                	jne    80104f71 <popcli+0x70>
80104f5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f62:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f68:	85 c0                	test   %eax,%eax
80104f6a:	74 05                	je     80104f71 <popcli+0x70>
    sti();
80104f6c:	e8 b7 fd ff ff       	call   80104d28 <sti>
}
80104f71:	c9                   	leave  
80104f72:	c3                   	ret    

80104f73 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104f73:	55                   	push   %ebp
80104f74:	89 e5                	mov    %esp,%ebp
80104f76:	57                   	push   %edi
80104f77:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f78:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f7b:	8b 55 10             	mov    0x10(%ebp),%edx
80104f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f81:	89 cb                	mov    %ecx,%ebx
80104f83:	89 df                	mov    %ebx,%edi
80104f85:	89 d1                	mov    %edx,%ecx
80104f87:	fc                   	cld    
80104f88:	f3 aa                	rep stos %al,%es:(%edi)
80104f8a:	89 ca                	mov    %ecx,%edx
80104f8c:	89 fb                	mov    %edi,%ebx
80104f8e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f91:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104f94:	5b                   	pop    %ebx
80104f95:	5f                   	pop    %edi
80104f96:	5d                   	pop    %ebp
80104f97:	c3                   	ret    

80104f98 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104f98:	55                   	push   %ebp
80104f99:	89 e5                	mov    %esp,%ebp
80104f9b:	57                   	push   %edi
80104f9c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fa0:	8b 55 10             	mov    0x10(%ebp),%edx
80104fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa6:	89 cb                	mov    %ecx,%ebx
80104fa8:	89 df                	mov    %ebx,%edi
80104faa:	89 d1                	mov    %edx,%ecx
80104fac:	fc                   	cld    
80104fad:	f3 ab                	rep stos %eax,%es:(%edi)
80104faf:	89 ca                	mov    %ecx,%edx
80104fb1:	89 fb                	mov    %edi,%ebx
80104fb3:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fb6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104fb9:	5b                   	pop    %ebx
80104fba:	5f                   	pop    %edi
80104fbb:	5d                   	pop    %ebp
80104fbc:	c3                   	ret    

80104fbd <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104fbd:	55                   	push   %ebp
80104fbe:	89 e5                	mov    %esp,%ebp
80104fc0:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc6:	83 e0 03             	and    $0x3,%eax
80104fc9:	85 c0                	test   %eax,%eax
80104fcb:	75 49                	jne    80105016 <memset+0x59>
80104fcd:	8b 45 10             	mov    0x10(%ebp),%eax
80104fd0:	83 e0 03             	and    $0x3,%eax
80104fd3:	85 c0                	test   %eax,%eax
80104fd5:	75 3f                	jne    80105016 <memset+0x59>
    c &= 0xFF;
80104fd7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104fde:	8b 45 10             	mov    0x10(%ebp),%eax
80104fe1:	c1 e8 02             	shr    $0x2,%eax
80104fe4:	89 c2                	mov    %eax,%edx
80104fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe9:	c1 e0 18             	shl    $0x18,%eax
80104fec:	89 c1                	mov    %eax,%ecx
80104fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff1:	c1 e0 10             	shl    $0x10,%eax
80104ff4:	09 c1                	or     %eax,%ecx
80104ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff9:	c1 e0 08             	shl    $0x8,%eax
80104ffc:	09 c8                	or     %ecx,%eax
80104ffe:	0b 45 0c             	or     0xc(%ebp),%eax
80105001:	89 54 24 08          	mov    %edx,0x8(%esp)
80105005:	89 44 24 04          	mov    %eax,0x4(%esp)
80105009:	8b 45 08             	mov    0x8(%ebp),%eax
8010500c:	89 04 24             	mov    %eax,(%esp)
8010500f:	e8 84 ff ff ff       	call   80104f98 <stosl>
80105014:	eb 19                	jmp    8010502f <memset+0x72>
  } else
    stosb(dst, c, n);
80105016:	8b 45 10             	mov    0x10(%ebp),%eax
80105019:	89 44 24 08          	mov    %eax,0x8(%esp)
8010501d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105020:	89 44 24 04          	mov    %eax,0x4(%esp)
80105024:	8b 45 08             	mov    0x8(%ebp),%eax
80105027:	89 04 24             	mov    %eax,(%esp)
8010502a:	e8 44 ff ff ff       	call   80104f73 <stosb>
  return dst;
8010502f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105032:	c9                   	leave  
80105033:	c3                   	ret    

80105034 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105034:	55                   	push   %ebp
80105035:	89 e5                	mov    %esp,%ebp
80105037:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010503a:	8b 45 08             	mov    0x8(%ebp),%eax
8010503d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105040:	8b 45 0c             	mov    0xc(%ebp),%eax
80105043:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105046:	eb 30                	jmp    80105078 <memcmp+0x44>
    if(*s1 != *s2)
80105048:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010504b:	0f b6 10             	movzbl (%eax),%edx
8010504e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105051:	0f b6 00             	movzbl (%eax),%eax
80105054:	38 c2                	cmp    %al,%dl
80105056:	74 18                	je     80105070 <memcmp+0x3c>
      return *s1 - *s2;
80105058:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010505b:	0f b6 00             	movzbl (%eax),%eax
8010505e:	0f b6 d0             	movzbl %al,%edx
80105061:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105064:	0f b6 00             	movzbl (%eax),%eax
80105067:	0f b6 c0             	movzbl %al,%eax
8010506a:	29 c2                	sub    %eax,%edx
8010506c:	89 d0                	mov    %edx,%eax
8010506e:	eb 1a                	jmp    8010508a <memcmp+0x56>
    s1++, s2++;
80105070:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105074:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105078:	8b 45 10             	mov    0x10(%ebp),%eax
8010507b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010507e:	89 55 10             	mov    %edx,0x10(%ebp)
80105081:	85 c0                	test   %eax,%eax
80105083:	75 c3                	jne    80105048 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105085:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105092:	8b 45 0c             	mov    0xc(%ebp),%eax
80105095:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105098:	8b 45 08             	mov    0x8(%ebp),%eax
8010509b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010509e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050a4:	73 3d                	jae    801050e3 <memmove+0x57>
801050a6:	8b 45 10             	mov    0x10(%ebp),%eax
801050a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050ac:	01 d0                	add    %edx,%eax
801050ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050b1:	76 30                	jbe    801050e3 <memmove+0x57>
    s += n;
801050b3:	8b 45 10             	mov    0x10(%ebp),%eax
801050b6:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801050b9:	8b 45 10             	mov    0x10(%ebp),%eax
801050bc:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801050bf:	eb 13                	jmp    801050d4 <memmove+0x48>
      *--d = *--s;
801050c1:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050c5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050cc:	0f b6 10             	movzbl (%eax),%edx
801050cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801050d4:	8b 45 10             	mov    0x10(%ebp),%eax
801050d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801050da:	89 55 10             	mov    %edx,0x10(%ebp)
801050dd:	85 c0                	test   %eax,%eax
801050df:	75 e0                	jne    801050c1 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801050e1:	eb 26                	jmp    80105109 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801050e3:	eb 17                	jmp    801050fc <memmove+0x70>
      *d++ = *s++;
801050e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050e8:	8d 50 01             	lea    0x1(%eax),%edx
801050eb:	89 55 f8             	mov    %edx,-0x8(%ebp)
801050ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050f1:	8d 4a 01             	lea    0x1(%edx),%ecx
801050f4:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801050f7:	0f b6 12             	movzbl (%edx),%edx
801050fa:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801050fc:	8b 45 10             	mov    0x10(%ebp),%eax
801050ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80105102:	89 55 10             	mov    %edx,0x10(%ebp)
80105105:	85 c0                	test   %eax,%eax
80105107:	75 dc                	jne    801050e5 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105109:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010510c:	c9                   	leave  
8010510d:	c3                   	ret    

8010510e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010510e:	55                   	push   %ebp
8010510f:	89 e5                	mov    %esp,%ebp
80105111:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105114:	8b 45 10             	mov    0x10(%ebp),%eax
80105117:	89 44 24 08          	mov    %eax,0x8(%esp)
8010511b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105122:	8b 45 08             	mov    0x8(%ebp),%eax
80105125:	89 04 24             	mov    %eax,(%esp)
80105128:	e8 5f ff ff ff       	call   8010508c <memmove>
}
8010512d:	c9                   	leave  
8010512e:	c3                   	ret    

8010512f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010512f:	55                   	push   %ebp
80105130:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105132:	eb 0c                	jmp    80105140 <strncmp+0x11>
    n--, p++, q++;
80105134:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105138:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010513c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105140:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105144:	74 1a                	je     80105160 <strncmp+0x31>
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	0f b6 00             	movzbl (%eax),%eax
8010514c:	84 c0                	test   %al,%al
8010514e:	74 10                	je     80105160 <strncmp+0x31>
80105150:	8b 45 08             	mov    0x8(%ebp),%eax
80105153:	0f b6 10             	movzbl (%eax),%edx
80105156:	8b 45 0c             	mov    0xc(%ebp),%eax
80105159:	0f b6 00             	movzbl (%eax),%eax
8010515c:	38 c2                	cmp    %al,%dl
8010515e:	74 d4                	je     80105134 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105160:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105164:	75 07                	jne    8010516d <strncmp+0x3e>
    return 0;
80105166:	b8 00 00 00 00       	mov    $0x0,%eax
8010516b:	eb 16                	jmp    80105183 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010516d:	8b 45 08             	mov    0x8(%ebp),%eax
80105170:	0f b6 00             	movzbl (%eax),%eax
80105173:	0f b6 d0             	movzbl %al,%edx
80105176:	8b 45 0c             	mov    0xc(%ebp),%eax
80105179:	0f b6 00             	movzbl (%eax),%eax
8010517c:	0f b6 c0             	movzbl %al,%eax
8010517f:	29 c2                	sub    %eax,%edx
80105181:	89 d0                	mov    %edx,%eax
}
80105183:	5d                   	pop    %ebp
80105184:	c3                   	ret    

80105185 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105185:	55                   	push   %ebp
80105186:	89 e5                	mov    %esp,%ebp
80105188:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010518b:	8b 45 08             	mov    0x8(%ebp),%eax
8010518e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105191:	90                   	nop
80105192:	8b 45 10             	mov    0x10(%ebp),%eax
80105195:	8d 50 ff             	lea    -0x1(%eax),%edx
80105198:	89 55 10             	mov    %edx,0x10(%ebp)
8010519b:	85 c0                	test   %eax,%eax
8010519d:	7e 1e                	jle    801051bd <strncpy+0x38>
8010519f:	8b 45 08             	mov    0x8(%ebp),%eax
801051a2:	8d 50 01             	lea    0x1(%eax),%edx
801051a5:	89 55 08             	mov    %edx,0x8(%ebp)
801051a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801051ab:	8d 4a 01             	lea    0x1(%edx),%ecx
801051ae:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801051b1:	0f b6 12             	movzbl (%edx),%edx
801051b4:	88 10                	mov    %dl,(%eax)
801051b6:	0f b6 00             	movzbl (%eax),%eax
801051b9:	84 c0                	test   %al,%al
801051bb:	75 d5                	jne    80105192 <strncpy+0xd>
    ;
  while(n-- > 0)
801051bd:	eb 0c                	jmp    801051cb <strncpy+0x46>
    *s++ = 0;
801051bf:	8b 45 08             	mov    0x8(%ebp),%eax
801051c2:	8d 50 01             	lea    0x1(%eax),%edx
801051c5:	89 55 08             	mov    %edx,0x8(%ebp)
801051c8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801051cb:	8b 45 10             	mov    0x10(%ebp),%eax
801051ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801051d1:	89 55 10             	mov    %edx,0x10(%ebp)
801051d4:	85 c0                	test   %eax,%eax
801051d6:	7f e7                	jg     801051bf <strncpy+0x3a>
    *s++ = 0;
  return os;
801051d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051db:	c9                   	leave  
801051dc:	c3                   	ret    

801051dd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051dd:	55                   	push   %ebp
801051de:	89 e5                	mov    %esp,%ebp
801051e0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801051e3:	8b 45 08             	mov    0x8(%ebp),%eax
801051e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ed:	7f 05                	jg     801051f4 <safestrcpy+0x17>
    return os;
801051ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f2:	eb 31                	jmp    80105225 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801051f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051fc:	7e 1e                	jle    8010521c <safestrcpy+0x3f>
801051fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105201:	8d 50 01             	lea    0x1(%eax),%edx
80105204:	89 55 08             	mov    %edx,0x8(%ebp)
80105207:	8b 55 0c             	mov    0xc(%ebp),%edx
8010520a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010520d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105210:	0f b6 12             	movzbl (%edx),%edx
80105213:	88 10                	mov    %dl,(%eax)
80105215:	0f b6 00             	movzbl (%eax),%eax
80105218:	84 c0                	test   %al,%al
8010521a:	75 d8                	jne    801051f4 <safestrcpy+0x17>
    ;
  *s = 0;
8010521c:	8b 45 08             	mov    0x8(%ebp),%eax
8010521f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105222:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105225:	c9                   	leave  
80105226:	c3                   	ret    

80105227 <strlen>:

int
strlen(const char *s)
{
80105227:	55                   	push   %ebp
80105228:	89 e5                	mov    %esp,%ebp
8010522a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010522d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105234:	eb 04                	jmp    8010523a <strlen+0x13>
80105236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010523a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010523d:	8b 45 08             	mov    0x8(%ebp),%eax
80105240:	01 d0                	add    %edx,%eax
80105242:	0f b6 00             	movzbl (%eax),%eax
80105245:	84 c0                	test   %al,%al
80105247:	75 ed                	jne    80105236 <strlen+0xf>
    ;
  return n;
80105249:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010524c:	c9                   	leave  
8010524d:	c3                   	ret    

8010524e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010524e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105252:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105256:	55                   	push   %ebp
  pushl %ebx
80105257:	53                   	push   %ebx
  pushl %esi
80105258:	56                   	push   %esi
  pushl %edi
80105259:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010525a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010525c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010525e:	5f                   	pop    %edi
  popl %esi
8010525f:	5e                   	pop    %esi
  popl %ebx
80105260:	5b                   	pop    %ebx
  popl %ebp
80105261:	5d                   	pop    %ebp
  ret
80105262:	c3                   	ret    

80105263 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105263:	55                   	push   %ebp
80105264:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
80105266:	8b 45 08             	mov    0x8(%ebp),%eax
80105269:	8b 00                	mov    (%eax),%eax
8010526b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010526e:	76 0f                	jbe    8010527f <fetchint+0x1c>
80105270:	8b 45 0c             	mov    0xc(%ebp),%eax
80105273:	8d 50 04             	lea    0x4(%eax),%edx
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	8b 00                	mov    (%eax),%eax
8010527b:	39 c2                	cmp    %eax,%edx
8010527d:	76 07                	jbe    80105286 <fetchint+0x23>
    return -1;
8010527f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105284:	eb 0f                	jmp    80105295 <fetchint+0x32>
  *ip = *(int*)(addr);
80105286:	8b 45 0c             	mov    0xc(%ebp),%eax
80105289:	8b 10                	mov    (%eax),%edx
8010528b:	8b 45 10             	mov    0x10(%ebp),%eax
8010528e:	89 10                	mov    %edx,(%eax)
  return 0;
80105290:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105295:	5d                   	pop    %ebp
80105296:	c3                   	ret    

80105297 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
8010529d:	8b 45 08             	mov    0x8(%ebp),%eax
801052a0:	8b 00                	mov    (%eax),%eax
801052a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801052a5:	77 07                	ja     801052ae <fetchstr+0x17>
    return -1;
801052a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ac:	eb 43                	jmp    801052f1 <fetchstr+0x5a>
  *pp = (char*)addr;
801052ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801052b1:	8b 45 10             	mov    0x10(%ebp),%eax
801052b4:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801052b6:	8b 45 08             	mov    0x8(%ebp),%eax
801052b9:	8b 00                	mov    (%eax),%eax
801052bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801052be:	8b 45 10             	mov    0x10(%ebp),%eax
801052c1:	8b 00                	mov    (%eax),%eax
801052c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801052c6:	eb 1c                	jmp    801052e4 <fetchstr+0x4d>
    if(*s == 0)
801052c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052cb:	0f b6 00             	movzbl (%eax),%eax
801052ce:	84 c0                	test   %al,%al
801052d0:	75 0e                	jne    801052e0 <fetchstr+0x49>
      return s - *pp;
801052d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052d5:	8b 45 10             	mov    0x10(%ebp),%eax
801052d8:	8b 00                	mov    (%eax),%eax
801052da:	29 c2                	sub    %eax,%edx
801052dc:	89 d0                	mov    %edx,%eax
801052de:	eb 11                	jmp    801052f1 <fetchstr+0x5a>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801052e0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052ea:	72 dc                	jb     801052c8 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
801052ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052f1:	c9                   	leave  
801052f2:	c3                   	ret    

801052f3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801052f3:	55                   	push   %ebp
801052f4:	89 e5                	mov    %esp,%ebp
801052f6:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
801052f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ff:	8b 40 18             	mov    0x18(%eax),%eax
80105302:	8b 50 44             	mov    0x44(%eax),%edx
80105305:	8b 45 08             	mov    0x8(%ebp),%eax
80105308:	c1 e0 02             	shl    $0x2,%eax
8010530b:	01 d0                	add    %edx,%eax
8010530d:	8d 48 04             	lea    0x4(%eax),%ecx
80105310:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105316:	8b 55 0c             	mov    0xc(%ebp),%edx
80105319:	89 54 24 08          	mov    %edx,0x8(%esp)
8010531d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105321:	89 04 24             	mov    %eax,(%esp)
80105324:	e8 3a ff ff ff       	call   80105263 <fetchint>
}
80105329:	c9                   	leave  
8010532a:	c3                   	ret    

8010532b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010532b:	55                   	push   %ebp
8010532c:	89 e5                	mov    %esp,%ebp
8010532e:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105331:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105334:	89 44 24 04          	mov    %eax,0x4(%esp)
80105338:	8b 45 08             	mov    0x8(%ebp),%eax
8010533b:	89 04 24             	mov    %eax,(%esp)
8010533e:	e8 b0 ff ff ff       	call   801052f3 <argint>
80105343:	85 c0                	test   %eax,%eax
80105345:	79 07                	jns    8010534e <argptr+0x23>
    return -1;
80105347:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010534c:	eb 3d                	jmp    8010538b <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010534e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105351:	89 c2                	mov    %eax,%edx
80105353:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105359:	8b 00                	mov    (%eax),%eax
8010535b:	39 c2                	cmp    %eax,%edx
8010535d:	73 16                	jae    80105375 <argptr+0x4a>
8010535f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105362:	89 c2                	mov    %eax,%edx
80105364:	8b 45 10             	mov    0x10(%ebp),%eax
80105367:	01 c2                	add    %eax,%edx
80105369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536f:	8b 00                	mov    (%eax),%eax
80105371:	39 c2                	cmp    %eax,%edx
80105373:	76 07                	jbe    8010537c <argptr+0x51>
    return -1;
80105375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537a:	eb 0f                	jmp    8010538b <argptr+0x60>
  *pp = (char*)i;
8010537c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537f:	89 c2                	mov    %eax,%edx
80105381:	8b 45 0c             	mov    0xc(%ebp),%eax
80105384:	89 10                	mov    %edx,(%eax)
  return 0;
80105386:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010538b:	c9                   	leave  
8010538c:	c3                   	ret    

8010538d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010538d:	55                   	push   %ebp
8010538e:	89 e5                	mov    %esp,%ebp
80105390:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105393:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105396:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539a:	8b 45 08             	mov    0x8(%ebp),%eax
8010539d:	89 04 24             	mov    %eax,(%esp)
801053a0:	e8 4e ff ff ff       	call   801052f3 <argint>
801053a5:	85 c0                	test   %eax,%eax
801053a7:	79 07                	jns    801053b0 <argstr+0x23>
    return -1;
801053a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ae:	eb 1e                	jmp    801053ce <argstr+0x41>
  return fetchstr(proc, addr, pp);
801053b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b3:	89 c2                	mov    %eax,%edx
801053b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801053be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801053c6:	89 04 24             	mov    %eax,(%esp)
801053c9:	e8 c9 fe ff ff       	call   80105297 <fetchstr>
}
801053ce:	c9                   	leave  
801053cf:	c3                   	ret    

801053d0 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	53                   	push   %ebx
801053d4:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801053d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053dd:	8b 40 18             	mov    0x18(%eax),%eax
801053e0:	8b 40 1c             	mov    0x1c(%eax),%eax
801053e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801053e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053ea:	78 2e                	js     8010541a <syscall+0x4a>
801053ec:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801053f0:	7f 28                	jg     8010541a <syscall+0x4a>
801053f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f5:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801053fc:	85 c0                	test   %eax,%eax
801053fe:	74 1a                	je     8010541a <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105400:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105406:	8b 58 18             	mov    0x18(%eax),%ebx
80105409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010540c:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105413:	ff d0                	call   *%eax
80105415:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105418:	eb 73                	jmp    8010548d <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010541a:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010541e:	7e 30                	jle    80105450 <syscall+0x80>
80105420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105423:	83 f8 15             	cmp    $0x15,%eax
80105426:	77 28                	ja     80105450 <syscall+0x80>
80105428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010542b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105432:	85 c0                	test   %eax,%eax
80105434:	74 1a                	je     80105450 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105436:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543c:	8b 58 18             	mov    0x18(%eax),%ebx
8010543f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105442:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105449:	ff d0                	call   *%eax
8010544b:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010544e:	eb 3d                	jmp    8010548d <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105450:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105456:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010545f:	8b 40 10             	mov    0x10(%eax),%eax
80105462:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105465:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010546d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105471:	c7 04 24 1f 87 10 80 	movl   $0x8010871f,(%esp)
80105478:	e8 23 af ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010547d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105483:	8b 40 18             	mov    0x18(%eax),%eax
80105486:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010548d:	83 c4 24             	add    $0x24,%esp
80105490:	5b                   	pop    %ebx
80105491:	5d                   	pop    %ebp
80105492:	c3                   	ret    

80105493 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105493:	55                   	push   %ebp
80105494:	89 e5                	mov    %esp,%ebp
80105496:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105499:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010549c:	89 44 24 04          	mov    %eax,0x4(%esp)
801054a0:	8b 45 08             	mov    0x8(%ebp),%eax
801054a3:	89 04 24             	mov    %eax,(%esp)
801054a6:	e8 48 fe ff ff       	call   801052f3 <argint>
801054ab:	85 c0                	test   %eax,%eax
801054ad:	79 07                	jns    801054b6 <argfd+0x23>
    return -1;
801054af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b4:	eb 50                	jmp    80105506 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801054b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b9:	85 c0                	test   %eax,%eax
801054bb:	78 21                	js     801054de <argfd+0x4b>
801054bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c0:	83 f8 0f             	cmp    $0xf,%eax
801054c3:	7f 19                	jg     801054de <argfd+0x4b>
801054c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ce:	83 c2 08             	add    $0x8,%edx
801054d1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054dc:	75 07                	jne    801054e5 <argfd+0x52>
    return -1;
801054de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e3:	eb 21                	jmp    80105506 <argfd+0x73>
  if(pfd)
801054e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054e9:	74 08                	je     801054f3 <argfd+0x60>
    *pfd = fd;
801054eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f1:	89 10                	mov    %edx,(%eax)
  if(pf)
801054f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f7:	74 08                	je     80105501 <argfd+0x6e>
    *pf = f;
801054f9:	8b 45 10             	mov    0x10(%ebp),%eax
801054fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ff:	89 10                	mov    %edx,(%eax)
  return 0;
80105501:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105506:	c9                   	leave  
80105507:	c3                   	ret    

80105508 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105508:	55                   	push   %ebp
80105509:	89 e5                	mov    %esp,%ebp
8010550b:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010550e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105515:	eb 30                	jmp    80105547 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105517:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105520:	83 c2 08             	add    $0x8,%edx
80105523:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105527:	85 c0                	test   %eax,%eax
80105529:	75 18                	jne    80105543 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010552b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105531:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105534:	8d 4a 08             	lea    0x8(%edx),%ecx
80105537:	8b 55 08             	mov    0x8(%ebp),%edx
8010553a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010553e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105541:	eb 0f                	jmp    80105552 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105543:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105547:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010554b:	7e ca                	jle    80105517 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010554d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105552:	c9                   	leave  
80105553:	c3                   	ret    

80105554 <sys_dup>:

int
sys_dup(void)
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010555a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010555d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105561:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105568:	00 
80105569:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105570:	e8 1e ff ff ff       	call   80105493 <argfd>
80105575:	85 c0                	test   %eax,%eax
80105577:	79 07                	jns    80105580 <sys_dup+0x2c>
    return -1;
80105579:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010557e:	eb 29                	jmp    801055a9 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105583:	89 04 24             	mov    %eax,(%esp)
80105586:	e8 7d ff ff ff       	call   80105508 <fdalloc>
8010558b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010558e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105592:	79 07                	jns    8010559b <sys_dup+0x47>
    return -1;
80105594:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105599:	eb 0e                	jmp    801055a9 <sys_dup+0x55>
  filedup(f);
8010559b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559e:	89 04 24             	mov    %eax,(%esp)
801055a1:	e8 d3 b9 ff ff       	call   80100f79 <filedup>
  return fd;
801055a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055a9:	c9                   	leave  
801055aa:	c3                   	ret    

801055ab <sys_read>:

int
sys_read(void)
{
801055ab:	55                   	push   %ebp
801055ac:	89 e5                	mov    %esp,%ebp
801055ae:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801055b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055bf:	00 
801055c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055c7:	e8 c7 fe ff ff       	call   80105493 <argfd>
801055cc:	85 c0                	test   %eax,%eax
801055ce:	78 35                	js     80105605 <sys_read+0x5a>
801055d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801055d7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801055de:	e8 10 fd ff ff       	call   801052f3 <argint>
801055e3:	85 c0                	test   %eax,%eax
801055e5:	78 1e                	js     80105605 <sys_read+0x5a>
801055e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801055ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801055f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801055fc:	e8 2a fd ff ff       	call   8010532b <argptr>
80105601:	85 c0                	test   %eax,%eax
80105603:	79 07                	jns    8010560c <sys_read+0x61>
    return -1;
80105605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010560a:	eb 19                	jmp    80105625 <sys_read+0x7a>
  return fileread(f, p, n);
8010560c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010560f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105615:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105619:	89 54 24 04          	mov    %edx,0x4(%esp)
8010561d:	89 04 24             	mov    %eax,(%esp)
80105620:	e8 c1 ba ff ff       	call   801010e6 <fileread>
}
80105625:	c9                   	leave  
80105626:	c3                   	ret    

80105627 <sys_write>:

int
sys_write(void)
{
80105627:	55                   	push   %ebp
80105628:	89 e5                	mov    %esp,%ebp
8010562a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010562d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105630:	89 44 24 08          	mov    %eax,0x8(%esp)
80105634:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010563b:	00 
8010563c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105643:	e8 4b fe ff ff       	call   80105493 <argfd>
80105648:	85 c0                	test   %eax,%eax
8010564a:	78 35                	js     80105681 <sys_write+0x5a>
8010564c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010564f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105653:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010565a:	e8 94 fc ff ff       	call   801052f3 <argint>
8010565f:	85 c0                	test   %eax,%eax
80105661:	78 1e                	js     80105681 <sys_write+0x5a>
80105663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105666:	89 44 24 08          	mov    %eax,0x8(%esp)
8010566a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010566d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105671:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105678:	e8 ae fc ff ff       	call   8010532b <argptr>
8010567d:	85 c0                	test   %eax,%eax
8010567f:	79 07                	jns    80105688 <sys_write+0x61>
    return -1;
80105681:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105686:	eb 19                	jmp    801056a1 <sys_write+0x7a>
  return filewrite(f, p, n);
80105688:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010568b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010568e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105691:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105695:	89 54 24 04          	mov    %edx,0x4(%esp)
80105699:	89 04 24             	mov    %eax,(%esp)
8010569c:	e8 01 bb ff ff       	call   801011a2 <filewrite>
}
801056a1:	c9                   	leave  
801056a2:	c3                   	ret    

801056a3 <sys_close>:

int
sys_close(void)
{
801056a3:	55                   	push   %ebp
801056a4:	89 e5                	mov    %esp,%ebp
801056a6:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801056a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801056b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801056b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056be:	e8 d0 fd ff ff       	call   80105493 <argfd>
801056c3:	85 c0                	test   %eax,%eax
801056c5:	79 07                	jns    801056ce <sys_close+0x2b>
    return -1;
801056c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cc:	eb 24                	jmp    801056f2 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801056ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056d7:	83 c2 08             	add    $0x8,%edx
801056da:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801056e1:	00 
  fileclose(f);
801056e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e5:	89 04 24             	mov    %eax,(%esp)
801056e8:	e8 d4 b8 ff ff       	call   80100fc1 <fileclose>
  return 0;
801056ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056f2:	c9                   	leave  
801056f3:	c3                   	ret    

801056f4 <sys_fstat>:

int
sys_fstat(void)
{
801056f4:	55                   	push   %ebp
801056f5:	89 e5                	mov    %esp,%ebp
801056f7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801056fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105701:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105708:	00 
80105709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105710:	e8 7e fd ff ff       	call   80105493 <argfd>
80105715:	85 c0                	test   %eax,%eax
80105717:	78 1f                	js     80105738 <sys_fstat+0x44>
80105719:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105720:	00 
80105721:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105724:	89 44 24 04          	mov    %eax,0x4(%esp)
80105728:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010572f:	e8 f7 fb ff ff       	call   8010532b <argptr>
80105734:	85 c0                	test   %eax,%eax
80105736:	79 07                	jns    8010573f <sys_fstat+0x4b>
    return -1;
80105738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573d:	eb 12                	jmp    80105751 <sys_fstat+0x5d>
  return filestat(f, st);
8010573f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105745:	89 54 24 04          	mov    %edx,0x4(%esp)
80105749:	89 04 24             	mov    %eax,(%esp)
8010574c:	e8 46 b9 ff ff       	call   80101097 <filestat>
}
80105751:	c9                   	leave  
80105752:	c3                   	ret    

80105753 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105753:	55                   	push   %ebp
80105754:	89 e5                	mov    %esp,%ebp
80105756:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105759:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010575c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105767:	e8 21 fc ff ff       	call   8010538d <argstr>
8010576c:	85 c0                	test   %eax,%eax
8010576e:	78 17                	js     80105787 <sys_link+0x34>
80105770:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105773:	89 44 24 04          	mov    %eax,0x4(%esp)
80105777:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010577e:	e8 0a fc ff ff       	call   8010538d <argstr>
80105783:	85 c0                	test   %eax,%eax
80105785:	79 0a                	jns    80105791 <sys_link+0x3e>
    return -1;
80105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578c:	e9 3d 01 00 00       	jmp    801058ce <sys_link+0x17b>
  if((ip = namei(old)) == 0)
80105791:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105794:	89 04 24             	mov    %eax,(%esp)
80105797:	e8 a3 ce ff ff       	call   8010263f <namei>
8010579c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a3:	75 0a                	jne    801057af <sys_link+0x5c>
    return -1;
801057a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057aa:	e9 1f 01 00 00       	jmp    801058ce <sys_link+0x17b>

  begin_trans();
801057af:	e8 6a dc ff ff       	call   8010341e <begin_trans>

  ilock(ip);
801057b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b7:	89 04 24             	mov    %eax,(%esp)
801057ba:	e8 8f c0 ff ff       	call   8010184e <ilock>
  if(ip->type == T_DIR){
801057bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801057c6:	66 83 f8 01          	cmp    $0x1,%ax
801057ca:	75 1a                	jne    801057e6 <sys_link+0x93>
    iunlockput(ip);
801057cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cf:	89 04 24             	mov    %eax,(%esp)
801057d2:	e8 fb c2 ff ff       	call   80101ad2 <iunlockput>
    commit_trans();
801057d7:	e8 8b dc ff ff       	call   80103467 <commit_trans>
    return -1;
801057dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e1:	e9 e8 00 00 00       	jmp    801058ce <sys_link+0x17b>
  }

  ip->nlink++;
801057e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057ed:	8d 50 01             	lea    0x1(%eax),%edx
801057f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801057f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fa:	89 04 24             	mov    %eax,(%esp)
801057fd:	e8 90 be ff ff       	call   80101692 <iupdate>
  iunlock(ip);
80105802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105805:	89 04 24             	mov    %eax,(%esp)
80105808:	e8 8f c1 ff ff       	call   8010199c <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010580d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105810:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105813:	89 54 24 04          	mov    %edx,0x4(%esp)
80105817:	89 04 24             	mov    %eax,(%esp)
8010581a:	e8 42 ce ff ff       	call   80102661 <nameiparent>
8010581f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105822:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105826:	75 02                	jne    8010582a <sys_link+0xd7>
    goto bad;
80105828:	eb 68                	jmp    80105892 <sys_link+0x13f>
  ilock(dp);
8010582a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582d:	89 04 24             	mov    %eax,(%esp)
80105830:	e8 19 c0 ff ff       	call   8010184e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105838:	8b 10                	mov    (%eax),%edx
8010583a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583d:	8b 00                	mov    (%eax),%eax
8010583f:	39 c2                	cmp    %eax,%edx
80105841:	75 20                	jne    80105863 <sys_link+0x110>
80105843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105846:	8b 40 04             	mov    0x4(%eax),%eax
80105849:	89 44 24 08          	mov    %eax,0x8(%esp)
8010584d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105850:	89 44 24 04          	mov    %eax,0x4(%esp)
80105854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105857:	89 04 24             	mov    %eax,(%esp)
8010585a:	e8 20 cb ff ff       	call   8010237f <dirlink>
8010585f:	85 c0                	test   %eax,%eax
80105861:	79 0d                	jns    80105870 <sys_link+0x11d>
    iunlockput(dp);
80105863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105866:	89 04 24             	mov    %eax,(%esp)
80105869:	e8 64 c2 ff ff       	call   80101ad2 <iunlockput>
    goto bad;
8010586e:	eb 22                	jmp    80105892 <sys_link+0x13f>
  }
  iunlockput(dp);
80105870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105873:	89 04 24             	mov    %eax,(%esp)
80105876:	e8 57 c2 ff ff       	call   80101ad2 <iunlockput>
  iput(ip);
8010587b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587e:	89 04 24             	mov    %eax,(%esp)
80105881:	e8 7b c1 ff ff       	call   80101a01 <iput>

  commit_trans();
80105886:	e8 dc db ff ff       	call   80103467 <commit_trans>

  return 0;
8010588b:	b8 00 00 00 00       	mov    $0x0,%eax
80105890:	eb 3c                	jmp    801058ce <sys_link+0x17b>

bad:
  ilock(ip);
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	89 04 24             	mov    %eax,(%esp)
80105898:	e8 b1 bf ff ff       	call   8010184e <ilock>
  ip->nlink--;
8010589d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058a4:	8d 50 ff             	lea    -0x1(%eax),%edx
801058a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058aa:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801058ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b1:	89 04 24             	mov    %eax,(%esp)
801058b4:	e8 d9 bd ff ff       	call   80101692 <iupdate>
  iunlockput(ip);
801058b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bc:	89 04 24             	mov    %eax,(%esp)
801058bf:	e8 0e c2 ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
801058c4:	e8 9e db ff ff       	call   80103467 <commit_trans>
  return -1;
801058c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058ce:	c9                   	leave  
801058cf:	c3                   	ret    

801058d0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801058d0:	55                   	push   %ebp
801058d1:	89 e5                	mov    %esp,%ebp
801058d3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058d6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801058dd:	eb 4b                	jmp    8010592a <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801058e9:	00 
801058ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801058ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f5:	8b 45 08             	mov    0x8(%ebp),%eax
801058f8:	89 04 24             	mov    %eax,(%esp)
801058fb:	e8 a1 c6 ff ff       	call   80101fa1 <readi>
80105900:	83 f8 10             	cmp    $0x10,%eax
80105903:	74 0c                	je     80105911 <isdirempty+0x41>
      panic("isdirempty: readi");
80105905:	c7 04 24 3b 87 10 80 	movl   $0x8010873b,(%esp)
8010590c:	e8 29 ac ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105911:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105915:	66 85 c0             	test   %ax,%ax
80105918:	74 07                	je     80105921 <isdirempty+0x51>
      return 0;
8010591a:	b8 00 00 00 00       	mov    $0x0,%eax
8010591f:	eb 1b                	jmp    8010593c <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	83 c0 10             	add    $0x10,%eax
80105927:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010592a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010592d:	8b 45 08             	mov    0x8(%ebp),%eax
80105930:	8b 40 18             	mov    0x18(%eax),%eax
80105933:	39 c2                	cmp    %eax,%edx
80105935:	72 a8                	jb     801058df <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105937:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010593c:	c9                   	leave  
8010593d:	c3                   	ret    

8010593e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010593e:	55                   	push   %ebp
8010593f:	89 e5                	mov    %esp,%ebp
80105941:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105944:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105947:	89 44 24 04          	mov    %eax,0x4(%esp)
8010594b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105952:	e8 36 fa ff ff       	call   8010538d <argstr>
80105957:	85 c0                	test   %eax,%eax
80105959:	79 0a                	jns    80105965 <sys_unlink+0x27>
    return -1;
8010595b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105960:	e9 aa 01 00 00       	jmp    80105b0f <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105965:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105968:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010596b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010596f:	89 04 24             	mov    %eax,(%esp)
80105972:	e8 ea cc ff ff       	call   80102661 <nameiparent>
80105977:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010597a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597e:	75 0a                	jne    8010598a <sys_unlink+0x4c>
    return -1;
80105980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105985:	e9 85 01 00 00       	jmp    80105b0f <sys_unlink+0x1d1>

  begin_trans();
8010598a:	e8 8f da ff ff       	call   8010341e <begin_trans>

  ilock(dp);
8010598f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105992:	89 04 24             	mov    %eax,(%esp)
80105995:	e8 b4 be ff ff       	call   8010184e <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010599a:	c7 44 24 04 4d 87 10 	movl   $0x8010874d,0x4(%esp)
801059a1:	80 
801059a2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059a5:	89 04 24             	mov    %eax,(%esp)
801059a8:	e8 e7 c8 ff ff       	call   80102294 <namecmp>
801059ad:	85 c0                	test   %eax,%eax
801059af:	0f 84 45 01 00 00    	je     80105afa <sys_unlink+0x1bc>
801059b5:	c7 44 24 04 4f 87 10 	movl   $0x8010874f,0x4(%esp)
801059bc:	80 
801059bd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059c0:	89 04 24             	mov    %eax,(%esp)
801059c3:	e8 cc c8 ff ff       	call   80102294 <namecmp>
801059c8:	85 c0                	test   %eax,%eax
801059ca:	0f 84 2a 01 00 00    	je     80105afa <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801059d0:	8d 45 c8             	lea    -0x38(%ebp),%eax
801059d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059da:	89 44 24 04          	mov    %eax,0x4(%esp)
801059de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e1:	89 04 24             	mov    %eax,(%esp)
801059e4:	e8 cd c8 ff ff       	call   801022b6 <dirlookup>
801059e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059f0:	75 05                	jne    801059f7 <sys_unlink+0xb9>
    goto bad;
801059f2:	e9 03 01 00 00       	jmp    80105afa <sys_unlink+0x1bc>
  ilock(ip);
801059f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fa:	89 04 24             	mov    %eax,(%esp)
801059fd:	e8 4c be ff ff       	call   8010184e <ilock>

  if(ip->nlink < 1)
80105a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a05:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a09:	66 85 c0             	test   %ax,%ax
80105a0c:	7f 0c                	jg     80105a1a <sys_unlink+0xdc>
    panic("unlink: nlink < 1");
80105a0e:	c7 04 24 52 87 10 80 	movl   $0x80108752,(%esp)
80105a15:	e8 20 ab ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a21:	66 83 f8 01          	cmp    $0x1,%ax
80105a25:	75 1f                	jne    80105a46 <sys_unlink+0x108>
80105a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2a:	89 04 24             	mov    %eax,(%esp)
80105a2d:	e8 9e fe ff ff       	call   801058d0 <isdirempty>
80105a32:	85 c0                	test   %eax,%eax
80105a34:	75 10                	jne    80105a46 <sys_unlink+0x108>
    iunlockput(ip);
80105a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a39:	89 04 24             	mov    %eax,(%esp)
80105a3c:	e8 91 c0 ff ff       	call   80101ad2 <iunlockput>
    goto bad;
80105a41:	e9 b4 00 00 00       	jmp    80105afa <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105a46:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a4d:	00 
80105a4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a55:	00 
80105a56:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a59:	89 04 24             	mov    %eax,(%esp)
80105a5c:	e8 5c f5 ff ff       	call   80104fbd <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a61:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a64:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a6b:	00 
80105a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a70:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a73:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	89 04 24             	mov    %eax,(%esp)
80105a7d:	e8 83 c6 ff ff       	call   80102105 <writei>
80105a82:	83 f8 10             	cmp    $0x10,%eax
80105a85:	74 0c                	je     80105a93 <sys_unlink+0x155>
    panic("unlink: writei");
80105a87:	c7 04 24 64 87 10 80 	movl   $0x80108764,(%esp)
80105a8e:	e8 a7 aa ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a96:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a9a:	66 83 f8 01          	cmp    $0x1,%ax
80105a9e:	75 1c                	jne    80105abc <sys_unlink+0x17e>
    dp->nlink--;
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105aa7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aad:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab4:	89 04 24             	mov    %eax,(%esp)
80105ab7:	e8 d6 bb ff ff       	call   80101692 <iupdate>
  }
  iunlockput(dp);
80105abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abf:	89 04 24             	mov    %eax,(%esp)
80105ac2:	e8 0b c0 ff ff       	call   80101ad2 <iunlockput>

  ip->nlink--;
80105ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ace:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad4:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adb:	89 04 24             	mov    %eax,(%esp)
80105ade:	e8 af bb ff ff       	call   80101692 <iupdate>
  iunlockput(ip);
80105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae6:	89 04 24             	mov    %eax,(%esp)
80105ae9:	e8 e4 bf ff ff       	call   80101ad2 <iunlockput>

  commit_trans();
80105aee:	e8 74 d9 ff ff       	call   80103467 <commit_trans>

  return 0;
80105af3:	b8 00 00 00 00       	mov    $0x0,%eax
80105af8:	eb 15                	jmp    80105b0f <sys_unlink+0x1d1>

bad:
  iunlockput(dp);
80105afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afd:	89 04 24             	mov    %eax,(%esp)
80105b00:	e8 cd bf ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80105b05:	e8 5d d9 ff ff       	call   80103467 <commit_trans>
  return -1;
80105b0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b0f:	c9                   	leave  
80105b10:	c3                   	ret    

80105b11 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b11:	55                   	push   %ebp
80105b12:	89 e5                	mov    %esp,%ebp
80105b14:	83 ec 48             	sub    $0x48,%esp
80105b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b1a:	8b 55 10             	mov    0x10(%ebp),%edx
80105b1d:	8b 45 14             	mov    0x14(%ebp),%eax
80105b20:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b24:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b28:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b2c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b33:	8b 45 08             	mov    0x8(%ebp),%eax
80105b36:	89 04 24             	mov    %eax,(%esp)
80105b39:	e8 23 cb ff ff       	call   80102661 <nameiparent>
80105b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b45:	75 0a                	jne    80105b51 <create+0x40>
    return 0;
80105b47:	b8 00 00 00 00       	mov    $0x0,%eax
80105b4c:	e9 7e 01 00 00       	jmp    80105ccf <create+0x1be>
  ilock(dp);
80105b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b54:	89 04 24             	mov    %eax,(%esp)
80105b57:	e8 f2 bc ff ff       	call   8010184e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b63:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b66:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6d:	89 04 24             	mov    %eax,(%esp)
80105b70:	e8 41 c7 ff ff       	call   801022b6 <dirlookup>
80105b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b7c:	74 47                	je     80105bc5 <create+0xb4>
    iunlockput(dp);
80105b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b81:	89 04 24             	mov    %eax,(%esp)
80105b84:	e8 49 bf ff ff       	call   80101ad2 <iunlockput>
    ilock(ip);
80105b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8c:	89 04 24             	mov    %eax,(%esp)
80105b8f:	e8 ba bc ff ff       	call   8010184e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105b94:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b99:	75 15                	jne    80105bb0 <create+0x9f>
80105b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ba2:	66 83 f8 02          	cmp    $0x2,%ax
80105ba6:	75 08                	jne    80105bb0 <create+0x9f>
      return ip;
80105ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bab:	e9 1f 01 00 00       	jmp    80105ccf <create+0x1be>
    iunlockput(ip);
80105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb3:	89 04 24             	mov    %eax,(%esp)
80105bb6:	e8 17 bf ff ff       	call   80101ad2 <iunlockput>
    return 0;
80105bbb:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc0:	e9 0a 01 00 00       	jmp    80105ccf <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105bc5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcc:	8b 00                	mov    (%eax),%eax
80105bce:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bd2:	89 04 24             	mov    %eax,(%esp)
80105bd5:	e8 d9 b9 ff ff       	call   801015b3 <ialloc>
80105bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105be1:	75 0c                	jne    80105bef <create+0xde>
    panic("create: ialloc");
80105be3:	c7 04 24 73 87 10 80 	movl   $0x80108773,(%esp)
80105bea:	e8 4b a9 ff ff       	call   8010053a <panic>

  ilock(ip);
80105bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf2:	89 04 24             	mov    %eax,(%esp)
80105bf5:	e8 54 bc ff ff       	call   8010184e <ilock>
  ip->major = major;
80105bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c01:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c08:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c0c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c13:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1c:	89 04 24             	mov    %eax,(%esp)
80105c1f:	e8 6e ba ff ff       	call   80101692 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105c24:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c29:	75 6a                	jne    80105c95 <create+0x184>
    dp->nlink++;  // for ".."
80105c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c32:	8d 50 01             	lea    0x1(%eax),%edx
80105c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c38:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	89 04 24             	mov    %eax,(%esp)
80105c42:	e8 4b ba ff ff       	call   80101692 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4a:	8b 40 04             	mov    0x4(%eax),%eax
80105c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c51:	c7 44 24 04 4d 87 10 	movl   $0x8010874d,0x4(%esp)
80105c58:	80 
80105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5c:	89 04 24             	mov    %eax,(%esp)
80105c5f:	e8 1b c7 ff ff       	call   8010237f <dirlink>
80105c64:	85 c0                	test   %eax,%eax
80105c66:	78 21                	js     80105c89 <create+0x178>
80105c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6b:	8b 40 04             	mov    0x4(%eax),%eax
80105c6e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c72:	c7 44 24 04 4f 87 10 	movl   $0x8010874f,0x4(%esp)
80105c79:	80 
80105c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7d:	89 04 24             	mov    %eax,(%esp)
80105c80:	e8 fa c6 ff ff       	call   8010237f <dirlink>
80105c85:	85 c0                	test   %eax,%eax
80105c87:	79 0c                	jns    80105c95 <create+0x184>
      panic("create dots");
80105c89:	c7 04 24 82 87 10 80 	movl   $0x80108782,(%esp)
80105c90:	e8 a5 a8 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c98:	8b 40 04             	mov    0x4(%eax),%eax
80105c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c9f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca9:	89 04 24             	mov    %eax,(%esp)
80105cac:	e8 ce c6 ff ff       	call   8010237f <dirlink>
80105cb1:	85 c0                	test   %eax,%eax
80105cb3:	79 0c                	jns    80105cc1 <create+0x1b0>
    panic("create: dirlink");
80105cb5:	c7 04 24 8e 87 10 80 	movl   $0x8010878e,(%esp)
80105cbc:	e8 79 a8 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc4:	89 04 24             	mov    %eax,(%esp)
80105cc7:	e8 06 be ff ff       	call   80101ad2 <iunlockput>

  return ip;
80105ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ccf:	c9                   	leave  
80105cd0:	c3                   	ret    

80105cd1 <sys_open>:

int
sys_open(void)
{
80105cd1:	55                   	push   %ebp
80105cd2:	89 e5                	mov    %esp,%ebp
80105cd4:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105cd7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cda:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ce5:	e8 a3 f6 ff ff       	call   8010538d <argstr>
80105cea:	85 c0                	test   %eax,%eax
80105cec:	78 17                	js     80105d05 <sys_open+0x34>
80105cee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cfc:	e8 f2 f5 ff ff       	call   801052f3 <argint>
80105d01:	85 c0                	test   %eax,%eax
80105d03:	79 0a                	jns    80105d0f <sys_open+0x3e>
    return -1;
80105d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0a:	e9 48 01 00 00       	jmp    80105e57 <sys_open+0x186>
  if(omode & O_CREATE){
80105d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d12:	25 00 02 00 00       	and    $0x200,%eax
80105d17:	85 c0                	test   %eax,%eax
80105d19:	74 40                	je     80105d5b <sys_open+0x8a>
    begin_trans();
80105d1b:	e8 fe d6 ff ff       	call   8010341e <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d23:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105d2a:	00 
80105d2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105d32:	00 
80105d33:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105d3a:	00 
80105d3b:	89 04 24             	mov    %eax,(%esp)
80105d3e:	e8 ce fd ff ff       	call   80105b11 <create>
80105d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105d46:	e8 1c d7 ff ff       	call   80103467 <commit_trans>
    if(ip == 0)
80105d4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d4f:	75 5c                	jne    80105dad <sys_open+0xdc>
      return -1;
80105d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d56:	e9 fc 00 00 00       	jmp    80105e57 <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
80105d5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d5e:	89 04 24             	mov    %eax,(%esp)
80105d61:	e8 d9 c8 ff ff       	call   8010263f <namei>
80105d66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d6d:	75 0a                	jne    80105d79 <sys_open+0xa8>
      return -1;
80105d6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d74:	e9 de 00 00 00       	jmp    80105e57 <sys_open+0x186>
    ilock(ip);
80105d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7c:	89 04 24             	mov    %eax,(%esp)
80105d7f:	e8 ca ba ff ff       	call   8010184e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d87:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d8b:	66 83 f8 01          	cmp    $0x1,%ax
80105d8f:	75 1c                	jne    80105dad <sys_open+0xdc>
80105d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d94:	85 c0                	test   %eax,%eax
80105d96:	74 15                	je     80105dad <sys_open+0xdc>
      iunlockput(ip);
80105d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9b:	89 04 24             	mov    %eax,(%esp)
80105d9e:	e8 2f bd ff ff       	call   80101ad2 <iunlockput>
      return -1;
80105da3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da8:	e9 aa 00 00 00       	jmp    80105e57 <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105dad:	e8 67 b1 ff ff       	call   80100f19 <filealloc>
80105db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db9:	74 14                	je     80105dcf <sys_open+0xfe>
80105dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbe:	89 04 24             	mov    %eax,(%esp)
80105dc1:	e8 42 f7 ff ff       	call   80105508 <fdalloc>
80105dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105dc9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dcd:	79 23                	jns    80105df2 <sys_open+0x121>
    if(f)
80105dcf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd3:	74 0b                	je     80105de0 <sys_open+0x10f>
      fileclose(f);
80105dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd8:	89 04 24             	mov    %eax,(%esp)
80105ddb:	e8 e1 b1 ff ff       	call   80100fc1 <fileclose>
    iunlockput(ip);
80105de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de3:	89 04 24             	mov    %eax,(%esp)
80105de6:	e8 e7 bc ff ff       	call   80101ad2 <iunlockput>
    return -1;
80105deb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df0:	eb 65                	jmp    80105e57 <sys_open+0x186>
  }
  iunlock(ip);
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	89 04 24             	mov    %eax,(%esp)
80105df8:	e8 9f bb ff ff       	call   8010199c <iunlock>

  f->type = FD_INODE;
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e0c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e12:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e1c:	83 e0 01             	and    $0x1,%eax
80105e1f:	85 c0                	test   %eax,%eax
80105e21:	0f 94 c0             	sete   %al
80105e24:	89 c2                	mov    %eax,%edx
80105e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e29:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e2f:	83 e0 01             	and    $0x1,%eax
80105e32:	85 c0                	test   %eax,%eax
80105e34:	75 0a                	jne    80105e40 <sys_open+0x16f>
80105e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e39:	83 e0 02             	and    $0x2,%eax
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	74 07                	je     80105e47 <sys_open+0x176>
80105e40:	b8 01 00 00 00       	mov    $0x1,%eax
80105e45:	eb 05                	jmp    80105e4c <sys_open+0x17b>
80105e47:	b8 00 00 00 00       	mov    $0x0,%eax
80105e4c:	89 c2                	mov    %eax,%edx
80105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e51:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e54:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e57:	c9                   	leave  
80105e58:	c3                   	ret    

80105e59 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e59:	55                   	push   %ebp
80105e5a:	89 e5                	mov    %esp,%ebp
80105e5c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105e5f:	e8 ba d5 ff ff       	call   8010341e <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e72:	e8 16 f5 ff ff       	call   8010538d <argstr>
80105e77:	85 c0                	test   %eax,%eax
80105e79:	78 2c                	js     80105ea7 <sys_mkdir+0x4e>
80105e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e85:	00 
80105e86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e8d:	00 
80105e8e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105e95:	00 
80105e96:	89 04 24             	mov    %eax,(%esp)
80105e99:	e8 73 fc ff ff       	call   80105b11 <create>
80105e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ea1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea5:	75 0c                	jne    80105eb3 <sys_mkdir+0x5a>
    commit_trans();
80105ea7:	e8 bb d5 ff ff       	call   80103467 <commit_trans>
    return -1;
80105eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb1:	eb 15                	jmp    80105ec8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 14 bc ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80105ebe:	e8 a4 d5 ff ff       	call   80103467 <commit_trans>
  return 0;
80105ec3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ec8:	c9                   	leave  
80105ec9:	c3                   	ret    

80105eca <sys_mknod>:

int
sys_mknod(void)
{
80105eca:	55                   	push   %ebp
80105ecb:	89 e5                	mov    %esp,%ebp
80105ecd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105ed0:	e8 49 d5 ff ff       	call   8010341e <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105ed5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105edc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ee3:	e8 a5 f4 ff ff       	call   8010538d <argstr>
80105ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eeb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eef:	78 5e                	js     80105f4f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105ef1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105eff:	e8 ef f3 ff ff       	call   801052f3 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105f04:	85 c0                	test   %eax,%eax
80105f06:	78 47                	js     80105f4f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f08:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f16:	e8 d8 f3 ff ff       	call   801052f3 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105f1b:	85 c0                	test   %eax,%eax
80105f1d:	78 30                	js     80105f4f <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f22:	0f bf c8             	movswl %ax,%ecx
80105f25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f28:	0f bf d0             	movswl %ax,%edx
80105f2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f2e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105f32:	89 54 24 08          	mov    %edx,0x8(%esp)
80105f36:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f3d:	00 
80105f3e:	89 04 24             	mov    %eax,(%esp)
80105f41:	e8 cb fb ff ff       	call   80105b11 <create>
80105f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4d:	75 0c                	jne    80105f5b <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105f4f:	e8 13 d5 ff ff       	call   80103467 <commit_trans>
    return -1;
80105f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f59:	eb 15                	jmp    80105f70 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5e:	89 04 24             	mov    %eax,(%esp)
80105f61:	e8 6c bb ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80105f66:	e8 fc d4 ff ff       	call   80103467 <commit_trans>
  return 0;
80105f6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f70:	c9                   	leave  
80105f71:	c3                   	ret    

80105f72 <sys_chdir>:

int
sys_chdir(void)
{
80105f72:	55                   	push   %ebp
80105f73:	89 e5                	mov    %esp,%ebp
80105f75:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105f78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f86:	e8 02 f4 ff ff       	call   8010538d <argstr>
80105f8b:	85 c0                	test   %eax,%eax
80105f8d:	78 14                	js     80105fa3 <sys_chdir+0x31>
80105f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f92:	89 04 24             	mov    %eax,(%esp)
80105f95:	e8 a5 c6 ff ff       	call   8010263f <namei>
80105f9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa1:	75 07                	jne    80105faa <sys_chdir+0x38>
    return -1;
80105fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa8:	eb 57                	jmp    80106001 <sys_chdir+0x8f>
  ilock(ip);
80105faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fad:	89 04 24             	mov    %eax,(%esp)
80105fb0:	e8 99 b8 ff ff       	call   8010184e <ilock>
  if(ip->type != T_DIR){
80105fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fbc:	66 83 f8 01          	cmp    $0x1,%ax
80105fc0:	74 12                	je     80105fd4 <sys_chdir+0x62>
    iunlockput(ip);
80105fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc5:	89 04 24             	mov    %eax,(%esp)
80105fc8:	e8 05 bb ff ff       	call   80101ad2 <iunlockput>
    return -1;
80105fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd2:	eb 2d                	jmp    80106001 <sys_chdir+0x8f>
  }
  iunlock(ip);
80105fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd7:	89 04 24             	mov    %eax,(%esp)
80105fda:	e8 bd b9 ff ff       	call   8010199c <iunlock>
  iput(proc->cwd);
80105fdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fe5:	8b 40 68             	mov    0x68(%eax),%eax
80105fe8:	89 04 24             	mov    %eax,(%esp)
80105feb:	e8 11 ba ff ff       	call   80101a01 <iput>
  proc->cwd = ip;
80105ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105ffc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106001:	c9                   	leave  
80106002:	c3                   	ret    

80106003 <sys_exec>:

int
sys_exec(void)
{
80106003:	55                   	push   %ebp
80106004:	89 e5                	mov    %esp,%ebp
80106006:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010600c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010600f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106013:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010601a:	e8 6e f3 ff ff       	call   8010538d <argstr>
8010601f:	85 c0                	test   %eax,%eax
80106021:	78 1a                	js     8010603d <sys_exec+0x3a>
80106023:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106029:	89 44 24 04          	mov    %eax,0x4(%esp)
8010602d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106034:	e8 ba f2 ff ff       	call   801052f3 <argint>
80106039:	85 c0                	test   %eax,%eax
8010603b:	79 0a                	jns    80106047 <sys_exec+0x44>
    return -1;
8010603d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106042:	e9 de 00 00 00       	jmp    80106125 <sys_exec+0x122>
  }
  memset(argv, 0, sizeof(argv));
80106047:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010604e:	00 
8010604f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106056:	00 
80106057:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010605d:	89 04 24             	mov    %eax,(%esp)
80106060:	e8 58 ef ff ff       	call   80104fbd <memset>
  for(i=0;; i++){
80106065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010606c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606f:	83 f8 1f             	cmp    $0x1f,%eax
80106072:	76 0a                	jbe    8010607e <sys_exec+0x7b>
      return -1;
80106074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106079:	e9 a7 00 00 00       	jmp    80106125 <sys_exec+0x122>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
8010607e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106081:	c1 e0 02             	shl    $0x2,%eax
80106084:	89 c2                	mov    %eax,%edx
80106086:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010608c:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010608f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106095:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
8010609b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010609f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801060a3:	89 04 24             	mov    %eax,(%esp)
801060a6:	e8 b8 f1 ff ff       	call   80105263 <fetchint>
801060ab:	85 c0                	test   %eax,%eax
801060ad:	79 07                	jns    801060b6 <sys_exec+0xb3>
      return -1;
801060af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b4:	eb 6f                	jmp    80106125 <sys_exec+0x122>
    if(uarg == 0){
801060b6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060bc:	85 c0                	test   %eax,%eax
801060be:	75 26                	jne    801060e6 <sys_exec+0xe3>
      argv[i] = 0;
801060c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c3:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060ca:	00 00 00 00 
      break;
801060ce:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801060dc:	89 04 24             	mov    %eax,(%esp)
801060df:	e8 0b aa ff ff       	call   80100aef <exec>
801060e4:	eb 3f                	jmp    80106125 <sys_exec+0x122>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
801060e6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060ef:	c1 e2 02             	shl    $0x2,%edx
801060f2:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801060f5:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
801060fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106101:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106105:	89 54 24 04          	mov    %edx,0x4(%esp)
80106109:	89 04 24             	mov    %eax,(%esp)
8010610c:	e8 86 f1 ff ff       	call   80105297 <fetchstr>
80106111:	85 c0                	test   %eax,%eax
80106113:	79 07                	jns    8010611c <sys_exec+0x119>
      return -1;
80106115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611a:	eb 09                	jmp    80106125 <sys_exec+0x122>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010611c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
80106120:	e9 47 ff ff ff       	jmp    8010606c <sys_exec+0x69>
  return exec(path, argv);
}
80106125:	c9                   	leave  
80106126:	c3                   	ret    

80106127 <sys_pipe>:

int
sys_pipe(void)
{
80106127:	55                   	push   %ebp
80106128:	89 e5                	mov    %esp,%ebp
8010612a:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010612d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106134:	00 
80106135:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106138:	89 44 24 04          	mov    %eax,0x4(%esp)
8010613c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106143:	e8 e3 f1 ff ff       	call   8010532b <argptr>
80106148:	85 c0                	test   %eax,%eax
8010614a:	79 0a                	jns    80106156 <sys_pipe+0x2f>
    return -1;
8010614c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106151:	e9 9b 00 00 00       	jmp    801061f1 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106156:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106159:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106160:	89 04 24             	mov    %eax,(%esp)
80106163:	e8 b0 dc ff ff       	call   80103e18 <pipealloc>
80106168:	85 c0                	test   %eax,%eax
8010616a:	79 07                	jns    80106173 <sys_pipe+0x4c>
    return -1;
8010616c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106171:	eb 7e                	jmp    801061f1 <sys_pipe+0xca>
  fd0 = -1;
80106173:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010617a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010617d:	89 04 24             	mov    %eax,(%esp)
80106180:	e8 83 f3 ff ff       	call   80105508 <fdalloc>
80106185:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106188:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010618c:	78 14                	js     801061a2 <sys_pipe+0x7b>
8010618e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106191:	89 04 24             	mov    %eax,(%esp)
80106194:	e8 6f f3 ff ff       	call   80105508 <fdalloc>
80106199:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010619c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a0:	79 37                	jns    801061d9 <sys_pipe+0xb2>
    if(fd0 >= 0)
801061a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a6:	78 14                	js     801061bc <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801061a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061b1:	83 c2 08             	add    $0x8,%edx
801061b4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801061bb:	00 
    fileclose(rf);
801061bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061bf:	89 04 24             	mov    %eax,(%esp)
801061c2:	e8 fa ad ff ff       	call   80100fc1 <fileclose>
    fileclose(wf);
801061c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ca:	89 04 24             	mov    %eax,(%esp)
801061cd:	e8 ef ad ff ff       	call   80100fc1 <fileclose>
    return -1;
801061d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d7:	eb 18                	jmp    801061f1 <sys_pipe+0xca>
  }
  fd[0] = fd0;
801061d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061df:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061e4:	8d 50 04             	lea    0x4(%eax),%edx
801061e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ea:	89 02                	mov    %eax,(%edx)
  return 0;
801061ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f1:	c9                   	leave  
801061f2:	c3                   	ret    

801061f3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801061f3:	55                   	push   %ebp
801061f4:	89 e5                	mov    %esp,%ebp
801061f6:	83 ec 08             	sub    $0x8,%esp
  return fork();
801061f9:	e8 cc e2 ff ff       	call   801044ca <fork>
}
801061fe:	c9                   	leave  
801061ff:	c3                   	ret    

80106200 <sys_exit>:

int
sys_exit(void)
{
80106200:	55                   	push   %ebp
80106201:	89 e5                	mov    %esp,%ebp
80106203:	83 ec 08             	sub    $0x8,%esp
  exit();
80106206:	e8 22 e4 ff ff       	call   8010462d <exit>
  return 0;  // not reached
8010620b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106210:	c9                   	leave  
80106211:	c3                   	ret    

80106212 <sys_wait>:

int
sys_wait(void)
{
80106212:	55                   	push   %ebp
80106213:	89 e5                	mov    %esp,%ebp
80106215:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106218:	e8 28 e5 ff ff       	call   80104745 <wait>
}
8010621d:	c9                   	leave  
8010621e:	c3                   	ret    

8010621f <sys_kill>:

int
sys_kill(void)
{
8010621f:	55                   	push   %ebp
80106220:	89 e5                	mov    %esp,%ebp
80106222:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106225:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106228:	89 44 24 04          	mov    %eax,0x4(%esp)
8010622c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106233:	e8 bb f0 ff ff       	call   801052f3 <argint>
80106238:	85 c0                	test   %eax,%eax
8010623a:	79 07                	jns    80106243 <sys_kill+0x24>
    return -1;
8010623c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106241:	eb 0b                	jmp    8010624e <sys_kill+0x2f>
  return kill(pid);
80106243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106246:	89 04 24             	mov    %eax,(%esp)
80106249:	e8 55 e9 ff ff       	call   80104ba3 <kill>
}
8010624e:	c9                   	leave  
8010624f:	c3                   	ret    

80106250 <sys_getpid>:

int
sys_getpid(void)
{
80106250:	55                   	push   %ebp
80106251:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106253:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106259:	8b 40 10             	mov    0x10(%eax),%eax
}
8010625c:	5d                   	pop    %ebp
8010625d:	c3                   	ret    

8010625e <sys_sbrk>:

int
sys_sbrk(void)
{
8010625e:	55                   	push   %ebp
8010625f:	89 e5                	mov    %esp,%ebp
80106261:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106264:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106267:	89 44 24 04          	mov    %eax,0x4(%esp)
8010626b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106272:	e8 7c f0 ff ff       	call   801052f3 <argint>
80106277:	85 c0                	test   %eax,%eax
80106279:	79 07                	jns    80106282 <sys_sbrk+0x24>
    return -1;
8010627b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106280:	eb 24                	jmp    801062a6 <sys_sbrk+0x48>
  addr = proc->sz;
80106282:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106288:	8b 00                	mov    (%eax),%eax
8010628a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010628d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106290:	89 04 24             	mov    %eax,(%esp)
80106293:	e8 8d e1 ff ff       	call   80104425 <growproc>
80106298:	85 c0                	test   %eax,%eax
8010629a:	79 07                	jns    801062a3 <sys_sbrk+0x45>
    return -1;
8010629c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a1:	eb 03                	jmp    801062a6 <sys_sbrk+0x48>
  return addr;
801062a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062a6:	c9                   	leave  
801062a7:	c3                   	ret    

801062a8 <sys_sleep>:

int
sys_sleep(void)
{
801062a8:	55                   	push   %ebp
801062a9:	89 e5                	mov    %esp,%ebp
801062ab:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801062ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062bc:	e8 32 f0 ff ff       	call   801052f3 <argint>
801062c1:	85 c0                	test   %eax,%eax
801062c3:	79 07                	jns    801062cc <sys_sleep+0x24>
    return -1;
801062c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ca:	eb 6c                	jmp    80106338 <sys_sleep+0x90>
  acquire(&tickslock);
801062cc:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801062d3:	e8 91 ea ff ff       	call   80104d69 <acquire>
  ticks0 = ticks;
801062d8:	a1 60 27 11 80       	mov    0x80112760,%eax
801062dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801062e0:	eb 34                	jmp    80106316 <sys_sleep+0x6e>
    if(proc->killed){
801062e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e8:	8b 40 24             	mov    0x24(%eax),%eax
801062eb:	85 c0                	test   %eax,%eax
801062ed:	74 13                	je     80106302 <sys_sleep+0x5a>
      release(&tickslock);
801062ef:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801062f6:	e8 d0 ea ff ff       	call   80104dcb <release>
      return -1;
801062fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106300:	eb 36                	jmp    80106338 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106302:	c7 44 24 04 20 1f 11 	movl   $0x80111f20,0x4(%esp)
80106309:	80 
8010630a:	c7 04 24 60 27 11 80 	movl   $0x80112760,(%esp)
80106311:	e8 89 e7 ff ff       	call   80104a9f <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106316:	a1 60 27 11 80       	mov    0x80112760,%eax
8010631b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010631e:	89 c2                	mov    %eax,%edx
80106320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106323:	39 c2                	cmp    %eax,%edx
80106325:	72 bb                	jb     801062e2 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106327:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010632e:	e8 98 ea ff ff       	call   80104dcb <release>
  return 0;
80106333:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106338:	c9                   	leave  
80106339:	c3                   	ret    

8010633a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010633a:	55                   	push   %ebp
8010633b:	89 e5                	mov    %esp,%ebp
8010633d:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106340:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
80106347:	e8 1d ea ff ff       	call   80104d69 <acquire>
  xticks = ticks;
8010634c:	a1 60 27 11 80       	mov    0x80112760,%eax
80106351:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106354:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010635b:	e8 6b ea ff ff       	call   80104dcb <release>
  return xticks;
80106360:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106363:	c9                   	leave  
80106364:	c3                   	ret    

80106365 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106365:	55                   	push   %ebp
80106366:	89 e5                	mov    %esp,%ebp
80106368:	83 ec 08             	sub    $0x8,%esp
8010636b:	8b 55 08             	mov    0x8(%ebp),%edx
8010636e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106371:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106375:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106378:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010637c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106380:	ee                   	out    %al,(%dx)
}
80106381:	c9                   	leave  
80106382:	c3                   	ret    

80106383 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106383:	55                   	push   %ebp
80106384:	89 e5                	mov    %esp,%ebp
80106386:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106389:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106390:	00 
80106391:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106398:	e8 c8 ff ff ff       	call   80106365 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010639d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801063a4:	00 
801063a5:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801063ac:	e8 b4 ff ff ff       	call   80106365 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801063b1:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801063b8:	00 
801063b9:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801063c0:	e8 a0 ff ff ff       	call   80106365 <outb>
  picenable(IRQ_TIMER);
801063c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063cc:	e8 da d8 ff ff       	call   80103cab <picenable>
}
801063d1:	c9                   	leave  
801063d2:	c3                   	ret    

801063d3 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801063d3:	1e                   	push   %ds
  pushl %es
801063d4:	06                   	push   %es
  pushl %fs
801063d5:	0f a0                	push   %fs
  pushl %gs
801063d7:	0f a8                	push   %gs
  pushal
801063d9:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801063da:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801063de:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801063e0:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801063e2:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801063e6:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801063e8:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801063ea:	54                   	push   %esp
  call trap
801063eb:	e8 d8 01 00 00       	call   801065c8 <trap>
  addl $4, %esp
801063f0:	83 c4 04             	add    $0x4,%esp

801063f3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801063f3:	61                   	popa   
  popl %gs
801063f4:	0f a9                	pop    %gs
  popl %fs
801063f6:	0f a1                	pop    %fs
  popl %es
801063f8:	07                   	pop    %es
  popl %ds
801063f9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801063fa:	83 c4 08             	add    $0x8,%esp
  iret
801063fd:	cf                   	iret   

801063fe <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801063fe:	55                   	push   %ebp
801063ff:	89 e5                	mov    %esp,%ebp
80106401:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106404:	8b 45 0c             	mov    0xc(%ebp),%eax
80106407:	83 e8 01             	sub    $0x1,%eax
8010640a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010640e:	8b 45 08             	mov    0x8(%ebp),%eax
80106411:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106415:	8b 45 08             	mov    0x8(%ebp),%eax
80106418:	c1 e8 10             	shr    $0x10,%eax
8010641b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010641f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106422:	0f 01 18             	lidtl  (%eax)
}
80106425:	c9                   	leave  
80106426:	c3                   	ret    

80106427 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106427:	55                   	push   %ebp
80106428:	89 e5                	mov    %esp,%ebp
8010642a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010642d:	0f 20 d0             	mov    %cr2,%eax
80106430:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106433:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106436:	c9                   	leave  
80106437:	c3                   	ret    

80106438 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106438:	55                   	push   %ebp
80106439:	89 e5                	mov    %esp,%ebp
8010643b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010643e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106445:	e9 c3 00 00 00       	jmp    8010650d <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010644a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644d:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106454:	89 c2                	mov    %eax,%edx
80106456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106459:	66 89 14 c5 60 1f 11 	mov    %dx,-0x7feee0a0(,%eax,8)
80106460:	80 
80106461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106464:	66 c7 04 c5 62 1f 11 	movw   $0x8,-0x7feee09e(,%eax,8)
8010646b:	80 08 00 
8010646e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106471:	0f b6 14 c5 64 1f 11 	movzbl -0x7feee09c(,%eax,8),%edx
80106478:	80 
80106479:	83 e2 e0             	and    $0xffffffe0,%edx
8010647c:	88 14 c5 64 1f 11 80 	mov    %dl,-0x7feee09c(,%eax,8)
80106483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106486:	0f b6 14 c5 64 1f 11 	movzbl -0x7feee09c(,%eax,8),%edx
8010648d:	80 
8010648e:	83 e2 1f             	and    $0x1f,%edx
80106491:	88 14 c5 64 1f 11 80 	mov    %dl,-0x7feee09c(,%eax,8)
80106498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649b:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
801064a2:	80 
801064a3:	83 e2 f0             	and    $0xfffffff0,%edx
801064a6:	83 ca 0e             	or     $0xe,%edx
801064a9:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
801064b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b3:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
801064ba:	80 
801064bb:	83 e2 ef             	and    $0xffffffef,%edx
801064be:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
801064c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c8:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
801064cf:	80 
801064d0:	83 e2 9f             	and    $0xffffff9f,%edx
801064d3:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
801064da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064dd:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
801064e4:	80 
801064e5:	83 ca 80             	or     $0xffffff80,%edx
801064e8:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
801064ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f2:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801064f9:	c1 e8 10             	shr    $0x10,%eax
801064fc:	89 c2                	mov    %eax,%edx
801064fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106501:	66 89 14 c5 66 1f 11 	mov    %dx,-0x7feee09a(,%eax,8)
80106508:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106509:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010650d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106514:	0f 8e 30 ff ff ff    	jle    8010644a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010651a:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010651f:	66 a3 60 21 11 80    	mov    %ax,0x80112160
80106525:	66 c7 05 62 21 11 80 	movw   $0x8,0x80112162
8010652c:	08 00 
8010652e:	0f b6 05 64 21 11 80 	movzbl 0x80112164,%eax
80106535:	83 e0 e0             	and    $0xffffffe0,%eax
80106538:	a2 64 21 11 80       	mov    %al,0x80112164
8010653d:	0f b6 05 64 21 11 80 	movzbl 0x80112164,%eax
80106544:	83 e0 1f             	and    $0x1f,%eax
80106547:	a2 64 21 11 80       	mov    %al,0x80112164
8010654c:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106553:	83 c8 0f             	or     $0xf,%eax
80106556:	a2 65 21 11 80       	mov    %al,0x80112165
8010655b:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106562:	83 e0 ef             	and    $0xffffffef,%eax
80106565:	a2 65 21 11 80       	mov    %al,0x80112165
8010656a:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106571:	83 c8 60             	or     $0x60,%eax
80106574:	a2 65 21 11 80       	mov    %al,0x80112165
80106579:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106580:	83 c8 80             	or     $0xffffff80,%eax
80106583:	a2 65 21 11 80       	mov    %al,0x80112165
80106588:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010658d:	c1 e8 10             	shr    $0x10,%eax
80106590:	66 a3 66 21 11 80    	mov    %ax,0x80112166
  
  initlock(&tickslock, "time");
80106596:	c7 44 24 04 a0 87 10 	movl   $0x801087a0,0x4(%esp)
8010659d:	80 
8010659e:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801065a5:	e8 9e e7 ff ff       	call   80104d48 <initlock>
}
801065aa:	c9                   	leave  
801065ab:	c3                   	ret    

801065ac <idtinit>:

void
idtinit(void)
{
801065ac:	55                   	push   %ebp
801065ad:	89 e5                	mov    %esp,%ebp
801065af:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801065b2:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801065b9:	00 
801065ba:	c7 04 24 60 1f 11 80 	movl   $0x80111f60,(%esp)
801065c1:	e8 38 fe ff ff       	call   801063fe <lidt>
}
801065c6:	c9                   	leave  
801065c7:	c3                   	ret    

801065c8 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	57                   	push   %edi
801065cc:	56                   	push   %esi
801065cd:	53                   	push   %ebx
801065ce:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801065d1:	8b 45 08             	mov    0x8(%ebp),%eax
801065d4:	8b 40 30             	mov    0x30(%eax),%eax
801065d7:	83 f8 40             	cmp    $0x40,%eax
801065da:	75 3f                	jne    8010661b <trap+0x53>
    if(proc->killed)
801065dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065e2:	8b 40 24             	mov    0x24(%eax),%eax
801065e5:	85 c0                	test   %eax,%eax
801065e7:	74 05                	je     801065ee <trap+0x26>
      exit();
801065e9:	e8 3f e0 ff ff       	call   8010462d <exit>
    proc->tf = tf;
801065ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065f4:	8b 55 08             	mov    0x8(%ebp),%edx
801065f7:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801065fa:	e8 d1 ed ff ff       	call   801053d0 <syscall>
    if(proc->killed)
801065ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106605:	8b 40 24             	mov    0x24(%eax),%eax
80106608:	85 c0                	test   %eax,%eax
8010660a:	74 0a                	je     80106616 <trap+0x4e>
      exit();
8010660c:	e8 1c e0 ff ff       	call   8010462d <exit>
    return;
80106611:	e9 2d 02 00 00       	jmp    80106843 <trap+0x27b>
80106616:	e9 28 02 00 00       	jmp    80106843 <trap+0x27b>
  }

  switch(tf->trapno){
8010661b:	8b 45 08             	mov    0x8(%ebp),%eax
8010661e:	8b 40 30             	mov    0x30(%eax),%eax
80106621:	83 e8 20             	sub    $0x20,%eax
80106624:	83 f8 1f             	cmp    $0x1f,%eax
80106627:	0f 87 bc 00 00 00    	ja     801066e9 <trap+0x121>
8010662d:	8b 04 85 48 88 10 80 	mov    -0x7fef77b8(,%eax,4),%eax
80106634:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106636:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010663c:	0f b6 00             	movzbl (%eax),%eax
8010663f:	84 c0                	test   %al,%al
80106641:	75 31                	jne    80106674 <trap+0xac>
      acquire(&tickslock);
80106643:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010664a:	e8 1a e7 ff ff       	call   80104d69 <acquire>
      ticks++;
8010664f:	a1 60 27 11 80       	mov    0x80112760,%eax
80106654:	83 c0 01             	add    $0x1,%eax
80106657:	a3 60 27 11 80       	mov    %eax,0x80112760
      wakeup(&ticks);
8010665c:	c7 04 24 60 27 11 80 	movl   $0x80112760,(%esp)
80106663:	e8 10 e5 ff ff       	call   80104b78 <wakeup>
      release(&tickslock);
80106668:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010666f:	e8 57 e7 ff ff       	call   80104dcb <release>
    }
    lapiceoi();
80106674:	e8 73 ca ff ff       	call   801030ec <lapiceoi>
    break;
80106679:	e9 41 01 00 00       	jmp    801067bf <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010667e:	e8 94 c2 ff ff       	call   80102917 <ideintr>
    lapiceoi();
80106683:	e8 64 ca ff ff       	call   801030ec <lapiceoi>
    break;
80106688:	e9 32 01 00 00       	jmp    801067bf <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010668d:	e8 46 c8 ff ff       	call   80102ed8 <kbdintr>
    lapiceoi();
80106692:	e8 55 ca ff ff       	call   801030ec <lapiceoi>
    break;
80106697:	e9 23 01 00 00       	jmp    801067bf <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010669c:	e8 97 03 00 00       	call   80106a38 <uartintr>
    lapiceoi();
801066a1:	e8 46 ca ff ff       	call   801030ec <lapiceoi>
    break;
801066a6:	e9 14 01 00 00       	jmp    801067bf <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066ab:	8b 45 08             	mov    0x8(%ebp),%eax
801066ae:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801066b1:	8b 45 08             	mov    0x8(%ebp),%eax
801066b4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066b8:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801066bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801066c1:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066c4:	0f b6 c0             	movzbl %al,%eax
801066c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801066cb:	89 54 24 08          	mov    %edx,0x8(%esp)
801066cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d3:	c7 04 24 a8 87 10 80 	movl   $0x801087a8,(%esp)
801066da:	e8 c1 9c ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801066df:	e8 08 ca ff ff       	call   801030ec <lapiceoi>
    break;
801066e4:	e9 d6 00 00 00       	jmp    801067bf <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801066e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ef:	85 c0                	test   %eax,%eax
801066f1:	74 11                	je     80106704 <trap+0x13c>
801066f3:	8b 45 08             	mov    0x8(%ebp),%eax
801066f6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066fa:	0f b7 c0             	movzwl %ax,%eax
801066fd:	83 e0 03             	and    $0x3,%eax
80106700:	85 c0                	test   %eax,%eax
80106702:	75 46                	jne    8010674a <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106704:	e8 1e fd ff ff       	call   80106427 <rcr2>
80106709:	8b 55 08             	mov    0x8(%ebp),%edx
8010670c:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010670f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106716:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106719:	0f b6 ca             	movzbl %dl,%ecx
8010671c:	8b 55 08             	mov    0x8(%ebp),%edx
8010671f:	8b 52 30             	mov    0x30(%edx),%edx
80106722:	89 44 24 10          	mov    %eax,0x10(%esp)
80106726:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010672a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010672e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106732:	c7 04 24 cc 87 10 80 	movl   $0x801087cc,(%esp)
80106739:	e8 62 9c ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010673e:	c7 04 24 fe 87 10 80 	movl   $0x801087fe,(%esp)
80106745:	e8 f0 9d ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010674a:	e8 d8 fc ff ff       	call   80106427 <rcr2>
8010674f:	89 c2                	mov    %eax,%edx
80106751:	8b 45 08             	mov    0x8(%ebp),%eax
80106754:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106757:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010675d:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106760:	0f b6 f0             	movzbl %al,%esi
80106763:	8b 45 08             	mov    0x8(%ebp),%eax
80106766:	8b 58 34             	mov    0x34(%eax),%ebx
80106769:	8b 45 08             	mov    0x8(%ebp),%eax
8010676c:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010676f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106775:	83 c0 6c             	add    $0x6c,%eax
80106778:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010677b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106781:	8b 40 10             	mov    0x10(%eax),%eax
80106784:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106788:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010678c:	89 74 24 14          	mov    %esi,0x14(%esp)
80106790:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106794:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106798:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010679b:	89 74 24 08          	mov    %esi,0x8(%esp)
8010679f:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a3:	c7 04 24 04 88 10 80 	movl   $0x80108804,(%esp)
801067aa:	e8 f1 9b ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801067af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067b5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801067bc:	eb 01                	jmp    801067bf <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801067be:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801067bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067c5:	85 c0                	test   %eax,%eax
801067c7:	74 24                	je     801067ed <trap+0x225>
801067c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067cf:	8b 40 24             	mov    0x24(%eax),%eax
801067d2:	85 c0                	test   %eax,%eax
801067d4:	74 17                	je     801067ed <trap+0x225>
801067d6:	8b 45 08             	mov    0x8(%ebp),%eax
801067d9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067dd:	0f b7 c0             	movzwl %ax,%eax
801067e0:	83 e0 03             	and    $0x3,%eax
801067e3:	83 f8 03             	cmp    $0x3,%eax
801067e6:	75 05                	jne    801067ed <trap+0x225>
    exit();
801067e8:	e8 40 de ff ff       	call   8010462d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801067ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067f3:	85 c0                	test   %eax,%eax
801067f5:	74 1e                	je     80106815 <trap+0x24d>
801067f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067fd:	8b 40 0c             	mov    0xc(%eax),%eax
80106800:	83 f8 04             	cmp    $0x4,%eax
80106803:	75 10                	jne    80106815 <trap+0x24d>
80106805:	8b 45 08             	mov    0x8(%ebp),%eax
80106808:	8b 40 30             	mov    0x30(%eax),%eax
8010680b:	83 f8 20             	cmp    $0x20,%eax
8010680e:	75 05                	jne    80106815 <trap+0x24d>
    yield();
80106810:	e8 2c e2 ff ff       	call   80104a41 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106815:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010681b:	85 c0                	test   %eax,%eax
8010681d:	74 24                	je     80106843 <trap+0x27b>
8010681f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106825:	8b 40 24             	mov    0x24(%eax),%eax
80106828:	85 c0                	test   %eax,%eax
8010682a:	74 17                	je     80106843 <trap+0x27b>
8010682c:	8b 45 08             	mov    0x8(%ebp),%eax
8010682f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106833:	0f b7 c0             	movzwl %ax,%eax
80106836:	83 e0 03             	and    $0x3,%eax
80106839:	83 f8 03             	cmp    $0x3,%eax
8010683c:	75 05                	jne    80106843 <trap+0x27b>
    exit();
8010683e:	e8 ea dd ff ff       	call   8010462d <exit>
}
80106843:	83 c4 3c             	add    $0x3c,%esp
80106846:	5b                   	pop    %ebx
80106847:	5e                   	pop    %esi
80106848:	5f                   	pop    %edi
80106849:	5d                   	pop    %ebp
8010684a:	c3                   	ret    

8010684b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010684b:	55                   	push   %ebp
8010684c:	89 e5                	mov    %esp,%ebp
8010684e:	83 ec 14             	sub    $0x14,%esp
80106851:	8b 45 08             	mov    0x8(%ebp),%eax
80106854:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106858:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010685c:	89 c2                	mov    %eax,%edx
8010685e:	ec                   	in     (%dx),%al
8010685f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106862:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106866:	c9                   	leave  
80106867:	c3                   	ret    

80106868 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106868:	55                   	push   %ebp
80106869:	89 e5                	mov    %esp,%ebp
8010686b:	83 ec 08             	sub    $0x8,%esp
8010686e:	8b 55 08             	mov    0x8(%ebp),%edx
80106871:	8b 45 0c             	mov    0xc(%ebp),%eax
80106874:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106878:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010687b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010687f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106883:	ee                   	out    %al,(%dx)
}
80106884:	c9                   	leave  
80106885:	c3                   	ret    

80106886 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106886:	55                   	push   %ebp
80106887:	89 e5                	mov    %esp,%ebp
80106889:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010688c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106893:	00 
80106894:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010689b:	e8 c8 ff ff ff       	call   80106868 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801068a0:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801068a7:	00 
801068a8:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801068af:	e8 b4 ff ff ff       	call   80106868 <outb>
  outb(COM1+0, 115200/9600);
801068b4:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801068bb:	00 
801068bc:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068c3:	e8 a0 ff ff ff       	call   80106868 <outb>
  outb(COM1+1, 0);
801068c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068cf:	00 
801068d0:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801068d7:	e8 8c ff ff ff       	call   80106868 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801068dc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801068e3:	00 
801068e4:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801068eb:	e8 78 ff ff ff       	call   80106868 <outb>
  outb(COM1+4, 0);
801068f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068f7:	00 
801068f8:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801068ff:	e8 64 ff ff ff       	call   80106868 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106904:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010690b:	00 
8010690c:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106913:	e8 50 ff ff ff       	call   80106868 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106918:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010691f:	e8 27 ff ff ff       	call   8010684b <inb>
80106924:	3c ff                	cmp    $0xff,%al
80106926:	75 02                	jne    8010692a <uartinit+0xa4>
    return;
80106928:	eb 6a                	jmp    80106994 <uartinit+0x10e>
  uart = 1;
8010692a:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106931:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106934:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010693b:	e8 0b ff ff ff       	call   8010684b <inb>
  inb(COM1+0);
80106940:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106947:	e8 ff fe ff ff       	call   8010684b <inb>
  picenable(IRQ_COM1);
8010694c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106953:	e8 53 d3 ff ff       	call   80103cab <picenable>
  ioapicenable(IRQ_COM1, 0);
80106958:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010695f:	00 
80106960:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106967:	e8 2a c2 ff ff       	call   80102b96 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010696c:	c7 45 f4 c8 88 10 80 	movl   $0x801088c8,-0xc(%ebp)
80106973:	eb 15                	jmp    8010698a <uartinit+0x104>
    uartputc(*p);
80106975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106978:	0f b6 00             	movzbl (%eax),%eax
8010697b:	0f be c0             	movsbl %al,%eax
8010697e:	89 04 24             	mov    %eax,(%esp)
80106981:	e8 10 00 00 00       	call   80106996 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106986:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010698a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698d:	0f b6 00             	movzbl (%eax),%eax
80106990:	84 c0                	test   %al,%al
80106992:	75 e1                	jne    80106975 <uartinit+0xef>
    uartputc(*p);
}
80106994:	c9                   	leave  
80106995:	c3                   	ret    

80106996 <uartputc>:

void
uartputc(int c)
{
80106996:	55                   	push   %ebp
80106997:	89 e5                	mov    %esp,%ebp
80106999:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010699c:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801069a1:	85 c0                	test   %eax,%eax
801069a3:	75 02                	jne    801069a7 <uartputc+0x11>
    return;
801069a5:	eb 4b                	jmp    801069f2 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069ae:	eb 10                	jmp    801069c0 <uartputc+0x2a>
    microdelay(10);
801069b0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801069b7:	e8 55 c7 ff ff       	call   80103111 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069c0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801069c4:	7f 16                	jg     801069dc <uartputc+0x46>
801069c6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801069cd:	e8 79 fe ff ff       	call   8010684b <inb>
801069d2:	0f b6 c0             	movzbl %al,%eax
801069d5:	83 e0 20             	and    $0x20,%eax
801069d8:	85 c0                	test   %eax,%eax
801069da:	74 d4                	je     801069b0 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801069dc:	8b 45 08             	mov    0x8(%ebp),%eax
801069df:	0f b6 c0             	movzbl %al,%eax
801069e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069ed:	e8 76 fe ff ff       	call   80106868 <outb>
}
801069f2:	c9                   	leave  
801069f3:	c3                   	ret    

801069f4 <uartgetc>:

static int
uartgetc(void)
{
801069f4:	55                   	push   %ebp
801069f5:	89 e5                	mov    %esp,%ebp
801069f7:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801069fa:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801069ff:	85 c0                	test   %eax,%eax
80106a01:	75 07                	jne    80106a0a <uartgetc+0x16>
    return -1;
80106a03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a08:	eb 2c                	jmp    80106a36 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106a0a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a11:	e8 35 fe ff ff       	call   8010684b <inb>
80106a16:	0f b6 c0             	movzbl %al,%eax
80106a19:	83 e0 01             	and    $0x1,%eax
80106a1c:	85 c0                	test   %eax,%eax
80106a1e:	75 07                	jne    80106a27 <uartgetc+0x33>
    return -1;
80106a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a25:	eb 0f                	jmp    80106a36 <uartgetc+0x42>
  return inb(COM1+0);
80106a27:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a2e:	e8 18 fe ff ff       	call   8010684b <inb>
80106a33:	0f b6 c0             	movzbl %al,%eax
}
80106a36:	c9                   	leave  
80106a37:	c3                   	ret    

80106a38 <uartintr>:

void
uartintr(void)
{
80106a38:	55                   	push   %ebp
80106a39:	89 e5                	mov    %esp,%ebp
80106a3b:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106a3e:	c7 04 24 f4 69 10 80 	movl   $0x801069f4,(%esp)
80106a45:	e8 63 9d ff ff       	call   801007ad <consoleintr>
}
80106a4a:	c9                   	leave  
80106a4b:	c3                   	ret    

80106a4c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $0
80106a4e:	6a 00                	push   $0x0
  jmp alltraps
80106a50:	e9 7e f9 ff ff       	jmp    801063d3 <alltraps>

80106a55 <vector1>:
.globl vector1
vector1:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $1
80106a57:	6a 01                	push   $0x1
  jmp alltraps
80106a59:	e9 75 f9 ff ff       	jmp    801063d3 <alltraps>

80106a5e <vector2>:
.globl vector2
vector2:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $2
80106a60:	6a 02                	push   $0x2
  jmp alltraps
80106a62:	e9 6c f9 ff ff       	jmp    801063d3 <alltraps>

80106a67 <vector3>:
.globl vector3
vector3:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $3
80106a69:	6a 03                	push   $0x3
  jmp alltraps
80106a6b:	e9 63 f9 ff ff       	jmp    801063d3 <alltraps>

80106a70 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $4
80106a72:	6a 04                	push   $0x4
  jmp alltraps
80106a74:	e9 5a f9 ff ff       	jmp    801063d3 <alltraps>

80106a79 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $5
80106a7b:	6a 05                	push   $0x5
  jmp alltraps
80106a7d:	e9 51 f9 ff ff       	jmp    801063d3 <alltraps>

80106a82 <vector6>:
.globl vector6
vector6:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $6
80106a84:	6a 06                	push   $0x6
  jmp alltraps
80106a86:	e9 48 f9 ff ff       	jmp    801063d3 <alltraps>

80106a8b <vector7>:
.globl vector7
vector7:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $7
80106a8d:	6a 07                	push   $0x7
  jmp alltraps
80106a8f:	e9 3f f9 ff ff       	jmp    801063d3 <alltraps>

80106a94 <vector8>:
.globl vector8
vector8:
  pushl $8
80106a94:	6a 08                	push   $0x8
  jmp alltraps
80106a96:	e9 38 f9 ff ff       	jmp    801063d3 <alltraps>

80106a9b <vector9>:
.globl vector9
vector9:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $9
80106a9d:	6a 09                	push   $0x9
  jmp alltraps
80106a9f:	e9 2f f9 ff ff       	jmp    801063d3 <alltraps>

80106aa4 <vector10>:
.globl vector10
vector10:
  pushl $10
80106aa4:	6a 0a                	push   $0xa
  jmp alltraps
80106aa6:	e9 28 f9 ff ff       	jmp    801063d3 <alltraps>

80106aab <vector11>:
.globl vector11
vector11:
  pushl $11
80106aab:	6a 0b                	push   $0xb
  jmp alltraps
80106aad:	e9 21 f9 ff ff       	jmp    801063d3 <alltraps>

80106ab2 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ab2:	6a 0c                	push   $0xc
  jmp alltraps
80106ab4:	e9 1a f9 ff ff       	jmp    801063d3 <alltraps>

80106ab9 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ab9:	6a 0d                	push   $0xd
  jmp alltraps
80106abb:	e9 13 f9 ff ff       	jmp    801063d3 <alltraps>

80106ac0 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ac0:	6a 0e                	push   $0xe
  jmp alltraps
80106ac2:	e9 0c f9 ff ff       	jmp    801063d3 <alltraps>

80106ac7 <vector15>:
.globl vector15
vector15:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $15
80106ac9:	6a 0f                	push   $0xf
  jmp alltraps
80106acb:	e9 03 f9 ff ff       	jmp    801063d3 <alltraps>

80106ad0 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ad0:	6a 00                	push   $0x0
  pushl $16
80106ad2:	6a 10                	push   $0x10
  jmp alltraps
80106ad4:	e9 fa f8 ff ff       	jmp    801063d3 <alltraps>

80106ad9 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ad9:	6a 11                	push   $0x11
  jmp alltraps
80106adb:	e9 f3 f8 ff ff       	jmp    801063d3 <alltraps>

80106ae0 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $18
80106ae2:	6a 12                	push   $0x12
  jmp alltraps
80106ae4:	e9 ea f8 ff ff       	jmp    801063d3 <alltraps>

80106ae9 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $19
80106aeb:	6a 13                	push   $0x13
  jmp alltraps
80106aed:	e9 e1 f8 ff ff       	jmp    801063d3 <alltraps>

80106af2 <vector20>:
.globl vector20
vector20:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $20
80106af4:	6a 14                	push   $0x14
  jmp alltraps
80106af6:	e9 d8 f8 ff ff       	jmp    801063d3 <alltraps>

80106afb <vector21>:
.globl vector21
vector21:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $21
80106afd:	6a 15                	push   $0x15
  jmp alltraps
80106aff:	e9 cf f8 ff ff       	jmp    801063d3 <alltraps>

80106b04 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $22
80106b06:	6a 16                	push   $0x16
  jmp alltraps
80106b08:	e9 c6 f8 ff ff       	jmp    801063d3 <alltraps>

80106b0d <vector23>:
.globl vector23
vector23:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $23
80106b0f:	6a 17                	push   $0x17
  jmp alltraps
80106b11:	e9 bd f8 ff ff       	jmp    801063d3 <alltraps>

80106b16 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $24
80106b18:	6a 18                	push   $0x18
  jmp alltraps
80106b1a:	e9 b4 f8 ff ff       	jmp    801063d3 <alltraps>

80106b1f <vector25>:
.globl vector25
vector25:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $25
80106b21:	6a 19                	push   $0x19
  jmp alltraps
80106b23:	e9 ab f8 ff ff       	jmp    801063d3 <alltraps>

80106b28 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $26
80106b2a:	6a 1a                	push   $0x1a
  jmp alltraps
80106b2c:	e9 a2 f8 ff ff       	jmp    801063d3 <alltraps>

80106b31 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $27
80106b33:	6a 1b                	push   $0x1b
  jmp alltraps
80106b35:	e9 99 f8 ff ff       	jmp    801063d3 <alltraps>

80106b3a <vector28>:
.globl vector28
vector28:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $28
80106b3c:	6a 1c                	push   $0x1c
  jmp alltraps
80106b3e:	e9 90 f8 ff ff       	jmp    801063d3 <alltraps>

80106b43 <vector29>:
.globl vector29
vector29:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $29
80106b45:	6a 1d                	push   $0x1d
  jmp alltraps
80106b47:	e9 87 f8 ff ff       	jmp    801063d3 <alltraps>

80106b4c <vector30>:
.globl vector30
vector30:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $30
80106b4e:	6a 1e                	push   $0x1e
  jmp alltraps
80106b50:	e9 7e f8 ff ff       	jmp    801063d3 <alltraps>

80106b55 <vector31>:
.globl vector31
vector31:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $31
80106b57:	6a 1f                	push   $0x1f
  jmp alltraps
80106b59:	e9 75 f8 ff ff       	jmp    801063d3 <alltraps>

80106b5e <vector32>:
.globl vector32
vector32:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $32
80106b60:	6a 20                	push   $0x20
  jmp alltraps
80106b62:	e9 6c f8 ff ff       	jmp    801063d3 <alltraps>

80106b67 <vector33>:
.globl vector33
vector33:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $33
80106b69:	6a 21                	push   $0x21
  jmp alltraps
80106b6b:	e9 63 f8 ff ff       	jmp    801063d3 <alltraps>

80106b70 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $34
80106b72:	6a 22                	push   $0x22
  jmp alltraps
80106b74:	e9 5a f8 ff ff       	jmp    801063d3 <alltraps>

80106b79 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $35
80106b7b:	6a 23                	push   $0x23
  jmp alltraps
80106b7d:	e9 51 f8 ff ff       	jmp    801063d3 <alltraps>

80106b82 <vector36>:
.globl vector36
vector36:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $36
80106b84:	6a 24                	push   $0x24
  jmp alltraps
80106b86:	e9 48 f8 ff ff       	jmp    801063d3 <alltraps>

80106b8b <vector37>:
.globl vector37
vector37:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $37
80106b8d:	6a 25                	push   $0x25
  jmp alltraps
80106b8f:	e9 3f f8 ff ff       	jmp    801063d3 <alltraps>

80106b94 <vector38>:
.globl vector38
vector38:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $38
80106b96:	6a 26                	push   $0x26
  jmp alltraps
80106b98:	e9 36 f8 ff ff       	jmp    801063d3 <alltraps>

80106b9d <vector39>:
.globl vector39
vector39:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $39
80106b9f:	6a 27                	push   $0x27
  jmp alltraps
80106ba1:	e9 2d f8 ff ff       	jmp    801063d3 <alltraps>

80106ba6 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $40
80106ba8:	6a 28                	push   $0x28
  jmp alltraps
80106baa:	e9 24 f8 ff ff       	jmp    801063d3 <alltraps>

80106baf <vector41>:
.globl vector41
vector41:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $41
80106bb1:	6a 29                	push   $0x29
  jmp alltraps
80106bb3:	e9 1b f8 ff ff       	jmp    801063d3 <alltraps>

80106bb8 <vector42>:
.globl vector42
vector42:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $42
80106bba:	6a 2a                	push   $0x2a
  jmp alltraps
80106bbc:	e9 12 f8 ff ff       	jmp    801063d3 <alltraps>

80106bc1 <vector43>:
.globl vector43
vector43:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $43
80106bc3:	6a 2b                	push   $0x2b
  jmp alltraps
80106bc5:	e9 09 f8 ff ff       	jmp    801063d3 <alltraps>

80106bca <vector44>:
.globl vector44
vector44:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $44
80106bcc:	6a 2c                	push   $0x2c
  jmp alltraps
80106bce:	e9 00 f8 ff ff       	jmp    801063d3 <alltraps>

80106bd3 <vector45>:
.globl vector45
vector45:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $45
80106bd5:	6a 2d                	push   $0x2d
  jmp alltraps
80106bd7:	e9 f7 f7 ff ff       	jmp    801063d3 <alltraps>

80106bdc <vector46>:
.globl vector46
vector46:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $46
80106bde:	6a 2e                	push   $0x2e
  jmp alltraps
80106be0:	e9 ee f7 ff ff       	jmp    801063d3 <alltraps>

80106be5 <vector47>:
.globl vector47
vector47:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $47
80106be7:	6a 2f                	push   $0x2f
  jmp alltraps
80106be9:	e9 e5 f7 ff ff       	jmp    801063d3 <alltraps>

80106bee <vector48>:
.globl vector48
vector48:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $48
80106bf0:	6a 30                	push   $0x30
  jmp alltraps
80106bf2:	e9 dc f7 ff ff       	jmp    801063d3 <alltraps>

80106bf7 <vector49>:
.globl vector49
vector49:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $49
80106bf9:	6a 31                	push   $0x31
  jmp alltraps
80106bfb:	e9 d3 f7 ff ff       	jmp    801063d3 <alltraps>

80106c00 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $50
80106c02:	6a 32                	push   $0x32
  jmp alltraps
80106c04:	e9 ca f7 ff ff       	jmp    801063d3 <alltraps>

80106c09 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $51
80106c0b:	6a 33                	push   $0x33
  jmp alltraps
80106c0d:	e9 c1 f7 ff ff       	jmp    801063d3 <alltraps>

80106c12 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $52
80106c14:	6a 34                	push   $0x34
  jmp alltraps
80106c16:	e9 b8 f7 ff ff       	jmp    801063d3 <alltraps>

80106c1b <vector53>:
.globl vector53
vector53:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $53
80106c1d:	6a 35                	push   $0x35
  jmp alltraps
80106c1f:	e9 af f7 ff ff       	jmp    801063d3 <alltraps>

80106c24 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $54
80106c26:	6a 36                	push   $0x36
  jmp alltraps
80106c28:	e9 a6 f7 ff ff       	jmp    801063d3 <alltraps>

80106c2d <vector55>:
.globl vector55
vector55:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $55
80106c2f:	6a 37                	push   $0x37
  jmp alltraps
80106c31:	e9 9d f7 ff ff       	jmp    801063d3 <alltraps>

80106c36 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $56
80106c38:	6a 38                	push   $0x38
  jmp alltraps
80106c3a:	e9 94 f7 ff ff       	jmp    801063d3 <alltraps>

80106c3f <vector57>:
.globl vector57
vector57:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $57
80106c41:	6a 39                	push   $0x39
  jmp alltraps
80106c43:	e9 8b f7 ff ff       	jmp    801063d3 <alltraps>

80106c48 <vector58>:
.globl vector58
vector58:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $58
80106c4a:	6a 3a                	push   $0x3a
  jmp alltraps
80106c4c:	e9 82 f7 ff ff       	jmp    801063d3 <alltraps>

80106c51 <vector59>:
.globl vector59
vector59:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $59
80106c53:	6a 3b                	push   $0x3b
  jmp alltraps
80106c55:	e9 79 f7 ff ff       	jmp    801063d3 <alltraps>

80106c5a <vector60>:
.globl vector60
vector60:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $60
80106c5c:	6a 3c                	push   $0x3c
  jmp alltraps
80106c5e:	e9 70 f7 ff ff       	jmp    801063d3 <alltraps>

80106c63 <vector61>:
.globl vector61
vector61:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $61
80106c65:	6a 3d                	push   $0x3d
  jmp alltraps
80106c67:	e9 67 f7 ff ff       	jmp    801063d3 <alltraps>

80106c6c <vector62>:
.globl vector62
vector62:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $62
80106c6e:	6a 3e                	push   $0x3e
  jmp alltraps
80106c70:	e9 5e f7 ff ff       	jmp    801063d3 <alltraps>

80106c75 <vector63>:
.globl vector63
vector63:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $63
80106c77:	6a 3f                	push   $0x3f
  jmp alltraps
80106c79:	e9 55 f7 ff ff       	jmp    801063d3 <alltraps>

80106c7e <vector64>:
.globl vector64
vector64:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $64
80106c80:	6a 40                	push   $0x40
  jmp alltraps
80106c82:	e9 4c f7 ff ff       	jmp    801063d3 <alltraps>

80106c87 <vector65>:
.globl vector65
vector65:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $65
80106c89:	6a 41                	push   $0x41
  jmp alltraps
80106c8b:	e9 43 f7 ff ff       	jmp    801063d3 <alltraps>

80106c90 <vector66>:
.globl vector66
vector66:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $66
80106c92:	6a 42                	push   $0x42
  jmp alltraps
80106c94:	e9 3a f7 ff ff       	jmp    801063d3 <alltraps>

80106c99 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $67
80106c9b:	6a 43                	push   $0x43
  jmp alltraps
80106c9d:	e9 31 f7 ff ff       	jmp    801063d3 <alltraps>

80106ca2 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $68
80106ca4:	6a 44                	push   $0x44
  jmp alltraps
80106ca6:	e9 28 f7 ff ff       	jmp    801063d3 <alltraps>

80106cab <vector69>:
.globl vector69
vector69:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $69
80106cad:	6a 45                	push   $0x45
  jmp alltraps
80106caf:	e9 1f f7 ff ff       	jmp    801063d3 <alltraps>

80106cb4 <vector70>:
.globl vector70
vector70:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $70
80106cb6:	6a 46                	push   $0x46
  jmp alltraps
80106cb8:	e9 16 f7 ff ff       	jmp    801063d3 <alltraps>

80106cbd <vector71>:
.globl vector71
vector71:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $71
80106cbf:	6a 47                	push   $0x47
  jmp alltraps
80106cc1:	e9 0d f7 ff ff       	jmp    801063d3 <alltraps>

80106cc6 <vector72>:
.globl vector72
vector72:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $72
80106cc8:	6a 48                	push   $0x48
  jmp alltraps
80106cca:	e9 04 f7 ff ff       	jmp    801063d3 <alltraps>

80106ccf <vector73>:
.globl vector73
vector73:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $73
80106cd1:	6a 49                	push   $0x49
  jmp alltraps
80106cd3:	e9 fb f6 ff ff       	jmp    801063d3 <alltraps>

80106cd8 <vector74>:
.globl vector74
vector74:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $74
80106cda:	6a 4a                	push   $0x4a
  jmp alltraps
80106cdc:	e9 f2 f6 ff ff       	jmp    801063d3 <alltraps>

80106ce1 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $75
80106ce3:	6a 4b                	push   $0x4b
  jmp alltraps
80106ce5:	e9 e9 f6 ff ff       	jmp    801063d3 <alltraps>

80106cea <vector76>:
.globl vector76
vector76:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $76
80106cec:	6a 4c                	push   $0x4c
  jmp alltraps
80106cee:	e9 e0 f6 ff ff       	jmp    801063d3 <alltraps>

80106cf3 <vector77>:
.globl vector77
vector77:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $77
80106cf5:	6a 4d                	push   $0x4d
  jmp alltraps
80106cf7:	e9 d7 f6 ff ff       	jmp    801063d3 <alltraps>

80106cfc <vector78>:
.globl vector78
vector78:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $78
80106cfe:	6a 4e                	push   $0x4e
  jmp alltraps
80106d00:	e9 ce f6 ff ff       	jmp    801063d3 <alltraps>

80106d05 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $79
80106d07:	6a 4f                	push   $0x4f
  jmp alltraps
80106d09:	e9 c5 f6 ff ff       	jmp    801063d3 <alltraps>

80106d0e <vector80>:
.globl vector80
vector80:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $80
80106d10:	6a 50                	push   $0x50
  jmp alltraps
80106d12:	e9 bc f6 ff ff       	jmp    801063d3 <alltraps>

80106d17 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $81
80106d19:	6a 51                	push   $0x51
  jmp alltraps
80106d1b:	e9 b3 f6 ff ff       	jmp    801063d3 <alltraps>

80106d20 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $82
80106d22:	6a 52                	push   $0x52
  jmp alltraps
80106d24:	e9 aa f6 ff ff       	jmp    801063d3 <alltraps>

80106d29 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $83
80106d2b:	6a 53                	push   $0x53
  jmp alltraps
80106d2d:	e9 a1 f6 ff ff       	jmp    801063d3 <alltraps>

80106d32 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $84
80106d34:	6a 54                	push   $0x54
  jmp alltraps
80106d36:	e9 98 f6 ff ff       	jmp    801063d3 <alltraps>

80106d3b <vector85>:
.globl vector85
vector85:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $85
80106d3d:	6a 55                	push   $0x55
  jmp alltraps
80106d3f:	e9 8f f6 ff ff       	jmp    801063d3 <alltraps>

80106d44 <vector86>:
.globl vector86
vector86:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $86
80106d46:	6a 56                	push   $0x56
  jmp alltraps
80106d48:	e9 86 f6 ff ff       	jmp    801063d3 <alltraps>

80106d4d <vector87>:
.globl vector87
vector87:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $87
80106d4f:	6a 57                	push   $0x57
  jmp alltraps
80106d51:	e9 7d f6 ff ff       	jmp    801063d3 <alltraps>

80106d56 <vector88>:
.globl vector88
vector88:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $88
80106d58:	6a 58                	push   $0x58
  jmp alltraps
80106d5a:	e9 74 f6 ff ff       	jmp    801063d3 <alltraps>

80106d5f <vector89>:
.globl vector89
vector89:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $89
80106d61:	6a 59                	push   $0x59
  jmp alltraps
80106d63:	e9 6b f6 ff ff       	jmp    801063d3 <alltraps>

80106d68 <vector90>:
.globl vector90
vector90:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $90
80106d6a:	6a 5a                	push   $0x5a
  jmp alltraps
80106d6c:	e9 62 f6 ff ff       	jmp    801063d3 <alltraps>

80106d71 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $91
80106d73:	6a 5b                	push   $0x5b
  jmp alltraps
80106d75:	e9 59 f6 ff ff       	jmp    801063d3 <alltraps>

80106d7a <vector92>:
.globl vector92
vector92:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $92
80106d7c:	6a 5c                	push   $0x5c
  jmp alltraps
80106d7e:	e9 50 f6 ff ff       	jmp    801063d3 <alltraps>

80106d83 <vector93>:
.globl vector93
vector93:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $93
80106d85:	6a 5d                	push   $0x5d
  jmp alltraps
80106d87:	e9 47 f6 ff ff       	jmp    801063d3 <alltraps>

80106d8c <vector94>:
.globl vector94
vector94:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $94
80106d8e:	6a 5e                	push   $0x5e
  jmp alltraps
80106d90:	e9 3e f6 ff ff       	jmp    801063d3 <alltraps>

80106d95 <vector95>:
.globl vector95
vector95:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $95
80106d97:	6a 5f                	push   $0x5f
  jmp alltraps
80106d99:	e9 35 f6 ff ff       	jmp    801063d3 <alltraps>

80106d9e <vector96>:
.globl vector96
vector96:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $96
80106da0:	6a 60                	push   $0x60
  jmp alltraps
80106da2:	e9 2c f6 ff ff       	jmp    801063d3 <alltraps>

80106da7 <vector97>:
.globl vector97
vector97:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $97
80106da9:	6a 61                	push   $0x61
  jmp alltraps
80106dab:	e9 23 f6 ff ff       	jmp    801063d3 <alltraps>

80106db0 <vector98>:
.globl vector98
vector98:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $98
80106db2:	6a 62                	push   $0x62
  jmp alltraps
80106db4:	e9 1a f6 ff ff       	jmp    801063d3 <alltraps>

80106db9 <vector99>:
.globl vector99
vector99:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $99
80106dbb:	6a 63                	push   $0x63
  jmp alltraps
80106dbd:	e9 11 f6 ff ff       	jmp    801063d3 <alltraps>

80106dc2 <vector100>:
.globl vector100
vector100:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $100
80106dc4:	6a 64                	push   $0x64
  jmp alltraps
80106dc6:	e9 08 f6 ff ff       	jmp    801063d3 <alltraps>

80106dcb <vector101>:
.globl vector101
vector101:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $101
80106dcd:	6a 65                	push   $0x65
  jmp alltraps
80106dcf:	e9 ff f5 ff ff       	jmp    801063d3 <alltraps>

80106dd4 <vector102>:
.globl vector102
vector102:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $102
80106dd6:	6a 66                	push   $0x66
  jmp alltraps
80106dd8:	e9 f6 f5 ff ff       	jmp    801063d3 <alltraps>

80106ddd <vector103>:
.globl vector103
vector103:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $103
80106ddf:	6a 67                	push   $0x67
  jmp alltraps
80106de1:	e9 ed f5 ff ff       	jmp    801063d3 <alltraps>

80106de6 <vector104>:
.globl vector104
vector104:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $104
80106de8:	6a 68                	push   $0x68
  jmp alltraps
80106dea:	e9 e4 f5 ff ff       	jmp    801063d3 <alltraps>

80106def <vector105>:
.globl vector105
vector105:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $105
80106df1:	6a 69                	push   $0x69
  jmp alltraps
80106df3:	e9 db f5 ff ff       	jmp    801063d3 <alltraps>

80106df8 <vector106>:
.globl vector106
vector106:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $106
80106dfa:	6a 6a                	push   $0x6a
  jmp alltraps
80106dfc:	e9 d2 f5 ff ff       	jmp    801063d3 <alltraps>

80106e01 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $107
80106e03:	6a 6b                	push   $0x6b
  jmp alltraps
80106e05:	e9 c9 f5 ff ff       	jmp    801063d3 <alltraps>

80106e0a <vector108>:
.globl vector108
vector108:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $108
80106e0c:	6a 6c                	push   $0x6c
  jmp alltraps
80106e0e:	e9 c0 f5 ff ff       	jmp    801063d3 <alltraps>

80106e13 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $109
80106e15:	6a 6d                	push   $0x6d
  jmp alltraps
80106e17:	e9 b7 f5 ff ff       	jmp    801063d3 <alltraps>

80106e1c <vector110>:
.globl vector110
vector110:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $110
80106e1e:	6a 6e                	push   $0x6e
  jmp alltraps
80106e20:	e9 ae f5 ff ff       	jmp    801063d3 <alltraps>

80106e25 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $111
80106e27:	6a 6f                	push   $0x6f
  jmp alltraps
80106e29:	e9 a5 f5 ff ff       	jmp    801063d3 <alltraps>

80106e2e <vector112>:
.globl vector112
vector112:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $112
80106e30:	6a 70                	push   $0x70
  jmp alltraps
80106e32:	e9 9c f5 ff ff       	jmp    801063d3 <alltraps>

80106e37 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $113
80106e39:	6a 71                	push   $0x71
  jmp alltraps
80106e3b:	e9 93 f5 ff ff       	jmp    801063d3 <alltraps>

80106e40 <vector114>:
.globl vector114
vector114:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $114
80106e42:	6a 72                	push   $0x72
  jmp alltraps
80106e44:	e9 8a f5 ff ff       	jmp    801063d3 <alltraps>

80106e49 <vector115>:
.globl vector115
vector115:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $115
80106e4b:	6a 73                	push   $0x73
  jmp alltraps
80106e4d:	e9 81 f5 ff ff       	jmp    801063d3 <alltraps>

80106e52 <vector116>:
.globl vector116
vector116:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $116
80106e54:	6a 74                	push   $0x74
  jmp alltraps
80106e56:	e9 78 f5 ff ff       	jmp    801063d3 <alltraps>

80106e5b <vector117>:
.globl vector117
vector117:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $117
80106e5d:	6a 75                	push   $0x75
  jmp alltraps
80106e5f:	e9 6f f5 ff ff       	jmp    801063d3 <alltraps>

80106e64 <vector118>:
.globl vector118
vector118:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $118
80106e66:	6a 76                	push   $0x76
  jmp alltraps
80106e68:	e9 66 f5 ff ff       	jmp    801063d3 <alltraps>

80106e6d <vector119>:
.globl vector119
vector119:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $119
80106e6f:	6a 77                	push   $0x77
  jmp alltraps
80106e71:	e9 5d f5 ff ff       	jmp    801063d3 <alltraps>

80106e76 <vector120>:
.globl vector120
vector120:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $120
80106e78:	6a 78                	push   $0x78
  jmp alltraps
80106e7a:	e9 54 f5 ff ff       	jmp    801063d3 <alltraps>

80106e7f <vector121>:
.globl vector121
vector121:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $121
80106e81:	6a 79                	push   $0x79
  jmp alltraps
80106e83:	e9 4b f5 ff ff       	jmp    801063d3 <alltraps>

80106e88 <vector122>:
.globl vector122
vector122:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $122
80106e8a:	6a 7a                	push   $0x7a
  jmp alltraps
80106e8c:	e9 42 f5 ff ff       	jmp    801063d3 <alltraps>

80106e91 <vector123>:
.globl vector123
vector123:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $123
80106e93:	6a 7b                	push   $0x7b
  jmp alltraps
80106e95:	e9 39 f5 ff ff       	jmp    801063d3 <alltraps>

80106e9a <vector124>:
.globl vector124
vector124:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $124
80106e9c:	6a 7c                	push   $0x7c
  jmp alltraps
80106e9e:	e9 30 f5 ff ff       	jmp    801063d3 <alltraps>

80106ea3 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $125
80106ea5:	6a 7d                	push   $0x7d
  jmp alltraps
80106ea7:	e9 27 f5 ff ff       	jmp    801063d3 <alltraps>

80106eac <vector126>:
.globl vector126
vector126:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $126
80106eae:	6a 7e                	push   $0x7e
  jmp alltraps
80106eb0:	e9 1e f5 ff ff       	jmp    801063d3 <alltraps>

80106eb5 <vector127>:
.globl vector127
vector127:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $127
80106eb7:	6a 7f                	push   $0x7f
  jmp alltraps
80106eb9:	e9 15 f5 ff ff       	jmp    801063d3 <alltraps>

80106ebe <vector128>:
.globl vector128
vector128:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $128
80106ec0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ec5:	e9 09 f5 ff ff       	jmp    801063d3 <alltraps>

80106eca <vector129>:
.globl vector129
vector129:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $129
80106ecc:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ed1:	e9 fd f4 ff ff       	jmp    801063d3 <alltraps>

80106ed6 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $130
80106ed8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106edd:	e9 f1 f4 ff ff       	jmp    801063d3 <alltraps>

80106ee2 <vector131>:
.globl vector131
vector131:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $131
80106ee4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ee9:	e9 e5 f4 ff ff       	jmp    801063d3 <alltraps>

80106eee <vector132>:
.globl vector132
vector132:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $132
80106ef0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106ef5:	e9 d9 f4 ff ff       	jmp    801063d3 <alltraps>

80106efa <vector133>:
.globl vector133
vector133:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $133
80106efc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f01:	e9 cd f4 ff ff       	jmp    801063d3 <alltraps>

80106f06 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $134
80106f08:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f0d:	e9 c1 f4 ff ff       	jmp    801063d3 <alltraps>

80106f12 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $135
80106f14:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f19:	e9 b5 f4 ff ff       	jmp    801063d3 <alltraps>

80106f1e <vector136>:
.globl vector136
vector136:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $136
80106f20:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f25:	e9 a9 f4 ff ff       	jmp    801063d3 <alltraps>

80106f2a <vector137>:
.globl vector137
vector137:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $137
80106f2c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f31:	e9 9d f4 ff ff       	jmp    801063d3 <alltraps>

80106f36 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $138
80106f38:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f3d:	e9 91 f4 ff ff       	jmp    801063d3 <alltraps>

80106f42 <vector139>:
.globl vector139
vector139:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $139
80106f44:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f49:	e9 85 f4 ff ff       	jmp    801063d3 <alltraps>

80106f4e <vector140>:
.globl vector140
vector140:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $140
80106f50:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f55:	e9 79 f4 ff ff       	jmp    801063d3 <alltraps>

80106f5a <vector141>:
.globl vector141
vector141:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $141
80106f5c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f61:	e9 6d f4 ff ff       	jmp    801063d3 <alltraps>

80106f66 <vector142>:
.globl vector142
vector142:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $142
80106f68:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f6d:	e9 61 f4 ff ff       	jmp    801063d3 <alltraps>

80106f72 <vector143>:
.globl vector143
vector143:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $143
80106f74:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f79:	e9 55 f4 ff ff       	jmp    801063d3 <alltraps>

80106f7e <vector144>:
.globl vector144
vector144:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $144
80106f80:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f85:	e9 49 f4 ff ff       	jmp    801063d3 <alltraps>

80106f8a <vector145>:
.globl vector145
vector145:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $145
80106f8c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f91:	e9 3d f4 ff ff       	jmp    801063d3 <alltraps>

80106f96 <vector146>:
.globl vector146
vector146:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $146
80106f98:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f9d:	e9 31 f4 ff ff       	jmp    801063d3 <alltraps>

80106fa2 <vector147>:
.globl vector147
vector147:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $147
80106fa4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106fa9:	e9 25 f4 ff ff       	jmp    801063d3 <alltraps>

80106fae <vector148>:
.globl vector148
vector148:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $148
80106fb0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106fb5:	e9 19 f4 ff ff       	jmp    801063d3 <alltraps>

80106fba <vector149>:
.globl vector149
vector149:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $149
80106fbc:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106fc1:	e9 0d f4 ff ff       	jmp    801063d3 <alltraps>

80106fc6 <vector150>:
.globl vector150
vector150:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $150
80106fc8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106fcd:	e9 01 f4 ff ff       	jmp    801063d3 <alltraps>

80106fd2 <vector151>:
.globl vector151
vector151:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $151
80106fd4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106fd9:	e9 f5 f3 ff ff       	jmp    801063d3 <alltraps>

80106fde <vector152>:
.globl vector152
vector152:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $152
80106fe0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106fe5:	e9 e9 f3 ff ff       	jmp    801063d3 <alltraps>

80106fea <vector153>:
.globl vector153
vector153:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $153
80106fec:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ff1:	e9 dd f3 ff ff       	jmp    801063d3 <alltraps>

80106ff6 <vector154>:
.globl vector154
vector154:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $154
80106ff8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ffd:	e9 d1 f3 ff ff       	jmp    801063d3 <alltraps>

80107002 <vector155>:
.globl vector155
vector155:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $155
80107004:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107009:	e9 c5 f3 ff ff       	jmp    801063d3 <alltraps>

8010700e <vector156>:
.globl vector156
vector156:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $156
80107010:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107015:	e9 b9 f3 ff ff       	jmp    801063d3 <alltraps>

8010701a <vector157>:
.globl vector157
vector157:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $157
8010701c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107021:	e9 ad f3 ff ff       	jmp    801063d3 <alltraps>

80107026 <vector158>:
.globl vector158
vector158:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $158
80107028:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010702d:	e9 a1 f3 ff ff       	jmp    801063d3 <alltraps>

80107032 <vector159>:
.globl vector159
vector159:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $159
80107034:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107039:	e9 95 f3 ff ff       	jmp    801063d3 <alltraps>

8010703e <vector160>:
.globl vector160
vector160:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $160
80107040:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107045:	e9 89 f3 ff ff       	jmp    801063d3 <alltraps>

8010704a <vector161>:
.globl vector161
vector161:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $161
8010704c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107051:	e9 7d f3 ff ff       	jmp    801063d3 <alltraps>

80107056 <vector162>:
.globl vector162
vector162:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $162
80107058:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010705d:	e9 71 f3 ff ff       	jmp    801063d3 <alltraps>

80107062 <vector163>:
.globl vector163
vector163:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $163
80107064:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107069:	e9 65 f3 ff ff       	jmp    801063d3 <alltraps>

8010706e <vector164>:
.globl vector164
vector164:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $164
80107070:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107075:	e9 59 f3 ff ff       	jmp    801063d3 <alltraps>

8010707a <vector165>:
.globl vector165
vector165:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $165
8010707c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107081:	e9 4d f3 ff ff       	jmp    801063d3 <alltraps>

80107086 <vector166>:
.globl vector166
vector166:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $166
80107088:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010708d:	e9 41 f3 ff ff       	jmp    801063d3 <alltraps>

80107092 <vector167>:
.globl vector167
vector167:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $167
80107094:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107099:	e9 35 f3 ff ff       	jmp    801063d3 <alltraps>

8010709e <vector168>:
.globl vector168
vector168:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $168
801070a0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070a5:	e9 29 f3 ff ff       	jmp    801063d3 <alltraps>

801070aa <vector169>:
.globl vector169
vector169:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $169
801070ac:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801070b1:	e9 1d f3 ff ff       	jmp    801063d3 <alltraps>

801070b6 <vector170>:
.globl vector170
vector170:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $170
801070b8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801070bd:	e9 11 f3 ff ff       	jmp    801063d3 <alltraps>

801070c2 <vector171>:
.globl vector171
vector171:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $171
801070c4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801070c9:	e9 05 f3 ff ff       	jmp    801063d3 <alltraps>

801070ce <vector172>:
.globl vector172
vector172:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $172
801070d0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801070d5:	e9 f9 f2 ff ff       	jmp    801063d3 <alltraps>

801070da <vector173>:
.globl vector173
vector173:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $173
801070dc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801070e1:	e9 ed f2 ff ff       	jmp    801063d3 <alltraps>

801070e6 <vector174>:
.globl vector174
vector174:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $174
801070e8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801070ed:	e9 e1 f2 ff ff       	jmp    801063d3 <alltraps>

801070f2 <vector175>:
.globl vector175
vector175:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $175
801070f4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801070f9:	e9 d5 f2 ff ff       	jmp    801063d3 <alltraps>

801070fe <vector176>:
.globl vector176
vector176:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $176
80107100:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107105:	e9 c9 f2 ff ff       	jmp    801063d3 <alltraps>

8010710a <vector177>:
.globl vector177
vector177:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $177
8010710c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107111:	e9 bd f2 ff ff       	jmp    801063d3 <alltraps>

80107116 <vector178>:
.globl vector178
vector178:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $178
80107118:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010711d:	e9 b1 f2 ff ff       	jmp    801063d3 <alltraps>

80107122 <vector179>:
.globl vector179
vector179:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $179
80107124:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107129:	e9 a5 f2 ff ff       	jmp    801063d3 <alltraps>

8010712e <vector180>:
.globl vector180
vector180:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $180
80107130:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107135:	e9 99 f2 ff ff       	jmp    801063d3 <alltraps>

8010713a <vector181>:
.globl vector181
vector181:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $181
8010713c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107141:	e9 8d f2 ff ff       	jmp    801063d3 <alltraps>

80107146 <vector182>:
.globl vector182
vector182:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $182
80107148:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010714d:	e9 81 f2 ff ff       	jmp    801063d3 <alltraps>

80107152 <vector183>:
.globl vector183
vector183:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $183
80107154:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107159:	e9 75 f2 ff ff       	jmp    801063d3 <alltraps>

8010715e <vector184>:
.globl vector184
vector184:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $184
80107160:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107165:	e9 69 f2 ff ff       	jmp    801063d3 <alltraps>

8010716a <vector185>:
.globl vector185
vector185:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $185
8010716c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107171:	e9 5d f2 ff ff       	jmp    801063d3 <alltraps>

80107176 <vector186>:
.globl vector186
vector186:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $186
80107178:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010717d:	e9 51 f2 ff ff       	jmp    801063d3 <alltraps>

80107182 <vector187>:
.globl vector187
vector187:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $187
80107184:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107189:	e9 45 f2 ff ff       	jmp    801063d3 <alltraps>

8010718e <vector188>:
.globl vector188
vector188:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $188
80107190:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107195:	e9 39 f2 ff ff       	jmp    801063d3 <alltraps>

8010719a <vector189>:
.globl vector189
vector189:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $189
8010719c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071a1:	e9 2d f2 ff ff       	jmp    801063d3 <alltraps>

801071a6 <vector190>:
.globl vector190
vector190:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $190
801071a8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801071ad:	e9 21 f2 ff ff       	jmp    801063d3 <alltraps>

801071b2 <vector191>:
.globl vector191
vector191:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $191
801071b4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801071b9:	e9 15 f2 ff ff       	jmp    801063d3 <alltraps>

801071be <vector192>:
.globl vector192
vector192:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $192
801071c0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801071c5:	e9 09 f2 ff ff       	jmp    801063d3 <alltraps>

801071ca <vector193>:
.globl vector193
vector193:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $193
801071cc:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801071d1:	e9 fd f1 ff ff       	jmp    801063d3 <alltraps>

801071d6 <vector194>:
.globl vector194
vector194:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $194
801071d8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801071dd:	e9 f1 f1 ff ff       	jmp    801063d3 <alltraps>

801071e2 <vector195>:
.globl vector195
vector195:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $195
801071e4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801071e9:	e9 e5 f1 ff ff       	jmp    801063d3 <alltraps>

801071ee <vector196>:
.globl vector196
vector196:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $196
801071f0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801071f5:	e9 d9 f1 ff ff       	jmp    801063d3 <alltraps>

801071fa <vector197>:
.globl vector197
vector197:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $197
801071fc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107201:	e9 cd f1 ff ff       	jmp    801063d3 <alltraps>

80107206 <vector198>:
.globl vector198
vector198:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $198
80107208:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010720d:	e9 c1 f1 ff ff       	jmp    801063d3 <alltraps>

80107212 <vector199>:
.globl vector199
vector199:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $199
80107214:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107219:	e9 b5 f1 ff ff       	jmp    801063d3 <alltraps>

8010721e <vector200>:
.globl vector200
vector200:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $200
80107220:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107225:	e9 a9 f1 ff ff       	jmp    801063d3 <alltraps>

8010722a <vector201>:
.globl vector201
vector201:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $201
8010722c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107231:	e9 9d f1 ff ff       	jmp    801063d3 <alltraps>

80107236 <vector202>:
.globl vector202
vector202:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $202
80107238:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010723d:	e9 91 f1 ff ff       	jmp    801063d3 <alltraps>

80107242 <vector203>:
.globl vector203
vector203:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $203
80107244:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107249:	e9 85 f1 ff ff       	jmp    801063d3 <alltraps>

8010724e <vector204>:
.globl vector204
vector204:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $204
80107250:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107255:	e9 79 f1 ff ff       	jmp    801063d3 <alltraps>

8010725a <vector205>:
.globl vector205
vector205:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $205
8010725c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107261:	e9 6d f1 ff ff       	jmp    801063d3 <alltraps>

80107266 <vector206>:
.globl vector206
vector206:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $206
80107268:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010726d:	e9 61 f1 ff ff       	jmp    801063d3 <alltraps>

80107272 <vector207>:
.globl vector207
vector207:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $207
80107274:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107279:	e9 55 f1 ff ff       	jmp    801063d3 <alltraps>

8010727e <vector208>:
.globl vector208
vector208:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $208
80107280:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107285:	e9 49 f1 ff ff       	jmp    801063d3 <alltraps>

8010728a <vector209>:
.globl vector209
vector209:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $209
8010728c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107291:	e9 3d f1 ff ff       	jmp    801063d3 <alltraps>

80107296 <vector210>:
.globl vector210
vector210:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $210
80107298:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010729d:	e9 31 f1 ff ff       	jmp    801063d3 <alltraps>

801072a2 <vector211>:
.globl vector211
vector211:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $211
801072a4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801072a9:	e9 25 f1 ff ff       	jmp    801063d3 <alltraps>

801072ae <vector212>:
.globl vector212
vector212:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $212
801072b0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801072b5:	e9 19 f1 ff ff       	jmp    801063d3 <alltraps>

801072ba <vector213>:
.globl vector213
vector213:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $213
801072bc:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801072c1:	e9 0d f1 ff ff       	jmp    801063d3 <alltraps>

801072c6 <vector214>:
.globl vector214
vector214:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $214
801072c8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801072cd:	e9 01 f1 ff ff       	jmp    801063d3 <alltraps>

801072d2 <vector215>:
.globl vector215
vector215:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $215
801072d4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801072d9:	e9 f5 f0 ff ff       	jmp    801063d3 <alltraps>

801072de <vector216>:
.globl vector216
vector216:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $216
801072e0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801072e5:	e9 e9 f0 ff ff       	jmp    801063d3 <alltraps>

801072ea <vector217>:
.globl vector217
vector217:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $217
801072ec:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801072f1:	e9 dd f0 ff ff       	jmp    801063d3 <alltraps>

801072f6 <vector218>:
.globl vector218
vector218:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $218
801072f8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801072fd:	e9 d1 f0 ff ff       	jmp    801063d3 <alltraps>

80107302 <vector219>:
.globl vector219
vector219:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $219
80107304:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107309:	e9 c5 f0 ff ff       	jmp    801063d3 <alltraps>

8010730e <vector220>:
.globl vector220
vector220:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $220
80107310:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107315:	e9 b9 f0 ff ff       	jmp    801063d3 <alltraps>

8010731a <vector221>:
.globl vector221
vector221:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $221
8010731c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107321:	e9 ad f0 ff ff       	jmp    801063d3 <alltraps>

80107326 <vector222>:
.globl vector222
vector222:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $222
80107328:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010732d:	e9 a1 f0 ff ff       	jmp    801063d3 <alltraps>

80107332 <vector223>:
.globl vector223
vector223:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $223
80107334:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107339:	e9 95 f0 ff ff       	jmp    801063d3 <alltraps>

8010733e <vector224>:
.globl vector224
vector224:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $224
80107340:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107345:	e9 89 f0 ff ff       	jmp    801063d3 <alltraps>

8010734a <vector225>:
.globl vector225
vector225:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $225
8010734c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107351:	e9 7d f0 ff ff       	jmp    801063d3 <alltraps>

80107356 <vector226>:
.globl vector226
vector226:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $226
80107358:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010735d:	e9 71 f0 ff ff       	jmp    801063d3 <alltraps>

80107362 <vector227>:
.globl vector227
vector227:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $227
80107364:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107369:	e9 65 f0 ff ff       	jmp    801063d3 <alltraps>

8010736e <vector228>:
.globl vector228
vector228:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $228
80107370:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107375:	e9 59 f0 ff ff       	jmp    801063d3 <alltraps>

8010737a <vector229>:
.globl vector229
vector229:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $229
8010737c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107381:	e9 4d f0 ff ff       	jmp    801063d3 <alltraps>

80107386 <vector230>:
.globl vector230
vector230:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $230
80107388:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010738d:	e9 41 f0 ff ff       	jmp    801063d3 <alltraps>

80107392 <vector231>:
.globl vector231
vector231:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $231
80107394:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107399:	e9 35 f0 ff ff       	jmp    801063d3 <alltraps>

8010739e <vector232>:
.globl vector232
vector232:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $232
801073a0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073a5:	e9 29 f0 ff ff       	jmp    801063d3 <alltraps>

801073aa <vector233>:
.globl vector233
vector233:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $233
801073ac:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801073b1:	e9 1d f0 ff ff       	jmp    801063d3 <alltraps>

801073b6 <vector234>:
.globl vector234
vector234:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $234
801073b8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801073bd:	e9 11 f0 ff ff       	jmp    801063d3 <alltraps>

801073c2 <vector235>:
.globl vector235
vector235:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $235
801073c4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801073c9:	e9 05 f0 ff ff       	jmp    801063d3 <alltraps>

801073ce <vector236>:
.globl vector236
vector236:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $236
801073d0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801073d5:	e9 f9 ef ff ff       	jmp    801063d3 <alltraps>

801073da <vector237>:
.globl vector237
vector237:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $237
801073dc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801073e1:	e9 ed ef ff ff       	jmp    801063d3 <alltraps>

801073e6 <vector238>:
.globl vector238
vector238:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $238
801073e8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801073ed:	e9 e1 ef ff ff       	jmp    801063d3 <alltraps>

801073f2 <vector239>:
.globl vector239
vector239:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $239
801073f4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801073f9:	e9 d5 ef ff ff       	jmp    801063d3 <alltraps>

801073fe <vector240>:
.globl vector240
vector240:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $240
80107400:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107405:	e9 c9 ef ff ff       	jmp    801063d3 <alltraps>

8010740a <vector241>:
.globl vector241
vector241:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $241
8010740c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107411:	e9 bd ef ff ff       	jmp    801063d3 <alltraps>

80107416 <vector242>:
.globl vector242
vector242:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $242
80107418:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010741d:	e9 b1 ef ff ff       	jmp    801063d3 <alltraps>

80107422 <vector243>:
.globl vector243
vector243:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $243
80107424:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107429:	e9 a5 ef ff ff       	jmp    801063d3 <alltraps>

8010742e <vector244>:
.globl vector244
vector244:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $244
80107430:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107435:	e9 99 ef ff ff       	jmp    801063d3 <alltraps>

8010743a <vector245>:
.globl vector245
vector245:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $245
8010743c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107441:	e9 8d ef ff ff       	jmp    801063d3 <alltraps>

80107446 <vector246>:
.globl vector246
vector246:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $246
80107448:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010744d:	e9 81 ef ff ff       	jmp    801063d3 <alltraps>

80107452 <vector247>:
.globl vector247
vector247:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $247
80107454:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107459:	e9 75 ef ff ff       	jmp    801063d3 <alltraps>

8010745e <vector248>:
.globl vector248
vector248:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $248
80107460:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107465:	e9 69 ef ff ff       	jmp    801063d3 <alltraps>

8010746a <vector249>:
.globl vector249
vector249:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $249
8010746c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107471:	e9 5d ef ff ff       	jmp    801063d3 <alltraps>

80107476 <vector250>:
.globl vector250
vector250:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $250
80107478:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010747d:	e9 51 ef ff ff       	jmp    801063d3 <alltraps>

80107482 <vector251>:
.globl vector251
vector251:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $251
80107484:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107489:	e9 45 ef ff ff       	jmp    801063d3 <alltraps>

8010748e <vector252>:
.globl vector252
vector252:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $252
80107490:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107495:	e9 39 ef ff ff       	jmp    801063d3 <alltraps>

8010749a <vector253>:
.globl vector253
vector253:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $253
8010749c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074a1:	e9 2d ef ff ff       	jmp    801063d3 <alltraps>

801074a6 <vector254>:
.globl vector254
vector254:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $254
801074a8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801074ad:	e9 21 ef ff ff       	jmp    801063d3 <alltraps>

801074b2 <vector255>:
.globl vector255
vector255:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $255
801074b4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801074b9:	e9 15 ef ff ff       	jmp    801063d3 <alltraps>

801074be <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801074be:	55                   	push   %ebp
801074bf:	89 e5                	mov    %esp,%ebp
801074c1:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801074c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801074c7:	83 e8 01             	sub    $0x1,%eax
801074ca:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074ce:	8b 45 08             	mov    0x8(%ebp),%eax
801074d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074d5:	8b 45 08             	mov    0x8(%ebp),%eax
801074d8:	c1 e8 10             	shr    $0x10,%eax
801074db:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801074df:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074e2:	0f 01 10             	lgdtl  (%eax)
}
801074e5:	c9                   	leave  
801074e6:	c3                   	ret    

801074e7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801074e7:	55                   	push   %ebp
801074e8:	89 e5                	mov    %esp,%ebp
801074ea:	83 ec 04             	sub    $0x4,%esp
801074ed:	8b 45 08             	mov    0x8(%ebp),%eax
801074f0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801074f4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801074f8:	0f 00 d8             	ltr    %ax
}
801074fb:	c9                   	leave  
801074fc:	c3                   	ret    

801074fd <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801074fd:	55                   	push   %ebp
801074fe:	89 e5                	mov    %esp,%ebp
80107500:	83 ec 04             	sub    $0x4,%esp
80107503:	8b 45 08             	mov    0x8(%ebp),%eax
80107506:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010750a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010750e:	8e e8                	mov    %eax,%gs
}
80107510:	c9                   	leave  
80107511:	c3                   	ret    

80107512 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107512:	55                   	push   %ebp
80107513:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107515:	8b 45 08             	mov    0x8(%ebp),%eax
80107518:	0f 22 d8             	mov    %eax,%cr3
}
8010751b:	5d                   	pop    %ebp
8010751c:	c3                   	ret    

8010751d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010751d:	55                   	push   %ebp
8010751e:	89 e5                	mov    %esp,%ebp
80107520:	8b 45 08             	mov    0x8(%ebp),%eax
80107523:	05 00 00 00 80       	add    $0x80000000,%eax
80107528:	5d                   	pop    %ebp
80107529:	c3                   	ret    

8010752a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010752a:	55                   	push   %ebp
8010752b:	89 e5                	mov    %esp,%ebp
8010752d:	8b 45 08             	mov    0x8(%ebp),%eax
80107530:	05 00 00 00 80       	add    $0x80000000,%eax
80107535:	5d                   	pop    %ebp
80107536:	c3                   	ret    

80107537 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107537:	55                   	push   %ebp
80107538:	89 e5                	mov    %esp,%ebp
8010753a:	53                   	push   %ebx
8010753b:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010753e:	e8 51 bb ff ff       	call   80103094 <cpunum>
80107543:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107549:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
8010754e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107554:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010755a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107566:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010756a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107571:	83 e2 f0             	and    $0xfffffff0,%edx
80107574:	83 ca 0a             	or     $0xa,%edx
80107577:	88 50 7d             	mov    %dl,0x7d(%eax)
8010757a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107581:	83 ca 10             	or     $0x10,%edx
80107584:	88 50 7d             	mov    %dl,0x7d(%eax)
80107587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010758e:	83 e2 9f             	and    $0xffffff9f,%edx
80107591:	88 50 7d             	mov    %dl,0x7d(%eax)
80107594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107597:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010759b:	83 ca 80             	or     $0xffffff80,%edx
8010759e:	88 50 7d             	mov    %dl,0x7d(%eax)
801075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075a8:	83 ca 0f             	or     $0xf,%edx
801075ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801075ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075b5:	83 e2 ef             	and    $0xffffffef,%edx
801075b8:	88 50 7e             	mov    %dl,0x7e(%eax)
801075bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075be:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075c2:	83 e2 df             	and    $0xffffffdf,%edx
801075c5:	88 50 7e             	mov    %dl,0x7e(%eax)
801075c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075cf:	83 ca 40             	or     $0x40,%edx
801075d2:	88 50 7e             	mov    %dl,0x7e(%eax)
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075dc:	83 ca 80             	or     $0xffffff80,%edx
801075df:	88 50 7e             	mov    %dl,0x7e(%eax)
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801075e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ec:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801075f3:	ff ff 
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801075ff:	00 00 
80107601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107604:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107615:	83 e2 f0             	and    $0xfffffff0,%edx
80107618:	83 ca 02             	or     $0x2,%edx
8010761b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107624:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010762b:	83 ca 10             	or     $0x10,%edx
8010762e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107637:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010763e:	83 e2 9f             	and    $0xffffff9f,%edx
80107641:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107651:	83 ca 80             	or     $0xffffff80,%edx
80107654:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010765a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107664:	83 ca 0f             	or     $0xf,%edx
80107667:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010766d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107670:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107677:	83 e2 ef             	and    $0xffffffef,%edx
8010767a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107683:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010768a:	83 e2 df             	and    $0xffffffdf,%edx
8010768d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107696:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010769d:	83 ca 40             	or     $0x40,%edx
801076a0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076b0:	83 ca 80             	or     $0xffffff80,%edx
801076b3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bc:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801076cd:	ff ff 
801076cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d2:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801076d9:	00 00 
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801076e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076ef:	83 e2 f0             	and    $0xfffffff0,%edx
801076f2:	83 ca 0a             	or     $0xa,%edx
801076f5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107705:	83 ca 10             	or     $0x10,%edx
80107708:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010770e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107711:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107718:	83 ca 60             	or     $0x60,%edx
8010771b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107724:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010772b:	83 ca 80             	or     $0xffffff80,%edx
8010772e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107737:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010773e:	83 ca 0f             	or     $0xf,%edx
80107741:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107751:	83 e2 ef             	and    $0xffffffef,%edx
80107754:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010775a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107764:	83 e2 df             	and    $0xffffffdf,%edx
80107767:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107770:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107777:	83 ca 40             	or     $0x40,%edx
8010777a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107783:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010778a:	83 ca 80             	or     $0xffffff80,%edx
8010778d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801077a7:	ff ff 
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801077b3:	00 00 
801077b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b8:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801077bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801077c9:	83 e2 f0             	and    $0xfffffff0,%edx
801077cc:	83 ca 02             	or     $0x2,%edx
801077cf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801077d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801077df:	83 ca 10             	or     $0x10,%edx
801077e2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801077f2:	83 ca 60             	or     $0x60,%edx
801077f5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801077fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fe:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107805:	83 ca 80             	or     $0xffffff80,%edx
80107808:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010780e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107811:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107818:	83 ca 0f             	or     $0xf,%edx
8010781b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107824:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010782b:	83 e2 ef             	and    $0xffffffef,%edx
8010782e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107837:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010783e:	83 e2 df             	and    $0xffffffdf,%edx
80107841:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107851:	83 ca 40             	or     $0x40,%edx
80107854:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107864:	83 ca 80             	or     $0xffffff80,%edx
80107867:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010786d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107870:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	05 b4 00 00 00       	add    $0xb4,%eax
8010787f:	89 c3                	mov    %eax,%ebx
80107881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107884:	05 b4 00 00 00       	add    $0xb4,%eax
80107889:	c1 e8 10             	shr    $0x10,%eax
8010788c:	89 c1                	mov    %eax,%ecx
8010788e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107891:	05 b4 00 00 00       	add    $0xb4,%eax
80107896:	c1 e8 18             	shr    $0x18,%eax
80107899:	89 c2                	mov    %eax,%edx
8010789b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789e:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801078a5:	00 00 
801078a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078aa:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801078b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b4:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801078ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801078c4:	83 e1 f0             	and    $0xfffffff0,%ecx
801078c7:	83 c9 02             	or     $0x2,%ecx
801078ca:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801078da:	83 c9 10             	or     $0x10,%ecx
801078dd:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801078ed:	83 e1 9f             	and    $0xffffff9f,%ecx
801078f0:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801078f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f9:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107900:	83 c9 80             	or     $0xffffff80,%ecx
80107903:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107913:	83 e1 f0             	and    $0xfffffff0,%ecx
80107916:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010791c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107926:	83 e1 ef             	and    $0xffffffef,%ecx
80107929:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010792f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107932:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107939:	83 e1 df             	and    $0xffffffdf,%ecx
8010793c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107945:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010794c:	83 c9 40             	or     $0x40,%ecx
8010794f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107958:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010795f:	83 c9 80             	or     $0xffffff80,%ecx
80107962:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796b:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	83 c0 70             	add    $0x70,%eax
80107977:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
8010797e:	00 
8010797f:	89 04 24             	mov    %eax,(%esp)
80107982:	e8 37 fb ff ff       	call   801074be <lgdt>
  loadgs(SEG_KCPU << 3);
80107987:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
8010798e:	e8 6a fb ff ff       	call   801074fd <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107996:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010799c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801079a3:	00 00 00 00 
}
801079a7:	83 c4 24             	add    $0x24,%esp
801079aa:	5b                   	pop    %ebx
801079ab:	5d                   	pop    %ebp
801079ac:	c3                   	ret    

801079ad <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801079ad:	55                   	push   %ebp
801079ae:	89 e5                	mov    %esp,%ebp
801079b0:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801079b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801079b6:	c1 e8 16             	shr    $0x16,%eax
801079b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079c0:	8b 45 08             	mov    0x8(%ebp),%eax
801079c3:	01 d0                	add    %edx,%eax
801079c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801079c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079cb:	8b 00                	mov    (%eax),%eax
801079cd:	83 e0 01             	and    $0x1,%eax
801079d0:	85 c0                	test   %eax,%eax
801079d2:	74 17                	je     801079eb <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801079d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079d7:	8b 00                	mov    (%eax),%eax
801079d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079de:	89 04 24             	mov    %eax,(%esp)
801079e1:	e8 44 fb ff ff       	call   8010752a <p2v>
801079e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079e9:	eb 4b                	jmp    80107a36 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801079eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801079ef:	74 0e                	je     801079ff <walkpgdir+0x52>
801079f1:	e8 25 b3 ff ff       	call   80102d1b <kalloc>
801079f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079fd:	75 07                	jne    80107a06 <walkpgdir+0x59>
      return 0;
801079ff:	b8 00 00 00 00       	mov    $0x0,%eax
80107a04:	eb 47                	jmp    80107a4d <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107a06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107a0d:	00 
80107a0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a15:	00 
80107a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a19:	89 04 24             	mov    %eax,(%esp)
80107a1c:	e8 9c d5 ff ff       	call   80104fbd <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a24:	89 04 24             	mov    %eax,(%esp)
80107a27:	e8 f1 fa ff ff       	call   8010751d <v2p>
80107a2c:	83 c8 07             	or     $0x7,%eax
80107a2f:	89 c2                	mov    %eax,%edx
80107a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a34:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107a36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a39:	c1 e8 0c             	shr    $0xc,%eax
80107a3c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107a41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4b:	01 d0                	add    %edx,%eax
}
80107a4d:	c9                   	leave  
80107a4e:	c3                   	ret    

80107a4f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107a4f:	55                   	push   %ebp
80107a50:	89 e5                	mov    %esp,%ebp
80107a52:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107a55:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107a60:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a63:	8b 45 10             	mov    0x10(%ebp),%eax
80107a66:	01 d0                	add    %edx,%eax
80107a68:	83 e8 01             	sub    $0x1,%eax
80107a6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a73:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107a7a:	00 
80107a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a82:	8b 45 08             	mov    0x8(%ebp),%eax
80107a85:	89 04 24             	mov    %eax,(%esp)
80107a88:	e8 20 ff ff ff       	call   801079ad <walkpgdir>
80107a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a94:	75 07                	jne    80107a9d <mappages+0x4e>
      return -1;
80107a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a9b:	eb 48                	jmp    80107ae5 <mappages+0x96>
    if(*pte & PTE_P)
80107a9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aa0:	8b 00                	mov    (%eax),%eax
80107aa2:	83 e0 01             	and    $0x1,%eax
80107aa5:	85 c0                	test   %eax,%eax
80107aa7:	74 0c                	je     80107ab5 <mappages+0x66>
      panic("remap");
80107aa9:	c7 04 24 d0 88 10 80 	movl   $0x801088d0,(%esp)
80107ab0:	e8 85 8a ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107ab5:	8b 45 18             	mov    0x18(%ebp),%eax
80107ab8:	0b 45 14             	or     0x14(%ebp),%eax
80107abb:	83 c8 01             	or     $0x1,%eax
80107abe:	89 c2                	mov    %eax,%edx
80107ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ac3:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107acb:	75 08                	jne    80107ad5 <mappages+0x86>
      break;
80107acd:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107ace:	b8 00 00 00 00       	mov    $0x0,%eax
80107ad3:	eb 10                	jmp    80107ae5 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107ad5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107adc:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ae3:	eb 8e                	jmp    80107a73 <mappages+0x24>
  return 0;
}
80107ae5:	c9                   	leave  
80107ae6:	c3                   	ret    

80107ae7 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107ae7:	55                   	push   %ebp
80107ae8:	89 e5                	mov    %esp,%ebp
80107aea:	53                   	push   %ebx
80107aeb:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107aee:	e8 28 b2 ff ff       	call   80102d1b <kalloc>
80107af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107afa:	75 0a                	jne    80107b06 <setupkvm+0x1f>
    return 0;
80107afc:	b8 00 00 00 00       	mov    $0x0,%eax
80107b01:	e9 98 00 00 00       	jmp    80107b9e <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107b06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b0d:	00 
80107b0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b15:	00 
80107b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b19:	89 04 24             	mov    %eax,(%esp)
80107b1c:	e8 9c d4 ff ff       	call   80104fbd <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107b21:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107b28:	e8 fd f9 ff ff       	call   8010752a <p2v>
80107b2d:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107b32:	76 0c                	jbe    80107b40 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107b34:	c7 04 24 d6 88 10 80 	movl   $0x801088d6,(%esp)
80107b3b:	e8 fa 89 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b40:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107b47:	eb 49                	jmp    80107b92 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	8b 48 0c             	mov    0xc(%eax),%ecx
80107b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b52:	8b 50 04             	mov    0x4(%eax),%edx
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	8b 58 08             	mov    0x8(%eax),%ebx
80107b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5e:	8b 40 04             	mov    0x4(%eax),%eax
80107b61:	29 c3                	sub    %eax,%ebx
80107b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b66:	8b 00                	mov    (%eax),%eax
80107b68:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107b6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107b70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107b74:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7b:	89 04 24             	mov    %eax,(%esp)
80107b7e:	e8 cc fe ff ff       	call   80107a4f <mappages>
80107b83:	85 c0                	test   %eax,%eax
80107b85:	79 07                	jns    80107b8e <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107b87:	b8 00 00 00 00       	mov    $0x0,%eax
80107b8c:	eb 10                	jmp    80107b9e <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b8e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b92:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107b99:	72 ae                	jb     80107b49 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b9e:	83 c4 34             	add    $0x34,%esp
80107ba1:	5b                   	pop    %ebx
80107ba2:	5d                   	pop    %ebp
80107ba3:	c3                   	ret    

80107ba4 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107ba4:	55                   	push   %ebp
80107ba5:	89 e5                	mov    %esp,%ebp
80107ba7:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107baa:	e8 38 ff ff ff       	call   80107ae7 <setupkvm>
80107baf:	a3 b8 27 11 80       	mov    %eax,0x801127b8
  switchkvm();
80107bb4:	e8 02 00 00 00       	call   80107bbb <switchkvm>
}
80107bb9:	c9                   	leave  
80107bba:	c3                   	ret    

80107bbb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107bbb:	55                   	push   %ebp
80107bbc:	89 e5                	mov    %esp,%ebp
80107bbe:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107bc1:	a1 b8 27 11 80       	mov    0x801127b8,%eax
80107bc6:	89 04 24             	mov    %eax,(%esp)
80107bc9:	e8 4f f9 ff ff       	call   8010751d <v2p>
80107bce:	89 04 24             	mov    %eax,(%esp)
80107bd1:	e8 3c f9 ff ff       	call   80107512 <lcr3>
}
80107bd6:	c9                   	leave  
80107bd7:	c3                   	ret    

80107bd8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107bd8:	55                   	push   %ebp
80107bd9:	89 e5                	mov    %esp,%ebp
80107bdb:	53                   	push   %ebx
80107bdc:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107bdf:	e8 d9 d2 ff ff       	call   80104ebd <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107be4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107bea:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107bf1:	83 c2 08             	add    $0x8,%edx
80107bf4:	89 d3                	mov    %edx,%ebx
80107bf6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107bfd:	83 c2 08             	add    $0x8,%edx
80107c00:	c1 ea 10             	shr    $0x10,%edx
80107c03:	89 d1                	mov    %edx,%ecx
80107c05:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c0c:	83 c2 08             	add    $0x8,%edx
80107c0f:	c1 ea 18             	shr    $0x18,%edx
80107c12:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107c19:	67 00 
80107c1b:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107c22:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107c28:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107c2f:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c32:	83 c9 09             	or     $0x9,%ecx
80107c35:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107c3b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107c42:	83 c9 10             	or     $0x10,%ecx
80107c45:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107c4b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107c52:	83 e1 9f             	and    $0xffffff9f,%ecx
80107c55:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107c5b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107c62:	83 c9 80             	or     $0xffffff80,%ecx
80107c65:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107c6b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107c72:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c75:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107c7b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107c82:	83 e1 ef             	and    $0xffffffef,%ecx
80107c85:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107c8b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107c92:	83 e1 df             	and    $0xffffffdf,%ecx
80107c95:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107c9b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107ca2:	83 c9 40             	or     $0x40,%ecx
80107ca5:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107cab:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107cb2:	83 e1 7f             	and    $0x7f,%ecx
80107cb5:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107cbb:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107cc1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107cc7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107cce:	83 e2 ef             	and    $0xffffffef,%edx
80107cd1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107cd7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107cdd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107ce3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ce9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107cf0:	8b 52 08             	mov    0x8(%edx),%edx
80107cf3:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107cf9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107cfc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107d03:	e8 df f7 ff ff       	call   801074e7 <ltr>
  if(p->pgdir == 0)
80107d08:	8b 45 08             	mov    0x8(%ebp),%eax
80107d0b:	8b 40 04             	mov    0x4(%eax),%eax
80107d0e:	85 c0                	test   %eax,%eax
80107d10:	75 0c                	jne    80107d1e <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107d12:	c7 04 24 e7 88 10 80 	movl   $0x801088e7,(%esp)
80107d19:	e8 1c 88 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d21:	8b 40 04             	mov    0x4(%eax),%eax
80107d24:	89 04 24             	mov    %eax,(%esp)
80107d27:	e8 f1 f7 ff ff       	call   8010751d <v2p>
80107d2c:	89 04 24             	mov    %eax,(%esp)
80107d2f:	e8 de f7 ff ff       	call   80107512 <lcr3>
  popcli();
80107d34:	e8 c8 d1 ff ff       	call   80104f01 <popcli>
}
80107d39:	83 c4 14             	add    $0x14,%esp
80107d3c:	5b                   	pop    %ebx
80107d3d:	5d                   	pop    %ebp
80107d3e:	c3                   	ret    

80107d3f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107d3f:	55                   	push   %ebp
80107d40:	89 e5                	mov    %esp,%ebp
80107d42:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107d45:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d4c:	76 0c                	jbe    80107d5a <inituvm+0x1b>
    panic("inituvm: more than a page");
80107d4e:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
80107d55:	e8 e0 87 ff ff       	call   8010053a <panic>
  mem = kalloc();
80107d5a:	e8 bc af ff ff       	call   80102d1b <kalloc>
80107d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107d62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d69:	00 
80107d6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d71:	00 
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	89 04 24             	mov    %eax,(%esp)
80107d78:	e8 40 d2 ff ff       	call   80104fbd <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	89 04 24             	mov    %eax,(%esp)
80107d83:	e8 95 f7 ff ff       	call   8010751d <v2p>
80107d88:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107d8f:	00 
80107d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107d94:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d9b:	00 
80107d9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107da3:	00 
80107da4:	8b 45 08             	mov    0x8(%ebp),%eax
80107da7:	89 04 24             	mov    %eax,(%esp)
80107daa:	e8 a0 fc ff ff       	call   80107a4f <mappages>
  memmove(mem, init, sz);
80107daf:	8b 45 10             	mov    0x10(%ebp),%eax
80107db2:	89 44 24 08          	mov    %eax,0x8(%esp)
80107db6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107db9:	89 44 24 04          	mov    %eax,0x4(%esp)
80107dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc0:	89 04 24             	mov    %eax,(%esp)
80107dc3:	e8 c4 d2 ff ff       	call   8010508c <memmove>
}
80107dc8:	c9                   	leave  
80107dc9:	c3                   	ret    

80107dca <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107dca:	55                   	push   %ebp
80107dcb:	89 e5                	mov    %esp,%ebp
80107dcd:	53                   	push   %ebx
80107dce:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dd4:	25 ff 0f 00 00       	and    $0xfff,%eax
80107dd9:	85 c0                	test   %eax,%eax
80107ddb:	74 0c                	je     80107de9 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107ddd:	c7 04 24 18 89 10 80 	movl   $0x80108918,(%esp)
80107de4:	e8 51 87 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107de9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107df0:	e9 a9 00 00 00       	jmp    80107e9e <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107dfb:	01 d0                	add    %edx,%eax
80107dfd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e04:	00 
80107e05:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e09:	8b 45 08             	mov    0x8(%ebp),%eax
80107e0c:	89 04 24             	mov    %eax,(%esp)
80107e0f:	e8 99 fb ff ff       	call   801079ad <walkpgdir>
80107e14:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e1b:	75 0c                	jne    80107e29 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107e1d:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
80107e24:	e8 11 87 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80107e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e2c:	8b 00                	mov    (%eax),%eax
80107e2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e39:	8b 55 18             	mov    0x18(%ebp),%edx
80107e3c:	29 c2                	sub    %eax,%edx
80107e3e:	89 d0                	mov    %edx,%eax
80107e40:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107e45:	77 0f                	ja     80107e56 <loaduvm+0x8c>
      n = sz - i;
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	8b 55 18             	mov    0x18(%ebp),%edx
80107e4d:	29 c2                	sub    %eax,%edx
80107e4f:	89 d0                	mov    %edx,%eax
80107e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e54:	eb 07                	jmp    80107e5d <loaduvm+0x93>
    else
      n = PGSIZE;
80107e56:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e60:	8b 55 14             	mov    0x14(%ebp),%edx
80107e63:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107e66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e69:	89 04 24             	mov    %eax,(%esp)
80107e6c:	e8 b9 f6 ff ff       	call   8010752a <p2v>
80107e71:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107e74:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e80:	8b 45 10             	mov    0x10(%ebp),%eax
80107e83:	89 04 24             	mov    %eax,(%esp)
80107e86:	e8 16 a1 ff ff       	call   80101fa1 <readi>
80107e8b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e8e:	74 07                	je     80107e97 <loaduvm+0xcd>
      return -1;
80107e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e95:	eb 18                	jmp    80107eaf <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107e97:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea1:	3b 45 18             	cmp    0x18(%ebp),%eax
80107ea4:	0f 82 4b ff ff ff    	jb     80107df5 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107eaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107eaf:	83 c4 24             	add    $0x24,%esp
80107eb2:	5b                   	pop    %ebx
80107eb3:	5d                   	pop    %ebp
80107eb4:	c3                   	ret    

80107eb5 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107eb5:	55                   	push   %ebp
80107eb6:	89 e5                	mov    %esp,%ebp
80107eb8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107ebb:	8b 45 10             	mov    0x10(%ebp),%eax
80107ebe:	85 c0                	test   %eax,%eax
80107ec0:	79 0a                	jns    80107ecc <allocuvm+0x17>
    return 0;
80107ec2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ec7:	e9 c1 00 00 00       	jmp    80107f8d <allocuvm+0xd8>
  if(newsz < oldsz)
80107ecc:	8b 45 10             	mov    0x10(%ebp),%eax
80107ecf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ed2:	73 08                	jae    80107edc <allocuvm+0x27>
    return oldsz;
80107ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ed7:	e9 b1 00 00 00       	jmp    80107f8d <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107edf:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ee4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107eec:	e9 8d 00 00 00       	jmp    80107f7e <allocuvm+0xc9>
    mem = kalloc();
80107ef1:	e8 25 ae ff ff       	call   80102d1b <kalloc>
80107ef6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ef9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107efd:	75 2c                	jne    80107f2b <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107eff:	c7 04 24 59 89 10 80 	movl   $0x80108959,(%esp)
80107f06:	e8 95 84 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f0e:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f12:	8b 45 10             	mov    0x10(%ebp),%eax
80107f15:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f19:	8b 45 08             	mov    0x8(%ebp),%eax
80107f1c:	89 04 24             	mov    %eax,(%esp)
80107f1f:	e8 6b 00 00 00       	call   80107f8f <deallocuvm>
      return 0;
80107f24:	b8 00 00 00 00       	mov    $0x0,%eax
80107f29:	eb 62                	jmp    80107f8d <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107f2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f32:	00 
80107f33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f3a:	00 
80107f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3e:	89 04 24             	mov    %eax,(%esp)
80107f41:	e8 77 d0 ff ff       	call   80104fbd <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f49:	89 04 24             	mov    %eax,(%esp)
80107f4c:	e8 cc f5 ff ff       	call   8010751d <v2p>
80107f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f54:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107f5b:	00 
80107f5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107f60:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f67:	00 
80107f68:	89 54 24 04          	mov    %edx,0x4(%esp)
80107f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f6f:	89 04 24             	mov    %eax,(%esp)
80107f72:	e8 d8 fa ff ff       	call   80107a4f <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107f77:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f81:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f84:	0f 82 67 ff ff ff    	jb     80107ef1 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107f8a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f8d:	c9                   	leave  
80107f8e:	c3                   	ret    

80107f8f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f8f:	55                   	push   %ebp
80107f90:	89 e5                	mov    %esp,%ebp
80107f92:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107f95:	8b 45 10             	mov    0x10(%ebp),%eax
80107f98:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f9b:	72 08                	jb     80107fa5 <deallocuvm+0x16>
    return oldsz;
80107f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa0:	e9 a4 00 00 00       	jmp    80108049 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107fa5:	8b 45 10             	mov    0x10(%ebp),%eax
80107fa8:	05 ff 0f 00 00       	add    $0xfff,%eax
80107fad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107fb5:	e9 80 00 00 00       	jmp    8010803a <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fc4:	00 
80107fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80107fcc:	89 04 24             	mov    %eax,(%esp)
80107fcf:	e8 d9 f9 ff ff       	call   801079ad <walkpgdir>
80107fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107fd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fdb:	75 09                	jne    80107fe6 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107fdd:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107fe4:	eb 4d                	jmp    80108033 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe9:	8b 00                	mov    (%eax),%eax
80107feb:	83 e0 01             	and    $0x1,%eax
80107fee:	85 c0                	test   %eax,%eax
80107ff0:	74 41                	je     80108033 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff5:	8b 00                	mov    (%eax),%eax
80107ff7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ffc:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107fff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108003:	75 0c                	jne    80108011 <deallocuvm+0x82>
        panic("kfree");
80108005:	c7 04 24 71 89 10 80 	movl   $0x80108971,(%esp)
8010800c:	e8 29 85 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108011:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108014:	89 04 24             	mov    %eax,(%esp)
80108017:	e8 0e f5 ff ff       	call   8010752a <p2v>
8010801c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010801f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108022:	89 04 24             	mov    %eax,(%esp)
80108025:	e8 58 ac ff ff       	call   80102c82 <kfree>
      *pte = 0;
8010802a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108033:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010803a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108040:	0f 82 74 ff ff ff    	jb     80107fba <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108046:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108049:	c9                   	leave  
8010804a:	c3                   	ret    

8010804b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010804b:	55                   	push   %ebp
8010804c:	89 e5                	mov    %esp,%ebp
8010804e:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108051:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108055:	75 0c                	jne    80108063 <freevm+0x18>
    panic("freevm: no pgdir");
80108057:	c7 04 24 77 89 10 80 	movl   $0x80108977,(%esp)
8010805e:	e8 d7 84 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108063:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010806a:	00 
8010806b:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108072:	80 
80108073:	8b 45 08             	mov    0x8(%ebp),%eax
80108076:	89 04 24             	mov    %eax,(%esp)
80108079:	e8 11 ff ff ff       	call   80107f8f <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010807e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108085:	eb 48                	jmp    801080cf <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108091:	8b 45 08             	mov    0x8(%ebp),%eax
80108094:	01 d0                	add    %edx,%eax
80108096:	8b 00                	mov    (%eax),%eax
80108098:	83 e0 01             	and    $0x1,%eax
8010809b:	85 c0                	test   %eax,%eax
8010809d:	74 2c                	je     801080cb <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010809f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080a9:	8b 45 08             	mov    0x8(%ebp),%eax
801080ac:	01 d0                	add    %edx,%eax
801080ae:	8b 00                	mov    (%eax),%eax
801080b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080b5:	89 04 24             	mov    %eax,(%esp)
801080b8:	e8 6d f4 ff ff       	call   8010752a <p2v>
801080bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801080c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c3:	89 04 24             	mov    %eax,(%esp)
801080c6:	e8 b7 ab ff ff       	call   80102c82 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801080cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080cf:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801080d6:	76 af                	jbe    80108087 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801080d8:	8b 45 08             	mov    0x8(%ebp),%eax
801080db:	89 04 24             	mov    %eax,(%esp)
801080de:	e8 9f ab ff ff       	call   80102c82 <kfree>
}
801080e3:	c9                   	leave  
801080e4:	c3                   	ret    

801080e5 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801080e5:	55                   	push   %ebp
801080e6:	89 e5                	mov    %esp,%ebp
801080e8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080f2:	00 
801080f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801080fa:	8b 45 08             	mov    0x8(%ebp),%eax
801080fd:	89 04 24             	mov    %eax,(%esp)
80108100:	e8 a8 f8 ff ff       	call   801079ad <walkpgdir>
80108105:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108108:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010810c:	75 0c                	jne    8010811a <clearpteu+0x35>
    panic("clearpteu");
8010810e:	c7 04 24 88 89 10 80 	movl   $0x80108988,(%esp)
80108115:	e8 20 84 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010811a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811d:	8b 00                	mov    (%eax),%eax
8010811f:	83 e0 fb             	and    $0xfffffffb,%eax
80108122:	89 c2                	mov    %eax,%edx
80108124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108127:	89 10                	mov    %edx,(%eax)
}
80108129:	c9                   	leave  
8010812a:	c3                   	ret    

8010812b <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010812b:	55                   	push   %ebp
8010812c:	89 e5                	mov    %esp,%ebp
8010812e:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108131:	e8 b1 f9 ff ff       	call   80107ae7 <setupkvm>
80108136:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108139:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010813d:	75 0a                	jne    80108149 <copyuvm+0x1e>
    return 0;
8010813f:	b8 00 00 00 00       	mov    $0x0,%eax
80108144:	e9 f1 00 00 00       	jmp    8010823a <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80108149:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108150:	e9 c4 00 00 00       	jmp    80108219 <copyuvm+0xee>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108158:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010815f:	00 
80108160:	89 44 24 04          	mov    %eax,0x4(%esp)
80108164:	8b 45 08             	mov    0x8(%ebp),%eax
80108167:	89 04 24             	mov    %eax,(%esp)
8010816a:	e8 3e f8 ff ff       	call   801079ad <walkpgdir>
8010816f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108172:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108176:	75 0c                	jne    80108184 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108178:	c7 04 24 92 89 10 80 	movl   $0x80108992,(%esp)
8010817f:	e8 b6 83 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108184:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108187:	8b 00                	mov    (%eax),%eax
80108189:	83 e0 01             	and    $0x1,%eax
8010818c:	85 c0                	test   %eax,%eax
8010818e:	75 0c                	jne    8010819c <copyuvm+0x71>
      panic("copyuvm: page not present");
80108190:	c7 04 24 ac 89 10 80 	movl   $0x801089ac,(%esp)
80108197:	e8 9e 83 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010819c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819f:	8b 00                	mov    (%eax),%eax
801081a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801081a9:	e8 6d ab ff ff       	call   80102d1b <kalloc>
801081ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801081b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801081b5:	75 02                	jne    801081b9 <copyuvm+0x8e>
      goto bad;
801081b7:	eb 71                	jmp    8010822a <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801081b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081bc:	89 04 24             	mov    %eax,(%esp)
801081bf:	e8 66 f3 ff ff       	call   8010752a <p2v>
801081c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081cb:	00 
801081cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801081d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081d3:	89 04 24             	mov    %eax,(%esp)
801081d6:	e8 b1 ce ff ff       	call   8010508c <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801081db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081de:	89 04 24             	mov    %eax,(%esp)
801081e1:	e8 37 f3 ff ff       	call   8010751d <v2p>
801081e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081e9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801081f0:	00 
801081f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801081f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081fc:	00 
801081fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80108201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108204:	89 04 24             	mov    %eax,(%esp)
80108207:	e8 43 f8 ff ff       	call   80107a4f <mappages>
8010820c:	85 c0                	test   %eax,%eax
8010820e:	79 02                	jns    80108212 <copyuvm+0xe7>
      goto bad;
80108210:	eb 18                	jmp    8010822a <copyuvm+0xff>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108212:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010821f:	0f 82 30 ff ff ff    	jb     80108155 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108228:	eb 10                	jmp    8010823a <copyuvm+0x10f>

bad:
  freevm(d);
8010822a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010822d:	89 04 24             	mov    %eax,(%esp)
80108230:	e8 16 fe ff ff       	call   8010804b <freevm>
  return 0;
80108235:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010823a:	c9                   	leave  
8010823b:	c3                   	ret    

8010823c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010823c:	55                   	push   %ebp
8010823d:	89 e5                	mov    %esp,%ebp
8010823f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108242:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108249:	00 
8010824a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010824d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108251:	8b 45 08             	mov    0x8(%ebp),%eax
80108254:	89 04 24             	mov    %eax,(%esp)
80108257:	e8 51 f7 ff ff       	call   801079ad <walkpgdir>
8010825c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010825f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108262:	8b 00                	mov    (%eax),%eax
80108264:	83 e0 01             	and    $0x1,%eax
80108267:	85 c0                	test   %eax,%eax
80108269:	75 07                	jne    80108272 <uva2ka+0x36>
    return 0;
8010826b:	b8 00 00 00 00       	mov    $0x0,%eax
80108270:	eb 25                	jmp    80108297 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108275:	8b 00                	mov    (%eax),%eax
80108277:	83 e0 04             	and    $0x4,%eax
8010827a:	85 c0                	test   %eax,%eax
8010827c:	75 07                	jne    80108285 <uva2ka+0x49>
    return 0;
8010827e:	b8 00 00 00 00       	mov    $0x0,%eax
80108283:	eb 12                	jmp    80108297 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108288:	8b 00                	mov    (%eax),%eax
8010828a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010828f:	89 04 24             	mov    %eax,(%esp)
80108292:	e8 93 f2 ff ff       	call   8010752a <p2v>
}
80108297:	c9                   	leave  
80108298:	c3                   	ret    

80108299 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108299:	55                   	push   %ebp
8010829a:	89 e5                	mov    %esp,%ebp
8010829c:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010829f:	8b 45 10             	mov    0x10(%ebp),%eax
801082a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801082a5:	e9 87 00 00 00       	jmp    80108331 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801082aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801082b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801082bc:	8b 45 08             	mov    0x8(%ebp),%eax
801082bf:	89 04 24             	mov    %eax,(%esp)
801082c2:	e8 75 ff ff ff       	call   8010823c <uva2ka>
801082c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801082ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801082ce:	75 07                	jne    801082d7 <copyout+0x3e>
      return -1;
801082d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082d5:	eb 69                	jmp    80108340 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801082d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801082da:	8b 55 ec             	mov    -0x14(%ebp),%edx
801082dd:	29 c2                	sub    %eax,%edx
801082df:	89 d0                	mov    %edx,%eax
801082e1:	05 00 10 00 00       	add    $0x1000,%eax
801082e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801082e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ec:	3b 45 14             	cmp    0x14(%ebp),%eax
801082ef:	76 06                	jbe    801082f7 <copyout+0x5e>
      n = len;
801082f1:	8b 45 14             	mov    0x14(%ebp),%eax
801082f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801082f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801082fd:	29 c2                	sub    %eax,%edx
801082ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108302:	01 c2                	add    %eax,%edx
80108304:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108307:	89 44 24 08          	mov    %eax,0x8(%esp)
8010830b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108312:	89 14 24             	mov    %edx,(%esp)
80108315:	e8 72 cd ff ff       	call   8010508c <memmove>
    len -= n;
8010831a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010831d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108323:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108326:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108329:	05 00 10 00 00       	add    $0x1000,%eax
8010832e:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108331:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108335:	0f 85 6f ff ff ff    	jne    801082aa <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010833b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108340:	c9                   	leave  
80108341:	c3                   	ret    
