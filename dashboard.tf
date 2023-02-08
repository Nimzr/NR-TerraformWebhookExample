resource "newrelic_one_dashboard" "myTFSynthDash" {
  name        = "TF Synth Dash Example"
  permissions = "public_read_only"

  page {
    name = "Synth Failures"

    widget_billboard {
      title  = "Average CPU"
      row    = 1
      column = 1
      width  = 3
      height = 3

      nrql_query {
        query = "FROM SyntheticCheck SELECT percentage(count(*), where result != 'SUCCESS') AS 'Failure Precent' FACET monitorName SINCE 24 hours ago"
      }
    }

    widget_line {
      title  = "Average CPU OverTime"
      row    = 1
      column = 4
      width  = 3
      height = 3

      nrql_query {
        account_id = var.account_id
        query      = "FROM SyntheticCheck SELECT percentage(count(*), where result != 'SUCCESS') AS 'Failure Precent' FACET monitorName since 24 hours ago TIMESERIES 1 hour"
      }

    
    }
  }
}