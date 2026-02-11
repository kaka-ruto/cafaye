#!/bin/bash
# Cafaye OS: End-to-End Remote Installation Test
# Automates GCP instance creation and installer execution

set -e

INSTANCE_NAME="cafaye-e2e-test-$(date +%s)"
ZONE="europe-west2-b"
IMAGE_FAMILY="ubuntu-2404-lts-amd64"
IMAGE_PROJECT="ubuntu-os-cloud"

echo "🚀 Starting End-To-End Test for Cafaye OS"

# 1. Create Instance
echo "Creating GCP instance: $INSTANCE_NAME..."
gcloud compute instances create "$INSTANCE_NAME" \
    --zone "$ZONE" \
    --machine-type n2-standard-4 \
    --image-family "$IMAGE_FAMILY" \
    --image-project "$IMAGE_PROJECT" \
    --boot-disk-size 50GB \
    --quiet

# Get IP
IP=$(gcloud compute instances describe "$INSTANCE_NAME" --zone "$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "Instance IP: $IP"

# Wait for SSH
echo "Waiting for SSH to be ready..."
until gcloud compute ssh "$INSTANCE_NAME" --zone "$ZONE" --command "uptime" --quiet &>/dev/null; do
    sleep 5
done

# 2. Setup SSH Keys
echo "Deploying SSH keys..."
gcloud compute ssh "$INSTANCE_NAME" --zone "$ZONE" --command "echo '$(cat ~/.ssh/cafaye.pub)' >> ~/.ssh/authorized_keys" --quiet

# 3. Sync local code
echo "Syncing local code to instance..."
rsync -avz -e "ssh -i ~/.ssh/cafaye -o StrictHostKeyChecking=no" --exclude .git --exclude .devbox --exclude .cache . "kaka@$IP:~/cafaye"

# 4. Run Installer
echo "Launching self-driving installer..."
ssh -i ~/.ssh/cafaye -o StrictHostKeyChecking=no kaka@$IP "\
    sudo mkdir -p /root/.ssh && \
    sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys && \
    sudo chmod 600 /root/.ssh/authorized_keys && \
    sudo mkdir -p /root/cafaye && \
    sudo cp -r ~/cafaye/* /root/cafaye/ && \
    sudo /root/cafaye/install.sh --yes"

echo "✅ Bootstrap complete. The system is installing in the background."
echo "You can check progress via serial console:"
echo "  gcloud compute instances get-serial-port-output $INSTANCE_NAME --zone $ZONE --tail=100"
echo ""
echo "Or wait ~10 minutes and try to SSH as root:"
echo "  ssh root@$IP"
