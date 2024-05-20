import boto3
from uuid import uuid4

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('ListaDeContatos')

def add_contact(name, email, phone):
    user_id = str(uuid4())  # Gera um UUID como ID
    table.put_item(Item={'id': user_id, 'name': name, 'email': email, 'phone': phone})
    return user_id

def delete_contact(user_id):
    table.delete_item(Key={'id': user_id})

def get_contacts():
    response = table.scan()
    contacts = response.get('Items', [])
    # Ordena os contatos por data de criação se estiver usando timestamp, ou mantém como está se estiver usando UUID
    return contacts