import telethon
import time
import asyncio
from telethon import TelegramClient
from telethon.tl.types import MessageEntityTextUrl

# set the global client variable
def client(api_id, api_hash):
  global client
  client = TelegramClient('session_name', api_id, api_hash)
  
# funtion to scrape messages
def scrape_messages(channel, n, reverse, min_id, max_id, offset_date, verbose):

    async def scrape(client, channel, n, reverse, min_id, max_id, offset_date, verbose):
      
        messages = []
        counter = 0

        async for message in client.iter_messages(channel, 
                                                  wait_time=3, 
                                                  reverse = reverse, 
                                                  min_id = min_id, 
                                                  max_id = max_id,
                                                  offset_date = offset_date):
            if not message.text:
                continue
    
            counter += 1
            
            title = "" if message.is_private else message.chat.title
            views = "" if message.views is None else message.views
            peer_id = message.peer_id.channel_id if message.is_channel else message.peer_id.user_id
            sender_id =  peer_id if message.from_id is None else message.from_id.user_id
            raw_text = "" if message.raw_text is None else message.raw_text.replace("\'", "\"")
            reply_to_message_id = message.reply_to_msg_id if message.is_reply else ""
            
            forward_from = ""
            try:
              forward_from = message.forward.chat.username.lower() if message.forward.chat.username else ""
            except AttributeError:
              pass
            
            if message.entities is None:
              links_inline = ""
            else:
              links_entity = [entity.url for entity in message.entities if isinstance(entity, MessageEntityTextUrl)]
              links_inline = '|'.join(links_entity)
              
        
            messages.append({
            'chat_name': message.chat.username.lower(),
            'chat_id': message.chat.id,
            'title': title,
            'message_id': message.id,
            'is_reply': message.is_reply,
            'reply_to_message_id': reply_to_message_id,
            'message_views': views,
            'date': str(message.date),
            'sender_id': sender_id,
            'message_text': raw_text,
            'forward_from': forward_from,
            'links_inline': links_inline
            })
            
            verbose = verbose
            if verbose and counter % 100 == 0:
                print(f"Progress: {counter} Messages")

            if n > 0 and counter >= n:
                break
              
             
        await asyncio.sleep(2) 
        return messages

    with client:
        try:
            messages_list = client.loop.run_until_complete(scrape(client, channel, n, reverse, min_id,
                                                                   max_id, offset_date, verbose))
        except telethon.errors.FloodWaitError as e:
            print("FloodWaitError: Sleep for " + str(e.seconds))
            time.sleep(e.seconds)

    return messages_list
    
    

