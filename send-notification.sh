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

spoc_name=""
if [ -n "$5" ]
then
  echo " loading spoc name from args"
  spoc_name=$5
fi

backup_spoc_name=""
if [ -n "$6" ]
then
  echo " loading backup spoc name from args"
  backup_spoc_name=$6
fi

spoc_email=""
if [ -n "$7" ]
then
  echo " loading spoc email from args"
  spoc_email=$7
fi

backup_spoc_email=""
if [ -n "$8" ]
then
  echo " loading backup spoc email from args"
  button_link=$8
fi

# load url from environment setting



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
    "type": "message",
    "attachments": [
        {
        "contentType": "application/vnd.microsoft.card.adaptive",
        "content": {
            "type": "AdaptiveCard",
            "body": [
                {
                    "type": "TextBlock",
                    "size": "Medium",
                    "weight": "Bolder",
                    "text": "msg_title"
                },
                {
                    "type": "TextBlock",
                    "text": "msg_text"
                }
            ],
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.0",
            "msteams": {
                "entities": [
                    {
                        "type": "mention",
                        "text": "<at>spoc_name</at>",
                        "mentioned": {
                          "id": "spoc_email",
                          "name": "spoc_name"
                        }
                      },
                      {
                        "type": "mention",
                        "text": "<at>backup_spoc_name</at>",
                        "mentioned": {
                          "id": "backup_spoc_email",
                          "name": "backup_spoc_name"
                        }
                      }
                ]
            }
        }
    }]
}' 

body=${body/msg_title/$title}
body=${body/spoc_name/$spoc_name}
body=${body/backup_spoc_name/$backup_spoc_name}
body=${body/spoc_email/$spoc_email}
body=${body/backup_spoc_email/$backup_spoc_email}
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
  $TEAMS_WEBHOOK 

if [ "$?" -ne 0 ]
then 
  echo "Error sending webhook"
  exit 1
fi
echo ""
echo "Done"