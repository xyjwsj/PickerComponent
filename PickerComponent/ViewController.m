//
//  ViewController.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/27.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "ViewController.h"
#import "HLImageManager.h"
#import "HLImagePickerController.h"
#import "HLGridView.h"
#import "HLPhotoPreviewController.h"
#import "UICommonPickerViewController.h"

@interface ViewController ()<HLImagePickerControllerDelegate>
@property (nonatomic, retain) HLGridView * gridView;
@property (nonatomic, retain) UICommonPickerViewController *con;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    
    [button setTitle:@"图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button.center = self.view.center;
    button.y = 80;
    button.x = 30;

    UIButton* selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    
    [selectBtn setTitle:@"选择" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBtn];
    
    selectBtn.center = self.view.center;
    selectBtn.y = 80;
    selectBtn.x = 190;

    
    _gridView = [[HLGridView alloc] initWithFrame:CGRectMake(10, button.y + 50, SCREEN_WIDTH - 20, 100) columnNumber:3];
    
    _gridView.backgroundColor = [UIColor lightGrayColor];
    
    __block typeof(self) weakSelf = self;
    _gridView.singleTapGestureBlock = ^(NSInteger index, NSMutableArray* assets, NSArray<UIImage *> *photos) {
        HLImagePickerController* imagePickerController = [[HLImagePickerController alloc] initWithSelectedAssets:assets selectedPhotos:[NSMutableArray arrayWithArray:photos] index:index mode:HLPreViewTypeEdite okCallback:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto){
            weakSelf.gridView.assets = [NSMutableArray arrayWithArray:assets];
            weakSelf.gridView.photos = [NSMutableArray arrayWithArray:photos];
            
        }];
        
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
    };
    [self.view addSubview:_gridView];
    
    
}

- (void)selectClick {
    NSMutableDictionary* dicData = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSMutableArray* arr1 = [[NSMutableArray alloc] initWithObjects:@"一列1",@"一列2",@"一列3",@"一列4",@"一列5", nil];
    [dicData setObject:arr1 forKey:FIRST];
    if (!_con) {
        _con = [[UICommonPickerViewController alloc] initWithType:ARRAY_PICKER data:dicData];
    }
    [_con showInController:self pickerCallbakc:^(BOOL result, id data) {
        NSLog(@"选择了:%@", data);
    }];
}

- (void)click {
    NSLog(@"click button");
    [self pushImagePickerController];
    
//    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
//    //指定源类型前，检查图片源是否可用
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//    {
//        //指定源的类型
//        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        
//        //在选定图片之前，用户可以简单编辑要选的图片。包括上下移动改变图片的选取范围，用手捏合动作改变图片的大小等。
//        imagePicker.allowsEditing = YES;
//        
//        //实现委托，委托必须实现UIImagePickerControllerDelegate协议，来对用户在图片选取器中的动作
//        imagePicker.delegate = self;
//        
//        //设置完iamgePicker后，就可以启动了。用以下方法将图像选取器的视图“推”出来
////        [self.navigationController pushViewController:imagePicker animated:YES];
//        [self presentViewController:imagePicker animated:YES completion:nil];
//    }

}

- (void)pushImagePickerController {
   
    HLImagePickerController *imagePickerVc = [[HLImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        _gridView.assets = [NSMutableArray arrayWithArray:assets];
        _gridView.photos = [NSMutableArray arrayWithArray:photos];
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
