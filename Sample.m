//
//  ZPL_ViewController.m
//  iOS
//
//  Created by Sangok OH on 15. 07. 30.
//  Copyright 2015. All rights reserved.
//

int iInterface = -1;

#import "ZPL_ViewController.h"

@implementation ZPL_ViewController

@synthesize ipAddressField;
@synthesize portNumberField;

@synthesize openButton;
@synthesize closeButton;
@synthesize sample01_Button;
@synthesize sample02_Button;
@synthesize sample03_Button;
@synthesize sample04_Button;
@synthesize sample05_Button;
@synthesize sample06_Button;
@synthesize sample07_Button;
@synthesize mediaSegmented;

NSString * media_type;
int statusType = 0;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void) uiToggle:(UIButton*) uiObj mode:(BOOL) mode
{
	if(mode)
	{
		[uiObj setEnabled:TRUE];
		[uiObj setTitleColor:RGB(50,79,133) forState:UIControlStateNormal];
	}
	else
	{
		[uiObj setEnabled:FALSE];
		[uiObj setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];	
	}
}

- (void) setUIConnected:(BOOL) isConnected
{
    // if connected.
	if(isConnected)
	{
		[ipAddressField setEnabled:FALSE];
        [portNumberField setEnabled:FALSE];
        [self uiToggle:openButton mode:FALSE ];
		[self uiToggle:closeButton mode:TRUE];
        [mediaSegmented setEnabled:TRUE];
		[self uiToggle:sample01_Button mode:TRUE];
		[self uiToggle:sample02_Button mode:TRUE];
		[self uiToggle:sample03_Button mode:TRUE];
		[self uiToggle:sample04_Button mode:TRUE];
		[self uiToggle:sample05_Button mode:TRUE];
		[self uiToggle:sample06_Button mode:TRUE];
        [self uiToggle:sample07_Button mode:TRUE];
    }
	else
	{
		[ipAddressField setEnabled:TRUE];
        [portNumberField setEnabled:TRUE];
        [self uiToggle:openButton mode:TRUE];
		[self uiToggle:closeButton mode:FALSE];
        [mediaSegmented setEnabled:FALSE];
		[self uiToggle:sample01_Button mode:FALSE];
		[self uiToggle:sample02_Button mode:FALSE];
		[self uiToggle:sample03_Button mode:FALSE];
		[self uiToggle:sample04_Button mode:FALSE];
		[self uiToggle:sample05_Button mode:FALSE];
		[self uiToggle:sample06_Button mode:FALSE];
        [self uiToggle:sample07_Button mode:FALSE];
	}
}

- (void) messageBox:(NSString *) message withTitle:(NSString *) title
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
	[alert show];
	[alert release];
}

// Display the status of printer.
- (void) tcpStatusBox:(long) sts
{
    NSString * result = [[[NSString alloc] init] autorelease];
    sts = [zplPrinter status];
    if(sts == STS_ZPL_NORMAL)
    {
        switch(statusType)
        {
            case 0:
                [self messageBox:@"No errors" withTitle:@"Printer Status"];
                break;
            case 1:
                [self messageBox:@"Printing success" withTitle:@"Printer Status"];
                break;
        }
    } else {
        if((sts & STS_ZPL_BUSY) > 0)
        {
            result = [result stringByAppendingString:@"Printer Busy\r\n"];
        }
        if((sts & STS_ZPL_COVER_OPEN) > 0)
        {
            result = [result stringByAppendingString:@"Cover Open\r\n"];
        }
        if((sts & STS_ZPL_PAPER_EMPTY) > 0)
        {
            result = [result stringByAppendingString:@"Paper Empty\r\n"];
        }
        if((sts & STS_ZPL_BATTERY_LOW) > 0)
        {
            result = [result stringByAppendingString:@"Battery Low\r\n"];
        }
        [self messageBox:result withTitle:@"Printer Status"];
    }
}

- (IBAction)connectCommand:(id)sender 
{
    int portnum;
    NSString * ip = [ipAddressField text];
	NSLog(@"Connect call\r\n");
    long ret;

    portnum = [[portNumberField text] intValue];

    if(![ip isEqualToString:@"bluetooth"])
    { // tcpip
        iInterface = 1;
//        ret = [zplPrinter openPort:ip withPortParam:9100];
        ret = [zplPrinter openPort:ip withPortParam:portnum];
    } else { // bluetooth.
        iInterface = 0;
        ret = [zplPrinter openPort:@"bluetooth" withPortParam:0];
    }
    
#ifdef DEBUG
    NSLog(@"Connect BT Ret %d",ret);
#endif
    if(ret >= 0)
    {
        [self setUIConnected:TRUE];
        if(iInterface == 0)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusCheckReceived:) name:EADSessionDataReceivedNotification object:nil];
            [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        }
    }
    else
    {
        [self messageBox:@"Please check the device status or settings." withTitle:@"Connection Failed"];
    }
}

- (IBAction) disconnectCommand: (id) sender 
{
    [zplPrinter closePort];
	NSLog(@"Disconnect call\r\n");
	[self setUIConnected:FALSE];

    if(iInterface == 0)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    }
    iInterface = -1;
}

// Print device font
- (IBAction) printTextProc:(id) sender;
{
    
    [zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:480];
	[zplPrinter startPage];
	[zplPrinter setInternationalFont:0];
    
    [zplPrinter printString:@"^XA ^FO100,200 ^AD,50,25 ^FH_^FD Hello world _7E ^FS ^XZ"];

	[zplPrinter printText:ZPL_FONT_A withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:0 withData:@"FontA 0123"];
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:30 withData:@"FontB 0123"];
	[zplPrinter printText:ZPL_FONT_C withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:60 withData:@"FontC 0123"];
	[zplPrinter printText:ZPL_FONT_D withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:90 withData:@"FontD 0123"];
	[zplPrinter printText:ZPL_FONT_E withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:120 withData:@"FontE 0123"];
	[zplPrinter printText:ZPL_FONT_F withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:160 withData:@"FontF 0123"];
	[zplPrinter printText:ZPL_FONT_G withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:210 withData:@"FontG 01"];
	[zplPrinter printText:ZPL_FONT_H withOrientation:ZPL_ROTATION_0 withWidth:15 withHeight:12 withPrintX:0 withPrintY:300 withData:@"FontH 01234567"];

	[zplPrinter endPage:1];
    
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

// Print Geometry
- (IBAction) printGeometryProc:(id) sender
{
	[zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:300];
	[zplPrinter startPage];
	[zplPrinter setInternationalFont:0];

	[zplPrinter printCircle:40 withPrintY:40 withDiameter:70 withThickness:0 withLineColor:ZPL_LINE_COLOR_B];
	[zplPrinter printDiagonalLine:30 withPrintY:30 withWidth:100 withHeight:100 withThickness:7 withLineColor:ZPL_LINE_COLOR_B withDirection:ZPL_DIAGONAL_L];
    [zplPrinter printEllipse:10 withPrintY:10 withWidth:300 withHeight:200 withThickness:2 withLineColor:ZPL_LINE_COLOR_B];
	[zplPrinter printRectangle:120 withPrintY:10 withWidth:120 withHeight:80 withThickness:10 withLineColor:ZPL_LINE_COLOR_B withRounding:0];
	[zplPrinter printRectangle:120 withPrintY:100 withWidth:120 withHeight:80 withThickness:10 withLineColor:ZPL_LINE_COLOR_B withRounding:8];

	[zplPrinter endPage:1];
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

- (IBAction) barcode1DTestProc:(id) sender
{
	NSString * barData = @"123456789012";
	[zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:1600];
	[zplPrinter startPage];
	[zplPrinter setInternationalFont:0];

	[zplPrinter setBarcodeField:2 withRatio:@"3" withBarHeight:20];

	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:70 withData:@"Code11"];
	[zplPrinter printBarcode:ZPL_BCS_Code11 withBarcodeProp:NULL withPrintX:10 withPrintY:10 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:150 withData:@"Code128"];
	[zplPrinter printBarcode:ZPL_BCS_Code128 withBarcodeProp:NULL withPrintX:10 withPrintY:100 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:250 withData:@"Code39"];
	[zplPrinter printBarcode:ZPL_BCS_Code39 withBarcodeProp:NULL withPrintX:10 withPrintY:200 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:350 withData:@"Code93"];
	[zplPrinter printBarcode:ZPL_BCS_Code93 withBarcodeProp:NULL withPrintX:10 withPrintY:300 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:450 withData:@"EAN13"];
	[zplPrinter printBarcode:ZPL_BCS_EAN13 withBarcodeProp:NULL withPrintX:10 withPrintY:400 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:550 withData:@"EAN8"];
	[zplPrinter printBarcode:ZPL_BCS_EAN8 withBarcodeProp:NULL withPrintX:10 withPrintY:500 withData:@"12345"];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:650 withData:@"Industrial 2OF5"];
	[zplPrinter printBarcode:ZPL_BCS_Industrial_2OF5 withBarcodeProp:NULL withPrintX:10 withPrintY:600 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:750 withData:@"Interleaved 2OF5"];
	[zplPrinter printBarcode:ZPL_BCS_Interleaved_2OF5 withBarcodeProp:NULL withPrintX:10 withPrintY:700 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:850 withData:@"LOGMARS"];
	[zplPrinter printBarcode:ZPL_BCS_LOGMARS withBarcodeProp:NULL withPrintX:10 withPrintY:800 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:950 withData:@"MSI"];
	[zplPrinter printBarcode:ZPL_BCS_MSI withBarcodeProp:NULL withPrintX:10 withPrintY:900 withData:barData];
				
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1050 withData:@"PlanetCode"];
	[zplPrinter printBarcode:ZPL_BCS_PlanetCode withBarcodeProp:NULL withPrintX:10 withPrintY:1000 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1150 withData:@"Plessey"];
	[zplPrinter printBarcode:ZPL_BCS_Plessey withBarcodeProp:NULL withPrintX:10 withPrintY:1100 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1250 withData:@"POSTNET"];
	[zplPrinter printBarcode:ZPL_BCS_POSTNET withBarcodeProp:NULL withPrintX:10 withPrintY:1200 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1350 withData:@"Standard 2OF5"];
	[zplPrinter printBarcode:ZPL_BCS_Standard_2OF5 withBarcodeProp:NULL withPrintX:10 withPrintY:1300 withData:barData];
				
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1450 withData:@"UPCA"];
	[zplPrinter printBarcode:ZPL_BCS_UPCA withBarcodeProp:NULL withPrintX:10 withPrintY:1400 withData:barData];
		
	[zplPrinter printText:ZPL_FONT_B withOrientation:ZPL_ROTATION_0 withWidth:10 withHeight:10 withPrintX:0 withPrintY:1550 withData:@"UPCE"];
	[zplPrinter printBarcode:ZPL_BCS_UPCE withBarcodeProp:NULL withPrintX:10 withPrintY:1500 withData:barData];

	[zplPrinter endPage:1];
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

- (IBAction) ImageTestProc:(id) sender
{
	[zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:340];
	[zplPrinter startPage];
	[zplPrinter setInternationalFont:0];

	NSString * imgFile2 = [[NSBundle mainBundle] pathForResource:@"sample_2.jpg" ofType:nil];
	NSString * imgFile3 = [[NSBundle mainBundle] pathForResource:@"sample_3.jpg" ofType:nil];
	NSString * imgFile4 = [[NSBundle mainBundle] pathForResource:@"sample_4.jpg" ofType:nil];
	
	[zplPrinter printImage:imgFile2 withPrintX:1 withPrintY:200 withBrightness:5];
	[zplPrinter printImage:imgFile3 withPrintX:100 withPrintY:10 withBrightness:5];
	[zplPrinter printImage:imgFile4 withPrintX:120 withPrintY:245 withBrightness:5];

	[zplPrinter endPage:1];

    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

- (IBAction) barcode2DTestProc:(id) sender
{
	[zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:400];
	[zplPrinter startPage];
	[zplPrinter setInternationalFont:0];

	[zplPrinter printQRCODE:10 withPrintY:220 withOrientation:ZPL_ROTATION_0 withModel:2 withCellWidth:5 withData:@"MM,AAC-42"];
    [zplPrinter printPDF417:10 withPrintY:10 withOrientation:ZPL_ROTATION_0 withCellWidth:5 withSecurity:5 withNumOfRow:23 withTruncate:@"N" withData:@"PDF417-ABDFFEWGSERSHSRGRR"];
    [zplPrinter printDataMatrix:200 withPrintY:220 withOrientation:ZPL_ROTATION_0 withCellWidth:10 withQuality:ZPL_DM_QUALITY_200    withData:@"ABDFFEWGSERSHSRGRR"];

	[zplPrinter endPage:1];
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

- (IBAction) printPdfFileProc:(id) sender
{
    [zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:340];
    // [zplPrinter setupPrinter:ZPL_ROTATION_180 withmTrack:media_type withWidth:384 withHeight:1000];
    [zplPrinter startPage];
    [zplPrinter setInternationalFont:0];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PDF_Sample-2mm" ofType:@"pdf"];
    // [zplPrinter printPdfFile:path withPage:0 withPrintWidth:384]; // 2-inch print all pages
    // [zplPrinter printPdfFile:path withPage:0 withPrintWidth:576]; // 3-inch print all pages
    // [zplPrinter printPdfFile:path withPage:0 withPrintWidth:832]; // 4-inch print all pages
    [zplPrinter printPdfFile:path withPage:1 withPrintWidth:576]; // 3-inch print page 1

    // [zplPrinter printPdfFilePartial:path withStartPage:2 withEndPage:3 withPrintWidth:576]; // 3-inch print partial pages(2~3)
    
    [zplPrinter endPage:1];
    
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

// Check the status of printer
- (IBAction) statusTestProc:(id) sender
{
    statusType = 1;
    
    [zplPrinter printerCheck];
    if(iInterface == 1)
    {
        long sts = [zplPrinter status];
        [self tcpStatusBox:sts];
    }
}

-(void)segmentedChange: (UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0)
        media_type = ZPL_SENSE_GAP;
    else if(sender.selectedSegmentIndex == 1)
        media_type = ZPL_SENSE_BLACKMARK;
    else if(sender.selectedSegmentIndex == 2)
        media_type = ZPL_SENSE_CONTINUOUS;
}

- (void) statusCheckReceived:(NSNotification *) notification
{
    long bytesAvailable = 0;
    long readLength = 0;
    unsigned char buf[8] = {0,};
    EABluetoothPort * sessionController = (EABluetoothPort *)[notification object];
    NSString * result = [[NSString alloc] init];
#ifdef DEBUG
    NSLog(@"===== Status Check START =====");
#endif
    NSMutableData * readData = [[NSMutableData alloc] init];
    while((bytesAvailable = [sessionController readBytesAvailable]) > 0)
    {
        NSData * data = [sessionController readData:bytesAvailable];
        if(data)
        {
            [readData appendData:data];
            readLength = readLength + bytesAvailable;
        }
    }
    if(readLength > sizeof(buf))
        readLength = sizeof(buf);
    [readData getBytes:buf length:readLength];
    
    int sts = buf[readLength - 1];
    if(sts == STS_ZPL_NORMAL)
    {
        switch(statusType)
        {
            case 0:
                [self messageBox:@"No errors" withTitle:@"Printer Status"];
                break;
            case 1:
                [self messageBox:@"Printing success" withTitle:@"Printer Status"];
                break;
        }
    }
    else
    {
        if((sts & STS_ZPL_BUSY) > 0)
        {
            result = [result stringByAppendingString:@"Printer Busy\r\n"];
        }
        if((sts & STS_ZPL_COVER_OPEN) > 0)
        {
            result = [result stringByAppendingString:@"Cover Open\r\n"];
        }
        if((sts & STS_ZPL_PAPER_EMPTY) > 0)
        {
            result = [result stringByAppendingString:@"Paper Empty\r\n"];
        }
        if((sts & STS_ZPL_BATTERY_LOW) > 0)
        {
            result = [result stringByAppendingString:@"Battery Low\r\n"];
        }
        [self messageBox:result withTitle:@"Printer Status"];
    }
#ifdef DEBUG
    NSLog(@"===== Status Check EXIT =====");
#endif
}

// TextField input done. - hiding keyboard. 
- (IBAction) textFieldDoneEditing:(id) sender
{
    [sender resignFirstResponder];
}

- (IBAction) backgroundTab:(id) sender
{
//	NSLog(@"pressed");
	[ipAddressField resignFirstResponder];
}

/////////////////////////////////
// run once at App start.
- (void) viewDidLoad 
{
//    NSLog(@"viewDidLoad");

    [ipAddressField setText:@"bluetooth"];
//    [ipAddressField setText:@"192.168.1.246"];
    [portNumberField setText:@"9100"];
	zplPrinter = [[ZPLPrinter alloc] init];
	[self setUIConnected:FALSE];
    
    media_type = ZPL_SENSE_GAP;    //default type is Gap
    
    [mediaSegmented addTarget:self action:@selector(segmentedChange:) forControlEvents:UIControlEventValueChanged];

    // Register bluetooth notification about data input event
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusCheckReceived:) name:EADSessionDataReceivedNotification object:nil];
//    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}
////////////////////////////////

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
	[ipAddressField release];
    [portNumberField release];

    [openButton release];
	[closeButton release];
	[sample01_Button release];
	[sample02_Button release];
	[sample03_Button release];
	[sample04_Button release];
	[sample05_Button release];
	[sample06_Button release];

    [zplPrinter release];
    [super dealloc];
}

@end
