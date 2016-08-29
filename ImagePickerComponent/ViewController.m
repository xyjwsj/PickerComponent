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

@interface ViewController ()<HLImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    
    [button setTitle:@"打开" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button.center = self.view.center;
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
