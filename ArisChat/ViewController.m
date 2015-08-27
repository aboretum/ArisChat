#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@property (nonatomic,strong) UILabel *statusLabel;
@end

@implementation ViewController

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor=[UIColor whiteColor];
    UIImage *tail = [UIImage imageNamed:@"tail.png"];
    UIImage *img = [UIImage imageNamed:@"dog2.jpg"];
    UIImageView *imgHolder = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width, [self.view bounds].size.height)];
    UIImageView *tailHolder = [[UIImageView alloc] initWithFrame:CGRectMake([self.view bounds].size.width*0.09375,[self.view bounds].size.height*0.572916,[self.view bounds].size.width*0.766*0.3, [self.view bounds].size.height*0.427*0.2)];
    imgHolder.image = img;
    tailHolder.image = tail;
    [self.view addSubview:imgHolder];
    [self.view addSubview:tailHolder];
    tailHolder.layer.anchorPoint = CGPointMake(0,1);
   
    
    [self rotateImage:tailHolder duration:0.2 delay:0.8 curve:UIViewAnimationCurveLinear rotations:(M_1_PI)];
       
    
}

- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
              curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(rotations);
                         
                     }
                     completion:^(BOOL finished){
                         [self rotateImage2:image duration:duration delay:0 curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)rotateImage2:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
               curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(-rotations);
                     }
                     completion:^(BOOL finished){
                         [self rotateImage3:image duration:duration delay:delay curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)rotateImage3:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
              curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(rotations);
                         
                     }
                     completion:^(BOOL finished){
                         [self rotateImage4:image duration:duration delay:delay curve:curve rotations:rotations];
                         ;
                     }];
    [UIView commitAnimations];
    
}


- (void)rotateImage4:(UIImageView *)image duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
               curve:(int)curve rotations:(CGFloat)rotations
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         image.transform = CGAffineTransformMakeRotation(-rotations);
                     }
                     completion:^(BOOL finished){
                         
                         ;
                     }];
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
