#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
# exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install dependencies and Java
sudo apt install -y curl gnupg2 software-properties-common openjdk-21-jre

# Add Jenkins repo and install
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar

# Setup init admin user
JENKINS_HOME="/var/lib/jenkins"
ADMIN_USER="admin"
ADMIN_PASSWORD="your_secure_password"

# Get the initial admin password
INITIAL_ADMIN_PASSWORD=$(sudo cat $JENKINS_HOME/secrets/initialAdminPassword)

# Create groovy script to disable setup wizard and create admin user
cat > /tmp/init.groovy << EOF
import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState

def instance = Jenkins.getInstance()

// Disable setup wizard
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("$ADMIN_USER", "$ADMIN_PASSWORD")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

# Create directory for groovy scripts if it doesn't exist
sudo mkdir -p $JENKINS_HOME/init.groovy.d/

# Execute the groovy script
sudo cp /tmp/init.groovy $JENKINS_HOME/init.groovy.d/

# # Restart Jenkins to apply changes
# sudo systemctl restart jenkins

# ==== Disable the Jenkins setup wizard ==== #
echo "Disabling Jenkins setup wizard..."
echo "JAVA_ARGS=\"-Djenkins.install.runSetupWizard=false\"" | sudo tee /etc/default/jenkins

# Create the marker file to indicate setup is complete
sudo mkdir -p "$JENKINS_HOME"
sudo chown -R jenkins:jenkins "$JENKINS_HOME"
sudo touch "$JENKINS_HOME"/.jenkins.install.UpgradeWizard.state
sudo touch "$JENKINS_HOME"/.jenkins.install.InstallUtil.lastExecVersion

# Set appropriate content if needed (optional, improves stability)
echo "2.426.1" | sudo tee "$JENKINS_HOME"/.jenkins.install.InstallUtil.lastExecVersion
echo "2.426.1" | sudo tee "$JENKINS_HOME"/.jenkins.install.UpgradeWizard.state

# Fix permissions
sudo chown jenkins:jenkins "$JENKINS_HOME"/.jenkins.install.*

# Restart Jenkins
echo "Restarting Jenkins..."
sudo systemctl restart jenkins

# # ======================
# # Install plugins
# # ======================
# wget "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -O jenkins-cli.jar

# PLUGINS=(
#   git
#   github
#   workflow-aggregator    # For pipelines
#   credentials
#   credentials-binding
#   pipeline-github-lib
#   configuration-as-code
#   job-dsl
#   ssh-slaves
#   matrix-auth
#   email-ext
#   blueocean
# )

# for plugin in "${PLUGINS[@]}"; do
#   java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $ADMIN_USER:$ADMIN_PASSWORD install-plugin git -deploy
# done

# java -jar jenkins-cli.jar -s "$JENKINS_URL" safe-restart
