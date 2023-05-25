# Approval Flow

Provision Assist includes a Power Automate flow ('Provisioning Request Approval') to handle approval of requests created by users.

Approval of requests in the solution can take place in two ways -

- Power Automate Approval action (Approval Email and Approvals app in Teams).
- Microsoft Teams Adaptive Card Approval (Adaptive card posted into a Teams channel).

This flow runs when the status of a request in the **'Provisioning Requests'** list changes to **'Submitted'** (user submits the request in the Power App). 

When you deploy the solution, be sure to follow the 'Step 5: Configure approval process' step of the [Deployment guide](/Deployment-guide.md) in order to set up approval. If you wish to change the approval method e.g. Move from Approvals to Teams adaptive cards, please follow the same step of the deployment guide. 

## Approval Reminders

If the approval process is configured to use Approvals, reminder emails can be sent to the approver(s), these are configurable in the 'Provisioning Request Settings' list.

![Approval reminder settings screenshot](/Images/ApprovalReminderSettings.png)

Simply edit the list items and change the value as appropriate:

- **EnableAppprovalReminderEmails** - Enable or disable the reminder emails to the approvers (true/false).
- **DisableApprovalNotifications** - Disable the native Power Automate approval notification emails, useful if you wish to edit the flow and add your own custom notification email.
- **ApprovalReminderInterval** - Interval (in days) before a reminder email is sent to the approvers.

## Process

At a high level the 'Provisioning Request Approval' flow works as follows:

1. Update status of the request item to 'Pending Approval'.
2. Retrieve settings from the 'Provisioning Request Settings' list.
3. Send either an approval task to the approver(s) OR post a Teams adaptive card.
4. Wait for the approval and send reminders to the approver(s) depending on the reminder settings.
5. Check approval response - update request status to 'Approved' or 'Rejected'.
6. Concatenate approval comments.
7. Send email and adaptive card in Teams to requestor to notify them of the outcome.

Requests that are 'Approved' will trigger provisioning.

Rejected requests can be edited by users in the Power App and resubmitted.

As mentioned above, you may edit the approval flow **however this will create an unmanaged layer in the Provision Assist Power Apps solution**. This means if the solution is upgraded in the future, updates to the approval flow will not be applied in your tenant.



