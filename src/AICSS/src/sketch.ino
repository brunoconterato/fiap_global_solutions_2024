// Pinos dos sensores e LED para o ambiente externo
const int LDR_EXTERNAL_PIN = 12;      // Pino para leitura do LDR (A0)
const int PIR_EXTERNAL_PIN = 34;      // Pino de entrada do sensor PIR (digital)
const int LED_EXTERNAL_PIN = 25;      // Pino de saída para controle do LED externo

// Limiar de luminosidade (lux) para definir dia ou noite
const int LUMINOSITY_EXTERNAL_THRESHOLD = 10;  // 10 lux correspondem à iluminação do crepúsculo

const double rl10_external = 50000.0; // LDR resistance at 10 lux para o ambiente externo
const double ldrGamma_external = 0.7;

const unsigned long MOTION_EXTERNAL_DURATION = 30000; // Duração da iluminação máxima (30 segundos)
long motionExternalStartTime = -MOTION_EXTERNAL_DURATION;   // Momento em que o movimento foi detectado no externo

void setup() {
  setupExternal();
}

void loop() {
  loopExternal();
}

// Função de inicialização para o ambiente externo
void setupExternal() {
  pinMode(PIR_EXTERNAL_PIN, INPUT);
  pinMode(LED_EXTERNAL_PIN, OUTPUT);

  // Inicialização da serial para monitoramento
  Serial.begin(115200);
}

// Função principal do loop para o ambiente externo
void loopExternal() {
  // Leitura da luminosidade e detecção de movimento no externo
  double luminosityExternal = readLuminosityExternal();
  bool motionDetectedExternal = readMotionExternal();

  // Log para monitoramento
  Serial.print("Luminosity (External): ");
  Serial.print(luminosityExternal);
  Serial.print(" | Night status (External): ");
  Serial.println(isNightExternal(luminosityExternal) ? "Night" : "Day");
  Serial.print("Motion detected (External): ");
  Serial.println(motionDetectedExternal ? "Yes" : "No");

  // Controle da iluminação externa
  controlLightingExternal(luminosityExternal, motionDetectedExternal);
  Serial.println();

  delay(1000); // Intervalo curto para leitura contínua
}

// Função para verificar se é noite com base na luminosidade do ambiente externo
bool isNightExternal(double luminosity) {
  return luminosity < LUMINOSITY_EXTERNAL_THRESHOLD;
}

// Função para calcular a resistência do LDR externo
double calculateResistance(int ldr_value) {
  double voltage_ratio = ldr_value / (4095.0 - ldr_value);
  return 10000.0 * voltage_ratio;
}

// Função para calcular a luminosidade em lux no ambiente externo
double calculateLux(double resistance) {
  return 10.0 * pow(rl10_external / resistance, 1.0 / ldrGamma_external);
}

// Função para ler a luminosidade do LDR no ambiente externo
double readLuminosityExternal() {
  int value = analogRead(LDR_EXTERNAL_PIN);
  double resistance = calculateResistance(value);
  return calculateLux(resistance);
}

// Função para verificar movimento no ambiente externo
bool readMotionExternal() {
  return digitalRead(PIR_EXTERNAL_PIN) == HIGH;
}

// Função para controlar o LED externo
void controlLightingExternal(double luminosity, bool motionDetected) {
  bool night = isNightExternal(luminosity);
  unsigned long currentTime = millis();

  if (night) {
    if (motionDetected) {
      // Movimento detectado: Acender o LED externo com intensidade máxima
      analogWrite(LED_EXTERNAL_PIN, 255); // Máxima intensidade
      motionExternalStartTime = currentTime; // Reinicia o temporizador
      Serial.println("External: Nighttime, motion detected. Lights at maximum brightness.");
    } else if (currentTime - motionExternalStartTime < MOTION_EXTERNAL_DURATION) {
      // Dentro do período de 30 segundos após o movimento
      analogWrite(LED_EXTERNAL_PIN, 255);
      Serial.println("External: Nighttime, recent motion detected. Keeping lights at maximum brightness.");
    } else {
      // Sem movimento: LED com intensidade mínima
      analogWrite(LED_EXTERNAL_PIN, 50);
      Serial.println("External: Nighttime, no motion. Lights at minimal brightness.");
    }
  } else {
    // Durante o dia, desliga o LED externo
    analogWrite(LED_EXTERNAL_PIN, 0);
    Serial.println("External: Daytime, lights are off.");
  }
}
