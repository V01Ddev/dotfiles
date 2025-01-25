#include <Servo.h>


/*
   Servo = D5;
*/


Servo servo; 

void setup(){
    servo.attach(5);
    servo.write(82.5);
}

void loop(){
    for (int pos = 0; pos <= 180; pos += 1) {
        servo.write(pos);
        delay(10);
    }

    for (int pos = 180; pos >= 0; pos -= 1) {
        servo.write(pos);
        delay(10);
    }
}
