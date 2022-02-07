This module will create two endpoints in the API GATEWAY.

# How to use it?
```
module "url-shortener" {
  source  = "anandbhaskaran/url-shortener/aws"
  version = "1.3.2"
}
```

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