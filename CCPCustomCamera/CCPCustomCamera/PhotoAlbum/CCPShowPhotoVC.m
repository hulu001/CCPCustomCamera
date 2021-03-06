//
//  CCPShowPhotoVC.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoVC.h"
#import "CCPShowPhotoCollectionViewCell.h"
#import "UIView+XLExtension.h"
#import "XLPhotoBrowser.h"
#import "CCPPhotoAlbumViewController.h"
//间距
#define CCP_Margin 3.0f
//每排显示的个数
#define CCP_count 3
//屏幕宽度
#define CCPScreenW  [UIScreen mainScreen].bounds.size.width

@interface CCPShowPhotoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic,strong) UICollectionView *showCollectionView;

//选中的图片数组
@property (nonatomic,strong) NSMutableArray *selectedImageArray;
//占位数组
@property (nonatomic,strong) NSMutableArray *dataImageArray;

@property (nonatomic,weak) UIButton *previewBtn;

@end

@implementation CCPShowPhotoVC

- (UICollectionView *)showCollectionView {
    
    if (_showCollectionView==nil) {
        // 流水布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = CCP_Margin;
        flowLayout.minimumInteritemSpacing = CCP_Margin;
        CGFloat w = (CCPScreenW - (CCP_count -1) * CCP_Margin) / CCP_count;
        flowLayout.itemSize = CGSizeMake(w,w);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _showCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,44, self.view.frame.size.width, self.view.frame.size.height - 44) collectionViewLayout:flowLayout];
        _showCollectionView.backgroundColor = [UIColor whiteColor];
        [_showCollectionView registerClass:[CCPShowPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    }
    
    return _showCollectionView;
}

- (NSMutableArray *)dataImageArray {
    
    if (_dataImageArray == nil) {
        
        _dataImageArray = [NSMutableArray array];
        
        for (int i = 0; i < self.imageArray.count; i ++) {
            
            [_dataImageArray addObject:@""];
        }
    }
    
    return _dataImageArray;
}

- (NSMutableArray *)selectedImageArray {
    
    if (_selectedImageArray == nil) {
        
        _selectedImageArray = [NSMutableArray array];
        
    }
    
    return _selectedImageArray;
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    
    _imageArray = imageArray;
    
    [self.showCollectionView reloadData];
    
}
- (void)setFetchResult:(PHFetchResult *)fetchResult {
    
    _fetchResult = fetchResult;
    
    __weak typeof(self) weakSelf = self;
    
    for (PHAsset * asset in fetchResult){
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
         {
            
             [weakSelf.imageArray addObject:result];
             
             [weakSelf.showCollectionView reloadData];
             
         }];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self makeUI];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    CCPShowPhotoCollectionViewCell * collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    if (self.imageArray.count > 0) {
        
        collectionCell.showImage = self.imageArray[indexPath.row];
        collectionCell.btnTag = indexPath.row;
        collectionCell.selectedBtnBlock = ^(NSInteger btnTag) {
            
            NSLog(@"---++++---%ld",btnTag);
            
            //        [weakSelf.dataImageArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%ld",btnTag]];
            [weakSelf.dataImageArray replaceObjectAtIndex:indexPath.row withObject:weakSelf.imageArray[btnTag]];
            
            NSLog(@"---++++---%@",weakSelf.dataImageArray);
            
            [weakSelf.selectedImageArray removeAllObjects];
            
            for (id obj in weakSelf.dataImageArray) {
                
                if (![obj isEqual: @""]) {
                    UIImage *objImage = (UIImage *)obj;
                    [weakSelf.selectedImageArray addObject:objImage];
                    
                }
                
                if (weakSelf.selectedImageArray.count == 0) {
                    
                    weakSelf.previewBtn.enabled = NO;
                } else {
                    weakSelf.previewBtn.enabled = YES;
                    
                }
            }
        };
        collectionCell.unselectedBtnBlock = ^(NSInteger btnTag) {
            
            NSLog(@"***********%ld",btnTag);
            
            [weakSelf.dataImageArray replaceObjectAtIndex:indexPath.row withObject:@""];
            
            NSLog(@"***********%@",weakSelf.dataImageArray);
            
            [weakSelf.selectedImageArray removeAllObjects];
            
            for (id obj in weakSelf.dataImageArray) {
                
                if (![obj isEqual: @""]) {
                    
                    UIImage *objImage = (UIImage *)obj;
                    
                    [weakSelf.selectedImageArray addObject:objImage];
                }
                
                if (weakSelf.selectedImageArray.count == 0) {
                    
                    weakSelf.previewBtn.enabled = NO;
                } else {
                    weakSelf.previewBtn.enabled = YES;
                }
            }
        };
    }
    
    return collectionCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
      XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.self.imageArray currentImageIndex:indexPath.row];
    browser.browserStyle = XLPhotoBrowserStylePageControl;
    
}

#pragma mark -UI布局
- (void) makeUI {
    
    [self.view addSubview:self.showCollectionView];
    if (!self.isIOS8) {
     NSMutableArray *imageArray = [NSMutableArray array];
     self.imageArray = imageArray;
    }
    self.showCollectionView.delegate = self;
    self.showCollectionView.dataSource = self;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    headView.backgroundColor = [UIColor blackColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 50, 44)];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(clickTheBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    UIButton *previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(CCPScreenW - 65, 0, 50, 44)];
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTintColor:[UIColor whiteColor]];
    previewBtn.enabled = NO;
    [previewBtn addTarget:self action:@selector(clickThepreviewBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:previewBtn];
    self.previewBtn = previewBtn;
    [self.view addSubview:headView];
}

- (void) clickThepreviewBtn {
    
    NSLog(@"()()()____________()()()%@",self.selectedImageArray);
    
    // 快速创建并进入浏览模式
// [XLPhotoBrowser showPhotoBrowserWithImages:self.selectedImageArray currentImageIndex:self.selectedImageArray.count - 1];
    
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.self.selectedImageArray currentImageIndex:0];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
    [browser setActionSheetWithTitle:nil delegate:self cancelButtonTitle:@"取消" deleteButtonTitle:nil otherButtonTitles:@"保存图片",nil];
    
}

- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    switch (actionSheetindex) {
        case 0: // 保存
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
            [browser saveCurrentShowImage];
        }
            break;
        default:
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
        }
            break;
    }
}




- (void) clickTheBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
