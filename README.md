Gitlab Asana Hook
=================

>**Note**: I've [submitted a PR to the official Gitlab repository](https://github.com/gitlabhq/gitlabhq/pull/7394) to integrate Asana as a service in Gitlab. As soon as this PR will be merged, this *gitlab-asana-hook* won't be necessary.

This is a hook that we use to post to Asana whenever we push to a GitLab repository:

  - it will post a message when you mention a task ID in your commit, like `This commit is about #1234566776`
  - it will close a task when you mention something about fixing it, like `This commit fixes #12342134213`

To use this simply fill out the Asana token in `env.rb` file. You can find your Asana token here: http://app.asana.com/-/account_api

Run this app from any machine like so: `ruby gitlab-hooks.rb -e production`
