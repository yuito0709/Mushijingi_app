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
    
    # insect_cards テーブルからカードデータを取得
    cursor.execute("SELECT name, 'Insect' as type FROM insect_cards")
    insect_cards = cursor.fetchall()
    
    # spell_enhancement_cards テーブルからカードデータを取得
    cursor.execute("SELECT name, 'Spell/Enhancement' as type FROM spell_enhancement_cards")
    spell_enhancement_cards = cursor.fetchall()
    
    # 両方のリストを結合
    all_cards = insect_cards + spell_enhancement_cards
    
    # データベース接続を閉じる
    conn.close()
    
    # JSON形式で返す
    return jsonify([{"name": card[0], "type": card[1]} for card in all_cards])

if __name__ == '__main__':
    app.run(debug=True)

