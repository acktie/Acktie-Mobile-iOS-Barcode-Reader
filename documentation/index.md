# Acktie Mobile Barcode Module

## Description

This module allows for a quick integration of a barcode reader into your Appcelerator Mobile application.  The barcode reading ability comes in three scanning modes and supports may barcode standards.

*  Scan from Camera Feed
*  Scan from Photo Album (user selected)

Support Barcode standards are:

*  EAN-2
*  EAN-5 
*  EAN-8 
*  UPC-E 
*  ISBN-10 
*  UPC-A 
*  EAN-13 
*  ISBN-13 
*  COMPOSITE 
*  I2/5 
*  DataBar 
*  DataBar-Exp 
*  Codabar 
*  CODE-39 
*  CODE-93 
*  CODE-128 
*  PDF417 

Additionally, the Camera Feed option has the ability to provide an overlay on the feed.  Several colors and layout are provide by default with the module.  
Documented below are a list of the preloaded overlays.

At this time, it is only for Apple iOS.

**NOTE**: iPhone 3GS or higher is supported.

## Accessing the Acktie Mobile Barcode Module

To access this module from JavaScript, you would do the following:

	var barcodeReader = require("com.acktie.mobile.ios.barcode");

The barcode reader variable is a reference to the Module object.	

## Reference

The following are the Javascript functions you can call with the module.

All of the modules provide callbacks for:

### success (Callack)
Called in the event of a successful scan.  

#### result (callback result)

*  data - This returns the data of the barcode scan.
*  type - This is the type of barcode that was detected

Example: 

	function success(data){
		var barcodeData = data.data;
		var barcodeType = data.type
	};

Valid barcode "type" string returned from module :

*  EAN-2
*  EAN-5 
*  EAN-8 
*  UPC-E 
*  ISBN-10 
*  UPC-A 
*  EAN-13 
*  ISBN-13 
*  COMPOSITE 
*  I2/5 
*  DataBar 
*  DataBar-Exp 
*  Codabar 
*  CODE-39 
*  CODE-93 
*  CODE-128 
*  PDF417 


### cancel (Callack)
Called if the user clicks the cancel button.

*NOTE*: Not callback data returned.

### error 
Called if the scan was not successful in reading the barcode.

*NOTE*: Not callback data returned.

### scanBarcodeFromAlbum

Scans a barcode from an image selected from the Photo Library

Example:

	scanBarcodeFromAlbum(
	{
		success : success,
		cancel : cancel,
		error : error,
	});

### scanBarcodeFromCamera

Automatically scans a barcode code from the live Camera Feed

Example of Scanning from Camera without overlay:

	scanBarcodeFromCamera(
	{
		success : success,
		cancel : cancel,
		error : error,
	});

Example of Scanning from Camera with overlay:

	scanBarcodeFromCamera(
	{
		overlay: {
			color: "blue",
			layout: "full",
		},
		success : success,
		cancel : cancel,
		error : error,
	});

#### Valid overlay options

The following are the value JSON values for overlay.

#### color (optional):
*  blue
*  purple
*  red
*  yellow

#### layout (optional):
*  full
*  center

NOTE: Both color and layout must be specified together.  Also, iPad does not have a "full" option and will default to "center".

#### imageName (optional):
Use this property if you want to use your own overlay image.  See the customize overlay section for more details.

#### alpha (optional):
A float value between 0 - 1.  0 being fully transparent and 1 being fully visible.

Example:

alpha: 0.5  // half transparent

#### allowZoom (optional):
This feature controls whether or not the user is allowed to use the pitch to zoom gesture.

Example:

allowZoom: false,

By default this value is true.

## Additional options:
These options apply to one to many of the above modes.

### Apply to all

#### continuous (optional):
This feature will continuously scan for barcodes even after one has been detected.  The user will have to click the "Done" button to exit the barcode screen.
With each barcode that is detected the "success" event will be triggers so you program will be able to process each barcode.  Also, the application can use
the phone virate feature to indicate a scan took place.  See example app.js for details.

Example:

continuous: true,

By default this value is false.

#### barcodes (optional):
An array of strings contain valid barcode types the modules should use for detection.  If the type is not specified it will not be detected.
The following are a list of valid types:

*  "EAN2",
*  "EAN5",
*  "EAN8",
*  "UPCE",
*  "ISBN10",
*  "UPCA",
*  "EAN13",
*  "ISBN13",
*  "COMPOSITE",
*  "I25",
*  "DATABAR",
*  "DATABAR_EXP",
*  "CODE39",
*  "PDF417",
*  "CODE93",
*  "CODE128",

The app.js has several examples of different barcode types grouped.

NOTE about ISBN:  This type is detected through the EAN13 algorithm.  If you want to detect ISBN10 or ISBN13 then you will need to include EAN13 in your barcodes array list.
Also, ISBN10 has priority over ISBN13 so ISBN10 data and type will be returns when both are detected. 

Default for this property is all the available barcode types.

Example:

Only detect UPC barcodes:

	...
	
	var UPC = [
    	"UPCE",
    	"UPCA",];
	
	...

	scanBarcodeFromCamera(
	{
		barcodes: UPC
		success : success,
		cancel : cancel,
		error : error,
	});
	
### Applies only to scanBarcodeFromCamera

#### userControlLight (optional):
This feature will presents the user an On/Off switch in which to control the flash/torch.  In scanBarcodeFromCamera the light will be continuously on.

Example:

userControlLight: true,

By default this value is false.

*NOTE*: By not setting this variable or setting it to false will default the mode to auto, which means the camera will make the determination when to use the light.

## Customize Overlay
In this module's subdirectory lives is a directory called assets.  It contains all of the images used in the overlay process.  
In order to customize the overlay you will need to do 2 things:

-  Place your custom image in the assets directory
-  Use the property "imageName" in the scanBarcodeFromCamera arguments (see above).

Example:

	scanBarcodeFromCamera(
	{
		overlay: {
			imageName: "myOverlay.png",
			alpha: 0.35f
		},
		success : success,
		cancel : cancel,
		error : error,
	});
	
NOTE: Specifying an imageName will override any color/layout that is also specified in the same overlay property. Meaning, when they are both specified imageName will take precedence.

However, alpha works on both regardless of what is used (color/layout or imageName).

Included in the example/images subdirectory is an example Photoshop file and .png files. 

NOTE: The overlay feature uses the standard @2x image name for high-res images (iPhone 4 and above). This give you the ability to support the non-retina and retina displays for your overlay. 

Here is a link to Apple's site for the support image types: [Link](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIImage_Class/Reference/Reference.html)

## Known Issues/Limitations:
This module does not support manual image capture like the QR Code module does.  After a bit of testing it produced unreliable results.

## Change Log
*  1.0:  Initial Release

## Author

Tony Nuzzi @ Acktie

Twitter: @Acktie

Email: support@acktie.com
