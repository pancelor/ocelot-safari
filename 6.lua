-- notes
--[[

tasks:

x make sprites: rocks, pick, stone
 (and make actors)
x map drawing (no gen); no black border...?
x fix machete
* worldgen
* ocelots
* day/night cycle

-----

* tool sprites
 x axe
 x machete
 x pick
 x flint
 * magnify glass

* world sprites
 x tree
 x wood
 x vines
 x rock
 x stone
 x fire
 * gem
 * lava(?)
 x water

* worldgen
 * choose algo
   perlin noise might be easy?
   can't guarantee no softlocks (large lake no rocks)
 * implement

x check perf - do trees etc need to be tiles, not actors?
 x probably collision is the big slowdown

* sfx

* day/night cycle
 * alt palettes (start with just 1 for night)

* other sprites
 * player
 * ocelot
 * demons

---

uh oh you can softlock kinda easy with e.g. machete.
 is this okay?

]]
