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

This bot uses a Rube Goldberg-esque system of Github Actions to work, as this was the quickest path
to done I could get (while still writing tests against Passport Parking's site).

Here's how you set it up:

1. Fork this repository.
2. Go to your repository's settings, then click on "Secrets." Add the three secrets
   below:

   * `env_file_encryption_key`: Key used to decrypt your environment file (see below)

## Local

`docker-compose run --rm parking-bot`
