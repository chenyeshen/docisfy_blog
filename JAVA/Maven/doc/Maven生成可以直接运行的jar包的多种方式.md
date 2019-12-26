# Maven生成可以直接运行的jar包的多种方式

Maven可以使用`mvn package`指令对项目进行打包生成jar文件，如果直接使用`java -jar xxx.jar`指令运行jar文件，会出现”no main manifest attribute, in xxx.jar”（没有设置Main-Class）、ClassNotFoundException（找不到依赖包）等错误。

要想jar包能直接通过`java -jar xxx.jar`运行，需要满足：

1、在jar包中的META-INF/MANIFEST.MF中指定Main-Class，这样才能确定程序的入口在哪里；

2、要能加载到依赖包。

使用Maven有以下几种方法可以生成满足以上两个条件能直接运行的jar包，可以根据需要选择一种合适的方法。

## 方法一：使用maven-jar-plugin和maven-dependency-plugin插件打包

在pom.xml中配置：

```
<build>
	<plugins>

		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-jar-plugin</artifactId>
			<version>2.6</version>
			<configuration>
				<archive>
					<manifest>
						<addClasspath>true</addClasspath>
						<classpathPrefix>lib/</classpathPrefix>
						<mainClass>com.xxg.Main</mainClass>
					</manifest>
				</archive>
			</configuration>
		</plugin>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-dependency-plugin</artifactId>
			<version>2.10</version>
			<executions>
				<execution>
					<id>copy-dependencies</id>
					<phase>package</phase>
					<goals>
						<goal>copy-dependencies</goal>
					</goals>
					<configuration>
						<outputDirectory>${project.build.directory}/lib</outputDirectory>
					</configuration>
				</execution>
			</executions>
		</plugin>

	</plugins>
</build>

```

maven-jar-plugin用于生成META-INF/MANIFEST.MF文件的部分内容，`<mainClass>com.xxg.Main</mainClass>`指定MANIFEST.MF中的Main-Class，`<addClasspath>true</addClasspath>`会在MANIFEST.MF加上Class-Path项并配置依赖包，`<classpathPrefix>lib/</classpathPrefix>`指定依赖包所在目录。

例如下面是一个通过maven-jar-plugin插件生成的MANIFEST.MF文件片段：

```
Class-Path: lib/commons-logging-1.2.jar lib/commons-io-2.4.jar
Main-Class: com.xxg.Main

```

不过仅仅生成MANIFEST.MF文件还不够，maven-dependency-plugin插件用于将依赖包拷贝到`<outputDirectory>${project.build.directory}/lib</outputDirectory>`指定的位置，即lib目录下。

配置完成后，通过`mvn package`指令打包，会在target目录下生成jar包，并将依赖包拷贝到target/lib目录下，目录结构如下：
[![目录结构](http://7xidft.com1.z0.glb.clouddn.com/blog/20150807174107439.jpg)](http://7xidft.com1.z0.glb.clouddn.com/blog/20150807174107439.jpg)目录结构
指定了Main-Class，有了依赖包，那么就可以直接通过`java -jar xxx.jar`运行jar包。

不过这种方式生成jar包有个缺点，就是生成的jar包太多不便于管理，下面两种方式只生成单个jar文件，包含项目本身的代码、资源以及所有的依赖包。

## 方法二：使用maven-assembly-plugin插件打包

在pom.xml中配置：

```
<build>
	<plugins>

		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-assembly-plugin</artifactId>
			<version>2.5.5</version>
			<configuration>
				<archive>
					<manifest>
						<mainClass>com.xxg.Main</mainClass>
					</manifest>
				</archive>
				<descriptorRefs>
					<descriptorRef>jar-with-dependencies</descriptorRef>
				</descriptorRefs>
			</configuration>
		</plugin>

	</plugins>
</build>

```

打包方式：

```
mvn package assembly:single

```

打包后会在target目录下生成一个`xxx-jar-with-dependencies.jar`文件，这个文件不但包含了自己项目中的代码和资源，还包含了所有依赖包的内容。所以可以直接通过`java -jar`来运行。

此外还可以直接通过`mvn package`来打包，无需`assembly:single`，不过需要加上一些配置：

```
<build>
	<plugins>

		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-assembly-plugin</artifactId>
			<version>2.5.5</version>
			<configuration>
				<archive>
					<manifest>
						<mainClass>com.xxg.Main</mainClass>
					</manifest>
				</archive>
				<descriptorRefs>
					<descriptorRef>jar-with-dependencies</descriptorRef>
				</descriptorRefs>
			</configuration>
			<executions>
				<execution>
					<id>make-assembly</id>
					<phase>package</phase>
					<goals>
						<goal>single</goal>
					</goals>
				</execution>
			</executions>
		</plugin>

	</plugins>
</build>

```

其中`<phase>package</phase>`、`<goal>single</goal>`表示在执行package打包时，执行`assembly:single`，所以可以直接使用`mvn package`打包。

不过，如果项目中用到Spring Framework，用这种方式打出来的包运行时会出现读取XML schema文件异常等奇怪的错误，使用下面的方法三可以处理。

## 方法三：使用maven-shade-plugin插件打包

在pom.xml中配置：

```
<build>
	<plugins>

		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-shade-plugin</artifactId>
			<version>2.4.1</version>
			<executions>
				<execution>
					<phase>package</phase>
					<goals>
						<goal>shade</goal>
					</goals>
					<configuration>
						<transformers>
							<transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
								<mainClass>com.xxg.Main</mainClass>
							</transformer>
						</transformers>
					</configuration>
				</execution>
			</executions>
		</plugin>

	</plugins>
</build>

```

配置完成后，执行`mvn package`即可打包。在target目录下会生成两个jar包，注意不是original-xxx.jar文件，而是另外一个。和maven-assembly-plugin一样，生成的jar文件包含了所有依赖，所以可以直接运行。

不过如果项目中用到了Spring Framework，将依赖打到一个jar包中，运行时会出现读取XML schema文件出错。原因是Spring Framework的多个jar包中包含相同的文件spring.handlers和spring.schemas，如果生成单个jar包会互相覆盖。为了避免互相影响，可以使用`AppendingTransformer`来对文件内容追加合并：

```
<build>
	<plugins>

		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-shade-plugin</artifactId>
			<version>2.4.1</version>
			<executions>
				<execution>
					<phase>package</phase>
					<goals>
						<goal>shade</goal>
					</goals>
					<configuration>
						<transformers>
							<transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
								<mainClass>com.xxg.Main</mainClass>
							</transformer>
							<transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
								<resource>META-INF/spring.handlers</resource>
							</transformer>
							<transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
								<resource>META-INF/spring.schemas</resource>
							</transformer>
						</transformers>
					</configuration>
				</execution>
			</executions>
		</plugin>

	</plugins>
</build>
```