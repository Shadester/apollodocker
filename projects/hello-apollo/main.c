#include <stdio.h>
#include <exec/types.h>

/* Apollo Vampire 68080 example program */
int main() {
    printf("Hello Apollo Vampire 68080!\n");
    printf("Cross-compiled with GCC 6.5.0\n");
    
    /* Apollo-specific code can go here */
    #ifdef APOLLO_68080
    printf("Apollo 68080 CPU features enabled\n");
    #endif
    
    return 0;
}