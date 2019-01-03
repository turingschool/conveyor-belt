# README

## App Setup

App was built using Ruby 2.4.4.

### Environment Variables

The app uses GithHub's API extensively and requires OAuth tokens to make API calls. You'll need to set the following environment variables:

The following two environment variables can be retrieved by registering an OAuth application here: https://github.com/settings/developers

* `GITHUB_KEY` - Can be retrieved from registering an OAuth application on Github. The app running on Heroku is already setup with these but the values there should not be used on your local machine.
* `GITHUB_SECRET` - Can be retrieved from registering an OAuth application on Github. The app running on Heroku is already setup with these but the values there should not be used on your local machine. See above link.
* When running on localhost:3000 you should set the `Homepage URL` to `http://localhost:3000` and the `Authorization callback URL` to `http://localhost:3000/auth/github/callback`

Only used for testing:
`GITHUB_TESTING_USER_TOKEN` - This is a user specific token from GitHub. Tokens can be generated here: https://github.com/settings/tokens

### Starting Your Server

Run through the standard Rails commands:

`$ bundle`
`$ rails db:{create,migrate}`
`$ rails s`

## Testing

Test suite is written using RSpec. API calls are stubbed using VCR. **Please do not delete cassettes from git.** This will make it more difficult for others looking to contribute to run the test suite. There is a `filter_sensitive_data` option used in VCR to filter out tokens and keys. Be sure to update the VCR config block if you add keys or tokens you don't want pushed up to GitHub.
