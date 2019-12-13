# JAVA设计模式精讲

课程：JAVA设计模式精讲 Debug 方式+内存分析 笔记

## 主图介绍

设计模式是工程师必备知识，也是面试高频考点。

这门课程将从设计模式定义、应用到源码解析，带你系统学习设计模式，并结合大量场景 Coding，让学习不枯燥，不空洞。

同时采用 Debug方式及内存分析讲解抽象程度高的设计模式，最后通过对JDK及热门开源框架中设计模式进行解析，让大家领略设计模式的妙用技巧。

希望通过这门课程的学习，让大家真正学懂设计模式，并在面试中脱颖而出。

![](imocc/design_pattern/assets/master.png)

> 我自己使用jdk8.

## 导航目录

### [第1章 课程导学](imocc/design_pattern/01/课程导学.md)

  本章节主要讲解大家能收获什么，课程具体包含哪些内容，通过哪些方式来学习设计模式，以及怎么讲，怎么安排，通过本章的学习，让大家为整个课程高效的学习打下基础。
  - [课程导学](imocc/design_pattern/01/课程导学.md)

### [第2章 UML急速入门](imocc/design_pattern/02_uml/UML类图讲解.md)

  本章节主要讲解UML基础、UML类图、UML类关系、UML时序图、UML类关系记忆技巧等，让大家急速入门UML，从而为后面设计模式的学习做好准备。

  - [本章导航](imocc/design_pattern/02_uml/本章导航.md)
  - [UML 类图讲解](imocc/design_pattern/02_uml/UML类图讲解.md)

### [第3章 软件设计七大原则](imocc/design_pattern/03_design_principles/本章导航.md)

  本章节主要讲解软件设计七大原则，同时结合业务场景及演进手把手coding，让大家更好的理解软件设计原则。
  - [本章导航](imocc/design_pattern/03_design_principles/本章导航.md)
  - [开闭原则](imocc/design_pattern/03_design_principles/open_close.md)
  - [依赖倒置原则](imocc/design_pattern/03_design_principles/dependency_inversion.md)
  - [单一职责原则](imocc/design_pattern/03_design_principles/single_responsibility.md)
  - [接口隔离原则](imocc/design_pattern/03_design_principles/interface_segregation.md)
  - [迪米特原则](imocc/design_pattern/03_design_principles/demeter.md)
  - [里氏替换原则](imocc/design_pattern/03_design_principles/liskov_substitution.md)
  - [合成复用原则](imocc/design_pattern/03_design_principles/composition_aggeregation.md)
### [第4章 简单工厂](imocc/design_pattern/04_simple_factory/simple_factory.md)

  本章节主要讲解简单工厂定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对简单工厂在框架(jdk+slf4j等)源码中的应用进行解析，让大家领略简单工厂的妙用技巧。

  - [简单工厂](imocc/design_pattern/04_simple_factory/simple_factory.md)

### [第5章 工厂方法模式](imocc/design_pattern/05_factory_method/factory_method.md)

  本章节主要讲解工厂方法模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对工厂方法模式在框架(jdk+slf4j等)源码中的应用进行解析，让大家领略工厂方法模式的妙用技巧。

  - [工厂方法模式](imocc/design_pattern/05_factory_method/factory_method.md)

### [第6章 抽象工厂模式](imocc/design_pattern/06_abstract_factory/abstract_factory.md)

  本章节主要讲解抽象工厂模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对抽象工厂模式在框架(jdk+mybatis等)源码中的应用进行解析，让大家领略抽象工厂模式的妙用技巧。

  - [抽象工厂模式](imocc/design_pattern/06_abstract_factory/abstract_factory.md)

### [第7章 建造者模式](imocc/design_pattern/07_builder/builder.md)

  本章节主要讲解建造者模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，手一边coding一边讲解，最后对建造者模式在框架(jdk+guava等)源码中的应用进行解析，让大家领略建造者模式的妙用技巧。

  - [建造者模式](imocc/design_pattern/07_builder/builder.md)

### [第8章 单例模式](imocc/design_pattern/08_singleton/singleton.md)

  本章节为面试高频环节，所以讲的比较深入，主要讲解单例模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对单例模式在框架(jdk，mybatis等)源码中的应用进行解析，让大家领略单例模式的妙用技巧。...

  - [单列模式一](imocc/design_pattern/08_singleton/singleton.md)
  - [单列模式二](imocc/design_pattern/08_singleton/singleton2.md)
### [第9章 原型模式](imocc/design_pattern/09_prototype/prototype.md)

  本章节主要讲解原型模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，同时讲解原型模式在框架(jdk+mybatis)源码中的应用进行解析，让大家领略原型模式的妙用技巧。课程中还会向前呼应讲解单例模式中的克隆破坏问题。让大家理解更深刻。...

  - [原型设计模式](imocc/design_pattern/09_prototype/prototype.md)

### [第10章 外观模式](imocc/design_pattern/10_facade/facade.md)

  本章节主要讲解外观模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对外观模式在框架(springjdbc+servlet等)源码中的应用进行解析，让大家领略外观模式的妙用技巧。

 - [外观模式](imocc/design_pattern/10_facade/facade.md)

### [第11章 装饰者模式](imocc/design_pattern/11_decorator/decorator.md)

  本章节主要讲解装饰者模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对装饰者模式在框架(jdk+spring等)源码中应用进行解析，，让大家领略装饰者模式的妙用技巧。

 - [装饰者模式](imocc/design_pattern/11_decorator/decorator.md)

### [第12章 适配器模式](imocc/design_pattern/12_adapter/adapter.md)

  本章节主要讲解适配器模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对适配器模式在框架(jdk+spring等)源码中的应用进行解析，，让大家领略适配器模式的妙用技巧。

 - [适配器模式](imocc/design_pattern/12_adapter/adapter.md)


### [第13章 享元模式](imocc/design_pattern/13_flyweight/flyweight.md)

  本章节主要讲解享元模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对享元模式在框架(jdk+apache-common-pool)源码中的应用进行解析，让大家领略享元模式的妙用技巧。

 - [享元模式Flyweight](imocc/design_pattern/13_flyweight/flyweight.md)

### [第14章 组合模式](imocc/design_pattern/14_composite/composite.md)

  本章节主要讲解享元模式定义及理解，适用场景，优缺点及扩展。并引入业务场景，一边coding一边讲解，最后对享元模式在框架(jdk+apache-common-pool)源码中的应用进行解析，让大家领略享元模式的妙用技巧。

 - [组合模式](imocc/design_pattern/14_composite/composite.md)
