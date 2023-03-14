> [Supervised Contrastive Learning" (and SimCLR incidentally) - Github](https://github.com/HobbitLong/SupContrast)

代码来自上述Github，稍作修改。解决了我在训练过程中出现nan的问题。

原代码出现NaN的可能原因可能是log_prob中有0的情况，导致了log(0)的计算结果为负无穷，而后续的计算操作则会出现NaN。

一种解决方法是通过将logits中的最大值减去一个较大的数，从而使得所有的元素都是负数，这样计算log时就不会出现0。修改后代码：
```python
class SupConLoss(nn.Module):
    """Supervised Contrastive Learning: https://arxiv.org/pdf/2004.11362.pdf.
    It also supports the unsupervised contrastive loss in SimCLR"""
    def __init__(self, temperature=0.07, contrast_mode='all',
                 base_temperature=0.07):
        super(SupConLoss, self).__init__()
        self.temperature = temperature
        self.contrast_mode = contrast_mode
        self.base_temperature = base_temperature

    def forward(self, features, labels=None, mask=None):
        """Compute loss for model. If both `labels` and `mask` are None,
        it degenerates to SimCLR unsupervised loss:
        https://arxiv.org/pdf/2002.05709.pdf

        Args:
            features: hidden vector of shape [bsz, n_views, ...].
            labels: ground truth of shape [bsz].
            mask: contrastive mask of shape [bsz, bsz], mask_{i,j}=1 if sample j
                has the same class as sample i. Can be asymmetric.
        Returns:
            A loss scalar.
        """
        device = (torch.device('cuda')
                  if features.is_cuda
                  else torch.device('cpu'))

        if len(features.shape) < 3:
            raise ValueError('`features` needs to be [bsz, n_views, ...],'
                             'at least 3 dimensions are required')
        if len(features.shape) > 3:
            features = features.view(features.shape[0], features.shape[1], -1)

        batch_size = features.shape[0]
        if labels is not None and mask is not None:
            raise ValueError('Cannot define both `labels` and `mask`')
        elif labels is None and mask is None:
            mask = torch.eye(batch_size, dtype=torch.float32).to(device)
        elif labels is not None:
            labels = labels.contiguous().view(-1, 1)
            if labels.shape[0] != batch_size:
                raise ValueError('Num of labels does not match num of features')
            mask = torch.eq(labels, labels.T).float().to(device)
        else:
            mask = mask.float().to(device)

        contrast_count = features.shape[1]
        contrast_feature = torch.cat(torch.unbind(features, dim=1), dim=0)
        if self.contrast_mode == 'one':
            anchor_feature = features[:, 0]
            anchor_count = 1
        elif self.contrast_mode == 'all':
            anchor_feature = contrast_feature
            anchor_count = contrast_count
        else:
            raise ValueError('Unknown mode: {}'.format(self.contrast_mode))

        # 首先通过将logits乘上temperature将其还原，然后在计算log_prob时，我们对分母加上了一个较小的常数1e-8，以避免分母为0
        # compute logits
        anchor_dot_contrast = torch.div(
            torch.matmul(anchor_feature, contrast_feature.T),
            self.temperature)
        # for numerical stability
        logits_max, _ = torch.max(anchor_dot_contrast, dim=1, keepdim=True)
        logits = anchor_dot_contrast - logits_max.detach()
        logits = logits * self.temperature  # multiply temperature back

        # tile mask
        mask = mask.repeat(anchor_count, contrast_count)
        # mask-out self-contrast cases
        logits_mask = torch.scatter(
            torch.ones_like(mask),
            1,
            torch.arange(batch_size * anchor_count).view(-1, 1).to(device),
            0
        )
        mask = mask * logits_mask

        # compute log_prob
        exp_logits = torch.exp(logits) * logits_mask
        sum_exp_logits = exp_logits.sum(1, keepdim=True)
        log_prob = logits - torch.log(sum_exp_logits + 1e-8)  # add eps for numerical stability

        # compute mean of log-likelihood over positive
        mean_log_prob_pos = (mask * log_prob).sum(1) / mask.sum(1)
        # loss
        loss = - (self.temperature / self.base_temperature) * mean_log_prob_pos
        loss = loss.view(anchor_count, batch_size)
        loss = loss.mean()
        return loss

```

Use
```python
# Define model, optimizer, and data loader
model = ...
optimizer = ...
train_loader = ...

# Define loss function
criterion = SupConLoss()

# Training loop
for epoch in range(num_epochs):
    for images, labels in train_loader:
        # Forward pass
        features = model(images)
        loss = criterion(features, labels)

        # Backward pass
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
```

温度系数(Temperature coefficient)是一个用于调整相似度度量的超参数，用于平衡样本之间的相似度和差异性。

通常情况下，温度系数的值为0.07或0.1，这些值已被证明在许多自监督学习任务中表现较好。但是，温度系数的最佳值取决于具体的数据集和应用场景。在实践中，通常需要通过实验来确定最佳的温度系数。

调整温度系数会影响SupConLoss的收敛速度和最终性能。
- 较高的温度系数会使样本之间的差异更加显著，从而可能导致更慢的收敛速度。
- 较低的温度系数可能导致样本之间的相似性不够明显，从而影响最终性能。
温度系数是SupConLoss的一个重要超参数，需要根据具体的应用场景进行调整。