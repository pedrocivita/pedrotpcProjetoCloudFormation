from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    @task(1)
    def index(self):
        self.client.get("/")

    @task(2)
    def add_contact(self):
        self.client.post("/", json={
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "1234567890",
            "add": "Adicionar"
        })

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
    host = "http://StackD-LoadB-LLOnOp77SjuU-133890934.us-east-1.elb.amazonaws.com"
