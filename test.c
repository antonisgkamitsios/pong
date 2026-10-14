// Testing file to see call conventions in assembly
#include <stdio.h>
#include <stdbool.h>
#include "raylib.h"

int main()
{

  const char *text = "%d - %d";
  TextFormat(text);

  return 0;
}