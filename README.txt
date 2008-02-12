= JackTheRIPper

http://johnwilger.com/search?q=JackTheRIPper

== DESCRIPTION:

RIPs Postscript documents (PDF, AI, EPS, etc) and performs transformations on
raster images such as scaling and padding based on instructions pulled from
Amazon SQS. Source files are pulled from a URI when the instruction is
processed, and result files are published to a URI specified by the client.

Currently, only RIPing and transforming on OSX machines is supported; support
for other platforms is planned for subsequent releases. On OSX, all RIP and
transformation operations are performed using the SIPS utility.

== FEATURES/PROBLEMS:

* Receives instructions from Amazon SQS
* Retrieves source images from a URI specified in the instruction
* Rasterizes Postscript documents (only the first page of multi-page documents)
* Scales and optionally pads raster images
* Publishes resulting image to a URI specified in the transformation instruction

== SYNOPSIS:

Just run `jack_the_ripper start` to start the service as a daemon.

Run `jack_the_ripper stop` to stop the service. Any currently processing
instructions will complete before the system exits. Pass the --kill switch
to stop immediately.

By default, the system will store its pidfile in /var/run/jack_the_ripper.pid
and its log file in /var/log/jack_the_ripper.log. You can override these
locations when starting the system by passing the --pid and --log switches,
respectively. Note that if you change the location of the pidfile, you will
also need to pass the --pid option when stopping the system.

=== SQS Message Body

The body of the SQS messages to be processed by JackTheRIPper should be a YAML
encoded Hash with the following keys:

* :source_uri - REQUIRED An HTTP URI pointing to the source image
	(i.e. 'http://example.com/an_image.pdf' ). A GET request to this URI must
	return the image file and a valid Content-Type header.
* :result_uri - REQUIRED An HTTP URI to which a PUT request will be sent containing the
	converted image data. The correct Content-Type header will also be sent with
	this request.
* :format - OPTIONAL One of :jpeg, :tiff, :png, :gif, :jp2, :pict, :bmp,
	:qtif, :psd, :sgi, :tga. The result file will be saved in this format.
* :scale - OPTIONAL The maximum dimension of the width and height of the
	result. The result image will be scaled to fit, maintaining the aspect
	ratio.
* :pad - OPTIONAL "HxW COLOR" Pads the image using COLOR to the specified
	dimensions. COLOR should be specified using a hex code such as 'FFFFFF'.
	
Example:

	instruction = YAML.dump( {
		:source_uri => 'http://example.com/an_image.pdf',
		:result_uri => 'http://example.com/receive_image/123',
		:format => :jpeg,
		:scale => 100,
		:pad => '100x100 FFFFFF'
	} )

== REQUIREMENTS:

* OSX 10.5.x
* Ruby 1.8.6
* An Amazon AWS account
* An SQS queue

== INSTALL:

  sudo gem install JackTheRIPper

== LICENSE:

(The MIT License)

Copyright (c) 2008 John Wilger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
