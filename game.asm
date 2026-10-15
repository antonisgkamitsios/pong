
format ELF64

section '.text' executable
public _start
extrn printf
extrn _exit

include 'raylib.inc'
include 'utils.inc'


FACTOR = 100
WIDTH = 16*FACTOR
HEIGHT = 9*FACTOR

SCORE_FONT = 80

BALL_SIZE = dword 20.0
BALL_SPEED = dword 500.0

PLAYER_WIDTH = dword 20.0
PLAYER_HEIGHT = dword 200.0
PLAYER_SPEED = dword 500.0
PLAYER_PADDING = BALL_SIZE

COLOR_BACKGROUND = 0xFF181818
COLOR_WHITE = 0xFFFFFFFF

struc vector x,y {
  .x dd x
  .y dd y
}

; rdi void *player_pos
check_player_collision:
  push rdi
  CheckCollisionRecs [rdi], [player_size], [ball_pos], [ball_size]
  pop rdi
  cmp al, 1
  je .collide
  jmp .over

.collide:

  movss xmm0, [ball_vel.x]
  mulss xmm0, [rspeed]
  movss [ball_vel.x], xmm0

  lea rax, [player_1_pos]
  cmp rdi, rax
  jne .right_player

.left_player:
  movss xmm0, [rdi]
  addss xmm0, [player_size.x]
  movss [ball_pos.x], xmm0
  jmp .over

.right_player:
  movss xmm0, [rdi]
  subss xmm0, [ball_size.x]
  movss [ball_pos.x], xmm0

.over:
  ret

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

  ; y = y - v*dt
  movss xmm0, [rdi]

  movss xmm2, [delta]
  mulss xmm2, [player_speed]
  mulss xmm2, [player_vel.y]
  subss xmm0, xmm2

  xorps xmm1, xmm1
  maxss xmm0, xmm1

  movss [rdi], xmm0
  jmp .over


.move_down:
  pop rdx
  pop rsi
  pop rdi

  ; y = y+v*dt
  movss xmm0, [delta]
  mulss xmm0, [player_speed]
  mulss xmm0,[player_vel.y] 
  addss xmm0, [rdi]

  movss xmm1, [h]
  cvtdq2ps xmm1, xmm1
  subss xmm1, [player_size.y]
  minss xmm0, xmm1

  movss [rdi], xmm0
  jmp .over

.over:
  ret

.no_op:
  pop rdx
  pop rsi
  pop rdi
  ret

reset_ball:
  ; ball velocity
  movss xmm0, [vel]
  GetRandomValue 0, 1
  cmp rax, 0
  je .negative

  jmp .over

.negative:
  mulss xmm0, [rspeed]

.over:
  movss [ball_vel.x], xmm0
  movss [ball_vel.y], xmm0

  ; ball position
  GetScreenWidth
  divide rax, 2
  mov [ball_pos.x], eax
  movss xmm0, [ball_pos.x]
  cvtdq2ps xmm0, xmm0
  subss xmm0, [ball_size.x]
  movss [ball_pos.x], xmm0

  GetScreenHeight
  divide rax, 2
  mov [ball_pos.y], eax
  movss xmm0, [ball_pos.y]
  cvtdq2ps xmm0, xmm0
  subss xmm0, [ball_size.y]
  movss [ball_pos.y], xmm0

  ret

init_state:
  ; init ball's state
  call reset_ball
  
  ; init players state
  GetScreenWidth
  mov eax, [w]
  mov [player_2_pos.x], eax
  movss xmm0, [player_2_pos.x]
  cvtdq2ps xmm0, xmm0
  subss xmm0, [player_size.x]
  subss xmm0, [player_padding.x]
  movss [player_2_pos.x], xmm0

  GetScreenHeight
  divide rax, 2
  movd xmm0, eax
  cvtdq2ps xmm0, xmm0

  movss xmm1, [player_size.y]
  divss xmm1, [two]
  subss xmm0, xmm1

  movss [player_1_pos.y], xmm0
  movss [player_2_pos.y], xmm0

  ret

update_state:
  GetScreenWidth
  GetScreenHeight

  GetFrameTime
  movss [delta], xmm0

  movss xmm1, [last_scored]
  addss xmm1, [delta]
  movss [last_scored], xmm1

  ucomiss xmm1, [wait_time]
  jb .over_y

  ; x = x+v*dt
  mulss xmm0, [ball_vel.x]
  mulss xmm0, [ball_speed]
  addss xmm0, [ball_pos.x]

  xorps xmm1, xmm1
  maxss xmm0, xmm1
  ucomiss xmm0, xmm1
  je .player_2_scored


  movss xmm2, [w] 
  cvtdq2ps xmm2, xmm2
  subss xmm2, [ball_size.x]
  minss xmm0, xmm2
  ucomiss xmm0, xmm2
  je .player_1_scored

  movss [ball_pos.x], xmm0
  jmp .over_x


.flip_dx:
  movss xmm0, [ball_vel.x]
  mulss xmm0, [rspeed]
  movss [ball_vel.x], xmm0

  .over_x:

  ; y = y+v*dt
  movss xmm0, [delta]
  mulss xmm0, [ball_speed]
  mulss xmm0, [ball_vel.y]
  addss xmm0, [ball_pos.y]

  xorps xmm1, xmm1
  ucomiss xmm0, xmm1
  jb .flip_dy

  movss xmm2, [h]
  cvtdq2ps xmm2, xmm2
  subss xmm2, [ball_size.y]
  ucomiss xmm0, xmm2
  ja .flip_dy

  movss [ball_pos.y], xmm0
  jmp .over_y

.flip_dy:
  movss xmm0, [ball_vel.y]
  mulss xmm0, [rspeed]
  movss [ball_vel.y], xmm0

.over_y:
  funcall3 move_player, player_1_pos.y, KEY_W, KEY_S
  funcall3 move_player, player_2_pos.y, KEY_UP, KEY_DOWN

  funcall1 check_player_collision, player_1_pos
  funcall1 check_player_collision, player_2_pos

  ret
.player_1_scored:
  inc [player_1_score]
  xorps xmm0, xmm0
  movss [last_scored], xmm0

  jmp .over
.player_2_scored:
  inc [player_2_score]
  xorps xmm0, xmm0
  movss [last_scored], xmm0
.over:
  call reset_ball
.no_op:
  ret


render_state:
    push rdi
    DrawRectangleV [ball_pos], [ball_size], COLOR_WHITE
    DrawRectangleV [player_1_pos], [player_size], COLOR_WHITE
    DrawRectangleV [player_2_pos], [player_size], COLOR_WHITE


    ; w/2 - size/2
    GetScreenWidth
    divide rax, 2
    mov r14, rax


    TextFormat score_text, [player_1_score], [player_2_score]
    mov r15, rax

    MeasureText r15, SCORE_FONT
    divide rax, 2
    sub r14, rax

    DrawText r15, r14, 20, SCORE_FONT, COLOR_WHITE

    pop rdi
  ret


_start:
  InitWindow WIDTH, HEIGHT, title
  call init_state

  SetTargetFPS 60
   
.again:
  WindowShouldClose .done
  
  call update_state

  ClearBackground COLOR_BACKGROUND

  BeginDrawing


  call render_state

  EndDrawing
  jmp .again

.done:
  CloseWindow
  exit 0


section '.data' writeable
title db "Ping Pong in asm", 0
score_text db "%d - %d", 0

w rd 1
h rd 1
delta rd 1

ball_size vector BALL_SIZE, BALL_SIZE
ball_pos vector 0.0, 0.0
ball_vel vector 1.0, 1.0
; ball_vel vector 50.0, 50.0

player_size vector PLAYER_WIDTH, PLAYER_HEIGHT
player_padding vector PLAYER_PADDING, PLAYER_PADDING
player_vel vector 1.0, 1.0

player_1_pos vector 0.0, 0.0
player_2_pos vector 0.0, 0.0

collision_pos vector 0.0, 0.0
collision_size vector 0.0, 0.0

rspeed dd -1.0
vel dd 1.0
two dd 2.0
player_speed dd PLAYER_SPEED
ball_speed dd BALL_SPEED

last_scored dd 0.0
wait_time dd 1.5

player_1_score dd 0
player_2_score dd 0
