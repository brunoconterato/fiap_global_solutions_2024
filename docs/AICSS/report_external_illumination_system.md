## Relatório: Sistema de Iluminação Externa Inteligente

**Objetivo:** Desenvolver um sistema de iluminação externa que otimize o consumo de energia, garantindo a segurança através de iluminação mínima à noite e acionando iluminação máxima apenas quando necessário, baseado na detecção de movimento.

**Lógica de Funcionamento:**

O sistema utiliza um sensor de luminosidade (LDR) e um sensor de movimento (simulado por um sensor genérico de presença no Wokwi, considerando as limitações do simulador) para controlar a intensidade da iluminação externa (simulada por um LED). A lógica de operação é a seguinte:
    
1. **Leitura da Luminosidade:** O ESP32 lê continuamente o valor fornecido pelo sensor LDR. Este valor representa a intensidade da luz ambiente.

2. **Determinação do Período (Dia/Noite):** O sistema compara o valor da luminosidade com um limiar pré-definido.  Se o valor estiver acima do limiar, considera-se dia. Abaixo do limiar, considera-se noite.

3. **Controle da Iluminação (Dia):** Durante o dia, independente da detecção de movimento, a iluminação externa permanece desligada (LED OFF).

4. **Controle da Iluminação (Noite - Sem Movimento):** Durante a noite, na ausência de detecção de movimento pelo sensor, a iluminação externa permanece em nível mínimo (LED com brilho reduzido, ou simulação através de PWM com baixo ciclo de trabalho).

5. **Controle da Iluminação (Noite - Com Movimento):**  Durante a noite, se o sensor de movimento detectar movimento, a iluminação externa é acionada em nível máximo (LED ON com brilho máximo, ou PWM com alto ciclo de trabalho) por um período de 30 segundos. Após os 30 segundos, o sistema retorna ao nível mínimo de iluminação noturna (item 4), a menos que um novo movimento seja detectado antes do término desse período.  Um temporizador é utilizado para controlar este período de 30 segundos.

**Sensores Utilizados:**

* **Sensor de Luminosidade (LDR):**  Um resistor dependente da luz (LDR) que varia sua resistência de acordo com a intensidade da luz incidente.  O ESP32 mede a resistência para determinar o nível de luminosidade.

* **Sensor de Movimento (Simulado):** No Wokwi, um sensor digital genérico que simula a detecção de movimento.  Um sinal HIGH indica presença de movimento, enquanto um sinal LOW indica ausência.  Alternativamente, pode-se utilizar um botão como um simulador muito simplificado.


**Componentes do Circuito (Wokwi):**

* 1 x ESP32
* 1 x LDR
* 1 x Sensor Digital (simulando sensor de movimento) ou 1 x Botão (Simulação simplificada)
* 1 x LED (Simulando a luz externa)
* Resistores de pull-up/pull-down (conforme necessário para o sensor e o LED)


**Considerações Adicionais:**

* **Calibração do Limiar de Luminosidade:** O limiar para distinguir dia e noite precisa ser calibrado para o ambiente específico.
* **Ajustes de Brilho do LED:**  A intensidade mínima e máxima do LED pode ser ajustada através de PWM (Pulse Width Modulation) para controlar o brilho.  No Wokwi, pode-se simular com diferentes níveis de luminosidade do LED.
* **Tratamento de Ruído:**  É importante implementar mecanismos para filtrar ruídos ou falsas leituras dos sensores.  No caso do sensor de movimento, um período mínimo de tempo entre detecções pode ser definido para evitar acionamentos repetidos por pequenas vibrações.

Este relatório descreve o funcionamento do sistema de iluminação externa. A implementação no Wokwi necessitará de um código adequado em linguagem C/C++ para o ESP32, que execute a lógica descrita acima.  A simulação no Wokwi permitirá validar a funcionalidade do sistema antes de uma implementação física.
