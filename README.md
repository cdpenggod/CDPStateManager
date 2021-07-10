# CDPStateManager
## 一个简单易用的 状态管理器，解决 view,model,viewController 等 各种object 状态同步 的问题，尤其是 复用场景。
## An easy-to-use state manager, especially for reuse scenarios such as TableView and CollectionView.

使用方法
1. 用 registerAction 方法注册 改变状态 处理回调 (只用注册一次即可，可在 AppDelegate 初始化时就把各状态注册好)
2. import "CDPStateManager.h"，将需要管理的 object 遵守 CDPStateManagerProtocol 协议，并添加进 对应状态 的管理池
3. 实现 CDPStateManagerProtocol 所需协议方法，接收 状态同步

其他:
1. 如果某控件需要 主动去改变 某已管理状态，则调用该状态对应 已注册action 即可，即调用 actionWithParameters: stateIdentifier: 方法
2. 如果需要将 已管理状态 与 已有notification通知 同步，则用 syncNotificationName 方法进行绑定
