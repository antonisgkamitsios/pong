macro funcall fn {
  call fn
}

macro funcall1 fn, a {
  mov rdi, a

  call fn
}

macro funcall2 fn, a, b {
  mov rdi, a
  mov rsi, b

  call fn
}

macro funcall3 fn, a, b, c {
  mov rdi, a
  mov rsi, b
  mov rdx, c

  call fn
}

macro funcall5 fn, a, b, c, d, e {
  mov rdi, a
  mov rsi, b
  mov rdx, c
  mov rcx, d
  mov r8,  e

  call fn
}

macro divide a, b {
  xor rdx, rdx
  mov rax, a
  mov rbx, b
  div rbx
}

macro multiply a, b{
  mov rax, a
  mov rcx, b
  imul rcx
}

macro exit code {
 funcall1 _exit, code
}
