//
//  HLImagePickerController.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLImagePickerController.h"
#import "HLImageManager.h"
#import "HLAlbumPickerController.h"
#import "HLPhotoPickerController.h"
#import "HLPhotoPreviewController.h"

@interface HLImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLable;
    UIButton *_settingBtn;
    BOOL _pushToPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLable;
    
    UIStatusBarStyle _originStatusBarStyle;
}

@property (nonatomic, assign) NSInteger columnNumber;

@end

@implementation HLImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [HLImageManager manager].shouldFixOrientation = NO;
    
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HLImagePickerController class]]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[HLImagePickerController class], nil];
#pragma clang diagnostic pop
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<HLImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HLImagePickerControllerDelegate>)delegate {
    HLAlbumPickerController *albumPickerVc = [[HLAlbumPickerController alloc] init];
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.photoPreviewMaxWidth = 600;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.barItemTextFont = [UIFont systemFontOfSize:15];
        self.barItemTextColor = [UIColor whiteColor];
        self.columnNumber = columnNumber;
        [self configDefaultImageName];
        
        if (![[HLImageManager manager] authorizationStatusAuthorized]) {
            _tipLable = [[UILabel alloc] init];
            _tipLable.frame = CGRectMake(8, 120, self.view.width - 16, 60);
            _tipLable.textAlignment = NSTextAlignmentCenter;
            _tipLable.numberOfLines = 0;
            _tipLable.font = [UIFont systemFontOfSize:16];
            _tipLable.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:@"设置提示"];
            _tipLable.text = tipText;
            [self.view addSubview:_tipLable];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:@"设置" forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        } else {
            [self pushToPhotoPickerVc];
        }
    }
    return self;
}

/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    
    __weak typeof(self) weakSelf = self;
    return [self initWithSelectedAssets:selectedAssets selectedPhotos:selectedPhotos index:index mode:HLPreViewTypeBrowse okCallback:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (weakSelf.didFinishPickingPhotosHandle) {
            weakSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
        }
    }];
}

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index mode:(HLPreViewType)mode okCallback:(void (^)(NSArray<UIImage *> *, NSArray *, BOOL))callback {
    HLPhotoPreviewController *previewVc = [[HLPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.maxImagesCount = selectedAssets.count;
        self.photoPreviewMaxWidth = 600;
        self.barItemTextFont = [UIFont systemFontOfSize:15];
        self.barItemTextColor = [UIColor whiteColor];
        [self configDefaultImageName];
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        previewVc.preViewMode = mode;
        __weak typeof(self) weakSelf = self;
        
        [previewVc setOkButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if (callback) {
                callback(photos,assets,isSelectOriginalPhoto);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return self;
}

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index mode:(HLPreViewType)mode okCallback:(void (^)(NSArray<UIImage *> *, NSArray *, BOOL))callback syncLoadImage:(void(^)(NSString* url, void(^imageLoadCallback)(UIImage* image)))syncLoadImage {
    HLPhotoPreviewController *previewVc = [[HLPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        self.timeout = 15;
        self.photoWidth = 828.0;
        self.maxImagesCount = selectedAssets.count;
        self.photoPreviewMaxWidth = 600;
        self.barItemTextFont = [UIFont systemFontOfSize:15];
        self.barItemTextColor = [UIColor whiteColor];
        [self configDefaultImageName];
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        previewVc.preViewMode = mode;
        previewVc.syncLoadImage = syncLoadImage;
        __weak typeof(self) weakSelf = self;
        
        [previewVc setOkButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if (callback) {
                callback(photos,assets,isSelectOriginalPhoto);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return self;
}

- (void)observeAuthrizationStatusChange {
    if ([[HLImageManager manager] authorizationStatusAuthorized]) {
        [self pushToPhotoPickerVc];
        [_tipLable removeFromSuperview];
        [_settingBtn removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture.png";
    self.photoSelImageName = @"photo_sel_photoPickerVc.png";
    self.photoDefImageName = @"photo_def_photoPickerVc.png";
    self.photoNumberIconImageName = @"photo_number_icon.png";
    self.photoPreviewOriginDefImageName = @"preview_original_def.png";
    self.photoOriginDefImageName = @"photo_original_def.png";
    self.photoOriginSelImageName = @"photo_original_sel.png";
}

- (void)pushToPhotoPickerVc {
    _pushToPhotoPickerVc = YES;
    if (_pushToPhotoPickerVc) {
        HLPhotoPickerController *photoPickerVc = [[HLPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        [[HLImageManager manager] cameraRollAlbum:^(HLAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            _pushToPhotoPickerVc = NO;
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
#pragma clang diagnostic pop
    }
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((self.view.width - 120) / 2, (self.view.height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = @"正在处理...";
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}


- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    HLAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [HLImageManager manager].columnNumber = _columnNumber;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [HLImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    for (id asset in selectedAssets) {
        HLAssetModel *model = [HLAssetModel modelWithAsset:asset type:HLAssetModelMediaTypePhoto];
        model.isSelected = YES;
        [_selectedModels addObject:model];
    }
}

- (void)settingBtnClick {
    if (iOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) { [_timer invalidate]; _timer = nil;}
    
    if (self.childViewControllers.count > 0) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 50, 44)];
        [backButton setImage:[UIImage imageNamedFromServiceBundle:@"navi_back.png"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        backButtonItem.style = UIBarButtonItemStyleBordered;
#pragma clang diagnostic pop
        self.topViewController.navigationItem.backBarButtonItem = backButtonItem;
        
        /**
         另外一种只有箭头的返回键
         UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
         self.topViewController.navigationItem.backBarButtonItem = backItem;
         */
    }
    [super pushViewController:viewController animated:animated];
}

@end
