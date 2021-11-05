#!/usr/bin/env python
# coding: utf-8

# In[9]:


import pandas as pd
df = pd.read_excel(r'C:\Users\Korisnik\trend excel\mergeXRPdtp.xlsx', sheet_name='Voted Score+Price per Hour')


# In[10]:


df = df.drop([0], axis = 0)
df = df.reset_index(drop=True)


# In[11]:


df.tail()
df = df.drop([2017], axis = 0)


# In[12]:


Promena = [0 for i in range(len(df))]

i = 0
while i < len(df):
    Promena[i] = df.at[i, 'XRP close value'] - df.at[i, 'XRP open value']
    i += 1
    
df['Promena'] = Promena


# In[ ]:





# In[13]:


import numpy as np
Znak = [0 for i in range(len(df))]

Znak = np.sign(df['Promena'])
Znak.head()

df['Znak'] = Znak


# In[14]:


PrethodniTrend  = [0 for i in range(len(df))]

i = 23
while i < len(df):
    series = df['Znak'][i-23:i+1]
    price_last_point = df.at[i, 'XRP close value']
    price_first_point = df.at[i-23, 'XRP open value']
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


# In[15]:


ZnakPrethodni = np.sign(df['Prethodni Trend'])

df['Znak Prethodni'] = ZnakPrethodni


# In[16]:


BuducaPromena = [0 for i in range(len(df))]

i = 11
while i < len(df):
    price_last_point = df.at[i, 'XRP close value']
    price_first_point = df.at[i-11, 'XRP close value']
    BuducaPromena[i-11] = round(((price_last_point - price_first_point)/price_first_point)*100, 2)
    i += 1

df['Buduca Promena'] = BuducaPromena


# In[17]:


ZnakBuduca = np.sign(df['Buduca Promena'])
df['Znak Buduca'] = ZnakBuduca


# In[18]:


writer = pd.ExcelWriter('TrendXRP1.xlsx')
df.to_excel(writer, 'Sheet1')
writer.save()

