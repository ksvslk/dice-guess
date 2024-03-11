# Mac notarization part
`xcrun notarytool submit DiceGuess.dmg --apple-id indrekl@gmail.com --team-id PGTN5QKRGG --password nefn-vjya-dqfn-pmvq`

Get back id from last command. And use here:

`xcrun notarytool [ID] --apple-id indrekl@gmail.com --team-id PGTN5QKRGG --password nefn-vjya-dqfn-pmvq`

Then when accepted (about 5 min or less).

`xcrun stapler staple DiceGuess.dmg`