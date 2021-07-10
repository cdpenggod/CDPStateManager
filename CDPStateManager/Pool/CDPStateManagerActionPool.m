//
//  CDPStateManagerActionPool.m
//  stateManager
//
//  Created by CDP on 2021/7/10.
//

#import "CDPStateManagerActionPool.h"

@interface CDPStateManagerActionPool ()

@property (nonatomic, strong) NSMutableDictionary *actionDic; //各状态 所对应的action

@end

@implementation CDPStateManagerActionPool

//保存状态对应action
- (void)saveActionConfigDic:(NSDictionary *)configDic identifier:(NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] &&
        identifier.length > 0 &&
        [configDic isKindOfClass:[NSDictionary class]]) {
        NSString *key = [CDPStateManagerActionPool getActionKeyWithIdentifier:identifier];
        [self.actionDic setObject:configDic forKey:key];
    }
}
//移除 identifier 对应状态 相关 action
- (void)removeActionWithStateIdentifier:(NSString *)identifier {
    if ([identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        NSString *key = [CDPStateManagerActionPool getActionKeyWithIdentifier:identifier];
        if ([self.actionDic.allKeys containsObject:key]) {
            [self.actionDic removeObjectForKey:key];
        }
    }
}
//获取状态对应action的相关设置
- (NSDictionary *)getActionConfigDicWithIdentifier:(NSString *)identifier {
    NSString *key = [CDPStateManagerActionPool getActionKeyWithIdentifier:identifier];
    NSDictionary *dic = [self.actionDic objectForKey:key];
    return (dic && [dic isKindOfClass:[NSDictionary class]])? dic : @{};
}
//获取对应action相关设置key
+ (NSString *)getActionKeyWithIdentifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"CDPStateActionKey_%@", identifier];
}

#pragma mark - getter
- (NSMutableDictionary *)actionDic {
    if (_actionDic == nil) {
        _actionDic = [NSMutableDictionary new];
    }
    return _actionDic;
}

@end
