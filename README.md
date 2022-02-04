This module will create two endpoints in the API GATEWAY.

# Create a new short url
POST endpoint-url/short

Body:
```json
{
    "slug":"google",
    "long_url":"https://google.com"
}
```

# Use a short url
GET endpoint-url/{slug}
You will be redirected to this page