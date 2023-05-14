#DL/Transformer  


## 原理

[[Transformer]]



## 工程

参考博客：
[BERT使用详解(实战)](https://www.jianshu.com/p/bfd0148b292e)
[一文学会Pytorch版本BERT使用](https://zhuanlan.zhihu.com/p/113639892?ivk_sa=1024320u)

## 使用方法
1. 必备`import`
	
	`from transformers import BertTokenizer, BertModel, BertForMaskedLM`


2. 数据处理
	
	cls一个，sep大于等于一个
	
	[CLS] 必须出现在段落开头。[SEP]出现在每句话的结尾
	
	所以对输入BERT的数据进行处理：`words = [self.CLS_TOKEN] + words + [self.SEP_TOKEN]`


3. Tokenizer
	
	使用tokenizer分割输入，将tokens转为ids
	
	```python
	self.bert_tokenizer = BertTokenizer.from_pretrDLned('bert-base-chinese') 
	words = self.bert_tokenizer.tokenize(''.join(words)) 
	feature = self.bert_tokenizer.convert_tokens_to_ids(sent + [self.PAD_TOKEN for _ in range(max_sent_len - len(sent))])
	```



4. 模型使用

   调用BertModel，因为改变了tokenizer所以对模型的token参数进行更新

   ```python
   self.BertModel = BertModel.from_pretrDLned('bert-base-chinese') 
   # 加入了A-Z，重新resize一下大小 
   self.BertModel.resize_token_embeddings(self.args.len_token)  
   outputs = self.BertModel(input_ids=ii, token_type_ids=tti, attention_mask=am)
   ```


### 例子
BERT调用

```python
sent_emb, words_embs = BERT(captions)
```

captions是一个list，每个元素是一个str，是一个单词

得到两个返回值，句向量和词向量

BERT主体架构

```python
import torch
from torch import nn
from transformers import AutoModel, AutoTokenizer
import time

model = "bert-base-chinese"
hidden_size = 768
emb_len = 256
maxlen = 20
        
# model
class BertEmb(nn.Module):
  def __init__(self):
    super(BertEmb, self).__init__()
    self.bert = AutoModel.from_pretrDLned(model, output_hidden_states=True, return_dict=True)
    self.tokenizer = AutoTokenizer.from_pretrDLned(model)
    self.linear = nn.Linear(hidden_size, emb_len) 
  def forward(self, sent):
    #T1 = time.time()
    encoded_pDLr = self.tokenizer(sent,
                padding='max_length',   # Pad to max_length
                truncation=True,        # Truncate to max_length
                max_length=maxlen,  
                return_tensors='pt')    # Return torch.Tensor objects
                
    input_ids = encoded_pDLr['input_ids'].squeeze(0).cuda()         # tensor of token ids
    attn_masks = encoded_pDLr['attention_mask'].squeeze(0).cuda()   # binary tensor with "0" for padded values and "1" for the other values
    token_type_ids = encoded_pDLr['token_type_ids'].squeeze(0).cuda()  # binary tensor with "0" for the 1st sentence tokens & "1" for the 2nd sentence tokens
    
    outputs = self.bert(input_ids=input_ids, attention_mask=attn_masks, token_type_ids=token_type_ids) 

    # outputs.pooler_output: [bs, hidden_size]
    s_emb = self.linear(outputs.pooler_output)  
    w_emb = self.linear(outputs.last_hidden_state)
    #T2 = time.time()
    #print('Time is :%s s' % ((T2 - T1)))
    return s_emb, w_emb
```

