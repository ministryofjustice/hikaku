#!/usr/bin/env ruby

require 'bundler/setup'
require './lib/hikaku'
require './lib/tax_tribs'

NORMALISED = 'normalised_html'

# We have to fetch the rails app pages separately, because we need to maintain
# a continuous session (otherwise we get an error)
app_fetcher = TaxTribs.new(
  base_url: 'https://tax-tribunals-datacapture-dev.dsd.io',
  output_dir: File.join(NORMALISED, 'app')
)

prototype_fetcher = Hikaku::PrototypeFetcher.new(
  base_url: 'https://moj-taxtribs-prototype.herokuapp.com',
  username: ENV.fetch('USERNAME'),
  password: ENV.fetch('PASSWORD'),
  output_dir: File.join(NORMALISED, 'prototype')
)

comparator = Hikaku::Comparator.new(
  app_fetcher: app_fetcher,
  prototype_fetcher: prototype_fetcher,
  report_template: 'templates/report.html.erb',
  report_file: 'report.html',
  diff_dir: 'diffs'
)

not_yet = Hikaku::NOT_IMPLEMENTED_YET

# tuples matching docpaths on the app to docpaths on the prototype
pages = [
  { app: '/',                                  prototype: 'application_type' },
  { app: 'task_list',                          prototype: 'task_list' },
  { app: 'steps/appeal/start',                 prototype: 'before_you_start/start' },
  { app: 'steps/appeal/must_challenge_hmrc',   prototype: 'before_you_start/hmrc_must' },
  { app: 'steps/appeal/challenged_decision',   prototype: 'before_you_start/hmrc_challenge' },
  { app: 'steps/appeal/case_type',             prototype: 'before_you_start/type_of_tax' },
  { app: 'steps/appeal/case_type_show_more',   prototype: 'before_you_start/types_tax_other' },
  { app: 'steps/appeal/dispute_type',          prototype: 'before_you_start/dispute_type' },
  { app: 'steps/appeal/penalty_amount',        prototype: 'before_you_start/penalty_detail' },
  { app: 'steps/appeal/determine_cost',        prototype: 'before_you_start/fee' },
  { app: 'steps/lateness/start',               prototype: 'lateness/start' },
  { app: 'steps/lateness/in_time',             prototype: 'lateness/hmrc_view_date' },
  { app: 'steps/details/start',                prototype: 'data_capture/start' },
  { app: 'steps/details/taxpayer_type',        prototype: 'data_capture/who_are_you' },
  { app:  not_yet,                             prototype: 'data_capture/appellant_type' },
  { app: 'steps/details/taxpayer_details',     prototype: 'data_capture/appellant_details' },
  { app:  not_yet,                             prototype: 'data_capture/do_you_have_rep' },
  { app: 'steps/details/grounds_for_appeal',   prototype: 'data_capture/grounds_for_appeal' },
  { app: 'steps/details/outcome',              prototype: 'data_capture/outcome' },
  { app: 'steps/details/documents_checklist',  prototype: 'data_capture/documents' },
  { app: 'steps/details/check_answers',        prototype: 'data_capture/check_answers' },
]

comparator.run(pages)
