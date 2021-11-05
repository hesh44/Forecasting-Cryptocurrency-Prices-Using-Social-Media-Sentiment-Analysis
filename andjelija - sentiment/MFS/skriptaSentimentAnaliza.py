#!/usr/bin/env python
# coding: utf-8

# In[14]:


import requests
import json
import time
import re
import pandas
import openpyxl
import nltk
nltk.download('vader_lexicon')
from nltk.sentiment.vader import SentimentIntensityAnalyzer

sid = SentimentIntensityAnalyzer()

start = 1501545600
end = 1501631999

text_sentiments = [0] * 30 
dates = []
#vote_sentiments = [] 
print(text_sentiments)


i = 0
while i < 30:
    url = 'https://api.pushshift.io/reddit/submission/search/?after='+str(start)+'&before='+str(end)+'&sort_type=score&sort=desc&subreddit=Bitcoin&category=best&size=30'
    r = requests.get(url)
    
    #Data export from the Response
    responseData = r.json()
    data = responseData['data']
    
    title_score = 0
    voted_score = 0
    for post in data:
        #Data export from the post
        title = post['title']
        score = int(post['score'])
        
        title_score = sid.polarity_scores(title)['compound']
        #print('title_score: ' + str(title_score))
        voted_score = title_score * (1+score*0.2)
        #print(voted_score)
        text_sentiments[i] += voted_score
    
    print('day: ' + str(i+1) + ' sentiment: ' + str(text_sentiments[i]))     
    
    date = time.strftime('%Y-%m-%d', time.localtime(start))
    dates.append(date)
    
    i+=1
    start+=86399
    end+=86399
    
new_dataframe = pandas.DataFrame(
    {
                                 "Date": dates,
                                 "Sentiment Score": text_sentiments
    }
)

writer = pandas.ExcelWriter('output2021.xlsx')
new_dataframe.to_excel(writer,'Sheet1')
writer.save()        
 

