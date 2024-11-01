import matplotlib
# matplotlib.use('Agg')  # 或者 'GTK3Agg' 等其他后端
import matplotlib.pyplot as plt

# 示例数据
x = [1, 2, 3, 4, 5]
y = [2, 3, 5, 7, 11]

# 创建折线图
plt.plot(x, y, marker='o', linestyle='-', color='b', label='示例数据')

# 添加标题和标签
plt.title('简单折线图示例')
plt.xlabel('X轴')
plt.ylabel('Y轴')

# 添加图例
plt.legend()

# 显示网格
plt.grid(True)

# 显示图形
plt.show()