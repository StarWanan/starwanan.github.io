乘方差，加均值
```python
img_mean = torch.tensor([0.485, 0.456, 0.406]).reshape(3,1,1)
img_std = torch.tensor([0.229, 0.224, 0.225]).reshape(3,1,1)

image1 = image.cpu().numpy()
show_image1 = tb_tran_image1 * np.array(img_std) + np.array(img_mean)
```
