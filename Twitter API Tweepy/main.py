import math
import re
import time
from datetime import timedelta
import pandas as pd
import tweepy

api_key = '3TOrnSFirZPbAzoRb106gCPXw'
api_key_secret = 'odAOk4rawL7gfQg6BqNn01QaiAgeKmKEhA9XOvtuRqQgp4XV8R'
access_token = '700585605407715328-FbnSRutcuPbGpJEJdAAZVoLVdKsvj5k'
access_token_secret = 'jewWQX6nyePLFroqhDNWDMyj4jniRVYL3BoGSNfsEObST'

auth_handler = tweepy.OAuthHandler(consumer_key=api_key, consumer_secret=api_key_secret)
auth_handler.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth_handler, wait_on_rate_limit=True)

#search_term = 'btc OR #btc OR bitcoin OR #bitcoin OR $btc'
#search_term = 'eth OR #eth OR ethereum OR #ethereum OR $eth'
search_term = 'xrp OR #xrp OR ripple OR #ripple OR $xrp'

tweet_amount = 500

search = f'#{search_term} -filter:retweets'



# delay koji trenutno nije aktivan
# time.sleep(0)

# popular znaci da izbacuje samo "popularne" tvitove. Nije poznato koji je kriterijum da bi tvit bio "popularan",
# verovatno je u pitanju neki kompleksan algoritam koji tviter ne zeli da otkrije. Extended daje ceo tekst a ne
# skracen na 140 karaktera. Mozda koristan atribut bi bio i result_type='popular', until=, since=
tweets = tweepy.Cursor(api.search, tweet_mode='extended', q=search_term, lang='en', result_type='popular'
                       ).items(tweet_amount)


def prettier_followers_count(fc):
    # math.floor zaokruzuje na donju vrednost
    if math.floor(fc / 1000) > 0:
        if math.floor(fc / 1000000) > 0:
            # kastujem u string kako bih zalepio M uz broj
            return str(round(fc / 1000000, 1)) + 'M'
        else:
            return str(round(fc / 1000)) + 'K'
    return fc


df = pd.DataFrame(columns=['Likes', 'Retweets', 'Time', 'Name', 'Followers count', 'Followers count 2', 'Text'])

for tweet in tweets:
    # final_text = tweet.text.replace('RT', '')
    # if final_text.startswith(' @'):
    #     position = final_text.index(':')
    #     final_text = final_text[position + 2:]
    # if final_text.startswith('@'):
    #     position = final_text.index(' ')
    #     final_text = final_text[position + 2:]
    # analysis = TextBlob(final_text)
    # polarity += analysis.polarity
    # print(tweet.text)
    # print("\n................Likes:", tweet.favorite_count)
    # print("................Retweets:", tweet.retweet_count)
    # # oduzeo sam 2 sata jer iz nekog razloga sat zuri za toliko
    # print("................How long ago:", datetime.now() - tweet.created_at - timedelta(hours=2))
    # print("................Name:", tweet.user.name)
    # print("................Followers count:", followers_count(tweet.user.followers_count))
    # print('\n ------------------------------------------------------------------------------------------------------------------------')

    # oduzeo sam 2 sata jer iz nekog razloga sat zuri za toliko
    tweet_date = tweet.created_at + timedelta(hours=2)


    def cleanText(text):
        text = re.sub(r'@[A-Za-z0-9]+', '', text)  # uklanja @mentions
        text = re.sub(r'RT[\s]+', '', text)  # uklanja RT
        text = re.sub(r'https?:\/\/\S+', '', text)  # uklanja linkove

        return text


    # uzimam samo one koji imaju vise od 1 lajka i ubacujemo u dataframe
    if tweet.favorite_count >= 0:
        df.loc[-1] = [tweet.favorite_count, tweet.retweet_count, tweet.created_at,
                      tweet.user.name, tweet.user.followers_count, prettier_followers_count(tweet.user.followers_count), cleanText(tweet.full_text)]
        df.index += 1
        df = df.sort_values(by='Likes', ascending=False)

df.sort_values(by=['Followers count'], inplace=True, ascending=False)

print(df)



df.to_excel(r'C:\Users\hesh\Desktop\Neuronske mreze\Twitter API Tweepy\data.xlsx', index=False)

# Twitter error response: status code = 429 ako se pijavi ovakva greska, znaci da je prekoracen limit broja zahteva i
# mora da se saceka 15 min ja mislim

# TextBlob je biblioteka koja vec ima svoju bazu pozitivnih i negativnih reci i omogucava da vrednujemo tvitove
# print(polarity)
