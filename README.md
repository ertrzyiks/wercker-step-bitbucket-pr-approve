# wercker-approve-bitbucket-pull-request
Approve [bitbucket](http://bitbucket.com) pull request or commit on successful build. Remove approval on failed build.

Based on https://github.com/hyzhak/wercker-step-bitbucket-approve

### Options

* `username` - user name of account which will be wercker bot and will approve commit. (for example: '<owner>-wercker').
* `password` - password of bot user.
* `exclude` - regular expression tested on branch name, step is finished without error on match (optional)

### How to configure?

You should create additional account for wercker bot. And give him permission for reading target repo.

# Example

    build:
        after-steps:
            - ertrzyiks/bitbucket-pr-approve:
                username: my-application-wercker
                password: $WERCKER_BITBUCKET_USER_PASSWORD
                exclude: ^(master|dist)$

# License

The MIT License (MIT)

Copyright (c) 2015 Mateusz Derks

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Changelog

## 0.0.4
- fix exiting from step with error on exclude match

## 0.0.3
- add exclude option

## 0.0.2
- initial version
