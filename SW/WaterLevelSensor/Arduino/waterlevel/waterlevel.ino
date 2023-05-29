#include <Arduino.h>
#include <U8g2lib.h>
#include <Wire.h>
#include <EEPROM.h>

// Debug print
#define DEBUG 

// OLED display 128x64 SH106 I2C Single Buffer
U8G2_SH1106_128X64_NONAME_1_HW_I2C OLED(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);

// Percentage lookup table
const byte SensorLUT[256] = {100,99,98,96,95,94,93,91,90,89,88,87,86,85,84,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,63,62,61,60,59,58,57,56,56,55,54,53,52,52,51,50,49,49,48,47,46,46,45,44,44,43,42,42,41,40,40,39,38,38,37,36,36,35,35,34,34,33,32,32,31,31,30,30,29,29,28,28,27,27,26,26,25,25,24,24,24,23,23,22,22,21,21,21,20,20,20,19,19,18,18,18,17,17,17,16,16,16,15,15,15,14,14,14,14,13,13,13,12,12,12,12,11,11,11,11,10,10,10,10,10,9,9,9,9,8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,6,6,5,5,5,5,5,5,5,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// CAL button pressed delay
#define BUTTON_CAL_DELAY	5000	// ms

// EEPROM ADDRESSES
#define EEPROM_CAL_WET  0
#define EEPROM_CAL_DRY  8
#define EEPROM_CURRENT  16

// Power-on timeout
#define POWER_ON_TIME 	10000

// Device state definitions
typedef enum _DEVICE_STATE{
	DEVICE_STATE_INIT = 0,
  DEVICE_STATE_SENSOR,
	DEVICE_STATE_CAL_WET,
  DEVICE_STATE_CAL_WET_DELAY,
	DEVICE_STATE_CAL_DRY,
	DEVICE_STATE_CAL_DRY_DELAY,
	DEVICE_STATE_DIAGNOSTICS,
  DEVICE_STATE_ERROR_SENSOR
	} DEVICE_STATE;
DEVICE_STATE deviceState;

// Global variables
bool buttonCalDryActive = false, buttonCalWetActive = false;
unsigned long buttonCalDryTimeStart, buttonCalWetTimeStart;
volatile unsigned long sensorPulseCount, sensorPulseValue; 
unsigned long calWetValue, calDryValue;
byte sensorPercentage;
byte loopCounter = 0;
bool batteryLowFlag = false;
unsigned int batteryValue;
unsigned long powerOnStartTime;

// I/O pins
#define PIN_SENSOR_PULSE      2
#define PIN_BUTTON_CAL_DRY  	3
#define PIN_BUTTON_CAL_WET  	4
#define PIN_POWER_ON          5
#define PIN_BATTERY_VOLTAGE		A0

void Dbg(const char* debugString)
{
#ifdef DEBUG
  Serial.println(debugString);
#endif  
}


// ------------------------------------------


// Translate current sensor value into percentage
unsigned char calcSensorPercentage()
{
    unsigned long freqStep = (calDryValue - calWetValue) >> 8;
    unsigned long tableValue = calWetValue;
    int LUTindex = 0;
    for (LUTindex = 0; LUTindex < 255; ++LUTindex){
        tableValue += freqStep;
        if (sensorPulseValue < tableValue){
            break;
        }
    }
    return SensorLUT[LUTindex];
}

// Display functions
void DisplayInit()
{
  // Show previous value
  byte oldPercentage;
  EEPROM.get(EEPROM_CURRENT, oldPercentage);
  char sensorPercentageStr[4];
  sprintf(sensorPercentageStr, "%3u %%", oldPercentage);
  OLED.setFont(u8g2_font_crox4h_tr);
 
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(45, 40, sensorPercentageStr); 
  } 
  while (OLED.nextPage());
}
 

void DisplayCalWetDelay()
{
  OLED.setFont(u8g2_font_crox4h_tr);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(28, 30, "CAL ~"); 
    OLED.drawStr(50, 50, "..."); 
  } 
  while (OLED.nextPage());
}

void DisplayCalWet()
{
  OLED.setFont(u8g2_font_crox4h_tr);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(28, 30, "CAL ~"); 
    OLED.drawStr(50, 50, "OK"); 
  } 
  while (OLED.nextPage());
}


void DisplayCalDryDelay()
{
  OLED.setFont(u8g2_font_crox4h_tr);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(28, 30, "CAL -"); 
    OLED.drawStr(50, 50, "..."); 
  } 
  while (OLED.nextPage());
}

void DisplayCalDry()
{
  OLED.setFont(u8g2_font_crox4h_tr);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(28, 30, "CAL -"); 
    OLED.drawStr(50, 50, "OK"); 
  } 
  while (OLED.nextPage());
}

void DisplayDiagnostics()
{
    OLED.setFont(u8g2_font_crox4h_tr);
    char row0[20];
    char row1[20];
    char row2[20];
    char row3[20];
    sprintf(row0, "%04u", batteryValue);
    sprintf(row1,"%06u", sensorPulseValue);
    sprintf(row2, "- %06u", calDryValue);
    sprintf(row3, "~ %06u", calWetValue);
    OLED.firstPage();
    do 
    {
      OLED.drawRFrame(0, 0, 128, 64, 5);
      OLED.drawStr(5, 17, row1); 
      OLED.drawStr(80, 17, row0); 
      OLED.drawStr(5, 37, row2); 
      OLED.drawStr(5, 57, row3); 
    } 
    while (OLED.nextPage());
}

void DisplayBatteryLow()
{
  if (!(loopCounter & 1)) {
    DisplaySensor();
  } else {
    OLED.setFont(u8g2_font_crox4h_tr);
    OLED.firstPage();
    do 
    {
      OLED.drawRFrame(0, 0, 128, 64, 5);
      OLED.drawStr(20, 40, "BATTERY"); 
    } 
    while (OLED.nextPage());
  }
}

void DisplaySensor()
{
  char sensorPercentageStr[4];
  sprintf(sensorPercentageStr, "%3u", sensorPercentage);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.setFont(u8g2_font_logisoso50_tn);
    OLED.drawStr(10, 56, sensorPercentageStr);  
    OLED.setFont(u8g2_font_helvB12_tf);
    OLED.drawStr(110, 56, "%");
  } 
  while (OLED.nextPage());

}

void DisplaySensorError()
{
  OLED.setFont(u8g2_font_crox4h_tr);
  OLED.firstPage();
  do 
  {
    OLED.drawRFrame(0, 0, 128, 64, 5);
    OLED.drawStr(18, 30, "SENSOR"); 
    OLED.drawStr(25, 50, "ERROR"); 
  } 
  while (OLED.nextPage());
}


// Update display from state machine
void HandleDisplay()
{
	switch (deviceState)
	{
    case DEVICE_STATE_INIT:
      DisplayInit();
      break;

		case DEVICE_STATE_CAL_WET_DELAY:
      DisplayCalWetDelay();
			break;
			
		case DEVICE_STATE_CAL_WET:
      DisplayCalWet();
			break;

		case DEVICE_STATE_CAL_DRY_DELAY:
      DisplayCalDryDelay();
			break;

		case DEVICE_STATE_CAL_DRY:
      DisplayCalDry();
			break;

		case DEVICE_STATE_DIAGNOSTICS:
      DisplayDiagnostics();
			break;
	
    case DEVICE_STATE_ERROR_SENSOR:
      DisplaySensorError();
      break;

		case DEVICE_STATE_SENSOR:
  	default:
      DisplaySensor();
			break;
			
	}
}

// ISR Sensor input
void ISR_SensorPulse() 
{ 
  sensorPulseCount++; 
} 

// Count sensor pulses
void HandleSensor()
{
  // Sensor sample
  noInterrupts();
  sensorPulseCount = 0; 
  interrupts(); 
  delay(1000); 
  noInterrupts(); 
  sensorPulseValue = sensorPulseCount;
  interrupts();

  // Sanity checks
  if (sensorPulseValue < 1000)  
  {
    sensorPercentage = 0;    
    deviceState = DEVICE_STATE_ERROR_SENSOR;
  } else if (sensorPulseValue < calWetValue && calWetValue != ~0){
    sensorPulseValue = calWetValue;
    sensorPercentage = calcSensorPercentage();
    deviceState = DEVICE_STATE_SENSOR;      
  } else if (sensorPulseValue > calDryValue && calDryValue != ~0 ){
    sensorPulseValue = calDryValue;
    sensorPercentage = calcSensorPercentage();    
    deviceState = DEVICE_STATE_SENSOR;      
  } else {
    sensorPercentage = calcSensorPercentage();
    deviceState = DEVICE_STATE_SENSOR;      
  }

  //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  /*
    sensorPercentage = 65;
    sensorPulseValue = 54678;
    deviceState = DEVICE_STATE_SENSOR; 
    */  
   //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  
  
}


// Check pushbuttons
void HandleButtons()
{  
	if (!digitalRead(PIN_BUTTON_CAL_WET) && digitalRead(PIN_BUTTON_CAL_DRY) && deviceState != DEVICE_STATE_ERROR_SENSOR){
    // CAL WET pressed
		if (!buttonCalWetActive){
			buttonCalWetTimeStart = millis();
			buttonCalWetActive = true;
		} else {
			if (millis() - buttonCalWetTimeStart > BUTTON_CAL_DELAY){
        // Store CAL WET value
        EEPROM.put(EEPROM_CAL_WET, sensorPulseValue);
        calWetValue = sensorPulseValue;
				deviceState = DEVICE_STATE_CAL_WET;		
        buttonCalWetActive = false;
        Dbg("CAL WET OK");       	
			} else {
				deviceState = DEVICE_STATE_CAL_WET_DELAY; 	
        Dbg("CAL WET DELAY");
			}
		}
	} else if (digitalRead(PIN_BUTTON_CAL_WET) && !digitalRead(PIN_BUTTON_CAL_DRY) && deviceState != DEVICE_STATE_ERROR_SENSOR){
    // CAL DRY pressed
    Dbg("CAL DRY PRESSED");
 		if (!buttonCalDryActive){
			buttonCalDryTimeStart = millis();
			buttonCalDryActive = true;
		} else {
			if (millis() - buttonCalDryTimeStart > BUTTON_CAL_DELAY){
        // Store CAL DRY value
        EEPROM.put(EEPROM_CAL_DRY, sensorPulseValue);
        calDryValue = sensorPulseValue;
				deviceState = DEVICE_STATE_CAL_DRY;			
        buttonCalDryActive = false;
			} else {
				deviceState = DEVICE_STATE_CAL_DRY_DELAY; 	
			}
		}
	} else if (!digitalRead(PIN_BUTTON_CAL_WET) && !digitalRead(PIN_BUTTON_CAL_DRY)){
    // CAL DRY and CAL WET pushed
    buttonCalDryActive = false;
    buttonCalWetActive = false;
		deviceState = DEVICE_STATE_DIAGNOSTICS;
	} else {
    buttonCalDryActive = false;
    buttonCalWetActive = false;
  }
 }


// Check battery voltage
void HandleBattery()
{
  // 5V ADC input= 1023
  // 7V battery / 43 * 10 = 1.62V  -> ADC value: 1023 / 5 * 1.62 = 331
  const int minimumBatteryVoltage = 330;
   // Check battery voltage -- 10K/33K ==> 1/4
	batteryValue = analogRead(PIN_BATTERY_VOLTAGE);
  // Show low battery alarm every 3 seonds  
  if (batteryValue < minimumBatteryVoltage){
    batteryLowFlag = true;  
  } else {
    batteryLowFlag = false;
  }
}

// Check power on time
void HandlePowerDown()
{
  // Reset timeout when a button is pressed
  if (!digitalRead(PIN_BUTTON_CAL_WET) || !digitalRead(PIN_BUTTON_CAL_DRY)){
    powerOnStartTime = millis();
  } else if (millis() - powerOnStartTime > POWER_ON_TIME){
    // Save the current value
    EEPROM.put(EEPROM_CURRENT, sensorPercentage);
    // Check low battery
    if (batteryLowFlag){
      DisplayBatteryLow();
      delay(1000);
    }
    // Power down
		while (1) {
			OLED.clearDisplay();
			digitalWrite(PIN_POWER_ON, LOW);
		}
	}
}


// Init
void setup() {
  // Init I/O pins
	pinMode(PIN_POWER_ON, OUTPUT);
	digitalWrite(PIN_POWER_ON, HIGH);
  pinMode(PIN_SENSOR_PULSE, INPUT_PULLUP); 
  pinMode(PIN_BUTTON_CAL_DRY, INPUT_PULLUP); 
  pinMode(PIN_BUTTON_CAL_WET, INPUT_PULLUP); 
  attachInterrupt(digitalPinToInterrupt(PIN_SENSOR_PULSE), ISR_SensorPulse, RISING); 
  
  // Sensor cal values
  EEPROM.get(EEPROM_CAL_WET, calWetValue);
  EEPROM.get(EEPROM_CAL_DRY, calDryValue);

  buttonCalDryActive = false;
  buttonCalWetActive = false;
  powerOnStartTime = millis();
  loopCounter = 0;
 
  // Serial monitor
  Serial.begin(9600);
  
  // Display 
  OLED.begin();
  deviceState = DEVICE_STATE_INIT;
  HandleDisplay(); 
 }

// Main loop
void loop() 
{
  
  // Read out sensor
	HandleSensor();

	// Check pushbuttons
	HandleButtons();
	
	// Check battery
	HandleBattery();
	
	// Check power down
	HandlePowerDown();

	// Update display
	HandleDisplay();

  // Update loop counter
  loopCounter++;
 
}

