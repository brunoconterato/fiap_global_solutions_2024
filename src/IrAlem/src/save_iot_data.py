import pandas as pd
import psycopg2
import argparse
import os

def save_iot_data_to_db(csv_filepath, db_host, db_port, db_name, db_user, db_password):
    """
    Loads IoT data from a CSV file and saves it to a PostgreSQL database.

    Args:
        csv_filepath: Path to the CSV file.
        db_host: PostgreSQL database host.
        db_port: PostgreSQL database port.
        db_name: PostgreSQL database name.
        db_user: PostgreSQL database user.
        db_password: PostgreSQL database password.
    """
    conn = None
    try:
        # Load data from CSV
        csv_filepath = os.path.abspath(csv_filepath)
        df = pd.read_csv(csv_filepath)

        # Convert timestamp column from milliseconds to datetime objects
        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')

        #Establish database connection
        conn = psycopg2.connect(host=db_host, database=db_name, user=db_user, password=db_password, port=db_port)
        cur = conn.cursor()

        # Insert data into database.  Using parameterized queries for security.
        for index, row in df.iterrows():
            cur.execute("""
                INSERT INTO CONSUMO_RESIDENCIAL (timestamp, consumo_potencia_kw, frequencia_atualizacao_s, dispositivo, status)
                VALUES (%s, %s, %s, %s, %s)
            """, (row['timestamp'], row['consumo_potencia_kw'], row['frequencia_atualizacao_s'], row['dispositivo'], row['status']))

        conn.commit()
        print(f"Dados do arquivo '{csv_filepath}' salvos com sucesso no banco de dados.")

    except FileNotFoundError:
        print(f"Erro: Arquivo CSV '{csv_filepath}' não encontrado.")
    except psycopg2.Error as e:
        print(f"Erro ao conectar ou gravar dados no banco de dados: {e}")
        conn.rollback()  # Rollback da transação em caso de erro
    except pd.errors.EmptyDataError:
        print(f"Erro: Arquivo CSV '{csv_filepath}' está vazio.")
    except pd.errors.ParserError:
        print(f"Erro: Erro ao analisar o arquivo CSV '{csv_filepath}'. Verifique o formato.")
    except Exception as e:
        print(f"Erro genérico: {e}")
    finally:
        if conn:
            cur.close()
            conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Save IoT data from CSV to PostgreSQL.")
    parser.add_argument("--csv_filepath", default="src/IrAlem/iot_data/data.csv", help="Path to the CSV file.")
    parser.add_argument("--host", default="localhost", help="PostgreSQL database host.")
    parser.add_argument("--port", type=int, default=5432, help="PostgreSQL database port.")
    parser.add_argument("--dbname", default="gs_energia_residencial", help="PostgreSQL database name.")
    parser.add_argument("--user", default="fiap_gs", help="PostgreSQL database user.")
    parser.add_argument("--password", default="fiap_gs", help="PostgreSQL database password.")
    args = parser.parse_args()
    save_iot_data_to_db(args.csv_filepath, args.host, args.port, args.dbname, args.user, args.password)