module Hikaku
  class PageFetcher
    attr_reader :base_url, :output_dir

    def initialize(params)
      @base_url = params.fetch(:base_url)
      @output_dir = params.fetch(:output_dir)
    end

    def get_normalised_filename(docpath)
      path = docpath.sub(/\A\//, '')
      ['/', ''].include?(path) ? 'root.html' : [path.gsub('/', '_'), 'html'].join('.')
    end

    private

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
      body.xpath('//label').xpath('//@for').remove
      body.xpath('//input').xpath('//@name').remove
      body.xpath('//input').xpath('//@value').remove

      remove_attributes(body, 'data')
      remove_attributes(body, 'aria')

      body.to_s
        .gsub(/>\s+/, '>')
        .gsub(/\s+</, '<')
        .gsub('><', ">\n<")
    end

    def write_normalised(docpath:, content:)
      file = get_normalised_filename(docpath)
      filename = File.join(output_dir, file)
      File.write(filename, content.gsub('><', ">\n<"))
      file
    end

    def remove_attributes(nokogiri_doc, prefix)
      nokogiri_doc.xpath('//*').map do |element|
        attrs = element.attributes.find_all {|name, attr| name =~ /\A#{prefix}/}
        attrs.map { |a| a[1].remove } if attrs.any?
      end
    end

  end
end
