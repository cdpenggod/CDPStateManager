//
//  CDPStateManagerObjectPool.h
//  stateManager
//
//  Created by CDP on 2021/7/10.
//  管理控件 object 储存池

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDPStateManagerObjectPool : NSObject

/// 将 相关控件 添加进 identifier 对应 状态管理池 (控件释放后 内部会自动对其 移除, 不需要 主动移除)
/// @param object 相关控件
/// @param identifier 对应 状态 唯一标识
- (void)addObject:(nonnull id)object stateIdentifier:(nonnull NSString *)identifier;

/// 主动将 相关控件 从 identifier 对应 状态管理池 移除
/// @param object 相关控件
/// @param identifier 对应 状态 唯一标识
- (void)removeObject:(nonnull id)object stateIdentifier:(nonnull NSString *)identifier;

/// 清空 identifier 对应 状态管理池 (慎用!!!)
/// @param identifier 对应 状态 唯一标识
- (void)removeAllObjectsWithStateIdentifier:(nonnull NSString *)identifier;

/// 获取 identifier 对应 状态 object 管理池
/// @param identifier 对应 状态 唯一标识
- (NSHashTable *)getHashTableWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
