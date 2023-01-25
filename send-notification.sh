#!/bin/bash

# load input parameters
title="Message from runner check workflow"
if [ -n "$1" ] 
then
  echo " loading title from args"
  title=$1 
fi

text="This is my test text"
if [ -n "$2" ]
then
  echo " loading text from args"
  text=$2
fi

button="Go to workflow"
if [ -n "$3" ]
then
  echo " loading button from args"
  button=$3
fi

button_link="$GITHUB_SERVER_URL"
if [ -n "$4" ]
then
  echo " loading button link from args"
  button_link=$4
fi

# load url from environment setting
echo "Found this Teams url to work with [$TEAMS_WEBHOOK]"
echo " - title: [$title]"
echo " - message: [$text]"
echo " - button: [$button]"
echo " - button_link: [$button_link]"

# remove first and last char
text=${text//'['/''}
text=${text//']'/''}
# remove double quotes
text=${text//'\"'/''}
text=${text//'"'/''}


if [ ${#text} == 0 ]
then
  echo "Nothing to report"
  exit 0
fi
# add the link as a new line
array=$array', Link: '$button_link

# replace comma's with newlines
text=${text//','/'\n\r'}
array=$text


# real array: 
#array=$(echo $text | tr "," "\n\r")

# docs for this webhook are here: https://docs.microsoft.com/en-us/outlook/actionable-messages/send-via-connectors
# prepare the body
body='{
  "@context": "https://schema.org/extensions",
  "@type": "MessageCard",
  "themeColor": "0072C6",
  "title": "msg_title",
  "text": "msg_text",
  "potentialAction": [
    {
      "@type": "OpenUri",
      "name": "msg_button",
      "targets": [
        { "os": "default", "uri": "msg_buttonlink" }
      ]
    }
  ]
}' 

body=${body/msg_title/$title}
body=${body/msg_text/$array}
body=${body/msg_button/$button}
body=${body/msg_buttonlink/$button_link}

if [ -z "$body" ]
then
  echo "No body found!"
  exit
fi

echo "body = "
echo $body

curl -i \
  -d "$body" \
  -H "Accept: application/json" \
  -H 'Content-Type: application/json' \
  $TEAMS_WEBHOOK

if [ "$?" -ne 0 ]
then 
  echo "Error sending webhook"
  exit 1
fi
echo ""
echo "Done"
