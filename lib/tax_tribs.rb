class TaxTribs < Hikaku::AppFetcher

  # Follow a path through the rails app, saving the normalised html at each stage
  # This is always going to be messy, because it involves knowing exactly what the
  # app. does, and how it's built
  def fetch_pages
    @agent = Mechanize.new

    fetch ''
    click_link 'Appeal against a tax decision'
    click_link 'Find out the cost of your appeal'
    click_link 'Continue'
    choose_radio_button 'Yes'
    choose_radio_button 'Income Tax'
    choose_radio_button 'Penalty or surcharge'
    choose_radio_button '£100 or less'
    click_link 'Continue', save: false  # skip over the repeated task list
    click_link 'Start'
    click_link 'Continue'
    choose_radio_button 'Yes, I am in time', save: false # skip over the repeated task list
    click_link 'Start'
    click_link 'Continue'
    choose_radio_button 'Individual'

    fill_in_form(
      'Name (first name and last name)' => 'Some Guy',
      'Address'                         => '123 Some Street',
      'Postcode'                        => 'W1A 4WW',
      'Email address'                   => 'some@guy.com',
      'Phone number'                    => '12345',
    )

    fill_in_form(
      'Enter reasons below or attach as a document' => "I don't like paying tax"
    )

    upload_documents './data/facepalm.png'
  end

  # This is specific to this application
  def upload_documents(file, save: true)
    page = @agent.page
    form = page.form_with(action: "#{base_url}/documents")
    form.file_upload.file_name = file
    @agent.submit(form)

    page = @agent.page
    form = page.form_with(action: "/steps/details/documents_checklist")
    form.checkboxes.find {|box| box.name =~ /original_notice_provided/}.check
    form.checkboxes.find {|box| box.name =~ /review_conclusion_provided/}.check
    @agent.submit(form)

    save_normalised if save
  end
end
