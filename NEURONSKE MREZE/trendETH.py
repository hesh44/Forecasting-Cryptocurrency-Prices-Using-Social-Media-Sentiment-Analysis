#!/usr/bin/env python
# coding: utf-8

# In[25]:


import pandas as pd
df = pd.read_excel(r'C:\Users\Korisnik\trend excel\mergeETHdtp.xlsx', sheet_name='Voted Score+Price per Hour')
df.head()


# In[26]:


df.tail()
df = df.drop([2780,2781], axis = 0)


# In[27]:


Promena = [0 for i in range(len(df))]

i = 0
while i < len(df):
    Promena[i] = df.at[i, 'ETH close value'] - df.at[i, 'ETH open value']
    i += 1
    
print(Promena)
df['Promena'] = Promena


# In[28]:


df.head()


# In[29]:


import numpy as np
Znak = [0 for i in range(len(df))]

Znak = np.sign(df['Promena'])
Znak.head()
print(Znak)

df['Znak'] = Znak
df.head()


# In[30]:


PrethodniTrend  = [0 for i in range(len(df))]

i = 23
while i < len(df):
    series = df['Znak'][i-23:i+1]
    price_last_point = df.at[i, 'ETH close value']
    price_first_point = df.at[i-23, 'ETH open value']
    if (price_last_point - price_first_point)>0:
        if series.sum() > 0:
            PrethodniTrend[i] = round(((price_last_point - price_first_point)/price_first_point)*100, 2)
    elif (price_last_point - price_first_point)<0:
        if series.sum() < 0:
            PrethodniTrend[i] = round(((price_last_point - price_first_point)/price_first_point)*100, 2)
    else:
        PrethodniTrend[i] = 0
    i += 1

df['Prethodni Trend'] = PrethodniTrend


# In[31]:


ZnakPrethodni = np.sign(df['Prethodni Trend'])

df['Znak Prethodni'] = ZnakPrethodni


# In[32]:


BuducaPromena = [0 for i in range(len(df))]

i = 11
while i < len(df):
    price_last_point = df.at[i, 'ETH close value']
    price_first_point = df.at[i-11, 'ETH close value']
    BuducaPromena[i-11] = round(((price_last_point - price_first_point)/price_first_point)*100,2)
    i += 1

df['Buduca Promena'] = BuducaPromena
df.head()


# In[33]:


ZnakBuduca = np.sign(df['Buduca Promena'])
df['Znak Buduca'] = ZnakBuduca


# In[34]:


writer = pd.ExcelWriter('TrendETH1.xlsx')
df.to_excel(writer, 'Sheet1')
writer.save()


# In[ ]:




