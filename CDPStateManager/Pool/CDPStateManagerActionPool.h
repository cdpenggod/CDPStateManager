//
//  CDPStateManagerActionPool.h
//  stateManager
//
//  Created by CDP on 2021/7/10.
//  action 储存池

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDPStateManagerActionPool : NSObject

/// 保存状态对应action
/// @param configDic 对应action相关设置
/// @param identifier 对应 状态 唯一标识
- (void)saveActionConfigDic:(NSDictionary *)configDic identifier:(NSString *)identifier;

/// 移除 identifier 对应状态 相关 action
/// @param identifier 对应 状态 唯一标识
- (void)removeActionWithStateIdentifier:(NSString *)identifier;

/// 获取状态对应action的相关设置
/// @param identifier 对应 状态 唯一标识
- (NSDictionary *)getActionConfigDicWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
