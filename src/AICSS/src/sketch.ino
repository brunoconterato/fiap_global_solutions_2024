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

// Parâmetros do LED externo
const int LED_EXTERNAL_MAX_BRIGHTNESS = 255; // Brilho máximo do LED externo
const int LED_EXTERNAL_MIN_BRIGHTNESS = 50;  // Brilho mínimo do LED externo

// Variável global para frequência de atualização (em segundos)
const int FREQUENCIA_ATUALIZACAO_S = 5;

// Variável global para armazenar logs CSV
String csvLog = "timestamp,consumo_potencia_kw,frequencia_atualizacao_s,dispositivo,status\n";
int loopCount = 0;

void setup() {
  setupExternal();
  setupInternal();
}

void loop() {
  Serial.println("-\n\n-------------------------------\n");
  Serial.println("Realizando nova leitura dos sensores. Leitura: " + String(loopCount + 1) + "\n");
  loopExternal();
  loopInternal();
  loopLog();
  delay(FREQUENCIA_ATUALIZACAO_S * 1000); // Intervalo curto para leitura contínua dos sensores
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
  int externalPwm = controlLightingExternal(luminosityExternal, motionDetectedExternal);

  if (externalPwm > 0) {
    // Calculo de potência consumida
    double power = computeLedPowerInKw(externalPwm);

    // Log para monitoramento
    logData(power, FREQUENCIA_ATUALIZACAO_S, "led_externo_1", externalPwm > 100 ? "ligado_maximo" : "ligado_minimo");
  }

  Serial.println();
}

int controlLightingExternal(double luminosity, bool motionDetected) {
  bool night = isNight(luminosity, LUMINOSITY_EXTERNAL_THRESHOLD);
  unsigned long currentTime = millis();
  int pwmValue = 0;

  if (night) {
    if (motionDetected) {
      pwmValue = LED_EXTERNAL_MAX_BRIGHTNESS;
      motionExternalStartTime = currentTime;
      Serial.println("External: Night, motion detected. Lights ON (high).");
    } else if (currentTime - motionExternalStartTime < MOTION_EXTERNAL_DURATION) {
      pwmValue = LED_EXTERNAL_MAX_BRIGHTNESS;
      Serial.println("External: Night, motion detected recently. Lights ON (high).");
    } else {
      pwmValue = LED_EXTERNAL_MIN_BRIGHTNESS;
      Serial.println("External: Night, no motion. Lights ON (low).");
    }
  } else {
    Serial.println("External: Day. Lights OFF.");
  }
  
  analogWrite(LED_EXTERNAL_PIN, pwmValue);
  return pwmValue;
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
  int internalPwm = controlLightingInternal(luminosityInternal, motionDetectedInternal);

  if (internalPwm > 0) {
    // Calculo de potência consumida
    double powerKW = computeLedPowerInKw(internalPwm);

    // Log para monitoramento
    logData(powerKW, FREQUENCIA_ATUALIZACAO_S, "led_interno_1", motionDetectedInternal ? "ligado" : "desligado");
  }

  Serial.println();
}

int controlLightingInternal(double luminosity, bool motionDetected) {
  bool insufficientLight = isNight(luminosity, LUMINOSITY_INTERNAL_THRESHOLD);
  int pwmValue = 0;

  if (insufficientLight && motionDetected) {
    pwmValue = LED_INTERNAL_BRIGHTNESS;
    Serial.println("Internal: Insufficient light, motion detected. Lights ON.");
  } else {
    pwmValue = 0;
    Serial.println("Internal: Sufficient light or no motion. Lights OFF.");
  }

  analogWrite(LED_INTERNAL_PIN, pwmValue);
  return pwmValue;
}

// ---------------------- Cálculo de Potência dos LEDs  ---------------------- //

// Cálculo de potência dos LEDs em watts
// Objetivo: simular o consumo de energia das lâmpadas LED
// Considerando que o LED externo consome 10W no máximo e 1W no mínimo
// Considerando que o LED interno consome 10W quando ligado

// Obs.: não considera o cálculo físico de consumo de energia dos LEDs
// Trata-se de um cálculo simplificado para fins de simulação de lâmpadas LED

const double LED_MAX_POWER = 10.0; // Potência máxima do LED em watts
const double LED_MIN_POWER = 1.0; // Potência mínima do LED em watts

double computeLedPowerInKw(int pwmValue) {
  double ledPower;
  if (pwmValue > 100) {
    ledPower = LED_MAX_POWER;
  } else if(pwmValue > 0) {
    ledPower = LED_MIN_POWER;
  } else {
    ledPower = 0.0;
  }

  return ledPower / 1000.0; // Convertendo para kilowatts
}

// ---------------------- Log CSV ---------------------- //

void loopLog() {
  loopCount++;
  if (loopCount % 10 == 0) {
    Serial.println("CSV Log Atual:");
    Serial.println(csvLog);
    csvLog = "timestamp,consumo_potencia_kw,frequencia_atualizacao_s,dispositivo,status\n";
  }
}

void logData(double powerKW, int frequency, String device, String status) {
  unsigned long timestamp = millis();
  csvLog += String(timestamp) + "," + String(powerKW, 4) + "," + String(frequency) + "," + device + "," + status + "\n";
}
