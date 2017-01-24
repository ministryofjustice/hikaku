# Hikaku

Hikaku (Japanese for 'Compare') is a tool to help compare a prototype and a 'real' application.

## Background

On our project, we use a prototype, written using the gov.uk [frontend toolkit][frontend_toolkit], to rapidly iterate our application. The prototype is what users see in research sessions, and also what stakeholders see during early-stage demos.

The prototype changes a lot faster than the 'real' ruby on rails application can keep up. This was a conscious choice we made as a team - keep the research/demo site as nimble as possible, and only incorporate changes into the rails application once we're confident in the user research.  The trade-off is that keeping the rails application up to date with the latest changes in the prototype can be tricky.

We wrote Hikaku to help with this.

The idea is simple - scrape the web pages of both the prototype and the real application, compare the resulting HTML and report on the differences. But, a naïve text comparison doesn't work;

* Different docpaths - the naming conventions for the docpaths are different, between the prototype and the rails application
* App/Prototype-specific HTML attributes
* Link hrefs differ
* Irrelevant differences - e.g. the contents of the `head` tag

Hikaku reduces the scraped HTML down to a 'normalised' form, which results in fewer irrelevant differences. It's far from perfect, but it's a lot better than nothing, and more reliable than comparing pages by eye.

## Usage

We may gem this, at some point. For now;

1. Clone this repo
1. Run `bundle install`
1. Using `lib/tax_tribs.rb` as a template, create a class that inherits from `Hikaku::AppFetcher` and implements `fetch_pages` in a way that works for your app.
1. Using `bin/compare.rb` as a template create a script with mappings between docpaths in your app and your prototype
1. Run your script, then open `report.html`

## Assumptions

Hikaku makes a lot of assumptions which are true for our project, and likely to be true for many gov.uk web applications. It is easy enough to code around these limitations, but straight out of the box, they're there.

* Prototypes have no state, so you can scrape them just by fetching a bunch of URLs
* Prototypes use basic auth to restrict access
* There is only one form per page
* You submit the form after clicking a single radio button
* All radio buttons are wrapped in `label` tags
* If you want the label 'Colour', it will be `<label>Colour</label>` or `<label><strong>Colour</strong>some other text</label>`
* Form fields are always the next sibling of labels. i.e. `<label>Name</label><input type="text"...`

Feedback, suggestions and PRs welcome.

[frontend_toolkit]: https://github.com/alphagov/govuk_frontend_toolkit
