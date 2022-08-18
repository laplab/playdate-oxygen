# Oxygen

A fast-paced platformer.

## Roadmap

- [x] Basic movement
- [x] Variable jump
- [x] Basic level editing setup
- [x] Exit
- [x] Oxygen timer
- [x] Wall jump
- [ ] Cancel wall attachment with A + Down
- [ ] Design 3 interesting non-beginner levels
- [x] Add QR code generation (or display a pre-generated QR code, does not matter)
- [x] Create basic website which reads data from QR code
- [ ] Make presentation for Panic

## Ideas bucket

- [ ] Dash with B (uses oxygen?)
- [ ] Add gameover detection
- [ ] Add environment details to levels

## Funding estimate

```python
development_hours = 55 * 200
bugfixing_hours = 55 * 100
artist_hours = 55 * 50
music_commission = 200

print(development_hours + bugfixing_hours + artist_hours + music_commission)
# == 19450
```

## Price estimate

20$ or equivalent. After the most harsh 40% taxes this becomes 12$, which covers development + bugfixing after selling 1375 copies. Selling this many copies is somewhat realistic (but a little bit optimistic as well).

In the most optimistic case where I sell 5k copies (10% of all PlayDate owners buy my game), I make net 43.5k dollarydoos excluding development + bugfixing costs and taxes.

## Build instructions

C part and Lua part are independent. To build the C part run:

```
mkdir build
cd build
cmake ..
make
```

After that you can rebuild Lua part with recent changes and the latest C build will be reused.