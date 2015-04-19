#!/bin/bash
if [ ! -n "$WERCKER_BITBUCKET_PR_APPROVE_PASSWORD" ]; then
  fail 'Missing password property'
fi

if [ ! -n "$WERCKER_BITBUCKET_PR_APPROVE_USERNAME" ]; then
  fail 'Missing username property'
fi

if [ -n "$DEPLOY" ]; then
  fail 'Should be used for build steps'
fi

function verifyResult {
  if [ "$RESULT" = "401" ]; then
    fail "Invalid username or password"
  fi

  if [ "$RESULT" = "404" ]; then
    fail "Subdomain or token not found."
  fi

  if [ "$RESULT" = "500" ]; then
    if grep -Fqx "No token" $WERCKER_STEP_TEMP/result.txt; then
      fail "No token is specified."
    fi

    if grep -Fqx "No hooks" $WERCKER_STEP_TEMP/result.txt; then
      fail "No hook can be found for specified subdomain/token"
    fi

    if grep -Fqx "Invalid channel specified" $WERCKER_STEP_TEMP/result.txt; then
      fail "Could not find specified channel for subdomain/token."
    fi

    if grep -Fqx "No text specified" $WERCKER_STEP_TEMP/result.txt; then
      fail "No text specified."
    fi

    fail "Unknown error."
  fi
}

function doGetRequest {
  RESULT_CODE=`curl -u $WERCKER_BITBUCKET_PR_APPROVE_USERNAME:$WERCKER_BITBUCKET_PR_APPROVE_PASSWORD -s $1 --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`
  RESULT_BODY=$(cat $WERCKER_STEP_TEMP/result.txt);

  verifyResult
}

function doPostRequest {
  RESULT_CODE=`curl -d "" -u $WERCKER_BITBUCKET_PR_APPROVE_USERNAME:$WERCKER_BITBUCKET_PR_APPROVE_PASSWORD -s $1 --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`
  RESULT_BODY=$(cat $WERCKER_STEP_TEMP/result.txt);

  verifyResult
}

function doDeleteRequest {
  RESULT_CODE=`curl -X DELETE -u $WERCKER_BITBUCKET_PR_APPROVE_USERNAME:$WERCKER_BITBUCKET_PR_APPROVE_PASSWORD -s $1 --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`
  RESULT_BODY=$(cat $WERCKER_STEP_TEMP/result.txt);

  verifyResult
}

doGetRequest "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/pullrequests?pagelen=50"
PULL_REQUEST_ID=$(echo $RESULT_BODY | $WERCKER_STEP_ROOT/bin/jq ".values[] | { id, hash: .source.commit.hash } | select(.hash == \"${WERCKER_GIT_COMMIT:0:12}\")| .id")
echo "Pull request: # $PULL_REQUEST_ID";

if [ "$WERCKER_RESULT" = "passed" ]; then
  if [ -z "$PULL_REQUEST_ID" ]; then
    echo "Pull request not found, approve commit $WERCKER_GIT_COMMIT";
    doPostRequest "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/commit/$WERCKER_GIT_COMMIT/approve"
  else
    echo "Approve pull request $PULL_REQUEST_ID";
    doPostRequest "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/pullrequests/$PULL_REQUEST_ID/approve"
  fi
else
  if [ -z "$PULL_REQUEST_ID" ]; then
    echo "Pull request not found, disapprove commit $WERCKER_GIT_COMMIT";
    doDeleteRequest "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/commit/$WERCKER_GIT_COMMIT/approve"
  else
    echo "Disapprove pull request $PULL_REQUEST_ID";
    doDeleteRequest "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/pullrequests/$PULL_REQUEST_ID/approve"
  fi
fi
