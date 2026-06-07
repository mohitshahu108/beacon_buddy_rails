# Beacon Buddy Rails - Getting Started

This guide helps you run the Rails API locally on Fedora.

## Daily Start (After Initial Setup)

Use this every time you start working.

From workspace root, open 3 terminals.

Terminal 1 (Rails API):

~~~bash
cd beacon_buddy_rails
bin/dev
~~~

Terminal 2 (Metro bundler):

~~~bash
cd BeaconBuddyMobile
npm start
~~~

Terminal 3 (Android app):

~~~bash
cd BeaconBuddyMobile
npm run android
~~~

Quick checks:

- Rails health: `curl http://localhost:3000/up`
- Mobile API base URL should be `http://10.0.2.2:3000/api/v1` for emulator
- Emulator must be running before `npm run android`

When all are up, start coding and testing API + app together.

## 1. Prerequisites

Install required system packages.

~~~bash
sudo dnf group install c-development development-tools
sudo dnf install -y \
  git curl openssl-devel readline-devel zlib-devel libyaml-devel libffi-devel \
  gdbm-devel ncurses-devel rust patch gcc-c++ make \
  postgresql-server postgresql-contrib postgresql-devel libpq-devel \
  ImageMagick
~~~

## 2. Ruby Setup

Project Ruby version is 3.3.5.

Choose one Ruby version manager:

### Option A: rbenv

~~~bash
# rbenv (if not installed yet)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
mkdir -p ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add to ~/.zshrc, then restart terminal
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# Install and use project Ruby
rbenv install 3.3.5
rbenv global 3.3.5

# Bundler version used by lockfile
gem install bundler -v 2.7.1
~~~

### Option B: mise

~~~bash
# Install mise from Fedora package (preferred) or upstream
sudo dnf install -y mise

# If dnf package unavailable, use upstream installer:
# curl https://mise.run | sh

# Add mise to ~/.zshrc, then restart terminal
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
exec zsh

# Verify mise
mise --version

# Install and use Ruby 3.3.5 for this project
cd beacon_buddy_rails
mise use ruby@3.3.5
ruby -v

# Bundler version used by lockfile
gem install bundler -v 2.7.1
bundler -v
~~~

## 3. PostgreSQL Setup

~~~bash
# Initialize PostgreSQL database cluster (one time only)
sudo postgresql-setup --initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Verify PostgreSQL is running
sudo systemctl status postgresql
ls -la /var/run/postgresql/

# Create a superuser role for your Linux user
createuser -s "$USER"

# Verify connection
psql -U "$USER" -c "SELECT version();"
~~~

Rails db:prepare task handles database creation automatically.

If PostgreSQL socket not found, try:

~~~bash
sudo systemctl restart postgresql
sleep 2
ls -la /var/run/postgresql/
~~~

## 4. Environment Variables

Create local env file.

~~~bash
cp .env.example .env
~~~

Recommended local defaults in .env:

- EMAIL_DELIVERY_METHOD=letter_opener
- MAILERSEND_API_KEY can stay placeholder for local testing when using letter_opener
- Set GOOGLE_WEB_CLIENT_ID if testing Google sign-in
- If PostgreSQL uses scram/md5 auth locally, also set DB env vars:

~~~env
PGHOST=127.0.0.1
PGPORT=5432
PGUSER=mohitsahu
PGPASSWORD=your_db_password
~~~

## 5. Install Gems and Prepare Database

~~~bash
bundle install
bin/rails db:prepare
~~~

## 6. Run the API

~~~bash
bin/dev
~~~

The API runs on port 3000 by default.

Health check:

~~~bash
curl http://localhost:3000/up
~~~

## 7. Important Local Dev Note

If any request hangs unexpectedly, search for accidental debugger breakpoints and remove them.

## 8. Optional: Run for Physical Device Testing

If mobile app runs on a physical Android device, expose Rails on your LAN:

~~~bash
bin/rails server -b 0.0.0.0 -p 3000
~~~

Then use your Fedora machine LAN IP from the device.

## 9. Common Issues

### PostgreSQL Connection Errors

If you see `connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed`:

~~~bash
sudo systemctl start postgresql
sudo systemctl status postgresql
sudo systemctl restart postgresql
sleep 2
bin/rails db:prepare
~~~

If socket still missing:

~~~bash
sudo -u postgres pg_ctl -D /var/lib/pgsql/data start
sudo systemctl start postgresql
~~~

If you see `Ident authentication failed for user` when connecting with password:

~~~bash
# Find active pg_hba.conf path
sudo -u postgres psql -d postgres -c "SHOW hba_file;"

# Backup config (replace with your hba_file path if different)
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak
~~~

Edit `pg_hba.conf` and make sure these lines are present near the top (before broader rules):

~~~conf
local   all             all                                     scram-sha-256
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
~~~

Then restart PostgreSQL and test password login:

~~~bash
sudo systemctl restart postgresql

PGPASSWORD='your_postgres_password' psql -h 127.0.0.1 -U postgres -d postgres -c "select current_user, current_database();"
PGPASSWORD='your_user_password' psql -h 127.0.0.1 -U "$USER" -d postgres -c "select current_user, current_database();"
~~~

If Rails health check returns 500 with `fe_sendauth: no password supplied`:

~~~bash
# Add DB credentials to .env so Rails can authenticate
echo 'PGHOST=127.0.0.1' >> .env
echo 'PGPORT=5432' >> .env
echo 'PGUSER=mohitsahu' >> .env
echo 'PGPASSWORD=your_db_password' >> .env

# Restart Rails process after env change
bin/rails db:prepare
bin/dev
~~~

### Ruby and Gem Issues

- pg gem fails to compile: ensure postgresql-devel and libpq-devel are installed.
- Ruby build fails: verify openssl-devel and readline-devel are installed.

### Email and Auth Issues

- Email verification fails: switch to EMAIL_DELIVERY_METHOD=letter_opener for local work.
- Google login fails: mobile web client id and backend GOOGLE_WEB_CLIENT_ID must match.
- Login requests hang: remove or comment out `binding.pry` from auth_controller.rb line 134.
