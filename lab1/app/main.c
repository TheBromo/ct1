#include "utils_ctboard.h"
#define LED_START 0x60000100
#define S_START 0x60000200
#define R_START 0x60000211
#define D_START 0x60000110
int main(void) {
 while (1) {
	 //aufgabe 4
	 //read from s7 to s0
	 uint32_t switches = read_word(S_START);
	 //write to led7 to led0
	 write_word(LED_START,switches);

	 //Aufgabe 5
	 uint8_t rotary = read_byte(R_START);
	 //cut off upper 4 bits
	 rotary = 0x0F & rotary;
	 const uint8_t display[] = 	 {
				0xC0,  // 0
        0xF9,  // 1
        0xA4,  // 2
        0xB0,  // 3
        0x99,  // 4
        0x92,  // 5
        0x82,  // 6
        0xF8,  // 7
        0x80,  // 8
        0x90,  // 9
        0x88,  // A
        0x83,  // b (lowercase to distinguish from 8)
        0xC6,  // C
        0xA1,  // d (lowercase to distinguish from 0)
        0x86,  // E
        0x8E   // F
		};
	 write_byte(0x60000100,rotary);
	 write_byte(0x60000101,display[rotary]);
	 write_byte(D_START, display[rotary]);
 }
} 