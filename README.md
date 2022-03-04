# Pluto Beacon

## What is this?

This script generates Morse code tones for the text supplied on the command-line
of a PlutoSDR. Note that this is written for the busybox shell (Almquist shell
or ash), because that's what's included in the default Pluto firmware. This has been tested on [v0.34 of the PlutoSDR firmware](https://github.com/analogdevicesinc/plutosdr-fw/releases/tag/v0.34).

The original idea is based on a python script by [LamaBleu](https://github.com/LamaBleu). The bist_tone
information came from the PDF of a FOSDEM 2018 presentation by [Robin Getz](https://github.com/rgetz) and
[Michael Hennerich](https://github.com/mhennerich) from [Analog Devices](https://github.com/analogdevicesinc).

- [Morse-code transmission concept](https://github.com/LamaBleu/plutoscripts/blob/master/root/CW-pluto.py)
- [The bist_tone shenannigans from the automounter example on page 31 of the PDF notes from the 2018 FOSDEM presentation](https://archive.fosdem.org/2018/schedule/event/plutosdr/attachments/slides/2503/export/events/attachments/plutosdr/slides/2503/pluto_stupid_tricks.pdf)
- [Analog Devices documentation for the bist_tone](https://wiki.analog.com/resources/tools-software/linux-drivers/iio-transceiver/ad9361#bist_tone)

## Disclaimer

This is not pretty. Ash doesn't have arrays so, we're calling a function to
determine the Morse-code for each character.

The frequency and local offsets are still a mystery to me. The numbers in the
script come from accidentally stumbling across a bist_tone test with my radio.
The numbers don't match anything I've seen in the documentation or the sample
code that was used.

The outcome is a 1kHz tone at the dial frequency.

This causes the PlutoSDR to transmit. Unless you have a license to do so, you
should not run this code on your device.

## Usage

- Upload cw.sh to the Pluto
- chmod +x cw.sh
- ./cw.sh "text"
- CTRL-C to stop before it's finished.

## Prerequisites
Note that these are part of the default PlutoSDR firmware.

- busybox
- iio_attr

## Author

Onno (VK6FLAB) [cq@vk6flab.com](mailto:cq@vk6flab.com)

