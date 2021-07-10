//
//  CDPStateManager.h
//  stateManager
//
//  Created by CDP on 2021/7/10.
//  状态管理类

#import <Foundation/Foundation.h>

#import "CDPStateManagerProtocol.h"

/// action回调block
typedef NSDictionary *_Nullable(^CDPHandleActionBlock)(NSDictionary * _Nullable parameters);
/// 同步notification状态回调block
typedef NSDictionary *_Nullable(^CDPHandleNotificationBlock)(NSNotification * _Nonnull notification);


@interface CDPStateManager : NSObject
/// 使用方法
/// 1. 用 registerAction 方法注册 改变状态 处理回调 (只用注册一次即可，可在 AppDelegate 初始化时就把各状态注册好)
/// 2. import "CDPStateManager.h"，将需要管理的 object 遵守 CDPStateManagerProtocol 协议，并添加进 对应状态 的管理池
/// 3. 实现 CDPStateManagerProtocol 所需协议方法，接收 状态同步
///
/// 其他:
/// 1. 如果某控件需要 主动去改变 某已管理状态，则调用该状态对应 已注册action 即可，即调用 actionWithParameters: stateIdentifier: 方法
/// 2. 如果需要将 已管理状态 与 已有notification通知 同步，则用 syncNotificationName 方法进行绑定

/// 单例对象
+ (instancetype _Nonnull )defaultManager;

#pragma mark - 管理控件

/// 获取 identifier 对应状态的 object 管理池
/// @param identifier 对应 状态 唯一标识
- (NSHashTable *_Nonnull)getHashTableWithIdentifier:(nonnull NSString *)identifier;

/// 将 相关控件 添加进 identifier 对应 状态管理池 中 (控件释放后 内部会自动对其 移除, 不需要 主动移除)
/// @param object 相关控件
/// @param identifier 对应 状态 唯一标识
- (void)addObject:(nonnull id <CDPStateManagerProtocol>)object stateIdentifier:(nonnull NSString *)identifier;

/// 主动将 相关控件 从 identifier 对应 状态管理池 中移除
/// @param object 相关控件
/// @param identifier 对应 状态 唯一标识
- (void)removeObject:(nonnull id <CDPStateManagerProtocol>)object stateIdentifier:(nonnull NSString *)identifier;

/// 清空 identifier 对应 状态管理池 (慎用!!!)
/// @param identifier 对应 状态 唯一标识
- (void)removeAllObjectsWithStateIdentifier:(nonnull NSString *)identifier;

#pragma mark - action

/// 注册 identifier 对应状态 相关 action，如果该状态已注册 action，则自动替换 (状态 与 action 一一对应)
/// @param identifier 对应 状态 唯一标识
/// @param block 进行action回调，进行切换状态等相关逻辑处理
///
/// 通过action改变状态时，会将 parameters 通过 block 回调，可以在 block 里根据 传参 进行相关逻辑处理，然后将结果数据通过 字典 封装返回，内部会将该 字典 通过 CDPStateManagerProtocol 协议方法进行全站同步管理
///
/// 注：回调 字典 里如果有 @"stateManagerNotSync" : @"1" ，则此次结果 字典 不会进行全站同步
- (void)registerActionWithStateIdentifier:(nonnull NSString *)identifier
                               completion:(nonnull CDPHandleActionBlock)block;

/// 移除 identifier 对应状态 相关 action
/// @param identifier 对应 状态 唯一标识
- (void)removeActionWithStateIdentifier:(nonnull NSString *)identifier;

/// 执行 identifier 对应状态 相关 action，以改变状态 (必须先用 registerAction 添加再使用)
/// @param parameters action 改变状态要用到的传参
/// @param identifier 对应 状态 唯一标识
- (void)actionWithParameters:(nullable NSDictionary *)parameters
             stateIdentifier:(nonnull NSString *)identifier;

#pragma mark - 同步通知
/// 如果有状态存在 不通过 CDPStateManager 管理，而是用 notification 通知 管理的情况，可以用以下方法将已管理的 状态 与该通知绑定同步

/// 将 notificationName 对应的通知 与 identifier 对应状态 进行同步绑定，使该 状态 可以被 notification 进行状态同步
/// 状态 与 通知 绑定关系为 多对多，及 一种状态可绑定多个通知 ，一个通知也可同步多个状态
/// @param notificationName 要同步的广播通知名称
/// @param identifier 被同步的 对应 状态 唯一标识
/// @param block 收到 notification 进行的 block 同步回调，进行相关逻辑处理
///
/// 当收到 notification 时，会将其通过 block 回调，可以在 block 里根据 收到的 notification 进行相关逻辑处理转换，然后将结果数据通过 字典 封装返回，内部会将该 字典 通过 CDPStateManagerProtocol 协议方法进行全站同步管理
///
/// 注：回调 字典 里如果有 @"stateManagerNotSync" : @"1" ，则此次结果 字典 不会进行全站同步
- (void)syncNotificationName:(nonnull NSNotificationName)notificationName
           toStateIdentifier:(nonnull NSString *)identifier
                      handle:(nonnull CDPHandleNotificationBlock)block;

/// 将 identifier 对应状态 与 notificationName 对应的通知 解除状态同步
/// @param notificationName 要同步的广播通知名称
/// @param identifier 被同步的 对应 状态 唯一标识
- (void)unsyncNotificationName:(nonnull NSNotificationName)notificationName
             toStateIdentifier:(nonnull NSString *)identifier;


@end


