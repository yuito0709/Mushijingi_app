from flask import Flask, jsonify, request
import sqlite3

app = Flask(__name__)

def connect_db():
    conn = sqlite3.connect("cards.db")
    cursor = conn.cursor()

    # 必要なテーブルが存在しない場合に作成する
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS deck_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER,
        card_name TEXT,
        FOREIGN KEY (deck_id) REFERENCES decks(id)
    )
    """)

    conn.commit()
    return conn

@app.route('/cards', methods=['GET'])
def get_cards():
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT name, 'Insect' as type FROM insect_cards")
    insect_cards = cursor.fetchall()
    
    cursor.execute("SELECT name, 'Spell/Enhancement' as type FROM spell_enhancement_cards")
    spell_enhancement_cards = cursor.fetchall()
    
    all_cards = insect_cards + spell_enhancement_cards
    conn.close()
    
    return jsonify([{"name": card[0], "type": card[1]} for card in all_cards])

@app.route('/save_deck', methods=['POST'])
def save_deck():
    conn = connect_db()
    cursor = conn.cursor()
    
    deck_name = request.json['deck_name']
    card_names = request.json['cards']
    
    cursor.execute("INSERT INTO decks (name) VALUES (?)", (deck_name,))
    deck_id = cursor.lastrowid
    
    for card_name in card_names:
        cursor.execute("INSERT INTO deck_cards (deck_id, card_name) VALUES (?, ?)", (deck_id, card_name))
    
    conn.commit()
    conn.close()
    
    return jsonify({"message": "デッキが保存されました！", "deck_id": deck_id})

@app.route('/decks', methods=['GET'])
def get_decks():
    conn = connect_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT id, name FROM decks")
    decks = cursor.fetchall()
    
    deck_list = []
    for deck in decks:
        deck_id = deck[0]
        deck_name = deck[1]
        
        cursor.execute("SELECT card_name FROM deck_cards WHERE deck_id=?", (deck_id,))
        cards = cursor.fetchall()
        
        deck_list.append({
            "id": deck_id,
            "name": deck_name,
            "cards": [card[0] for card in cards]
        })
    
    conn.close()
    return jsonify(deck_list)

@app.route('/edit_deck/<int:deck_id>', methods=['POST'])
def edit_deck(deck_id):
    conn = connect_db()
    cursor = conn.cursor()
    
    new_cards = request.json['cards']
    
    # 既存のカードを削除
    cursor.execute("DELETE FROM deck_cards WHERE deck_id=?", (deck_id,))
    
    # 新しいカードを追加
    for card_name in new_cards:
        cursor.execute("INSERT INTO deck_cards (deck_id, card_name) VALUES (?, ?)", (deck_id, card_name))
    
    conn.commit()
    conn.close()
    
    return jsonify({"message": "デッキが更新されました！", "deck_id": deck_id})

if __name__ == '__main__':
    app.run(debug=True)
