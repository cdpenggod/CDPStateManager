//
//  CDPStateManagerNotificationPool.m
//  stateManager
//
//  Created by CDP on 2021/7/10.
//

#import "CDPStateManagerNotificationPool.h"

@interface CDPStateManagerNotificationPool ()

@property (nonatomic, strong) NSMutableDictionary *stateDic; //各监听通知所对应的状态

@end

@implementation CDPStateManagerNotificationPool

//获取 notificationName 通知已绑定的 同步状态池
- (NSArray *)getAllStateIdentifierWithNotificationName:(NSNotificationName)notificationName {
    if (![notificationName isKindOfClass:[NSString class]]) {
        notificationName = @"";
    }
    NSArray *arr = [self.stateDic objectForKey:notificationName];
    return (arr && [arr isKindOfClass:[NSArray class]])? arr : @[];
}
//添加要同步的 状态 到 notificationName 通知对应的 同步状态池，进行绑定
- (void)addSyncStateIdentifier:(NSString *)identifier forNotificationName:(NSNotificationName)notificationName {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        [notificationName isKindOfClass:[NSString class]] &&
        notificationName.length > 0) {
        //获取对应状态池
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self getAllStateIdentifierWithNotificationName:notificationName]];
        //判断是否已包含该状态
        if (![arr containsObject:identifier]) {
            [arr addObject:identifier];
            [self.stateDic setObject:arr forKey:notificationName];
        }
    }
}
//从 notificationName 通知对应的 同步状态池 里移除要同步的 状态，解除绑定
- (void)removeSyncStateIdentifier:(NSString *)identifier forNotificationName:(NSNotificationName)notificationName {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        [notificationName isKindOfClass:[NSString class]] &&
        notificationName.length > 0) {
        //获取对应状态池
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self getAllStateIdentifierWithNotificationName:notificationName]];
        //判断是否已包含该状态
        if ([arr containsObject:identifier]) {
            [arr removeObject:identifier];
            
            if (arr.count == 0) {
                [self.stateDic removeObjectForKey:notificationName];
            } else {
                [self.stateDic setObject:arr forKey:notificationName];
            }
        }
    }
}
#pragma mark - getter
- (NSMutableDictionary *)stateDic {
    if (_stateDic == nil) {
        _stateDic = [NSMutableDictionary new];
    }
    return _stateDic;
}
- (NSMutableArray *)listenNotificationArr {
    if (_listenNotificationArr == nil) {
        _listenNotificationArr = [NSMutableArray new];
    }
    return _listenNotificationArr;
}

@end
