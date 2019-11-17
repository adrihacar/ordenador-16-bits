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
bool recived;
char newChar;
bool isNewChar;

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
char decodeHex(String hexCharacter){
  if(hexCharacter == "15") return 'q';
  if(hexCharacter == "1d") return 'w';
  if(hexCharacter == "24") return 'e';
  if(hexCharacter == "2d") return 'r';
  if(hexCharacter == "2c") return 't';
  if(hexCharacter == "35") return 'y';
  if(hexCharacter == "3c") return 'u';
  if(hexCharacter == "43") return 'i';
  if(hexCharacter == "44") return 'o';
  if(hexCharacter == "4d") return 'p';
  if(hexCharacter == "1c") return 'a';
  if(hexCharacter == "1b") return 's';
  if(hexCharacter == "23") return 'd';
  if(hexCharacter == "2b") return 'f';
  if(hexCharacter == "34") return 'g';
  if(hexCharacter == "33") return 'h';
  if(hexCharacter == "3b") return 'j';
  if(hexCharacter == "42") return 'k';
  if(hexCharacter == "4b") return 'l';
  if(hexCharacter == "4c") return 'ñ';
  if(hexCharacter == "1a") return 'z';
  if(hexCharacter == "22") return 'x';
  if(hexCharacter == "21") return 'c';
  if(hexCharacter == "2a") return 'v';
  if(hexCharacter == "32") return 'b';
  if(hexCharacter == "31") return 'n';
  if(hexCharacter == "3a") return 'm';
  if(hexCharacter == "29") return ' ';
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

  if(changed){
    decData = data[7]*128+data[6]*64+data[5]*32+data[4]*16+data[3]*8+data[2]*4+data[1]*2+data[0]*1;
    hexData = String(decData, HEX);
    if(recived){
      newChar = decodeHex(hexData);
      recived = false;
      isNewChar = true;
    }
    if(hexData == "f0"){
      recived = true;
    }
  }
  if(isNewChar){
    Serial.print(newChar);
    changed = false;
    isNewChar = false;
  }
  delay(1);
}
