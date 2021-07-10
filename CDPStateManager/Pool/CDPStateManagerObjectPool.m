//
//  CDPStateManagerObjectPool.m
//  stateManager
//
//  Created by CDP on 2021/7/10.
//

#import "CDPStateManagerObjectPool.h"

@interface CDPStateManagerObjectPool ()

@property (nonatomic, strong) NSMutableDictionary *objectDic; //各状态 所对应的控件管理池容器

@end

@implementation CDPStateManagerObjectPool

//将 相关控件 添加进 identifier 对应 状态管理池 (控件释放后 内部会自动对其 移除, 不需要 主动移除)
- (void)addObject:(id)object stateIdentifier:(NSString *)identifier {
    if (object &&
        [identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0) {
        
        //获取对应状态的 控件管理池容器
        NSHashTable *hashTable = [self getHashTableWithIdentifier:identifier];
        //添加控件进管理池
        if (![hashTable containsObject:object]) {
            [hashTable addObject:object];
        }
    }
}
//主动将 相关控件 从 identifier 对应 状态管理池 移除
- (void)removeObject:(id)object stateIdentifier:(NSString *)identifier {
    if (object &&
        [identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0) {
        //获取对应状态的 控件管理池容器
        NSHashTable *hashTable = [self getHashTableWithIdentifier:identifier];
        if ([hashTable containsObject:object]) {
            //移除控件
            [hashTable removeObject:object];
        }
    }
}
//清空 identifier 对应 状态管理池
- (void)removeAllObjectsWithStateIdentifier:(NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        //获取对应状态的 控件管理池容器
        NSHashTable *hashTable = [self getHashTableWithIdentifier:identifier];
        [hashTable removeAllObjects];
    }
}
//获取 object 管理池
- (NSHashTable *)getHashTableWithIdentifier:(NSString *)identifier {
    if (![identifier isKindOfClass:[NSString class]]) {
        identifier = @"";
    }
    NSHashTable *hashTable = [self.objectDic objectForKey:identifier];
    if (hashTable == nil || ![hashTable isKindOfClass:[NSHashTable class]]) {
        hashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        [self.objectDic setObject:hashTable forKey:identifier];
    }
    return hashTable;
}
#pragma mark - getter
- (NSMutableDictionary *)objectDic {
    if (_objectDic == nil) {
        _objectDic = [NSMutableDictionary new];
    }
    return _objectDic;
}

@end
