import pygame

class Card:
    def __init__(self, card_id, name, cost, health, attribute, rarity):
        self.card_id = card_id
        self.name = name
        self.cost = cost
        self.health = health
        self.attribute = attribute
        self.rarity = rarity
        self.techniques = []
    
    def add_technique(self, name, power, description):
        self.techniques.append({"name": name, "power": power, "description": description})
    
    def apply_effect(self, game_state, target, technique_name):
        for technique in self.techniques:
            if technique['name'] == technique_name:
                if technique_name == "ツノ突進":
                    self.horn_charge_effect(game_state, target, technique)
                elif technique_name == "すくい投げ":
                    self.scoop_throw_effect(game_state, target, technique)
                break

    def horn_charge_effect(self, game_state, target, technique):
        if target:
            damage = technique['power']
            if self.attribute == '青' and target.attribute == '赤':
                damage *= 2
            target.health -= damage
            if target.health <= 0:
                game_state.remove_card(target)

    def scoop_throw_effect(self, game_state, target, technique):
        if target:
            game_state.flip_card(target)

class GameState:
    def __init__(self, player1, player2):
        self.players = [player1, player2]
        self.current_player = 0
        self.winner = None

    def switch_turn(self):
        self.current_player = 1 - self.current_player

    def get_current_player(self):
        return self.players[self.current_player]

    def remove_card(self, card):
        card.health = 0  # 簡易的なカードの除去ロジック

    def flip_card(self, card):
        card.flipped = True

    def limit_attack(self, card):
        card.can_be_attacked = False

    def get_player_cards(self, player):
        return player.field

class Player:
    def __init__(self, name, deck):
        self.name = name
        self.deck = deck
        self.hand = []
        self.field = []
        self.health = 20

    def draw_card(self):
        if self.deck:
            card = self.deck.pop(0)
            self.hand.append(card)

    def play_card(self, card_index, game_state):
        card = self.hand.pop(card_index)
        self.field.append(card)
        card.apply_effect(game_state, target=None, technique_name=None)

class AIPlayer(Player):
    def take_turn(self, game_state):
        if self.hand:
            best_card_index = self.choose_best_card(game_state)
            self.play_card(best_card_index, game_state)

    def choose_best_card(self, game_state):
        return 0  # 最適なカードを選ぶための簡単なロジック

class GameUI:
    def __init__(self, game_state):
        pygame.init()
        self.screen = pygame.display.set_mode((800, 600))
        pygame.display.set_caption('虫神器')
        self.clock = pygame.time.Clock()
        self.game_state = game_state
        self.selected_card_index = None
        self.card_images = self.load_card_images()

    def load_card_images(self):
        card_images = {}
        card_images['カブトムシ'] = pygame.image.load('card_images/kabutomushi.png').convert_alpha()
        card_images['ギンヤンマ'] = pygame.image.load('card_images/ginyanma.png').convert_alpha()
        return card_images

    def draw_card(self, card, position):
        if card.name in self.card_images:
            image = self.card_images[card.name]
            self.screen.blit(image, position)
        else:
            font = pygame.font.Font(None, 36)
            card_text = font.render(card.name, True, (0, 0, 0))
            self.screen.blit(card_text, position)
        self.draw_health_bar(card, position)

    def draw_health_bar(self, card, position):
        bar_width = 100
        bar_height = 10
        health_ratio = max(card.health / 1000, 0)
        pygame.draw.rect(self.screen, (255, 0, 0), (position[0], position[1] + 80, bar_width, bar_height))
        pygame.draw.rect(self.screen, (0, 255, 0), (position[0], position[1] + 80, bar_width * health_ratio, bar_height))

    def handle_input(self):
        mouse_pos = pygame.mouse.get_pos()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                self.selected_card_index = self.get_card_index_at_position(mouse_pos)
            elif event.type == pygame.MOUSEBUTTONUP and self.selected_card_index is not None:
                if self.is_drop_position_valid(mouse_pos):
                    self.place_card_on_field(self.selected_card_index)
                self.selected_card_index = None
        return True

    def is_drop_position_valid(self, position):
        return 100 <= position[1] <= 200  # 仮のフィールド位置

    def place_card_on_field(self, card_index):
        player = self.game_state.get_current_player()
        card = player.hand[card_index]
        start_pos = (100 + card_index * 120, 350)
        end_pos = (100 + len(player.field) * 120, 150)
        self.animate_card_movement(card, start_pos, end_pos)
        player.play_card(card_index, self.game_state)

    def animate_card_movement(self, card, start_pos, end_pos):
        duration = 30
        for i in range(duration):
            x = start_pos[0] + (end_pos[0] - start_pos[0]) * i / duration
            y = start_pos[1] + (end_pos[1] - start_pos[1]) * i / duration
            self.screen.fill((255, 255, 255))
            self.draw_game_state()
            self.draw_card(card, (x, y))
            pygame.display.flip()
            self.clock.tick(60)

    def run(self):
        running = True
        while running:
            running = self.handle_input()
            self.draw_game_state()
            self.clock.tick(30)
        pygame.quit()

