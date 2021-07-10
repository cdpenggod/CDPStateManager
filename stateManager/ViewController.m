//
//  ViewController.m
//  stateManager
//
//  Created by CDP on 2021/7/10.
//

#import "ViewController.h"

#import "OtherViewController.h"

#import "CDPStateManager.h" //引入.h

#define Tip @"点击左侧按钮，进入不同vc，用不同方式去改变状态，然后返回到此VC，显示状态同步结果:"

#define StateName @"follow" //要监听同步的状态

@interface ViewController () <CDPStateManagerProtocol> //遵守protocol

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建UI
    [self createUI];
    
    //注册action (可以写在 AppDelegate 初始化 或 调用action前的其他地方，写一次就行)
    [[CDPStateManager defaultManager] registerActionWithStateIdentifier:StateName completion:^NSDictionary * _Nullable(NSDictionary * _Nullable parameters) {
        NSLog(@"收到 对应action 改变状态请求，开始根据 传参 判断是否改变并同步");
        
        NSString *theID = [parameters objectForKey:@"id"];
        NSString *type = [parameters objectForKey:@"type"];
        NSDate *date = [NSDate date];
        //根据 传参 判断是否改变状态 并处理，并将 改变的状态相关数据 返回同步给其他监听该状态的控件
        //假设此状态有两种情况：@"first" : @"other"
        return @{@"changeID": theID,
                 @"changeToType": ([type isEqualToString:@"1"])? @"first" : @"other",
                 @"changeTime": [NSString stringWithFormat:@"%@", date]};
    }];
    
    //将状态与通知绑定 (状态与通知 为 多对多,一个状态可绑定多个通知，一个通知也可同步多个状态)
    //可以写在 AppDelegate 初始化 或 调用action前的其他地方，写一次就行
    //如果该状态没有通过 notification 通知管理的情况，则不用绑定，此处只是demo演示
    [[CDPStateManager defaultManager] syncNotificationName:@"stateNotificationName" toStateIdentifier:StateName handle:^NSDictionary * _Nullable(NSNotification * _Nonnull notification) {
        NSLog(@"收到 state通知 改变状态请求，开始根据 notification 判断是否改变并同步");
        
        NSDictionary *dic = notification.object;
        NSString *theID = [dic objectForKey:@"id"];
        NSString *type = [dic objectForKey:@"type"];
        NSDate *date = [NSDate date];
        
        return @{@"changeID": theID,
                 @"changeToType": ([type isEqualToString:@"1"])? @"first" : @"other",
                 @"changeTime": [NSString stringWithFormat:@"%@", date]};
    }];
    [[CDPStateManager defaultManager] syncNotificationName:UIApplicationDidEnterBackgroundNotification toStateIdentifier:StateName handle:^NSDictionary * _Nullable(NSNotification * _Nonnull notification) {
        NSLog(@"收到 进入后台通知 改变状态请求，开始根据 notification 判断是否改变并同步");
        
        NSDate *date = [NSDate date];
        return @{@"name": @"did enter background",
                 @"haveBack": @"1",
                 @"time": [NSString stringWithFormat:@"%@", date]};
    }];
    
    //添加进状态管理池
    [[CDPStateManager defaultManager] addObject:self stateIdentifier:StateName];
}
//创建UI
- (void)createUI {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 200, 50)];
    button.adjustsImageWhenHighlighted = NO;
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:@"去改变状态" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(otherClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(30, 150, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height - 200)];
    self.textView.editable = NO;
    self.textView.text = Tip;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.textColor = [UIColor blackColor];
    [self.view addSubview:self.textView];
}
//点击进入其他vc
- (void)otherClick {
    [self presentViewController:[OtherViewController new] animated:YES completion:nil];
}
//更新text
- (void)updateText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n\n%@", Tip, text];
}
#pragma mark - CDPStateManagerProtocol 实现状态管理protocol
//收到 状态改变 回调，可进行改变后的逻辑处理
- (void)receiveStateActionWithDic:(NSDictionary *)dic
                       parameters:(NSDictionary *)parameters
                  stateIdentifier:(NSString *)identifier {
    NSLog(@"收到 action 同步回调");
    NSString *str = [NSString stringWithFormat:@"收到 action 同步回调\n\n收到改变的状态:\n%@\n\n此次改变状态时的传参:\n%@\n\n收到的同步dic:\n%@\n", identifier, parameters, dic];
    [self updateText:str];
}
//收到 通知 的同步回调，可进行对应逻辑处理
- (void)receiveStateNotificationSyncWithDic:(NSDictionary *)dic
                               notification:(NSNotification *)notification
                            stateIdentifier:(NSString *)identifier {
    NSLog(@"收到 通知 同步回调");
    NSString *str = [NSString stringWithFormat:@"收到 通知 同步回调\n\n收到改变的状态:\n%@\n\n此次改变状态时的通知:\n%@\n\n收到的同步dic:\n%@\n", identifier, notification, dic];
    [self updateText:str];
}


@end
