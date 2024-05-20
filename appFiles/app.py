from flask import Flask, request, render_template, redirect, url_for
from dynamo_service import add_contact, delete_contact, get_contacts

app = Flask(__name__, template_folder='/var/www/html/appListaDeContatos')

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        if 'add' in request.form:
            name = request.form.get('name')
            email = request.form.get('email')
            phone = request.form.get('phone')
            add_contact(name, email, phone)
        elif 'delete' in request.form:
            user_id = request.form.get('delete_id')
            delete_contact(user_id)
        return redirect(url_for('home'))
    contacts = get_contacts()
    return render_template('home.html', contacts=contacts)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)