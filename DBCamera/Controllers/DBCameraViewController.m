//
//  DBCameraViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraViewController.h"
#import "DBCameraManager.h"
#import "DBCameraView.h"
#import "DBCameraGridView.h"
#import "DBCameraDelegate.h"
#import "DBCameraSegueViewController.h"
#import "DBCameraLibraryViewController.h"
#import "DBLibraryManager.h"
#import "DBMotionManager.h"
#import "DBNoContentViewController.h"

#import "UIImage+Crop.h"
#import "DBCameraMacros.h"
#import "UIImage+Resizing.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define DBCameraLocalizedStrings(key, comment) [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DBCameraBundle" ofType:@"bundle"]] localizedStringForKey:(key) value:@"" table:@"DBCamera"]


@interface DBCameraViewController () <DBCameraManagerDelegate, DBCameraViewDelegate,DBNoContentViewControllerDelegate> {
    BOOL _processingPhoto;
    UIDeviceOrientation _deviceOrientation;
    BOOL wasStatusBarHidden;
    BOOL wasWantsFullScreenLayout;
}

@property (nonatomic, strong) DBNoContentViewController *cameraAccessDeniedController;

@property (nonatomic, strong) id customCamera;
@end

@implementation DBCameraViewController
@synthesize cameraGridView = _cameraGridView;
@synthesize forceQuadCrop = _forceQuadCrop;
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;
@synthesize cameraSegueConfigureBlock = _cameraSegueConfigureBlock;
@synthesize cameraManager = _cameraManager;

#pragma mark - Life cycle

+ (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate cameraView:nil];
}

+ (instancetype) init
{
    return [[self alloc] initWithDelegate:nil cameraView:nil];
}

- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraView:(id)camera
{
    self = [super init];

    if ( self ) {
        _processingPhoto = NO;
        _deviceOrientation = UIDeviceOrientationPortrait;
        if ( delegate )
            _delegate = delegate;

        if ( camera )
            [self setCustomCamera:camera];

        [self setUseCameraSegue:YES];

        [self setTintColor:[UIColor whiteColor]];
        [self setSelectedTintColor:[UIColor cyanColor]];
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:[UIColor blackColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

    NSError *error;
    if ( [self.cameraManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error] ) {
        if ( self.customCamera ) {
            if ( [self.customCamera respondsToSelector:@selector(previewLayer)] ) {
                [(AVCaptureVideoPreviewLayer *)[self.customCamera valueForKey:@"previewLayer"] setSession:self.cameraManager.captureSession];

                if ( [self.customCamera respondsToSelector:@selector(delegate)] )
                    [self.customCamera setValue:self forKey:@"delegate"];
            }

            [self.view addSubview:self.customCamera];
        } else
            [self.view addSubview:self.cameraView];
    }

    DBCameraView *camera =_customCamera ?: _cameraView;
    [camera insertSubview:self.cameraGridView belowSubview:camera.topContainerBar];
    
    self.cameraAccessDeniedController = [[DBNoContentViewController alloc] init];
    self.cameraAccessDeniedController.view.tintColor = [UIColor whiteColor];
    self.cameraAccessDeniedController.messageTitle = @"Cannot access Camera!";
    self.cameraAccessDeniedController.messageDescription = DBCameraLocalizedStrings(@"cameraimage.nopolicy",nil);
    self.cameraAccessDeniedController.image = [[UIImage imageNamed:@"trigger"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cameraAccessDeniedController.buttonTitle = @"GO TO SETTINGS";
    self.cameraAccessDeniedController.delegate = self;
    
    [self addChildViewController:self.cameraAccessDeniedController];
    [camera insertSubview:self.cameraAccessDeniedController.view belowSubview:camera.topContainerBar];
    [self.cameraAccessDeniedController didMoveToParentViewController:self];
    self.cameraAccessDeniedController.view.frame = camera.bounds;
    
    if ( [camera respondsToSelector:@selector(cameraButton)] ) {
        [(DBCameraView *)camera cameraButton].enabled = [self.cameraManager hasMultipleCameras];
        [self.cameraManager hasMultipleCameras];
    }

    [self refreshCameraAccessUI];
}

-(void)refreshCameraAccessUI
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        self.cameraAccessDeniedController.view.hidden = NO;
        
        DBCameraView *camera =_customCamera ?: _cameraView;

        camera.triggerButton.enabled = NO;
        camera.gridButton.enabled = NO;
        camera.cameraButton.enabled = NO;
        camera.flashButton.enabled = NO;

        [camera.triggerButton setBackgroundColor:[camera.tintColor colorWithAlphaComponent:0.5]];
        
        for (UIGestureRecognizer *gesture in camera.gestureRecognizers)
        {
            gesture.enabled = NO;
        }

        //This is for custom cameras only
        [camera.closeButton.superview bringSubviewToFront:camera.closeButton];
        
    } else {
        self.cameraAccessDeniedController.view.hidden = YES;
    }
}

- (void)noContentViewControllerDidTapOnButton:(DBNoContentViewController *)noContentViewController
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.cameraManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
    
    __weak typeof(self) weakSelf = self;
    [[DBMotionManager sharedManager] setMotionRotationHandler:^(UIDeviceOrientation orientation){
        [weakSelf rotationChanged:orientation];
    }];
    [[DBMotionManager sharedManager] startMotionHandler];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( !self.customCamera )
        [self checkForLibraryImage];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _cameraManager = nil;
}

- (void) checkForLibraryImage
{
    if ( !self.cameraView.photoLibraryButton.isHidden && [self.parentViewController.class isSubclassOfClass:NSClassFromString(@"DBCameraContainerViewController")] ) {
        if ( [ALAssetsLibrary authorizationStatus] !=  ALAuthorizationStatusDenied ) {
            __weak DBCameraView *weakCamera = self.cameraView;
            [[DBLibraryManager sharedInstance] loadLastItemWithBlock:^(BOOL success, UIImage *image) {
                [weakCamera.photoLibraryButton setBackgroundImage:image forState:UIControlStateNormal];
            }];
        }
    } else
        [self.cameraView.photoLibraryButton setHidden:YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) dismissCamera
{
    if ( _delegate && [_delegate respondsToSelector:@selector(dismissCamera:)] )
        [_delegate dismissCamera:self];
}

- (CGSize)maxImageSize
{
    if(CGSizeEqualToSize(_maxImageSize, CGSizeZero))
        _maxImageSize = _forceQuadCrop ? CGSizeMake(960, 960) : CGSizeMake(960, 1280);
    return _maxImageSize;
}

- (DBCameraView *) cameraView
{
    if ( !_cameraView ) {
        _cameraView = [DBCameraView initWithCaptureSession:self.cameraManager.captureSession];
        [_cameraView setTintColor:self.tintColor];
        [_cameraView setSelectedTintColor:self.selectedTintColor];
        [_cameraView defaultInterface];
        [_cameraView setDelegate:self];
    }

    return _cameraView;
}

- (DBCameraManager *) cameraManager
{
    if ( !_cameraManager ) {
        _cameraManager = [[DBCameraManager alloc] init];
        [_cameraManager setDelegate:self];
    }

    return _cameraManager;
}

- (DBCameraGridView *) cameraGridView
{
    if ( !_cameraGridView ) {
        DBCameraView *camera =_customCamera ?: _cameraView;
        _cameraGridView = [[DBCameraGridView alloc] initWithFrame:camera.previewLayer.frame];
        [_cameraGridView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_cameraGridView setNumberOfColumns:2];
        [_cameraGridView setNumberOfRows:2];
        [_cameraGridView setAlpha:0];
    }

    return _cameraGridView;
}

- (void) setCameraGridView:(DBCameraGridView *)cameraGridView
{
    _cameraGridView = cameraGridView;
    __block DBCameraGridView *blockGridView = cameraGridView;
    __weak DBCameraView *camera =_customCamera ?: _cameraView;
    [camera.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[DBCameraGridView class]] ) {
            [obj removeFromSuperview];
            [camera insertSubview:blockGridView atIndex:1];
            blockGridView = nil;
            *stop = YES;
        }
    }];
}

- (void)setForceQuadCrop:(BOOL)forceQuadCrop
{
    _forceQuadCrop = forceQuadCrop;

    //For getting the max image size....
    if(CGSizeEqualToSize(_maxImageSize, CGSizeZero))
        _maxImageSize = _forceQuadCrop ? CGSizeMake(960, 960) : CGSizeMake(960, 1280);
}

- (void) rotationChanged:(UIDeviceOrientation) orientation
{
    if ( orientation != UIDeviceOrientationUnknown ||
         orientation != UIDeviceOrientationFaceUp ||
         orientation != UIDeviceOrientationFaceDown ) {
        _deviceOrientation = orientation;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    DBCameraView *camera = _customCamera ?: _cameraView;
    camera.frame = CGRectMake(0, 0, size.width, size.height);
    camera.previewLayer.frame = CGRectMake(0, 0, size.width, size.height);
}

+ (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation {
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
    return videoOrientation;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    AVCaptureVideoOrientation videoOrientation = [[self class] interfaceOrientationToVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    DBCameraView *camera = _customCamera ?: _cameraView;
    if (camera.previewLayer.connection.supportsVideoOrientation
        && camera.previewLayer.connection.videoOrientation != videoOrientation) {
        camera.previewLayer.connection.videoOrientation = videoOrientation;
    }
}

- (void) disPlayGridViewToCameraView:(BOOL)show
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cameraGridView.alpha = (show ? 1.0 : 0.0);
    } completion:NULL];
}

#pragma mark - CameraManagerDelagate

- (void) closeCamera
{
    [self dismissCamera];
}

- (void) switchCamera
{
    if ( [self.cameraManager hasMultipleCameras] )
        [self.cameraManager cameraToggle];
}

- (void) cameraView:(UIView *)camera showGridView:(BOOL)show {
    [self disPlayGridViewToCameraView:!show];
}

- (void) triggerFlashForMode:(AVCaptureFlashMode)flashMode
{
    if ( [self.cameraManager hasFlash] )
        [self.cameraManager setFlashMode:flashMode];
}

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    _processingPhoto = NO;

    NSMutableDictionary *finalMetadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
    finalMetadata[@"DBCameraSource"] = @"Camera";
    
    if ( !self.useCameraSegue ) {
        if ( [_delegate respondsToSelector:@selector(camera:didFinishWithImage:withMetadata:)] )
        {
            //For resizing the image to a given size....
            image = [image scaleToFitSize:self.maxImageSize];

            [_delegate camera:self didFinishWithImage:image withMetadata:finalMetadata];
        }
    } else {
        CGFloat newW = 256.0;
        CGFloat newH = 256.0;

        if ( image.size.width > image.size.height ) {
            newW = 340.0;
        }
        
        //This will calculate the height accordingly...
        newH = ( newW * image.size.height ) / image.size.width;

        if ( image.size.height > 0 && image.size.width > 0 && newH > 0 && newW > 0)
        {
            DBCameraSegueViewController *segue = [[DBCameraSegueViewController alloc] initWithImage:image thumb:[image scaleToFitSize:(CGSize){ newW, newH }]];
            [segue setTintColor:self.tintColor];
            [segue setSelectedTintColor:self.selectedTintColor];
            [segue setForceQuadCrop:_forceQuadCrop];
            [segue enableGestures:YES];
            [segue setDelegate:self.delegate];
            [segue setCapturedImageMetadata:finalMetadata];
            [segue setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];
            [segue setMaxImageSize:self.maxImageSize];

            [self.navigationController pushViewController:segue animated:YES];
        }
        else
        {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error loading the image. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void) captureImageFailedWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (void) captureSessionDidStartRunning
{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {

        id camera = self.customCamera ?: _cameraView;
        CGRect bounds = [(UIView *)camera bounds];
        CGPoint screenCenter = (CGPoint){ CGRectGetMidX(bounds), CGRectGetMidY(bounds) };
        if ([camera respondsToSelector:@selector(drawFocusBoxAtPointOfInterest:andRemove:)] )
            [camera drawFocusBoxAtPointOfInterest:screenCenter andRemove:NO];
        if ( [camera respondsToSelector:@selector(drawExposeBoxAtPointOfInterest:andRemove:)] )
            [camera drawExposeBoxAtPointOfInterest:screenCenter andRemove:NO];
    }
}

- (void) openLibrary
{
    [UIView animateWithDuration:.3 animations:^{
        [self.view setAlpha:0];
        [self.view setTransform:CGAffineTransformMakeScale(.8, .8)];
    } completion:^(BOOL finished) {
        DBCameraLibraryViewController *library = [[DBCameraLibraryViewController alloc] initWithDelegate:self.containerDelegate];
        [library setTintColor:self.tintColor];
        [library setSelectedTintColor:self.selectedTintColor];
        [library setForceQuadCrop:_forceQuadCrop];
        [library setDelegate:self.delegate];
        [library setUseCameraSegue:self.useCameraSegue];
        [library setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];
        [library setLibraryMaxImageSize:self.libraryMaxImageSize];
        [library setMaxImageSize:self.maxImageSize];
        [self.containerDelegate switchFromController:self toController:library];
    }];
}

#pragma mark - CameraViewDelegate

- (void) cameraViewStartRecording
{
    if ( _processingPhoto )
        return;

    _processingPhoto = YES;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
        
        return;
    }

    [self.cameraManager captureImageForDeviceOrientation:_deviceOrientation];
}

- (void) cameraView:(UIView *)camera focusAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isFocusPointOfInterestSupported ) {
        [self.cameraManager focusAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                              coordinates:point
                                                                                    layer:[(DBCameraView *)camera previewLayer]]];
    }
}

- (BOOL) cameraViewHasFocus
{
    return self.cameraManager.hasFocus;
}

- (void) cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isExposurePointOfInterestSupported ) {
        [self.cameraManager exposureAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                                 coordinates:point
                                                                                       layer:[(DBCameraView *)camera previewLayer]]];
    }
}

- (CGFloat) cameraMaxScale
{
    return [self.cameraManager cameraMaxScale];
}

- (void) cameraCaptureScale:(CGFloat)scaleNum
{
    [self.cameraManager setCameraMaxScale:scaleNum];
}

#pragma mark - UIApplicationDidEnterBackgroundNotification

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    id modalViewController = self.presentingViewController;
    if ( modalViewController )
        [self dismissCamera];
}

@end
