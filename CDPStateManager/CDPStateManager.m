//
//  CDPStateManager.m
//  stateManager
//
//  Created by CDP on 2021/7/10.
//

#import "CDPStateManager.h"

#import "CDPStateManagerObjectPool.h"
#import "CDPStateManagerActionPool.h"
#import "CDPStateManagerNotificationPool.h"

#define CDPStateNotificationKeyPrefix @"CDPStateNotification_"

@interface CDPStateManager ()

@property (nonatomic, strong) CDPStateManagerObjectPool *objectPool; //object储存池

@property (nonatomic, strong) CDPStateManagerActionPool *actionPool; //action储存池

@property (nonatomic, strong) CDPStateManagerNotificationPool *notificationPool; //notification相关储存池

@end

@implementation CDPStateManager

+ (instancetype)defaultManager {
    static CDPStateManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[CDPStateManager alloc] init];
    });
    return manager;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 管理控件
//获取 identifier 对应状态的 object 管理池
- (NSHashTable *_Nonnull)getHashTableWithIdentifier:(nonnull NSString *)identifier {
    return [self.objectPool getHashTableWithIdentifier:identifier];
}
//将 相关控件 添加进 identifier 对应 状态管理池 中 (控件释放后 内部会自动对其 移除, 不需要 主动移除)
- (void)addObject:(id<CDPStateManagerProtocol>)object stateIdentifier:(NSString *)identifier {
    if ([object conformsToProtocol:@protocol(CDPStateManagerProtocol)]) {
        [self.objectPool addObject:object stateIdentifier:identifier];
    }
}
//主动将 相关控件 从 identifier 对应 状态管理池 中移除
- (void)removeObject:(id<CDPStateManagerProtocol>)object stateIdentifier:(NSString *)identifier {
    if ([object conformsToProtocol:@protocol(CDPStateManagerProtocol)]) {
        [self.objectPool removeObject:object stateIdentifier:identifier];
    }
}
//清空 identifier 对应 状态管理池 (慎用!!!)
- (void)removeAllObjectsWithStateIdentifier:(NSString *)identifier {
    [self.objectPool removeAllObjectsWithStateIdentifier:identifier];
}

#pragma mark - action

//注册 identifier 对应状态 相关 action，如果该状态已注册 action，则自动替换 (状态 与 action 一一对应)
- (void)registerActionWithStateIdentifier:(NSString *)identifier completion:(CDPHandleActionBlock)block {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        block) {
        NSDictionary *blockDic = @{@"block": [block copy]};
        [self.actionPool saveActionConfigDic:blockDic identifier:identifier];
    }
}
//移除 identifier 对应状态 相关 action
- (void)removeActionWithStateIdentifier:(nonnull NSString *)identifier {
    [self.actionPool removeActionWithStateIdentifier:identifier];
}
//执行 identifier 对应状态 相关 action，以改变状态 (必须先用 registerAction 添加再使用)
- (void)actionWithParameters:(nullable NSDictionary *)parameters stateIdentifier:(nonnull NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        //获取actionBlock
        NSDictionary *blockDic = [self.actionPool getActionConfigDicWithIdentifier:identifier];
        
        if (blockDic.allKeys.count == 0) {
            return;
        }
        CDPHandleActionBlock block = [blockDic objectForKey:@"block"];
        
        //获取action处理后的数据
        NSDictionary *completionDic = nil;
        if (block) {
            completionDic = block(parameters);
        }
        if ([completionDic isKindOfClass:[NSDictionary class]]) {
            NSString *notSync = [completionDic objectForKey:@"stateManagerNotSync"];
            if ([notSync isKindOfClass:[NSString class]] && [notSync isEqualToString:@"1"]) {
                //不进行同步回调
                return;
            }
        }
        //对该状态关联的管理控件发送回调
        [self actionStateChangedWithDic:completionDic parameters:parameters identifier:identifier];
    }
}
//发送action回调
- (void)actionStateChangedWithDic:(NSDictionary *)dic parameters:(NSDictionary *)parameters identifier:(NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        //获取对应状态的 控件管理池容器
        NSHashTable *hashTable = [self.objectPool getHashTableWithIdentifier:identifier];
        
        for (id object in hashTable) {
            //判断CDPStateManagerProtocol协议
            if ([object conformsToProtocol:@protocol(CDPStateManagerProtocol)] &&
                [object respondsToSelector:@selector(receiveStateActionWithDic:parameters:stateIdentifier:)]) {
                [object receiveStateActionWithDic:dic parameters:parameters stateIdentifier:identifier];
            }
        }
    }
}

#pragma mark - 同步通知

//将 notificationName 对应的通知 与 identifier 对应状态 进行同步绑定，使该 状态 可以被 notification 进行状态同步
- (void)syncNotificationName:(nonnull NSNotificationName)notificationName
           toStateIdentifier:(nonnull NSString *)identifier
                      handle:(nonnull CDPHandleNotificationBlock)block {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        [notificationName isKindOfClass:[NSString class]] &&
        notificationName.length > 0 &&
        block) {
        //监听该通知
        if (![self.notificationPool.listenNotificationArr containsObject:notificationName]) {
            [self.notificationPool.listenNotificationArr addObject:notificationName];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:notificationName object:nil];
        }
        //将状态与通知绑定
        [self.notificationPool addSyncStateIdentifier:identifier forNotificationName:notificationName];
        //保存对应的block回调
        NSDictionary *blockDic = @{@"block": [block copy]};
        NSString *actionKey = [self getNotificationActionKeyWithStateIdentifier:identifier notificationName:notificationName];
        [self.actionPool saveActionConfigDic:blockDic identifier:actionKey];
    }
}
//将 identifier 对应状态 与 notificationName 对应的通知 解除状态同步
- (void)unsyncNotificationName:(nonnull NSNotificationName)notificationName toStateIdentifier:(nonnull NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        [notificationName isKindOfClass:[NSString class]] &&
        notificationName.length > 0) {
        //解除绑定
        [self.notificationPool removeSyncStateIdentifier:identifier forNotificationName:notificationName];
        //移除对应block回调
        NSString *actionKey = [self getNotificationActionKeyWithStateIdentifier:identifier notificationName:notificationName];
        [self.actionPool removeActionWithStateIdentifier:actionKey];
        
        //检查是否可移除监听通知
        if ([self.notificationPool getAllStateIdentifierWithNotificationName:notificationName].count == 0 &&
            [self.notificationPool.listenNotificationArr containsObject:notificationName]) {
            
            [self.notificationPool.listenNotificationArr removeObject:notificationName];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
        }
    }
}
//收到通知进行处理并回调
- (void)receiveNotification:(NSNotification *)notification {
    if (notification &&
        [notification.name isKindOfClass:[NSString class]] &&
        notification.name.length > 0) {
        //获取所有绑定的自定义状态
        NSArray *stateArr = [self.notificationPool getAllStateIdentifierWithNotificationName:notification.name];
        for (NSString *identifier in stateArr) {
            //获取对应block
            NSString *actionKey = [self getNotificationActionKeyWithStateIdentifier:identifier notificationName:notification.name];
            NSDictionary *blockDic = [self.actionPool getActionConfigDicWithIdentifier:actionKey];
            if (blockDic.allKeys.count == 0) {
                continue;
            }
            CDPHandleNotificationBlock block = [blockDic objectForKey:@"block"];
            //获取action处理后的数据
            NSDictionary *completionDic = nil;
            if (block) {
                completionDic = block(notification);
            }
            if ([completionDic isKindOfClass:[NSDictionary class]]) {
                NSString *notSync = [completionDic objectForKey:@"stateManagerNotSync"];
                if ([notSync isKindOfClass:[NSString class]] && [notSync isEqualToString:@"1"]) {
                    //不进行同步回调
                    return;
                }
            }
            //对该自定义状态所管理控件发送同步回调
            [self syncNotificationWithDic:completionDic notification:notification identifier:identifier];
        }
    }
}
//发送notification通知同步回调
- (void)syncNotificationWithDic:(NSDictionary *)dic notification:(NSNotification *)notification identifier:(NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        //获取对应状态的 控件管理池容器
        NSHashTable *hashTable = [self.objectPool getHashTableWithIdentifier:identifier];
        
        for (id object in hashTable) {
            //判断CDPStateManagerProtocol协议
            if ([object conformsToProtocol:@protocol(CDPStateManagerProtocol)] &&
                [object respondsToSelector:@selector(receiveStateNotificationSyncWithDic:notification:stateIdentifier:)]) {
                [object receiveStateNotificationSyncWithDic:dic notification:notification stateIdentifier:identifier];
            }
        }
    }
}
//获取对应状态处理notification数据的block的key
- (NSString *)getNotificationActionKeyWithStateIdentifier:(nonnull NSString *)identifier notificationName:(nonnull NSNotificationName)notificationName {
    return [NSString stringWithFormat:@"%@%@_%@", CDPStateNotificationKeyPrefix, notificationName, identifier];
}
#pragma mark - getter
- (CDPStateManagerObjectPool *)objectPool {
    if (_objectPool == nil) {
        _objectPool = [CDPStateManagerObjectPool new];
    }
    return _objectPool;
}
- (CDPStateManagerActionPool *)actionPool {
    if (_actionPool == nil) {
        _actionPool = [CDPStateManagerActionPool new];
    }
    return _actionPool;
}
- (CDPStateManagerNotificationPool *)notificationPool {
    if (_notificationPool == nil) {
        _notificationPool = [CDPStateManagerNotificationPool new];
    }
    return _notificationPool;
}

@end
