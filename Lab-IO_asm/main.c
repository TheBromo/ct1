#include <stdint.h>

void out_word(uint32_t out_address, uint32_t out_value);
uint32_t in_word(uint32_t in_address); 


static const uint32_t DIPSW_ADDRESS = 0x60000200;
static const uint32_t LED_ADDRESS = 0x60000100;

int main(void) {
	while (1) {
		uint32_t dip_switch_value = in_word(DIPSW_ADDRESS);
		out_word(LED_ADDRESS, dip_switch_value);
	}
}