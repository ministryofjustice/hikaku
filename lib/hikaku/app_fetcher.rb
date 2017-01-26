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

    # Takes a nokogiri doc and throws away a whole bunch of stuff
    # to make it easier to compare the structure and content of html
    # pages
    def normalise(html)
      doc = Nokogiri::HTML(html)
      body = doc.xpath('//body')

      body.xpath('//script').each {|s| s.remove}
      body.xpath('//comment()').each {|c| c.remove}
      body.xpath('//text()').find_all {|t| t.to_s.strip == ''}.map(&:remove)
      body.xpath('//header').remove
      body.xpath('//footer').remove
      body.xpath('//div[@id = "global-cookie-message"]').remove
      body.xpath('//div[@id = "global-header-bar"]').remove
      body.xpath('//div[@class = "phase-banner-alpha"]').remove
      body.xpath('//@class').remove
      body.xpath('//@id').remove
      body.xpath('//a').xpath('//@href').remove

      remove_data_attributes body

      body.to_s
        .gsub(/>\s+/, '>')
        .gsub(/\s+</, '<')
        .gsub('><', ">\n<")
    end

    def write_normalised(docpath:, content:)
      file = get_normalised_filename(docpath)
      filename = File.join(output_dir, file)
      File.write(filename, content)
      file
    end

    def remove_data_attributes(nokogiri_doc)
      nokogiri_doc.xpath('//*').map do |element|
        elements = element.attributes.find_all {|name, attr| name =~ /\Adata/}
        elements[0][1].remove if elements.any?
      end
    end
  end
end
