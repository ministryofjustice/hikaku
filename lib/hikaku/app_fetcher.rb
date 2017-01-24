module Hikaku
  class AppFetcher < PageFetcher

    private

    def fetch(docpath)
      url = [base_url, docpath].join('/')
      @agent.get url
      save_normalised
    end

    def click_link(text, save: true)
      @agent.page.links_with(text: text).first.click
      save_normalised if save
    end

    # this is convoluted, because the text actually lives inside a strong
    # tag inside a label tag, wrapped around the input field.
    # So, we find the label, then the id of the first input inside it,
    # then check that via the form
    def choose_radio_button(text, save: true)
      page = @agent.page
      form = page.forms.first
      label = find_label(text)
      input = label.node.search('input').first
      id = input.attributes['id'].to_s
      form.radiobutton_with(id: id).check
      @agent.submit(form)
      save_normalised if save
    end

    # This relies on every form field having a label immediately
    # before it. This is fragile, but works, for now
    def fill_in_form(params, save: true)
      form = @agent.page.forms.first

      params.each do |text, value|
        label = find_label(text)
        field = label.node.next_sibling
        name = field.attributes['name'].to_s
        form[name] = value
      end

      @agent.submit(form)
      save_normalised if save
    end

    def find_label(text)
      page = @agent.page
      page.labels.find {|l| l.text == text} || page.labels.find {|l| l.node.search('strong').text == text}
    end

    def save_normalised
      page = @agent.page
      path = page.uri.path
      puts "#{self.class} #{path}"
      content = normalise page.body
      write_normalised(docpath: path, content: content)
    end
  end
end
