# Fill in the variables here;
# they will be used for all the Terraform sub-projects
# You must use double quotes around each value
project_name="jdtcp0"
environment="dev"
aws_region="us-east-1"
aws_email="john.duquette@excella.com"
project_key_name="jdtcp0-keypair"

# credentials used to create any application database
# password must be greater than 8 characters
db_name="jdtcp0" # Only alpha-numeric
db_username="jdtcp0" # alpha-numeric  NOTE: Cannot be 'admin'
db_password="always-something24!"
db_identifier="testtcp" # lowercase, alpha-numeric
