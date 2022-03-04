#!/bin/sh
# This is busybox on the pluto, so ash

# Tone generation and offsets are still a mystery to me. This works, based on
# accedentalliy finding my transmission signal with a nearby radio, but no idea
# how the TX_LO, sample frequency and any other offsets work. The outcome is a
# 1kHz tone on the specified frequency.

# Text to send. Unknown characters are ignored, converted to UPPER case
text=$(echo "$@" | tr '[:lower:]' '[:upper:]')

# default frequency
frequency=144654321

# default speed
wpm=10

#
# No idea at this time where this offset comes from,
# the resulting tone is 1kHz when the radio dial is set to $frequency
#
carrier=$((frequency - 997000))

# We don't have arrays in busybox
char_to_code() {
	while read char code
	do
		if [ "$1" = "${char}" ]
		then
			echo "${code}"
			exit
		fi
	done <<-MORSE
		A 	.- 
		B 	-... 
		C 	-.-. 
		D 	-.. 
		E 	. 
		F 	..-. 
		G 	--. 
		H 	.... 
		I 	.. 
		J 	.--- 
		K 	-.- 
		L 	.-.. 
		M 	-- 
		N 	-. 
		O 	--- 
		P 	.--. 
		Q 	--.- 
		R 	.-. 
		S 	... 
		T 	- 
		U 	..- 
		V 	...- 
		W 	.-- 
		X 	-..- 
		Y 	-.-- 
		Z 	--.. 
		0 	----- 
		1 	.---- 
		2 	..--- 
		3 	...-- 
		4 	....- 
		5 	..... 
		6 	-.... 
		7 	--... 
		8 	---.. 
		9 	----. 
		.	·−·−·−
		,	--..--
		?	..--..
		!	-.-.--
		/	-..-.
		(	-.--.
		)	-.--.-
		&	.-...
		:	---...
		;	-.-.-.
		=	-...-
		+	.-.-.
		-	-....-
		_	..--.-
		"	.-..-.
		$	...-..-
		@	.--.-.
	MORSE
}

# We don't have floating point math
calc() {
	awk "BEGIN { print "$*" }";
}

# If you hit CTRL-C, the TX needs to stop.
stopTX() {
	echo
	echo "Interrupted"
	echo 0 0 0 0  > /sys/kernel/debug/iio/iio:\device1/bist_tone
	exit 2
}

trap "stopTX" 2

# How to space dits, dahs, inter-letter and inter-word
# In: morse dit units to sleep
morse_sleep() (
	duration=$(calc "$1*60/(50*${wpm})")
	sleep ${duration}
)

# Send a dit
TXdit() {
	echo 1 0 0 0  > /sys/kernel/debug/iio/iio\:device1/bist_tone
	morse_sleep 1
	echo 0 0 0 0  > /sys/kernel/debug/iio/iio\:device1/bist_tone
}

# Send a dah
TXdah() {
	echo 1 0 0 0  > /sys/kernel/debug/iio/iio\:device1/bist_tone
	morse_sleep 3
	echo 0 0 0 0  > /sys/kernel/debug/iio/iio\:device1/bist_tone
}

# Setup the transmitter
iio_attr -q -c ad9361-phy voltage0 sampling_frequency 32000000
iio_attr -q -c ad9361-phy altvoltage1 frequency ${carrier}

# Process each letter, converting the string to lines
echo "${text}" | grep -o . | while read char
do

# If a letter is a space, it will show up as an empty line
	if [ "${char}" = "" ]
	then
# A word space is 7 units, but we've already waited an inter-symbol and 
# inter-character space - note that this breaks if it's the first character,
# but then we haven't yet transmitted anything at this point.
		morse_sleep 4
		echo -n " "
		continue ;
	fi

# Convert each character to the morse code equivalent
	char_to_code "${char}" | grep -o . | while read symbol
	do
		echo -n "${symbol}"

# If we're sending a dit
		if [ "${symbol}" = "." ]
		then
			TXdit
		else
			TXdah
		fi
# Inter-symbol spacing
		morse_sleep 1
	done
	echo -n " "
# Inter-character spacing which already includes the inter-symbol space
# from the one we just sent
	morse_sleep 2
done

# Line feed so we aren't still on the line showing morse
echo
