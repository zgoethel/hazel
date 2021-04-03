#include "display.h"

void print(char* message)
{
    char* temp = message;
    
    while (*temp != '\0')
    {
        char c = *(temp++);
        
        switch (c)
        {
        case '\n':
        case '\t':
        case '\r':
        case '\b':
        case '\f':
            print_special(c);
            break;
        default:
            print_char(c);
        }
    }
}
