#!/bin/sh

NAME="Jenkins-deploy"
DESCRIPTION="Jenkins deployment in Kubernetes cluster"
TS=$(date +%s)
PROJECT_ID="$NAME-$TS"
PROJECT_ID=$(echo "$PROJECT_ID" | tr '[:upper:]' '[:lower:]')
SCRIPTS_DIR=$(pwd)

mkdir $HOME/$PROJECT_ID

echo "Creating progect $PROJECT_ID"

gcloud projects create $PROJECT_ID --name=$NAME
gcloud config set project $PROJECT_ID
echo
echo "Enabling billing for $PROJECT_ID"
BA=$(gcloud beta billing accounts list | grep True | awk {'print $1'})
gcloud beta billing projects link $PROJECT_ID --billing-account $BA
echo

echo "Enabling needed services"

for nsvc in compute.googleapis.com container.googleapis.com cloudbuild.googleapis.com
do
  gcloud services enable $nsvc
done

echo
echo "Setting up zone"
GOOGLE_CLOUD_ZONE="us-east1-d"
echo $GOOGLE_CLOUD_ZONE
echo
gcloud config set compute/zone $GOOGLE_CLOUD_ZONE

echo

# Create a service account, on Google Cloud Platform (GCP)
echo
echo "Configuring service accs and permissions with IAM"
gcloud iam service-accounts create jenkins-sa --display-name "jenkins-sa"

# Add required permissions, to the service account, using predefined roles

for role in roles/viewer roles/source.reader roles/storage.admin roles/storage.objectAdmin roles/cloudbuild.builds.editor roles/container.developer
do
  gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:jenkins-sa@$PROJECT_ID.iam.gserviceaccount.com" --role "$role"
done

# Export the service account credentials to a JSON key file in Cloud Shell
echo
echo "Creating KEY for jenkins-sa"
gcloud iam service-accounts keys create ~/$PROJECT_ID/jenkins-sa-key.json --iam-account "jenkins-sa@$PROJECT_ID.iam.gserviceaccount.com"
# Click Download File from More on the Cloud Shell toolbar and download jenkins-sa-key.json
echo

# Create a Kubernetes Cluster
KUBERNETES_ENGINE_VERSION="1.14"

# Provision the cluster with gcloud
# Use Google Kubernetes Engine (GKE) to create and manage your Kubernetes cluster, named jenkins-cd. Use the service account created earlier
echo "Creating Jenkins cluster"
gcloud container clusters create jenkins-cd --num-nodes 2 --machine-type n1-standard-2 --cluster-version $KUBERNETES_ENGINE_VERSION --service-account "jenkins-sa@$PROJECT_ID.iam.gserviceaccount.com"
# Once that operation completes, retrieve the credentials for your cluster
gcloud container clusters get-credentials jenkins-cd

# Confirm that the cluster is running and kubectl is working by listing pods
kubectl get pods

# Add yourself as a cluster administrator in the cluster's RBAC so that you can give Jenkins permissions in the cluster
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
echo "Configuring and install HELM"

HELM_RESOURCES="$HOME/$PROJECT_ID/HELM_SRC"
mkdir "$HELM_RESOURCES"
cd $HELM_RESOURCES

# Download and install the helm binary
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz

# Unzip the file to your local system
tar zxfv helm-v2.14.3-linux-amd64.tar.gz
cp linux-amd64/helm .

# Grant Tiller, the server side of Helm, the cluster-admin role in your cluster
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

./helm init --service-account=tiller

# Update your local repo with the latest charts
./helm repo update
echo "Need to wait near 6 minutes for tiller"
sleep 240

# Ensure Helm is properly installed by running the following command. You should see versions v2.14.3 appear for both the server and the client
./helm version

# Configure and Install Jenkins

# Use the Helm CLI to deploy the chart with your configuration set
./helm install -n cd stable/jenkins -f $SCRIPTS_DIR/jenkins/values.yaml --version 1.7.3 --wait

# The Jenkins pod STATUS should change to Running when it's ready
kubectl get pods

# Configure the Jenkins service account to be able to deploy to the cluster
kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins

# Set up port forwarding to the Jenkins UI
export JENKINS_POD_NAME=$(kubectl get pods -l "app.kubernetes.io/component=jenkins-master" -o jsonpath="{.items[0].metadata.name}")
kubectl expose deployment cd-jenkins --type=LoadBalancer --name=cd-jenkins-external
kubectl port-forward $JENKINS_POD_NAME 8080:8080 >> /dev/null &
sleep 90
# Now, check that the Jenkins Service was created properly
kubectl get svc

JENKINS_URL="$(kubectl get svc | grep LoadBalancer | awk {'print $4'}):8080"
printf $(kubectl get secret --namespace default cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode) > $HOME/$PROJECT_ID/jenkins_admin.txt

echo
echo "You just finished $DESCRIPTION"
echo "Link and credentials to Jenkins:"
echo "Link| http://$JENKINS_URL"
echo "Login| admin"
echo "Password| $(cat ${HOME}/$PROJECT_ID/jenkins_admin.txt)"
echo "Jenkins service account credentials You can find in $HOME/$PROJECT_ID folder"

