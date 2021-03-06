//
//  ZoneTableViewController.m
//  Family_ipad
//
//  Created by walt.chan on 12-12-30.
//  Copyright (c) 2012年 walt.chan. All rights reserved.
//

#import "ZoneTableViewController.h"
#import "HeaderView.h"
#import "AppDelegate.h"
#import "StackScrollViewController.h"
#import "RootViewController.h"
#import "ZoneCell.h"
#import "ZoneWaterFallView.h"
#import "KGModal.h"
#import "PostBaseView.h"
#import "UIActionSheet+BlocksKit.h"
#import "WaterFallViewController.h"
#import "UIView+BlocksKit.h"
#import "AddChildViewController.h"
#import "PostBaseViewController.h"  
#import "CKMacros.h"
#import "DDAlertPrompt.h"
#import "UIAlertView+BlocksKit.h"
@interface ZoneTableViewController ()

@end

@implementation ZoneTableViewController
- (void)sendRequest:(id)sender
{
    NSString *requestStr;
    if (!_userId) 
        requestStr = $str(@"%@space.php?m_auth=%@&page=%d",BASE_URL,GET_M_AUTH,currentPage);
    else
        requestStr = $str(@"%@space.php?m_auth=%@&page=%d&uid=%@",BASE_URL,GET_M_AUTH,currentPage,_userId);

    [[MyHttpClient sharedInstance] commandWithPath:requestStr
                                      onCompletion:^(NSDictionary *dict) {
                                          [self stopLoading:sender];
                                          if (needRemoveObjects == YES) {
                                              [dataArray removeAllObjects];
                                              [_tableView reloadData];
                                              needRemoveObjects = NO;
                                          }
                                          NSArray *resultArr = [[dict objectForKey:WEB_DATA] objectForKey:PESONAL_SPACE_LIST];
                                          
                                          [dataArray addObjectsFromArray:resultArr];
                                          [_tableView reloadData];
                                          
                                      }
                                           failure:^(NSError *error) {
                                               [self stopLoading:sender];
                                               currentPage--;
                                           }];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isFromPost = NO;
        _parent = nil;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super init]) {
		[self.view setFrame:frame];
	}
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    header.headerTitle.text = @"空间";
    header.headerLogo.userInteractionEnabled = YES;
//    [header.headerLogo whenTapped:^{
//        AddChildViewController  *detailViewController = [[AddChildViewController alloc] initWithNibName:@"AddChildViewController" bundle:nil];
//        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:detailViewController invokeByController:self isStackStartView:FALSE];
//    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskLandscape;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}   
#pragma mark -
#pragma mark Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_userId) 
        return [dataArray count]+1;
    else
        return [dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell;
    static NSString *CellIdentifier = @"ZoneCellId";
    static NSString *newCellIdentifier = @"newzone";
    if (indexPath.row ==dataArray.count) 
        cell=(ZoneCell *)[tableView dequeueReusableCellWithIdentifier:newCellIdentifier];
    else
        cell = (ZoneCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        if (indexPath.row ==dataArray.count) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ZoneCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        }
        else{
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        

    }
    
    // Configure the cell...
	if ([dataArray count]>0&&indexPath.row != dataArray.count) {
        [cell setCellData:[dataArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    HeaderView *header = [[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:nil options:nil]objectAtIndex:0];
//    return header;
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 76.0f;
//}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == dataArray.count) {
        DDAlertPrompt *alertPrompt = [[DDAlertPrompt alloc] initWithTitle:@"新建空间" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:nil];
        __block DDAlertPrompt *blockAlert = alertPrompt;
        [alertPrompt addButtonWithTitle:@"确认" handler:^{
            [SVProgressHUD showWithStatus:@"请稍等"];
            NSString *url = $str(@"%@tag", POST_CP_API);
            NSMutableDictionary *para = [NSMutableDictionary dictionaryWithObjectsAndKeys:blockAlert.theTextView.text, TAG_NAME, ONE, TAG_SUBMIT, POST_M_AUTH, M_AUTH, nil];
            [[MyHttpClient sharedInstance] commandWithPathAndParamsAndNoHUD:url params:para addData:^(id<AFMultipartFormData> formData) {
            } onCompletion:^(NSDictionary *dict) {
                if ([[dict objectForKey:WEB_ERROR] intValue] != 0) {
                    [SVProgressHUD showErrorWithStatus:[dict objectForKey:WEB_MSG]];
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"空间创建成功"];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"网络不好T_T"];
            }];
        }];
        [alertPrompt show];
        return;
    }
    ZoneCell *cell = (ZoneCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (_isFromPost&&_parent) {
        [_parent.zoneBtn setTitle:cell.nameLabel.text forState:UIControlStateNormal];
        _parent.zoneBtn.tag = [cell.tagID intValue];
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    NSDictionary *celldict = [dataArray objectAtIndex:indexPath.row];
    if([[celldict objectForKey:PHOTO_NUM]isEqualToString:ZERO]&&[[celldict objectForKey:BLOG_NUM]isEqualToString:ZERO]){
        if (_userId) {
            [SVProgressHUD showSuccessWithStatus:@"空间还没有相片呢"];
            return;
        }

        UIActionSheet *ac =[[UIActionSheet alloc]initWithTitle:@"空间还没有相片呢"];
        [ac addButtonWithTitle:@"发一张照片" handler:^{
            REMOVEDETAIL;
            PostBaseViewController *con = [[PostBaseViewController alloc]initWithNibName:@"PostBaseViewController" bundle:nil];
            [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:con invokeByController:self isStackStartView:FALSE];
            [con.postView.zoneBtn setTitle:$safe([celldict objectForKey:TAG_NAME]) forState:UIControlStateNormal];
            [con.postView initPostView:nil];

        }];
        [ac showInView:[AppDelegate instance].rootViewController.view];
        
    }
    else{
        ZoneWaterFallView *view = [[ZoneWaterFallView alloc]initWithFrame:CGRectMake(0, 0, 1024-100, 768)];
        view.tagID = cell.tagID;
        view.contentType = ZONE_TYPE;
        view.userid = _userId;
        [view refreshTable:$int(ZONE_TYPE)];
        [[KGModal sharedInstance] showWithContentView:view andAnimated:YES];
    }
    
    
}
@end
