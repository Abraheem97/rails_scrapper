# 🕷️ Web Scraper App (Rails + Docker)

This is a lightweight, API-style Ruby on Rails application that scrapes public web pages using CSS selectors or meta tags. It accepts a URL and field configuration in JSON format, fetches the content, and returns the extracted data in structured JSON.

---

## 🎥 Screenshots
![image](https://github.com/user-attachments/assets/c5ef573f-527a-4a1f-890e-dd9b2c11c16b)


## 🚀 Features

- ✅ Accepts **GET** and **POST** scraping requests
- ✅ Pass custom **CSS selectors or meta tag names**
- ✅ Supports meta tags (`keywords`, `twitter:image`, etc.)
- ✅ Caching with `Rails.cache` to avoid redundant downloads
- ✅ Uses `HTTParty` + stealth headers to reduce blocking
- ✅ Debug output via `debug.html` for inspection
- ✅ Fully Dockerized — zero local setup needed

---

## 🌐 Example Usage

### 🔗 Recommended Test URL:

Amazon product page:  
`https://www.amazon.com/dp/B08N5KWB9H`

### 🧾 Sample JSON Fields

```json
{
  "meta": ["description"],
  "title": "title",
  "tags": "h1"
}
```

---

## ⚙️ Setup Instructions (Docker)

### 1. Clone the repository

```bash
git clone https://github.com/Abraheem97/rails_scrapper.git
cd rails_scrapper
```

### 2. Build the Docker container

```bash
docker-compose build
```

### 3. Start the Rails app

```bash
docker-compose up
```

Now visit:  
🔗 http://localhost:3000

---

## 🧪 How to Use

Use the built-in UI to test any site:

- Input the target URL
- Input the field configuration (CSS selectors and/or meta array)
- View JSON response instantly

Example fields:
```json
{
  "meta": ["description"],
  "title": "title",
  "tags": "h1"
}
```

---

## 📦 Internals

### 🔍 Scraper Logic

Defined in: `app/services/scraper_service.rb`

Uses `HTTParty` with custom headers and caching:

```ruby
Rails.cache.fetch("scraped_html:#{@url}", expires_in: 1.hour)
```

### ❗ CAPTCHA Note

Some websites (like Alza.cz) may return CAPTCHA intermittently. In these cases, the response is skipped and an error is returned. For best results, test with stable URLs like **Amazon.com** product pages.

---

## 🧰 Development Tools

### Run the app with debugging enabled:
```bash
docker-compose run --service-ports web
```

### See rendered HTML output:
```bash
start debug.html   # Windows
open debug.html    # macOS/Linux
```

---

## 🧪 Running Specs

RSpec is configured for service-level testing.

To run all tests:

```bash
docker-compose run web bundle exec rspec
```

To run a specific spec file:

```bash
docker-compose run web bundle exec rspec spec/services/scraper_service_spec.rb
```

RSpec output will display passing, failing, and pending examples. Make sure your container is built and dependencies are installed before running tests.


---

## 🧼 Linting with RuboCop

To lint your code:
```bash
docker-compose run web bundle exec rubocop
```

---

## 📤 Deployment

This app runs entirely from memory and does not require a database.

---
