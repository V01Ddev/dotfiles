# How I configure git

1. Move to ~
1. rename gitconfig to .gitconfig
1. rename gitconfig-work to .gitconfig-work

# To configure SSH keys

1. Reference [git's documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to create ssh key.
1. Edit `.bashrc` to `eval` they private key, for example:
```
    eval $(keychain --quiet --eval ~/.ssh/git ~/.ssh/work_github) > /dev/null 2>&1
```
Reference `.bashrc`
