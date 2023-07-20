#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"
MAIN_MENU(){

if [[ $1 ]]
then
    echo -e "\n$1"
fi

#mutasd meg milyen service k vannak
SHOW_SERVICES=$($PSQL "SELECT service_id,name FROM services" )

echo "$SHOW_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
    if [[ $SERVICE_ID != "service_id" ]] 
    then
       echo "$SERVICE_ID) $SERVICE_NAME"
    fi
done


read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~  ^[1-5]+$  ]] 
then 
    MAIN_MENU "I could not find that service. What would you like today?"
else
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED' " | sed 's/ //g' )
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    SELECTED_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $SELECTED_CUSTOMER ]]
    then
     echo "I don't have a record for that phone number, what's your name?"        
     read CUSTOMER_NAME
     echo "What time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME ?"
     read SERVICE_TIME
     echo "I have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
     INSERT_NEU_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
     SELECTED_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
     INSERT_NEU_APPOINTMENT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES ('$SERVICE_TIME','$SELECTED_CUSTOMER_ID','$SERVICE_ID_SELECTED')")
    else
     echo "What time would you like your $SELECTED_SERVICE_NAME, $SELECTED_CUSTOMER ?"
     read SERVICE_TIME
     echo "I have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $SELECTED_NAME."
     SELECTED_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
     INSERT_NEU_APPOINTMENT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES ('$SERVICE_TIME','$SELECTED_CUSTOMER_ID','$SERVICE_ID_SELECTED')")
    fi
 
fi

}

MAIN_MENU
