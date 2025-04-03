name := "slack-bot-template"
entrypoint := "main"
python_version := "python312"
service_account_name := replace(name, "_", "-")
service_account_email := service_account_name + "@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"


venv:
    python -m venv .venv

install: venv
    pip install -r requirements.txt


format:
    ruff format . && ruff check --fix .


create-service-account:
    #!/usr/bin/env bash
    set -euxo pipefail

    if ! gcloud iam service-accounts describe {{ service_account_email }} &>/dev/null; then
        echo "Service account does not exist, creating..."
        gcloud iam service-accounts create {{ service_account_name }} \
            --display-name="Service Account for Cloud Functions and AI Platform"
    else
        echo "Service account already exists, updating..."
    fi

    # add roles/aiplatform.expressUser
    gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
        --member="serviceAccount:{{ service_account_email }}" \
        --role="roles/aiplatform.expressUser"

deploy:
    gcloud functions deploy {{ name }} \
        --entry-point {{ entrypoint }} \
        --project $GOOGLE_CLOUD_PROJECT \
        --runtime {{ python_version }} \
        --trigger-http \
        --allow-unauthenticated \
        --region $GOOGLE_CLOUD_LOCATION \
        --service-account {{ service_account_email }} \
        --set-env-vars SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET \
        --set-env-vars SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN \
        --source .
