// Example of using Acktie Mobile Barcode

//FirstView Component Constructor
var barcodereader = undefined;
var barcodeCodeWindow = undefined;
var barcodeCodeView = undefined;

// Import
if (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad') {
	barcodereader = require('com.acktie.mobile.ios.barcode');
} else if (Ti.Platform.osname === 'android') {
	barcodereader = require('com.acktie.mobile.android.barcode');
}


// All supported Barcode types
var ALL = [
    "EAN2",
    "EAN5",
    "EAN8",
    "UPCE",
    "ISBN10",
    "UPCA",
    "EAN13",
    "ISBN13",
    "COMPOSITE",
    "I25",
    "DATABAR",
    "DATABAR_EXP",
    "CODE39",
    "PDF417",
    "CODE93",
    "CODE128",];

// Examples of Barcode type groups
var EAN = [
    "EAN2",
    "EAN5",
    "EAN8",
    "EAN13"];
    
var UPC = [
    "UPCE",
    "UPCA",];
    
var ISBN13 = [
	"EAN13",
    "ISBN13",];
    
var ISBN10 = [
	"EAN13",
    "ISBN10",];
    
var DATABAR = [
    "DATABAR",
    "DATABAR_EXP",];

var CODE = [
    "CODE39",
    "CODE93",
    "CODE128",];

// open a single window
var self = Ti.UI.createWindow({
	backgroundColor : 'white'
});

var barcodeFromAlbumButton = Titanium.UI.createButton({
	title : 'Barcode from Album (Default (All))',
	height : 40,
	width : '100%',
	top : 10
});

barcodeFromAlbumButton.addEventListener('click', function() {
	// Android does not currently support reading from the Image Gallery
	if (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad') {
		barcodereader.scanBarcodeFromAlbum({
			success : success,
			cancel : cancel,
			error : error,
		});
	} else if (Ti.Platform.osname === 'android') {
		alert("Scanning from Image Gallery is not support on Android");
	}
	
});

self.add(barcodeFromAlbumButton);

var barcodeFromCameraButton = Titanium.UI.createButton({
	title : 'Barcode from Camera (All)',
	height : 40,
	width : '100%',
	top : 60
});
barcodeFromCameraButton.addEventListener('click', function() {
	var options = {
		// ** Android Barcode Reader properties (ignored by iOS)
		backgroundColor : 'black',
		width : '100%',
		height : '90%',
		top : 0,
		left : 0,
		// **

		// ** Used by both iOS and Android
		overlay : {
			color : "blue",
			layout : "center",
			alpha : .75
		},
		barcodes:ALL,
		success : success,
		cancel : cancel,
		error : error,
	};

	if (Ti.Platform.name == "android") {
		scanBarcodeFromCamera(options);
	} else {
		barcodereader.scanBarcodeFromCamera(options);
	}
});

self.add(barcodeFromCameraButton);

var barcodeFromCameraContButton = Titanium.UI.createButton({
	title : 'Barcode from Cont. Camera (ISBN13)',
	height : 40,
	width : '100%',
	top : 110
});
barcodeFromCameraContButton.addEventListener('click', function() {
	var options = {
		// ** Android Barcode Reader properties (ignored by iOS)
		backgroundColor : 'black',
		width : '100%',
		height : '90%',
		top : 0,
		left : 0,
		// **

		// ** Used by iOS (allowZoom/userControlLight ignored on Android)
		userControlLight : true,
		allowZoom : false,
			
		// ** Used by both iOS and Android
		overlay : {
			imageName : 'exampleBranding.png',
		},
		barcodes:ISBN13,
		continuous : true,
		success : success,
		cancel : cancel,
		error : error,
	};

	if (Ti.Platform.name == "android") {
		scanBarcodeFromCamera(options);
	} else {
		barcodereader.scanBarcodeFromCamera(options);
	}
});

self.add(barcodeFromCameraContButton);

var barcodeFromManualCameraButton = Titanium.UI.createButton({
	title : 'Barcode from Image Cap. (UPC)',
	height : 40,
	width : '100%',
	top : 160
});
barcodeFromManualCameraButton.addEventListener('click', function() {
	var options = {
		backgroundColor : 'black',
		width : '100%',
		height : '90%',
		top : 0,
		left : 0,
		scanBarcodeFromImageCapture : true,
		overlay : {
			color : "purple",
			layout : "center",
			alpha : .75
		},
		scanButtonName : 'Scan Code!',
		success : success,
		cancel : cancel,
		error : error,
	};

	if (Ti.Platform.name == "android") {
		scanBarcodeFromImageCapture(options);
	} else {
		alert("Image Capture not support on iOS");
	}
});

self.add(barcodeFromManualCameraButton);

var barcodeFromManualContCameraButton = Titanium.UI.createButton({
	title : 'Barcode from Image Cap. Cont. (UPC)',
	height : 40,
	width : '100%',
	top : 210
});
barcodeFromManualContCameraButton.addEventListener('click', function() {
	var options = {
		backgroundColor : 'black',
		width : '100%',
		height : '90%',
		top : 0,
		left : 0,
		scanBarcodeFromImageCapture : true,
		overlay : {
			color : "red",
			layout : "center",
		},
		continuous : true,
		scanButtonName : 'Keep Scanning!',
		success : success,
		cancel : cancel,
		error : error,
	};

	if (Ti.Platform.name == "android") {
		scanBarcodeFromImageCapture(options);
	} else {
		alert("Image Capture not support on iOS");
	}
});

self.add(barcodeFromManualContCameraButton);
	
function success(data) {
	if(data != undefined && data.data != undefined) {
		Titanium.Media.vibrate();
		alert('data: ' + data.data + ' type: ' + data.type);
	}
};

function cancel() {
	alert("Cancelled");
};

function error() {
	alert("error");
};

/*
 * Function that mimics the iPhone Barcode Code reader behavior.
 */
function scanBarcodeFromCamera(options) {
	barcodeCodeWindow = Titanium.UI.createWindow({
		backgroundColor : 'black',
		width : '100%',
		height : '100%',
	});
	barcodeCodeView = barcodereader.createBarcodeView(options);

	var closeButton = Titanium.UI.createButton({
		title : "close",
		bottom : 0,
		left : 0
	});
	var lightToggle = Ti.UI.createSwitch({
		value : false,
		bottom : 0,
		right : 0
	});

	closeButton.addEventListener('click', function() {
		barcodeCodeView.stop();
		barcodeCodeWindow.close();
	});

	lightToggle.addEventListener('change', function() {
		barcodeCodeView.toggleLight();
	})

	barcodeCodeWindow.add(barcodeCodeView);
	barcodeCodeWindow.add(closeButton);

	if (options.userControlLight != undefined && options.userControlLight) {
		barcodeCodeWindow.add(lightToggle);
	}

	// NOTE: Do not make the window Modal.  It screws stuff up.  Not sure why
	barcodeCodeWindow.open();
}

/*
 * Function that mimics the iPhone Barcode Code reader behavior.
 */
function scanBarcodeFromImageCapture(options) {

	barcodeCodeWindow = Titanium.UI.createWindow({
		backgroundColor : 'black',
		width : '100%',
		height : '100%',
	});
	barcodeCodeView = barcodereader.createBarcodeView(options);

	var closeButton = Titanium.UI.createButton({
		title : "close",
		bottom : 0,
		left : 0
	});

	var scanBarcode = Titanium.UI.createButton({
		title : options.scanButtonName,
		bottom : 0,
		left : '50%'
	});

	var lightToggle = Ti.UI.createSwitch({
		value : false,
		bottom : 0,
		right : 0
	});

	closeButton.addEventListener('click', function() {
		barcodeCodeView.stop();
		barcodeCodeWindow.close();
	});

	scanBarcode.addEventListener('click', function() {
		barcodeCodeView.scanBarcode();
	});

	lightToggle.addEventListener('change', function() {
		barcodeCodeView.toggleLight();
	})

	barcodeCodeWindow.add(barcodeCodeView);
	barcodeCodeWindow.add(scanBarcode);
	barcodeCodeWindow.add(closeButton);

	if (options.userControlLight != undefined && options.userControlLight) {
		barcodeCodeWindow.add(lightToggle);
	}

	// NOTE: Do not make the window Modal.  It screws stuff up.  Not sure why
	barcodeCodeWindow.open();
}

if (Ti.Platform.osname === 'android') {
	var activity = Ti.Android.currentActivity;
	activity.addEventListener('pause', function(e) {
		Ti.API.info('Inside pause');
		if (barcodeCodeView != undefined) {
			barcodeCodeView.stop();
		}

		if (barcodeCodeWindow != undefined) {
			barcodeCodeWindow.close();
		}
	});
}

self.open();