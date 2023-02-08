## Create a new Alert Policy

resource "newrelic_alert_policy" "myTFSynthpolicy" {
  name                  = "My TF Synth Test Policy"
  incident_preference   = "PER_POLICY" # PER_POLICY is default
}

# Creates an email alert destination.
resource "newrelic_notification_destination" "myTFWebhookDestination" {
  name = "OpsGenie"
  type = "WEBHOOK"

  property {
    key = "url"
    value = "https://webhookdestination.opsgenie.com"
  }
}

##Notification template 
resource "newrelic_notification_channel" "myTFOpsGenieTemplate" {
  name = "webhook example opsg"
  type = "WEBHOOK"
  destination_id = newrelic_notification_destination.myTFWebhookDestination.id
  product = "IINT" // (Workflows)

  // must be valid json
  property {
    key = "payload"
    value =file("${path.module}/templatepayload.json")
    label = "Payload Template"
  }

}

/*
##Notification template 
resource "newrelic_notification_channel" "myTFOpsGenieTemplate" {
  name = "webhook example opsg"
  type = "WEBHOOK"
  destination_id = newrelic_notification_destination.myTFWebhookDestination.id
  product = "IINT" // (Workflows)

  // must be valid json
  property {
    key = "payload"
    value ="{\"tags\": \"tag1,tag2\",\"teams\": \"team1,team2\",\"recipients\": \"user1,user2\",\"payload\": {\"condition_id\": {{json accumulations.conditionFamilyId.[0]}},\"condition_name\": {{json accumulations.conditionName.[0] }}, \"current_state\": {{#if issueClosedAtUtc}} \"closed\" {{else if issueAcknowledgedAt}} \"acknowledged\" {{else}} \"open\"{{/if}},\"details\": {{json issueTitle}},\"event_type\": \"Incident\",\"incident_acknowledge_url\": {{json issueAckUrl }},\"incident_api_url\": \"N/A\",\"incident_id\": {{json issueId }},\"incident_url\": {{json issuePageUrl }},\"owner\": \"N/A\",\"policy_name\": {{ json accumulations.policyName.[0] }},\"policy_url\":  {{json issuePageUrl }},\"runbook_url\": {{ json accumulations.runbookUrl.[0] }},\"severity\": {{#eq \"HIGH\" priority}} \"WARNING\" {{else}}{{json priority}} {{/eq}},\"targets\": {\"id\": {{ json entitiesData.entities.[0].id }},\"name\": {{ json entitiesData.entities.[0].name }},\"type\": \"{{entitiesData.entities.[0].type }}\",\"product\": \"{{accumulations.conditionProduct.[0]}}\"},\"timestamp\": {{#if closedAt}} {{ closedAt }} {{else if acknowledgedAt}} {{ acknowledgedAt }} {{else}} {{ createdAt }} {{/if}}}}"
    label = "Payload Template"
  }

}
*/

// A workflow that matches issues that include incidents triggered by the policy
resource "newrelic_workflow" "myTFSynthWorkFlow" {
  name = "TF Workflow Example"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.myTFSynthpolicy.id ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.myTFOpsGenieTemplate.id
  }
}


resource "newrelic_nrql_alert_condition" "myTFSynthAlertCondition" {
  type                         = "static"
  name                         = "My Test NRQL Alert For Synth"
  policy_id = newrelic_alert_policy.myTFSynthpolicy.id
  description                  = "FailureCount"
  enabled                      = true
  violation_time_limit_seconds = 3600


  nrql {
    query = "FROM SyntheticCheck SELECT count(*) where result !='SUCCEED' facet monitorName"
  }

  critical {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}

/*{\"tags\": \"tag1,tag2\",\"teams\": \"team1,team2\",\"recipients\": \"user1,user2\",\"payload\": {\"condition_id\": {{json accumulations.conditionFamilyId.[0]}},\"condition_name\": {{json accumulations.conditionName.[0] }}, \"current_state\": {{#if issueClosedAtUtc}} \"closed\" {{else if issueAcknowledgedAt}} \"acknowledged\" {{else}} \"open\"{{/if}},\"details\": {{json issueTitle}},\"event_type\": \"Incident\",\"incident_acknowledge_url\": {{json issueAckUrl }},\"incident_api_url\": \"N/A\",\"incident_id\": {{json issueId }},\"incident_url\": {{json issuePageUrl }},\"owner\": \"N/A\",\"policy_name\": {{ json accumulations.policyName.[0] }},\"policy_url\":  {{json issuePageUrl }},\"runbook_url\": {{ json accumulations.runbookUrl.[0] }},\"severity\": {{#eq "HIGH" priority}} "WARNING" {{else}}{{json priority}} {{/eq}},\"targets\": {\"id\": {{ json entitiesData.entities.[0].id }},\"name\": {{ json entitiesData.entities.[0].name }},\"type\": "{{entitiesData.entities.[0].type }}",\"product\": "{{accumulations.conditionProduct.[0]}}\"},\"timestamp\": {{#if closedAt}} {{ closedAt }} {{else if acknowledgedAt}} {{ acknowledgedAt }} {{else}} {{ createdAt }} {{/if}}}}*/

