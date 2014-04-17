//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.3
//-------------------


#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Documents Ornder abfragen
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    
    markerArray = [[NSArray alloc]init];
    
    [self createLogFile];
	   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createLogFile
{

    //Zeitstempel abfragen
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH_mm_ss__ddMMyy"];
    NSString* str = [formatter stringFromDate:date];
    
    NSString *logFilename = [NSString stringWithFormat:@"%@.txt", str];
    
    //Log Datei
    logFile = [documentsDirectory stringByAppendingPathComponent:logFilename];
    
    [[NSFileManager defaultManager] createFileAtPath:logFile contents:[NSData data] attributes:nil];
    
    //erste Zeile schreiben
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logFile];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[[NSString stringWithFormat:@"TranslationX;TranslationY;TranslationZ;RotationX;RotationY;RotationZ,CameraResolution;Time\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    
}

-(IBAction)newLog:(id)sender
{
    [self createLogFile];
}



-(void)initTracking
{
	
	// load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml" inDirectory:@"Assets"];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}


	
}


#pragma mark - Logging

-(void)logging

{

    //TrackingValues Abfragen
        metaio::TrackingValues currentTrackingValues = m_metaioSDK->getTrackingValues(1);

            //Translation  und Rotation abfragen
            metaio::Vector3d markerTranslation = currentTrackingValues.translation;
            metaio::Vector3d markerRotation = currentTrackingValues.rotation.getEulerAngleDegrees();
    
            //Werte in GUI schreiben
            [transX setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.x]];
            [transY setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.y]];
            [transZ setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.z]];
    
            [rotX setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.x]];
            [rotY setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.y]];
            [rotZ setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.z]];
    
            if (currentTrackingValues.quality>0)
                [label setBackgroundColor:[UIColor greenColor]];
            else
                [label setBackgroundColor:[UIColor redColor]];
    
    
            //Log schreiben
            if ([logSwitch isOn ] && (currentTrackingValues.quality>0))
            {
                
                NSDate *date = [[NSDate alloc] init];
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH_mm_ss__ddMMyy"];
                NSString* logDate = [formatter stringFromDate:date];
                
                NSString* camResuSegValue = [camResuSeg titleForSegmentAtIndex:camResuSeg.selectedSegmentIndex];
                

                
                
                NSString *markerPose = [NSString stringWithFormat:@"%1.3f;%1.3f;%1.3f;%1.3f;%1.3f;%1.3f;%@;%@\r\n", markerTranslation.x, markerTranslation.y, markerTranslation.z, markerRotation.x, markerRotation.y, markerRotation.z, camResuSegValue, logDate];
                
                // Schreiben
                NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logFile];
                [handle truncateFileAtOffset:[handle seekToEndOfFile]];
                [handle writeData:[markerPose dataUsingEncoding:NSUTF8StringEncoding]];
                
                
                //screenshot erstellen
                [self takeScreenshot:logDate];
                 
                //logswitch nach einem druchlauf deaktivieren
                logSwitch.on = false;
            }
    
}

-(void)takeScreenshot: (NSString*)logDate
{

	
	NSString *screenShotFilename = [NSString stringWithFormat:@"%@.jpg",logDate];;
	
	m_metaioSDK->requestScreenshot([[documentsDirectory stringByAppendingPathComponent:screenShotFilename] UTF8String],glView->defaultFramebuffer, glView->colorRenderbuffer);

}

- (IBAction)changeCamResu:(id)sender
{
    int resX;
    int resY;
    
    UISegmentedControl *segControl = sender;
    
    
    if (segControl.selectedSegmentIndex == 0)
    {
        resX = 320;
        resY = 240;
    }
    else if (segControl.selectedSegmentIndex == 1)
    {
        resX = 640;
        resY = 480;
    }
    else if (segControl.selectedSegmentIndex == 2)
    {
        resX = 1280;
        resY = 720;
    }
    else if (segControl.selectedSegmentIndex == 3)
    {
        resX = 1920;
        resY = 1080;
    }
    
    
    
    
    
    if( m_metaioSDK )
    {
        //m_metaioSDK->stopCamera();
        
		std::vector<metaio::Camera> cameras = m_metaioSDK->getCameraList();
		if(cameras.size()>0)
		{
            cameras[0].resolution.x = resX;
            cameras[0].resolution.y = resY;
            
            
			m_metaioSDK->startCamera(cameras[0]);
		} else {
			NSLog(@"No Camera Found");
		}

        
    }
    
}



#pragma mark - @protocol metaioSDKDelegate

- (void) drawFrame
{
    [super drawFrame];
    
    [self logging];
    

}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
	
	[self initTracking];
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    NSLog(@"animation ended %@", animationName);
}


- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName
{
	NSLog(@"movie ended %@", movieName);
	
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    NSLog(@"a new camera frame image is saved to %@", filepath);
}

-(void) onScreenshotImage:(metaio::ImageStruct *)image
{
    
    NSLog(@"screenshot image is received %f", image->timestamp);
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot image is received %@", [image description]);
}

-(void) onScreenshot:(NSString *)filepath
{
    NSLog(@"screenshot is saved to %@", filepath);
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    if (success)
    {
        NSLog(@"Instant 3D tracking is successful");
    }
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    if (success)
    {
        NSLog(@"Visual search is successful");
    }
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    if (state == metaio::EVSS_SERVER_COMMUNICATION)
    {
        NSLog(@"Visual search is currently communicating with the server");
    }
}


@end
