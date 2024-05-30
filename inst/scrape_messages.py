import telethon
import time
import asyncio
from telethon import TelegramClient

client = TelegramClient('session_name', api_id, api_hash)

async def scrape_messages(client, channel_id):
    messages = []
    counter = 0
    if n_limit != 0:
      async for message in client.iter_messages(channel_id, wait_time = 3):
          if message.text is None:
              continue
          else:
              sender_id = message.peer_id.channel_id if message.is_channel else message.peer_id.user_id
              raw_text = "" if message.raw_text is None else message.raw_text.replace("\'", "\"")
              messages.append({
                  'channel_name': message.chat.username.lower(),
                  'channel_id': message.chat.id,
                  'title': message.chat.title,
                  'message_id': message.id,
                  'message_views': message.views,
                  'date': str(message.date),
                  'sender_id': sender_id,
                  'message_text': raw_text
              })
              
              counter += 1
              if counter % 100 == 0:
                print(f"Messages scraped: {counter}")
              if counter >= n_limit:
                break
    else:
      async for message in client.iter_messages(channel_id, wait_time = 3):
          if message.text is None:
              continue
          else:
              sender_id = message.peer_id.channel_id if message.is_channel else message.peer_id.user_id
              raw_text = "" if message.raw_text is None else message.raw_text.replace("\'", "\"")
              messages.append({
                  'channel_name': message.chat.username.lower(),
                  'channel_id': message.chat.id,
                  'title': message.chat.title,
                  'message_id': message.id,
                  'message_views': message.views,
                  'date': str(message.date),
                  'sender_id': sender_id,
                  'message_text': raw_text
              })
            
              counter += 1
              if counter % 100 == 0:
                print(f"Messages scraped: {counter}")
    return messages


async def scrape_more_channels(client, channel_links):
    all_messages = []
    for channel_id in channel_links:
        print(f"Scrape Channel: {channel_id}")
        messages = await scrape_messages(client, channel_id)
        all_messages.extend(messages)
        await asyncio.sleep(2)
    return all_messages


def main(channel_links):
    with client:
        try:
          messages_list = client.loop.run_until_complete(scrape_more_channels(client, channel_links))
        except telethon.errors.FloodWaitError as e:
          print("FloodWaitError: Sleep for " + str(e.seconds))
          time.sleep(e.seconds)
    return messages_list

# Call the function to get messages
all_messages = main(channel_links)
