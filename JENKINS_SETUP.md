# Jenkins Configuration Guide

## Required Jenkins Plugins

Install these plugins via **Manage Jenkins → Plugins → Available Plugins**:

1. **Git Plugin** (usually pre-installed)
2. **GitHub Plugin**
3. **Pipeline Plugin** (usually pre-installed)
4. **Docker Pipeline Plugin**
5. **SSH Agent Plugin**
6. **AWS Credentials Plugin**
7. **CloudBees AWS Credentials Plugin**

## Required Credentials Setup

### 1. AWS Account ID (Text Credential)

**Navigate to:** Manage Jenkins → Credentials → System → Global credentials → Add Credentials

- **Kind:** Secret text
- **Secret:** Your AWS Account ID (e.g., `123456789012`)
- **ID:** `aws-account-id`
- **Description:** AWS Account ID for ECR

**To find your AWS Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

### 2. EC2 SSH Key (SSH Username with private key)

**Navigate to:** Manage Jenkins → Credentials → System → Global credentials → Add Credentials

- **Kind:** SSH Username with private key
- **ID:** `ec2-ssh-key`
- **Description:** EC2 SSH Key for App Server
- **Username:** `ec2-user`
- **Private Key:** Enter directly
  - Copy the contents of your `AutoKeyPair.pem` file
  - Or select "From a file on Jenkins controller" and provide the path

**To copy your key:**
```bash
cat ~/path/to/AutoKeyPair.pem
```

### 3. GitHub Credentials (Optional but recommended)

**Navigate to:** Manage Jenkins → Credentials → System → Global credentials → Add Credentials

- **Kind:** Username with password OR Personal Access Token
- **ID:** `github-credentials`
- **Description:** GitHub Access Token
- **Username:** Your GitHub username
- **Password/Token:** GitHub Personal Access Token

**To create GitHub PAT:**
1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` scope

## Configure AWS Credentials on Jenkins Server

SSH into your Jenkins server and configure AWS CLI:

```bash
ssh -i AutoKeyPair.pem ec2-user@<jenkins-public-ip>
sudo su - jenkins
aws configure
```

Enter:
- **AWS Access Key ID:** Your AWS access key
- **AWS Secret Access Key:** Your AWS secret key
- **Default region:** `eu-west-1`
- **Default output format:** `json`

## Create Jenkins Pipeline Job

1. **Navigate to:** Jenkins Dashboard → New Item
2. **Enter name:** `nodejs-cicd-pipeline` (or your preferred name)
3. **Select:** Pipeline
4. **Click:** OK

### Configure Pipeline

#### General Section
- ✅ Check "GitHub project"
- **Project url:** `https://github.com/KofiAckah/A-simple-Jenkins-project/`

#### Build Triggers (Optional)
- ✅ Check "GitHub hook trigger for GITScm polling" (if using webhooks)
- OR ✅ Check "Poll SCM" and set schedule: `H/5 * * * *` (poll every 5 minutes)

#### Pipeline Section
- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `git@github.com:KofiAckah/A-simple-Jenkins-project.git`
  - OR `https://github.com/KofiAckah/A-simple-Jenkins-project.git`
- **Credentials:** Select your GitHub credentials (if private repo)
- **Branch Specifier:** `*/main` (or `*/master` depending on your default branch)
- **Script Path:** `Jenkinsfile`

**Click:** Save

## Test the Pipeline

1. Click **Build Now** to run your first pipeline
2. Monitor the build progress in the console output
3. Verify each stage completes successfully

## Troubleshooting

### If "Install Dependencies" fails:
```bash
# SSH into Jenkins server
ssh -i AutoKeyPair.pem ec2-user@<jenkins-ip>

# Install Node.js and npm
sudo yum install -y nodejs npm

# Verify installation
node --version
npm --version
```

### If "Push to ECR" fails:
```bash
# Verify AWS credentials on Jenkins server
sudo su - jenkins
aws sts get-caller-identity
aws ecr describe-repositories --region eu-west-1
```

### If "Deploy to App Server" fails:
```bash
# Verify SSH connectivity from Jenkins to App Server
ssh -i /var/lib/jenkins/.ssh/id_rsa ec2-user@<app-server-ip>

# Ensure Jenkins user has the SSH key
sudo cp /path/to/AutoKeyPair.pem /var/lib/jenkins/.ssh/id_rsa
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
sudo chmod 400 /var/lib/jenkins/.ssh/id_rsa
```

### If Docker commands fail on Jenkins:
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Verify
sudo su - jenkins
docker ps
```

## GitHub Webhook Setup (Optional)

For automatic builds on git push:

1. Go to your GitHub repository → Settings → Webhooks → Add webhook
2. **Payload URL:** `http://<jenkins-public-ip>:8080/github-webhook/`
3. **Content type:** `application/json`
4. **Which events:** Just the push event
5. **Active:** ✅ Checked
6. Click **Add webhook**

## Security Best Practices

1. **Restrict Jenkins access:**
   - Go to Manage Jenkins → Configure Global Security
   - Enable "Jenkins' own user database"
   - Set "Authorization" to "Logged-in users can do anything"

2. **Use HTTPS:** Consider setting up a reverse proxy with SSL

3. **Limit SSH access:** Update security groups to allow SSH only from Jenkins server to App server

4. **Rotate credentials:** Regularly update AWS access keys and SSH keys

## Monitoring

After successful deployment, access your application:
- **Application URL:** `http://<app-server-public-ip>:3000`
- **Jenkins URL:** `http://<jenkins-public-ip>:8080`

## Next Steps

1. Configure email notifications for build failures
2. Add code quality checks (ESLint, code coverage)
3. Implement blue-green deployment
4. Add rollback mechanism
5. Set up monitoring with CloudWatch or Prometheus
