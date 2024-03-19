# Mac notarization part
`xcrun notarytool submit DiceGuess.dmg --apple-id indrekl@gmail.com --team-id PGTN5QKRGG --password nefn-vjya-dqfn-pmvq`

Get back id from last command. And use here:

`xcrun notarytool [ID] --apple-id indrekl@gmail.com --team-id PGTN5QKRGG --password nefn-vjya-dqfn-pmvq`

Then when accepted (about 5 min or less).

`xcrun stapler staple DiceGuess.dmg`

# Useful commands 

## Screenshots 
magick mogrify -path /path/to/output -resize 1920x1080 -background black -gravity center -extent 1920x1080 /path/to/input/*.png
magick mogrify -path /path/to/output -resize 1920x1080 -background black -gravity center -extent 1920x1080 *.png
magick mogrify -resize 1920x1080 -background black -gravity center -extent 1920x1080 *.png

## Gifs
ffmpeg -i /Users/ksvslk/Projects/dice-guess-graphics/gif_dice.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" -c:v gif output.gif
ffmpeg -i gif_dice.mp4 -filter_complex "[0:v] fps=20,scale=640:-1:flags=lanczos,split [a][b];[a] palettegen [p];[b][p] paletteuse" -c:v gif output.gif

## Icons
magick convert icon_256x256.png -define icon:auto-resize=256,128,64,48,32,16 icon.ico

