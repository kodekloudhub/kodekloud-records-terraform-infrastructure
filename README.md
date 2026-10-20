# Secure AWS Infrastructure Automation with Terraform, GitHub Actions and OIDC

**A practical DevSecOps and Infrastructure as Code case study**

This repository demonstrates how to automate AWS infrastructure provisioning and integrate existing cloud resources into Terraform state using secure GitHub Actions workflows.

The project is designed as a learning resource for university students studying Cloud Computing, DevOps, Site Reliability Engineering and Cloud Security.

## 1. Problem Statement

In real-world environments, cloud resources are often created manually before organisations adopt Infrastructure as Code.

When Terraform attempts to create those existing resources, AWS may return errors such as:

- `EntityAlreadyExists` — an IAM user already exists.
- `BucketAlreadyOwnedByYou` — an S3 bucket already exists.
- `AccessDenied` — the deployment identity lacks a required permission.
- `AuthorizationHeaderMalformed` — an incorrect AWS Region is configured.

**Our challenge:** Build a secure automation pipeline and bring manually created AWS resources under Terraform management without deleting or recreating them.

## 2. Project Objectives

- Automate AWS infrastructure operations using Terraform and GitHub Actions.
- Authenticate GitHub Actions to AWS through OIDC federation.
- Manage Terraform state using an Amazon S3 remote backend.
- Provision multiple IAM users using Terraform `for_each`.
- Import existing IAM users and an S3 bucket.
- Apply least-privilege access controls.
- Diagnose and resolve real infrastructure automation failures.
- Demonstrate validation, planning and infrastructure state verification.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| GitHub Actions | CI/CD automation |
| AWS IAM | Identity and permissions management |
| OpenID Connect | Federated GitHub-to-AWS authentication |
| AWS STS | Temporary role credentials |
| Amazon S3 | Remote Terraform state and laboratory storage |
| Git | Version control |
| VS Code | Infrastructure configuration development |

## 4. Solution Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions Workflow
    |
    v
GitHub OIDC Identity Token
    |
    v
AWS STS / GitHubTerraformRole
    |
    v
Terraform
    |
    +---- S3 Remote State Backend
    |
    +---- AWS IAM Users
    |
    +---- S3 Laboratory Bucket
```

The GitHub Actions workflow uses OIDC authentication rather than requiring permanent AWS access keys in repository secrets.

## 5. AWS Resources

The lab demonstrates Terraform management of seven IAM users.

**Existing IAM users brought under Terraform management:**

- `iamuser-julia`
- `iamuser-pablo`

**Five new IAM users provisioned during the exercise:**

- `student-user-01`
- `student-user-02`
- `student-user-03`
- `student-user-04`
- `student-user-05`

**Amazon S3 buckets:**

| Bucket | Purpose |
|---|---|
| `terraform-state-code-file` | Terraform remote state |
| `terraform-state-2527a9a1` | Laboratory infrastructure bucket |

AWS Region: `eu-west-2` (London).

The Terraform configuration also includes planned S3 security settings and IAM permissions for controlled practical exercises.

## 6. GitHub Actions Workflows

The repository contains workflows for Terraform deployment, import and cleanup.

**Terraform Apply:** Runs Terraform deployment operations against AWS. Changes should be reviewed and approved before execution.

**Terraform Import IAM Users:** Imports existing AWS resources into Terraform state without creating duplicates.

**Terraform Destroy:** Contains cleanup operations and must be reviewed carefully before use.

A typical Terraform execution sequence is:

```text
Checkout
   ↓
Configure AWS OIDC credentials
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Terraform Plan
   ↓
Review changes
   ↓
Terraform Apply (when approved)
   ↓
Verify infrastructure
```

## 7. Terraform Import Demonstration

Terraform tracks resources through its state.

If an AWS resource already exists but is not registered in the current state, Terraform may attempt to create a duplicate.

For example, the project used these commands:

```bash
terraform import \
  'module.iam_users.aws_iam_user.new_users["iamuser-julia"]' \
  iamuser-julia

terraform import \
  'module.iam_users.aws_iam_user.new_users["iamuser-pablo"]' \
  iamuser-pablo

terraform import \
  aws_s3_bucket.terraform_state \
  terraform-state-2527a9a1
```

These commands require an initialised Terraform backend, matching configuration, the correct AWS account and appropriate read permissions.

**Note:** Do not import resources already managed by another Terraform state.

## 8. Troubleshooting Lessons

| Error | Learning outcome |
|---|---|
| Incorrect AWS Region | Understand variable precedence and provider configuration |
| Missing IAM `CreateUser` permission | Understand identity-based IAM policies |
| Existing IAM users | Learn Terraform import and state reconciliation |
| Existing S3 bucket | Understand resource ownership and state |
| S3 `AccessDenied` | Diagnose granular IAM authorisation |
| Terraform wrapper `EPIPE` | Investigate CI/CD tooling failures |

The S3 import exercise required reading bucket configuration using specific IAM permissions rather than granting unrestricted access.

## 9. Verified Results

On **20 October 2026**, the GitHub Actions workflow **Terraform Import IAM Users #13** completed successfully in approximately **52 seconds**.

The successful execution verified:

- GitHub-to-AWS OIDC authentication.
- AWS account and Region checks.
- Terraform remote backend initialisation.
- Terraform state access.
- Existing IAM user import/state recognition.
- Existing S3 bucket import.
- Terraform state verification.
- Terraform validation.
- Terraform planning.

The Terraform Plan recognised the seven IAM users and the imported laboratory bucket.

**Remaining planned work:** The latest reviewed plan proposed 24 additional resources: three S3 security configurations, seven IAM inline policies and fourteen managed-policy attachments. Those additions should not be described as deployed until a successful Apply confirms them.

**Successful workflow evidence:**

[GitHub Actions — Terraform Import IAM Users #13](https://github.com/Vaishalisang/kodekloud-records-terraform-infrastructure/actions/runs/39410089094/job/118585439985)

## 10. Security Considerations

This is a controlled educational project.

- Use temporary OIDC credentials for GitHub Actions.
- Restrict role assumption to approved GitHub identities.
- Never commit AWS secrets, private credentials or Terraform state files.
- Review IAM policy permissions before Apply.
- Restrict student permissions to designated lab resources.
- Avoid unnecessary permanent IAM access keys.
- Protect the Terraform state backend.
- Review any Destroy plan before running cleanup.

The Terraform module should be reviewed for any automatic IAM access-key resources before reuse.

## 11. Student Practical Exercise

Students can study how infrastructure code provisions multiple IAM users, how Terraform imports existing AWS resources, and how GitHub Actions executes an infrastructure workflow.

A proposed extension is to configure all seven lab identities with controlled upload, download and delete permissions on the designated S3 bucket.

Such permissions must first be applied and verified in AWS before conducting object-access exercises.

Students should use their own authorised AWS learning environments rather than deploying directly into the demonstration account.

## 12. Learning Outcomes

After completing this case study, students should understand:

1. The purpose of Infrastructure as Code.
2. Secure OIDC authentication between GitHub and AWS.
3. Terraform remote state management.
4. Automated provisioning using `for_each`.
5. Terraform resource import.
6. AWS IAM permission evaluation.
7. The difference between Terraform Plan and Apply.
8. Systematic debugging of cloud automation failures.

## 13. Conclusion

This project demonstrates that secure cloud automation is more than executing Terraform commands.

A reliable DevSecOps workflow requires correct authentication, narrowly scoped authorisation, accurate state management, infrastructure validation and controlled deployment.

The successful Terraform import workflow illustrates how existing AWS resources can be reconciled with Infrastructure as Code without unnecessary deletion or recreation.

**Key lesson:** A green CI/CD workflow confirms that the configured workflow completed successfully. Infrastructure completion additionally requires verifying that the real AWS environment matches the approved Terraform configuration.

---

**Repository:** https://github.com/Vaishalisang/kodekloud-records-terraform-infrastructure

**Demonstration branch:** `dev-test`

**Audience:** University students studying DevOps, Cloud Computing, SRE and Cybersecurity.
