# OpenHeInput Project
Open source HeInput project for Mac OS X is based on Mac OS X 10.5 Input Method Kit Framework, started from learning Apple's NumberInput_IMKit_Sample: 
https://developer.apple.com/library/mac/samplecode/NumberInput_IMKit_Sample/Introduction/Intro.html

Now it is fully functional Chinese Input application, target to Mac OS X 10.9+, has features:

1. Has 3 input modes: Chinese Simplified, Chines traditional, HeEngligh;
2. Use main keyboard or number pad to input;
3. Includes 21,000 Chinese words, 180,000 phrases.

This application is also available in App Store:
(waiting for review)

# Application Structure

Created with XCode 7.2.1, using Objective C.

Workspace: HeMacOS-Workspace 

Include 3 modules:

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
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>HanZi text,	
</br>M1 numeric,
</br>M2 numeric,
</br>M3 numeric,
</br>M4 numeric,
</br>GBOrder numeric,
</br>B5Order numeric
</br>);

create table CiZu
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>CiZu text,	
</br>M1 numeric,
</br>M2 numeric,
</br>M3 numeric,
</br>M4 numeric,
</br>HeMaOrder numeric,
</br>JianFan numeric
</br>);

create table English_Word
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>word text,	
</br>HeMaOrder numeric
</br>);

create table PinYin_Number
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>PinYin text,
</br>number numeric
</br>);

create table PinYin_HanZi
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>PinYin text,	
</br>HanZiString text
</br>);

create table HanZi_PinYin
</br>(
</br>--_id INTEGER PRIMARY KEY,
</br>HanZi text,	
</br>PinYin text,
</br>ShengDiao numeric
</br>);

# Compile and Install

Aftet geting source from here, then:

1. Run XCode, open HeMacOS-Workspace.xcworkspace;

2. Select OpenHeInput project --> OpenHeInput target;

3. Build;

4. Select OpenHeInput-->Products-->OpenHeInput.app, right click to show in Finder,

5. Copy OpenHeInput.app to /Library/Input Methods/ folder，then Log out, and Log in again；

6. Open Mac OS X System Preferences;

7. Select Keyboard --> Input Source; 

8. Click ' + ' Sign at bottom left;

9.  Select Simplified Chinese;

10. Select one or more OpenHeInput methods: Chinese Simplified, Chinese Traditional, HeEnglish; 

11. Then click 'Add' button;

12. Run an application which requires Chinese input;

13. Select HeInput method by click language icon on screen's top right corner;

14. Then type in Chinese.

OpenHeInput.app can be download from AppStore:</br>
(waiting for review)</br>
Or download from: http://www.hezi.net/forum/?g=posts&t=40</br>
Then follow steps from 5 to complete install and setting.

# How to use OpenHeInput application

1. Shift + Space (or character): switch to English input;

2. fn + Space: switch Chinese or PinYin, or HeEnglish input mode;

3. 0(M) to display function menu, and select from menu;

4. fn + character to switch input mode:

fn + j, s: switch to Chinese simplified mode;

fn + f, t: switch to Traditional Chinese mode;

fn + p: switch to PinYin mode;

fn + e: switch to HeEnglish mode;

fn + r: switch to reset mode;

fn + a: turn Off/On pinyin prompt. 

# More Information about HeInput
1. http://www.hezi.net/He/UserGuide/zh-Hans/Set/BookCover.html

2. http://www.hezi.net/He/UserGuide_Concise/zh-Hans/Set/HeChinese_Guide_Concise.htm


# 一、开源和码输入程序与数据库
苹果电脑上，和码输入程序是基于Mac OS X 10.5 引入的Input Method Kit Framework制作的，程序开始于学习 Apple's NumberInput_IMKit_Sample: 
https://developer.apple.com/library/mac/samplecode/NumberInput_IMKit_Sample/Introduction/Intro.html。

现在是一款完整的和码汉字字形输入软件，有以下输入功能：

1、有三种输入选择：简体汉字(Chinese Simplified)、繁体汉字(Chinese Traditional)，和码英文(HeEnglish)；</br>
2、可用电脑大键盘，与数字小键盘输入；</br>
3、包含21,000多个单字, 180,000多条词组。

和码输入软件还可以从AppStore下载：
（等待审查）

# 二、程序编译与安装
Mac苹果电脑和码开源输入软件，是用XCode 7.2.1开发编译的。获取程序后，可用以下步骤编译与安装OpenHeInput：

1、用XCode打开HeMacOS-Workspace.xcworkspace;

2、选择OpenHeInput project --> OpenHeInput target;

3、编译Build;

4、OpenHeInput-->Products-->OpenHeInput.app, 鼠标右击-->Show in Finder,

5、将OpenHeInput.app文件，拷贝到Mac个人用户的　/Library/Input Methods/ 目录下，然后Log out（退出登录），再登录Log in；

6、打开Mac的System Preferences（系统设置）--> Keyboard（键盘）--> Input Source（输入程序）--> Chinese Simplified（简体汉字）；

7、选择HeInput Simplified（和码简体）, HeInput Traditional（和码繁体）, 或HeEnglish（和码英文）, 任选一种输入方式；

8、打开应用软件，在屏幕北方的输入法列表中，调用和码输入法，就可以用和码输入了。

OpenHeInput.app软件也可以从AppStore下载：</br>
（现在审测）</br>
还可以在以下网页下载：http://www.hezi.net/forum/?g=posts&t=40</br>
再从上述第5步开始进行安装与设置。</br>

# 三、Mac电脑上和码输入软件的使用方法

1、Shift + Space(Character): 切换到纯英文输入方式；

2、fn + Space: 切换到汉字或拼音输入方式，或和码英文输入方式；

3、输入码0(M)，软件显示功能目录，再选择目录项；

4、fn + 字母键进行输入方式转换，如：

fn + e: 转为HeEnglish输入模式(english)；

fn + j, s: 简体字输入(jianTi, simplified Chinese);

fn + f, t: 繁体字输入(fanTi, traditional Chinese);

fn + p: 拼音单字输入(拼音查码)(pinYin);

fn + r: 回复到初始设定(reset)；

fn + a: 开启或 关闭拼音提示(annotation)；

# 四、和码资料
有关和码汉字字形技术，和码输入法的学习资料，可查看：

1、和码线上书：http://www.hezi.net/He/UserGuide/zh-Hans/Set/BookCover.html

2、和码简明教程：http://www.hezi.net/He/UserGuide_Concise/zh-Hans/Set/HeChinese_Guide_Concise.htm

3、和码在Android/iPad/iPhone上的练习与输入软件：http://www.hezi.net/he/HTML/HeChinese_Download.html
