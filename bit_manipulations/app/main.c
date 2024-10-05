/* -----------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zurich University of             -
 * --  _| |_| | | | |____ ____) |  Applied Sciences                 -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- main.c
 * --
 * -- main for Computer Engineering "Bit Manipulations"
 * --
 * -- $Id: main.c 744 2014-09-24 07:48:46Z ruan $
 * ------------------------------------------------------------------
 */
//#include <reg_ctboard.h>
#include "utils_ctboard.h"

#define ADDR_DIP_SWITCH_31_0 0x60000200
#define ADDR_DIP_SWITCH_7_0  0x60000200
#define ADDR_LED_31_24       0x60000103
#define ADDR_LED_23_16       0x60000102
#define ADDR_LED_15_8        0x60000101
#define ADDR_LED_7_0         0x60000100
#define ADDR_BUTTONS         0x60000210

// define your own macros for bitmasks below (#define)
/// STUDENTS: To be programmed
#define MASK_DARK 0b11001111
#define MASK_BRIGHT 0b11000000



/// END: To be programmed

int main(void)
{
    uint8_t led_value = 0;

    // add variables below
    /// STUDENTS: To be programmed
		uint8_t counter =0, last_buttons_state =0, push_events=0, value=0;



    /// END: To be programmed

    while (1) {
        // ---------- Task 3.1 ----------
        led_value = read_byte(ADDR_DIP_SWITCH_7_0);

        /// STUDENTS: To be programmed
				// apply masks
				led_value |= MASK_BRIGHT;
				led_value	&= MASK_DARK;


        /// END: To be programmed

        write_byte(ADDR_LED_7_0, led_value);

        // ---------- Task 3.2 and 3.3 ----------
        /// STUDENTS: To be programmed
				uint8_t buttons = read_byte(ADDR_BUTTONS);
				//cutoff
				buttons &= 0b00001111;
				
				uint8_t edges = buttons & ~last_buttons_state;
			
				//only read last bit
				uint8_t lastBit = buttons & 0b00000001;
				//count how long button is pressed
				if(lastBit ==1) counter ++;
			
				//check if it has changes meaning been pressed
				if(((edges & 0b00000001)) == 1){ 
					push_events ++;
				}
				
				switch(edges){
					//handle Button T3: The variable shall be assigned the value set on the dip switches S7 to S0. 
					default: //if more than one are pressed or case 0b00001000
						value = read_byte(ADDR_DIP_SWITCH_7_0);
						break;
					//handle Button T2: The value of the variable shall be bit-wise inverted (one’s complement). 
					case 0b00000100:
						value  ^= 0b00111100 ;
						break;
					//handle Button T1: The value of the variable shall be shifted by one bit to the left (<< operator). 
					case 0b00000010:
						value = value << 1;
						break;
					//handle Button T0: The value of the variable shall be shifted by one bit to the right (>> operator). 
					case 0b00000001:
						value = value >> 1;
						break;
					//handle  In the case where more than one button is pressed simultaneously only one action shall be carried out. 
					// 				Continuously output the value of the variable on LED23 to LED16.
					case 0b00000000:
						write_byte(ADDR_LED_23_16,value);
						break;
				}

				last_buttons_state = buttons; 
				write_byte(ADDR_LED_15_8, counter);
				write_byte(ADDR_LED_31_24, push_events);
        /// END: To be programmed
    }
}
