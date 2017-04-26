/*
*	main.c by Jared Kamp
*	created on 11/5/2015
*	A simple program to run on the KL25X128
*/
#include "derivative.h" /* include peripheral declarations */
#define CTOF 0x80

/*Activate Port B via System Clock Gating Control Register 5 */
const uint32_t	Port_Clock_Gate_Control_B =  0b10000000000;	//Bit 10 is port B
const uint32_t	Port_Clock_Gate_Control_D =  0b1000000000000;	//Bit 12 is port D
  		
/*MUX Manipulation */
const uint32_t	MUX_GPIO_Mask_SET = 0b00000000000000000000000100000000;	//Set GPIO option in MUX by
const uint32_t	MUX_GPIO_Mask_CLR = 0b11111111111111111111100111111111;	//Masking 001 to the MUX bits
		
/*LED bit masks */
const uint32_t	red = 0x00040000;	//Red is bit 18
const uint32_t	blue = 0x00000002;	//blue is bit ?
const uint32_t	green = 0x00080000;	//green is bit 19

/* Variables are saved in RAM */
uint32_t data;				//For storing register data
volatile uint32_t *addr;	//For storing register addresses
/* NOTE: saved system addresses (such as SIM_SCGC5 are declared volatile
 * when defined in the system. It is therefore necessary to declare any 
 * variable that will use these values volatile.
 */

/* Functions for convenience */
void waitMillis(uint32_t);
void ledOn(uint32_t);
void ledOff(uint32_t);
void ledToggle(uint32_t);
void setStates(uint8_t);


int main(void) {
	//Enable the internal reference clock via the
	//	Multipurpose Clock Generator control register 1	
	MCG_C1 |= (1 << 1);
		
	//Select MCGIRCLK as clock for TPM0 using TPMSRC in
	//	the System Integration Module control register 2
	SIM_SOPT2 |= (1 << 24)|(1<<25); 
	
	//Turn on TPM0 clock using TPM0 in SIM_SCGC6
	// 	(System Clock Gating Control register 6)
	SIM_SCGC6 |= (1 << 24);
		
	//Reset the LPTPM counter to avoid confusion about when the first
	//	counter overflow will occur.
	TPM0_CNT = 0;
		
	//Disable the LPTPM counter while setting up by writing 0 to TPM0_SC
	TPM0_SC &= 0xFFFFFFE7;
		
	//Initialize TPM0_MOD flag with roll-over value for 1ms
	TPM0_MOD = 3200;
		
	//Enable internal module clock such that the LPTPM counter
	//	increments on every LPTPM counter clock
	TPM0_SC |= (1 << 6);
		
	//Clear TOF flag by writing 1 to it's bit in TPM0_SC
	TPM0_SC |= CTOF;
	
	//Activate port C
	SIM_SCGC5 |= SIM_SCGC5_PORTC_MASK;
	
	//Set the pin as GPIO in the MUX settings
	PORTC_PCR0 = PORT_PCR_MUX(1);
	
	//Set the pin as output
	GPIOC_PDDR = 0b1;
	
	//Turn the pin off
	GPIOC_PCOR = 0b1;
	
	//reenable the LPTPM counter while setting up by writing 1 to TPM0_SC
	TPM0_SC |= (1 << 3);
		
	data = SIM_SCGC5;				//Store the data from the specified register
	data |= Port_Clock_Gate_Control_B;//Update the data to what it should be
	addr = &SIM_SCGC5;				//Get the address of the specified register
	*addr = data;					//"Upload" the data to the specified register
	
	/* Activate port D by masking the Port Clock Gate Control bits */		
	data = SIM_SCGC5;				//Store the data from the specified register
	data |= Port_Clock_Gate_Control_D;//Update the data to what it should be
	addr = &SIM_SCGC5;				//Get the address of the specified register
	*addr = data;					//"Upload" the data to the specified register
	
	/* Set the LED pin as GPIO in the MUX settings via bit-masking */
	/* Red */
	data = PORTB_PCR18;			//Store the data from the specified register
	data |= MUX_GPIO_Mask_SET;	//Update the data to what it should be
	data &= MUX_GPIO_Mask_CLR;	//Update the data to what it should be
	addr = &PORTB_PCR18;		//Get the address of the specified register
	*addr = data;				//"Upload" the data to the specified register
	/* Blue */
	data = PORTD_PCR1;			//Store the data from the specified register
	data |= MUX_GPIO_Mask_SET;	//Update the data to what it should be
	data &= MUX_GPIO_Mask_CLR;	//Update the data to what it should be
	addr = &PORTD_PCR1;		//Get the address of the specified register
	*addr = data;				//"Upload" the data to the specified register		
	/* Green */
	data = PORTB_PCR19;			//Store the data from the specified register
	data |= MUX_GPIO_Mask_SET;	//Update the data to what it should be
	data &= MUX_GPIO_Mask_CLR;	//Update the data to what it should be
	addr = &PORTB_PCR19;		//Get the address of the specified register
	*addr = data;				//"Upload" the data to the specified register
		
	/* Set the LED pin as an output */
	/* Red */
	data = GPIOB_PDDR;		//Store the data from the specified register
	data |= red;			//Update the data to what it should be
	addr = &GPIOB_PDDR;		//Get the address of the specified register
	*addr = data;			//"Upload" the data to the specified register
	/* Blue */
	data = GPIOD_PDDR;		//Store the data from the specified register
	data |= blue;			//Update the data to what it should be
	addr = &GPIOD_PDDR;		//Get the address of the specified register
	*addr = data;			//"Upload" the data to the specified register
	/* Green */
	data = GPIOB_PDDR;		//Store the data from the specified register
	data |= green;			//Update the data to what it should be
	addr = &GPIOB_PDDR;		//Get the address of the specified register
	*addr = data;			//"Upload" the data to the specified register

	/* Turn off the LED */
	ledOff(red);
	ledOff(green);
	ledOff(blue);
			
	for(;;) {
		/*Demo 1
		//red
		ledOn(red);
		waitMillis(500);
		//white
		ledOn(blue);
		ledOn(green);
		waitMillis(500);
		//purple
		ledOff(green);
		waitMillis(500);
		//yellow
		ledOn(green);
		ledOff(blue);
		waitMillis(500);
		//teal
		ledOff(red);
		ledOn(blue);
		ledOn(green);
		waitMillis(500);
		//blue
		ledOff(green);
		waitMillis(500);
		//green
		ledOff(blue);
		ledOn(green);
		waitMillis(500);
		ledOff(green);
		*/
		// Demo 2
		ledToggle(blue);		
		//Wait for the TOF flag to be asserted
		while((TPM0_SC & CTOF) != CTOF);
		
		//Clear TOF flag by writing 1 to it's bit in TPM0_SC
		TPM0_SC |= CTOF;
		/*/
		/* Demo 3
		TSI0_GENCS |= (1 << 7)|(1 << 6);
		//start scan of touch sensor
		TSI0_DATA |= (1 << 22);
		
		//DigitalOut gpo(PTB8);
		//DigitalOut led(LED_RED);
		//PwmOut led(LED_RED) = 1.0 - tsi.readPercentage();
		waitMillis(500);
		*/
	}
	return 0;
}

/* Power on a specified LED */
void ledOn(uint32_t led) {
	if(led == red || led == green)
	{
	addr = &GPIOB_PCOR;	//Clear (turn on)
	*addr = led;		//the led
	}
	else
	{
	addr = &GPIOD_PCOR;	//Clear (turn on)
	*addr = led;		//the led
	}
}

/* Power off a specified LED */
void ledOff(uint32_t led) {
	if(led == red || led == green)
	{
	addr = &GPIOB_PSOR;	//Set (turn off)
	*addr = led;		//the led
	}
	else
	{
	addr = &GPIOD_PSOR;	//Set (turn off)
	*addr = led;		//the led
	}
}

/* Toggle a specified LED */
void ledToggle(uint32_t led) {
	if(led == red || led == green)
	{
	addr = &GPIOB_PTOR;
	*addr = led;
	}
	else
	{
		addr = &GPIOD_PTOR;	//Set (turn off)
		*addr = led;		//the led
	}
}

/* Wait for a specified number of milliseconds */
void waitMillis(uint32_t millis) {
	millis *= 2400;
	while(millis > 0) millis--;
}
