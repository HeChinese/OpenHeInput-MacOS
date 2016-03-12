# OpenHeInput Project
Open source HeInput project for Mac OS X is based on Mac OS X 10.5 Input Method Kit Framework, using Objective-C。

It is full functional Chinese Input application, target to Mac OS X 10.9+.

This application is also available in App Store:

# Application Structure

Created with XCode 7.2.1, using Objective C.

Project Name: HeChinese, 

include 3 modules:

1. Static Library: HeLibrary; 
2. Static Library: HeInputLibrary; 
3. Application: OpenHeInput. 

The main parts of code are:

1. HeInputController class, which is inherited from IMKInputController, handles key events, abtains candidates from data server, and sends selected words to client (application);
2. Input_DataServer process key input and provide cadidates;
   1. HeInput_DataServer includes EngineCollection;
   2. EngineCollection includes HeMaEngine, PinYinEngine, HeEnglishEngine, etc;
   3. Each Engine access SQLite database;

# Database Structure

Include a SQLite database: hema_db.sqlite, it includes tables:

create table HanZi
(
--_id INTEGER PRIMARY KEY,
HanZi text,	
M1 numeric,
M2 numeric,
M3 numeric,
M4 numeric,
GBOrder numeric,
B5Order numeric
);

create table CiZu
(
--_id INTEGER PRIMARY KEY,
CiZu text,	
M1 numeric,
M2 numeric,
M3 numeric,
M4 numeric,
HeMaOrder numeric,
JianFan numeric
);

create table English_Word
(
--_id INTEGER PRIMARY KEY,
word text,	
HeMaOrder numeric
);

create table PinYin_Number
(
--_id INTEGER PRIMARY KEY,
PinYin text,
number numeric
);

create table PinYin_HanZi
(
--_id INTEGER PRIMARY KEY,
PinYin text,	
HanZiString text
);

create table HanZi_PinYin
(
--_id INTEGER PRIMARY KEY,
HanZi text,	
PinYin text,
ShengDiao numeric
);

# Compile and Install

1、Run XCode, then open HeMacOS-Workspace.xcworkspace;

2、Select OpenHeInput project --> OpenHeInput target;

3、Build;

4、Select OpenHeInput-->Products-->OpenHeInput.app, right click to show in Finder,

5、Copy OpenHeInput.app to /Library/Input Methods/ folder，then Log out, and Log in again；

After installation, take following steps for setting: 

1. Open Mac OS X System Preferences;

2. Select Keyboard;

3. Select Input Source; 

4. Click ' + ' Sign at bottom left;

5. Select Simplified Chinese;

6. Select one or more HeInput methods; 

7. Then click 'Add' button
# OpenHeInput Usage

HeInput software’ usage:

1. HeInput install three input mode: Chinese Simplified, Chinese Traditional, and HeEnglish;

2. Can use main keyboard and number pad;

3. Includes 21,000 words, and 180,000 phrases.

4. Shift + Space (or character): switch to English input;

5. fn + Space: switch Chinese or PinYin, or HeEnglish input mode;

6. 0(M) to display function menu, and select from menu;

7. fn + j, s: switch to Chinese simplified mode;

8. fn + f, t: switch to Traditional Chinese mode;

9. fn + p: switch to PinYin mode;

10. fn + e: switch to HeEnglish mode;

11. fn + r: switch to reset mode;

12. fn + a: turn Off/On pinyin prompt. 

# More Information about HeInput
1. http://www.hezi.net/He/UserGuide/zh-Hans/Set/BookCover.html

2. http://www.hezi.net/He/UserGuide_Concise/zh-Hans/Set/HeChinese_Guide_Concise.htm


# 一、苹果电脑系统(Mac OS X 10.9+)，开源和码输入程序与数据库
苹果电脑上，和码输入程序是基于Mac OS X 10.5 引入的Input Method Kit Framework制作的，编程语言是Objective-C。
# 二、程序编译与安装
Mac苹果电脑和码输入软件，是用XCode 7.2.1开发编译的。获取程序后，可用以下步骤编译与安装OpenHeInput：

1、用XCode打开HeMacOS-Workspace.xcworkspace;

2、选择OpenHeInput project --> OpenHeInput target;

3、编译Build;

4、OpenHeInput-->Products-->OpenHeInput.app, 鼠标右击-->Show in Finder,

5、将OpenHeInput.app文件，拷贝到Mac个人用户的　/Library/Input Methods/ 目录下，然后Log out（退出登录），再登录Log in；

6、打开Mac的System Preferences（系统设置）--> Keyboard（键盘）--> Input Source（输入速度）--> Chinese Simplified（简体汉字）；

7、选择HeInput Simplified（和码简体）, HeInput Traditional（和码繁体）, 或HeEnglish（和码英文）, 任何一种输入方式；

8、打开应用软件，在输入法列表中，调用和码输入法，就可以用和码输入了。
# 三、Mac电脑上和码输入法的使用方法

也以下网页下载：http://www.hezi.net/forum/?g=posts&t=40

和码OpenHeInput2.0的主要功能有：

1、和码输入法安装了三种初选输入方式：简体输入、繁体输入、HeEnglish输入，安装时可选其中一种或几种；

2、大键盘与小键盘都可以输入，两种键盘的输入方式可以分开设置，如(大键盘英文输入，小键盘中文输入)，或(大键盘输入中文，小键盘输入数字)。

3、能输入2万1千多个单字(简繁体)，18万余条词组。

输入模式的切换方式：

1、Shift + Space(Character): 切换到纯英文输入方式；

2、fn + Space: 切换到汉字或拼音输入方式，或和码英文输入方式；

3、输入模式转换也可以通过输入码0(M)，软件显示功能目录，再选择目录项；

4、fn + 字母键进行输入方式转换，如：

fn + 字母代表的功能：

e: 转为HeEnglish输入模式(english)；

j, s: 简体字输入(jianTi, simplified Chinese);

f, f: 繁体字输入(fanTi, traditional Chinese);

p: 拼音单字输入(拼音查码)(pinYin);

r: 回复到初始设定(reset)；

a: 开启或 关闭拼音提示(annotation)；

# 四、和码资料
有关和码汉字字形技术，和码输入法的学习资料，可查看：

1、和码线上书：http://www.hezi.net/He/UserGuide/zh-Hans/Set/BookCover.html

2、和码简明教程：http://www.hezi.net/He/UserGuide_Concise/zh-Hans/Set/HeChinese_Guide_Concise.htm

3、和码在Android/iPad/iPhone上的练习与输入软件：http://www.hezi.net/he/HTML/HeChinese_Download.html


