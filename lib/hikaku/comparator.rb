module Hikaku
  class Comparator
    attr_reader :app_fetcher, :prototype_fetcher, :report_template, :report_file, :normalised_html_dir, :diff_dir

    WRAP_WIDTH = 120

    def initialize(app_fetcher:,
                   prototype_fetcher:,
                   report_file:,
                   report_template:,
                   diff_dir:)
      @app_fetcher = app_fetcher                 # class to fetch 'real' app pages
      @prototype_fetcher = prototype_fetcher     # class to fetch prototype app pages
      @report_template = report_template         # erb template to generate the report.html file
      @report_file = report_file                 # final HTML index file, with report results
      @diff_dir = diff_dir                       # dir. to store the results of diffing two normalised html files
    end

    # Takes an array of tuples that match app. docpaths to prototype docpaths
    def run(pages)
      clean

      prototype_fetcher.fetch_pages(pages.map {|p| p[:prototype]})
      app_fetcher.fetch_pages

      normalised_html_files = pages.map do |i|
        {
          prototype_file: prototype_fetcher.get_normalised_filename(i[:prototype]),
          app_file: app_fetcher.get_normalised_filename(i[:app])
        }
      end

      diff_files = normalised_html_files.map do |i|
        generate_diff(i)
      end

      output_report diff_files
    end

    private

    def clean
      system "rm #{report_file} 2>/dev/null"
      system "rm #{app_fetcher.output_dir}/* 2>/dev/null"
      system "rm #{prototype_fetcher.output_dir}/* 2>/dev/null"
      system "rm #{diff_dir}/* 2>/dev/null"
      system "touch #{app_fetcher.output_dir}/#{NOT_IMPLEMENTED_YET}.html"
      system "touch #{diff_dir}/#{NOT_IMPLEMENTED_YET}.html"
    end

    # takes: names of two normalised_html files and generates an
    # html diff file
    def generate_diff(app_file:, prototype_file:)
      rails_file = File.join(app_fetcher.output_dir, app_file)
      prototype_file = File.join(prototype_fetcher.output_dir, prototype_file)

      File.join(diff_dir, File.basename(app_file)).tap do |output|
        system "bin/codediff.py --wrap #{WRAP_WIDTH} --yes #{rails_file} #{prototype_file} -o #{output}"
      end
    end

    def output_report(arr)
      @files = arr.map {|f| {basename: File.basename(f), path: f, diff_score: diff_score(f)} }
      erb = ERB.new(File.read report_template)
      File.write(report_file, erb.result(binding))
    end

    def diff_score(diff_file)
      count = File.read(diff_file).split("\n").grep(/span.class..diff/).length
      [count, 100].min
    end
  end
end
