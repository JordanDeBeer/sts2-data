local Enchantment = [
  { "name": "amount", "type": "INTEGER" },
  { "name": "id", "type": "STRING" }
];

local Choice = [
  { "name": "choice", "type": "STRING", "mode": "REQUIRED" },
  { "name": "was_picked", "type": "BOOLEAN", "mode": "REQUIRED" }
];

local Title = [
  { "name": "key", "type": "STRING", "mode": "REQUIRED" },
  { "name": "table", "type": "STRING", "mode": "REQUIRED" }
];

local PropInts = [
  { "name": "name", "type": "STRING", "mode": "NULLABLE" },
  { "name": "value", "type": "INTEGER", "mode": "NULLABLE" }
];

local PropStrings = [
  { "name": "name", "type": "STRING" },
  { "name": "value", "type": "STRING" }
];

local PropBools = [
  { "name": "name", "type": "STRING", "mode": "NULLABLE" },
  { "name": "value", "type": "BOOLEAN", "mode": "NULLABLE" }
];

local PropIntArrays = [
  { "name": "name", "type": "STRING", "mode": "NULLABLE" },
  { "name": "value", "type": "INTEGER", "mode": "REPEATED" }
];

local Props = [
  {
    "name": "ints",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": PropInts
  },
  {
    "name": "strings",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": PropStrings
  },
  {
    "name": "bools",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": PropBools
  },
  {
    "name": "int_arrays",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": PropIntArrays
  }
];

local Card = [
  { "name": "id", "type": "STRING", "mode": "REQUIRED" },
  { "name": "current_upgrade_level", "type": "INTEGER" },
  { "name": "floor_added_to_deck", "type": "INTEGER" },
  Enchantment,
  Props
];

[
  {
    "name": "acts",
    "type": "STRING",
    "mode": "REPEATED"
  },
  {
    "name": "ascension",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "build_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "game_mode",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "killed_by_encounter",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "killed_by_event",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "map_point_history",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": [
      {
        "name": "act",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "points",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
          {
            "name": "map_point_type",
            "type": "STRING",
            "mode": "REQUIRED"
          },
          {
            "name": "player_stats",
            "type": "RECORD",
            "mode": "REPEATED",
            "fields": [
              {
                "name": "downgraded_cards",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "completed_quests",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "potion_discarded",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "bought_colorless",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "cards_removed",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": Card
              },
              {
                "name": "bought_potions",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "bought_relics",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "upgraded_cards",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "cards_transformed",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                  {
                    "name": "final_card",
                    "type": "RECORD",
                    "fields": Card
                  },
                  {
                    "name": "original_card",
                    "type": "RECORD",
                    "fields": Card
                  }
                ]
              },
              {
                "name": "cards_enchanted",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": Card
              },
              {
                "name": "cards_gained",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": Card
              },
              {
                "name": "current_gold",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "current_hp",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "damage_taken",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "gold_gained",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "gold_lost",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "gold_spent",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "gold_stolen",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "hp_healed",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "max_hp",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "max_hp_gained",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "max_hp_lost",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "player_id",
                "type": "INTEGER",
                "mode": "REQUIRED"
              },
              {
                "name": "rest_site_choices",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "potion_choices",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": Choice
              },
              {
                "name": "ancient_choice",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                  {
                    "name": "TextKey",
                    "type": "STRING",
                    "mode": "REQUIRED"
                  },
                  {
                    "name": "title",
                    "type": "RECORD",
                    "fields": Title
                  },
                  {
                    "name": "was_chosen",
                    "type": "BOOLEAN",
                    "mode": "REQUIRED"
                  }
                ]
              },
              {
                "name": "event_choices",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                  {
                    "name": "title",
                    "type": "RECORD",
                    "fields": Title
                  },
                  {
                    "name": "variables",
                    "type": "JSON"
                  }
                ]
              },
              {
                "name": "relic_choices",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": Choice
              },
              {
                "name": "potion_used",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "card_choices",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                  {
                    "name": "card",
                    "type": "RECORD",
                    "fields": Card
                  },
                  {
                    "name": "was_picked",
                    "type": "BOOLEAN",
                    "mode": "REQUIRED"
                  }
                ]
              },
              {
                "name": "relics_removed",
                "type": "STRING",
                "mode": "REPEATED"
              }
            ]
          },
          {
            "name": "rooms",
            "type": "RECORD",
            "mode": "REPEATED",
            "fields": [
              {
                "name": "model_id",
                "type": "STRING"
              },
              {
                "name": "monster_ids",
                "type": "STRING",
                "mode": "REPEATED"
              },
              {
                "name": "room_type",
                "type": "STRING",
                "mode": "required"
              },
              {
                "name": "turns_taken",
                "type": "INTEGER",
                "mode": "REQUIRED"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "name": "modifiers",
    "type": "STRING",
    "mode": "REPEATED"
  },
  {
    "name": "platform_type",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "players",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": [
      {
        "name": "character",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "deck",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": Card
      },
      {
        "name": "id",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "max_potion_slot_count",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "potions",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
          {
            "name": "id",
            "type": "STRING",
            "mode": "NULLABLE"
          },
          {
            "name": "slot_index",
            "type": "INTEGER",
            "mode": "NULLABLE"
          }
        ]
      },
      {
        "name": "relics",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
          {
            "name": "floor_added_to_deck",
            "type": "INTEGER"
          },
          {
            "name": "id",
            "type": "STRING"
          },
          {
            "name": "props",
            "type": "RECORD",
            "mode": "NULLABLE",
            "fields": [
              {
                "name": "model_ids",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": PropStrings
              },
              {
                "name": "cards",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": [
                  {
                    "name": "name",
                    "type": "STRING"
                  },
                  {
                    "name": "value",
                    "type": "RECORD",
                    "fields": Card
                  }
                ]
              },
              {
                "name": "ints",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": PropInts
              },
              {
                "name": "strings",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": PropStrings
              },
              {
                "name": "bools",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": PropBools
              },
              {
                "name": "int_arrays",
                "type": "RECORD",
                "mode": "REPEATED",
                "fields": PropIntArrays
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "name": "run_time",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "schema_version",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "seed",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "start_time",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "was_abandoned",
    "type": "BOOLEAN",
    "mode": "REQUIRED"
  },
  {
    "name": "win",
    "type": "BOOLEAN",
    "mode": "REQUIRED"
  }
]
