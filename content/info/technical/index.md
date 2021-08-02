
---
en:
  title: Technical Information
  body: |
## UK Web Archive Crawler Settings

We run a number of different web crawlers for different purposes. Our main crawler visit hundreds of sites on a daily, weekly, monthly, quarterly or six-monthly basis. This crawl process uses two different approaches for capturing web pages. For some URLs, we use an automated web browser to download the page, including images, stylesheets, and some dynamic JavaScript content. We identify this crawling process by including the following declaration in the [User Agent](https://en.wikipedia.org/wiki/User_agent):

    bl.uk_lddc_renderbot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

Where the `{{VERSION}}` part indicates which version of our crawler is in use, e.g. `bl.uk_lddc_renderbot/2.0.0`.

Because this process involves running an actual web browser, it can download quite a lot of URLs in a short time, just like a normal user would. However, only a very small set of URLs use this crawl method -- the vast majority of URLs are downloaded using a more traditional web crawler that works a bit more like a normal search engine web crawler. This identifies itself as:

    bl.uk_ldfc_bot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

for the usual regular crawling activity, or as

    bl.uk_lddc_bot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

if it's part of our less frequent domain crawls, where we attempt to download content from all UK web sites, which we usually do once per year.

These larger-scale crawls are more polite, and will download resources from a given web site at no more than two requests per second, will 'back off' if the site is responding slowly. 

In general [`robots.txt`](https://en.wikipedia.org/wiki/Robots_exclusion_standard) is respected and is checked every hour for any changes. We do occasionally chose to disobey `robots.txt` if necessary. Those 'robot exclusion' directives are usually composed with search engines in mind, and as such, tend to block resources that are unimportant to search engines like stylesheets or JavaScript. However, as an archive, we need those resources in order to be able to replay the content, so sometimes have to ignore `robots.txt` in order to get them.

In general a limit is set on the amount of data we download from a given web host: exceeding the limit will automatically stop the crawler. This ensures that if the crawler is in some kind of "trap" it will stop automatically. These download caps are occasionally lifted for large sites where we wish to ensure we get as much of the content as possible.

## Making Your Website Crawler-Friendly

There are a number of things which you can do to help the UK Web Archive capture as much content as possible from your website:

 * Create a [Site Map](https://en.wikipedia.org/wiki/Site_map), and if possible a XML site map too. Creating a site map ensures all the website content can be crawled (some pages may not be discoverable by the crawler, for example pages which use Flash or JavaScript navigation). Having a site map will also help users to find your pages via search engines.
 * Use [`robots.txt`](https://en.wikipedia.org/wiki/Robots_exclusion_standard) to prevent access to areas of the site which may cause problems if crawled e.g. databases, including online catalogues; "shopping baskets", etc.
 * Provide standard links to content which would otherwise only be accessed via selecting drop down menus, certain dynamic kinds of navigation (e.g JavaScript) or by conducting searches on the website. This is because the crawler cannot access content hidden behind search forms. Websites can of course still use those devices but if standard links are also provided on the website then the content is more likely to be captured properly.
 
For more information, please see:

- Columbia Universities Libraries' [Guidelines for Preservable Websites](https://library.columbia.edu/bts/web_resources_collection/guidelines_for_preservable_websites.html)
- Stanford Libraries' [Archivability](https://library.stanford.edu/projects/web-archiving/archivability)

## What Can't Yet Be Archived

The current generation of web crawlers cannot capture:

* Interactive, dynamically generated content
* Content that is only available via a search engine on the website, or some other form submission method
* Some types of JavaScript-driven menus
* YouTube videos, Flash movies and similar streaming audio or video (some audio and video files can be captured, e.g. those embedded via the standard [HTML5](https://en.wikipedia.org/wiki/HTML5) `<video>` or `<audio>` tags).

Unlike static HTML, which is relatively easy to capture, script code is very hard for traditional web crawlers to analyse, which is why we run web browsers for a limited part of our crawls. Even that cannot capture very interactive web sites, like single-page web applications, or any site feature that needs a remote server to function.  In practical terms this means that entering queries into the search box of an archived version of a website will not work. Standard links on the website, however, will work as normal.

Many sites provide both a search box and a site map to help their users search content in different ways, but if there is only search engine retrieval the UK Web Archive will not be able to harvest the content.

Some JavaScript driven menus do not function well once archived. YouTube videos, Flash movies, and similar streaming audio or video are also beyond the capability of web crawlers. However, as members of the International Internet Preservation Consortium, contributors to the UK Web Archive are developing tools which will help capture this content in the future.

The crawler software cannot automatically gather any material that is protected behind a password, without the owner's collaboration. Web site owners may however choose to divulge confidentially a user ID and password to allow archiving of these areas. Please [contact us](/contact) for more information.

## Search Engines and the UK Web Archive

The UK Web Archive site is indexed by search engines but only to the level of the information pages: search engines are not allowed to index the archived sites.

For example, if you search for the 'Arts and Humanities Research Council' on Google , you will only find the live site on the initial pages of hits. If you search for 'UKWA' and the 'Arts and Humanities Research Council', you will find a UK Web Archive information page which links to the archived instances of the AHRC website.

This is to stop the Archive diverting traffic from the live site and to prevent users thinking that information on the archived version is actually the latest version of events. The archived version of your website will not appear in a search engine without your permission.

## Linking to the UK Web Archive

All sites are welcome to link to the UK Web Archive.

To use a plain text link, simply copy and paste the following code below onto your page. Please customise the text between > and < to suit your own house style of citation:

    <div style=...><a href="http://www.webarchive.org.uk/">Click here for the UK Web Archive</a></div>

To use a link that has the UK Web Archive logo, then copy and paste this code:

    <div style=...><a href="http://www.webarchive.org.uk/"><img alt="UK Web Archive" src="https://www.webarchive.org.uk/en/ukwa/img/ukwa-logo-60px.jpg"></img></a></div>

## Technical Background

Before the 2013 [Legal Deposit](https://www.bl.uk/legal-deposit) regulations came into force, websites were gathered for the UK Web Archive strictly on a by-permission-only basis using the Web Curator Tool (WCT) which was developed collaboratively by the National Library of New Zealand and the British Library, under the auspices of the International Internet Preservation Consortium. [WCT is an open-source software](http://dia-nz.github.io/webcurator/), freely available under the terms of the Apache Public License. 

Due to the increase volume of continual crawling activity required to meet our Legal Deposit responsibilities, we have moved to different crawl tools. Like WCT, we use the core [Heritrix](https://github.com/internetarchive/heritrix3) archival crawler software, developed by the Internet Archive, but as part of a different suite of lifecycle management tools. All of these tools are available for re-use via [our GitHub organisation](https://github.com/ukwa).
---
