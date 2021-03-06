#!/bin/bash
#必须放在文件的第一行，会指引操作系统使用接下来指定的程序运行此文件

#变量：Shell 变量默认全都是字符串
#变量赋值与引用
#Shell 编程中，使用变量无需事先声明。变量名的命名遵守正则表达式 <tt>[a-zA-Z_][a-zA-Z0-9_]+，也就是由大小写字母数字和下划线组成，且不能以数字开头。
#请注意 shell 环境中的确有以数字和特殊符号开头的变量名，但是那些东西不可以用接下来的方式赋值。
# e.g.注意：要取用一个变量的值，只需在变量名前面加一个 $
a="hello world"  # 等号两边均不能有空格存在
# print
printf '%s\n' "A is: $a"
num=2
echo "this is the $numnd"   # 输出 this is the       — shell 尝试寻找 $numnd 的值
echo "this is the ${num}nd" # 输出 this is the 2nd   — 使用花括号可以隔开变量名
#变量算术
var=0
# bash 里面可以用 (( )) 执行 C 风格的算术表达式。
# 如果你接下来还会读 if 那一段的话，你还会知道这玩意的返回和 C 的非零真假判断一致。
(( var += 1 )) # 这是一种，现在 var 是 1
(( var++ ))    # 这也是一种自增，2
(( var = var * var )) # 怎么来乘法了！var 现在是 4。
let 'var = var / 3'   # 还是只有 bash 才能用的拓展。除法是整数除法，向 0 舍入，1。
# 来一点不一定要 bash 的方法吧，毕竟 sh 还有很多种，总不能全报错了吧。
# $(( )) 会展开成为这个 C 表达式求值的结果。以前 bash 有个 $[ ] 一样，但是别去用。
echo $((var += 2))    # echo 出 3，var 现在是 3。
var=$((var-1))        # 展开成 var=2，var 现在是……还用说吗，2。






#shell里的流程控制
#if语句
#方式一：
if
  判断命令，可以有很多个，真假取最后的返回值
then
  如果前述为真做什么
[ elif
  可以再来个判断，如果签名为假继续尝试这里
then
  如果前述为真做什么 ]
else
  如果全都不行做什么
fi # 结束，就是倒写的 if
#方式二：
if ....; then # 也可以写成 if 之后换行，这样就不用分号了。
  ....
fi
#测试语句
-f "filename" #判断是否是一个文件
-x "/bin/ls" #判断/bin/ls是否存在并有可执行权限
-n "$var" #判断 $var 变量是否有值
"$a" == "$b" #判断$a和$b是否相等
-r "$mailfolder"  #判断文件是否可读

#e.g. 变量 $SHELL 包含有登录shell的名称，我们拿它和 /bin/bash 进行比较以判断当前使用的shell是否为bash。
if [ "${SHELL}" == "/bin/bash" ]; then
  echo "your login shell is the bash (bourne again shell)"
else
  echo "your login shell is not bash but ${SHELL}"
fi
#&& 和 || 操作符
#e.g. 表示如果/etc/shadow文件存在，则打印“This computer uses shadow passwords”。
[ -f "/etc/shadow" ] && echo "This computer uses shadow passwords"
#e.g. 首先判断mailfolder是否可读，如果可读则打印该文件中以"From"开头的行。如果不可读则或操作生效，打印错误信息后脚本退出。
mailfolder=/var/spool/mail/james
[ -r "$mailfolder" ] || { echo "Can not read $mailfolder"; exit 1; }  #使用花括号以组合命令的形式将两个命令放到一起作为一个命令使用
echo "$mailfolder has mail from:"
grep "^From " $mailfolder


#case语句：case表达式可以用来匹配一个给定的字符串，而不是数字
case ... in
   ...) do something here
   ;;
esac
file lf.gz #file命令可以辨别出一个给定文件的文件类型
#输出结果：
lf.gz: gzip compressed data, deflated, original filename,
last modified: Mon Aug 27 23:09:18 2001, os: Unix

#e.g.该脚本可以自动解压bzip2, gzip和zip 类型的压缩文件
#!/bin/bash
ftype="$(file "$1")"  #$1，该变量包含有传递给该脚本的第一个参数值
case "$ftype" in
"$1: Zip archive"*)
   unzip "$1" ;;
"$1: gzip compressed"*)
   gunzip "$1" ;;
"$1: bzip2 compressed"*)
   bunzip2 "$1" ;;
*)
   echo "File $1 can not be uncompressed with smartzip";;
esac

#select循环语句：用户可以从一组不同的值中进行选择
#e.g.
#!/bin/bash
echo "What is your favourite OS?"
select var in "Linux" "Gnu Hurd" "Free BSD" "Other"; do
  break;
done
echo "You have selected $var"
#运行结果
What is your favourite OS?
1) Linux
2) Gnu Hurd
3) Free BSD
4) Other
#? 1
You have selected Linux

#while、for循环
#关键字"break"用来跳出循环，而关键字”continue”则可以跳过一个循环的余下部分，直接跳到下一次循环中
while ...; do
   ....
done
#for循环会查看一个字符串列表（字符串用空格分隔），并将其赋给一个变量：
for var in ....; do
   ....
done
#实用的脚本showrpm，其功能是打印一些RPM包的统计信息
#!/bin/bash

# list a content summary of a number of RPM packages
# USAGE: showrpm rpmfile1 rpmfile2 ...
# EXAMPLE: showrpm /cdrom/RedHat/RPMS/*.rpm
for rpmpackage in "$@"; do
   if [ -r "$rpmpackage" ];then  # $@，该变量包含有输入的所有命令行参数值。如果不加引号，带空格的参数会被截断。
      echo "=============== $rpmpackage =============="
      rpm -qi -p $rpmpackage
   else
      echo "ERROR: cannot read file $rpmpackage"
   fi
done
#如果你运行showrpm openssh.rpm w3m.rpm webgrep.rpm，那么 "$@"(有引号) 就包含有 3 个字符串，即openssh.rpm, w3m.rpm和 webgrep.rpm。
# $*的意思是差不多的。但是只有一个字串。


#Shell里的一些特殊符号
