# **************************** REMOTE BACKEND!! Removed from the state *****************************

# resource "aws_dynamodb_table" "terraform_locks_eks_portfolio" {
#   name         = "terraform-lock-table-eks-portfolio" # Replace with your desired table name
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name                      = "Terraform Lock Table",
#     finops_billing_code       = var.finops_billing_code,
#     servicenow_application_id = var.servicenow_application_id
#   }
# }