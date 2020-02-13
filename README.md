# Park and Go Parking Meter Bot

Automatically pays for parking so you can sleep longer 😃

# Why?

While working with a client in Lincoln, NE, I often liked to park my rental car near street parking
by the hotel instead of the parking garage for three reasons:

1. Parking between 6pm-8am was free,
2. Two hour parking sessions were _way_ cheaper for my client than using the garage, and
3. The garage had a manual teller, and I'm not usually functional until about 10:30am!

[3] was the problem with this strategy. 8am is too early for me, but risking getting fined was
worse.

I wanted best of both worlds. This bot is the best of both worlds.

# How do I use it?

There are a few steps involved in getting all of this working. I didn't play when it comes to sleep
:)

This bot is designed to run in GitHub Actions. Here's how you do it.

**READ ALL OF THE CONFIGURATION NOTES BELOW FOR THIS TO WORK.**

## Pay for parking at a later time

To schedule parking for a later time, issue this GitHub dispatch:

```
time_to_park=$(TZ=UTC date -d "@$(date -d 'time_to_park' +%s)" +%s);
curl -v -X POST -H 'Accept: application/vnd.github.everest-preview+json' -H \
  'Authorization: token token_from_step_6' \
  --data "{\"event_type\": \"schedule\", \
          \"client_payload\": {\"zone_number\": \"zone_number\", \
                            \"space_number\": \"space_number\", \
                            \"time\": \"$time_to_park\"}" \
  https://api.github.com/repos/your_username/lincoln-ne-parking-bot/dispatches
```

This will schedule two jobs. The first job will queue your request into a S3 bucket. The second,
which executes every five minutes, will wait until its time is greater than or equal to the time of
your request and then pay for parking on your behalf.

Ensure that `zone_number` and `space_number` are valid zones and spaces, respectively.

## Pay for parking right now

If you want to pay for parking right now, issue the following GitHub dispatch:

```sh
curl -v -X POST -H 'Accept: application/vnd.github.everest-preview+json' -H \
  'Authorization: token token_from_step_6' \
  --data '{"event_type": "execute", "client_payload": {"zone_number": "zone_number", "space_number": "space_number"}' \
  https://api.github.com/repos/your_username/lincoln-ne-parking-bot/dispatches
```

# Configuring the bot

## Create a Passport Parking account

You'll need a Passport Parking account to use this bot. From a web browser:

1. Go to https://ppprk.com/park
2. Click or tap "Get Started"
3. Enter a **Google Voice** phone number and click/tap "Text Me" to get a verification PIN.

   **IMPORTANT**. This bot depends on being able to receive these PINs from
   an email address. At the time, I used a Google Voice number for verification
   and forwarded those emails to the email address for this bot.

   While Passport Parking supports sending PINs to email addresses, I haven't incorporated that
   here.
4. Set up a PIN.
5. Enter the parking zone and space that you're currently parked at.
6. Enter the amount of time you'd like to park for.

   **IMPORTANT**. This bot will always pay for the maximum amount of time available.

7. Add a card to pay with. Save the ID, as you'll need it later.

## Configure Github

This bot uses a Rube Goldberg-esque system of Github Actions to work, as this was the quickest path
to done I could get (while still writing tests against Passport Parking's site).

Here's how you set it up:

1. Fork this repository.
2. Clone this repository to your local machine.
3. `cp .env.example .env` and change the "change me" values to real values.
4. Run `ENV_PASSWORD=foo docker-compose -f docker-compose.deploy.yml run --rm encrypt-env`.
   Replace "foo" with a different password.

   **Note**: Put the name of your credit card from the earlier step into the
   `CREDIT_CARD_ID` field. `ZONE_ID` and `SPACE_NUMBER` are used for unit and integration testing
   only. You don't have to fill them out if you only intend on running this with Actions.

5. In Github, go to your repository's settings, then click on "Secrets." Add the secrets
   below:

   * `env_file_encryption_key`: Key used to decrypt your environment file (`ENV_PASSWORD`), and
   * `queue_bucket`: An AWS S3 bucket to store future runs (see ERRATA for fixes here)
6. Create a Github token with `repo` permission.

## Configure AWS

You will need to create an email address that is capable of receiving forwarded emails from Gmail
(described in the next section). See
[here](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses.html) on
how to do this.

## Configure Google Voice

Next, you'll need to configure Google Voice to forward emails to the email that you created above.

Getting the verification code is a bit tricky with SES. The easiest way to do this is:

1. Create a S3 bucket: `docker-compose -f docker-compose.deploy.yml run --rm aws s3 mb
   s3://my-gmail-verification-codes`

1. Create a receipt rule set: `docker-compose -f docker-compose.deploy.yml run --rm aws ses
   create-receipt-rule-set --rule-set-name foo`

2. Create a receipt rule to send emails to a S3 bucket, like this:

  ```
  docker-compose -f docker-compose.deploy.yml run --rm aws ses create-receipt-rule \
    --rule-set-name foo \
    --rule $(cat <<-JSON
{
  "Name": "gmail-verification-codes",
  "Enabled": true,
  "Recipients": "your@email.address",
  "Actions": [
    {
      "S3Action": {
        "BucketName": "my-gmail-verification-codes"
      }
    }
  ]
}
JSON
)
  ```

3. Re-send the confirmation email, then verify that it landed in the bucket:
   `docker-compose... aws s3 ls s3://my-gmail-verification-codes`

Once you've verified your address, create a filter that finds all emails with
"Your Passport Parking Mobile Pay Code is" and forwards them to the address you created.

## Running it locally

Finally, you can run it locally in two steps:

1. Create infrastructure: `scripts/deploy`
2. Run the bot: `docker-compose run --rm parking-bot`

# Testing

Unit and integration tests are available for you to run.

**Important!** Integration tests _will_ purchase a parking spot on your behalf!

## Unit

`docker-compose run --rm unit`

## Integration

`docker-compose run --rm integration`
