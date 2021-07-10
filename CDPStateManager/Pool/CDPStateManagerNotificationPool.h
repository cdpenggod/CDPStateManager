//
//  CDPStateManagerNotificationPool.h
//  stateManager
//
//  Created by CDP on 2021/7/10.
//  notification 相关储存池

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDPStateManagerNotificationPool : NSObject

/// 记录当前 manager 正在监听的 notificationName (供外部使用，pool 内部不会对其修改)
@property (nonatomic, strong) NSMutableArray *listenNotificationArr;

/// 获取 notificationName 通知已绑定的 同步状态池
/// @param notificationName 广播通知名
- (NSArray *)getAllStateIdentifierWithNotificationName:(NSNotificationName)notificationName;

/// 添加要同步的 状态 到 notificationName 通知对应的 同步状态池，进行绑定
/// @param identifier 对应 状态 唯一标识
/// @param notificationName 广播通知名
- (void)addSyncStateIdentifier:(NSString *)identifier forNotificationName:(NSNotificationName)notificationName;

/// 从 notificationName 通知对应的 同步状态池 里移除要同步的 状态，解除绑定
/// @param identifier 对应 状态 唯一标识
/// @param notificationName 广播通知名
- (void)removeSyncStateIdentifier:(NSString *)identifier forNotificationName:(NSNotificationName)notificationName;

@end

NS_ASSUME_NONNULL_END
