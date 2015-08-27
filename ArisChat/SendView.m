//
//  SendView.m
//  ArisChat
//
//  Created by Wuchen Wang on 6/28/15.
//  Copyright (c) 2015 Wuchen Wang. All rights reserved.
//

#import "SendView.h"
#import "ContentButton.h"
#import "Grid.h"


@interface SendView()
@property (nonatomic,strong)  NSArray *contentButtons;
@property (nonatomic,strong)  NSMutableArray *finishedButtons;


@end


@implementation SendView

const CGFloat CONTENT_ASPECT_RATIO = 1.0;
const int INITIAL_CONTENT_NUMBER = 4;


#pragma mark - Initialization

- (void)setup
{
    if(!self.contentButtons){
        self.contentButtons = [[NSUserDefaults standardUserDefaults] valueForKey:@"Image_Contents"];
        if(!self.contentButtons){
            self.contentButtons = @[@"eat",@"home",@"drink",@"work"];
        }
    }
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    Grid *grid = [[Grid alloc] init];
    grid.cellAspectRatio = CONTENT_ASPECT_RATIO;
    grid.size = self.frame.size;
    grid.minimumNumberOfCells = INITIAL_CONTENT_NUMBER;
    NSLog(@"%lu",(unsigned long)grid.rowCount);
    NSLog(@"%lu",(unsigned long)grid.columnCount);
    
    
 
    self.finishedButtons = [[NSMutableArray alloc]init];
    for (int i=0; i<grid.rowCount; i++){
        for(int j=0;j<grid.columnCount;j++){
            CGRect rect = [grid frameOfCellAtRow:i inColumn:j];
            
            UIButton *newButton = [[ContentButton alloc]initWithFrame:CGRectInset(rect, self.frame.size.width/4*0.06, self.frame.size.width/4*0.06)];
            [newButton addTarget:self.conversationViewController action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
            [self.finishedButtons addObject:newButton];
            [self addSubview:newButton];
        }
    }
    
    
    for (int i=0;i<self.contentButtons.count;i++){
        ContentButton *curButton = self.finishedButtons[i];
        [curButton setContent:self.contentButtons[i]];
    }
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
