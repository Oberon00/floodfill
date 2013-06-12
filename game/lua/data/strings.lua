--[[
    module data.strings
    language: German
--]]

return {

-- State: Splash
    press_any_key = "Dr�cken Sie eine beliebige Taste . . .",

-- State: Menu
    menu_back = "ZUR�CK",

    -- Main menu
    new_game = "Neues Spiel",
    continue_game = "Spiel fortsetzen",
    show_help = "Hilfe",
    show_credits = "Credits",
    show_settings = "Einstellungen",
    exit_program = "Beenden",

    -- Settings
    setting_enabled = "ein",
    setting_disabled = "aus",
    fullscreen_stat = "Vollbild: %s",
    vsync_stat = "VSync: %s",
    resolution_stat = "Aufl�sung: %s",
    resolution_add_desktop = " (Desktop)",
    resolution_add_current = " (aktuell)",
    resolution_title = "Aufl�sung w�hlen",


    -- Level selection
    level_i_locked = "[Level %i]",

-- State: Game, Menu
    level_i = "Level %i",

-- State: Game
    lose_level = "Verloren!",


-- State: Help
    help_text =
[[FloodFill ist ein Logikspiel. Der Spieler steuert seine Figur und bet�tigt Hebel und Schalter, um Schleusen zu �ffnen und zu schlie�en und somit Wasser, das ihn auch blockieren kann, von einer oder mehreren Quellen zu einem oder mehreren Zielen zu leiten.

Die Schwierigkeit besteht darin, die Hebel in der richtigen Reihenfolge in die richtige Stellung zu bringen.

Zum Bewegen des Spielers werden die W (auf), A (links), S (ab), D (rechts) Tasten verwendet. Wenn der Spieler an ein Objekt anst��t, das eine Aktion ausl�st, geschieht dies automatisch. Mit F5 kann das Level neu gestartet werden.
Im Men� kann auch mit den Pfeiltasten auf/ab eine Auswahl getroffen werden, und mit links/rechts zwischen mehreren Seiten (falls verf�gbar) gewechselt werden. Mit Enter oder Leertaste wird die Auswahl best�tigt.

F�r mehr und ausf�hrlichere Hilfe sehen Sie bitte im FloodFill-Handbuch (usermanual.pdf) nach.]]
,

-- Debugging
    _test1 = "@strings._test1",
    _test2 = "@strings._test2",
    _test3 = "@strings._test3",
    _test4 = "@strings._test4",
    _test5 = "@strings._test5",
    _test6 = "@strings._test6",
    _test7 = "@strings._test7",
    _test8 = "@strings._test8",
    _test9 = "@strings._test9",
    _test10 = "@strings._test10",
    _test11 = "@strings._test11",
    _test12 = "@strings._test12",
    _test13 = "@strings._test13",
    _test14 = "@strings._test14",
    _test15 = "@strings._test15",
    _test16 = "@strings._test16",
    _test17 = "@strings._test17",
    _test18 = "@strings._test18",
    _test19 = "@strings._test19",
}
