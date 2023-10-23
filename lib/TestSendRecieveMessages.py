import json
import requests

# Define your phone number ID, access token, and the recipient's phone number
phone_number_id = "163959690131871" # Phone number ID provided
access_token = "EAAKL40FZATe4BOx9UgpKNK5BZCioJ9TCcbWhvZBNsX8zrefh6zsbcVCb1AIMhzLQgw2GAoefnvfmRSUTn0dL045EmJoL8iVtMeWNb61qeIF6fdkjZA94fYdX0KoHfOQsllINlYBISSUlG5zvTwVmsawysHewqLq5cgy99Q2pYoQoBS8pGzz4z8Bg88rabzFBPA9aOJomVJRwZCPZBwsOkZD" # Your temporary access token
recipient_phone_number = "97334466419" # Your own phone number

# Define the URL for the POST HTTP request and the headers for this request
url = f"https://graph.facebook.com/v17.0/{phone_number_id}/messages"
headers = {
    "Authorization": f"Bearer {access_token}",
    'Content-Type': 'application/json'
}

# Define the parameters for the WhatsApp message
data = {
    'messaging_product': 'whatsapp',
    'to': recipient_phone_number,
    'type': 'template',
    'template': {
        'name': 'hello_world',
        'language': {
            'code': 'en_US'
        }
    }
}

# Make the POST request with the URL, headers, and message body
response = requests.post(
    url,
    headers=headers,
    data=json.dumps(data)
)

# Check if the request was successful
if response.ok:
    print("Message sent successfully!")
else:
    print("Failed to send the message.")
