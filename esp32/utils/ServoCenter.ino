#include <SPI.h>
#include <Servo.h>


/*
   Servo = D5
*/


int mid = 82.5;


Servo servo; 

void setup(){
    servo.attach(5);
    servo.write(mid);
}

void loop(){
}
