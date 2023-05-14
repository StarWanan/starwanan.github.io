## Basic Information:

-   Title: Evolutionary Diversity Optimisation for The Traveling Thief Problem （寻找旅行小偷问题的进化多样性优化）
-   Authors: Adel Nikfarjam, Aneta Neumann, and Frank Neumann
-   Affiliation: Adel Nikfarjam - School of Computer Science, The University of Adelaide, Adelaide, Australia （阿德尔·尼克法贾姆 - 阿德莱德大学计算机科学学院，阿德莱德，澳大利亚）
-   Keywords: Evolutionary diversity optimisation, multi-component optimisation problems, traveling thief problem
-   URLs: [https://doi.org/10.1145/3512290.3528862](https://doi.org/10.1145/3512290.3528862) , GitHub: None

### 总结：

-   a. 本文的研究背景：探讨在多元素优化问题中，特别是旅行贼问题（TTP），如何利用进化多样性优化寻找高质量解决方案的重要性和发展。
-   b. 过去的方法、问题和动机：介绍已有的方法，并指出其问题。提出提高多样性的动机及其目标。
-   c. 本文提出的研究方法：使用双层进化算法探索子问题之间的相互依赖性，以最大化 TTP 解决方案的结构多样性。
-   d. 方法在任务和性能方面的表现：比较提出的算法和基于 QD 技术的算法，并在 TTP 基准实例上展示了提出算法的实验结果，在结构多样性方面显著改善了解决方案。

### 背景：

-   a. 主题和特点：探讨在多元素优化问题中，特别是 TTP，如何利用进化多样性优化寻找高质量解决方案的重要性和发展。
-   b. 历史发展：介绍过去的研究和已有的方法。
-   c. 过去的方法：介绍已有的方法，并指出其问题。
-   d. 过去的研究缺陷：指出已有方法存在的问题和不足。
-   e. 需要解决的当前问题：提出提高多样性的动机及其目标。

### 方法：

-   a. 研究的理论基础：使用双层进化算法探索子问题之间的相互依赖性，以最大化 TTP 解决方案的结构多样性。
-   b. 文章的技术路线（逐步）：
    -   采用基于熵（entropy）度量的方法计算其解决方案的结构多样性。
    -   使用 Edge Assembly Crossover（EAX）和 Dynamic Programming（DP）生成高质量 TTP 解决方案。
    -   DP 用于计算 EAX 生成的旅游线路的最佳装箱清单。
    -   算法生成符合质量限制但在结构上不相同的 TTP 解决方案的集合，从而提高了多样性。

### 结论：

-   a. 研究的意义：提出了一种将多样性纳入加强解决方案空间鲁棒性的重要问题，并通过实验证明了提出方法在提高多样性方面显著改善了解决方案。
-   b. 创新、性能和工作负荷：应用双层进化算法，提高了 TTP 解决方案多样性，支持从多样的高质量解决方案中进行选择，改善了解决方案空间的鲁棒性；并提出了未来研究的方向和可以改进的地方。
-   c. 研究结论（列出要点）：提出了一种有效的方法，可以生成一些在质量约束下具有多样性但在结构上不相同的 TTP 解决方案，并使用实验证实了其在结构多样性方面的改进。同时，提出了将该方法应用于现实问题，并结合多目标优化算法来进一步改进的展望。