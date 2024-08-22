from flask import Flask, jsonify
import sqlite3

app = Flask(__name__)

def connect_db():
    conn = sqlite3.connect("cards.db")
    return conn

@app.route('/cards', methods=['GET'])
def get_cards():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT name, type FROM card_info")  # 適切なテーブル名を指定してください
    cards = cursor.fetchall()
    conn.close()
    return jsonify([{"name": card[0], "type": card[1]} for card in cards])

if __name__ == '__main__':
    app.run(debug=True)
