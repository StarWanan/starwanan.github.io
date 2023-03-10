邻域评估：找到最好的执行动作

<img src="https://s1.vika.cn/space/2023/03/07/83ea45c932764e8a8d1f82d8031f1c72" alt="image.png" style="zoom:30%;" />

```text
1. 初始化着色方案S
2. 初始化禁忌表T
3. while (not meet stop criteria) do
4.     选取邻域操作中不在禁忌表中的最好操作O
5.     执行操作O，得到新解S'
6.     计算新解S'的适应度F(S')
7.     如果新解S'不在禁忌表中，或者S'在禁忌表中但是F(S')比禁忌表中对应解的适应度值好，则接受新解S'
8.     更新禁忌表T
9. end while
10. 返回最终的着色方案S
```


```cpp
// 初始化着色方案S
Solution S = initial_solution();

// 初始化禁忌表T
TabuList T;

// 循环搜索直到满足停止准则
while (!meet_stop_criteria()) {
    // 获取邻域操作中不在禁忌表中的最好操作O
    Operation O = select_best_operation_not_in_tabu_list(S, T);

    // 执行操作O，得到新解S'
    Solution S_prime = apply_operation(S, O);

    // 计算新解S'的适应度F(S')
    double fitness = calculate_fitness(S_prime);

    // 如果新解S'不在禁忌表中，或者S'在禁忌表中但是F(S')比禁忌表中对应解的适应度值好，则接受新解S'
    if (!T.contains(S_prime) || fitness > T.get_fitness(S_prime)) {
        S = S_prime;
    }

    // 更新禁忌表T
    T.update(S, O);
}

// 返回最终的着色方案S
return S;
```
其中，`Solution`表示着色方案的实现，包括节点的颜色、颜色分配等信息。`TabuList`表示禁忌表的实现，包括添加禁忌状态、查询禁忌状态是否存在、获取禁忌状态的禁忌长度和适应度值等方法。`Operation`表示邻域操作的实现，包括变更节点颜色、交换节点颜色等操作。`select_best_operation_not_in_tabu_list(S, T)`表示从邻域操作中选择不在禁忌表中的最好操作。`apply_operation(S, O)`表示对当前解S应用操作O得到新解S'。`calculate_fitness(S)`表示计算解S的适应度值。`meet_stop_criteria()`表示是否满足停止准则。

