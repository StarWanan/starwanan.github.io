
git 操作练习链接: [Learn Git Branching](https://learngitbranching.js.org/?locale=zh_CN)
git：[Git - Reference (git-scm.com)](https://git-scm.com/docs)

> [git放弃本地文件修改 - 简书 (jianshu.com)](https://www.jianshu.com/p/c0f7e4ac14c7)


## 查看状态
暂存
```sh
git status [file]
```
- 查看本地仓库中是否有未提交或未暂存的更改，可以使用 `git status` 命令。这个命令会显示当前分支的状态，包括未暂存的更改、未提交的更改和未跟踪的文件。
- 只查看某个特定文件是否有未提交或未暂存的更改，可以使用 `git status <file>` 命令。其中 `<file>` 是你要检查的文件的名称。

分支
```sh
git branch [-a|r]
```
- 查看远程仓库中的所有分支，可以使用 `git branch -r` 命令。这个命令会列出远程仓库中所有的分支。
- 查看本地和远程仓库中所有的分支，可以使用 `git branch -a` 命令。




## 主要操作

查看 commit 记录
```sh
git log --graph --oneline
```
完整哈希码的可以用：
```sh
git log --graph --pretty=oneline
```

### 基础
#### commit
提交修改
```sh
git commit [-a|-m "message"]
```
-  `-a`会打开vim编辑器的一个文件，提交修改信息
- `-m "message"` 会直接提交修改信息


#### branch
##### 创建分支
```sh
git branch <branch_name>
```

创建一个新的分支同时切换到新创建的分支
```sh
git checkout -b <branch-name>
```

##### 删除分支
```sh
git branch -[d|D] <branch-name>
```
- git branch -d 会在删除前检查 merge 状态（其与上游分支或者与 head）。  
- git branch -D 是 git branch --delete --force 的简写，它会直接删除。

##### 切换分支
```sh
git checkout <local_branch>
```

在 Git 2.23 版本中，引入了一个名为 git switch 的新命令，最终会取代 git checkout，因为 checkout 作为单个命令有点超载（它承载了很多独立的功能）。


##### 储存分支
```sh
git stash
```

没有暂存更改时想要切换分支，会报错：
```txt
Please commit your changes or stash them before you switch branches.
```


> [Git切换分支-CSDN博客](https://blog.csdn.net/weixin_44422604/article/details/111994539)







#### Merge
合并分支
```sh
git merge <branch-tobe-merge>
```
`git merge`。在 Git 中合并两个分支时会产生一个特殊的提交记录，它有两个父节点。翻译成自然语言相当于：“我要把这两个父节点本身及它们所有的祖先都包含进来。

merge 的时候实是在主要 main 分支上，合并想要合并的分支，然后再转到被合并的分支，合并主分支 main ，直接继承。

#### Rebase
```
git rebase 
```
Rebase 实际上就是取出一系列的提交记录，“复制”它们，然后在另外一个地方逐个的放下去。

Rebase 的优势就是可以创造更线性的提交历史，这听上去有些难以理解。如果只允许使用 Rebase 的话，代码库的提交历史将会变得异常清晰。

Rebase 就是在修改的分支上，直接 rebase 主分支 main 。再切换回 main ，再次 rebase 

![|400](https://s1.vika.cn/space/2023/04/04/6d050495e8cb4ba89ab8304fd7573341)

### 高级: Git 提交树

#### Head

HEAD 通常指向一个分支，但是可以通过提交的==哈希值==把 HEAD 分离出来，指向一个提交记录。HEAD 指向的分支通常用`*`表示，比如 `main*`

```sh
git checkout <Hash-commit>
```

##### 未使用 git add 缓存代码
-   使用 git checkout -- filename，注意中间有--
```sh
git checkout -- filename
```
-   放弃所有文件修改 git checkout .
```sh
git checkout .
```
-   此命令用来放弃掉所有还没有加入到缓存区（就是 git add 命令）的修改：**内容修改与整个文件删除**
-   **此命令不会删除新建的文件，因为新建的文件还没加入git管理系统中，所以对git来说是未知，只需手动删除即可**



#### 相对引用
通过指定提交记录哈希值的方式在 Git 中移动不太方便。在实际应用时，并没有像本程序中这么漂亮的可视化提交树供你参考，所以你就不得不用 `git log` 来查查看提交记录的哈希值。

并且哈希值在真实的 Git 世界中也会更长（译者注：基于 SHA-1，共 40 位）。例如前一关的介绍中的提交记录的哈希值可能是 `fed2da64c0efc5293610bdd892f82a58e8cbc5d8`。

通过哈希值指定提交记录很不方便，所以 Git 引入了相对引用。这个就很厉害了!

使用相对引用的话，你就可以从一个易于记忆的地方（比如 `bugFix` 分支或 `HEAD`）开始计算。

相对引用非常给力，这里我介绍两个简单的用法：
-   使用 `^` 向上移动 1 个提交记录
-   使用 `~<num>` 向上移动多个提交记录，如 `~3`

以下是改变分支指向位置，也就是改变 HEAD 位置。
```sh
git checkout <HEAD|提交记录哈希码>^
```

```sh
git checkout <HEAD|提交记录哈希码>～<num>
```


##### 强制修改分支位置

你现在是相对引用的专家了，现在用它来做点实际事情。

我使用相对引用最多的就是移动分支。可以直接使用 `-f` 选项让分支指向另一个提交。例如:

```sh
git branch -f main HEAD~3
```

上面的命令会将 main 分支强制指向 HEAD 的第 3 级父提交。

`checkout` 就是用来改变当前指向的，也就是改变 HEAD 的位置。而 `branch -f <branch_to_move>` 就是改变指定分支的位置。

#### 撤销变更

在 Git 里撤销变更的方法很多。和提交一样，撤销变更由底层部分（暂存区的独立文件或者片段）和上层部分（变更到底是通过哪种方式被撤销的）组成。我们这个应用主要关注的是后者。

主要有两种方法用来撤销变更 —— 一是 `git reset`，还有就是 `git revert`。接下来咱们逐个进行讲解

##### Reset

`git reset` 通过把分支记录回退几个提交记录来实现撤销改动。你可以将这想象成“改写历史”。`git reset` 向上移动分支，原来指向的提交记录就跟从来没有提交过一样。

让我们来看看演示：

![|250](https://s1.vika.cn/space/2023/04/04/87ff4e4958ff4cda99d074278a841520)

```sh
git reset HEAD~1
```

![250](https://s1.vika.cn/space/2023/04/04/9999b0f90fe545fb9dddc9a9d7eb9486)


漂亮! Git 把 main 分支移回到 `C1`；现在我们的本地代码库根本就不知道有 `C2` 这个提交了。


##### revert
虽然在你的本地分支中使用 `git reset` 很方便，但是这种“改写历史”的方法对大家一起使用的远程分支是无效的哦！

为了撤销更改并**分享**给别人，我们需要使用 `git revert`。来看演示：

![100](https://s1.vika.cn/space/2023/04/04/bf2ff6edf159400cb826aa139fb45c38)

```sh
git revert HEAD
```

![100](https://s1.vika.cn/space/2023/04/04/6d3a3a0a87de4f6193e5438430585c6e)

奇怪！在我们要撤销的提交记录后面居然多了一个新提交！这是因为新提交记录 `C2'` 引入了**更改** —— 这些更改刚好是用来撤销 `C2` 这个提交的。也就是说 `C2'` 的状态与 `C1` 是相同的。

revert 之后就可以把你的更改推送到远程仓库与别人分享啦。


### 整理提交记录

#### Git Cherry-pick

```sh
git cherry-pick <提交号>...
```

这里有一个仓库, 我们想将 `side` 分支上的工作复制到 `main` 分支，你立刻想到了之前学过的 `rebase` 了吧？但是咱们还是看看 `cherry-pick` 有什么本领吧。

栗子：
![200](https://s1.vika.cn/space/2023/04/04/557acfa3a2e54ff7817f2882d4667581)

```sh
git cherry-pick C2 C4
```

![200](https://s1.vika.cn/space/2023/04/04/70dee9d3ebab4d09aa380513e9e9b73a)
这就是了！我们只需要提交记录 `C2` 和 `C4`，所以 Git 就将被它们抓过来放到当前分支下了。就是这么简单!


#### 交互式的 rebase

当你知道你所需要的提交记录（**并且**还知道这些提交记录的哈希值）时, 用 cherry-pick 再好不过了 —— 没有比这更简单的方式了。

但是如果你不清楚你想要的提交记录的哈希值呢? 幸好 Git 帮你想到了这一点, 我们可以利用交互式的 rebase —— 如果你想从一系列的提交记录中找到想要的记录, 这就是最好的方法了

交互式 rebase 指的是使用带参数 `--interactive` 的 rebase 命令, 简写为 `-i`

如果你在命令后增加了这个选项, Git 会打开一个 UI 界面并列出将要被复制到目标分支的备选提交记录，它还会显示每个提交记录的哈希值和提交说明，提交说明有助于你理解这个提交进行了哪些更改。

在实际使用时，所谓的 UI 窗口一般会在文本编辑器 —— 如 Vim —— 中打开一个文件。 考虑到课程的初衷，我弄了一个对话框来模拟这些操作。

当 rebase UI 界面打开时, 你能做3件事:

-   调整提交记录的顺序（通过鼠标拖放来完成）
-   删除你不想要的提交（通过切换 `pick` 的状态来完成，关闭就意味着你不想要这个提交记录）
-   合并提交。 遗憾的是由于某种逻辑的原因，我们的课程不支持此功能，因此我不会详细介绍这个操作。简而言之，它允许你把多个提交记录合并成一个。

```sh
git rebase -i <分支位置>
```
之后在 UI 界面进行操作

### 杂项
#### 本地栈式提交

来看一个在开发中经常会遇到的情况：我正在解决某个特别棘手的 Bug，为了便于调试而在代码中添加了一些调试命令并向控制台打印了一些信息。

这些调试和打印语句都在它们各自的提交记录里。最后我终于找到了造成这个 Bug 的根本原因，解决掉以后觉得沾沾自喜！

最后就差把 `bugFix` 分支里的工作合并回 `main` 分支了。你可以选择通过 fast-forward 快速合并到 `main` 分支上，但这样的话 `main` 分支就会包含我这些调试语句了。你肯定不想这样，应该还有更好的方式……

实际我们只要让 Git 复制解决问题的那一个提交记录就可以了。跟之前我们在“整理提交记录”中学到的一样，我们可以使用

-   `git rebase -i`
-   `git cherry-pick`

来达到目的。

#### 提交的技巧 #1

接下来这种情况也是很常见的：你之前在 `newImage` 分支上进行了一次提交，然后又基于它创建了 `caption` 分支，然后又提交了一次。

此时你想对某个以前的提交记录进行一些小小的调整。比如设计师想修改一下 `newImage` 中图片的分辨率，尽管那个提交记录并不是最新的了。

我们可以通过下面的方法来克服困难：

-   先用 `git rebase -i` 将提交重新排序，然后把我们想要修改的提交记录挪到最前
-   然后用 `git commit --amend` 来进行一些小修改 (修改 commit 记录，覆盖上一次)
-   接着再用 `git rebase -i` 来将他们调回原来的顺序
-   最后我们把 main 移到修改的最前端（用你自己喜欢的方法），就大功告成啦！

当然完成这个任务的方法不止上面提到的一种（我知道你在看 cherry-pick 啦），之后我们会多点关注这些技巧啦，但现在暂时只专注上面这种方法。 最后有必要说明一下目标状态中的那几个`'` —— 我们把这个提交移动了两次，每移动一次会产生一个 `'`；而 C2 上多出来的那个是我们在使用了 amend 参数提交时产生的，所以最终结果就是这样了。

也就是说，我在对比结果的时候只会对比提交树的结构，对于 `'` 的数量上的不同，并不纳入对比范围内。只要你的 `main` 分支结构与目标结构相同，我就算你通过。


#### 提交的技巧 #2

_如果你还没有完成“提交的技巧 #1”（前一关）的话，请先通过以后再来！_

正如你在上一关所见到的，我们可以使用 `rebase -i` 对提交记录进行重新排序。只要把我们想要的提交记录挪到最前端，我们就可以很轻松的用 `--amend` 修改它，然后把它们重新排成我们想要的顺序。

但这样做就唯一的问题就是要进行两次排序，而这有可能造成由 rebase 而导致的冲突。下面还是看看 `git cherry-pick` 是怎么做的吧。

要在心里牢记 cherry-pick 可以将提交树上任何地方的提交记录取过来追加到 HEAD 上（只要不是 HEAD 上游的提交就没问题）。





---

## 远程操作

### clone
```sh
git clone [-b 分支] https://xxx.git
```



### pull
```sh
git pull origin <remote_branch>:<local_branch>
```


### 分支


#### 删除远程分支

```sh
git push [origin] --delete <remote-branch-name>
```

#### 通过远程分支创建本地分支并切换
```sh
git checkout -b <local_branch> origin/<remote_branch>
```
不能直接切换到远程分支，但是你可以在本地创建一个远程分支的副本，然后切换到这个本地分支。具体操作如下：
1.  使用 `git checkout -b <local_branch> origin/<remote_branch>` 命令在本地创建一个远程分支的副本并切换。其中 `<local_branch>` 是你要创建的本地分支的名称，`<remote_branch>` 是远程分支的名称。


#### push 到远程指定分支
```sh
git push origin <local_branch>:<remote_branch>
```
如果远程分支不存在，则创建新远程分支

`push.default` 配置项用来指定当你使用 `git push` 命令但没有指定分支时，Git 应该采取什么行为。

在 Git 2.0 之前，默认值是 `matching`，这意味着 Git 会把本地仓库中所有与远程仓库中同名的分支都推送到远程仓库。从 Git 2.0 开始，默认值更改为 `simple`，这意味着只有当前分支会被推送到远程仓库。

如果你想保留当前的行为（即 `matching`），可以按照警告信息中的提示，使用 `git config --global push.default matching` 命令进行设置。如果你想采用新的默认行为（即 `simple`），可以使用 `git config --global push.default simple` 命令进行设置。








---

## Error



#### Github 取消密码
提示：remote: Support for password authentication was removed on August 13, 2021.

那么久生成一个 token 并且当作密码使用。

1.  之后用自己生成的 token 登录，把上面生成的 token 粘贴到输入密码的位置。

如果 push 等操作没有出现输入密码选项，请先输入如下命令，之后就可以看到输入密码选项了。

```text
git config --system --unset credential.helper
```

1.  把 token 直接添加远程仓库链接中，这样就可以避免同一个仓库每次提交代码都要输入 token 了：

```text
git remote set-url origin https://<your_token>@github.com/<USERNAME>/<REPO>.git
```

-   `<your_token>`：换成你自己得到的 token
-   `<USERNAME>`：是你自己 github 的用户名
-   `<REPO>`：是你的仓库名称




#### master-main 分支拉取报错
```sh
git push -f git@github.com:StarWanan/P-Center.git master
error: src refspec master does not match any
```

由于github的分支名称已经从master --> main，所以代码应该改成：
```sh
git push -f git@github.com:StarWanan/P-Center.git main
```


#### .gitignore失效
参考： [博客园](https://www.cnblogs.com/goloving/p/15017769.html)
.gitignore 文件只是 ignore 没有被 staged(cached) 文件，对于已经被 staged 的文件，加入 ignore 文件时一定要先从 staged 移除
```sh
git rm -r --cached .
git add .
git commit -m "update .gitignore"  // windows使用的命令时，需要使用双引号
```



#### 服务器-github代理问题
报错`GnuTLS recv error (-110): The TLS connection was non-properly terminated`

取消代理即可恢复正常，执行下面的命令即可

```
git config --global --unset http.https://github.com.proxy
```


报错：`fatal: unable to access 'https://github.com/StarWanan/gcp.git/': HTTP/2 stream 1 was not closed cleanly before end of the underlying stream`



在项目文件夹的命令行窗口执行下面代码，然后再 git commit 或 git clone  
取消git本身的https代理，使用自己本机的代理，如果没有的话，其实默认还是用git的
```sh
git config --global --unset http.proxy
git config --global --unset https.proxy
```
