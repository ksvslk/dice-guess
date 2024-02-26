extends ColorRect

var blink_timer = 0 # Timer to control the blinking
var blink_duration = 1.0 # Duration of one blink cycle (fade out and in)
var blinking = false # Control whether the sprite should blink

func _process(delta):
	if blinking:
		blink_timer += delta # Increment the timer by the elapsed time
		
		# Calculate the alpha value for the current frame
		var alpha = abs(sin(blink_timer / blink_duration * PI))
		
		# Update the modulate property to apply the alpha
		modulate.a = alpha
		
		# Reset the timer to create a continuous loop
		if blink_timer >= blink_duration:
			blink_timer = 0
