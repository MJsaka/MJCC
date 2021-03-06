# MJCC


## 简介
**MJCC** 是一个类似带记忆功能的计算器软件，它可以让你将一些常用的计算过程保存为公式，在公式中将每次计算时取值会变化的部分定义为变量，这样每次打开该公式，只需输入变量的值，即可求出所需的结果。

## 语法

### 句子

每个公式可以包含很多的句子，每个句子的形式为: “**变量 = 表达式;**”。

每个句子必须由一个**变量**开头，之后跟一个等号"**=**"，再跟一个**表达式**，并以分号**;**结尾。

### 变量

**变量**是以一对花括号“**{}**”包含一个名字的方式来定义，如**{a}**定义了一个名称为**a**的变量，变量可以引用，即：某句子里出现的变量也可以出现在其他句子中，且他们代表同一个变量，因此一个变量可能有以下三种情况：

1.  **结果变量**: 某变量只在唯一某个句子的等号左边出现过，刚该变量是一个**结果变量**，在公式计算时，需要根据该句子等号右侧的表达式来求取该变量的值，并且其值将被软件显示在计算结果列表中。
2.  **输入变量**: 某变量只在任意句子的等号右边出现过，刚该变量是一个**输入变量**，软件会为每一个**输入变量**生成一个输入框，在公式计算前，用户必须输入该变量的值，才可以对公式进行计算。
3.  **中间变量**: 某变量在唯一某个句子的等号左边出现过，且在其他句子的等号右边出现过，则该变量是一个**中间变量**，软件不会为**中间变量**生成输入框，也不会在计算结果列表中显示出**中间变量**的值。

**注意**：一个变量不能同时出现在同一个句子等号的左边和右边(**自引用**)，也不能同时出现在多个句子的左边(**重复计算**)。

### 表达式
**表达式**是一个可计算的数学计算式，由**运算符**、**数字**、**常量**、**变量**、**(反)三角函数**、**对数函数**、**括号()**、**逗号,**等结合而成。

### 运算符
**运算符**包括**加法+**、**减法-**、**乘法\***、**除法/**、**乘方^**、**开方~**、**阶乘!**、**双阶乘!!**等八个。其中:

*  **阶乘!**、**双阶乘!!**运算符只能用在整数后面。
*  **乘方运算符^**表示的意义举例：表达式a^b中，a为底数，b为指数。
*  **开方运算符~**表示的意义举例：表达式a~b中，若a~b的结果为c，则a = c^b。

### 数字
**数字**包括整数和实数。

### 常量
**常量**包括PI、e，PI表示圆周率，e表示自然常数。

### (反)三角函数
**三角函数包括**sin、cos、tan、cot。**反三角函数**包括asin、acos、atan、acot。

### 对数函数
**对数函数**包括lg、ln、lb、log，其中lg是以10为底的对数，ln是自然对数，lb是以2为底的对数，log是以任意数为底的对数，用法为log(x,N)，其中x为底数，N为真数。




