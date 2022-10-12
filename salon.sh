#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"


SCHEDULE_MENU(){
SERVICES=$($PSQL "select service_id, name from services order by service_id")
echo -e "\nHere are the Services we offer:"
echo "$SERVICES" | while IFS="| " read SERVICE_ID NAME
do
echo "$SERVICE_ID) $NAME"
done
echo -e "\nWhich service would you like?"
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]{1}$ ]]
then
echo "That is not a valid service."
SCHEDULE_MENU
else
SERVICE_AVAILABILITY=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
        echo -e "\nWhat time would you be available for your appointment?"
        read SERVICE_TIME
        INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) values('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
        SERVICE_INFO=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
        SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ |/"/')
        echo "I have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
fi
EXIT
}


EXIT(){
echo -e "\nThank you for stopping by!"
}

SCHEDULE_MENU
