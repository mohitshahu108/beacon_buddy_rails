# Email Setup Guide for BeaconBuddy

This guide explains how to configure and test email delivery using MailerSend.

## Prerequisites

- MailerSend account (sign up at https://www.mailersend.com/)
- MailerSend API key

## Getting Your MailerSend API Key

1. Log in to your MailerSend account at https://app.mailersend.com/
2. Navigate to the dashboard
3. Click on your profile/settings
4. Find "API Tokens" or generate a new API token
5. Copy the API key - you'll need it for configuration

## Setting Up Environment Variables

### Development

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` with your MailerSend credentials:
```bash
MAILERSEND_API_KEY=your_actual_api_key_here
MAILERSEND_FROM_EMAIL=trial@yourdomain.mailersend.com  # Use sandbox domain for testing
MAILERSEND_FROM_NAME=BeaconBuddy Team
EMAIL_DELIVERY_METHOD=mailersend
```

### For Local Testing (No Custom Domain Required)

MailerSend provides a free sandbox domain for testing:
- Use the sandbox domain provided in your MailerSend dashboard
- Example: `trial@yourdomain.mailersend.com`
- No domain verification needed
- Emails will be sent to real email addresses

### For Production

1. Verify your custom domain in MailerSend:
   - Go to Domains in MailerSend dashboard
   - Add your domain (e.g., beaconbuddy.com)
   - Add the DNS records provided by MailerSend
   - Wait for verification

2. Update your environment variables:
```bash
MAILERSEND_FROM_EMAIL=noreply@beaconbuddy.com
```

3. For production, use Rails credentials instead of .env:
```bash
rails credentials:edit
```

Add to credentials.yml.enc:
```yaml
mailer_send:
  api_key: your_production_api_key
```

## Switching Between Email Delivery Methods

### Use MailerSend (Real Emails)
```bash
# In .env
EMAIL_DELIVERY_METHOD=mailersend
```

### Use Letter Opener (Browser Preview)
```bash
# In .env
EMAIL_DELIVERY_METHOD=letter_opener
```

Then restart your Rails server.

## Installing Dependencies

```bash
bundle install
```

## Testing Email Delivery

### Test with Letter Opener (Development)

1. Set `EMAIL_DELIVERY_METHOD=letter_opener` in `.env`
2. Restart Rails server
3. Trigger a verification email from the mobile app
4. Email will open in a new browser tab
5. Copy the token from the email

### Test with MailerSend (Real Emails)

1. Set `EMAIL_DELIVERY_METHOD=mailersend` in `.env`
2. Add your MailerSend API key to `.env`
3. Restart Rails server
4. Trigger a verification email from the mobile app
5. Check your email inbox (Gmail, Outlook, etc.)
6. Enter the token from the email in the mobile app

## Testing the Complete Flow

1. Start Rails server: `rails s -b 0.0.2.2:3000`
2. Start ngrok: `ngrok http 3000`
3. Update mobile app config with ngrok URL
4. Run mobile app
5. Click "Sign Up"
6. Enter email address
7. Check email for verification token
8. Enter token in mobile app
9. Set password and complete registration

## Troubleshooting

### Emails Not Sending

- Check that `MAILERSEND_API_KEY` is set correctly
- Verify your API key is active in MailerSend dashboard
- Check Rails logs for error messages
- Ensure `EMAIL_DELIVERY_METHOD=mailersend` is set

### API Key Errors

- Regenerate API key in MailerSend dashboard
- Ensure no extra spaces in .env file
- Restart Rails server after changing .env

### Domain Not Verified (Production)

- Verify DNS records are added correctly
- Wait up to 24 hours for DNS propagation
- Check MailerSend dashboard for verification status

## Monitoring

View email delivery statistics in your MailerSend dashboard:
- Sent emails
- Open rates
- Click rates
- Bounces and complaints

## Security Best Practices

- Never commit `.env` file to version control
- Use different API keys for development and production
- Rotate API keys periodically
- Monitor email delivery for suspicious activity
