import os
import json
import pymysql
import requests

def lambda_handler(event, context):
    # Connect to the database
    connection = pymysql.connect(host=os.getenv('DB_HOST'),
                                 user=os.getenv('DB_USER'),
                                 password=os.getenv('DB_PASSWORD'),
                                 db=os.getenv('DB_NAME'))

    try:
        with connection.cursor() as cursor:
            # Execute a SQL query
            sql = "INSERT INTO `repo_operations` (`operationId`, `operationDate`, `operationType`, `note`, `totalAmtAccepted`) VALUES (%s, %s, %s, %s, %s)"

            # Send the GET request
            response = requests.get('https://markets.newyorkfed.org/api/rp/reverserepo/propositions/search.json?startDate=2023-06-23')
            data = response.json()
            operations = data['repo']['operations']

            for operation in operations:
                cursor.execute(sql, (operation['operationId'], operation['operationDate'], operation['operationType'], operation['note'], operation['totalAmtAccepted']))

        connection.commit()
    finally:
        connection.close()
