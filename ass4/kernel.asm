
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
8010002d:	b8 44 37 10 80       	mov    $0x80103744,%eax
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
8010003a:	c7 44 24 04 d8 85 10 	movl   $0x801085d8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 40 4e 00 00       	call   80104e8e <initlock>

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
801000bd:	e8 ed 4d 00 00       	call   80104eaf <acquire>

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
80100104:	e8 08 4e 00 00       	call   80104f11 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 c1 4a 00 00       	call   80104be5 <sleep>
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
8010017c:	e8 90 4d 00 00       	call   80104f11 <release>
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
80100198:	c7 04 24 df 85 10 80 	movl   $0x801085df,(%esp)
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
801001d3:	e8 48 29 00 00       	call   80102b20 <iderw>
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
801001ef:	c7 04 24 f0 85 10 80 	movl   $0x801085f0,(%esp)
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
80100210:	e8 0b 29 00 00       	call   80102b20 <iderw>
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
80100229:	c7 04 24 f7 85 10 80 	movl   $0x801085f7,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 6e 4c 00 00       	call   80104eaf <acquire>

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
8010029d:	e8 1c 4a 00 00       	call   80104cbe <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 63 4c 00 00       	call   80104f11 <release>
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
801003bb:	e8 ef 4a 00 00       	call   80104eaf <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 fe 85 10 80 	movl   $0x801085fe,(%esp)
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
801004b0:	c7 45 ec 07 86 10 80 	movl   $0x80108607,-0x14(%ebp)
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
80100533:	e8 d9 49 00 00       	call   80104f11 <release>
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
8010055f:	c7 04 24 0e 86 10 80 	movl   $0x8010860e,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 1d 86 10 80 	movl   $0x8010861d,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 cc 49 00 00       	call   80104f60 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 1f 86 10 80 	movl   $0x8010861f,(%esp)
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
801006b2:	e8 1b 4b 00 00       	call   801051d2 <memmove>
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
801006e1:	e8 1d 4a 00 00       	call   80105103 <memset>
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
80100776:	e8 b1 64 00 00       	call   80106c2c <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 a5 64 00 00       	call   80106c2c <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 99 64 00 00       	call   80106c2c <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 8c 64 00 00       	call   80106c2c <uartputc>
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
801007ba:	e8 f0 46 00 00       	call   80104eaf <acquire>
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
801007ea:	e8 72 45 00 00       	call   80104d61 <procdump>
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
801008f3:	e8 c6 43 00 00       	call   80104cbe <wakeup>
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
80100914:	e8 f8 45 00 00       	call   80104f11 <release>
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
80100939:	e8 71 45 00 00       	call   80104eaf <acquire>
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
80100959:	e8 b3 45 00 00       	call   80104f11 <release>
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
80100982:	e8 5e 42 00 00       	call   80104be5 <sleep>

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
801009fe:	e8 0e 45 00 00       	call   80104f11 <release>
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
80100a32:	e8 78 44 00 00       	call   80104eaf <acquire>
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
80100a6c:	e8 a0 44 00 00       	call   80104f11 <release>
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
80100a87:	c7 44 24 04 23 86 10 	movl   $0x80108623,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 f3 43 00 00       	call   80104e8e <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 2b 86 10 	movl   $0x8010862b,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100aaa:	e8 df 43 00 00       	call   80104e8e <initlock>

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
80100ad4:	e8 18 33 00 00       	call   80103df1 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 ef 21 00 00       	call   80102cdc <ioapicenable>
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
80100afe:	e8 62 1c 00 00       	call   80102765 <namei>
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
80100b69:	c7 04 24 61 2e 10 80 	movl   $0x80102e61,(%esp)
80100b70:	e8 08 72 00 00       	call   80107d7d <setupkvm>
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
80100c11:	e8 35 75 00 00       	call   8010814b <allocuvm>
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
80100c4f:	e8 0c 74 00 00       	call   80108060 <loaduvm>
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
80100cb8:	e8 8e 74 00 00       	call   8010814b <allocuvm>
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
80100cdd:	e8 99 76 00 00       	call   8010837b <clearpteu>
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
80100d13:	e8 55 46 00 00       	call   8010536d <strlen>
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
80100d3c:	e8 2c 46 00 00       	call   8010536d <strlen>
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
80100d6c:	e8 be 77 00 00       	call   8010852f <copyout>
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
80100e13:	e8 17 77 00 00       	call   8010852f <copyout>
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
80100e6b:	e8 b3 44 00 00       	call   80105323 <safestrcpy>

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
80100ebd:	e8 ac 6f 00 00       	call   80107e6e <switchuvm>
  freevm(oldpgdir);
80100ec2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ec5:	89 04 24             	mov    %eax,(%esp)
80100ec8:	e8 14 74 00 00       	call   801082e1 <freevm>
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
80100ee0:	e8 fc 73 00 00       	call   801082e1 <freevm>
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
80100f03:	c7 44 24 04 31 86 10 	movl   $0x80108631,0x4(%esp)
80100f0a:	80 
80100f0b:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f12:	e8 77 3f 00 00       	call   80104e8e <initlock>
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
80100f26:	e8 84 3f 00 00       	call   80104eaf <acquire>
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
80100f4f:	e8 bd 3f 00 00       	call   80104f11 <release>
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
80100f6d:	e8 9f 3f 00 00       	call   80104f11 <release>
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
80100f86:	e8 24 3f 00 00       	call   80104eaf <acquire>
  if(f->ref < 1)
80100f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f8e:	8b 40 04             	mov    0x4(%eax),%eax
80100f91:	85 c0                	test   %eax,%eax
80100f93:	7f 0c                	jg     80100fa1 <filedup+0x28>
    panic("filedup");
80100f95:	c7 04 24 38 86 10 80 	movl   $0x80108638,(%esp)
80100f9c:	e8 99 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa4:	8b 40 04             	mov    0x4(%eax),%eax
80100fa7:	8d 50 01             	lea    0x1(%eax),%edx
80100faa:	8b 45 08             	mov    0x8(%ebp),%eax
80100fad:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fb0:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fb7:	e8 55 3f 00 00       	call   80104f11 <release>
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
80100fce:	e8 dc 3e 00 00       	call   80104eaf <acquire>
  if(f->ref < 1)
80100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd6:	8b 40 04             	mov    0x4(%eax),%eax
80100fd9:	85 c0                	test   %eax,%eax
80100fdb:	7f 0c                	jg     80100fe9 <fileclose+0x28>
    panic("fileclose");
80100fdd:	c7 04 24 40 86 10 80 	movl   $0x80108640,(%esp)
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
80101009:	e8 03 3f 00 00       	call   80104f11 <release>
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
80101053:	e8 b9 3e 00 00       	call   80104f11 <release>
  
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
80101071:	e8 2b 30 00 00       	call   801040a1 <pipeclose>
80101076:	eb 1d                	jmp    80101095 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101078:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010107b:	83 f8 02             	cmp    $0x2,%eax
8010107e:	75 15                	jne    80101095 <fileclose+0xd4>
    begin_trans();
80101080:	e8 df 24 00 00       	call   80103564 <begin_trans>
    iput(ff.ip);
80101085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101088:	89 04 24             	mov    %eax,(%esp)
8010108b:	e8 71 09 00 00       	call   80101a01 <iput>
    commit_trans();
80101090:	e8 18 25 00 00       	call   801035ad <commit_trans>
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
80101122:	e8 fb 30 00 00       	call   80104222 <piperead>
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
80101194:	c7 04 24 4a 86 10 80 	movl   $0x8010864a,(%esp)
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
801011df:	e8 4f 2f 00 00       	call   80104133 <pipewrite>
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
80101225:	e8 3a 23 00 00       	call   80103564 <begin_trans>
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
8010128b:	e8 1d 23 00 00       	call   801035ad <commit_trans>

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
801012a0:	c7 04 24 53 86 10 80 	movl   $0x80108653,(%esp)
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
801012d2:	c7 04 24 63 86 10 80 	movl   $0x80108663,(%esp)
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
80101318:	e8 b5 3e 00 00       	call   801051d2 <memmove>
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
8010135e:	e8 a0 3d 00 00       	call   80105103 <memset>
  log_write(bp);
80101363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 97 22 00 00       	call   80103605 <log_write>
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
80101448:	e8 b8 21 00 00       	call   80103605 <log_write>
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
801014bb:	c7 04 24 6d 86 10 80 	movl   $0x8010866d,(%esp)
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
8010154d:	c7 04 24 83 86 10 80 	movl   $0x80108683,(%esp)
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
80101585:	e8 7b 20 00 00       	call   80103605 <log_write>
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
8010159d:	c7 44 24 04 96 86 10 	movl   $0x80108696,0x4(%esp)
801015a4:	80 
801015a5:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015ac:	e8 dd 38 00 00       	call   80104e8e <initlock>
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
8010162e:	e8 d0 3a 00 00       	call   80105103 <memset>
      dip->type = type;
80101633:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101636:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010163a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101640:	89 04 24             	mov    %eax,(%esp)
80101643:	e8 bd 1f 00 00       	call   80103605 <log_write>
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
80101684:	c7 04 24 9d 86 10 80 	movl   $0x8010869d,(%esp)
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
8010172d:	e8 a0 3a 00 00       	call   801051d2 <memmove>
  log_write(bp);
80101732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101735:	89 04 24             	mov    %eax,(%esp)
80101738:	e8 c8 1e 00 00       	call   80103605 <log_write>
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
80101757:	e8 53 37 00 00       	call   80104eaf <acquire>

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
801017a1:	e8 6b 37 00 00       	call   80104f11 <release>
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
801017d4:	c7 04 24 af 86 10 80 	movl   $0x801086af,(%esp)
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
80101812:	e8 fa 36 00 00       	call   80104f11 <release>

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
80101829:	e8 81 36 00 00       	call   80104eaf <acquire>
  ip->ref++;
8010182e:	8b 45 08             	mov    0x8(%ebp),%eax
80101831:	8b 40 08             	mov    0x8(%eax),%eax
80101834:	8d 50 01             	lea    0x1(%eax),%edx
80101837:	8b 45 08             	mov    0x8(%ebp),%eax
8010183a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010183d:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101844:	e8 c8 36 00 00       	call   80104f11 <release>
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
80101864:	c7 04 24 bf 86 10 80 	movl   $0x801086bf,(%esp)
8010186b:	e8 ca ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101870:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101877:	e8 33 36 00 00       	call   80104eaf <acquire>
  while(ip->flags & I_BUSY)
8010187c:	eb 13                	jmp    80101891 <ilock+0x43>
    sleep(ip, &icache.lock);
8010187e:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
80101885:	80 
80101886:	8b 45 08             	mov    0x8(%ebp),%eax
80101889:	89 04 24             	mov    %eax,(%esp)
8010188c:	e8 54 33 00 00       	call   80104be5 <sleep>

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
801018b6:	e8 56 36 00 00       	call   80104f11 <release>

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
80101961:	e8 6c 38 00 00       	call   801051d2 <memmove>
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
8010198e:	c7 04 24 c5 86 10 80 	movl   $0x801086c5,(%esp)
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
801019bf:	c7 04 24 d4 86 10 80 	movl   $0x801086d4,(%esp)
801019c6:	e8 6f eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019cb:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019d2:	e8 d8 34 00 00       	call   80104eaf <acquire>
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
801019ee:	e8 cb 32 00 00       	call   80104cbe <wakeup>
  release(&icache.lock);
801019f3:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019fa:	e8 12 35 00 00       	call   80104f11 <release>
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
80101a0e:	e8 9c 34 00 00       	call   80104eaf <acquire>
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
80101a4c:	c7 04 24 dc 86 10 80 	movl   $0x801086dc,(%esp)
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
80101a70:	e8 9c 34 00 00       	call   80104f11 <release>
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
80101a9b:	e8 0f 34 00 00       	call   80104eaf <acquire>
    ip->flags = 0;
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	89 04 24             	mov    %eax,(%esp)
80101ab0:	e8 09 32 00 00       	call   80104cbe <wakeup>
  }
  ip->ref--;
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 08             	mov    0x8(%eax),%eax
80101abb:	8d 50 ff             	lea    -0x1(%eax),%edx
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ac4:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101acb:	e8 41 34 00 00       	call   80104f11 <release>
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
80101bd6:	e8 2a 1a 00 00       	call   80103605 <log_write>
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
80101cee:	e8 12 19 00 00       	call   80103605 <log_write>
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
80101d03:	c7 04 24 e6 86 10 80 	movl   $0x801086e6,(%esp)
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
801020d2:	e8 fb 30 00 00       	call   801051d2 <memmove>
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
80102231:	e8 9c 2f 00 00       	call   801051d2 <memmove>
    log_write(bp);
80102236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102239:	89 04 24             	mov    %eax,(%esp)
8010223c:	e8 c4 13 00 00       	call   80103605 <log_write>
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
801022af:	e8 c1 2f 00 00       	call   80105275 <strncmp>
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
801022c9:	c7 04 24 f9 86 10 80 	movl   $0x801086f9,(%esp)
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
80102307:	c7 04 24 0b 87 10 80 	movl   $0x8010870b,(%esp)
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
801023ec:	c7 04 24 0b 87 10 80 	movl   $0x8010870b,(%esp)
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
80102431:	e8 95 2e 00 00       	call   801052cb <strncpy>
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
80102463:	c7 04 24 18 87 10 80 	movl   $0x80108718,(%esp)
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
801024e8:	e8 e5 2c 00 00       	call   801051d2 <memmove>
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
80102503:	e8 ca 2c 00 00       	call   801051d2 <memmove>
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
namex(char *path, int nameiparent, char *name, uint l_counter, struct inode *last_pos)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  struct inode *ip, *next;
  char buf[100], tname[DIRSIZ];

  if (l_counter > LOOP_PROTECTION) {
80102531:	83 7d 14 10          	cmpl   $0x10,0x14(%ebp)
80102535:	76 0a                	jbe    80102541 <namex+0x19>
	  return 0;  // probably infinite loop.
80102537:	b8 00 00 00 00       	mov    $0x0,%eax
8010253c:	e9 22 02 00 00       	jmp    80102763 <namex+0x23b>
  }

  if(*path == '/')
80102541:	8b 45 08             	mov    0x8(%ebp),%eax
80102544:	0f b6 00             	movzbl (%eax),%eax
80102547:	3c 2f                	cmp    $0x2f,%al
80102549:	75 19                	jne    80102564 <namex+0x3c>
    ip = iget(ROOTDEV, ROOTINO);
8010254b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102552:	00 
80102553:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010255a:	e8 eb f1 ff ff       	call   8010174a <iget>
8010255f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102562:	eb 2f                	jmp    80102593 <namex+0x6b>
  else if (last_pos)
80102564:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
80102568:	74 10                	je     8010257a <namex+0x52>
	ip = idup(last_pos);		// need to remember last inode
8010256a:	8b 45 18             	mov    0x18(%ebp),%eax
8010256d:	89 04 24             	mov    %eax,(%esp)
80102570:	e8 a7 f2 ff ff       	call   8010181c <idup>
80102575:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102578:	eb 19                	jmp    80102593 <namex+0x6b>
  else
	ip = idup(proc->cwd);
8010257a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102580:	8b 40 68             	mov    0x68(%eax),%eax
80102583:	89 04 24             	mov    %eax,(%esp)
80102586:	e8 91 f2 ff ff       	call   8010181c <idup>
8010258b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0) {
8010258e:	e9 96 01 00 00       	jmp    80102729 <namex+0x201>
80102593:	e9 91 01 00 00       	jmp    80102729 <namex+0x201>
	  cprintf("path is %s , name is %s\n", path, name);
80102598:	8b 45 10             	mov    0x10(%ebp),%eax
8010259b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259f:	8b 45 08             	mov    0x8(%ebp),%eax
801025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801025a6:	c7 04 24 20 87 10 80 	movl   $0x80108720,(%esp)
801025ad:	e8 ee dd ff ff       	call   801003a0 <cprintf>
	  ilock(ip);
801025b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b5:	89 04 24             	mov    %eax,(%esp)
801025b8:	e8 91 f2 ff ff       	call   8010184e <ilock>
    if(ip->type != T_DIR){
801025bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025c4:	66 83 f8 01          	cmp    $0x1,%ax
801025c8:	74 15                	je     801025df <namex+0xb7>
      iunlockput(ip);
801025ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cd:	89 04 24             	mov    %eax,(%esp)
801025d0:	e8 fd f4 ff ff       	call   80101ad2 <iunlockput>
      return 0;
801025d5:	b8 00 00 00 00       	mov    $0x0,%eax
801025da:	e9 84 01 00 00       	jmp    80102763 <namex+0x23b>
    }
    if(nameiparent && *path == '\0'){
801025df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025e3:	74 1d                	je     80102602 <namex+0xda>
801025e5:	8b 45 08             	mov    0x8(%ebp),%eax
801025e8:	0f b6 00             	movzbl (%eax),%eax
801025eb:	84 c0                	test   %al,%al
801025ed:	75 13                	jne    80102602 <namex+0xda>
      // Stop one level early.
      iunlock(ip);
801025ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f2:	89 04 24             	mov    %eax,(%esp)
801025f5:	e8 a2 f3 ff ff       	call   8010199c <iunlock>
      return ip;
801025fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fd:	e9 61 01 00 00       	jmp    80102763 <namex+0x23b>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102602:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102609:	00 
8010260a:	8b 45 10             	mov    0x10(%ebp),%eax
8010260d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102614:	89 04 24             	mov    %eax,(%esp)
80102617:	e8 9a fc ff ff       	call   801022b6 <dirlookup>
8010261c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010261f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102623:	75 28                	jne    8010264d <namex+0x125>
      cprintf("could not find directory %s\n", name);
80102625:	8b 45 10             	mov    0x10(%ebp),%eax
80102628:	89 44 24 04          	mov    %eax,0x4(%esp)
8010262c:	c7 04 24 39 87 10 80 	movl   $0x80108739,(%esp)
80102633:	e8 68 dd ff ff       	call   801003a0 <cprintf>
      iunlockput(ip);
80102638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263b:	89 04 24             	mov    %eax,(%esp)
8010263e:	e8 8f f4 ff ff       	call   80101ad2 <iunlockput>
      return 0;
80102643:	b8 00 00 00 00       	mov    $0x0,%eax
80102648:	e9 16 01 00 00       	jmp    80102763 <namex+0x23b>
    }
    iunlockput(ip);
8010264d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102650:	89 04 24             	mov    %eax,(%esp)
80102653:	e8 7a f4 ff ff       	call   80101ad2 <iunlockput>
    ilock(next);  // lock next inode
80102658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010265b:	89 04 24             	mov    %eax,(%esp)
8010265e:	e8 eb f1 ff ff       	call   8010184e <ilock>
    if(next->type == FD_SYMLINK) {		// if symbolic link
80102663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102666:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010266a:	66 83 f8 03          	cmp    $0x3,%ax
8010266e:	0f 85 99 00 00 00    	jne    8010270d <namex+0x1e5>
    	if(readi(next, buf, 0, next->size) != next->size) { // read pointed path
80102674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102677:	8b 40 18             	mov    0x18(%eax),%eax
8010267a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010267e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102685:	00 
80102686:	8d 45 8c             	lea    -0x74(%ebp),%eax
80102689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102690:	89 04 24             	mov    %eax,(%esp)
80102693:	e8 09 f9 ff ff       	call   80101fa1 <readi>
80102698:	89 c2                	mov    %eax,%edx
8010269a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010269d:	8b 40 18             	mov    0x18(%eax),%eax
801026a0:	39 c2                	cmp    %eax,%edx
801026a2:	74 20                	je     801026c4 <namex+0x19c>
    		iunlockput(next);
801026a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026a7:	89 04 24             	mov    %eax,(%esp)
801026aa:	e8 23 f4 ff ff       	call   80101ad2 <iunlockput>
    		iput(ip);
801026af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b2:	89 04 24             	mov    %eax,(%esp)
801026b5:	e8 47 f3 ff ff       	call   80101a01 <iput>
    		return 0;
801026ba:	b8 00 00 00 00       	mov    $0x0,%eax
801026bf:	e9 9f 00 00 00       	jmp    80102763 <namex+0x23b>
    	}
		buf[next->size] = 0;  // null terminated
801026c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026c7:	8b 40 18             	mov    0x18(%eax),%eax
801026ca:	c6 44 05 8c 00       	movb   $0x0,-0x74(%ebp,%eax,1)
		iunlockput(next);
801026cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026d2:	89 04 24             	mov    %eax,(%esp)
801026d5:	e8 f8 f3 ff ff       	call   80101ad2 <iunlockput>
		next = namex(buf, 0, tname, l_counter+1, ip);
801026da:	8b 45 14             	mov    0x14(%ebp),%eax
801026dd:	8d 50 01             	lea    0x1(%eax),%edx
801026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e3:	89 44 24 10          	mov    %eax,0x10(%esp)
801026e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
801026eb:	8d 85 7e ff ff ff    	lea    -0x82(%ebp),%eax
801026f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801026f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026fc:	00 
801026fd:	8d 45 8c             	lea    -0x74(%ebp),%eax
80102700:	89 04 24             	mov    %eax,(%esp)
80102703:	e8 20 fe ff ff       	call   80102528 <namex>
80102708:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010270b:	eb 0b                	jmp    80102718 <namex+0x1f0>
    }  else {
      iunlock(next);
8010270d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102710:	89 04 24             	mov    %eax,(%esp)
80102713:	e8 84 f2 ff ff       	call   8010199c <iunlock>
    }
    iput(ip);
80102718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271b:	89 04 24             	mov    %eax,(%esp)
8010271e:	e8 de f2 ff ff       	call   80101a01 <iput>
    ip = next;
80102723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102726:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else if (last_pos)
	ip = idup(last_pos);		// need to remember last inode
  else
	ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0) {
80102729:	8b 45 10             	mov    0x10(%ebp),%eax
8010272c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102730:	8b 45 08             	mov    0x8(%ebp),%eax
80102733:	89 04 24             	mov    %eax,(%esp)
80102736:	e8 3b fd ff ff       	call   80102476 <skipelem>
8010273b:	89 45 08             	mov    %eax,0x8(%ebp)
8010273e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102742:	0f 85 50 fe ff ff    	jne    80102598 <namex+0x70>
      iunlock(next);
    }
    iput(ip);
    ip = next;
  }
  if(nameiparent){
80102748:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010274c:	74 12                	je     80102760 <namex+0x238>
    iput(ip);
8010274e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102751:	89 04 24             	mov    %eax,(%esp)
80102754:	e8 a8 f2 ff ff       	call   80101a01 <iput>
    return 0;
80102759:	b8 00 00 00 00       	mov    $0x0,%eax
8010275e:	eb 03                	jmp    80102763 <namex+0x23b>
  }
  return ip;
80102760:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102763:	c9                   	leave  
80102764:	c3                   	ret    

80102765 <namei>:

struct inode*
namei(char *path)
{
80102765:	55                   	push   %ebp
80102766:	89 e5                	mov    %esp,%ebp
80102768:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ];
  return namex(path, 0, name, 1, 0);
8010276b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
80102772:	00 
80102773:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
8010277a:	00 
8010277b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010277e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102782:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102789:	00 
8010278a:	8b 45 08             	mov    0x8(%ebp),%eax
8010278d:	89 04 24             	mov    %eax,(%esp)
80102790:	e8 93 fd ff ff       	call   80102528 <namex>
}
80102795:	c9                   	leave  
80102796:	c3                   	ret    

80102797 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102797:	55                   	push   %ebp
80102798:	89 e5                	mov    %esp,%ebp
8010279a:	83 ec 28             	sub    $0x28,%esp
  return namex(path, 1, name, 1, 0);
8010279d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
801027a4:	00 
801027a5:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
801027ac:	00 
801027ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801027b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801027b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027bb:	00 
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	89 04 24             	mov    %eax,(%esp)
801027c2:	e8 61 fd ff ff       	call   80102528 <namex>
}
801027c7:	c9                   	leave  
801027c8:	c3                   	ret    

801027c9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027c9:	55                   	push   %ebp
801027ca:	89 e5                	mov    %esp,%ebp
801027cc:	83 ec 14             	sub    $0x14,%esp
801027cf:	8b 45 08             	mov    0x8(%ebp),%eax
801027d2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027d6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027da:	89 c2                	mov    %eax,%edx
801027dc:	ec                   	in     (%dx),%al
801027dd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027e0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801027e4:	c9                   	leave  
801027e5:	c3                   	ret    

801027e6 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027e6:	55                   	push   %ebp
801027e7:	89 e5                	mov    %esp,%ebp
801027e9:	57                   	push   %edi
801027ea:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027eb:	8b 55 08             	mov    0x8(%ebp),%edx
801027ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027f1:	8b 45 10             	mov    0x10(%ebp),%eax
801027f4:	89 cb                	mov    %ecx,%ebx
801027f6:	89 df                	mov    %ebx,%edi
801027f8:	89 c1                	mov    %eax,%ecx
801027fa:	fc                   	cld    
801027fb:	f3 6d                	rep insl (%dx),%es:(%edi)
801027fd:	89 c8                	mov    %ecx,%eax
801027ff:	89 fb                	mov    %edi,%ebx
80102801:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102804:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102807:	5b                   	pop    %ebx
80102808:	5f                   	pop    %edi
80102809:	5d                   	pop    %ebp
8010280a:	c3                   	ret    

8010280b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010280b:	55                   	push   %ebp
8010280c:	89 e5                	mov    %esp,%ebp
8010280e:	83 ec 08             	sub    $0x8,%esp
80102811:	8b 55 08             	mov    0x8(%ebp),%edx
80102814:	8b 45 0c             	mov    0xc(%ebp),%eax
80102817:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010281b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010281e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102822:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102826:	ee                   	out    %al,(%dx)
}
80102827:	c9                   	leave  
80102828:	c3                   	ret    

80102829 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102829:	55                   	push   %ebp
8010282a:	89 e5                	mov    %esp,%ebp
8010282c:	56                   	push   %esi
8010282d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010282e:	8b 55 08             	mov    0x8(%ebp),%edx
80102831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102834:	8b 45 10             	mov    0x10(%ebp),%eax
80102837:	89 cb                	mov    %ecx,%ebx
80102839:	89 de                	mov    %ebx,%esi
8010283b:	89 c1                	mov    %eax,%ecx
8010283d:	fc                   	cld    
8010283e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102840:	89 c8                	mov    %ecx,%eax
80102842:	89 f3                	mov    %esi,%ebx
80102844:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102847:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010284a:	5b                   	pop    %ebx
8010284b:	5e                   	pop    %esi
8010284c:	5d                   	pop    %ebp
8010284d:	c3                   	ret    

8010284e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010284e:	55                   	push   %ebp
8010284f:	89 e5                	mov    %esp,%ebp
80102851:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102854:	90                   	nop
80102855:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010285c:	e8 68 ff ff ff       	call   801027c9 <inb>
80102861:	0f b6 c0             	movzbl %al,%eax
80102864:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102867:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286a:	25 c0 00 00 00       	and    $0xc0,%eax
8010286f:	83 f8 40             	cmp    $0x40,%eax
80102872:	75 e1                	jne    80102855 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102874:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102878:	74 11                	je     8010288b <idewait+0x3d>
8010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287d:	83 e0 21             	and    $0x21,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	74 07                	je     8010288b <idewait+0x3d>
    return -1;
80102884:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102889:	eb 05                	jmp    80102890 <idewait+0x42>
  return 0;
8010288b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102890:	c9                   	leave  
80102891:	c3                   	ret    

80102892 <ideinit>:

void
ideinit(void)
{
80102892:	55                   	push   %ebp
80102893:	89 e5                	mov    %esp,%ebp
80102895:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102898:	c7 44 24 04 56 87 10 	movl   $0x80108756,0x4(%esp)
8010289f:	80 
801028a0:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028a7:	e8 e2 25 00 00       	call   80104e8e <initlock>
  picenable(IRQ_IDE);
801028ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028b3:	e8 39 15 00 00       	call   80103df1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028b8:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
801028bd:	83 e8 01             	sub    $0x1,%eax
801028c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028cb:	e8 0c 04 00 00       	call   80102cdc <ioapicenable>
  idewait(0);
801028d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028d7:	e8 72 ff ff ff       	call   8010284e <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028dc:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028e3:	00 
801028e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028eb:	e8 1b ff ff ff       	call   8010280b <outb>
  for(i=0; i<1000; i++){
801028f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028f7:	eb 20                	jmp    80102919 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028f9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102900:	e8 c4 fe ff ff       	call   801027c9 <inb>
80102905:	84 c0                	test   %al,%al
80102907:	74 0c                	je     80102915 <ideinit+0x83>
      havedisk1 = 1;
80102909:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102910:	00 00 00 
      break;
80102913:	eb 0d                	jmp    80102922 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102915:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102919:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102920:	7e d7                	jle    801028f9 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102922:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102929:	00 
8010292a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102931:	e8 d5 fe ff ff       	call   8010280b <outb>
}
80102936:	c9                   	leave  
80102937:	c3                   	ret    

80102938 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102938:	55                   	push   %ebp
80102939:	89 e5                	mov    %esp,%ebp
8010293b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010293e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102942:	75 0c                	jne    80102950 <idestart+0x18>
    panic("idestart");
80102944:	c7 04 24 5a 87 10 80 	movl   $0x8010875a,(%esp)
8010294b:	e8 ea db ff ff       	call   8010053a <panic>

  idewait(0);
80102950:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102957:	e8 f2 fe ff ff       	call   8010284e <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010295c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102963:	00 
80102964:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010296b:	e8 9b fe ff ff       	call   8010280b <outb>
  outb(0x1f2, 1);  // number of sectors
80102970:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102977:	00 
80102978:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010297f:	e8 87 fe ff ff       	call   8010280b <outb>
  outb(0x1f3, b->sector & 0xff);
80102984:	8b 45 08             	mov    0x8(%ebp),%eax
80102987:	8b 40 08             	mov    0x8(%eax),%eax
8010298a:	0f b6 c0             	movzbl %al,%eax
8010298d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102991:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102998:	e8 6e fe ff ff       	call   8010280b <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 40 08             	mov    0x8(%eax),%eax
801029a3:	c1 e8 08             	shr    $0x8,%eax
801029a6:	0f b6 c0             	movzbl %al,%eax
801029a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ad:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b4:	e8 52 fe ff ff       	call   8010280b <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029b9:	8b 45 08             	mov    0x8(%ebp),%eax
801029bc:	8b 40 08             	mov    0x8(%eax),%eax
801029bf:	c1 e8 10             	shr    $0x10,%eax
801029c2:	0f b6 c0             	movzbl %al,%eax
801029c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c9:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029d0:	e8 36 fe ff ff       	call   8010280b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029d5:	8b 45 08             	mov    0x8(%ebp),%eax
801029d8:	8b 40 04             	mov    0x4(%eax),%eax
801029db:	83 e0 01             	and    $0x1,%eax
801029de:	c1 e0 04             	shl    $0x4,%eax
801029e1:	89 c2                	mov    %eax,%edx
801029e3:	8b 45 08             	mov    0x8(%ebp),%eax
801029e6:	8b 40 08             	mov    0x8(%eax),%eax
801029e9:	c1 e8 18             	shr    $0x18,%eax
801029ec:	83 e0 0f             	and    $0xf,%eax
801029ef:	09 d0                	or     %edx,%eax
801029f1:	83 c8 e0             	or     $0xffffffe0,%eax
801029f4:	0f b6 c0             	movzbl %al,%eax
801029f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029fb:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a02:	e8 04 fe ff ff       	call   8010280b <outb>
  if(b->flags & B_DIRTY){
80102a07:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0a:	8b 00                	mov    (%eax),%eax
80102a0c:	83 e0 04             	and    $0x4,%eax
80102a0f:	85 c0                	test   %eax,%eax
80102a11:	74 34                	je     80102a47 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102a13:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a1a:	00 
80102a1b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a22:	e8 e4 fd ff ff       	call   8010280b <outb>
    outsl(0x1f0, b->data, 512/4);
80102a27:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2a:	83 c0 18             	add    $0x18,%eax
80102a2d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a34:	00 
80102a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a39:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a40:	e8 e4 fd ff ff       	call   80102829 <outsl>
80102a45:	eb 14                	jmp    80102a5b <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a47:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a4e:	00 
80102a4f:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a56:	e8 b0 fd ff ff       	call   8010280b <outb>
  }
}
80102a5b:	c9                   	leave  
80102a5c:	c3                   	ret    

80102a5d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a5d:	55                   	push   %ebp
80102a5e:	89 e5                	mov    %esp,%ebp
80102a60:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a63:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a6a:	e8 40 24 00 00       	call   80104eaf <acquire>
  if((b = idequeue) == 0){
80102a6f:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a7b:	75 11                	jne    80102a8e <ideintr+0x31>
    release(&idelock);
80102a7d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a84:	e8 88 24 00 00       	call   80104f11 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a89:	e9 90 00 00 00       	jmp    80102b1e <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a91:	8b 40 14             	mov    0x14(%eax),%eax
80102a94:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9c:	8b 00                	mov    (%eax),%eax
80102a9e:	83 e0 04             	and    $0x4,%eax
80102aa1:	85 c0                	test   %eax,%eax
80102aa3:	75 2e                	jne    80102ad3 <ideintr+0x76>
80102aa5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aac:	e8 9d fd ff ff       	call   8010284e <idewait>
80102ab1:	85 c0                	test   %eax,%eax
80102ab3:	78 1e                	js     80102ad3 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	83 c0 18             	add    $0x18,%eax
80102abb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102ac2:	00 
80102ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac7:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ace:	e8 13 fd ff ff       	call   801027e6 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad6:	8b 00                	mov    (%eax),%eax
80102ad8:	83 c8 02             	or     $0x2,%eax
80102adb:	89 c2                	mov    %eax,%edx
80102add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae5:	8b 00                	mov    (%eax),%eax
80102ae7:	83 e0 fb             	and    $0xfffffffb,%eax
80102aea:	89 c2                	mov    %eax,%edx
80102aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af4:	89 04 24             	mov    %eax,(%esp)
80102af7:	e8 c2 21 00 00       	call   80104cbe <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102afc:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b01:	85 c0                	test   %eax,%eax
80102b03:	74 0d                	je     80102b12 <ideintr+0xb5>
    idestart(idequeue);
80102b05:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b0a:	89 04 24             	mov    %eax,(%esp)
80102b0d:	e8 26 fe ff ff       	call   80102938 <idestart>

  release(&idelock);
80102b12:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b19:	e8 f3 23 00 00       	call   80104f11 <release>
}
80102b1e:	c9                   	leave  
80102b1f:	c3                   	ret    

80102b20 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b20:	55                   	push   %ebp
80102b21:	89 e5                	mov    %esp,%ebp
80102b23:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	8b 00                	mov    (%eax),%eax
80102b2b:	83 e0 01             	and    $0x1,%eax
80102b2e:	85 c0                	test   %eax,%eax
80102b30:	75 0c                	jne    80102b3e <iderw+0x1e>
    panic("iderw: buf not busy");
80102b32:	c7 04 24 63 87 10 80 	movl   $0x80108763,(%esp)
80102b39:	e8 fc d9 ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b41:	8b 00                	mov    (%eax),%eax
80102b43:	83 e0 06             	and    $0x6,%eax
80102b46:	83 f8 02             	cmp    $0x2,%eax
80102b49:	75 0c                	jne    80102b57 <iderw+0x37>
    panic("iderw: nothing to do");
80102b4b:	c7 04 24 77 87 10 80 	movl   $0x80108777,(%esp)
80102b52:	e8 e3 d9 ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80102b57:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5a:	8b 40 04             	mov    0x4(%eax),%eax
80102b5d:	85 c0                	test   %eax,%eax
80102b5f:	74 15                	je     80102b76 <iderw+0x56>
80102b61:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b66:	85 c0                	test   %eax,%eax
80102b68:	75 0c                	jne    80102b76 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b6a:	c7 04 24 8c 87 10 80 	movl   $0x8010878c,(%esp)
80102b71:	e8 c4 d9 ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b76:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b7d:	e8 2d 23 00 00       	call   80104eaf <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b82:	8b 45 08             	mov    0x8(%ebp),%eax
80102b85:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b8c:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b93:	eb 0b                	jmp    80102ba0 <iderw+0x80>
80102b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b98:	8b 00                	mov    (%eax),%eax
80102b9a:	83 c0 14             	add    $0x14,%eax
80102b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba3:	8b 00                	mov    (%eax),%eax
80102ba5:	85 c0                	test   %eax,%eax
80102ba7:	75 ec                	jne    80102b95 <iderw+0x75>
    ;
  *pp = b;
80102ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bac:	8b 55 08             	mov    0x8(%ebp),%edx
80102baf:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102bb1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102bb6:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bb9:	75 0d                	jne    80102bc8 <iderw+0xa8>
    idestart(b);
80102bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbe:	89 04 24             	mov    %eax,(%esp)
80102bc1:	e8 72 fd ff ff       	call   80102938 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc6:	eb 15                	jmp    80102bdd <iderw+0xbd>
80102bc8:	eb 13                	jmp    80102bdd <iderw+0xbd>
    sleep(b, &idelock);
80102bca:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102bd1:	80 
80102bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd5:	89 04 24             	mov    %eax,(%esp)
80102bd8:	e8 08 20 00 00       	call   80104be5 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102be0:	8b 00                	mov    (%eax),%eax
80102be2:	83 e0 06             	and    $0x6,%eax
80102be5:	83 f8 02             	cmp    $0x2,%eax
80102be8:	75 e0                	jne    80102bca <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102bea:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bf1:	e8 1b 23 00 00       	call   80104f11 <release>
}
80102bf6:	c9                   	leave  
80102bf7:	c3                   	ret    

80102bf8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bf8:	55                   	push   %ebp
80102bf9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfb:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102c00:	8b 55 08             	mov    0x8(%ebp),%edx
80102c03:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c05:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102c0a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c0d:	5d                   	pop    %ebp
80102c0e:	c3                   	ret    

80102c0f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c0f:	55                   	push   %ebp
80102c10:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c12:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102c17:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c1c:	a1 fc f8 10 80       	mov    0x8010f8fc,%eax
80102c21:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c24:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c27:	5d                   	pop    %ebp
80102c28:	c3                   	ret    

80102c29 <ioapicinit>:

void
ioapicinit(void)
{
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
80102c2c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c2f:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80102c34:	85 c0                	test   %eax,%eax
80102c36:	75 05                	jne    80102c3d <ioapicinit+0x14>
    return;
80102c38:	e9 9d 00 00 00       	jmp    80102cda <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c3d:	c7 05 fc f8 10 80 00 	movl   $0xfec00000,0x8010f8fc
80102c44:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c4e:	e8 a5 ff ff ff       	call   80102bf8 <ioapicread>
80102c53:	c1 e8 10             	shr    $0x10,%eax
80102c56:	25 ff 00 00 00       	and    $0xff,%eax
80102c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c65:	e8 8e ff ff ff       	call   80102bf8 <ioapicread>
80102c6a:	c1 e8 18             	shr    $0x18,%eax
80102c6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c70:	0f b6 05 c0 f9 10 80 	movzbl 0x8010f9c0,%eax
80102c77:	0f b6 c0             	movzbl %al,%eax
80102c7a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c7d:	74 0c                	je     80102c8b <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c7f:	c7 04 24 ac 87 10 80 	movl   $0x801087ac,(%esp)
80102c86:	e8 15 d7 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c92:	eb 3e                	jmp    80102cd2 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c97:	83 c0 20             	add    $0x20,%eax
80102c9a:	0d 00 00 01 00       	or     $0x10000,%eax
80102c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ca2:	83 c2 08             	add    $0x8,%edx
80102ca5:	01 d2                	add    %edx,%edx
80102ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cab:	89 14 24             	mov    %edx,(%esp)
80102cae:	e8 5c ff ff ff       	call   80102c0f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb6:	83 c0 08             	add    $0x8,%eax
80102cb9:	01 c0                	add    %eax,%eax
80102cbb:	83 c0 01             	add    $0x1,%eax
80102cbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cc5:	00 
80102cc6:	89 04 24             	mov    %eax,(%esp)
80102cc9:	e8 41 ff ff ff       	call   80102c0f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cd8:	7e ba                	jle    80102c94 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cda:	c9                   	leave  
80102cdb:	c3                   	ret    

80102cdc <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ce2:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80102ce7:	85 c0                	test   %eax,%eax
80102ce9:	75 02                	jne    80102ced <ioapicenable+0x11>
    return;
80102ceb:	eb 37                	jmp    80102d24 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	83 c0 20             	add    $0x20,%eax
80102cf3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cf6:	83 c2 08             	add    $0x8,%edx
80102cf9:	01 d2                	add    %edx,%edx
80102cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cff:	89 14 24             	mov    %edx,(%esp)
80102d02:	e8 08 ff ff ff       	call   80102c0f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d0a:	c1 e0 18             	shl    $0x18,%eax
80102d0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d10:	83 c2 08             	add    $0x8,%edx
80102d13:	01 d2                	add    %edx,%edx
80102d15:	83 c2 01             	add    $0x1,%edx
80102d18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d1c:	89 14 24             	mov    %edx,(%esp)
80102d1f:	e8 eb fe ff ff       	call   80102c0f <ioapicwrite>
}
80102d24:	c9                   	leave  
80102d25:	c3                   	ret    

80102d26 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d26:	55                   	push   %ebp
80102d27:	89 e5                	mov    %esp,%ebp
80102d29:	8b 45 08             	mov    0x8(%ebp),%eax
80102d2c:	05 00 00 00 80       	add    $0x80000000,%eax
80102d31:	5d                   	pop    %ebp
80102d32:	c3                   	ret    

80102d33 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d33:	55                   	push   %ebp
80102d34:	89 e5                	mov    %esp,%ebp
80102d36:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d39:	c7 44 24 04 de 87 10 	movl   $0x801087de,0x4(%esp)
80102d40:	80 
80102d41:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102d48:	e8 41 21 00 00       	call   80104e8e <initlock>
  kmem.use_lock = 0;
80102d4d:	c7 05 34 f9 10 80 00 	movl   $0x0,0x8010f934
80102d54:	00 00 00 
  freerange(vstart, vend);
80102d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d61:	89 04 24             	mov    %eax,(%esp)
80102d64:	e8 26 00 00 00       	call   80102d8f <freerange>
}
80102d69:	c9                   	leave  
80102d6a:	c3                   	ret    

80102d6b <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d6b:	55                   	push   %ebp
80102d6c:	89 e5                	mov    %esp,%ebp
80102d6e:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d74:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d78:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7b:	89 04 24             	mov    %eax,(%esp)
80102d7e:	e8 0c 00 00 00       	call   80102d8f <freerange>
  kmem.use_lock = 1;
80102d83:	c7 05 34 f9 10 80 01 	movl   $0x1,0x8010f934
80102d8a:	00 00 00 
}
80102d8d:	c9                   	leave  
80102d8e:	c3                   	ret    

80102d8f <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d8f:	55                   	push   %ebp
80102d90:	89 e5                	mov    %esp,%ebp
80102d92:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d95:	8b 45 08             	mov    0x8(%ebp),%eax
80102d98:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da5:	eb 12                	jmp    80102db9 <freerange+0x2a>
    kfree(p);
80102da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daa:	89 04 24             	mov    %eax,(%esp)
80102dad:	e8 16 00 00 00       	call   80102dc8 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbc:	05 00 10 00 00       	add    $0x1000,%eax
80102dc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dc4:	76 e1                	jbe    80102da7 <freerange+0x18>
    kfree(p);
}
80102dc6:	c9                   	leave  
80102dc7:	c3                   	ret    

80102dc8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dc8:	55                   	push   %ebp
80102dc9:	89 e5                	mov    %esp,%ebp
80102dcb:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dce:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd1:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dd6:	85 c0                	test   %eax,%eax
80102dd8:	75 1b                	jne    80102df5 <kfree+0x2d>
80102dda:	81 7d 08 bc 27 11 80 	cmpl   $0x801127bc,0x8(%ebp)
80102de1:	72 12                	jb     80102df5 <kfree+0x2d>
80102de3:	8b 45 08             	mov    0x8(%ebp),%eax
80102de6:	89 04 24             	mov    %eax,(%esp)
80102de9:	e8 38 ff ff ff       	call   80102d26 <v2p>
80102dee:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102df3:	76 0c                	jbe    80102e01 <kfree+0x39>
    panic("kfree");
80102df5:	c7 04 24 e3 87 10 80 	movl   $0x801087e3,(%esp)
80102dfc:	e8 39 d7 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e01:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e08:	00 
80102e09:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e10:	00 
80102e11:	8b 45 08             	mov    0x8(%ebp),%eax
80102e14:	89 04 24             	mov    %eax,(%esp)
80102e17:	e8 e7 22 00 00       	call   80105103 <memset>

  if(kmem.use_lock)
80102e1c:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102e21:	85 c0                	test   %eax,%eax
80102e23:	74 0c                	je     80102e31 <kfree+0x69>
    acquire(&kmem.lock);
80102e25:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102e2c:	e8 7e 20 00 00       	call   80104eaf <acquire>
  r = (struct run*)v;
80102e31:	8b 45 08             	mov    0x8(%ebp),%eax
80102e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e37:	8b 15 38 f9 10 80    	mov    0x8010f938,%edx
80102e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e40:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e45:	a3 38 f9 10 80       	mov    %eax,0x8010f938
  if(kmem.use_lock)
80102e4a:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102e4f:	85 c0                	test   %eax,%eax
80102e51:	74 0c                	je     80102e5f <kfree+0x97>
    release(&kmem.lock);
80102e53:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102e5a:	e8 b2 20 00 00       	call   80104f11 <release>
}
80102e5f:	c9                   	leave  
80102e60:	c3                   	ret    

80102e61 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e67:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102e6c:	85 c0                	test   %eax,%eax
80102e6e:	74 0c                	je     80102e7c <kalloc+0x1b>
    acquire(&kmem.lock);
80102e70:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102e77:	e8 33 20 00 00       	call   80104eaf <acquire>
  r = kmem.freelist;
80102e7c:	a1 38 f9 10 80       	mov    0x8010f938,%eax
80102e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e88:	74 0a                	je     80102e94 <kalloc+0x33>
    kmem.freelist = r->next;
80102e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8d:	8b 00                	mov    (%eax),%eax
80102e8f:	a3 38 f9 10 80       	mov    %eax,0x8010f938
  if(kmem.use_lock)
80102e94:	a1 34 f9 10 80       	mov    0x8010f934,%eax
80102e99:	85 c0                	test   %eax,%eax
80102e9b:	74 0c                	je     80102ea9 <kalloc+0x48>
    release(&kmem.lock);
80102e9d:	c7 04 24 00 f9 10 80 	movl   $0x8010f900,(%esp)
80102ea4:	e8 68 20 00 00       	call   80104f11 <release>
  return (char*)r;
80102ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    

80102eae <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
80102eb1:	83 ec 14             	sub    $0x14,%esp
80102eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102eb7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ebb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ebf:	89 c2                	mov    %eax,%edx
80102ec1:	ec                   	in     (%dx),%al
80102ec2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ec5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ec9:	c9                   	leave  
80102eca:	c3                   	ret    

80102ecb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ecb:	55                   	push   %ebp
80102ecc:	89 e5                	mov    %esp,%ebp
80102ece:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ed1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ed8:	e8 d1 ff ff ff       	call   80102eae <inb>
80102edd:	0f b6 c0             	movzbl %al,%eax
80102ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee6:	83 e0 01             	and    $0x1,%eax
80102ee9:	85 c0                	test   %eax,%eax
80102eeb:	75 0a                	jne    80102ef7 <kbdgetc+0x2c>
    return -1;
80102eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef2:	e9 25 01 00 00       	jmp    8010301c <kbdgetc+0x151>
  data = inb(KBDATAP);
80102ef7:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102efe:	e8 ab ff ff ff       	call   80102eae <inb>
80102f03:	0f b6 c0             	movzbl %al,%eax
80102f06:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f09:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f10:	75 17                	jne    80102f29 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f12:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f17:	83 c8 40             	or     $0x40,%eax
80102f1a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f1f:	b8 00 00 00 00       	mov    $0x0,%eax
80102f24:	e9 f3 00 00 00       	jmp    8010301c <kbdgetc+0x151>
  } else if(data & 0x80){
80102f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2c:	25 80 00 00 00       	and    $0x80,%eax
80102f31:	85 c0                	test   %eax,%eax
80102f33:	74 45                	je     80102f7a <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f35:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f3a:	83 e0 40             	and    $0x40,%eax
80102f3d:	85 c0                	test   %eax,%eax
80102f3f:	75 08                	jne    80102f49 <kbdgetc+0x7e>
80102f41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f44:	83 e0 7f             	and    $0x7f,%eax
80102f47:	eb 03                	jmp    80102f4c <kbdgetc+0x81>
80102f49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f52:	05 20 90 10 80       	add    $0x80109020,%eax
80102f57:	0f b6 00             	movzbl (%eax),%eax
80102f5a:	83 c8 40             	or     $0x40,%eax
80102f5d:	0f b6 c0             	movzbl %al,%eax
80102f60:	f7 d0                	not    %eax
80102f62:	89 c2                	mov    %eax,%edx
80102f64:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f69:	21 d0                	and    %edx,%eax
80102f6b:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f70:	b8 00 00 00 00       	mov    $0x0,%eax
80102f75:	e9 a2 00 00 00       	jmp    8010301c <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f7a:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f7f:	83 e0 40             	and    $0x40,%eax
80102f82:	85 c0                	test   %eax,%eax
80102f84:	74 14                	je     80102f9a <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f86:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f8d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f92:	83 e0 bf             	and    $0xffffffbf,%eax
80102f95:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f9d:	05 20 90 10 80       	add    $0x80109020,%eax
80102fa2:	0f b6 00             	movzbl (%eax),%eax
80102fa5:	0f b6 d0             	movzbl %al,%edx
80102fa8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fad:	09 d0                	or     %edx,%eax
80102faf:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb7:	05 20 91 10 80       	add    $0x80109120,%eax
80102fbc:	0f b6 00             	movzbl (%eax),%eax
80102fbf:	0f b6 d0             	movzbl %al,%edx
80102fc2:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc7:	31 d0                	xor    %edx,%eax
80102fc9:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fce:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fd3:	83 e0 03             	and    $0x3,%eax
80102fd6:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fe0:	01 d0                	add    %edx,%eax
80102fe2:	0f b6 00             	movzbl (%eax),%eax
80102fe5:	0f b6 c0             	movzbl %al,%eax
80102fe8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102feb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ff0:	83 e0 08             	and    $0x8,%eax
80102ff3:	85 c0                	test   %eax,%eax
80102ff5:	74 22                	je     80103019 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102ff7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ffb:	76 0c                	jbe    80103009 <kbdgetc+0x13e>
80102ffd:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103001:	77 06                	ja     80103009 <kbdgetc+0x13e>
      c += 'A' - 'a';
80103003:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103007:	eb 10                	jmp    80103019 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103009:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010300d:	76 0a                	jbe    80103019 <kbdgetc+0x14e>
8010300f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103013:	77 04                	ja     80103019 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103015:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103019:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010301c:	c9                   	leave  
8010301d:	c3                   	ret    

8010301e <kbdintr>:

void
kbdintr(void)
{
8010301e:	55                   	push   %ebp
8010301f:	89 e5                	mov    %esp,%ebp
80103021:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103024:	c7 04 24 cb 2e 10 80 	movl   $0x80102ecb,(%esp)
8010302b:	e8 7d d7 ff ff       	call   801007ad <consoleintr>
}
80103030:	c9                   	leave  
80103031:	c3                   	ret    

80103032 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103032:	55                   	push   %ebp
80103033:	89 e5                	mov    %esp,%ebp
80103035:	83 ec 08             	sub    $0x8,%esp
80103038:	8b 55 08             	mov    0x8(%ebp),%edx
8010303b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010303e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103042:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103045:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103049:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010304d:	ee                   	out    %al,(%dx)
}
8010304e:	c9                   	leave  
8010304f:	c3                   	ret    

80103050 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103056:	9c                   	pushf  
80103057:	58                   	pop    %eax
80103058:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010305b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010305e:	c9                   	leave  
8010305f:	c3                   	ret    

80103060 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103063:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80103068:	8b 55 08             	mov    0x8(%ebp),%edx
8010306b:	c1 e2 02             	shl    $0x2,%edx
8010306e:	01 c2                	add    %eax,%edx
80103070:	8b 45 0c             	mov    0xc(%ebp),%eax
80103073:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103075:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
8010307a:	83 c0 20             	add    $0x20,%eax
8010307d:	8b 00                	mov    (%eax),%eax
}
8010307f:	5d                   	pop    %ebp
80103080:	c3                   	ret    

80103081 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103081:	55                   	push   %ebp
80103082:	89 e5                	mov    %esp,%ebp
80103084:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103087:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
8010308c:	85 c0                	test   %eax,%eax
8010308e:	75 05                	jne    80103095 <lapicinit+0x14>
    return;
80103090:	e9 43 01 00 00       	jmp    801031d8 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103095:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010309c:	00 
8010309d:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030a4:	e8 b7 ff ff ff       	call   80103060 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030a9:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030b0:	00 
801030b1:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030b8:	e8 a3 ff ff ff       	call   80103060 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030bd:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030c4:	00 
801030c5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030cc:	e8 8f ff ff ff       	call   80103060 <lapicw>
  lapicw(TICR, 10000000); 
801030d1:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030d8:	00 
801030d9:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030e0:	e8 7b ff ff ff       	call   80103060 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030e5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030ec:	00 
801030ed:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030f4:	e8 67 ff ff ff       	call   80103060 <lapicw>
  lapicw(LINT1, MASKED);
801030f9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103100:	00 
80103101:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103108:	e8 53 ff ff ff       	call   80103060 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010310d:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80103112:	83 c0 30             	add    $0x30,%eax
80103115:	8b 00                	mov    (%eax),%eax
80103117:	c1 e8 10             	shr    $0x10,%eax
8010311a:	0f b6 c0             	movzbl %al,%eax
8010311d:	83 f8 03             	cmp    $0x3,%eax
80103120:	76 14                	jbe    80103136 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103122:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103129:	00 
8010312a:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103131:	e8 2a ff ff ff       	call   80103060 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103136:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010313d:	00 
8010313e:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103145:	e8 16 ff ff ff       	call   80103060 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010314a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103151:	00 
80103152:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103159:	e8 02 ff ff ff       	call   80103060 <lapicw>
  lapicw(ESR, 0);
8010315e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103165:	00 
80103166:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010316d:	e8 ee fe ff ff       	call   80103060 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103172:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103179:	00 
8010317a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103181:	e8 da fe ff ff       	call   80103060 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103186:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010318d:	00 
8010318e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103195:	e8 c6 fe ff ff       	call   80103060 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010319a:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031a1:	00 
801031a2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031a9:	e8 b2 fe ff ff       	call   80103060 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031ae:	90                   	nop
801031af:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
801031b4:	05 00 03 00 00       	add    $0x300,%eax
801031b9:	8b 00                	mov    (%eax),%eax
801031bb:	25 00 10 00 00       	and    $0x1000,%eax
801031c0:	85 c0                	test   %eax,%eax
801031c2:	75 eb                	jne    801031af <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031cb:	00 
801031cc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031d3:	e8 88 fe ff ff       	call   80103060 <lapicw>
}
801031d8:	c9                   	leave  
801031d9:	c3                   	ret    

801031da <cpunum>:

int
cpunum(void)
{
801031da:	55                   	push   %ebp
801031db:	89 e5                	mov    %esp,%ebp
801031dd:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031e0:	e8 6b fe ff ff       	call   80103050 <readeflags>
801031e5:	25 00 02 00 00       	and    $0x200,%eax
801031ea:	85 c0                	test   %eax,%eax
801031ec:	74 25                	je     80103213 <cpunum+0x39>
    static int n;
    if(n++ == 0)
801031ee:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031f3:	8d 50 01             	lea    0x1(%eax),%edx
801031f6:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
801031fc:	85 c0                	test   %eax,%eax
801031fe:	75 13                	jne    80103213 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80103200:	8b 45 04             	mov    0x4(%ebp),%eax
80103203:	89 44 24 04          	mov    %eax,0x4(%esp)
80103207:	c7 04 24 ec 87 10 80 	movl   $0x801087ec,(%esp)
8010320e:	e8 8d d1 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103213:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80103218:	85 c0                	test   %eax,%eax
8010321a:	74 0f                	je     8010322b <cpunum+0x51>
    return lapic[ID]>>24;
8010321c:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
80103221:	83 c0 20             	add    $0x20,%eax
80103224:	8b 00                	mov    (%eax),%eax
80103226:	c1 e8 18             	shr    $0x18,%eax
80103229:	eb 05                	jmp    80103230 <cpunum+0x56>
  return 0;
8010322b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103230:	c9                   	leave  
80103231:	c3                   	ret    

80103232 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103232:	55                   	push   %ebp
80103233:	89 e5                	mov    %esp,%ebp
80103235:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103238:	a1 3c f9 10 80       	mov    0x8010f93c,%eax
8010323d:	85 c0                	test   %eax,%eax
8010323f:	74 14                	je     80103255 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103248:	00 
80103249:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103250:	e8 0b fe ff ff       	call   80103060 <lapicw>
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
}
8010325a:	5d                   	pop    %ebp
8010325b:	c3                   	ret    

8010325c <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010325c:	55                   	push   %ebp
8010325d:	89 e5                	mov    %esp,%ebp
8010325f:	83 ec 1c             	sub    $0x1c,%esp
80103262:	8b 45 08             	mov    0x8(%ebp),%eax
80103265:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103268:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010326f:	00 
80103270:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103277:	e8 b6 fd ff ff       	call   80103032 <outb>
  outb(IO_RTC+1, 0x0A);
8010327c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103283:	00 
80103284:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010328b:	e8 a2 fd ff ff       	call   80103032 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103290:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103297:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010329a:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010329f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032a2:	8d 50 02             	lea    0x2(%eax),%edx
801032a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801032a8:	c1 e8 04             	shr    $0x4,%eax
801032ab:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032ae:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032b2:	c1 e0 18             	shl    $0x18,%eax
801032b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032b9:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032c0:	e8 9b fd ff ff       	call   80103060 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032c5:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032cc:	00 
801032cd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032d4:	e8 87 fd ff ff       	call   80103060 <lapicw>
  microdelay(200);
801032d9:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032e0:	e8 72 ff ff ff       	call   80103257 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032e5:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032ec:	00 
801032ed:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032f4:	e8 67 fd ff ff       	call   80103060 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032f9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103300:	e8 52 ff ff ff       	call   80103257 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103305:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010330c:	eb 40                	jmp    8010334e <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010330e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103312:	c1 e0 18             	shl    $0x18,%eax
80103315:	89 44 24 04          	mov    %eax,0x4(%esp)
80103319:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103320:	e8 3b fd ff ff       	call   80103060 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103325:	8b 45 0c             	mov    0xc(%ebp),%eax
80103328:	c1 e8 0c             	shr    $0xc,%eax
8010332b:	80 cc 06             	or     $0x6,%ah
8010332e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103332:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103339:	e8 22 fd ff ff       	call   80103060 <lapicw>
    microdelay(200);
8010333e:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103345:	e8 0d ff ff ff       	call   80103257 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010334a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010334e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103352:	7e ba                	jle    8010330e <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103354:	c9                   	leave  
80103355:	c3                   	ret    

80103356 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103356:	55                   	push   %ebp
80103357:	89 e5                	mov    %esp,%ebp
80103359:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010335c:	c7 44 24 04 18 88 10 	movl   $0x80108818,0x4(%esp)
80103363:	80 
80103364:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
8010336b:	e8 1e 1b 00 00       	call   80104e8e <initlock>
  readsb(ROOTDEV, &sb);
80103370:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103373:	89 44 24 04          	mov    %eax,0x4(%esp)
80103377:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010337e:	e8 61 df ff ff       	call   801012e4 <readsb>
  log.start = sb.size - sb.nlog;
80103383:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103389:	29 c2                	sub    %eax,%edx
8010338b:	89 d0                	mov    %edx,%eax
8010338d:	a3 74 f9 10 80       	mov    %eax,0x8010f974
  log.size = sb.nlog;
80103392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103395:	a3 78 f9 10 80       	mov    %eax,0x8010f978
  log.dev = ROOTDEV;
8010339a:	c7 05 80 f9 10 80 01 	movl   $0x1,0x8010f980
801033a1:	00 00 00 
  recover_from_log();
801033a4:	e8 9a 01 00 00       	call   80103543 <recover_from_log>
}
801033a9:	c9                   	leave  
801033aa:	c3                   	ret    

801033ab <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033ab:	55                   	push   %ebp
801033ac:	89 e5                	mov    %esp,%ebp
801033ae:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b8:	e9 8c 00 00 00       	jmp    80103449 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033bd:	8b 15 74 f9 10 80    	mov    0x8010f974,%edx
801033c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c6:	01 d0                	add    %edx,%eax
801033c8:	83 c0 01             	add    $0x1,%eax
801033cb:	89 c2                	mov    %eax,%edx
801033cd:	a1 80 f9 10 80       	mov    0x8010f980,%eax
801033d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d6:	89 04 24             	mov    %eax,(%esp)
801033d9:	e8 c8 cd ff ff       	call   801001a6 <bread>
801033de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033e4:	83 c0 10             	add    $0x10,%eax
801033e7:	8b 04 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%eax
801033ee:	89 c2                	mov    %eax,%edx
801033f0:	a1 80 f9 10 80       	mov    0x8010f980,%eax
801033f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801033f9:	89 04 24             	mov    %eax,(%esp)
801033fc:	e8 a5 cd ff ff       	call   801001a6 <bread>
80103401:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103404:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103407:	8d 50 18             	lea    0x18(%eax),%edx
8010340a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010340d:	83 c0 18             	add    $0x18,%eax
80103410:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103417:	00 
80103418:	89 54 24 04          	mov    %edx,0x4(%esp)
8010341c:	89 04 24             	mov    %eax,(%esp)
8010341f:	e8 ae 1d 00 00       	call   801051d2 <memmove>
    bwrite(dbuf);  // write dst to disk
80103424:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103427:	89 04 24             	mov    %eax,(%esp)
8010342a:	e8 ae cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010342f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103432:	89 04 24             	mov    %eax,(%esp)
80103435:	e8 dd cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010343a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010343d:	89 04 24             	mov    %eax,(%esp)
80103440:	e8 d2 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103445:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103449:	a1 84 f9 10 80       	mov    0x8010f984,%eax
8010344e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103451:	0f 8f 66 ff ff ff    	jg     801033bd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103457:	c9                   	leave  
80103458:	c3                   	ret    

80103459 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103459:	55                   	push   %ebp
8010345a:	89 e5                	mov    %esp,%ebp
8010345c:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010345f:	a1 74 f9 10 80       	mov    0x8010f974,%eax
80103464:	89 c2                	mov    %eax,%edx
80103466:	a1 80 f9 10 80       	mov    0x8010f980,%eax
8010346b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010346f:	89 04 24             	mov    %eax,(%esp)
80103472:	e8 2f cd ff ff       	call   801001a6 <bread>
80103477:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010347a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347d:	83 c0 18             	add    $0x18,%eax
80103480:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103483:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103486:	8b 00                	mov    (%eax),%eax
80103488:	a3 84 f9 10 80       	mov    %eax,0x8010f984
  for (i = 0; i < log.lh.n; i++) {
8010348d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103494:	eb 1b                	jmp    801034b1 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103499:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a3:	83 c2 10             	add    $0x10,%edx
801034a6:	89 04 95 48 f9 10 80 	mov    %eax,-0x7fef06b8(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b1:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801034b6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034b9:	7f db                	jg     80103496 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034be:	89 04 24             	mov    %eax,(%esp)
801034c1:	e8 51 cd ff ff       	call   80100217 <brelse>
}
801034c6:	c9                   	leave  
801034c7:	c3                   	ret    

801034c8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034c8:	55                   	push   %ebp
801034c9:	89 e5                	mov    %esp,%ebp
801034cb:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ce:	a1 74 f9 10 80       	mov    0x8010f974,%eax
801034d3:	89 c2                	mov    %eax,%edx
801034d5:	a1 80 f9 10 80       	mov    0x8010f980,%eax
801034da:	89 54 24 04          	mov    %edx,0x4(%esp)
801034de:	89 04 24             	mov    %eax,(%esp)
801034e1:	e8 c0 cc ff ff       	call   801001a6 <bread>
801034e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ec:	83 c0 18             	add    $0x18,%eax
801034ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034f2:	8b 15 84 f9 10 80    	mov    0x8010f984,%edx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103504:	eb 1b                	jmp    80103521 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103509:	83 c0 10             	add    $0x10,%eax
8010350c:	8b 0c 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%ecx
80103513:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103516:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103519:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010351d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103521:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103526:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103529:	7f db                	jg     80103506 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010352b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352e:	89 04 24             	mov    %eax,(%esp)
80103531:	e8 a7 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103539:	89 04 24             	mov    %eax,(%esp)
8010353c:	e8 d6 cc ff ff       	call   80100217 <brelse>
}
80103541:	c9                   	leave  
80103542:	c3                   	ret    

80103543 <recover_from_log>:

static void
recover_from_log(void)
{
80103543:	55                   	push   %ebp
80103544:	89 e5                	mov    %esp,%ebp
80103546:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103549:	e8 0b ff ff ff       	call   80103459 <read_head>
  install_trans(); // if committed, copy from log to disk
8010354e:	e8 58 fe ff ff       	call   801033ab <install_trans>
  log.lh.n = 0;
80103553:	c7 05 84 f9 10 80 00 	movl   $0x0,0x8010f984
8010355a:	00 00 00 
  write_head(); // clear the log
8010355d:	e8 66 ff ff ff       	call   801034c8 <write_head>
}
80103562:	c9                   	leave  
80103563:	c3                   	ret    

80103564 <begin_trans>:

void
begin_trans(void)
{
80103564:	55                   	push   %ebp
80103565:	89 e5                	mov    %esp,%ebp
80103567:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010356a:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103571:	e8 39 19 00 00       	call   80104eaf <acquire>
  while (log.busy) {
80103576:	eb 14                	jmp    8010358c <begin_trans+0x28>
    sleep(&log, &log.lock);
80103578:	c7 44 24 04 40 f9 10 	movl   $0x8010f940,0x4(%esp)
8010357f:	80 
80103580:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
80103587:	e8 59 16 00 00       	call   80104be5 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010358c:	a1 7c f9 10 80       	mov    0x8010f97c,%eax
80103591:	85 c0                	test   %eax,%eax
80103593:	75 e3                	jne    80103578 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103595:	c7 05 7c f9 10 80 01 	movl   $0x1,0x8010f97c
8010359c:	00 00 00 
  release(&log.lock);
8010359f:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801035a6:	e8 66 19 00 00       	call   80104f11 <release>
}
801035ab:	c9                   	leave  
801035ac:	c3                   	ret    

801035ad <commit_trans>:

void
commit_trans(void)
{
801035ad:	55                   	push   %ebp
801035ae:	89 e5                	mov    %esp,%ebp
801035b0:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035b3:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801035b8:	85 c0                	test   %eax,%eax
801035ba:	7e 19                	jle    801035d5 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035bc:	e8 07 ff ff ff       	call   801034c8 <write_head>
    install_trans(); // Now install writes to home locations
801035c1:	e8 e5 fd ff ff       	call   801033ab <install_trans>
    log.lh.n = 0; 
801035c6:	c7 05 84 f9 10 80 00 	movl   $0x0,0x8010f984
801035cd:	00 00 00 
    write_head();    // Erase the transaction from the log
801035d0:	e8 f3 fe ff ff       	call   801034c8 <write_head>
  }
  
  acquire(&log.lock);
801035d5:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801035dc:	e8 ce 18 00 00       	call   80104eaf <acquire>
  log.busy = 0;
801035e1:	c7 05 7c f9 10 80 00 	movl   $0x0,0x8010f97c
801035e8:	00 00 00 
  wakeup(&log);
801035eb:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801035f2:	e8 c7 16 00 00       	call   80104cbe <wakeup>
  release(&log.lock);
801035f7:	c7 04 24 40 f9 10 80 	movl   $0x8010f940,(%esp)
801035fe:	e8 0e 19 00 00       	call   80104f11 <release>
}
80103603:	c9                   	leave  
80103604:	c3                   	ret    

80103605 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103605:	55                   	push   %ebp
80103606:	89 e5                	mov    %esp,%ebp
80103608:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010360b:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103610:	83 f8 09             	cmp    $0x9,%eax
80103613:	7f 12                	jg     80103627 <log_write+0x22>
80103615:	a1 84 f9 10 80       	mov    0x8010f984,%eax
8010361a:	8b 15 78 f9 10 80    	mov    0x8010f978,%edx
80103620:	83 ea 01             	sub    $0x1,%edx
80103623:	39 d0                	cmp    %edx,%eax
80103625:	7c 0c                	jl     80103633 <log_write+0x2e>
    panic("too big a transaction");
80103627:	c7 04 24 1c 88 10 80 	movl   $0x8010881c,(%esp)
8010362e:	e8 07 cf ff ff       	call   8010053a <panic>
  if (!log.busy)
80103633:	a1 7c f9 10 80       	mov    0x8010f97c,%eax
80103638:	85 c0                	test   %eax,%eax
8010363a:	75 0c                	jne    80103648 <log_write+0x43>
    panic("write outside of trans");
8010363c:	c7 04 24 32 88 10 80 	movl   $0x80108832,(%esp)
80103643:	e8 f2 ce ff ff       	call   8010053a <panic>

  for (i = 0; i < log.lh.n; i++) {
80103648:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010364f:	eb 1f                	jmp    80103670 <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103654:	83 c0 10             	add    $0x10,%eax
80103657:	8b 04 85 48 f9 10 80 	mov    -0x7fef06b8(,%eax,4),%eax
8010365e:	89 c2                	mov    %eax,%edx
80103660:	8b 45 08             	mov    0x8(%ebp),%eax
80103663:	8b 40 08             	mov    0x8(%eax),%eax
80103666:	39 c2                	cmp    %eax,%edx
80103668:	75 02                	jne    8010366c <log_write+0x67>
      break;
8010366a:	eb 0e                	jmp    8010367a <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010366c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103670:	a1 84 f9 10 80       	mov    0x8010f984,%eax
80103675:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103678:	7f d7                	jg     80103651 <log_write+0x4c>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
  }
  log.lh.sector[i] = b->sector;
8010367a:	8b 45 08             	mov    0x8(%ebp),%eax
8010367d:	8b 40 08             	mov    0x8(%eax),%eax
80103680:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103683:	83 c2 10             	add    $0x10,%edx
80103686:	89 04 95 48 f9 10 80 	mov    %eax,-0x7fef06b8(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010368d:	8b 15 74 f9 10 80    	mov    0x8010f974,%edx
80103693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103696:	01 d0                	add    %edx,%eax
80103698:	83 c0 01             	add    $0x1,%eax
8010369b:	89 c2                	mov    %eax,%edx
8010369d:	8b 45 08             	mov    0x8(%ebp),%eax
801036a0:	8b 40 04             	mov    0x4(%eax),%eax
801036a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801036a7:	89 04 24             	mov    %eax,(%esp)
801036aa:	e8 f7 ca ff ff       	call   801001a6 <bread>
801036af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036b2:	8b 45 08             	mov    0x8(%ebp),%eax
801036b5:	8d 50 18             	lea    0x18(%eax),%edx
801036b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036bb:	83 c0 18             	add    $0x18,%eax
801036be:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036c5:	00 
801036c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801036ca:	89 04 24             	mov    %eax,(%esp)
801036cd:	e8 00 1b 00 00       	call   801051d2 <memmove>
  bwrite(lbuf);
801036d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d5:	89 04 24             	mov    %eax,(%esp)
801036d8:	e8 00 cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e0:	89 04 24             	mov    %eax,(%esp)
801036e3:	e8 2f cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036e8:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801036ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036f0:	75 0d                	jne    801036ff <log_write+0xfa>
    log.lh.n++;
801036f2:	a1 84 f9 10 80       	mov    0x8010f984,%eax
801036f7:	83 c0 01             	add    $0x1,%eax
801036fa:	a3 84 f9 10 80       	mov    %eax,0x8010f984
  b->flags |= B_DIRTY; // XXX prevent eviction
801036ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103702:	8b 00                	mov    (%eax),%eax
80103704:	83 c8 04             	or     $0x4,%eax
80103707:	89 c2                	mov    %eax,%edx
80103709:	8b 45 08             	mov    0x8(%ebp),%eax
8010370c:	89 10                	mov    %edx,(%eax)
}
8010370e:	c9                   	leave  
8010370f:	c3                   	ret    

80103710 <v2p>:
80103710:	55                   	push   %ebp
80103711:	89 e5                	mov    %esp,%ebp
80103713:	8b 45 08             	mov    0x8(%ebp),%eax
80103716:	05 00 00 00 80       	add    $0x80000000,%eax
8010371b:	5d                   	pop    %ebp
8010371c:	c3                   	ret    

8010371d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010371d:	55                   	push   %ebp
8010371e:	89 e5                	mov    %esp,%ebp
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	05 00 00 00 80       	add    $0x80000000,%eax
80103728:	5d                   	pop    %ebp
80103729:	c3                   	ret    

8010372a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103730:	8b 55 08             	mov    0x8(%ebp),%edx
80103733:	8b 45 0c             	mov    0xc(%ebp),%eax
80103736:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103739:	f0 87 02             	lock xchg %eax,(%edx)
8010373c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010373f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103742:	c9                   	leave  
80103743:	c3                   	ret    

80103744 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103744:	55                   	push   %ebp
80103745:	89 e5                	mov    %esp,%ebp
80103747:	83 e4 f0             	and    $0xfffffff0,%esp
8010374a:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010374d:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103754:	80 
80103755:	c7 04 24 bc 27 11 80 	movl   $0x801127bc,(%esp)
8010375c:	e8 d2 f5 ff ff       	call   80102d33 <kinit1>
  kvmalloc();      // kernel page table
80103761:	e8 d4 46 00 00       	call   80107e3a <kvmalloc>
  mpinit();        // collect info about this machine
80103766:	e8 56 04 00 00       	call   80103bc1 <mpinit>
  lapicinit(mpbcpu());
8010376b:	e8 1f 02 00 00       	call   8010398f <mpbcpu>
80103770:	89 04 24             	mov    %eax,(%esp)
80103773:	e8 09 f9 ff ff       	call   80103081 <lapicinit>
  seginit();       // set up segments
80103778:	e8 50 40 00 00       	call   801077cd <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010377d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103783:	0f b6 00             	movzbl (%eax),%eax
80103786:	0f b6 c0             	movzbl %al,%eax
80103789:	89 44 24 04          	mov    %eax,0x4(%esp)
8010378d:	c7 04 24 49 88 10 80 	movl   $0x80108849,(%esp)
80103794:	e8 07 cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103799:	e8 81 06 00 00       	call   80103e1f <picinit>
  ioapicinit();    // another interrupt controller
8010379e:	e8 86 f4 ff ff       	call   80102c29 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037a3:	e8 d9 d2 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
801037a8:	e8 6f 33 00 00       	call   80106b1c <uartinit>
  pinit();         // process table
801037ad:	e8 77 0b 00 00       	call   80104329 <pinit>
  tvinit();        // trap vectors
801037b2:	e8 17 2f 00 00       	call   801066ce <tvinit>
  binit();         // buffer cache
801037b7:	e8 78 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037bc:	e8 3c d7 ff ff       	call   80100efd <fileinit>
  iinit();         // inode cache
801037c1:	e8 d1 dd ff ff       	call   80101597 <iinit>
  ideinit();       // disk
801037c6:	e8 c7 f0 ff ff       	call   80102892 <ideinit>
  if(!ismp)
801037cb:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
801037d0:	85 c0                	test   %eax,%eax
801037d2:	75 05                	jne    801037d9 <main+0x95>
    timerinit();   // uniprocessor timer
801037d4:	e8 40 2e 00 00       	call   80106619 <timerinit>
  startothers();   // start other processors
801037d9:	e8 87 00 00 00       	call   80103865 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037de:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037e5:	8e 
801037e6:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037ed:	e8 79 f5 ff ff       	call   80102d6b <kinit2>
  userinit();      // first user process
801037f2:	e8 4d 0c 00 00       	call   80104444 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037f7:	e8 22 00 00 00       	call   8010381e <mpmain>

801037fc <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037fc:	55                   	push   %ebp
801037fd:	89 e5                	mov    %esp,%ebp
801037ff:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103802:	e8 4a 46 00 00       	call   80107e51 <switchkvm>
  seginit();
80103807:	e8 c1 3f 00 00       	call   801077cd <seginit>
  lapicinit(cpunum());
8010380c:	e8 c9 f9 ff ff       	call   801031da <cpunum>
80103811:	89 04 24             	mov    %eax,(%esp)
80103814:	e8 68 f8 ff ff       	call   80103081 <lapicinit>
  mpmain();
80103819:	e8 00 00 00 00       	call   8010381e <mpmain>

8010381e <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010381e:	55                   	push   %ebp
8010381f:	89 e5                	mov    %esp,%ebp
80103821:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103824:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010382a:	0f b6 00             	movzbl (%eax),%eax
8010382d:	0f b6 c0             	movzbl %al,%eax
80103830:	89 44 24 04          	mov    %eax,0x4(%esp)
80103834:	c7 04 24 60 88 10 80 	movl   $0x80108860,(%esp)
8010383b:	e8 60 cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103840:	e8 fd 2f 00 00       	call   80106842 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103845:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010384b:	05 a8 00 00 00       	add    $0xa8,%eax
80103850:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103857:	00 
80103858:	89 04 24             	mov    %eax,(%esp)
8010385b:	e8 ca fe ff ff       	call   8010372a <xchg>
  scheduler();     // start running processes
80103860:	e8 d8 11 00 00       	call   80104a3d <scheduler>

80103865 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103865:	55                   	push   %ebp
80103866:	89 e5                	mov    %esp,%ebp
80103868:	53                   	push   %ebx
80103869:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010386c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103873:	e8 a5 fe ff ff       	call   8010371d <p2v>
80103878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010387b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103880:	89 44 24 08          	mov    %eax,0x8(%esp)
80103884:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010388b:	80 
8010388c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388f:	89 04 24             	mov    %eax,(%esp)
80103892:	e8 3b 19 00 00       	call   801051d2 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103897:	c7 45 f4 e0 f9 10 80 	movl   $0x8010f9e0,-0xc(%ebp)
8010389e:	e9 85 00 00 00       	jmp    80103928 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
801038a3:	e8 32 f9 ff ff       	call   801031da <cpunum>
801038a8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038ae:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
801038b3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b6:	75 02                	jne    801038ba <startothers+0x55>
      continue;
801038b8:	eb 67                	jmp    80103921 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038ba:	e8 a2 f5 ff ff       	call   80102e61 <kalloc>
801038bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c5:	83 e8 04             	sub    $0x4,%eax
801038c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038cb:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038d1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d6:	83 e8 08             	sub    $0x8,%eax
801038d9:	c7 00 fc 37 10 80    	movl   $0x801037fc,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038e2:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038e5:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038ec:	e8 1f fe ff ff       	call   80103710 <v2p>
801038f1:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f6:	89 04 24             	mov    %eax,(%esp)
801038f9:	e8 12 fe ff ff       	call   80103710 <v2p>
801038fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103901:	0f b6 12             	movzbl (%edx),%edx
80103904:	0f b6 d2             	movzbl %dl,%edx
80103907:	89 44 24 04          	mov    %eax,0x4(%esp)
8010390b:	89 14 24             	mov    %edx,(%esp)
8010390e:	e8 49 f9 ff ff       	call   8010325c <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103913:	90                   	nop
80103914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103917:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010391d:	85 c0                	test   %eax,%eax
8010391f:	74 f3                	je     80103914 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103921:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103928:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
8010392d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103933:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
80103938:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010393b:	0f 87 62 ff ff ff    	ja     801038a3 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103941:	83 c4 24             	add    $0x24,%esp
80103944:	5b                   	pop    %ebx
80103945:	5d                   	pop    %ebp
80103946:	c3                   	ret    

80103947 <p2v>:
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	8b 45 08             	mov    0x8(%ebp),%eax
8010394d:	05 00 00 00 80       	add    $0x80000000,%eax
80103952:	5d                   	pop    %ebp
80103953:	c3                   	ret    

80103954 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103954:	55                   	push   %ebp
80103955:	89 e5                	mov    %esp,%ebp
80103957:	83 ec 14             	sub    $0x14,%esp
8010395a:	8b 45 08             	mov    0x8(%ebp),%eax
8010395d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103961:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103965:	89 c2                	mov    %eax,%edx
80103967:	ec                   	in     (%dx),%al
80103968:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010396b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010396f:	c9                   	leave  
80103970:	c3                   	ret    

80103971 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103971:	55                   	push   %ebp
80103972:	89 e5                	mov    %esp,%ebp
80103974:	83 ec 08             	sub    $0x8,%esp
80103977:	8b 55 08             	mov    0x8(%ebp),%edx
8010397a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010397d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103981:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103984:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103988:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010398c:	ee                   	out    %al,(%dx)
}
8010398d:	c9                   	leave  
8010398e:	c3                   	ret    

8010398f <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010398f:	55                   	push   %ebp
80103990:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103992:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103997:	89 c2                	mov    %eax,%edx
80103999:	b8 e0 f9 10 80       	mov    $0x8010f9e0,%eax
8010399e:	29 c2                	sub    %eax,%edx
801039a0:	89 d0                	mov    %edx,%eax
801039a2:	c1 f8 02             	sar    $0x2,%eax
801039a5:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039ab:	5d                   	pop    %ebp
801039ac:	c3                   	ret    

801039ad <sum>:

static uchar
sum(uchar *addr, int len)
{
801039ad:	55                   	push   %ebp
801039ae:	89 e5                	mov    %esp,%ebp
801039b0:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039b3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039c1:	eb 15                	jmp    801039d8 <sum+0x2b>
    sum += addr[i];
801039c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039c6:	8b 45 08             	mov    0x8(%ebp),%eax
801039c9:	01 d0                	add    %edx,%eax
801039cb:	0f b6 00             	movzbl (%eax),%eax
801039ce:	0f b6 c0             	movzbl %al,%eax
801039d1:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039d4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039db:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039de:	7c e3                	jl     801039c3 <sum+0x16>
    sum += addr[i];
  return sum;
801039e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039e3:	c9                   	leave  
801039e4:	c3                   	ret    

801039e5 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039e5:	55                   	push   %ebp
801039e6:	89 e5                	mov    %esp,%ebp
801039e8:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039eb:	8b 45 08             	mov    0x8(%ebp),%eax
801039ee:	89 04 24             	mov    %eax,(%esp)
801039f1:	e8 51 ff ff ff       	call   80103947 <p2v>
801039f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801039fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ff:	01 d0                	add    %edx,%eax
80103a01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a0a:	eb 3f                	jmp    80103a4b <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a0c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a13:	00 
80103a14:	c7 44 24 04 74 88 10 	movl   $0x80108874,0x4(%esp)
80103a1b:	80 
80103a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1f:	89 04 24             	mov    %eax,(%esp)
80103a22:	e8 53 17 00 00       	call   8010517a <memcmp>
80103a27:	85 c0                	test   %eax,%eax
80103a29:	75 1c                	jne    80103a47 <mpsearch1+0x62>
80103a2b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a32:	00 
80103a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a36:	89 04 24             	mov    %eax,(%esp)
80103a39:	e8 6f ff ff ff       	call   801039ad <sum>
80103a3e:	84 c0                	test   %al,%al
80103a40:	75 05                	jne    80103a47 <mpsearch1+0x62>
      return (struct mp*)p;
80103a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a45:	eb 11                	jmp    80103a58 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a47:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a51:	72 b9                	jb     80103a0c <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a58:	c9                   	leave  
80103a59:	c3                   	ret    

80103a5a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a5a:	55                   	push   %ebp
80103a5b:	89 e5                	mov    %esp,%ebp
80103a5d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a60:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6a:	83 c0 0f             	add    $0xf,%eax
80103a6d:	0f b6 00             	movzbl (%eax),%eax
80103a70:	0f b6 c0             	movzbl %al,%eax
80103a73:	c1 e0 08             	shl    $0x8,%eax
80103a76:	89 c2                	mov    %eax,%edx
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	83 c0 0e             	add    $0xe,%eax
80103a7e:	0f b6 00             	movzbl (%eax),%eax
80103a81:	0f b6 c0             	movzbl %al,%eax
80103a84:	09 d0                	or     %edx,%eax
80103a86:	c1 e0 04             	shl    $0x4,%eax
80103a89:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a90:	74 21                	je     80103ab3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a92:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a99:	00 
80103a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9d:	89 04 24             	mov    %eax,(%esp)
80103aa0:	e8 40 ff ff ff       	call   801039e5 <mpsearch1>
80103aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103aa8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aac:	74 50                	je     80103afe <mpsearch+0xa4>
      return mp;
80103aae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ab1:	eb 5f                	jmp    80103b12 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab6:	83 c0 14             	add    $0x14,%eax
80103ab9:	0f b6 00             	movzbl (%eax),%eax
80103abc:	0f b6 c0             	movzbl %al,%eax
80103abf:	c1 e0 08             	shl    $0x8,%eax
80103ac2:	89 c2                	mov    %eax,%edx
80103ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac7:	83 c0 13             	add    $0x13,%eax
80103aca:	0f b6 00             	movzbl (%eax),%eax
80103acd:	0f b6 c0             	movzbl %al,%eax
80103ad0:	09 d0                	or     %edx,%eax
80103ad2:	c1 e0 0a             	shl    $0xa,%eax
80103ad5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103adb:	2d 00 04 00 00       	sub    $0x400,%eax
80103ae0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ae7:	00 
80103ae8:	89 04 24             	mov    %eax,(%esp)
80103aeb:	e8 f5 fe ff ff       	call   801039e5 <mpsearch1>
80103af0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103af3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103af7:	74 05                	je     80103afe <mpsearch+0xa4>
      return mp;
80103af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103afc:	eb 14                	jmp    80103b12 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103afe:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b05:	00 
80103b06:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b0d:	e8 d3 fe ff ff       	call   801039e5 <mpsearch1>
}
80103b12:	c9                   	leave  
80103b13:	c3                   	ret    

80103b14 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b14:	55                   	push   %ebp
80103b15:	89 e5                	mov    %esp,%ebp
80103b17:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b1a:	e8 3b ff ff ff       	call   80103a5a <mpsearch>
80103b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b26:	74 0a                	je     80103b32 <mpconfig+0x1e>
80103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2b:	8b 40 04             	mov    0x4(%eax),%eax
80103b2e:	85 c0                	test   %eax,%eax
80103b30:	75 0a                	jne    80103b3c <mpconfig+0x28>
    return 0;
80103b32:	b8 00 00 00 00       	mov    $0x0,%eax
80103b37:	e9 83 00 00 00       	jmp    80103bbf <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3f:	8b 40 04             	mov    0x4(%eax),%eax
80103b42:	89 04 24             	mov    %eax,(%esp)
80103b45:	e8 fd fd ff ff       	call   80103947 <p2v>
80103b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b4d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b54:	00 
80103b55:	c7 44 24 04 79 88 10 	movl   $0x80108879,0x4(%esp)
80103b5c:	80 
80103b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b60:	89 04 24             	mov    %eax,(%esp)
80103b63:	e8 12 16 00 00       	call   8010517a <memcmp>
80103b68:	85 c0                	test   %eax,%eax
80103b6a:	74 07                	je     80103b73 <mpconfig+0x5f>
    return 0;
80103b6c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b71:	eb 4c                	jmp    80103bbf <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b76:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b7a:	3c 01                	cmp    $0x1,%al
80103b7c:	74 12                	je     80103b90 <mpconfig+0x7c>
80103b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b81:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b85:	3c 04                	cmp    $0x4,%al
80103b87:	74 07                	je     80103b90 <mpconfig+0x7c>
    return 0;
80103b89:	b8 00 00 00 00       	mov    $0x0,%eax
80103b8e:	eb 2f                	jmp    80103bbf <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b93:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b97:	0f b7 c0             	movzwl %ax,%eax
80103b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba1:	89 04 24             	mov    %eax,(%esp)
80103ba4:	e8 04 fe ff ff       	call   801039ad <sum>
80103ba9:	84 c0                	test   %al,%al
80103bab:	74 07                	je     80103bb4 <mpconfig+0xa0>
    return 0;
80103bad:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb2:	eb 0b                	jmp    80103bbf <mpconfig+0xab>
  *pmp = mp;
80103bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bba:	89 10                	mov    %edx,(%eax)
  return conf;
80103bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bbf:	c9                   	leave  
80103bc0:	c3                   	ret    

80103bc1 <mpinit>:

void
mpinit(void)
{
80103bc1:	55                   	push   %ebp
80103bc2:	89 e5                	mov    %esp,%ebp
80103bc4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bc7:	c7 05 44 b6 10 80 e0 	movl   $0x8010f9e0,0x8010b644
80103bce:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bd1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bd4:	89 04 24             	mov    %eax,(%esp)
80103bd7:	e8 38 ff ff ff       	call   80103b14 <mpconfig>
80103bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bdf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103be3:	75 05                	jne    80103bea <mpinit+0x29>
    return;
80103be5:	e9 9c 01 00 00       	jmp    80103d86 <mpinit+0x1c5>
  ismp = 1;
80103bea:	c7 05 c4 f9 10 80 01 	movl   $0x1,0x8010f9c4
80103bf1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf7:	8b 40 24             	mov    0x24(%eax),%eax
80103bfa:	a3 3c f9 10 80       	mov    %eax,0x8010f93c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c02:	83 c0 2c             	add    $0x2c,%eax
80103c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c0f:	0f b7 d0             	movzwl %ax,%edx
80103c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c15:	01 d0                	add    %edx,%eax
80103c17:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1a:	e9 f4 00 00 00       	jmp    80103d13 <mpinit+0x152>
    switch(*p){
80103c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c22:	0f b6 00             	movzbl (%eax),%eax
80103c25:	0f b6 c0             	movzbl %al,%eax
80103c28:	83 f8 04             	cmp    $0x4,%eax
80103c2b:	0f 87 bf 00 00 00    	ja     80103cf0 <mpinit+0x12f>
80103c31:	8b 04 85 bc 88 10 80 	mov    -0x7fef7744(,%eax,4),%eax
80103c38:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c43:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c47:	0f b6 d0             	movzbl %al,%edx
80103c4a:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103c4f:	39 c2                	cmp    %eax,%edx
80103c51:	74 2d                	je     80103c80 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c56:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c5a:	0f b6 d0             	movzbl %al,%edx
80103c5d:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103c62:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c66:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c6a:	c7 04 24 7e 88 10 80 	movl   $0x8010887e,(%esp)
80103c71:	e8 2a c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c76:	c7 05 c4 f9 10 80 00 	movl   $0x0,0x8010f9c4
80103c7d:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c83:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c87:	0f b6 c0             	movzbl %al,%eax
80103c8a:	83 e0 02             	and    $0x2,%eax
80103c8d:	85 c0                	test   %eax,%eax
80103c8f:	74 15                	je     80103ca6 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c91:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103c96:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c9c:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
80103ca1:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103ca6:	8b 15 c0 ff 10 80    	mov    0x8010ffc0,%edx
80103cac:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103cb1:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cb7:	81 c2 e0 f9 10 80    	add    $0x8010f9e0,%edx
80103cbd:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cbf:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80103cc4:	83 c0 01             	add    $0x1,%eax
80103cc7:	a3 c0 ff 10 80       	mov    %eax,0x8010ffc0
      p += sizeof(struct mpproc);
80103ccc:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cd0:	eb 41                	jmp    80103d13 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cdb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cdf:	a2 c0 f9 10 80       	mov    %al,0x8010f9c0
      p += sizeof(struct mpioapic);
80103ce4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ce8:	eb 29                	jmp    80103d13 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cea:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cee:	eb 23                	jmp    80103d13 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf3:	0f b6 00             	movzbl (%eax),%eax
80103cf6:	0f b6 c0             	movzbl %al,%eax
80103cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cfd:	c7 04 24 9c 88 10 80 	movl   $0x8010889c,(%esp)
80103d04:	e8 97 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103d09:	c7 05 c4 f9 10 80 00 	movl   $0x0,0x8010f9c4
80103d10:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d16:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d19:	0f 82 00 ff ff ff    	jb     80103c1f <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d1f:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
80103d24:	85 c0                	test   %eax,%eax
80103d26:	75 1d                	jne    80103d45 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d28:	c7 05 c0 ff 10 80 01 	movl   $0x1,0x8010ffc0
80103d2f:	00 00 00 
    lapic = 0;
80103d32:	c7 05 3c f9 10 80 00 	movl   $0x0,0x8010f93c
80103d39:	00 00 00 
    ioapicid = 0;
80103d3c:	c6 05 c0 f9 10 80 00 	movb   $0x0,0x8010f9c0
    return;
80103d43:	eb 41                	jmp    80103d86 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d48:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d4c:	84 c0                	test   %al,%al
80103d4e:	74 36                	je     80103d86 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d50:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d57:	00 
80103d58:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d5f:	e8 0d fc ff ff       	call   80103971 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d64:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d6b:	e8 e4 fb ff ff       	call   80103954 <inb>
80103d70:	83 c8 01             	or     $0x1,%eax
80103d73:	0f b6 c0             	movzbl %al,%eax
80103d76:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d7a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d81:	e8 eb fb ff ff       	call   80103971 <outb>
  }
}
80103d86:	c9                   	leave  
80103d87:	c3                   	ret    

80103d88 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d88:	55                   	push   %ebp
80103d89:	89 e5                	mov    %esp,%ebp
80103d8b:	83 ec 08             	sub    $0x8,%esp
80103d8e:	8b 55 08             	mov    0x8(%ebp),%edx
80103d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d94:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d98:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d9b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d9f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103da3:	ee                   	out    %al,(%dx)
}
80103da4:	c9                   	leave  
80103da5:	c3                   	ret    

80103da6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103da6:	55                   	push   %ebp
80103da7:	89 e5                	mov    %esp,%ebp
80103da9:	83 ec 0c             	sub    $0xc,%esp
80103dac:	8b 45 08             	mov    0x8(%ebp),%eax
80103daf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103db3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103db7:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103dbd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dc1:	0f b6 c0             	movzbl %al,%eax
80103dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dcf:	e8 b4 ff ff ff       	call   80103d88 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103dd4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dd8:	66 c1 e8 08          	shr    $0x8,%ax
80103ddc:	0f b6 c0             	movzbl %al,%eax
80103ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
80103de3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dea:	e8 99 ff ff ff       	call   80103d88 <outb>
}
80103def:	c9                   	leave  
80103df0:	c3                   	ret    

80103df1 <picenable>:

void
picenable(int irq)
{
80103df1:	55                   	push   %ebp
80103df2:	89 e5                	mov    %esp,%ebp
80103df4:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103df7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfa:	ba 01 00 00 00       	mov    $0x1,%edx
80103dff:	89 c1                	mov    %eax,%ecx
80103e01:	d3 e2                	shl    %cl,%edx
80103e03:	89 d0                	mov    %edx,%eax
80103e05:	f7 d0                	not    %eax
80103e07:	89 c2                	mov    %eax,%edx
80103e09:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e10:	21 d0                	and    %edx,%eax
80103e12:	0f b7 c0             	movzwl %ax,%eax
80103e15:	89 04 24             	mov    %eax,(%esp)
80103e18:	e8 89 ff ff ff       	call   80103da6 <picsetmask>
}
80103e1d:	c9                   	leave  
80103e1e:	c3                   	ret    

80103e1f <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e1f:	55                   	push   %ebp
80103e20:	89 e5                	mov    %esp,%ebp
80103e22:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e25:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e2c:	00 
80103e2d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e34:	e8 4f ff ff ff       	call   80103d88 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e39:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e40:	00 
80103e41:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e48:	e8 3b ff ff ff       	call   80103d88 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e4d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e54:	00 
80103e55:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e5c:	e8 27 ff ff ff       	call   80103d88 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e61:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e68:	00 
80103e69:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e70:	e8 13 ff ff ff       	call   80103d88 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e75:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e7c:	00 
80103e7d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e84:	e8 ff fe ff ff       	call   80103d88 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e89:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e90:	00 
80103e91:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e98:	e8 eb fe ff ff       	call   80103d88 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e9d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ea4:	00 
80103ea5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eac:	e8 d7 fe ff ff       	call   80103d88 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103eb1:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103eb8:	00 
80103eb9:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ec0:	e8 c3 fe ff ff       	call   80103d88 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ec5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ecc:	00 
80103ecd:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ed4:	e8 af fe ff ff       	call   80103d88 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ed9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ee0:	00 
80103ee1:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ee8:	e8 9b fe ff ff       	call   80103d88 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103eed:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ef4:	00 
80103ef5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103efc:	e8 87 fe ff ff       	call   80103d88 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f01:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f08:	00 
80103f09:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f10:	e8 73 fe ff ff       	call   80103d88 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f15:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f1c:	00 
80103f1d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f24:	e8 5f fe ff ff       	call   80103d88 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f29:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f30:	00 
80103f31:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f38:	e8 4b fe ff ff       	call   80103d88 <outb>

  if(irqmask != 0xFFFF)
80103f3d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f44:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f48:	74 12                	je     80103f5c <picinit+0x13d>
    picsetmask(irqmask);
80103f4a:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f51:	0f b7 c0             	movzwl %ax,%eax
80103f54:	89 04 24             	mov    %eax,(%esp)
80103f57:	e8 4a fe ff ff       	call   80103da6 <picsetmask>
}
80103f5c:	c9                   	leave  
80103f5d:	c3                   	ret    

80103f5e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f5e:	55                   	push   %ebp
80103f5f:	89 e5                	mov    %esp,%ebp
80103f61:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f74:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f77:	8b 10                	mov    (%eax),%edx
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f7e:	e8 96 cf ff ff       	call   80100f19 <filealloc>
80103f83:	8b 55 08             	mov    0x8(%ebp),%edx
80103f86:	89 02                	mov    %eax,(%edx)
80103f88:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8b:	8b 00                	mov    (%eax),%eax
80103f8d:	85 c0                	test   %eax,%eax
80103f8f:	0f 84 c8 00 00 00    	je     8010405d <pipealloc+0xff>
80103f95:	e8 7f cf ff ff       	call   80100f19 <filealloc>
80103f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f9d:	89 02                	mov    %eax,(%edx)
80103f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa2:	8b 00                	mov    (%eax),%eax
80103fa4:	85 c0                	test   %eax,%eax
80103fa6:	0f 84 b1 00 00 00    	je     8010405d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fac:	e8 b0 ee ff ff       	call   80102e61 <kalloc>
80103fb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fb4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fb8:	75 05                	jne    80103fbf <pipealloc+0x61>
    goto bad;
80103fba:	e9 9e 00 00 00       	jmp    8010405d <pipealloc+0xff>
  p->readopen = 1;
80103fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fc9:	00 00 00 
  p->writeopen = 1;
80103fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fd6:	00 00 00 
  p->nwrite = 0;
80103fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fe3:	00 00 00 
  p->nread = 0;
80103fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ff0:	00 00 00 
  initlock(&p->lock, "pipe");
80103ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff6:	c7 44 24 04 d0 88 10 	movl   $0x801088d0,0x4(%esp)
80103ffd:	80 
80103ffe:	89 04 24             	mov    %eax,(%esp)
80104001:	e8 88 0e 00 00       	call   80104e8e <initlock>
  (*f0)->type = FD_PIPE;
80104006:	8b 45 08             	mov    0x8(%ebp),%eax
80104009:	8b 00                	mov    (%eax),%eax
8010400b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104011:	8b 45 08             	mov    0x8(%ebp),%eax
80104014:	8b 00                	mov    (%eax),%eax
80104016:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010401a:	8b 45 08             	mov    0x8(%ebp),%eax
8010401d:	8b 00                	mov    (%eax),%eax
8010401f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104023:	8b 45 08             	mov    0x8(%ebp),%eax
80104026:	8b 00                	mov    (%eax),%eax
80104028:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010402b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010402e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104031:	8b 00                	mov    (%eax),%eax
80104033:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403c:	8b 00                	mov    (%eax),%eax
8010403e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104042:	8b 45 0c             	mov    0xc(%ebp),%eax
80104045:	8b 00                	mov    (%eax),%eax
80104047:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010404b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404e:	8b 00                	mov    (%eax),%eax
80104050:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104053:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104056:	b8 00 00 00 00       	mov    $0x0,%eax
8010405b:	eb 42                	jmp    8010409f <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010405d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104061:	74 0b                	je     8010406e <pipealloc+0x110>
    kfree((char*)p);
80104063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104066:	89 04 24             	mov    %eax,(%esp)
80104069:	e8 5a ed ff ff       	call   80102dc8 <kfree>
  if(*f0)
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	85 c0                	test   %eax,%eax
80104075:	74 0d                	je     80104084 <pipealloc+0x126>
    fileclose(*f0);
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	89 04 24             	mov    %eax,(%esp)
8010407f:	e8 3d cf ff ff       	call   80100fc1 <fileclose>
  if(*f1)
80104084:	8b 45 0c             	mov    0xc(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	85 c0                	test   %eax,%eax
8010408b:	74 0d                	je     8010409a <pipealloc+0x13c>
    fileclose(*f1);
8010408d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	89 04 24             	mov    %eax,(%esp)
80104095:	e8 27 cf ff ff       	call   80100fc1 <fileclose>
  return -1;
8010409a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010409f:	c9                   	leave  
801040a0:	c3                   	ret    

801040a1 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040a1:	55                   	push   %ebp
801040a2:	89 e5                	mov    %esp,%ebp
801040a4:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	89 04 24             	mov    %eax,(%esp)
801040ad:	e8 fd 0d 00 00       	call   80104eaf <acquire>
  if(writable){
801040b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040b6:	74 1f                	je     801040d7 <pipeclose+0x36>
    p->writeopen = 0;
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040c2:	00 00 00 
    wakeup(&p->nread);
801040c5:	8b 45 08             	mov    0x8(%ebp),%eax
801040c8:	05 34 02 00 00       	add    $0x234,%eax
801040cd:	89 04 24             	mov    %eax,(%esp)
801040d0:	e8 e9 0b 00 00       	call   80104cbe <wakeup>
801040d5:	eb 1d                	jmp    801040f4 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040d7:	8b 45 08             	mov    0x8(%ebp),%eax
801040da:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040e1:	00 00 00 
    wakeup(&p->nwrite);
801040e4:	8b 45 08             	mov    0x8(%ebp),%eax
801040e7:	05 38 02 00 00       	add    $0x238,%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 ca 0b 00 00       	call   80104cbe <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040f4:	8b 45 08             	mov    0x8(%ebp),%eax
801040f7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040fd:	85 c0                	test   %eax,%eax
801040ff:	75 25                	jne    80104126 <pipeclose+0x85>
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010410a:	85 c0                	test   %eax,%eax
8010410c:	75 18                	jne    80104126 <pipeclose+0x85>
    release(&p->lock);
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	89 04 24             	mov    %eax,(%esp)
80104114:	e8 f8 0d 00 00       	call   80104f11 <release>
    kfree((char*)p);
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	89 04 24             	mov    %eax,(%esp)
8010411f:	e8 a4 ec ff ff       	call   80102dc8 <kfree>
80104124:	eb 0b                	jmp    80104131 <pipeclose+0x90>
  } else
    release(&p->lock);
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	89 04 24             	mov    %eax,(%esp)
8010412c:	e8 e0 0d 00 00       	call   80104f11 <release>
}
80104131:	c9                   	leave  
80104132:	c3                   	ret    

80104133 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104133:	55                   	push   %ebp
80104134:	89 e5                	mov    %esp,%ebp
80104136:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104139:	8b 45 08             	mov    0x8(%ebp),%eax
8010413c:	89 04 24             	mov    %eax,(%esp)
8010413f:	e8 6b 0d 00 00       	call   80104eaf <acquire>
  for(i = 0; i < n; i++){
80104144:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010414b:	e9 a6 00 00 00       	jmp    801041f6 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104150:	eb 57                	jmp    801041a9 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104152:	8b 45 08             	mov    0x8(%ebp),%eax
80104155:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010415b:	85 c0                	test   %eax,%eax
8010415d:	74 0d                	je     8010416c <pipewrite+0x39>
8010415f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104165:	8b 40 24             	mov    0x24(%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	74 15                	je     80104181 <pipewrite+0x4e>
        release(&p->lock);
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	89 04 24             	mov    %eax,(%esp)
80104172:	e8 9a 0d 00 00       	call   80104f11 <release>
        return -1;
80104177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010417c:	e9 9f 00 00 00       	jmp    80104220 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104181:	8b 45 08             	mov    0x8(%ebp),%eax
80104184:	05 34 02 00 00       	add    $0x234,%eax
80104189:	89 04 24             	mov    %eax,(%esp)
8010418c:	e8 2d 0b 00 00       	call   80104cbe <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104191:	8b 45 08             	mov    0x8(%ebp),%eax
80104194:	8b 55 08             	mov    0x8(%ebp),%edx
80104197:	81 c2 38 02 00 00    	add    $0x238,%edx
8010419d:	89 44 24 04          	mov    %eax,0x4(%esp)
801041a1:	89 14 24             	mov    %edx,(%esp)
801041a4:	e8 3c 0a 00 00       	call   80104be5 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041bb:	05 00 02 00 00       	add    $0x200,%eax
801041c0:	39 c2                	cmp    %eax,%edx
801041c2:	74 8e                	je     80104152 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041c4:	8b 45 08             	mov    0x8(%ebp),%eax
801041c7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041cd:	8d 48 01             	lea    0x1(%eax),%ecx
801041d0:	8b 55 08             	mov    0x8(%ebp),%edx
801041d3:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041d9:	25 ff 01 00 00       	and    $0x1ff,%eax
801041de:	89 c1                	mov    %eax,%ecx
801041e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e6:	01 d0                	add    %edx,%eax
801041e8:	0f b6 10             	movzbl (%eax),%edx
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f9:	3b 45 10             	cmp    0x10(%ebp),%eax
801041fc:	0f 8c 4e ff ff ff    	jl     80104150 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104202:	8b 45 08             	mov    0x8(%ebp),%eax
80104205:	05 34 02 00 00       	add    $0x234,%eax
8010420a:	89 04 24             	mov    %eax,(%esp)
8010420d:	e8 ac 0a 00 00       	call   80104cbe <wakeup>
  release(&p->lock);
80104212:	8b 45 08             	mov    0x8(%ebp),%eax
80104215:	89 04 24             	mov    %eax,(%esp)
80104218:	e8 f4 0c 00 00       	call   80104f11 <release>
  return n;
8010421d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104220:	c9                   	leave  
80104221:	c3                   	ret    

80104222 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104222:	55                   	push   %ebp
80104223:	89 e5                	mov    %esp,%ebp
80104225:	53                   	push   %ebx
80104226:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	89 04 24             	mov    %eax,(%esp)
8010422f:	e8 7b 0c 00 00       	call   80104eaf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104234:	eb 3a                	jmp    80104270 <piperead+0x4e>
    if(proc->killed){
80104236:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010423c:	8b 40 24             	mov    0x24(%eax),%eax
8010423f:	85 c0                	test   %eax,%eax
80104241:	74 15                	je     80104258 <piperead+0x36>
      release(&p->lock);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	89 04 24             	mov    %eax,(%esp)
80104249:	e8 c3 0c 00 00       	call   80104f11 <release>
      return -1;
8010424e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104253:	e9 b5 00 00 00       	jmp    8010430d <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	8b 55 08             	mov    0x8(%ebp),%edx
8010425e:	81 c2 34 02 00 00    	add    $0x234,%edx
80104264:	89 44 24 04          	mov    %eax,0x4(%esp)
80104268:	89 14 24             	mov    %edx,(%esp)
8010426b:	e8 75 09 00 00       	call   80104be5 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104270:	8b 45 08             	mov    0x8(%ebp),%eax
80104273:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104282:	39 c2                	cmp    %eax,%edx
80104284:	75 0d                	jne    80104293 <piperead+0x71>
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010428f:	85 c0                	test   %eax,%eax
80104291:	75 a3                	jne    80104236 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010429a:	eb 4b                	jmp    801042e7 <piperead+0xc5>
    if(p->nread == p->nwrite)
8010429c:	8b 45 08             	mov    0x8(%ebp),%eax
8010429f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042a5:	8b 45 08             	mov    0x8(%ebp),%eax
801042a8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042ae:	39 c2                	cmp    %eax,%edx
801042b0:	75 02                	jne    801042b4 <piperead+0x92>
      break;
801042b2:	eb 3b                	jmp    801042ef <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ba:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042bd:	8b 45 08             	mov    0x8(%ebp),%eax
801042c0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042c6:	8d 48 01             	lea    0x1(%eax),%ecx
801042c9:	8b 55 08             	mov    0x8(%ebp),%edx
801042cc:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042d2:	25 ff 01 00 00       	and    $0x1ff,%eax
801042d7:	89 c2                	mov    %eax,%edx
801042d9:	8b 45 08             	mov    0x8(%ebp),%eax
801042dc:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042e1:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801042ed:	7c ad                	jl     8010429c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042ef:	8b 45 08             	mov    0x8(%ebp),%eax
801042f2:	05 38 02 00 00       	add    $0x238,%eax
801042f7:	89 04 24             	mov    %eax,(%esp)
801042fa:	e8 bf 09 00 00       	call   80104cbe <wakeup>
  release(&p->lock);
801042ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104302:	89 04 24             	mov    %eax,(%esp)
80104305:	e8 07 0c 00 00       	call   80104f11 <release>
  return i;
8010430a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010430d:	83 c4 24             	add    $0x24,%esp
80104310:	5b                   	pop    %ebx
80104311:	5d                   	pop    %ebp
80104312:	c3                   	ret    

80104313 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104313:	55                   	push   %ebp
80104314:	89 e5                	mov    %esp,%ebp
80104316:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104319:	9c                   	pushf  
8010431a:	58                   	pop    %eax
8010431b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010431e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104321:	c9                   	leave  
80104322:	c3                   	ret    

80104323 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104323:	55                   	push   %ebp
80104324:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104326:	fb                   	sti    
}
80104327:	5d                   	pop    %ebp
80104328:	c3                   	ret    

80104329 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104329:	55                   	push   %ebp
8010432a:	89 e5                	mov    %esp,%ebp
8010432c:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010432f:	c7 44 24 04 d5 88 10 	movl   $0x801088d5,0x4(%esp)
80104336:	80 
80104337:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010433e:	e8 4b 0b 00 00       	call   80104e8e <initlock>
}
80104343:	c9                   	leave  
80104344:	c3                   	ret    

80104345 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104345:	55                   	push   %ebp
80104346:	89 e5                	mov    %esp,%ebp
80104348:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010434b:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104352:	e8 58 0b 00 00       	call   80104eaf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104357:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
8010435e:	eb 50                	jmp    801043b0 <allocproc+0x6b>
    if(p->state == UNUSED)
80104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104363:	8b 40 0c             	mov    0xc(%eax),%eax
80104366:	85 c0                	test   %eax,%eax
80104368:	75 42                	jne    801043ac <allocproc+0x67>
      goto found;
8010436a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010436b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104375:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010437a:	8d 50 01             	lea    0x1(%eax),%edx
8010437d:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104383:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104386:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104389:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104390:	e8 7c 0b 00 00       	call   80104f11 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104395:	e8 c7 ea ff ff       	call   80102e61 <kalloc>
8010439a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439d:	89 42 08             	mov    %eax,0x8(%edx)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	8b 40 08             	mov    0x8(%eax),%eax
801043a6:	85 c0                	test   %eax,%eax
801043a8:	75 33                	jne    801043dd <allocproc+0x98>
801043aa:	eb 20                	jmp    801043cc <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043ac:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043b0:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
801043b7:	72 a7                	jb     80104360 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043b9:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
801043c0:	e8 4c 0b 00 00       	call   80104f11 <release>
  return 0;
801043c5:	b8 00 00 00 00       	mov    $0x0,%eax
801043ca:	eb 76                	jmp    80104442 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043d6:	b8 00 00 00 00       	mov    $0x0,%eax
801043db:	eb 65                	jmp    80104442 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
801043dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e0:	8b 40 08             	mov    0x8(%eax),%eax
801043e3:	05 00 10 00 00       	add    $0x1000,%eax
801043e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043eb:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f5:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043f8:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043fc:	ba 89 66 10 80       	mov    $0x80106689,%edx
80104401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104404:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104406:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104410:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	8b 40 1c             	mov    0x1c(%eax),%eax
80104419:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104420:	00 
80104421:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104428:	00 
80104429:	89 04 24             	mov    %eax,(%esp)
8010442c:	e8 d2 0c 00 00       	call   80105103 <memset>
  p->context->eip = (uint)forkret;
80104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104434:	8b 40 1c             	mov    0x1c(%eax),%eax
80104437:	ba b9 4b 10 80       	mov    $0x80104bb9,%edx
8010443c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104442:	c9                   	leave  
80104443:	c3                   	ret    

80104444 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104444:	55                   	push   %ebp
80104445:	89 e5                	mov    %esp,%ebp
80104447:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010444a:	e8 f6 fe ff ff       	call   80104345 <allocproc>
8010444f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010445a:	c7 04 24 61 2e 10 80 	movl   $0x80102e61,(%esp)
80104461:	e8 17 39 00 00       	call   80107d7d <setupkvm>
80104466:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104469:	89 42 04             	mov    %eax,0x4(%edx)
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 40 04             	mov    0x4(%eax),%eax
80104472:	85 c0                	test   %eax,%eax
80104474:	75 0c                	jne    80104482 <userinit+0x3e>
    panic("userinit: out of memory?");
80104476:	c7 04 24 dc 88 10 80 	movl   $0x801088dc,(%esp)
8010447d:	e8 b8 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104482:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448a:	8b 40 04             	mov    0x4(%eax),%eax
8010448d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104491:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104498:	80 
80104499:	89 04 24             	mov    %eax,(%esp)
8010449c:	e8 34 3b 00 00       	call   80107fd5 <inituvm>
  p->sz = PGSIZE;
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	8b 40 18             	mov    0x18(%eax),%eax
801044b0:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044b7:	00 
801044b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044bf:	00 
801044c0:	89 04 24             	mov    %eax,(%esp)
801044c3:	e8 3b 0c 00 00       	call   80105103 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	8b 40 18             	mov    0x18(%eax),%eax
801044ce:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	8b 40 18             	mov    0x18(%eax),%eax
801044da:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e3:	8b 40 18             	mov    0x18(%eax),%eax
801044e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e9:	8b 52 18             	mov    0x18(%edx),%edx
801044ec:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044f0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	8b 40 18             	mov    0x18(%eax),%eax
801044fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044fd:	8b 52 18             	mov    0x18(%edx),%edx
80104500:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104504:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 18             	mov    0x18(%eax),%eax
8010450e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104525:	8b 40 18             	mov    0x18(%eax),%eax
80104528:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	83 c0 6c             	add    $0x6c,%eax
80104535:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010453c:	00 
8010453d:	c7 44 24 04 f5 88 10 	movl   $0x801088f5,0x4(%esp)
80104544:	80 
80104545:	89 04 24             	mov    %eax,(%esp)
80104548:	e8 d6 0d 00 00       	call   80105323 <safestrcpy>
  p->cwd = namei("/");
8010454d:	c7 04 24 fe 88 10 80 	movl   $0x801088fe,(%esp)
80104554:	e8 0c e2 ff ff       	call   80102765 <namei>
80104559:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455c:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104569:	c9                   	leave  
8010456a:	c3                   	ret    

8010456b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010456b:	55                   	push   %ebp
8010456c:	89 e5                	mov    %esp,%ebp
8010456e:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104571:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104577:	8b 00                	mov    (%eax),%eax
80104579:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010457c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104580:	7e 34                	jle    801045b6 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104582:	8b 55 08             	mov    0x8(%ebp),%edx
80104585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104588:	01 c2                	add    %eax,%edx
8010458a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104590:	8b 40 04             	mov    0x4(%eax),%eax
80104593:	89 54 24 08          	mov    %edx,0x8(%esp)
80104597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010459e:	89 04 24             	mov    %eax,(%esp)
801045a1:	e8 a5 3b 00 00       	call   8010814b <allocuvm>
801045a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ad:	75 41                	jne    801045f0 <growproc+0x85>
      return -1;
801045af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b4:	eb 58                	jmp    8010460e <growproc+0xa3>
  } else if(n < 0){
801045b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045ba:	79 34                	jns    801045f0 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045bc:	8b 55 08             	mov    0x8(%ebp),%edx
801045bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c2:	01 c2                	add    %eax,%edx
801045c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ca:	8b 40 04             	mov    0x4(%eax),%eax
801045cd:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801045d8:	89 04 24             	mov    %eax,(%esp)
801045db:	e8 45 3c 00 00       	call   80108225 <deallocuvm>
801045e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045e7:	75 07                	jne    801045f0 <growproc+0x85>
      return -1;
801045e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ee:	eb 1e                	jmp    8010460e <growproc+0xa3>
  }
  proc->sz = sz;
801045f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f9:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104601:	89 04 24             	mov    %eax,(%esp)
80104604:	e8 65 38 00 00       	call   80107e6e <switchuvm>
  return 0;
80104609:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010460e:	c9                   	leave  
8010460f:	c3                   	ret    

80104610 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104610:	55                   	push   %ebp
80104611:	89 e5                	mov    %esp,%ebp
80104613:	57                   	push   %edi
80104614:	56                   	push   %esi
80104615:	53                   	push   %ebx
80104616:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104619:	e8 27 fd ff ff       	call   80104345 <allocproc>
8010461e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104621:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104625:	75 0a                	jne    80104631 <fork+0x21>
    return -1;
80104627:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462c:	e9 3a 01 00 00       	jmp    8010476b <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104631:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104637:	8b 10                	mov    (%eax),%edx
80104639:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463f:	8b 40 04             	mov    0x4(%eax),%eax
80104642:	89 54 24 04          	mov    %edx,0x4(%esp)
80104646:	89 04 24             	mov    %eax,(%esp)
80104649:	e8 73 3d 00 00       	call   801083c1 <copyuvm>
8010464e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104651:	89 42 04             	mov    %eax,0x4(%edx)
80104654:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104657:	8b 40 04             	mov    0x4(%eax),%eax
8010465a:	85 c0                	test   %eax,%eax
8010465c:	75 2c                	jne    8010468a <fork+0x7a>
    kfree(np->kstack);
8010465e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104661:	8b 40 08             	mov    0x8(%eax),%eax
80104664:	89 04 24             	mov    %eax,(%esp)
80104667:	e8 5c e7 ff ff       	call   80102dc8 <kfree>
    np->kstack = 0;
8010466c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104676:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104679:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104685:	e9 e1 00 00 00       	jmp    8010476b <fork+0x15b>
  }
  np->sz = proc->sz;
8010468a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104690:	8b 10                	mov    (%eax),%edx
80104692:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104695:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104697:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010469e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a7:	8b 50 18             	mov    0x18(%eax),%edx
801046aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b0:	8b 40 18             	mov    0x18(%eax),%eax
801046b3:	89 c3                	mov    %eax,%ebx
801046b5:	b8 13 00 00 00       	mov    $0x13,%eax
801046ba:	89 d7                	mov    %edx,%edi
801046bc:	89 de                	mov    %ebx,%esi
801046be:	89 c1                	mov    %eax,%ecx
801046c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c5:	8b 40 18             	mov    0x18(%eax),%eax
801046c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046d6:	eb 3d                	jmp    80104715 <fork+0x105>
    if(proc->ofile[i])
801046d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046e1:	83 c2 08             	add    $0x8,%edx
801046e4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046e8:	85 c0                	test   %eax,%eax
801046ea:	74 25                	je     80104711 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046f5:	83 c2 08             	add    $0x8,%edx
801046f8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046fc:	89 04 24             	mov    %eax,(%esp)
801046ff:	e8 75 c8 ff ff       	call   80100f79 <filedup>
80104704:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104707:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010470a:	83 c1 08             	add    $0x8,%ecx
8010470d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104711:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104715:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104719:	7e bd                	jle    801046d8 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010471b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104721:	8b 40 68             	mov    0x68(%eax),%eax
80104724:	89 04 24             	mov    %eax,(%esp)
80104727:	e8 f0 d0 ff ff       	call   8010181c <idup>
8010472c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010472f:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104732:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104735:	8b 40 10             	mov    0x10(%eax),%eax
80104738:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010473b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010474e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104751:	83 c0 6c             	add    $0x6c,%eax
80104754:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010475b:	00 
8010475c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104760:	89 04 24             	mov    %eax,(%esp)
80104763:	e8 bb 0b 00 00       	call   80105323 <safestrcpy>
  return pid;
80104768:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010476b:	83 c4 2c             	add    $0x2c,%esp
8010476e:	5b                   	pop    %ebx
8010476f:	5e                   	pop    %esi
80104770:	5f                   	pop    %edi
80104771:	5d                   	pop    %ebp
80104772:	c3                   	ret    

80104773 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104773:	55                   	push   %ebp
80104774:	89 e5                	mov    %esp,%ebp
80104776:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104779:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104780:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104785:	39 c2                	cmp    %eax,%edx
80104787:	75 0c                	jne    80104795 <exit+0x22>
    panic("init exiting");
80104789:	c7 04 24 00 89 10 80 	movl   $0x80108900,(%esp)
80104790:	e8 a5 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104795:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010479c:	eb 44                	jmp    801047e2 <exit+0x6f>
    if(proc->ofile[fd]){
8010479e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047a7:	83 c2 08             	add    $0x8,%edx
801047aa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047ae:	85 c0                	test   %eax,%eax
801047b0:	74 2c                	je     801047de <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047bb:	83 c2 08             	add    $0x8,%edx
801047be:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047c2:	89 04 24             	mov    %eax,(%esp)
801047c5:	e8 f7 c7 ff ff       	call   80100fc1 <fileclose>
      proc->ofile[fd] = 0;
801047ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047d3:	83 c2 08             	add    $0x8,%edx
801047d6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047dd:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047e2:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047e6:	7e b6                	jle    8010479e <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801047e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ee:	8b 40 68             	mov    0x68(%eax),%eax
801047f1:	89 04 24             	mov    %eax,(%esp)
801047f4:	e8 08 d2 ff ff       	call   80101a01 <iput>
  proc->cwd = 0;
801047f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ff:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104806:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010480d:	e8 9d 06 00 00       	call   80104eaf <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104812:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104818:	8b 40 14             	mov    0x14(%eax),%eax
8010481b:	89 04 24             	mov    %eax,(%esp)
8010481e:	e8 5d 04 00 00       	call   80104c80 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104823:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
8010482a:	eb 38                	jmp    80104864 <exit+0xf1>
    if(p->parent == proc){
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	8b 50 14             	mov    0x14(%eax),%edx
80104832:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104838:	39 c2                	cmp    %eax,%edx
8010483a:	75 24                	jne    80104860 <exit+0xed>
      p->parent = initproc;
8010483c:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104845:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484b:	8b 40 0c             	mov    0xc(%eax),%eax
8010484e:	83 f8 05             	cmp    $0x5,%eax
80104851:	75 0d                	jne    80104860 <exit+0xed>
        wakeup1(initproc);
80104853:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104858:	89 04 24             	mov    %eax,(%esp)
8010485b:	e8 20 04 00 00       	call   80104c80 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104860:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104864:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
8010486b:	72 bf                	jb     8010482c <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010486d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104873:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010487a:	e8 56 02 00 00       	call   80104ad5 <sched>
  panic("zombie exit");
8010487f:	c7 04 24 0d 89 10 80 	movl   $0x8010890d,(%esp)
80104886:	e8 af bc ff ff       	call   8010053a <panic>

8010488b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010488b:	55                   	push   %ebp
8010488c:	89 e5                	mov    %esp,%ebp
8010488e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104891:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104898:	e8 12 06 00 00       	call   80104eaf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010489d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a4:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
801048ab:	e9 9a 00 00 00       	jmp    8010494a <wait+0xbf>
      if(p->parent != proc)
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	8b 50 14             	mov    0x14(%eax),%edx
801048b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048bc:	39 c2                	cmp    %eax,%edx
801048be:	74 05                	je     801048c5 <wait+0x3a>
        continue;
801048c0:	e9 81 00 00 00       	jmp    80104946 <wait+0xbb>
      havekids = 1;
801048c5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cf:	8b 40 0c             	mov    0xc(%eax),%eax
801048d2:	83 f8 05             	cmp    $0x5,%eax
801048d5:	75 6f                	jne    80104946 <wait+0xbb>
        // Found one.
        pid = p->pid;
801048d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048da:	8b 40 10             	mov    0x10(%eax),%eax
801048dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 40 08             	mov    0x8(%eax),%eax
801048e6:	89 04 24             	mov    %eax,(%esp)
801048e9:	e8 da e4 ff ff       	call   80102dc8 <kfree>
        p->kstack = 0;
801048ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fb:	8b 40 04             	mov    0x4(%eax),%eax
801048fe:	89 04 24             	mov    %eax,(%esp)
80104901:	e8 db 39 00 00       	call   801082e1 <freevm>
        p->state = UNUSED;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104913:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104935:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
8010493c:	e8 d0 05 00 00       	call   80104f11 <release>
        return pid;
80104941:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104944:	eb 52                	jmp    80104998 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104946:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010494a:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104951:	0f 82 59 ff ff ff    	jb     801048b0 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104957:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010495b:	74 0d                	je     8010496a <wait+0xdf>
8010495d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104963:	8b 40 24             	mov    0x24(%eax),%eax
80104966:	85 c0                	test   %eax,%eax
80104968:	74 13                	je     8010497d <wait+0xf2>
      release(&ptable.lock);
8010496a:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104971:	e8 9b 05 00 00       	call   80104f11 <release>
      return -1;
80104976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497b:	eb 1b                	jmp    80104998 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010497d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104983:	c7 44 24 04 e0 ff 10 	movl   $0x8010ffe0,0x4(%esp)
8010498a:	80 
8010498b:	89 04 24             	mov    %eax,(%esp)
8010498e:	e8 52 02 00 00       	call   80104be5 <sleep>
  }
80104993:	e9 05 ff ff ff       	jmp    8010489d <wait+0x12>
}
80104998:	c9                   	leave  
80104999:	c3                   	ret    

8010499a <register_handler>:

void
register_handler(sighandler_t sighandler)
{
8010499a:	55                   	push   %ebp
8010499b:	89 e5                	mov    %esp,%ebp
8010499d:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
801049a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a6:	8b 40 18             	mov    0x18(%eax),%eax
801049a9:	8b 40 44             	mov    0x44(%eax),%eax
801049ac:	89 c2                	mov    %eax,%edx
801049ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b4:	8b 40 04             	mov    0x4(%eax),%eax
801049b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801049bb:	89 04 24             	mov    %eax,(%esp)
801049be:	e8 0f 3b 00 00       	call   801084d2 <uva2ka>
801049c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
801049c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cc:	8b 40 18             	mov    0x18(%eax),%eax
801049cf:	8b 40 44             	mov    0x44(%eax),%eax
801049d2:	25 ff 0f 00 00       	and    $0xfff,%eax
801049d7:	85 c0                	test   %eax,%eax
801049d9:	75 0c                	jne    801049e7 <register_handler+0x4d>
    panic("esp_offset == 0");
801049db:	c7 04 24 19 89 10 80 	movl   $0x80108919,(%esp)
801049e2:	e8 53 bb ff ff       	call   8010053a <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
801049e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ed:	8b 40 18             	mov    0x18(%eax),%eax
801049f0:	8b 40 44             	mov    0x44(%eax),%eax
801049f3:	83 e8 04             	sub    $0x4,%eax
801049f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801049fb:	89 c2                	mov    %eax,%edx
801049fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a00:	01 c2                	add    %eax,%edx
          = proc->tf->eip;
80104a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a08:	8b 40 18             	mov    0x18(%eax),%eax
80104a0b:	8b 40 38             	mov    0x38(%eax),%eax
80104a0e:	89 02                	mov    %eax,(%edx)
  proc->tf->esp -= 4;
80104a10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a16:	8b 40 18             	mov    0x18(%eax),%eax
80104a19:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a20:	8b 52 18             	mov    0x18(%edx),%edx
80104a23:	8b 52 44             	mov    0x44(%edx),%edx
80104a26:	83 ea 04             	sub    $0x4,%edx
80104a29:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a32:	8b 40 18             	mov    0x18(%eax),%eax
80104a35:	8b 55 08             	mov    0x8(%ebp),%edx
80104a38:	89 50 38             	mov    %edx,0x38(%eax)
}
80104a3b:	c9                   	leave  
80104a3c:	c3                   	ret    

80104a3d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a3d:	55                   	push   %ebp
80104a3e:	89 e5                	mov    %esp,%ebp
80104a40:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a43:	e8 db f8 ff ff       	call   80104323 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a48:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104a4f:	e8 5b 04 00 00       	call   80104eaf <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a54:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104a5b:	eb 5e                	jmp    80104abb <scheduler+0x7e>
      if(p->state != RUNNABLE)
80104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a60:	8b 40 0c             	mov    0xc(%eax),%eax
80104a63:	83 f8 03             	cmp    $0x3,%eax
80104a66:	74 02                	je     80104a6a <scheduler+0x2d>
        continue;
80104a68:	eb 4d                	jmp    80104ab7 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a76:	89 04 24             	mov    %eax,(%esp)
80104a79:	e8 f0 33 00 00       	call   80107e6e <switchuvm>
      p->state = RUNNING;
80104a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a81:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a91:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a98:	83 c2 04             	add    $0x4,%edx
80104a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a9f:	89 14 24             	mov    %edx,(%esp)
80104aa2:	e8 ed 08 00 00       	call   80105394 <swtch>
      switchkvm();
80104aa7:	e8 a5 33 00 00       	call   80107e51 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104aac:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ab3:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104abb:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104ac2:	72 99                	jb     80104a5d <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ac4:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104acb:	e8 41 04 00 00       	call   80104f11 <release>

  }
80104ad0:	e9 6e ff ff ff       	jmp    80104a43 <scheduler+0x6>

80104ad5 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ad5:	55                   	push   %ebp
80104ad6:	89 e5                	mov    %esp,%ebp
80104ad8:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104adb:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104ae2:	e8 f2 04 00 00       	call   80104fd9 <holding>
80104ae7:	85 c0                	test   %eax,%eax
80104ae9:	75 0c                	jne    80104af7 <sched+0x22>
    panic("sched ptable.lock");
80104aeb:	c7 04 24 29 89 10 80 	movl   $0x80108929,(%esp)
80104af2:	e8 43 ba ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104af7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104afd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b03:	83 f8 01             	cmp    $0x1,%eax
80104b06:	74 0c                	je     80104b14 <sched+0x3f>
    panic("sched locks");
80104b08:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
80104b0f:	e8 26 ba ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b1d:	83 f8 04             	cmp    $0x4,%eax
80104b20:	75 0c                	jne    80104b2e <sched+0x59>
    panic("sched running");
80104b22:	c7 04 24 47 89 10 80 	movl   $0x80108947,(%esp)
80104b29:	e8 0c ba ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b2e:	e8 e0 f7 ff ff       	call   80104313 <readeflags>
80104b33:	25 00 02 00 00       	and    $0x200,%eax
80104b38:	85 c0                	test   %eax,%eax
80104b3a:	74 0c                	je     80104b48 <sched+0x73>
    panic("sched interruptible");
80104b3c:	c7 04 24 55 89 10 80 	movl   $0x80108955,(%esp)
80104b43:	e8 f2 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104b48:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b4e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b5d:	8b 40 04             	mov    0x4(%eax),%eax
80104b60:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b67:	83 c2 1c             	add    $0x1c,%edx
80104b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b6e:	89 14 24             	mov    %edx,(%esp)
80104b71:	e8 1e 08 00 00       	call   80105394 <swtch>
  cpu->intena = intena;
80104b76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b7f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b85:	c9                   	leave  
80104b86:	c3                   	ret    

80104b87 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b87:	55                   	push   %ebp
80104b88:	89 e5                	mov    %esp,%ebp
80104b8a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b8d:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104b94:	e8 16 03 00 00       	call   80104eaf <acquire>
  proc->state = RUNNABLE;
80104b99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ba6:	e8 2a ff ff ff       	call   80104ad5 <sched>
  release(&ptable.lock);
80104bab:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104bb2:	e8 5a 03 00 00       	call   80104f11 <release>
}
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bbf:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104bc6:	e8 46 03 00 00       	call   80104f11 <release>

  if (first) {
80104bcb:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104bd0:	85 c0                	test   %eax,%eax
80104bd2:	74 0f                	je     80104be3 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104bd4:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104bdb:	00 00 00 
    initlog();
80104bde:	e8 73 e7 ff ff       	call   80103356 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104be3:	c9                   	leave  
80104be4:	c3                   	ret    

80104be5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
80104be8:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104beb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf1:	85 c0                	test   %eax,%eax
80104bf3:	75 0c                	jne    80104c01 <sleep+0x1c>
    panic("sleep");
80104bf5:	c7 04 24 69 89 10 80 	movl   $0x80108969,(%esp)
80104bfc:	e8 39 b9 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c05:	75 0c                	jne    80104c13 <sleep+0x2e>
    panic("sleep without lk");
80104c07:	c7 04 24 6f 89 10 80 	movl   $0x8010896f,(%esp)
80104c0e:	e8 27 b9 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c13:	81 7d 0c e0 ff 10 80 	cmpl   $0x8010ffe0,0xc(%ebp)
80104c1a:	74 17                	je     80104c33 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c1c:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104c23:	e8 87 02 00 00       	call   80104eaf <acquire>
    release(lk);
80104c28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2b:	89 04 24             	mov    %eax,(%esp)
80104c2e:	e8 de 02 00 00       	call   80104f11 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104c33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c39:	8b 55 08             	mov    0x8(%ebp),%edx
80104c3c:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104c3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c45:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c4c:	e8 84 fe ff ff       	call   80104ad5 <sched>

  // Tidy up.
  proc->chan = 0;
80104c51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c57:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c5e:	81 7d 0c e0 ff 10 80 	cmpl   $0x8010ffe0,0xc(%ebp)
80104c65:	74 17                	je     80104c7e <sleep+0x99>
    release(&ptable.lock);
80104c67:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104c6e:	e8 9e 02 00 00       	call   80104f11 <release>
    acquire(lk);
80104c73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c76:	89 04 24             	mov    %eax,(%esp)
80104c79:	e8 31 02 00 00       	call   80104eaf <acquire>
  }
}
80104c7e:	c9                   	leave  
80104c7f:	c3                   	ret    

80104c80 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c80:	55                   	push   %ebp
80104c81:	89 e5                	mov    %esp,%ebp
80104c83:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c86:	c7 45 fc 14 00 11 80 	movl   $0x80110014,-0x4(%ebp)
80104c8d:	eb 24                	jmp    80104cb3 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c92:	8b 40 0c             	mov    0xc(%eax),%eax
80104c95:	83 f8 02             	cmp    $0x2,%eax
80104c98:	75 15                	jne    80104caf <wakeup1+0x2f>
80104c9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9d:	8b 40 20             	mov    0x20(%eax),%eax
80104ca0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ca3:	75 0a                	jne    80104caf <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ca5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104caf:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104cb3:	81 7d fc 14 1f 11 80 	cmpl   $0x80111f14,-0x4(%ebp)
80104cba:	72 d3                	jb     80104c8f <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cbc:	c9                   	leave  
80104cbd:	c3                   	ret    

80104cbe <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cbe:	55                   	push   %ebp
80104cbf:	89 e5                	mov    %esp,%ebp
80104cc1:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104cc4:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104ccb:	e8 df 01 00 00       	call   80104eaf <acquire>
  wakeup1(chan);
80104cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd3:	89 04 24             	mov    %eax,(%esp)
80104cd6:	e8 a5 ff ff ff       	call   80104c80 <wakeup1>
  release(&ptable.lock);
80104cdb:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104ce2:	e8 2a 02 00 00       	call   80104f11 <release>
}
80104ce7:	c9                   	leave  
80104ce8:	c3                   	ret    

80104ce9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ce9:	55                   	push   %ebp
80104cea:	89 e5                	mov    %esp,%ebp
80104cec:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cef:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104cf6:	e8 b4 01 00 00       	call   80104eaf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cfb:	c7 45 f4 14 00 11 80 	movl   $0x80110014,-0xc(%ebp)
80104d02:	eb 41                	jmp    80104d45 <kill+0x5c>
    if(p->pid == pid){
80104d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d07:	8b 40 10             	mov    0x10(%eax),%eax
80104d0a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d0d:	75 32                	jne    80104d41 <kill+0x58>
      p->killed = 1;
80104d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d12:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d1f:	83 f8 02             	cmp    $0x2,%eax
80104d22:	75 0a                	jne    80104d2e <kill+0x45>
        p->state = RUNNABLE;
80104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d27:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d2e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104d35:	e8 d7 01 00 00       	call   80104f11 <release>
      return 0;
80104d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d3f:	eb 1e                	jmp    80104d5f <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d41:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104d45:	81 7d f4 14 1f 11 80 	cmpl   $0x80111f14,-0xc(%ebp)
80104d4c:	72 b6                	jb     80104d04 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d4e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80104d55:	e8 b7 01 00 00       	call   80104f11 <release>
  return -1;
80104d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d5f:	c9                   	leave  
80104d60:	c3                   	ret    

80104d61 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d61:	55                   	push   %ebp
80104d62:	89 e5                	mov    %esp,%ebp
80104d64:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d67:	c7 45 f0 14 00 11 80 	movl   $0x80110014,-0x10(%ebp)
80104d6e:	e9 d6 00 00 00       	jmp    80104e49 <procdump+0xe8>
    if(p->state == UNUSED)
80104d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d76:	8b 40 0c             	mov    0xc(%eax),%eax
80104d79:	85 c0                	test   %eax,%eax
80104d7b:	75 05                	jne    80104d82 <procdump+0x21>
      continue;
80104d7d:	e9 c3 00 00 00       	jmp    80104e45 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d85:	8b 40 0c             	mov    0xc(%eax),%eax
80104d88:	83 f8 05             	cmp    $0x5,%eax
80104d8b:	77 23                	ja     80104db0 <procdump+0x4f>
80104d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d90:	8b 40 0c             	mov    0xc(%eax),%eax
80104d93:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104d9a:	85 c0                	test   %eax,%eax
80104d9c:	74 12                	je     80104db0 <procdump+0x4f>
      state = states[p->state];
80104d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da1:	8b 40 0c             	mov    0xc(%eax),%eax
80104da4:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104dab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104dae:	eb 07                	jmp    80104db7 <procdump+0x56>
    else
      state = "???";
80104db0:	c7 45 ec 80 89 10 80 	movl   $0x80108980,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dba:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc0:	8b 40 10             	mov    0x10(%eax),%eax
80104dc3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104dc7:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104dca:	89 54 24 08          	mov    %edx,0x8(%esp)
80104dce:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dd2:	c7 04 24 84 89 10 80 	movl   $0x80108984,(%esp)
80104dd9:	e8 c2 b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de1:	8b 40 0c             	mov    0xc(%eax),%eax
80104de4:	83 f8 02             	cmp    $0x2,%eax
80104de7:	75 50                	jne    80104e39 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dec:	8b 40 1c             	mov    0x1c(%eax),%eax
80104def:	8b 40 0c             	mov    0xc(%eax),%eax
80104df2:	83 c0 08             	add    $0x8,%eax
80104df5:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104df8:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dfc:	89 04 24             	mov    %eax,(%esp)
80104dff:	e8 5c 01 00 00       	call   80104f60 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e0b:	eb 1b                	jmp    80104e28 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e10:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e14:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e18:	c7 04 24 8d 89 10 80 	movl   $0x8010898d,(%esp)
80104e1f:	e8 7c b5 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e28:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e2c:	7f 0b                	jg     80104e39 <procdump+0xd8>
80104e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e31:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e35:	85 c0                	test   %eax,%eax
80104e37:	75 d4                	jne    80104e0d <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e39:	c7 04 24 91 89 10 80 	movl   $0x80108991,(%esp)
80104e40:	e8 5b b5 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e45:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104e49:	81 7d f0 14 1f 11 80 	cmpl   $0x80111f14,-0x10(%ebp)
80104e50:	0f 82 1d ff ff ff    	jb     80104d73 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e56:	c9                   	leave  
80104e57:	c3                   	ret    

80104e58 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e58:	55                   	push   %ebp
80104e59:	89 e5                	mov    %esp,%ebp
80104e5b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e5e:	9c                   	pushf  
80104e5f:	58                   	pop    %eax
80104e60:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104e63:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e68:	55                   	push   %ebp
80104e69:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e6b:	fa                   	cli    
}
80104e6c:	5d                   	pop    %ebp
80104e6d:	c3                   	ret    

80104e6e <sti>:

static inline void
sti(void)
{
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e71:	fb                   	sti    
}
80104e72:	5d                   	pop    %ebp
80104e73:	c3                   	ret    

80104e74 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e74:	55                   	push   %ebp
80104e75:	89 e5                	mov    %esp,%ebp
80104e77:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e7a:	8b 55 08             	mov    0x8(%ebp),%edx
80104e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e83:	f0 87 02             	lock xchg %eax,(%edx)
80104e86:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e8c:	c9                   	leave  
80104e8d:	c3                   	ret    

80104e8e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e8e:	55                   	push   %ebp
80104e8f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e91:	8b 45 08             	mov    0x8(%ebp),%eax
80104e94:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e97:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e9d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ead:	5d                   	pop    %ebp
80104eae:	c3                   	ret    

80104eaf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104eaf:	55                   	push   %ebp
80104eb0:	89 e5                	mov    %esp,%ebp
80104eb2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104eb5:	e8 49 01 00 00       	call   80105003 <pushcli>
  if(holding(lk))
80104eba:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebd:	89 04 24             	mov    %eax,(%esp)
80104ec0:	e8 14 01 00 00       	call   80104fd9 <holding>
80104ec5:	85 c0                	test   %eax,%eax
80104ec7:	74 0c                	je     80104ed5 <acquire+0x26>
    panic("acquire");
80104ec9:	c7 04 24 bd 89 10 80 	movl   $0x801089bd,(%esp)
80104ed0:	e8 65 b6 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104ed5:	90                   	nop
80104ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104ee0:	00 
80104ee1:	89 04 24             	mov    %eax,(%esp)
80104ee4:	e8 8b ff ff ff       	call   80104e74 <xchg>
80104ee9:	85 c0                	test   %eax,%eax
80104eeb:	75 e9                	jne    80104ed6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104eed:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ef7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104efa:	8b 45 08             	mov    0x8(%ebp),%eax
80104efd:	83 c0 0c             	add    $0xc,%eax
80104f00:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f04:	8d 45 08             	lea    0x8(%ebp),%eax
80104f07:	89 04 24             	mov    %eax,(%esp)
80104f0a:	e8 51 00 00 00       	call   80104f60 <getcallerpcs>
}
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f17:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1a:	89 04 24             	mov    %eax,(%esp)
80104f1d:	e8 b7 00 00 00       	call   80104fd9 <holding>
80104f22:	85 c0                	test   %eax,%eax
80104f24:	75 0c                	jne    80104f32 <release+0x21>
    panic("release");
80104f26:	c7 04 24 c5 89 10 80 	movl   $0x801089c5,(%esp)
80104f2d:	e8 08 b6 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104f32:	8b 45 08             	mov    0x8(%ebp),%eax
80104f35:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f46:	8b 45 08             	mov    0x8(%ebp),%eax
80104f49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f50:	00 
80104f51:	89 04 24             	mov    %eax,(%esp)
80104f54:	e8 1b ff ff ff       	call   80104e74 <xchg>

  popcli();
80104f59:	e8 e9 00 00 00       	call   80105047 <popcli>
}
80104f5e:	c9                   	leave  
80104f5f:	c3                   	ret    

80104f60 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f60:	55                   	push   %ebp
80104f61:	89 e5                	mov    %esp,%ebp
80104f63:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104f66:	8b 45 08             	mov    0x8(%ebp),%eax
80104f69:	83 e8 08             	sub    $0x8,%eax
80104f6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f6f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f76:	eb 38                	jmp    80104fb0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f78:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f7c:	74 38                	je     80104fb6 <getcallerpcs+0x56>
80104f7e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f85:	76 2f                	jbe    80104fb6 <getcallerpcs+0x56>
80104f87:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f8b:	74 29                	je     80104fb6 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f97:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9a:	01 c2                	add    %eax,%edx
80104f9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f9f:	8b 40 04             	mov    0x4(%eax),%eax
80104fa2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fa7:	8b 00                	mov    (%eax),%eax
80104fa9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104fac:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104fb0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fb4:	7e c2                	jle    80104f78 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fb6:	eb 19                	jmp    80104fd1 <getcallerpcs+0x71>
    pcs[i] = 0;
80104fb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc5:	01 d0                	add    %edx,%eax
80104fc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fcd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104fd1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fd5:	7e e1                	jle    80104fb8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104fd7:	c9                   	leave  
80104fd8:	c3                   	ret    

80104fd9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104fd9:	55                   	push   %ebp
80104fda:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdf:	8b 00                	mov    (%eax),%eax
80104fe1:	85 c0                	test   %eax,%eax
80104fe3:	74 17                	je     80104ffc <holding+0x23>
80104fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe8:	8b 50 08             	mov    0x8(%eax),%edx
80104feb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ff1:	39 c2                	cmp    %eax,%edx
80104ff3:	75 07                	jne    80104ffc <holding+0x23>
80104ff5:	b8 01 00 00 00       	mov    $0x1,%eax
80104ffa:	eb 05                	jmp    80105001 <holding+0x28>
80104ffc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105001:	5d                   	pop    %ebp
80105002:	c3                   	ret    

80105003 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105003:	55                   	push   %ebp
80105004:	89 e5                	mov    %esp,%ebp
80105006:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105009:	e8 4a fe ff ff       	call   80104e58 <readeflags>
8010500e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105011:	e8 52 fe ff ff       	call   80104e68 <cli>
  if(cpu->ncli++ == 0)
80105016:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010501d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105023:	8d 48 01             	lea    0x1(%eax),%ecx
80105026:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010502c:	85 c0                	test   %eax,%eax
8010502e:	75 15                	jne    80105045 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105030:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105036:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105039:	81 e2 00 02 00 00    	and    $0x200,%edx
8010503f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    

80105047 <popcli>:

void
popcli(void)
{
80105047:	55                   	push   %ebp
80105048:	89 e5                	mov    %esp,%ebp
8010504a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010504d:	e8 06 fe ff ff       	call   80104e58 <readeflags>
80105052:	25 00 02 00 00       	and    $0x200,%eax
80105057:	85 c0                	test   %eax,%eax
80105059:	74 0c                	je     80105067 <popcli+0x20>
    panic("popcli - interruptible");
8010505b:	c7 04 24 cd 89 10 80 	movl   $0x801089cd,(%esp)
80105062:	e8 d3 b4 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105067:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010506d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105073:	83 ea 01             	sub    $0x1,%edx
80105076:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010507c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105082:	85 c0                	test   %eax,%eax
80105084:	79 0c                	jns    80105092 <popcli+0x4b>
    panic("popcli");
80105086:	c7 04 24 e4 89 10 80 	movl   $0x801089e4,(%esp)
8010508d:	e8 a8 b4 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105092:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105098:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010509e:	85 c0                	test   %eax,%eax
801050a0:	75 15                	jne    801050b7 <popcli+0x70>
801050a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050a8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050ae:	85 c0                	test   %eax,%eax
801050b0:	74 05                	je     801050b7 <popcli+0x70>
    sti();
801050b2:	e8 b7 fd ff ff       	call   80104e6e <sti>
}
801050b7:	c9                   	leave  
801050b8:	c3                   	ret    

801050b9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801050b9:	55                   	push   %ebp
801050ba:	89 e5                	mov    %esp,%ebp
801050bc:	57                   	push   %edi
801050bd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801050be:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050c1:	8b 55 10             	mov    0x10(%ebp),%edx
801050c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c7:	89 cb                	mov    %ecx,%ebx
801050c9:	89 df                	mov    %ebx,%edi
801050cb:	89 d1                	mov    %edx,%ecx
801050cd:	fc                   	cld    
801050ce:	f3 aa                	rep stos %al,%es:(%edi)
801050d0:	89 ca                	mov    %ecx,%edx
801050d2:	89 fb                	mov    %edi,%ebx
801050d4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050d7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050da:	5b                   	pop    %ebx
801050db:	5f                   	pop    %edi
801050dc:	5d                   	pop    %ebp
801050dd:	c3                   	ret    

801050de <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050de:	55                   	push   %ebp
801050df:	89 e5                	mov    %esp,%ebp
801050e1:	57                   	push   %edi
801050e2:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050e6:	8b 55 10             	mov    0x10(%ebp),%edx
801050e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ec:	89 cb                	mov    %ecx,%ebx
801050ee:	89 df                	mov    %ebx,%edi
801050f0:	89 d1                	mov    %edx,%ecx
801050f2:	fc                   	cld    
801050f3:	f3 ab                	rep stos %eax,%es:(%edi)
801050f5:	89 ca                	mov    %ecx,%edx
801050f7:	89 fb                	mov    %edi,%ebx
801050f9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050fc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050ff:	5b                   	pop    %ebx
80105100:	5f                   	pop    %edi
80105101:	5d                   	pop    %ebp
80105102:	c3                   	ret    

80105103 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105103:	55                   	push   %ebp
80105104:	89 e5                	mov    %esp,%ebp
80105106:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105109:	8b 45 08             	mov    0x8(%ebp),%eax
8010510c:	83 e0 03             	and    $0x3,%eax
8010510f:	85 c0                	test   %eax,%eax
80105111:	75 49                	jne    8010515c <memset+0x59>
80105113:	8b 45 10             	mov    0x10(%ebp),%eax
80105116:	83 e0 03             	and    $0x3,%eax
80105119:	85 c0                	test   %eax,%eax
8010511b:	75 3f                	jne    8010515c <memset+0x59>
    c &= 0xFF;
8010511d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105124:	8b 45 10             	mov    0x10(%ebp),%eax
80105127:	c1 e8 02             	shr    $0x2,%eax
8010512a:	89 c2                	mov    %eax,%edx
8010512c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512f:	c1 e0 18             	shl    $0x18,%eax
80105132:	89 c1                	mov    %eax,%ecx
80105134:	8b 45 0c             	mov    0xc(%ebp),%eax
80105137:	c1 e0 10             	shl    $0x10,%eax
8010513a:	09 c1                	or     %eax,%ecx
8010513c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513f:	c1 e0 08             	shl    $0x8,%eax
80105142:	09 c8                	or     %ecx,%eax
80105144:	0b 45 0c             	or     0xc(%ebp),%eax
80105147:	89 54 24 08          	mov    %edx,0x8(%esp)
8010514b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010514f:	8b 45 08             	mov    0x8(%ebp),%eax
80105152:	89 04 24             	mov    %eax,(%esp)
80105155:	e8 84 ff ff ff       	call   801050de <stosl>
8010515a:	eb 19                	jmp    80105175 <memset+0x72>
  } else
    stosb(dst, c, n);
8010515c:	8b 45 10             	mov    0x10(%ebp),%eax
8010515f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105163:	8b 45 0c             	mov    0xc(%ebp),%eax
80105166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	89 04 24             	mov    %eax,(%esp)
80105170:	e8 44 ff ff ff       	call   801050b9 <stosb>
  return dst;
80105175:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105178:	c9                   	leave  
80105179:	c3                   	ret    

8010517a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010517a:	55                   	push   %ebp
8010517b:	89 e5                	mov    %esp,%ebp
8010517d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105180:	8b 45 08             	mov    0x8(%ebp),%eax
80105183:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105186:	8b 45 0c             	mov    0xc(%ebp),%eax
80105189:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010518c:	eb 30                	jmp    801051be <memcmp+0x44>
    if(*s1 != *s2)
8010518e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105191:	0f b6 10             	movzbl (%eax),%edx
80105194:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105197:	0f b6 00             	movzbl (%eax),%eax
8010519a:	38 c2                	cmp    %al,%dl
8010519c:	74 18                	je     801051b6 <memcmp+0x3c>
      return *s1 - *s2;
8010519e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a1:	0f b6 00             	movzbl (%eax),%eax
801051a4:	0f b6 d0             	movzbl %al,%edx
801051a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051aa:	0f b6 00             	movzbl (%eax),%eax
801051ad:	0f b6 c0             	movzbl %al,%eax
801051b0:	29 c2                	sub    %eax,%edx
801051b2:	89 d0                	mov    %edx,%eax
801051b4:	eb 1a                	jmp    801051d0 <memcmp+0x56>
    s1++, s2++;
801051b6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051ba:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051be:	8b 45 10             	mov    0x10(%ebp),%eax
801051c1:	8d 50 ff             	lea    -0x1(%eax),%edx
801051c4:	89 55 10             	mov    %edx,0x10(%ebp)
801051c7:	85 c0                	test   %eax,%eax
801051c9:	75 c3                	jne    8010518e <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801051cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051d0:	c9                   	leave  
801051d1:	c3                   	ret    

801051d2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801051d2:	55                   	push   %ebp
801051d3:	89 e5                	mov    %esp,%ebp
801051d5:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801051d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801051db:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051de:	8b 45 08             	mov    0x8(%ebp),%eax
801051e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051e7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051ea:	73 3d                	jae    80105229 <memmove+0x57>
801051ec:	8b 45 10             	mov    0x10(%ebp),%eax
801051ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051f2:	01 d0                	add    %edx,%eax
801051f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051f7:	76 30                	jbe    80105229 <memmove+0x57>
    s += n;
801051f9:	8b 45 10             	mov    0x10(%ebp),%eax
801051fc:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801051ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105202:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105205:	eb 13                	jmp    8010521a <memmove+0x48>
      *--d = *--s;
80105207:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010520b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010520f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105212:	0f b6 10             	movzbl (%eax),%edx
80105215:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105218:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010521a:	8b 45 10             	mov    0x10(%ebp),%eax
8010521d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105220:	89 55 10             	mov    %edx,0x10(%ebp)
80105223:	85 c0                	test   %eax,%eax
80105225:	75 e0                	jne    80105207 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105227:	eb 26                	jmp    8010524f <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105229:	eb 17                	jmp    80105242 <memmove+0x70>
      *d++ = *s++;
8010522b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010522e:	8d 50 01             	lea    0x1(%eax),%edx
80105231:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105234:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105237:	8d 4a 01             	lea    0x1(%edx),%ecx
8010523a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010523d:	0f b6 12             	movzbl (%edx),%edx
80105240:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105242:	8b 45 10             	mov    0x10(%ebp),%eax
80105245:	8d 50 ff             	lea    -0x1(%eax),%edx
80105248:	89 55 10             	mov    %edx,0x10(%ebp)
8010524b:	85 c0                	test   %eax,%eax
8010524d:	75 dc                	jne    8010522b <memmove+0x59>
      *d++ = *s++;

  return dst;
8010524f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105252:	c9                   	leave  
80105253:	c3                   	ret    

80105254 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105254:	55                   	push   %ebp
80105255:	89 e5                	mov    %esp,%ebp
80105257:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010525a:	8b 45 10             	mov    0x10(%ebp),%eax
8010525d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105261:	8b 45 0c             	mov    0xc(%ebp),%eax
80105264:	89 44 24 04          	mov    %eax,0x4(%esp)
80105268:	8b 45 08             	mov    0x8(%ebp),%eax
8010526b:	89 04 24             	mov    %eax,(%esp)
8010526e:	e8 5f ff ff ff       	call   801051d2 <memmove>
}
80105273:	c9                   	leave  
80105274:	c3                   	ret    

80105275 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105278:	eb 0c                	jmp    80105286 <strncmp+0x11>
    n--, p++, q++;
8010527a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010527e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105282:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105286:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010528a:	74 1a                	je     801052a6 <strncmp+0x31>
8010528c:	8b 45 08             	mov    0x8(%ebp),%eax
8010528f:	0f b6 00             	movzbl (%eax),%eax
80105292:	84 c0                	test   %al,%al
80105294:	74 10                	je     801052a6 <strncmp+0x31>
80105296:	8b 45 08             	mov    0x8(%ebp),%eax
80105299:	0f b6 10             	movzbl (%eax),%edx
8010529c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529f:	0f b6 00             	movzbl (%eax),%eax
801052a2:	38 c2                	cmp    %al,%dl
801052a4:	74 d4                	je     8010527a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801052a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052aa:	75 07                	jne    801052b3 <strncmp+0x3e>
    return 0;
801052ac:	b8 00 00 00 00       	mov    $0x0,%eax
801052b1:	eb 16                	jmp    801052c9 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801052b3:	8b 45 08             	mov    0x8(%ebp),%eax
801052b6:	0f b6 00             	movzbl (%eax),%eax
801052b9:	0f b6 d0             	movzbl %al,%edx
801052bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801052bf:	0f b6 00             	movzbl (%eax),%eax
801052c2:	0f b6 c0             	movzbl %al,%eax
801052c5:	29 c2                	sub    %eax,%edx
801052c7:	89 d0                	mov    %edx,%eax
}
801052c9:	5d                   	pop    %ebp
801052ca:	c3                   	ret    

801052cb <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052cb:	55                   	push   %ebp
801052cc:	89 e5                	mov    %esp,%ebp
801052ce:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052d1:	8b 45 08             	mov    0x8(%ebp),%eax
801052d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052d7:	90                   	nop
801052d8:	8b 45 10             	mov    0x10(%ebp),%eax
801052db:	8d 50 ff             	lea    -0x1(%eax),%edx
801052de:	89 55 10             	mov    %edx,0x10(%ebp)
801052e1:	85 c0                	test   %eax,%eax
801052e3:	7e 1e                	jle    80105303 <strncpy+0x38>
801052e5:	8b 45 08             	mov    0x8(%ebp),%eax
801052e8:	8d 50 01             	lea    0x1(%eax),%edx
801052eb:	89 55 08             	mov    %edx,0x8(%ebp)
801052ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801052f1:	8d 4a 01             	lea    0x1(%edx),%ecx
801052f4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801052f7:	0f b6 12             	movzbl (%edx),%edx
801052fa:	88 10                	mov    %dl,(%eax)
801052fc:	0f b6 00             	movzbl (%eax),%eax
801052ff:	84 c0                	test   %al,%al
80105301:	75 d5                	jne    801052d8 <strncpy+0xd>
    ;
  while(n-- > 0)
80105303:	eb 0c                	jmp    80105311 <strncpy+0x46>
    *s++ = 0;
80105305:	8b 45 08             	mov    0x8(%ebp),%eax
80105308:	8d 50 01             	lea    0x1(%eax),%edx
8010530b:	89 55 08             	mov    %edx,0x8(%ebp)
8010530e:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105311:	8b 45 10             	mov    0x10(%ebp),%eax
80105314:	8d 50 ff             	lea    -0x1(%eax),%edx
80105317:	89 55 10             	mov    %edx,0x10(%ebp)
8010531a:	85 c0                	test   %eax,%eax
8010531c:	7f e7                	jg     80105305 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010531e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105321:	c9                   	leave  
80105322:	c3                   	ret    

80105323 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105323:	55                   	push   %ebp
80105324:	89 e5                	mov    %esp,%ebp
80105326:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010532f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105333:	7f 05                	jg     8010533a <safestrcpy+0x17>
    return os;
80105335:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105338:	eb 31                	jmp    8010536b <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010533a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010533e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105342:	7e 1e                	jle    80105362 <safestrcpy+0x3f>
80105344:	8b 45 08             	mov    0x8(%ebp),%eax
80105347:	8d 50 01             	lea    0x1(%eax),%edx
8010534a:	89 55 08             	mov    %edx,0x8(%ebp)
8010534d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105350:	8d 4a 01             	lea    0x1(%edx),%ecx
80105353:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105356:	0f b6 12             	movzbl (%edx),%edx
80105359:	88 10                	mov    %dl,(%eax)
8010535b:	0f b6 00             	movzbl (%eax),%eax
8010535e:	84 c0                	test   %al,%al
80105360:	75 d8                	jne    8010533a <safestrcpy+0x17>
    ;
  *s = 0;
80105362:	8b 45 08             	mov    0x8(%ebp),%eax
80105365:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105368:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010536b:	c9                   	leave  
8010536c:	c3                   	ret    

8010536d <strlen>:

int
strlen(const char *s)
{
8010536d:	55                   	push   %ebp
8010536e:	89 e5                	mov    %esp,%ebp
80105370:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105373:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010537a:	eb 04                	jmp    80105380 <strlen+0x13>
8010537c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105380:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105383:	8b 45 08             	mov    0x8(%ebp),%eax
80105386:	01 d0                	add    %edx,%eax
80105388:	0f b6 00             	movzbl (%eax),%eax
8010538b:	84 c0                	test   %al,%al
8010538d:	75 ed                	jne    8010537c <strlen+0xf>
    ;
  return n;
8010538f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105392:	c9                   	leave  
80105393:	c3                   	ret    

80105394 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105394:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105398:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010539c:	55                   	push   %ebp
  pushl %ebx
8010539d:	53                   	push   %ebx
  pushl %esi
8010539e:	56                   	push   %esi
  pushl %edi
8010539f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053a0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053a2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053a4:	5f                   	pop    %edi
  popl %esi
801053a5:	5e                   	pop    %esi
  popl %ebx
801053a6:	5b                   	pop    %ebx
  popl %ebp
801053a7:	5d                   	pop    %ebp
  ret
801053a8:	c3                   	ret    

801053a9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801053a9:	55                   	push   %ebp
801053aa:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801053ac:	8b 45 08             	mov    0x8(%ebp),%eax
801053af:	8b 00                	mov    (%eax),%eax
801053b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801053b4:	76 0f                	jbe    801053c5 <fetchint+0x1c>
801053b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b9:	8d 50 04             	lea    0x4(%eax),%edx
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	8b 00                	mov    (%eax),%eax
801053c1:	39 c2                	cmp    %eax,%edx
801053c3:	76 07                	jbe    801053cc <fetchint+0x23>
    return -1;
801053c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ca:	eb 0f                	jmp    801053db <fetchint+0x32>
  *ip = *(int*)(addr);
801053cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cf:	8b 10                	mov    (%eax),%edx
801053d1:	8b 45 10             	mov    0x10(%ebp),%eax
801053d4:	89 10                	mov    %edx,(%eax)
  return 0;
801053d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053db:	5d                   	pop    %ebp
801053dc:	c3                   	ret    

801053dd <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801053dd:	55                   	push   %ebp
801053de:	89 e5                	mov    %esp,%ebp
801053e0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801053e3:	8b 45 08             	mov    0x8(%ebp),%eax
801053e6:	8b 00                	mov    (%eax),%eax
801053e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801053eb:	77 07                	ja     801053f4 <fetchstr+0x17>
    return -1;
801053ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f2:	eb 43                	jmp    80105437 <fetchstr+0x5a>
  *pp = (char*)addr;
801053f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801053f7:	8b 45 10             	mov    0x10(%ebp),%eax
801053fa:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801053fc:	8b 45 08             	mov    0x8(%ebp),%eax
801053ff:	8b 00                	mov    (%eax),%eax
80105401:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105404:	8b 45 10             	mov    0x10(%ebp),%eax
80105407:	8b 00                	mov    (%eax),%eax
80105409:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010540c:	eb 1c                	jmp    8010542a <fetchstr+0x4d>
    if(*s == 0)
8010540e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105411:	0f b6 00             	movzbl (%eax),%eax
80105414:	84 c0                	test   %al,%al
80105416:	75 0e                	jne    80105426 <fetchstr+0x49>
      return s - *pp;
80105418:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010541b:	8b 45 10             	mov    0x10(%ebp),%eax
8010541e:	8b 00                	mov    (%eax),%eax
80105420:	29 c2                	sub    %eax,%edx
80105422:	89 d0                	mov    %edx,%eax
80105424:	eb 11                	jmp    80105437 <fetchstr+0x5a>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
80105426:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010542a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105430:	72 dc                	jb     8010540e <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105437:	c9                   	leave  
80105438:	c3                   	ret    

80105439 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105439:	55                   	push   %ebp
8010543a:	89 e5                	mov    %esp,%ebp
8010543c:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
8010543f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105445:	8b 40 18             	mov    0x18(%eax),%eax
80105448:	8b 50 44             	mov    0x44(%eax),%edx
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	c1 e0 02             	shl    $0x2,%eax
80105451:	01 d0                	add    %edx,%eax
80105453:	8d 48 04             	lea    0x4(%eax),%ecx
80105456:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010545c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010545f:	89 54 24 08          	mov    %edx,0x8(%esp)
80105463:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105467:	89 04 24             	mov    %eax,(%esp)
8010546a:	e8 3a ff ff ff       	call   801053a9 <fetchint>
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105477:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010547a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547e:	8b 45 08             	mov    0x8(%ebp),%eax
80105481:	89 04 24             	mov    %eax,(%esp)
80105484:	e8 b0 ff ff ff       	call   80105439 <argint>
80105489:	85 c0                	test   %eax,%eax
8010548b:	79 07                	jns    80105494 <argptr+0x23>
    return -1;
8010548d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105492:	eb 3d                	jmp    801054d1 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105494:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105497:	89 c2                	mov    %eax,%edx
80105499:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549f:	8b 00                	mov    (%eax),%eax
801054a1:	39 c2                	cmp    %eax,%edx
801054a3:	73 16                	jae    801054bb <argptr+0x4a>
801054a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a8:	89 c2                	mov    %eax,%edx
801054aa:	8b 45 10             	mov    0x10(%ebp),%eax
801054ad:	01 c2                	add    %eax,%edx
801054af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b5:	8b 00                	mov    (%eax),%eax
801054b7:	39 c2                	cmp    %eax,%edx
801054b9:	76 07                	jbe    801054c2 <argptr+0x51>
    return -1;
801054bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c0:	eb 0f                	jmp    801054d1 <argptr+0x60>
  *pp = (char*)i;
801054c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054c5:	89 c2                	mov    %eax,%edx
801054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ca:	89 10                	mov    %edx,(%eax)
  return 0;
801054cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054d1:	c9                   	leave  
801054d2:	c3                   	ret    

801054d3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054d3:	55                   	push   %ebp
801054d4:	89 e5                	mov    %esp,%ebp
801054d6:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e0:	8b 45 08             	mov    0x8(%ebp),%eax
801054e3:	89 04 24             	mov    %eax,(%esp)
801054e6:	e8 4e ff ff ff       	call   80105439 <argint>
801054eb:	85 c0                	test   %eax,%eax
801054ed:	79 07                	jns    801054f6 <argstr+0x23>
    return -1;
801054ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f4:	eb 1e                	jmp    80105514 <argstr+0x41>
  return fetchstr(proc, addr, pp);
801054f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f9:	89 c2                	mov    %eax,%edx
801054fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105504:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105508:	89 54 24 04          	mov    %edx,0x4(%esp)
8010550c:	89 04 24             	mov    %eax,(%esp)
8010550f:	e8 c9 fe ff ff       	call   801053dd <fetchstr>
}
80105514:	c9                   	leave  
80105515:	c3                   	ret    

80105516 <syscall>:
[SYS_readlink] sys_readlink,
};

void
syscall(void)
{
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	53                   	push   %ebx
8010551a:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010551d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105523:	8b 40 18             	mov    0x18(%eax),%eax
80105526:	8b 40 1c             	mov    0x1c(%eax),%eax
80105529:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
8010552c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105530:	78 2e                	js     80105560 <syscall+0x4a>
80105532:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105536:	7f 28                	jg     80105560 <syscall+0x4a>
80105538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105542:	85 c0                	test   %eax,%eax
80105544:	74 1a                	je     80105560 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105546:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554c:	8b 58 18             	mov    0x18(%eax),%ebx
8010554f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105552:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105559:	ff d0                	call   *%eax
8010555b:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010555e:	eb 73                	jmp    801055d3 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105560:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105564:	7e 30                	jle    80105596 <syscall+0x80>
80105566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105569:	83 f8 17             	cmp    $0x17,%eax
8010556c:	77 28                	ja     80105596 <syscall+0x80>
8010556e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105571:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105578:	85 c0                	test   %eax,%eax
8010557a:	74 1a                	je     80105596 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
8010557c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105582:	8b 58 18             	mov    0x18(%eax),%ebx
80105585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105588:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010558f:	ff d0                	call   *%eax
80105591:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105594:	eb 3d                	jmp    801055d3 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105596:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010559c:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010559f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801055a5:	8b 40 10             	mov    0x10(%eax),%eax
801055a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
801055af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801055b7:	c7 04 24 eb 89 10 80 	movl   $0x801089eb,(%esp)
801055be:	e8 dd ad ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801055c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055c9:	8b 40 18             	mov    0x18(%eax),%eax
801055cc:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801055d3:	83 c4 24             	add    $0x24,%esp
801055d6:	5b                   	pop    %ebx
801055d7:	5d                   	pop    %ebp
801055d8:	c3                   	ret    

801055d9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055d9:	55                   	push   %ebp
801055da:	89 e5                	mov    %esp,%ebp
801055dc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e6:	8b 45 08             	mov    0x8(%ebp),%eax
801055e9:	89 04 24             	mov    %eax,(%esp)
801055ec:	e8 48 fe ff ff       	call   80105439 <argint>
801055f1:	85 c0                	test   %eax,%eax
801055f3:	79 07                	jns    801055fc <argfd+0x23>
    return -1;
801055f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055fa:	eb 50                	jmp    8010564c <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801055fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ff:	85 c0                	test   %eax,%eax
80105601:	78 21                	js     80105624 <argfd+0x4b>
80105603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105606:	83 f8 0f             	cmp    $0xf,%eax
80105609:	7f 19                	jg     80105624 <argfd+0x4b>
8010560b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105611:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105614:	83 c2 08             	add    $0x8,%edx
80105617:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010561b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010561e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105622:	75 07                	jne    8010562b <argfd+0x52>
    return -1;
80105624:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105629:	eb 21                	jmp    8010564c <argfd+0x73>
  if(pfd)
8010562b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010562f:	74 08                	je     80105639 <argfd+0x60>
    *pfd = fd;
80105631:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105634:	8b 45 0c             	mov    0xc(%ebp),%eax
80105637:	89 10                	mov    %edx,(%eax)
  if(pf)
80105639:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010563d:	74 08                	je     80105647 <argfd+0x6e>
    *pf = f;
8010563f:	8b 45 10             	mov    0x10(%ebp),%eax
80105642:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105645:	89 10                	mov    %edx,(%eax)
  return 0;
80105647:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010564c:	c9                   	leave  
8010564d:	c3                   	ret    

8010564e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010564e:	55                   	push   %ebp
8010564f:	89 e5                	mov    %esp,%ebp
80105651:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105654:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010565b:	eb 30                	jmp    8010568d <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010565d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105663:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105666:	83 c2 08             	add    $0x8,%edx
80105669:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010566d:	85 c0                	test   %eax,%eax
8010566f:	75 18                	jne    80105689 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105671:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105677:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010567a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010567d:	8b 55 08             	mov    0x8(%ebp),%edx
80105680:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105684:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105687:	eb 0f                	jmp    80105698 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105689:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010568d:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105691:	7e ca                	jle    8010565d <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105693:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105698:	c9                   	leave  
80105699:	c3                   	ret    

8010569a <sys_dup>:

int
sys_dup(void)
{
8010569a:	55                   	push   %ebp
8010569b:	89 e5                	mov    %esp,%ebp
8010569d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801056a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056ae:	00 
801056af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056b6:	e8 1e ff ff ff       	call   801055d9 <argfd>
801056bb:	85 c0                	test   %eax,%eax
801056bd:	79 07                	jns    801056c6 <sys_dup+0x2c>
    return -1;
801056bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c4:	eb 29                	jmp    801056ef <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801056c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c9:	89 04 24             	mov    %eax,(%esp)
801056cc:	e8 7d ff ff ff       	call   8010564e <fdalloc>
801056d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d8:	79 07                	jns    801056e1 <sys_dup+0x47>
    return -1;
801056da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056df:	eb 0e                	jmp    801056ef <sys_dup+0x55>
  filedup(f);
801056e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e4:	89 04 24             	mov    %eax,(%esp)
801056e7:	e8 8d b8 ff ff       	call   80100f79 <filedup>
  return fd;
801056ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056ef:	c9                   	leave  
801056f0:	c3                   	ret    

801056f1 <sys_read>:

int
sys_read(void)
{
801056f1:	55                   	push   %ebp
801056f2:	89 e5                	mov    %esp,%ebp
801056f4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801056fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105705:	00 
80105706:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010570d:	e8 c7 fe ff ff       	call   801055d9 <argfd>
80105712:	85 c0                	test   %eax,%eax
80105714:	78 35                	js     8010574b <sys_read+0x5a>
80105716:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105719:	89 44 24 04          	mov    %eax,0x4(%esp)
8010571d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105724:	e8 10 fd ff ff       	call   80105439 <argint>
80105729:	85 c0                	test   %eax,%eax
8010572b:	78 1e                	js     8010574b <sys_read+0x5a>
8010572d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105730:	89 44 24 08          	mov    %eax,0x8(%esp)
80105734:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105737:	89 44 24 04          	mov    %eax,0x4(%esp)
8010573b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105742:	e8 2a fd ff ff       	call   80105471 <argptr>
80105747:	85 c0                	test   %eax,%eax
80105749:	79 07                	jns    80105752 <sys_read+0x61>
    return -1;
8010574b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105750:	eb 19                	jmp    8010576b <sys_read+0x7a>
  return fileread(f, p, n);
80105752:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105755:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010575b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010575f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105763:	89 04 24             	mov    %eax,(%esp)
80105766:	e8 7b b9 ff ff       	call   801010e6 <fileread>
}
8010576b:	c9                   	leave  
8010576c:	c3                   	ret    

8010576d <sys_write>:

int
sys_write(void)
{
8010576d:	55                   	push   %ebp
8010576e:	89 e5                	mov    %esp,%ebp
80105770:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105773:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105776:	89 44 24 08          	mov    %eax,0x8(%esp)
8010577a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105781:	00 
80105782:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105789:	e8 4b fe ff ff       	call   801055d9 <argfd>
8010578e:	85 c0                	test   %eax,%eax
80105790:	78 35                	js     801057c7 <sys_write+0x5a>
80105792:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105795:	89 44 24 04          	mov    %eax,0x4(%esp)
80105799:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801057a0:	e8 94 fc ff ff       	call   80105439 <argint>
801057a5:	85 c0                	test   %eax,%eax
801057a7:	78 1e                	js     801057c7 <sys_write+0x5a>
801057a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801057b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801057b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057be:	e8 ae fc ff ff       	call   80105471 <argptr>
801057c3:	85 c0                	test   %eax,%eax
801057c5:	79 07                	jns    801057ce <sys_write+0x61>
    return -1;
801057c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cc:	eb 19                	jmp    801057e7 <sys_write+0x7a>
  return filewrite(f, p, n);
801057ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057db:	89 54 24 04          	mov    %edx,0x4(%esp)
801057df:	89 04 24             	mov    %eax,(%esp)
801057e2:	e8 bb b9 ff ff       	call   801011a2 <filewrite>
}
801057e7:	c9                   	leave  
801057e8:	c3                   	ret    

801057e9 <sys_close>:

int
sys_close(void)
{
801057e9:	55                   	push   %ebp
801057ea:	89 e5                	mov    %esp,%ebp
801057ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801057ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f2:	89 44 24 08          	mov    %eax,0x8(%esp)
801057f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801057fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105804:	e8 d0 fd ff ff       	call   801055d9 <argfd>
80105809:	85 c0                	test   %eax,%eax
8010580b:	79 07                	jns    80105814 <sys_close+0x2b>
    return -1;
8010580d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105812:	eb 24                	jmp    80105838 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105814:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010581a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010581d:	83 c2 08             	add    $0x8,%edx
80105820:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105827:	00 
  fileclose(f);
80105828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582b:	89 04 24             	mov    %eax,(%esp)
8010582e:	e8 8e b7 ff ff       	call   80100fc1 <fileclose>
  return 0;
80105833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105838:	c9                   	leave  
80105839:	c3                   	ret    

8010583a <sys_fstat>:

int
sys_fstat(void)
{
8010583a:	55                   	push   %ebp
8010583b:	89 e5                	mov    %esp,%ebp
8010583d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105840:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105843:	89 44 24 08          	mov    %eax,0x8(%esp)
80105847:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010584e:	00 
8010584f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105856:	e8 7e fd ff ff       	call   801055d9 <argfd>
8010585b:	85 c0                	test   %eax,%eax
8010585d:	78 1f                	js     8010587e <sys_fstat+0x44>
8010585f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105866:	00 
80105867:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010586e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105875:	e8 f7 fb ff ff       	call   80105471 <argptr>
8010587a:	85 c0                	test   %eax,%eax
8010587c:	79 07                	jns    80105885 <sys_fstat+0x4b>
    return -1;
8010587e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105883:	eb 12                	jmp    80105897 <sys_fstat+0x5d>
  return filestat(f, st);
80105885:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010588f:	89 04 24             	mov    %eax,(%esp)
80105892:	e8 00 b8 ff ff       	call   80101097 <filestat>
}
80105897:	c9                   	leave  
80105898:	c3                   	ret    

80105899 <sys_readlink>:

static struct inode* create(char *path, short type, short major, short minor);

int //task1.b
sys_readlink(void) {
80105899:	55                   	push   %ebp
8010589a:	89 e5                	mov    %esp,%ebp
8010589c:	83 ec 28             	sub    $0x28,%esp
	 char *pathname, *buf;
	// size_t bufsize;
	 uint counter;

	 counter = 0;
8010589f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
// if(argstr(0, &pathname) < 0 || argstr(1, &buf) < 0 || argint(2, bufsize) < 0)
	  if(argstr(0, &pathname) < 0 || argstr(1, &buf) < 0)
801058a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058b4:	e8 1a fc ff ff       	call   801054d3 <argstr>
801058b9:	85 c0                	test   %eax,%eax
801058bb:	78 17                	js     801058d4 <sys_readlink+0x3b>
801058bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058cb:	e8 03 fc ff ff       	call   801054d3 <argstr>
801058d0:	85 c0                	test   %eax,%eax
801058d2:	79 07                	jns    801058db <sys_readlink+0x42>
	    return -1;
801058d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d9:	eb 3b                	jmp    80105916 <sys_readlink+0x7d>

	  if (nameiparent(pathname, buf) == 0)
801058db:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801058e5:	89 04 24             	mov    %eax,(%esp)
801058e8:	e8 aa ce ff ff       	call   80102797 <nameiparent>
801058ed:	85 c0                	test   %eax,%eax
801058ef:	75 07                	jne    801058f8 <sys_readlink+0x5f>
		  return -1;
801058f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f6:	eb 1e                	jmp    80105916 <sys_readlink+0x7d>
	  while (*buf) {		// how many bytes we wrote to buffer
801058f8:	eb 0f                	jmp    80105909 <sys_readlink+0x70>
		  counter++ ;							// not including '\0'
801058fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		  (*buf)++;
801058fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105901:	0f b6 10             	movzbl (%eax),%edx
80105904:	83 c2 01             	add    $0x1,%edx
80105907:	88 10                	mov    %dl,(%eax)
	  if(argstr(0, &pathname) < 0 || argstr(1, &buf) < 0)
	    return -1;

	  if (nameiparent(pathname, buf) == 0)
		  return -1;
	  while (*buf) {		// how many bytes we wrote to buffer
80105909:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010590c:	0f b6 00             	movzbl (%eax),%eax
8010590f:	84 c0                	test   %al,%al
80105911:	75 e7                	jne    801058fa <sys_readlink+0x61>
		  counter++ ;							// not including '\0'
		  (*buf)++;
	  }

	return counter;
80105913:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105916:	c9                   	leave  
80105917:	c3                   	ret    

80105918 <sys_symlink>:



int //task1.b
sys_symlink(void)
{
80105918:	55                   	push   %ebp
80105919:	89 e5                	mov    %esp,%ebp
8010591b:	83 ec 28             	sub    $0x28,%esp
	 char *old, *new;
	 struct inode *ip;

	  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010591e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105921:	89 44 24 04          	mov    %eax,0x4(%esp)
80105925:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010592c:	e8 a2 fb ff ff       	call   801054d3 <argstr>
80105931:	85 c0                	test   %eax,%eax
80105933:	78 17                	js     8010594c <sys_symlink+0x34>
80105935:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105943:	e8 8b fb ff ff       	call   801054d3 <argstr>
80105948:	85 c0                	test   %eax,%eax
8010594a:	79 0a                	jns    80105956 <sys_symlink+0x3e>
	    return -1;
8010594c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105951:	e9 91 00 00 00       	jmp    801059e7 <sys_symlink+0xcf>

	  begin_trans();
80105956:	e8 09 dc ff ff       	call   80103564 <begin_trans>
	  if((ip = create(new, FD_SYMLINK, 0, 0)) == 0){
8010595b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010595e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105965:	00 
80105966:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010596d:	00 
8010596e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105975:	00 
80105976:	89 04 24             	mov    %eax,(%esp)
80105979:	e8 29 04 00 00       	call   80105da7 <create>
8010597e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105985:	75 0c                	jne    80105993 <sys_symlink+0x7b>
	    commit_trans();
80105987:	e8 21 dc ff ff       	call   801035ad <commit_trans>
	    return -1;
8010598c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105991:	eb 54                	jmp    801059e7 <sys_symlink+0xcf>
	  }
	  ip->type = FD_SYMLINK;
80105993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105996:	66 c7 40 10 03 00    	movw   $0x3,0x10(%eax)
	  iupdate(ip);			// update on-disk data
8010599c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599f:	89 04 24             	mov    %eax,(%esp)
801059a2:	e8 eb bc ff ff       	call   80101692 <iupdate>

	  writei(ip, old, 0, strlen(old));		// write the old path into the inode of the new one
801059a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059aa:	89 04 24             	mov    %eax,(%esp)
801059ad:	e8 bb f9 ff ff       	call   8010536d <strlen>
801059b2:	89 c2                	mov    %eax,%edx
801059b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
801059bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801059c2:	00 
801059c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ca:	89 04 24             	mov    %eax,(%esp)
801059cd:	e8 33 c7 ff ff       	call   80102105 <writei>

	  iunlockput(ip);
801059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d5:	89 04 24             	mov    %eax,(%esp)
801059d8:	e8 f5 c0 ff ff       	call   80101ad2 <iunlockput>
	  commit_trans();
801059dd:	e8 cb db ff ff       	call   801035ad <commit_trans>
	  return 0;
801059e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059e7:	c9                   	leave  
801059e8:	c3                   	ret    

801059e9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059e9:	55                   	push   %ebp
801059ea:	89 e5                	mov    %esp,%ebp
801059ec:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059ef:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059fd:	e8 d1 fa ff ff       	call   801054d3 <argstr>
80105a02:	85 c0                	test   %eax,%eax
80105a04:	78 17                	js     80105a1d <sys_link+0x34>
80105a06:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a09:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a14:	e8 ba fa ff ff       	call   801054d3 <argstr>
80105a19:	85 c0                	test   %eax,%eax
80105a1b:	79 0a                	jns    80105a27 <sys_link+0x3e>
    return -1;
80105a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a22:	e9 3d 01 00 00       	jmp    80105b64 <sys_link+0x17b>
  if((ip = namei(old)) == 0)
80105a27:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a2a:	89 04 24             	mov    %eax,(%esp)
80105a2d:	e8 33 cd ff ff       	call   80102765 <namei>
80105a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a39:	75 0a                	jne    80105a45 <sys_link+0x5c>
    return -1;
80105a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a40:	e9 1f 01 00 00       	jmp    80105b64 <sys_link+0x17b>

  begin_trans();
80105a45:	e8 1a db ff ff       	call   80103564 <begin_trans>

  ilock(ip);
80105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4d:	89 04 24             	mov    %eax,(%esp)
80105a50:	e8 f9 bd ff ff       	call   8010184e <ilock>
  if(ip->type == T_DIR){
80105a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a58:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a5c:	66 83 f8 01          	cmp    $0x1,%ax
80105a60:	75 1a                	jne    80105a7c <sys_link+0x93>
    iunlockput(ip);
80105a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a65:	89 04 24             	mov    %eax,(%esp)
80105a68:	e8 65 c0 ff ff       	call   80101ad2 <iunlockput>
    commit_trans();
80105a6d:	e8 3b db ff ff       	call   801035ad <commit_trans>
    return -1;
80105a72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a77:	e9 e8 00 00 00       	jmp    80105b64 <sys_link+0x17b>
  }

  ip->nlink++;
80105a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a83:	8d 50 01             	lea    0x1(%eax),%edx
80105a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a89:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a90:	89 04 24             	mov    %eax,(%esp)
80105a93:	e8 fa bb ff ff       	call   80101692 <iupdate>
  iunlock(ip);
80105a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9b:	89 04 24             	mov    %eax,(%esp)
80105a9e:	e8 f9 be ff ff       	call   8010199c <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105aa3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105aa6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105aa9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aad:	89 04 24             	mov    %eax,(%esp)
80105ab0:	e8 e2 cc ff ff       	call   80102797 <nameiparent>
80105ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ab8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105abc:	75 02                	jne    80105ac0 <sys_link+0xd7>
    goto bad;
80105abe:	eb 68                	jmp    80105b28 <sys_link+0x13f>
  ilock(dp);
80105ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac3:	89 04 24             	mov    %eax,(%esp)
80105ac6:	e8 83 bd ff ff       	call   8010184e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ace:	8b 10                	mov    (%eax),%edx
80105ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad3:	8b 00                	mov    (%eax),%eax
80105ad5:	39 c2                	cmp    %eax,%edx
80105ad7:	75 20                	jne    80105af9 <sys_link+0x110>
80105ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adc:	8b 40 04             	mov    0x4(%eax),%eax
80105adf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ae3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aed:	89 04 24             	mov    %eax,(%esp)
80105af0:	e8 8a c8 ff ff       	call   8010237f <dirlink>
80105af5:	85 c0                	test   %eax,%eax
80105af7:	79 0d                	jns    80105b06 <sys_link+0x11d>
    iunlockput(dp);
80105af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afc:	89 04 24             	mov    %eax,(%esp)
80105aff:	e8 ce bf ff ff       	call   80101ad2 <iunlockput>
    goto bad;
80105b04:	eb 22                	jmp    80105b28 <sys_link+0x13f>
  }
  iunlockput(dp);
80105b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b09:	89 04 24             	mov    %eax,(%esp)
80105b0c:	e8 c1 bf ff ff       	call   80101ad2 <iunlockput>
  iput(ip);
80105b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b14:	89 04 24             	mov    %eax,(%esp)
80105b17:	e8 e5 be ff ff       	call   80101a01 <iput>

  commit_trans();
80105b1c:	e8 8c da ff ff       	call   801035ad <commit_trans>

  return 0;
80105b21:	b8 00 00 00 00       	mov    $0x0,%eax
80105b26:	eb 3c                	jmp    80105b64 <sys_link+0x17b>

bad:
  ilock(ip);
80105b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2b:	89 04 24             	mov    %eax,(%esp)
80105b2e:	e8 1b bd ff ff       	call   8010184e <ilock>
  ip->nlink--;
80105b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b36:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b3a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b40:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b47:	89 04 24             	mov    %eax,(%esp)
80105b4a:	e8 43 bb ff ff       	call   80101692 <iupdate>
  iunlockput(ip);
80105b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b52:	89 04 24             	mov    %eax,(%esp)
80105b55:	e8 78 bf ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80105b5a:	e8 4e da ff ff       	call   801035ad <commit_trans>
  return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b64:	c9                   	leave  
80105b65:	c3                   	ret    

80105b66 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b66:	55                   	push   %ebp
80105b67:	89 e5                	mov    %esp,%ebp
80105b69:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b6c:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b73:	eb 4b                	jmp    80105bc0 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b78:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b7f:	00 
80105b80:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8e:	89 04 24             	mov    %eax,(%esp)
80105b91:	e8 0b c4 ff ff       	call   80101fa1 <readi>
80105b96:	83 f8 10             	cmp    $0x10,%eax
80105b99:	74 0c                	je     80105ba7 <isdirempty+0x41>
      panic("isdirempty: readi");
80105b9b:	c7 04 24 07 8a 10 80 	movl   $0x80108a07,(%esp)
80105ba2:	e8 93 a9 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105ba7:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bab:	66 85 c0             	test   %ax,%ax
80105bae:	74 07                	je     80105bb7 <isdirempty+0x51>
      return 0;
80105bb0:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb5:	eb 1b                	jmp    80105bd2 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	83 c0 10             	add    $0x10,%eax
80105bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc6:	8b 40 18             	mov    0x18(%eax),%eax
80105bc9:	39 c2                	cmp    %eax,%edx
80105bcb:	72 a8                	jb     80105b75 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bcd:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bd2:	c9                   	leave  
80105bd3:	c3                   	ret    

80105bd4 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bd4:	55                   	push   %ebp
80105bd5:	89 e5                	mov    %esp,%ebp
80105bd7:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bda:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105be8:	e8 e6 f8 ff ff       	call   801054d3 <argstr>
80105bed:	85 c0                	test   %eax,%eax
80105bef:	79 0a                	jns    80105bfb <sys_unlink+0x27>
    return -1;
80105bf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf6:	e9 aa 01 00 00       	jmp    80105da5 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105bfb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bfe:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c01:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c05:	89 04 24             	mov    %eax,(%esp)
80105c08:	e8 8a cb ff ff       	call   80102797 <nameiparent>
80105c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c14:	75 0a                	jne    80105c20 <sys_unlink+0x4c>
    return -1;
80105c16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1b:	e9 85 01 00 00       	jmp    80105da5 <sys_unlink+0x1d1>

  begin_trans();
80105c20:	e8 3f d9 ff ff       	call   80103564 <begin_trans>

  ilock(dp);
80105c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c28:	89 04 24             	mov    %eax,(%esp)
80105c2b:	e8 1e bc ff ff       	call   8010184e <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c30:	c7 44 24 04 19 8a 10 	movl   $0x80108a19,0x4(%esp)
80105c37:	80 
80105c38:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c3b:	89 04 24             	mov    %eax,(%esp)
80105c3e:	e8 51 c6 ff ff       	call   80102294 <namecmp>
80105c43:	85 c0                	test   %eax,%eax
80105c45:	0f 84 45 01 00 00    	je     80105d90 <sys_unlink+0x1bc>
80105c4b:	c7 44 24 04 1b 8a 10 	movl   $0x80108a1b,0x4(%esp)
80105c52:	80 
80105c53:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c56:	89 04 24             	mov    %eax,(%esp)
80105c59:	e8 36 c6 ff ff       	call   80102294 <namecmp>
80105c5e:	85 c0                	test   %eax,%eax
80105c60:	0f 84 2a 01 00 00    	je     80105d90 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c66:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c69:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c6d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c77:	89 04 24             	mov    %eax,(%esp)
80105c7a:	e8 37 c6 ff ff       	call   801022b6 <dirlookup>
80105c7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c86:	75 05                	jne    80105c8d <sys_unlink+0xb9>
    goto bad;
80105c88:	e9 03 01 00 00       	jmp    80105d90 <sys_unlink+0x1bc>
  ilock(ip);
80105c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c90:	89 04 24             	mov    %eax,(%esp)
80105c93:	e8 b6 bb ff ff       	call   8010184e <ilock>

  if(ip->nlink < 1)
80105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c9f:	66 85 c0             	test   %ax,%ax
80105ca2:	7f 0c                	jg     80105cb0 <sys_unlink+0xdc>
    panic("unlink: nlink < 1");
80105ca4:	c7 04 24 1e 8a 10 80 	movl   $0x80108a1e,(%esp)
80105cab:	e8 8a a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cb7:	66 83 f8 01          	cmp    $0x1,%ax
80105cbb:	75 1f                	jne    80105cdc <sys_unlink+0x108>
80105cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc0:	89 04 24             	mov    %eax,(%esp)
80105cc3:	e8 9e fe ff ff       	call   80105b66 <isdirempty>
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	75 10                	jne    80105cdc <sys_unlink+0x108>
    iunlockput(ip);
80105ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccf:	89 04 24             	mov    %eax,(%esp)
80105cd2:	e8 fb bd ff ff       	call   80101ad2 <iunlockput>
    goto bad;
80105cd7:	e9 b4 00 00 00       	jmp    80105d90 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105cdc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ce3:	00 
80105ce4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ceb:	00 
80105cec:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cef:	89 04 24             	mov    %eax,(%esp)
80105cf2:	e8 0c f4 ff ff       	call   80105103 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cf7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cfa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d01:	00 
80105d02:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d06:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d09:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d10:	89 04 24             	mov    %eax,(%esp)
80105d13:	e8 ed c3 ff ff       	call   80102105 <writei>
80105d18:	83 f8 10             	cmp    $0x10,%eax
80105d1b:	74 0c                	je     80105d29 <sys_unlink+0x155>
    panic("unlink: writei");
80105d1d:	c7 04 24 30 8a 10 80 	movl   $0x80108a30,(%esp)
80105d24:	e8 11 a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d30:	66 83 f8 01          	cmp    $0x1,%ax
80105d34:	75 1c                	jne    80105d52 <sys_unlink+0x17e>
    dp->nlink--;
80105d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d39:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d43:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4a:	89 04 24             	mov    %eax,(%esp)
80105d4d:	e8 40 b9 ff ff       	call   80101692 <iupdate>
  }
  iunlockput(dp);
80105d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 75 bd ff ff       	call   80101ad2 <iunlockput>

  ip->nlink--;
80105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d60:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d64:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d71:	89 04 24             	mov    %eax,(%esp)
80105d74:	e8 19 b9 ff ff       	call   80101692 <iupdate>
  iunlockput(ip);
80105d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7c:	89 04 24             	mov    %eax,(%esp)
80105d7f:	e8 4e bd ff ff       	call   80101ad2 <iunlockput>

  commit_trans();
80105d84:	e8 24 d8 ff ff       	call   801035ad <commit_trans>

  return 0;
80105d89:	b8 00 00 00 00       	mov    $0x0,%eax
80105d8e:	eb 15                	jmp    80105da5 <sys_unlink+0x1d1>

bad:
  iunlockput(dp);
80105d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d93:	89 04 24             	mov    %eax,(%esp)
80105d96:	e8 37 bd ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80105d9b:	e8 0d d8 ff ff       	call   801035ad <commit_trans>
  return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    

80105da7 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105da7:	55                   	push   %ebp
80105da8:	89 e5                	mov    %esp,%ebp
80105daa:	83 ec 48             	sub    $0x48,%esp
80105dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105db0:	8b 55 10             	mov    0x10(%ebp),%edx
80105db3:	8b 45 14             	mov    0x14(%ebp),%eax
80105db6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dba:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dbe:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dc2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80105dcc:	89 04 24             	mov    %eax,(%esp)
80105dcf:	e8 c3 c9 ff ff       	call   80102797 <nameiparent>
80105dd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ddb:	75 0a                	jne    80105de7 <create+0x40>
    return 0;
80105ddd:	b8 00 00 00 00       	mov    $0x0,%eax
80105de2:	e9 7e 01 00 00       	jmp    80105f65 <create+0x1be>
  ilock(dp);
80105de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dea:	89 04 24             	mov    %eax,(%esp)
80105ded:	e8 5c ba ff ff       	call   8010184e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105df2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105df5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105df9:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e03:	89 04 24             	mov    %eax,(%esp)
80105e06:	e8 ab c4 ff ff       	call   801022b6 <dirlookup>
80105e0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e12:	74 47                	je     80105e5b <create+0xb4>
    iunlockput(dp);
80105e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e17:	89 04 24             	mov    %eax,(%esp)
80105e1a:	e8 b3 bc ff ff       	call   80101ad2 <iunlockput>
    ilock(ip);
80105e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e22:	89 04 24             	mov    %eax,(%esp)
80105e25:	e8 24 ba ff ff       	call   8010184e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e2a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e2f:	75 15                	jne    80105e46 <create+0x9f>
80105e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e34:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e38:	66 83 f8 02          	cmp    $0x2,%ax
80105e3c:	75 08                	jne    80105e46 <create+0x9f>
      return ip;
80105e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e41:	e9 1f 01 00 00       	jmp    80105f65 <create+0x1be>
    iunlockput(ip);
80105e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e49:	89 04 24             	mov    %eax,(%esp)
80105e4c:	e8 81 bc ff ff       	call   80101ad2 <iunlockput>
    return 0;
80105e51:	b8 00 00 00 00       	mov    $0x0,%eax
80105e56:	e9 0a 01 00 00       	jmp    80105f65 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e5b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e62:	8b 00                	mov    (%eax),%eax
80105e64:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e68:	89 04 24             	mov    %eax,(%esp)
80105e6b:	e8 43 b7 ff ff       	call   801015b3 <ialloc>
80105e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e77:	75 0c                	jne    80105e85 <create+0xde>
    panic("create: ialloc");
80105e79:	c7 04 24 3f 8a 10 80 	movl   $0x80108a3f,(%esp)
80105e80:	e8 b5 a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	89 04 24             	mov    %eax,(%esp)
80105e8b:	e8 be b9 ff ff       	call   8010184e <ilock>
  ip->major = major;
80105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e93:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e97:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ea2:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea9:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb2:	89 04 24             	mov    %eax,(%esp)
80105eb5:	e8 d8 b7 ff ff       	call   80101692 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105eba:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ebf:	75 6a                	jne    80105f2b <create+0x184>
    dp->nlink++;  // for ".."
80105ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ec8:	8d 50 01             	lea    0x1(%eax),%edx
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed5:	89 04 24             	mov    %eax,(%esp)
80105ed8:	e8 b5 b7 ff ff       	call   80101692 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee0:	8b 40 04             	mov    0x4(%eax),%eax
80105ee3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ee7:	c7 44 24 04 19 8a 10 	movl   $0x80108a19,0x4(%esp)
80105eee:	80 
80105eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef2:	89 04 24             	mov    %eax,(%esp)
80105ef5:	e8 85 c4 ff ff       	call   8010237f <dirlink>
80105efa:	85 c0                	test   %eax,%eax
80105efc:	78 21                	js     80105f1f <create+0x178>
80105efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f01:	8b 40 04             	mov    0x4(%eax),%eax
80105f04:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f08:	c7 44 24 04 1b 8a 10 	movl   $0x80108a1b,0x4(%esp)
80105f0f:	80 
80105f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f13:	89 04 24             	mov    %eax,(%esp)
80105f16:	e8 64 c4 ff ff       	call   8010237f <dirlink>
80105f1b:	85 c0                	test   %eax,%eax
80105f1d:	79 0c                	jns    80105f2b <create+0x184>
      panic("create dots");
80105f1f:	c7 04 24 4e 8a 10 80 	movl   $0x80108a4e,(%esp)
80105f26:	e8 0f a6 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2e:	8b 40 04             	mov    0x4(%eax),%eax
80105f31:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f35:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f38:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3f:	89 04 24             	mov    %eax,(%esp)
80105f42:	e8 38 c4 ff ff       	call   8010237f <dirlink>
80105f47:	85 c0                	test   %eax,%eax
80105f49:	79 0c                	jns    80105f57 <create+0x1b0>
    panic("create: dirlink");
80105f4b:	c7 04 24 5a 8a 10 80 	movl   $0x80108a5a,(%esp)
80105f52:	e8 e3 a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5a:	89 04 24             	mov    %eax,(%esp)
80105f5d:	e8 70 bb ff ff       	call   80101ad2 <iunlockput>

  return ip;
80105f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f65:	c9                   	leave  
80105f66:	c3                   	ret    

80105f67 <sys_open>:

int
sys_open(void)
{
80105f67:	55                   	push   %ebp
80105f68:	89 e5                	mov    %esp,%ebp
80105f6a:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f6d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f7b:	e8 53 f5 ff ff       	call   801054d3 <argstr>
80105f80:	85 c0                	test   %eax,%eax
80105f82:	78 17                	js     80105f9b <sys_open+0x34>
80105f84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f87:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f92:	e8 a2 f4 ff ff       	call   80105439 <argint>
80105f97:	85 c0                	test   %eax,%eax
80105f99:	79 0a                	jns    80105fa5 <sys_open+0x3e>
    return -1;
80105f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa0:	e9 48 01 00 00       	jmp    801060ed <sys_open+0x186>
  if(omode & O_CREATE){
80105fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa8:	25 00 02 00 00       	and    $0x200,%eax
80105fad:	85 c0                	test   %eax,%eax
80105faf:	74 40                	je     80105ff1 <sys_open+0x8a>
    begin_trans();
80105fb1:	e8 ae d5 ff ff       	call   80103564 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105fb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fc0:	00 
80105fc1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fc8:	00 
80105fc9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fd0:	00 
80105fd1:	89 04 24             	mov    %eax,(%esp)
80105fd4:	e8 ce fd ff ff       	call   80105da7 <create>
80105fd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105fdc:	e8 cc d5 ff ff       	call   801035ad <commit_trans>
    if(ip == 0)
80105fe1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe5:	75 5c                	jne    80106043 <sys_open+0xdc>
      return -1;
80105fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fec:	e9 fc 00 00 00       	jmp    801060ed <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
80105ff1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff4:	89 04 24             	mov    %eax,(%esp)
80105ff7:	e8 69 c7 ff ff       	call   80102765 <namei>
80105ffc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106003:	75 0a                	jne    8010600f <sys_open+0xa8>
      return -1;
80106005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600a:	e9 de 00 00 00       	jmp    801060ed <sys_open+0x186>
    ilock(ip);
8010600f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106012:	89 04 24             	mov    %eax,(%esp)
80106015:	e8 34 b8 ff ff       	call   8010184e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010601a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106021:	66 83 f8 01          	cmp    $0x1,%ax
80106025:	75 1c                	jne    80106043 <sys_open+0xdc>
80106027:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602a:	85 c0                	test   %eax,%eax
8010602c:	74 15                	je     80106043 <sys_open+0xdc>
      iunlockput(ip);
8010602e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106031:	89 04 24             	mov    %eax,(%esp)
80106034:	e8 99 ba ff ff       	call   80101ad2 <iunlockput>
      return -1;
80106039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603e:	e9 aa 00 00 00       	jmp    801060ed <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106043:	e8 d1 ae ff ff       	call   80100f19 <filealloc>
80106048:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010604b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010604f:	74 14                	je     80106065 <sys_open+0xfe>
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	89 04 24             	mov    %eax,(%esp)
80106057:	e8 f2 f5 ff ff       	call   8010564e <fdalloc>
8010605c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010605f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106063:	79 23                	jns    80106088 <sys_open+0x121>
    if(f)
80106065:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106069:	74 0b                	je     80106076 <sys_open+0x10f>
      fileclose(f);
8010606b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606e:	89 04 24             	mov    %eax,(%esp)
80106071:	e8 4b af ff ff       	call   80100fc1 <fileclose>
    iunlockput(ip);
80106076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106079:	89 04 24             	mov    %eax,(%esp)
8010607c:	e8 51 ba ff ff       	call   80101ad2 <iunlockput>
    return -1;
80106081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106086:	eb 65                	jmp    801060ed <sys_open+0x186>
  }
  iunlock(ip);
80106088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608b:	89 04 24             	mov    %eax,(%esp)
8010608e:	e8 09 b9 ff ff       	call   8010199c <iunlock>

  f->type = FD_INODE;
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010609c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060a2:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b2:	83 e0 01             	and    $0x1,%eax
801060b5:	85 c0                	test   %eax,%eax
801060b7:	0f 94 c0             	sete   %al
801060ba:	89 c2                	mov    %eax,%edx
801060bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bf:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c5:	83 e0 01             	and    $0x1,%eax
801060c8:	85 c0                	test   %eax,%eax
801060ca:	75 0a                	jne    801060d6 <sys_open+0x16f>
801060cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060cf:	83 e0 02             	and    $0x2,%eax
801060d2:	85 c0                	test   %eax,%eax
801060d4:	74 07                	je     801060dd <sys_open+0x176>
801060d6:	b8 01 00 00 00       	mov    $0x1,%eax
801060db:	eb 05                	jmp    801060e2 <sys_open+0x17b>
801060dd:	b8 00 00 00 00       	mov    $0x0,%eax
801060e2:	89 c2                	mov    %eax,%edx
801060e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e7:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060ed:	c9                   	leave  
801060ee:	c3                   	ret    

801060ef <sys_mkdir>:

int
sys_mkdir(void)
{
801060ef:	55                   	push   %ebp
801060f0:	89 e5                	mov    %esp,%ebp
801060f2:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801060f5:	e8 6a d4 ff ff       	call   80103564 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106108:	e8 c6 f3 ff ff       	call   801054d3 <argstr>
8010610d:	85 c0                	test   %eax,%eax
8010610f:	78 2c                	js     8010613d <sys_mkdir+0x4e>
80106111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106114:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010611b:	00 
8010611c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106123:	00 
80106124:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010612b:	00 
8010612c:	89 04 24             	mov    %eax,(%esp)
8010612f:	e8 73 fc ff ff       	call   80105da7 <create>
80106134:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106137:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010613b:	75 0c                	jne    80106149 <sys_mkdir+0x5a>
    commit_trans();
8010613d:	e8 6b d4 ff ff       	call   801035ad <commit_trans>
    return -1;
80106142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106147:	eb 15                	jmp    8010615e <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614c:	89 04 24             	mov    %eax,(%esp)
8010614f:	e8 7e b9 ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
80106154:	e8 54 d4 ff ff       	call   801035ad <commit_trans>
  return 0;
80106159:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010615e:	c9                   	leave  
8010615f:	c3                   	ret    

80106160 <sys_mknod>:

int
sys_mknod(void)
{
80106160:	55                   	push   %ebp
80106161:	89 e5                	mov    %esp,%ebp
80106163:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80106166:	e8 f9 d3 ff ff       	call   80103564 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010616b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010616e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106179:	e8 55 f3 ff ff       	call   801054d3 <argstr>
8010617e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106181:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106185:	78 5e                	js     801061e5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106187:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010618a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010618e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106195:	e8 9f f2 ff ff       	call   80105439 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010619a:	85 c0                	test   %eax,%eax
8010619c:	78 47                	js     801061e5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010619e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801061a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061ac:	e8 88 f2 ff ff       	call   80105439 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061b1:	85 c0                	test   %eax,%eax
801061b3:	78 30                	js     801061e5 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061b8:	0f bf c8             	movswl %ax,%ecx
801061bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061be:	0f bf d0             	movswl %ax,%edx
801061c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061c4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061c8:	89 54 24 08          	mov    %edx,0x8(%esp)
801061cc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061d3:	00 
801061d4:	89 04 24             	mov    %eax,(%esp)
801061d7:	e8 cb fb ff ff       	call   80105da7 <create>
801061dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e3:	75 0c                	jne    801061f1 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801061e5:	e8 c3 d3 ff ff       	call   801035ad <commit_trans>
    return -1;
801061ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ef:	eb 15                	jmp    80106206 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801061f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f4:	89 04 24             	mov    %eax,(%esp)
801061f7:	e8 d6 b8 ff ff       	call   80101ad2 <iunlockput>
  commit_trans();
801061fc:	e8 ac d3 ff ff       	call   801035ad <commit_trans>
  return 0;
80106201:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106206:	c9                   	leave  
80106207:	c3                   	ret    

80106208 <sys_chdir>:

int
sys_chdir(void)
{
80106208:	55                   	push   %ebp
80106209:	89 e5                	mov    %esp,%ebp
8010620b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
8010620e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106211:	89 44 24 04          	mov    %eax,0x4(%esp)
80106215:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621c:	e8 b2 f2 ff ff       	call   801054d3 <argstr>
80106221:	85 c0                	test   %eax,%eax
80106223:	78 14                	js     80106239 <sys_chdir+0x31>
80106225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106228:	89 04 24             	mov    %eax,(%esp)
8010622b:	e8 35 c5 ff ff       	call   80102765 <namei>
80106230:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106237:	75 07                	jne    80106240 <sys_chdir+0x38>
    return -1;
80106239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623e:	eb 57                	jmp    80106297 <sys_chdir+0x8f>
  ilock(ip);
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	89 04 24             	mov    %eax,(%esp)
80106246:	e8 03 b6 ff ff       	call   8010184e <ilock>
  if(ip->type != T_DIR){
8010624b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106252:	66 83 f8 01          	cmp    $0x1,%ax
80106256:	74 12                	je     8010626a <sys_chdir+0x62>
    iunlockput(ip);
80106258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625b:	89 04 24             	mov    %eax,(%esp)
8010625e:	e8 6f b8 ff ff       	call   80101ad2 <iunlockput>
    return -1;
80106263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106268:	eb 2d                	jmp    80106297 <sys_chdir+0x8f>
  }
  iunlock(ip);
8010626a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626d:	89 04 24             	mov    %eax,(%esp)
80106270:	e8 27 b7 ff ff       	call   8010199c <iunlock>
  iput(proc->cwd);
80106275:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010627b:	8b 40 68             	mov    0x68(%eax),%eax
8010627e:	89 04 24             	mov    %eax,(%esp)
80106281:	e8 7b b7 ff ff       	call   80101a01 <iput>
  proc->cwd = ip;
80106286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010628c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010628f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106292:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106297:	c9                   	leave  
80106298:	c3                   	ret    

80106299 <sys_exec>:

int
sys_exec(void)
{
80106299:	55                   	push   %ebp
8010629a:	89 e5                	mov    %esp,%ebp
8010629c:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b0:	e8 1e f2 ff ff       	call   801054d3 <argstr>
801062b5:	85 c0                	test   %eax,%eax
801062b7:	78 1a                	js     801062d3 <sys_exec+0x3a>
801062b9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062ca:	e8 6a f1 ff ff       	call   80105439 <argint>
801062cf:	85 c0                	test   %eax,%eax
801062d1:	79 0a                	jns    801062dd <sys_exec+0x44>
    return -1;
801062d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d8:	e9 de 00 00 00       	jmp    801063bb <sys_exec+0x122>
  }
  memset(argv, 0, sizeof(argv));
801062dd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801062e4:	00 
801062e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062ec:	00 
801062ed:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062f3:	89 04 24             	mov    %eax,(%esp)
801062f6:	e8 08 ee ff ff       	call   80105103 <memset>
  for(i=0;; i++){
801062fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106305:	83 f8 1f             	cmp    $0x1f,%eax
80106308:	76 0a                	jbe    80106314 <sys_exec+0x7b>
      return -1;
8010630a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630f:	e9 a7 00 00 00       	jmp    801063bb <sys_exec+0x122>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80106314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106317:	c1 e0 02             	shl    $0x2,%eax
8010631a:	89 c2                	mov    %eax,%edx
8010631c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106322:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80106325:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010632b:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106331:	89 54 24 08          	mov    %edx,0x8(%esp)
80106335:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106339:	89 04 24             	mov    %eax,(%esp)
8010633c:	e8 68 f0 ff ff       	call   801053a9 <fetchint>
80106341:	85 c0                	test   %eax,%eax
80106343:	79 07                	jns    8010634c <sys_exec+0xb3>
      return -1;
80106345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634a:	eb 6f                	jmp    801063bb <sys_exec+0x122>
    if(uarg == 0){
8010634c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106352:	85 c0                	test   %eax,%eax
80106354:	75 26                	jne    8010637c <sys_exec+0xe3>
      argv[i] = 0;
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106360:	00 00 00 00 
      break;
80106364:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106365:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106368:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010636e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106372:	89 04 24             	mov    %eax,(%esp)
80106375:	e8 75 a7 ff ff       	call   80100aef <exec>
8010637a:	eb 3f                	jmp    801063bb <sys_exec+0x122>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
8010637c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106382:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106385:	c1 e2 02             	shl    $0x2,%edx
80106388:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010638b:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106391:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106397:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010639b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010639f:	89 04 24             	mov    %eax,(%esp)
801063a2:	e8 36 f0 ff ff       	call   801053dd <fetchstr>
801063a7:	85 c0                	test   %eax,%eax
801063a9:	79 07                	jns    801063b2 <sys_exec+0x119>
      return -1;
801063ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b0:	eb 09                	jmp    801063bb <sys_exec+0x122>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801063b6:	e9 47 ff ff ff       	jmp    80106302 <sys_exec+0x69>
  return exec(path, argv);
}
801063bb:	c9                   	leave  
801063bc:	c3                   	ret    

801063bd <sys_pipe>:

int
sys_pipe(void)
{
801063bd:	55                   	push   %ebp
801063be:	89 e5                	mov    %esp,%ebp
801063c0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063c3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801063ca:	00 
801063cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d9:	e8 93 f0 ff ff       	call   80105471 <argptr>
801063de:	85 c0                	test   %eax,%eax
801063e0:	79 0a                	jns    801063ec <sys_pipe+0x2f>
    return -1;
801063e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e7:	e9 9b 00 00 00       	jmp    80106487 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801063ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063f6:	89 04 24             	mov    %eax,(%esp)
801063f9:	e8 60 db ff ff       	call   80103f5e <pipealloc>
801063fe:	85 c0                	test   %eax,%eax
80106400:	79 07                	jns    80106409 <sys_pipe+0x4c>
    return -1;
80106402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106407:	eb 7e                	jmp    80106487 <sys_pipe+0xca>
  fd0 = -1;
80106409:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106410:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106413:	89 04 24             	mov    %eax,(%esp)
80106416:	e8 33 f2 ff ff       	call   8010564e <fdalloc>
8010641b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010641e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106422:	78 14                	js     80106438 <sys_pipe+0x7b>
80106424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106427:	89 04 24             	mov    %eax,(%esp)
8010642a:	e8 1f f2 ff ff       	call   8010564e <fdalloc>
8010642f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106432:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106436:	79 37                	jns    8010646f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106438:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010643c:	78 14                	js     80106452 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010643e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106444:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106447:	83 c2 08             	add    $0x8,%edx
8010644a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106451:	00 
    fileclose(rf);
80106452:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106455:	89 04 24             	mov    %eax,(%esp)
80106458:	e8 64 ab ff ff       	call   80100fc1 <fileclose>
    fileclose(wf);
8010645d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106460:	89 04 24             	mov    %eax,(%esp)
80106463:	e8 59 ab ff ff       	call   80100fc1 <fileclose>
    return -1;
80106468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646d:	eb 18                	jmp    80106487 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010646f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106472:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106475:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010647a:	8d 50 04             	lea    0x4(%eax),%edx
8010647d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106480:	89 02                	mov    %eax,(%edx)
  return 0;
80106482:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106487:	c9                   	leave  
80106488:	c3                   	ret    

80106489 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106489:	55                   	push   %ebp
8010648a:	89 e5                	mov    %esp,%ebp
8010648c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010648f:	e8 7c e1 ff ff       	call   80104610 <fork>
}
80106494:	c9                   	leave  
80106495:	c3                   	ret    

80106496 <sys_exit>:

int
sys_exit(void)
{
80106496:	55                   	push   %ebp
80106497:	89 e5                	mov    %esp,%ebp
80106499:	83 ec 08             	sub    $0x8,%esp
  exit();
8010649c:	e8 d2 e2 ff ff       	call   80104773 <exit>
  return 0;  // not reached
801064a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a6:	c9                   	leave  
801064a7:	c3                   	ret    

801064a8 <sys_wait>:

int
sys_wait(void)
{
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064ae:	e8 d8 e3 ff ff       	call   8010488b <wait>
}
801064b3:	c9                   	leave  
801064b4:	c3                   	ret    

801064b5 <sys_kill>:

int
sys_kill(void)
{
801064b5:	55                   	push   %ebp
801064b6:	89 e5                	mov    %esp,%ebp
801064b8:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064be:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064c9:	e8 6b ef ff ff       	call   80105439 <argint>
801064ce:	85 c0                	test   %eax,%eax
801064d0:	79 07                	jns    801064d9 <sys_kill+0x24>
    return -1;
801064d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d7:	eb 0b                	jmp    801064e4 <sys_kill+0x2f>
  return kill(pid);
801064d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064dc:	89 04 24             	mov    %eax,(%esp)
801064df:	e8 05 e8 ff ff       	call   80104ce9 <kill>
}
801064e4:	c9                   	leave  
801064e5:	c3                   	ret    

801064e6 <sys_getpid>:

int
sys_getpid(void)
{
801064e6:	55                   	push   %ebp
801064e7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801064e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ef:	8b 40 10             	mov    0x10(%eax),%eax
}
801064f2:	5d                   	pop    %ebp
801064f3:	c3                   	ret    

801064f4 <sys_sbrk>:

int
sys_sbrk(void)
{
801064f4:	55                   	push   %ebp
801064f5:	89 e5                	mov    %esp,%ebp
801064f7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106501:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106508:	e8 2c ef ff ff       	call   80105439 <argint>
8010650d:	85 c0                	test   %eax,%eax
8010650f:	79 07                	jns    80106518 <sys_sbrk+0x24>
    return -1;
80106511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106516:	eb 24                	jmp    8010653c <sys_sbrk+0x48>
  addr = proc->sz;
80106518:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010651e:	8b 00                	mov    (%eax),%eax
80106520:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106526:	89 04 24             	mov    %eax,(%esp)
80106529:	e8 3d e0 ff ff       	call   8010456b <growproc>
8010652e:	85 c0                	test   %eax,%eax
80106530:	79 07                	jns    80106539 <sys_sbrk+0x45>
    return -1;
80106532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106537:	eb 03                	jmp    8010653c <sys_sbrk+0x48>
  return addr;
80106539:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010653c:	c9                   	leave  
8010653d:	c3                   	ret    

8010653e <sys_sleep>:

int
sys_sleep(void)
{
8010653e:	55                   	push   %ebp
8010653f:	89 e5                	mov    %esp,%ebp
80106541:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106544:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106547:	89 44 24 04          	mov    %eax,0x4(%esp)
8010654b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106552:	e8 e2 ee ff ff       	call   80105439 <argint>
80106557:	85 c0                	test   %eax,%eax
80106559:	79 07                	jns    80106562 <sys_sleep+0x24>
    return -1;
8010655b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106560:	eb 6c                	jmp    801065ce <sys_sleep+0x90>
  acquire(&tickslock);
80106562:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
80106569:	e8 41 e9 ff ff       	call   80104eaf <acquire>
  ticks0 = ticks;
8010656e:	a1 60 27 11 80       	mov    0x80112760,%eax
80106573:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106576:	eb 34                	jmp    801065ac <sys_sleep+0x6e>
    if(proc->killed){
80106578:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010657e:	8b 40 24             	mov    0x24(%eax),%eax
80106581:	85 c0                	test   %eax,%eax
80106583:	74 13                	je     80106598 <sys_sleep+0x5a>
      release(&tickslock);
80106585:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010658c:	e8 80 e9 ff ff       	call   80104f11 <release>
      return -1;
80106591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106596:	eb 36                	jmp    801065ce <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106598:	c7 44 24 04 20 1f 11 	movl   $0x80111f20,0x4(%esp)
8010659f:	80 
801065a0:	c7 04 24 60 27 11 80 	movl   $0x80112760,(%esp)
801065a7:	e8 39 e6 ff ff       	call   80104be5 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065ac:	a1 60 27 11 80       	mov    0x80112760,%eax
801065b1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065b4:	89 c2                	mov    %eax,%edx
801065b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b9:	39 c2                	cmp    %eax,%edx
801065bb:	72 bb                	jb     80106578 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801065bd:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801065c4:	e8 48 e9 ff ff       	call   80104f11 <release>
  return 0;
801065c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ce:	c9                   	leave  
801065cf:	c3                   	ret    

801065d0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065d0:	55                   	push   %ebp
801065d1:	89 e5                	mov    %esp,%ebp
801065d3:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801065d6:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801065dd:	e8 cd e8 ff ff       	call   80104eaf <acquire>
  xticks = ticks;
801065e2:	a1 60 27 11 80       	mov    0x80112760,%eax
801065e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065ea:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801065f1:	e8 1b e9 ff ff       	call   80104f11 <release>
  return xticks;
801065f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065f9:	c9                   	leave  
801065fa:	c3                   	ret    

801065fb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801065fb:	55                   	push   %ebp
801065fc:	89 e5                	mov    %esp,%ebp
801065fe:	83 ec 08             	sub    $0x8,%esp
80106601:	8b 55 08             	mov    0x8(%ebp),%edx
80106604:	8b 45 0c             	mov    0xc(%ebp),%eax
80106607:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010660b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010660e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106612:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106616:	ee                   	out    %al,(%dx)
}
80106617:	c9                   	leave  
80106618:	c3                   	ret    

80106619 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106619:	55                   	push   %ebp
8010661a:	89 e5                	mov    %esp,%ebp
8010661c:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010661f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106626:	00 
80106627:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010662e:	e8 c8 ff ff ff       	call   801065fb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106633:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010663a:	00 
8010663b:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106642:	e8 b4 ff ff ff       	call   801065fb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106647:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010664e:	00 
8010664f:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106656:	e8 a0 ff ff ff       	call   801065fb <outb>
  picenable(IRQ_TIMER);
8010665b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106662:	e8 8a d7 ff ff       	call   80103df1 <picenable>
}
80106667:	c9                   	leave  
80106668:	c3                   	ret    

80106669 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106669:	1e                   	push   %ds
  pushl %es
8010666a:	06                   	push   %es
  pushl %fs
8010666b:	0f a0                	push   %fs
  pushl %gs
8010666d:	0f a8                	push   %gs
  pushal
8010666f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106670:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106674:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106676:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106678:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010667c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010667e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106680:	54                   	push   %esp
  call trap
80106681:	e8 d8 01 00 00       	call   8010685e <trap>
  addl $4, %esp
80106686:	83 c4 04             	add    $0x4,%esp

80106689 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106689:	61                   	popa   
  popl %gs
8010668a:	0f a9                	pop    %gs
  popl %fs
8010668c:	0f a1                	pop    %fs
  popl %es
8010668e:	07                   	pop    %es
  popl %ds
8010668f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106690:	83 c4 08             	add    $0x8,%esp
  iret
80106693:	cf                   	iret   

80106694 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106694:	55                   	push   %ebp
80106695:	89 e5                	mov    %esp,%ebp
80106697:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010669a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010669d:	83 e8 01             	sub    $0x1,%eax
801066a0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066a4:	8b 45 08             	mov    0x8(%ebp),%eax
801066a7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066ab:	8b 45 08             	mov    0x8(%ebp),%eax
801066ae:	c1 e8 10             	shr    $0x10,%eax
801066b1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066b5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066b8:	0f 01 18             	lidtl  (%eax)
}
801066bb:	c9                   	leave  
801066bc:	c3                   	ret    

801066bd <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801066bd:	55                   	push   %ebp
801066be:	89 e5                	mov    %esp,%ebp
801066c0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066c3:	0f 20 d0             	mov    %cr2,%eax
801066c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066cc:	c9                   	leave  
801066cd:	c3                   	ret    

801066ce <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066ce:	55                   	push   %ebp
801066cf:	89 e5                	mov    %esp,%ebp
801066d1:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801066d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066db:	e9 c3 00 00 00       	jmp    801067a3 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e3:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801066ea:	89 c2                	mov    %eax,%edx
801066ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ef:	66 89 14 c5 60 1f 11 	mov    %dx,-0x7feee0a0(,%eax,8)
801066f6:	80 
801066f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fa:	66 c7 04 c5 62 1f 11 	movw   $0x8,-0x7feee09e(,%eax,8)
80106701:	80 08 00 
80106704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106707:	0f b6 14 c5 64 1f 11 	movzbl -0x7feee09c(,%eax,8),%edx
8010670e:	80 
8010670f:	83 e2 e0             	and    $0xffffffe0,%edx
80106712:	88 14 c5 64 1f 11 80 	mov    %dl,-0x7feee09c(,%eax,8)
80106719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671c:	0f b6 14 c5 64 1f 11 	movzbl -0x7feee09c(,%eax,8),%edx
80106723:	80 
80106724:	83 e2 1f             	and    $0x1f,%edx
80106727:	88 14 c5 64 1f 11 80 	mov    %dl,-0x7feee09c(,%eax,8)
8010672e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106731:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
80106738:	80 
80106739:	83 e2 f0             	and    $0xfffffff0,%edx
8010673c:	83 ca 0e             	or     $0xe,%edx
8010673f:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
80106746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106749:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
80106750:	80 
80106751:	83 e2 ef             	and    $0xffffffef,%edx
80106754:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
8010675b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675e:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
80106765:	80 
80106766:	83 e2 9f             	and    $0xffffff9f,%edx
80106769:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
80106770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106773:	0f b6 14 c5 65 1f 11 	movzbl -0x7feee09b(,%eax,8),%edx
8010677a:	80 
8010677b:	83 ca 80             	or     $0xffffff80,%edx
8010677e:	88 14 c5 65 1f 11 80 	mov    %dl,-0x7feee09b(,%eax,8)
80106785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106788:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010678f:	c1 e8 10             	shr    $0x10,%eax
80106792:	89 c2                	mov    %eax,%edx
80106794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106797:	66 89 14 c5 66 1f 11 	mov    %dx,-0x7feee09a(,%eax,8)
8010679e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010679f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067a3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067aa:	0f 8e 30 ff ff ff    	jle    801066e0 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067b0:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801067b5:	66 a3 60 21 11 80    	mov    %ax,0x80112160
801067bb:	66 c7 05 62 21 11 80 	movw   $0x8,0x80112162
801067c2:	08 00 
801067c4:	0f b6 05 64 21 11 80 	movzbl 0x80112164,%eax
801067cb:	83 e0 e0             	and    $0xffffffe0,%eax
801067ce:	a2 64 21 11 80       	mov    %al,0x80112164
801067d3:	0f b6 05 64 21 11 80 	movzbl 0x80112164,%eax
801067da:	83 e0 1f             	and    $0x1f,%eax
801067dd:	a2 64 21 11 80       	mov    %al,0x80112164
801067e2:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
801067e9:	83 c8 0f             	or     $0xf,%eax
801067ec:	a2 65 21 11 80       	mov    %al,0x80112165
801067f1:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
801067f8:	83 e0 ef             	and    $0xffffffef,%eax
801067fb:	a2 65 21 11 80       	mov    %al,0x80112165
80106800:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106807:	83 c8 60             	or     $0x60,%eax
8010680a:	a2 65 21 11 80       	mov    %al,0x80112165
8010680f:	0f b6 05 65 21 11 80 	movzbl 0x80112165,%eax
80106816:	83 c8 80             	or     $0xffffff80,%eax
80106819:	a2 65 21 11 80       	mov    %al,0x80112165
8010681e:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106823:	c1 e8 10             	shr    $0x10,%eax
80106826:	66 a3 66 21 11 80    	mov    %ax,0x80112166
  
  initlock(&tickslock, "time");
8010682c:	c7 44 24 04 6c 8a 10 	movl   $0x80108a6c,0x4(%esp)
80106833:	80 
80106834:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
8010683b:	e8 4e e6 ff ff       	call   80104e8e <initlock>
}
80106840:	c9                   	leave  
80106841:	c3                   	ret    

80106842 <idtinit>:

void
idtinit(void)
{
80106842:	55                   	push   %ebp
80106843:	89 e5                	mov    %esp,%ebp
80106845:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106848:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010684f:	00 
80106850:	c7 04 24 60 1f 11 80 	movl   $0x80111f60,(%esp)
80106857:	e8 38 fe ff ff       	call   80106694 <lidt>
}
8010685c:	c9                   	leave  
8010685d:	c3                   	ret    

8010685e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010685e:	55                   	push   %ebp
8010685f:	89 e5                	mov    %esp,%ebp
80106861:	57                   	push   %edi
80106862:	56                   	push   %esi
80106863:	53                   	push   %ebx
80106864:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106867:	8b 45 08             	mov    0x8(%ebp),%eax
8010686a:	8b 40 30             	mov    0x30(%eax),%eax
8010686d:	83 f8 40             	cmp    $0x40,%eax
80106870:	75 3f                	jne    801068b1 <trap+0x53>
    if(proc->killed)
80106872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106878:	8b 40 24             	mov    0x24(%eax),%eax
8010687b:	85 c0                	test   %eax,%eax
8010687d:	74 05                	je     80106884 <trap+0x26>
      exit();
8010687f:	e8 ef de ff ff       	call   80104773 <exit>
    proc->tf = tf;
80106884:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010688a:	8b 55 08             	mov    0x8(%ebp),%edx
8010688d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106890:	e8 81 ec ff ff       	call   80105516 <syscall>
    if(proc->killed)
80106895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010689b:	8b 40 24             	mov    0x24(%eax),%eax
8010689e:	85 c0                	test   %eax,%eax
801068a0:	74 0a                	je     801068ac <trap+0x4e>
      exit();
801068a2:	e8 cc de ff ff       	call   80104773 <exit>
    return;
801068a7:	e9 2d 02 00 00       	jmp    80106ad9 <trap+0x27b>
801068ac:	e9 28 02 00 00       	jmp    80106ad9 <trap+0x27b>
  }

  switch(tf->trapno){
801068b1:	8b 45 08             	mov    0x8(%ebp),%eax
801068b4:	8b 40 30             	mov    0x30(%eax),%eax
801068b7:	83 e8 20             	sub    $0x20,%eax
801068ba:	83 f8 1f             	cmp    $0x1f,%eax
801068bd:	0f 87 bc 00 00 00    	ja     8010697f <trap+0x121>
801068c3:	8b 04 85 14 8b 10 80 	mov    -0x7fef74ec(,%eax,4),%eax
801068ca:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801068cc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068d2:	0f b6 00             	movzbl (%eax),%eax
801068d5:	84 c0                	test   %al,%al
801068d7:	75 31                	jne    8010690a <trap+0xac>
      acquire(&tickslock);
801068d9:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
801068e0:	e8 ca e5 ff ff       	call   80104eaf <acquire>
      ticks++;
801068e5:	a1 60 27 11 80       	mov    0x80112760,%eax
801068ea:	83 c0 01             	add    $0x1,%eax
801068ed:	a3 60 27 11 80       	mov    %eax,0x80112760
      wakeup(&ticks);
801068f2:	c7 04 24 60 27 11 80 	movl   $0x80112760,(%esp)
801068f9:	e8 c0 e3 ff ff       	call   80104cbe <wakeup>
      release(&tickslock);
801068fe:	c7 04 24 20 1f 11 80 	movl   $0x80111f20,(%esp)
80106905:	e8 07 e6 ff ff       	call   80104f11 <release>
    }
    lapiceoi();
8010690a:	e8 23 c9 ff ff       	call   80103232 <lapiceoi>
    break;
8010690f:	e9 41 01 00 00       	jmp    80106a55 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106914:	e8 44 c1 ff ff       	call   80102a5d <ideintr>
    lapiceoi();
80106919:	e8 14 c9 ff ff       	call   80103232 <lapiceoi>
    break;
8010691e:	e9 32 01 00 00       	jmp    80106a55 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106923:	e8 f6 c6 ff ff       	call   8010301e <kbdintr>
    lapiceoi();
80106928:	e8 05 c9 ff ff       	call   80103232 <lapiceoi>
    break;
8010692d:	e9 23 01 00 00       	jmp    80106a55 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106932:	e8 97 03 00 00       	call   80106cce <uartintr>
    lapiceoi();
80106937:	e8 f6 c8 ff ff       	call   80103232 <lapiceoi>
    break;
8010693c:	e9 14 01 00 00       	jmp    80106a55 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106941:	8b 45 08             	mov    0x8(%ebp),%eax
80106944:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106947:	8b 45 08             	mov    0x8(%ebp),%eax
8010694a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010694e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106951:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106957:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010695a:	0f b6 c0             	movzbl %al,%eax
8010695d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106961:	89 54 24 08          	mov    %edx,0x8(%esp)
80106965:	89 44 24 04          	mov    %eax,0x4(%esp)
80106969:	c7 04 24 74 8a 10 80 	movl   $0x80108a74,(%esp)
80106970:	e8 2b 9a ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106975:	e8 b8 c8 ff ff       	call   80103232 <lapiceoi>
    break;
8010697a:	e9 d6 00 00 00       	jmp    80106a55 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010697f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106985:	85 c0                	test   %eax,%eax
80106987:	74 11                	je     8010699a <trap+0x13c>
80106989:	8b 45 08             	mov    0x8(%ebp),%eax
8010698c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106990:	0f b7 c0             	movzwl %ax,%eax
80106993:	83 e0 03             	and    $0x3,%eax
80106996:	85 c0                	test   %eax,%eax
80106998:	75 46                	jne    801069e0 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010699a:	e8 1e fd ff ff       	call   801066bd <rcr2>
8010699f:	8b 55 08             	mov    0x8(%ebp),%edx
801069a2:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069a5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069ac:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069af:	0f b6 ca             	movzbl %dl,%ecx
801069b2:	8b 55 08             	mov    0x8(%ebp),%edx
801069b5:	8b 52 30             	mov    0x30(%edx),%edx
801069b8:	89 44 24 10          	mov    %eax,0x10(%esp)
801069bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801069c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801069c8:	c7 04 24 98 8a 10 80 	movl   $0x80108a98,(%esp)
801069cf:	e8 cc 99 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801069d4:	c7 04 24 ca 8a 10 80 	movl   $0x80108aca,(%esp)
801069db:	e8 5a 9b ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069e0:	e8 d8 fc ff ff       	call   801066bd <rcr2>
801069e5:	89 c2                	mov    %eax,%edx
801069e7:	8b 45 08             	mov    0x8(%ebp),%eax
801069ea:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f3:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069f6:	0f b6 f0             	movzbl %al,%esi
801069f9:	8b 45 08             	mov    0x8(%ebp),%eax
801069fc:	8b 58 34             	mov    0x34(%eax),%ebx
801069ff:	8b 45 08             	mov    0x8(%ebp),%eax
80106a02:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a0b:	83 c0 6c             	add    $0x6c,%eax
80106a0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a17:	8b 40 10             	mov    0x10(%eax),%eax
80106a1a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106a1e:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106a22:	89 74 24 14          	mov    %esi,0x14(%esp)
80106a26:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106a2a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106a31:	89 74 24 08          	mov    %esi,0x8(%esp)
80106a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a39:	c7 04 24 d0 8a 10 80 	movl   $0x80108ad0,(%esp)
80106a40:	e8 5b 99 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a52:	eb 01                	jmp    80106a55 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a54:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a5b:	85 c0                	test   %eax,%eax
80106a5d:	74 24                	je     80106a83 <trap+0x225>
80106a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a65:	8b 40 24             	mov    0x24(%eax),%eax
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	74 17                	je     80106a83 <trap+0x225>
80106a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a73:	0f b7 c0             	movzwl %ax,%eax
80106a76:	83 e0 03             	and    $0x3,%eax
80106a79:	83 f8 03             	cmp    $0x3,%eax
80106a7c:	75 05                	jne    80106a83 <trap+0x225>
    exit();
80106a7e:	e8 f0 dc ff ff       	call   80104773 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a89:	85 c0                	test   %eax,%eax
80106a8b:	74 1e                	je     80106aab <trap+0x24d>
80106a8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a93:	8b 40 0c             	mov    0xc(%eax),%eax
80106a96:	83 f8 04             	cmp    $0x4,%eax
80106a99:	75 10                	jne    80106aab <trap+0x24d>
80106a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9e:	8b 40 30             	mov    0x30(%eax),%eax
80106aa1:	83 f8 20             	cmp    $0x20,%eax
80106aa4:	75 05                	jne    80106aab <trap+0x24d>
    yield();
80106aa6:	e8 dc e0 ff ff       	call   80104b87 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106aab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	74 24                	je     80106ad9 <trap+0x27b>
80106ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abb:	8b 40 24             	mov    0x24(%eax),%eax
80106abe:	85 c0                	test   %eax,%eax
80106ac0:	74 17                	je     80106ad9 <trap+0x27b>
80106ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ac9:	0f b7 c0             	movzwl %ax,%eax
80106acc:	83 e0 03             	and    $0x3,%eax
80106acf:	83 f8 03             	cmp    $0x3,%eax
80106ad2:	75 05                	jne    80106ad9 <trap+0x27b>
    exit();
80106ad4:	e8 9a dc ff ff       	call   80104773 <exit>
}
80106ad9:	83 c4 3c             	add    $0x3c,%esp
80106adc:	5b                   	pop    %ebx
80106add:	5e                   	pop    %esi
80106ade:	5f                   	pop    %edi
80106adf:	5d                   	pop    %ebp
80106ae0:	c3                   	ret    

80106ae1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106ae1:	55                   	push   %ebp
80106ae2:	89 e5                	mov    %esp,%ebp
80106ae4:	83 ec 14             	sub    $0x14,%esp
80106ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80106aea:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106aee:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106af2:	89 c2                	mov    %eax,%edx
80106af4:	ec                   	in     (%dx),%al
80106af5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106af8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106afc:	c9                   	leave  
80106afd:	c3                   	ret    

80106afe <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106afe:	55                   	push   %ebp
80106aff:	89 e5                	mov    %esp,%ebp
80106b01:	83 ec 08             	sub    $0x8,%esp
80106b04:	8b 55 08             	mov    0x8(%ebp),%edx
80106b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b0a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b0e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b11:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b15:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b19:	ee                   	out    %al,(%dx)
}
80106b1a:	c9                   	leave  
80106b1b:	c3                   	ret    

80106b1c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b1c:	55                   	push   %ebp
80106b1d:	89 e5                	mov    %esp,%ebp
80106b1f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b29:	00 
80106b2a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b31:	e8 c8 ff ff ff       	call   80106afe <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b36:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106b3d:	00 
80106b3e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b45:	e8 b4 ff ff ff       	call   80106afe <outb>
  outb(COM1+0, 115200/9600);
80106b4a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106b51:	00 
80106b52:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b59:	e8 a0 ff ff ff       	call   80106afe <outb>
  outb(COM1+1, 0);
80106b5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b65:	00 
80106b66:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b6d:	e8 8c ff ff ff       	call   80106afe <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b72:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b79:	00 
80106b7a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b81:	e8 78 ff ff ff       	call   80106afe <outb>
  outb(COM1+4, 0);
80106b86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b8d:	00 
80106b8e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106b95:	e8 64 ff ff ff       	call   80106afe <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106ba1:	00 
80106ba2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ba9:	e8 50 ff ff ff       	call   80106afe <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bae:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106bb5:	e8 27 ff ff ff       	call   80106ae1 <inb>
80106bba:	3c ff                	cmp    $0xff,%al
80106bbc:	75 02                	jne    80106bc0 <uartinit+0xa4>
    return;
80106bbe:	eb 6a                	jmp    80106c2a <uartinit+0x10e>
  uart = 1;
80106bc0:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106bc7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bca:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bd1:	e8 0b ff ff ff       	call   80106ae1 <inb>
  inb(COM1+0);
80106bd6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106bdd:	e8 ff fe ff ff       	call   80106ae1 <inb>
  picenable(IRQ_COM1);
80106be2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106be9:	e8 03 d2 ff ff       	call   80103df1 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106bee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106bf5:	00 
80106bf6:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106bfd:	e8 da c0 ff ff       	call   80102cdc <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c02:	c7 45 f4 94 8b 10 80 	movl   $0x80108b94,-0xc(%ebp)
80106c09:	eb 15                	jmp    80106c20 <uartinit+0x104>
    uartputc(*p);
80106c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0e:	0f b6 00             	movzbl (%eax),%eax
80106c11:	0f be c0             	movsbl %al,%eax
80106c14:	89 04 24             	mov    %eax,(%esp)
80106c17:	e8 10 00 00 00       	call   80106c2c <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c23:	0f b6 00             	movzbl (%eax),%eax
80106c26:	84 c0                	test   %al,%al
80106c28:	75 e1                	jne    80106c0b <uartinit+0xef>
    uartputc(*p);
}
80106c2a:	c9                   	leave  
80106c2b:	c3                   	ret    

80106c2c <uartputc>:

void
uartputc(int c)
{
80106c2c:	55                   	push   %ebp
80106c2d:	89 e5                	mov    %esp,%ebp
80106c2f:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106c32:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106c37:	85 c0                	test   %eax,%eax
80106c39:	75 02                	jne    80106c3d <uartputc+0x11>
    return;
80106c3b:	eb 4b                	jmp    80106c88 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c44:	eb 10                	jmp    80106c56 <uartputc+0x2a>
    microdelay(10);
80106c46:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106c4d:	e8 05 c6 ff ff       	call   80103257 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c56:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c5a:	7f 16                	jg     80106c72 <uartputc+0x46>
80106c5c:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c63:	e8 79 fe ff ff       	call   80106ae1 <inb>
80106c68:	0f b6 c0             	movzbl %al,%eax
80106c6b:	83 e0 20             	and    $0x20,%eax
80106c6e:	85 c0                	test   %eax,%eax
80106c70:	74 d4                	je     80106c46 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106c72:	8b 45 08             	mov    0x8(%ebp),%eax
80106c75:	0f b6 c0             	movzbl %al,%eax
80106c78:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c7c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c83:	e8 76 fe ff ff       	call   80106afe <outb>
}
80106c88:	c9                   	leave  
80106c89:	c3                   	ret    

80106c8a <uartgetc>:

static int
uartgetc(void)
{
80106c8a:	55                   	push   %ebp
80106c8b:	89 e5                	mov    %esp,%ebp
80106c8d:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106c90:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106c95:	85 c0                	test   %eax,%eax
80106c97:	75 07                	jne    80106ca0 <uartgetc+0x16>
    return -1;
80106c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9e:	eb 2c                	jmp    80106ccc <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106ca0:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ca7:	e8 35 fe ff ff       	call   80106ae1 <inb>
80106cac:	0f b6 c0             	movzbl %al,%eax
80106caf:	83 e0 01             	and    $0x1,%eax
80106cb2:	85 c0                	test   %eax,%eax
80106cb4:	75 07                	jne    80106cbd <uartgetc+0x33>
    return -1;
80106cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbb:	eb 0f                	jmp    80106ccc <uartgetc+0x42>
  return inb(COM1+0);
80106cbd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cc4:	e8 18 fe ff ff       	call   80106ae1 <inb>
80106cc9:	0f b6 c0             	movzbl %al,%eax
}
80106ccc:	c9                   	leave  
80106ccd:	c3                   	ret    

80106cce <uartintr>:

void
uartintr(void)
{
80106cce:	55                   	push   %ebp
80106ccf:	89 e5                	mov    %esp,%ebp
80106cd1:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106cd4:	c7 04 24 8a 6c 10 80 	movl   $0x80106c8a,(%esp)
80106cdb:	e8 cd 9a ff ff       	call   801007ad <consoleintr>
}
80106ce0:	c9                   	leave  
80106ce1:	c3                   	ret    

80106ce2 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $0
80106ce4:	6a 00                	push   $0x0
  jmp alltraps
80106ce6:	e9 7e f9 ff ff       	jmp    80106669 <alltraps>

80106ceb <vector1>:
.globl vector1
vector1:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $1
80106ced:	6a 01                	push   $0x1
  jmp alltraps
80106cef:	e9 75 f9 ff ff       	jmp    80106669 <alltraps>

80106cf4 <vector2>:
.globl vector2
vector2:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $2
80106cf6:	6a 02                	push   $0x2
  jmp alltraps
80106cf8:	e9 6c f9 ff ff       	jmp    80106669 <alltraps>

80106cfd <vector3>:
.globl vector3
vector3:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $3
80106cff:	6a 03                	push   $0x3
  jmp alltraps
80106d01:	e9 63 f9 ff ff       	jmp    80106669 <alltraps>

80106d06 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $4
80106d08:	6a 04                	push   $0x4
  jmp alltraps
80106d0a:	e9 5a f9 ff ff       	jmp    80106669 <alltraps>

80106d0f <vector5>:
.globl vector5
vector5:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $5
80106d11:	6a 05                	push   $0x5
  jmp alltraps
80106d13:	e9 51 f9 ff ff       	jmp    80106669 <alltraps>

80106d18 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $6
80106d1a:	6a 06                	push   $0x6
  jmp alltraps
80106d1c:	e9 48 f9 ff ff       	jmp    80106669 <alltraps>

80106d21 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $7
80106d23:	6a 07                	push   $0x7
  jmp alltraps
80106d25:	e9 3f f9 ff ff       	jmp    80106669 <alltraps>

80106d2a <vector8>:
.globl vector8
vector8:
  pushl $8
80106d2a:	6a 08                	push   $0x8
  jmp alltraps
80106d2c:	e9 38 f9 ff ff       	jmp    80106669 <alltraps>

80106d31 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $9
80106d33:	6a 09                	push   $0x9
  jmp alltraps
80106d35:	e9 2f f9 ff ff       	jmp    80106669 <alltraps>

80106d3a <vector10>:
.globl vector10
vector10:
  pushl $10
80106d3a:	6a 0a                	push   $0xa
  jmp alltraps
80106d3c:	e9 28 f9 ff ff       	jmp    80106669 <alltraps>

80106d41 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d41:	6a 0b                	push   $0xb
  jmp alltraps
80106d43:	e9 21 f9 ff ff       	jmp    80106669 <alltraps>

80106d48 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d48:	6a 0c                	push   $0xc
  jmp alltraps
80106d4a:	e9 1a f9 ff ff       	jmp    80106669 <alltraps>

80106d4f <vector13>:
.globl vector13
vector13:
  pushl $13
80106d4f:	6a 0d                	push   $0xd
  jmp alltraps
80106d51:	e9 13 f9 ff ff       	jmp    80106669 <alltraps>

80106d56 <vector14>:
.globl vector14
vector14:
  pushl $14
80106d56:	6a 0e                	push   $0xe
  jmp alltraps
80106d58:	e9 0c f9 ff ff       	jmp    80106669 <alltraps>

80106d5d <vector15>:
.globl vector15
vector15:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $15
80106d5f:	6a 0f                	push   $0xf
  jmp alltraps
80106d61:	e9 03 f9 ff ff       	jmp    80106669 <alltraps>

80106d66 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $16
80106d68:	6a 10                	push   $0x10
  jmp alltraps
80106d6a:	e9 fa f8 ff ff       	jmp    80106669 <alltraps>

80106d6f <vector17>:
.globl vector17
vector17:
  pushl $17
80106d6f:	6a 11                	push   $0x11
  jmp alltraps
80106d71:	e9 f3 f8 ff ff       	jmp    80106669 <alltraps>

80106d76 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $18
80106d78:	6a 12                	push   $0x12
  jmp alltraps
80106d7a:	e9 ea f8 ff ff       	jmp    80106669 <alltraps>

80106d7f <vector19>:
.globl vector19
vector19:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $19
80106d81:	6a 13                	push   $0x13
  jmp alltraps
80106d83:	e9 e1 f8 ff ff       	jmp    80106669 <alltraps>

80106d88 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d88:	6a 00                	push   $0x0
  pushl $20
80106d8a:	6a 14                	push   $0x14
  jmp alltraps
80106d8c:	e9 d8 f8 ff ff       	jmp    80106669 <alltraps>

80106d91 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $21
80106d93:	6a 15                	push   $0x15
  jmp alltraps
80106d95:	e9 cf f8 ff ff       	jmp    80106669 <alltraps>

80106d9a <vector22>:
.globl vector22
vector22:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $22
80106d9c:	6a 16                	push   $0x16
  jmp alltraps
80106d9e:	e9 c6 f8 ff ff       	jmp    80106669 <alltraps>

80106da3 <vector23>:
.globl vector23
vector23:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $23
80106da5:	6a 17                	push   $0x17
  jmp alltraps
80106da7:	e9 bd f8 ff ff       	jmp    80106669 <alltraps>

80106dac <vector24>:
.globl vector24
vector24:
  pushl $0
80106dac:	6a 00                	push   $0x0
  pushl $24
80106dae:	6a 18                	push   $0x18
  jmp alltraps
80106db0:	e9 b4 f8 ff ff       	jmp    80106669 <alltraps>

80106db5 <vector25>:
.globl vector25
vector25:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $25
80106db7:	6a 19                	push   $0x19
  jmp alltraps
80106db9:	e9 ab f8 ff ff       	jmp    80106669 <alltraps>

80106dbe <vector26>:
.globl vector26
vector26:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $26
80106dc0:	6a 1a                	push   $0x1a
  jmp alltraps
80106dc2:	e9 a2 f8 ff ff       	jmp    80106669 <alltraps>

80106dc7 <vector27>:
.globl vector27
vector27:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $27
80106dc9:	6a 1b                	push   $0x1b
  jmp alltraps
80106dcb:	e9 99 f8 ff ff       	jmp    80106669 <alltraps>

80106dd0 <vector28>:
.globl vector28
vector28:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $28
80106dd2:	6a 1c                	push   $0x1c
  jmp alltraps
80106dd4:	e9 90 f8 ff ff       	jmp    80106669 <alltraps>

80106dd9 <vector29>:
.globl vector29
vector29:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $29
80106ddb:	6a 1d                	push   $0x1d
  jmp alltraps
80106ddd:	e9 87 f8 ff ff       	jmp    80106669 <alltraps>

80106de2 <vector30>:
.globl vector30
vector30:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $30
80106de4:	6a 1e                	push   $0x1e
  jmp alltraps
80106de6:	e9 7e f8 ff ff       	jmp    80106669 <alltraps>

80106deb <vector31>:
.globl vector31
vector31:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $31
80106ded:	6a 1f                	push   $0x1f
  jmp alltraps
80106def:	e9 75 f8 ff ff       	jmp    80106669 <alltraps>

80106df4 <vector32>:
.globl vector32
vector32:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $32
80106df6:	6a 20                	push   $0x20
  jmp alltraps
80106df8:	e9 6c f8 ff ff       	jmp    80106669 <alltraps>

80106dfd <vector33>:
.globl vector33
vector33:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $33
80106dff:	6a 21                	push   $0x21
  jmp alltraps
80106e01:	e9 63 f8 ff ff       	jmp    80106669 <alltraps>

80106e06 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $34
80106e08:	6a 22                	push   $0x22
  jmp alltraps
80106e0a:	e9 5a f8 ff ff       	jmp    80106669 <alltraps>

80106e0f <vector35>:
.globl vector35
vector35:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $35
80106e11:	6a 23                	push   $0x23
  jmp alltraps
80106e13:	e9 51 f8 ff ff       	jmp    80106669 <alltraps>

80106e18 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $36
80106e1a:	6a 24                	push   $0x24
  jmp alltraps
80106e1c:	e9 48 f8 ff ff       	jmp    80106669 <alltraps>

80106e21 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $37
80106e23:	6a 25                	push   $0x25
  jmp alltraps
80106e25:	e9 3f f8 ff ff       	jmp    80106669 <alltraps>

80106e2a <vector38>:
.globl vector38
vector38:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $38
80106e2c:	6a 26                	push   $0x26
  jmp alltraps
80106e2e:	e9 36 f8 ff ff       	jmp    80106669 <alltraps>

80106e33 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $39
80106e35:	6a 27                	push   $0x27
  jmp alltraps
80106e37:	e9 2d f8 ff ff       	jmp    80106669 <alltraps>

80106e3c <vector40>:
.globl vector40
vector40:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $40
80106e3e:	6a 28                	push   $0x28
  jmp alltraps
80106e40:	e9 24 f8 ff ff       	jmp    80106669 <alltraps>

80106e45 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $41
80106e47:	6a 29                	push   $0x29
  jmp alltraps
80106e49:	e9 1b f8 ff ff       	jmp    80106669 <alltraps>

80106e4e <vector42>:
.globl vector42
vector42:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $42
80106e50:	6a 2a                	push   $0x2a
  jmp alltraps
80106e52:	e9 12 f8 ff ff       	jmp    80106669 <alltraps>

80106e57 <vector43>:
.globl vector43
vector43:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $43
80106e59:	6a 2b                	push   $0x2b
  jmp alltraps
80106e5b:	e9 09 f8 ff ff       	jmp    80106669 <alltraps>

80106e60 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $44
80106e62:	6a 2c                	push   $0x2c
  jmp alltraps
80106e64:	e9 00 f8 ff ff       	jmp    80106669 <alltraps>

80106e69 <vector45>:
.globl vector45
vector45:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $45
80106e6b:	6a 2d                	push   $0x2d
  jmp alltraps
80106e6d:	e9 f7 f7 ff ff       	jmp    80106669 <alltraps>

80106e72 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $46
80106e74:	6a 2e                	push   $0x2e
  jmp alltraps
80106e76:	e9 ee f7 ff ff       	jmp    80106669 <alltraps>

80106e7b <vector47>:
.globl vector47
vector47:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $47
80106e7d:	6a 2f                	push   $0x2f
  jmp alltraps
80106e7f:	e9 e5 f7 ff ff       	jmp    80106669 <alltraps>

80106e84 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $48
80106e86:	6a 30                	push   $0x30
  jmp alltraps
80106e88:	e9 dc f7 ff ff       	jmp    80106669 <alltraps>

80106e8d <vector49>:
.globl vector49
vector49:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $49
80106e8f:	6a 31                	push   $0x31
  jmp alltraps
80106e91:	e9 d3 f7 ff ff       	jmp    80106669 <alltraps>

80106e96 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $50
80106e98:	6a 32                	push   $0x32
  jmp alltraps
80106e9a:	e9 ca f7 ff ff       	jmp    80106669 <alltraps>

80106e9f <vector51>:
.globl vector51
vector51:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $51
80106ea1:	6a 33                	push   $0x33
  jmp alltraps
80106ea3:	e9 c1 f7 ff ff       	jmp    80106669 <alltraps>

80106ea8 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $52
80106eaa:	6a 34                	push   $0x34
  jmp alltraps
80106eac:	e9 b8 f7 ff ff       	jmp    80106669 <alltraps>

80106eb1 <vector53>:
.globl vector53
vector53:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $53
80106eb3:	6a 35                	push   $0x35
  jmp alltraps
80106eb5:	e9 af f7 ff ff       	jmp    80106669 <alltraps>

80106eba <vector54>:
.globl vector54
vector54:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $54
80106ebc:	6a 36                	push   $0x36
  jmp alltraps
80106ebe:	e9 a6 f7 ff ff       	jmp    80106669 <alltraps>

80106ec3 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $55
80106ec5:	6a 37                	push   $0x37
  jmp alltraps
80106ec7:	e9 9d f7 ff ff       	jmp    80106669 <alltraps>

80106ecc <vector56>:
.globl vector56
vector56:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $56
80106ece:	6a 38                	push   $0x38
  jmp alltraps
80106ed0:	e9 94 f7 ff ff       	jmp    80106669 <alltraps>

80106ed5 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $57
80106ed7:	6a 39                	push   $0x39
  jmp alltraps
80106ed9:	e9 8b f7 ff ff       	jmp    80106669 <alltraps>

80106ede <vector58>:
.globl vector58
vector58:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $58
80106ee0:	6a 3a                	push   $0x3a
  jmp alltraps
80106ee2:	e9 82 f7 ff ff       	jmp    80106669 <alltraps>

80106ee7 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $59
80106ee9:	6a 3b                	push   $0x3b
  jmp alltraps
80106eeb:	e9 79 f7 ff ff       	jmp    80106669 <alltraps>

80106ef0 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $60
80106ef2:	6a 3c                	push   $0x3c
  jmp alltraps
80106ef4:	e9 70 f7 ff ff       	jmp    80106669 <alltraps>

80106ef9 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $61
80106efb:	6a 3d                	push   $0x3d
  jmp alltraps
80106efd:	e9 67 f7 ff ff       	jmp    80106669 <alltraps>

80106f02 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $62
80106f04:	6a 3e                	push   $0x3e
  jmp alltraps
80106f06:	e9 5e f7 ff ff       	jmp    80106669 <alltraps>

80106f0b <vector63>:
.globl vector63
vector63:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $63
80106f0d:	6a 3f                	push   $0x3f
  jmp alltraps
80106f0f:	e9 55 f7 ff ff       	jmp    80106669 <alltraps>

80106f14 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $64
80106f16:	6a 40                	push   $0x40
  jmp alltraps
80106f18:	e9 4c f7 ff ff       	jmp    80106669 <alltraps>

80106f1d <vector65>:
.globl vector65
vector65:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $65
80106f1f:	6a 41                	push   $0x41
  jmp alltraps
80106f21:	e9 43 f7 ff ff       	jmp    80106669 <alltraps>

80106f26 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $66
80106f28:	6a 42                	push   $0x42
  jmp alltraps
80106f2a:	e9 3a f7 ff ff       	jmp    80106669 <alltraps>

80106f2f <vector67>:
.globl vector67
vector67:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $67
80106f31:	6a 43                	push   $0x43
  jmp alltraps
80106f33:	e9 31 f7 ff ff       	jmp    80106669 <alltraps>

80106f38 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $68
80106f3a:	6a 44                	push   $0x44
  jmp alltraps
80106f3c:	e9 28 f7 ff ff       	jmp    80106669 <alltraps>

80106f41 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $69
80106f43:	6a 45                	push   $0x45
  jmp alltraps
80106f45:	e9 1f f7 ff ff       	jmp    80106669 <alltraps>

80106f4a <vector70>:
.globl vector70
vector70:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $70
80106f4c:	6a 46                	push   $0x46
  jmp alltraps
80106f4e:	e9 16 f7 ff ff       	jmp    80106669 <alltraps>

80106f53 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $71
80106f55:	6a 47                	push   $0x47
  jmp alltraps
80106f57:	e9 0d f7 ff ff       	jmp    80106669 <alltraps>

80106f5c <vector72>:
.globl vector72
vector72:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $72
80106f5e:	6a 48                	push   $0x48
  jmp alltraps
80106f60:	e9 04 f7 ff ff       	jmp    80106669 <alltraps>

80106f65 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $73
80106f67:	6a 49                	push   $0x49
  jmp alltraps
80106f69:	e9 fb f6 ff ff       	jmp    80106669 <alltraps>

80106f6e <vector74>:
.globl vector74
vector74:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $74
80106f70:	6a 4a                	push   $0x4a
  jmp alltraps
80106f72:	e9 f2 f6 ff ff       	jmp    80106669 <alltraps>

80106f77 <vector75>:
.globl vector75
vector75:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $75
80106f79:	6a 4b                	push   $0x4b
  jmp alltraps
80106f7b:	e9 e9 f6 ff ff       	jmp    80106669 <alltraps>

80106f80 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $76
80106f82:	6a 4c                	push   $0x4c
  jmp alltraps
80106f84:	e9 e0 f6 ff ff       	jmp    80106669 <alltraps>

80106f89 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $77
80106f8b:	6a 4d                	push   $0x4d
  jmp alltraps
80106f8d:	e9 d7 f6 ff ff       	jmp    80106669 <alltraps>

80106f92 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $78
80106f94:	6a 4e                	push   $0x4e
  jmp alltraps
80106f96:	e9 ce f6 ff ff       	jmp    80106669 <alltraps>

80106f9b <vector79>:
.globl vector79
vector79:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $79
80106f9d:	6a 4f                	push   $0x4f
  jmp alltraps
80106f9f:	e9 c5 f6 ff ff       	jmp    80106669 <alltraps>

80106fa4 <vector80>:
.globl vector80
vector80:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $80
80106fa6:	6a 50                	push   $0x50
  jmp alltraps
80106fa8:	e9 bc f6 ff ff       	jmp    80106669 <alltraps>

80106fad <vector81>:
.globl vector81
vector81:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $81
80106faf:	6a 51                	push   $0x51
  jmp alltraps
80106fb1:	e9 b3 f6 ff ff       	jmp    80106669 <alltraps>

80106fb6 <vector82>:
.globl vector82
vector82:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $82
80106fb8:	6a 52                	push   $0x52
  jmp alltraps
80106fba:	e9 aa f6 ff ff       	jmp    80106669 <alltraps>

80106fbf <vector83>:
.globl vector83
vector83:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $83
80106fc1:	6a 53                	push   $0x53
  jmp alltraps
80106fc3:	e9 a1 f6 ff ff       	jmp    80106669 <alltraps>

80106fc8 <vector84>:
.globl vector84
vector84:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $84
80106fca:	6a 54                	push   $0x54
  jmp alltraps
80106fcc:	e9 98 f6 ff ff       	jmp    80106669 <alltraps>

80106fd1 <vector85>:
.globl vector85
vector85:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $85
80106fd3:	6a 55                	push   $0x55
  jmp alltraps
80106fd5:	e9 8f f6 ff ff       	jmp    80106669 <alltraps>

80106fda <vector86>:
.globl vector86
vector86:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $86
80106fdc:	6a 56                	push   $0x56
  jmp alltraps
80106fde:	e9 86 f6 ff ff       	jmp    80106669 <alltraps>

80106fe3 <vector87>:
.globl vector87
vector87:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $87
80106fe5:	6a 57                	push   $0x57
  jmp alltraps
80106fe7:	e9 7d f6 ff ff       	jmp    80106669 <alltraps>

80106fec <vector88>:
.globl vector88
vector88:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $88
80106fee:	6a 58                	push   $0x58
  jmp alltraps
80106ff0:	e9 74 f6 ff ff       	jmp    80106669 <alltraps>

80106ff5 <vector89>:
.globl vector89
vector89:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $89
80106ff7:	6a 59                	push   $0x59
  jmp alltraps
80106ff9:	e9 6b f6 ff ff       	jmp    80106669 <alltraps>

80106ffe <vector90>:
.globl vector90
vector90:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $90
80107000:	6a 5a                	push   $0x5a
  jmp alltraps
80107002:	e9 62 f6 ff ff       	jmp    80106669 <alltraps>

80107007 <vector91>:
.globl vector91
vector91:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $91
80107009:	6a 5b                	push   $0x5b
  jmp alltraps
8010700b:	e9 59 f6 ff ff       	jmp    80106669 <alltraps>

80107010 <vector92>:
.globl vector92
vector92:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $92
80107012:	6a 5c                	push   $0x5c
  jmp alltraps
80107014:	e9 50 f6 ff ff       	jmp    80106669 <alltraps>

80107019 <vector93>:
.globl vector93
vector93:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $93
8010701b:	6a 5d                	push   $0x5d
  jmp alltraps
8010701d:	e9 47 f6 ff ff       	jmp    80106669 <alltraps>

80107022 <vector94>:
.globl vector94
vector94:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $94
80107024:	6a 5e                	push   $0x5e
  jmp alltraps
80107026:	e9 3e f6 ff ff       	jmp    80106669 <alltraps>

8010702b <vector95>:
.globl vector95
vector95:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $95
8010702d:	6a 5f                	push   $0x5f
  jmp alltraps
8010702f:	e9 35 f6 ff ff       	jmp    80106669 <alltraps>

80107034 <vector96>:
.globl vector96
vector96:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $96
80107036:	6a 60                	push   $0x60
  jmp alltraps
80107038:	e9 2c f6 ff ff       	jmp    80106669 <alltraps>

8010703d <vector97>:
.globl vector97
vector97:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $97
8010703f:	6a 61                	push   $0x61
  jmp alltraps
80107041:	e9 23 f6 ff ff       	jmp    80106669 <alltraps>

80107046 <vector98>:
.globl vector98
vector98:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $98
80107048:	6a 62                	push   $0x62
  jmp alltraps
8010704a:	e9 1a f6 ff ff       	jmp    80106669 <alltraps>

8010704f <vector99>:
.globl vector99
vector99:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $99
80107051:	6a 63                	push   $0x63
  jmp alltraps
80107053:	e9 11 f6 ff ff       	jmp    80106669 <alltraps>

80107058 <vector100>:
.globl vector100
vector100:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $100
8010705a:	6a 64                	push   $0x64
  jmp alltraps
8010705c:	e9 08 f6 ff ff       	jmp    80106669 <alltraps>

80107061 <vector101>:
.globl vector101
vector101:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $101
80107063:	6a 65                	push   $0x65
  jmp alltraps
80107065:	e9 ff f5 ff ff       	jmp    80106669 <alltraps>

8010706a <vector102>:
.globl vector102
vector102:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $102
8010706c:	6a 66                	push   $0x66
  jmp alltraps
8010706e:	e9 f6 f5 ff ff       	jmp    80106669 <alltraps>

80107073 <vector103>:
.globl vector103
vector103:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $103
80107075:	6a 67                	push   $0x67
  jmp alltraps
80107077:	e9 ed f5 ff ff       	jmp    80106669 <alltraps>

8010707c <vector104>:
.globl vector104
vector104:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $104
8010707e:	6a 68                	push   $0x68
  jmp alltraps
80107080:	e9 e4 f5 ff ff       	jmp    80106669 <alltraps>

80107085 <vector105>:
.globl vector105
vector105:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $105
80107087:	6a 69                	push   $0x69
  jmp alltraps
80107089:	e9 db f5 ff ff       	jmp    80106669 <alltraps>

8010708e <vector106>:
.globl vector106
vector106:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $106
80107090:	6a 6a                	push   $0x6a
  jmp alltraps
80107092:	e9 d2 f5 ff ff       	jmp    80106669 <alltraps>

80107097 <vector107>:
.globl vector107
vector107:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $107
80107099:	6a 6b                	push   $0x6b
  jmp alltraps
8010709b:	e9 c9 f5 ff ff       	jmp    80106669 <alltraps>

801070a0 <vector108>:
.globl vector108
vector108:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $108
801070a2:	6a 6c                	push   $0x6c
  jmp alltraps
801070a4:	e9 c0 f5 ff ff       	jmp    80106669 <alltraps>

801070a9 <vector109>:
.globl vector109
vector109:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $109
801070ab:	6a 6d                	push   $0x6d
  jmp alltraps
801070ad:	e9 b7 f5 ff ff       	jmp    80106669 <alltraps>

801070b2 <vector110>:
.globl vector110
vector110:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $110
801070b4:	6a 6e                	push   $0x6e
  jmp alltraps
801070b6:	e9 ae f5 ff ff       	jmp    80106669 <alltraps>

801070bb <vector111>:
.globl vector111
vector111:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $111
801070bd:	6a 6f                	push   $0x6f
  jmp alltraps
801070bf:	e9 a5 f5 ff ff       	jmp    80106669 <alltraps>

801070c4 <vector112>:
.globl vector112
vector112:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $112
801070c6:	6a 70                	push   $0x70
  jmp alltraps
801070c8:	e9 9c f5 ff ff       	jmp    80106669 <alltraps>

801070cd <vector113>:
.globl vector113
vector113:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $113
801070cf:	6a 71                	push   $0x71
  jmp alltraps
801070d1:	e9 93 f5 ff ff       	jmp    80106669 <alltraps>

801070d6 <vector114>:
.globl vector114
vector114:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $114
801070d8:	6a 72                	push   $0x72
  jmp alltraps
801070da:	e9 8a f5 ff ff       	jmp    80106669 <alltraps>

801070df <vector115>:
.globl vector115
vector115:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $115
801070e1:	6a 73                	push   $0x73
  jmp alltraps
801070e3:	e9 81 f5 ff ff       	jmp    80106669 <alltraps>

801070e8 <vector116>:
.globl vector116
vector116:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $116
801070ea:	6a 74                	push   $0x74
  jmp alltraps
801070ec:	e9 78 f5 ff ff       	jmp    80106669 <alltraps>

801070f1 <vector117>:
.globl vector117
vector117:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $117
801070f3:	6a 75                	push   $0x75
  jmp alltraps
801070f5:	e9 6f f5 ff ff       	jmp    80106669 <alltraps>

801070fa <vector118>:
.globl vector118
vector118:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $118
801070fc:	6a 76                	push   $0x76
  jmp alltraps
801070fe:	e9 66 f5 ff ff       	jmp    80106669 <alltraps>

80107103 <vector119>:
.globl vector119
vector119:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $119
80107105:	6a 77                	push   $0x77
  jmp alltraps
80107107:	e9 5d f5 ff ff       	jmp    80106669 <alltraps>

8010710c <vector120>:
.globl vector120
vector120:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $120
8010710e:	6a 78                	push   $0x78
  jmp alltraps
80107110:	e9 54 f5 ff ff       	jmp    80106669 <alltraps>

80107115 <vector121>:
.globl vector121
vector121:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $121
80107117:	6a 79                	push   $0x79
  jmp alltraps
80107119:	e9 4b f5 ff ff       	jmp    80106669 <alltraps>

8010711e <vector122>:
.globl vector122
vector122:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $122
80107120:	6a 7a                	push   $0x7a
  jmp alltraps
80107122:	e9 42 f5 ff ff       	jmp    80106669 <alltraps>

80107127 <vector123>:
.globl vector123
vector123:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $123
80107129:	6a 7b                	push   $0x7b
  jmp alltraps
8010712b:	e9 39 f5 ff ff       	jmp    80106669 <alltraps>

80107130 <vector124>:
.globl vector124
vector124:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $124
80107132:	6a 7c                	push   $0x7c
  jmp alltraps
80107134:	e9 30 f5 ff ff       	jmp    80106669 <alltraps>

80107139 <vector125>:
.globl vector125
vector125:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $125
8010713b:	6a 7d                	push   $0x7d
  jmp alltraps
8010713d:	e9 27 f5 ff ff       	jmp    80106669 <alltraps>

80107142 <vector126>:
.globl vector126
vector126:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $126
80107144:	6a 7e                	push   $0x7e
  jmp alltraps
80107146:	e9 1e f5 ff ff       	jmp    80106669 <alltraps>

8010714b <vector127>:
.globl vector127
vector127:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $127
8010714d:	6a 7f                	push   $0x7f
  jmp alltraps
8010714f:	e9 15 f5 ff ff       	jmp    80106669 <alltraps>

80107154 <vector128>:
.globl vector128
vector128:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $128
80107156:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010715b:	e9 09 f5 ff ff       	jmp    80106669 <alltraps>

80107160 <vector129>:
.globl vector129
vector129:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $129
80107162:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107167:	e9 fd f4 ff ff       	jmp    80106669 <alltraps>

8010716c <vector130>:
.globl vector130
vector130:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $130
8010716e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107173:	e9 f1 f4 ff ff       	jmp    80106669 <alltraps>

80107178 <vector131>:
.globl vector131
vector131:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $131
8010717a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010717f:	e9 e5 f4 ff ff       	jmp    80106669 <alltraps>

80107184 <vector132>:
.globl vector132
vector132:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $132
80107186:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010718b:	e9 d9 f4 ff ff       	jmp    80106669 <alltraps>

80107190 <vector133>:
.globl vector133
vector133:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $133
80107192:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107197:	e9 cd f4 ff ff       	jmp    80106669 <alltraps>

8010719c <vector134>:
.globl vector134
vector134:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $134
8010719e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071a3:	e9 c1 f4 ff ff       	jmp    80106669 <alltraps>

801071a8 <vector135>:
.globl vector135
vector135:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $135
801071aa:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071af:	e9 b5 f4 ff ff       	jmp    80106669 <alltraps>

801071b4 <vector136>:
.globl vector136
vector136:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $136
801071b6:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071bb:	e9 a9 f4 ff ff       	jmp    80106669 <alltraps>

801071c0 <vector137>:
.globl vector137
vector137:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $137
801071c2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071c7:	e9 9d f4 ff ff       	jmp    80106669 <alltraps>

801071cc <vector138>:
.globl vector138
vector138:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $138
801071ce:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071d3:	e9 91 f4 ff ff       	jmp    80106669 <alltraps>

801071d8 <vector139>:
.globl vector139
vector139:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $139
801071da:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071df:	e9 85 f4 ff ff       	jmp    80106669 <alltraps>

801071e4 <vector140>:
.globl vector140
vector140:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $140
801071e6:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071eb:	e9 79 f4 ff ff       	jmp    80106669 <alltraps>

801071f0 <vector141>:
.globl vector141
vector141:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $141
801071f2:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801071f7:	e9 6d f4 ff ff       	jmp    80106669 <alltraps>

801071fc <vector142>:
.globl vector142
vector142:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $142
801071fe:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107203:	e9 61 f4 ff ff       	jmp    80106669 <alltraps>

80107208 <vector143>:
.globl vector143
vector143:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $143
8010720a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010720f:	e9 55 f4 ff ff       	jmp    80106669 <alltraps>

80107214 <vector144>:
.globl vector144
vector144:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $144
80107216:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010721b:	e9 49 f4 ff ff       	jmp    80106669 <alltraps>

80107220 <vector145>:
.globl vector145
vector145:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $145
80107222:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107227:	e9 3d f4 ff ff       	jmp    80106669 <alltraps>

8010722c <vector146>:
.globl vector146
vector146:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $146
8010722e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107233:	e9 31 f4 ff ff       	jmp    80106669 <alltraps>

80107238 <vector147>:
.globl vector147
vector147:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $147
8010723a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010723f:	e9 25 f4 ff ff       	jmp    80106669 <alltraps>

80107244 <vector148>:
.globl vector148
vector148:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $148
80107246:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010724b:	e9 19 f4 ff ff       	jmp    80106669 <alltraps>

80107250 <vector149>:
.globl vector149
vector149:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $149
80107252:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107257:	e9 0d f4 ff ff       	jmp    80106669 <alltraps>

8010725c <vector150>:
.globl vector150
vector150:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $150
8010725e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107263:	e9 01 f4 ff ff       	jmp    80106669 <alltraps>

80107268 <vector151>:
.globl vector151
vector151:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $151
8010726a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010726f:	e9 f5 f3 ff ff       	jmp    80106669 <alltraps>

80107274 <vector152>:
.globl vector152
vector152:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $152
80107276:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010727b:	e9 e9 f3 ff ff       	jmp    80106669 <alltraps>

80107280 <vector153>:
.globl vector153
vector153:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $153
80107282:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107287:	e9 dd f3 ff ff       	jmp    80106669 <alltraps>

8010728c <vector154>:
.globl vector154
vector154:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $154
8010728e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107293:	e9 d1 f3 ff ff       	jmp    80106669 <alltraps>

80107298 <vector155>:
.globl vector155
vector155:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $155
8010729a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010729f:	e9 c5 f3 ff ff       	jmp    80106669 <alltraps>

801072a4 <vector156>:
.globl vector156
vector156:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $156
801072a6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072ab:	e9 b9 f3 ff ff       	jmp    80106669 <alltraps>

801072b0 <vector157>:
.globl vector157
vector157:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $157
801072b2:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072b7:	e9 ad f3 ff ff       	jmp    80106669 <alltraps>

801072bc <vector158>:
.globl vector158
vector158:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $158
801072be:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072c3:	e9 a1 f3 ff ff       	jmp    80106669 <alltraps>

801072c8 <vector159>:
.globl vector159
vector159:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $159
801072ca:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072cf:	e9 95 f3 ff ff       	jmp    80106669 <alltraps>

801072d4 <vector160>:
.globl vector160
vector160:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $160
801072d6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072db:	e9 89 f3 ff ff       	jmp    80106669 <alltraps>

801072e0 <vector161>:
.globl vector161
vector161:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $161
801072e2:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072e7:	e9 7d f3 ff ff       	jmp    80106669 <alltraps>

801072ec <vector162>:
.globl vector162
vector162:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $162
801072ee:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801072f3:	e9 71 f3 ff ff       	jmp    80106669 <alltraps>

801072f8 <vector163>:
.globl vector163
vector163:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $163
801072fa:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072ff:	e9 65 f3 ff ff       	jmp    80106669 <alltraps>

80107304 <vector164>:
.globl vector164
vector164:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $164
80107306:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010730b:	e9 59 f3 ff ff       	jmp    80106669 <alltraps>

80107310 <vector165>:
.globl vector165
vector165:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $165
80107312:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107317:	e9 4d f3 ff ff       	jmp    80106669 <alltraps>

8010731c <vector166>:
.globl vector166
vector166:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $166
8010731e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107323:	e9 41 f3 ff ff       	jmp    80106669 <alltraps>

80107328 <vector167>:
.globl vector167
vector167:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $167
8010732a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010732f:	e9 35 f3 ff ff       	jmp    80106669 <alltraps>

80107334 <vector168>:
.globl vector168
vector168:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $168
80107336:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010733b:	e9 29 f3 ff ff       	jmp    80106669 <alltraps>

80107340 <vector169>:
.globl vector169
vector169:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $169
80107342:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107347:	e9 1d f3 ff ff       	jmp    80106669 <alltraps>

8010734c <vector170>:
.globl vector170
vector170:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $170
8010734e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107353:	e9 11 f3 ff ff       	jmp    80106669 <alltraps>

80107358 <vector171>:
.globl vector171
vector171:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $171
8010735a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010735f:	e9 05 f3 ff ff       	jmp    80106669 <alltraps>

80107364 <vector172>:
.globl vector172
vector172:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $172
80107366:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010736b:	e9 f9 f2 ff ff       	jmp    80106669 <alltraps>

80107370 <vector173>:
.globl vector173
vector173:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $173
80107372:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107377:	e9 ed f2 ff ff       	jmp    80106669 <alltraps>

8010737c <vector174>:
.globl vector174
vector174:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $174
8010737e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107383:	e9 e1 f2 ff ff       	jmp    80106669 <alltraps>

80107388 <vector175>:
.globl vector175
vector175:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $175
8010738a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010738f:	e9 d5 f2 ff ff       	jmp    80106669 <alltraps>

80107394 <vector176>:
.globl vector176
vector176:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $176
80107396:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010739b:	e9 c9 f2 ff ff       	jmp    80106669 <alltraps>

801073a0 <vector177>:
.globl vector177
vector177:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $177
801073a2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073a7:	e9 bd f2 ff ff       	jmp    80106669 <alltraps>

801073ac <vector178>:
.globl vector178
vector178:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $178
801073ae:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073b3:	e9 b1 f2 ff ff       	jmp    80106669 <alltraps>

801073b8 <vector179>:
.globl vector179
vector179:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $179
801073ba:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073bf:	e9 a5 f2 ff ff       	jmp    80106669 <alltraps>

801073c4 <vector180>:
.globl vector180
vector180:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $180
801073c6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073cb:	e9 99 f2 ff ff       	jmp    80106669 <alltraps>

801073d0 <vector181>:
.globl vector181
vector181:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $181
801073d2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073d7:	e9 8d f2 ff ff       	jmp    80106669 <alltraps>

801073dc <vector182>:
.globl vector182
vector182:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $182
801073de:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073e3:	e9 81 f2 ff ff       	jmp    80106669 <alltraps>

801073e8 <vector183>:
.globl vector183
vector183:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $183
801073ea:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073ef:	e9 75 f2 ff ff       	jmp    80106669 <alltraps>

801073f4 <vector184>:
.globl vector184
vector184:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $184
801073f6:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073fb:	e9 69 f2 ff ff       	jmp    80106669 <alltraps>

80107400 <vector185>:
.globl vector185
vector185:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $185
80107402:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107407:	e9 5d f2 ff ff       	jmp    80106669 <alltraps>

8010740c <vector186>:
.globl vector186
vector186:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $186
8010740e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107413:	e9 51 f2 ff ff       	jmp    80106669 <alltraps>

80107418 <vector187>:
.globl vector187
vector187:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $187
8010741a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010741f:	e9 45 f2 ff ff       	jmp    80106669 <alltraps>

80107424 <vector188>:
.globl vector188
vector188:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $188
80107426:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010742b:	e9 39 f2 ff ff       	jmp    80106669 <alltraps>

80107430 <vector189>:
.globl vector189
vector189:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $189
80107432:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107437:	e9 2d f2 ff ff       	jmp    80106669 <alltraps>

8010743c <vector190>:
.globl vector190
vector190:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $190
8010743e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107443:	e9 21 f2 ff ff       	jmp    80106669 <alltraps>

80107448 <vector191>:
.globl vector191
vector191:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $191
8010744a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010744f:	e9 15 f2 ff ff       	jmp    80106669 <alltraps>

80107454 <vector192>:
.globl vector192
vector192:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $192
80107456:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010745b:	e9 09 f2 ff ff       	jmp    80106669 <alltraps>

80107460 <vector193>:
.globl vector193
vector193:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $193
80107462:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107467:	e9 fd f1 ff ff       	jmp    80106669 <alltraps>

8010746c <vector194>:
.globl vector194
vector194:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $194
8010746e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107473:	e9 f1 f1 ff ff       	jmp    80106669 <alltraps>

80107478 <vector195>:
.globl vector195
vector195:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $195
8010747a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010747f:	e9 e5 f1 ff ff       	jmp    80106669 <alltraps>

80107484 <vector196>:
.globl vector196
vector196:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $196
80107486:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010748b:	e9 d9 f1 ff ff       	jmp    80106669 <alltraps>

80107490 <vector197>:
.globl vector197
vector197:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $197
80107492:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107497:	e9 cd f1 ff ff       	jmp    80106669 <alltraps>

8010749c <vector198>:
.globl vector198
vector198:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $198
8010749e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074a3:	e9 c1 f1 ff ff       	jmp    80106669 <alltraps>

801074a8 <vector199>:
.globl vector199
vector199:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $199
801074aa:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074af:	e9 b5 f1 ff ff       	jmp    80106669 <alltraps>

801074b4 <vector200>:
.globl vector200
vector200:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $200
801074b6:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074bb:	e9 a9 f1 ff ff       	jmp    80106669 <alltraps>

801074c0 <vector201>:
.globl vector201
vector201:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $201
801074c2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074c7:	e9 9d f1 ff ff       	jmp    80106669 <alltraps>

801074cc <vector202>:
.globl vector202
vector202:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $202
801074ce:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074d3:	e9 91 f1 ff ff       	jmp    80106669 <alltraps>

801074d8 <vector203>:
.globl vector203
vector203:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $203
801074da:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074df:	e9 85 f1 ff ff       	jmp    80106669 <alltraps>

801074e4 <vector204>:
.globl vector204
vector204:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $204
801074e6:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074eb:	e9 79 f1 ff ff       	jmp    80106669 <alltraps>

801074f0 <vector205>:
.globl vector205
vector205:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $205
801074f2:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801074f7:	e9 6d f1 ff ff       	jmp    80106669 <alltraps>

801074fc <vector206>:
.globl vector206
vector206:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $206
801074fe:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107503:	e9 61 f1 ff ff       	jmp    80106669 <alltraps>

80107508 <vector207>:
.globl vector207
vector207:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $207
8010750a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010750f:	e9 55 f1 ff ff       	jmp    80106669 <alltraps>

80107514 <vector208>:
.globl vector208
vector208:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $208
80107516:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010751b:	e9 49 f1 ff ff       	jmp    80106669 <alltraps>

80107520 <vector209>:
.globl vector209
vector209:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $209
80107522:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107527:	e9 3d f1 ff ff       	jmp    80106669 <alltraps>

8010752c <vector210>:
.globl vector210
vector210:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $210
8010752e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107533:	e9 31 f1 ff ff       	jmp    80106669 <alltraps>

80107538 <vector211>:
.globl vector211
vector211:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $211
8010753a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010753f:	e9 25 f1 ff ff       	jmp    80106669 <alltraps>

80107544 <vector212>:
.globl vector212
vector212:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $212
80107546:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010754b:	e9 19 f1 ff ff       	jmp    80106669 <alltraps>

80107550 <vector213>:
.globl vector213
vector213:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $213
80107552:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107557:	e9 0d f1 ff ff       	jmp    80106669 <alltraps>

8010755c <vector214>:
.globl vector214
vector214:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $214
8010755e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107563:	e9 01 f1 ff ff       	jmp    80106669 <alltraps>

80107568 <vector215>:
.globl vector215
vector215:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $215
8010756a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010756f:	e9 f5 f0 ff ff       	jmp    80106669 <alltraps>

80107574 <vector216>:
.globl vector216
vector216:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $216
80107576:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010757b:	e9 e9 f0 ff ff       	jmp    80106669 <alltraps>

80107580 <vector217>:
.globl vector217
vector217:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $217
80107582:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107587:	e9 dd f0 ff ff       	jmp    80106669 <alltraps>

8010758c <vector218>:
.globl vector218
vector218:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $218
8010758e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107593:	e9 d1 f0 ff ff       	jmp    80106669 <alltraps>

80107598 <vector219>:
.globl vector219
vector219:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $219
8010759a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010759f:	e9 c5 f0 ff ff       	jmp    80106669 <alltraps>

801075a4 <vector220>:
.globl vector220
vector220:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $220
801075a6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075ab:	e9 b9 f0 ff ff       	jmp    80106669 <alltraps>

801075b0 <vector221>:
.globl vector221
vector221:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $221
801075b2:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075b7:	e9 ad f0 ff ff       	jmp    80106669 <alltraps>

801075bc <vector222>:
.globl vector222
vector222:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $222
801075be:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075c3:	e9 a1 f0 ff ff       	jmp    80106669 <alltraps>

801075c8 <vector223>:
.globl vector223
vector223:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $223
801075ca:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075cf:	e9 95 f0 ff ff       	jmp    80106669 <alltraps>

801075d4 <vector224>:
.globl vector224
vector224:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $224
801075d6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075db:	e9 89 f0 ff ff       	jmp    80106669 <alltraps>

801075e0 <vector225>:
.globl vector225
vector225:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $225
801075e2:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075e7:	e9 7d f0 ff ff       	jmp    80106669 <alltraps>

801075ec <vector226>:
.globl vector226
vector226:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $226
801075ee:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801075f3:	e9 71 f0 ff ff       	jmp    80106669 <alltraps>

801075f8 <vector227>:
.globl vector227
vector227:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $227
801075fa:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075ff:	e9 65 f0 ff ff       	jmp    80106669 <alltraps>

80107604 <vector228>:
.globl vector228
vector228:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $228
80107606:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010760b:	e9 59 f0 ff ff       	jmp    80106669 <alltraps>

80107610 <vector229>:
.globl vector229
vector229:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $229
80107612:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107617:	e9 4d f0 ff ff       	jmp    80106669 <alltraps>

8010761c <vector230>:
.globl vector230
vector230:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $230
8010761e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107623:	e9 41 f0 ff ff       	jmp    80106669 <alltraps>

80107628 <vector231>:
.globl vector231
vector231:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $231
8010762a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010762f:	e9 35 f0 ff ff       	jmp    80106669 <alltraps>

80107634 <vector232>:
.globl vector232
vector232:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $232
80107636:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010763b:	e9 29 f0 ff ff       	jmp    80106669 <alltraps>

80107640 <vector233>:
.globl vector233
vector233:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $233
80107642:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107647:	e9 1d f0 ff ff       	jmp    80106669 <alltraps>

8010764c <vector234>:
.globl vector234
vector234:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $234
8010764e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107653:	e9 11 f0 ff ff       	jmp    80106669 <alltraps>

80107658 <vector235>:
.globl vector235
vector235:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $235
8010765a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010765f:	e9 05 f0 ff ff       	jmp    80106669 <alltraps>

80107664 <vector236>:
.globl vector236
vector236:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $236
80107666:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010766b:	e9 f9 ef ff ff       	jmp    80106669 <alltraps>

80107670 <vector237>:
.globl vector237
vector237:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $237
80107672:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107677:	e9 ed ef ff ff       	jmp    80106669 <alltraps>

8010767c <vector238>:
.globl vector238
vector238:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $238
8010767e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107683:	e9 e1 ef ff ff       	jmp    80106669 <alltraps>

80107688 <vector239>:
.globl vector239
vector239:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $239
8010768a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010768f:	e9 d5 ef ff ff       	jmp    80106669 <alltraps>

80107694 <vector240>:
.globl vector240
vector240:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $240
80107696:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010769b:	e9 c9 ef ff ff       	jmp    80106669 <alltraps>

801076a0 <vector241>:
.globl vector241
vector241:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $241
801076a2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076a7:	e9 bd ef ff ff       	jmp    80106669 <alltraps>

801076ac <vector242>:
.globl vector242
vector242:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $242
801076ae:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076b3:	e9 b1 ef ff ff       	jmp    80106669 <alltraps>

801076b8 <vector243>:
.globl vector243
vector243:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $243
801076ba:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076bf:	e9 a5 ef ff ff       	jmp    80106669 <alltraps>

801076c4 <vector244>:
.globl vector244
vector244:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $244
801076c6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076cb:	e9 99 ef ff ff       	jmp    80106669 <alltraps>

801076d0 <vector245>:
.globl vector245
vector245:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $245
801076d2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076d7:	e9 8d ef ff ff       	jmp    80106669 <alltraps>

801076dc <vector246>:
.globl vector246
vector246:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $246
801076de:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076e3:	e9 81 ef ff ff       	jmp    80106669 <alltraps>

801076e8 <vector247>:
.globl vector247
vector247:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $247
801076ea:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076ef:	e9 75 ef ff ff       	jmp    80106669 <alltraps>

801076f4 <vector248>:
.globl vector248
vector248:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $248
801076f6:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076fb:	e9 69 ef ff ff       	jmp    80106669 <alltraps>

80107700 <vector249>:
.globl vector249
vector249:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $249
80107702:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107707:	e9 5d ef ff ff       	jmp    80106669 <alltraps>

8010770c <vector250>:
.globl vector250
vector250:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $250
8010770e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107713:	e9 51 ef ff ff       	jmp    80106669 <alltraps>

80107718 <vector251>:
.globl vector251
vector251:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $251
8010771a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010771f:	e9 45 ef ff ff       	jmp    80106669 <alltraps>

80107724 <vector252>:
.globl vector252
vector252:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $252
80107726:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010772b:	e9 39 ef ff ff       	jmp    80106669 <alltraps>

80107730 <vector253>:
.globl vector253
vector253:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $253
80107732:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107737:	e9 2d ef ff ff       	jmp    80106669 <alltraps>

8010773c <vector254>:
.globl vector254
vector254:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $254
8010773e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107743:	e9 21 ef ff ff       	jmp    80106669 <alltraps>

80107748 <vector255>:
.globl vector255
vector255:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $255
8010774a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010774f:	e9 15 ef ff ff       	jmp    80106669 <alltraps>

80107754 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107754:	55                   	push   %ebp
80107755:	89 e5                	mov    %esp,%ebp
80107757:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010775a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010775d:	83 e8 01             	sub    $0x1,%eax
80107760:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107764:	8b 45 08             	mov    0x8(%ebp),%eax
80107767:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010776b:	8b 45 08             	mov    0x8(%ebp),%eax
8010776e:	c1 e8 10             	shr    $0x10,%eax
80107771:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107775:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107778:	0f 01 10             	lgdtl  (%eax)
}
8010777b:	c9                   	leave  
8010777c:	c3                   	ret    

8010777d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010777d:	55                   	push   %ebp
8010777e:	89 e5                	mov    %esp,%ebp
80107780:	83 ec 04             	sub    $0x4,%esp
80107783:	8b 45 08             	mov    0x8(%ebp),%eax
80107786:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010778a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010778e:	0f 00 d8             	ltr    %ax
}
80107791:	c9                   	leave  
80107792:	c3                   	ret    

80107793 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107793:	55                   	push   %ebp
80107794:	89 e5                	mov    %esp,%ebp
80107796:	83 ec 04             	sub    $0x4,%esp
80107799:	8b 45 08             	mov    0x8(%ebp),%eax
8010779c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077a0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077a4:	8e e8                	mov    %eax,%gs
}
801077a6:	c9                   	leave  
801077a7:	c3                   	ret    

801077a8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077a8:	55                   	push   %ebp
801077a9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077ab:	8b 45 08             	mov    0x8(%ebp),%eax
801077ae:	0f 22 d8             	mov    %eax,%cr3
}
801077b1:	5d                   	pop    %ebp
801077b2:	c3                   	ret    

801077b3 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801077b3:	55                   	push   %ebp
801077b4:	89 e5                	mov    %esp,%ebp
801077b6:	8b 45 08             	mov    0x8(%ebp),%eax
801077b9:	05 00 00 00 80       	add    $0x80000000,%eax
801077be:	5d                   	pop    %ebp
801077bf:	c3                   	ret    

801077c0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077c0:	55                   	push   %ebp
801077c1:	89 e5                	mov    %esp,%ebp
801077c3:	8b 45 08             	mov    0x8(%ebp),%eax
801077c6:	05 00 00 00 80       	add    $0x80000000,%eax
801077cb:	5d                   	pop    %ebp
801077cc:	c3                   	ret    

801077cd <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077cd:	55                   	push   %ebp
801077ce:	89 e5                	mov    %esp,%ebp
801077d0:	53                   	push   %ebx
801077d1:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801077d4:	e8 01 ba ff ff       	call   801031da <cpunum>
801077d9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801077df:	05 e0 f9 10 80       	add    $0x8010f9e0,%eax
801077e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ea:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f3:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fc:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107803:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107807:	83 e2 f0             	and    $0xfffffff0,%edx
8010780a:	83 ca 0a             	or     $0xa,%edx
8010780d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107813:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107817:	83 ca 10             	or     $0x10,%edx
8010781a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010781d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107820:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107824:	83 e2 9f             	and    $0xffffff9f,%edx
80107827:	88 50 7d             	mov    %dl,0x7d(%eax)
8010782a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107831:	83 ca 80             	or     $0xffffff80,%edx
80107834:	88 50 7d             	mov    %dl,0x7d(%eax)
80107837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010783e:	83 ca 0f             	or     $0xf,%edx
80107841:	88 50 7e             	mov    %dl,0x7e(%eax)
80107844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107847:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010784b:	83 e2 ef             	and    $0xffffffef,%edx
8010784e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107858:	83 e2 df             	and    $0xffffffdf,%edx
8010785b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107865:	83 ca 40             	or     $0x40,%edx
80107868:	88 50 7e             	mov    %dl,0x7e(%eax)
8010786b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107872:	83 ca 80             	or     $0xffffff80,%edx
80107875:	88 50 7e             	mov    %dl,0x7e(%eax)
80107878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107889:	ff ff 
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107895:	00 00 
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078ab:	83 e2 f0             	and    $0xfffffff0,%edx
801078ae:	83 ca 02             	or     $0x2,%edx
801078b1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ba:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078c1:	83 ca 10             	or     $0x10,%edx
801078c4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078d4:	83 e2 9f             	and    $0xffffff9f,%edx
801078d7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078e7:	83 ca 80             	or     $0xffffff80,%edx
801078ea:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078fa:	83 ca 0f             	or     $0xf,%edx
801078fd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107906:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010790d:	83 e2 ef             	and    $0xffffffef,%edx
80107910:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107919:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107920:	83 e2 df             	and    $0xffffffdf,%edx
80107923:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107933:	83 ca 40             	or     $0x40,%edx
80107936:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010793c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107946:	83 ca 80             	or     $0xffffff80,%edx
80107949:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010794f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107952:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107963:	ff ff 
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010796f:	00 00 
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010797b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107985:	83 e2 f0             	and    $0xfffffff0,%edx
80107988:	83 ca 0a             	or     $0xa,%edx
8010798b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107994:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010799b:	83 ca 10             	or     $0x10,%edx
8010799e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ae:	83 ca 60             	or     $0x60,%edx
801079b1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079c1:	83 ca 80             	or     $0xffffff80,%edx
801079c4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079d4:	83 ca 0f             	or     $0xf,%edx
801079d7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079e7:	83 e2 ef             	and    $0xffffffef,%edx
801079ea:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079fa:	83 e2 df             	and    $0xffffffdf,%edx
801079fd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a06:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a0d:	83 ca 40             	or     $0x40,%edx
80107a10:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a19:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a20:	83 ca 80             	or     $0xffffff80,%edx
80107a23:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a36:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a3d:	ff ff 
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a49:	00 00 
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a5f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a62:	83 ca 02             	or     $0x2,%edx
80107a65:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a75:	83 ca 10             	or     $0x10,%edx
80107a78:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a88:	83 ca 60             	or     $0x60,%edx
80107a8b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a9b:	83 ca 80             	or     $0xffffff80,%edx
80107a9e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aae:	83 ca 0f             	or     $0xf,%edx
80107ab1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aba:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ac1:	83 e2 ef             	and    $0xffffffef,%edx
80107ac4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ad4:	83 e2 df             	and    $0xffffffdf,%edx
80107ad7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ae7:	83 ca 40             	or     $0x40,%edx
80107aea:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107afa:	83 ca 80             	or     $0xffffff80,%edx
80107afd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b06:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b10:	05 b4 00 00 00       	add    $0xb4,%eax
80107b15:	89 c3                	mov    %eax,%ebx
80107b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1a:	05 b4 00 00 00       	add    $0xb4,%eax
80107b1f:	c1 e8 10             	shr    $0x10,%eax
80107b22:	89 c1                	mov    %eax,%ecx
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	05 b4 00 00 00       	add    $0xb4,%eax
80107b2c:	c1 e8 18             	shr    $0x18,%eax
80107b2f:	89 c2                	mov    %eax,%edx
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b3b:	00 00 
80107b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b40:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b53:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b5a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b5d:	83 c9 02             	or     $0x2,%ecx
80107b60:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b70:	83 c9 10             	or     $0x10,%ecx
80107b73:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b83:	83 e1 9f             	and    $0xffffff9f,%ecx
80107b86:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107b96:	83 c9 80             	or     $0xffffff80,%ecx
80107b99:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ba9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107bac:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107bbc:	83 e1 ef             	and    $0xffffffef,%ecx
80107bbf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107bcf:	83 e1 df             	and    $0xffffffdf,%ecx
80107bd2:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdb:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107be2:	83 c9 40             	or     $0x40,%ecx
80107be5:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bee:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107bf5:	83 c9 80             	or     $0xffffff80,%ecx
80107bf8:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c01:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	83 c0 70             	add    $0x70,%eax
80107c0d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107c14:	00 
80107c15:	89 04 24             	mov    %eax,(%esp)
80107c18:	e8 37 fb ff ff       	call   80107754 <lgdt>
  loadgs(SEG_KCPU << 3);
80107c1d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107c24:	e8 6a fb ff ff       	call   80107793 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c32:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c39:	00 00 00 00 
}
80107c3d:	83 c4 24             	add    $0x24,%esp
80107c40:	5b                   	pop    %ebx
80107c41:	5d                   	pop    %ebp
80107c42:	c3                   	ret    

80107c43 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c43:	55                   	push   %ebp
80107c44:	89 e5                	mov    %esp,%ebp
80107c46:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4c:	c1 e8 16             	shr    $0x16,%eax
80107c4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c56:	8b 45 08             	mov    0x8(%ebp),%eax
80107c59:	01 d0                	add    %edx,%eax
80107c5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c61:	8b 00                	mov    (%eax),%eax
80107c63:	83 e0 01             	and    $0x1,%eax
80107c66:	85 c0                	test   %eax,%eax
80107c68:	74 17                	je     80107c81 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6d:	8b 00                	mov    (%eax),%eax
80107c6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c74:	89 04 24             	mov    %eax,(%esp)
80107c77:	e8 44 fb ff ff       	call   801077c0 <p2v>
80107c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c7f:	eb 4b                	jmp    80107ccc <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c85:	74 0e                	je     80107c95 <walkpgdir+0x52>
80107c87:	e8 d5 b1 ff ff       	call   80102e61 <kalloc>
80107c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c93:	75 07                	jne    80107c9c <walkpgdir+0x59>
      return 0;
80107c95:	b8 00 00 00 00       	mov    $0x0,%eax
80107c9a:	eb 47                	jmp    80107ce3 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c9c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ca3:	00 
80107ca4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107cab:	00 
80107cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caf:	89 04 24             	mov    %eax,(%esp)
80107cb2:	e8 4c d4 ff ff       	call   80105103 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cba:	89 04 24             	mov    %eax,(%esp)
80107cbd:	e8 f1 fa ff ff       	call   801077b3 <v2p>
80107cc2:	83 c8 07             	or     $0x7,%eax
80107cc5:	89 c2                	mov    %eax,%edx
80107cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cca:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ccf:	c1 e8 0c             	shr    $0xc,%eax
80107cd2:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce1:	01 d0                	add    %edx,%eax
}
80107ce3:	c9                   	leave  
80107ce4:	c3                   	ret    

80107ce5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ce5:	55                   	push   %ebp
80107ce6:	89 e5                	mov    %esp,%ebp
80107ce8:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cf9:	8b 45 10             	mov    0x10(%ebp),%eax
80107cfc:	01 d0                	add    %edx,%eax
80107cfe:	83 e8 01             	sub    $0x1,%eax
80107d01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d09:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107d10:	00 
80107d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d14:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d18:	8b 45 08             	mov    0x8(%ebp),%eax
80107d1b:	89 04 24             	mov    %eax,(%esp)
80107d1e:	e8 20 ff ff ff       	call   80107c43 <walkpgdir>
80107d23:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d26:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d2a:	75 07                	jne    80107d33 <mappages+0x4e>
      return -1;
80107d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d31:	eb 48                	jmp    80107d7b <mappages+0x96>
    if(*pte & PTE_P)
80107d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d36:	8b 00                	mov    (%eax),%eax
80107d38:	83 e0 01             	and    $0x1,%eax
80107d3b:	85 c0                	test   %eax,%eax
80107d3d:	74 0c                	je     80107d4b <mappages+0x66>
      panic("remap");
80107d3f:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
80107d46:	e8 ef 87 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107d4b:	8b 45 18             	mov    0x18(%ebp),%eax
80107d4e:	0b 45 14             	or     0x14(%ebp),%eax
80107d51:	83 c8 01             	or     $0x1,%eax
80107d54:	89 c2                	mov    %eax,%edx
80107d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d59:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d61:	75 08                	jne    80107d6b <mappages+0x86>
      break;
80107d63:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107d64:	b8 00 00 00 00       	mov    $0x0,%eax
80107d69:	eb 10                	jmp    80107d7b <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107d6b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d72:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107d79:	eb 8e                	jmp    80107d09 <mappages+0x24>
  return 0;
}
80107d7b:	c9                   	leave  
80107d7c:	c3                   	ret    

80107d7d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107d7d:	55                   	push   %ebp
80107d7e:	89 e5                	mov    %esp,%ebp
80107d80:	53                   	push   %ebx
80107d81:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d84:	e8 d8 b0 ff ff       	call   80102e61 <kalloc>
80107d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d90:	75 0a                	jne    80107d9c <setupkvm+0x1f>
    return 0;
80107d92:	b8 00 00 00 00       	mov    $0x0,%eax
80107d97:	e9 98 00 00 00       	jmp    80107e34 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107d9c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107da3:	00 
80107da4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dab:	00 
80107dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107daf:	89 04 24             	mov    %eax,(%esp)
80107db2:	e8 4c d3 ff ff       	call   80105103 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107db7:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107dbe:	e8 fd f9 ff ff       	call   801077c0 <p2v>
80107dc3:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107dc8:	76 0c                	jbe    80107dd6 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107dca:	c7 04 24 a2 8b 10 80 	movl   $0x80108ba2,(%esp)
80107dd1:	e8 64 87 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dd6:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107ddd:	eb 49                	jmp    80107e28 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	8b 48 0c             	mov    0xc(%eax),%ecx
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	8b 50 04             	mov    0x4(%eax),%edx
80107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dee:	8b 58 08             	mov    0x8(%eax),%ebx
80107df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df4:	8b 40 04             	mov    0x4(%eax),%eax
80107df7:	29 c3                	sub    %eax,%ebx
80107df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfc:	8b 00                	mov    (%eax),%eax
80107dfe:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107e02:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e06:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e11:	89 04 24             	mov    %eax,(%esp)
80107e14:	e8 cc fe ff ff       	call   80107ce5 <mappages>
80107e19:	85 c0                	test   %eax,%eax
80107e1b:	79 07                	jns    80107e24 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107e1d:	b8 00 00 00 00       	mov    $0x0,%eax
80107e22:	eb 10                	jmp    80107e34 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e24:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e28:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e2f:	72 ae                	jb     80107ddf <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e34:	83 c4 34             	add    $0x34,%esp
80107e37:	5b                   	pop    %ebx
80107e38:	5d                   	pop    %ebp
80107e39:	c3                   	ret    

80107e3a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e3a:	55                   	push   %ebp
80107e3b:	89 e5                	mov    %esp,%ebp
80107e3d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e40:	e8 38 ff ff ff       	call   80107d7d <setupkvm>
80107e45:	a3 b8 27 11 80       	mov    %eax,0x801127b8
  switchkvm();
80107e4a:	e8 02 00 00 00       	call   80107e51 <switchkvm>
}
80107e4f:	c9                   	leave  
80107e50:	c3                   	ret    

80107e51 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e51:	55                   	push   %ebp
80107e52:	89 e5                	mov    %esp,%ebp
80107e54:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e57:	a1 b8 27 11 80       	mov    0x801127b8,%eax
80107e5c:	89 04 24             	mov    %eax,(%esp)
80107e5f:	e8 4f f9 ff ff       	call   801077b3 <v2p>
80107e64:	89 04 24             	mov    %eax,(%esp)
80107e67:	e8 3c f9 ff ff       	call   801077a8 <lcr3>
}
80107e6c:	c9                   	leave  
80107e6d:	c3                   	ret    

80107e6e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e6e:	55                   	push   %ebp
80107e6f:	89 e5                	mov    %esp,%ebp
80107e71:	53                   	push   %ebx
80107e72:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107e75:	e8 89 d1 ff ff       	call   80105003 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e80:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e87:	83 c2 08             	add    $0x8,%edx
80107e8a:	89 d3                	mov    %edx,%ebx
80107e8c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e93:	83 c2 08             	add    $0x8,%edx
80107e96:	c1 ea 10             	shr    $0x10,%edx
80107e99:	89 d1                	mov    %edx,%ecx
80107e9b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ea2:	83 c2 08             	add    $0x8,%edx
80107ea5:	c1 ea 18             	shr    $0x18,%edx
80107ea8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107eaf:	67 00 
80107eb1:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107eb8:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107ebe:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ec5:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ec8:	83 c9 09             	or     $0x9,%ecx
80107ecb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ed1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ed8:	83 c9 10             	or     $0x10,%ecx
80107edb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ee1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ee8:	83 e1 9f             	and    $0xffffff9f,%ecx
80107eeb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ef1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ef8:	83 c9 80             	or     $0xffffff80,%ecx
80107efb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107f01:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f08:	83 e1 f0             	and    $0xfffffff0,%ecx
80107f0b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f11:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f18:	83 e1 ef             	and    $0xffffffef,%ecx
80107f1b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f21:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f28:	83 e1 df             	and    $0xffffffdf,%ecx
80107f2b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f31:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f38:	83 c9 40             	or     $0x40,%ecx
80107f3b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f41:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f48:	83 e1 7f             	and    $0x7f,%ecx
80107f4b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f51:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f5d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f64:	83 e2 ef             	and    $0xffffffef,%edx
80107f67:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f73:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f79:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f7f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107f86:	8b 52 08             	mov    0x8(%edx),%edx
80107f89:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f8f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107f92:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107f99:	e8 df f7 ff ff       	call   8010777d <ltr>
  if(p->pgdir == 0)
80107f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa1:	8b 40 04             	mov    0x4(%eax),%eax
80107fa4:	85 c0                	test   %eax,%eax
80107fa6:	75 0c                	jne    80107fb4 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107fa8:	c7 04 24 b3 8b 10 80 	movl   $0x80108bb3,(%esp)
80107faf:	e8 86 85 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb7:	8b 40 04             	mov    0x4(%eax),%eax
80107fba:	89 04 24             	mov    %eax,(%esp)
80107fbd:	e8 f1 f7 ff ff       	call   801077b3 <v2p>
80107fc2:	89 04 24             	mov    %eax,(%esp)
80107fc5:	e8 de f7 ff ff       	call   801077a8 <lcr3>
  popcli();
80107fca:	e8 78 d0 ff ff       	call   80105047 <popcli>
}
80107fcf:	83 c4 14             	add    $0x14,%esp
80107fd2:	5b                   	pop    %ebx
80107fd3:	5d                   	pop    %ebp
80107fd4:	c3                   	ret    

80107fd5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fd5:	55                   	push   %ebp
80107fd6:	89 e5                	mov    %esp,%ebp
80107fd8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107fdb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fe2:	76 0c                	jbe    80107ff0 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107fe4:	c7 04 24 c7 8b 10 80 	movl   $0x80108bc7,(%esp)
80107feb:	e8 4a 85 ff ff       	call   8010053a <panic>
  mem = kalloc();
80107ff0:	e8 6c ae ff ff       	call   80102e61 <kalloc>
80107ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ff8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fff:	00 
80108000:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108007:	00 
80108008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800b:	89 04 24             	mov    %eax,(%esp)
8010800e:	e8 f0 d0 ff ff       	call   80105103 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108016:	89 04 24             	mov    %eax,(%esp)
80108019:	e8 95 f7 ff ff       	call   801077b3 <v2p>
8010801e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108025:	00 
80108026:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010802a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108031:	00 
80108032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108039:	00 
8010803a:	8b 45 08             	mov    0x8(%ebp),%eax
8010803d:	89 04 24             	mov    %eax,(%esp)
80108040:	e8 a0 fc ff ff       	call   80107ce5 <mappages>
  memmove(mem, init, sz);
80108045:	8b 45 10             	mov    0x10(%ebp),%eax
80108048:	89 44 24 08          	mov    %eax,0x8(%esp)
8010804c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010804f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108056:	89 04 24             	mov    %eax,(%esp)
80108059:	e8 74 d1 ff ff       	call   801051d2 <memmove>
}
8010805e:	c9                   	leave  
8010805f:	c3                   	ret    

80108060 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108060:	55                   	push   %ebp
80108061:	89 e5                	mov    %esp,%ebp
80108063:	53                   	push   %ebx
80108064:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010806f:	85 c0                	test   %eax,%eax
80108071:	74 0c                	je     8010807f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108073:	c7 04 24 e4 8b 10 80 	movl   $0x80108be4,(%esp)
8010807a:	e8 bb 84 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010807f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108086:	e9 a9 00 00 00       	jmp    80108134 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010808b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108091:	01 d0                	add    %edx,%eax
80108093:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010809a:	00 
8010809b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010809f:	8b 45 08             	mov    0x8(%ebp),%eax
801080a2:	89 04 24             	mov    %eax,(%esp)
801080a5:	e8 99 fb ff ff       	call   80107c43 <walkpgdir>
801080aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080b1:	75 0c                	jne    801080bf <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801080b3:	c7 04 24 07 8c 10 80 	movl   $0x80108c07,(%esp)
801080ba:	e8 7b 84 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801080bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c2:	8b 00                	mov    (%eax),%eax
801080c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cf:	8b 55 18             	mov    0x18(%ebp),%edx
801080d2:	29 c2                	sub    %eax,%edx
801080d4:	89 d0                	mov    %edx,%eax
801080d6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080db:	77 0f                	ja     801080ec <loaduvm+0x8c>
      n = sz - i;
801080dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e0:	8b 55 18             	mov    0x18(%ebp),%edx
801080e3:	29 c2                	sub    %eax,%edx
801080e5:	89 d0                	mov    %edx,%eax
801080e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080ea:	eb 07                	jmp    801080f3 <loaduvm+0x93>
    else
      n = PGSIZE;
801080ec:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f6:	8b 55 14             	mov    0x14(%ebp),%edx
801080f9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080ff:	89 04 24             	mov    %eax,(%esp)
80108102:	e8 b9 f6 ff ff       	call   801077c0 <p2v>
80108107:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010810a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010810e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108112:	89 44 24 04          	mov    %eax,0x4(%esp)
80108116:	8b 45 10             	mov    0x10(%ebp),%eax
80108119:	89 04 24             	mov    %eax,(%esp)
8010811c:	e8 80 9e ff ff       	call   80101fa1 <readi>
80108121:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108124:	74 07                	je     8010812d <loaduvm+0xcd>
      return -1;
80108126:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010812b:	eb 18                	jmp    80108145 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010812d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108137:	3b 45 18             	cmp    0x18(%ebp),%eax
8010813a:	0f 82 4b ff ff ff    	jb     8010808b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108140:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108145:	83 c4 24             	add    $0x24,%esp
80108148:	5b                   	pop    %ebx
80108149:	5d                   	pop    %ebp
8010814a:	c3                   	ret    

8010814b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010814b:	55                   	push   %ebp
8010814c:	89 e5                	mov    %esp,%ebp
8010814e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
80108154:	85 c0                	test   %eax,%eax
80108156:	79 0a                	jns    80108162 <allocuvm+0x17>
    return 0;
80108158:	b8 00 00 00 00       	mov    $0x0,%eax
8010815d:	e9 c1 00 00 00       	jmp    80108223 <allocuvm+0xd8>
  if(newsz < oldsz)
80108162:	8b 45 10             	mov    0x10(%ebp),%eax
80108165:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108168:	73 08                	jae    80108172 <allocuvm+0x27>
    return oldsz;
8010816a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010816d:	e9 b1 00 00 00       	jmp    80108223 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108172:	8b 45 0c             	mov    0xc(%ebp),%eax
80108175:	05 ff 0f 00 00       	add    $0xfff,%eax
8010817a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108182:	e9 8d 00 00 00       	jmp    80108214 <allocuvm+0xc9>
    mem = kalloc();
80108187:	e8 d5 ac ff ff       	call   80102e61 <kalloc>
8010818c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010818f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108193:	75 2c                	jne    801081c1 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108195:	c7 04 24 25 8c 10 80 	movl   $0x80108c25,(%esp)
8010819c:	e8 ff 81 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801081a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a4:	89 44 24 08          	mov    %eax,0x8(%esp)
801081a8:	8b 45 10             	mov    0x10(%ebp),%eax
801081ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801081af:	8b 45 08             	mov    0x8(%ebp),%eax
801081b2:	89 04 24             	mov    %eax,(%esp)
801081b5:	e8 6b 00 00 00       	call   80108225 <deallocuvm>
      return 0;
801081ba:	b8 00 00 00 00       	mov    $0x0,%eax
801081bf:	eb 62                	jmp    80108223 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801081c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081c8:	00 
801081c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081d0:	00 
801081d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d4:	89 04 24             	mov    %eax,(%esp)
801081d7:	e8 27 cf ff ff       	call   80105103 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081df:	89 04 24             	mov    %eax,(%esp)
801081e2:	e8 cc f5 ff ff       	call   801077b3 <v2p>
801081e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081ea:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801081f1:	00 
801081f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801081f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081fd:	00 
801081fe:	89 54 24 04          	mov    %edx,0x4(%esp)
80108202:	8b 45 08             	mov    0x8(%ebp),%eax
80108205:	89 04 24             	mov    %eax,(%esp)
80108208:	e8 d8 fa ff ff       	call   80107ce5 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010820d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108217:	3b 45 10             	cmp    0x10(%ebp),%eax
8010821a:	0f 82 67 ff ff ff    	jb     80108187 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108220:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108223:	c9                   	leave  
80108224:	c3                   	ret    

80108225 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108225:	55                   	push   %ebp
80108226:	89 e5                	mov    %esp,%ebp
80108228:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010822b:	8b 45 10             	mov    0x10(%ebp),%eax
8010822e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108231:	72 08                	jb     8010823b <deallocuvm+0x16>
    return oldsz;
80108233:	8b 45 0c             	mov    0xc(%ebp),%eax
80108236:	e9 a4 00 00 00       	jmp    801082df <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010823b:	8b 45 10             	mov    0x10(%ebp),%eax
8010823e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108243:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108248:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010824b:	e9 80 00 00 00       	jmp    801082d0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108253:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010825a:	00 
8010825b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010825f:	8b 45 08             	mov    0x8(%ebp),%eax
80108262:	89 04 24             	mov    %eax,(%esp)
80108265:	e8 d9 f9 ff ff       	call   80107c43 <walkpgdir>
8010826a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010826d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108271:	75 09                	jne    8010827c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108273:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010827a:	eb 4d                	jmp    801082c9 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010827c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010827f:	8b 00                	mov    (%eax),%eax
80108281:	83 e0 01             	and    $0x1,%eax
80108284:	85 c0                	test   %eax,%eax
80108286:	74 41                	je     801082c9 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010828b:	8b 00                	mov    (%eax),%eax
8010828d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108292:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108295:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108299:	75 0c                	jne    801082a7 <deallocuvm+0x82>
        panic("kfree");
8010829b:	c7 04 24 3d 8c 10 80 	movl   $0x80108c3d,(%esp)
801082a2:	e8 93 82 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
801082a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082aa:	89 04 24             	mov    %eax,(%esp)
801082ad:	e8 0e f5 ff ff       	call   801077c0 <p2v>
801082b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801082b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082b8:	89 04 24             	mov    %eax,(%esp)
801082bb:	e8 08 ab ff ff       	call   80102dc8 <kfree>
      *pte = 0;
801082c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801082c9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082d6:	0f 82 74 ff ff ff    	jb     80108250 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801082dc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082df:	c9                   	leave  
801082e0:	c3                   	ret    

801082e1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082e1:	55                   	push   %ebp
801082e2:	89 e5                	mov    %esp,%ebp
801082e4:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801082e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082eb:	75 0c                	jne    801082f9 <freevm+0x18>
    panic("freevm: no pgdir");
801082ed:	c7 04 24 43 8c 10 80 	movl   $0x80108c43,(%esp)
801082f4:	e8 41 82 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108300:	00 
80108301:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108308:	80 
80108309:	8b 45 08             	mov    0x8(%ebp),%eax
8010830c:	89 04 24             	mov    %eax,(%esp)
8010830f:	e8 11 ff ff ff       	call   80108225 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108314:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010831b:	eb 48                	jmp    80108365 <freevm+0x84>
    if(pgdir[i] & PTE_P){
8010831d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108320:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108327:	8b 45 08             	mov    0x8(%ebp),%eax
8010832a:	01 d0                	add    %edx,%eax
8010832c:	8b 00                	mov    (%eax),%eax
8010832e:	83 e0 01             	and    $0x1,%eax
80108331:	85 c0                	test   %eax,%eax
80108333:	74 2c                	je     80108361 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108338:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010833f:	8b 45 08             	mov    0x8(%ebp),%eax
80108342:	01 d0                	add    %edx,%eax
80108344:	8b 00                	mov    (%eax),%eax
80108346:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010834b:	89 04 24             	mov    %eax,(%esp)
8010834e:	e8 6d f4 ff ff       	call   801077c0 <p2v>
80108353:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108359:	89 04 24             	mov    %eax,(%esp)
8010835c:	e8 67 aa ff ff       	call   80102dc8 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108361:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108365:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010836c:	76 af                	jbe    8010831d <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010836e:	8b 45 08             	mov    0x8(%ebp),%eax
80108371:	89 04 24             	mov    %eax,(%esp)
80108374:	e8 4f aa ff ff       	call   80102dc8 <kfree>
}
80108379:	c9                   	leave  
8010837a:	c3                   	ret    

8010837b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010837b:	55                   	push   %ebp
8010837c:	89 e5                	mov    %esp,%ebp
8010837e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108381:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108388:	00 
80108389:	8b 45 0c             	mov    0xc(%ebp),%eax
8010838c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108390:	8b 45 08             	mov    0x8(%ebp),%eax
80108393:	89 04 24             	mov    %eax,(%esp)
80108396:	e8 a8 f8 ff ff       	call   80107c43 <walkpgdir>
8010839b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010839e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083a2:	75 0c                	jne    801083b0 <clearpteu+0x35>
    panic("clearpteu");
801083a4:	c7 04 24 54 8c 10 80 	movl   $0x80108c54,(%esp)
801083ab:	e8 8a 81 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	8b 00                	mov    (%eax),%eax
801083b5:	83 e0 fb             	and    $0xfffffffb,%eax
801083b8:	89 c2                	mov    %eax,%edx
801083ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bd:	89 10                	mov    %edx,(%eax)
}
801083bf:	c9                   	leave  
801083c0:	c3                   	ret    

801083c1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083c1:	55                   	push   %ebp
801083c2:	89 e5                	mov    %esp,%ebp
801083c4:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
801083c7:	e8 b1 f9 ff ff       	call   80107d7d <setupkvm>
801083cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083d3:	75 0a                	jne    801083df <copyuvm+0x1e>
    return 0;
801083d5:	b8 00 00 00 00       	mov    $0x0,%eax
801083da:	e9 f1 00 00 00       	jmp    801084d0 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801083df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083e6:	e9 c4 00 00 00       	jmp    801084af <copyuvm+0xee>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083f5:	00 
801083f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801083fa:	8b 45 08             	mov    0x8(%ebp),%eax
801083fd:	89 04 24             	mov    %eax,(%esp)
80108400:	e8 3e f8 ff ff       	call   80107c43 <walkpgdir>
80108405:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108408:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010840c:	75 0c                	jne    8010841a <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010840e:	c7 04 24 5e 8c 10 80 	movl   $0x80108c5e,(%esp)
80108415:	e8 20 81 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010841a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841d:	8b 00                	mov    (%eax),%eax
8010841f:	83 e0 01             	and    $0x1,%eax
80108422:	85 c0                	test   %eax,%eax
80108424:	75 0c                	jne    80108432 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108426:	c7 04 24 78 8c 10 80 	movl   $0x80108c78,(%esp)
8010842d:	e8 08 81 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108435:	8b 00                	mov    (%eax),%eax
80108437:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010843c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
8010843f:	e8 1d aa ff ff       	call   80102e61 <kalloc>
80108444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010844b:	75 02                	jne    8010844f <copyuvm+0x8e>
      goto bad;
8010844d:	eb 71                	jmp    801084c0 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010844f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108452:	89 04 24             	mov    %eax,(%esp)
80108455:	e8 66 f3 ff ff       	call   801077c0 <p2v>
8010845a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108461:	00 
80108462:	89 44 24 04          	mov    %eax,0x4(%esp)
80108466:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108469:	89 04 24             	mov    %eax,(%esp)
8010846c:	e8 61 cd ff ff       	call   801051d2 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108474:	89 04 24             	mov    %eax,(%esp)
80108477:	e8 37 f3 ff ff       	call   801077b3 <v2p>
8010847c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010847f:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108486:	00 
80108487:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010848b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108492:	00 
80108493:	89 54 24 04          	mov    %edx,0x4(%esp)
80108497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849a:	89 04 24             	mov    %eax,(%esp)
8010849d:	e8 43 f8 ff ff       	call   80107ce5 <mappages>
801084a2:	85 c0                	test   %eax,%eax
801084a4:	79 02                	jns    801084a8 <copyuvm+0xe7>
      goto bad;
801084a6:	eb 18                	jmp    801084c0 <copyuvm+0xff>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801084a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084b5:	0f 82 30 ff ff ff    	jb     801083eb <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
801084bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084be:	eb 10                	jmp    801084d0 <copyuvm+0x10f>

bad:
  freevm(d);
801084c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c3:	89 04 24             	mov    %eax,(%esp)
801084c6:	e8 16 fe ff ff       	call   801082e1 <freevm>
  return 0;
801084cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084d0:	c9                   	leave  
801084d1:	c3                   	ret    

801084d2 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084d2:	55                   	push   %ebp
801084d3:	89 e5                	mov    %esp,%ebp
801084d5:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084df:	00 
801084e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801084e7:	8b 45 08             	mov    0x8(%ebp),%eax
801084ea:	89 04 24             	mov    %eax,(%esp)
801084ed:	e8 51 f7 ff ff       	call   80107c43 <walkpgdir>
801084f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	8b 00                	mov    (%eax),%eax
801084fa:	83 e0 01             	and    $0x1,%eax
801084fd:	85 c0                	test   %eax,%eax
801084ff:	75 07                	jne    80108508 <uva2ka+0x36>
    return 0;
80108501:	b8 00 00 00 00       	mov    $0x0,%eax
80108506:	eb 25                	jmp    8010852d <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850b:	8b 00                	mov    (%eax),%eax
8010850d:	83 e0 04             	and    $0x4,%eax
80108510:	85 c0                	test   %eax,%eax
80108512:	75 07                	jne    8010851b <uva2ka+0x49>
    return 0;
80108514:	b8 00 00 00 00       	mov    $0x0,%eax
80108519:	eb 12                	jmp    8010852d <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010851b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851e:	8b 00                	mov    (%eax),%eax
80108520:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108525:	89 04 24             	mov    %eax,(%esp)
80108528:	e8 93 f2 ff ff       	call   801077c0 <p2v>
}
8010852d:	c9                   	leave  
8010852e:	c3                   	ret    

8010852f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010852f:	55                   	push   %ebp
80108530:	89 e5                	mov    %esp,%ebp
80108532:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108535:	8b 45 10             	mov    0x10(%ebp),%eax
80108538:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010853b:	e9 87 00 00 00       	jmp    801085c7 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108540:	8b 45 0c             	mov    0xc(%ebp),%eax
80108543:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108548:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010854b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010854e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108552:	8b 45 08             	mov    0x8(%ebp),%eax
80108555:	89 04 24             	mov    %eax,(%esp)
80108558:	e8 75 ff ff ff       	call   801084d2 <uva2ka>
8010855d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108560:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108564:	75 07                	jne    8010856d <copyout+0x3e>
      return -1;
80108566:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010856b:	eb 69                	jmp    801085d6 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010856d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108570:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108573:	29 c2                	sub    %eax,%edx
80108575:	89 d0                	mov    %edx,%eax
80108577:	05 00 10 00 00       	add    $0x1000,%eax
8010857c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010857f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108582:	3b 45 14             	cmp    0x14(%ebp),%eax
80108585:	76 06                	jbe    8010858d <copyout+0x5e>
      n = len;
80108587:	8b 45 14             	mov    0x14(%ebp),%eax
8010858a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010858d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108590:	8b 55 0c             	mov    0xc(%ebp),%edx
80108593:	29 c2                	sub    %eax,%edx
80108595:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108598:	01 c2                	add    %eax,%edx
8010859a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859d:	89 44 24 08          	mov    %eax,0x8(%esp)
801085a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801085a8:	89 14 24             	mov    %edx,(%esp)
801085ab:	e8 22 cc ff ff       	call   801051d2 <memmove>
    len -= n;
801085b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bf:	05 00 10 00 00       	add    $0x1000,%eax
801085c4:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085c7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085cb:	0f 85 6f ff ff ff    	jne    80108540 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801085d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085d6:	c9                   	leave  
801085d7:	c3                   	ret    
