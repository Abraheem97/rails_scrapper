FROM ruby:3.2.2

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  curl \
  nodejs \
  yarn \
  libvips \
  libnss3 \
  libatk-bridge2.0-0 \
  libxss1 \
  libasound2 \
  libgbm1 \
  libgtk-3-0 \
  libxshmfence1 \
  libxcomposite1 \
  libxrandr2 \
  libxdamage1 \
  libxi6 \
  libgl1 \
  libpangocairo-1.0-0 \
  libpango-1.0-0 \
  fonts-liberation \
  ca-certificates \
  wget \
  chromium

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy app code
COPY . .

# Add bundle bin to PATH
ENV PATH="/usr/local/bundle/bin:$PATH"
ENV BROWSER_PATH="/usr/bin/chromium"

# Expose port 3000
EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]


