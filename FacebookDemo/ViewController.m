//
//  ViewController.m
//  FacebookDemo
//
//  Created by Jose Chen on 16/5/30.
//  Copyright © 2016年 Jose Chen. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <GPUImage/GPUImageVideoCamera.h>
#import <GPUImage/GPUImageView.h>
#import <GDLiveStreaming/GDLRawDataOutput.h>

#define FRONTROW_ROOT [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface ViewController ()

@property(nonatomic,strong) GPUImageVideoCamera *camera;
@property(nonatomic,strong) GPUImageView *imageView;
@property(nonatomic,strong) GDLRawDataOutput *output;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a custom login button to your app
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.backgroundColor=[UIColor darkGrayColor];
    myLoginButton.frame=CGRectMake(200,20,180,40);
    [myLoginButton setTitle: @"Login" forState: UIControlStateNormal];
    
    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Add the button to the view
    [self.view addSubview:myLoginButton];
    
    NSString *cachePath = [FRONTROW_ROOT stringByAppendingPathComponent:@"token"];
    FBSDKAccessToken *token = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if (token) {
        [FBSDKAccessToken setCurrentAccessToken:token];
    }
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 20, 180, 40)];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    loginButton.publishPermissions = @[@"publish_pages",@"publish_actions",@"manage_pages"];
    [self.view addSubview:loginButton];
    
    //@[@"public_profile", @"email", @"user_friends",@"user_religion_politics",@"user_about_me",@"user_videos",@"user_posts",@"user_actions.video",@"manage_pages",@"publish_pages",@"publish_actions",@"rsvp_event",]
    
    // Do any additional setup after loading the view, typically from a nib.
     FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    NSLog(@"accessToken =%@",accessToken);
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL
                          URLWithString:@"https://www.facebook.com/FacebookDevelopers"];
    FBSDKShareButton *shareButton = [[FBSDKShareButton alloc] initWithFrame:CGRectMake(120, 80, 80, 40)];
    shareButton.shareContent = content;
    [self.view addSubview:shareButton];
    
    // Add a custom login button to your app
    UIButton *friendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    friendButton.backgroundColor=[UIColor darkGrayColor];
    friendButton.frame=CGRectMake(220, 80, 120, 40);
    [friendButton setTitle: @"get friends" forState: UIControlStateNormal];
    [friendButton addTarget:self action:@selector(getFriends) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:friendButton];
    
    
    UIButton *postFeedButton=[UIButton buttonWithType:UIButtonTypeCustom];
    postFeedButton.backgroundColor=[UIColor darkGrayColor];
    postFeedButton.frame=CGRectMake(120, 140, 120, 40);
    [postFeedButton setTitle: @"post feed" forState: UIControlStateNormal];
    [postFeedButton addTarget:self action:@selector(postFeed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postFeedButton];

    UIButton *liveVideosButton=[UIButton buttonWithType:UIButtonTypeCustom];
    liveVideosButton.backgroundColor=[UIColor darkGrayColor];
    liveVideosButton.frame=CGRectMake(260, 140, 100, 40);
    [liveVideosButton setTitle: @"live video" forState: UIControlStateNormal];
    [liveVideosButton addTarget:self action:@selector(createLiveVideos) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:liveVideosButton];
    
    UIButton *customShareButton=[UIButton buttonWithType:UIButtonTypeCustom];
    customShareButton.backgroundColor=[UIColor darkGrayColor];
    customShareButton.frame=CGRectMake(120,200,180,40);
    [customShareButton setTitle: @"Share" forState: UIControlStateNormal];
    [customShareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customShareButton];
    
    
    FBSDKProfilePictureView *picView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 80, 100, 100)];
    [self.view addSubview:picView];
}

- (void)share
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
//    
//    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//    dialog.fromViewController = self;
//    dialog.shareContent = content;
//    dialog.mode = FBSDKShareDialogModeShareSheet;
//    [dialog show];
}

- (void)getFriends
{
    NSDictionary *parameters = @{
                                 @"fields": @"name",
                                 @"limit" : @"50"
                                 };
    // This will only return the list of friends who have this app installed
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends"
                                                                          parameters:parameters];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    [connection addRequest:friendsRequest
         completionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error) {
             if (error) {
                 NSLog(@"%@", error);
                 return;
             }
             if (result) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [alert show];
                 NSArray *data = result[@"data"];
                 NSLog(@"result = %@",result);
             }
         }];
      [connection start];
}

- (void)postFeed
{
    NSDictionary *parameters = @{
                                 @"message": @"Hello World!",
                                 };
    // This will only return the list of friends who have this app installed
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                                                          parameters:parameters
                                                                          HTTPMethod:@"POST"];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    [connection addRequest:friendsRequest
         completionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error) {
             if (error) {
                 NSLog(@"%@", error);
                 return;
             }
             if (result) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [alert show];
                 NSArray *data = result[@"data"];
                 NSLog(@"result = %@",result);
             }
         }];
    [connection start];
}

// Once the button is clicked, show the login dialog
-(void)loginButtonClicked
{
    NSLog(@"profile =%@",[FBSDKProfile currentProfile]);

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSString *cachePath = [FRONTROW_ROOT stringByAppendingPathComponent:@"token"];
              FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
             [NSKeyedArchiver archiveRootObject:accessToken toFile:cachePath];
             NSLog(@"Logged in");
         }
     }];
}

- (void)createLiveVideos
{
  //  NSDictionary *privacy = @{@"value":@"0"};
   // NSString* privacy = @"{'value': '0'}";
    NSDictionary *parameters = @{
                                 @"privacy": @"{'value': 'ALL_FRIENDS'}",
                               //  @"privacy":privacy,
                                 @"published": @"true",
                                 };
    // This will only return the list of friends who have this app installed
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/live_videos"
                                                                          parameters:parameters
                                                                          HTTPMethod:@"POST"];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    [connection addRequest:friendsRequest
         completionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error) {
             if (error) {
                 NSLog(@"%@", error);
                 return;
             }
             if (result) {
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                 [alert show];
//                 NSArray *data = result[@"data"];
                 NSString *streamUrl = [result objectForKey:@"stream_url"];
                 NSArray *array = [streamUrl componentsSeparatedByString:@"rtmp/"]; //从字符A中分隔成2个元素的数组
                 
                 NSString *host = [[array objectAtIndex:0] stringByAppendingString:@"rtmp"];
                 NSString *key = [array objectAtIndex:1];
              //   [self startCamera:host key:key];
                 
                 NSLog(@"result = %@",result);
             }
         }];
    [connection start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startCamera:(NSString*)url key:(NSString*)key
{
    //  1. 创建视频摄像头
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                                      cameraPosition:AVCaptureDevicePositionBack];
    //  2. 设置摄像头帧率
    self.camera.frameRate = 25;
    //  3. 设置摄像头输出视频的方向
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //  4.0 创建用于展示视频的GPUImageView
    self.imageView = [[GPUImageView alloc] init];
    self.imageView.frame = self.view.bounds;
    [self.view addSubview:self.imageView];
    
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    [closeButton setBackgroundColor:[UIColor purpleColor]];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(stopCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:closeButton];
    
    //  4.1 添加GPUImageView为摄像头的的输出目标
    [self.camera addTarget:self.imageView];
    //  5. 创建原始数据输出对象
    
    self.output = [[GDLRawDataOutput alloc] initWithVideoCamera:self.camera withImageSize:CGSizeMake(720, 1280)];
    
    //  6. 添加数据输出对象为摄像头输出目标
    [self.camera addTarget:self.output];
    
    //  7.开始捕获视频
    [self.camera startCameraCapture];
    
    //  8.开始上传视频
    [ self.output startUploadStreamWithURL:url andStreamKey:key];
}

- (void)stopCamera
{
    [self.output stopUploadStream];
    [self.camera stopCameraCapture];

    [self.imageView removeFromSuperview];
}

@end
