#include <SoftwareSerial.h>
SoftwareSerial hc05(2,3);

String cmd="";
const int GSR=A0;
const int Max_GSR_value = 500;
const int Min_GSR_value = 0;

void setup(){
  Serial.begin(9600); //Initialize Serial Monitor
  hc05.begin(9600); //Initialize Bluetooth Serial Port
}

//send value by Bluetooth
void send_number(int value){
  hc05.print("\n");
  hc05.print(value);
}

//GSR signal source 
int get_current_gsr_value(){
  int sensorValue=0;
  int gsr_average=0;
  long sum=0;
  //Promedio de X medidas para eliminar la falla
  int num_medidas = 25;
  for(int i=0;i<num_medidas;i++){
      sensorValue = analogRead(GSR);
      sum += sensorValue;
      delay(40);
      }
   gsr_average = sum/num_medidas;
   return gsr_average;
}

int convert(int current_gsr_value){
  int r = Max_GSR_value - current_gsr_value;
  if(r<Min_GSR_value){ r=Min_GSR_value; }
  if(r>Max_GSR_value){ r=Max_GSR_value; }
  return r;
}

void loop(){
  //get data from blutooth
  while(hc05.available()>0){
    cmd+=(char)hc05.read();
  }
  //check comnad from flutter
  if(cmd!=""){
      Serial.println(cmd);
      cmd = "";
  }
  int gsr_value = get_current_gsr_value();
  Serial.println(gsr_value);
  send_number( convert(gsr_value) );
}
