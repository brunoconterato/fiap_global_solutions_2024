# Sistema de Monitoramento de Energia Residencial

## Introdução

Este projeto foi desenvolvido como parte da atividade **Global Solutions (GS) 2024.2**, cujo tema é **Energia**. A solução utiliza **Data Science**, **IoT**, **Python** e **Banco de Dados** para otimizar o consumo de energia em ambientes residenciais, com foco na eficiência energética, sustentabilidade e redução de custos.

A aplicação apresentada oferece uma interface gráfica para monitoramento e gerenciamento do consumo energético, integrando dispositivos residenciais e simulando dados em tempo real. A ideia é proporcionar uma base funcional que pode ser expandida para incluir recursos avançados, como integração com fontes renováveis (solar, eólica) e análise preditiva.

---

## Objetivos

- **Monitorar o consumo energético em tempo real:** Simular dispositivos e seu impacto no consumo total.
- **Promover eficiência energética:** Apresentar dados que ajudam o usuário a identificar padrões e reduzir custos.
- **Fornecer uma base escalável:** Preparar o sistema para integração com banco de dados e fontes renováveis.
- **Estimar custos de energia:** Calcular o custo com base no consumo diário e na tarifa energética.

---

## Funcionalidades do Sistema

### 1. Interface Gráfica
- Desenvolvida com **Tkinter**, apresentando um painel principal dividido em:
  - **Dispositivos:** Lista de dispositivos com status, potência e consumo.
  - **Gráficos:** Exibição do consumo energético em tempo real.
  - **Estatísticas:** Dados de consumo atual, diário e custo estimado.

### 2. Monitoramento em Tempo Real
- Atualizações automáticas a cada 10 segundos.
- Consumo de dispositivos simulados com variações aleatórias para refletir condições reais.

### 3. Gráficos Interativos
- Exibição do histórico de consumo com timestamps.
- Representação visual clara e intuitiva para análise do usuário.

### 4. Estatísticas de Consumo e Custo
- Consumo atual em watts (W).
- Consumo diário estimado em kilowatt-hora (kWh).
- Cálculo do custo com base na tarifa simulada (R$ 0,75/kWh).

---

## Detalhamento Técnico

### Tecnologias Utilizadas
- **Python 3.9+**
- **Tkinter:** Criação da interface gráfica.
- **Matplotlib:** Gráficos interativos de consumo.
- **Pandas:** Manipulação e análise de dados (possível expansão futura).
- **Random:** Simulação de dados para dispositivos.

### Estrutura do Código
1. **Classe Principal (`EnergyMonitorSystem`):**
   - Gerencia dispositivos, consumo e atualização dos dados.
   - Responsável pela interface gráfica e integração dos componentes.
2. **Simulação de Consumo:**
   - Estima o consumo de dispositivos com base no status atual (ligado/desligado) e uma variação aleatória.
3. **Atualização Automática:**
   - Usa `root.after()` para atualizar os dados e gráficos em intervalos regulares.

---

## Utilidade Prática

- **Residências:** Monitoramento detalhado do consumo energético e identificação de dispositivos com alto consumo.
- **Educação:** Demonstração de conceitos de IoT e otimização energética para estudantes e profissionais.
- **Base para Projetos Avançados:** Escalável para integração com fontes renováveis, banco de dados e dispositivos reais.

---

## Possibilidades de Expansão

### 1. Integração com Banco de Dados
- Armazenar histórico de consumo para análises futuras.
- Salvar configurações personalizadas de dispositivos.

### 2. Fontes de Energia Renovável
- Monitorar geração solar e eólica.
- Selecionar automaticamente a fonte mais econômica e sustentável.

### 3. Análise Preditiva
- Usar algoritmos de machine learning para prever padrões de consumo.
- Detectar anomalias e sugerir ações corretivas.

### 4. Relatórios e Notificações
- Gerar relatórios em PDF com estatísticas detalhadas.
- Enviar notificações em tempo real (e-mail ou push).

### 5. Controle Automático
- Ativar/desativar dispositivos automaticamente com base em regras predefinidas (ex.: horários de pico).

---

## Como Usar

1. **Pré-requisitos:**
   - Python 3.9+ instalado.
   - Bibliotecas necessárias: `tkinter`, `matplotlib`, `pandas`.

2. **Execução:**
   - Clone este repositório:
     ```bash
     git clone https://github.com/brunoconterato/fiap_global_solutions_2024
     cd fiap_global_solutions_2024/src/CTWP
     ```
   - Execute o script principal:
     ```bash
     python src/main.py
     ```

3. **Interface:**
   - Visualize os dispositivos e seu status.
   - Acompanhe o consumo em tempo real no gráfico.
   - Consulte as estatísticas de consumo e custo estimado.

---

## Conclusão

Este projeto é um ponto de partida para o desenvolvimento de sistemas inteligentes de monitoramento energético. Ele combina conceitos de programação, ciência de dados e IoT, com foco na sustentabilidade e eficiência energética. A solução pode ser personalizada e expandida conforme as necessidades específicas de diferentes cenários residenciais, comerciais ou urbanos.

## Apêndices

### A. Imagem da Interface Gráfica

![Interface Gráfica](./assets/interface.png)

### B. Código-fonte

```python
import tkinter as tk
from tkinter import ttk
import random
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import pandas as pd

class EnergyMonitorSystem:
    def __init__(self, root):
        self.root = root
        self.root.title("Sistema de Monitoramento de Energia")
        self.root.geometry("1200x800")
        
        # Dados simulados
        self.devices = {
            "Ar Condicionado": {"power": 1400, "status": "OFF"},
            "Geladeira": {"power": 350, "status": "ON"},
            "Chuveiro": {"power": 5500, "status": "OFF"},
            "TV": {"power": 100, "status": "OFF"},
            "Iluminação": {"power": 200, "status": "ON"}
        }
        
        self.current_consumption = 0
        self.consumption_history = []
        self.timestamps = []
        
        self.setup_gui()
        self.update_data()

    def setup_gui(self):
        # Frame principal
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Título
        title = ttk.Label(main_frame, text="Monitoramento de Energia Residencial", 
                         font=('Helvetica', 16, 'bold'))
        title.grid(row=0, column=0, columnspan=2, pady=10)

        # Frame esquerdo - Dispositivos
        devices_frame = ttk.LabelFrame(main_frame, text="Dispositivos", padding="10")
        devices_frame.grid(row=1, column=0, padx=5, pady=5, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Lista de dispositivos
        for i, (device, info) in enumerate(self.devices.items()):
            ttk.Label(devices_frame, text=f"{device}:").grid(row=i, column=0, padx=5, pady=2)
            ttk.Label(devices_frame, text=f"{info['power']}W").grid(row=i, column=1, padx=5, pady=2)
            status_var = tk.StringVar(value=info['status'])
            ttk.Label(devices_frame, textvariable=status_var).grid(row=i, column=2, padx=5, pady=2)

        # Frame direito - Gráficos
        graph_frame = ttk.LabelFrame(main_frame, text="Consumo em Tempo Real", padding="10")
        graph_frame.grid(row=1, column=1, padx=5, pady=5, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Criar figura do matplotlib
        self.fig, self.ax = plt.subplots(figsize=(8, 4))
        self.canvas = FigureCanvasTkAgg(self.fig, master=graph_frame)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

        # Frame inferior - Estatísticas
        stats_frame = ttk.LabelFrame(main_frame, text="Estatísticas", padding="10")
        stats_frame.grid(row=2, column=0, columnspan=2, padx=5, pady=5, sticky=(tk.W, tk.E))

        # Labels para estatísticas
        self.current_power_var = tk.StringVar(value="Consumo Atual: 0W")
        self.daily_consumption_var = tk.StringVar(value="Consumo Diário: 0 kWh")
        self.cost_var = tk.StringVar(value="Custo Estimado: R$ 0,00")

        ttk.Label(stats_frame, textvariable=self.current_power_var).grid(row=0, column=0, padx=5)
        ttk.Label(stats_frame, textvariable=self.daily_consumption_var).grid(row=0, column=1, padx=5)
        ttk.Label(stats_frame, textvariable=self.cost_var).grid(row=0, column=2, padx=5)

    def simulate_consumption(self):
        """Simula o consumo de energia dos dispositivos"""
        total = 0
        for device, info in self.devices.items():
            if info['status'] == 'ON':
                # Adiciona alguma variação aleatória
                variation = random.uniform(0.8, 1.2)
                total += info['power'] * variation
        return total

    def update_data(self):
        """Atualiza os dados e gráficos"""
        # Simular novo consumo
        self.current_consumption = self.simulate_consumption()
        self.consumption_history.append(self.current_consumption)
        self.timestamps.append(datetime.now())

        # Manter apenas os últimos 60 pontos (10 minutos)
        if len(self.consumption_history) > 60:
            self.consumption_history.pop(0)
            self.timestamps.pop(0)

        # Atualizar gráfico
        self.ax.clear()
        self.ax.plot(self.timestamps, self.consumption_history, 'b-')
        self.ax.set_xlabel('Tempo')
        self.ax.set_ylabel('Consumo (W)')
        self.ax.tick_params(axis='x', rotation=45)
        self.fig.tight_layout()
        self.canvas.draw()

        # Atualizar estatísticas
        self.current_power_var.set(f"Consumo Atual: {self.current_consumption:.1f}W")
        daily_kwh = sum(self.consumption_history) * 10 / (3600 * 1000)  # convertendo para kWh
        self.daily_consumption_var.set(f"Consumo Diário: {daily_kwh:.2f} kWh")
        cost = daily_kwh * 0.75  # Considerando tarifa de R$ 0,75 por kWh
        self.cost_var.set(f"Custo Estimado: R$ {cost:.2f}")

        # Simular mudança aleatória no status dos dispositivos
        for device in self.devices:
            if random.random() < 0.1:  # 10% de chance de mudar o status
                self.devices[device]['status'] = 'ON' if random.random() < 0.5 else 'OFF'

        # Agendar próxima atualização
        self.root.after(10000, self.update_data)  # Atualiza a cada 10 segundos

if __name__ == "__main__":
    root = tk.Tk()
    app = EnergyMonitorSystem(root)
    root.mainloop()
```