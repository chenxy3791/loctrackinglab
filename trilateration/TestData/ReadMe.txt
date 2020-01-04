这里，将给出5点说明。

1、数据来源
当前文件夹内保存的是TWR策略下一个tag的相关定位数据。测量工具有桌面数据采集软件、基站板子、标签板子、监听板子、数据线等。

2、文件命名规则

每一个文件的命名规则及含义如下：
4/6基站_定位解算算法_有/无遮挡_运动/静止

其中，
4anchors，是指有4个固定基站参与组网。
6anchors，是指有6个基站参与组网的情况，我们会根据一定条件，选择其中表现较好的4个基站与tag的距离值，来进行最终tag的位置解算。

定位解算算法目前有两个，一是decawave提供的三角定位算法，简称trilateration，二是Nick给出的算法,简称antiShake。



3、文件内的数据格式说明

timestamp, 硬件driver给出的时间戳，单位ms
tag_id, tag的ID编号
tag_x, tag的坐标x
tag_y,  tag的坐标y
anchor0_id, anchor0的ID编号
anchor1_id, anchor1的ID编号
anchor2_id, anchor2的ID编号
anchor3_id, anchor3的ID编号
range0, tag与anchor0的距离值
range1, tag与anchor1的距离值
range2, tag与anchor2的距离值
range3, tag与anchor3的距离值
anchor0_x,anchor0的坐标x
anchor0_y,anchor0的坐标y
anchor1_x,anchor1的坐标x
anchor1_y,anchor1的坐标y
anchor2_x,anchor2的坐标x
anchor2_y,anchor2的坐标y
anchor3_x,anchor3的坐标x
anchor3_y,anchor3的坐标y

当上述属性值为0时，表示未参与计算或者解算失败

4、静止时tag的大概位置
无遮挡时，tag的大概位置（18.9,9.505）
有遮挡时，tag的大概位置（15.9,10.15）

5、基站分布的注意点
当采用三角定位解算时，若是排序靠前的三个基站分布在一条直线上，那么计算时往往会没有解。见文件夹“三个基站在一条线上时的数据”下的数据。
