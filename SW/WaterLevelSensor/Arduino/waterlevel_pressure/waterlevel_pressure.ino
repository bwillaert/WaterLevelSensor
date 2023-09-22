/*****************************************************************
* WATER LEVEL SENSOR
* Pressure sensor with current loop 4-20 mA
*
* (c)BW 2023
*****************************************************************/
#include <Arduino.h>
#include <U8g2lib.h>
#include <Wire.h>
#include <EEPROM.h>

// Debug print
#define DEBUG 

// OLED display 128x64 SH106 I2C Single Buffer
U8G2_SH1106_128X64_NONAME_1_HW_I2C OLED(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);

// EEPROM ADDRESSES
#define EEPROM_CURRENT  0

// Power-on timeout
#define POWER_ON_TIME 	5000

// Sensor minimum value: 220 Ohm * 4 mA = 880 mV
// 1023 / 5 * 0.880 = 180
#define SENSOR_MIN_VALUE 180

// Battery minimum value
 // 7V battery / 43 * 10 = 1.62V  -> ADC value: 1023 / 5 * 1.62 = 331
#define BATTERY_MIN_VALUE 330

// Average the max value + sensor value
#define AVERAGE_CNT 32

// Update interval for sensor value on display
#define SENSOR_UPDATE_MS 500

// Device state definitions
typedef enum _DEVICE_STATE{
	DEVICE_STATE_INIT = 0,
  DEVICE_STATE_SENSOR,
	DEVICE_STATE_DIAGNOSTICS,
  DEVICE_STATE_ERROR_SENSOR
	} DEVICE_STATE;
DEVICE_STATE deviceState;

// Global variables
volatile unsigned int sensorValue, sensorMaxValue, sensorMaxValueOld; 
byte sensorPercentage;
byte sensorAverage[AVERAGE_CNT];
byte sensorAverageIndex = 0;
byte loopCounter = 0;
bool batteryLowFlag = false;
unsigned int batteryValue;
unsigned long powerOnStartTime;
unsigned long oldDisplayTime;

// I/O pins
#define PIN_BUTTON_DIAGNOSTICS  5 
#define PIN_POWER_ON            2 
#define PIN_BATTERY_VOLTAGE		  A7
#define PIN_BATTERY_VOLTAGE		  A7
#define PIN_SENSOR_MAX		      A1
#define PIN_SENSOR              A0         

void Dbg(const char* debugString)
{
#ifdef DEBUG
  Serial.println(debugString);
#endif  
}

// ------------------------------------------

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
  delay(1000);
  oldDisplayTime = millis();  
}
 
void DisplayDiagnostics()
{
  // 7V battery / 43 * 10 = 1.62V  -> ADC value: 1023 / 5 * 1.62 = 331
  // Battery Voltage = 5 mV * Value * 4 
    byte batteryVoltage = (float)batteryValue * 0.005 * 4.0;
    OLED.setFont(u8g2_font_crox4h_tr);
    char row0[20];
    char row1[20];
    char row2[20];
    sprintf(row0, "batt: %uV", batteryVoltage);
    sprintf(row1,"sensor: %u", sensorValue);
    sprintf(row2, "max: %u", sensorMaxValue);
    OLED.firstPage();
    do 
    {
      OLED.drawRFrame(0, 0, 128, 64, 5);
      OLED.drawStr(10, 17, row0); 
      OLED.drawStr(10, 37, row1); 
      OLED.drawStr(10, 57, row2); 
    } 
    while (OLED.nextPage());
}

void DisplayBatteryLow()
{
    OLED.setFont(u8g2_font_crox4h_tr);
    OLED.firstPage();
    do 
    {
      OLED.drawRFrame(0, 0, 128, 64, 5);
      OLED.drawTriangle(54, 40, 74, 40, 64, 55); // xxxx
      OLED.drawStr(20, 30, "BATTERY"); 
    } 
    while (OLED.nextPage());
  
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

		case DEVICE_STATE_DIAGNOSTICS:
      DisplayDiagnostics();
			break;
	
    case DEVICE_STATE_ERROR_SENSOR:
      DisplaySensorError();
      break;

		case DEVICE_STATE_SENSOR:
  	default:
      // Update sensor value every 500 ms
      if ((millis() - oldDisplayTime) > SENSOR_UPDATE_MS) {
        DisplaySensor();
        oldDisplayTime = millis();
      }
			break;
			
	}
}

// Read sensor current
// Read sensor max input value potmeter
void HandleSensor()
{
  // Sensor sample and max value potmeter sample
  sensorValue = analogRead(PIN_SENSOR);
  sensorMaxValue = analogRead(PIN_SENSOR_MAX);
  // No timeout as long as the potmeter max value changes
  int sensorMaxDiff = sensorMaxValue - sensorMaxValueOld;
  if (abs(sensorMaxDiff) > 10)
  {
      sensorMaxValueOld = sensorMaxValue;
      powerOnStartTime = millis();
  }


  // Sanity checks on sensor connectivity
  if (sensorValue < SENSOR_MIN_VALUE/2)  
  {
    sensorPercentage = 0;    
    deviceState = DEVICE_STATE_ERROR_SENSOR;  
    return;
  } 
  // Sanity checks on sensor value
  if (sensorMaxValue < SENSOR_MIN_VALUE){
    sensorPercentage = 0;
    deviceState = DEVICE_STATE_SENSOR; 
  } else if (sensorValue < SENSOR_MIN_VALUE){
    sensorPercentage = 0;
    deviceState = DEVICE_STATE_SENSOR;      
  } else if (sensorValue >= sensorMaxValue){
    sensorPercentage = 100;    
    deviceState = DEVICE_STATE_SENSOR;      
  } else {
    // Calc percentage
    float step = ((float)sensorMaxValue - (float)SENSOR_MIN_VALUE) / 100.0;
    sensorAverage[sensorAverageIndex % AVERAGE_CNT] = ((float)sensorValue - (float)SENSOR_MIN_VALUE) / step;
    sensorAverageIndex++;
    unsigned int sensorSum = 0;
    for (int i = 0; i < AVERAGE_CNT; i++){
      sensorSum += sensorAverage[i];   
   }
    sensorPercentage = sensorSum >> 5;
    deviceState = DEVICE_STATE_SENSOR;        
  }
}
  
// Check pushbuttons
void HandleButtons()
{  
  if (!digitalRead(PIN_BUTTON_DIAGNOSTICS)) {
      deviceState = DEVICE_STATE_DIAGNOSTICS;
      powerOnStartTime = millis();
    }
}

// Check battery voltage
void HandleBattery()
{
  // 5V ADC input= 1023
  // 7V battery / 43 * 10 = 1.62V  -> ADC value: 1023 / 5 * 1.62 = 331
   // Check battery voltage -- 10K/33K ==> 1/4
	batteryValue = analogRead(PIN_BATTERY_VOLTAGE);
  // Show low battery alarm every 3 seonds  
  if (batteryValue < BATTERY_MIN_VALUE){
    batteryLowFlag = true;  
  } else {
    batteryLowFlag = false;
  }
}

// Check power on time
void HandlePowerDown()
{
  // Reset timeout when a button is pressed
  if (!digitalRead(PIN_BUTTON_DIAGNOSTICS)){
    powerOnStartTime = millis();
  } else if (millis() - powerOnStartTime > POWER_ON_TIME){
    // Save the current value
    EEPROM.put(EEPROM_CURRENT, sensorPercentage);
    // Check low battery
    if (batteryLowFlag){
      DisplayBatteryLow();
      delay(2000);
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
  pinMode(PIN_BATTERY_VOLTAGE, INPUT);
  pinMode(PIN_SENSOR_MAX, INPUT);
  pinMode(PIN_SENSOR, INPUT);     
  pinMode(PIN_BUTTON_DIAGNOSTICS, INPUT_PULLUP); 
  
  // Power ON time
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

