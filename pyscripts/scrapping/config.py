
import base64


def getMailID():
  mail_id = ""
  with open('/home/rajesh/scripts/mid', 'r') as file:
    mail_id = file.read()
  return mail_id.strip()

def getPasswd():
  pwd = ""
  with open('/home/rajesh/scripts/passcode', 'r') as file:
    passwd = file.read()
    base64_bytes = passwd.encode('ascii')
    message_bytes = base64.b64decode(base64_bytes)
    pwd = message_bytes.decode('ascii')
  return pwd
