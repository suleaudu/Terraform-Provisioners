Installing flask: 
This project was carried out to demonstrate the use of Terraform Provisioner. I created an instance and used terraform provisioner to execute command to install and exposed flask app.
First i set up the main.tf configuration file consisting of provider block, resource blocks (VPC, Pub Subnet, Routetable, Internet gateway, Instance and provisioner).
I created the flask app file (app.py). 
I install python and pip in my system so that flaskapp can run on it.
Then initialize my configuration file using terraform init, followed by terraform plan to show reources to be created, when satisfied with the plan, i ran terraform apply to created the instance and install the flask app using terraform provisioner during the creation.
