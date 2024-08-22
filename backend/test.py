import sqlite3

def list_tables(db_path):
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        conn.close()
        return tables
    except sqlite3.Error as e:
        print(f"エラー: {e}")
        return []

if __name__ == "__main__":
    db_path = "cards.db"  # データベースファイルのパス
    tables = list_tables(db_path)
    print("テーブル一覧:")
    for table in tables:
        print(table[0])