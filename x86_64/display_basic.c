#include "kernel/display.h"

#define VIDEO_WIDTH 80
#define VIDEO_HEIGHT 25

#define TAB_SIZE 4

void roll_up();

char* video_mem = (char*)0xb8000;
unsigned int cursor = 0;

void print_char(char c)
{
    if (cursor == VIDEO_WIDTH * VIDEO_HEIGHT)
    {
        cursor -= VIDEO_WIDTH;
        roll_up();
    }
    
    video_mem[cursor * 2] = c;
    video_mem[cursor * 2 + 1] = 0x0F;
    
    cursor++;
}

void roll_up()
{
    int i = 0;
    
    for (i; i < VIDEO_WIDTH * (VIDEO_HEIGHT - 1); i++)
    {
        video_mem[i * 2] = video_mem[(i + VIDEO_WIDTH) * 2];
        video_mem[i * 2 + 1] = video_mem[(i + VIDEO_WIDTH) * 2 + 1];
    }
    
    for (i; i < VIDEO_WIDTH * VIDEO_HEIGHT; i++)
    {
        video_mem[i * 2] = 0x00;
        video_mem[i * 2 + 1] = 0x00;
    }
}

void print_special(char c)
{
    int req_tab = TAB_SIZE - cursor % TAB_SIZE;
    int i = 0;
    
    switch (c)
    {
    case '\n':
        if (cursor < VIDEO_WIDTH * (VIDEO_HEIGHT - 1))
            cursor += VIDEO_WIDTH;
        else
            roll_up();
    case '\r':
        cursor -= cursor % VIDEO_WIDTH;
        break;
        
    case '\t':
        i = 0;
        for (i; i < req_tab; i++)
            print_char(' ');
        break;
        
    case '\b':
        if (cursor > 0)
            cursor--;
        break;
        
    case '\f':
        if (cursor < VIDEO_WIDTH * (VIDEO_HEIGHT - 1))
            cursor += VIDEO_WIDTH;
        else
            roll_up();
        break;
    }
}
