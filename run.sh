#!/bin/bash
if [ ! -n "$WERCKER_BITBUCKET_APPROVE_PASSWORD" ]; then
  fail 'Missing password property'
fi

if [ ! -n "$WERCKER_BITBUCKET_APPROVE_USERNAME" ]; then
  fail 'Missing username property'
fi

if [ -n "$DEPLOY" ]; then
  fail 'Should be used for build steps'
fi

RESULT=`curl -u $WERCKER_BITBUCKET_APPROVE_USERNAME:$WERCKER_BITBUCKET_APPROVE_PASSWORD -s "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/pullrequests?pagelen=50"  --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`
echo $(cat result.txt | $WERCKER_STEP_ROOT/bin/jq ".values[] | { id, hash: .source.commit.hash } | select(.hash == \"$WERCKER_GIT_COMMIT\")");
