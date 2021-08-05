import boto3
import requests
import xlsxwriter
import yaml
import sys

requests.packages.urllib3.disable_warnings()


input = []

with open("input.yaml") as input_file:
    input = yaml.safe_load(input_file)

defaults = input["defaults"]
accounts = input["account_id"]

def create_excel_headers(worksheet):
    worksheet.write(0, 0, "account_id")
    worksheet.write(0, 1, "aws_region")
    worksheet.write(0, 2, "vpc_id")
    worksheet.write(0, 3, "vpc_name")
    worksheet.set_column(0, 15, 20)


def get_regions(creds):
    ec2_resource = get_ec2_resource_handler("us-east-1", creds)
    ec2 = ec2_resource.meta.client
    response = ec2.describe_regions()
    regions = response["Regions"]
    list_of_regions = []
    for region in regions:
        list_of_regions.append(region["RegionName"])
    return list_of_regions

def get_role_arn(account_id):
    role_name = defaults["role_name"]
    role_arn = "arn:aws:iam::" + str(account_id) + ":role/" + role_name
    return role_arn


def get_temp_creds_for_account(role_arn):
    sts_client = boto3.client("sts")
    try:
        assumed_role = sts_client.assume_role(
            RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
        )
    except Exception as e:
        print(e)
        sys.exit(1)
    creds = assumed_role["Credentials"]
    return creds


def get_ec2_resource_handler(aws_region, creds):
    ec2_resource = boto3.resource(
        "ec2",
        region_name=aws_region,
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
    )
    return ec2_resource



def write_to_excel():
    row = 1

    for account in accounts:
        role_arn = get_role_arn(account)
        creds = get_temp_creds_for_account(role_arn)

        try:
            regions = input["aws_region"]
        except KeyError:
            regions = get_regions(creds)

        for region in regions:
            ec2_resource = get_ec2_resource_handler(region, creds)
            ec2 = ec2_resource.meta.client
            response = ec2.describe_vpcs()
            vpcs = response["Vpcs"]
            for vpc in vpcs:
                worksheet.write(row, 0, str(account))
                worksheet.write(row, 1, region)
                worksheet.write(row, 2, vpc["VpcId"])

                vpcname = ""
                if "Tags" in vpc:
                    for tag in vpc["Tags"]:
                        if tag["Key"] == "Name":
                            vpcname = tag["Value"]
                spoke_gw_name = (vpcname + "-AVXGW").replace(" ", "_")
                worksheet.write(row, 3, vpcname)
                row += 1


workbook = xlsxwriter.Workbook("test.xlsx")
worksheet = workbook.add_worksheet()
create_excel_headers(worksheet)
write_to_excel()
workbook.close()
