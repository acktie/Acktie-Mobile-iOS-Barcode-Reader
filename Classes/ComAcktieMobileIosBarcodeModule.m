/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import <AVFoundation/AVFoundation.h>
#import "ComAcktieMobileIosBarcodeModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "TiUIViewProxy.h"
#import "TiUIButtonProxy.h"

@implementation ComAcktieMobileIosBarcodeModule

@synthesize continuous;
@synthesize userControlLight;
@synthesize allowZoom;
@synthesize proxy;
@synthesize navBarButton;
@synthesize popover;
@synthesize cameraDevice;

NSDictionary *barcodeDict = nil;
NSArray *allBarcodes = nil;


static const enum zbar_symbol_type_e symbolValues[] = 
{
    ZBAR_NONE,
    ZBAR_PARTIAL,
    ZBAR_EAN2,
    ZBAR_EAN5,
    ZBAR_EAN8,
    ZBAR_UPCE,
    ZBAR_ISBN10,
    ZBAR_UPCA,
    ZBAR_EAN13,
    ZBAR_ISBN13,
    ZBAR_COMPOSITE,
    ZBAR_I25,
    ZBAR_DATABAR,
    ZBAR_DATABAR_EXP,
    ZBAR_CODE39,
    ZBAR_PDF417,
    ZBAR_QRCODE,
    ZBAR_CODE93,
    ZBAR_CODE128,
    ZBAR_CODABAR,
};

static const enum zbar_symbol_type_e allSymbols[] = 
{
    ZBAR_EAN2,
    ZBAR_EAN5,
    ZBAR_EAN8,
    ZBAR_UPCE,
    ZBAR_ISBN10,
    ZBAR_UPCA,
    ZBAR_EAN13,
    ZBAR_ISBN13,
    ZBAR_COMPOSITE,
    ZBAR_I25,
    ZBAR_DATABAR,
    ZBAR_DATABAR_EXP,
    ZBAR_CODE39,
    ZBAR_PDF417,
    ZBAR_CODE93,
    ZBAR_CODE128,
    ZBAR_CODABAR,
};

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"65d076de-fa81-4d4c-b564-75f66c3f6a30";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.acktie.mobile.ios.barcode";
}

- (void) initReader: (NSString*) clsName
{
    [reader release];
    reader = [NSClassFromString(clsName) new];
    reader.readerDelegate = self;
}

- (UIImage *)imageNamed:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *modulePathWithFile = [NSString stringWithFormat:@"/modules/%@/%@", [self moduleId], name];
    NSString *fullPathWithFile = [NSString stringWithFormat:@"%@%@", bundlePath, modulePathWithFile];
    NSLog(fullPathWithFile);
    
    return [UIImage imageWithContentsOfFile:fullPathWithFile];
}

-(NSString*) overlayColor: (NSDictionary*) overlay
{
    NSString *color = [TiUtils stringValue:[overlay objectForKey:@"color"]];
    NSLog([NSString stringWithFormat:@"%@ %@", @"color:", color]);
    
    NSString* overLayColor = nil;
    if ([color caseInsensitiveCompare:@"blue"] == NSOrderedSame) {
        overLayColor = @"Blue";
    }
    else if ([color caseInsensitiveCompare:@"purple"] == NSOrderedSame) {
        overLayColor = @"Purple";
    }
    else if ([color caseInsensitiveCompare:@"red"] == NSOrderedSame) {
        overLayColor = @"Red";
    }
    else if ([color caseInsensitiveCompare:@"yellow"] == NSOrderedSame) {
        overLayColor = @"Yellow";
    }
    
    return overLayColor;
}

-(NSString*) overlayLayout: (NSDictionary*) overlay
{
    NSString *layout = [TiUtils stringValue:[overlay objectForKey:@"layout"]];
    NSLog([NSString stringWithFormat:@"%@ %@", @"layout:", layout]);
    
    NSString* overlayLayout = nil;
    if ([layout caseInsensitiveCompare:@"center"] == NSOrderedSame) {
        overlayLayout = @"Center";
    }
    else if ([layout caseInsensitiveCompare:@"full"] == NSOrderedSame) {
        overlayLayout = @"FullScreen";
    }
    
    return overlayLayout;
}

-(NSString*) overlayImageName: (NSDictionary*) overlay
{
    NSString *imageName = [TiUtils stringValue:[overlay objectForKey:@"imageName"]];
    NSLog([NSString stringWithFormat:@"%@ %@", @"imageName:", imageName]);
    
    return imageName;
}

-(float) overlayAlpha: (NSDictionary*) overlay
{
    float alpha = [TiUtils floatValue:[overlay objectForKey:@"alpha"] def:1.0f];
    NSLog([NSString stringWithFormat:@"%@ %f", @"alpha:", alpha]);
    
    return alpha;
}

- (id) setCallbacks: (NSDictionary*)args
{
    // callbacks
    if ([args objectForKey:@"success"] != nil)
    {
        NSLog(@"Received success callback");
        
        successCallback = [args objectForKey:@"success"];
        ENSURE_TYPE_OR_NIL(successCallback,KrollCallback);
        [successCallback retain];
    }
    
    if ([args objectForKey:@"error"] != nil) 
    {
        NSLog(@"Received error callback");
        
        errorCallback = [args objectForKey:@"error"];
        ENSURE_TYPE_OR_NIL(errorCallback,KrollCallback);
        [errorCallback retain];
    }
    
    if ([args objectForKey:@"cancel"] != nil) 
    {
        NSLog(@"Received cancel callback");
        
        cancelCallback = [args objectForKey:@"cancel"];
        ENSURE_TYPE_OR_NIL(cancelCallback,KrollCallback);
        [cancelCallback retain];
    } 
}

- (UIBarButtonItem*) flexSpace
{
    return [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
             target: nil
             action: nil]
            autorelease];
}

- (void) initControls: (ZBarReaderViewController*) readerView: (BOOL) showScanButton: (NSString *) scanButtonName
{    
    UIView *view = readerView.view;
    
    CGRect r = view.bounds;
    r.origin.y = r.size.height - 54;
    r.size.height = 54;
    controls = [[UIView alloc] initWithFrame: r];
    controls.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    [controls setAlpha:0.75f];
    controls.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleTopMargin;
    controls.backgroundColor = [UIColor blackColor];
    
    UIToolbar *toolbar = [UIToolbar new];
    toolbar.translucent = true;
    r.origin.y = 0;
    toolbar.frame = r;
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIBarButtonSystemItem button = 0;
    
    if(continuous)
    {
        button = UIBarButtonSystemItemDone;
    }
    else
    {
        button = UIBarButtonSystemItemCancel;
    }
    
    NSMutableArray *toolBarItems = [[NSMutableArray alloc] init];
    [toolBarItems addObject:[[[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem: button
                              target: self
                              action: @selector(cancel)]
                             autorelease]];
    [toolBarItems addObject:[self flexSpace]];
    if(showScanButton)
    {
        [toolBarItems addObject:[[[UIBarButtonItem alloc]
                                  initWithTitle: scanButtonName
                                  style: UIBarButtonItemStyleDone
                                  target: self
                                  action: @selector(scan)]
                                 autorelease]];
        
        [toolBarItems addObject:[self flexSpace]];
    }
    
    if (userControlLight) 
    {
        lightSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [lightSwitch addTarget:self action:@selector(toggleLight) forControlEvents:UIControlEventValueChanged];
        
        [toolBarItems addObject:[[[UIBarButtonItem alloc]
                                  initWithCustomView:lightSwitch]
                                 autorelease]];
    }
    
    toolbar.items = toolBarItems;
    [controls addSubview: toolbar];
    [toolbar release];
    
    [view addSubview: controls];
}

- (void) turnLightOff
{
    if([reader isKindOfClass:[ZBarReaderController class]])
    {
        reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff; 
    }
    else
    {
        reader.readerView.torchMode = AVCaptureTorchModeOff;
    }
}

- (void) turnLightOn
{
    if([reader isKindOfClass:[ZBarReaderController class]])
    {
        reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn; 
    }
    else
    {
        reader.readerView.torchMode = AVCaptureTorchModeOn;
    }
}

- (void) toggleLight
{
    if(lightSwitch == nil)
        return;
    
    if(lightSwitch.on)
    {
        [self turnLightOn];        
    }
    else
    {
        [self turnLightOff];
    }
}

- (void) scan
{
    reader.view.userInteractionEnabled = NO;
    [reader takePicture];
}

- (void) cancel
{
    SEL cb = @selector(imagePickerControllerDidCancel:);
    if([self respondsToSelector: cb])
        [self imagePickerControllerDidCancel: (UIImagePickerController*)reader];
    else
    {
        [UIApplication sharedApplication].statusBarHidden = NO; 
        [NSThread sleepForTimeInterval:0.1f];
        [reader dismissModalViewControllerAnimated: YES];
    }
    
    [controls release];
    controls = nil;
}

-(void)initScanner: (NSDictionary*) args: (NSString*) readerController: (ZBarReaderControllerCameraMode) cameraMode: (UIImagePickerControllerSourceType) sourceType: (BOOL) useOverlay: (UIImagePickerControllerCameraDevice) cameraDeviceToUse
{
    // init reader
    [self initReader: readerController];
    
    // Only enable Scanning of specified Barcodes    
    for (int k = 0, l = (sizeof symbolValues); l > k; k++) {
        [reader.scanner setSymbology: symbolValues[k]
                              config: ZBAR_CFG_ENABLE
                                  to: false];
    }
    
    NSArray* barcodes = nil;
    
    if([args objectForKey:@"barcodes"] != nil) 
    {
        NSLog(@"barcodes != nil");
        barcodes = [args objectForKey:@"barcodes"];
    
        NSLog([NSString stringWithFormat:@"barcodes: %@", barcodes]);
        for(NSString * barcode in barcodes)
        {
            if(barcode != nil)
            {
                if([barcodeDict objectForKey:[barcode uppercaseString]] != nil)
                {
                    NSLog([NSString stringWithFormat:@"Barcode type: %@", barcode]);
                    [reader.scanner setSymbology:[[barcodeDict objectForKey:[barcode uppercaseString]] intValue] config:ZBAR_CFG_ENABLE to:true];
                }
                else
                {
                    NSLog([NSString stringWithFormat:@"Unknown barcode type: %@", barcode]);
                }            
            }
            else
            {
                NSLog([NSString stringWithFormat:@"barcode is nil"]);
            }
        }        
    }
    else
    {
        for (int k = 0, l = (sizeof allSymbols); l > k; k++) {
            [reader.scanner setSymbology: allSymbols[k]
                                  config: ZBAR_CFG_ENABLE
                                      to: true];
        } 
    }    
    
    //sourceType
    reader.sourceType = sourceType;
    
    //cameraMode
    reader.cameraMode = cameraMode;
    
    //cameraDevice
    if(cameraDeviceToUse != 0)
    {
        reader.cameraDevice = cameraDeviceToUse;
    }
    
    if ([reader isKindOfClass:[ZBarReaderViewController class]]) 
    {
        if(allowZoom)
        {
            reader.readerView.allowsPinchZoom = true;
        }
        else
        {
            reader.readerView.allowsPinchZoom = false;
        }
    }
    
    if(userControlLight)
    {
        // Default the light to off
        [self turnLightOff];
    }
    
    if(useOverlay)
    {
        if ([args objectForKey:@"overlay"] != nil) {
            NSDictionary* overlay = [args objectForKey:@"overlay"];
            NSLog(@"overlay");
            
            NSString* color = [self overlayColor:overlay];
            NSString* layout = [self overlayLayout:overlay];
            
            NSString* overlayImageName = nil;
            
            if(color != nil && layout != nil)
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
                {
                    overlayImageName = [NSString stringWithFormat:@"Center-%@-ipad.png", color];
                }
                else
                {
                    overlayImageName = [NSString stringWithFormat:@"%@-%@.png", layout, color];
                }
            }
            
            NSString* imageName = [self overlayImageName:overlay];
            if(imageName != nil)
            {
                overlayImageName = [NSString stringWithString:imageName];
            }
            
            if(overlayImageName != nil)
            {
                // Add Image overlay
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageNamed:overlayImageName]];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.alpha = [self overlayAlpha:overlay];
                
                reader.cameraOverlayView = imageView;
            }
        }
    }
    
    
    [reader setTracksSymbols: NO];
    [reader setShowsHelpOnFail: NO];
    
    // callbacks
    [self setCallbacks:args];
}

-(void) show
{
    // show
    TiApp* tiApp = [TiApp app];
    [tiApp showModalController:reader animated:YES];
}

// ZBarReaderDelegate Methods

- (void) imagePickerController: (UIImagePickerController*) imagePickerController
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    NSLog(@"imagePickerController (Successful Scan):");
    
    // get the results of image scan
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    int quality = 0;
    ZBarSymbol *symbol = nil;
    for(ZBarSymbol *sym in results)
    {
        NSLog([NSString stringWithFormat:@"%@ %d", @"Quality of Scan (Higher than 0 is good):", sym.quality]);
        if(sym.quality > quality)
        {
            symbol = sym;
        }
    }
    
    // Callback for success
    if (successCallback != nil)
    {
        id listener = [[successCallback retain] autorelease];
        
        // Populate Callback data
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:symbol.data forKey:@"data"];
        [dictionary setObject:symbol.typeName forKey:@"type"];             
        [self _fireEventToListener:@"success" withObject:dictionary listener:listener thisObject:nil];  
    }
    
    // Don't close the scanner if continuous is true
    if(!continuous)
    {
        [UIApplication sharedApplication].statusBarHidden = NO; 
        [NSThread sleepForTimeInterval:0.1f];
        [reader dismissModalViewControllerAnimated: YES];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) imagePickerController
{
    NSLog(@"imagePickerControllerDidCancel:");
    
    if (cancelCallback != nil){
        id listener = [[cancelCallback retain] autorelease];
        
        // No data with Cancel
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [self _fireEventToListener:@"cancel" withObject:dictionary listener:listener thisObject:nil];   
    }
    
    [UIApplication sharedApplication].statusBarHidden = NO; 
    [NSThread sleepForTimeInterval:0.1f];
    [reader dismissModalViewControllerAnimated: YES];
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) readerController
                             withRetry: (BOOL) retry
{
    NSLog([NSString stringWithFormat:@"readerControllerDidFailToRead: withRetry=%d", retry]);
    
    if (errorCallback != nil)
    {
        id listener = [[errorCallback retain] autorelease];
        
        // No data with error
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [self _fireEventToListener:@"error" withObject:dictionary listener:listener thisObject:nil];    
    }
    
    // Don't close the scanner if continuous is true
    if(!continuous)
    {
        [UIApplication sharedApplication].statusBarHidden = NO; 
        [NSThread sleepForTimeInterval:0.1f];
        [reader dismissModalViewControllerAnimated: YES];
    }
}

- (void) continuous: (id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    if ([args objectForKey:@"continuous"] != nil) 
    {
        [self setContinuous:[TiUtils boolValue:[args objectForKey:@"continuous"]]];
        NSLog([NSString stringWithFormat:@"continuous: %d", continuous]);
    }
    else
    {
        [self setContinuous:false];
    }
}

- (void) userControlLight: (id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    if ([args objectForKey:@"userControlLight"] != nil) 
    {
        [self setUserControlLight:[TiUtils boolValue:[args objectForKey:@"userControlLight"]]];
        NSLog([NSString stringWithFormat:@"userControlLight: %d", userControlLight]);
    }
    else
    {
        [self setUserControlLight:false];
    }
}

- (void) allowZoom: (id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    if ([args objectForKey:@"allowZoom"] != nil) 
    {
        [self setAllowZoom:[TiUtils boolValue:[args objectForKey:@"allowZoom"]]];
        NSLog([NSString stringWithFormat:@"allowZoom: %d", allowZoom]);
    }
    else
    {
        [self setAllowZoom:true];
    }
}

- (void) useFrontCamera: (id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    if ([args objectForKey:@"useFrontCamera"] != nil)
    {
        if([TiUtils boolValue:[args objectForKey:@"useFrontCamera"]])
        {
            [self setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        }
        else
        {
            [self setCameraDevice:UIImagePickerControllerCameraDeviceRear];
        }
    }
    else
    {
        [self setCameraDevice:UIImagePickerControllerCameraDeviceRear];
    }
    
    NSLog([NSString stringWithFormat:@"cameraDevice: %d", cameraDevice]);
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    [self setContinuous:false];
    [self setUserControlLight:false];
    [self setAllowZoom:true];
    barcodeDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithInt: ZBAR_EAN2], @"EAN2",
                   [NSNumber numberWithInt: ZBAR_EAN5], @"EAN5",
                   [NSNumber numberWithInt: ZBAR_EAN8], @"EAN8",
                   [NSNumber numberWithInt: ZBAR_UPCE], @"UPCE",
                   [NSNumber numberWithInt: ZBAR_ISBN10], @"ISBN10",
                   [NSNumber numberWithInt: ZBAR_UPCA], @"UPCA",
                   [NSNumber numberWithInt: ZBAR_EAN13], @"EAN13",
                   [NSNumber numberWithInt: ZBAR_ISBN13], @"ISBN13",
                   [NSNumber numberWithInt: ZBAR_COMPOSITE], @"COMPOSITE",
                   [NSNumber numberWithInt: ZBAR_I25], @"I25",
                   [NSNumber numberWithInt: ZBAR_DATABAR], @"DATABAR",
                   [NSNumber numberWithInt: ZBAR_DATABAR_EXP], @"DATABAR_EXP",
                   [NSNumber numberWithInt: ZBAR_CODE39], @"CODE39",
                   [NSNumber numberWithInt: ZBAR_PDF417], @"PDF417",
                   [NSNumber numberWithInt: ZBAR_CODE93], @"CODE93",
                   [NSNumber numberWithInt: ZBAR_CODE128], @"CODE128",
                   [NSNumber numberWithInt: ZBAR_CODABAR], @"CODABAR",
                   nil];
    allBarcodes = [NSArray arrayWithObjects:
                   @"EAN2",
                   @"EAN5",
                   @"EAN8",
                   @"UPCE",
                   @"ISBN10",
                   @"UPCA",
                   @"EAN13",
                   @"ISBN13",
                   @"COMPOSITE",
                   @"I25",
                   @"DATABAR",
                   @"DATABAR_EXP",
                   @"CODE39",
                   @"PDF417",
                   @"CODE93",
                   @"CODE128",
                   @"CODABAR",
                   nil];
    
	
	NSLog(@"[INFO] %@ loaded",self);
    NSLog([NSString stringWithFormat:@"barcodes: %@", allBarcodes]);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
    [barcodeDict autorelease];
    [allBarcodes autorelease];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

-(void)scanBarcodeFromCamera:(id)args
{
    NSLog(@"scanBarcodeFromCamera");
    ENSURE_UI_THREAD(scanBarcodeFromCamera, args);
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString* readerController = @"ZBarReaderViewController";
    ZBarReaderControllerCameraMode cameraMode = ZBarReaderControllerCameraModeSampling;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    BOOL useOverlay = true;
    
    [self continuous:args];
    [self userControlLight:args];
    [self allowZoom:args];
    [self useFrontCamera:args];
    [self initScanner:args :readerController :cameraMode :sourceType :useOverlay :cameraDevice];
    
    // Use custom controls
    reader.showsZBarControls = NO;
    [self initControls:reader :false :nil];
    
    [self show];
}

/**
 May remove support for this feature.  Using image capture (user manually pressing the button when the barcode is in focus)
 seems to be unreliable.  Keeping the function here but not document it.
 */
-(void)scanBarcodeFromImageCapture:(id)args
{
    NSLog(@"scanBarcodeFromImageCapture");
    ENSURE_UI_THREAD(scanBarcodeFromImageCapture, args);
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString* readerController = @"ZBarReaderController";
    ZBarReaderControllerCameraMode cameraMode = ZBarReaderControllerCameraModeDefault;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    BOOL useOverlay = false;
    NSString* scanButtonName = @"Scan";
    
    if ([args objectForKey:@"scanButtonName"] != nil) 
    {
        NSString* name = [args objectForKey:@"scanButtonName"];
        NSLog([NSString stringWithFormat:@"scanButtonName: %@", name]);
        
        scanButtonName = [NSString stringWithString:name];
    }
    
    [self continuous:args];
    [self userControlLight:args];
    [self useFrontCamera:args];
    [self initScanner:args :readerController :cameraMode :sourceType :useOverlay :cameraDevice];
    
    reader.showsZBarControls = NO;
    reader.showsCameraControls = NO;
    [self initControls:reader :true :scanButtonName];
    
    
    [self show];
}

-(void)scanBarcodeFromAlbum: (id)args
{
    NSLog(@"scanBarcodeFromAlbum");
    ENSURE_UI_THREAD(scanBarcodeFromAlbum, args);
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString* readerController = @"ZBarReaderController";
    ZBarReaderControllerCameraMode cameraMode = ZBarReaderControllerCameraModeDefault;;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    BOOL useOverlay = false;
    
    [self continuous:args];
    [self initScanner:args :readerController :cameraMode :sourceType :useOverlay :0];
    [self setProxy:nil];
    [self setNavBarButton:nil];
    
    if([args objectForKey:@"view"] != nil)
    {
        [self setProxy:(TiViewProxy*)[args objectForKey:@"view"]];
    }
    else if([args objectForKey:@"navBarButton"] != nil)
    {
        UIBarButtonItem* button = ((TiUIButtonProxy *)[args objectForKey:@"navBarButton"]).barButtonItem;
        [self setNavBarButton:button];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self.popover isPopoverVisible])
        {
            NSLog(@"Popover already exist and is being displayed.");
            return;
        }

        [self setPopover:[[UIPopoverController alloc] initWithContentViewController:reader]];
        
        if(self.navBarButton != nil)
        {
            [self.popover presentPopoverFromBarButtonItem:navBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else if(self.proxy != nil)
        {
            [self.popover presentPopoverFromRect:self.proxy.view.frame inView:self.proxy.parent.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            NSLog(@"You must specify a \"view\" or \"navBarButton\" on an iPad when calling the scanBarcodeFromAlbum.");
        }
    }
    else
    {
        [self show];
    }

}
@end
