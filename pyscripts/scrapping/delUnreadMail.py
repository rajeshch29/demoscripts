#!/home/rajesh/projects/scrapping/web_crawling/bin/python3
from imapclient import IMAPClient
import config

mail = IMAPClient('imap.gmail.com', ssl=True, port=993)
mail.login(config.getMailID(), config.getPasswd())
totalMail = mail.select_folder('Inbox')
#Shows how many messages are there - both read and unread
print('You have total %d messages in your folder' % totalMail[b'EXISTS'])
delMsg = mail.search(('UNSEEN'))
mail.delete_messages(delMsg)
#Shows number of unread messages that have been deleted now
print('%d unread messages in your folder have been deleted' % len(delMsg))
mail.logout()
