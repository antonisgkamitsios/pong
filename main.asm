format ELF64

section '.text' executable
public _start
extrn printf
extrn _exit

include 'raylib.inc'
include 'utils.inc'



macro exit code {
 funcall1 _exit, code
}


WIDTH = 800
HEIGHT = 600

BALL_WIDTH = 20
BALL_HEIGHT = 20

PLAYER_WIDTH = BALL_WIDTH
PLAYER_HEIGHT = 100
PLAYER_PADDING = BALL_WIDTH

PLAYER_SPEED = 2



; rdi void *player_y
; rsi int key_up
; rdx int key_down
move_player:
  push rdi
  push rsi
  push rdx

  IsKeyDown rdx
  cmp al, 1
  je .move_down

  IsKeyDown rsi
  cmp al, 1
  je .move_up


  jmp .no_op

.move_up:
  pop rdx
  pop rsi
  pop rdi
  mov rax, [rdi]
  sub rax, PLAYER_SPEED

  cmp rax, 0
  je .over
  mov [rdi], rax
  jmp .over
.move_down:
  pop rdx
  pop rsi
  pop rdi

  mov rax, [rdi]
  add rax, PLAYER_SPEED

  mov rbx, [h]
  sub rbx, PLAYER_HEIGHT
  cmp rax, rbx
  je .over
  mov [rdi], rax
  jmp .over
.over:
  ret
.no_op:
  pop rdx
  pop rsi
  pop rdi
  ret


init_state: 
  mov [ball_dx], 1
  mov [ball_dy], 1


  GetScreenWidth
  divide [w], 2
  sub rax, BALL_WIDTH
  mov [ball_x], rax

  GetScreenHeight
  divide [h], 2
  sub rax, BALL_HEIGHT
  mov [ball_y], rax

  mov [player_1_x], PLAYER_PADDING
  mov [player_1_y], PLAYER_PADDING

  mov rax, [w]
  sub rax, PLAYER_WIDTH
  sub rax, PLAYER_PADDING
  mov [player_2_x], rax
  mov [player_2_y], PLAYER_PADDING

  ret

update_state:
  ; this will populate [w]
  GetScreenWidth
  ; this will populate [h]
  GetScreenHeight

  mov rax, [ball_x]
  add rax, [ball_dx]
  cmp rax, 0
  jle .flip_dx
  
  mov rbx, [w]
  sub rbx, BALL_WIDTH
  cmp rax, rbx
  jge .flip_dx
  
  mov [ball_x], rax
  jmp .over_x

.flip_dx:
  multiply [ball_dx], -1
  mov [ball_dx], rax
.over_x:

  mov rax, [ball_y]
  add rax, [ball_dy]
  cmp rax, 0
  jle .flip_dy
  
  mov rbx, [h]
  sub rbx, BALL_HEIGHT
  cmp rax, rbx
  jge .flip_dy
  
  mov [ball_y], rax
  jmp .over_y

.flip_dy:
  multiply [ball_dy], -1
  mov [ball_dy], rax
.over_y:

  funcall3 move_player, player_1_y, KEY_W, KEY_S
  funcall3 move_player, player_2_y, KEY_UP, KEY_DOWN
  ret


render_state: 
  DrawRectangle [ball_x], [ball_y], BALL_WIDTH, BALL_HEIGHT, 0xFFFFFFFF
  DrawRectangle [player_1_x], [player_1_y], PLAYER_WIDTH, PLAYER_HEIGHT, 0xFFFFFFFF
  DrawRectangle [player_2_x], [player_2_y], PLAYER_WIDTH, PLAYER_HEIGHT, 0xFFFFFFFF
  ret

_start:
  InitWindow WIDTH, HEIGHT, title

  call init_state

.again:
  WindowShouldClose .done


  call update_state

  ClearBackground 0xFF181818

  BeginDrawing

  call render_state

  EndDrawing
  jmp .again

.done:
  CloseWindow
  exit 0


section '.data' writeable
title db "Ping Pong in asm", 0

w rq 1
h rq 1

ball_x rq 1
ball_nx rq 1

ball_y rq 1
ball_ny rq 1

ball_dx rq 1
ball_dy rq 1


player_1_x rq 1
player_1_y rq 1

player_2_x rq 1
player_2_y rq 1

