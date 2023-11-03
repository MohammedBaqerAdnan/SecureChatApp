import json
import requests

# Define your phone number ID, access token, and the recipient's phone number
phone_number_id = "169999262855512" # Phone number ID provided
access_token = "EAAFN7IE6TUABO4qp6rFaAzaSaHkKogeJ5TSnW6kR3TSMMTPcZBWg3zDvc0kNCsQevKgzMgJOWZAJwbAsureTBdxEim0ZBV8eVDgklUp18ivHky5Vtd3QJ43Y5WGWKVuRiYZC4CEO5kh2CXGxcrQJTPemBifsGhNuh8iVUgy4Qzczah0JE6JT7TKzvffwhd5ljGJGH53tBOyEnWA6YZBDl" # Your temporary access token
recipient_phone_number = "97333407786" # Your own phone number

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
