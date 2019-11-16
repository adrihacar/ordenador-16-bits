#define data0 22
#define data1 24
#define data2 26
#define data3 28
#define data4 30
#define data5 32
#define data6 34
#define data7 36

#define valid 38
#define error 40

int data[8];
int decData;
String hexData;
bool changed;

void setup() {
  Serial.begin(115200);
  pinMode(data0, INPUT);
  pinMode(data1, INPUT);
  pinMode(data2, INPUT);
  pinMode(data3, INPUT);
  pinMode(data4, INPUT);
  pinMode(data5, INPUT);
  pinMode(data6, INPUT);
  pinMode(data7, INPUT);

  pinMode(valid, INPUT);
  pinMode(error, INPUT);
}

void loop() {
  changed = false;
 
  if(digitalRead(data0) != data[0]){
    data[0] = digitalRead(data0);
    changed = true;
  }
  if(digitalRead(data1) != data[1]){
    data[1] = digitalRead(data1);
    changed = true;
  }
  if(digitalRead(data2) != data[2]){
    data[2] = digitalRead(data2);
    changed = true;
  }
  if(digitalRead(data3) != data[3]){
    data[3] = digitalRead(data3);
    changed = true;
  }
  if(digitalRead(data4) != data[4]){
    data[4] = digitalRead(data4);
    changed = true;
  }
  if(digitalRead(data5) != data[5]){
    data[5] = digitalRead(data5);
    changed = true;
  }
  if(digitalRead(data6) != data[6]){
    data[6] = digitalRead(data6);
    changed = true;
  }
  if(digitalRead(data7) != data[7]){
    data[7] = digitalRead(data7);
    changed = true;
  }
  decData = data[7]*128+data[6]*64+data[5]*32+data[4]*16+data[3]*8+data[2]*4+data[1]*2+data[0]*1;
  hexData = String(decData, HEX);
  if(changed){
    Serial.print("Hex value:");
    Serial.print(hexData);
    Serial.print("    ");
    Serial.print(digitalRead(valid));
    Serial.print(" ");
    Serial.println(digitalRead(error));
    changed = false;
  }
}
