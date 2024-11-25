import tkinter as tk
from tkinter import ttk
import random
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import pandas as pd
import psycopg2

class EnergyMonitorSystem:
    def __init__(self, root, db_host, db_port, db_name, db_user, db_password):
        self.initialize_db(db_host, db_port, db_name, db_user, db_password)
        
        self.root = root
        self.root.title("Sistema de Monitoramento de Energia")
        self.root.geometry("1200x800")
        
        # Dados simulados
        self.devices = {
            "Ar Condicionado": {"power": 1400, "status": "ON"},
            "Geladeira": {"power": 350, "status": "ON"},
            "Chuveiro": {"power": 5500, "status": "ON"},
            "TV": {"power": 100, "status": "ON"},
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
            
        self.save_consumption_data() #Salva os dados no banco de dados.

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
        
    def initialize_db(self, db_host, db_port, db_name, db_user, db_password):
        self.db_host = db_host
        self.db_port = db_port
        self.db_name = db_name
        self.db_user = db_user
        self.db_password = db_password
        self.conn = None
        self.cur = None
        self.connect_to_db()
        
    def connect_to_db(self):
        try:
            self.conn = psycopg2.connect(host=self.db_host, database=self.db_name, user=self.db_user, password=self.db_password, port=self.db_port)
            self.cur = self.conn.cursor()
            print("Conectado ao banco de dados PostgreSQL")
        except psycopg2.Error as e:
            print(f"Erro ao conectar ao banco de dados: {e}")
            
    def close_db_connection(self):
        if self.conn:
            self.cur.close()
            self.conn.close()
            print("Conexão com o banco de dados fechada")
    
    def save_consumption_data(self):
        try:
            self.cur.execute("BEGIN;")  # inicia uma transação
            for device, info in self.devices.items():
                if info['status'] == 'ON':
                    consumo_kw = info['power'] / 1000.0  # convertendo para kW
                    try:
                        self.cur.execute("""
                            INSERT INTO CONSUMO_RESIDENCIAL (timestamp, consumo_potencia_kw, frequencia_atualizacao_s, dispositivo, status)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (datetime.now(), consumo_kw, 10, device, info['status']))
                    except psycopg2.IntegrityError as e:  # captura erro de chave única
                        if 'unique constraint' in str(e).lower():
                            print(f"Aviso: Tentativa de inserção duplicada ignorada para {device}.")
                        else:
                            raise e  # relança outras exceções

            self.conn.commit()  # commit da transação inteira, caso tudo tenha dado certo
            print("Dados de consumo salvos no banco de dados.")

        except psycopg2.Error as e:
            print(f"Erro ao salvar dados no banco de dados: {e}")
            self.conn.rollback()  # Rollback caso ocorra algum erro, mantendo a consistência
        except Exception as e:
            self.conn.rollback()
            print(f"Erro genérico: {e}")

if __name__ == "__main__":
    root = tk.Tk()
    
    #Credenciais do seu banco de dados
    db_host = "localhost" #ou seu IP
    db_port = "5432"
    db_name = "gs_energia_residencial"
    db_user = "fiap_gs"
    db_password = "fiap_gs"
    
    app = EnergyMonitorSystem(root, db_host, db_port, db_name, db_user, db_password)
    root.mainloop()