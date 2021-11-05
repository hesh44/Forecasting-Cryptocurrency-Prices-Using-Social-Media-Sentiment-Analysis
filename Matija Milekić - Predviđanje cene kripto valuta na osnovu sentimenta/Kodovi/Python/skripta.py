import requests
import json
import time
import re
import pandas
import openpyxl

start = 1501545600
end = 1501631999

dates = []
comments = []
scores = []
positive_sentiment = []
negative_sentiment = []
positive_slash_negative = []
sentiment_score = []

p = open("positive.txt", 'r')
n = open("negative.txt", 'r')

x = p.read().split("\n")
y = n.read().split("\n")

u = {"name": "Matija", "surname": "Milekic"}

print(u)

# example = "Something. Please, Work! ,This Somehow;"
# result = re.sub('[,.!?;:]',' ',example)
# print(result)

# print(len(x))
# print(len(y))

i = 1
while i < 365:
    url = 'https://api.pushshift.io/reddit/submission/search/?after=' + str(start) + '&before=' + str(
        end) + '&sort_type=score&sort=desc&subreddit=Bitcoin&category=best&size=30'
    r = requests.get(url)

    # Data export from the Response
    responseData = r.json()
    data = responseData['data']

    # j = 1
    counter = 0
    positive_score = 0
    negative_score = 0
    total_score = 0
    total_comments = 0
    for post in data:
        # print("\n#################################START##################################################")
        # Data export from the post
        post_id = post['id']
        title = post['title']
        comment = post['num_comments']
        score = post['score']
        if 'selftext' not in post:
            text = ""
        else:
            text = post['selftext']

        total_score = total_score + score
        total_comments = total_comments + comment

        positive_counter = 0
        negative_counter = 0
        # TITLE ANALYSYS
        title = re.sub('[,.!?;:]', ' ', title)
        words_title = re.findall(r"[\w']+", title)
        for word in words_title:
            for positive_word in x:
                if positive_word == word.lower():
                    positive_counter = positive_counter + 1
                    break
            for negative_word in y:
                if negative_word == word.lower():
                    negative_counter = negative_counter + 1
                    break

        # IF TEXT AVAILABLE TEXT ANALYSYS
        if text != "":
            # print("\n#################################START##################################################")
            text = re.sub('[,.!?;:]', ' ', text)
            words_text = re.findall(r"[\w']+", text)

            positive_counter = 0
            negative_counter = 0

            for word in words_text:
                for positive_word in x:
                    if positive_word == word.lower():
                        positive_counter = positive_counter + 1
                        break
                for negative_word in y:
                    if negative_word == word.lower():
                        negative_counter = negative_counter + 1
                        break
            # print(str(j)+". =========>>>> Pos("+str(positive_counter)+") Neg("+str(negative_counter)+")")
            # j=j+1
            # print("#################################END####################################################\n")

        # print(title+" =========>>>> Pos("+str(positive_counter)+") Neg("+str(negative_counter)+")")
        # print(j)
        # print(post_id)
        # print(title)
        if text == "":
            counter = counter + 1
        # if text != "":
        # print("There is text")

        # else:
        # print("No text")
        # counter = counter + 1
        # print(score)
        # print(comments)
        # j = j + 1
        positive_score = positive_score + positive_counter
        negative_score = negative_score + negative_counter
        # print("#################################END####################################################\n")
        ###

    date = time.strftime('%Y-%m-%d', time.localtime(start))

    dates.append(date)
    comments.append(str(total_comments))
    scores.append(str(total_score))
    positive_sentiment.append(str(positive_score))
    negative_sentiment.append(str(negative_score))
    positive_slash_negative.append(str(positive_score / negative_score))
    sentiment_score.append(str(positive_score - negative_score))

    day = {"date": date, "positive score": positive_score, "negative score:": negative_score}
    print(day)
    # print(str(i)+". Score on "+str(date)+" is Pos("+str(positive_score)+") Neg("+str(negative_score)+")")
    # print("Number of posts without text: "+ str(counter)+ "/"+str(len(data))+" on " + str(date) + " --> " + str(counter/len(data)) + "% of without text")
    i = i + 1
    start += 86399
    end += 86399

new_dataframe = pandas.DataFrame(
    {
        "Date": dates,
        "Num of comments on 30 posts": comments,
        "Score on 30 posts": scores,
        "Positive Sentiment": positive_sentiment,
        "Negative Sentiment": negative_sentiment,
        "P/N": positive_slash_negative,
        "Sentiment Score": sentiment_score
    }
)

writer = pandas.ExcelWriter('output.xlsx')
new_dataframe.to_excel(writer, 'Sheet1')
writer.save()
