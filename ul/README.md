# Kit for Unix-like

* [Bash Environement](#bash-environement)
* [Java Programming Environement](#java-programming-environement)
  * [How Easy to Install All](#how-easy-to-install-all)
  * [Just Install Only One of Your Need](#just-only-one-of-your-need)
* [Tomcat Console](#tomcat-console)
  * [Level Zero](#level-zero)
  * [Install on the Fly](#install-on-the-fly)
  * [Play](#play)

## Bash Environement 
Setup bash, aliases, paths and vars etc., on Windows, Darwin, Linux or Unix-like box, 
and just one line code you need to getting things done:
```sh
$ bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/setup-bash.sh)
```
For Windiows you can use [Git Bash](https://git-scm.com/downloads) instead.

You can boot it from local storage two.
```sh
# git clone it from github to <kit-local-dir>
$ git clone --depth=1 https://github.com/junjiemars/kit.git <kit-local-dir>

# boot up from <kit-local-dir>
$ GITHUB_H=file://<kit-local-dir> <kit-local-dir>/ul/setup-bash.sh
```

## Java Programming Environement
A tone of building and programming tools for Java, but you just need one line code to boot up,
do not scare what paltform you are on.

### How Easy to Install All
To install 
[JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html), 
[Ant](http://ant.apache.org), 
[Maven](https://maven.apache.org), 
[Boot](http://boot-clj.com), 
[Lein](http://leiningen.org/), 
[Gradle](https://gradle.org), 
[Groovy](http://www.groovy-lang.org) 
and [Scala](http://www.scala-lang.org) all in once just via one line code

```sh
$ HAS_ALL=YES HAS_JDK=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)
```

### Just Install Only One of Your Need
```sh
# just install jdk 
$ HAS_JDK=1 JDK_U="8u91" JDK_B="b14" bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install ant
$ HAS_ANT=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install maven
$ HAS_MAVEN=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install boot
$ HAS_BOOT=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install lein
$ HAS_LEIN=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)
 
# just install gradle
$ HAS_GRADLE=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install groovy
$ HAS_GROOVY=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)

# just install scala
$ HAS_SCALA=1 bash <(curl https://raw.githubusercontent.com/junjiemars/kit/master/ul/install-java-kits.sh)
```


## Tomcat Console 
Control the [Tomcat](http://tomcat.apache.org) via just one [Tomcat Console](https://raw.githubusercontent.com/junjiemars/kit/master/ul/tc.sh) Bash script.

### Level Zero
```sh
# show usage
$ tc.sh

# show Tomcat's version
$ tc.sh -v
```
### Install on the Fly
```sh
# simple case
$ tc.sh install

# specify install directory
$ PREFIX='/opt/run/www/tomcat' tc.sh install

# specify Tomcat's version to install
$ VER='8.5.4' tc.sh install
```

### Play
```sh
# start 
$ tc.sh start

# stop
$ tc.sh stop

# start into jpda debug mode
$ tc.sh debug

# specify Tomcat's start or stop ports
$ START_PORT='8080' STOP_PORT='8005' tc.sh start
$ START_PORT='8080' STOP_PORT='8005' tc.sh stop 
```
