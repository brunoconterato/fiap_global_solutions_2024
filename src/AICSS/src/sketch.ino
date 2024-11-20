// Pinos dos sensores e LED para o ambiente externo
const int LDR_EXTERNAL_PIN = 12;      // Pino para leitura do LDR (A0)
const int PIR_EXTERNAL_PIN = 34;      // Pino de entrada do sensor PIR (digital)
const int LED_EXTERNAL_PIN = 25;      // Pino de saída para controle do LED externo

// Pinos dos sensores e LED para o ambiente interno
const int LDR_INTERNAL_PIN = 35;      // Pino para leitura do LDR interno (A1)
const int PIR_INTERNAL_PIN = 18;      // Pino de entrada do sensor de presença interno (digital)
const int LED_INTERNAL_PIN = 19;      // Pino de saída para controle do LED interno

// Limiar de luminosidade (lux) para definir dia ou noite
const int LUMINOSITY_EXTERNAL_THRESHOLD = 10;  // Limiar para iluminação externa
const int LUMINOSITY_INTERNAL_THRESHOLD = 50;  // Limiar para iluminação interna

// LDR resistance at 10 lux e valor do Gamma (usados para ambos os ambientes)
const double rl10 = 50000.0; // LDR resistance at 10 lux
const double ldrGamma = 0.7;  // Gamma para o LDR

const unsigned long MOTION_EXTERNAL_DURATION = 30000; // Duração da iluminação máxima (30 segundos)
long motionExternalStartTime = -MOTION_EXTERNAL_DURATION;   // Momento em que o movimento foi detectado no externo

// Parâmetros do LED interno
const int LED_INTERNAL_BRIGHTNESS = 255; // Brilho máximo do LED interno

void setup() {
  setupExternal();
  setupInternal();
}

void loop() {
  loopExternal();
  loopInternal();
}

// ---------------------- Comum aos ambientes interno e externo ---------------------- //

bool isNight(double luminosity, int threshold) {
  return luminosity < threshold;
}

double calculateResistance(int ldr_value) {
  double voltage_ratio = ldr_value / (4095.0 - ldr_value);
  return 10000.0 * voltage_ratio;
}

double calculateLux(double resistance, double rl10, double gamma) {
  return 10.0 * pow(rl10 / resistance, 1.0 / gamma);
}

double readLuminosity(int ldr_pin, double rl10, double gamma) {
  int value = analogRead(ldr_pin);
  double resistance = calculateResistance(value);
  return calculateLux(resistance, rl10, gamma);
}

bool readMotion(int pir_pin) {
  return digitalRead(pir_pin) == HIGH;
}

// ---------------------- Ambiente Externo ---------------------- //
void setupExternal() {
  pinMode(PIR_EXTERNAL_PIN, INPUT);
  pinMode(LED_EXTERNAL_PIN, OUTPUT);

  // Inicialização da serial para monitoramento
  Serial.begin(115200);
}

void loopExternal() {
  // Leitura da luminosidade e detecção de movimento no externo
  double luminosityExternal = readLuminosity(LDR_EXTERNAL_PIN, rl10, ldrGamma);
  bool motionDetectedExternal = readMotion(PIR_EXTERNAL_PIN);

  // Log para monitoramento
  Serial.print("Luminosity (External): ");
  Serial.print(luminosityExternal);
  Serial.print(" | Night status (External): ");
  Serial.println(isNight(luminosityExternal, LUMINOSITY_EXTERNAL_THRESHOLD) ? "Night" : "Day");
  Serial.print("Motion detected (External): ");
  Serial.println(motionDetectedExternal ? "Yes" : "No");

  // Controle da iluminação externa
  controlLightingExternal(luminosityExternal, motionDetectedExternal);
  Serial.println();

  delay(1000); // Intervalo curto para leitura contínua
}

// Função de controle de iluminação específica para o ambiente externo
void controlLightingExternal(double luminosity, bool motionDetected) {
  bool night = isNight(luminosity, LUMINOSITY_EXTERNAL_THRESHOLD);
  unsigned long currentTime = millis();

  if (night) {
    if (motionDetected) {
      analogWrite(LED_EXTERNAL_PIN, 255);
      motionExternalStartTime = currentTime;
    } else if (currentTime - motionExternalStartTime < MOTION_EXTERNAL_DURATION) {
      analogWrite(LED_EXTERNAL_PIN, 255);
    } else {
      analogWrite(LED_EXTERNAL_PIN, 50);
    }
  } else {
    analogWrite(LED_EXTERNAL_PIN, 0);
  }
}

// ---------------------- Ambiente Interno ---------------------- //
void setupInternal() {
  pinMode(PIR_INTERNAL_PIN, INPUT);
  pinMode(LED_INTERNAL_PIN, OUTPUT);
}

void loopInternal() {
  // Leitura da luminosidade e detecção de movimento no interno
  double luminosityInternal = readLuminosity(LDR_INTERNAL_PIN, rl10, ldrGamma);
  bool motionDetectedInternal = readMotion(PIR_INTERNAL_PIN);

  // Log para monitoramento
  Serial.print("Luminosity (Internal): ");
  Serial.print(luminosityInternal);
  Serial.print(" | Insufficient light: ");
  Serial.println(isNight(luminosityInternal, LUMINOSITY_INTERNAL_THRESHOLD) ? "Yes" : "No");
  Serial.print("Motion detected (Internal): ");
  Serial.println(motionDetectedInternal ? "Yes" : "No");

  // Controle da iluminação interna
  controlLightingInternal(luminosityInternal, motionDetectedInternal);
  Serial.println();

  delay(5000); // Intervalo curto para leitura contínua
}

void controlLightingInternal(double luminosity, bool motionDetected) {
  bool insufficientLight = isNight(luminosity, LUMINOSITY_INTERNAL_THRESHOLD);

  if (insufficientLight && motionDetected) {
    analogWrite(LED_INTERNAL_PIN, LED_INTERNAL_BRIGHTNESS);
    Serial.println("Internal: Insufficient light, motion detected. Lights ON.");
  } else {
    analogWrite(LED_INTERNAL_PIN, 0);
    Serial.println("Internal: Sufficient light or no motion. Lights OFF.");
  }
}
