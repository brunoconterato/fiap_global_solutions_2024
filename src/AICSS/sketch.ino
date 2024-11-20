// Pinos dos sensores e LED
const int LDR_PIN = 12;      // Pino para leitura do LDR (A0)
const int PIR_PIN = 34;      // Pino de entrada do sensor PIR (digital)
const int LED_PIN = 25;      // Pino de saída para controle do LED

// Limiar de luminosidade (lux) para definir dia ou noite
const int LUMINOSITY_THRESHOLD = 10;  // 10 lux correspondem à iluminação do crepúsculo

const double rl10 = 50000.0; // LDR resistance at 10 lux
const double ldrGamma = 0.7;

const unsigned long MOTION_DURATION = 30000; // Duração da iluminação máxima (30 segundos)
long motionStartTime = -MOTION_DURATION;   // Momento em que o movimento foi detectado

void setup() {
  pinMode(PIR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);

  // Inicialização da serial para monitoramento
  Serial.begin(115200);
}

void loop() {
  // Leitura da luminosidade e detecção de movimento
  double luminosity = readLuminosity();
  bool motionDetected = readMotion();

  // Log para monitoramento
  Serial.print("Luminosity: ");
  Serial.print(luminosity);
  Serial.print(" | IsNight: ");
  Serial.println(isNight(luminosity));
  Serial.print("Motion Detected: ");
  Serial.println(motionDetected);

  // Controle da iluminação
  controlLighting(luminosity, motionDetected);
  Serial.println();

  delay(1000); // Intervalo curto para leitura contínua
}

// Função para verificar se é noite com base na luminosidade
bool isNight(double luminosity) {
  return luminosity < LUMINOSITY_THRESHOLD;
}

// Função para calcular a resistência do LDR
double calculate_resistance(int ldr_value) {
  double voltage_ratio = ldr_value / (4095.0 - ldr_value);
  return 10000.0 * voltage_ratio;
}

// Função para calcular a luminosidade em lux
double calculate_lux(double resistance) {
  return 10.0 * pow(rl10 / resistance, 1.0 / ldrGamma);
}

// Função para ler a luminosidade do LDR
double readLuminosity() {
  int value = analogRead(LDR_PIN);
  double resistance = calculate_resistance(value);
  return calculate_lux(resistance);
}

// Função para verificar movimento
bool readMotion() {
  return digitalRead(PIR_PIN) == HIGH;
}

// Função para controlar o LED
void controlLighting(double luminosity, bool motionDetected) {
  bool night = isNight(luminosity);
  unsigned long currentTime = millis();

  if (night) {
    if (motionDetected) {
      // Movimento detectado: Acender o LED com intensidade máxima
      analogWrite(LED_PIN, 255); // Máxima intensidade
      motionStartTime = currentTime; // Reinicia o temporizador
      Serial.println("Está de noite e há movimento detectado. Acionando luzes no máximo.");
    } else if (currentTime - motionStartTime < MOTION_DURATION) {
      // Dentro do período de 30 segundos após o movimento
      analogWrite(LED_PIN, 255);
      Serial.println("Está de noite e houve movimento nos últimos 30s. Mantendo luzes no máximo.");
    } else {
      // Sem movimento: LED com intensidade mínima
      analogWrite(LED_PIN, 50);
      Serial.println("Está de noite e não há movimento. Luzes em intensidade mínima.");
    }
  } else {
    // Durante o dia, desliga o LED
    analogWrite(LED_PIN, 0);
    Serial.println("Está de dia, luzes desligadas.");
  }
}
