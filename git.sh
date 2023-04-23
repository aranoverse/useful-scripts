# delete merged branch
git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d

# replace user info
 git filter-repo --name-callback 'return name.replace(b"old", b"new")' && \
 git filter-repo --email-callback 'return email.replace(b"old", b"new")'