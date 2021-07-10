//
//  CDPStateManagerProtocol.h
//  stateManager
//
//  Created by CDP on 2021/7/10.
//  涉及状态管理的 object 需要遵循的协议 ，并通过 CDPStateManager 管理使用

@protocol CDPStateManagerProtocol <NSObject>

@optional

/// 收到 状态改变 回调，可进行改变后的逻辑处理
/// @param dic 执行 action 时通过 block 回调的用来 同步状态数据的 字典
/// @param parameters 执行 action 时的 传参，可与 当前数据进行匹配 是否对应
/// @param identifier 对应 状态 唯一标识
- (void)receiveStateActionWithDic:(NSDictionary *)dic
                       parameters:(NSDictionary *)parameters
                  stateIdentifier:(NSString *)identifier;

/// 收到 通知 的同步回调，可进行对应逻辑处理
/// @param dic 对收到的 notification 用 block 回调处理后的 同步数据
/// @param notification 收到的 notification 通知
/// @param identifier 对应 状态 唯一标识
- (void)receiveStateNotificationSyncWithDic:(NSDictionary *)dic
                               notification:(NSNotification *)notification
                            stateIdentifier:(NSString *)identifier;

@end
