# shiro

#### 1. .简述 Shiro 的核心组件

  Shiro 架构 3 个核心组件:
  Subject: 正与系统进行交互的人, 或某一个第三方服务.所有 Subject 实例都被绑定到（且这是必须的）一个SecurityManager 上。
  SecurityManager: Shiro 架构的心脏, 用来协调内部各安全组件, 管理内部组件实例, 并通过它来提供安全管理的各种服务.当 Shiro 与一个 Subject 进行交互时, 实质上是幕后的 SecurityManager 处理所有繁重的 Subject 安全操作。
  Realms: 本质上是一个特定安全的 DAO.当配置 Shiro 时, 必须指定至少一个 Realm 用来进行身份验证和/或授权.
  Shiro 提供了多种可用的 Realms 来获取安全相关的数据. 如关系数据库(JDBC),INI 及属性文件等.
  可以定义自己 Realm 实现来代表自定义的数据源。

#### 2. Shiro认证过程

(1) 应用程序代码调用 Subject.login 方法，传递创建好的包含终端用户的 Principals(身份)和 Credentials(凭证)的 AuthenticationToken 实例
(2) Subject 实例: 通常为 DelegatingSubject(或子类)委托应用程序的 SecurityManager 通过调用securityManager.login(token) 开始真正的验证。
(3)SubjectManager 接收 token，调用内部的 Authenticator 实例调用 authenticator.authenticate(token).Authenticator 通常是一个 ModularRealmAuthenticator 实例, 支持在身份验证中协调一个或多个Realm 实例
(4) 如果应用程序中配置了一个以上的 Realm, ModularRealmAuthenticator 实例将利用配置好的AuthenticationStrategy 来启动 Multi-Realm 认证尝试. 在Realms 被身份验证调用之前, 期间和以后,AuthenticationStrategy 被调用使其能够对每个Realm 的结果作出反应.
(5)每个配置的 Realm 用来帮助看它是否支持提交的 AuthenticationToken. 如果支持, 那么支持 Realm 的 getAuthenticationInfo 方法将会伴随着提交的 token 被调用. getAuthenticationInfo 方法有效地代表一个特定 Realm 的单一的身份验证尝试。

#### 3. Shiro授权过程

(1)应用程序或框架代码调用任何 Subject 的hasRole*, checkRole*, isPermitted*,或者checkPermission*方法的变体, 传递任何所需的权限
(2) Subject 的实例—通常是 DelegatingSubject(或子类), 调用securityManager 的对应的方法.
(3) SecurityManager 调用 org.apache.shiro.authz.Authorizer 接口的对应方法.默认情况下，authorizer 实例是一个 ModularRealmAuthorizer 实例, 它支持协调任何授权操作过程中的一个或多个Realm 实例
(4) 每个配置好的 Realm 被检查是否实现了相同的 Authorizer 接口. 如果是, Realm 各自的 hasRole*, checkRole*,isPermitted*，或 checkPermission* 方法将被调用

#### 4. Shiro 如何自实现认证

Shiro 的认证过程由 Realm 执行, SecurityManager 会调用 org.apache.shiro.realm.Realm 的 getAuthenticationInfo(AuthenticationToken token) 方法. 实际开发中, 通常提供 org.apache.shiro.realm.AuthenticatingRealm 的实现类, 并在该实现类中提供 doGetAuthenticationInfo(AuthenticationToken token)方法的具体实现。

#### 5. 如何实现自实现授权

实际开发中, 通常提供  org.apache.shiro.realm.AuthorizingRealm 的实现类,并提供 doGetAuthorizationInfo(PrincipalCollection principals) 方法的具体实现