//
//  OtherViewController.m
//  stateManager
//
//  Created by Chai,Dongpeng on 2021/7/10.
//

#import "OtherViewController.h"

#import "CDPStateManager.h"

#define StateName @"follow" //要监听同步的状态

@interface OtherViewController ()

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, (i == 0)? 80 : 150, 200, 50)];
        button.adjustsImageWhenHighlighted = NO;
        button.backgroundColor = [UIColor blackColor];
        [button setTitle:(i == 0)? @"调用action 改变状态" : @"发送通知 改变状态" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:(i == 0)? @selector(actionClick) : @selector(notificationClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 220, 200, 50)];
    button.adjustsImageWhenHighlighted = NO;
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)actionClick {
    NSString *theID = [NSString stringWithFormat:@"%d", arc4random()%1000];
    NSString *type = [NSString stringWithFormat:@"%d", arc4random()%2];
    [[CDPStateManager defaultManager] actionWithParameters:@{@"id": theID, @"type": type} stateIdentifier:StateName];
}
- (void)notificationClick {
    NSString *theID = [NSString stringWithFormat:@"%d", 1000 + arc4random()%1000];
    NSString *type = [NSString stringWithFormat:@"%d", arc4random()%2];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateNotificationName" object:@{@"id": theID, @"type": type}];
}
- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
