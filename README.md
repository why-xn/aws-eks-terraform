## Create AWS EKS Cluster with Terraform ##
<br>

- Change the values in [00.variable.tf](00.variable.tf) file according to your needs
  
- Initialize your aws-cli with your Access Key & Secret Key. Your Access Key & Secret Key must have the proper permissions for creating all the resources needed for an EKS Cluster.

- Run Terraform
  ```sh
  ### INITIALIZE TERRAFORM FOR DOWNLOADING MODULES & DEPENDENCIES ###
  terraform init

  ### CHECK CODE VALIDATION AND GET THE PLAN FOR EXECUTION ###
  terraform plan

  ### EXECUTE ###
  terraform apply
  ```

- Update your ~/.kubeconfig file
  ```sh
  aws eks update-kubeconfig --region REGION --name CLUSTER_NAME
  ```

- Enjoy!!
  ```sh
  kubectl get all
  ```



- Cleanup
  ```sh
  terraform destroy
  ```