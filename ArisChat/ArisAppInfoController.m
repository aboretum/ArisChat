//
//  ArisAppInfoController.m
//  ArisChat
//
//  Created by Wuchen Wang on 9/18/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "ArisAppInfoController.h"
@interface ArisAppInfoController()

@property UITextView *aboutus;

@end

@implementation ArisAppInfoController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ArisHelper colorWithHexString:@"FBF6E9"];
    self.aboutus = [[UITextView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"AppInfo"
                                                     ofType:@"txt"];
    NSString *myText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.aboutus.text = myText;
    self.aboutus.backgroundColor = [ArisHelper colorWithHexString:@"FBF6E9"];
;
    [self.aboutus addGestureRecognizer: [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)]];
    [self.view addSubview:self.aboutus];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    NSLog(@"*** Pinch: Scale: %f Velocity: %f", gestureRecognizer.scale, gestureRecognizer.velocity);
    
    UIFont *font = self.aboutus.font;
    CGFloat pointSize = font.pointSize;
    NSString *fontName = font.fontName;
    
    pointSize = ((gestureRecognizer.velocity > 0) ? 1 : -1) * 1 + pointSize;
    
    if (pointSize < 13) pointSize = 13;
    if (pointSize > 42) pointSize = 42;
    
    self.aboutus.font = [UIFont fontWithName:fontName size:pointSize];
}


@end
