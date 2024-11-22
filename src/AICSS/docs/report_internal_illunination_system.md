## Relatório: Sistema de Iluminação Interna Inteligente

**Objetivo:** Desenvolver um sistema de iluminação interna que otimize o consumo de energia, acionando a luz apenas quando necessário: em ambientes com luminosidade insuficiente e com detecção de presença.

**Lógica de Funcionamento:**

O sistema utiliza um sensor de luminosidade (LDR) e um sensor de presença (simulado por um sensor genérico de presença no Wokwi, ou por um botão como simplificação) para controlar a intensidade da iluminação interna (simulada por um LED). A lógica de operação é a seguinte:

1. **Leitura da Luminosidade:** O ESP32 lê continuamente o valor fornecido pelo sensor LDR. Este valor representa a intensidade da luz ambiente.

2. **Determinação do Nível de Luminosidade:** O sistema compara o valor da luminosidade com um limiar pré-definido.  Se o valor estiver acima do limiar, considera-se luminosidade suficiente. Abaixo do limiar, considera-se luminosidade insuficiente.

3. **Detecção de Presença:** O ESP32 lê o estado do sensor de presença. Um sinal HIGH indica presença, enquanto um sinal LOW indica ausência.

4. **Controle da Iluminação:**

    * **Luminosidade Suficiente:** Independente do estado do sensor de presença, se a luminosidade for suficiente, a iluminação interna permanece desligada (LED OFF).

    * **Luminosidade Insuficiente e Presença Detectado:** Se a luminosidade for insuficiente E o sensor de presença detectar presença, a iluminação interna é acionada (LED ON).

    * **Luminosidade Insuficiente e Ausência de Presença:** Se a luminosidade for insuficiente, MAS o sensor de presença NÃO detectar presença, a iluminação interna permanece desligada (LED OFF).


**Sensores Utilizados:**

* **Sensor de Luminosidade (LDR):** Um resistor dependente da luz (LDR) que varia sua resistência de acordo com a intensidade da luz incidente. O ESP32 mede a resistência para determinar o nível de luminosidade.

* **Sensor de Presença (Simulado):** No Wokwi, um sensor digital genérico que simula a detecção de presença. Um sinal HIGH indica presença, enquanto um sinal LOW indica ausência. Alternativamente, pode-se utilizar um botão como um simulador muito simplificado.


**Componentes do Circuito (Wokwi):**

* 1 x ESP32
* 1 x LDR
* 1 x Sensor Digital (simulando sensor de presença) ou 1 x Botão (Simulação simplificada)
* 1 x LED (Simulando a luz interna)
* Resistores de pull-up/pull-down (conforme necessário para o sensor e o LED)


**Considerações Adicionais:**

* **Calibração do Limiar de Luminosidade:** O limiar para distinguir luminosidade suficiente e insuficiente precisa ser calibrado para o ambiente específico.
* **Tratamento de Ruído:** É importante implementar mecanismos para filtrar ruídos ou falsas leituras dos sensores, principalmente do sensor de presença.  Um período mínimo de tempo entre detecções ou uma contagem de múltiplas detecções podem ser considerados para evitar acionamentos falsos.
* **Tipo de Lâmpada:**  A escolha do tipo de lâmpada (e sua potência) afetará diretamente o consumo de energia. Lâmpadas LED são mais eficientes em termos de energia do que as lâmpadas incandescentes ou fluorescentes.


Este relatório descreve o funcionamento do sistema de iluminação interna. A implementação no Wokwi necessitará de um código adequado em linguagem C/C++ para o ESP32, que execute a lógica descrita acima. A simulação no Wokwi permitirá validar a funcionalidade do sistema antes de uma implementação física.
