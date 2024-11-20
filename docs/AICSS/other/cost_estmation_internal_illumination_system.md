## Estimativa de Economia de Energia com o Sistema de Iluminação Interna Inteligente

Esta estimativa considera uma única lâmpada interna e um mês com 30 dias.  Novamente, precisaremos fazer algumas suposições razoáveis, pois dados precisos dependem de fatores específicos como o tipo de lâmpada, seu consumo de potência, a luminosidade ambiente e a frequência de ocupação do cômodo.

**Suposições:**

* **Lâmpada:** Lâmpada LED de 8W.
* **Iluminação Máxima (Sem Sistema):** A lâmpada permanece ligada durante 8 horas por dia (cenário base: ocupação média do cômodo).
* **Iluminação Máxima (Com Sistema):** A lâmpada opera a 8W apenas quando a luminosidade é insuficiente e há presença detectada.  Suponhamos que isto ocorra por 4 horas por dia, em média.
* **Consumo ESP32:** O consumo do ESP32 é desprezível em comparação com o consumo da lâmpada e será ignorado.
* **Custo da Energia:** R$ 0,74593/kWh.


**Cálculos:**

**1. Sem o Sistema Proposto:**

* **Consumo Diário:** 8W * 8h/dia = 64 Wh/dia
* **Consumo Mensal:** 64 Wh/dia * 30 dias = 1920 Wh = 1.92 kWh
* **Custo Mensal:** 1.92 kWh * R$ 0,74593/kWh = R$ 1.4317056


**2. Com o Sistema Proposto:**

* **Consumo Diário (Com Sistema):** 8W * 4h/dia = 32 Wh/dia
* **Consumo Mensal (Com Sistema):** 32 Wh/dia * 30 dias = 960 Wh = 0.96 kWh
* **Custo Mensal (Com Sistema):** 0.96 kWh * R$ 0,74593/kWh = R$ 0.7160928


**Economia:**

* **Economia Mensal:** R$ 1.4317056 - R$ 0.7160928 = R$ 0.7156128

**Conclusão:**

Considerando as suposições feitas, a economia estimada por lâmpada com o sistema de iluminação interna inteligente ao longo de um mês é de aproximadamente **R$ 0,72**.  Novamente, esta é uma estimativa e o valor real pode variar significativamente dependendo de fatores como a frequência de uso do cômodo, a luminosidade ambiente e a sensibilidade do sensor de presença. Um monitoramento do consumo real em um ambiente real forneceria dados mais precisos.  Observe que esta estimativa considera uma ocupação do ambiente de 8 horas diárias sem o sistema, e de 4 horas com o sistema. Esta diferença deve-se à lógica do sistema que mantém a lâmpada desligada mesmo durante o período de ocupação caso a luminosidade seja suficiente.  Assim, o resultado da estimativa dependerá de forma significativa das condições de iluminação ambiente.
