# Fill in the variables here;
# they will be used for all the Terraform sub-projects
# You must use double quotes around each value
project_name     = ""
environment      = ""
aws_region       = ""
aws_email        = ""
project_key_name = ""

# credentials used to create any application database
# password must be greater than 8 characters
db_name       = "TestTcpEcs" # Only alpha-numeric
db_username   = "TestTcpEcs" # alpha-numeric  NOTE: Cannot be 'admin'
db_password   = "always-something24!"
db_identifier = "testtcpecs" # lowercase, alpha-numeric
