AntiShake算法思想如下：
1）观察当前接收到的距离值与上一次所接收的距离值，若存在tag与同一基站的两次距离，则对此距离求均值，否则取当前距离。
2）将1）中取得的距离值代入位置解算算法（算法源代码见文档AntiShakePositionSolution.cpp/AntiShakePositionSolution.h），求得tag的坐标值，记为curPos。
3）最终坐标值取加权值：3/4*lastPos + 1/4*curPos
