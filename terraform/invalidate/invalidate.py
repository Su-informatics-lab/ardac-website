import json
import boto3
import os

code_pipeline = boto3.client("codepipeline")
cloud_front = boto3.client("cloudfront")
DISTRIBUTION_ID = os.environ["DISTRIBUTION_ID"]

def lambda_handler(event, context):
    job_id = event["CodePipeline.job"]["id"]
    object_paths = ["/*"]
    try:
        cloud_front.create_invalidation(
            DistributionId=DISTRIBUTION_ID,
            InvalidationBatch={
                "Paths": {
                    "Quantity": len(object_paths),
                    "Items": object_paths,
                },
                "CallerReference": event["CodePipeline.job"]["id"],
            },
        )
    except Exception as e:
        code_pipeline.put_job_failure_result(
            jobId=job_id,
            failureDetails={
                "type": "JobFailed",
                "message": str(e),
            },
        )
    else:
        code_pipeline.put_job_success_result(
            jobId=job_id,
        )