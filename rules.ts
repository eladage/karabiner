import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open } from "./utils";

const rules: KarabinerRules[] = [
  // Define the Hyper key itself
  {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
      {
        description: "Caps Lock -> Hyper Key",
        from: {
          key_code: "caps_lock",
          modifiers: {
            optional: ["any"],
          },
        },
        to: [
          {
            key_code: "left_shift",
            modifiers: ["left_command", "left_control", "left_option"],
          },
        ],
        type: "basic",
      },
      {
        description: "Right Shift -> Esc",
        from: {
          key_code: "right_shift",
        },
        to: [
          {
            key_code: "escape",
          },
        ],
        type: "basic",
      },
      {
        type: "basic",
        description: "Up Arrow",
        from: {
          key_code: "i",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "up_arrow",
          },
        ],
      },
      {
        type: "basic",
        description: "Down Arrow",
        from: {
          key_code: "k",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "down_arrow",
          },
        ],
      },
      {
        type: "basic",
        description: "Left Arrow",
        from: {
          key_code: "j",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "left_arrow",
          },
        ],
      },
      {
        type: "basic",
        description: "Right Arrow",
        from: {
          key_code: "l",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "right_arrow",
          },
        ],
      },
      {
        type: "basic",
        description: "Right Arrow",
        from: {
          key_code: "l",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "right_arrow",
          },
        ],
      },
      {
        type: "basic",
        description: "Page Down",
        from: {
          key_code: "o",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "page_down",
          },
        ],
      },
      {
        type: "basic",
        description: "Page Up",
        from: {
          key_code: "u",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "page_up",
          },
        ],
      },
      {
        type: "basic",
        description: "Delete",
        from: {
          key_code: "delete_or_backspace",
          modifiers: {
            mandatory: [
              "left_shift",
              "left_command",
              "left_control",
              "left_option",
            ],
          },
        },
        to: [
          {
            key_code: "delete_forward",
          },
        ],
      },
    ],
  },
  ...createHyperSubLayers({
    // a= "Applications"
    a: {
      d: app("Visual Studio Code"),
      v: app("Visual Studio Code"),
      c: app("Visual Studio Code"),
      s: app("Warp"),
      n: app("Notion"),
      f: app("Finder"),
      t: app("Microsoft Teams"),
      m: app("Messages"),
      e: app("Mail"),
      w: app("Warp"),
      left_command: app("Visual Studio Code"),
      spacebar: app("Arc"),
    },

    // s = "System"
    s: {
      equal_sign: {
        to: [
          {
            key_code: "volume_increment",
          },
        ],
      },
      hyphen: {
        to: [
          {
            key_code: "volume_decrement",
          },
        ],
      },
      i: {
        to: [
          {
            key_code: "display_brightness_increment",
          },
        ],
      },
      k: {
        to: [
          {
            key_code: "display_brightness_decrement",
          },
        ],
      },
      l: {
        to: [
          {
            key_code: "q",
            modifiers: ["right_control", "right_command"],
          },
        ],
      },
      p: {
        to: [
          {
            key_code: "play_or_pause",
          },
        ],
      },
      semicolon: {
        to: [
          {
            key_code: "fastforward",
          },
        ],
      },
      e: {
        to: [
          {
            // Emoji picker
            key_code: "spacebar",
            modifiers: ["right_control", "right_command"],
          },
        ],
      },
    },
  }),
];

fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: {
        show_in_menu_bar: false,
      },
      profiles: [
        {
          name: "Default",
          complex_modifications: {
            rules,
          },
        },
      ],
    },
    null,
    2
  )
);
