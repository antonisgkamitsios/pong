format ELF64

section '.text' executable
public _start
extrn printf
extrn InitWindow
extrn WindowShouldClose
extrn CloseWindow
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn DrawRectangle
extrn GetScreenWidth
extrn GetScreenHeight
extrn DrawLine
extrn _exit

include 'utils.inc'

macro exit code {
 funcall1 _exit, code
}

macro WindowShouldClose jump_to {
  funcall WindowShouldClose
  cmp rax, 1
  je jump_to
}

macro CloseWindow {
  funcall CloseWindow
}

macro InitWindow width, height, title {
  funcall3 InitWindow, width, height, title
}

macro GetScreenWidth {
  call GetScreenWidth
  mov [w], rax
}

macro GetScreenHeight {
  call GetScreenHeight
  mov [h], rax
}

macro ClearBackground color {
  funcall1 ClearBackground, color
}

macro BeginDrawing {
  call BeginDrawing
}

macro EndDrawing {
  call EndDrawing
}

macro DrawRectangle posX, posY, width, height, color {
  funcall5 DrawRectangle, posX, posY, width, height, color
}

; RLAPI void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);                // Draw a line
macro DrawLine startPosX, startPosY, endPosX, endPosY, color {
  funcall DrawLine, startPosX, startPosY, endPosX, endPosY, color
}

WIDTH = 800
HEIGHT = 600

BALL_WIDTH = 20
BALL_HEIGHT = 20

PLAYER_WIDTH = BALL_WIDTH
PLAYER_HEIGHT = 100
PLAYER_PADDING = BALL_WIDTH


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

  ; p2_x = w - player_width - player_padding
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
  ret

render_state: 
  ; render ball
  DrawRectangle [ball_x], [ball_y], BALL_WIDTH, BALL_HEIGHT, 0xFFFFFFFF


  ; render player_1
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
