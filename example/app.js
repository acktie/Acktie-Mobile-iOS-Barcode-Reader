// Example of using Acktie Mobile Barcode

// Import
var barcodeReader = require("com.acktie.mobile.ios.barcode");

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

// Examples of Barcode types groups
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
	barcodeReader.scanBarcodeFromAlbum({
		success : success,
		cancel : cancel,
		error : error,
	});
});

self.add(barcodeFromAlbumButton);

var barcodeFromCameraButton = Titanium.UI.createButton({
	title : 'Barcode from Camera (All)',
	height : 40,
	width : '100%',
	top : 60
});
barcodeFromCameraButton.addEventListener('click', function() {
	barcodeReader.scanBarcodeFromCamera({
		overlay : {
			color : "blue",
			layout : "center",
		},
		barcodes:ALL,
		success : success,
		cancel : cancel,
		error : error,
	});
});

self.add(barcodeFromCameraButton);

var barcodeFromCameraContButton = Titanium.UI.createButton({
	title : 'Barcode from Cont. Camera (ISBN13)',
	height : 40,
	width : '100%',
	top : 110
});
barcodeFromCameraContButton.addEventListener('click', function() {
	barcodeReader.scanBarcodeFromCamera({
		overlay : {
			color : "purple",
			layout : "center",
		},
		barcodes:ISBN13,
		continuous : true,
		userControlLight : true,
		allowZoom : false,
		success : success,
		cancel : cancel,
		error : error,
	});
});

self.add(barcodeFromCameraContButton);

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

self.open();