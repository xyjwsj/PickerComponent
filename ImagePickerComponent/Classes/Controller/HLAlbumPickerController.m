//
//  HLAlbumPickerController.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLAlbumPickerController.h"
#import "HLImagePickerController.h"
#import "HLImageManager.h"
#import "HLAlbumCell.h"
#import "HLPhotoPickerController.h"

@interface HLAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
}

@property (nonatomic, strong) NSMutableArray *albumArr;

@end

@implementation HLAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self configTableView];
}

- (void)configTableView {
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    [[HLImageManager manager] allAlbums:^(NSArray<HLAlbumModel *> *models) {
        _albumArr = [NSMutableArray arrayWithArray:models];
        for (HLAlbumModel *albumModel in _albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        if (!_tableView) {
            CGFloat top = 44;
            if (iOS7Later) top += 20;
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top) style:UITableViewStylePlain];
            _tableView.rowHeight = 70;
            _tableView.tableFooterView = [[UIView alloc] init];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            [_tableView registerClass:[HLAlbumCell class] forCellReuseIdentifier:@"HLAlbumCell"];
            [self.view addSubview:_tableView];
        } else {
            [_tableView reloadData];
        }
    }];
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

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLAlbumCell"];
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HLPhotoPickerController *photoPickerVc = [[HLPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    HLAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    __weak typeof(self) weakSelf = self;
    [photoPickerVc setBackButtonClickHandle:^(HLAlbumModel *model) {
        [weakSelf.albumArr replaceObjectAtIndex:indexPath.row withObject:model];
    }];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
