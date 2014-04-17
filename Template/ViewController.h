//
//  ViewController.h
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"

@interface ViewController : MetaioSDKViewController
{

    __weak IBOutlet UISwitch *logSwitch;
    
    NSArray *markerArray;
    
    NSString *logFile;
    
    NSString *documentsDirectory;
    
    __weak IBOutlet UITextField *transX;
    __weak IBOutlet UITextField *transY;
    __weak IBOutlet UITextField *transZ;
    
    __weak IBOutlet UITextField *rotX;
    __weak IBOutlet UITextField *rotY;
    __weak IBOutlet UITextField *rotZ;
    
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UISegmentedControl *camResuSeg;
    
}
- (IBAction)newLog:(id)sender;
- (IBAction)changeCamResu:(id)sender;

@end
